using System.Text.RegularExpressions;

namespace FootholdConfigManager;

internal sealed record ConfigSearchIndexItem(
    string TargetKey,
    string? RowKey,
    string DisplayName,
    string CategoryName,
    string CategoryLabel,
    string Description,
    int Order);

internal sealed record ConfigSearchIndexMatch(ConfigSearchIndexItem Item, int Score, string Excerpt);

internal static class ConfigSearchIndex
{
    public static List<ConfigSearchIndexMatch> Search(
        IReadOnlyList<ConfigSearchIndexItem> items,
        string query,
        int limit = 250)
    {
        return items
            .Select(item => new
            {
                Item = item,
                Score = GetMatchScore(
                    query,
                    item.RowKey ?? item.TargetKey,
                    item.DisplayName,
                    item.CategoryLabel,
                    item.Description)
            })
            .Where(match => match.Score >= 0)
            .OrderBy(match => match.Score)
            .ThenBy(match => match.Item.Order)
            .Take(limit)
            .Select(match => new ConfigSearchIndexMatch(
                match.Item,
                match.Score,
                GetExcerpt(match.Item.Description, query)))
            .ToList();
    }

    private static int GetMatchScore(
        string query,
        string key,
        string displayName,
        string categoryLabel,
        string description)
    {
        if (key.Equals(query, StringComparison.OrdinalIgnoreCase) ||
            displayName.Equals(query, StringComparison.OrdinalIgnoreCase))
        {
            return 0;
        }

        if (key.StartsWith(query, StringComparison.OrdinalIgnoreCase) ||
            displayName.StartsWith(query, StringComparison.OrdinalIgnoreCase))
        {
            return 1;
        }

        if (key.Contains(query, StringComparison.OrdinalIgnoreCase) ||
            displayName.Contains(query, StringComparison.OrdinalIgnoreCase))
        {
            return 2;
        }

        if (description.Contains(query, StringComparison.OrdinalIgnoreCase))
        {
            return 3;
        }

        return categoryLabel.Contains(query, StringComparison.OrdinalIgnoreCase) ? 4 : -1;
    }

    private static string GetExcerpt(string description, string query)
    {
        if (string.IsNullOrWhiteSpace(description))
        {
            return "";
        }

        var lines = description
            .Replace("\r\n", "\n", StringComparison.Ordinal)
            .Replace('\r', '\n')
            .Split('\n', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
        var line = lines.FirstOrDefault(candidate => candidate.Contains(query, StringComparison.OrdinalIgnoreCase)) ??
                   lines.FirstOrDefault() ?? "";
        return Regex.Replace(line, @"\s+", " ").Trim();
    }
}
