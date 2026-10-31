using Loretta.CodeAnalysis.Lua.Syntax;

namespace FootholdConfigManager;

internal sealed class MissionOption<T>
{
    public bool Enforce { get; set; }
    public T Value { get; set; } = default!;
    public MissionOption() { }
    public MissionOption(T value) => Value = value;
}

internal sealed class ExtendedF10RoleOptions
{
    public string View { get; set; } = "optview_all";
    public bool[] VisibleUnitLayers { get; set; } = Enumerable.Repeat(true, 15).ToArray();
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
    public MissionOption<bool> CrashRecovery { get; set; } = new(true);
    public MissionOption<bool> ExternalViews { get; set; } = new(true);
    public MissionOption<bool> SimplifiedFlight { get; set; } = new(true);
    public MissionOption<bool> Immortal { get; set; } = new(false);
    public MissionOption<bool> UnlimitedFuel { get; set; } = new(false);
    public MissionOption<bool> UnlimitedWeapons { get; set; } = new(false);
    public MissionOption<bool> RadioAssists { get; set; } = new(false);
    public MissionOption<bool> UnrestrictedSatnav { get; set; } = new(false);
    public MissionOption<bool> Padlock { get; set; } = new(true);
    public MissionOption<bool> WakeTurbulence { get; set; } = new(false);
    public MissionOption<bool> RandomFailures { get; set; } = new(false);
    public MissionOption<bool> GWarmUp { get; set; } = new(false);
    public MissionOption<bool> MiniHud { get; set; } = new(false);
    public MissionOption<bool> CockpitVisualRecon { get; set; } = new(false);
    public MissionOption<bool> F10UserMarks { get; set; } = new(true);
    public MissionOption<bool> CockpitStatusBar { get; set; } = new(false);
    public MissionOption<string> GEffects { get; set; } = new("none");
    public MissionOption<int> Birds { get; set; } = new(0);
    public Dictionary<int, ExtendedF10RoleOptions> ExtendedF10 { get; set; }
        = Enumerable.Range(1, 6).ToDictionary(role => role, _ => new ExtendedF10RoleOptions());

    // Known option pairs from Foothold_CA_5.4.3; absent keys remain unenforced.
    internal static MissionOptionsSettings CreateFootholdDefaults() => new()
    {
        F10View = new("optview_allies") { Enforce = true },
        Labels = new(0) { Enforce = true },
        EasyCommunication = new(false) { Enforce = true },
        CivilTraffic = new("") { Enforce = true },
        DeckCrew = new(true) { Enforce = true },
        Carrier1Mc = new(true) { Enforce = true },
        CrashRecovery = new(false) { Enforce = true },
        ExternalViews = new(true) { Enforce = true },
        SimplifiedFlight = new(false) { Enforce = true },
        Immortal = new(false) { Enforce = true },
        UnlimitedFuel = new(false) { Enforce = true },
        UnlimitedWeapons = new(false) { Enforce = true },
        RadioAssists = new(false) { Enforce = true },
        UnrestrictedSatnav = new(true) { Enforce = true },
        Padlock = new(false) { Enforce = true },
        WakeTurbulence = new(false) { Enforce = true },
        RandomFailures = new(false) { Enforce = true },
        MiniHud = new(false) { Enforce = true },
        CockpitVisualRecon = new(false) { Enforce = true },
        F10UserMarks = new(true) { Enforce = true },
        CockpitStatusBar = new(false) { Enforce = true },
        GEffects = new("realistic") { Enforce = true },
        Birds = new(0) { Enforce = true }
    };

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

    internal static readonly (string Label, string Value)[] GEffectChoices =
    {
        ("None", "none"), ("Reduced", "reduced"), ("Simulation", "realistic")
    };

