using System.Text;

namespace FootholdConfigManager;

// Identity only. Certified transitions and archive/reference checks still decide update eligibility.
internal sealed record MissionVersionStamp(string Version, string Map)
{
    internal const int MaximumHeaderBytes = 4096;
    private const string VersionPrefix = "-- Foothold mission version:";
    private const string MapPrefix = "-- Foothold map:";
    private static readonly UTF8Encoding Utf8 = new(false, true);

    internal static MissionVersionStamp? Read(byte[] config)
    {
        var end = Math.Min(config.Length, MaximumHeaderBytes);
        if (end < config.Length)
        {
            while (end > 0 && config[end - 1] != '\n') end--;
            if (end == 0) return null;
        }
        var text = Utf8.GetString(config, 0, end).TrimStart('\uFEFF');
        string? version = null, map = null;
        foreach (var raw in text.Split('\n'))
        {
            var line = raw.Trim();
            if (line.Length != 0 && !line.StartsWith("--", StringComparison.Ordinal)) break;
            if (line.StartsWith(VersionPrefix, StringComparison.Ordinal))
            {
                if (version is not null) throw new InvalidDataException("Duplicate mission version stamp.");
                version = NormalizeVersion(line[VersionPrefix.Length..].Trim());
            }
            else if (line.StartsWith(MapPrefix, StringComparison.Ordinal))
            {
                if (map is not null) throw new InvalidDataException("Duplicate mission map stamp.");
                map = line[MapPrefix.Length..].Trim();
                if (map.Length == 0 || map.Length > 80) throw new InvalidDataException("Invalid mission map stamp.");
            }
        }
        if (version is null && map is null) return null;
        if (version is null || map is null) throw new InvalidDataException("Incomplete mission identity stamp.");
        return new(version, map);
    }

    internal static string NormalizeVersion(string value)
    {
        var token = value.TrimStart('v', 'V');
        if (!System.Version.TryParse(token, out var version) || version.Build < 0)
            throw new InvalidDataException("Invalid mission version stamp.");
        return version.ToString(version.Revision == 0 ? 3 : version.Revision < 0 ? 3 : 4);
    }

    internal static byte[] Write(byte[] config, string version, string map)
    {
        version = NormalizeVersion(version);
        if (string.IsNullOrWhiteSpace(map) || map.Length > 80 || map.IndexOfAny(['\r', '\n']) >= 0)
            throw new InvalidDataException("Invalid mission map stamp.");
        return Rewrite(config, new(version, map));
    }

    internal static byte[] Remove(byte[] config) => Rewrite(config, null);

    private static byte[] Rewrite(byte[] config, MissionVersionStamp? identity)
    {
        var text = Utf8.GetString(config).TrimStart('\uFEFF');
        var newline = text.IndexOf('\n') is var first && first > 0 && text[first - 1] == '\r' ? "\r\n" : "\n";
        var leading = new StringBuilder();
        var position = 0;
        while (position < text.Length)
        {
            var end = text.IndexOf('\n', position);
            var next = end < 0 ? text.Length : end + 1;
            var line = text[position..(end < 0 ? text.Length : end)].Trim();
            if (line.Length != 0 && !line.StartsWith("--", StringComparison.Ordinal)) break;
            if (!line.StartsWith(VersionPrefix, StringComparison.Ordinal) && !line.StartsWith(MapPrefix, StringComparison.Ordinal))
                leading.Append(text, position, next - position);
            position = next;
        }
        var header = leading.ToString();
        if (identity is not null)
        {
            var insert = header.StartsWith("-- Foothold release: ", StringComparison.Ordinal)
                ? (header.IndexOf('\n') is var end && end >= 0 ? end + 1 : header.Length) : 0;
            var metadata = VersionPrefix + " v" + identity.Version + newline + MapPrefix + " " + identity.Map + newline;
            if (insert > 0 && header[insert - 1] != '\n') metadata = newline + metadata;
            header = header.Insert(insert, metadata);
        }
        var result = Utf8.GetBytes(header + text[position..]);
        if (Read(result) != identity) throw new InvalidDataException("Mission identity is outside the header limit.");
        return result;
    }
}
