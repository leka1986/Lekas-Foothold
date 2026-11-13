using System.Text.RegularExpressions;

namespace FootholdConfigManager;

internal static class WeatherExportNames
{
    private static readonly Regex EraAndLanguage = new(
        @"(^|[_\s-]+)(?:multi[_\s-]*(?:language|lang)|cold[_\s-]*war|modern|vietnam|gulfwar|ww2|wwii(?!_Normandy_Foothold_))(?=$|[_\s-])",
        RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);

    public static string Suggest(string sourceFileName, string? era, string? cloudName,
        WeatherSettings settings, double? sourceStartTimeSeconds)
    {
        var parts = BaseParts(sourceFileName, era);
        parts.Add(WeatherTag(cloudName, settings));
        var time = settings.ChangeDateTime && settings.ChangeStartTime != false ? settings.StartTimeSeconds : sourceStartTimeSeconds;
        if (time is >= 0 && double.IsFinite(time.Value))
        {
            var hour = time.Value % 86400 / 3600;
            parts.Add(hour < 6 || hour >= 18 ? "Night" : "Day");
        }
        return string.Join("_", parts) + ".miz";
    }

    internal static string DownloadProfileSuffix(string? cloudName, WeatherSettings settings)
    {
        var tag = WeatherTag(cloudName, settings);
        if (settings.ChangeDateTime && settings.ChangeStartTime != false && settings.StartTimeSeconds is >= 0 && double.IsFinite(settings.StartTimeSeconds))
        {
            var hour = settings.StartTimeSeconds % 86400 / 3600;
            tag += "_" + (hour < 6 || hour >= 18 ? "Night" : "Day");
        }
        return tag;
    }
    public static string SuggestOptions(string sourceFileName, string? era) =>
        SuggestOptions(sourceFileName, era, null, true);

    internal static string SuggestOptions(string sourceFileName, string? era, double? startTimeSeconds, bool includeOptions)
    {
        var parts = BaseParts(sourceFileName, era);
        if (!includeOptions || startTimeSeconds is not null) parts.Add(includeOptions ? "Options" : "Time");
        if (startTimeSeconds is >= 0 && double.IsFinite(startTimeSeconds.Value))
        {
            var clock = TimeSpan.FromSeconds(startTimeSeconds.Value % 86400);
            parts.Add(clock.ToString(@"hhmm", System.Globalization.CultureInfo.InvariantCulture));
            parts.Add(clock.Hours < 6 || clock.Hours >= 18 ? "Night" : "Day");
        }
        return string.Join("_", parts) + ".miz";
    }

    internal static string MissionStem(string fileName) => Path.GetFileNameWithoutExtension(
        fileName.EndsWith(".miz.orig", StringComparison.OrdinalIgnoreCase) ? fileName[..^5] : fileName);

    internal static string WithMissionExtension(string fileName, bool original)
    {
        fileName = fileName.Trim();
        var suffix = original ? ".miz.orig" : ".miz";
        if (fileName.EndsWith(suffix, StringComparison.OrdinalIgnoreCase)) return fileName;
        var length = fileName.EndsWith(".miz.orig", StringComparison.OrdinalIgnoreCase) ? 9
            : fileName.EndsWith(".miz", StringComparison.OrdinalIgnoreCase) ? 4 : 0;
        return fileName[..(fileName.Length - length)] + suffix;
    }

    private static List<string> BaseParts(string sourceFileName, string? era)
    {
        var stem = EraAndLanguage.Replace(MissionStem(sourceFileName), "").Trim('_', '-', ' ');
        var parts = new List<string> { stem.Length == 0 ? "Mission" : stem };
        if (!string.IsNullOrWhiteSpace(era))
        {
            var eraTag = string.Concat(era.Trim().Where(ch => !Path.GetInvalidFileNameChars().Contains(ch) && !char.IsWhiteSpace(ch)));
            if (eraTag.Length > 0) parts.Add(eraTag);
        }
        return parts;
    }

    public static string Normalize(string fileName, string sourcePath) =>
        Normalize(fileName, sourcePath, Path.GetDirectoryName(Path.GetFullPath(sourcePath))!, false);

    public static string Normalize(string fileName, string sourcePath, string destinationDirectory, bool keepBoth, bool original = false)
    {
        fileName = fileName.Trim();
        if (fileName.Length == 0 || fileName.IndexOfAny(Path.GetInvalidFileNameChars()) >= 0
            || !string.Equals(Path.GetFileName(fileName), fileName, StringComparison.Ordinal))
            throw new InvalidDataException("Enter a filename only, without folders or invalid filename characters.");
        fileName = WithMissionExtension(fileName, original);
        var stem = MissionStem(fileName).TrimEnd(' ', '.');
        if (stem.Length == 0 || Regex.IsMatch(stem, @"^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(?:\.|$)",
                RegexOptions.IgnoreCase | RegexOptions.CultureInvariant))
            throw new InvalidDataException("Choose a valid Windows mission filename.");
        if (!Path.IsPathFullyQualified(destinationDirectory)) throw new InvalidDataException("Choose a full mission destination folder.");
        var candidate = Path.GetFullPath(Path.Combine(destinationDirectory, fileName));
        if (!keepBoth && candidate.Equals(Path.GetFullPath(sourcePath), StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException("Choose a different filename to keep the original MIZ unchanged.");
        return fileName;
    }

    public static string NumberedName(string fileName, int number) => number == 1 ? fileName
        : MissionStem(fileName) + " (" + number + ")" + (fileName.EndsWith(".miz.orig", StringComparison.OrdinalIgnoreCase) ? ".miz.orig" : Path.GetExtension(fileName));

    public static string AvailableName(string directory, string fileName)
    {
        for (var number = 1; ; number++)
        {
            var candidate = NumberedName(fileName, number);
            if (!File.Exists(Path.Combine(directory, candidate))) return candidate;
        }
    }

    private static string WeatherTag(string? cloudName, WeatherSettings settings)
    {
        if (settings.DynamicWeather) return "DYN";
        if (settings.CloudMode == "clear") return "CLR";
        if (settings.CloudMode == "custom") return "CUSTOM";
        var name = cloudName ?? "";
        var rain = name.Contains("rain", StringComparison.OrdinalIgnoreCase) || name.Contains("shower", StringComparison.OrdinalIgnoreCase);
        if (name.Contains("overcast", StringComparison.OrdinalIgnoreCase)) return rain ? "OVC_RA" : "OVC";
        if (name.Contains("broken", StringComparison.OrdinalIgnoreCase)) return rain ? "BKN_RA" : "BKN";
        if (name.Contains("scattered", StringComparison.OrdinalIgnoreCase)) return rain ? "SCT_RA" : "SCT";
        if (rain) return "RA";
        return "WX";
    }
}
