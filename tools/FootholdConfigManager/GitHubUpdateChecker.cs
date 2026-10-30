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

    public GitHubUpdateChecker(Version? localVersion, HttpClient? client = null, TimeProvider? timeProvider = null,
        UpdateNotificationStore? store = null, UpdateNotificationState? initialState = null)
    {
        _localVersion = localVersion is null ? null : new Version(localVersion.Major, localVersion.Minor, Math.Max(0, localVersion.Build), Math.Max(0, localVersion.Revision));
        _client = client ?? ProcessClient;
        _timeProvider = timeProvider ?? TimeProvider.System;
        _store = store ?? new UpdateNotificationStore();
        _initialization = Task.Run(() =>
        {
            try { _state = initialState is null ? _store.Load() : ValidateCachedState(initialState); }
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

    public Task<UpdateCheckResult> AcknowledgeFootholdAsync(CancellationToken cancellationToken = default) =>
        MutateAsync(state => state.Foothold.Data is { } release
            ? state with { AcknowledgedFootholdReleaseId = release.Id, AcknowledgedFootholdTag = release.Tag } : state, cancellationToken);

    public Task<UpdateCheckResult> AcknowledgeFootholdAsync(long id, string tag, CancellationToken cancellationToken = default) =>
        MutateAsync(state => state with { AcknowledgedFootholdReleaseId = id, AcknowledgedFootholdTag = tag }, cancellationToken);

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
            _state = mutate(_state);
            SaveState();
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
        var retryAfterUtc = release.RetryAfterUtc.GetValueOrDefault() > manager.RetryAfterUtc.GetValueOrDefault()
            ? release.RetryAfterUtc : manager.RetryAfterUtc;
        if (retryAfterUtc > _timeProvider.GetUtcNow()) return snapshot;
        var changed = false;
        if (NeedsCheck(release, force))
        {
            release = await ReadFeedAsync(ReleasesUrl, release, ParseRelease, cancellationToken).ConfigureAwait(false);
            changed = true;
        }
        if (NeedsCheck(manager, force) && !(release.RetryAfterUtc > _timeProvider.GetUtcNow()))
        {
            manager = await ReadFeedAsync(ManagerUrl, manager, ParseManager, cancellationToken).ConfigureAwait(false);
            changed = true;
        }
        await _stateGate.WaitAsync(cancellationToken).ConfigureAwait(false);
        try
        {
            cancellationToken.ThrowIfCancellationRequested();
            if (changed)
            {
                // Keep preference/acknowledgement changes made while the requests were in flight.
                _state = _state with { Manager = manager, Foothold = release };
                SaveState();
            }
            return CurrentResult();
        }
        finally { _stateGate.Release(); }
    }

    private bool NeedsCheck<T>(UpdateFeedResult<T> feed, bool force) where T : class =>
        !(feed.RetryAfterUtc > _timeProvider.GetUtcNow()) && (force || feed.CheckedAtUtc is null
            || _timeProvider.GetUtcNow() - feed.CheckedAtUtc.Value >= CacheLifetime || feed.Error is not null);

    private UpdateCheckResult CurrentResult() => new(_state with
    {
        Manager = AgeFeed(_state.Manager), Foothold = AgeFeed(_state.Foothold)
    }, _localVersion, _persistenceError);

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
        Func<JsonElement, T?> parse, CancellationToken cancellationToken) where T : class
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
            using var response = await _client.SendAsync(request, HttpCompletionOption.ResponseHeadersRead, linked.Token).ConfigureAwait(false);
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
            using var stream = await response.Content.ReadAsStreamAsync(linked.Token).ConfigureAwait(false);
            using var body = new MemoryStream();
            var buffer = new byte[8192];
            int read;
            while ((read = await stream.ReadAsync(buffer, linked.Token).ConfigureAwait(false)) > 0)
            {
                if (body.Length + read > 2 * 1024 * 1024) throw new InvalidDataException("GitHub metadata is too large.");
                body.Write(buffer, 0, read);
            }
            using var document = JsonDocument.Parse(body.GetBuffer().AsMemory(0, (int)body.Length), new JsonDocumentOptions { MaxDepth = 32 });
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
        return release;
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
        && ValidUrl(release.HtmlUrl, "github.com", "/leka1986/Lekas-Foothold/releases/tag/" + release.Tag);

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
        if (release.Data is { } releaseData && !IsValidRelease(releaseData)) release = new();
        return state with
        {
            Manager = manager with { ETag = ValidETag(manager.ETag) }, Foothold = release with { ETag = ValidETag(release.ETag) },
            AcknowledgedFootholdReleaseId = state.AcknowledgedFootholdReleaseId > 0 ? state.AcknowledgedFootholdReleaseId : null,
            AcknowledgedFootholdTag = state.AcknowledgedFootholdTag is { Length: <= 256 } ? state.AcknowledgedFootholdTag : null,
            SkippedManagerVersion = ManagerBuildInfo.TryParseReleaseVersion(state.SkippedManagerVersion, out var skipped) ? skipped.ToString(4) : null
        };
    }

    private static string? ValidETag(string? value) => value is { Length: <= 256 } && EntityTagHeaderValue.TryParse(value, out _) ? value : null;
}