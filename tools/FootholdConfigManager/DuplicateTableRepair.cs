namespace FootholdConfigManager;

internal readonly record struct DefaultedPlayerValue(string Table, string Key, string PlayerValue);

internal sealed class DuplicateTableRepairResult
{
    public HashSet<string> HandledTables { get; } = new(StringComparer.Ordinal);
    public List<string> PreservedWholeTables { get; } = new();
    public List<DefaultedPlayerValue> DefaultedPlayerValues { get; } = new();
}

internal static class DuplicateTableRepair
{
    public static IReadOnlyList<string> FindDirectDuplicateTableKeys(ConfigDocument document)
    {
        return GetDirectTableEntries(document)
            .GroupBy(entry => entry.DisplayKey, StringComparer.Ordinal)
            .Where(group => group.Count() > 1)
            .Select(group => group.First().ParentKey)
            .Distinct(StringComparer.Ordinal)
            .ToList();
    }

    public static DuplicateTableRepairResult ApplyToIncoming(
        ConfigDocument playerDocument,
        ConfigDocument? previousCleanDocument,
        ConfigDocument incomingDocument)
    {
        var result = new DuplicateTableRepairResult();
        var cleanIncomingDocument = ConfigDocument.Load(incomingDocument.Path);

        foreach (var table in FindDirectDuplicateTableKeys(playerDocument))
        {
            var playerRows = GetEffectiveRows(playerDocument, table);
            var previousRows = previousCleanDocument is null
                ? new Dictionary<string, ConfigEntry>(StringComparer.Ordinal)
                : GetEffectiveRows(previousCleanDocument, table);

            if (!incomingDocument.TryGetTableBlockText(table, out _) ||
                FindDirectDuplicateTableKeys(incomingDocument).Contains(table, StringComparer.Ordinal))
            {
                PreserveWholePlayerTableOrDefault(
                    playerDocument,
                    previousCleanDocument,
                    cleanIncomingDocument,
                    incomingDocument,
                    table,
                    playerRows,
                    previousRows,
                    result);
                continue;
            }

            try
            {
                OverlayPlayerValues(incomingDocument, table, playerRows, previousRows, previousCleanDocument is not null);
                var errors = incomingDocument.Validate();
                if (errors.Count > 0)
                {
                    throw new InvalidOperationException(string.Join(Environment.NewLine, errors.Take(8)));
                }

                incomingDocument.MaterializePendingEdits();
                result.HandledTables.Add(table);
            }
            catch
            {
                PreserveWholePlayerTableOrDefault(
                    playerDocument,
                    previousCleanDocument,
                    cleanIncomingDocument,
                    incomingDocument,
                    table,
                    playerRows,
                    previousRows,
                    result);
            }
        }

        return result;
    }

    public static DuplicateTableRepairResult RepairForSave(
        ConfigDocument playerDocument,
        ConfigDocument outputDocument,
        ConfigDocument? cleanDocument)
    {
        var result = new DuplicateTableRepairResult();
        var cleanDuplicateTables = cleanDocument is null
            ? new HashSet<string>(StringComparer.Ordinal)
            : FindDirectDuplicateTableKeys(cleanDocument).ToHashSet(StringComparer.Ordinal);

        foreach (var table in FindDirectDuplicateTableKeys(playerDocument))
        {
            var playerRows = GetEffectiveRows(playerDocument, table);
            try
            {
                if (cleanDocument is not null &&
                    !cleanDuplicateTables.Contains(table) &&
                    cleanDocument.TryGetTableBlockText(table, out _))
                {
                    if (!outputDocument.ReplaceTableBodyFrom(cleanDocument, table))
                    {
                        throw new InvalidOperationException("Could not copy the clean table body for " + table + ".");
                    }

                    var cleanRows = GetEffectiveRows(cleanDocument, table);
                    OverlayPlayerValues(outputDocument, table, playerRows, cleanRows, hasPreviousClean: true);
                }
                else
                {
                    RemoveEarlierDuplicateRows(outputDocument, table);
                }

                EnsureEffectiveRowsPreserved(outputDocument, table, playerRows);
                var errors = outputDocument.Validate();
                if (errors.Count > 0)
                {
                    throw new InvalidOperationException(string.Join(Environment.NewLine, errors.Take(8)));
                }

                outputDocument.MaterializePendingEdits();
                result.HandledTables.Add(table);
            }
            catch
            {
                if (!outputDocument.ReplaceTableBodyFrom(playerDocument, table) ||
                    outputDocument.Validate().Count > 0)
                {
                    throw new InvalidOperationException("Could not preserve the complete player table " + table + ".");
                }

                result.HandledTables.Add(table);
                result.PreservedWholeTables.Add(table);
            }
        }

        return result;
    }

    private static IEnumerable<ConfigEntry> GetDirectTableEntries(ConfigDocument document)
    {
        return document.Entries.Where(entry =>
            !string.IsNullOrWhiteSpace(entry.ParentKey) &&
            !entry.ParentKey.Contains(".", StringComparison.Ordinal));
    }