    public void Validate()
    {
        if (F10View is null || Labels is null || SpottingDots is null || EasyCommunication is null
            || CivilTraffic is null || BattleDamage is null || DeckCrew is null || Carrier1Mc is null)
            throw new InvalidDataException("Mission options contain an incomplete Enforce/value pair.");
        if (CrashRecovery is null || ExternalViews is null || SimplifiedFlight is null || Immortal is null
            || UnlimitedFuel is null || UnlimitedWeapons is null || RadioAssists is null || UnrestrictedSatnav is null
            || Padlock is null || WakeTurbulence is null || RandomFailures is null || GWarmUp is null
            || MiniHud is null || CockpitVisualRecon is null || F10UserMarks is null || CockpitStatusBar is null
            || GEffects is null || Birds is null)
            throw new InvalidDataException("Mission options contain an incomplete Enforce/value pair.");
        if (!GEffectChoices.Any(item => item.Value == GEffects.Value))
            throw new InvalidDataException("Choose a valid G-Effects value.");
        if (Birds.Value is < 0 or > 1000)
            throw new InvalidDataException("Birds must be between 0 and 1,000, as in the DCS editor.");
        if (!F10Choices.Any(item => item.Value == F10View.Value) && F10View.Value != "optview_extended")
            throw new InvalidDataException("Choose a valid F10 view option.");
        if (ExtendedF10 is null || ExtendedF10.Count != 6)
            throw new InvalidDataException("Extended F10 requires the six DCS role settings.");
        for (var role = 1; role <= 6; role++)
            if (!ExtendedF10.TryGetValue(role, out var options) || options is null
                || !F10Choices.Any(item => item.Value == options.View)
                || options.VisibleUnitLayers is null || options.VisibleUnitLayers.Length != 15)
                throw new InvalidDataException("Extended F10 requires a standard view and 15 visibility layers for each role.");
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
        Set(forced, "permitCrash", CrashRecovery);
        Set(forced, "externalViews", ExternalViews);
        Set(forced, "easyFlight", SimplifiedFlight);
        Set(forced, "immortal", Immortal);
        Set(forced, "fuel", UnlimitedFuel);
        Set(forced, "weapons", UnlimitedWeapons);
        Set(forced, "radio", RadioAssists);
        Set(forced, "unrestrictedSATNAV", UnrestrictedSatnav);
        Set(forced, "padlock", Padlock);
        Set(forced, "wakeTurbulence", WakeTurbulence);
        Set(forced, "accidental_failures", RandomFailures);
        Set(forced, "gWarmUp", GWarmUp);
        Set(forced, "miniHUD", MiniHud);
        Set(forced, "cockpitVisualRM", CockpitVisualRecon);
        Set(forced, "userMarks", F10UserMarks);
        Set(forced, "cockpitStatusBarAllowed", CockpitStatusBar);
        Set(forced, "geffect", GEffects);
        Set(forced, "birds", Birds);
        if (F10View.Enforce && F10View.Value == "optview_extended")
        {
            var extended = forced.Table("optionsViewExtended");
            for (var roleId = 1; roleId <= 6; roleId++)
            {
                var existing = extended.Get(roleId);
                if (existing is not null && existing is not LuaDataTable)
                    throw new InvalidDataException("Extended F10 role " + roleId + " is not a table.");
                var role = existing as LuaDataTable ?? new LuaDataTable();
                var options = ExtendedF10[roleId];
                role.Set("f10ViewOption", options.View);
                var mask = role.Table("visibleUnitLayersMask");
                for (var bit = 0; bit < options.VisibleUnitLayers.Length; bit++)
                    mask.Set(bit, options.VisibleUnitLayers[bit]);
                extended.Set(roleId, role);
            }
        }
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
    // The export caller has validated Labels; preserve all unowned option text.
    internal static string ApplyEnforcedLabels(string optionsText, int labels)
    {
        var root = WeatherLua.Parse(optionsText, "options");
        var assignments = root.Statements.Statements.OfType<AssignmentStatementSyntax>()
            .Where(statement => statement.Variables.Count == 1
                && statement.Variables[0] is IdentifierNameSyntax name && name.Identifier.Text == "options").ToArray();
        if (assignments.Length != 1 || assignments[0].EqualsValues.Values.Count != 1
            || assignments[0].EqualsValues.Values[0] is not TableConstructorExpressionSyntax options)
            throw new InvalidDataException("Expected one literal options table.");
        var fields = options.Fields.Where(field => OptionFieldName(field) == "difficulty").ToArray();
        if (fields.Length > 1) throw new InvalidDataException("Duplicate options difficulty fields.");
        var existing = fields.Length == 0 ? null : MissionWeather.FieldValue(fields[0]);
        if (existing is not null && existing is not TableConstructorExpressionSyntax)
            throw new InvalidDataException("Expected a literal difficulty table in options.");
        var newLine = optionsText.Contains("\r\n", StringComparison.Ordinal) ? "\r\n" : "\n";
        var changes = new List<(int Start, int Length, string Text)>();
        var values = new (string Name, object Value)[] { ("labels", labels), ("setGlobal", false) };
        if (existing is TableConstructorExpressionSyntax difficulty)
        {
            var additions = new List<string>();
            foreach (var value in values)
            {
                var matches = difficulty.Fields.Where(field => OptionFieldName(field) == value.Name).ToArray();
                if (matches.Length > 1) throw new InvalidDataException("Duplicate difficulty field: " + value.Name);
                var text = WeatherLua.Serialize(value.Value);
                if (matches.Length == 1)
                {
                    var expression = MissionWeather.FieldValue(matches[0]);
                    if (WeatherLua.Read(expression) is LuaDataTable)
                        throw new InvalidDataException("Expected a literal difficulty value: " + value.Name);
                    changes.Add((expression.Span.Start, expression.Span.Length, text));
                }
                else additions.Add("\t\t[\"" + value.Name + "\"] = " + text + ",");
            }
            if (additions.Count > 0)
            {
                var separator = difficulty.Fields.Count > 0 && difficulty.Fields.SeparatorCount < difficulty.Fields.Count ? "," : "";
                changes.Add((difficulty.CloseBraceToken.Span.Start, 0,
                    separator + newLine + string.Join(newLine, additions) + newLine));
            }
        }
        else
        {
            var createdDifficulty = new LuaDataTable();
            foreach (var value in values) createdDifficulty.Set(value.Name, value.Value);
            var separator = options.Fields.Count > 0 && options.Fields.SeparatorCount < options.Fields.Count ? "," : "";
            changes.Add((options.CloseBraceToken.Span.Start, 0,
                separator + newLine + "\t[\"difficulty\"] = " + WeatherLua.Serialize(createdDifficulty, 1, newLine) + "," + newLine));
        }
        var output = optionsText;
        foreach (var change in changes.OrderByDescending(change => change.Start))
            output = output.Remove(change.Start, change.Length).Insert(change.Start, change.Text);
        WeatherLua.Parse(output, "options");
        return output;

        static string? OptionFieldName(TableFieldSyntax field) => field is ExpressionKeyedTableFieldSyntax keyed
            ? WeatherLua.Read(keyed.Key) as string : MissionWeather.FieldName(field);
    }


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
