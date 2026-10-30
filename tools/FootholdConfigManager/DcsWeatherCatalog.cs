using Loretta.CodeAnalysis.Lua.Syntax;
using Microsoft.Win32;
using System.Text.RegularExpressions;

namespace FootholdConfigManager;

internal sealed record DcsCloudPreset(string Id, string Name, string? ThumbnailPath,
    double MinimumBaseMeters, double MaximumBaseMeters, double DefaultBaseMeters)
{
    public override string ToString() => Name;
}
internal sealed record DcsHaloPreset(string Id, string Name, string? ThumbnailPath)
{
    public override string ToString() => Name;
}

internal sealed class DcsWeatherCatalog
{
    public string InstallationPath { get; }
    public IReadOnlyList<DcsCloudPreset> CloudPresets { get; }
    public IReadOnlyList<DcsHaloPreset> HaloPresets { get; }
    public IReadOnlyList<DcsHaloPreset> CrystalPresets { get; }
    public bool UsesClientPreviewAssets => CloudPresets.Any(preset => preset.ThumbnailPath is not null
        && !preset.ThumbnailPath.StartsWith(InstallationPath + Path.DirectorySeparatorChar, StringComparison.OrdinalIgnoreCase));

    private DcsWeatherCatalog(string root, List<DcsCloudPreset> clouds, List<DcsHaloPreset> halos, List<DcsHaloPreset> crystals)
    {
        InstallationPath = root;
        CloudPresets = clouds;
        HaloPresets = halos;
        CrystalPresets = crystals;
    }

    public static DcsWeatherCatalog Load(string root)
    {
        root = Path.TrimEndingDirectorySeparator(Path.GetFullPath(root));
        var cloudsPath = Path.Combine(root, "Config", "Effects", "clouds.lua");
        if (!File.Exists(cloudsPath))
            throw new InvalidDataException("Choose the main DCS installation folder containing Config/Effects/clouds.lua.");
        var cloudsTable = AssignedTable(File.ReadAllText(cloudsPath), "clouds");
        var presets = TableValue(cloudsTable, "presets");
        var clouds = new List<DcsCloudPreset>();
        foreach (var field in presets.Fields)
        {
            var id = MissionWeather.FieldName(field);
            if (id is null || MissionWeather.FieldValue(field) is not TableConstructorExpressionSyntax definition
                || Literal(definition, "visibleInGUI") is not true) continue;
            var name = Text(Value(definition, "readableNameShort"))
                ?? Text(Value(definition, "readableName")) ?? id;
            var min = Number(definition, "presetAltMin");
            var max = Number(definition, "presetAltMax");
            var layers = Value(definition, "layers") as TableConstructorExpressionSyntax;
            var firstLayer = layers?.Fields.FirstOrDefault();
            var initial = firstLayer is not null && MissionWeather.FieldValue(firstLayer) is TableConstructorExpressionSyntax layer
                ? Number(layer, "altitudeMin", Math.Max(0, min)) : Math.Max(0, min);
            if (min < 0 || max < 0) min = max = initial;
            if (max < min || min < 0 || max > 30000) throw new InvalidDataException("Invalid cloud base limits for " + id + ".");
            clouds.Add(new DcsCloudPreset(id, name, AssetPath(root, Text(Value(definition, "thumbnailName"))),
                min, max, Math.Clamp(initial, min, max)));
        }
        if (clouds.Count == 0) throw new InvalidDataException("No visible cloud presets were found in this installation.");
        if (clouds.Select(p => p.Id).Distinct(StringComparer.Ordinal).Count() != clouds.Count)
            throw new InvalidDataException("Duplicate cloud preset IDs.");
        var halos = new List<DcsHaloPreset>();
        var crystals = new List<DcsHaloPreset>();
        var haloPath = Path.Combine(root, "Config", "Effects", "icehalo.lua");
        if (File.Exists(haloPath))
        {
            var halo = AssignedTable(File.ReadAllText(haloPath), "icehalo");
            LoadHaloChoices("presets", halos);
            LoadHaloChoices("crystalsPresets", crystals);

            void LoadHaloChoices(string tableName, List<DcsHaloPreset> choices)
            {
                if (Value(halo, tableName) is not TableConstructorExpressionSyntax table) return;
                foreach (var field in table.Fields)
                {
                    var id = MissionWeather.FieldName(field);
                    if (id is null || MissionWeather.FieldValue(field) is not TableConstructorExpressionSyntax entry
                        || Literal(entry, "visibleInGUI") is not true) continue;
                    var name = Text(Value(entry, "readableName")) ?? Text(Value(entry, "readableNameShort")) ?? id;
                    var order = name.IndexOf("##", StringComparison.Ordinal);
                    if (order >= 0) name = name[(order + 2)..].Trim();
                    choices.Add(new DcsHaloPreset(id, name, AssetPath(root, Text(Value(entry, "thumbnailName")))));
                }
            }
        }
        return new DcsWeatherCatalog(root, clouds, halos, crystals);
    }

