#if !FOOTHOLD_USER_BUILD
using System.Globalization;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace FootholdConfigManager;

internal sealed partial class SignedReleaseService : ISignedReleaseService
{
    internal const string Repository = "leka1986/Lekas-Foothold";
    internal const string Workflow = "foothold-manager-signed.yml";
    internal const string ManagerPath = "tools/FootholdConfigManager/";
    private static readonly Version VersionFloor = new(2, 1, 5, 0);
    private static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented = true, MaxDepth = 32 };
    private readonly ISignedReleaseCommandRunner _runner;
    private readonly ISignedReleaseVerifier _verifier;
    private readonly Func<TimeSpan, CancellationToken, Task> _delay;
    private readonly Action<SignedReleaseJob> _save;

    public SignedReleaseService() : this(new SignedReleaseCommandRunner()) { }
    private SignedReleaseService(ISignedReleaseCommandRunner runner) : this(runner, new SignedReleaseVerifier(runner)) { }
    internal SignedReleaseService(ISignedReleaseCommandRunner runner, ISignedReleaseVerifier verifier,
        Func<TimeSpan, CancellationToken, Task>? delay = null, Action<SignedReleaseJob>? save = null)
    {
        _runner = runner;
        _verifier = verifier;
        _delay = delay ?? Task.Delay;
        _save = save ?? SaveLastJob;
    }

    private static string JobPath => Path.Combine(RuntimeSettings.SettingsDirectory, "signed-release-job.json");
    public static SignedReleaseJob? LoadLastJob()
    {
        if (!File.Exists(JobPath)) return null;
        if (new FileInfo(JobPath).Length > 64 * 1024) throw new InvalidDataException("The saved release job is too large.");
        var job = JsonSerializer.Deserialize<SignedReleaseJob>(File.ReadAllText(JobPath), JsonOptions)
            ?? throw new InvalidDataException("The saved release job is empty.");
        ValidateJob(job);
        return job;
    }

    public static void SaveLastJob(SignedReleaseJob job)
    {
        ValidateJob(job);
        AtomicFile.WriteUtf8Text(JobPath, JsonSerializer.Serialize(job, JsonOptions));
    }

    public async Task<SignedReleaseSetup> CheckSetupAsync(CancellationToken cancellationToken)
    {
        try
        {
            var context = await CheckSetupCoreAsync(cancellationToken).ConfigureAwait(false);
            return new(true, "Repository prerequisites are present. SignPath Foundation acceptance and its trusted-build/release-approval policy must also be configured.", context.LatestVersion);
        }
        catch (Exception error) when (error is IOException or InvalidOperationException or InvalidDataException or JsonException
            or TimeoutException or System.ComponentModel.Win32Exception)
        {
            return new(false, "Setup needed: " + error.Message);
        }
    }

    private sealed record SetupContext(string DefaultBranch, string HeadSha, string TreeSha, Version? LatestVersion);
    private async Task<SetupContext> CheckSetupCoreAsync(CancellationToken token)
    {
        await CheckOwnerAsync(token).ConfigureAwait(false);
        using var repo = await ApiAsync("repos/" + Repository, token).ConfigureAwait(false);
        var branch = Text(repo.RootElement, "default_branch");
        if (branch.Length == 0 || !repo.RootElement.GetProperty("permissions").GetProperty("push").GetBoolean())
            throw new InvalidOperationException("The GitHub CLI account needs repository write access.");
        using var head = await ApiAsync("repos/" + Repository + "/git/ref/heads/" + EscapeRef(branch), token).ConfigureAwait(false);
        var sha = Sha(Text(head.RootElement.GetProperty("object"), "sha"));
        using var commit = await ApiAsync("repos/" + Repository + "/git/commits/" + sha, token).ConfigureAwait(false);
        // The workflow is read from the exact default-head commit the release branch will inherit.
        using var workflow = await ApiAsync("repos/" + Repository + "/contents/.github/workflows/" + Workflow + "?ref=" + sha, token).ConfigureAwait(false);
        if (Text(workflow.RootElement, "type") != "file" || !HasDispatchContract(workflow.RootElement))
            throw new InvalidDataException("Install the approved signed-release workflow with workflow_dispatch and its version input on the repository's default branch.");
        using var active = await ApiAsync("repos/" + Repository + "/actions/workflows/" + Workflow, token).ConfigureAwait(false);
        if (Text(active.RootElement, "state") != "active") throw new InvalidOperationException("Enable the signed-release GitHub Actions workflow on the default branch.");
        foreach (var name in new[] { "SIGNPATH_ORGANIZATION_ID", "SIGNPATH_PROJECT_SLUG", "SIGNPATH_SIGNING_POLICY_SLUG" })
        {
            using var variable = await ApiAsync("repos/" + Repository + "/actions/variables/" + name, token).ConfigureAwait(false);
            if (string.IsNullOrWhiteSpace(Text(variable.RootElement, "value")))
                throw new InvalidOperationException("Configure repository Actions variable " + name + " after SignPath Foundation approval.");
        }
        using var secrets = await ApiAsync("repos/" + Repository + "/actions/secrets?per_page=100", token).ConfigureAwait(false);
        if (!secrets.RootElement.GetProperty("secrets").EnumerateArray().Any(item => Text(item, "name") == "SIGNPATH_API_TOKEN"))
            throw new InvalidOperationException("Configure repository Actions secret SIGNPATH_API_TOKEN. Its value stays in GitHub/SignPath and is never read by the Manager.");
        var latest = await ReadLatestAsync(token).ConfigureAwait(false);

        return new(branch, sha, Sha(Text(commit.RootElement.GetProperty("tree"), "sha")), latest);
    }

    private async Task<Version?> ReadLatestAsync(CancellationToken token)
    {
        using var listing = await ApiAsync("repos/" + Repository + "/contents/" + ManagerPath.TrimEnd('/') + "?ref=main", token).ConfigureAwait(false);
        return GitHubUpdateChecker.ParseManager(listing.RootElement)?.Version;
    }

    public async Task<SignedReleaseJob> BuildAsync(SignedReleaseRequest request, IProgress<SignedReleaseProgress> progress, CancellationToken cancellationToken)
    {
        var version = ReleaseVersion(request.Version);
        progress.Report(new("setup", "Checking GitHub and signing prerequisites…"));
        // Every prerequisite read completes before any snapshot upload or Git-data mutation.
        var context = await CheckSetupCoreAsync(cancellationToken).ConfigureAwait(false);
        EnsureNewer(version, context.LatestVersion);
        var output = Path.GetFullPath(request.OutputDirectory);
        var snapshot = Path.Combine(Path.GetTempPath(), "FootholdSignedRelease-" + Guid.NewGuid().ToString("N"));
        try
        {
            progress.Report(new("snapshot", "Preparing selected Designer metadata and Manager inputs…"));
            var files = await Task.Run(() => Snapshot(request, version, snapshot), cancellationToken).ConfigureAwait(false);
            var entries = new List<object>();
            progress.Report(new("upload", "Uploading the immutable Manager build inputs…"));
            foreach (var file in files)
            {
                cancellationToken.ThrowIfCancellationRequested();
                using var blob = await ApiAsync("repos/" + Repository + "/git/blobs", cancellationToken,
                    new { content = Convert.ToBase64String(file.Value), encoding = "base64" }).ConfigureAwait(false);
                entries.Add(new { path = file.Key, mode = "100644", type = "blob", sha = Sha(Text(blob.RootElement, "sha")) });
            }
            using var tree = await ApiAsync("repos/" + Repository + "/git/trees", cancellationToken,
                new { base_tree = context.TreeSha, tree = entries }).ConfigureAwait(false);
            var selected = VersionText(version);
            using var commit = await ApiAsync("repos/" + Repository + "/git/commits", cancellationToken,
                new { message = "Build signed Foothold Manager " + selected, tree = Sha(Text(tree.RootElement, "sha")), parents = new[] { context.HeadSha } }).ConfigureAwait(false);
            var job = new SignedReleaseJob(selected, "foothold-manager/releases/" + selected + "-" + Guid.NewGuid().ToString("N"),
                Sha(Text(commit.RootElement, "sha")), output);
            using var reference = await ApiAsync("repos/" + Repository + "/git/refs", cancellationToken,
                new { @ref = "refs/heads/" + job.Branch, sha = job.CommitSha }).ConfigureAwait(false);
            // Persist the exact immutable branch before dispatch; a stopped watch can always resume.
            _save(job);
            progress.Report(new("dispatch", "Starting the hosted build and SignPath signing request…"));
            job = await DispatchAsync(job, cancellationToken).ConfigureAwait(false);
            _save(job);
            return await ResumeAsync(job, progress, cancellationToken).ConfigureAwait(false);
        }
        finally { if (Directory.Exists(snapshot)) Directory.Delete(snapshot, recursive: true); }
    }

    private async Task CheckOwnerAsync(CancellationToken token)
    {
        using var user = await ApiAsync("user", token).ConfigureAwait(false);
        if (!string.Equals(Text(user.RootElement, "login"), "leka1986", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Sign in to GitHub CLI as repository owner leka1986 (gh auth login). No credentials are entered in this dialog.");
    }

    private static bool HasDispatchContract(JsonElement workflow)
    {
        if (!workflow.TryGetProperty("encoding", out var encoding) || encoding.GetString() != "base64"
            || !workflow.TryGetProperty("content", out var content) || content.ValueKind != JsonValueKind.String) return false;
        string yaml;
        try { yaml = new UTF8Encoding(false, true).GetString(Convert.FromBase64String(content.GetString()!)); }
        catch (Exception error) when (error is FormatException or DecoderFallbackException) { return false; }
        if (yaml.Length > 128 * 1024) return false;
        // Validate the approved block-style YAML dispatch hierarchy without depending on a new YAML package.
        var parents = new List<(int Indent, string Key)>();
        foreach (var line in yaml.Split('\n'))
        {
            var trimmed = line.TrimStart();
            if (trimmed.Length == 0 || trimmed.StartsWith('#')) continue;
            var indent = line.Length - trimmed.Length;
            while (parents.Count > 0 && parents[^1].Indent >= indent) parents.RemoveAt(parents.Count - 1);
            var colon = trimmed.IndexOf(':');
            if (colon <= 0) continue;
            var key = trimmed[..colon].Trim('"', '\'');
            if (key == "version" && parents.Select(parent => parent.Key).SequenceEqual(new[] { "on", "workflow_dispatch", "inputs" })) return true;
            var value = trimmed[(colon + 1)..].Trim();
            if (value.Length == 0 || value.StartsWith('#')) parents.Add((indent, key));
        }
        return false;
    }

    private async Task<SignedReleaseJob> DispatchAsync(SignedReleaseJob job, CancellationToken token)
    {
        await CheckOwnerAsync(token).ConfigureAwait(false);
        var endpoint = "repos/" + Repository + "/actions/workflows/" + Workflow + "/dispatches";
        var input = JsonSerializer.Serialize(new { @ref = job.Branch, inputs = new { version = job.Version } });
        await _delay(TimeSpan.FromSeconds(1), token).ConfigureAwait(false);
        var result = await _runner.RunAsync("gh", ["api", "--hostname", "github.com", "--method", "POST", endpoint,
            "-H", "X-GitHub-Api-Version: 2026-03-10", "--input", "-"], input, TimeSpan.FromMinutes(2), token).ConfigureAwait(false);
        if (result.ExitCode != 0) throw new InvalidOperationException("The workflow dispatch did not confirm submission. Check Actions and Resume the saved job; a request may already have reached GitHub.");
        if (string.IsNullOrWhiteSpace(result.Output)) return job; // Older API responses can be monitored by exact branch+commit.
        using var response = JsonDocument.Parse(result.Output);
        if (!response.RootElement.TryGetProperty("workflow_run_id", out var id) || !id.TryGetInt64(out var runId) || runId <= 0)
            throw new InvalidDataException("GitHub did not confirm a valid workflow run identity. Resume checks the saved branch without resubmitting it.");
        return job with { RunId = runId };
    }

    private async Task<JsonDocument> ApiAsync(string endpoint, CancellationToken token, object? body = null)
    {
        // GitHub recommends spacing mutative requests; reuse the active-operation delay seam.
        if (body is not null) await _delay(TimeSpan.FromSeconds(1), token).ConfigureAwait(false);
        var args = new List<string> { "api", "--hostname", "github.com", "--method", body is null ? "GET" : "POST", endpoint };
        if (body is not null) { args.Add("--input"); args.Add("-"); }
        var result = await _runner.RunAsync("gh", args, body is null ? null : JsonSerializer.Serialize(body), TimeSpan.FromMinutes(2), token).ConfigureAwait(false);
        if (result.ExitCode != 0)
        {
            var step = endpoint.Contains("/contents/.github/workflows/", StringComparison.Ordinal) ? "Install " + Workflow + " on the default branch."
                : endpoint.Contains("/actions/variables/", StringComparison.Ordinal) ? "Configure repository Actions variable " + endpoint.Split('/')[^1] + "."
                : endpoint.Contains("/actions/secrets", StringComparison.Ordinal) ? "Allow the owner CLI login to read repository Actions secret names (never secret values)."
                : "Check the owner GitHub CLI login, repository permissions, connectivity and repository setup.";
            throw new InvalidOperationException("GitHub could not complete a required release step. " + step);
        }
        return JsonDocument.Parse(result.Output, new JsonDocumentOptions { MaxDepth = 32 });
    }

    private async Task CommandAsync(IReadOnlyList<string> args, CancellationToken token)
    {
        var result = await _runner.RunAsync("gh", args, null, TimeSpan.FromMinutes(10), token).ConfigureAwait(false);
        if (result.ExitCode != 0) throw new InvalidOperationException("GitHub CLI could not complete the build/artifact request. Check connectivity and Resume the saved job; remote signing may still be waiting for approval.");
    }

    private static string Text(JsonElement element, string property) => element.GetProperty(property).GetString() ?? "";
    private static string EscapeRef(string value) => string.Join('/', value.Split('/').Select(Uri.EscapeDataString));
    private static string Sha(string value) => Regex.IsMatch(value, @"\A[0-9a-fA-F]{40}\z", RegexOptions.CultureInvariant)
        ? value.ToLowerInvariant() : throw new InvalidDataException("GitHub returned an invalid immutable commit/tree/blob identity.");
    private static Version ReleaseVersion(string value)
    {
        if (!ManagerBuildInfo.TryParseReleaseVersion(value, out var version) || version <= VersionFloor)
            throw new InvalidOperationException("Choose a numeric release version newer than 2.1.5; the first suggested signed release is 2.1.6.");
        return version;
    }
    private static string VersionText(Version version) => version.ToString(version.Revision == 0 ? 3 : 4);
    private static void EnsureNewer(Version version, Version? latest)
    {
        if (latest is not null && version <= latest) throw new InvalidOperationException("Choose a release version newer than the current public download (" + VersionText(latest) + ").");
    }
    private static void ValidateJob(SignedReleaseJob job)
    {
        var version = ReleaseVersion(job.Version);
        var prefix = "foothold-manager/releases/" + VersionText(version) + "-";
        if (job.Version != VersionText(version) || !job.Branch.StartsWith(prefix, StringComparison.Ordinal)
            || !Guid.TryParseExact(job.Branch[prefix.Length..], "N", out _) || Sha(job.CommitSha) != job.CommitSha || job.RunId < 0
            || !Path.IsPathFullyQualified(job.OutputDirectory))
            throw new InvalidDataException("The saved release job does not identify an approved immutable release build.");
    }
}
#endif
