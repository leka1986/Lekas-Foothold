using System.Text.Json;
using System.Text.RegularExpressions;

namespace FootholdConfigManager;

internal static class PresetStore
{
    private static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented = true };

    public static string DirectoryPath => Path.Combine(RuntimeSettings.SettingsDirectory, "presets");

    private static string LegacyDirectoryPath => Path.Combine(AppContext.BaseDirectory, "presets");

    public static List<string> ListPresetNames()
    {
        EnsureDirectory();
        return Directory.EnumerateFiles(DirectoryPath, "*.json")
            .Select(Path.GetFileNameWithoutExtension)
            .Where(name => !string.IsNullOrWhiteSpace(name))
            .Cast<string>()
            .OrderBy(name => name, StringComparer.OrdinalIgnoreCase)
            .ToList();
    }

    public static void Save(string name, IEnumerable<ConfigEntry> entries)
    {
        EnsureDirectory();
        var values = entries.ToDictionary(entry => entry.DisplayKey, entry => entry.ValueText, StringComparer.Ordinal);
        var path = Path.Combine(DirectoryPath, SafeName(name) + ".json");
        File.WriteAllText(path, JsonSerializer.Serialize(values, JsonOptions));
    }

    public static Dictionary<string, string> Load(string name)
    {
        EnsureDirectory();
        var path = Path.Combine(DirectoryPath, SafeName(name) + ".json");
        var text = File.ReadAllText(path);
        return JsonSerializer.Deserialize<Dictionary<string, string>>(text) ?? new Dictionary<string, string>();
    }

    private static void EnsureDirectory()
    {
        Directory.CreateDirectory(DirectoryPath);
        if (!Directory.Exists(LegacyDirectoryPath) ||
            string.Equals(Path.GetFullPath(LegacyDirectoryPath), Path.GetFullPath(DirectoryPath), StringComparison.OrdinalIgnoreCase))
        {
            return;
        }

        foreach (var legacyPath in Directory.EnumerateFiles(LegacyDirectoryPath, "*.json"))
        {
            var targetPath = Path.Combine(DirectoryPath, Path.GetFileName(legacyPath));
            if (!File.Exists(targetPath))
            {
                File.Copy(legacyPath, targetPath);
            }
        }
    }

    private static string SafeName(string name)
    {
        var safe = Regex.Replace(name.Trim(), @"[\\/:*?""<>|]+", "_");
        return string.IsNullOrWhiteSpace(safe) ? "preset" : safe;
    }
}
