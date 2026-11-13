using System.Net;
using System.Net.Http.Headers;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace FootholdConfigManager;

internal sealed class GitHubUpdateChecker
{
    private const string ReleasesUrl = "https://api.github.com/repos/leka1986/Lekas-Foothold/releases/latest";
    private const string ManagerUrl = "https://api.github.com/repos/leka1986/Lekas-Foothold/contents/tools/FootholdConfigManager?ref=main";
    private static readonly TimeSpan CacheLifetime = TimeSpan.FromHours(24);
    private static readonly HttpClient ProcessClient = new(new SocketsHttpHandler { AllowAutoRedirect = false }) { Timeout = Timeout.InfiniteTimeSpan };
    private static readonly Regex ManagerName = new(@"^Foothold Config Manager ([0-9]+\.[0-9]+\.[0-9]+(?:\.[0-9]+)?)\.exe$", RegexOptions.CultureInvariant);
    private static readonly Regex BlobSha = new("^[a-fA-F0-9]{40}$", RegexOptions.CultureInvariant);
    private readonly Version? _localVersion;
    private readonly HttpClient _client;
    private readonly TimeProvider _timeProvider;
    private readonly UpdateNotificationStore _store;
    private readonly SemaphoreSlim _stateGate = new(1, 1);
    private readonly object _operationGate = new();
    private readonly Task _initialization;
    private UpdateNotificationState _state = new();
    private string? _persistenceError;
    private Task<UpdateCheckResult>? _inflight;
    private bool _hadValidStoredState;
    private bool _interactiveLaunchRegistered;
    private bool _allowUnknownMissionNotice;
    private string? _checkedWeaponCatalogIdentity;

    public GitHubUpdateChecker(Version? localVersion, HttpClient? client = null, TimeProvider? timeProvider = null,
        UpdateNotificationStore? store = null, UpdateNotificationState? initialState = null)
    {
        _localVersion = localVersion is null ? null : new Version(localVersion.Major, localVersion.Minor, Math.Max(0, localVersion.Build), Math.Max(0, localVersion.Revision));
        _client = client ?? ProcessClient;
        _timeProvider = timeProvider ?? TimeProvider.System;
        _store = store ?? new UpdateNotificationStore();
        _initialization = Task.Run(() =>
        {
            try
            {
                _state = initialState is null ? _store.Load() : ValidateCachedState(initialState);
                _hadValidStoredState = initialState is not null || File.Exists(_store.Path);
            }
            catch (Exception exception) when (IsStorageError(exception))
            {
                _persistenceError = "Could not read update history: " + exception.Message;
            }
        });
    }

    public Task<UpdateCheckResult> CheckAsync(bool force, CancellationToken cancellationToken)
    {
        lock (_operationGate)
        {
            if (_inflight is { IsCompleted: false }) return _inflight;
            _inflight = Task.Run(() => CheckCoreAsync(force, cancellationToken), CancellationToken.None);
            return _inflight;
        }
    }

    public async Task<UpdateCheckResult> GetCurrentAsync(CancellationToken cancellationToken = default)
    {
        await _initialization.WaitAsync(cancellationToken).ConfigureAwait(false);
        await _stateGate.WaitAsync(cancellationToken).ConfigureAwait(false);
        try { return CurrentResult(); }
        finally { _stateGate.Release(); }
    }

