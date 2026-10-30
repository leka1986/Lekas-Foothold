using Loretta.CodeAnalysis.Lua.Syntax;

namespace FootholdConfigManager;

internal sealed class MissionOption<T>
{
    public bool Enforce { get; set; }
    public T Value { get; set; } = default!;
    public MissionOption() { }
    public MissionOption(T value) => Value = value;
}

internal sealed class MissionOptionsSettings
{
    public MissionOption<string> F10View { get; set; } = new("optview_all");
    public MissionOption<int> Labels { get; set; } = new(0);
    public MissionOption<int> SpottingDots { get; set; } = new(3);
    public MissionOption<bool> EasyCommunication { get; set; } = new(true);
    public MissionOption<string> CivilTraffic { get; set; } = new("");
    public MissionOption<bool> BattleDamage { get; set; } = new(true);
    public MissionOption<bool> DeckCrew { get; set; } = new(true);
    public MissionOption<bool> Carrier1Mc { get; set; } = new(true);

    internal static readonly (string Label, string Value)[] F10Choices =
    {
        ("Map Only", "optview_onlymap"), ("My A/C", "optview_myaircraft"),
        ("Fog of War", "optview_allies"), ("Allies Only", "optview_onlyallies"), ("All", "optview_all")
    };
    internal static readonly (string Label, int Value)[] LabelChoices =
    {
        ("Full", 1), ("Abbreviated", 2), ("Symbol Only", 3), ("Dot Neutral", 4), ("No Labels", 0)
    };
    internal static readonly (string Label, int Value)[] SpottingChoices =
    {
        ("Off", 0), ("Auto", 3), ("1 pixel", 1), ("2 pixels", 2)
    };
    internal static readonly (string Label, string Value)[] TrafficChoices =
    {
        ("Off", ""), ("Low", "low"), ("Medium", "medium"), ("High", "high")
    };

    public void Validate()
    {
        if (F10View is null || Labels is null || SpottingDots is null || EasyCommunication is null
            || CivilTraffic is null || BattleDamage is null || DeckCrew is null || Carrier1Mc is null)
            throw new InvalidDataException("Mission options contain an incomplete Enforce/value pair.");
        if (!F10Choices.Any(item => item.Value == F10View.Value))
            throw new InvalidDataException("Choose one of the five standard F10 view options. Extended is not supported.");
        if (!LabelChoices.Any(item => item.Value == Labels.Value)) throw new InvalidDataException("Choose a valid Labels value.");
        if (!SpottingChoices.Any(item => item.Value == SpottingDots.Value)) throw new InvalidDataException("Choose a valid Spotting Dots value.");
        if (!TrafficChoices.Any(item => item.Value == CivilTraffic.Value)) throw new InvalidDataException("Choose a valid Civ. Traffic value.");
    }

    internal void ApplyTo(LuaDataTable forced)
    {
        Validate();
        Set(forced, "optionsView", F10View);
        Set(forced, "labels", Labels);
        Set(forced, "spottingDot", SpottingDots);
        Set(forced, "easyCommunication", EasyCommunication);
        Set(forced, "civTraffic", CivilTraffic);
        Set(forced, "RBDAI", BattleDamage);
        if (forced.Get("Supercarrier") is not null || DeckCrew.Enforce || Carrier1Mc.Enforce)
        {
            var carrier = forced.Table("Supercarrier");
            Set(carrier, "deck_crew", DeckCrew);
            Set(carrier, "speakers_enabled", Carrier1Mc);
            if (carrier.Entries.Count == 0) forced.Remove("Supercarrier");
        }

        static void Set<T>(LuaDataTable table, string key, MissionOption<T> option)
        {
            if (option.Enforce) table.Set(key, option.Value);
            else table.Remove(key);
        }
    }
}

internal static class MissionOptions
{
    public static string Apply(string missionText, MissionOptionsSettings settings)
        => ApplyParsed(missionText, settings, null);

    // The caller supplies the validated root for this exact immutable mission text.
    internal static string ApplyParsed(string missionText, MissionOptionsSettings settings, CompilationUnitSyntax? root)
    {
        settings.Validate();
        root ??= WeatherLua.Parse(missionText);
        var assignments = root.Statements.Statements.OfType<AssignmentStatementSyntax>()
            .Where(statement => statement.Variables.Count == 1
                && statement.Variables[0] is IdentifierNameSyntax name && name.Identifier.Text == "mission").ToArray();
        if (assignments.Length != 1 || assignments[0].EqualsValues.Values.Count != 1
            || assignments[0].EqualsValues.Values[0] is not TableConstructorExpressionSyntax mission)
            throw new InvalidDataException("Expected one literal mission table.");
        var fields = mission.Fields.Where(field => MissionWeather.FieldName(field) == "forcedOptions").ToArray();
        if (fields.Length > 1) throw new InvalidDataException("Duplicate mission forcedOptions fields.");
        var existing = fields.Length == 0 ? null : MissionWeather.FieldValue(fields[0]);
        if (existing is not null && existing is not TableConstructorExpressionSyntax)
            throw new InvalidDataException("Expected a literal forcedOptions table in the mission.");
        var forced = existing is TableConstructorExpressionSyntax syntax ? WeatherLua.ReadTable(syntax, rejectDuplicates: true) : new LuaDataTable();
        settings.ApplyTo(forced);
        if (existing is null && forced.Entries.Count == 0) return missionText;
        var newLine = missionText.Contains("\r\n", StringComparison.Ordinal) ? "\r\n" : "\n";
        var serialized = WeatherLua.Serialize(forced, 1, newLine);
        string output;
        if (existing is not null)
            output = missionText.Remove(existing.Span.Start, existing.Span.Length).Insert(existing.Span.Start, serialized);
        else
        {
            var separator = mission.Fields.Count > 0 && mission.Fields.SeparatorCount < mission.Fields.Count ? "," : "";
            output = missionText.Insert(mission.CloseBraceToken.Span.Start,
                separator + newLine + "\t[\"forcedOptions\"] = " + serialized + "," + newLine);
        }
        WeatherLua.Parse(output);
        return output;
    }
}
