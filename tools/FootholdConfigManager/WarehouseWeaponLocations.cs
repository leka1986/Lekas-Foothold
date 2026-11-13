using Loretta.CodeAnalysis.Lua.Syntax;

namespace FootholdConfigManager;

internal sealed class WarehouseWeaponLocations
{
    internal const string RulesKey = "WarehouseWeaponsAllowedAtAirbases";
    internal const string CatalogKey = "WarehouseWeaponLocationAirbases";

    internal Dictionary<string, Dictionary<string, string[]>> Rules { get; }
    internal Dictionary<string, string[]> Catalog { get; }

    internal WarehouseWeaponLocations(string rulesText, string catalogText)
    {
        Rules = ReadNamedTables(rulesText).ToDictionary(
            entry => entry.Key,
            entry => entry.Value.Entries.ToDictionary(
                field => field.Key as string ?? throw new InvalidDataException("Expected a DCS weapon ID."),
                field => ReadNames(field.Value),
                StringComparer.Ordinal),
            StringComparer.Ordinal);
        Catalog = ReadNamedTables(catalogText).ToDictionary(
            entry => entry.Key, entry => ReadNames(entry.Value), StringComparer.Ordinal);

        // Older South Atlantic catalogs omitted two of the mission's carrier warehouses.
        if (Catalog.TryGetValue("South Atlantic", out var southAtlantic))
            Catalog["South Atlantic"] = southAtlantic.Union(["CVN-72", "CVN-74", "Tarawa"], StringComparer.Ordinal).ToArray();

        // Older Persian Gulf catalogs included a carrier that is absent from the mission.
        if (Catalog.TryGetValue("Persian Gulf", out var persianGulf))
            Catalog["Persian Gulf"] = persianGulf.Where(name => name != "CVN-73").ToArray();
    }

    private static Dictionary<string, LuaDataTable> ReadNamedTables(string text)
    {
        return WeatherLua.ReadTable(ReadTableSyntax(text), rejectDuplicates: true).Entries.ToDictionary(
            pair => pair.Key as string ?? throw new InvalidDataException("Expected a Foothold mission name."),
            pair => pair.Value as LuaDataTable ?? throw new InvalidDataException("Expected a table for each mission."),
            StringComparer.Ordinal);
    }

    private static TableConstructorExpressionSyntax ReadTableSyntax(string text)
    {
        var root = WeatherLua.Parse(text, "warehouse locations");
        if (root.Statements.Statements.SingleOrDefault() is not AssignmentStatementSyntax assignment ||
            assignment.EqualsValues.Values.SingleOrDefault() is not TableConstructorExpressionSyntax table)
        {
            throw new InvalidDataException("Expected a warehouse location table.");
        }

        return table;
    }

    private static string[] ReadNames(object? value)
    {
        if (value is not LuaDataTable table)
            throw new InvalidDataException("Expected a list of warehouse names.");

        return table.Entries.Select((entry, index) =>
            entry.Key is double number && number == index + 1 && entry.Value is string name
                ? name
                : throw new InvalidDataException("Expected a list of exact warehouse names.")).ToArray();
    }

    internal string RenderMissionRules(string original, string mission)
    {
        var table = ReadTableSyntax(original);
        var rules = Rules[mission];
        var missionField = table.Fields.SingleOrDefault(field => FieldKey(field) == mission);
        if (missionField is null)
        {
            var rows = string.Concat(rules.Select(pair => FormatRow(pair.Key, pair.Value)));
            return original.Insert(table.OpenBraceToken.Span.End, "\n    [" + WeatherLua.Serialize(mission)
                + "] = {" + rows + "\n    },");
        }

        var missionTable = (TableConstructorExpressionSyntax)FieldValue(missionField);
        var existing = missionTable.Fields.Select(FieldKey).ToHashSet(StringComparer.Ordinal);
        var edits = new List<(int Start, int Length, string Text)>();
        for (var index = 0; index < missionTable.Fields.Count; index++)
        {
            var field = missionTable.Fields[index];
            var id = FieldKey(field);
            if (rules.TryGetValue(id, out var names))
            {
                var value = FieldValue(field);
                if (!ReadNames(WeatherLua.Read(value)).SequenceEqual(names, StringComparer.Ordinal))
                    edits.Add((value.Span.Start, value.Span.Length, FormatNames(names)));
            }
            else
            {
                edits.Add((field.Span.Start, field.Span.Length, ""));
                if (index < missionTable.Fields.SeparatorCount)
                {
                    var separator = missionTable.Fields.GetSeparator(index).Span;
                    edits.Add((separator.Start, separator.Length, ""));
                }
                else if (index > 0)
                {
                    var separator = missionTable.Fields.GetSeparator(index - 1).Span;
                    edits.Add((separator.Start, separator.Length, ""));
                }
            }
        }

        var added = string.Concat(rules.Where(pair => !existing.Contains(pair.Key))
            .Select(pair => FormatRow(pair.Key, pair.Value)));
        if (added.Length > 0) edits.Add((missionTable.OpenBraceToken.Span.End, 0, added));

        foreach (var (start, length, replacement) in edits.OrderByDescending(edit => edit.Start))
            original = original.Remove(start, length).Insert(start, replacement);
        return original;
    }

    private static string FormatRow(string id, string[] names) =>
        "\n        [" + WeatherLua.Serialize(id) + "] = " + FormatNames(names) + ",";

    private static string FormatNames(string[] names) =>
        "{ " + string.Join(", ", names.Select(name => WeatherLua.Serialize(name))) + " }";

    private static string FieldKey(TableFieldSyntax field) => field switch
    {
        IdentifierKeyedTableFieldSyntax named => named.Identifier.Text,
        ExpressionKeyedTableFieldSyntax keyed => (string)WeatherLua.Read(keyed.Key)!,
        _ => throw new InvalidDataException("Expected a named warehouse rule.")
    };

    private static ExpressionSyntax FieldValue(TableFieldSyntax field) => field switch
    {
        IdentifierKeyedTableFieldSyntax named => named.Value,
        ExpressionKeyedTableFieldSyntax keyed => keyed.Value,
        _ => throw new InvalidDataException("Expected a named warehouse rule.")
    };
}
