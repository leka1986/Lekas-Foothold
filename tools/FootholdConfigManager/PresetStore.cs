using System.Text.Encodings.Web;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;

namespace FootholdConfigManager;

internal sealed class StoredConfigPreset
{
    public int SchemaVersion { get; set; } = 1;
    public string Id { get; set; } = "";
    public string Name { get; set; } = "";
    public string ConfigFileName { get; set; } = RuntimeSettings.DefaultConfigFileName;
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }

    [JsonIgnore]
    public string DirectoryPath { get; set; } = "";

    [JsonIgnore]
    public string MetadataPath { get; set; } = "";

    [JsonIgnore]
    public string ConfigPath { get; set; } = "";
}

internal static class PresetStore
{
    public const int MaximumPresetsPerConfig = 3;

    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        WriteIndented = true,
        Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping
    };

    public static string DirectoryPath => Path.Combine(RuntimeSettings.SettingsDirectory, "presets");
    public static string InstancesDirectoryPath => Path.Combine(RuntimeSettings.SettingsDirectory, "Instances");

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

    public static bool HasLegacyPresetFiles()
    {
        return (Directory.Exists(DirectoryPath) &&
                Directory.EnumerateFiles(DirectoryPath, "*.json").Any()) ||
               (Directory.Exists(LegacyDirectoryPath) &&
                Directory.EnumerateFiles(LegacyDirectoryPath, "*.json").Any());
    }

    public static void Save(string name, IEnumerable<ConfigEntry> entries)
    {
        EnsureDirectory();
        var values = entries.ToDictionary(entry => entry.DisplayKey, entry => entry.ValueText, StringComparer.Ordinal);
        var path = Path.Combine(DirectoryPath, SafeName(name) + ".json");
        SaveLegacyValuesTo(path, values);
    }

    internal static void SaveLegacyValuesTo(string path, IReadOnlyDictionary<string, string> values)
    {
        AtomicFile.WriteUtf8Text(path, JsonSerializer.Serialize(values, JsonOptions));
    }

    public static Dictionary<string, string> Load(string name)
    {
        EnsureDirectory();
        var path = Path.Combine(DirectoryPath, SafeName(name) + ".json");
        var text = File.ReadAllText(path);
        return JsonSerializer.Deserialize<Dictionary<string, string>>(text) ?? new Dictionary<string, string>();
    }

    public static List<StoredConfigPreset> List(string instanceId, string configFileName)
    {
        ValidateConfigFileName(configFileName);
        var presetsDirectory = GetPresetsDirectory(instanceId);
        if (!Directory.Exists(presetsDirectory))
        {
            return new List<StoredConfigPreset>();
        }

        return Directory.EnumerateDirectories(presetsDirectory)
            .Select(LoadStoredPreset)
            .Where(preset => preset.ConfigFileName.Equals(configFileName, StringComparison.OrdinalIgnoreCase))
            .OrderBy(preset => preset.Name, StringComparer.OrdinalIgnoreCase)
            .ToList();
    }

    public static StoredConfigPreset Create(
        string instanceId,
        string configFileName,
        string name,
        Action<string> writeConfig)
    {
        ValidateConfigFileName(configFileName);
        var cleanName = ValidatePresetName(name);
        var existing = List(instanceId, configFileName);
        if (existing.Count >= MaximumPresetsPerConfig)
        {
            throw new InvalidOperationException(
                "This config already has " +
                MaximumPresetsPerConfig.ToString(System.Globalization.CultureInfo.InvariantCulture) +
                " presets.");
        }

        if (existing.Any(preset => preset.Name.Equals(cleanName, StringComparison.OrdinalIgnoreCase)))
        {
            throw new InvalidOperationException("A preset named " + cleanName + " already exists.");
        }

        var presetId = Guid.NewGuid().ToString("N");
        var presetDirectory = Path.Combine(GetPresetsDirectory(instanceId), presetId);
        var now = DateTime.Now;
        var preset = new StoredConfigPreset
        {
            Id = presetId,
            Name = cleanName,
            ConfigFileName = configFileName,
            CreatedAt = now,
            UpdatedAt = now,
            DirectoryPath = presetDirectory,
            MetadataPath = Path.Combine(presetDirectory, "preset.json"),
            ConfigPath = Path.Combine(presetDirectory, configFileName)
        };

        Directory.CreateDirectory(presetDirectory);
        try
        {
            WriteConfig(preset, writeConfig, updateTimestamp: false);
            SaveMetadata(preset);
            return preset;
        }
        catch
        {
            if (Directory.Exists(presetDirectory))
            {
                Directory.Delete(presetDirectory, recursive: true);
            }

            throw;
        }
    }

    public static void ReplaceConfig(StoredConfigPreset preset, Action<string> writeConfig)
    {
        WriteConfig(preset, writeConfig, updateTimestamp: true);
        SaveMetadata(preset);
    }

    public static void Rename(
        string instanceId,
        StoredConfigPreset preset,
        string name)
    {
        var cleanName = ValidatePresetName(name);
        if (List(instanceId, preset.ConfigFileName).Any(candidate =>
                !candidate.Id.Equals(preset.Id, StringComparison.OrdinalIgnoreCase) &&
                candidate.Name.Equals(cleanName, StringComparison.OrdinalIgnoreCase)))
        {
            throw new InvalidOperationException("A preset named " + cleanName + " already exists.");
        }

        preset.Name = cleanName;
        preset.UpdatedAt = DateTime.Now;
        SaveMetadata(preset);
    }

    public static void Delete(string instanceId, StoredConfigPreset preset)
    {
        var presetsRoot = Path.GetFullPath(GetPresetsDirectory(instanceId))
            .TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar) +
                          Path.DirectorySeparatorChar;
        var presetDirectory = Path.GetFullPath(preset.DirectoryPath)
            .TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
        if (!presetDirectory.StartsWith(presetsRoot, StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("The preset directory is outside this instance.");
        }

        if (Directory.Exists(presetDirectory))
        {
            Directory.Delete(presetDirectory, recursive: true);
        }
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
                AtomicFile.Copy(legacyPath, targetPath);
            }
        }
    }

    private static StoredConfigPreset LoadStoredPreset(string presetDirectory)
    {
        var metadataPath = Path.Combine(presetDirectory, "preset.json");
        if (!File.Exists(metadataPath))
        {
            throw new InvalidOperationException("Preset metadata was not found: " + metadataPath);
        }

        var preset = JsonSerializer.Deserialize<StoredConfigPreset>(File.ReadAllText(metadataPath), JsonOptions)
                     ?? throw new InvalidOperationException("Preset metadata could not be read: " + metadataPath);
        ValidateStoredId(preset.Id, "preset");
        if (!Path.GetFileName(presetDirectory).Equals(preset.Id, StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Preset metadata does not match its storage directory: " + metadataPath);
        }

        ValidateConfigFileName(preset.ConfigFileName);
        preset.Name = ValidatePresetName(preset.Name);
        preset.DirectoryPath = presetDirectory;
        preset.MetadataPath = metadataPath;
        preset.ConfigPath = Path.Combine(presetDirectory, preset.ConfigFileName);
        if (!File.Exists(preset.ConfigPath))
        {
            throw new InvalidOperationException("The preset config was not found: " + preset.ConfigPath);
        }

        return preset;
    }

    internal static void WriteConfig(
        StoredConfigPreset preset,
        Action<string> writeConfig,
        bool updateTimestamp)
    {
        Directory.CreateDirectory(preset.DirectoryPath);
        AtomicFile.WriteStaged(preset.ConfigPath, writeConfig);
        if (updateTimestamp)
        {
            preset.UpdatedAt = DateTime.Now;
        }
    }

    internal static void SaveMetadata(StoredConfigPreset preset)
    {
        Directory.CreateDirectory(preset.DirectoryPath);
        AtomicFile.WriteUtf8Text(preset.MetadataPath, JsonSerializer.Serialize(preset, JsonOptions));
    }

    private static string GetPresetsDirectory(string instanceId)
    {
        ValidateStoredId(instanceId, "instance");
        return Path.Combine(InstancesDirectoryPath, instanceId, "Presets");
    }

    private static string ValidatePresetName(string name)
    {
        var cleanName = name.Trim();
        if (string.IsNullOrWhiteSpace(cleanName))
        {
            throw new InvalidOperationException("Enter a preset name.");
        }

        if (cleanName.Length > 50)
        {
            throw new InvalidOperationException("Preset names can contain at most 50 characters.");
        }

        if (cleanName.Any(char.IsControl))
        {
            throw new InvalidOperationException("Preset names cannot contain control characters.");
        }

        return cleanName;
    }

    private static void ValidateConfigFileName(string configFileName)
    {
        if (!RuntimeSettings.SupportedConfigFileNames.Any(candidate =>
                candidate.Equals(configFileName, StringComparison.OrdinalIgnoreCase)))
        {
            throw new InvalidOperationException("Unsupported preset config type: " + configFileName);
        }
    }

    private static void ValidateStoredId(string value, string label)
    {
        if (string.IsNullOrWhiteSpace(value) ||
            !Regex.IsMatch(value, @"^[A-Za-z0-9_-]+$", RegexOptions.CultureInvariant))
        {
            throw new InvalidOperationException("The " + label + " ID is invalid.");
        }
    }

    private static string SafeName(string name)
    {
        var safe = Regex.Replace(name.Trim(), @"[\\/:*?""<>|]+", "_");
        return string.IsNullOrWhiteSpace(safe) ? "preset" : safe;
    }
}
