using System.Text.Json;
using System.Text.Json.Serialization;

namespace FootholdConfigManager;

internal sealed class StringListCatalogStore
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        WriteIndented = true
    };

    [JsonPropertyName("tables")]
    public Dictionary<string, List<string>> Tables { get; set; } = new(StringComparer.Ordinal);

    public static string CatalogPath => Path.Combine(RuntimeSettings.SettingsDirectory, "catalog.json");

    public static StringListCatalogStore Load()
    {
        if (!File.Exists(CatalogPath))
        {
            return new StringListCatalogStore();
        }

        try
        {
            var loaded = JsonSerializer.Deserialize<StringListCatalogStore>(File.ReadAllText(CatalogPath), JsonOptions);
            return loaded?.Normalize() ?? new StringListCatalogStore();
        }
        catch
        {
            return new StringListCatalogStore();
        }
    }

    public bool MergeFrom(ConfigDocument document)
    {
        var changed = false;
        foreach (var table in document.StringListTables)
        {
            foreach (var value in table.Items.Concat(table.CommentedItems).Select(item => item.Value))
            {
                changed |= Add(table.Key, value);
            }
        }

        return changed;
    }

    public IReadOnlyList<string> GetValues(string tableKey)
    {
        return Tables.TryGetValue(tableKey, out var values)
            ? values
            : Array.Empty<string>();
    }

    public bool Add(string tableKey, string value)
    {
        if (string.IsNullOrWhiteSpace(tableKey) || string.IsNullOrWhiteSpace(value))
        {
            return false;
        }

        if (!Tables.TryGetValue(tableKey, out var values))
        {
            values = new List<string>();
            Tables[tableKey] = values;
        }

        if (values.Any(existing => existing.Equals(value, StringComparison.Ordinal)))
        {
            return false;
        }

        values.Add(value);
        return true;
    }

    public bool Remove(string tableKey, string value)
    {
        if (!Tables.TryGetValue(tableKey, out var values))
        {
            return false;
        }

        var removed = values.RemoveAll(existing => existing.Equals(value, StringComparison.Ordinal)) > 0;
        if (values.Count == 0)
        {
            Tables.Remove(tableKey);
        }

        return removed;
    }

    public void Save()
    {
        Directory.CreateDirectory(RuntimeSettings.SettingsDirectory);
        File.WriteAllText(CatalogPath, JsonSerializer.Serialize(this, JsonOptions));
    }

    private StringListCatalogStore Normalize()
    {
        Tables = Tables
            .Where(table => !string.IsNullOrWhiteSpace(table.Key))
            .ToDictionary(
                table => table.Key,
                table => table.Value
                    .Where(value => !string.IsNullOrWhiteSpace(value))
                    .Distinct(StringComparer.Ordinal)
                    .ToList(),
                StringComparer.Ordinal);
        return this;
    }
}
