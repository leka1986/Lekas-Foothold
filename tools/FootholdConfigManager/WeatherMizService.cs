using Loretta.CodeAnalysis.Lua.Syntax;
using System.IO.Compression;
using System.Security.Cryptography;
using System.Text;

namespace FootholdConfigManager;

internal sealed record WeatherMizResult(string OutputPath, string? BackupPath);
internal sealed record WeatherMizNamingContext(string InputPath, double? SourceStartTimeSeconds);
internal sealed record MissionSettingsImport(WeatherSettings? Weather, MissionDateTimeSettings? DateTime, MissionOptionsSettings? Options);

internal static class WeatherMizService
{
    private static readonly UTF8Encoding Utf8 = new(false, true);
    private sealed record Member(string Name, long Length, byte[] Hash);

    internal static MissionSettingsImport ReadSettings(string mizPath, bool includeWeatherAndTime, bool includeMissionOptions)
    {
        if (!includeWeatherAndTime && !includeMissionOptions)
            throw new InvalidDataException("Choose Weather + date & time, Mission options, or both to import.");
        mizPath = Path.GetFullPath(mizPath);
        if (!Path.GetExtension(mizPath).Equals(".miz", StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException("Choose a .miz mission file.");
        using var sourceFile = new FileStream(mizPath, FileMode.Open, FileAccess.Read, FileShare.Read | FileShare.Delete);
        using var source = new ZipArchive(sourceFile, ZipArchiveMode.Read);
        var missions = source.Entries.Where(entry => entry.FullName == "mission").ToArray();
        if (missions.Length != 1) throw new InvalidDataException("The MIZ must contain exactly one root mission entry.");
        var bytes = ReadBytes(missions[0]);
        var offset = bytes.AsSpan().StartsWith(new byte[] { 0xEF, 0xBB, 0xBF }) ? 3 : 0;
        string text;
        try { text = Utf8.GetString(bytes, offset, bytes.Length - offset); }
        catch (DecoderFallbackException error) { throw new InvalidDataException("The mission entry is not valid UTF-8.", error); }
        var root = WeatherLua.Parse(text);
        var assignments = root.Statements.Statements.OfType<AssignmentStatementSyntax>()
            .Where(statement => statement.Variables.Count == 1
                && statement.Variables[0] is IdentifierNameSyntax name && name.Identifier.Text == "mission").ToArray();
        if (assignments.Length != 1 || assignments[0].EqualsValues.Values.Count != 1
            || assignments[0].EqualsValues.Values[0] is not TableConstructorExpressionSyntax mission)
            throw new InvalidDataException("Expected one literal mission table.");
        WeatherSettings? weather = null;
        MissionDateTimeSettings? dateTime = null;
        if (includeWeatherAndTime)
        {
            weather = ReadImportedWeather(ReadRootTable("weather"));
            var date = ReadRootTable("date");
            try
            {
                dateTime = new MissionDateTimeSettings { ChangeDate = true,
                    MissionDate = new DateTime(ImportInteger(date, "Year"), ImportInteger(date, "Month"), ImportInteger(date, "Day")),
                    StartTimeSeconds = ReadRootValue("start_time") is double seconds ? seconds
                        : throw new InvalidDataException("Mission start_time must be a literal number.") };
            }
            catch (ArgumentOutOfRangeException error) { throw new InvalidDataException("The selected MIZ contains an invalid mission date.", error); }
            dateTime.Validate();
            weather.ChangeDateTime = weather.ChangeMissionDate = true;
            weather.MissionDate = dateTime.MissionDate;
            weather.StartTimeSeconds = dateTime.StartTimeSeconds;
            weather.Validate();
        }
        var options = includeMissionOptions ? ReadImportedOptions(ReadRootTable("forcedOptions", optional: true)) : null;
        return new MissionSettingsImport(weather, dateTime, options);

        object? ReadRootValue(string key) => WeatherLua.Read(MissionWeather.FieldValue(RootField(key)!));
        TableFieldSyntax? RootField(string key, bool optional = false)
        {
            var fields = mission.Fields.Where(field => MissionWeather.FieldName(field) == key).ToArray();
            if (fields.Length > 1) throw new InvalidDataException("Duplicate mission field: " + key);
            if (fields.Length == 0 && !optional) throw new InvalidDataException("The mission is missing " + key + ".");
            return fields.SingleOrDefault();
        }
        LuaDataTable ReadRootTable(string key, bool optional = false)
        {
            var field = RootField(key, optional);
            if (field is null) return new LuaDataTable();
            if (MissionWeather.FieldValue(field) is not TableConstructorExpressionSyntax table)
                throw new InvalidDataException("Expected a literal " + key + " table in the selected MIZ.");
            return WeatherLua.ReadTable(table, rejectDuplicates: true);
        }
    }

    private static WeatherSettings ReadImportedWeather(LuaDataTable weather)
    {
        if (ImportNumber(weather, "atmosphere_type", 0) != 0)
            throw new InvalidDataException("This MIZ uses unsupported dynamic weather. Import Mission options only to leave its weather unchanged.");
        if (ImportNumber(weather, "type_weather", 0) != 0)
            throw new InvalidDataException("This MIZ uses an unsupported weather type. Import Mission options only to leave its weather unchanged.");
        var clouds = ImportTable(weather, "clouds");
        var preset = ImportText(clouds, "preset");
        if (preset is not null && string.IsNullOrWhiteSpace(preset))
            throw new InvalidDataException("The mission cloud preset must be a nonempty literal string.");
        var density = ImportInteger(clouds, "density");
        var precipitation = ImportInteger(clouds, "iprecptns");
        var wind = ImportTable(weather, "wind");
        var halo = ImportTable(weather, "halo", optional: true);
        var settings = new WeatherSettings
        {
            CloudMode = preset is not null ? "preset" : density == 0 && precipitation == 0 ? "clear" : "custom",
            CloudPreset = preset, CloudBaseMeters = ImportNumber(clouds, "base"),
            CloudBaseMinimumMeters = 0, CloudBaseMaximumMeters = 30000,
            CloudThicknessMeters = ImportNumber(clouds, "thickness"), CloudDensity = density, Precipitation = precipitation,
            GroundWind = Wind("atGround"), Wind2000 = Wind("at2000"), Wind8000 = Wind("at8000"),
            TemperatureC = ImportNumber(ImportTable(weather, "season"), "temperature"),
            PressureMmHg = ImportNumber(weather, "qnh"),
            VisibilityMeters = ImportNumber(ImportTable(weather, "visibility"), "distance"),
            TurbulenceMps = ImportNumber(weather, "groundTurbulence") / 10,
            DustEnabled = ImportBoolean(weather, "enable_dust"),
            DustVisibilityMeters = ImportNumber(weather, "dust_density", 0),
            HaloMode = ImportText(halo, "preset", "off")!, HaloCrystalPreset = ImportText(halo, "crystalsPreset")
        };
        if (!settings.DustEnabled && settings.DustVisibilityMeters == 0) settings.DustVisibilityMeters = 300;
        ReadImportedFog(weather, settings);
        if (settings.DustEnabled && settings.FogMode != "off")
            throw new InvalidDataException("DCS cannot enable fog and dust at the same time. The selected MIZ settings were not imported.");
        return settings;

        WeatherWind Wind(string key)
        {
            var layer = ImportTable(wind, key);
            return new WeatherWind { SpeedMps = ImportNumber(layer, "speed"), DirectionTo = ImportNumber(layer, "dir") };
        }
    }

    private static void ReadImportedFog(LuaDataTable weather, WeatherSettings settings)
    {
        var fog = ImportTable(weather, "fog2", optional: true);
        if (!fog.Contains("mode") && ImportBoolean(weather, "enable_fog"))
            throw new InvalidDataException("This MIZ uses unsupported legacy fog. Import Mission options only to leave its weather unchanged.");
        settings.FogMode = ImportNumber(fog, "mode", 1) switch
        {
            1 => "off", 2 => "auto", 4 => "manual",
            _ => throw new InvalidDataException("The mission uses an unsupported fog mode.")
        };
        if (settings.FogMode != "manual") return;
        var manual = ImportTable(fog, "manual");
        settings.FogFrames = new List<WeatherFogFrame>();
        var nextIndex = 1d;
        foreach (var pair in manual.Entries.Where(pair => pair.Key is double).OrderBy(pair => (double)pair.Key))
        {
            if ((double)pair.Key != nextIndex++ || pair.Value is not LuaDataTable frame)
                throw new InvalidDataException("Manual fog must contain consecutive literal frames starting at 1.");
            settings.FogFrames.Add(new WeatherFogFrame { TimeSeconds = ImportNumber(frame, "time"),
                VisibilityMeters = ImportNumber(frame, "visibility"), ThicknessMeters = ImportNumber(frame, "thickness") });
        }
    }

    private static MissionOptionsSettings ReadImportedOptions(LuaDataTable forced)
    {
        var settings = new MissionOptionsSettings();
        settings.Labels.Value = 1;
        Pair(forced, "optionsView", settings.F10View);
        Pair(forced, "labels", settings.Labels);
        Pair(forced, "spottingDot", settings.SpottingDots);
        Pair(forced, "easyCommunication", settings.EasyCommunication);
        Pair(forced, "civTraffic", settings.CivilTraffic);
        Pair(forced, "RBDAI", settings.BattleDamage);
        Pair(forced, "permitCrash", settings.CrashRecovery);
        Pair(forced, "externalViews", settings.ExternalViews);
        Pair(forced, "easyFlight", settings.SimplifiedFlight);
        Pair(forced, "immortal", settings.Immortal);
        Pair(forced, "fuel", settings.UnlimitedFuel);
        Pair(forced, "weapons", settings.UnlimitedWeapons);
        Pair(forced, "radio", settings.RadioAssists);
        Pair(forced, "unrestrictedSATNAV", settings.UnrestrictedSatnav);
        Pair(forced, "padlock", settings.Padlock);
        Pair(forced, "wakeTurbulence", settings.WakeTurbulence);
        Pair(forced, "accidental_failures", settings.RandomFailures);
        Pair(forced, "gWarmUp", settings.GWarmUp);
        Pair(forced, "miniHUD", settings.MiniHud);
        Pair(forced, "cockpitVisualRM", settings.CockpitVisualRecon);
        Pair(forced, "userMarks", settings.F10UserMarks);
        Pair(forced, "cockpitStatusBarAllowed", settings.CockpitStatusBar);
        Pair(forced, "geffect", settings.GEffects);
        Pair(forced, "birds", settings.Birds);
        var carrier = ImportTable(forced, "Supercarrier", optional: true);
        Pair(carrier, "deck_crew", settings.DeckCrew);
        Pair(carrier, "speakers_enabled", settings.Carrier1Mc);
        ReadImportedExtendedF10(forced, settings);
        settings.Validate();
        return settings;

        static void Pair<T>(LuaDataTable table, string key, MissionOption<T> option)
        {
            if (!table.Contains(key)) return;
            if (typeof(T) == typeof(int)) option.Value = (T)(object)ImportInteger(table, key);
            else if (table.Get(key) is T value) option.Value = value;
            else throw new InvalidDataException("Mission option '" + key + "' has an invalid literal type.");
            option.Enforce = true;
        }
    }

    private static void ReadImportedExtendedF10(LuaDataTable forced, MissionOptionsSettings settings)
    {
        var extended = ImportTable(forced, "optionsViewExtended", optional: true);
        foreach (var pair in extended.Entries)
        {
            if (pair.Key is not double roleId || roleId != Math.Truncate(roleId) || roleId < 1 || roleId > 6
                || pair.Value is not LuaDataTable role)
                throw new InvalidDataException("Extended F10 must contain literal role tables numbered 1 through 6.");
            var options = settings.ExtendedF10[(int)roleId];
            options.View = ImportText(role, "f10ViewOption", options.View)!;
            var mask = ImportTable(role, "visibleUnitLayersMask", optional: true);
            foreach (var bit in mask.Entries)
            {
                if (bit.Key is not double index || index != Math.Truncate(index) || index < 0 || index > 14 || bit.Value is not bool visible)
                    throw new InvalidDataException("Extended F10 visibility layers must be true or false at indices 0 through 14.");
                options.VisibleUnitLayers[(int)index] = visible;
            }
        }
    }

    private static LuaDataTable ImportTable(LuaDataTable table, string key, bool optional = false)
    {
        if (!table.Contains(key) && optional) return new LuaDataTable();
        return table.Get(key) is LuaDataTable value ? value
            : throw new InvalidDataException("Mission setting '" + key + "' must be a literal table.");
    }

    private static double ImportNumber(LuaDataTable table, string key, double? fallback = null)
    {
        if (!table.Contains(key) && fallback.HasValue) return fallback.Value;
        return table.Get(key) is double value && double.IsFinite(value) ? value
            : throw new InvalidDataException("Mission setting '" + key + "' must be a finite literal number.");
    }

    private static int ImportInteger(LuaDataTable table, string key)
    {
        var value = ImportNumber(table, key);
        if (value != Math.Truncate(value) || value < int.MinValue || value > int.MaxValue)
            throw new InvalidDataException("Mission setting '" + key + "' must be a whole number.");
        return (int)value;
    }

    private static bool ImportBoolean(LuaDataTable table, string key, bool fallback = false)
    {
        if (!table.Contains(key)) return fallback;
        return table.Get(key) is bool value ? value
            : throw new InvalidDataException("Mission setting '" + key + "' must be true or false.");
    }

    private static string? ImportText(LuaDataTable table, string key, string? fallback = null)
    {
        if (!table.Contains(key)) return fallback;
        var value = table.Get(key);
        if (value is string text) return text;
        if (value is null && fallback is null) return null;
        throw new InvalidDataException("Mission setting '" + key + "' must be a literal string.");
    }

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
        byte[]? newOptions = null;
        DateTimeOffset optionsTimestamp = default;
        int optionsAttributes = 0;
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
            if (options?.Labels.Enforce == true)
            {
                var optionEntries = source.Entries.Where(item => item.FullName == "options").ToArray();
                if (optionEntries.Length > 1) throw new InvalidDataException("The MIZ contains duplicate root options entries.");
                var optionEntry = optionEntries.SingleOrDefault();
                var optionBytes = optionEntry is null ? Array.Empty<byte>() : ReadBytes(optionEntry);
                var optionBom = optionBytes.AsSpan().StartsWith(new byte[] { 0xEF, 0xBB, 0xBF });
                string optionText;
                try { optionText = optionEntry is null ? "options = {}" : Utf8.GetString(optionBytes, optionBom ? 3 : 0, optionBytes.Length - (optionBom ? 3 : 0)); }
                catch (DecoderFallbackException error) { throw new InvalidDataException("The options entry is not valid UTF-8.", error); }
                var editedOptions = MissionOptions.ApplyEnforcedLabels(optionText, options.Labels.Value);
                if (optionEntry is null || editedOptions != optionText)
                {
                    var optionPayload = Utf8.GetBytes(editedOptions);
                    newOptions = optionBom ? new byte[] { 0xEF, 0xBB, 0xBF }.Concat(optionPayload).ToArray() : optionPayload;
                    optionsTimestamp = optionEntry?.LastWriteTime ?? missionTimestamp;
                    optionsAttributes = optionEntry?.ExternalAttributes ?? missionAttributes;
                }
            }
            unchanged = source.Entries.Where(item => item.FullName != "mission" && (newOptions is null || item.FullName != "options")).Select(Fingerprint).ToList();
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
                    using (var stream = mission.Open()) stream.Write(newMission);
                    if (newOptions is not null)
                    {
                        staged.GetEntry("options")?.Delete();
                        var companion = staged.CreateEntry("options", CompressionLevel.Optimal);
                        companion.LastWriteTime = optionsTimestamp;
                        companion.ExternalAttributes = optionsAttributes;
                        using var optionStream = companion.Open();
                        optionStream.Write(newOptions);
                    }
                }
                using (var check = ZipFile.OpenRead(temporaryPath))
                {
                    var mission = check.Entries.Where(item => item.FullName == "mission").ToArray();
                    if (mission.Length != 1 || !ReadBytes(mission[0]).SequenceEqual(newMission))
                        throw new InvalidDataException("The staged mission failed verification.");
                    if (newOptions is not null)
                    {
                        var companion = check.Entries.Where(item => item.FullName == "options").ToArray();
                        if (companion.Length != 1 || !ReadBytes(companion[0]).SequenceEqual(newOptions))
                            throw new InvalidDataException("The staged mission options failed verification.");
                    }
                    var actual = check.Entries.Where(item => item.FullName != "mission" && (newOptions is null || item.FullName != "options")).Select(Fingerprint).ToArray();
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
