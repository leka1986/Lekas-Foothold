using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using Loretta.CodeAnalysis.Lua.Syntax;

namespace FootholdConfigManager;

internal sealed record DcsOfflineMissionList(string Text, IReadOnlyList<DcsServerActionOutcome> Outcomes);

internal sealed record DcsRegistrationTargetState(DcsServerTarget Target, string? MissionsIdentity,
    string? SettingsIdentity, string? LogIdentity, long SettingsLength, long SettingsWriteTime, long LogLength, long LogWriteTime);


internal sealed partial class DcsDedicatedServerPlatform
{
    // Parse inert Lua and insert only new list entries. Never execute the settings file.
    internal static DcsOfflineMissionList AppendOfflineMissionList(string text, DcsServerTarget target, IReadOnlyList<string> outputs, Func<string, string>? physical = null)
    {
        var syntax = WeatherLua.Parse(text, "serverSettings.lua");
        var assignments = syntax.Statements.Statements.OfType<AssignmentStatementSyntax>()
            .Where(s => s.Variables.Count == 1 && s.Variables[0] is IdentifierNameSyntax name && name.Identifier.Text == "cfg").ToArray();
        if (syntax.Statements.Statements.Count != 1 || assignments.Length != 1 || assignments[0].EqualsValues.Values.Count != 1
            || assignments[0].EqualsValues.Values[0] is not TableConstructorExpressionSyntax cfg)
            throw new InvalidDataException("Expected one literal cfg table in serverSettings.lua.");
        var fields = cfg.Fields.Where(field => field is IdentifierKeyedTableFieldSyntax named && named.Identifier.Text == "missionList"
            || field is ExpressionKeyedTableFieldSyntax keyed && WeatherLua.Read(keyed.Key) is "missionList").ToArray();
        if (fields.Length > 1) throw new InvalidDataException("The server mission list is duplicated.");
        var expression = fields.FirstOrDefault() switch {
            IdentifierKeyedTableFieldSyntax named => named.Value,
            ExpressionKeyedTableFieldSyntax keyed => keyed.Value,
            _ => null
        };
        if (expression is not null && expression is not TableConstructorExpressionSyntax)
            throw new InvalidDataException("The server mission list must be a literal table.");
        var list = expression as TableConstructorExpressionSyntax;
        var literal = WeatherLua.ReadTable(cfg, rejectDuplicates: true);
        var entries = literal.Get("missionList") as LuaDataTable ?? new LuaDataTable();
        var root = Path.GetFullPath(target.MissionsDirectory);
        var listed = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        for (var index = 1; index <= entries.Entries.Count; index++)
        {
            if (entries.Get(index) is not string path || string.IsNullOrWhiteSpace(path))
                throw new InvalidDataException("The server mission list has missing or unsupported entries.");
            var full = Path.GetFullPath(Path.IsPathFullyQualified(path) ? path : Path.Combine(root, path));
            listed.Add(physical is null ? full : physical(full));
        }
        var outcomes = new List<DcsServerActionOutcome>();
        var added = new List<string>();
        foreach (var output in outputs.Distinct(StringComparer.OrdinalIgnoreCase))
        {
            var full = physical is null ? Path.GetFullPath(output) : physical(output);
            if (!Path.IsPathFullyQualified(output) || !DcsDedicatedServerService.ContainsPath(root, full)
                || !Path.GetExtension(full).Equals(".miz", StringComparison.OrdinalIgnoreCase))
                throw new InvalidDataException("An offline mission entry must be a MIZ inside this instance's Missions folder.");
            if (listed.Contains(full)) outcomes.Add(new(output, "Already listed", target.DisplayName + ": already in the server list."));
            else if (DcsDedicatedServerService.HasBotCounterpart(root, full))
                outcomes.Add(new(output, "Not added", target.DisplayName + ": a ServerBot copy already exists; manage that entry through the bot."));
            else
            {
                listed.Add(full); added.Add(full);
                outcomes.Add(new(output, "Added", target.DisplayName + ": added to the stopped server's mission list."));
            }
        }
        if (added.Count == 0) return new(text, outcomes);
        var newline = text.Contains("\r\n", StringComparison.Ordinal) ? "\r\n" : "\n";
        var lines = added.Select((path, index) => "\t\t[" + (entries.Entries.Count + index + 1) + "] = " + WeatherLua.Serialize(path) + ",");
        var container = list ?? cfg;
        var separator = container.Fields.Count > 0 && container.Fields.SeparatorCount < container.Fields.Count ? "," : "";
        var insertion = list is null
            ? separator + newline + "\t[\"missionList\"] = {" + newline + string.Join(newline, lines) + newline + "\t}," + newline
            : separator + newline + string.Join(newline, lines) + newline;
        var changed = text.Insert(container.CloseBraceToken.Span.Start, insertion);
        WeatherLua.Parse(changed, "serverSettings.lua");
        return new(changed, outcomes);
    }

