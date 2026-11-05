using Loretta.CodeAnalysis.Lua.Syntax;
using System.IO.Compression;
using System.Security.Cryptography;
using System.Text;

namespace FootholdConfigManager;

internal static class MissionWarehouseService
{
    private static readonly (string Prefix, string Name, string Theatre)[] Maps = [
        ("Foothold_CA_", "Caucasus", "Caucasus"), ("Foothold_AF_", "Afghanistan", "Afghanistan"),
        ("Foothold_GCW_", "Germany Cold War", "GermanyCW"), ("Foothold_IRAQ_", "Iraq", "Iraq"),
        ("Foothold_Ko_", "Kola", "Kola"), ("Foothold_PG_", "Persian Gulf", "PersianGulf"),
        ("Foothold_SI_extended_", "Sinai Extended", "SinaiMap"), ("Foothold_SI_North_", "Sinai North", "SinaiMap"),
        ("Foothold_SY_extended_", "Syria Extended", "Syria"), ("WWII_Normandy_Foothold_", "Normandy WWII", "Normandy") ];
    private static readonly (string Prefix, string Name)[] MapAliases = [
        ("Foothold_Caucasus_", "Caucasus"), ("Foothold_Afghanistan_", "Afghanistan"),
        ("Foothold_Germany_", "Germany Cold War"), ("Foothold_PersianGulf_", "Persian Gulf"),
        ("Foothold_Kola_", "Kola"), ("Foothold_Syria_", "Syria Extended"),
        ("Foothold_Sinai_Extended_", "Sinai Extended"), ("Foothold_Sinai_North_", "Sinai North"),
        ("Foothold_Normandy_", "Normandy WWII") ];
    private static readonly UTF8Encoding Utf8 = new(false, true);
    internal sealed record WarehouseReferences(HashSet<long> Airports, HashSet<long> Units, HashSet<long> Groups);
    internal sealed record UnitIdentity(string Name, string Type, string Coalition);
    internal sealed record GroupIdentity(string Name, string Coalition);
    internal sealed record MissionReferences(string Theatre, Dictionary<long, UnitIdentity> Units, Dictionary<long, GroupIdentity> Groups);
    internal sealed record SourceSnapshot(MissionPathIdentity Identity, byte[] Bytes, string Sha256,
        WarehouseReferences References, MissionReferences Mission);

    internal static string? GetMapVariant(string name)
    {
        var fileName = Path.GetFileName(name);
        return Maps.FirstOrDefault(map => fileName.StartsWith(map.Prefix, StringComparison.OrdinalIgnoreCase)).Name
            ?? MapAliases.FirstOrDefault(map => fileName.StartsWith(map.Prefix, StringComparison.OrdinalIgnoreCase)).Name;
    }

    private static bool MatchesSourceVariant(string path, string variant)
    {
        var sourceVariant = GetMapVariant(path);
        return sourceVariant == variant || sourceVariant is null && (variant is "Sinai North" or "Sinai Extended")
            && Path.GetFileName(path).StartsWith("Foothold_Sinai_", StringComparison.OrdinalIgnoreCase);
    }

    internal static IReadOnlyList<MissionWarehouseSource> DiscoverSources(string missionDirectory, CancellationToken token)
    {
        token.ThrowIfCancellationRequested();
        if (!Path.IsPathFullyQualified(missionDirectory)) throw new InvalidDataException("Choose a full mission folder before finding older missions.");
        var sources = new List<MissionWarehouseSource>();
        foreach (var path in Directory.EnumerateFiles(missionDirectory, "*", SearchOption.TopDirectoryOnly))
        {
            token.ThrowIfCancellationRequested();
            if (!Path.GetExtension(path).Equals(".miz", StringComparison.OrdinalIgnoreCase)) continue;
            var file = new FileInfo(path);
            sources.Add(new(file.FullName, file.LastWriteTimeUtc, file.Length));
        }
        return sources.AsReadOnly();
    }

    internal static IReadOnlyList<MissionWarehouseSource> FindSources(string templateName, IReadOnlyList<MissionWarehouseSource> catalog)
    {
        var variant = GetMapVariant(templateName);
        return variant is null ? Array.Empty<MissionWarehouseSource>() : Array.AsReadOnly(catalog
            .Where(source => MatchesSourceVariant(source.Path, variant)).OrderByDescending(source => source.LastWriteTimeUtc)
            .ThenBy(source => source.Path, StringComparer.OrdinalIgnoreCase).ToArray());
    }

