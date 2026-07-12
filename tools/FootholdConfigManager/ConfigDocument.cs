using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;

namespace FootholdConfigManager;

internal enum ConfigValueKind
{
    Boolean,
    Number,
    String,
    Raw
}

internal enum ConfigTupleFieldKind
{
    Boolean,
    Number,
    Choice,
    Raw
}

internal sealed class ConfigChoice
{
    public ConfigChoice(string display, string literal)
    {
        Display = display;
        Literal = literal;
    }

    public string Display { get; }
    public string Literal { get; }
}

internal sealed class ConfigTupleField
{
    public ConfigTupleField(string name, ConfigTupleFieldKind kind, string? key = null)
    {
        Name = name;
        Kind = kind;
        Key = key;
    }

    public string Name { get; }
    public ConfigTupleFieldKind Kind { get; }
    public string? Key { get; }
    public List<ConfigChoice> Choices { get; } = new();
}

internal sealed class ConfigStringListItem
{
    public required string Value { get; set; }
    public required int LineIndex { get; set; }
    public required int StartIndex { get; set; }
    public required int Length { get; set; }
    public bool IsCommented { get; set; }
}

internal sealed class ConfigStringListTable
{
    public required string Key { get; init; }
    public required string Section { get; init; }
    public required string Description { get; init; }
    public string? GuiLabel { get; init; }
    public string? GuiEditor { get; init; }
    public string? GuiVisibleWhen { get; init; }
    public string? InstallPolicy { get; init; }
    public required int StartLineIndex { get; set; }
    public required int EndLineIndex { get; set; }
    public List<ConfigStringListItem> Items { get; } = new();
    public List<ConfigStringListItem> CommentedItems { get; } = new();
}

internal sealed class ConfigStageRow
{
    public required string Difficulty { get; init; }
    public required int LineIndex { get; set; }
    public required string Indent { get; init; }
    public required string Suffix { get; init; }
    public required decimal Player { get; set; }
    public required decimal Amount { get; set; }
    public decimal OriginalPlayer { get; private set; }
    public decimal OriginalAmount { get; private set; }

    public bool IsChanged => Player != OriginalPlayer || Amount != OriginalAmount;

    public void AcceptSavedValue()
    {
        OriginalPlayer = Player;
        OriginalAmount = Amount;
    }

    public string RenderLine()
    {
        return Indent + "{ player = " + FormatDecimal(Player) + ", amount = " + FormatDecimal(Amount) + " }" + Suffix;
    }

    internal static string FormatDecimal(decimal value)
    {
        return value.ToString("0.###", CultureInfo.InvariantCulture);
    }
}

internal sealed class ConfigStageTable
{
    public required string Key { get; init; }
    public required string Section { get; init; }
    public required string Description { get; init; }
    public string? GuiLabel { get; init; }
    public string? LinkedSettingKey { get; init; }
    public string? GuiVisibleWhen { get; init; }
    public required int StartLineIndex { get; set; }
    public required int EndLineIndex { get; set; }
    public List<ConfigStageRow> Rows { get; } = new();
}

internal sealed class ConfigEntry
{
    public required int LineIndex { get; set; }
    public required string Section { get; init; }
    public required string Key { get; init; }
    public required string DisplayKey { get; init; }
    public required string ParentKey { get; init; }
    public required string ParentDescription { get; init; }
    public required string Description { get; init; }
    public string InlineComment { get; init; } = "";
    public required string Prefix { get; init; }
    public required string Suffix { get; init; }
    public required string RawValue { get; init; }
    public required ConfigValueKind Kind { get; init; }
    public required char QuoteChar { get; init; }
    public required bool InferredAdvanced { get; init; }
    public int EndLineIndex { get; set; }
    public bool IsLongText { get; init; }
    public List<ConfigChoice> Choices { get; } = new();
    public List<ConfigTupleField> TupleFields { get; } = new();
    public string? LabelOverride { get; private set; }
    public string? GuiLabel { get; init; }
    public string? ParentGuiEditor { get; init; }
    public string? ParentGuiFields { get; init; }
    public string? ParentGuiUntickRowsWhen { get; init; }
    public string? ParentGuiConfirmUntickRowsWhen { get; init; }
    public string? ParentGuiConfirmSetRowsByEra { get; init; }
    public string? ParentGuiRowLabel { get; init; }
    public string? ParentGuiVisibleWhen { get; init; }
    public string? GuiVisibleWhen { get; init; }
    public string? CategoryOverride { get; private set; }
    public string? HelpOverride { get; private set; }
    public string? ControlTypeOverride { get; private set; }
    public bool? AdvancedOverride { get; private set; }
    public string? GuiValidValues { get; init; }

    public string OriginalValueText { get; private set; } = "";
    public string ValueText { get; set; } = "";

    public bool IsChanged => !StringComparer.Ordinal.Equals(ValueText, OriginalValueText);

    public bool IsAdvanced => AdvancedOverride ?? InferredAdvanced;

    public string EffectiveCategory => string.IsNullOrWhiteSpace(CategoryOverride) ? Section : CategoryOverride;

    public string TypeLabel
    {
        get
        {
            if (IsSideMultiplier)
            {
                return "Speed";
            }

            if (TupleFields.Count > 0)
            {
                return "Table row";
            }

            if (Choices.Count > 0)
            {
                return "Choice";
            }

            return Kind switch
            {
                ConfigValueKind.Boolean => "Boolean",
                ConfigValueKind.Number => "Number",
                ConfigValueKind.String => "Text",
                _ => "Raw Lua"
            };
        }
    }

    public string DisplayName
    {
        get
        {
            if (!string.IsNullOrWhiteSpace(ParentKey))
            {
                return LabelOverride ?? GuiLabel ?? $"{HumanizeKey(ParentKey)}: {Key}";
            }

            return LabelOverride ?? GuiLabel ?? HumanizeKey(Key);
        }
    }

    public bool IsSideMultiplier =>
        DisplayKey.Equals("GlobalSettings.difficultyScaling", StringComparison.Ordinal) ||
        DisplayKey.Equals("GlobalSettings.supplyDifficultyScaling", StringComparison.Ordinal);

    public string FriendlyValueText
    {
        get
        {
            if (TryGetSideMultipliers(out var red, out var blue))
            {
                return $"RED {DescribeMultiplier(red)} / BLUE {DescribeMultiplier(blue)}";
            }

            if (TupleFields.Count > 0)
            {
                var values = GetTupleValues();
                var parts = new List<string>();
                for (var i = 0; i < Math.Min(values.Count, TupleFields.Count); i++)
                {
                    parts.Add($"{TupleFields[i].Name}: {FormatTupleDisplayValue(TupleFields[i], values[i])}");
                }

                return string.Join("; ", parts);
            }

            if (Kind == ConfigValueKind.Boolean)
            {
                return ValueText.Equals("true", StringComparison.OrdinalIgnoreCase) ? "Yes" : "No";
            }

            return ValueText;
        }
    }

    public string EffectiveDescription
    {
        get
        {
            if (!string.IsNullOrWhiteSpace(HelpOverride))
            {
                return HelpOverride;
            }

            if (string.IsNullOrWhiteSpace(ParentDescription))
            {
                return Description;
            }

            if (string.IsNullOrWhiteSpace(Description))
            {
                return ParentDescription;
            }

            return ParentDescription + Environment.NewLine + Description;
        }
    }

    public void InitializeValueText(string valueText)
    {
        OriginalValueText = valueText;
        ValueText = valueText;
    }

    public void AcceptSavedValue()
    {
        OriginalValueText = ValueText;
    }

    public string RenderLine()
    {
        return Prefix + FormatValue() + Suffix;
    }

    public List<string> RenderLines()
    {
        if (!IsLongText)
        {
            return new List<string> { RenderLine() };
        }

        var normalized = ValueText.Replace("\r\n", "\n", StringComparison.Ordinal).Replace('\r', '\n');
        var parts = normalized.Split('\n');
        var lines = new List<string> { Prefix.TrimEnd() };

        if (parts.Length == 0)
        {
            lines.Add("[[]]" + Suffix);
            return lines;
        }

        if (parts.Length == 1)
        {
            lines.Add("[[" + parts[0] + "]]" + Suffix);
            return lines;
        }

        lines.Add("[[" + parts[0]);
        for (var i = 1; i < parts.Length - 1; i++)
        {
            lines.Add(parts[i]);
        }

        lines.Add(parts[^1] + "]]" + Suffix);
        return lines;
    }

    public string FormatValue()
    {
        var text = ValueText.Trim();
        var choice = FindChoice(text);
        if (choice is not null)
        {
            return choice.Literal;
        }

        return Kind switch
        {
            ConfigValueKind.Boolean => FormatBoolean(text),
            ConfigValueKind.Number => FormatNumber(text),
            ConfigValueKind.String => QuoteLuaString(ValueText, QuoteChar),
            _ => FormatRaw(text)
        };
    }

    public string? Validate()
    {
        try
        {
            var formatted = FormatValue();
            if (Kind == ConfigValueKind.Raw && !HasBalancedBraces(formatted))
            {
                return "Raw Lua value has unbalanced braces.";
            }

            if (IsLongText && ValueText.Contains("]]", StringComparison.Ordinal))
            {
                return "Message text cannot contain the Lua long-bracket terminator ]].";
            }
        }
        catch (Exception ex)
        {
            return ex.Message;
        }

        return null;
    }

    public bool TryGetSideMultipliers(out decimal red, out decimal blue)
    {
        red = 1m;
        blue = 1m;
        if (!IsSideMultiplier)
        {
            return false;
        }

        var redMatch = Regex.Match(ValueText, @"\[1\]\s*=\s*(?<value>-?\d+(?:\.\d+)?)");
        var blueMatch = Regex.Match(ValueText, @"\[2\]\s*=\s*(?<value>-?\d+(?:\.\d+)?)");
        return redMatch.Success &&
               blueMatch.Success &&
               decimal.TryParse(redMatch.Groups["value"].Value, NumberStyles.Float, CultureInfo.InvariantCulture, out red) &&
               decimal.TryParse(blueMatch.Groups["value"].Value, NumberStyles.Float, CultureInfo.InvariantCulture, out blue);
    }

    public void SetSideMultipliers(decimal red, decimal blue)
    {
        ValueText = "{ [1]=" + FormatDecimal(red) + ", [2]=" + FormatDecimal(blue) + " }";
    }

    public List<string> GetTupleValues()
    {
        var text = ValueText.Trim();
        if (!text.StartsWith("{", StringComparison.Ordinal) || !text.EndsWith("}", StringComparison.Ordinal))
        {
            return new List<string>();
        }

        var values = SplitLuaValues(text[1..^1]).Select(value => value.Trim()).ToList();
        if (TupleFields.All(field => string.IsNullOrWhiteSpace(field.Key)))
        {
            return values;
        }

        var valuesByKey = new Dictionary<string, string>(StringComparer.Ordinal);
        foreach (var value in values)
        {
            if (TrySplitNamedTupleValue(value, out var key, out var fieldValue))
            {
                valuesByKey[key] = fieldValue;
            }
        }

        return TupleFields
            .Select(field => field.Key is not null && valuesByKey.TryGetValue(field.Key, out var value) ? value : "")
            .ToList();
    }

    public void SetTupleValues(IReadOnlyList<string> values)
    {
        if (TupleFields.Any(field => !string.IsNullOrWhiteSpace(field.Key)))
        {
            var parts = new List<string>();
            for (var i = 0; i < TupleFields.Count; i++)
            {
                var field = TupleFields[i];
                var value = i < values.Count ? values[i].Trim() : "";
                parts.Add((field.Key ?? field.Name) + " = " + value);
            }

            ValueText = "{ " + string.Join(", ", parts) + " }";
            return;
        }

        ValueText = "{ " + string.Join(", ", values.Select(value => value.Trim())) + " }";
    }

    public void ApplyMetadata(GuiMetadataEntry metadata)
    {
        LabelOverride = NormalizeNullable(metadata.Label);
        CategoryOverride = NormalizeNullable(metadata.Category);
        HelpOverride = NormalizeNullable(metadata.Help);
        ControlTypeOverride = NormalizeNullable(metadata.ControlType);
        AdvancedOverride = metadata.Advanced;

        if (metadata.Choices.Count == 0)
        {
            return;
        }

        Choices.Clear();
        foreach (var choice in metadata.Choices)
        {
            if (string.IsNullOrWhiteSpace(choice.Display))
            {
                continue;
            }

            var literal = string.IsNullOrWhiteSpace(choice.Literal) ? choice.Display : choice.Literal;
            if (Kind == ConfigValueKind.String &&
                !literal.StartsWith("\"", StringComparison.Ordinal) &&
                !literal.StartsWith("'", StringComparison.Ordinal))
            {
                literal = QuoteLuaString(literal, QuoteChar);
            }

            Choices.Add(new ConfigChoice(choice.Display.Trim(), literal.Trim()));
        }
        UseChoiceDisplayForCurrentValue();
    }

    private static string? NormalizeNullable(string? value)
    {
        return string.IsNullOrWhiteSpace(value) ? null : value.Trim();
    }

    private ConfigChoice? FindChoice(string text)
    {
        return Choices.FirstOrDefault(choice =>
            StringComparer.OrdinalIgnoreCase.Equals(choice.Display, text) ||
            StringComparer.OrdinalIgnoreCase.Equals(choice.Literal, text) ||
            StringComparer.OrdinalIgnoreCase.Equals(UnquoteLuaString(choice.Literal), text));
    }

    public void UseChoiceDisplayForCurrentValue()
    {
        var choice = FindChoice(ValueText);
        if (choice is not null)
        {
            InitializeValueText(choice.Display);
        }
    }

    internal static List<string> SplitLuaValues(string text)
    {
        var values = new List<string>();
        var start = 0;
        var depth = 0;
        var inQuote = false;
        var quote = '\0';
        var escaped = false;

        for (var i = 0; i < text.Length; i++)
        {
            var ch = text[i];
            if (inQuote)
            {
                if (escaped)
                {
                    escaped = false;
                    continue;
                }

                if (ch == '\\')
                {
                    escaped = true;
                    continue;
                }

                if (ch == quote)
                {
                    inQuote = false;
                }

                continue;
            }

            if (ch is '"' or '\'')
            {
                inQuote = true;
                quote = ch;
                continue;
            }

            if (ch == '{')
            {
                depth++;
            }
            else if (ch == '}')
            {
                depth--;
            }
            else if (ch == ',' && depth == 0)
            {
                values.Add(text[start..i]);
                start = i + 1;
            }
        }

        values.Add(text[start..]);
        return values;
    }

    private static bool TrySplitNamedTupleValue(string text, out string key, out string value)
    {
        key = "";
        value = "";
        var match = Regex.Match(text.Trim(), @"^(?<key>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*(?<value>.*)$");
        if (!match.Success)
        {
            return false;
        }

        key = match.Groups["key"].Value;
        value = match.Groups["value"].Value.Trim();
        return true;
    }

    private static string FormatTupleDisplayValue(ConfigTupleField field, string value)
    {
        if (field.Kind == ConfigTupleFieldKind.Boolean)
        {
            return value.Equals("true", StringComparison.OrdinalIgnoreCase) ? "Yes" : "No";
        }

        var choice = field.Choices.FirstOrDefault(choice =>
            choice.Literal.Equals(value, StringComparison.OrdinalIgnoreCase) ||
            choice.Display.Equals(value, StringComparison.OrdinalIgnoreCase));
        return choice?.Display ?? value;
    }

    private static string DescribeMultiplier(decimal value)
    {
        if (value == 1m)
        {
            return "normal";
        }

        if (value > 1m)
        {
            return $"{Math.Round((value - 1m) * 100m)}% slower";
        }

        return $"{Math.Round((1m - value) * 100m)}% faster";
    }

    private static string FormatDecimal(decimal value)
    {
        return value.ToString("0.###", CultureInfo.InvariantCulture);
    }