    public IReadOnlyList<DcsServerActionOutcome> RegisterStoppedMissions(DcsServerTarget target,
        DcsCapabilitySnapshot snapshot, IReadOnlyList<string> outputs, Func<string, string> physical, CancellationToken token)
    {
        token.ThrowIfCancellationRequested();
        var root = CanonicalPath(target.MissionsDirectory);
        var profile = Directory.GetParent(Path.GetFullPath(target.MissionsDirectory))?.FullName
            ?? throw new InvalidDataException("The server profile could not be resolved.");
        var settings = Path.Combine(profile, "Config", "serverSettings.lua");
        var log = Path.Combine(profile, "Logs", "dcs.log");
        var settingsIdentity = CanonicalPath(settings);
        var utf8 = new UTF8Encoding(false, true);
        VerifyStopped(snapshot);
        if (new FileInfo(settings).Length > 4 * 1024 * 1024)
            throw new InvalidDataException("The server settings are too large to verify.");
        var original = File.ReadAllBytes(settings);
        var text = utf8.GetString(original).TrimStart('\uFEFF');
        var plan = AppendOfflineMissionList(text, target with { MissionsDirectory = root }, outputs, physical);
        if (plan.Text == text) return plan.Outcomes;
        token.ThrowIfCancellationRequested();
        var beforeHash = SHA256.HashData(original);
        var backup = settings + ".foothold-backup-" + DateTime.UtcNow.ToString("yyyyMMdd-HHmmss") + "-" + Guid.NewGuid().ToString("N")[..8];
        AtomicFile.WriteStaged(backup, temporary => File.WriteAllBytes(temporary, original));
        var mayHaveCommitted = false;
        try
        {
            AtomicFile.WriteStaged(settings, temporary => {
                File.WriteAllText(temporary, plan.Text, utf8);
                token.ThrowIfCancellationRequested();
                VerifyStopped(CaptureCapabilities(token));
                if (!CanonicalPath(settings).Equals(settingsIdentity, StringComparison.OrdinalIgnoreCase)
                    || !SHA256.HashData(File.ReadAllBytes(settings)).SequenceEqual(beforeHash))
                    throw new InvalidDataException("The server settings changed before registration; no edit was applied.");
                foreach (var output in plan.Outcomes.Where(item => item.RegistrationState == "Added"))
                    if (!File.Exists(output.OutputPath) || !DcsDedicatedServerService.ContainsPath(root, CanonicalPath(output.OutputPath)))
                        throw new InvalidDataException("A saved mission moved or disappeared before registration.");
                mayHaveCommitted = true;
            });
            VerifyStopped(CaptureCapabilities(token));
            if (!File.ReadAllBytes(settings).SequenceEqual(utf8.GetBytes(plan.Text)))
                throw new IOException("The server settings changed during registration.");
            return plan.Outcomes;
        }
        catch (Exception error) when (mayHaveCommitted && (Unavailable(error) || error is OperationCanceledException))
        {
            return plan.Outcomes.Select(item => item.RegistrationState != "Added" ? item : item with {
                RegistrationState = "Unconfirmed", Message = "The offline list edit could not be fully confirmed; no retry was sent. " + error.Message }).ToArray();
        }

        void VerifyStopped(DcsCapabilitySnapshot capabilities) =>
            VerifyStoppedTarget(target, capabilities, root, profile, settingsIdentity, log, utf8, token);
    }

