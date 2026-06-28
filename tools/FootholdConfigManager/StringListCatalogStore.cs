using System.Text.Json;
using System.Text.Json.Serialization;

namespace FootholdConfigManager;

internal sealed class StringListCatalogStore
{
    private static readonly HashSet<string> Ww2AircraftCatalogValues = new(StringComparer.Ordinal)
    {
        "P-51D-30-NA",
        "SpitfireLFMkIX",
        "MosquitoFBMkVI",
        "Bf-109K-4",
        "FW-190A8",
        "FW-190D9",
        "F4U-1D",
        "F4U-1D_CW",
        "I-16",
        "P-47D-30",
        "P-47D-30bl1",
        "P-47D-40",
        "P-51D",
        "SpitfireLFMkIXCW",
        "La-7",
        "TF-51D"
    };

    private static readonly HashSet<string> ModernAircraftCatalogValues = new(StringComparer.Ordinal)
    {
        "A-10A",
        "A-10C",
        "A-10C_2",
        "AH-64D_BLK_II",
        "F-14B",
        "F-15C",
        "F-16C_50",
        "FA-18C_hornet",
        "Mi-24P",
        "UH-60L"
    };

    private static readonly HashSet<string> AircraftCatalogTableKeys = new(StringComparer.Ordinal)
    {
        "allowedPlanes",
        "allowedPlanesRed"
    };

    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        WriteIndented = true
    };

    [JsonPropertyName("tables")]
    public Dictionary<string, List<string>> Tables { get; set; } = new(StringComparer.Ordinal);
    [JsonPropertyName("configs")]
    public Dictionary<string, Dictionary<string, List<string>>> Configs { get; set; } = new(StringComparer.OrdinalIgnoreCase);
    [JsonIgnore]
    private bool NeedsSave { get; set; }

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

    public bool RefreshFrom(ConfigDocument document)
    {
        var scope = GetScope(document);
        var refreshedTables = new Dictionary<string, List<string>>(StringComparer.Ordinal);
        foreach (var table in document.StringListTables)
        {
            var values = table.Items
                .Concat(table.CommentedItems)
                .Select(item => item.Value)
                .Where(value => !string.IsNullOrWhiteSpace(value))
                .Distinct(StringComparer.Ordinal)
                .ToList();
            if (values.Count > 0)
            {
                refreshedTables[table.Key] = values;
            }
        }

        var changed = NeedsSave ||
                      !Configs.TryGetValue(scope, out var currentTables) ||
                      !CatalogTablesEqual(currentTables, refreshedTables);
        if (refreshedTables.Count > 0)
        {
            Configs[scope] = refreshedTables;
        }
        else
        {
            Configs.Remove(scope);
        }

        return changed;
    }

    public IReadOnlyList<string> GetValues(ConfigDocument document, string tableKey)
    {
        var scope = GetScope(document);
        return Configs.TryGetValue(scope, out var tables) && tables.TryGetValue(tableKey, out var values)
            ? values
            : Array.Empty<string>();
    }

    public bool Add(ConfigDocument document, string tableKey, string value)
    {
        return Add(GetScope(document), tableKey, value);
    }

    private bool Add(string scope, string tableKey, string value)
    {
        if (string.IsNullOrWhiteSpace(scope) || string.IsNullOrWhiteSpace(tableKey) || string.IsNullOrWhiteSpace(value))
        {
            return false;
        }

        if (!Configs.TryGetValue(scope, out var tables))
        {
            tables = new Dictionary<string, List<string>>(StringComparer.Ordinal);
            Configs[scope] = tables;
        }

        if (!tables.TryGetValue(tableKey, out var values))
        {
            values = new List<string>();
            tables[tableKey] = values;
        }

        if (values.Any(existing => existing.Equals(value, StringComparison.Ordinal)))
        {
            return false;
        }

        values.Add(value);
        return true;
    }

    private static bool CatalogTablesEqual(
        Dictionary<string, List<string>> left,
        Dictionary<string, List<string>> right)
    {
        if (left.Count != right.Count)
        {
            return false;
        }

        foreach (var (tableKey, leftValues) in left)
        {
            if (!right.TryGetValue(tableKey, out var rightValues) ||
                leftValues.Count != rightValues.Count ||
                !leftValues.SequenceEqual(rightValues))
            {
                return false;
            }
        }

        return true;
    }

    public bool Remove(ConfigDocument document, string tableKey, string value)
    {
        var scope = GetScope(document);
        if (!Configs.TryGetValue(scope, out var tables) || !tables.TryGetValue(tableKey, out var values))
        {
            return false;
        }

        var removed = values.RemoveAll(existing => existing.Equals(value, StringComparison.Ordinal)) > 0;
        if (values.Count == 0)
        {
            tables.Remove(tableKey);
        }
        if (tables.Count == 0)
        {
            Configs.Remove(scope);
        }

        return removed;
    }

    public void Save()
    {
        Directory.CreateDirectory(RuntimeSettings.SettingsDirectory);
        File.WriteAllText(CatalogPath, JsonSerializer.Serialize(this, JsonOptions));
        NeedsSave = false;
    }

    private StringListCatalogStore Normalize()
    {
        Tables ??= new Dictionary<string, List<string>>(StringComparer.Ordinal);
        Configs ??= new Dictionary<string, Dictionary<string, List<string>>>(StringComparer.OrdinalIgnoreCase);
        Tables = Tables
            .Where(table => !string.IsNullOrWhiteSpace(table.Key))
            .ToDictionary(
                table => table.Key,
                table => (table.Value ?? new List<string>())
                    .Where(value => !string.IsNullOrWhiteSpace(value))
                    .Distinct(StringComparer.Ordinal)
                    .ToList(),
                StringComparer.Ordinal);
        Configs = Configs
            .Where(config => !string.IsNullOrWhiteSpace(config.Key))
            .ToDictionary(
                config => config.Key,
                config => (config.Value ?? new Dictionary<string, List<string>>(StringComparer.Ordinal))
                    .Where(table => !string.IsNullOrWhiteSpace(table.Key))
                    .ToDictionary(
                        table => table.Key,
                        table => (table.Value ?? new List<string>())
                            .Where(value => !string.IsNullOrWhiteSpace(value))
                            .Distinct(StringComparer.Ordinal)
                            .ToList(),
                        StringComparer.Ordinal),
                StringComparer.OrdinalIgnoreCase);
        if (Tables.Count > 0)
        {
            if (!Configs.ContainsKey(RuntimeSettings.DefaultConfigFileName))
            {
                Configs[RuntimeSettings.DefaultConfigFileName] = Tables.ToDictionary(
                    table => table.Key,
                    table => table.Value.ToList(),
                    StringComparer.Ordinal);
            }

            Tables = new Dictionary<string, List<string>>(StringComparer.Ordinal);
            NeedsSave = true;
        }

        if (MoveMisScopedWw2AircraftToWw2Catalog())
        {
            NeedsSave = true;
        }

        return this;
    }

    private bool MoveMisScopedWw2AircraftToWw2Catalog()
    {
        if (!Configs.TryGetValue(RuntimeSettings.DefaultConfigFileName, out var normalTables))
        {
            return false;
        }

        var changed = false;
        foreach (var tableKey in AircraftCatalogTableKeys)
        {
            if (!normalTables.TryGetValue(tableKey, out var values))
            {
                continue;
            }

            var ww2Values = values
                .Where(value => Ww2AircraftCatalogValues.Contains(value))
                .ToList();
            if (ww2Values.Count == 0)
            {
                continue;
            }

            foreach (var value in ww2Values)
            {
                Add(RuntimeSettings.Ww2ConfigFileName, tableKey, value);
            }

            values.RemoveAll(value => Ww2AircraftCatalogValues.Contains(value));
            if (values.Count == 0)
            {
                normalTables.Remove(tableKey);
            }
            changed = true;
        }

        if (normalTables.Count == 0)
        {
            Configs.Remove(RuntimeSettings.DefaultConfigFileName);
        }

        return changed;
    }

    private static string GetScope(ConfigDocument document)
    {
        var scope = GetScope(document.Path);
        return scope.Equals(RuntimeSettings.DefaultConfigFileName, StringComparison.OrdinalIgnoreCase) &&
               LooksLikeWw2Config(document)
            ? RuntimeSettings.Ww2ConfigFileName
            : scope;
    }

    private static string GetScope(string configPath)
    {
        var fileName = Path.GetFileName(configPath);
        return string.IsNullOrWhiteSpace(fileName)
            ? RuntimeSettings.DefaultConfigFileName
            : fileName;
    }

    private static bool LooksLikeWw2Config(ConfigDocument document)
    {
        var table = document.StringListTables
            .FirstOrDefault(item => item.Key.Equals("allowedPlanes", StringComparison.Ordinal));
        if (table is null)
        {
            return false;
        }

        var values = table.Items
            .Concat(table.CommentedItems)
            .Select(item => item.Value)
            .Distinct(StringComparer.Ordinal)
            .ToList();
        var ww2Matches = values.Count(value => Ww2AircraftCatalogValues.Contains(value));
        var modernMatches = values.Count(value => ModernAircraftCatalogValues.Contains(value));

        return ww2Matches >= 6 && modernMatches == 0;
    }
}