    private static string HumanizeKey(string key)
    {
        var text = Regex.Replace(key, @"[_\.]+", " ");
        text = Regex.Replace(text, @"(?<=[a-z0-9])(?=[A-Z])", " ");
        return CultureInfo.InvariantCulture.TextInfo.ToTitleCase(text.ToLowerInvariant())
            .Replace("Ai ", "AI ", StringComparison.Ordinal)
            .Replace("Ctld", "CTLD", StringComparison.Ordinal)
            .Replace("Csar", "CSAR", StringComparison.Ordinal)
            .Replace("Pve", "PVE", StringComparison.Ordinal)
            .Replace("Ewrs", "EWRS", StringComparison.Ordinal)
            .Replace("Samon Mfd", "SAM On MFD", StringComparison.Ordinal)
            .Replace("Sa10", "SA-10", StringComparison.Ordinal)
            .Replace("Sa11", "SA-11", StringComparison.Ordinal)
            .Replace("Sa15", "SA-15", StringComparison.Ordinal)
            .Replace("Tor M2", "Tor M2", StringComparison.Ordinal)
            .Replace("A10", "A-10", StringComparison.Ordinal)
            .Replace("C130", "C-130", StringComparison.Ordinal);
    }

    private static string FormatBoolean(string text)
    {
        if (StringComparer.OrdinalIgnoreCase.Equals(text, "true"))
        {
            return "true";
        }

        if (StringComparer.OrdinalIgnoreCase.Equals(text, "false"))
        {
            return "false";
        }

        throw new InvalidOperationException("Boolean values must be true or false.");
    }

    private static string FormatNumber(string text)
    {
        if (!double.TryParse(text, NumberStyles.Float, CultureInfo.InvariantCulture, out _))
        {
            throw new InvalidOperationException("Number values must use Lua-compatible numeric text.");
        }

        return text;
    }

    private static string FormatRaw(string text)
    {
        if (string.IsNullOrWhiteSpace(text))
        {
            throw new InvalidOperationException("Raw Lua value cannot be empty.");
        }

        return text;
    }

    private static bool HasBalancedBraces(string text)
    {
        var depth = 0;
        var inQuote = false;
        var quote = '\0';
        var escaped = false;

        foreach (var ch in text)
        {
            if (inQuote)
            {
                if (escaped)
                {
                    escaped = false;
                    continue;
                }

                if (ch == '\\')
                {
                    escaped = true;
                    continue;
                }

                if (ch == quote)
                {
                    inQuote = false;
                }

                continue;
            }

            if (ch is '"' or '\'')
            {
                inQuote = true;
                quote = ch;
                continue;
            }

            if (ch == '{')
            {
                depth++;
            }
            else if (ch == '}')
            {
                depth--;
                if (depth < 0)
                {
                    return false;
                }
            }
        }

        return depth == 0;
    }

    private static string QuoteLuaString(string text, char quoteChar)
    {
        if (text.Length >= 2 && ((text[0] == '"' && text[^1] == '"') || (text[0] == '\'' && text[^1] == '\'')))
        {
            return text;
        }

        quoteChar = quoteChar is '\'' ? '\'' : '"';
        var escaped = text.Replace("\\", "\\\\", StringComparison.Ordinal)
            .Replace(quoteChar.ToString(), "\\" + quoteChar, StringComparison.Ordinal);
        return quoteChar + escaped + quoteChar;
    }

    internal static string UnquoteLuaString(string text)
    {
        var trimmed = text.Trim();
        if (trimmed.Length < 2)
        {
            return trimmed;
        }

        var quote = trimmed[0];
        if ((quote != '"' && quote != '\'') || trimmed[^1] != quote)
        {
            return trimmed;
        }

        var body = trimmed[1..^1];
        return body.Replace("\\" + quote, quote.ToString(), StringComparison.Ordinal)
            .Replace("\\\\", "\\", StringComparison.Ordinal);
    }
}

internal sealed class ConfigDocument
{
    private sealed class TableContext
    {
        public required string Key { get; init; }
        public required string DisplayKey { get; init; }
        public required string Description { get; init; }
        public string? GuiEditor { get; init; }
        public string? GuiFields { get; init; }
        public string? GuiUntickRowsWhen { get; init; }
        public string? GuiConfirmUntickRowsWhen { get; init; }
        public string? GuiConfirmSetRowsByEra { get; init; }
        public string? GuiRowLabel { get; init; }
        public string? GuiVisibleWhen { get; init; }
    }

    private enum StringListLineIssue
    {
        None,
        MissingOpeningQuoteAfterSeparator,
        MissingClosingQuoteBeforeSeparator,
        UnfinishedString,
        MalformedTextAfterString
    }

    private static readonly Regex AssignmentRegex = new(
        @"^(?<lhs>\s*(?:[A-Za-z_][A-Za-z0-9_\.]*|\[[^\]]+\])\s*=\s*)(?<rest>.*)$",
        RegexOptions.Compiled);

    private static readonly Regex QuotedChoiceRegex = new(
        "\"([^\"]+)\"|'([^']+)'",
        RegexOptions.Compiled);

    private static readonly Regex NumberChoiceRegex = new(
        @"(?<number>\d+)\s*=\s*(?<name>[A-Za-z0-9 _\-/]+)",
        RegexOptions.Compiled);

    private static readonly Regex GuiAttributeRegex = new(
        "(?<name>[A-Za-z][A-Za-z0-9_]*)\\s*=\\s*(?:\"(?<dq>[^\"]*)\"|'(?<sq>[^']*)'|(?<bare>.*?)(?=\\s+[A-Za-z][A-Za-z0-9_]*\\s*=|\\s*$))",
        RegexOptions.Compiled | RegexOptions.IgnoreCase);

    private readonly List<string> _lines = new();
    private readonly Dictionary<string, string> _guiLabels = new(StringComparer.Ordinal);
    private readonly Dictionary<string, string> _guiInstallPolicies = new(StringComparer.Ordinal);
    private readonly Dictionary<string, string> _topLevelGuiInstallPolicies = new(StringComparer.Ordinal);
    private string _savedSnapshot = "";
    private bool _hasStructuralChanges;

    private ConfigDocument(string path, string newLine)
    {
        Path = path;
        NewLine = newLine;
    }

    public string Path { get; }
    public string NewLine { get; }
    public GuiMetadataStore Metadata { get; private set; } = new();
    public List<ConfigEntry> Entries { get; } = new();
    public List<ConfigStringListTable> StringListTables { get; } = new();
    public List<ConfigStageTable> StageTables { get; } = new();
    public List<string> LoadWarnings { get; } = new();
    public bool HasUnsavedChanges
    {
        get
        {
            if (Entries.Any(entry => entry.IsChanged) ||
                StageTables.Any(table => table.Rows.Any(row => row.IsChanged)))
            {
                return true;
            }

            if (!_hasStructuralChanges)
            {
                return false;
            }

            var hasChanges = !StringComparer.Ordinal.Equals(RenderCurrentText(), _savedSnapshot);
            if (!hasChanges)
            {
                _hasStructuralChanges = false;
            }

            return hasChanges;
        }
    }

    public static ConfigDocument Load(string path)
    {
        var text = File.ReadAllText(path, new UTF8Encoding(false, true));
        var newLine = text.Contains("\r\n", StringComparison.Ordinal) ? "\r\n" : "\n";
        var doc = new ConfigDocument(path, newLine);
        doc._lines.AddRange(Regex.Split(text, "\r\n|\n|\r"));
        var originalText = string.Join(newLine, doc._lines);
        var repairWarnings = doc.RepairMissingTopLevelTableClosers();
        if (repairWarnings.Count > 0)
        {
            var repairErrors = doc.ValidateClosedTableBlocks();
            repairErrors.AddRange(LuaSyntaxValidator.Validate(doc.RenderCurrentText(), path));
            if (repairErrors.Count > 0)
            {
                doc._lines.Clear();
                doc._lines.AddRange(Regex.Split(text, "\r\n|\n|\r"));
                repairWarnings.Clear();
            }
        }

        doc.Parse();
        doc.Metadata = GuiMetadataStore.LoadForConfig(path);
        doc.ApplyMetadata();
        if (repairWarnings.Count > 0)
        {
            doc.LoadWarnings.AddRange(repairWarnings);
            doc._savedSnapshot = originalText;
            doc._hasStructuralChanges = true;
        }
        else
        {
            doc._savedSnapshot = doc.RenderCurrentText();
        }

        return doc;
    }

    public string? GetGuiLabel(string key)
    {
        return _guiLabels.TryGetValue(key, out var label) ? label : null;
    }

    public string? GetInstallPolicy(string key)
    {
        return _guiInstallPolicies.TryGetValue(key, out var policy) ? policy : null;
    }

    public IEnumerable<string> GetTopLevelTableKeysWithInstallPolicy(string policy)
    {
        return _topLevelGuiInstallPolicies
            .Where(item => item.Value.Equals(policy, StringComparison.OrdinalIgnoreCase))
            .Select(item => item.Key);
    }

    public bool TryGetTableBlockText(string key, out string text)
    {
        text = "";
        if (!TryFindTableBlock(key, out var startLine, out var endLine))
        {
            return false;
        }

        text = string.Join("\n", _lines.Skip(startLine).Take(endLine - startLine + 1));
        return true;
    }

    public bool ReplaceTableBlockFrom(ConfigDocument sourceDocument, string key)
    {
        if (!sourceDocument.TryFindTableBlock(key, out var sourceStart, out var sourceEnd) ||
            !TryFindTableBlock(key, out var targetStart, out var targetEnd))
        {
            return false;
        }

        var replacement = sourceDocument._lines.Skip(sourceStart).Take(sourceEnd - sourceStart + 1).ToList();
        _lines.RemoveRange(targetStart, targetEnd - targetStart + 1);
        _lines.InsertRange(targetStart, replacement);
        Parse();
        ApplyMetadata();
        _hasStructuralChanges = true;
        return true;
    }

    public bool ReplaceTableBodyFrom(ConfigDocument sourceDocument, string key)
    {
        if (!sourceDocument.TryFindTableBlock(key, out var sourceStart, out var sourceEnd) ||
            !TryFindTableBlock(key, out var targetStart, out var targetEnd) ||
            sourceEnd <= sourceStart ||
            targetEnd <= targetStart)
        {
            return false;
        }

        var replacement = sourceDocument._lines.Skip(sourceStart + 1).Take(sourceEnd - sourceStart - 1).ToList();
        _lines.RemoveRange(targetStart + 1, targetEnd - targetStart - 1);
        _lines.InsertRange(targetStart + 1, replacement);
        Parse();
        ApplyMetadata();
        _hasStructuralChanges = true;
        return true;
    }

    public bool RewriteBucketStringListBodyFrom(ConfigDocument currentDocument, string key)
    {
        var targetTable = StringListTables.FirstOrDefault(table => table.Key.Equals(key, StringComparison.Ordinal));
        var currentTable = currentDocument.StringListTables.FirstOrDefault(table => table.Key.Equals(key, StringComparison.Ordinal));
        if (targetTable is null ||
            currentTable is null ||
            !TryFindTableBlock(key, out var targetStart, out var targetEnd) ||
            targetEnd <= targetStart)
        {
            return false;
        }

        var activeValues = GetStringListValuesInSourceOrder(currentTable.Items);
        var inactiveValues = GetStringListValuesInSourceOrder(currentTable.CommentedItems)
            .Where(value => !activeValues.Contains(value))
            .ToList();
        var closingLine = GetBucketStringListClosingLine(targetEnd);
        var replacement = BuildBucketStringListBody(targetTable, activeValues, inactiveValues);
        replacement.Add(closingLine);

        _lines.RemoveRange(targetStart + 1, targetEnd - targetStart);
        _lines.InsertRange(targetStart + 1, replacement);
        Parse();
        ApplyMetadata();
        _hasStructuralChanges = true;
        return true;
    }

    private List<string> BuildBucketStringListBody(
        ConfigStringListTable table,
        IReadOnlyList<string> activeValues,
        IReadOnlyList<string> inactiveValues)
    {
        var activeSet = activeValues.ToHashSet(StringComparer.Ordinal);
        var seen = new HashSet<string>(StringComparer.Ordinal);
        var lines = new List<string>();
        var indent = GetStringListIndent(table);

        for (var i = table.StartLineIndex + 1; i <= table.EndLineIndex && i < _lines.Count; i++)
        {
            var sourceLine = GetBucketStringListBodyLine(table, i);
            if (i == table.EndLineIndex && string.IsNullOrWhiteSpace(sourceLine))
            {
                continue;
            }

            var tokens = ReadBucketStringListLineTokens(sourceLine);
            if (tokens.Count > 0)
            {
                foreach (var token in tokens)
                {
                    if (seen.Add(token))
                    {
                        lines.Add(RenderBucketStringListLine(indent, token, activeSet.Contains(token)));
                    }
                }

                continue;
            }

            if (ShouldPreserveBucketStringListLine(sourceLine))
            {
                lines.Add(sourceLine);
            }
        }

        foreach (var value in activeValues)
        {
            if (seen.Add(value))
            {
                lines.Add(RenderBucketStringListLine(indent, value, isActive: true));
            }
        }

        foreach (var value in inactiveValues)
        {
            if (seen.Add(value))
            {
                lines.Add(RenderBucketStringListLine(indent, value, isActive: false));
            }
        }

        return lines;
    }

    private string GetBucketStringListBodyLine(ConfigStringListTable table, int lineIndex)
    {
        var line = _lines[lineIndex];
        if (lineIndex != table.EndLineIndex)
        {
            return line;
        }

        var braceIndex = line.IndexOf('}', StringComparison.Ordinal);
        return braceIndex >= 0 ? line[..braceIndex] : line;
    }

    private string GetBucketStringListClosingLine(int endLineIndex)
    {
        var line = _lines[endLineIndex];
        var braceIndex = line.IndexOf('}', StringComparison.Ordinal);
        if (braceIndex < 0)
        {
            return "}";
        }

        var beforeBrace = line[..braceIndex];
        if (string.IsNullOrWhiteSpace(beforeBrace))
        {
            return line;
        }

        var indent = Regex.Match(line, @"^\s*").Value;
        var afterBrace = line[(braceIndex + 1)..].TrimStart();
        return indent + "}" + (afterBrace.StartsWith(",", StringComparison.Ordinal) ? "," : "");
    }

    private static List<string> GetStringListValuesInSourceOrder(IEnumerable<ConfigStringListItem> items)
    {
        var values = new List<string>();
        var seen = new HashSet<string>(StringComparer.Ordinal);
        foreach (var value in items
                     .OrderBy(item => item.LineIndex)
                     .ThenBy(item => item.StartIndex)
                     .Select(item => item.Value))
        {
            if (seen.Add(value))
            {
                values.Add(value);
            }
        }

        return values;
    }

    private static List<string> ReadBucketStringListLineTokens(string line)
    {
        return ReadQuotedStringTokens(line)
            .Concat(ReadCommentedStringListTokens(line))
            .OrderBy(token => token.StartIndex)
            .Select(token => ConfigEntry.UnquoteLuaString(token.Text))
            .ToList();
    }

    private static bool ShouldPreserveBucketStringListLine(string line)
    {
        var trimmed = line.Trim();
        return string.IsNullOrWhiteSpace(trimmed) ||
               trimmed.StartsWith("--", StringComparison.Ordinal);
    }

    private static string RenderBucketStringListLine(string indent, string value, bool isActive)
    {
        return indent + (isActive ? "" : "--") + QuoteStringListValue(value) + ",";
    }

    public bool RemoveTableBlock(string key)
    {
        if (!TryFindTableBlock(key, out var startLine, out var endLine))
        {
            return false;
        }

        _lines.RemoveRange(startLine, endLine - startLine + 1);
        Parse();
        ApplyMetadata();
        _hasStructuralChanges = true;
        return true;
    }

    public static string? FindDefaultConfig()
    {
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        while (dir is not null)
        {
            var candidate = System.IO.Path.Combine(dir.FullName, "Utils", "Foothold Config.lua");
            if (File.Exists(candidate))
            {
                return candidate;
            }

            candidate = System.IO.Path.Combine(dir.FullName, "..", "Utils", "Foothold Config.lua");
            candidate = System.IO.Path.GetFullPath(candidate);
            if (File.Exists(candidate))
            {
                return candidate;
            }

            dir = dir.Parent;
        }

        return null;
    }

    public void Save()
    {
        SaveTo(Path);
    }