    // Cheap page-entry cache validation. No process, log-owner, header or HTTP discovery.
    internal DcsRegistrationTargetState CaptureRegistrationTargetState(DcsServerTarget target)
    {
        try
        {
            var profile = Directory.GetParent(Path.GetFullPath(target.MissionsDirectory))!.FullName;
            var settings = new FileInfo(Path.Combine(profile, "Config", "serverSettings.lua"));
            var log = new FileInfo(Path.Combine(profile, "Logs", "dcs.log"));
            return new(target, CanonicalPath(target.MissionsDirectory),
                settings.Exists ? CanonicalPath(settings.FullName) : null, log.Exists ? CanonicalPath(log.FullName) : null,
                settings.Exists ? settings.Length : -1, settings.Exists ? settings.LastWriteTimeUtc.Ticks : 0,
                log.Exists ? log.Length : -1, log.Exists ? log.LastWriteTimeUtc.Ticks : 0);
        }
        catch (Exception error) when (Unavailable(error)) { return new(target, null, null, null, -1, 0, -1, 0); }
    }

    // Read-only UI proof; the save path still repeats its running/offline guards before mutation.
    internal string? CaptureRegistrationTarget(DcsServerTarget target, DcsCapabilitySnapshot snapshot, CancellationToken token)
    {
        token.ThrowIfCancellationRequested();
        try
        {
            var root = CanonicalPath(target.MissionsDirectory);
            if (snapshot.Processes.Count > 0 && ResolveLocalTarget(target, snapshot, token) is { } running)
                return running.CanonicalMissionsDirectory.Equals(root, StringComparison.OrdinalIgnoreCase) ? root : null;
            var profile = Directory.GetParent(Path.GetFullPath(target.MissionsDirectory))?.FullName;
            if (profile is null) return null;
            var settingsIdentity = CanonicalPath(Path.Combine(profile, "Config", "serverSettings.lua"));
            VerifyStoppedTarget(target, snapshot, root, profile, settingsIdentity, Path.Combine(profile, "Logs", "dcs.log"),
                new UTF8Encoding(false, true), token);
            return root;
        }
        catch (Exception error) when (Unavailable(error) || error is RegexMatchTimeoutException) { return null; }
    }

    private void VerifyStoppedTarget(DcsServerTarget target, DcsCapabilitySnapshot capabilities, string root,
        string profile, string settingsIdentity, string log, UTF8Encoding utf8, CancellationToken token)
    {
        token.ThrowIfCancellationRequested();
        if (capabilities.UnavailableReason is not null || capabilities.DedicatedInstallations.Count == 0
            || !Path.GetFileName(target.MissionsDirectory.TrimEnd(Path.DirectorySeparatorChar)).Equals("Missions", StringComparison.OrdinalIgnoreCase)
            || root.StartsWith(@"\\", StringComparison.Ordinal) || !CanonicalPath(target.MissionsDirectory).Equals(root, StringComparison.OrdinalIgnoreCase)
            || !DcsDedicatedServerService.ContainsPath(CanonicalPath(profile), settingsIdentity)
            || !File.Exists(log) || LogOwners(log).Length != 0)
            throw new InvalidDataException("This dedicated instance could not be verified as stopped; its settings were not edited.");
        // The target's own bounded startup header supplies offline dedicated-profile provenance.
        using var reader = new StreamReader(new FileStream(log, FileMode.Open, FileAccess.Read, FileShare.ReadWrite | FileShare.Delete), utf8, true);
        var buffer = new char[65536]; var count = reader.ReadBlock(buffer, 0, buffer.Length);
        var header = new string(buffer, 0, count);
        var command = Regex.Match(header, @"Command line:\s*""(?<exe>[^""\r\n]+DCS_server\.exe)""(?<args>[^\r\n]*)", RegexOptions.IgnoreCase | RegexOptions.CultureInvariant, TimeSpan.FromSeconds(1));
        var instance = Regex.Match(command.Groups["args"].Value, @"(?:^|\s)-w\s+(?:""(?<name>[^""]+)""|(?<name>\S+))", RegexOptions.IgnoreCase | RegexOptions.CultureInvariant, TimeSpan.FromSeconds(1));
        if (!command.Success || !instance.Success || !instance.Groups["name"].Value.Equals(Path.GetFileName(profile), StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException("The instance log does not identify this stopped dedicated profile; its settings were not edited.");
        var executable = CanonicalPath(command.Groups["exe"].Value);
        var installation = Directory.GetParent(Path.GetDirectoryName(executable)!)?.FullName;
        if (!Path.GetFileName(executable).Equals("DCS_server.exe", StringComparison.OrdinalIgnoreCase)
            || !capabilities.DedicatedInstallations.Contains(installation, StringComparer.OrdinalIgnoreCase))
            throw new InvalidDataException("The instance log does not identify a verified dedicated installation; its settings were not edited.");
    }
}