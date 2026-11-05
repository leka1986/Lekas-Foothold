using System.IO.Compression;
using System.Net;
using System.Security.Cryptography;

namespace FootholdConfigManager;

internal sealed record MissionPackageLimits(int Entries, long MizBytes, long MemberBytes, long ExpandedBytes)
{
    public long CapturedBytes { get; init; } = 256L * 1024 * 1024;
    public long StagedBytes { get; init; } = 2L * 1024 * 1024 * 1024;
    internal static readonly MissionPackageLimits Default = new(4096, 512L * 1024 * 1024, 512L * 1024 * 1024, 2L * 1024 * 1024 * 1024);
}

// One instance owns one job's private staging cache. It never owns an install destination.
internal sealed class MissionDownloadService : IDisposable
{
    private static readonly HttpClient Client = new(new SocketsHttpHandler { AllowAutoRedirect = false })
        { Timeout = Timeout.InfiniteTimeSpan };
    private readonly HttpClient _client;
    private readonly string _stageParent;
    private readonly MissionPackageLimits _limits;
    private PreparedMissionDownload? _prepared;
    private (long Id, string Tag)? _release;
    private bool _disposed;
    private bool _preparing;
    internal IReadOnlyList<string> CleanupWarnings => _prepared?.CleanupWarnings ?? Array.Empty<string>();

    internal MissionDownloadService() : this(Client, Path.Combine(Path.GetTempPath(), "Foothold-MissionDownloads")) { }
    internal MissionDownloadService(HttpClient client, string stageParent) : this(client, stageParent, MissionPackageLimits.Default) { }
    internal MissionDownloadService(HttpClient client, string stageParent, MissionPackageLimits limits)
    {
        var max = MissionPackageLimits.Default;
        if (limits.Entries is <= 0 || limits.Entries > max.Entries || limits.MizBytes is <= 0 || limits.MizBytes > max.MizBytes
            || limits.MemberBytes is <= 0 || limits.MemberBytes > max.MemberBytes || limits.ExpandedBytes is <= 0 || limits.ExpandedBytes > max.ExpandedBytes
            || limits.CapturedBytes is <= 0 || limits.CapturedBytes > max.CapturedBytes
            || limits.StagedBytes is <= 0 || limits.StagedBytes > max.StagedBytes)
            throw new ArgumentOutOfRangeException(nameof(limits));
        _client = client;
        _stageParent = Path.GetFullPath(stageParent);
        _limits = limits;
    }

    internal async Task<PreparedMissionDownload> PrepareAsync(FootholdReleaseInfo release,
        IReadOnlyList<MissionReleaseAsset> assets, IProgress<LoadingProgress> progress, CancellationToken token)
    {
        ObjectDisposedException.ThrowIf(_disposed, this);
        if (_preparing) throw new InvalidOperationException("A mission preparation is already running.");
        token.ThrowIfCancellationRequested();
        var selected = assets.ToArray();
        if (selected.Length is 0 or > 512 || selected.Select(a => a.Id).Distinct().Count() != selected.Length
            || selected.Any(a => !GitHubUpdateChecker.IsValidReleaseAsset(a, release.Tag) || !release.Assets.Contains(a)))
            throw new InvalidDataException("Choose ZIP assets from the selected Foothold release.");
        _preparing = true;
        try
        {
            if (_release != (release.Id, release.Tag) || _prepared is { IsDisposed: true })
            {
                _prepared?.Dispose();
                if (_prepared is not null && Directory.Exists(_prepared.StageDirectory))
                    throw new IOException("The previous temporary download folder is still in use. Close its reader and try again: " + _prepared.StageDirectory);
                _prepared = null;
            }
            if (_prepared is null)
            {
                var stage = Path.Combine(_stageParent, Guid.NewGuid().ToString("N"));
                Directory.CreateDirectory(stage);
                _prepared = new PreparedMissionDownload(stage, _limits);
                _release = (release.Id, release.Tag);
            }
            _prepared.Templates = [];
            for (var index = 0; index < selected.Length; index++)
            {
                var asset = selected[index];
                token.ThrowIfCancellationRequested();
                if (_prepared.Packages.TryGetValue(asset.Id, out var cached) && cached.Asset == asset
                    && !_prepared.InvalidatedPackageIds.Contains(asset.Id))
                {
                    progress.Report(new LoadingProgress("Using prepared " + asset.Name + "…", index + 1, selected.Length));
                    continue;
                }
                progress.Report(new LoadingProgress("Downloading " + asset.Name + "…", index, selected.Length));
                var directory = Path.Combine(_prepared.StageDirectory, Guid.NewGuid().ToString("N"));
                Directory.CreateDirectory(directory);
                var capturedBefore = _prepared.CapturedBytes;
                var stagedBefore = _prepared.StagedBytes;
                try
                {
                    _prepared.ReserveStagedBytes(asset.Size);
                    var zipPath = Path.Combine(directory, "package.zip");
                    var downloadedHash = await DownloadAsync(asset, zipPath, token).ConfigureAwait(false);
                    progress.Report(new LoadingProgress("Inspecting " + asset.Name + "…", index, selected.Length));
                    var package = (await Task.Run(() => InspectPackage(asset, zipPath, directory, _prepared, token), token).ConfigureAwait(false))
                        with { Sha256 = downloadedHash, CapturedBytes = _prepared.CapturedBytes - capturedBefore,
                            StagedBytes = _prepared.StagedBytes - stagedBefore };
                    if (cached is not null && _prepared.TryDeleteDirectory(Path.GetDirectoryName(cached.ZipPath)!))
                        _prepared.StagedBytes -= cached.StagedBytes;
                    _prepared.Packages[asset.Id] = package;
                    if (cached is not null) _prepared.CapturedBytes -= cached.CapturedBytes;
                    _prepared.InvalidatedPackageIds.Remove(asset.Id);
                }
                catch
                {
                    _prepared.CapturedBytes = capturedBefore;
                    if (_prepared.TryDeleteDirectory(directory)) _prepared.StagedBytes = stagedBefore;
                    throw;
                }
            }
            _prepared.Templates = Array.AsReadOnly(selected.SelectMany(a => _prepared.Packages[a.Id].Templates).ToArray());
            progress.Report(new LoadingProgress("Missions ready for review.", selected.Length, selected.Length));
            return _prepared;
        }
        finally { _preparing = false; }
    }