    internal static MissionWarehouseCopy Prepare(PreparedMissionTemplate target, string sourcePath, CancellationToken token)
        => PrepareFromSource(target, CaptureSource(target, sourcePath, token), token);

    internal static SourceSnapshot CaptureSource(PreparedMissionTemplate firstTarget, string sourcePath, CancellationToken token)
    {
        token.ThrowIfCancellationRequested();
        sourcePath = Path.GetFullPath(sourcePath);
        _ = ValidateSourceSelection(firstTarget, sourcePath);
        var limits = MissionPackageLimits.Default;
        byte[] sourceMission, sourceWarehouses;
        MissionPathIdentity identity;
        using (var file = new FileStream(sourcePath, FileMode.Open, FileAccess.Read, FileShare.Read))
        {
            if (file.Length > limits.MizBytes) throw new InvalidDataException("The older MIZ exceeds the supported size.");
            identity = new(sourcePath, true, file.Length, Convert.ToHexString(SHA256.HashData(file)));
            file.Position = 0;
            using var archive = new ZipArchive(file, ZipArchiveMode.Read);
            CheckArchive(archive, limits);
            var mission = RootEntry(archive, "mission"); var warehouses = RootEntry(archive, "warehouses");
            if (mission.Length > limits.CapturedBytes - warehouses.Length)
                throw new InvalidDataException("The older mission and warehouses exceed the preparation memory limit.");
            sourceMission = ReadMember(mission, limits.MemberBytes, token);
            sourceWarehouses = ReadMember(warehouses, limits.MemberBytes, token);
        }
        var references = ReadWarehouseReferences(sourceWarehouses, token);
        var missionReferences = ReadMissionReferences(sourceMission, references, token);
        token.ThrowIfCancellationRequested();
        return new(identity, sourceWarehouses, Convert.ToHexString(SHA256.HashData(sourceWarehouses)), references, missionReferences);
    }

    internal static MissionWarehouseCopy PrepareFromSource(PreparedMissionTemplate target, SourceSnapshot source, CancellationToken token)
    {
        token.ThrowIfCancellationRequested();
        var sourcePath = source.Identity.Path;
        var variant = ValidateSourceSelection(target, sourcePath);
        var limits = MissionPackageLimits.Default;
        var targetWarehouseMember = target.Members.SingleOrDefault(member => member.Name == "warehouses")
            ?? throw new InvalidDataException("The new mission is missing its root warehouses member.");
        byte[] targetWarehouses;
        using (var archive = ZipFile.OpenRead(target.SourcePath))
        {
            var member = RootEntry(archive, "warehouses");
            if (target.MissionBytes.LongLength > limits.CapturedBytes - member.Length)
                throw new InvalidDataException("The new mission and warehouses exceed the preparation memory limit.");
            targetWarehouses = ReadMember(member, limits.MemberBytes, token);
        }
        if (targetWarehouses.LongLength != targetWarehouseMember.Length
            || Convert.ToHexString(SHA256.HashData(targetWarehouses)) != targetWarehouseMember.Sha256)
            throw new InvalidDataException("The downloaded warehouses changed after preparation. Prepare the release again.");
        var oldReferences = source.References;
        var newReferences = ReadWarehouseReferences(targetWarehouses, token);
        if (!oldReferences.Airports.SetEquals(newReferences.Airports) || !oldReferences.Units.SetEquals(newReferences.Units))
            throw new InvalidDataException("The older and new missions have different airport or warehouse unit IDs. Use the new warehouses or choose another source.");
        var oldMission = source.Mission;
        var newMission = ReadMissionReferences(target.MissionBytes, oldReferences, token);
        var expectedTheatre = Maps.Single(map => map.Name == variant).Theatre;
        if (oldMission.Theatre != newMission.Theatre || newMission.Theatre != expectedTheatre)
            throw new InvalidDataException("The actual mission theatres do not match the selected map/variant.");
        foreach (var id in oldReferences.Units)
            if (!oldMission.Units.TryGetValue(id, out var before) || !newMission.Units.TryGetValue(id, out var after) || before != after)
                throw new InvalidDataException("Warehouse unit " + id + " is missing or has a different name, type or coalition in the new mission.");
        foreach (var id in oldReferences.Groups)
            if (!oldMission.Groups.TryGetValue(id, out var before) || !newMission.Groups.TryGetValue(id, out var after) || before != after)
                throw new InvalidDataException("Dynamic warehouse group " + id + " is missing or has a different name or coalition in the new mission.");
        token.ThrowIfCancellationRequested();
        return new(source.Identity, source.Bytes, source.Sha256, newMission.Theatre, Path.GetFileName(sourcePath));
    }

