using System.Diagnostics;
using System.Globalization;
using System.Net.Http.Headers;
using System.Security.AccessControl;
using System.Security.Cryptography;
using System.Security.Principal;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace FootholdConfigManager;

internal sealed record ManagerSelfUpdateCandidate(string Name, string Version, string GitBlobSha, long Size);

internal static partial class ManagerSelfUpdater
{
    internal const string HelperArgument = "--manager-update-helper";
    internal const long MaximumExecutableSize = 512L * 1024 * 1024;
    internal const string StagePrefix = ".FootholdManagerUpdate-";
    private const string RepositoryPath = "tools/FootholdConfigManager/";
    private static readonly HttpClient Client = new(new SocketsHttpHandler { AllowAutoRedirect = false })
    {
        Timeout = Timeout.InfiniteTimeSpan
    };

    public static Task<PreparedManagerUpdate> PrepareAsync(ManagerSelfUpdateCandidate candidate, CancellationToken cancellationToken)
    {
        return Task.Run(async () =>
        {
            if (!AppMode.IsExportedUserBuild)
                throw new InvalidOperationException("The admin/source Manager cannot install a public player update.");
            var version = ValidateCandidate(candidate);
            if (ManagerBuildInfo.ReleaseVersion is not { } localVersion || version <= localVersion)
                throw new InvalidOperationException("Only a newer public Manager version can be installed.");
            cancellationToken.ThrowIfCancellationRequested();
            var target = Path.GetFullPath(Environment.ProcessPath ?? throw new InvalidOperationException("The running Manager path is unavailable."));
            if (!target.EndsWith(".exe", StringComparison.OrdinalIgnoreCase) || new Uri(target).IsUnc)
                throw new InvalidOperationException("The running Manager must be a local executable.");
            var directory = Path.GetDirectoryName(target)!;
            PreflightDestination(target, directory);
            var stageId = Guid.NewGuid().ToString("N");
            var stage = Path.Combine(directory, StagePrefix + stageId);
            CreatePrivateDirectory(stage);
            try
            {
                var payload = Path.Combine(stage, "manager-update.exe");
                var downloadSha256 = await DownloadVerifiedAsync(Client, candidate, payload, cancellationToken).ConfigureAwait(false);
                cancellationToken.ThrowIfCancellationRequested();
                var originalSha256 = FileSha256(target);
                var helper = Path.Combine(stage, "update-helper.exe");
                AtomicFile.Copy(target, helper);
                if (FileSha256(helper) != originalSha256)
                    throw new InvalidDataException("The private update helper did not match the running Manager.");
                using var current = Process.GetCurrentProcess();
                var manifest = new ManagerUpdateManifest(stageId, target, current.Id, current.StartTime.ToUniversalTime().Ticks,
                    Path.GetFullPath(Environment.CurrentDirectory), ApprovedRestartArguments(Environment.GetCommandLineArgs().Skip(1)),
                    originalSha256, originalSha256, downloadSha256, candidate.GitBlobSha.ToLowerInvariant(), candidate.Size, 120, 120);
                AtomicFile.WriteUtf8Text(Path.Combine(stage, "update.json"), JsonSerializer.Serialize(manifest));
                return new PreparedManagerUpdate(stage, manifest);
            }
            catch
            {
                DeleteOwnedStage(stage);
                throw;
            }
        }, cancellationToken);
    }

