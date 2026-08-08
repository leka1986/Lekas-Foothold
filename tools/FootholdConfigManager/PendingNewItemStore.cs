using System.Text.Json;
using System.Text.Json.Serialization;

namespace FootholdConfigManager;

internal readonly record struct PendingNewItemKey(string TableKey, string Value);

internal sealed class PendingNewItemSession
{
    private readonly PendingNewItemStore _store;
    private readonly string _configPath;
    private readonly HashSet<PendingNewItemKey> _resolved = new();

    internal PendingNewItemSession(PendingNewItemStore store, string configPath)
    {
        _store = store;
        _configPath = PendingNewItemStore.NormalizeConfigPath(configPath);
    }

    internal IReadOnlyCollection<PendingNewItemKey> GetPending()
    {
        return _store.Get(_configPath)
            .Where(item => !_resolved.Contains(item))
            .ToList();
    }

    internal bool IsPending(string tableKey, string value)
    {
        var key = new PendingNewItemKey(tableKey, value);
        return !_resolved.Contains(key) && _store.Contains(_configPath, tableKey, value);
    }

    internal bool Resolve(string tableKey, string value)
    {
        return _store.Contains(_configPath, tableKey, value) &&
               _resolved.Add(new PendingNewItemKey(tableKey, value));
    }

    internal bool Restore(string tableKey, string value)
    {
        return _resolved.Remove(new PendingNewItemKey(tableKey, value));
    }

    internal void ResetResolved()
    {
        _resolved.Clear();
    }

    internal bool CommitResolved(string? storePath = null)
    {
        if (_resolved.Count == 0)
        {
            return false;
        }

        var committed = _resolved.ToList();
        _store.Remove(_configPath, committed);
        try
        {
            if (string.IsNullOrWhiteSpace(storePath))
            {
                _store.Save();
            }
            else
            {
                _store.SaveTo(storePath);
            }

            _resolved.Clear();
            return true;
        }
        catch
        {
            _store.Add(_configPath, committed);
            _resolved.Clear();
            throw;
        }
    }
}

internal sealed class PendingNewItemStore
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        WriteIndented = true
    };

    [JsonPropertyName("configs")]
    public Dictionary<string, Dictionary<string, List<string>>> Configs { get; set; } =
        new(StringComparer.OrdinalIgnoreCase);

    [JsonIgnore]
    internal string? LoadWarning { get; private set; }

    internal static string StorePath => Path.Combine(RuntimeSettings.SettingsDirectory, "pending-new-items.json");

    internal static PendingNewItemStore Load()
    {
        return LoadFrom(StorePath);
    }

    internal static PendingNewItemStore LoadFrom(string path)
    {
        if (!File.Exists(path))
        {
            return new PendingNewItemStore();
        }

        try
        {
            var loaded = JsonSerializer.Deserialize<PendingNewItemStore>(File.ReadAllText(path), JsonOptions);
            return loaded?.Normalize() ?? new PendingNewItemStore();
        }
        catch (Exception ex)
        {
            return new PendingNewItemStore
            {
                LoadWarning = "Pending NEW marker storage could not be read: " + ex.Message
            };
        }
    }

    internal IReadOnlyCollection<PendingNewItemKey> Get(string configPath)
    {
        var normalizedPath = NormalizeConfigPath(configPath);
        if (!Configs.TryGetValue(normalizedPath, out var tables))
        {
            return Array.Empty<PendingNewItemKey>();
        }

        return tables
            .SelectMany(table => table.Value.Select(value => new PendingNewItemKey(table.Key, value)))
            .ToList();
    }

    internal bool Contains(string configPath, string tableKey, string value)
    {
        var normalizedPath = NormalizeConfigPath(configPath);
        return Configs.TryGetValue(normalizedPath, out var tables) &&
               tables.TryGetValue(tableKey, out var values) &&
               values.Any(existing => existing.Equals(value, StringComparison.Ordinal));
    }

    internal bool Add(string configPath, string tableKey, string value)
    {
        if (string.IsNullOrWhiteSpace(configPath) ||
            string.IsNullOrWhiteSpace(tableKey) ||
            string.IsNullOrWhiteSpace(value))
        {
            return false;
        }

        var normalizedPath = NormalizeConfigPath(configPath);
        if (!Configs.TryGetValue(normalizedPath, out var tables))
        {
            tables = new Dictionary<string, List<string>>(StringComparer.Ordinal);
            Configs[normalizedPath] = tables;
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

    internal bool Add(string configPath, IEnumerable<PendingNewItemKey> items)
    {
        var changed = false;
        foreach (var item in items)
        {
            changed |= Add(configPath, item.TableKey, item.Value);
        }

        return changed;
    }

    internal bool Replace(string configPath, IEnumerable<PendingNewItemKey> items)
    {
        var normalizedPath = NormalizeConfigPath(configPath);
        var replacement = items.Distinct().ToList();
        var existing = Get(normalizedPath).ToHashSet();
        if (existing.SetEquals(replacement))
        {
            return false;
        }

        Configs.Remove(normalizedPath);
        Add(normalizedPath, replacement);
        return true;
    }

    internal bool Remove(string configPath, string tableKey, string value)
    {
        var normalizedPath = NormalizeConfigPath(configPath);
        if (!Configs.TryGetValue(normalizedPath, out var tables) ||
            !tables.TryGetValue(tableKey, out var values))
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
            Configs.Remove(normalizedPath);
        }

        return removed;
    }

    internal bool Remove(string configPath, IEnumerable<PendingNewItemKey> items)
    {
        var changed = false;
        foreach (var item in items)
        {
            changed |= Remove(configPath, item.TableKey, item.Value);
        }

        return changed;
    }

    internal int Reconcile(string configPath, ConfigDocument document)
    {
        var markers = Get(configPath);
        if (markers.Count == 0)
        {
            return 0;
        }

        var knownValuesByTable = document.StringListTables.ToDictionary(
            table => table.Key,
            table => table.Items
                .Concat(table.CommentedItems)
                .Select(item => item.Value)
                .ToHashSet(StringComparer.Ordinal),
            StringComparer.Ordinal);
        var stale = markers
            .Where(marker =>
                !knownValuesByTable.TryGetValue(marker.TableKey, out var values) ||
                !values.Contains(marker.Value))
            .ToList();
        Remove(configPath, stale);
        return stale.Count;
    }

    internal void Save()
    {
        SaveTo(StorePath);
    }

    internal void SaveTo(string path)
    {
        AtomicFile.WriteUtf8Text(path, JsonSerializer.Serialize(this, JsonOptions));
    }

    internal static string NormalizeConfigPath(string path)
    {
        return Path.GetFullPath(path);
    }

    private PendingNewItemStore Normalize()
    {
        Configs ??= new Dictionary<string, Dictionary<string, List<string>>>(StringComparer.OrdinalIgnoreCase);
        Configs = Configs
            .Where(config => !string.IsNullOrWhiteSpace(config.Key))
            .ToDictionary(
                config => NormalizeConfigPath(config.Key),
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
        return this;
    }
}
