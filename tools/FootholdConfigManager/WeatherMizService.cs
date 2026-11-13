using Loretta.CodeAnalysis.Lua.Syntax;
using System.IO.Compression;
using System.Security.Cryptography;
using System.Text;

namespace FootholdConfigManager;

internal sealed record WeatherMizResult(string OutputPath, string? BackupPath);
internal sealed record WeatherMizExportChoice(string FileName, string Directory, bool KeepBoth)
{
    public bool SaveAsOriginal { get; init; }
    public string? OriginalMissionsDirectory { get; init; }
    public MissionPathIdentity? ReplacementIdentity { get; init; }
}
internal sealed record WeatherMizNamingContext(string InputPath, double? SourceStartTimeSeconds)
{
    public WeatherMizExportChoice? ExistingChoice { get; init; }
}
internal sealed record MissionSettingsImport(WeatherSettings? Weather, MissionDateTimeSettings? DateTime, MissionOptionsSettings? Options);
internal sealed record PreparedMissionInput(string Text, CompilationUnitSyntax Root, bool HasBom);

internal static class WeatherMizService
{
    private static readonly UTF8Encoding Utf8 = new(false, true);
    private sealed record Member(string Name, long Length, byte[] Hash);

    internal static bool IsMissionInputPath(string path) => path.EndsWith(".miz", StringComparison.OrdinalIgnoreCase)
        || path.EndsWith(".miz.orig", StringComparison.OrdinalIgnoreCase);

    internal static bool BotOriginalsAvailable(string inputPath, string? missionsDirectory)
    {
        return HasOriginals(Path.GetDirectoryName(Path.GetFullPath(inputPath))) || HasOriginals(missionsDirectory);
        static bool HasOriginals(string? directory)
        {
            if (directory is null) return false;
            if (Directory.Exists(Path.Combine(directory, ".dcssb"))) return true;
            for (var current = new DirectoryInfo(directory); current is not null; current = current.Parent)
            {
                if (current.Name.Equals(".dcssb", StringComparison.OrdinalIgnoreCase)) return current.Exists;
                if (current.Name.Equals("Missions", StringComparison.OrdinalIgnoreCase))
                    return Directory.Exists(Path.Combine(current.FullName, ".dcssb"));
            }
            return false;
        }
    }

    internal static PreparedMissionInput GetPreparedMissionInput(PreparedMissionTemplate template,
        Dictionary<PreparedMissionTemplate, PreparedMissionInput> inputs)
    {
        if (inputs.TryGetValue(template, out var input)) return input;
        var bytes = template.MissionBytes;
        var hasBom = bytes.AsSpan().StartsWith(new byte[] { 0xEF, 0xBB, 0xBF });
        var offset = hasBom ? 3 : 0;
        var text = Utf8.GetString(bytes, offset, bytes.Length - offset);
        input = new PreparedMissionInput(text, WeatherLua.Parse(text), hasBom);
        inputs.Add(template, input);
        return input;
    }

