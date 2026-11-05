using System.Text;
using System.Text.Json;

namespace FootholdConfigManager;

internal static class MissionOutputFolderStore
{
    private static string FilePath => Path.Combine(RuntimeSettings.SettingsDirectory, "mission-output-folder.json");

    internal static string? Load()
    {
        string json;
        try { json = File.ReadAllText(FilePath, new UTF8Encoding(false, true)); }
        catch (FileNotFoundException) { return null; }
        catch (DirectoryNotFoundException) { return null; }
        return Normalize(JsonSerializer.Deserialize<string>(json)
            ?? throw new InvalidDataException("The saved custom output folder is empty."));
    }

    internal static string Save(string folder)
    {
        var normalized = Normalize(folder);
        AtomicFile.WriteUtf8Text(FilePath, JsonSerializer.Serialize(normalized));
        return normalized;
    }

    private static string Normalize(string folder)
    {
        if (string.IsNullOrWhiteSpace(folder) || !Path.IsPathFullyQualified(folder))
            throw new InvalidDataException("Choose a full custom output folder path.");
        return Path.TrimEndingDirectorySeparator(Path.GetFullPath(folder));
    }
}
