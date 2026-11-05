using System.Text;
using System.Text.Json;

namespace FootholdConfigManager;

internal static class MissionSourceFolderStore
{
    private static string FilePath => Path.Combine(RuntimeSettings.SettingsDirectory, "mission-source-folders.json");

    internal static IReadOnlyList<string> Load()
    {
        string json;
        try { json = File.ReadAllText(FilePath, new UTF8Encoding(false, true)); }
        catch (FileNotFoundException) { return Array.Empty<string>(); }
        catch (DirectoryNotFoundException) { return Array.Empty<string>(); }
        return Normalize(JsonSerializer.Deserialize<string[]>(json)
            ?? throw new InvalidDataException("The saved mission source folders are empty."));
    }

    internal static IReadOnlyList<string> Save(IReadOnlyList<string> folders)
    {
        var normalized = Normalize(folders);
        AtomicFile.WriteUtf8Text(FilePath, JsonSerializer.Serialize(normalized));
        return normalized;
    }

    private static IReadOnlyList<string> Normalize(IReadOnlyList<string> folders)
    {
        var paths = new List<string>();
        var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var folder in folders)
        {
            if (string.IsNullOrWhiteSpace(folder) || !Path.IsPathFullyQualified(folder))
                throw new InvalidDataException("Choose a full mission source folder path.");
            var path = Path.TrimEndingDirectorySeparator(Path.GetFullPath(folder));
            if (seen.Add(path)) paths.Add(path);
        }
        return paths.AsReadOnly();
    }
}