    public static IReadOnlyList<string> DetectInstallations(string? remembered, string? missionScripting)
    {
        var candidates = new List<string>();
        Add(remembered);
        Add(@"C:\Games\DCS World Server");
        Add(@"C:\Games\Eagle Dynamics\DCS World");
        if (!string.IsNullOrWhiteSpace(missionScripting))
            Add(Path.GetDirectoryName(Path.GetDirectoryName(missionScripting)));
        foreach (var hive in new[] { Registry.CurrentUser, Registry.LocalMachine })
            foreach (var keyName in new[] { @"SOFTWARE\Eagle Dynamics\DCS World", @"SOFTWARE\Eagle Dynamics\DCS World OpenBeta",
                @"SOFTWARE\WOW6432Node\Eagle Dynamics\DCS World" })
            {
                try
                {
                    using var key = hive.OpenSubKey(keyName);
                    Add(key?.GetValue("Path") as string);
                }
                catch (Exception ex) when (ex is UnauthorizedAccessException or System.Security.SecurityException) { }
            }
        var names = new[] { "DCS World", "DCS World OpenBeta", "DCS World Server" };
        foreach (var drive in DriveInfo.GetDrives().Where(d => d.DriveType == DriveType.Fixed && d.IsReady))
            foreach (var parent in new[] { "Games", @"Games\Eagle Dynamics", @"Eagle Dynamics",
                @"Program Files\Eagle Dynamics", @"Program Files (x86)\Eagle Dynamics" })
                foreach (var name in names) Add(Path.Combine(drive.RootDirectory.FullName, parent, name));
        var steamRoots = new List<string>
        {
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86), "Steam")
        };
        try
        {
            using var key = Registry.CurrentUser.OpenSubKey(@"SOFTWARE\Valve\Steam");
            if (key?.GetValue("SteamPath") is string steamPath) steamRoots.Add(steamPath);
        }
        catch (Exception ex) when (ex is UnauthorizedAccessException or System.Security.SecurityException) { }
        foreach (var steamRoot in steamRoots.Distinct(StringComparer.OrdinalIgnoreCase))
        {
            Add(Path.Combine(steamRoot, "steamapps", "common", "DCSWorld"));
            var libraries = Path.Combine(steamRoot, "steamapps", "libraryfolders.vdf");
            if (!File.Exists(libraries)) continue;
            try
            {
                foreach (Match match in Regex.Matches(File.ReadAllText(libraries), "\"path\"\\s+\"([^\"]+)\""))
                    Add(Path.Combine(match.Groups[1].Value.Replace(@"\\", @"\"), "steamapps", "common", "DCSWorld"));
            }
            catch (Exception ex) when (ex is IOException or UnauthorizedAccessException) { }
        }
        return candidates;

        void Add(string? path)
        {
            if (string.IsNullOrWhiteSpace(path)) return;
            try
            {
                path = Path.TrimEndingDirectorySeparator(Path.GetFullPath(path));
                if (File.Exists(Path.Combine(path, "Config", "Effects", "clouds.lua"))
                    && !candidates.Contains(path, StringComparer.OrdinalIgnoreCase)) candidates.Add(path);
            }
            catch (Exception ex) when (ex is ArgumentException or NotSupportedException or IOException) { }
        }
    }

    private static TableConstructorExpressionSyntax AssignedTable(string text, string name)
    {
        var root = WeatherLua.Parse(text, name + ".lua");
        var assignment = root.Statements.Statements.OfType<AssignmentStatementSyntax>()
            .FirstOrDefault(statement => statement.Variables.Count == 1 && statement.Variables[0].ToString() == name);
        return assignment?.EqualsValues.Values.FirstOrDefault() as TableConstructorExpressionSyntax
            ?? throw new InvalidDataException("Could not locate the " + name + " definitions.");
    }

    private static ExpressionSyntax? Value(TableConstructorExpressionSyntax table, string name) =>
        table.Fields.Where(field => MissionWeather.FieldName(field) == name).Select(MissionWeather.FieldValue).LastOrDefault();

    private static TableConstructorExpressionSyntax TableValue(TableConstructorExpressionSyntax table, string name) =>
        Value(table, name) as TableConstructorExpressionSyntax ?? throw new InvalidDataException("Missing preset table: " + name);

    private static object? Literal(TableConstructorExpressionSyntax table, string name) =>
        Value(table, name) is { } expression ? WeatherLua.Read(expression) : null;

    private static double Number(TableConstructorExpressionSyntax table, string name, double? fallback = null) =>
        Literal(table, name) is double value ? value
            : fallback ?? throw new InvalidDataException("Missing numeric preset field: " + name);

    private static string? Text(ExpressionSyntax? expression)
    {
        if (expression is LiteralExpressionSyntax literal) return literal.Token.Value as string;
        if (expression is FunctionCallExpressionSyntax or BinaryExpressionSyntax)
        {
            var parts = expression.DescendantNodesAndSelf().OfType<LiteralExpressionSyntax>()
                .Select(node => node.Token.Value).OfType<string>().ToArray();
            if (parts.Length > 0) return string.Concat(parts);
        }
        return null;
    }

    private static string? AssetPath(string root, string? relative)
    {
        if (string.IsNullOrWhiteSpace(relative)) return null;
        var full = Path.GetFullPath(Path.Combine(root, relative.Replace('/', Path.DirectorySeparatorChar)));
        if (!full.StartsWith(root + Path.DirectorySeparatorChar, StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException("A DCS thumbnail path leaves its installation folder.");
        if (File.Exists(full)) return full;
        const string client = @"C:\Games\Eagle Dynamics\DCS World";
        var fallback = Path.GetFullPath(Path.Combine(client, relative.Replace('/', Path.DirectorySeparatorChar)));
        return fallback.StartsWith(client + Path.DirectorySeparatorChar, StringComparison.OrdinalIgnoreCase)
            && File.Exists(fallback) ? fallback : null;
    }
}