    // The injected client is only a transport seam for disposable tests; production owns a no-redirect client.
    internal static async Task<string> DownloadVerifiedAsync(HttpClient client, ManagerSelfUpdateCandidate candidate,
        string destination, CancellationToken cancellationToken)
    {
        ValidateCandidate(candidate);
        cancellationToken.ThrowIfCancellationRequested();
        var escapedName = Uri.EscapeDataString(candidate.Name);
        var metadataUri = new Uri("https://api.github.com/repos/leka1986/Lekas-Foothold/contents/" + RepositoryPath + escapedName + "?ref=main");
        var downloadUri = new Uri("https://raw.githubusercontent.com/leka1986/Lekas-Foothold/main/" + RepositoryPath + escapedName);
        using (var timeout = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken))
        {
            timeout.CancelAfter(TimeSpan.FromSeconds(8));
            using var request = CreateRequest(metadataUri, "application/vnd.github.object+json");
            using var response = await client.SendAsync(request, HttpCompletionOption.ResponseHeadersRead, timeout.Token).ConfigureAwait(false);
            RequireDirectResponse(response, metadataUri);
            var json = await ReadBoundedAsync(response.Content, 64 * 1024, timeout.Token).ConfigureAwait(false);
            try
            {
                using var document = JsonDocument.Parse(json);
                var entry = document.RootElement;
                if (entry.GetProperty("type").GetString() != "file" || entry.GetProperty("name").GetString() != candidate.Name ||
                    entry.GetProperty("path").GetString() != RepositoryPath + candidate.Name ||
                    !string.Equals(entry.GetProperty("sha").GetString(), candidate.GitBlobSha, StringComparison.OrdinalIgnoreCase) ||
                    entry.GetProperty("size").GetInt64() != candidate.Size ||
                    !Uri.TryCreate(entry.GetProperty("download_url").GetString(), UriKind.Absolute, out var returnedUri) ||
                    returnedUri != downloadUri)
                    throw new InvalidDataException("The public Manager file changed. Check again before updating.");
            }
            catch (Exception error) when (error is JsonException or KeyNotFoundException or InvalidOperationException or FormatException)
            {
                throw new InvalidDataException("The public Manager metadata was invalid.", error);
            }
        }
        var ownsDestination = false;
        using var downloadTimeout = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        downloadTimeout.CancelAfter(TimeSpan.FromMinutes(5));
        try
        {
            using var request = CreateRequest(downloadUri, "application/octet-stream");
            using var response = await client.SendAsync(request, HttpCompletionOption.ResponseHeadersRead, downloadTimeout.Token).ConfigureAwait(false);
            RequireDirectResponse(response, downloadUri);
            if (response.Content.Headers.ContentLength is { } length && length != candidate.Size)
                throw new InvalidDataException("The Manager download size did not match its public metadata.");
            using var blobHash = IncrementalHash.CreateHash(HashAlgorithmName.SHA1);
            using var stageHash = IncrementalHash.CreateHash(HashAlgorithmName.SHA256);
            blobHash.AppendData(Encoding.ASCII.GetBytes("blob " + candidate.Size.ToString(CultureInfo.InvariantCulture) + "\0"));
            await using (var source = await response.Content.ReadAsStreamAsync(downloadTimeout.Token).ConfigureAwait(false))
            await using (var output = new FileStream(destination, FileMode.CreateNew, FileAccess.Write, FileShare.None, 64 * 1024, FileOptions.Asynchronous | FileOptions.SequentialScan))
            {
                ownsDestination = true;
                var buffer = new byte[64 * 1024];
                long count = 0;
                int read;
                while ((read = await source.ReadAsync(buffer, downloadTimeout.Token).ConfigureAwait(false)) != 0)
                {
                    count += read;
                    if (count > candidate.Size || count > MaximumExecutableSize)
                        throw new InvalidDataException("The Manager download exceeded its declared size.");
                    blobHash.AppendData(buffer, 0, read);
                    stageHash.AppendData(buffer, 0, read);
                    await output.WriteAsync(buffer.AsMemory(0, read), downloadTimeout.Token).ConfigureAwait(false);
                }
                if (count != candidate.Size || !string.Equals(Convert.ToHexString(blobHash.GetHashAndReset()), candidate.GitBlobSha, StringComparison.OrdinalIgnoreCase))
                    throw new InvalidDataException("The Manager download did not match its public Git blob identity.");
                await output.FlushAsync(downloadTimeout.Token).ConfigureAwait(false);
                output.Flush(flushToDisk: true);
            }
            ValidateExecutable(destination);
            return Convert.ToHexString(stageHash.GetHashAndReset());
        }
        catch
        {
            if (ownsDestination && File.Exists(destination)) File.Delete(destination);
            throw;
        }
    }

    private static Version ValidateCandidate(ManagerSelfUpdateCandidate candidate)
    {
        if (!Regex.IsMatch(candidate.Name, @"\AFoothold Config Manager ([0-9]+\.[0-9]+\.[0-9]+(?:\.[0-9]+)?)\.exe\z", RegexOptions.CultureInvariant) ||
            !ManagerBuildInfo.TryParseReleaseVersion(candidate.Version, out var chosenVersion) ||
            !ManagerBuildInfo.TryParseReleaseVersion(candidate.Name[24..^4], out var fileVersion) || chosenVersion != fileVersion ||
            !Regex.IsMatch(candidate.GitBlobSha, @"\A[0-9a-fA-F]{40}\z", RegexOptions.CultureInvariant) ||
            candidate.Size < 128 || candidate.Size > MaximumExecutableSize)
            throw new InvalidDataException("The selected public Manager file is invalid.");
        return chosenVersion;
    }

    private static HttpRequestMessage CreateRequest(Uri uri, string mediaType)
    {
        var request = new HttpRequestMessage(HttpMethod.Get, uri);
        request.Headers.UserAgent.ParseAdd("FootholdConfigManager-Updater/1.0");
        request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue(mediaType));
        request.Headers.CacheControl = new CacheControlHeaderValue { NoCache = true, NoStore = true };
        return request;
    }

    private static void RequireDirectResponse(HttpResponseMessage response, Uri expectedUri)
    {
        response.EnsureSuccessStatusCode();
        if (response.RequestMessage?.RequestUri != expectedUri)
            throw new InvalidDataException("The update request left its trusted repository URL.");
    }

    private static async Task<byte[]> ReadBoundedAsync(HttpContent content, int maximum, CancellationToken cancellationToken)
    {
        if (content.Headers.ContentLength > maximum) throw new InvalidDataException("The update metadata was too large.");
        await using var source = await content.ReadAsStreamAsync(cancellationToken).ConfigureAwait(false);
        using var output = new MemoryStream();
        var buffer = new byte[8192];
        int read;
        while ((read = await source.ReadAsync(buffer, cancellationToken).ConfigureAwait(false)) != 0)
        {
            if (output.Length + read > maximum) throw new InvalidDataException("The update metadata was too large.");
            output.Write(buffer, 0, read);
        }
        return output.ToArray();
    }

    private static void PreflightDestination(string target, string directory)
    {
        if ((File.GetAttributes(target) & FileAttributes.ReadOnly) != 0)
            throw new UnauthorizedAccessException("The running Manager is read-only. Move it to a writable folder before updating.");
        var probe = Path.Combine(directory, ".FootholdManagerWrite-" + Guid.NewGuid().ToString("N"));
        using var stream = new FileStream(probe, FileMode.CreateNew, FileAccess.Write, FileShare.None, 1, FileOptions.DeleteOnClose);
        stream.WriteByte(0);
        stream.Flush(flushToDisk: true);
    }

    private static void CreatePrivateDirectory(string path)
    {
        if (Directory.Exists(path)) throw new IOException("The private update stage already exists.");
        var user = WindowsIdentity.GetCurrent().User ?? throw new InvalidOperationException("The current Windows user is unavailable.");
        var security = new DirectorySecurity();
        security.SetAccessRuleProtection(isProtected: true, preserveInheritance: false);
        security.SetOwner(user);
        security.AddAccessRule(new FileSystemAccessRule(user, FileSystemRights.FullControl,
            InheritanceFlags.ContainerInherit | InheritanceFlags.ObjectInherit, PropagationFlags.None, AccessControlType.Allow));
        new DirectoryInfo(path).Create(security);
    }

    internal static string[] ApprovedRestartArguments(IEnumerable<string> arguments) =>
        arguments.Where(argument => argument.Equals("--normal-data", StringComparison.OrdinalIgnoreCase)).Take(1).ToArray();

    internal static string FileSha256(string path)
    {
        using var stream = File.OpenRead(path);
        return Convert.ToHexString(SHA256.HashData(stream));
    }

    private static void ValidateExecutable(string path)
    {
        using var stream = File.OpenRead(path);
        using var reader = new BinaryReader(stream);
        if (stream.Length < 128 || reader.ReadUInt16() != 0x5A4D)
            throw new InvalidDataException("The verified download is not a Windows executable.");
        stream.Position = 60;
        var signatureOffset = reader.ReadInt32();
        if (signatureOffset < 64 || signatureOffset > stream.Length - 4)
            throw new InvalidDataException("The downloaded executable header is invalid.");
        stream.Position = signatureOffset;
        if (reader.ReadUInt32() != 0x00004550)
            throw new InvalidDataException("The downloaded executable header is invalid.");
    }

    internal static void DeleteOwnedStage(string stage)
    {
        var name = Path.GetFileName(stage);
        if (name.StartsWith(StagePrefix, StringComparison.Ordinal) && Guid.TryParseExact(name[StagePrefix.Length..], "N", out _) &&
            Directory.Exists(stage) && (File.GetAttributes(stage) & FileAttributes.ReparsePoint) == 0)
        {
            try { Directory.Delete(stage, recursive: true); }
            catch (Exception error) when (error is IOException or UnauthorizedAccessException) { }
        }
    }
}
internal sealed record ManagerUpdateManifest(string StageId, string TargetPath, int ParentProcessId, long ParentStartUtcTicks,
    string WorkingDirectory, string[] RestartArguments, string OriginalSha256, string HelperSha256, string DownloadSha256,
    string GitBlobSha, long DownloadSize, int AuthorizationTimeoutSeconds, int ParentExitTimeoutSeconds);

