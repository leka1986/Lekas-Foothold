#if !FOOTHOLD_USER_BUILD
using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace FootholdConfigManager;

internal sealed partial class SignedReleaseService
{
    internal static string RunUrl(SignedReleaseJob job) => job.RunId > 0
        ? "https://github.com/" + Repository + "/actions/runs/" + job.RunId.ToString(CultureInfo.InvariantCulture)
        : "https://github.com/" + Repository + "/actions/workflows/" + Workflow;

    public async Task<SignedReleaseJob> ResumeAsync(SignedReleaseJob job, IProgress<SignedReleaseProgress> progress, CancellationToken cancellationToken)
    {
        ValidateJob(job);

        var missingRunPolls = 0;
        for (var poll = 0; poll < 720; poll++)
        {
            cancellationToken.ThrowIfCancellationRequested();
            if (job.RunId == 0)
            {
                using var runs = await ApiAsync("repos/" + Repository + "/actions/workflows/" + Workflow + "/runs?branch="
                    + Uri.EscapeDataString(job.Branch) + "&event=workflow_dispatch&per_page=100", cancellationToken).ConfigureAwait(false);
                var matches = runs.RootElement.GetProperty("workflow_runs").EnumerateArray()
                    .Where(run => Text(run, "head_branch") == job.Branch && Text(run, "head_sha") == job.CommitSha
                        && Text(run, "event") == "workflow_dispatch").OrderBy(run => run.GetProperty("id").GetInt64()).ToArray();
                if (matches.Length > 0)
                {
                    ValidateRun(matches[0], job);
                    job = job with { RunId = matches[0].GetProperty("id").GetInt64() };
                    _save(job);
                }
                else
                {
                    // A timeout/cancellation can hide a successful dispatch. Resume must never duplicate that request.
                    if (++missingRunPolls >= 12) throw new InvalidOperationException("No exact workflow run is visible for the saved branch yet. Submission may still be pending. Check Actions and Resume later; this watch did not resubmit or cancel any request.");
                    progress.Report(new("queued", "Waiting for the exact branch and commit to appear in Actions…", RunUrl(job)));
                    await _delay(TimeSpan.FromSeconds(5), cancellationToken).ConfigureAwait(false);
                    continue;
                }
            }
            using var runDocument = await ApiAsync("repos/" + Repository + "/actions/runs/" + job.RunId.ToString(CultureInfo.InvariantCulture), cancellationToken).ConfigureAwait(false);
            var run = runDocument.RootElement;
            ValidateRun(run, job);
            if (Text(run, "status") == "completed")
            {
                if (Text(run, "conclusion") != "success")
                    throw new InvalidOperationException("The hosted build/signing run finished with " + Text(run, "conclusion") + ". Open build for its details; no release is ready.");
                return await DownloadAsync(job, progress, cancellationToken).ConfigureAwait(false);
            }
            var message = "Hosted compile/tests/signing are running. Stop watching preserves this job for Resume.";
            var stage = "building";
            using var jobs = await ApiAsync("repos/" + Repository + "/actions/runs/" + job.RunId.ToString(CultureInfo.InvariantCulture) + "/jobs?per_page=100", cancellationToken).ConfigureAwait(false);
            foreach (var item in jobs.RootElement.GetProperty("jobs").EnumerateArray())
            foreach (var step in item.GetProperty("steps").EnumerateArray())
                if (Text(step, "name") == "Request SignPath signing" && Text(step, "status") == "in_progress")
                {
                    stage = "signing";
                    message = "SignPath signing is active and may need your approval. Use Approve in SignPath; you can stop watching and Resume later.";
                }
            progress.Report(new(stage, message, RunUrl(job)));
            await _delay(TimeSpan.FromSeconds(5), cancellationToken).ConfigureAwait(false);
        }
        throw new TimeoutException("The watch reached its one-hour limit. The remote job was kept; Resume to continue watching.");
    }

    private static void ValidateRun(JsonElement run, SignedReleaseJob job)
    {
        var id = run.GetProperty("id").GetInt64();
        var workflowPath = Text(run, "path").Split('@')[0];
        if (id <= 0 || job.RunId != 0 && id != job.RunId || Text(run, "head_sha") != job.CommitSha
            || Text(run, "head_branch") != job.Branch || Text(run, "event") != "workflow_dispatch"
            || workflowPath != ".github/workflows/" + Workflow
            || Text(run.GetProperty("repository"), "full_name") != Repository
            || Text(run.GetProperty("head_repository"), "full_name") != Repository)
            throw new InvalidDataException("The GitHub run does not match this release's repository, workflow, immutable branch and exact commit.");
    }

