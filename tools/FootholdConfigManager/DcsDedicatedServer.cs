namespace FootholdConfigManager;

internal sealed record DcsProcessIdentity(int ProcessId, long StartFileTime, string ExecutablePath, string InstallationDirectory);
internal sealed record DcsCapabilitySnapshot(IReadOnlyList<string> DedicatedInstallations,
    IReadOnlyList<DcsProcessIdentity> Processes, string? UnavailableReason = null);
internal sealed record DcsServerTarget(string Id, string DisplayName, string MissionsDirectory);

internal sealed record DcsLocalTargetIdentity(DcsServerTarget Target, DcsProcessIdentity Process,
    Uri Endpoint, string CanonicalMissionsDirectory);

internal sealed record DcsNativeMissionList(IReadOnlyList<string> Paths, int StartIndex, bool Loop, bool Shuffle);
internal sealed record DcsNativeMissionState(int Mode, string? CurrentPath);
internal sealed record DcsServerActionOutcome(string OutputPath, string RegistrationState, string Message);

internal interface IDcsDedicatedServerPlatform
{
    DcsCapabilitySnapshot CaptureCapabilities(CancellationToken token);
    DcsLocalTargetIdentity? ResolveLocalTarget(DcsServerTarget target, DcsCapabilitySnapshot snapshot, CancellationToken token);
    IReadOnlyList<DcsServerActionOutcome> RegisterStoppedMissions(DcsServerTarget target, DcsCapabilitySnapshot snapshot,
        IReadOnlyList<string> outputs, Func<string, string> physical, CancellationToken token);
    bool IsCurrent(DcsProcessIdentity process);
    string CanonicalPath(string path);
}