internal sealed record ManagerUpdateRecoveryResult(bool Success, bool Cancelled, string Message, string TargetPath, string BackupPath);

internal static partial class ManagerSelfUpdater
{
    public static bool TryRunHelper(string[] args, out int exitCode)
    {
        exitCode = 64;
        if (args.Length == 0 || !args[0].Equals(HelperArgument, StringComparison.OrdinalIgnoreCase)) return false;
        // Deliberately before all startup/settings code. The admin assembly never reads a helper manifest.
        if (!AppMode.IsExportedUserBuild || args.Length != 2) return true;
        ManagerUpdateRecoveryResult result;
        try { result = RunHelperCore(args[1]); }
        catch (Exception error) when (error is IOException or UnauthorizedAccessException or InvalidDataException or ArgumentException or
            InvalidOperationException or System.ComponentModel.Win32Exception or System.Security.SecurityException or WaitHandleCannotBeOpenedException)
        {
            result = new(false, false, "The Manager update was not installed. " + error.Message, "", "");
        }
        exitCode = result.Success ? 0 : result.Cancelled ? 2 : 3;
        if (!result.Success && !result.Cancelled)
            MessageBox.Show(result.Message, "Foothold Config Manager update", MessageBoxButtons.OK, MessageBoxIcon.Error);
        return true;
    }

