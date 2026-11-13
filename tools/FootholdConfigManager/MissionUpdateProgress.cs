namespace FootholdConfigManager;

// Completed operations, never compatibility proof or an inventory of every mission variant.
internal sealed record MissionMapUpdate(string InstanceId, string ReleaseTag, string Map,
    string Method, DateTimeOffset CompletedUtc)
{
    public string? SourcePath { get; init; }
    public string? SourceSha256 { get; init; }
    public string? SourceContentSha256 { get; init; }
    public string? OutputPath { get; init; }
    public string? MissionsDirectory { get; init; }
    public string? CompletionName { get; init; }
    public string? ScriptVersion { get; init; }
}

internal static class MissionUpdateProgress
{
    internal static MissionMapUpdate? Find(IReadOnlyList<MissionMapUpdate> updates, string instanceId,
        string releaseTag, string map, Version? scriptVersion = null) => updates.LastOrDefault(update =>
            update.InstanceId == instanceId && update.ReleaseTag.Equals(releaseTag, StringComparison.OrdinalIgnoreCase)
            && update.Map == map && (scriptVersion is null || MatchesVersion(update, scriptVersion)));

    internal static bool MatchesVersion(MissionMapUpdate update, Version scriptVersion) =>
        ManagerBuildInfo.TryParseReleaseVersion(update.ScriptVersion, out var recorded) ? recorded == scriptVersion
            : (MissionVersion(update.OutputPath) ?? MissionVersion(update.CompletionName)
                ?? (ManagerBuildInfo.TryParseReleaseVersion(update.ReleaseTag.TrimStart('v', 'V'), out var release) ? release : null)) == scriptVersion;

    internal static void Record(RuntimeSettings settings, MissionMapUpdate update)
    {
        settings.MissionMapUpdates.RemoveAll(previous => previous.InstanceId == update.InstanceId
            && previous.ReleaseTag.Equals(update.ReleaseTag, StringComparison.OrdinalIgnoreCase) && previous.Map == update.Map
            && previous.ScriptVersion == update.ScriptVersion
            && string.Equals(previous.SourcePath, update.SourcePath, StringComparison.OrdinalIgnoreCase));
        settings.MissionMapUpdates.Add(update);
    }

    // Presence is refreshed at operation/page boundaries, never from a paint/selection callback.
    internal static IReadOnlyList<MissionMapUpdate> Available(IReadOnlyList<MissionMapUpdate> updates) =>
        updates.Where(update => update.OutputPath is null || File.Exists(update.OutputPath)).ToArray();

    internal static IReadOnlyList<FileUpdateInspection> Project(MissionFilesPreparation preparation,
        IReadOnlyList<MissionMapUpdate> updates, string releaseTag)
    {
        var available = Available(updates).Where(update => update.ReleaseTag.Equals(releaseTag, StringComparison.OrdinalIgnoreCase)).ToArray();
        var equivalents = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var contentUpdates = new List<(MissionMapUpdate Update, string Folder, string Content)>();
        foreach (var update in available)
        {
            preparation.Compatible.TryGetValue(update.SourcePath ?? "", out var source);
            var sameSource = source is not null && source.Identity.Sha256 == update.SourceSha256;
            var name = update.CompletionName;
            if (name is null && sameSource && source!.CompletionName is { } inferredName
                && MissionVersion(inferredName) is { } version && MatchesVersion(update, version)) name = inferredName;
            var folder = update.MissionsDirectory ?? (update.SourcePath is null ? null : Path.GetDirectoryName(update.SourcePath));
            if (name is not null && folder is not null && update.OutputPath is not null)
                equivalents.Add(Path.Combine(folder, name));
            var content = update.SourceContentSha256 ?? (sameSource ? source!.ContentSha256 : null);
            if (content is not null && folder is not null && update.OutputPath is not null)
                contentUpdates.Add((update, folder, content));
        }
        return preparation.Rows.Select(row =>
        {
            if (row.State != FileUpdateInspectionState.Compatible || !preparation.Compatible.TryGetValue(row.Path, out var facts)) return row;
            ManagerBuildInfo.TryParseReleaseVersion(facts.Target.TargetScriptVersion, out var targetVersion);
            var completed = available.Any(update => string.Equals(update.SourcePath, row.Path, StringComparison.OrdinalIgnoreCase)
                && update.SourceSha256 == facts.Identity.Sha256 && update.OutputPath is not null
                && MatchesVersion(update, targetVersion));
            var folder = facts.DefaultOutputDirectory ?? Path.GetDirectoryName(row.Path)!;
            if (facts.ContentSha256 is { } content) completed |= contentUpdates.Any(item => item.Content == content
                && string.Equals(item.Folder, folder, StringComparison.OrdinalIgnoreCase) && MatchesVersion(item.Update, targetVersion));
            if (facts.CompletionName is not null) completed |= equivalents.Contains(Path.Combine(folder, facts.CompletionName));
            // Reuse the existing export naming rules: stock era/language labels are not separate variants.
            foreach (var name in new[] { row.ProposedOutputName, facts.CompletionName }.Distinct(StringComparer.OrdinalIgnoreCase))
            {
                var counterpart = name is null ? null : Path.Combine(folder, name);
                completed |= counterpart is not null && !string.Equals(counterpart, row.Path, StringComparison.OrdinalIgnoreCase) && File.Exists(counterpart);
            }
            return completed ? row with { State = FileUpdateInspectionState.Updated, Reason = "An updated copy already exists." } : row;
        }).ToArray();
    }

