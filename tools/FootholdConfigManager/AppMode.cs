using System.Reflection;

namespace FootholdConfigManager;

internal static class AppMode
{
    public static bool IsExportedUserBuild { get; } = ReadBuildMode()
        .Equals("user", StringComparison.OrdinalIgnoreCase);

    private static string ReadBuildMode()
    {
        var assembly = Assembly.GetExecutingAssembly();
        using var stream = assembly.GetManifestResourceStream("FootholdConfigManager.EmbeddedBuildMode.txt");
        if (stream is null)
        {
            return "";
        }

        using var reader = new StreamReader(stream);
        return reader.ReadToEnd().Trim();
    }
}