    internal static ManagerUpdateRecoveryResult RunHelperCore(string manifestPath)
    {
        if (!AppMode.IsExportedUserBuild)
            throw new InvalidOperationException("Only a player build can run the update helper.");
        var manifest = ReadHelperManifest(manifestPath, out var stage);
        var backup = Path.Combine(stage, "previous-manager.exe");
        ManagerUpdateRecoveryResult result;
        var replaced = false;
        try
        {
            using var parent = Process.GetProcessById(manifest.ParentProcessId);
            // Holding this process handle distinguishes exit of the original process from PID reuse/absence.
            _ = parent.SafeHandle;
            if (parent.StartTime.ToUniversalTime().Ticks != manifest.ParentStartUtcTicks ||
                !SamePath(parent.MainModule!.FileName, manifest.TargetPath))
                throw new InvalidDataException("The original Manager process identity no longer matches.");
            using var authorization = EventWaitHandle.OpenExisting(EventName(manifest.StageId, "authorize"));
            using var cancellation = EventWaitHandle.OpenExisting(EventName(manifest.StageId, "cancel"));
            using var ready = EventWaitHandle.OpenExisting(EventName(manifest.StageId, "ready"));
            if (FileSha256(manifest.TargetPath) != manifest.OriginalSha256 ||
                FileSha256(Path.Combine(stage, "update-helper.exe")) != manifest.HelperSha256 ||
                manifest.HelperSha256 != manifest.OriginalSha256)
                throw new InvalidDataException("The running Manager or its helper changed before updating.");
            VerifyStagedPayload(Path.Combine(stage, "manager-update.exe"), manifest);
            ready.Set();
            var signal = WaitHandle.WaitAny(new WaitHandle[] { cancellation, authorization }, TimeSpan.FromSeconds(manifest.AuthorizationTimeoutSeconds));
            if (signal == 0)
                result = new(false, true, "The Manager update was cancelled. The original executable was kept.", manifest.TargetPath, backup);
            else if (signal == WaitHandle.WaitTimeout)
                result = new(false, false, "The Manager update timed out waiting for close authorization. The original executable was kept.", manifest.TargetPath, backup);
            else if (!parent.WaitForExit(manifest.ParentExitTimeoutSeconds * 1000))
                result = new(false, false, "The Manager did not exit in time. The original executable was kept.", manifest.TargetPath, backup);
            else
            {
                if (FileSha256(manifest.TargetPath) != manifest.OriginalSha256)
                    throw new InvalidDataException("The original executable changed after the update was prepared.");
                // Recheck after waiting: nothing unverified is moved or executed.
                VerifyStagedPayload(Path.Combine(stage, "manager-update.exe"), manifest);
                File.Replace(Path.Combine(stage, "manager-update.exe"), manifest.TargetPath, backup, ignoreMetadataErrors: true);
                replaced = true;
                using var restartReadLock = new FileStream(manifest.TargetPath, FileMode.Open, FileAccess.Read, FileShare.Read);
                VerifyStagedPayload(manifest.TargetPath, manifest);
                var start = new ProcessStartInfo(manifest.TargetPath) { UseShellExecute = false, WorkingDirectory = manifest.WorkingDirectory };
                foreach (var argument in manifest.RestartArguments) start.ArgumentList.Add(argument);
                using var restarted = Process.Start(start) ?? throw new IOException("Windows did not start the updated Manager.");
                result = new(true, false, "The Manager was updated at its existing path. The prior executable is retained at " + backup,
                    manifest.TargetPath, backup);
            }
        }
        catch (Exception error) when (error is IOException or UnauthorizedAccessException or InvalidDataException or ArgumentException or
            InvalidOperationException or System.ComponentModel.Win32Exception or System.Security.SecurityException or WaitHandleCannotBeOpenedException)
        {
            var recovery = replaced || File.Exists(backup) ? RestorePreviousExecutable(manifest, backup) : "The original executable was kept.";
            result = new(false, false, "The Manager update failed. " + error.Message + Environment.NewLine + recovery +
                Environment.NewLine + "Recovery files: " + stage, manifest.TargetPath, backup);
        }
        AtomicFile.WriteUtf8Text(Path.Combine(stage, "recovery-result.json"), JsonSerializer.Serialize(result));
        return result;
    }