internal sealed class DcsDedicatedServerService(IDcsDedicatedServerPlatform platform,
    Func<Uri, string, DcsWebGuiClient> clientFactory)
{
    internal DcsCapabilitySnapshot? LastCapabilities { get; private set; }

    internal static bool ContainsPath(string directory, string path) =>
        path.StartsWith(Path.TrimEndingDirectorySeparator(directory) + Path.DirectorySeparatorChar, StringComparison.OrdinalIgnoreCase);

    internal static bool HasBotCounterpart(string root, string physical)
    {
        var relative = Path.GetRelativePath(root, physical);
        var botPath = Path.Combine(root, ".dcssb", relative);
        return relative.Split(Path.DirectorySeparatorChar)[0].Equals(".dcssb", StringComparison.OrdinalIgnoreCase)
            || File.Exists(botPath) || File.Exists(botPath + ".orig");
    }

    internal async Task<IReadOnlyList<DcsServerActionOutcome>> RegisterSavedMissionsAsync(
        IReadOnlyList<string> outputs, IReadOnlyList<DcsServerTarget> targets, CancellationToken token)
    {
        if (outputs.Count == 0) return [];
        var results = outputs.Distinct(StringComparer.OrdinalIgnoreCase).ToDictionary(p => p,
            p => new DcsServerActionOutcome(p, "Not added", "No running dedicated instance could be verified for this saved mission."),
            StringComparer.OrdinalIgnoreCase);
        // Physical path facts are shared only within this admitted batch, not across jobs.
        var identities = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        string Physical(string path)
        {
            if (!Path.IsPathFullyQualified(path)) throw new InvalidDataException("A server path must be absolute.");
            var full = Path.GetFullPath(path);
            if (!identities.TryGetValue(full, out var physical))
            {
                physical = File.Exists(full) || Directory.Exists(full) ? platform.CanonicalPath(full) : full;
                identities.Add(full, physical);
            }
            return physical;
        }
        var roots = new Dictionary<string, DcsServerTarget>(StringComparer.OrdinalIgnoreCase);
        foreach (var target in targets)
        {
            token.ThrowIfCancellationRequested();
            try { if (Directory.Exists(target.MissionsDirectory)) roots.TryAdd(Physical(target.MissionsDirectory), target); }
            catch (Exception error) when (ExternalFailure(error)) { }
        }
        var groups = new Dictionary<string, List<string>>(StringComparer.OrdinalIgnoreCase);
        foreach (var output in results.Keys)
        {
            token.ThrowIfCancellationRequested();
            try
            {
                if (!File.Exists(output) || !Path.GetExtension(output).Equals(".miz", StringComparison.OrdinalIgnoreCase)) continue;
                var outputIdentity = Physical(output);
                var owners = roots.Keys.Where(root => ContainsPath(root, outputIdentity)).Take(2).ToArray();
                if (owners.Length != 1) continue;
                if (!groups.TryGetValue(owners[0], out var group)) groups.Add(owners[0], group = []);
                group.Add(output);
            }
            catch (Exception error) when (ExternalFailure(error)) { }
        }
        if (groups.Count == 0) return results.Values.ToArray();
        DcsCapabilitySnapshot snapshot;
        try { snapshot = LastCapabilities = platform.CaptureCapabilities(token); }
        catch (Exception error) when (ExternalFailure(error) && !token.IsCancellationRequested)
        { return results.Values.Select(result => result with { Message = "Server information is unavailable: " + error.Message }).ToArray(); }
        if (snapshot.Processes.Count == 0 && snapshot.DedicatedInstallations.Count == 0) return results.Values.ToArray();

        foreach (var (root, group) in groups)
        {
            if (token.IsCancellationRequested) return results.Values.ToArray();
            var attempted = false;
            try
            {
                var local = platform.ResolveLocalTarget(roots[root], snapshot, token);
                if (local is null)
                {
                    foreach (var outcome in platform.RegisterStoppedMissions(roots[root], snapshot, group, Physical, token))
                        results[outcome.OutputPath] = outcome;
                    continue;
                }
                if (!platform.IsCurrent(local.Process)) continue;
                using var client = clientFactory(local.Endpoint, local.Process.InstallationDirectory);
                var reportedRoot = await client.GetDefaultMissionsDirectoryAsync(token).ConfigureAwait(false);
                if (!Physical(reportedRoot).Equals(root, StringComparison.OrdinalIgnoreCase)
                    || !local.CanonicalMissionsDirectory.Equals(root, StringComparison.OrdinalIgnoreCase)) continue;
                var beforeState = await client.GetMissionStateAsync(token).ConfigureAwait(false);
                if (beforeState.Mode != 4 || string.IsNullOrWhiteSpace(beforeState.CurrentPath)) continue;
                var before = await client.GetMissionListAsync(token).ConfigureAwait(false);
                var listed = before.Paths.Select(Physical).ToHashSet(StringComparer.OrdinalIgnoreCase);
                var missing = new List<string>();
                foreach (var path in group)
                {
                    var physical = Physical(path);
                    if (listed.Contains(physical))
                        results[path] = new(path, "Already listed", local.Target.DisplayName + ": already in the server list.");
                    else
                    {
                        if (HasBotCounterpart(root, physical))
                            results[path] = new(path, "Not added", local.Target.DisplayName + ": a ServerBot copy already exists; manage that entry through the bot.");
                        else missing.Add(path);
                    }
                }
                if (missing.Count == 0) continue;
                token.ThrowIfCancellationRequested();
                var currentRoot = await client.GetDefaultMissionsDirectoryAsync(token).ConfigureAwait(false);
                var currentState = await client.GetMissionStateAsync(token).ConfigureAwait(false);
                if (!Physical(currentRoot).Equals(root, StringComparison.OrdinalIgnoreCase)
                    || currentState != beforeState) continue;
                if (!platform.IsCurrent(local.Process)
                    || !platform.CanonicalPath(local.Target.MissionsDirectory).Equals(root, StringComparison.OrdinalIgnoreCase)
                    || missing.Any(path => !File.Exists(path) || !platform.CanonicalPath(path).Equals(Physical(path), StringComparison.OrdinalIgnoreCase))) continue;
                var acknowledged = false;
                attempted = true;
                try { acknowledged = await client.AddMissionsAsync(missing, token).ConfigureAwait(false); }
                catch (Exception error) when (ExternalFailure(error) || error is OperationCanceledException)
                {
                    // DCS may have accepted the append. Never resend it on timeout/cancel.
                    if (token.IsCancellationRequested)
                    {
                        foreach (var path in missing)
                            results[path] = new(path, "Unconfirmed", "Registration may have been accepted before cancellation.");
                        return results.Values.ToArray();
                    }
                }
                var after = await client.GetMissionListAsync(token).ConfigureAwait(false);
                var afterState = await client.GetMissionStateAsync(token).ConfigureAwait(false);
                var unchanged = platform.IsCurrent(local.Process) && afterState.Mode == beforeState.Mode && before.Loop == after.Loop && before.Shuffle == after.Shuffle
                    && before.StartIndex == after.StartIndex && after.Paths.Count >= before.Paths.Count
                    && before.Paths.SequenceEqual(after.Paths.Take(before.Paths.Count), StringComparer.OrdinalIgnoreCase)
                    && string.Equals(beforeState.CurrentPath, afterState.CurrentPath, StringComparison.OrdinalIgnoreCase);
                var afterPaths = after.Paths.Select(Physical).ToHashSet(StringComparer.OrdinalIgnoreCase);
                foreach (var path in missing)
                {
                    var added = acknowledged && unchanged && afterPaths.Contains(Physical(path));
                    results[path] = new(path, added ? "Added" : "Unconfirmed", added
                        ? local.Target.DisplayName + ": added to the server list."
                        : local.Target.DisplayName + ": registration could not be fully confirmed; no retry was sent.");
                }
            }
            catch (OperationCanceledException) when (token.IsCancellationRequested)
            {
                if (attempted)
                    foreach (var path in group)
                        if (results[path].RegistrationState != "Already listed")
                            results[path] = new(path, "Unconfirmed", "Registration may have been accepted before cancellation; no retry was sent.");
                return results.Values.ToArray();
            }
            catch (Exception error) when (ExternalFailure(error))
            {
                foreach (var path in group)
                    if (results[path].RegistrationState != "Already listed")
                        results[path] = new(path, attempted ? "Unconfirmed" : "Not added",
                            "Server list: " + error.Message);
            }
        }
        return results.Values.ToArray();
    }

    private static bool ExternalFailure(Exception error) => DcsDedicatedServerPlatform.Unavailable(error)
        || error is HttpRequestException or System.Text.Json.JsonException or System.Security.Cryptography.CryptographicException
            or OperationCanceledException or KeyNotFoundException or FormatException;
}
