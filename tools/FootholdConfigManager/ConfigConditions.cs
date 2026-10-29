namespace FootholdConfigManager;

internal static class ConfigConditions
{
    internal static ConfigEntry? FindSource(ConfigDocument document, string key)
    {
        return document.Entries.FirstOrDefault(entry => entry.DisplayKey.Equals(key, StringComparison.Ordinal)) ??
               document.Entries.FirstOrDefault(entry => entry.Key.Equals(key, StringComparison.Ordinal));
    }

    internal static bool ValueMatches(string sourceValue, IReadOnlyList<string> expectedValues)
    {
        var normalizedSourceValue = Normalize(sourceValue);
        return expectedValues.Any(value =>
            Normalize(value).Equals(normalizedSourceValue, StringComparison.OrdinalIgnoreCase));
    }

    internal static bool Matches(ConfigDocument document, IReadOnlyList<(string SourceKey, List<string> Values)> rules)
    {
        foreach (var rule in rules)
        {
            var source = FindSource(document, rule.SourceKey);
            if (source is null)
            {
                if (!rule.SourceKey.Contains('|')) continue;
                var alternatives = rule.SourceKey.Split('|', StringSplitOptions.TrimEntries);
                if (alternatives.Any(string.IsNullOrWhiteSpace) || !alternatives.Any(key =>
                    FindSource(document, key) is { } candidate && ValueMatches(candidate.ValueText, rule.Values))) return false;
                continue;
            }
            if (!ValueMatches(source.ValueText, rule.Values)) return false;
        }
        return true;
    }

    internal static string Normalize(string value)
    {
        return ConfigEntry.UnquoteLuaString(value.Trim());
    }

    internal static List<(string SourceKey, List<string> Values)> Parse(string ruleText) => Parse(ruleText, out _);
    internal static List<(string SourceKey, List<string> Values)> Parse(string ruleText, out bool malformed)
    {
        malformed = false;
        var rules = new List<(string SourceKey, List<string> Values)>();
        foreach (var rawRule in ruleText.Split(';', StringSplitOptions.TrimEntries))
        {
            if (string.IsNullOrWhiteSpace(rawRule)) { malformed = true; continue; }
            var separator = rawRule.IndexOf(':');
            if (separator <= 0 || separator >= rawRule.Length - 1)
            {
                malformed = true;
                continue;
            }

            var sourceKey = rawRule[..separator].Trim();
            var values = rawRule[(separator + 1)..]
                .Split('|', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                .Where(value => !string.IsNullOrWhiteSpace(value))
                .ToList();
            if (string.IsNullOrWhiteSpace(sourceKey) || values.Count == 0)
            {
                malformed = true;
                continue;
            }

            rules.Add((sourceKey, values));
        }

        return rules;
    }

}