    public string SaveTo(string targetPath)
    {
        var errors = Validate();
        if (errors.Count > 0)
        {
            throw new InvalidOperationException(string.Join(Environment.NewLine, errors.Take(8)));
        }

        var edits = new List<(int LineIndex, Action Apply)>();
        edits.AddRange(Entries.Where(entry => entry.IsChanged)
            .Select(entry => (entry.LineIndex, (Action)(() =>
            {
                if (entry.IsLongText)
                {
                    var count = entry.EndLineIndex - entry.LineIndex + 1;
                    _lines.RemoveRange(entry.LineIndex, count);
                    _lines.InsertRange(entry.LineIndex, entry.RenderLines());
                }
                else
                {
                    _lines[entry.LineIndex] = entry.RenderLine();
                }

                entry.AcceptSavedValue();
            }))));
        edits.AddRange(StageTables.SelectMany(table => table.Rows)
            .Where(row => row.IsChanged)
            .Select(row => (row.LineIndex, (Action)(() =>
            {
                _lines[row.LineIndex] = row.RenderLine();
                row.AcceptSavedValue();
            }))));

        foreach (var edit in edits.OrderByDescending(edit => edit.LineIndex))
        {
            edit.Apply();
        }

        File.WriteAllText(targetPath, string.Join(NewLine, _lines), new UTF8Encoding(false));
        _savedSnapshot = RenderCurrentText();
        _hasStructuralChanges = false;
        return targetPath;
    }

    private string RenderCurrentText()
    {
        var lines = _lines.ToList();
        var edits = new List<(int LineIndex, int Count, List<string> Replacement)>();
        edits.AddRange(Entries.Select(entry =>
        {
            var count = entry.IsLongText ? entry.EndLineIndex - entry.LineIndex + 1 : 1;
            var replacement = entry.IsLongText ? entry.RenderLines() : new List<string> { entry.RenderLine() };
            return (entry.LineIndex, count, replacement);
        }));
        edits.AddRange(StageTables.SelectMany(table => table.Rows)
            .Select(row => (row.LineIndex, 1, new List<string> { row.RenderLine() })));

        foreach (var edit in edits
            .Where(edit => edit.LineIndex >= 0 && edit.LineIndex + edit.Count <= lines.Count)
            .OrderByDescending(edit => edit.LineIndex))
        {
            lines.RemoveRange(edit.LineIndex, edit.Count);
            lines.InsertRange(edit.LineIndex, edit.Replacement);
        }

        return string.Join(NewLine, lines);
    }

    public ConfigEntry AddTableEntry(string parentKey, string key, string valueText, ConfigEntry template)
    {
        if (Entries.Any(entry => entry.ParentKey == parentKey && entry.Key.Equals(key, StringComparison.Ordinal)))
        {
            throw new InvalidOperationException("That table already has an item named " + key + ".");
        }

        var insertLine = FindTableInsertLine(parentKey);
        ShiftLineIndexes(insertLine, 1);

        var prefix = GetEntryIndent(template) + "[\"" + EscapeLuaKey(key) + "\"] = ";
        var entry = new ConfigEntry
        {
            LineIndex = insertLine,
            EndLineIndex = insertLine,
            Section = template.Section,
            Key = key,
            DisplayKey = parentKey + "." + key,
            ParentKey = parentKey,
            ParentDescription = template.ParentDescription,
            Description = "",
            ParentGuiEditor = template.ParentGuiEditor,
            ParentGuiFields = template.ParentGuiFields,
            ParentGuiUntickRowsWhen = template.ParentGuiUntickRowsWhen,
            ParentGuiConfirmUntickRowsWhen = template.ParentGuiConfirmUntickRowsWhen,
            ParentGuiConfirmSetRowsByEra = template.ParentGuiConfirmSetRowsByEra,
            ParentGuiRowLabel = template.ParentGuiRowLabel,
            ParentGuiVisibleWhen = template.ParentGuiVisibleWhen,
            Prefix = prefix,
            Suffix = ",",
            RawValue = valueText,
            Kind = template.Kind,
            QuoteChar = template.QuoteChar,
            InferredAdvanced = template.InferredAdvanced
        };
        entry.InitializeValueText(valueText);
        AddChoices(entry);
        AddTupleFields(entry);
        if (Metadata.Entries.TryGetValue(entry.DisplayKey, out var metadata))
        {
            entry.ApplyMetadata(metadata);
        }

        _lines.Insert(insertLine, entry.RenderLine());
        Entries.Add(entry);
        _hasStructuralChanges = true;
        return entry;
    }

    public ConfigEntry RenameTableEntry(ConfigEntry entry, string newKey)
    {
        if (string.IsNullOrWhiteSpace(entry.ParentKey))
        {
            throw new InvalidOperationException("Only table rows can be renamed.");
        }

        newKey = newKey.Trim();
        if (string.IsNullOrWhiteSpace(newKey))
        {
            throw new InvalidOperationException("Callsign cannot be empty.");
        }

        if (newKey.Any(char.IsControl))
        {
            throw new InvalidOperationException("Callsign cannot contain control characters.");
        }

        if (entry.Key.Equals(newKey, StringComparison.Ordinal))
        {
            return entry;
        }

        if (Entries.Any(candidate =>
                !ReferenceEquals(candidate, entry) &&
                candidate.ParentKey.Equals(entry.ParentKey, StringComparison.Ordinal) &&
                candidate.Key.Equals(newKey, StringComparison.Ordinal)))
        {
            throw new InvalidOperationException("That aircraft already has a callsign named " + newKey + ".");
        }

        var index = Entries.IndexOf(entry);
        if (index < 0)
        {
            throw new InvalidOperationException("Could not rename row because it is no longer in the document.");
        }

        if (entry.IsLongText)
        {
            throw new InvalidOperationException("Cannot rename a multi-line table row.");
        }

        if (entry.LineIndex < 0 || entry.LineIndex >= _lines.Count)
        {
            throw new InvalidOperationException("Could not rename row because its source line was not found.");
        }

        var renamed = new ConfigEntry
        {
            LineIndex = entry.LineIndex,
            EndLineIndex = entry.EndLineIndex,
            Section = entry.Section,
            Key = newKey,
            DisplayKey = entry.ParentKey + "." + newKey,
            ParentKey = entry.ParentKey,
            ParentDescription = entry.ParentDescription,
            Description = entry.Description,
            InlineComment = entry.InlineComment,
            Prefix = GetEntryIndent(entry) + "[\"" + EscapeLuaKey(newKey) + "\"] = ",
            Suffix = entry.Suffix,
            RawValue = entry.RawValue,
            Kind = entry.Kind,
            QuoteChar = entry.QuoteChar,
            InferredAdvanced = entry.InferredAdvanced,
            IsLongText = entry.IsLongText,
            GuiLabel = entry.GuiLabel,
            ParentGuiEditor = entry.ParentGuiEditor,
            ParentGuiFields = entry.ParentGuiFields,
            ParentGuiUntickRowsWhen = entry.ParentGuiUntickRowsWhen,
            ParentGuiConfirmUntickRowsWhen = entry.ParentGuiConfirmUntickRowsWhen,
            ParentGuiConfirmSetRowsByEra = entry.ParentGuiConfirmSetRowsByEra,
            ParentGuiRowLabel = entry.ParentGuiRowLabel,
            ParentGuiVisibleWhen = entry.ParentGuiVisibleWhen,
            GuiVisibleWhen = entry.GuiVisibleWhen,
            GuiValidValues = entry.GuiValidValues
        };
        renamed.InitializeValueText(entry.RawValue);
        renamed.ValueText = entry.ValueText;
        AddChoices(renamed);
        AddTupleFields(renamed);
        if (Metadata.Entries.TryGetValue(renamed.DisplayKey, out var metadata))
        {
            renamed.ApplyMetadata(metadata);
        }

        Entries[index] = renamed;
        _lines[renamed.LineIndex] = renamed.RenderLine();
        _hasStructuralChanges = true;
        return renamed;
    }

    public void RemoveEntry(ConfigEntry entry)
    {
        var count = Math.Max(1, entry.EndLineIndex - entry.LineIndex + 1);
        if (entry.LineIndex < 0 || entry.LineIndex + count > _lines.Count)
        {
            throw new InvalidOperationException("Could not remove row because its source line was not found.");
        }

        _lines.RemoveRange(entry.LineIndex, count);
        Entries.Remove(entry);
        ShiftLineIndexes(entry.LineIndex, -count);
        _hasStructuralChanges = true;
    }

    public ConfigStringListItem AddStringListItem(ConfigStringListTable table, string value)
    {
        return AddStringListItem(table, value, table.EndLineIndex);
    }

    private ConfigStringListItem AddStringListItem(ConfigStringListTable table, string value, int insertLine)
    {
        if (table.Items.Any(item => item.Value.Equals(value, StringComparison.Ordinal)))
        {
            throw new InvalidOperationException("That list already has " + value + ".");
        }

        insertLine = Math.Clamp(insertLine, table.StartLineIndex + 1, table.EndLineIndex);
        EnsureStringListSeparatorBeforeInsert(table, insertLine);
        ShiftLineIndexes(insertLine, 1);
        var indent = GetStringListIndent(table);
        var quotedValue = QuoteStringListValue(value);
        var line = indent + quotedValue + ",";
        _lines.Insert(insertLine, line);

        var item = new ConfigStringListItem
        {
            Value = value,
            LineIndex = insertLine,
            StartIndex = indent.Length,
            Length = quotedValue.Length
        };
        table.Items.Add(item);
        _hasStructuralChanges = true;
        return item;
    }

    public ConfigStringListItem ActivateStringListValue(ConfigStringListTable table, string value, IReadOnlyList<string>? preferredOrder = null)
    {
        var existing = table.Items.FirstOrDefault(item => item.Value.Equals(value, StringComparison.Ordinal));
        if (existing is not null)
        {
            return existing;
        }

        var commented = table.CommentedItems
            .OrderBy(item => item.LineIndex)
            .ThenBy(item => item.StartIndex)
            .FirstOrDefault(item => item.Value.Equals(value, StringComparison.Ordinal));
        if (commented is not null)
        {
            var insertLine = commented.LineIndex;
            RemoveCommentedStringListItem(table, commented);
            return AddStringListItem(table, value, insertLine);
        }

        return AddStringListItem(table, value, FindStringListInsertLine(table, value, preferredOrder));
    }

    public ConfigStringListItem DeactivateStringListItem(ConfigStringListTable table, ConfigStringListItem item)
    {
        var value = item.Value;
        var insertLine = item.LineIndex;
        RemoveStringListItem(table, item);
        return AddCommentedStringListItem(table, value, insertLine);
    }

    public ConfigStringListItem AddCommentedStringListItem(ConfigStringListTable table, string value)
    {
        return AddCommentedStringListItem(table, value, table.EndLineIndex);
    }

    private ConfigStringListItem AddCommentedStringListItem(ConfigStringListTable table, string value, int insertLine)
    {
        var existing = table.CommentedItems.FirstOrDefault(item => item.Value.Equals(value, StringComparison.Ordinal));
        if (existing is not null)
        {
            return existing;
        }

        insertLine = Math.Clamp(insertLine, table.StartLineIndex + 1, table.EndLineIndex);
        ShiftLineIndexes(insertLine, 1);
        var indent = GetStringListIndent(table);
        var quotedValue = QuoteStringListValue(value);
        var line = indent + "--" + quotedValue + ",";
        _lines.Insert(insertLine, line);

        var item = new ConfigStringListItem
        {
            Value = value,
            LineIndex = insertLine,
            StartIndex = indent.Length + 2,
            Length = quotedValue.Length,
            IsCommented = true
        };
        table.CommentedItems.Add(item);
        _hasStructuralChanges = true;
        return item;
    }

    private int FindStringListInsertLine(ConfigStringListTable table, string value, IReadOnlyList<string>? preferredOrder)
    {
        if (preferredOrder is null || preferredOrder.Count == 0)
        {
            return table.EndLineIndex;
        }

        var valueOrder = IndexOfPreferredValue(preferredOrder, value);
        if (valueOrder < 0)
        {
            return table.EndLineIndex;
        }

        var nextItem = table.Items
            .Select(item => (Item: item, Order: IndexOfPreferredValue(preferredOrder, item.Value)))
            .Where(item => item.Order > valueOrder)
            .OrderBy(item => item.Order)
            .ThenBy(item => item.Item.LineIndex)
            .ThenBy(item => item.Item.StartIndex)
            .FirstOrDefault();

        return nextItem.Item is not null ? nextItem.Item.LineIndex : table.EndLineIndex;
    }

    private static int IndexOfPreferredValue(IReadOnlyList<string> preferredOrder, string value)
    {
        for (var i = 0; i < preferredOrder.Count; i++)
        {
            if (preferredOrder[i].Equals(value, StringComparison.Ordinal))
            {
                return i;
            }
        }

        return -1;
    }

    public void RemoveStringListItem(ConfigStringListTable table, ConfigStringListItem item)
    {
        var sameLineItems = table.Items
            .Where(candidate => candidate.LineIndex == item.LineIndex)
            .OrderBy(candidate => candidate.StartIndex)
            .ToList();
        if (sameLineItems.Count <= 1 && !_lines[item.LineIndex].Contains("}", StringComparison.Ordinal))
        {
            _lines.RemoveAt(item.LineIndex);
            table.Items.Remove(item);
            ShiftLineIndexes(item.LineIndex, -1);
            _hasStructuralChanges = true;
            return;
        }

        var remaining = sameLineItems
            .Where(candidate => !ReferenceEquals(candidate, item))
            .Select(candidate => candidate.Value)
            .ToList();
        var line = _lines[item.LineIndex];
        if (sameLineItems.Count == 0)
        {
            return;
        }

        var first = sameLineItems[0];
        var last = sameLineItems[^1];
        var prefix = line[..first.StartIndex];
        var suffix = line[(last.StartIndex + last.Length)..];
        _lines[item.LineIndex] = prefix + string.Join(", ", remaining.Select(QuoteStringListValue)) + suffix;
        table.Items.Remove(item);
        RefreshStringListTableItems(table);
        _hasStructuralChanges = true;
    }

    public void RemoveCommentedStringListItem(ConfigStringListTable table, ConfigStringListItem item)
    {
        var sameLineItems = table.CommentedItems
            .Where(candidate => candidate.LineIndex == item.LineIndex)
            .OrderBy(candidate => candidate.StartIndex)
            .ToList();
        if (sameLineItems.Count <= 1 && !_lines[item.LineIndex].Contains("}", StringComparison.Ordinal))
        {
            _lines.RemoveAt(item.LineIndex);
            table.CommentedItems.Remove(item);
            ShiftLineIndexes(item.LineIndex, -1);
            _hasStructuralChanges = true;
            return;
        }

        var remaining = sameLineItems
            .Where(candidate => !ReferenceEquals(candidate, item))
            .Select(candidate => candidate.Value)
            .ToList();
        var line = _lines[item.LineIndex];
        if (sameLineItems.Count == 0)
        {
            return;
        }

        var first = sameLineItems[0];
        var last = sameLineItems[^1];
        var prefix = line[..first.StartIndex];
        var suffix = line[(last.StartIndex + last.Length)..];
        _lines[item.LineIndex] = prefix + string.Join(", ", remaining.Select(QuoteStringListValue)) + suffix;
        table.CommentedItems.Remove(item);
        RefreshStringListTableItems(table);
        _hasStructuralChanges = true;
    }

    public int RepairStringListSeparators()
    {
        var repairCount = 0;
        foreach (var table in StringListTables.OrderBy(table => table.StartLineIndex))
        {
            var previousItemLine = -1;
            for (var i = table.StartLineIndex; i <= table.EndLineIndex && i < _lines.Count; i++)
            {
                repairCount += RepairSmartQuotesInCode(i);
                repairCount += RepairBrokenCommentMarker(i);
                repairCount += RepairDuplicateCommas(i);
                repairCount += RepairStringListLineQuotes(i);
                if (GetStringListLineIssue(_lines[i], out _, out _) is not StringListLineIssue.None)
                {
                    continue;
                }

                var line = _lines[i];
                var tokens = ReadQuotedStringTokens(line);
                if (tokens.Count == 0)
                {
                    continue;
                }

                for (var tokenIndex = tokens.Count - 2; tokenIndex >= 0; tokenIndex--)
                {
                    var current = tokens[tokenIndex];
                    var next = tokens[tokenIndex + 1];
                    if (HasLuaFieldSeparator(line, current.StartIndex + current.Length, next.StartIndex))
                    {
                        continue;
                    }

                    line = line.Insert(current.StartIndex + current.Length, ",");
                    repairCount++;
                }

                _lines[i] = line;
                if (previousItemLine >= 0 && !StringListLineEndsWithSeparator(_lines[previousItemLine]))
                {
                    InsertStringListLineSeparator(previousItemLine);
                    repairCount++;
                }

                previousItemLine = i;
            }
        }

        repairCount += RepairSafeConfigTableFormat();

        if (repairCount > 0)
        {
            Parse();
            ApplyMetadata();
            _hasStructuralChanges = true;
        }

        return repairCount;
    }

