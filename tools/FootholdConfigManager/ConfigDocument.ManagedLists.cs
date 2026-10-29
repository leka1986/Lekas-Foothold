namespace FootholdConfigManager;

internal sealed partial class ConfigDocument
{
    private string? _managedListError;
    // Migration catalog mirrors Zone Commander's internal warehouse-only aircraft registry.
    // Never expose these as player choices or require them in the player's aircraft lists.
    private static readonly HashSet<string> AiAircraftMigrationValues = new(StringComparer.Ordinal)
    {
        "A-50",
        "AH-1W",
        "An-26B",
        "An-30M",
        "B-1B",
        "B-52H",
        "E-2C",
        "E-3A",
        "F-15E",
        "F-16A MLU",
        "F/A-18A",
        "IL-76MD",
        "Ka-27",
        "KC-135",
        "KC135MPRS",
        "Mi-24V",
        "Mi-28N",
        "MiG-23MLD",
        "MiG-25PD",
        "MiG-27K",
        "MiG-31",
        "Mirage-F1AD",
        "Mirage-F1AZ",
        "Mirage-F1B",
        "Mirage-F1BD",
        "Mirage-F1BQ",
        "Mirage-F1C",
        "Mirage-F1C-200",
        "Mirage-F1CG",
        "Mirage-F1CH",
        "Mirage-F1CJ",
        "Mirage-F1CK",
        "Mirage-F1CR",
        "Mirage-F1CT",
        "Mirage-F1CZ",
        "Mirage-F1DDA",
        "Mirage-F1ED",
        "Mirage-F1EDA",
        "Mirage-F1EH",
        "Mirage-F1EQ",
        "Mirage-F1M-CE",
        "Mirage-F1M-EE",
        "MQ-9 Reaper",
        "S-3B Tanker",
        "SA342Mistral",
        "Su-17M4",
        "Su-24M",
        "Su-24MR",
        "Su-34",
        "Tornado IDS",
        "Tu-22M3",
        "Tu-95MS",
        "UH-60A",
        "Bell-47",
        "F-14A",
        "A-20G",
        "B-17G",
        "C-47",
        "Ju-88A4",
    };
    private static readonly HashSet<string> AiAircraftMigrationTargets = new(StringComparer.Ordinal)
    {
        "allowedPlanesModern", "allowedPlanesRedModern", "allowedPlanes",
        "allowedPlanesSharedColdwarPvP", "allowedPlanesBlueColdwarPvP", "allowedPlanesRed",
        "allowedPlanesRedColdwarPvP", "allowedPlanesVietnam", "allowedPlanesSharedVietnamPvP",
        "allowedPlanesBlueVietnamPvP", "allowedPlanesRedVietnam", "allowedPlanesRedVietnamPvP",
        "restockAircraft", "AllowedWW2Planes", "AllowedWW2RedPlanes"
    };


    private void ConfigureManagedStringLists()
    {
        _managedListError = null;
        foreach (var source in StringListTables)
        {
            if (source.Key == "AIOnlyAircraft")
            {
                // Old generated tables retire; an explicit plain Config override stays internal.
                if (source.ManagedTargetKeys.Length == 0)
                    foreach (var target in StringListTables)
                        if (AiAircraftMigrationTargets.Contains(target.Key)) target.ManagedSource = source;
                continue;
            }
            foreach (var key in source.ManagedTargetKeys)
            {
                var target = StringListTables.FirstOrDefault(t => t.Key.Equals(key, StringComparison.Ordinal));
                if (target is null || ReferenceEquals(target, source) || target.ManagedSource is not null)
                {
                    _managedListError = source.Key + ": invalid or duplicate managedTargets entry: " + key;
                    continue;
                }
                target.ManagedSource = source;
                target.ManagedVisibilityConditions = string.IsNullOrWhiteSpace(target.GuiVisibleWhen)
                    ? Array.Empty<(string, List<string>)>() : ConfigConditions.Parse(target.GuiVisibleWhen);
            }
        }
    }

    // The source table owns the single lookup. Hidden targets return before reading its rows.
    internal IReadOnlySet<string>? GetManagedStringListValues(ConfigStringListTable table)
    {
        if (AiAircraftMigrationTargets.Contains(table.Key))
            return table.ManagedSource is { Key: "AIOnlyAircraft" } extra
                ? extra.ManagedValues ??= AiAircraftMigrationValues.Concat(extra.Items.Select(item => item.Value)).ToHashSet(StringComparer.Ordinal)
                : AiAircraftMigrationValues;
        var source = table.ManagedSource;
        if (source is null || !ConfigConditions.Matches(this, table.ManagedVisibilityConditions)) return null;
        return source.ManagedValues ??= source.Items.Select(item => item.Value).ToHashSet(StringComparer.Ordinal);
    }

    internal bool NeedsManagedStringListPreparation()
    {
        if (_managedListError is not null) return false;
        foreach (var table in StringListTables)
        {
            if (table.Key == "AIOnlyAircraft" && table.ManagedTargetKeys.Length > 0) return true;
            var values = GetManagedStringListValues(table);
            if (values is null || values.Count == 0) continue;
            if (AiAircraftMigrationTargets.Contains(table.Key))
            {
                if (table.Items.Concat(table.CommentedItems).Any(item => values.Contains(item.Value))) return true;
                continue;
            }
            var active = table.Items.Select(item => item.Value).ToHashSet(StringComparer.Ordinal);
            if (values.Any(value => !active.Contains(value))) return true;
        }
        return false;
    }

    internal bool PrepareManagedStringLists()
    {
        if (_managedListError is not null) return false;
        var changed = false;
        foreach (var table in StringListTables)
        {
            var values = GetManagedStringListValues(table);
            if (values is null || values.Count == 0) continue;
            if (AiAircraftMigrationTargets.Contains(table.Key))
            {
                // Removing a token can rebuild row objects; reacquire after that invalidation.
                while (table.Items.FirstOrDefault(item => values.Contains(item.Value)) is { } item)
                {
                    RemoveStringListItem(table, item, RequiredValueResolution.Empty);
                    changed = true;
                }
                while (table.CommentedItems.FirstOrDefault(item => values.Contains(item.Value)) is { } item)
                {
                    RemoveCommentedStringListItemCore(table, item);
                    changed = true;
                }
                continue;
            }
            var active = table.Items.Select(item => item.Value).ToHashSet(StringComparer.Ordinal);
            foreach (var value in values)
            {
                if (!active.Add(value)) continue;
                ActivateStringListValue(table, value);
                changed = true;
            }
        }
        var legacy = StringListTables.FirstOrDefault(table => table.Key == "AIOnlyAircraft" && table.ManagedTargetKeys.Length > 0);
        if (legacy is not null)
        {
            var start = legacy.StartLineIndex;
            while (start > 0 && _lines[start - 1].TrimStart().StartsWith("--", StringComparison.Ordinal)) start--;
            var count = legacy.EndLineIndex - start + 1;
            _lines.RemoveRange(start, count);
            StringListTables.Remove(legacy);
            ShiftLineIndexes(start, -count);
            _hasStructuralChanges = true;
            changed = true;
        }
        return changed;
    }
}
