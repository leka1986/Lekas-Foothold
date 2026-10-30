using Loretta.CodeAnalysis.Lua.Syntax;

namespace FootholdConfigManager;

internal static class MissionWeather
{
    public static string Apply(string missionText, WeatherSettings settings) => Apply(missionText, settings, out _);

    internal static string Apply(string missionText, WeatherSettings settings, out double? sourceStartTimeSeconds)
        => ApplyParsed(missionText, settings, out sourceStartTimeSeconds, out _);

    internal static string ApplyParsed(string missionText, WeatherSettings settings, out double? sourceStartTimeSeconds,
        out CompilationUnitSyntax validatedOutput)
        => ApplyParsed(missionText, settings, settings.ChangeDateTime ? new MissionDateTimeSettings
        { ChangeDate = settings.ChangeMissionDate, MissionDate = settings.MissionDate, StartTimeSeconds = settings.StartTimeSeconds } : null,
            out sourceStartTimeSeconds, out validatedOutput);

    internal static string ApplyParsed(string missionText, WeatherSettings? settings, MissionDateTimeSettings? dateTime,
        out double? sourceStartTimeSeconds, out CompilationUnitSyntax validatedOutput)
    {
        sourceStartTimeSeconds = null;
        settings?.Validate();
        dateTime?.Validate();
        var root = WeatherLua.Parse(missionText);
        var assignments = root.Statements.Statements.OfType<AssignmentStatementSyntax>()
            .Where(statement => statement.Variables.Count == 1
                && statement.Variables[0] is IdentifierNameSyntax name && name.Identifier.Text == "mission").ToArray();
        if (assignments.Length != 1 || assignments[0].EqualsValues.Values.Count != 1
            || assignments[0].EqualsValues.Values[0] is not TableConstructorExpressionSyntax mission)
            throw new InvalidDataException("Expected one literal mission table.");
        var sourceTimeField = mission.Fields.LastOrDefault(field => FieldName(field) == "start_time");
        if (sourceTimeField is not null)
        {
            try { sourceStartTimeSeconds = WeatherLua.Read(FieldValue(sourceTimeField)) is double seconds ? seconds : null; }
            catch (InvalidDataException) { /* A scripted mission time is left untouched and gets no guessed time tag. */ }
        }
        var newLine = missionText.Contains("\r\n", StringComparison.Ordinal) ? "\r\n" : "\n";
        var changes = new List<(int Start, int Length, string Text)>();
        if (settings is not null)
        {
            var weatherFields = mission.Fields.Where(field => FieldName(field) == "weather").ToArray();
            if (weatherFields.Length != 1 || FieldValue(weatherFields[0]) is not TableConstructorExpressionSyntax weatherSyntax)
                throw new InvalidDataException("Expected one literal weather table in the mission.");
            var weather = WeatherLua.ReadTable(weatherSyntax);
            if (!settings.DynamicWeather && weather.Get("atmosphere_type") is double atmosphere && atmosphere != 0)
                throw new InvalidDataException("This mission uses dynamic weather. Turn off Apply Weather to edit only its mission options; dynamic weather is left unchanged.");
            settings.ApplyTo(weather);
            changes.Add((weatherSyntax.Span.Start, weatherSyntax.Span.Length, WeatherLua.Serialize(weather, 1, newLine)));
        }
        var additions = new List<string>();
        if (dateTime is not null)
        {
            if (dateTime.ChangeDate)
            {
                var dateFields = mission.Fields.Where(field => FieldName(field) == "date").ToArray();
                if (dateFields.Length > 1) throw new InvalidDataException("Duplicate mission date fields.");
                var date = dateFields.Length == 1 && FieldValue(dateFields[0]) is TableConstructorExpressionSyntax dateSyntax
                    ? WeatherLua.ReadTable(dateSyntax) : new LuaDataTable();
                date.Set("Year", (double)dateTime.MissionDate.Year);
                date.Set("Month", (double)dateTime.MissionDate.Month);
                date.Set("Day", (double)dateTime.MissionDate.Day);
                ChangeRootField("date", date, dateFields);
            }
            ChangeRootField("start_time", dateTime.StartTimeSeconds);
        }
        if (additions.Count > 0)
        {
            var separator = mission.Fields.Count > 0 && mission.Fields.SeparatorCount < mission.Fields.Count ? "," : "";
            changes.Add((mission.CloseBraceToken.Span.Start, 0,
                separator + newLine + string.Join(newLine, additions) + newLine));
        }
        var output = missionText;
        foreach (var change in changes.OrderByDescending(change => change.Start))
            output = output.Remove(change.Start, change.Length).Insert(change.Start, change.Text);
        validatedOutput = WeatherLua.Parse(output);
        return output;

        void ChangeRootField(string name, object value, TableFieldSyntax[]? knownFields = null)
        {
            var fields = knownFields ?? mission.Fields.Where(field => FieldName(field) == name).ToArray();
            if (fields.Length > 1) throw new InvalidDataException("Duplicate mission field: " + name);
            var text = WeatherLua.Serialize(value, 1, newLine);
            if (fields.Length == 1)
            {
                var existing = FieldValue(fields[0]);
                changes.Add((existing.Span.Start, existing.Span.Length, text));
            }
            else additions.Add("\t[\"" + name + "\"] = " + text + ",");
        }
    }

    internal static string? FieldName(TableFieldSyntax field) => field switch
    {
        IdentifierKeyedTableFieldSyntax named => named.Identifier.Text,
        ExpressionKeyedTableFieldSyntax keyed when keyed.Key is LiteralExpressionSyntax literal
            && literal.Token.Value is string name => name,
        _ => null
    };

    internal static ExpressionSyntax FieldValue(TableFieldSyntax field) => field switch
    {
        IdentifierKeyedTableFieldSyntax named => named.Value,
        ExpressionKeyedTableFieldSyntax keyed => keyed.Value,
        UnkeyedTableFieldSyntax unkeyed => unkeyed.Value,
        _ => throw new InvalidDataException("Unsupported table field.")
    };
}