    private static Dictionary<string, ConfigEntry> GetEffectiveRows(ConfigDocument document, string table)
    {
        return GetDirectTableEntries(document)
            .Where(entry => entry.ParentKey.Equals(table, StringComparison.Ordinal))
            .GroupBy(entry => entry.Key, StringComparer.Ordinal)
            .ToDictionary(
                group => group.Key,
                group => group.OrderBy(entry => entry.LineIndex).Last(),
                StringComparer.Ordinal);
    }

    private static void OverlayPlayerValues(
        ConfigDocument incomingDocument,
        string table,
        IReadOnlyDictionary<string, ConfigEntry> playerRows,
        IReadOnlyDictionary<string, ConfigEntry> previousRows,
        bool hasPreviousClean)
    {
        var incomingRows = GetEffectiveRows(incomingDocument, table);
        var template = incomingRows.Values.OrderBy(entry => entry.LineIndex).FirstOrDefault();

        foreach (var playerRow in playerRows.Values.OrderBy(entry => entry.LineIndex))
        {
            var preserveValue = !hasPreviousClean ||
                                !previousRows.TryGetValue(playerRow.Key, out var previousRow) ||
                                !playerRow.ValueText.Equals(previousRow.ValueText, StringComparison.Ordinal);
            if (!preserveValue)
            {
                continue;
            }

            if (incomingRows.TryGetValue(playerRow.Key, out var incomingRow))
            {
                incomingRow.ValueText = playerRow.ValueText;
                continue;
            }

            if (template is null)
            {
                throw new InvalidOperationException("The clean table has no row template for " + table + ".");
            }

            incomingRows[playerRow.Key] = incomingDocument.AddTableEntry(
                table,
                playerRow.Key,
                playerRow.ValueText,
                template);
        }
    }

    private static void RemoveEarlierDuplicateRows(ConfigDocument document, string table)
    {
        var earlierRows = GetDirectTableEntries(document)
            .Where(entry => entry.ParentKey.Equals(table, StringComparison.Ordinal))
            .GroupBy(entry => entry.Key, StringComparer.Ordinal)
            .SelectMany(group => group.OrderBy(entry => entry.LineIndex).SkipLast(1))
            .OrderByDescending(entry => entry.LineIndex)
            .ToList();

        foreach (var entry in earlierRows)
        {
            document.RemoveEntry(entry);
        }
    }

    private static void EnsureEffectiveRowsPreserved(
        ConfigDocument document,
        string table,
        IReadOnlyDictionary<string, ConfigEntry> playerRows)
    {
        var repairedRows = GetEffectiveRows(document, table);
        foreach (var playerRow in playerRows.Values)
        {
            if (!repairedRows.TryGetValue(playerRow.Key, out var repairedRow) ||
                !repairedRow.ValueText.Equals(playerRow.ValueText, StringComparison.Ordinal))
            {
                throw new InvalidOperationException("Could not preserve " + table + "." + playerRow.Key + ".");
            }
        }
    }

    private static void PreserveWholePlayerTableOrDefault(
        ConfigDocument playerDocument,
        ConfigDocument? previousCleanDocument,
        ConfigDocument cleanIncomingDocument,
        ConfigDocument incomingDocument,
        string table,
        IReadOnlyDictionary<string, ConfigEntry> playerRows,
        IReadOnlyDictionary<string, ConfigEntry> previousRows,
        DuplicateTableRepairResult result)
    {
        var preservedWholeTable = incomingDocument.TryGetTableBlockText(table, out _)
            ? incomingDocument.ReplaceTableBodyFrom(playerDocument, table)
            : incomingDocument.AppendTableBlockFrom(playerDocument, table);
        if (preservedWholeTable && incomingDocument.Validate().Count == 0)
        {
            result.HandledTables.Add(table);
            result.PreservedWholeTables.Add(table);
            return;
        }

        bool cleanTableRestored;
        if (cleanIncomingDocument.TryGetTableBlockText(table, out _))
        {
            cleanTableRestored = incomingDocument.ReplaceTableBodyFrom(cleanIncomingDocument, table);
        }
        else
        {
            cleanTableRestored = !incomingDocument.TryGetTableBlockText(table, out _) ||
                                 incomingDocument.RemoveTableBlock(table);
        }

        if (!cleanTableRestored || incomingDocument.Validate().Count > 0)
        {
            throw new InvalidOperationException("Could not restore the clean table state for " + table + ".");
        }

        result.HandledTables.Add(table);
        foreach (var playerRow in playerRows.Values.OrderBy(entry => entry.LineIndex))
        {
            var wasCustomized = previousCleanDocument is null ||
                                !previousRows.TryGetValue(playerRow.Key, out var previousRow) ||
                                !playerRow.ValueText.Equals(previousRow.ValueText, StringComparison.Ordinal);
            if (wasCustomized)
            {
                result.DefaultedPlayerValues.Add(new DefaultedPlayerValue(table, playerRow.Key, playerRow.ValueText));
            }
        }
    }
}