    internal static MissionSettingsImport ReadSettings(string mizPath, bool includeWeatherAndTime, bool includeMissionOptions)
    {
        if (!includeWeatherAndTime && !includeMissionOptions)
            throw new InvalidDataException("Choose Weather + date & time, Mission options, or both to import.");
        mizPath = Path.GetFullPath(mizPath);
        if (!IsMissionInputPath(mizPath))
            throw new InvalidDataException("Choose a .miz or .miz.orig mission file.");
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

    internal static WeatherMizResult? ApplySettingsToDestination(string mizPath, WeatherSettings? settings, MissionOptionsSettings? options,
        MissionDateTimeSettings? dateTime, Func<WeatherMizNamingContext, WeatherMizExportChoice?> chooseExport) =>
        ApplySettingsCore(mizPath, settings, options, false, null, keepBackup: false, dateTime, independentTime: true, chooseExport);

    internal static string ApplyPrepared(PreparedMissionTemplate template, WeatherSettings? weather, MissionOptionsSettings? options,
        IReadOnlyDictionary<string, byte[]> configMembers, string outputPath, bool replaceExisting, CancellationToken token,
        MissionPathIdentity? reviewedIdentity = null)
        => ApplyPreparedWarehouse(template, weather, options, configMembers, outputPath, replaceExisting, token, reviewedIdentity, null);

    internal static string ApplyPreparedWarehouse(PreparedMissionTemplate template, WeatherSettings? weather, MissionOptionsSettings? options,
        IReadOnlyDictionary<string, byte[]> configMembers, string outputPath, bool replaceExisting, CancellationToken token,
        MissionPathIdentity? reviewedIdentity, MissionWarehouseCopy? warehouseCopy, PreparedMissionInput? preparedInput = null)
    {
        token.ThrowIfCancellationRequested();
        var warehouseOnly = weather is null && options is null && warehouseCopy is not null;
        if (warehouseOnly && configMembers.Count != 0) throw new InvalidDataException("Warehouse-only copying must preserve the release Config members.");
        if (warehouseCopy is not null && Convert.ToHexString(SHA256.HashData(warehouseCopy.Bytes)) != warehouseCopy.Sha256)
            throw new InvalidDataException("The reviewed warehouse snapshot changed. Prepare and review again.");
        if (!warehouseOnly && (template.ConfigMembers.Count == 0 || configMembers.Count != template.ConfigMembers.Count
            || template.ConfigMembers.Any(member => !configMembers.ContainsKey(member.Name))
            || configMembers.Keys.Any(name => !template.ConfigMembers.Any(member => member.Name == name))))
            throw new InvalidDataException("A matching destination Config snapshot is required for every Config member in this generated mission.");
        if (!Path.IsPathFullyQualified(outputPath) || !Directory.Exists(Path.GetDirectoryName(outputPath)))
            throw new DirectoryNotFoundException("The reviewed mission destination folder is unavailable.");
        var directory = Path.GetDirectoryName(Path.GetFullPath(outputPath))!;
        outputPath = Path.Combine(directory, WeatherExportNames.Normalize(Path.GetFileName(outputPath), template.SourcePath, directory, false));
        return ApplySettingsCore(template.SourcePath, weather, options, false, null, keepBackup: false,
            prepared: template, configMembers: warehouseOnly ? null : configMembers, preparedOutputPath: outputPath,
            replacePreparedOutput: replaceExisting, cancellationToken: token, reviewedIdentity: reviewedIdentity, warehouseCopy: warehouseCopy, preparedInput: preparedInput)!.OutputPath;
    }
    private static WeatherMizResult? ApplySettingsCore(string mizPath, WeatherSettings? settings, MissionOptionsSettings? options,
        bool replaceOriginal, Func<WeatherMizNamingContext, string?>? chooseExportName, bool keepBackup,
        MissionDateTimeSettings? dateTime = null, bool independentTime = false,
        Func<WeatherMizNamingContext, WeatherMizExportChoice?>? chooseDestination = null,
        PreparedMissionTemplate? prepared = null, IReadOnlyDictionary<string, byte[]>? configMembers = null,
        string? preparedOutputPath = null, bool replacePreparedOutput = false, CancellationToken cancellationToken = default,
        MissionPathIdentity? reviewedIdentity = null, MissionWarehouseCopy? warehouseCopy = null, PreparedMissionInput? preparedInput = null)
    {
        mizPath = Path.GetFullPath(mizPath);
        if (!IsMissionInputPath(mizPath))
            throw new InvalidDataException("Choose a .miz or .miz.orig mission file.");
        if (settings is null && options is null && dateTime is null && warehouseCopy is null) throw new InvalidDataException("Choose Weather, Date & time, Mission options, or a combination to apply.");
        var warehouseOnly = warehouseCopy is not null && settings is null && options is null && dateTime is null;
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
            var bytes = prepared?.MissionBytes ?? ReadBytes(entry);
            if (warehouseOnly) newMission = bytes;
            else
            {
                var hasBom = preparedInput?.HasBom ?? bytes.AsSpan().StartsWith(new byte[] { 0xEF, 0xBB, 0xBF });
                var offset = hasBom ? 3 : 0;
                var original = preparedInput?.Text ?? Utf8.GetString(bytes, offset, bytes.Length - offset);
                Loretta.CodeAnalysis.Lua.Syntax.CompilationUnitSyntax? validatedWeather = null;
                var edited = settings is null && dateTime is null ? original
                    : independentTime ? MissionWeather.ApplyParsed(original, settings, dateTime, out sourceStartTime, out validatedWeather, preparedInput?.Root)
                    : MissionWeather.ApplyParsed(original, settings!, out sourceStartTime, out validatedWeather, preparedInput?.Root);
                if (options is not null) edited = validatedWeather is null
                    ? MissionOptions.ApplyParsed(edited, options, preparedInput?.Root) : MissionOptions.ApplyParsed(edited, options, validatedWeather);
                var payload = Utf8.GetBytes(edited);
                newMission = hasBom ? new byte[] { 0xEF, 0xBB, 0xBF }.Concat(payload).ToArray() : payload;
            }
            missionTimestamp = entry.LastWriteTime;
            missionAttributes = entry.ExternalAttributes;
            if (options?.Labels.Enforce == true)
            {
                var optionEntries = source.Entries.Where(item => item.FullName == "options").ToArray();
                if (optionEntries.Length > 1) throw new InvalidDataException("The MIZ contains duplicate root options entries.");
                var optionEntry = optionEntries.SingleOrDefault();
                var optionBytes = prepared is not null ? prepared.OptionsBytes ?? Array.Empty<byte>()
                    : optionEntry is null ? Array.Empty<byte>() : ReadBytes(optionEntry);
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
            unchanged = prepared is null
                ? source.Entries.Where(item => IsUnchanged(item.FullName)).Select(Fingerprint).ToList()
                : prepared.Members.Where(item => IsUnchanged(item.Name))
                    .Select(item => new Member(item.Name, item.Length, Convert.FromHexString(item.Sha256))).ToList();
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
        var outputPath = preparedOutputPath ?? mizPath;
        FileStream? reservation = null;
        var committed = false;
        try
        {
            if (!replaceOriginal && preparedOutputPath is null)
            {
                WeatherMizExportChoice? choice = null;
                while (reservation is null)
                {
                    if (chooseDestination is not null)
                    {
                        choice = chooseDestination(new WeatherMizNamingContext(mizPath, sourceStartTime) { ExistingChoice = choice });
                        if (choice is null) return null;
                        if (!Path.IsPathFullyQualified(choice.Directory)) throw new InvalidDataException("Choose a full mission destination folder.");
                        directory = Path.GetFullPath(choice.Directory);
                        if (!Directory.Exists(directory)) throw new DirectoryNotFoundException("The selected mission destination folder is unavailable: " + directory);
                        if (choice.SaveAsOriginal && !BotOriginalsAvailable(mizPath, choice.OriginalMissionsDirectory ?? directory))
                            throw new InvalidDataException("DCSServerBot originals are available only for a detected bot mission folder.");
                        selectedName = WeatherExportNames.Normalize(choice.FileName, mizPath, directory,
                            choice.KeepBoth || choice.ReplacementIdentity is not null, choice.SaveAsOriginal);
                        if (choice.ReplacementIdentity is { } replacement)
                        {
                            var candidate = Path.GetFullPath(Path.Combine(directory, selectedName));
                            if (!choice.SaveAsOriginal || choice.KeepBoth || !replacement.Exists
                                || !candidate.Equals(replacement.Path, StringComparison.OrdinalIgnoreCase))
                                throw new InvalidDataException("Only a confirmed DCSServerBot original can be replaced here.");
                            replacement.RequireUnchanged();
                            if (candidate.Equals(mizPath, StringComparison.OrdinalIgnoreCase))
                            {
                                sourceFile.Position = 0;
                                if (sourceFile.Length != replacement.Length
                                    || !Convert.ToHexString(SHA256.HashData(sourceFile)).Equals(replacement.Sha256, StringComparison.OrdinalIgnoreCase))
                                    throw new InvalidDataException("The source original changed while settings were being prepared. Choose it again.");
                            }
                            reviewedIdentity = replacement;
                            preparedOutputPath = outputPath = candidate;
                            replacePreparedOutput = true;
                            break;
                        }
                    }
                    var fileName = selectedName ?? WeatherExportNames.MissionStem(mizPath) + (settings is null ? " - Options.miz" : " - Weather.miz");
                    for (var number = 1; ; number++)
                    {
                        var candidate = Path.Combine(directory, WeatherExportNames.NumberedName(fileName, number));
                        if (chooseDestination is not null && candidate.Equals(mizPath, StringComparison.OrdinalIgnoreCase))
                        {
                            if (choice!.KeepBoth) continue;
                            throw new InvalidDataException("Choose a different output path to keep the original MIZ unchanged.");
                        }
                        try
                        {
                            reservation = new FileStream(candidate, FileMode.CreateNew, FileAccess.ReadWrite, FileShare.Read | FileShare.Delete);
                            outputPath = candidate;
                            break;
                        }
                        catch (IOException) when (File.Exists(candidate))
                        {
                            // A typed choice requires explicit Keep both, including a collision after the dialog closed.
                            if (chooseDestination is not null && choice!.KeepBoth == false) break;
                        }
                    }
                }
            }
            reviewedIdentity?.RequireUnchanged();
            if (preparedOutputPath is not null && !replacePreparedOutput)
                reservation = new FileStream(outputPath, FileMode.CreateNew, FileAccess.ReadWrite, FileShare.Read | FileShare.Delete);
            var publicationIdentity = reviewedIdentity is { Exists: false } && reservation is not null
                ? MissionPathIdentity.Capture(outputPath, []) : reviewedIdentity;
            cancellationToken.ThrowIfCancellationRequested();
            AtomicFile.WriteStaged(outputPath, temporaryPath =>
            {
                sourceFile.Position = 0;
                using (var copy = new FileStream(temporaryPath, FileMode.CreateNew, FileAccess.Write, FileShare.None))
                    sourceFile.CopyTo(copy);
                using (var staged = ZipFile.Open(temporaryPath, ZipArchiveMode.Update))
                {
                    if (!warehouseOnly)
                    {
                        var previous = staged.GetEntry("mission")!;
                        previous.Delete();
                        var mission = staged.CreateEntry("mission", CompressionLevel.Optimal);
                        mission.LastWriteTime = missionTimestamp;
                        mission.ExternalAttributes = missionAttributes;
                        using (var stream = mission.Open()) stream.Write(newMission);
                    }
                    if (newOptions is not null)
                    {
                        staged.GetEntry("options")?.Delete();
                        var companion = staged.CreateEntry("options", CompressionLevel.Optimal);
                        companion.LastWriteTime = optionsTimestamp;
                        companion.ExternalAttributes = optionsAttributes;
                        using var optionStream = companion.Open();
                        optionStream.Write(newOptions);
                    }
                    if (configMembers is not null)
                        foreach (var replacement in configMembers)
                        {
                            cancellationToken.ThrowIfCancellationRequested();
                            var oldConfig = staged.GetEntry(replacement.Key)
                                ?? throw new InvalidDataException("The prepared Config member is missing: " + replacement.Key);
                            var timestamp = oldConfig.LastWriteTime;
                            var attributes = oldConfig.ExternalAttributes;
                            oldConfig.Delete();
                            var config = staged.CreateEntry(replacement.Key, CompressionLevel.Optimal);
                            config.LastWriteTime = timestamp;
                            config.ExternalAttributes = attributes;
                            using var stream = config.Open();
                            stream.Write(replacement.Value);
                        }
                    if (warehouseCopy is not null)
                    {
                        cancellationToken.ThrowIfCancellationRequested();
                        var oldWarehouses = staged.GetEntry("warehouses")
                            ?? throw new InvalidDataException("The new mission is missing its root warehouses member.");
                        var timestamp = oldWarehouses.LastWriteTime;
                        var attributes = oldWarehouses.ExternalAttributes;
                        oldWarehouses.Delete();
                        var warehouses = staged.CreateEntry("warehouses", CompressionLevel.Optimal);
                        warehouses.LastWriteTime = timestamp;
                        warehouses.ExternalAttributes = attributes;
                        using var stream = warehouses.Open();
                        stream.Write(warehouseCopy.Bytes);
                    }
                }
                using (var check = ZipFile.OpenRead(temporaryPath))
                {
                    if (!warehouseOnly)
                    {
                        var mission = check.Entries.Where(item => item.FullName == "mission").ToArray();
                        if (mission.Length != 1 || !ReadBytes(mission[0]).SequenceEqual(newMission))
                            throw new InvalidDataException("The staged mission failed verification.");
                    }
                    if (newOptions is not null)
                    {
                        var companion = check.Entries.Where(item => item.FullName == "options").ToArray();
                        if (companion.Length != 1 || !ReadBytes(companion[0]).SequenceEqual(newOptions))
                            throw new InvalidDataException("The staged mission options failed verification.");
                    }
                    if (configMembers is not null)
                        foreach (var replacement in configMembers)
                        {
                            var configs = check.Entries.Where(item => item.FullName == replacement.Key).ToArray();
                            if (configs.Length != 1 || !ReadBytes(configs[0]).SequenceEqual(replacement.Value))
                                throw new InvalidDataException("The staged Config failed verification: " + replacement.Key);
                        }
                    if (warehouseCopy is not null)
                    {
                        var warehouses = check.Entries.Where(item => item.FullName == "warehouses").ToArray();
                        if (warehouses.Length != 1 || !ReadBytes(warehouses[0]).SequenceEqual(warehouseCopy.Bytes))
                            throw new InvalidDataException("The staged warehouses failed verification.");
                    }
                    var actual = check.Entries.Where(item => IsUnchanged(item.FullName)).Select(Fingerprint).ToArray();
                    if (actual.Length != unchanged.Count)
                        throw new InvalidDataException("The staged MIZ changed its member list.");
                    for (var i = 0; i < actual.Length; i++)
                        if (actual[i].Name != unchanged[i].Name || actual[i].Length != unchanged[i].Length
                            || !actual[i].Hash.SequenceEqual(unchanged[i].Hash))
                            throw new InvalidDataException("The staged MIZ changed an unrelated entry: " + unchanged[i].Name);
                }
                cancellationToken.ThrowIfCancellationRequested();
                publicationIdentity?.RequireUnchanged(reservation);
                if (replaceOriginal && keepBackup || preparedOutputPath is not null && replacePreparedOutput && File.Exists(outputPath))
                {
                    var backupSource = preparedOutputPath ?? mizPath;
                    backupPath = Path.Combine(Path.GetDirectoryName(backupSource)!, Path.GetFileNameWithoutExtension(backupSource)
                        + ".weather-backup-" + DateTime.UtcNow.ToString("yyyyMMdd-HHmmss")
                        + "-" + Guid.NewGuid().ToString("N")[..8] + ".miz");
                    AtomicFile.Copy(backupSource, backupPath);
                }
                cancellationToken.ThrowIfCancellationRequested();
            });
            committed = true;
            return new WeatherMizResult(outputPath, backupPath);
        }
        finally
        {
            if (!committed && reservation is not null && File.Exists(outputPath)
                && (preparedOutputPath is null || new FileInfo(outputPath).Length == 0)) File.Delete(outputPath);
            reservation?.Dispose();
        }
        bool IsUnchanged(string name) => (warehouseOnly || name != "mission") && (newOptions is null || name != "options")
            && (configMembers is null || !configMembers.ContainsKey(name))
            && (warehouseCopy is null || name != "warehouses");
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