    public ConfigStageRow AddStageRow(ConfigStageTable table, string difficulty, decimal? player = null, decimal? amount = null)
    {
        var normalizedDifficulty = NormalizeStageDifficulty(difficulty);
        var insertLine = FindStageInsertLine(table, normalizedDifficulty);
        ShiftLineIndexes(insertLine, 1);

        var siblingRows = table.Rows
            .Where(row => row.Difficulty.Equals(normalizedDifficulty, StringComparison.OrdinalIgnoreCase))
            .OrderBy(row => row.LineIndex)
            .ToList();
        var defaultPlayer = player ?? (siblingRows.Count == 0 ? 0m : siblingRows[^1].Player + 1m);
        var defaultAmount = amount ?? (siblingRows.Count == 0 ? 0m : siblingRows[^1].Amount);
        var row = new ConfigStageRow
        {
            Difficulty = normalizedDifficulty,
            LineIndex = insertLine,
            Indent = GetStageRowIndent(table, normalizedDifficulty),
            Suffix = ",",
            Player = defaultPlayer,
            Amount = defaultAmount
        };
        row.AcceptSavedValue();

        _lines.Insert(insertLine, row.RenderLine());
        table.Rows.Add(row);
        _hasStructuralChanges = true;
        return row;
    }

    public void RemoveStageRow(ConfigStageTable table, ConfigStageRow row)
    {
        if (row.LineIndex < 0 || row.LineIndex >= _lines.Count)
        {
            throw new InvalidOperationException("Could not remove stage row because its source line was not found.");
        }

        _lines.RemoveAt(row.LineIndex);
        table.Rows.Remove(row);
        ShiftLineIndexes(row.LineIndex, -1);
        _hasStructuralChanges = true;
    }

    public void MoveStageRow(ConfigStageTable table, ConfigStageRow row, int delta)
    {
        var rows = table.Rows
            .Where(candidate => candidate.Difficulty.Equals(row.Difficulty, StringComparison.OrdinalIgnoreCase))
            .OrderBy(candidate => candidate.LineIndex)
            .ToList();
        var index = rows.IndexOf(row);
        var targetIndex = index + delta;
        if (index < 0 || targetIndex < 0 || targetIndex >= rows.Count)
        {
            return;
        }

        var other = rows[targetIndex];
        _lines[row.LineIndex] = row.RenderLine();
        _lines[other.LineIndex] = other.RenderLine();
        (_lines[row.LineIndex], _lines[other.LineIndex]) = (_lines[other.LineIndex], _lines[row.LineIndex]);
        (row.LineIndex, other.LineIndex) = (other.LineIndex, row.LineIndex);
        _hasStructuralChanges = true;
    }

    public List<string> Validate()
    {
        var errors = Entries
            .Select(entry => (entry, error: entry.Validate()))
            .Where(item => item.error is not null)
            .Select(item => $"{item.entry.DisplayKey}: {item.error}")
            .ToList();

        errors.AddRange(ValidateStageTables());
        errors.AddRange(ValidateClosedTableBlocks());
        errors.AddRange(ValidateStringListSeparators());
        errors.AddRange(ValidateSafeConfigTableFormat());
        errors.AddRange(ValidateMisplacedTopLevelRows());
        errors.AddRange(LuaSyntaxValidator.Validate(RenderCurrentText(), Path));
        return errors;
    }

    private List<string> ValidateClosedTableBlocks()
    {
        var errors = new List<string>();
        for (var i = 0; i < _lines.Count; i++)
        {
            var match = AssignmentRegex.Match(_lines[i]);
            if (!match.Success)
            {
                continue;
            }

            var lhsWithEquals = match.Groups["lhs"].Value;
            var lhs = lhsWithEquals[..lhsWithEquals.LastIndexOf('=')].Trim();
            var value = SplitValueAndSuffix(match.Groups["rest"].Value).value.TrimEnd();
            if (IsTableStart(value) && FindTableEndLine(i) < i)
            {
                errors.Add($"{NormalizeKey(lhs)}: Lua table starts on line {i + 1} but is not closed.");
            }
        }

        return errors;
    }

    private List<string> RepairMissingTopLevelTableClosers()
    {
        var warnings = new List<string>();
        var guard = 0;
        while (guard++ < 16 &&
               TryFindMissingTopLevelTableCloser(out var tableKey, out var nextKey, out var insertLine))
        {
            _lines.Insert(insertLine, "}");
            warnings.Add("Added missing closing brace for " + tableKey + " before " + nextKey + ".");
        }

        return warnings;
    }

    private bool TryFindMissingTopLevelTableCloser(out string tableKey, out string nextKey, out int insertLine)
    {
        tableKey = "";
        nextKey = "";
        insertLine = -1;
        for (var i = 0; i < _lines.Count; i++)
        {
            if (!TryReadTopLevelAssignment(i, requireTableStart: true, out tableKey))
            {
                continue;
            }

            if (FindTableEndLine(i) >= i)
            {
                continue;
            }

            for (var nextLine = i + 1; nextLine < _lines.Count; nextLine++)
            {
                if (!TryReadTopLevelAssignment(nextLine, requireTableStart: true, out nextKey))
                {
                    continue;
                }

                insertLine = FindInsertionLineBeforeCommentBlock(nextLine);
                return true;
            }
        }

        return false;
    }

    private bool TryReadTopLevelAssignment(int lineIndex, bool requireTableStart, out string key)
    {
        key = "";
        if (lineIndex < 0 || lineIndex >= _lines.Count)
        {
            return false;
        }

        var line = _lines[lineIndex];
        if (string.IsNullOrWhiteSpace(line) ||
            char.IsWhiteSpace(line[0]) ||
            line.TrimStart().StartsWith("--", StringComparison.Ordinal))
        {
            return false;
        }

        var match = AssignmentRegex.Match(line);
        if (!match.Success)
        {
            return false;
        }

        var lhsWithEquals = match.Groups["lhs"].Value;
        key = NormalizeKey(lhsWithEquals[..lhsWithEquals.LastIndexOf('=')].Trim());
        if (!requireTableStart)
        {
            return true;
        }

        var value = SplitValueAndSuffix(match.Groups["rest"].Value).value.TrimEnd();
        return IsTableStart(value);
    }

    private int FindInsertionLineBeforeCommentBlock(int assignmentLine)
    {
        var insertLine = assignmentLine;
        while (insertLine > 0)
        {
            var previous = _lines[insertLine - 1].Trim();
            if (previous.Length == 0 || previous.StartsWith("--", StringComparison.Ordinal))
            {
                insertLine--;
                continue;
            }

            break;
        }

        return insertLine;
    }

    private List<string> ValidateStringListSeparators()
    {
        var errors = new List<string>();
        foreach (var table in StringListTables)
        {
            var previousItemLine = -1;
            for (var i = table.StartLineIndex; i <= table.EndLineIndex && i < _lines.Count; i++)
            {
                if (HasSmartQuoteInCode(_lines[i]))
                {
                    errors.Add($"{table.Key}: smart quote in list item on line {i + 1}.");
                    continue;
                }

                if (TryFindBrokenCommentMarkerRepair(_lines[i], out _))
                {
                    errors.Add($"{table.Key}: broken comment marker on line {i + 1}.");
                    continue;
                }

                if (FindDuplicateCommaIndex(_lines[i]) >= 0)
                {
                    errors.Add($"{table.Key}: duplicate comma in list item on line {i + 1}.");
                    continue;
                }

                var issue = GetStringListLineIssue(_lines[i], out _, out _);
                if (issue is StringListLineIssue.MissingOpeningQuoteAfterSeparator)
                {
                    errors.Add($"{table.Key}: missing opening quote after list separator on line {i + 1}.");
                    continue;
                }

                if (issue is StringListLineIssue.UnfinishedString)
                {
                    errors.Add($"{table.Key}: unfinished string on line {i + 1}. Fix the missing quote first.");
                    continue;
                }

                if (issue is StringListLineIssue.MissingClosingQuoteBeforeSeparator)
                {
                    errors.Add($"{table.Key}: missing closing quote before list separator on line {i + 1}.");
                    continue;
                }

                if (issue is StringListLineIssue.MalformedTextAfterString)
                {
                    errors.Add($"{table.Key}: malformed string list item on line {i + 1}. Fix the quote or comma near this entry first.");
                    continue;
                }

                var tokens = ReadQuotedStringTokens(_lines[i]);
                if (tokens.Count == 0)
                {
                    continue;
                }

                for (var tokenIndex = 0; tokenIndex < tokens.Count - 1; tokenIndex++)
                {
                    var current = tokens[tokenIndex];
                    var next = tokens[tokenIndex + 1];
                    if (!HasLuaFieldSeparator(_lines[i], current.StartIndex + current.Length, next.StartIndex))
                    {
                        errors.Add($"{table.Key}: missing comma between list items on line {i + 1}.");
                    }
                }

                if (previousItemLine >= 0 && !StringListLineEndsWithSeparator(_lines[previousItemLine]))
                {
                    errors.Add($"{table.Key}: missing comma after line {previousItemLine + 1} before line {i + 1}.");
                }

                previousItemLine = i;
            }
        }

        return errors;
    }

    private List<string> ValidateSafeConfigTableFormat()
    {
        var errors = new List<string>();
        foreach (var table in EnumerateTableBlocks())
        {
            if (StringListTables.Any(stringTable => stringTable.StartLineIndex == table.StartLine))
            {
                continue;
            }

            var previousRowLine = -1;
            var depth = 1;
            for (var i = table.StartLine + 1; i < table.EndLine && i < _lines.Count; i++)
            {
                if (depth == 1)
                {
                    if (HasSmartQuoteInCode(_lines[i]))
                    {
                        errors.Add($"{table.Key}: smart quote in config code on line {i + 1}.");
                    }

                    if (TryFindMissingEqualsInKeyedRowRepair(_lines[i], out _))
                    {
                        errors.Add($"{table.Key}: missing '=' in keyed table row on line {i + 1}.");
                    }

                    if (TryFindSameLineKeyedRowSeparatorRepair(_lines[i], out _))
                    {
                        errors.Add($"{table.Key}: missing comma between keyed table rows on line {i + 1}.");
                    }

                    if (IsSimpleKeyedTableRow(_lines[i]))
                    {
                        if (previousRowLine >= 0 && !TableLineEndsWithSeparator(_lines[previousRowLine]))
                        {
                            errors.Add($"{table.Key}: missing comma after line {previousRowLine + 1} before line {i + 1}.");
                        }

                        previousRowLine = i;
                    }
                }

                depth += CountBraceDelta(_lines[i]);
            }
        }

        return errors;
    }

    private int RepairSafeConfigTableFormat()
    {
        var repairCount = 0;
        foreach (var table in EnumerateTableBlocks())
        {
            if (StringListTables.Any(stringTable => stringTable.StartLineIndex == table.StartLine))
            {
                continue;
            }

            var previousRowLine = -1;
            var depth = 1;
            for (var i = table.StartLine + 1; i < table.EndLine && i < _lines.Count; i++)
            {
                if (depth == 1)
                {
                    repairCount += RepairSmartQuotesInCode(i);
                    repairCount += RepairMissingEqualsInKeyedRow(i);
                    repairCount += RepairSameLineKeyedRowSeparator(i);

                    if (IsSimpleKeyedTableRow(_lines[i]))
                    {
                        if (previousRowLine >= 0 && !TableLineEndsWithSeparator(_lines[previousRowLine]))
                        {
                            InsertStringListLineSeparator(previousRowLine);
                            repairCount++;
                        }

                        previousRowLine = i;
                    }
                }

                depth += CountBraceDelta(_lines[i]);
            }
        }

        return repairCount;
    }

    private List<string> ValidateMisplacedTopLevelRows()
    {
        var topLevelKeys = Entries
            .Where(entry => string.IsNullOrWhiteSpace(entry.ParentKey))
            .Select(entry => entry.Key)
            .ToHashSet(StringComparer.Ordinal);

        return Entries
            .Where(entry => !string.IsNullOrWhiteSpace(entry.ParentKey) &&
                            !entry.ParentKey.Contains('.', StringComparison.Ordinal) &&
                            topLevelKeys.Contains(entry.Key))
            .Select(entry => $"{entry.DisplayKey}: {entry.Key} appears inside {entry.ParentKey}, but {entry.Key} is also a top-level setting. Move it outside the table or remove the table row.")
            .ToList();
    }

    public List<string> BuildAuditLines(out bool ok)
    {
        var lines = new List<string>
        {
            "Foothold Config Manager audit",
            "Timestamp\t" + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss", CultureInfo.InvariantCulture),
            "Config\t" + Path,
            "Entries\t" + Entries.Count.ToString(CultureInfo.InvariantCulture),
            "String list tables\t" + StringListTables.Count.ToString(CultureInfo.InvariantCulture),
            "Stage tables\t" + StageTables.Count.ToString(CultureInfo.InvariantCulture)
        };

        var validationErrors = Validate();
        var mismatchCount = 0;
        var renderErrorCount = 0;
        var commentWarningCount = 0;
        var detailLines = new List<string>
        {
            "",
            "Validation\t" + (validationErrors.Count == 0 ? "OK" : "FAILED")
        };
        foreach (var error in validationErrors)
        {
            detailLines.Add("Validation error\t" + SanitizeAuditField(error));
        }

        detailLines.Add("");
        detailLines.Add("Kind\tLine\tSection\tKey\tType\tValue\tChoices\tValue/render match\tComment warnings\tNote");
        foreach (var entry in Entries.OrderBy(entry => entry.LineIndex).ThenBy(entry => entry.DisplayKey, StringComparer.Ordinal))
        {
            var choices = entry.Choices.Count == 0
                ? ""
                : string.Join(", ", entry.Choices.Select(choice => choice.Display));
            var commentWarnings = EvaluateCommentHelp(entry);
            commentWarningCount += commentWarnings.Count;
            var renderMatch = "OK";
            var note = "";
            try
            {
                if (entry.IsLongText)
                {
                    if (!string.Equals(entry.OriginalValueText, entry.ValueText, StringComparison.Ordinal))
                    {
                        renderMatch = "MISMATCH";
                        mismatchCount++;
                    }
                }
                else
                {
                    var original = string.Join(NewLine, _lines.Skip(entry.LineIndex).Take(entry.EndLineIndex - entry.LineIndex + 1));
                    var rendered = string.Join(NewLine, entry.RenderLines());
                    if (!string.Equals(original, rendered, StringComparison.Ordinal))
                    {
                        renderMatch = "MISMATCH";
                        mismatchCount++;
                    }
                }
            }
            catch (Exception ex)
            {
                renderMatch = "ERROR";
                note = ex.Message;
                renderErrorCount++;
            }

            detailLines.Add(string.Join("\t", new[]
            {
                "Entry",
                (entry.LineIndex + 1).ToString(CultureInfo.InvariantCulture),
                SanitizeAuditField(entry.EffectiveCategory),
                SanitizeAuditField(entry.DisplayKey),
                SanitizeAuditField(entry.TypeLabel),
                SanitizeAuditField(entry.ValueText),
                SanitizeAuditField(choices),
                renderMatch,
                SanitizeAuditField(string.Join("; ", commentWarnings)),
                SanitizeAuditField(note)
            }));
        }

        foreach (var table in StringListTables.OrderBy(table => table.StartLineIndex).ThenBy(table => table.Key, StringComparer.Ordinal))
        {
            detailLines.Add(string.Join("\t", new[]
            {
                "StringList",
                (table.StartLineIndex + 1).ToString(CultureInfo.InvariantCulture),
                SanitizeAuditField(table.Section),
                SanitizeAuditField(table.Key),
                "Table",
                SanitizeAuditField(table.Items.Count.ToString(CultureInfo.InvariantCulture) + " item(s)"),
                "",
                "OK",
                "",
                SanitizeAuditField(string.Join(", ", table.Items.Select(item => item.Value)))
            }));
        }

        foreach (var table in StageTables.OrderBy(table => table.StartLineIndex).ThenBy(table => table.Key, StringComparer.Ordinal))
        {
            var difficulties = table.Rows
                .GroupBy(row => row.Difficulty, StringComparer.OrdinalIgnoreCase)
                .Select(group => group.Key + "=" + group.Count().ToString(CultureInfo.InvariantCulture))
                .ToList();
            var warnings = EvaluateStageTable(table);
            detailLines.Add(string.Join("\t", new[]
            {
                "StageTable",
                (table.StartLineIndex + 1).ToString(CultureInfo.InvariantCulture),
                SanitizeAuditField(table.Section),
                SanitizeAuditField(table.Key),
                "Table",
                SanitizeAuditField(table.Rows.Count.ToString(CultureInfo.InvariantCulture) + " row(s)"),
                "",
                "OK",
                SanitizeAuditField(string.Join("; ", warnings)),
                SanitizeAuditField(string.Join(", ", difficulties))
            }));
        }

        lines.Add("Value/render mismatches\t" + mismatchCount.ToString(CultureInfo.InvariantCulture));
        lines.Add("Render errors\t" + renderErrorCount.ToString(CultureInfo.InvariantCulture));
        lines.Add("Comment warnings\t" + commentWarningCount.ToString(CultureInfo.InvariantCulture));
        lines.AddRange(detailLines);
        ok = validationErrors.Count == 0 && mismatchCount == 0 && renderErrorCount == 0;
        return lines;
    }