    internal static Uri ReviewReleaseAssetRedirect(Uri original, Uri current, Uri? location, int redirects)
    {
        if (redirects >= 3 || location is null) throw new InvalidDataException("The mission download redirected too many times.");
        var next = location.IsAbsoluteUri ? location : new Uri(current, location);
        if (next.Scheme != Uri.UriSchemeHttps || !next.IsDefaultPort || next.UserInfo.Length != 0 || next.Fragment.Length != 0
            || !(next == original || next.Host is "release-assets.githubusercontent.com" or "objects.githubusercontent.com"))
            throw new InvalidDataException("The mission download left GitHub's release asset hosts.");
        return next;
    }

    private Task<string> DownloadAsync(MissionReleaseAsset asset, string destination, CancellationToken token)
        => DownloadAsync(asset.DownloadUri, asset.Size, asset.Sha256, destination, token);

    internal async Task<string> DownloadAsync(Uri downloadUri, long expectedLength, string? expectedDigest, string destination, CancellationToken token)
    {
        using var timeout = CancellationTokenSource.CreateLinkedTokenSource(token);
        timeout.CancelAfter(TimeSpan.FromMinutes(15));
        var uri = downloadUri;
        for (var redirects = 0; ; redirects++)
        {
            using var request = new HttpRequestMessage(HttpMethod.Get, uri);
            request.Headers.UserAgent.ParseAdd("FootholdConfigManager-Missions/1.0");
            request.Headers.Accept.ParseAdd("application/octet-stream");
            using var response = await _client.SendAsync(request, HttpCompletionOption.ResponseHeadersRead, timeout.Token).ConfigureAwait(false);
            if (response.RequestMessage?.RequestUri != uri)
                throw new InvalidDataException("The download transport followed an unreviewed redirect.");
            if (response.StatusCode is HttpStatusCode.MovedPermanently or HttpStatusCode.Found or HttpStatusCode.SeeOther
                or HttpStatusCode.TemporaryRedirect or HttpStatusCode.PermanentRedirect)
            {
                uri = ReviewReleaseAssetRedirect(downloadUri, uri, response.Headers.Location, redirects);
                continue;
            }
            response.EnsureSuccessStatusCode();
            if (response.Content.Headers.ContentLength is { } length && length != expectedLength)
                throw new InvalidDataException("The mission download size differs from its release metadata.");
            using var hash = IncrementalHash.CreateHash(HashAlgorithmName.SHA256);
            await using var input = await response.Content.ReadAsStreamAsync(timeout.Token).ConfigureAwait(false);
            await using var output = new FileStream(destination, FileMode.CreateNew, FileAccess.Write, FileShare.None, 65536,
                FileOptions.Asynchronous | FileOptions.SequentialScan);
            var buffer = new byte[65536];
            long count = 0;
            int read;
            while ((read = await input.ReadAsync(buffer, timeout.Token).ConfigureAwait(false)) != 0)
            {
                count += read;
                if (count > expectedLength || count > MissionReleaseAsset.MaximumSize)
                    throw new InvalidDataException("The mission download exceeded its declared size.");
                hash.AppendData(buffer, 0, read);
                await output.WriteAsync(buffer.AsMemory(0, read), timeout.Token).ConfigureAwait(false);
            }
            var downloadedHash = Convert.ToHexString(hash.GetHashAndReset());
            if (count != expectedLength || expectedDigest is { } digest
                && !downloadedHash.Equals(digest, StringComparison.OrdinalIgnoreCase))
                throw new InvalidDataException("The mission download did not match its release size or SHA-256 digest.");
            await output.FlushAsync(timeout.Token).ConfigureAwait(false);
            return downloadedHash;
        }
    }