    // Member digests already come from the admitted scan; ZIP order, timestamps and external names are not mission data.
    internal static string ContentIdentity(IReadOnlyList<MissionArchiveMember> members) => FilePatchEnvelope.Digest(
        System.Text.Json.JsonSerializer.SerializeToUtf8Bytes(members.Where(member => member.Name != MissionFileUpdateService.ReceiptPath)
            .OrderBy(member => member.Name, StringComparer.Ordinal).Select(member => new { member.Name, member.Length, member.Sha256 })));

    internal static string? CompletionName(string path, FilePatchTarget target, IReadOnlyList<PreparedConfigMember> configs)
    {
        var members = configs.Where(config => target.Replacements.Any(replacement => replacement.MemberPath == config.Name
            && replacement.ConfigVariant == config.Variant)).ToArray();
        if (members.Length != 1) return null;
        try
        {
            var config = members[0];
            var root = WeatherLua.Parse(new System.Text.UTF8Encoding(false, true).GetString(config.Bytes), config.Name);
            var assignments = root.Statements.Statements.OfType<Loretta.CodeAnalysis.Lua.Syntax.AssignmentStatementSyntax>()
                .Where(statement => statement.Variables.Any(variable => variable.ToString() == "Era")).ToArray();
            string? era = assignments.Length == 0 && config.Variant == RuntimeSettings.Ww2ConfigFileName ? "WW2" : null;
            if (assignments.Length == 1 && assignments[0].Variables.Count == 1 && assignments[0].EqualsValues.Values.Count == 1
                && assignments[0].EqualsValues.Values[0] is Loretta.CodeAnalysis.Lua.Syntax.LiteralExpressionSyntax literal)
                era = WeatherLua.Read(literal) as string;
            if (string.IsNullOrWhiteSpace(era)) return null;
            if (path.EndsWith(".miz.orig", StringComparison.OrdinalIgnoreCase)) path = path[..^5];
            return WeatherExportNames.SuggestOptions(MissionFileUpdateService.ProposeOutputName(path, target.TargetScriptVersion), era);
        }
        catch (Exception error) when (error is InvalidDataException or System.Text.DecoderFallbackException)
        { return null; } // Uncertain Config naming never expands completion matching or changes compatibility.
    }

    // Folder status is a filename hint, never files-only compatibility or recorded operation history.
    internal static Version? MissionVersion(string? path)
    {
        if (path is null) return null;
        Version? version = null;
        foreach (var token in Path.GetFileNameWithoutExtension(path).Split('_'))
            if (ManagerBuildInfo.TryParseReleaseVersion(token.TrimStart('v', 'V'), out var parsed))
            { if (version is not null) return null; version = parsed; }
        return version;
    }