    private static List<string> EvaluateCommentHelp(ConfigEntry entry)
    {
        var warnings = new List<string>();
        var validValues = ReadValidValueComments(entry.EffectiveDescription, out var validLineCount);
        if (validLineCount > 1)
        {
            warnings.Add("multiple Valid values lines in help text");
        }

        if (validValues.Count == 0)
        {
            return warnings;
        }

        var distinctValidValues = validValues
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();

        if (entry.Kind == ConfigValueKind.Boolean)
        {
            var choiceValues = entry.Choices
                .Select(choice => NormalizeCommentValue(choice.Display))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .ToList();
            var nonBooleanValues = distinctValidValues
                .Where(value => !value.Equals("true", StringComparison.OrdinalIgnoreCase) &&
                                !value.Equals("false", StringComparison.OrdinalIgnoreCase) &&
                                !choiceValues.Contains(value, StringComparer.OrdinalIgnoreCase))
                .ToList();
            if (nonBooleanValues.Count > 0)
            {
                warnings.Add("boolean help includes non-boolean valid values: " + string.Join(", ", nonBooleanValues));
            }
        }

        if (entry.Choices.Count > 0)
        {
            var choiceValues = entry.Choices
                .Select(choice => NormalizeCommentValue(choice.Display))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .ToList();
            if (!new HashSet<string>(distinctValidValues, StringComparer.OrdinalIgnoreCase).SetEquals(choiceValues))
            {
                warnings.Add("comment valid values do not match GUI choices: comment [" +
                             string.Join(", ", distinctValidValues) + "] choices [" +
                             string.Join(", ", choiceValues) + "]");
            }
        }

        return warnings;
    }

    private List<string> ValidateStageTables()
    {
        var errors = new List<string>();
        foreach (var table in StageTables)
        {
            foreach (var row in table.Rows)
            {
                if (row.Player < 0)
                {
                    errors.Add(table.Key + "." + row.Difficulty + ": player threshold cannot be negative.");
                }

                if (row.Amount < 0)
                {
                    errors.Add(table.Key + "." + row.Difficulty + ": amount cannot be negative.");
                }
            }

            errors.AddRange(EvaluateStageTable(table)
                .Where(warning => warning.StartsWith("duplicate", StringComparison.OrdinalIgnoreCase) ||
                                  warning.StartsWith("not sorted", StringComparison.OrdinalIgnoreCase))
                .Select(warning => table.Key + ": " + warning));
        }

        return errors;
    }

    private static List<string> EvaluateStageTable(ConfigStageTable table)
    {
        var warnings = new List<string>();
        foreach (var group in table.Rows.GroupBy(row => row.Difficulty, StringComparer.OrdinalIgnoreCase))
        {
            var rows = group.OrderBy(row => row.LineIndex).ToList();
            var duplicatePlayers = rows
                .GroupBy(row => row.Player)
                .Where(duplicate => duplicate.Count() > 1)
                .Select(duplicate => ConfigStageRow.FormatDecimal(duplicate.Key))
                .ToList();
            if (duplicatePlayers.Count > 0)
            {
                warnings.Add("duplicate " + group.Key + " thresholds: " + string.Join(", ", duplicatePlayers));
            }

            for (var i = 1; i < rows.Count; i++)
            {
                if (rows[i].Player < rows[i - 1].Player)
                {
                    warnings.Add("not sorted in " + group.Key);
                    break;
                }
            }

            if (rows.Count > 0 && rows[^1].Player < 999)
            {
                warnings.Add("no high fallback row in " + group.Key);
            }
        }

        foreach (var difficulty in new[] { "easy", "medium", "hard" })
        {
            if (!table.Rows.Any(row => row.Difficulty.Equals(difficulty, StringComparison.OrdinalIgnoreCase)))
            {
                warnings.Add("missing " + difficulty + " rows");
            }
        }

        return warnings;
    }

    private static List<string> ReadValidValueComments(string text, out int validLineCount)
    {
        var values = new List<string>();
        validLineCount = 0;
        foreach (var line in text.Split(new[] { "\r\n", "\n" }, StringSplitOptions.None))
        {
            var markerIndex = line.IndexOf("Valid values", StringComparison.OrdinalIgnoreCase);
            if (markerIndex < 0)
            {
                continue;
            }

            var colonIndex = line.IndexOf(':', markerIndex);
            if (colonIndex < 0)
            {
                continue;
            }

            validLineCount++;
            foreach (var part in line[(colonIndex + 1)..].Split('|'))
            {
                var value = NormalizeCommentValue(part);
                if (!string.IsNullOrWhiteSpace(value))
                {
                    values.Add(value);
                }
            }
        }

        return values;
    }

    private static string NormalizeCommentValue(string value)
    {
        return value
            .Trim()
            .TrimEnd('.', ',', ';')
            .Trim()
            .Trim('"', '\'')
            .Trim();
    }

    private static string SanitizeAuditField(string value)
    {
        return value
            .Replace("\r\n", "\\n", StringComparison.Ordinal)
            .Replace("\n", "\\n", StringComparison.Ordinal)
            .Replace("\r", "\\n", StringComparison.Ordinal)
            .Replace("\t", " ", StringComparison.Ordinal);
    }

    public void ApplyMetadata()
    {
        foreach (var entry in Entries)
        {
            if (Metadata.Entries.TryGetValue(entry.DisplayKey, out var metadata))
            {
                entry.ApplyMetadata(metadata);
            }
        }
    }

    private int FindTableInsertLine(string parentKey)
    {
        var tableEntries = Entries
            .Where(entry => entry.ParentKey == parentKey)
            .OrderBy(entry => entry.LineIndex)
            .ToList();
        if (tableEntries.Count == 0)
        {
            throw new InvalidOperationException("Cannot add a row to an empty or unsupported table yet.");
        }

        var searchStart = tableEntries[^1].EndLineIndex + 1;
        for (var i = searchStart; i < _lines.Count; i++)
        {
            if (_lines[i].TrimStart().StartsWith("}", StringComparison.Ordinal))
            {
                return i;
            }
        }

        return searchStart;
    }

    private void ShiftLineIndexes(int startLine, int delta)
    {
        foreach (var entry in Entries)
        {
            if (entry.LineIndex >= startLine)
            {
                entry.LineIndex += delta;
            }

            if (entry.EndLineIndex >= startLine)
            {
                entry.EndLineIndex += delta;
            }
        }

        foreach (var table in StringListTables)
        {
            if (table.StartLineIndex >= startLine)
            {
                table.StartLineIndex += delta;
            }

            if (table.EndLineIndex >= startLine)
            {
                table.EndLineIndex += delta;
            }

            foreach (var item in table.Items)
            {
                if (item.LineIndex >= startLine)
                {
                    item.LineIndex += delta;
                }
            }
        }

        foreach (var table in StageTables)
        {
            if (table.StartLineIndex >= startLine)
            {
                table.StartLineIndex += delta;
            }

            if (table.EndLineIndex >= startLine)
            {
                table.EndLineIndex += delta;
            }

            foreach (var row in table.Rows)
            {
                if (row.LineIndex >= startLine)
                {
                    row.LineIndex += delta;
                }
            }
        }
    }

    private static string GetEntryIndent(ConfigEntry template)
    {
        return Regex.Match(template.Prefix, @"^\s*").Value;
    }

    private static string EscapeLuaKey(string key)
    {
        return key.Replace("\\", "\\\\", StringComparison.Ordinal).Replace("\"", "\\\"", StringComparison.Ordinal);
    }

    private static string QuoteStringListValue(string value)
    {
        var escaped = value.Replace("\\", "\\\\", StringComparison.Ordinal)
            .Replace("\"", "\\\"", StringComparison.Ordinal);
        return "\"" + escaped + "\"";
    }

    private string GetStringListIndent(ConfigStringListTable table)
    {
        var firstItem = table.Items.OrderBy(item => item.LineIndex).FirstOrDefault();
        if (firstItem is not null && firstItem.LineIndex >= 0 && firstItem.LineIndex < _lines.Count)
        {
            return Regex.Match(_lines[firstItem.LineIndex], @"^\s*").Value;
        }

        return "    ";
    }

    private void EnsureStringListSeparatorBeforeInsert(ConfigStringListTable table, int insertLine)
    {
        var previousItemLine = FindPreviousStringListItemLine(table, insertLine);
        if (previousItemLine < 0 || StringListLineEndsWithSeparator(_lines[previousItemLine]))
        {
            return;
        }

        InsertStringListLineSeparator(previousItemLine);
    }

    private int FindPreviousStringListItemLine(ConfigStringListTable table, int insertLine)
    {
        for (var i = Math.Min(insertLine - 1, _lines.Count - 1); i > table.StartLineIndex; i--)
        {
            if (ReadQuotedStringTokens(_lines[i]).Count > 0)
            {
                return i;
            }
        }

        return -1;
    }

    private IEnumerable<(string Key, int StartLine, int EndLine)> EnumerateTableBlocks()
    {
        for (var i = 0; i < _lines.Count; i++)
        {
            var match = AssignmentRegex.Match(_lines[i]);
            if (!match.Success)
            {
                continue;
            }

            var lhsWithEquals = match.Groups["lhs"].Value;
            var lhs = lhsWithEquals[..lhsWithEquals.LastIndexOf('=')].Trim();
            var value = SplitValueAndSuffix(match.Groups["rest"].Value).value.TrimEnd();
            if (!IsTableStart(value))
            {
                continue;
            }

            var endLine = FindTableEndLine(i);
            if (endLine >= i)
            {
                yield return (NormalizeKey(lhs), i, endLine);
            }
        }
    }

    private int RepairSmartQuotesInCode(int lineIndex)
    {
        var line = _lines[lineIndex];
        var codeEnd = GetCodeEndIndex(line);
        if (codeEnd <= 0 || !HasSmartQuoteInCode(line))
        {
            return 0;
        }

        var code = line[..codeEnd]
            .Replace('\u201C', '"')
            .Replace('\u201D', '"')
            .Replace('\u2018', '\'')
            .Replace('\u2019', '\'');
        _lines[lineIndex] = code + line[codeEnd..];
        return 1;
    }

    private static bool HasSmartQuoteInCode(string line)
    {
        var codeEnd = GetCodeEndIndex(line);
        for (var i = 0; i < codeEnd; i++)
        {
            if (line[i] is '\u201C' or '\u201D' or '\u2018' or '\u2019')
            {
                return true;
            }
        }

        return false;
    }

    private int RepairBrokenCommentMarker(int lineIndex)
    {
        if (!TryFindBrokenCommentMarkerRepair(_lines[lineIndex], out var insertIndex))
        {
            return 0;
        }

        _lines[lineIndex] = _lines[lineIndex].Insert(insertIndex, "-");
        return 1;
    }

    private static bool TryFindBrokenCommentMarkerRepair(string line, out int insertIndex)
    {
        insertIndex = -1;
        var codeEnd = GetCodeEndIndex(line);
        var inQuote = false;
        var quote = '\0';
        var escaped = false;
        for (var i = 0; i < codeEnd; i++)
        {
            var ch = line[i];
            if (inQuote)
            {
                if (escaped)
                {
                    escaped = false;
                    continue;
                }

                if (ch == '\\')
                {
                    escaped = true;
                    continue;
                }

                if (ch == quote)
                {
                    inQuote = false;
                }

                continue;
            }

            if (ch is '"' or '\'')
            {
                inQuote = true;
                quote = ch;
                continue;
            }

            if (ch != '-' || (i + 1 < codeEnd && line[i + 1] == '-'))
            {
                continue;
            }

            var after = FindNextCodeCharacter(line, i + 1, codeEnd);
            if (after < 0 || !char.IsLetter(line[after]))
            {
                continue;
            }

            var before = line[..i];
            if (ReadQuotedStringTokens(before).Count == 0 || !StringListLineEndsWithSeparator(before))
            {
                continue;
            }

            insertIndex = i;
            return true;
        }

        return false;
    }

    private int RepairDuplicateCommas(int lineIndex)
    {
        var repairCount = 0;
        while (FindDuplicateCommaIndex(_lines[lineIndex]) is var commaIndex && commaIndex >= 0)
        {
            _lines[lineIndex] = _lines[lineIndex].Remove(commaIndex, 1);
            repairCount++;
        }

        return repairCount;
    }

    private static int FindDuplicateCommaIndex(string line)
    {
        var codeEnd = GetCodeEndIndex(line);
        var inQuote = false;
        var quote = '\0';
        var escaped = false;
        for (var i = 0; i < codeEnd; i++)
        {
            var ch = line[i];
            if (inQuote)
            {
                if (escaped)
                {
                    escaped = false;
                    continue;
                }

                if (ch == '\\')
                {
                    escaped = true;
                    continue;
                }

                if (ch == quote)
                {
                    inQuote = false;
                }

                continue;
            }

            if (ch is '"' or '\'')
            {
                inQuote = true;
                quote = ch;
                continue;
            }

            if (ch != ',')
            {
                continue;
            }

            var next = FindNextCodeCharacter(line, i + 1, codeEnd);
            if (next >= 0 && line[next] == ',')
            {
                return next;
            }
        }

        return -1;
    }

    private int RepairMissingEqualsInKeyedRow(int lineIndex)
    {
        if (!TryFindMissingEqualsInKeyedRowRepair(_lines[lineIndex], out var insertIndex))
        {
            return 0;
        }

        _lines[lineIndex] = _lines[lineIndex].Insert(insertIndex, " =");
        return 1;
    }

    private static bool TryFindMissingEqualsInKeyedRowRepair(string line, out int insertIndex)
    {
        insertIndex = -1;
        var code = line[..GetCodeEndIndex(line)];
        var match = Regex.Match(code, @"^\s*(?<lhs>\[[^\]]+\])\s+(?=(?:true|false|-?\d+(?:\.\d+)?|""[^""]*""|'[^']*'|\{))", RegexOptions.IgnoreCase);
        if (!match.Success)
        {
            return false;
        }

        insertIndex = match.Groups["lhs"].Index + match.Groups["lhs"].Length;
        return true;
    }

    private int RepairSameLineKeyedRowSeparator(int lineIndex)
    {
        var repairCount = 0;
        while (TryFindSameLineKeyedRowSeparatorRepair(_lines[lineIndex], out var insertIndex))
        {
            _lines[lineIndex] = _lines[lineIndex].Insert(insertIndex, ",");
            repairCount++;
        }

        return repairCount;
    }

    private static bool TryFindSameLineKeyedRowSeparatorRepair(string line, out int insertIndex)
    {
        insertIndex = -1;
        var code = line[..GetCodeEndIndex(line)];
        var match = Regex.Match(
            code,
            @"(?<value>\btrue\b|\bfalse\b|-?\d+(?:\.\d+)?|""(?:\\.|[^""])*""|'(?:\\.|[^'])*')\s+(?=(?:\[[^\]]+\]|[A-Za-z_][A-Za-z0-9_]*)\s*=)",
            RegexOptions.IgnoreCase);
        if (!match.Success)
        {
            return false;
        }

        insertIndex = match.Groups["value"].Index + match.Groups["value"].Length;
        return true;
    }

    private static bool IsSimpleKeyedTableRow(string line)
    {
        var code = line[..GetCodeEndIndex(line)];
        var match = AssignmentRegex.Match(code);
        if (!match.Success)
        {
            return false;
        }

        var value = SplitValueAndSuffix(match.Groups["rest"].Value).value.TrimEnd();
        return value.Length > 0 && !IsTableStart(value);
    }