    internal static ManagerUpdateManifest ReadHelperManifest(string manifestPath, out string stage)
    {
        var fullPath = Path.GetFullPath(manifestPath);
        stage = Path.GetDirectoryName(fullPath) ?? throw new InvalidDataException("The update stage is missing.");
        var name = Path.GetFileName(stage);
        if (!name.StartsWith(StagePrefix, StringComparison.Ordinal) || !Guid.TryParseExact(name[StagePrefix.Length..], "N", out _) ||
            !SamePath(fullPath, Path.Combine(stage, "update.json")) ||
            !SamePath(Environment.ProcessPath!, Path.Combine(stage, "update-helper.exe")) ||
            (File.GetAttributes(stage) & FileAttributes.ReparsePoint) != 0 || new FileInfo(fullPath).Length > 64 * 1024)
            throw new InvalidDataException("The helper was not started from its private update stage.");
        foreach (var file in new[] { fullPath, Path.Combine(stage, "update-helper.exe"), Path.Combine(stage, "manager-update.exe") })
            if ((File.GetAttributes(file) & FileAttributes.ReparsePoint) != 0)
                throw new InvalidDataException("Update files cannot be links.");
        ManagerUpdateManifest manifest;
        try { manifest = JsonSerializer.Deserialize<ManagerUpdateManifest>(File.ReadAllText(fullPath)) ?? throw new InvalidDataException("The update manifest is empty."); }
        catch (JsonException error) { throw new InvalidDataException("The update manifest is invalid.", error); }
        if (manifest.StageId != name[StagePrefix.Length..] || !Path.IsPathFullyQualified(manifest.TargetPath) ||
            !SamePath(Path.GetDirectoryName(manifest.TargetPath)!, Path.GetDirectoryName(stage)!) ||
            !manifest.TargetPath.EndsWith(".exe", StringComparison.OrdinalIgnoreCase) || new Uri(manifest.TargetPath).IsUnc ||
            SamePath(manifest.TargetPath, Path.Combine(stage, "update-helper.exe")) ||
            manifest.ParentProcessId <= 0 || manifest.ParentStartUtcTicks <= 0 ||
            !Path.IsPathFullyQualified(manifest.WorkingDirectory) || !Directory.Exists(manifest.WorkingDirectory) ||
            manifest.RestartArguments is null || !manifest.RestartArguments.SequenceEqual(ApprovedRestartArguments(manifest.RestartArguments)) ||
            !IsSha256(manifest.OriginalSha256) || !IsSha256(manifest.HelperSha256) || !IsSha256(manifest.DownloadSha256) ||
            !Regex.IsMatch(manifest.GitBlobSha ?? "", @"\A[0-9a-f]{40}\z", RegexOptions.CultureInvariant) ||
            manifest.DownloadSize < 128 || manifest.DownloadSize > MaximumExecutableSize ||
            manifest.AuthorizationTimeoutSeconds is < 1 or > 120 || manifest.ParentExitTimeoutSeconds is < 1 or > 120)
            throw new InvalidDataException("The update manifest does not identify an approved same-path player update.");
        return manifest;
    }