    private async Task<SignedReleaseJob> DownloadAsync(SignedReleaseJob job, IProgress<SignedReleaseProgress> progress, CancellationToken token)
    {
        progress.Report(new("download", "Downloading the exact signed artifact for this build…", RunUrl(job)));
        var artifactName = "foothold-manager-signed-" + job.Version;
        using var list = await ApiAsync("repos/" + Repository + "/actions/runs/" + job.RunId.ToString(CultureInfo.InvariantCulture) + "/artifacts?per_page=100", token).ConfigureAwait(false);
        var artifacts = list.RootElement.GetProperty("artifacts").EnumerateArray().Where(item => Text(item, "name") == artifactName).ToArray();
        if (artifacts.Length != 1 || artifacts[0].GetProperty("expired").GetBoolean()
            || Text(artifacts[0].GetProperty("workflow_run"), "head_sha") != job.CommitSha
            || artifacts[0].GetProperty("workflow_run").GetProperty("id").GetInt64() != job.RunId
            || artifacts[0].GetProperty("size_in_bytes").GetInt64() is <= 0 or > ManagerSelfUpdater.MaximumExecutableSize)
            throw new InvalidDataException("The exact unexpired signed artifact for this commit is missing or ambiguous.");
        Directory.CreateDirectory(job.OutputDirectory);
        var stage = Path.Combine(job.OutputDirectory, ".FootholdSignedRelease-" + Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(stage);
        try
        {
            await CommandAsync(["run", "download", job.RunId.ToString(CultureInfo.InvariantCulture), "--repo", "github.com/" + Repository,
                "--name", artifactName, "--dir", stage], token).ConfigureAwait(false);
            var exeName = "Foothold Config Manager " + job.Version + ".exe";
            var executable = Path.Combine(stage, exeName);
            var manifest = Path.Combine(stage, "release-result.json");
            if (Directory.EnumerateDirectories(stage, "*", SearchOption.AllDirectories).Any()
                || !Directory.EnumerateFiles(stage).Select(Path.GetFileName).Order().SequenceEqual(new[] { exeName, "release-result.json" }.Order()))
                throw new InvalidDataException("The signed artifact must contain exactly its versioned EXE and release-result.json.");
            var hash = ReadResultManifest(manifest, job);
            var stagedJob = job with { SignedExePath = executable, SignedSha256 = hash };
            progress.Report(new("verify", "Checking release identity, hash and trusted Foundation signature…", RunUrl(job)));
            await VerifyExecutableAsync(stagedJob, token).ConfigureAwait(false);
            var destination = Path.Combine(job.OutputDirectory, exeName);
            var resultPath = ResultPath(job);
            if (File.Exists(destination) || File.Exists(resultPath))
            {
                if (!File.Exists(destination) || !File.Exists(resultPath))
                    throw new IOException("The output folder contains an incomplete or different release. Choose an empty output folder; existing files are never overwritten.");
                // Stop watching may have arrived after the files were copied but before ready was persisted.
                // Recover only this exact commit/hash/signature; a different existing release is never replaced.
                var recovered = job with { SignedExePath = destination, SignedSha256 = hash };
                await VerifyReadyAsync(recovered, token).ConfigureAwait(false);
                _save(recovered);
                progress.Report(new("ready", "The existing exact signed release was reverified and recovered. Publishing remains a separate action.", RunUrl(recovered)));
                return recovered;
            }
            File.Copy(executable, destination, overwrite: false);
            try { File.Copy(manifest, resultPath, overwrite: false); }
            catch { File.Delete(destination); throw; }
            job = job with { SignedExePath = destination, SignedSha256 = hash };
            await VerifyReadyAsync(job, token).ConfigureAwait(false);
            _save(job);
            progress.Report(new("ready", "The signed release is verified and ready. Publish download is a separate action.", RunUrl(job)));
            return job;
        }
        finally { Directory.Delete(stage, recursive: true); }
    }

    private static string ResultPath(SignedReleaseJob job) => Path.Combine(job.OutputDirectory, "release-result-" + job.Version + ".json");
    private static string ReadResultManifest(string path, SignedReleaseJob job)
    {
        if ((File.GetAttributes(path) & FileAttributes.ReparsePoint) != 0 || new FileInfo(path).Length > 64 * 1024)
            throw new InvalidDataException("The release manifest is invalid.");
        using var document = JsonDocument.Parse(File.ReadAllText(path));
        var result = document.RootElement;
        var hash = Text(result, "sha256");
        if (Text(result, "version") != job.Version || Text(result, "sourceCommit") != job.CommitSha
            || Text(result, "fileName") != "Foothold Config Manager " + job.Version + ".exe" || Text(result, "buildMode") != "user"
            || !Regex.IsMatch(hash, @"\A[0-9a-fA-F]{64}\z", RegexOptions.CultureInvariant))
            throw new InvalidDataException("The signed artifact manifest does not match this release version, source commit, user mode and executable.");
        return hash.ToUpperInvariant();
    }

    private async Task VerifyExecutableAsync(SignedReleaseJob job, CancellationToken token)
    {
        if (job.SignedExePath is null || job.SignedSha256 is null || (File.GetAttributes(job.SignedExePath) & FileAttributes.ReparsePoint) != 0
            || new FileInfo(job.SignedExePath).Length is <= 0 or > ManagerSelfUpdater.MaximumExecutableSize)
            throw new InvalidDataException("A verified signed executable is required before this action.");
        using var locked = new FileStream(job.SignedExePath, FileMode.Open, FileAccess.Read, FileShare.Read);
        if (ManagerSelfUpdater.FileSha256(job.SignedExePath) != job.SignedSha256) throw new InvalidDataException("The signed executable hash changed.");
        await _verifier.VerifyAsync(job.SignedExePath, ReleaseVersion(job.Version), token).ConfigureAwait(false);
        token.ThrowIfCancellationRequested();
        if (ManagerSelfUpdater.FileSha256(job.SignedExePath) != job.SignedSha256) throw new InvalidDataException("The signed executable changed during signature verification.");
    }

    private async Task VerifyReadyAsync(SignedReleaseJob job, CancellationToken token)
    {
        ValidateJob(job);
        if (job.RunId <= 0 || job.SignedExePath is null || !ManagerSelfUpdater.SamePath(job.SignedExePath,
            Path.Combine(job.OutputDirectory, "Foothold Config Manager " + job.Version + ".exe"))
            || ReadResultManifest(ResultPath(job), job) != job.SignedSha256)
            throw new InvalidDataException("This job has no matching verified ready artifact.");
        await VerifyExecutableAsync(job, token).ConfigureAwait(false);
    }

    public async Task PublishAsync(SignedReleaseJob job, IProgress<SignedReleaseProgress> progress, CancellationToken cancellationToken)
    {
        progress.Report(new("verify", "Rechecking signed release identity before publishing…", RunUrl(job)));
        await VerifyReadyAsync(job, cancellationToken).ConfigureAwait(false);
        await CheckOwnerAsync(cancellationToken).ConfigureAwait(false);
        // Bind locally editable ready metadata back to the exact remote run artifact before publication.
        job = await ResumeAsync(job, progress, cancellationToken).ConfigureAwait(false);
        EnsureNewer(ReleaseVersion(job.Version), await ReadLatestAsync(cancellationToken).ConfigureAwait(false));
        using var run = await ApiAsync("repos/" + Repository + "/actions/runs/" + job.RunId.ToString(CultureInfo.InvariantCulture), cancellationToken).ConfigureAwait(false);
        ValidateRun(run.RootElement, job);
        if (Text(run.RootElement, "status") != "completed" || Text(run.RootElement, "conclusion") != "success")
            throw new InvalidOperationException("Only a successful exact signed build can be published.");
        using var locked = new FileStream(job.SignedExePath!, FileMode.Open, FileAccess.Read, FileShare.Read);
        var bytes = new byte[checked((int)locked.Length)];
        await locked.ReadExactlyAsync(bytes, cancellationToken).ConfigureAwait(false);
        if (Convert.ToHexString(SHA256.HashData(bytes)) != job.SignedSha256) throw new InvalidDataException("The release changed before publication.");
        var fileName = Path.GetFileName(job.SignedExePath!);
        var endpoint = "repos/" + Repository + "/contents/" + ManagerPath + Uri.EscapeDataString(fileName);
        var body = JsonSerializer.Serialize(new { message = "Publish signed Foothold Manager " + job.Version, branch = "main", content = Convert.ToBase64String(bytes) });
        progress.Report(new("publish", "Publishing only the new versioned EXE to the public Manager download folder…", RunUrl(job)));
        // Deliberately omit sha: GitHub refuses an existing path instead of overwriting any release.
        var result = await _runner.RunAsync("gh", ["api", "--hostname", "github.com", "--method", "PUT", endpoint, "--input", "-"], body,
            TimeSpan.FromMinutes(5), cancellationToken).ConfigureAwait(false);
        if (result.ExitCode != 0) throw new InvalidOperationException("GitHub refused publication. Existing releases are never overwritten; check the current public version and permissions.");
        using var response = JsonDocument.Parse(result.Output);
        using var gitHash = IncrementalHash.CreateHash(HashAlgorithmName.SHA1);
        gitHash.AppendData(Encoding.ASCII.GetBytes("blob " + bytes.Length.ToString(CultureInfo.InvariantCulture) + "\0"));
        gitHash.AppendData(bytes);
        if (!string.Equals(Text(response.RootElement.GetProperty("content"), "sha"), Convert.ToHexString(gitHash.GetHashAndReset()), StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException("GitHub publication did not confirm the exact verified executable blob. Check the public folder before retrying.");
        progress.Report(new("published", "The signed versioned EXE is now in the existing public Manager download folder.", RunUrl(job)));
    }
}
#endif