    private static bool TableLineEndsWithSeparator(string line)
    {
        return StringListLineEndsWithSeparator(line);
    }

    private int RepairStringListLineQuotes(int lineIndex)
    {
        var repairCount = 0;
        var guard = 0;
        while (guard++ < 8)
        {
            var issue = GetStringListLineIssue(_lines[lineIndex], out var insertIndex, out var quote);
            if (insertIndex < 0 ||
                issue is not (StringListLineIssue.MissingOpeningQuoteAfterSeparator or StringListLineIssue.MissingClosingQuoteBeforeSeparator))
            {
                break;
            }

            _lines[lineIndex] = _lines[lineIndex].Insert(insertIndex, quote.ToString());
            repairCount++;
        }

        return repairCount;
    }

    private static StringListLineIssue GetStringListLineIssue(string line, out int repairInsertIndex, out char repairQuote)
    {
        repairInsertIndex = -1;
        repairQuote = '"';
        var commentIndex = FindCommentIndex(line);
        var limit = commentIndex >= 0 ? commentIndex : line.Length;

        for (var i = 0; i < limit; i++)
        {
            var quote = line[i];
            if (quote is not ('"' or '\''))
            {
                continue;
            }

            if (TryFindMissingOpeningQuoteRepair(line, i, out repairInsertIndex))
            {
                repairQuote = quote;
                return StringListLineIssue.MissingOpeningQuoteAfterSeparator;
            }

            var escaped = false;
            var closeIndex = -1;
            for (var j = i + 1; j < limit; j++)
            {
                var ch = line[j];
                if (escaped)
                {
                    escaped = false;
                    continue;
                }

                if (ch == '\\')
                {
                    escaped = true;
                    continue;
                }

                if (ch == quote)
                {
                    closeIndex = j;
                    break;
                }
            }

            if (closeIndex < 0)
            {
                return StringListLineIssue.UnfinishedString;
            }

            var nextIndex = FindNextCodeCharacter(line, closeIndex + 1, limit);
            if (nextIndex >= 0 && line[nextIndex] is not (',' or ';' or '}' or '"' or '\''))
            {
                if (TryFindMissingClosingQuoteRepair(line, i, closeIndex, out repairInsertIndex))
                {
                    repairQuote = quote;
                    return StringListLineIssue.MissingClosingQuoteBeforeSeparator;
                }

                return StringListLineIssue.MalformedTextAfterString;
            }

            i = closeIndex;
        }

        return StringListLineIssue.None;
    }

    private static bool TryFindMissingOpeningQuoteRepair(string line, int quoteIndex, out int insertIndex)
    {
        insertIndex = -1;
        for (var i = quoteIndex - 1; i >= 0; i--)
        {
            if (line[i] is '"' or '\'' or '}')
            {
                return false;
            }

            if (line[i] is not (',' or ';' or '{'))
            {
                continue;
            }

            var valueStart = FindNextCodeCharacter(line, i + 1, quoteIndex);
            if (valueStart < 0)
            {
                return false;
            }

            insertIndex = valueStart;
            return true;
        }

        return false;
    }

    private static bool TryFindMissingClosingQuoteRepair(string line, int startIndex, int closeIndex, out int insertIndex)
    {
        insertIndex = -1;
        for (var i = closeIndex - 1; i > startIndex; i--)
        {
            if (line[i] is not (',' or ';'))
            {
                if (!char.IsWhiteSpace(line[i]))
                {
                    return false;
                }

                continue;
            }

            var hasValueBeforeSeparator = line
                .Skip(startIndex + 1)
                .Take(i - startIndex - 1)
                .Any(ch => !char.IsWhiteSpace(ch));
            if (!hasValueBeforeSeparator)
            {
                return false;
            }

            insertIndex = i;
            return true;
        }

        return false;
    }

    private static int FindNextCodeCharacter(string line, int startIndex, int limit)
    {
        for (var i = Math.Max(0, startIndex); i < limit; i++)
        {
            if (!char.IsWhiteSpace(line[i]))
            {
                return i;
            }
        }

        return -1;
    }

    private static bool StringListLineEndsWithSeparator(string line)
    {
        var index = GetCodeEndIndex(line);
        while (index > 0 && char.IsWhiteSpace(line[index - 1]))
        {
            index--;
        }

        return index == 0 || line[index - 1] is ',' or ';' or '{';
    }

    private static bool HasLuaFieldSeparator(string line, int startIndex, int endIndex)
    {
        var limit = Math.Min(endIndex, line.Length);
        for (var i = Math.Max(0, startIndex); i < limit; i++)
        {
            if (line[i] is ',' or ';')
            {
                return true;
            }
        }

        return false;
    }

    private void InsertStringListLineSeparator(int lineIndex)
    {
        var insertIndex = GetCodeEndIndex(_lines[lineIndex]);
        while (insertIndex > 0 && char.IsWhiteSpace(_lines[lineIndex][insertIndex - 1]))
        {
            insertIndex--;
        }

        _lines[lineIndex] = _lines[lineIndex].Insert(insertIndex, ",");
    }

    private static int GetCodeEndIndex(string line)
    {
        var commentIndex = FindCommentIndex(line);
        return commentIndex >= 0 ? commentIndex : line.Length;
    }

    private void Parse()
    {
        Entries.Clear();
        StringListTables.Clear();
        StageTables.Clear();
        _guiLabels.Clear();
        _guiInstallPolicies.Clear();
        _topLevelGuiInstallPolicies.Clear();
        var section = "General";
        var pendingComments = new List<string>();
        var tablePath = new List<TableContext>();
        var inDoNotTouchBlock = false;

        for (var i = 0; i < _lines.Count; i++)
        {
            var line = _lines[i];
            var trimmed = line.Trim();

            if (trimmed.Contains("DO NOT TOUCH THIS BLOCK", StringComparison.OrdinalIgnoreCase))
            {
                inDoNotTouchBlock = true;
            }

            if (trimmed.Contains("End of do not touch", StringComparison.OrdinalIgnoreCase))
            {
                inDoNotTouchBlock = false;
                pendingComments.Clear();
                continue;
            }

            if (TryReadSection(i, out var foundSection))
            {
                section = foundSection;
                pendingComments.Clear();
                continue;
            }

            if (trimmed.Length == 0)
            {
                if (pendingComments.Count > 0 && IsNextLineAssignment(i + 1))
                {
                    continue;
                }

                pendingComments.Clear();
                continue;
            }

            if (trimmed.StartsWith("--", StringComparison.Ordinal))
            {
                if (!IsSectionDelimiter(trimmed) && !IsSectionTitleLine(i))
                {
                    pendingComments.Add(CleanComment(trimmed));
                }

                continue;
            }

            if (trimmed.StartsWith("}", StringComparison.Ordinal))
            {
                PopTable(tablePath);
                pendingComments.Clear();
                continue;
            }

            if (inDoNotTouchBlock)
            {
                pendingComments.Clear();
                continue;
            }

            var match = AssignmentRegex.Match(line);
            if (!match.Success)
            {
                pendingComments.Clear();
                continue;
            }

            var lhsWithEquals = match.Groups["lhs"].Value;
            var rest = match.Groups["rest"].Value;
            var lhs = lhsWithEquals[..lhsWithEquals.LastIndexOf('=')].Trim();
            var split = SplitValueAndSuffix(rest);
            var value = split.value.TrimEnd();
            var isTableStart = IsTableStart(value);

            if (isTableStart)
            {
                var key = NormalizeKey(lhs);
                var displayKey = BuildDisplayKey(tablePath, lhs);
                var guiLabel = ReadGuiLabel(pendingComments);
                var guiEditor = ReadGuiEditor(pendingComments);
                var guiVisibleWhen = ReadGuiVisibleWhen(pendingComments);
                var guiFields = ReadGuiFields(pendingComments);
                var guiUntickRowsWhen = ReadGuiUntickRowsWhen(pendingComments);
                var guiConfirmUntickRowsWhen = ReadGuiConfirmUntickRowsWhen(pendingComments);
                var guiConfirmSetRowsByEra = ReadGuiConfirmSetRowsByEra(pendingComments);
                var guiRowLabel = ReadGuiRowLabel(pendingComments);
                var linkedSettingKey = ReadGuiLinkedSetting(pendingComments);
                var installPolicy = ReadGuiInstallPolicy(pendingComments);
                if (!string.IsNullOrWhiteSpace(guiLabel))
                {
                    _guiLabels[displayKey] = guiLabel;
                }

                if (!string.IsNullOrWhiteSpace(installPolicy))
                {
                    _guiInstallPolicies[displayKey] = installPolicy;
                    _guiInstallPolicies[key] = installPolicy;
                    if (tablePath.Count == 0)
                    {
                        _topLevelGuiInstallPolicies[key] = installPolicy;
                    }
                }

                var tableParent = tablePath.LastOrDefault();
                var description = BuildDescription(pendingComments, split.inlineComment, CollectFollowingComments(i + 1));
                if (TryReadStringListTable(i, key, section, description, guiLabel, guiEditor, guiVisibleWhen, installPolicy, out var stringListTable))
                {
                    StringListTables.Add(stringListTable);
                    pendingComments.Clear();
                    i = stringListTable.EndLineIndex;
                    continue;
                }

                if (TryReadStageTable(i, key, section, description, guiLabel, linkedSettingKey, guiVisibleWhen, out var stageTable))
                {
                    StageTables.Add(stageTable);
                    pendingComments.Clear();
                    i = stageTable.EndLineIndex;
                    continue;
                }

                tablePath.Add(new TableContext
                {
                    Key = key,
                    DisplayKey = displayKey,
                    Description = string.IsNullOrWhiteSpace(description) ? tableParent?.Description ?? "" : description,
                    GuiEditor = guiEditor,
                    GuiFields = guiFields,
                    GuiUntickRowsWhen = guiUntickRowsWhen,
                    GuiConfirmUntickRowsWhen = guiConfirmUntickRowsWhen,
                    GuiConfirmSetRowsByEra = guiConfirmSetRowsByEra,
                    GuiRowLabel = guiRowLabel,
                    GuiVisibleWhen = guiVisibleWhen
                });
                pendingComments.Clear();
                continue;
            }

            if (ShouldSkipAssignment(lhs, value))
            {
                pendingComments.Clear();
                continue;
            }

            if (value.Length == 0)
            {
                if (TryReadLongTextEntry(i, lhsWithEquals, lhs, section, tablePath, pendingComments, split.inlineComment, out var longTextEntry))
                {
                    Entries.Add(longTextEntry);
                    pendingComments.Clear();
                    i = longTextEntry.EndLineIndex;
                    continue;
                }

                pendingComments.Clear();
                continue;
            }

            var kind = DetectKind(value, out var quoteChar);
            var parent = tablePath.LastOrDefault();
            var entry = new ConfigEntry
            {
                LineIndex = i,
                Section = section,
                Key = NormalizeKey(lhs),
                DisplayKey = BuildDisplayKey(tablePath, lhs),
                ParentKey = parent?.DisplayKey ?? "",
                ParentDescription = parent?.Description ?? "",
                Description = BuildDescription(pendingComments, split.inlineComment, CollectFollowingComments(i + 1)),
                InlineComment = split.inlineComment,
                GuiLabel = ReadGuiLabel(pendingComments),
                ParentGuiEditor = parent?.GuiEditor,
                ParentGuiFields = parent?.GuiFields,
                ParentGuiUntickRowsWhen = parent?.GuiUntickRowsWhen,
                ParentGuiConfirmUntickRowsWhen = parent?.GuiConfirmUntickRowsWhen,
                ParentGuiConfirmSetRowsByEra = parent?.GuiConfirmSetRowsByEra,
                ParentGuiRowLabel = parent?.GuiRowLabel,
                ParentGuiVisibleWhen = parent?.GuiVisibleWhen,
                GuiVisibleWhen = ReadGuiVisibleWhen(pendingComments),
                GuiValidValues = ReadGuiValidValues(pendingComments),
                Prefix = lhsWithEquals,
                Suffix = split.suffix,
                RawValue = value,
                Kind = kind,
                QuoteChar = quoteChar,
                InferredAdvanced = IsAdvancedEntry(tablePath, section, lhs),
                EndLineIndex = i
            };

            entry.InitializeValueText(ToDisplayValue(value, kind));
            AddChoices(entry);
            entry.UseChoiceDisplayForCurrentValue();
            AddTupleFields(entry);
            Entries.Add(entry);
            pendingComments.Clear();
        }
    }

    private static bool ShouldSkipAssignment(string lhs, string value)
    {
        if (lhs is "FootholdConfigLoadedOk")
        {
            return true;
        }

        if (value.Contains(" or ", StringComparison.Ordinal))
        {
            return true;
        }

        return false;
    }

    private bool TryFindTableBlock(string key, out int startLine, out int endLine)
    {
        startLine = -1;
        endLine = -1;
        for (var i = 0; i < _lines.Count; i++)
        {
            var match = AssignmentRegex.Match(_lines[i]);
            if (!match.Success)
            {
                continue;
            }

            var lhsWithEquals = match.Groups["lhs"].Value;
            var lhs = lhsWithEquals[..lhsWithEquals.LastIndexOf('=')].Trim();
            if (!NormalizeKey(lhs).Equals(key, StringComparison.Ordinal))
            {
                continue;
            }

            var value = SplitValueAndSuffix(match.Groups["rest"].Value).value.TrimEnd();
            if (!IsTableStart(value))
            {
                continue;
            }

            startLine = i;
            endLine = FindTableEndLine(i);
            return endLine >= startLine;
        }

        return false;
    }

