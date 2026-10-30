namespace FootholdConfigManager;

internal static class ManagerBuildInfo
{
    public static Version? ReleaseVersion { get; } = ReadReleaseVersion();
    public static string VersionText { get; } = ReleaseVersion is { } version
        ? version.ToString(version.Revision == 0 ? 3 : 4)
        : "";

    public static bool TryParseReleaseVersion(string? text, out Version version)
    {
        version = null!;
        if (string.IsNullOrWhiteSpace(text)) return false;
        var parts = text.Trim().Split('.');
        if (parts.Length is not (3 or 4)) return false;
        foreach (var part in parts)
        {
            if (part.Length == 0 || part.Any(character => character is < '0' or > '9')) return false;
        }
        if (!Version.TryParse(string.Join('.', parts), out var parsed)) return false;
        version = new Version(parsed.Major, parsed.Minor, parsed.Build, parsed.Revision < 0 ? 0 : parsed.Revision);
        return true;
    }

    private static Version? ReadReleaseVersion()
    {
        using var stream = typeof(ManagerBuildInfo).Assembly.GetManifestResourceStream("FootholdConfigManager.ManagerVersion.txt");
        if (stream is null) return null;
        using var reader = new StreamReader(stream);
        return TryParseReleaseVersion(reader.ReadToEnd(), out var version) ? version : null;
    }
}