    private PreparedMissionPackage InspectPackage(MissionReleaseAsset asset, string zipPath, string directory, PreparedMissionDownload prepared, CancellationToken token)
    {
        using var zip = ZipFile.OpenRead(zipPath);
        CheckNames(zip);
        var candidates = zip.Entries.Where(e => e.FullName.EndsWith(".miz", StringComparison.OrdinalIgnoreCase)).ToArray();
        if (candidates.Length == 0) throw new InvalidDataException("This ZIP contains no MIZ missions.");
        var templates = new List<PreparedMissionTemplate>();
        foreach (var entry in candidates)
        {
            token.ThrowIfCancellationRequested();
            if (entry.Length > _limits.MizBytes) throw new InvalidDataException("A downloaded MIZ exceeds the supported size.");
            var path = Path.Combine(directory, "mission-" + templates.Count.ToString(System.Globalization.CultureInfo.InvariantCulture) + ".miz");
            prepared.ReserveStagedBytes(entry.Length);
            using (var input = entry.Open())
            using (var output = new FileStream(path, FileMode.CreateNew, FileAccess.Write))
                CopyBounded(input, output, entry.Length, _limits.MizBytes, entry.Crc32, token);
            templates.Add(InspectTemplate(path, Path.GetFileName(entry.FullName), asset, prepared, token));
        }
        return new PreparedMissionPackage(asset, zipPath, Array.AsReadOnly(templates.ToArray()));
    }

    private PreparedMissionTemplate InspectTemplate(string path, string name, MissionReleaseAsset asset, PreparedMissionDownload prepared, CancellationToken token)
    {
        var archive = InspectArchive(path, prepared, member => member is "mission" or "options"
            || RuntimeSettings.SupportedConfigFileNames.Any(n => Path.GetFileName(member).Equals(n, StringComparison.OrdinalIgnoreCase)), true, token);
        var configs = archive.Members.Where(m => RuntimeSettings.SupportedConfigFileNames.Any(n => Path.GetFileName(m.Name).Equals(n, StringComparison.OrdinalIgnoreCase)))
            .Select(m => new PreparedConfigMember(m.Name, RuntimeSettings.SupportedConfigFileNames.First(n => Path.GetFileName(m.Name).Equals(n, StringComparison.OrdinalIgnoreCase)),
                archive.Captures[m.Name], m.Sha256)).ToArray();
        return new(path, name, asset, archive.Captures["mission"], archive.Captures.GetValueOrDefault("options"),
            Array.AsReadOnly(configs), archive.Members, archive.Sha256);
    }

