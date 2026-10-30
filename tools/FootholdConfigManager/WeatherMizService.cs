using System.IO.Compression;
using System.Security.Cryptography;
using System.Text;

namespace FootholdConfigManager;

internal sealed record WeatherMizResult(string OutputPath, string? BackupPath);
internal sealed record WeatherMizNamingContext(string InputPath, double? SourceStartTimeSeconds);

internal static class WeatherMizService
{
    private static readonly UTF8Encoding Utf8 = new(false, true);
    private sealed record Member(string Name, long Length, byte[] Hash);

    public static WeatherMizResult Apply(string mizPath, WeatherSettings settings, bool replaceOriginal)
        => Apply(mizPath, settings, replaceOriginal, null)!;

    internal static WeatherMizResult? Apply(string mizPath, WeatherSettings settings, bool replaceOriginal,
        Func<WeatherMizNamingContext, string?>? chooseExportName)
        => ApplySettings(mizPath, settings, null, replaceOriginal, chooseExportName);

    internal static WeatherMizResult? ApplySettings(string mizPath, WeatherSettings? settings, MissionOptionsSettings? options,
        bool replaceOriginal, Func<WeatherMizNamingContext, string?>? chooseExportName)
        => ApplySettingsCore(mizPath, settings, options, replaceOriginal, chooseExportName, keepBackup: true);

    internal static WeatherMizResult? ApplySettings(string mizPath, WeatherSettings? settings, MissionOptionsSettings? options,
        MissionDateTimeSettings? dateTime, Func<WeatherMizNamingContext, string?> chooseExportName)
        => ApplySettingsCore(mizPath, settings, options, false, chooseExportName, keepBackup: false, dateTime, independentTime: true);

    internal static WeatherMizResult ApplyInPlace(string mizPath, WeatherSettings? settings, MissionOptionsSettings? options)
        => ApplySettingsCore(mizPath, settings, options, true, null, keepBackup: false)!;

    internal static WeatherMizResult ApplyInPlace(string mizPath, WeatherSettings? settings, MissionOptionsSettings? options,
        MissionDateTimeSettings? dateTime)
        => ApplySettingsCore(mizPath, settings, options, true, null, keepBackup: false, dateTime, independentTime: true)!;