    private static void VerifyStagedPayload(string path, ManagerUpdateManifest manifest)
    {
        if ((File.GetAttributes(path) & FileAttributes.ReparsePoint) != 0)
            throw new InvalidDataException("The verified executable cannot be a link.");
        using var source = File.OpenRead(path);
        if (source.Length != manifest.DownloadSize || Convert.ToHexString(SHA256.HashData(source)) != manifest.DownloadSha256)
            throw new InvalidDataException("The staged update changed after download verification.");
        source.Position = 0;
        using var hash = IncrementalHash.CreateHash(HashAlgorithmName.SHA1);
        hash.AppendData(Encoding.ASCII.GetBytes("blob " + manifest.DownloadSize.ToString(CultureInfo.InvariantCulture) + "\0"));
        var buffer = new byte[64 * 1024];
        int read;
        while ((read = source.Read(buffer, 0, buffer.Length)) != 0) hash.AppendData(buffer, 0, read);
        if (!string.Equals(Convert.ToHexString(hash.GetHashAndReset()), manifest.GitBlobSha, StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException("The staged Git blob identity changed.");
        ValidateExecutable(path);
    }

    private static string RestorePreviousExecutable(ManagerUpdateManifest manifest, string backup)
    {
        try
        {
            if (FileSha256(backup) != manifest.OriginalSha256)
                return "Automatic recovery was refused because the backup identity changed. Recovery backup: " + backup;
            if (File.Exists(manifest.TargetPath)) File.Replace(backup, manifest.TargetPath, destinationBackupFileName: null, ignoreMetadataErrors: true);
            else File.Move(backup, manifest.TargetPath);
            return FileSha256(manifest.TargetPath) == manifest.OriginalSha256
                ? "The previous executable was restored. Start it again at " + manifest.TargetPath
                : "Recovery could not be verified. Recovery backup: " + backup;
        }
        catch (Exception error) when (error is IOException or UnauthorizedAccessException)
        {
            return "Automatic recovery failed: " + error.Message + ". Keep the recovery backup at " + backup;
        }
    }

    private static bool IsSha256(string? value) => Regex.IsMatch(value ?? "", @"\A[0-9A-F]{64}\z", RegexOptions.CultureInvariant);
    internal static bool SamePath(string left, string right) => string.Equals(Path.GetFullPath(left), Path.GetFullPath(right), StringComparison.OrdinalIgnoreCase);
    internal static string EventName(string stageId, string purpose) => @"Local\FootholdManagerUpdate-" + stageId + "-" + purpose;
}

internal sealed class PreparedManagerUpdate : IDisposable
{
    private readonly ManagerUpdateManifest _manifest;
    private readonly EventWaitHandle _authorization;
    private readonly EventWaitHandle _cancellation;
    private readonly EventWaitHandle _ready;
    private Process? _helper;
    private bool _authorized;
    private bool _disposed;
    public string StagingDirectory { get; }
    public string RecoveryResultPath => Path.Combine(StagingDirectory, "recovery-result.json");

    internal PreparedManagerUpdate(string stage, ManagerUpdateManifest manifest)
    {
        StagingDirectory = stage;
        _manifest = manifest;
        _authorization = CreateSignal(manifest.StageId, "authorize");
        try
        {
            _cancellation = CreateSignal(manifest.StageId, "cancel");
            try { _ready = CreateSignal(manifest.StageId, "ready"); }
            catch { _cancellation.Dispose(); throw; }
        }
        catch { _authorization.Dispose(); throw; }
    }

    public async Task StartHelperAsync(CancellationToken cancellationToken)
    {
        ObjectDisposedException.ThrowIf(_disposed, this);
        if (_helper is not null) throw new InvalidOperationException("The update helper has already been started.");
        try
        {
            cancellationToken.ThrowIfCancellationRequested();
            var start = new ProcessStartInfo(Path.Combine(StagingDirectory, "update-helper.exe"))
            {
                UseShellExecute = false, CreateNoWindow = true, WorkingDirectory = StagingDirectory
            };
            start.ArgumentList.Add(ManagerSelfUpdater.HelperArgument);
            start.ArgumentList.Add(Path.Combine(StagingDirectory, "update.json"));
            using (var helperReadLock = await Task.Run(() =>
            {
                if ((File.GetAttributes(StagingDirectory) & FileAttributes.ReparsePoint) != 0 ||
                    (File.GetAttributes(start.FileName) & FileAttributes.ReparsePoint) != 0)
                    throw new InvalidDataException("The private update helper cannot be a link.");
                var locked = new FileStream(start.FileName, FileMode.Open, FileAccess.Read, FileShare.Read);
                try
                {
                    if (Convert.ToHexString(SHA256.HashData(locked)) != _manifest.HelperSha256 ||
                        File.ReadAllText(Path.Combine(StagingDirectory, "update.json")) != JsonSerializer.Serialize(_manifest))
                        throw new InvalidDataException("The private update helper or manifest changed before launch.");
                    return locked;
                }
                catch { locked.Dispose(); throw; }
            }, cancellationToken).ConfigureAwait(false))
            {
                cancellationToken.ThrowIfCancellationRequested();
                _helper = Process.Start(start) ?? throw new IOException("The private update helper could not be started.");
            }
            var ready = await Task.Run(() => WaitHandle.WaitAny(new WaitHandle[] { _ready, cancellationToken.WaitHandle }, TimeSpan.FromSeconds(15)), CancellationToken.None).ConfigureAwait(false);
            cancellationToken.ThrowIfCancellationRequested();
            if (ready != 0 || _helper.HasExited)
                throw new IOException("The update helper was not ready. The running Manager was kept open.");
        }
        catch { Dispose(); throw; }
    }

    // The owner must call this only from the actual, uncancelled FormClosed event.
    public void AuthorizeAfterFormClosed()
    {
        ObjectDisposedException.ThrowIf(_disposed, this);
        if (_helper is null || _helper.HasExited || !_ready.WaitOne(0))
            throw new InvalidOperationException("The update helper is no longer waiting. The original Manager was kept.");
        _authorization.Set();
        _authorized = true;
    }

    public void Dispose()
    {
        if (_disposed) return;
        _disposed = true;
        if (!_authorized)
        {
            _cancellation.Set();
            if (_helper is not null && !_helper.HasExited)
            {
                try { _helper.Kill(); _helper.WaitForExit(1000); }
                catch (Exception error) when (error is InvalidOperationException or System.ComponentModel.Win32Exception) { }
            }
        }
        _helper?.Dispose();
        _authorization.Dispose();
        _cancellation.Dispose();
        _ready.Dispose();
        if (!_authorized) ManagerSelfUpdater.DeleteOwnedStage(StagingDirectory);
    }

    private static EventWaitHandle CreateSignal(string stageId, string purpose)
    {
        var signal = new EventWaitHandle(false, EventResetMode.ManualReset, ManagerSelfUpdater.EventName(stageId, purpose), out var createdNew);
        if (createdNew) return signal;
        signal.Dispose();
        throw new IOException("An update authorization signal already exists. Prepare the update again.");
    }
}