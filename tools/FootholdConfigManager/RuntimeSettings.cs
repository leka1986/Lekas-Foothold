using System.Text.Encodings.Web;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace FootholdConfigManager;

internal sealed class RuntimeSettings
{
    public const string DefaultConfigFileName = "Foothold Config.lua";
    public const string Ww2ConfigFileName = "Foothold Config WW2.lua";
    public static readonly string[] SupportedConfigFileNames =
    {
        DefaultConfigFileName,
        Ww2ConfigFileName
    };

    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        WriteIndented = true,
        Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping
    };

    [JsonIgnore]
    public string Path { get; private set; } = SettingsPath;

    public string? LastConfigPath { get; set; }
    public List<string> RecentConfigPaths { get; set; } = new();
    public List<ServerProfileSettings> ServerProfiles { get; set; } = new();
    public string? MasterConfigPath { get; set; }
    public string? MissionScriptingPath { get; set; }
    public List<string> DeployTargetFolders { get; set; } = new();
    public int UiZoomPercent { get; set; } = 100;
    public int? WindowLeft { get; set; }
    public int? WindowTop { get; set; }
    public int WindowWidth { get; set; }
    public int WindowHeight { get; set; }
    public bool DarkMode { get; set; }

    public static string SettingsDirectory =>
        System.IO.Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.UserProfile),
            "Saved Games",
            "Foothold Config Manager");

    public static string SettingsPath => System.IO.Path.Combine(SettingsDirectory, "settings.json");

    public static RuntimeSettings Load()
    {
        if (!File.Exists(SettingsPath))
        {
            return new RuntimeSettings();
        }

        try
        {
            var loaded = JsonSerializer.Deserialize<RuntimeSettings>(File.ReadAllText(SettingsPath), JsonOptions);
            if (loaded is null)
            {
                return new RuntimeSettings();
            }

            loaded.Path = SettingsPath;
            loaded.RecentConfigPaths = NormalizePaths(loaded.RecentConfigPaths);
            loaded.DeployTargetFolders = NormalizePaths(loaded.DeployTargetFolders);
            loaded.ServerProfiles = NormalizeServerProfiles(loaded.ServerProfiles);
            loaded.UiZoomPercent = Math.Clamp(loaded.UiZoomPercent, 80, 150);
            loaded.WindowWidth = Math.Max(0, loaded.WindowWidth);
            loaded.WindowHeight = Math.Max(0, loaded.WindowHeight);
            return loaded;
        }
        catch
        {
            return new RuntimeSettings();
        }
    }

    public void Save()
    {
        SaveTo(SettingsPath);
    }

    internal void SaveTo(string path)
    {
        AtomicFile.WriteUtf8Text(path, JsonSerializer.Serialize(this, JsonOptions));
    }

    public void RememberConfig(string configPath)
    {
        var fullPath = System.IO.Path.GetFullPath(configPath);
        LastConfigPath = fullPath;
        RecentConfigPaths.RemoveAll(path => path.Equals(fullPath, StringComparison.OrdinalIgnoreCase));
        RecentConfigPaths.Insert(0, fullPath);
        if (RecentConfigPaths.Count > 12)
        {
            RecentConfigPaths.RemoveRange(12, RecentConfigPaths.Count - 12);
        }

        Save();
    }

    public string? FindRememberedConfig()
    {
        return GetRememberedConfigCandidates().FirstOrDefault(File.Exists);
    }

    public IReadOnlyList<string> GetRememberedConfigCandidates()
    {
        var candidates = new List<string>();
        foreach (var path in new[] { LastConfigPath }.Concat(RecentConfigPaths))
        {
            if (string.IsNullOrWhiteSpace(path))
            {
                continue;
            }

            try
            {
                var fullPath = System.IO.Path.GetFullPath(path);
                if (!candidates.Contains(fullPath, StringComparer.OrdinalIgnoreCase))
                {
                    candidates.Add(fullPath);
                }
            }
            catch
            {
                // Invalid remembered paths are ignored; the config picker remains available.
            }
        }

        return candidates;
    }

    public static List<string> FindSavedGamesConfigs()
    {
        var savedGames = System.IO.Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.UserProfile),
            "Saved Games");
        if (!Directory.Exists(savedGames))
        {
            return new List<string>();
        }

        var results = new List<string>();
        try
        {
            foreach (var configFileName in SupportedConfigFileNames)
            {
                foreach (var path in Directory.EnumerateFiles(savedGames, configFileName, SearchOption.AllDirectories))
                {
                    if (IsMissionsSavesPath(path))
                    {
                        results.Add(System.IO.Path.GetFullPath(path));
                    }
                }
            }
        }
        catch
        {
            // If one folder is inaccessible, manual Open remains available.
        }

        return results
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .OrderByDescending(IsLikelyServerPath)
            .ThenByDescending(path => File.GetLastWriteTime(path))
            .ToList();
    }

    public static string GetBestInitialDirectory()
    {
        var savedGames = System.IO.Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.UserProfile),
            "Saved Games");
        return Directory.Exists(savedGames) ? savedGames : Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
    }

    private static List<string> NormalizePaths(IEnumerable<string>? paths)
    {
        return paths?
            .Where(path => !string.IsNullOrWhiteSpace(path))
            .Select(path => System.IO.Path.GetFullPath(path))
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList() ?? new List<string>();
    }

    private static List<ServerProfileSettings> NormalizeServerProfiles(IEnumerable<ServerProfileSettings>? profiles)
    {
        var normalized = profiles?
            .Where(profile => !string.IsNullOrWhiteSpace(profile.Name) &&
                              !string.IsNullOrWhiteSpace(profile.ConfigPath))
            .Select(profile => new ServerProfileSettings
            {
                Id = string.IsNullOrWhiteSpace(profile.Id)
                    ? CreateStableProfileId(profile.ConfigPath)
                    : profile.Id.Trim(),
                Name = profile.Name.Trim(),
                ConfigPath = System.IO.Path.GetFullPath(profile.ConfigPath),
                DeployTarget = profile.DeployTarget,
                ActivePresetIds = NormalizeActivePresetIds(profile.ActivePresetIds)
            })
            .GroupBy(profile => GetProfileConfigFamilyKey(profile.ConfigPath), StringComparer.OrdinalIgnoreCase)
            .Select(group => group.First())
            .OrderBy(profile => profile.Name, StringComparer.OrdinalIgnoreCase)
            .ToList() ?? new List<ServerProfileSettings>();

        var usedIds = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var profile in normalized)
        {
            if (!usedIds.Add(profile.Id))
            {
                profile.Id = Guid.NewGuid().ToString("N");
                usedIds.Add(profile.Id);
            }
        }

        return normalized;
    }

    private static Dictionary<string, string> NormalizeActivePresetIds(
        IReadOnlyDictionary<string, string>? activePresetIds)
    {
        return activePresetIds?
            .Where(item => SupportedConfigFileNames.Any(fileName =>
                               fileName.Equals(item.Key, StringComparison.OrdinalIgnoreCase)) &&
                           !string.IsNullOrWhiteSpace(item.Value))
            .GroupBy(
                item => SupportedConfigFileNames.First(fileName =>
                    fileName.Equals(item.Key, StringComparison.OrdinalIgnoreCase)),
                StringComparer.OrdinalIgnoreCase)
            .ToDictionary(
                group => group.Key,
                group => group.Last().Value.Trim(),
                StringComparer.OrdinalIgnoreCase) ??
               new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    }

    public static string CreateStableProfileId(string configPath)
    {
        var familyKey = GetProfileConfigFamilyKey(System.IO.Path.GetFullPath(configPath)).ToUpperInvariant();
        var hash = System.Security.Cryptography.SHA256.HashData(System.Text.Encoding.UTF8.GetBytes(familyKey));
        return Convert.ToHexString(hash)[..16].ToLowerInvariant();
    }

    private static string GetProfileConfigFamilyKey(string configPath)
    {
        var fileName = System.IO.Path.GetFileName(configPath);
        if (SupportedConfigFileNames.Any(supported => supported.Equals(fileName, StringComparison.OrdinalIgnoreCase)))
        {
            return System.IO.Path.GetDirectoryName(configPath) ?? configPath;
        }

        return configPath;
    }

    private static bool IsMissionsSavesPath(string path)
    {
        var normalized = path.Replace('/', '\\');
        return normalized.Contains("\\Missions\\Saves\\", StringComparison.OrdinalIgnoreCase);
    }

    private static bool IsLikelyServerPath(string path)
    {
        var normalized = path.Replace('/', '\\');
        return normalized.Contains("\\DCS.server\\", StringComparison.OrdinalIgnoreCase) ||
               normalized.Contains("\\DCS.openbeta_server\\", StringComparison.OrdinalIgnoreCase) ||
               normalized.Contains("server", StringComparison.OrdinalIgnoreCase) ||
               normalized.Contains("dedicated", StringComparison.OrdinalIgnoreCase);
    }
}

internal sealed class ServerProfileSettings
{
    public string Id { get; set; } = "";
    public string Name { get; set; } = "";
    public string ConfigPath { get; set; } = "";
    public bool DeployTarget { get; set; }
    public Dictionary<string, string> ActivePresetIds { get; set; } = new(StringComparer.OrdinalIgnoreCase);
}