    internal static string ValidateSourceSelection(PreparedMissionTemplate target, string sourcePath)
    {
        var targetNameVariant = GetMapVariant(target.Name);
        var assetVariant = GetMapVariant(target.Asset.Name);
        if (targetNameVariant is not null && assetVariant is not null && targetNameVariant != assetVariant)
            throw new InvalidDataException("The downloaded mission name and release map/variant disagree.");
        var variant = targetNameVariant ?? assetVariant ?? throw new InvalidDataException("The downloaded mission map/variant is not recognized.");
        if (!Path.GetExtension(sourcePath).Equals(".miz", StringComparison.OrdinalIgnoreCase) || !MatchesSourceVariant(sourcePath, variant))
            throw new InvalidDataException("Choose an older mission with the same map and mission variant.");
        if (sourcePath.Equals(Path.GetFullPath(target.SourcePath), StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException("Choose an older local MIZ instead of the downloaded template itself.");
        return variant;
    }

    private static void CheckArchive(ZipArchive archive, MissionPackageLimits limits)
    {
        if (archive.Entries.Count > limits.Entries) throw new InvalidDataException("The older MIZ has too many archive entries.");
        var names = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        long expanded = 0;
        foreach (var entry in archive.Entries)
        {
            if (!names.Add(entry.FullName)) throw new InvalidDataException("The older MIZ contains ambiguous duplicate member names.");
            if (entry.Length > limits.MemberBytes || entry.Length > limits.ExpandedBytes - expanded)
                throw new InvalidDataException("The older MIZ exceeds the expanded-member limits.");
            expanded += entry.Length;
        }
    }

    private static ZipArchiveEntry RootEntry(ZipArchive archive, string name)
    {
        var entries = archive.Entries.Where(entry => entry.FullName == name).ToArray();
        if (entries.Length != 1) throw new InvalidDataException("Expected exactly one root " + name + " archive member.");
        return entries[0];
    }

    private static byte[] ReadMember(ZipArchiveEntry entry, long maximum, CancellationToken token)
    {
        if (entry.Length > maximum || entry.Length > int.MaxValue) throw new InvalidDataException("The mission archive member is too large: " + entry.FullName);
        var bytes = new byte[checked((int)entry.Length)];
        using var input = entry.Open(); using var output = new MemoryStream(bytes, writable: true);
        MissionDownloadService.CopyBounded(input, output, entry.Length, maximum, entry.Crc32, token);
        return bytes;
    }

    private static TableConstructorExpressionSyntax ReadRoot(byte[] bytes, string name)
    {
        var offset = bytes.AsSpan().StartsWith(Encoding.UTF8.Preamble) ? Encoding.UTF8.Preamble.Length : 0;
        string text;
        try { text = Utf8.GetString(bytes, offset, bytes.Length - offset); }
        catch (DecoderFallbackException error) { throw new InvalidDataException("The " + name + " member is not valid UTF-8.", error); }
        var parsed = WeatherLua.Parse(text, name);
        var assignments = parsed.Statements.Statements.OfType<AssignmentStatementSyntax>().Where(statement =>
            statement.Variables.Count == 1 && statement.Variables[0] is IdentifierNameSyntax variable && variable.Identifier.Text == name).ToArray();
        if (assignments.Length != 1 || assignments[0].EqualsValues.Values.Count != 1
            || assignments[0].EqualsValues.Values[0] is not TableConstructorExpressionSyntax table)
            throw new InvalidDataException("Expected one literal " + name + " table.");
        if (parsed.Statements.Statements.Count != 1) throw new InvalidDataException("The " + name + " archive member must contain only its literal table assignment.");
        return table;
    }

    private static ExpressionSyntax? Field(TableConstructorExpressionSyntax table, string name, bool optional = false)
    {
        var fields = table.Fields.Where(field => MissionWeather.FieldName(field) == name).ToArray();
        if (fields.Length > 1 || fields.Length == 0 && !optional) throw new InvalidDataException("Expected one literal field: " + name);
        return fields.Length == 0 ? null : MissionWeather.FieldValue(fields[0]);
    }
    private static TableConstructorExpressionSyntax Table(ExpressionSyntax? value, string name) => value as TableConstructorExpressionSyntax
        ?? throw new InvalidDataException("Expected a literal table for " + name + ".");
    private static string Text(ExpressionSyntax? value, string name) => value is LiteralExpressionSyntax literal
        && WeatherLua.Read(literal) is string text && text.Length > 0 ? text
        : throw new InvalidDataException("Expected literal text for " + name + ".");
    private static long Id(ExpressionSyntax? value, string name)
    {
        while (value is ParenthesizedExpressionSyntax parenthesized) value = parenthesized.Expression;
        if (value is LiteralExpressionSyntax or UnaryExpressionSyntax { Operand: LiteralExpressionSyntax }
            && WeatherLua.Read(value) is double number && number >= 0 && number <= int.MaxValue && number == Math.Truncate(number)) return (long)number;
        throw new InvalidDataException("Expected a literal nonnegative ID for " + name + ".");
    }

    private static WarehouseReferences ReadWarehouseReferences(byte[] bytes, CancellationToken token)
    {
        var table = ReadRoot(bytes, "warehouses");
        HashSet<long> Keys(string name)
        {
            var ids = new HashSet<long>();
            var nextIndex = 1L;
            foreach (var field in Table(Field(table, name), name).Fields)
            {
                var id = field switch
                {
                    ExpressionKeyedTableFieldSyntax keyed => Id(keyed.Key, name),
                    UnkeyedTableFieldSyntax => nextIndex++,
                    _ => throw new InvalidDataException("Ambiguous warehouse IDs in " + name + ".")
                };
                if (!ids.Add(id))
                    throw new InvalidDataException("Ambiguous warehouse IDs in " + name + ".");
                _ = Table(MissionWeather.FieldValue(field), name);
            }
            return ids;
        }
        var airports = Keys("airports"); var units = Keys("warehouses"); var groups = new HashSet<long>();
        foreach (var node in table.DescendantNodesAndSelf())
        {
            token.ThrowIfCancellationRequested();
            if (node is TableFieldSyntax field && MissionWeather.FieldName(field) == "linkDynTempl")
            {
                var id = Id(MissionWeather.FieldValue(field), "linkDynTempl");
                if (id > 0) groups.Add(id); // DCS writes zero when no dynamic template is linked.
            }
            if (node is ExpressionSyntax expression && expression is not TableConstructorExpressionSyntax
                and not LiteralExpressionSyntax and not UnaryExpressionSyntax and not ParenthesizedExpressionSyntax)
                throw new InvalidDataException("The warehouses member contains a nonliteral expression. No mission code is executed.");
            if (node is UnaryExpressionSyntax unary) _ = WeatherLua.Read(unary);
        }
        return new(airports, units, groups);
    }

    private static MissionReferences ReadMissionReferences(byte[] bytes, WarehouseReferences wanted, CancellationToken token)
    {
        var mission = ReadRoot(bytes, "mission");
        var theatre = Text(Field(mission, "theatre"), "theatre");
        var units = new Dictionary<long, UnitIdentity>(); var groups = new Dictionary<long, GroupIdentity>();
        var coalition = Table(Field(mission, "coalition"), "coalition");
        foreach (var side in coalition.Fields)
        {
            var sideName = MissionWeather.FieldName(side) ?? throw new InvalidDataException("Expected a named coalition.");
            var countryValue = Field(Table(MissionWeather.FieldValue(side), sideName), "country", optional: true);
            if (countryValue is null) continue;
            foreach (var country in Table(countryValue, "country").Fields)
            foreach (var category in Table(MissionWeather.FieldValue(country), "country").Fields)
            {
                token.ThrowIfCancellationRequested();
                if (MissionWeather.FieldValue(category) is not TableConstructorExpressionSyntax categoryTable) continue;
                var groupValue = Field(categoryTable, "group", optional: true);
                if (groupValue is null) continue;
                foreach (var groupField in Table(groupValue, "group").Fields)
                {
                    var group = Table(MissionWeather.FieldValue(groupField), "group");
                    var groupId = Id(Field(group, "groupId"), "groupId");
                    if (wanted.Groups.Contains(groupId) && !groups.TryAdd(groupId, new(Text(Field(group, "name"), "group name"), sideName)))
                        throw new InvalidDataException("A referenced dynamic group ID occurs more than once.");
                    var unitValue = Field(group, "units", optional: true);
                    if (unitValue is null) continue;
                    foreach (var unitField in Table(unitValue, "units").Fields)
                    {
                        var unit = Table(MissionWeather.FieldValue(unitField), "unit");
                        var unitId = Id(Field(unit, "unitId"), "unitId");
                        if (wanted.Units.Contains(unitId) && !units.TryAdd(unitId,
                            new(Text(Field(unit, "name"), "unit name"), Text(Field(unit, "type"), "unit type"), sideName)))
                            throw new InvalidDataException("A referenced warehouse unit ID occurs more than once.");
                    }
                }
            }
        }
        return new(theatre, units, groups);
    }
}