    internal static IReadOnlySet<(string Map, Version Version)> CurrentMaps(IReadOnlyList<MissionWarehouseSource> catalog) => CurrentMaps(catalog, []);

    internal static IReadOnlySet<(string Map, Version Version)> CurrentMaps(IReadOnlyList<MissionWarehouseSource> catalog,
        IReadOnlyList<FileUpdateInspection> inspections)
    {
        var inspected = inspections.ToDictionary(row => Path.GetFullPath(row.Path), StringComparer.OrdinalIgnoreCase);
        var maps = new HashSet<(string, Version)>();
        foreach (var source in catalog)
        {
            if (inspected.TryGetValue(Path.GetFullPath(source.Path), out var row))
            {
                if (row.State is FileUpdateInspectionState.Compatible or FileUpdateInspectionState.Updated
                    && row.ObservedMap is { } observedMap && ManagerBuildInfo.TryParseReleaseVersion(row.ObservedMissionVersion, out var observedVersion))
                    maps.Add((observedMap, observedVersion));
                if (row.ObservedMap is not null || row.IdentityOverridesName) continue;
                // Legacy rows with no reusable identity retain the existing catalog-name hint.
            }
            if (!Path.GetExtension(source.Path).Equals(".miz", StringComparison.OrdinalIgnoreCase)
                || MissionWarehouseService.GetMapVariant(source.Path) is not { } map) continue;
            if (MissionVersion(source.Path) is { } version) maps.Add((map, version));
        }
        return maps;
    }

    internal static IReadOnlySet<string> CurrentMaps(IReadOnlyList<MissionWarehouseSource> catalog, string releaseTag) =>
        ManagerBuildInfo.TryParseReleaseVersion(releaseTag.TrimStart('v', 'V'), out var release)
            ? CurrentMaps(catalog).Where(item => item.Version == release).Select(item => item.Map).ToHashSet(StringComparer.Ordinal)
            : new HashSet<string>(StringComparer.Ordinal);

    internal static MissionMapUpdate? FullMission(string instanceId, string releaseTag, MissionReleaseAsset asset, bool zipOnly)
    {
        var map = MissionWarehouseService.GetMapVariant(asset.Name);
        return zipOnly || map is null || string.IsNullOrEmpty(instanceId) || instanceId == "mission-download-folder"
            ? null : new(instanceId, releaseTag, map, "full mission", DateTimeOffset.UtcNow) { ScriptVersion = MissionVersion(asset.Name)?.ToString() };
    }

    internal static IReadOnlyList<MissionMapUpdate> FilesOnly(MissionFilesPreparation preparation,
        IReadOnlyList<MissionFilesRoot> roots, string releaseTag, MissionFilesApplyResult applied)
    {
        var rows = preparation.Rows.ToDictionary(row => row.Path, StringComparer.OrdinalIgnoreCase);
        var instances = roots.ToDictionary(root => root.Id, StringComparer.Ordinal);
        var updates = new List<MissionMapUpdate>();
        foreach (var item in applied.Items)
        {
            if (item.OutputPath is null || item.Error is not null || !rows.TryGetValue(item.SourcePath, out var row)
                || !preparation.Compatible.TryGetValue(item.SourcePath, out var facts)) continue;
            instances.TryGetValue(row.GroupId, out var owner);
            var map = MissionWarehouseService.GetMapVariant(facts.Target);
            if (map is not null) updates.Add(new(row.GroupId, releaseTag, map, "files-only", DateTimeOffset.UtcNow)
            {
                SourcePath = item.SourcePath, SourceSha256 = facts.Identity.Sha256, SourceContentSha256 = facts.ContentSha256, OutputPath = item.OutputPath,
                MissionsDirectory = owner?.MissionsDirectory, CompletionName = facts.CompletionName,
                ScriptVersion = facts.Target.TargetScriptVersion
            });
        }
        return updates;
    }
}
