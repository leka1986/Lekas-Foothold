using System.Text.Encodings.Web;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Reflection;

namespace FootholdConfigManager;

internal sealed class GuiMetadataStore
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        WriteIndented = true,
        Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping
    };

    [JsonIgnore]
    public string Path { get; private set; } = "";
    public Dictionary<string, GuiMetadataEntry> Entries { get; set; } = new(StringComparer.Ordinal);
    public Dictionary<string, GuiCategoryLayout> CategoryLayouts { get; set; } = new(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> CategoryLabels { get; set; } = new(StringComparer.OrdinalIgnoreCase);
    public List<string> CategoryOrder { get; set; } = new();
    public List<string> HiddenCategories { get; set; } = new();
    public bool AdvancedToggleVisible { get; set; } = true;
    public bool RawValuesVisible { get; set; } = true;
    public string? FooterVersion { get; set; }

    public static GuiMetadataStore LoadForConfig(string configPath)
    {
        var store = new GuiMetadataStore { Path = GetPathForConfig(configPath) };
        if (File.Exists(store.Path))
        {
            var loaded = FromJson(File.ReadAllText(store.Path));
            if (loaded is not null)
            {
                loaded.Path = store.Path;
                return loaded;
            }
        }

        var legacyPath = GetLegacyPathForConfig(configPath);
        if (!legacyPath.Equals(store.Path, StringComparison.OrdinalIgnoreCase) &&
            File.Exists(legacyPath))
        {
            var loaded = FromJson(File.ReadAllText(legacyPath));
            if (loaded is not null)
            {
                loaded.Path = store.Path;
                return loaded;
            }
        }

        var embedded = LoadEmbedded();
        if (embedded is not null)
        {
            embedded.Path = store.Path;
            return embedded;
        }

        return store;
    }

    public void Save()
    {
        Directory.CreateDirectory(System.IO.Path.GetDirectoryName(Path) ?? ".");
        File.WriteAllText(Path, ToJson());
    }

    public string ToJson()
    {
        return JsonSerializer.Serialize(this, JsonOptions);
    }

    public GuiMetadataEntry GetOrCreate(string key)
    {
        if (!Entries.TryGetValue(key, out var metadata))
        {
            metadata = new GuiMetadataEntry();
            Entries[key] = metadata;
        }

        return metadata;
    }

    public void RemoveIfEmpty(string key)
    {
        if (Entries.TryGetValue(key, out var metadata) && metadata.IsEmpty)
        {
            Entries.Remove(key);
        }
    }

    private static string GetPathForConfig(string configPath)
    {
        return System.IO.Path.Combine(GetMetadataDirectory(), "Foothold Config.gui.json");
    }

    private static string GetMetadataDirectory()
    {
        if (!AppMode.IsExportedUserBuild && FindProjectDirectory() is { } projectDir)
        {
            return projectDir;
        }

        return RuntimeSettings.SettingsDirectory;
    }

    private static string GetLegacyPathForConfig(string configPath)
    {
        var dir = System.IO.Path.GetDirectoryName(configPath) ?? ".";
        return System.IO.Path.Combine(dir, System.IO.Path.GetFileNameWithoutExtension(configPath) + ".gui.json");
    }

    private static string? FindProjectDirectory()
    {
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        while (dir is not null)
        {
            var candidate = System.IO.Path.Combine(dir.FullName, "FootholdConfigManager.csproj");
            if (File.Exists(candidate))
            {
                return dir.FullName;
            }

            dir = dir.Parent;
        }

        return null;
    }

    private static GuiMetadataStore? FromJson(string text)
    {
        var loaded = JsonSerializer.Deserialize<GuiMetadataStore>(text, JsonOptions);
        if (loaded is null)
        {
            return null;
        }

        loaded.Entries = new Dictionary<string, GuiMetadataEntry>(loaded.Entries ?? new Dictionary<string, GuiMetadataEntry>(), StringComparer.Ordinal);
        loaded.CategoryLayouts = new Dictionary<string, GuiCategoryLayout>(loaded.CategoryLayouts ?? new Dictionary<string, GuiCategoryLayout>(), StringComparer.OrdinalIgnoreCase);
        var categoryLabels = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        if (loaded.CategoryLabels is not null)
        {
            foreach (var pair in loaded.CategoryLabels)
            {
                if (!string.IsNullOrWhiteSpace(pair.Key) && !string.IsNullOrWhiteSpace(pair.Value))
                {
                    categoryLabels[pair.Key] = pair.Value.Trim();
                }
            }
        }
        loaded.CategoryLabels = categoryLabels;
        loaded.CategoryOrder = loaded.CategoryOrder?
            .Where(name => !string.IsNullOrWhiteSpace(name))
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList() ?? new List<string>();
        loaded.HiddenCategories = loaded.HiddenCategories?
            .Where(name => !string.IsNullOrWhiteSpace(name))
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList() ?? new List<string>();
        loaded.FooterVersion = string.IsNullOrWhiteSpace(loaded.FooterVersion)
            ? null
            : loaded.FooterVersion.Trim();
        return loaded;
    }

    private static GuiMetadataStore? LoadEmbedded()
    {
        var assembly = Assembly.GetExecutingAssembly();
        foreach (var resourceName in new[]
        {
            "FootholdConfigManager.EmbeddedGuiMetadata.json",
            "FootholdConfigManager.DefaultGuiMetadata.json",
        })
        {
            using var stream = assembly.GetManifestResourceStream(resourceName);
            if (stream is null)
            {
                continue;
            }

            using var reader = new StreamReader(stream);
            return FromJson(reader.ReadToEnd());
        }

        return null;
    }
}

internal sealed class GuiMetadataEntry
{
    public string? Label { get; set; }
    public string? Category { get; set; }
    public string? Help { get; set; }
    public string? ControlType { get; set; }
    public bool? Advanced { get; set; }
    public int? Order { get; set; }
    public string? TableHeightMode { get; set; }
    public int? TableMaxVisibleRows { get; set; }
    public List<GuiChoiceMetadata> Choices { get; set; } = new();

    public bool IsEmpty =>
        string.IsNullOrWhiteSpace(Label) &&
        string.IsNullOrWhiteSpace(Category) &&
        string.IsNullOrWhiteSpace(Help) &&
        string.IsNullOrWhiteSpace(ControlType) &&
        Advanced is null &&
        Order is null &&
        string.IsNullOrWhiteSpace(TableHeightMode) &&
        TableMaxVisibleRows is null &&
        Choices.Count == 0;
}

internal sealed class GuiChoiceMetadata
{
    public string Display { get; set; } = "";
    public string Literal { get; set; } = "";
}

internal sealed class GuiCategoryLayout
{
    public List<string> Items { get; set; } = new();
}