    private bool TryReadStringListTable(
        int lineIndex,
        string key,
        string section,
        string description,
        string? guiLabel,
        string? guiEditor,
        string? guiVisibleWhen,
        string? installPolicy,
        out ConfigStringListTable table)
    {
        table = null!;
        if (!IsStringListTableKey(key) &&
            !string.Equals(guiEditor, "bucket", StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }

        var endLine = FindTableEndLine(lineIndex);
        if (endLine < lineIndex)
        {
            return false;
        }

        table = new ConfigStringListTable
        {
            Key = key,
            Section = section,
            Description = description,
            GuiLabel = guiLabel,
            GuiEditor = guiEditor,
            GuiVisibleWhen = guiVisibleWhen,
            InstallPolicy = installPolicy,
            StartLineIndex = lineIndex,
            EndLineIndex = endLine
        };
        RefreshStringListTableItems(table);
        return true;
    }

    private bool TryReadStageTable(
        int lineIndex,
        string key,
        string section,
        string description,
        string? guiLabel,
        string? linkedSettingKey,
        string? guiVisibleWhen,
        out ConfigStageTable table)
    {
        table = null!;
        if (!key.EndsWith("Stages", StringComparison.Ordinal))
        {
            return false;
        }

        var endLine = FindTableEndLine(lineIndex);
        if (endLine < lineIndex)
        {
            return false;
        }

        var rows = ReadStageRows(lineIndex, endLine);
        if (rows.Count == 0)
        {
            return false;
        }

        table = new ConfigStageTable
        {
            Key = key,
            Section = section,
            Description = description,
            GuiLabel = guiLabel,
            LinkedSettingKey = linkedSettingKey,
            GuiVisibleWhen = guiVisibleWhen,
            StartLineIndex = lineIndex,
            EndLineIndex = endLine
        };
        table.Rows.AddRange(rows);
        return true;
    }

    private List<ConfigStageRow> ReadStageRows(int startLine, int endLine)
    {
        var rows = new List<ConfigStageRow>();
        string? difficulty = null;
        for (var i = startLine + 1; i < endLine && i < _lines.Count; i++)
        {
            var line = _lines[i];
            var trimmed = line.Trim();
            var difficultyMatch = Regex.Match(trimmed, @"^(easy|medium|hard)\s*=\s*\{\s*$", RegexOptions.IgnoreCase);
            if (difficultyMatch.Success)
            {
                difficulty = NormalizeStageDifficulty(difficultyMatch.Groups[1].Value);
                continue;
            }

            if (difficulty is not null && trimmed.StartsWith("}", StringComparison.Ordinal))
            {
                difficulty = null;
                continue;
            }

            if (difficulty is not null && TryReadStageRow(line, i, difficulty, out var row))
            {
                rows.Add(row);
            }
        }

        return rows;
    }

    private static bool TryReadStageRow(string line, int lineIndex, string difficulty, out ConfigStageRow row)
    {
        row = null!;
        var commentIndex = FindCommentIndex(line);
        var code = commentIndex >= 0 ? line[..commentIndex] : line;
        if (!code.Contains("{", StringComparison.Ordinal) || !code.Contains("}", StringComparison.Ordinal))
        {
            return false;
        }

        if (!TryReadNamedDecimal(code, "player", out var player) ||
            !TryReadNamedDecimal(code, "amount", out var amount))
        {
            return false;
        }

        var closeIndex = code.LastIndexOf('}');
        if (closeIndex < 0)
        {
            return false;
        }

        row = new ConfigStageRow
        {
            Difficulty = difficulty,
            LineIndex = lineIndex,
            Indent = Regex.Match(line, @"^\s*").Value,
            Suffix = line[(closeIndex + 1)..],
            Player = player,
            Amount = amount
        };
        row.AcceptSavedValue();
        return true;
    }

    private static bool TryReadNamedDecimal(string text, string name, out decimal value)
    {
        value = 0m;
        var match = Regex.Match(text, @"\b" + Regex.Escape(name) + @"\s*=\s*(?<value>-?\d+(?:\.\d+)?)");
        return match.Success &&
               decimal.TryParse(match.Groups["value"].Value, NumberStyles.Float, CultureInfo.InvariantCulture, out value);
    }

    private static bool IsStringListTableKey(string key)
    {
        return key is "allowedPlanes" or "allowedPlanesRed" or "restockAircraft" or "restrictedWeapons" or "ForbiddWeaponsInAllEra" or "WarehouseWeaponCaps";
    }

    private int FindStageInsertLine(ConfigStageTable table, string difficulty)
    {
        var rows = table.Rows
            .Where(row => row.Difficulty.Equals(difficulty, StringComparison.OrdinalIgnoreCase))
            .OrderBy(row => row.LineIndex)
            .ToList();
        if (rows.Count > 0)
        {
            return rows[^1].LineIndex + 1;
        }

        for (var i = table.StartLineIndex + 1; i < table.EndLineIndex && i < _lines.Count; i++)
        {
            if (Regex.IsMatch(_lines[i].Trim(), "^" + Regex.Escape(difficulty) + @"\s*=\s*\{\s*$", RegexOptions.IgnoreCase))
            {
                return i + 1;
            }
        }

        throw new InvalidOperationException("Could not find the " + difficulty + " block in " + table.Key + ".");
    }

    private string GetStageRowIndent(ConfigStageTable table, string difficulty)
    {
        var sibling = table.Rows
            .Where(row => row.Difficulty.Equals(difficulty, StringComparison.OrdinalIgnoreCase))
            .OrderBy(row => row.LineIndex)
            .FirstOrDefault();
        if (sibling is not null)
        {
            return sibling.Indent;
        }

        var anyRow = table.Rows.OrderBy(row => row.LineIndex).FirstOrDefault();
        if (anyRow is not null)
        {
            return anyRow.Indent;
        }

        return "\t\t";
    }

    private static string NormalizeStageDifficulty(string difficulty)
    {
        var text = difficulty.Trim().ToLowerInvariant();
        return text is "easy" or "medium" or "hard" ? text : "medium";
    }

    private int FindTableEndLine(int startLine)
    {
        var depth = 0;
        for (var i = startLine; i < _lines.Count; i++)
        {
            depth += CountBraceDelta(_lines[i]);
            if (depth <= 0)
            {
                return i;
            }
        }

        return -1;
    }

    private static int CountBraceDelta(string line)
    {
        var delta = 0;
        var inQuote = false;
        var quote = '\0';
        var escaped = false;
        for (var i = 0; i < line.Length; i++)
        {
            var ch = line[i];
            if (inQuote)
            {
                if (escaped)
                {
                    escaped = false;
                    continue;
                }

                if (ch == '\\')
                {
                    escaped = true;
                    continue;
                }

                if (ch == quote)
                {
                    inQuote = false;
                }

                continue;
            }

            if (ch == '-' && i + 1 < line.Length && line[i + 1] == '-')
            {
                break;
            }

            if (ch is '"' or '\'')
            {
                inQuote = true;
                quote = ch;
                continue;
            }

            if (ch == '{')
            {
                delta++;
            }
            else if (ch == '}')
            {
                delta--;
            }
        }

        return delta;
    }

    private void RefreshStringListTableItems(ConfigStringListTable table)
    {
        table.Items.Clear();
        table.CommentedItems.Clear();
        for (var i = table.StartLineIndex; i <= table.EndLineIndex && i < _lines.Count; i++)
        {
            foreach (var token in ReadQuotedStringTokens(_lines[i]))
            {
                table.Items.Add(new ConfigStringListItem
                {
                    Value = ConfigEntry.UnquoteLuaString(token.Text),
                    LineIndex = i,
                    StartIndex = token.StartIndex,
                    Length = token.Length
                });
            }

            foreach (var token in ReadCommentedStringListTokens(_lines[i]))
            {
                table.CommentedItems.Add(new ConfigStringListItem
                {
                    Value = ConfigEntry.UnquoteLuaString(token.Text),
                    LineIndex = i,
                    StartIndex = token.StartIndex,
                    Length = token.Length,
                    IsCommented = true
                });
            }
        }
    }

    private static List<(string Text, int StartIndex, int Length)> ReadQuotedStringTokens(string line)
    {
        var commentIndex = FindCommentIndex(line);
        var limit = commentIndex >= 0 ? commentIndex : line.Length;
        return ReadQuotedStringTokens(line, 0, limit);
    }

    private static List<(string Text, int StartIndex, int Length)> ReadCommentedStringListTokens(string line)
    {
        var commentIndex = FindCommentIndex(line);
        if (commentIndex < 0 || line[..commentIndex].Trim().Length > 0)
        {
            return new List<(string Text, int StartIndex, int Length)>();
        }

        return ReadQuotedStringTokens(line, commentIndex + 2, line.Length);
    }

    private static List<(string Text, int StartIndex, int Length)> ReadQuotedStringTokens(string line, int startIndex, int limit)
    {
        var tokens = new List<(string Text, int StartIndex, int Length)>();
        for (var i = Math.Max(0, startIndex); i < Math.Min(limit, line.Length); i++)
        {
            var quote = line[i];
            if (quote is not ('"' or '\''))
            {
                continue;
            }

            var escaped = false;
            for (var j = i + 1; j < limit; j++)
            {
                var ch = line[j];
                if (escaped)
                {
                    escaped = false;
                    continue;
                }

                if (ch == '\\')
                {
                    escaped = true;
                    continue;
                }

                if (ch == quote)
                {
                    var length = j - i + 1;
                    tokens.Add((line.Substring(i, length), i, length));
                    i = j;
                    break;
                }
            }
        }

        return tokens;
    }

    private static string BuildDisplayKey(List<TableContext> tablePath, string lhs)
    {
        var key = NormalizeKey(lhs);
        if (tablePath.Count == 0)
        {
            return key;
        }

        return string.Join(".", tablePath.Select(context => context.Key).Concat(new[] { key }));
    }

    private static string NormalizeKey(string lhs)
    {
        var key = lhs.Trim();
        if (key.StartsWith("[", StringComparison.Ordinal) && key.EndsWith("]", StringComparison.Ordinal))
        {
            key = key[1..^1].Trim();
            key = ConfigEntry.UnquoteLuaString(key);
        }

        return key;
    }

    private bool TryReadLongTextEntry(
        int lineIndex,
        string lhsWithEquals,
        string lhs,
        string section,
        List<TableContext> tablePath,
        List<string> pendingComments,
        string inlineComment,
        out ConfigEntry entry)
    {
        entry = null!;
        if (lineIndex + 1 >= _lines.Count || !_lines[lineIndex + 1].TrimStart().StartsWith("[[", StringComparison.Ordinal))
        {
            return false;
        }

        var textLines = new List<string>();
        var endLine = -1;
        var suffix = "";
        for (var i = lineIndex + 1; i < _lines.Count; i++)
        {
            var current = _lines[i];
            var startIndex = i == lineIndex + 1 ? current.IndexOf("[[", StringComparison.Ordinal) + 2 : 0;
            var endIndex = current.IndexOf("]]", startIndex, StringComparison.Ordinal);

            if (endIndex >= 0)
            {
                textLines.Add(current[startIndex..endIndex]);
                suffix = SplitValueAndSuffix(current[(endIndex + 2)..]).suffix;
                endLine = i;
                break;
            }

            textLines.Add(current[startIndex..]);
        }

        if (endLine < 0)
        {
            return false;
        }

        var parent = tablePath.LastOrDefault();
        entry = new ConfigEntry
        {
            LineIndex = lineIndex,
            EndLineIndex = endLine,
            IsLongText = true,
            Section = section,
            Key = NormalizeKey(lhs),
            DisplayKey = BuildDisplayKey(tablePath, lhs),
            ParentKey = parent?.DisplayKey ?? "",
            ParentDescription = parent?.Description ?? "",
            Description = BuildDescription(pendingComments, inlineComment, CollectFollowingComments(endLine + 1)),
            InlineComment = inlineComment,
            GuiLabel = ReadGuiLabel(pendingComments),
            ParentGuiEditor = parent?.GuiEditor,
            ParentGuiFields = parent?.GuiFields,
            ParentGuiUntickRowsWhen = parent?.GuiUntickRowsWhen,
            ParentGuiConfirmUntickRowsWhen = parent?.GuiConfirmUntickRowsWhen,
            ParentGuiConfirmSetRowsByEra = parent?.GuiConfirmSetRowsByEra,
            ParentGuiRowLabel = parent?.GuiRowLabel,
            ParentGuiVisibleWhen = parent?.GuiVisibleWhen,
            GuiVisibleWhen = ReadGuiVisibleWhen(pendingComments),
            Prefix = lhsWithEquals,
            Suffix = suffix,
            RawValue = string.Join(NewLine, textLines),
            Kind = ConfigValueKind.String,
            QuoteChar = '"',
            InferredAdvanced = IsAdvancedEntry(tablePath, section, lhs)
        };
        entry.InitializeValueText(entry.RawValue);
        return true;
    }

    private static (string value, string suffix, string inlineComment) SplitValueAndSuffix(string rest)
    {
        var commentIndex = FindCommentIndex(rest);
        var beforeComment = commentIndex >= 0 ? rest[..commentIndex] : rest;
        var inlineComment = commentIndex >= 0 ? CleanComment(rest[commentIndex..].Trim()) : "";
        var codeRightTrimmed = beforeComment.TrimEnd();
        var valueEnd = codeRightTrimmed.Length;

        if (codeRightTrimmed.EndsWith(",", StringComparison.Ordinal))
        {
            valueEnd--;
        }

        var value = beforeComment[..valueEnd];
        var suffix = rest[valueEnd..];
        return (value, suffix, inlineComment);
    }

    private static int FindCommentIndex(string text)
    {
        var inQuote = false;
        var quote = '\0';
        var escaped = false;

        for (var i = 0; i < text.Length - 1; i++)
        {
            var ch = text[i];
            if (inQuote)
            {
                if (escaped)
                {
                    escaped = false;
                    continue;
                }

                if (ch == '\\')
                {
                    escaped = true;
                    continue;
                }

                if (ch == quote)
                {
                    inQuote = false;
                }

                continue;
            }

            if (ch is '"' or '\'')
            {
                inQuote = true;
                quote = ch;
                continue;
            }

            if (ch == '-' && text[i + 1] == '-')
            {
                return i;
            }
        }

        return -1;
    }

    private static ConfigValueKind DetectKind(string value, out char quoteChar)
    {
        var trimmed = value.Trim();
        quoteChar = '"';

        if (trimmed is "true" or "false")
        {
            return ConfigValueKind.Boolean;
        }

        if (double.TryParse(trimmed, NumberStyles.Float, CultureInfo.InvariantCulture, out _))
        {
            return ConfigValueKind.Number;
        }

        if (trimmed.Length >= 2 && ((trimmed[0] == '"' && trimmed[^1] == '"') || (trimmed[0] == '\'' && trimmed[^1] == '\'')))
        {
            quoteChar = trimmed[0];
            return ConfigValueKind.String;
        }

        return ConfigValueKind.Raw;
    }

    private static string ToDisplayValue(string value, ConfigValueKind kind)
    {
        return kind == ConfigValueKind.String ? ConfigEntry.UnquoteLuaString(value) : value.Trim();
    }

    private static bool IsTableStart(string value)
    {
        var trimmed = value.Trim();
        return trimmed.StartsWith("{", StringComparison.Ordinal) && !HasBalancedSingleLineBraces(trimmed);
    }

    private static bool HasBalancedSingleLineBraces(string text)
    {
        var depth = 0;
        foreach (var ch in text)
        {
            if (ch == '{')
            {
                depth++;
            }
            else if (ch == '}')
            {
                depth--;
            }
        }

        return depth == 0;
    }

    private static void PopTable(List<TableContext> tablePath)
    {
        if (tablePath.Count > 0)
        {
            tablePath.RemoveAt(tablePath.Count - 1);
        }
    }

    private bool TryReadSection(int index, out string section)
    {
        section = "";
        if (!IsSectionDelimiter(_lines[index]))
        {
            return false;
        }

        if (index + 2 >= _lines.Count || !IsSectionDelimiter(_lines[index + 2]))
        {
            return false;
        }

        var title = _lines[index + 1].Trim();
        if (!title.StartsWith("--", StringComparison.Ordinal))
        {
            return false;
        }

        section = CleanComment(title);
        return !string.IsNullOrWhiteSpace(section);
    }

    private bool IsSectionTitleLine(int index)
    {
        return index > 0 &&
               index + 1 < _lines.Count &&
               IsSectionDelimiter(_lines[index - 1]) &&
               IsSectionDelimiter(_lines[index + 1]);
    }

    private static bool IsSectionDelimiter(string line)
    {
        var trimmed = line.Trim();
        if (trimmed.StartsWith("-- @gui", StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }
        return trimmed.StartsWith("--", StringComparison.Ordinal) &&
               trimmed.Count(ch => ch == '=') >= 10;
    }

    private static string CleanComment(string comment)
    {
        var text = comment.Trim();
        if (text.StartsWith("--", StringComparison.Ordinal))
        {
            text = text[2..];
        }

        return text.Trim();
    }

    private string BuildDescription(List<string> pendingComments, string inlineComment, List<string> followingComments)
    {
        var parts = new List<string>();
        parts.AddRange(pendingComments.Where(IsUserFacingComment));

        if (IsUserFacingComment(inlineComment))
        {
            parts.Add(inlineComment);
        }

        parts.AddRange(followingComments.Where(IsUserFacingComment));
        return string.Join(Environment.NewLine, parts);
    }

    private static bool IsUserFacingComment(string comment)
    {
        return !string.IsNullOrWhiteSpace(comment) &&
               !comment.TrimStart().StartsWith("@gui", StringComparison.OrdinalIgnoreCase);
    }

    private static string? ReadGuiLabel(IEnumerable<string> comments)
    {
        return ReadGuiAttribute(comments, "label");
    }

    private static string? ReadGuiEditor(IEnumerable<string> comments)
    {
        return ReadGuiAttribute(comments, "editor");
    }

    private static string? ReadGuiFields(IEnumerable<string> comments)
    {
        return ReadGuiAttribute(comments, "fields");
    }

    private static string? ReadGuiVisibleWhen(IEnumerable<string> comments)
    {
        return ReadGuiAttribute(comments, "visibleWhen");
    }

    private static string? ReadGuiUntickRowsWhen(IEnumerable<string> comments)
    {
        var values = ReadGuiAttributes(comments, "untickRowsWhen");
        return values.Count == 0 ? null : string.Join(";", values);
    }

    private static string? ReadGuiConfirmUntickRowsWhen(IEnumerable<string> comments)
    {
        return ReadGuiAttribute(comments, "confirmUntickRowsWhen");
    }

    private static string? ReadGuiConfirmSetRowsByEra(IEnumerable<string> comments)
    {
        return ReadGuiAttribute(comments, "confirmSetRowsByEra");
    }

    private static string? ReadGuiRowLabel(IEnumerable<string> comments)
    {
        return ReadGuiAttribute(comments, "rowLabel");
    }

    private static string? ReadGuiLinkedSetting(IEnumerable<string> comments)
    {
        return ReadGuiAttribute(comments, "linkedSetting");
    }

    private static string? ReadGuiInstallPolicy(IEnumerable<string> comments)
    {
        return ReadGuiAttribute(comments, "installPolicy");
    }

    private static string? ReadGuiValidValues(IEnumerable<string> comments)
    {
        return ReadGuiAttribute(comments, "validValues") ??
               ReadGuiColonAttribute(comments, "validValues");
    }

    private static string? ReadGuiAttribute(IEnumerable<string> comments, string attributeName)
    {
        foreach (var comment in comments)
        {
            var trimmed = comment.Trim();
            if (!trimmed.StartsWith("@gui", StringComparison.OrdinalIgnoreCase))
            {
                continue;
            }

            foreach (Match match in GuiAttributeRegex.Matches(trimmed))
            {
                if (!match.Groups["name"].Value.Equals(attributeName, StringComparison.OrdinalIgnoreCase))
                {
                    continue;
                }

                var value = ReadGuiAttributeValue(match);
                if (!string.IsNullOrWhiteSpace(value))
                {
                    return value;
                }
            }
        }

        return null;
    }

    private static List<string> ReadGuiAttributes(IEnumerable<string> comments, string attributeName)
    {
        var values = new List<string>();
        foreach (var comment in comments)
        {
            var trimmed = comment.Trim();
            if (!trimmed.StartsWith("@gui", StringComparison.OrdinalIgnoreCase))
            {
                continue;
            }

            foreach (Match match in GuiAttributeRegex.Matches(trimmed))
            {
                if (!match.Groups["name"].Value.Equals(attributeName, StringComparison.OrdinalIgnoreCase))
                {
                    continue;
                }

                var value = ReadGuiAttributeValue(match);
                if (!string.IsNullOrWhiteSpace(value))
                {
                    values.Add(value);
                }
            }
        }

        return values;
    }

    private static string? ReadGuiColonAttribute(IEnumerable<string> comments, string attributeName)
    {
        foreach (var comment in comments)
        {
            var trimmed = comment.Trim();
            if (!trimmed.StartsWith("@gui", StringComparison.OrdinalIgnoreCase))
            {
                continue;
            }

            var body = trimmed[4..].TrimStart();
            if (!body.StartsWith(attributeName, StringComparison.OrdinalIgnoreCase))
            {
                continue;
            }

            var rest = body[attributeName.Length..].TrimStart();
            if (!rest.StartsWith(":", StringComparison.Ordinal))
            {
                continue;
            }

            var value = rest[1..].Trim();
            if (!string.IsNullOrWhiteSpace(value))
            {
                return value;
            }
        }

        return null;
    }

    private static string? ReadGuiAttributeValue(Match match)
    {
        foreach (var name in new[] { "dq", "sq", "bare" })
        {
            var value = match.Groups[name].Value.Trim();
            if (!string.IsNullOrWhiteSpace(value))
            {
                return value;
            }
        }

        return null;
    }

    private List<string> CollectFollowingComments(int startIndex)
    {
        var comments = new List<string>();
        for (var i = startIndex; i < _lines.Count; i++)
        {
            var trimmed = _lines[i].Trim();
            if (trimmed.Length == 0)
            {
                break;
            }

            if (!trimmed.StartsWith("--", StringComparison.Ordinal) || IsSectionDelimiter(trimmed) || IsSectionTitleLine(i))
            {
                break;
            }

            var comment = CleanComment(trimmed);
            if (string.IsNullOrWhiteSpace(comment))
            {
                break;
            }

            comments.Add(comment);
        }

        return comments;
    }

    private bool IsNextLineAssignment(int index)
    {
        if (index >= _lines.Count)
        {
            return false;
        }

        var trimmed = _lines[index].Trim();
        return trimmed.Length > 0 &&
               !trimmed.StartsWith("--", StringComparison.Ordinal) &&
               !IsSectionDelimiter(trimmed) &&
               AssignmentRegex.IsMatch(_lines[index]);
    }

    private static bool IsAdvancedEntry(List<TableContext> tablePath, string section, string lhs)
    {
        var key = NormalizeKey(lhs);
        if (tablePath.Count > 0)
        {
            return true;
        }

        if (key.StartsWith("GlobalSettings.", StringComparison.Ordinal) &&
            key.Contains("DifficultyScaling", StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }

        var advancedWords = new[]
        {
            "advanced",
            "restrictions",
            "warehouse restock",
            "ignore",
            "limit stages",
            "configuration"
        };

        return advancedWords.Any(word => section.Contains(word, StringComparison.OrdinalIgnoreCase));
    }

    private static void AddChoices(ConfigEntry entry)
    {
        if (AddGuiValidValueChoices(entry))
        {
            return;
        }

        if (entry.Kind == ConfigValueKind.Boolean)
        {
            AddKnownChoices(entry);
            return;
        }

        if (AddScopedKnownChoices(entry))
        {
            return;
        }

        var text = JoinDescriptions(entry.ParentDescription, entry.Description);
        if (string.IsNullOrWhiteSpace(text))
        {
            return;
        }

        var lower = text.ToLowerInvariant();
        var looksLikeChoiceHelp = lower.Contains("valid", StringComparison.Ordinal) ||
                                  lower.Contains("one of", StringComparison.Ordinal) ||
                                  lower.Contains("set ", StringComparison.Ordinal);

        if (!looksLikeChoiceHelp)
        {
            AddKnownChoices(entry);
            return;
        }

        foreach (Match match in QuotedChoiceRegex.Matches(text))
        {
            var display = match.Groups[1].Success ? match.Groups[1].Value : match.Groups[2].Value;
            var literal = QuoteWith(entry.QuoteChar, display);
            AddChoiceIfMissing(entry, display, literal);
        }

        foreach (var line in text.Split(new[] { "\r\n", "\n" }, StringSplitOptions.None))
        {
            if (!line.Contains('|', StringComparison.Ordinal))
            {
                continue;
            }

            var valueText = line.Contains(':', StringComparison.Ordinal) ? line[(line.IndexOf(':') + 1)..] : line;
            foreach (var part in valueText.Split('|'))
            {
                var token = part.Trim().TrimEnd('.');
                if (token.Equals("true", StringComparison.OrdinalIgnoreCase) ||
                    token.Equals("false", StringComparison.OrdinalIgnoreCase))
                {
                    AddChoiceIfMissing(entry, token.ToLowerInvariant(), token.ToLowerInvariant());
                }
                else if ((token.StartsWith("\"", StringComparison.Ordinal) && token.EndsWith("\"", StringComparison.Ordinal)) ||
                         (token.StartsWith("'", StringComparison.Ordinal) && token.EndsWith("'", StringComparison.Ordinal)))
                {
                    AddChoiceIfMissing(entry, ConfigEntry.UnquoteLuaString(token), token);
                }
            }
        }

        AddKnownChoices(entry);
    }

    private static bool AddGuiValidValueChoices(ConfigEntry entry)
    {
        if (string.IsNullOrWhiteSpace(entry.GuiValidValues))
        {
            return false;
        }

        var before = entry.Choices.Count;
        foreach (var part in entry.GuiValidValues.Split('|'))
        {
            AddGuiValidValueChoice(entry, part);
        }
        return entry.Choices.Count > before;
    }

    private static void AddGuiValidValueChoice(ConfigEntry entry, string text)
    {
        var token = text.Trim().TrimEnd('.', ',', ';').Trim();
        if (string.IsNullOrWhiteSpace(token))
        {
            return;
        }

        var equalsIndex = token.IndexOf('=');
        var display = equalsIndex >= 0 ? token[..equalsIndex].Trim() : token;
        var literal = equalsIndex >= 0 ? token[(equalsIndex + 1)..].Trim() : token;
        if (string.IsNullOrWhiteSpace(display))
        {
            display = literal;
        }

        if (entry.Kind == ConfigValueKind.Number && literal.EndsWith("%", StringComparison.Ordinal))
        {
            literal = literal[..^1].Trim();
        }
        else if (entry.Kind == ConfigValueKind.String &&
                 !literal.StartsWith("\"", StringComparison.Ordinal) &&
                 !literal.StartsWith("'", StringComparison.Ordinal))
        {
            literal = QuoteWith(entry.QuoteChar, literal);
        }

        AddChoiceIfMissing(entry, display, literal);
    }

    private static bool AddScopedKnownChoices(ConfigEntry entry)
    {
        if (entry.DisplayKey == "ewrs_defaultReference")
        {
            AddChoiceIfMissing(entry, "self", QuoteWith(entry.QuoteChar, "self"));
            AddChoiceIfMissing(entry, "bulls", QuoteWith(entry.QuoteChar, "bulls"));
            return true;
        }

        if (entry.DisplayKey == "ewrs_defaultMeasurements")
        {
            AddChoiceIfMissing(entry, "imperial", QuoteWith(entry.QuoteChar, "imperial"));
            AddChoiceIfMissing(entry, "metric", QuoteWith(entry.QuoteChar, "metric"));
            return true;
        }

        if (entry.DisplayKey == "ewrs_maxRangeKm")
        {
            foreach (var value in new[] { "10", "20", "40", "60", "80", "100", "150" })
            {
                AddChoiceIfMissing(entry, value, value);
            }
            return true;
        }

        if (entry.DisplayKey == "ewrs_maxRangeNm")
        {
            foreach (var value in new[] { "5", "10", "20", "40", "60", "80", "100" })
            {
                AddChoiceIfMissing(entry, value, value);
            }
            return true;
        }

        return false;
    }

    private static void AddKnownChoices(ConfigEntry entry)
    {
        var easyMediumHard = new[]
        {
            "CapDifficulty",
            "CasDifficulty",
            "SeadDifficulty",
            "RunwayStrikeDifficulty",
            "FriendlyCapSupport",
            "FriendlyCasSupport",
            "FriendlySeadSupport",
            "RedReactiveDifficulty"
        };

        if (easyMediumHard.Contains(entry.DisplayKey, StringComparer.Ordinal))
        {
            AddChoiceIfMissing(entry, "easy", QuoteWith(entry.QuoteChar, "easy"));
            AddChoiceIfMissing(entry, "medium", QuoteWith(entry.QuoteChar, "medium"));
            AddChoiceIfMissing(entry, "hard", QuoteWith(entry.QuoteChar, "hard"));
        }

        if (entry.DisplayKey == "HideSAMOnMFD")
        {
            AddChoiceIfMissing(entry, "false", "false");
            AddChoiceIfMissing(entry, "true", "true");
            AddChoiceIfMissing(entry, "random", QuoteWith(entry.QuoteChar, "random"));
        }

        if (entry.DisplayKey == "Era")
        {
            AddChoiceIfMissing(entry, "Modern", QuoteWith(entry.QuoteChar, "Modern"));
            AddChoiceIfMissing(entry, "Coldwar", QuoteWith(entry.QuoteChar, "Coldwar"));
            AddChoiceIfMissing(entry, "Gulfwar", QuoteWith(entry.QuoteChar, "Gulfwar"));
            AddChoiceIfMissing(entry, "Vietnam", QuoteWith(entry.QuoteChar, "Vietnam"));
        }
    }

    private static void AddTupleFields(ConfigEntry entry)
    {
        if (entry.Kind != ConfigValueKind.Raw)
        {
            return;
        }

        if (entry.ParentGuiEditor?.Equals("fieldTable", StringComparison.OrdinalIgnoreCase) == true)
        {
            var fields = ReadGuiFieldTableFields(entry.ParentGuiFields);
            if (fields.Count > 0)
            {
                entry.TupleFields.AddRange(fields);
                return;
            }
        }

        var values = entry.GetTupleValues();
        if (values.Count == 0)
        {
            return;
        }

        var comments = JoinDescriptions(entry.ParentDescription, entry.Description);
        if (comments.Contains("escortType", StringComparison.OrdinalIgnoreCase) && values.Count == 2)
        {
            entry.TupleFields.Add(new ConfigTupleField("Escort available", ConfigTupleFieldKind.Boolean));
            var escortType = new ConfigTupleField("Escort type", ConfigTupleFieldKind.Choice);
            foreach (var choice in ReadNumberChoices(comments))
            {
                escortType.Choices.Add(choice);
            }

            entry.TupleFields.Add(escortType);
            return;
        }

        var fieldNames = ReadTupleFieldNames(comments);
        if (fieldNames.Count == values.Count)
        {
            for (var i = 0; i < fieldNames.Count; i++)
            {
                entry.TupleFields.Add(new ConfigTupleField(fieldNames[i], DetectTupleFieldKind(values[i])));
            }
        }
    }

    private static List<ConfigTupleField> ReadGuiFieldTableFields(string? text)
    {
        if (string.IsNullOrWhiteSpace(text))
        {
            return new List<ConfigTupleField>();
        }

        var fields = new List<ConfigTupleField>();
        foreach (var part in text.Split('|', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
        {
            var pieces = part.Split(':', 3, StringSplitOptions.TrimEntries);
            if (pieces.Length < 2 || !IsSimpleLuaIdentifier(pieces[0]))
            {
                continue;
            }

            var kind = pieces.Length >= 3 ? ParseGuiFieldKind(pieces[2]) : ConfigTupleFieldKind.Raw;
            fields.Add(new ConfigTupleField(pieces[1], kind, pieces[0]));
        }

        return fields;
    }

    private static ConfigTupleFieldKind ParseGuiFieldKind(string value)
    {
        return value.Trim().ToLowerInvariant() switch
        {
            "bool" or "boolean" or "checkbox" => ConfigTupleFieldKind.Boolean,
            "number" or "numeric" or "int" or "integer" or "decimal" => ConfigTupleFieldKind.Number,
            "choice" or "dropdown" => ConfigTupleFieldKind.Choice,
            _ => ConfigTupleFieldKind.Raw
        };
    }

    private static bool IsSimpleLuaIdentifier(string value)
    {
        return Regex.IsMatch(value, @"^[A-Za-z_][A-Za-z0-9_]*$");
    }

    private static List<ConfigChoice> ReadNumberChoices(string comments)
    {
        var choices = new List<ConfigChoice>();
        foreach (Match match in NumberChoiceRegex.Matches(comments))
        {
            var literal = match.Groups["number"].Value;
            var name = match.Groups["name"].Value.Trim().TrimEnd(',', '.', ')');
            if (string.IsNullOrWhiteSpace(name))
            {
                continue;
            }

            if (choices.Any(choice => choice.Literal == literal))
            {
                continue;
            }

            choices.Add(new ConfigChoice(name, literal));
        }

        return choices;
    }

    private static List<string> ReadTupleFieldNames(string comments)
    {
        var match = Regex.Match(comments, @"\{\s*(?<fields>[A-Za-z0-9_,\s]+)\s*\}");
        if (!match.Success)
        {
            return new List<string>();
        }

        return match.Groups["fields"].Value
            .Split(',')
            .Select(field => field.Trim())
            .Where(field => field.Length > 0)
            .Select(HumanizeTupleField)
            .ToList();
    }

    private static ConfigTupleFieldKind DetectTupleFieldKind(string value)
    {
        var trimmed = value.Trim();
        if (trimmed.Equals("true", StringComparison.OrdinalIgnoreCase) ||
            trimmed.Equals("false", StringComparison.OrdinalIgnoreCase))
        {
            return ConfigTupleFieldKind.Boolean;
        }

        return double.TryParse(trimmed, NumberStyles.Float, CultureInfo.InvariantCulture, out _)
            ? ConfigTupleFieldKind.Number
            : ConfigTupleFieldKind.Raw;
    }

    private static string HumanizeTupleField(string field)
    {
        var text = Regex.Replace(field, @"(?<=[a-z0-9])(?=[A-Z])", " ");
        return CultureInfo.InvariantCulture.TextInfo.ToTitleCase(text.ToLowerInvariant())
            .Replace("Ctld", "CTLD", StringComparison.Ordinal);
    }

    private static string JoinDescriptions(string first, string second)
    {
        if (string.IsNullOrWhiteSpace(first))
        {
            return second;
        }

        if (string.IsNullOrWhiteSpace(second))
        {
            return first;
        }

        return first + Environment.NewLine + second;
    }

    private static void AddChoiceIfMissing(ConfigEntry entry, string display, string literal)
    {
        if (entry.Choices.Any(choice => StringComparer.OrdinalIgnoreCase.Equals(choice.Display, display)))
        {
            return;
        }

        entry.Choices.Add(new ConfigChoice(display, literal));
    }

    private static string QuoteWith(char quoteChar, string display)
    {
        quoteChar = quoteChar is '\'' ? '\'' : '"';
        var escaped = display.Replace("\\", "\\\\", StringComparison.Ordinal)
            .Replace(quoteChar.ToString(), "\\" + quoteChar, StringComparison.Ordinal);
        return quoteChar + escaped + quoteChar;
    }
}