    // Shared single fingerprint/CRC pass. Callers select captures and own quota rollback/release.
    internal InspectedMissionArchive InspectArchive(string path, PreparedMissionDownload prepared,
        Func<string, bool> captureMember, bool requireMission, CancellationToken token, string? knownSha256 = null)
    {
        using var file = File.OpenRead(path);
        if (file.Length > (requireMission ? _limits.MizBytes : MissionReleaseAsset.MaximumSize))
            throw new InvalidDataException("The archive exceeds the supported size.");
        var digest = knownSha256 ?? Convert.ToHexString(SHA256.HashData(file));
        file.Position = 0;
        using var miz = new ZipArchive(file, ZipArchiveMode.Read);
        CheckNames(miz);
        if (requireMission && miz.Entries.Count(e => e.FullName == "mission") != 1)
            throw new InvalidDataException("The downloaded MIZ must contain exactly one root mission.");
        var members = new List<MissionArchiveMember>();
        var captures = new Dictionary<string, byte[]>(StringComparer.Ordinal);
        long expanded = 0;
        foreach (var entry in miz.Entries)
        {
            token.ThrowIfCancellationRequested();
            if (entry.Length > _limits.MemberBytes || entry.Length > _limits.ExpandedBytes - expanded)
                throw new InvalidDataException("The downloaded MIZ exceeds the expanded-member limits.");
            var capture = captureMember(entry.FullName);
            using var hash = IncrementalHash.CreateHash(HashAlgorithmName.SHA256);
            if (capture) prepared.ReserveCapturedBytes(entry.Length);
            var bytes = capture ? new byte[checked((int)entry.Length)] : null;
            using var input = entry.Open();
            var buffer = new byte[65536];
            long count = 0;
            uint crc = uint.MaxValue;
            int read;
            while ((read = input.Read(buffer)) != 0)
            {
                token.ThrowIfCancellationRequested();
                count += read;
                if (count > entry.Length || count > _limits.MemberBytes || count > _limits.ExpandedBytes - expanded)
                    throw new InvalidDataException("The downloaded MIZ exceeded its expanded-byte limits.");
                hash.AppendData(buffer, 0, read);
                if (bytes is not null) Buffer.BlockCopy(buffer, 0, bytes, checked((int)(count - read)), read);
                crc = UpdateCrc(crc, buffer.AsSpan(0, read));
            }
            if (count != entry.Length || ~crc != entry.Crc32) throw new InvalidDataException("A downloaded MIZ member failed its length or CRC check.");
            expanded += count;
            var memberHash = Convert.ToHexString(hash.GetHashAndReset());
            members.Add(new(entry.FullName, count, memberHash, entry.LastWriteTime, entry.ExternalAttributes));
            if (bytes is not null) captures.Add(entry.FullName, bytes);
        }
        return new(Array.AsReadOnly(members.ToArray()),
            System.Collections.Frozen.FrozenDictionary.ToFrozenDictionary(captures, StringComparer.Ordinal), digest, file.Length);
    }

    private void CheckNames(ZipArchive zip)
    {
        if (zip.Entries.Count > _limits.Entries) throw new InvalidDataException("The downloaded archive has too many entries.");
        var names = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var entry in zip.Entries)
        {
            var name = entry.FullName;
            var parts = name.TrimEnd('/').Split('/');
            if (name.Length is 0 or > 1024 || name.StartsWith('/') || name.Contains('\\') || name.Contains(':')
                || parts.Any(p => p is "" or "." or ".." || p.Any(char.IsControl)) || !names.Add(name))
                throw new InvalidDataException("The downloaded archive contains ambiguous or unsafe member names.");
        }
    }

    internal static void CopyBounded(Stream input, Stream output, long expected, long maximum, uint expectedCrc, CancellationToken token)
    {
        var buffer = new byte[65536];
        long count = 0;
        uint crc = uint.MaxValue;
        int read;
        while ((read = input.Read(buffer)) != 0)
        {
            token.ThrowIfCancellationRequested();
            count += read;
            if (count > expected || count > maximum) throw new InvalidDataException("The downloaded MIZ exceeded its declared size.");
            output.Write(buffer, 0, read);
            crc = UpdateCrc(crc, buffer.AsSpan(0, read));
        }
        if (count != expected || ~crc != expectedCrc) throw new InvalidDataException("The downloaded MIZ failed its length or CRC check.");
    }

    private static readonly uint[] CrcTable = Enumerable.Range(0, 256).Select(value =>
    {
        var crc = (uint)value;
        for (var bit = 0; bit < 8; bit++) crc = (crc & 1) != 0 ? 0xedb88320U ^ (crc >> 1) : crc >> 1;
        return crc;
    }).ToArray();

    private static uint UpdateCrc(uint crc, ReadOnlySpan<byte> bytes)
    {
        foreach (var value in bytes) crc = CrcTable[(crc ^ value) & 255] ^ (crc >> 8);
        return crc;
    }
    public void Dispose()
    {
        if (_preparing) throw new InvalidOperationException("Cancel and finish the active download before disposing its stage.");
        _disposed = true;
        _prepared?.Dispose();
    }
}