    private static WeatherMizResult? ApplySettingsCore(string mizPath, WeatherSettings? settings, MissionOptionsSettings? options,
        bool replaceOriginal, Func<WeatherMizNamingContext, string?>? chooseExportName, bool keepBackup,
        MissionDateTimeSettings? dateTime = null, bool independentTime = false)
    {
        mizPath = Path.GetFullPath(mizPath);
        if (!Path.GetExtension(mizPath).Equals(".miz", StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException("Choose a .miz mission file.");
        if (settings is null && options is null && dateTime is null) throw new InvalidDataException("Choose Weather, Date & time, Mission options, or a combination to apply.");
        settings?.Validate();
        options?.Validate();
        dateTime?.Validate();
        if (settings?.DynamicWeather == true) throw new InvalidDataException("Only static weather editing is supported.");
        if (settings is { DustEnabled: true, FogMode: not "off" })
            throw new InvalidDataException("DCS cannot enable fog and dust at the same time. Turn one off before exporting.");
        using var sourceFile = new FileStream(mizPath, FileMode.Open, FileAccess.Read, FileShare.Read | FileShare.Delete);
        byte[] newMission;
        double? sourceStartTime = null;
        List<Member> unchanged;
        DateTimeOffset missionTimestamp;
        int missionAttributes;
        using (var source = new ZipArchive(sourceFile, ZipArchiveMode.Read, leaveOpen: true))
        {
            var missions = source.Entries.Where(entry => entry.FullName == "mission").ToArray();
            if (missions.Length != 1) throw new InvalidDataException("The MIZ must contain exactly one root mission entry.");
            var entry = missions[0];
            var bytes = ReadBytes(entry);
            var hasBom = bytes.AsSpan().StartsWith(new byte[] { 0xEF, 0xBB, 0xBF });
            var offset = hasBom ? 3 : 0;
            var original = Utf8.GetString(bytes, offset, bytes.Length - offset);
            Loretta.CodeAnalysis.Lua.Syntax.CompilationUnitSyntax? validatedWeather = null;
            var edited = settings is null && dateTime is null ? original
                : independentTime ? MissionWeather.ApplyParsed(original, settings, dateTime, out sourceStartTime, out validatedWeather)
                : MissionWeather.ApplyParsed(original, settings!, out sourceStartTime, out validatedWeather);
            if (options is not null) edited = validatedWeather is null
                ? MissionOptions.Apply(edited, options) : MissionOptions.ApplyParsed(edited, options, validatedWeather);
            var payload = Utf8.GetBytes(edited);
            newMission = hasBom ? new byte[] { 0xEF, 0xBB, 0xBF }.Concat(payload).ToArray() : payload;
            missionTimestamp = entry.LastWriteTime;
            missionAttributes = entry.ExternalAttributes;
            unchanged = source.Entries.Where(item => item.FullName != "mission").Select(Fingerprint).ToList();
        }

        var directory = Path.GetDirectoryName(mizPath)!;
        string? selectedName = null;
        if (!replaceOriginal && chooseExportName is not null)
        {
            selectedName = chooseExportName(new WeatherMizNamingContext(mizPath, sourceStartTime));
            if (selectedName is null) return null;
            selectedName = WeatherExportNames.Normalize(selectedName, mizPath);
        }
        string? backupPath = null;
        var outputPath = mizPath;
        FileStream? reservation = null;
        var committed = false;
        try
        {
            if (!replaceOriginal)
            {
                var fileName = selectedName ?? Path.GetFileNameWithoutExtension(mizPath) + (settings is null ? " - Options.miz" : " - Weather.miz");
                for (var number = 1; ; number++)
                {
                    var candidate = Path.Combine(directory, WeatherExportNames.NumberedName(fileName, number));
                    try
                    {
                        reservation = new FileStream(candidate, FileMode.CreateNew, FileAccess.ReadWrite, FileShare.Read | FileShare.Delete);
                        outputPath = candidate;
                        break;
                    }
                    catch (IOException) when (File.Exists(candidate)) { }
                }
            }
            AtomicFile.WriteStaged(outputPath, temporaryPath =>
            {
                sourceFile.Position = 0;
                using (var copy = new FileStream(temporaryPath, FileMode.CreateNew, FileAccess.Write, FileShare.None))
                    sourceFile.CopyTo(copy);
                using (var staged = ZipFile.Open(temporaryPath, ZipArchiveMode.Update))
                {
                    var previous = staged.GetEntry("mission")!;
                    previous.Delete();
                    var mission = staged.CreateEntry("mission", CompressionLevel.Optimal);
                    mission.LastWriteTime = missionTimestamp;
                    mission.ExternalAttributes = missionAttributes;
                    using var stream = mission.Open();
                    stream.Write(newMission);
                }
                using (var check = ZipFile.OpenRead(temporaryPath))
                {
                    var mission = check.Entries.Where(item => item.FullName == "mission").ToArray();
                    if (mission.Length != 1 || !ReadBytes(mission[0]).SequenceEqual(newMission))
                        throw new InvalidDataException("The staged mission failed verification.");
                    var actual = check.Entries.Where(item => item.FullName != "mission").Select(Fingerprint).ToArray();
                    if (actual.Length != unchanged.Count)
                        throw new InvalidDataException("The staged MIZ changed its member list.");
                    for (var i = 0; i < actual.Length; i++)
                        if (actual[i].Name != unchanged[i].Name || actual[i].Length != unchanged[i].Length
                            || !actual[i].Hash.SequenceEqual(unchanged[i].Hash))
                            throw new InvalidDataException("The staged MIZ changed an unrelated entry: " + unchanged[i].Name);
                }
                if (replaceOriginal && keepBackup)
                {
                    backupPath = Path.Combine(directory, Path.GetFileNameWithoutExtension(mizPath)
                        + ".weather-backup-" + DateTime.UtcNow.ToString("yyyyMMdd-HHmmss")
                        + "-" + Guid.NewGuid().ToString("N")[..8] + ".miz");
                    AtomicFile.Copy(mizPath, backupPath);
                }
            });
            committed = true;
            return new WeatherMizResult(outputPath, backupPath);
        }
        finally
        {
            if (!committed && reservation is not null && File.Exists(outputPath)) File.Delete(outputPath);
            reservation?.Dispose();
        }
    }

    private static byte[] ReadBytes(ZipArchiveEntry entry)
    {
        using var stream = entry.Open();
        using var memory = new MemoryStream();
        stream.CopyTo(memory);
        return memory.ToArray();
    }

    private static Member Fingerprint(ZipArchiveEntry entry)
    {
        using var stream = entry.Open();
        return new Member(entry.FullName, entry.Length, SHA256.HashData(stream));
    }
}