    public Task<UpdateCheckResult> BeginInteractiveLaunchAsync(CancellationToken cancellationToken = default) => Task.Run(async () =>
    {
        await _initialization.WaitAsync(cancellationToken).ConfigureAwait(false);
        await _stateGate.WaitAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            cancellationToken.ThrowIfCancellationRequested();
            if (!_interactiveLaunchRegistered)
            {
                _interactiveLaunchRegistered = true;
                _allowUnknownMissionNotice = _state.HasCompletedInteractiveLaunch == true
                    || (_state.HasCompletedInteractiveLaunch is null && _hadValidStoredState);
                if (_state.HasCompletedInteractiveLaunch != true)
                {
                    _state = _state with { HasCompletedInteractiveLaunch = true };
                    SaveState();
                }
            }
            return CurrentResult();
        }
        finally { _stateGate.Release(); }
    }, CancellationToken.None);

    public Task<UpdateCheckResult> AcknowledgeFootholdAsync(CancellationToken cancellationToken = default) =>
        MutateAsync(state => state.Foothold.Data is { } release
            ? state with { AcknowledgedFootholdReleaseId = release.Id, AcknowledgedFootholdTag = release.Tag } : state, cancellationToken);

    public Task<UpdateCheckResult> AcknowledgeFootholdAsync(long id, string tag, CancellationToken cancellationToken = default) =>
        MutateAsync(state => state with { AcknowledgedFootholdReleaseId = id, AcknowledgedFootholdTag = tag }, cancellationToken);

    public async Task<UpdateCheckResult> RecordImportedFootholdAsync(string? tag, CancellationToken cancellationToken = default)
    {
        var current = await GetCurrentAsync(cancellationToken).ConfigureAwait(false);
        if (!ManagerBuildInfo.TryParseReleaseVersion(tag?.TrimStart('v', 'V'), out var imported)) return current;
        if (current.PersistenceError is null && current.ImportedFootholdVersion is { } previous && previous >= imported) return current;
        return await MutateAsync(state =>
            ManagerBuildInfo.TryParseReleaseVersion(state.HighestImportedFootholdTag?.TrimStart('v', 'V'), out var latest) && latest >= imported
                ? state : state with { HighestImportedFootholdTag = "v" + imported.ToString(imported.Revision == 0 ? 3 : 4) }, cancellationToken).ConfigureAwait(false);
    }
    public Task<UpdateCheckResult> SkipManagerAsync(CancellationToken cancellationToken = default) =>
        MutateAsync(state => state.Manager.Data is { } manager
            ? state with { SkippedManagerVersion = manager.Version.ToString(4) } : state, cancellationToken);

    public Task<UpdateCheckResult> SkipManagerAsync(Version version, CancellationToken cancellationToken = default) =>
        MutateAsync(state => state with { SkippedManagerVersion = new Version(version.Major, version.Minor,
            Math.Max(0, version.Build), Math.Max(0, version.Revision)).ToString(4) }, cancellationToken);

    public Task<UpdateCheckResult> SetAutomaticChecksAsync(bool enabled, CancellationToken cancellationToken = default) =>
        MutateAsync(state => state with { AutomaticChecksEnabled = enabled }, cancellationToken);

    private Task<UpdateCheckResult> MutateAsync(Func<UpdateNotificationState, UpdateNotificationState> mutate, CancellationToken cancellationToken) => Task.Run(async () =>
    {
        await _initialization.WaitAsync(cancellationToken).ConfigureAwait(false);
        await _stateGate.WaitAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            cancellationToken.ThrowIfCancellationRequested();
            var next = mutate(_state);
            if (next != _state || _persistenceError is not null)
            {
                _state = next;
                SaveState();
            }
            return CurrentResult();
        }
        finally { _stateGate.Release(); }
    }, CancellationToken.None);

    private async Task<UpdateCheckResult> CheckCoreAsync(bool force, CancellationToken cancellationToken)
    {
        var snapshot = await GetCurrentAsync(cancellationToken).ConfigureAwait(false);
        if (!force && !snapshot.AutomaticChecksEnabled) return snapshot;
        var release = snapshot.Foothold;
        var manager = snapshot.Manager;
        var files = snapshot.FilesEnvelope;
        var filesIdentity = snapshot.State.FilesEnvelopeAssetIdentity;
        var retryAfterUtc = release.RetryAfterUtc.GetValueOrDefault() > manager.RetryAfterUtc.GetValueOrDefault()
            ? release.RetryAfterUtc : manager.RetryAfterUtc;
        if (files.RetryAfterUtc.GetValueOrDefault() > retryAfterUtc.GetValueOrDefault()) retryAfterUtc = files.RetryAfterUtc;
        if (retryAfterUtc > _timeProvider.GetUtcNow()) return snapshot;
        var changed = false;
        var managerChecked = false;
        if (NeedsCheck(release, force))
        {
            // Legacy caches did not discover the JSON asset: fetch that metadata once, then resume conditional checks.
            var requestCache = release.Data is { } old && (!old.AssetMetadataLoaded || !old.FilesEnvelopeMetadataLoaded || !old.WeaponCatalogMetadataLoaded) ? release with { ETag = null } : release;
            release = await ReadFeedAsync(ReleasesUrl, requestCache, ParseRelease, cancellationToken).ConfigureAwait(false);
            changed = true;
        }
        if (NeedsCheck(manager, force) && !(release.RetryAfterUtc > _timeProvider.GetUtcNow()))
        {
            manager = await ReadFeedAsync(ManagerUrl, manager, ParseManager, cancellationToken).ConfigureAwait(false);
            managerChecked = true;
            changed = true;
        }
        if (release.Status == UpdateFeedStatus.Fresh && release.Data is { } admitted)
        {
            var asset = admitted.FilesEnvelopeAsset;
            var identity = asset is null ? null : FilesAssetIdentity(admitted, asset);
            if (identity != filesIdentity) { files = new(RetryAfterUtc: files.RetryAfterUtc); filesIdentity = identity; changed = true; }
            if (asset is null || asset.Sha256 is null)
            {
                files = new(RetryAfterUtc: files.RetryAfterUtc, Error: admitted.FilesEnvelopeError
                    ?? (asset is null ? null : "The files-only envelope has no advertised digest."));
                changed = true;
            }
            if (asset is not null && asset.Sha256 is not null && NeedsCheck(files, force)
                && !(manager.RetryAfterUtc > _timeProvider.GetUtcNow()))
            {
                files = await ReadFeedAsync<FilePatchEnvelope>(asset.DownloadUri.AbsoluteUri, files, _ => null,
                    cancellationToken, FilePatchEnvelope.MaximumBytes, asset.Sha256, asset.Size,
                    bytes => FilePatchEnvelope.Parse(bytes, admitted.Tag)).ConfigureAwait(false);
                changed = true;
            }
        }
        if (release.Status == UpdateFeedStatus.Fresh && release.Data is { } catalogRelease)
            await CacheWeaponCatalogAsync(catalogRelease, cancellationToken).ConfigureAwait(false);

        await _stateGate.WaitAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            cancellationToken.ThrowIfCancellationRequested();
            if (changed)
            {
                // Keep preference/acknowledgement changes made while the requests were in flight.
                _state = _state with { Manager = manager, Foothold = release, FilesEnvelope = files, FilesEnvelopeAssetIdentity = filesIdentity };
                SaveState();
            }
            return CurrentResult() with { ManagerCheckedThisOperation = managerChecked };
        }
        finally { _stateGate.Release(); }
    }

    private async Task CacheWeaponCatalogAsync(FootholdReleaseInfo release, CancellationToken token)
    {
        if (release.WeaponCatalogAsset is not { Sha256: { } digest } asset) return;
        var identity = FilesAssetIdentity(release, asset);
        if (_checkedWeaponCatalogIdentity == identity) return;
        var path = Path.Combine(Path.GetDirectoryName(_store.Path)!, ReleaseWeaponCatalog.CacheName);
        try
        {
            if (new FileInfo(path) is { Exists: true } info && info.Length == asset.Size &&
                FilePatchEnvelope.Digest(await File.ReadAllBytesAsync(path, token).ConfigureAwait(false)) == digest)
            {
                _checkedWeaponCatalogIdentity = identity;
                return;
            }

            string? verifiedJson = null;
            var result = await ReadFeedAsync<ReleaseWeaponCatalog>(asset.DownloadUri.AbsoluteUri, new(), _ => null, token,
                ReleaseWeaponCatalog.MaximumBytes, digest, asset.Size, bytes =>
                {
                    var parsed = ReleaseWeaponCatalog.Parse(bytes, release.Tag);
                    verifiedJson = System.Text.Encoding.UTF8.GetString(bytes.Span);
                    return parsed;
                }).ConfigureAwait(false);
            if (result.Data is null || verifiedJson is null) return;
            token.ThrowIfCancellationRequested();
            AtomicFile.WriteUtf8Text(path, verifiedJson);
            _checkedWeaponCatalogIdentity = identity;
        }
        catch (Exception exception) when (IsStorageError(exception))
        {
            System.Diagnostics.Trace.TraceWarning("Could not cache the Foothold weapon catalog: " + exception.Message);
        }
    }

    private bool NeedsCheck<T>(UpdateFeedResult<T> feed, bool force) where T : class =>
        !(feed.RetryAfterUtc > _timeProvider.GetUtcNow()) && (force || feed.CheckedAtUtc is null
            || _timeProvider.GetUtcNow() - feed.CheckedAtUtc.Value >= CacheLifetime || feed.Error is not null);

    private UpdateCheckResult CurrentResult() => AgeSnapshot(new(_state, _localVersion, _persistenceError)
        { AllowUnknownMissionNotice = _allowUnknownMissionNotice });

    internal UpdateCheckResult AgeSnapshot(UpdateCheckResult snapshot) => snapshot with
    {
        State = snapshot.State with
        {
            Manager = AgeFeed(snapshot.Manager), Foothold = AgeFeed(snapshot.Foothold), FilesEnvelope = AgeFeed(snapshot.FilesEnvelope)
        }
    };

    private UpdateFeedResult<T> AgeFeed<T>(UpdateFeedResult<T> feed) where T : class
    {
        var now = _timeProvider.GetUtcNow();
        if (feed.CheckedAtUtc > now.AddMinutes(5)) feed = feed with { CheckedAtUtc = null };
        if (feed.RetryAfterUtc > now.AddDays(1)) feed = feed with { RetryAfterUtc = now.AddDays(1) };
        var status = feed.RetryAfterUtc > now ? UpdateFeedStatus.Backoff
            : feed.Error is not null || feed.CheckedAtUtc is { } checkedAt && now - checkedAt >= CacheLifetime ? UpdateFeedStatus.Stale
            : feed.CheckedAtUtc is not null ? UpdateFeedStatus.Fresh
            : feed.Data is not null ? UpdateFeedStatus.Stale : UpdateFeedStatus.Unknown;
        return feed with { Status = status };
    }

    private void SaveState()
    {
        try { _store.Save(_state); _persistenceError = null; }
        catch (Exception exception) when (IsStorageError(exception))
        {
            _persistenceError = "Could not save update history: " + exception.Message;
        }
    }

    private static bool IsStorageError(Exception exception) => exception is IOException or InvalidDataException or UnauthorizedAccessException or JsonException or NotSupportedException;

    private async Task<UpdateFeedResult<T>> ReadFeedAsync<T>(string url, UpdateFeedResult<T> cached,
        Func<JsonElement, T?> parse, CancellationToken cancellationToken, int maximumBytes = 2 * 1024 * 1024,
        string? expectedSha256 = null, long? expectedLength = null, Func<ReadOnlyMemory<byte>, T?>? parseBytes = null) where T : class
    {
        using var timeout = new CancellationTokenSource(TimeSpan.FromSeconds(8), _timeProvider);
        using var linked = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken, timeout.Token);
        using var request = new HttpRequestMessage(HttpMethod.Get, url);
        request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/vnd.github+json"));
        request.Headers.UserAgent.ParseAdd("FootholdConfigManager/1.0");
        request.Headers.Add("X-GitHub-Api-Version", "2022-11-28");
        if (EntityTagHeaderValue.TryParse(cached.ETag, out var etag)) request.Headers.IfNoneMatch.Add(etag);
        try
        {
            using var response = await SendFeedRequestAsync(request, expectedSha256 is not null, linked.Token).ConfigureAwait(false);
            var now = _timeProvider.GetUtcNow();
            if (response.StatusCode == HttpStatusCode.NotModified)
            {
                if (cached.CheckedAtUtc is null) throw new InvalidDataException("GitHub returned 304 without a cached result.");
                return cached with { Status = UpdateFeedStatus.Fresh, CheckedAtUtc = now, RetryAfterUtc = null, Error = null,
                    ETag = response.Headers.ETag?.ToString() ?? cached.ETag };
            }
            if (!response.IsSuccessStatusCode)
            {
                var retryAt = GetRetryAfter(response, now);
                return cached with { Status = retryAt is null ? UpdateFeedStatus.Stale : UpdateFeedStatus.Backoff,
                    RetryAfterUtc = retryAt, Error = $"GitHub returned {(int)response.StatusCode}." };
            }
            if (response.Content.Headers.ContentLength is { } advertisedLength && advertisedLength > maximumBytes)
                throw new InvalidDataException("GitHub metadata is too large.");
            using var stream = await response.Content.ReadAsStreamAsync(linked.Token).ConfigureAwait(false);
            using var body = new MemoryStream();
            var buffer = new byte[8192];
            int read;
            while ((read = await stream.ReadAsync(buffer.AsMemory(0, Math.Min(buffer.Length, maximumBytes - (int)body.Length + 1)), linked.Token).ConfigureAwait(false)) > 0)
            {
                if (body.Length + read > maximumBytes) throw new InvalidDataException("GitHub metadata is too large.");
                body.Write(buffer, 0, read);
            }
            var bytes = body.GetBuffer().AsMemory(0, (int)body.Length);
            if (expectedLength is { } exactLength && body.Length != exactLength
                || expectedSha256 is not null && FilePatchEnvelope.Digest(bytes.Span) != expectedSha256)
                throw new InvalidDataException("GitHub envelope length/digest differs.");
            if (parseBytes is not null) return new(parseBytes(bytes), UpdateFeedStatus.Fresh, response.Headers.ETag?.ToString(), now);
            using var document = JsonDocument.Parse(bytes, new JsonDocumentOptions { MaxDepth = 32 });
            return new(parse(document.RootElement), UpdateFeedStatus.Fresh, response.Headers.ETag?.ToString(), now);
        }
        catch (OperationCanceledException) when (!cancellationToken.IsCancellationRequested)
        {
            return cached with { Status = UpdateFeedStatus.Stale, RetryAfterUtc = null, Error = "The GitHub request timed out." };
        }
        catch (Exception exception) when (exception is HttpRequestException or JsonException or InvalidDataException or IOException)
        {
            return cached with { Status = UpdateFeedStatus.Stale, RetryAfterUtc = null, Error = "Could not check GitHub: " + exception.Message };
        }
    }

    private async Task<HttpResponseMessage> SendFeedRequestAsync(HttpRequestMessage original, bool releaseAsset, CancellationToken token)
    {
        var uri = original.RequestUri!;
        for (var redirects = 0; ; redirects++)
        {
            using var request = new HttpRequestMessage(HttpMethod.Get, uri);
            foreach (var header in original.Headers) request.Headers.TryAddWithoutValidation(header.Key, header.Value);
            var response = await _client.SendAsync(request, HttpCompletionOption.ResponseHeadersRead, token).ConfigureAwait(false);
            try
            {
                if (releaseAsset && response.RequestMessage?.RequestUri != uri)
                    throw new InvalidDataException("The envelope transport followed an unreviewed redirect.");
                if (!releaseAsset || response.StatusCode is not (HttpStatusCode.MovedPermanently or HttpStatusCode.Found or HttpStatusCode.SeeOther
                    or HttpStatusCode.TemporaryRedirect or HttpStatusCode.PermanentRedirect)) return response;
                uri = MissionDownloadService.ReviewReleaseAssetRedirect(original.RequestUri!, uri, response.Headers.Location, redirects);
            }
            catch { response.Dispose(); throw; }
            response.Dispose();
        }
    }

    private static DateTimeOffset? GetRetryAfter(HttpResponseMessage response, DateTimeOffset now)
    {
        if (response.Headers.RetryAfter?.Date is { } date && date > now) return date;
        if (response.Headers.RetryAfter?.Delta is { } delta && delta > TimeSpan.Zero) return now.Add(delta);
        if (response.StatusCode is not (HttpStatusCode.Forbidden or HttpStatusCode.TooManyRequests)) return null;
        if (response.Headers.TryGetValues("X-RateLimit-Reset", out var values) && long.TryParse(values.FirstOrDefault(), out var seconds)
            && seconds >= 0 && seconds <= 253402300799)
        {
            var reset = DateTimeOffset.FromUnixTimeSeconds(seconds);
            if (reset > now) return reset;
        }
        return now.AddHours(1);
    }

    private static FootholdReleaseInfo ParseRelease(JsonElement element)
    {
        if (element.ValueKind != JsonValueKind.Object || !element.TryGetProperty("id", out var id) || id.ValueKind != JsonValueKind.Number || !id.TryGetInt64(out var releaseId)
            || releaseId <= 0 || IsTrue(element, "draft") || IsTrue(element, "prerelease"))
            throw new InvalidDataException("GitHub did not return a published stable release.");
        var tag = ReadString(element, "tag_name");
        var release = new FootholdReleaseInfo(releaseId, tag, ReadString(element, "name", required: false) is { Length: > 0 } title ? title : tag,
            ReadString(element, "html_url"));
        if (!IsValidRelease(release)) throw new InvalidDataException("GitHub returned an invalid release link or identity.");
        if (!element.TryGetProperty("assets", out var entries) || entries.ValueKind != JsonValueKind.Array || entries.GetArrayLength() > 512)
            throw new InvalidDataException("GitHub returned an invalid release asset list.");
        var assets = new List<MissionReleaseAsset>();
        MissionReleaseAsset? envelopeAsset = null;
        string? envelopeError = null;
        MissionReleaseAsset? weaponCatalogAsset = null;
        var weaponCatalogInvalid = false;
        var ids = new HashSet<long>();
        var names = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var entry in entries.EnumerateArray())
        {
            if (entry.ValueKind != JsonValueKind.Object) throw new InvalidDataException("GitHub returned an invalid release asset.");
            var name = ReadString(entry, "name", false);
            var isEnvelope = name.Equals("foothold-files.json", StringComparison.Ordinal);
            var isWeaponCatalog = name.Equals(ReleaseWeaponCatalog.AssetName, StringComparison.Ordinal);
            if (ReadString(entry, "state", false) != "uploaded" ||
                !isEnvelope && !isWeaponCatalog && !name.EndsWith(".zip", StringComparison.OrdinalIgnoreCase)) continue;
            if (!isEnvelope && !isWeaponCatalog && IsReservedFilesAsset(name)) continue;
            try
            {
                if (!entry.TryGetProperty("id", out var assetId) || assetId.ValueKind != JsonValueKind.Number || !assetId.TryGetInt64(out var numericId)
                    || !entry.TryGetProperty("size", out var size) || size.ValueKind != JsonValueKind.Number || !size.TryGetInt64(out var bytes)
                    || !Uri.TryCreate(ReadString(entry, "browser_download_url"), UriKind.Absolute, out var url))
                    throw new InvalidDataException("GitHub returned invalid ZIP asset metadata.");
                string? digest = null;
                if (entry.TryGetProperty("digest", out var digestValue) && digestValue.ValueKind != JsonValueKind.Null)
                {
                    if (digestValue.ValueKind != JsonValueKind.String || digestValue.GetString() is not { } advertised
                        || !advertised.StartsWith("sha256:", StringComparison.OrdinalIgnoreCase))
                        throw new InvalidDataException("GitHub returned an invalid ZIP digest.");
                    digest = advertised[7..].ToLowerInvariant();
                }
                var asset = new MissionReleaseAsset(numericId, name, bytes, url, digest);
                if (isWeaponCatalog)
                {
                    if (weaponCatalogInvalid || weaponCatalogAsset is not null || !IsValidWeaponCatalogAsset(asset, tag))
                        throw new InvalidDataException("GitHub returned an invalid or duplicate weapon catalog.");
                    weaponCatalogAsset = asset;
                    continue;
                }

                if (!(isEnvelope ? IsValidEnvelopeAsset(asset, tag) : IsValidReleaseAsset(asset, tag)) || !ids.Add(asset.Id) || !names.Add(asset.Name))
                    throw new InvalidDataException("GitHub returned an invalid or duplicate ZIP asset.");
                if (isEnvelope) { if (envelopeError is null) envelopeAsset = asset; } else assets.Add(asset);
            }
            catch (InvalidDataException) when (isWeaponCatalog)
            {
                weaponCatalogAsset = null;
                weaponCatalogInvalid = true;
            }
            catch (InvalidDataException error) when (isEnvelope)
            {
                envelopeAsset = null;
                envelopeError = "Files-only metadata: " + error.Message;
            }
        }
        if (weaponCatalogAsset is not null && ids.Contains(weaponCatalogAsset.Id)) weaponCatalogAsset = null;
        return release with
        {
            Assets = assets.ToArray(), AssetMetadataLoaded = true, FilesEnvelopeMetadataLoaded = true,
            FilesEnvelopeAsset = envelopeAsset, FilesEnvelopeError = envelopeError,
            WeaponCatalogMetadataLoaded = true, WeaponCatalogAsset = weaponCatalogAsset
        };
    }

    internal static ManagerUpdateInfo? ParseManager(JsonElement element)
    {
        if (element.ValueKind != JsonValueKind.Array) throw new InvalidDataException("GitHub did not return the Manager folder listing.");
        ManagerUpdateInfo? highest = null;
        foreach (var entry in element.EnumerateArray())
        {
            if (entry.ValueKind != JsonValueKind.Object || ReadString(entry, "type", false) != "file") continue;
            var name = ReadString(entry, "name", false);
            var match = ManagerName.Match(name);
            if (!match.Success || !ManagerBuildInfo.TryParseReleaseVersion(match.Groups[1].Value, out var version)) continue;
            if (!entry.TryGetProperty("size", out var size) || size.ValueKind != JsonValueKind.Number || !size.TryGetInt64(out var bytes))
                throw new InvalidDataException("GitHub returned an invalid Manager file size.");
            var candidate = new ManagerUpdateInfo(name, version, ReadString(entry, "url", false), ReadString(entry, "download_url", false),
                ReadString(entry, "html_url", false), ReadString(entry, "sha", false), bytes);
            if (!IsValidManager(candidate)) throw new InvalidDataException("GitHub returned invalid Manager file metadata.");
            if (highest is null || candidate.Version > highest.Version) highest = candidate;
        }
        return highest;
    }

    private static bool IsTrue(JsonElement element, string name) => element.TryGetProperty(name, out var property) && property.ValueKind == JsonValueKind.True;
    private static string ReadString(JsonElement element, string name, bool required = true)
    {
        if (element.TryGetProperty(name, out var value) && value.ValueKind == JsonValueKind.String) return value.GetString() ?? "";
        if (!required) return "";
        throw new InvalidDataException("GitHub metadata is missing " + name + ".");
    }

    private static bool IsValidRelease(FootholdReleaseInfo release) => release.Id > 0 && release.Tag is { Length: > 0 and <= 256 }
        && release.Title is { Length: > 0 and <= 512 }
        && ValidUrl(release.HtmlUrl, "github.com", "/leka1986/Lekas-Foothold/releases/tag/" + release.Tag)
        && release.Assets is { Count: <= 512 } && release.Assets.All(asset => IsValidReleaseAsset(asset, release.Tag))
        && release.Assets.Select(asset => asset.Id).Distinct().Count() == release.Assets.Count
        && release.Assets.Select(asset => asset.Name).Distinct(StringComparer.OrdinalIgnoreCase).Count() == release.Assets.Count
        && (release.FilesEnvelopeAsset is null || IsValidEnvelopeAsset(release.FilesEnvelopeAsset, release.Tag))
        && (release.FilesEnvelopeError is null or { Length: <= 512 });

    internal static bool IsValidReleaseAsset(MissionReleaseAsset? asset, string tag) => asset is not null
        && asset.Id > 0 && asset.Size is > 0 and <= MissionReleaseAsset.MaximumSize
        && asset.Name is { Length: > 0 and <= 255 } && asset.Name.EndsWith(".zip", StringComparison.OrdinalIgnoreCase)
        && !IsReservedFilesAsset(asset.Name)
        && asset.Name.IndexOfAny(Path.GetInvalidFileNameChars()) < 0 && asset.Name.Trim() == asset.Name
        && asset.DownloadUri is { IsAbsoluteUri: true }
        && ValidUrl(asset.DownloadUri.AbsoluteUri, "github.com", "/leka1986/Lekas-Foothold/releases/download/" + tag + "/" + asset.Name)
        && (asset.Sha256 is null || Regex.IsMatch(asset.Sha256, "\\A[0-9a-fA-F]{64}\\z", RegexOptions.CultureInvariant));

    internal static bool IsReservedFilesAsset(string name) => name.Equals("foothold-files.json", StringComparison.OrdinalIgnoreCase)
        || name.StartsWith("Foothold-files-", StringComparison.OrdinalIgnoreCase);
    private static string FilesAssetIdentity(FootholdReleaseInfo release, MissionReleaseAsset asset) =>
        release.Id + "|" + release.Tag + "|" + asset.Id + "|" + asset.Name + "|" + asset.Size + "|" + asset.Sha256;
    private static bool IsValidWeaponCatalogAsset(MissionReleaseAsset asset, string tag) => asset.Id > 0
        && asset.Name == ReleaseWeaponCatalog.AssetName && asset.Size is > 0 and <= ReleaseWeaponCatalog.MaximumBytes
        && ValidUrl(asset.DownloadUri?.AbsoluteUri, "github.com",
            "/leka1986/Lekas-Foothold/releases/download/" + tag + "/" + ReleaseWeaponCatalog.AssetName)
        && asset.Sha256 is { } digest && Regex.IsMatch(digest, @"\A[0-9a-f]{64}\z", RegexOptions.CultureInvariant);

    private static bool IsValidEnvelopeAsset(MissionReleaseAsset asset, string tag) => asset.Id > 0
        && asset.Name == "foothold-files.json" && asset.Size is > 0 and <= FilePatchEnvelope.MaximumBytes
        && ValidUrl(asset.DownloadUri?.AbsoluteUri, "github.com", "/leka1986/Lekas-Foothold/releases/download/" + tag + "/foothold-files.json")
        && (asset.Sha256 is null || Regex.IsMatch(asset.Sha256, "\\A[0-9a-f]{64}\\z", RegexOptions.CultureInvariant));

    private static bool IsValidManager(ManagerUpdateInfo manager)
    {
        if (manager.Name is null || manager.Version is null || manager.Sha is null) return false;
        var match = ManagerName.Match(manager.Name);
        if (!match.Success || !ManagerBuildInfo.TryParseReleaseVersion(match.Groups[1].Value, out var parsed) || parsed != manager.Version
            || !BlobSha.IsMatch(manager.Sha) || manager.Size is <= 0 or > 1073741824) return false;
        return ValidUrl(manager.ApiUrl, "api.github.com", "/repos/leka1986/Lekas-Foothold/contents/tools/FootholdConfigManager/" + manager.Name, "?ref=main")
            && ValidUrl(manager.DownloadUrl, "raw.githubusercontent.com", "/leka1986/Lekas-Foothold/main/tools/FootholdConfigManager/" + manager.Name)
            && ValidUrl(manager.HtmlUrl, "github.com", "/leka1986/Lekas-Foothold/blob/main/tools/FootholdConfigManager/" + manager.Name);
    }

    private static bool ValidUrl(string? value, string host, string path, string query = "") =>
        Uri.TryCreate(value, UriKind.Absolute, out var uri) && uri.Scheme == Uri.UriSchemeHttps && uri.IsDefaultPort
        && uri.UserInfo.Length == 0 && uri.Host.Equals(host, StringComparison.OrdinalIgnoreCase) && uri.Fragment.Length == 0
        && Uri.UnescapeDataString(uri.AbsolutePath).Equals(path, StringComparison.Ordinal)
        && (uri.Query == query || query.Length > 0 && uri.Query.Length == 0);

    internal static UpdateNotificationState ValidateCachedState(UpdateNotificationState state)
    {
        var manager = state.Manager ?? new();
        var release = state.Foothold ?? new();
        if (manager.Data is { } managerData && !IsValidManager(managerData)) manager = new();
        if (release.Data is { Assets: { } cachedAssets } cached && cachedAssets.Any(asset => asset is not null && IsReservedFilesAsset(asset.Name)))
            release = release with { Data = cached with { Assets = Array.AsReadOnly(cachedAssets.Where(asset => asset is null || !IsReservedFilesAsset(asset.Name)).ToArray()) } };
        if (release.Data is { } releaseData && !IsValidRelease(releaseData)) release = new();
        else if (release.Data is { WeaponCatalogAsset: { } catalogAsset } catalogRelease &&
            (!IsValidWeaponCatalogAsset(catalogAsset, catalogRelease.Tag) ||
             catalogRelease.Assets.Any(asset => asset.Id == catalogAsset.Id) || catalogRelease.FilesEnvelopeAsset?.Id == catalogAsset.Id))
            release = release with { Data = catalogRelease with { WeaponCatalogAsset = null } };
        var files = state.FilesEnvelope ?? new();
        var identity = release.Data?.FilesEnvelopeAsset is { Sha256: not null } asset ? FilesAssetIdentity(release.Data, asset) : null;
        var discardedFiles = identity is null || identity != state.FilesEnvelopeAssetIdentity || files.Data is { } envelope
            && (envelope.ReleaseTag != release.Data?.Tag || FilePatchEnvelope.Digest(System.Text.Encoding.UTF8.GetBytes(envelope.RawJson)) != release.Data.FilesEnvelopeAsset!.Sha256
                || System.Text.Encoding.UTF8.GetByteCount(envelope.RawJson) != release.Data.FilesEnvelopeAsset.Size);
        if (discardedFiles)
            files = new(RetryAfterUtc: files.RetryAfterUtc, Error: release.Data?.FilesEnvelopeError
                ?? (release.Data?.FilesEnvelopeAsset is { Sha256: null } ? "The files-only envelope has no advertised digest." : null));
        else if (files.Data is null)
            files = files with { ETag = null, CheckedAtUtc = null, Error = files.ETag is not null || files.CheckedAtUtc is not null
                ? "Saved files-only envelope was invalid; check again to refresh it." : files.Error };
        return state with
        {
            FilesEnvelope = files with { ETag = ValidETag(files.ETag) }, FilesEnvelopeAssetIdentity = identity,
            Manager = manager with { ETag = ValidETag(manager.ETag) }, Foothold = release with { ETag = ValidETag(release.ETag) },
            AcknowledgedFootholdReleaseId = state.AcknowledgedFootholdReleaseId > 0 ? state.AcknowledgedFootholdReleaseId : null,
            AcknowledgedFootholdTag = state.AcknowledgedFootholdTag is { Length: <= 256 } ? state.AcknowledgedFootholdTag : null,
            HighestImportedFootholdTag = ManagerBuildInfo.TryParseReleaseVersion(state.HighestImportedFootholdTag?.TrimStart('v', 'V'), out var imported)
                ? "v" + imported.ToString(imported.Revision == 0 ? 3 : 4) : null,
            SkippedManagerVersion = ManagerBuildInfo.TryParseReleaseVersion(state.SkippedManagerVersion, out var skipped) ? skipped.ToString(4) : null
        };
    }

    private static string? ValidETag(string? value) => value is { Length: <= 256 } && EntityTagHeaderValue.TryParse(value, out _) ? value : null;
}