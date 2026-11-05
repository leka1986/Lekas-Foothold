using System.Text.Json;
using System.Text.Json.Serialization;

namespace FootholdConfigManager;

internal enum UpdateFeedStatus { Unknown, Fresh, Stale, Backoff }

internal sealed record UpdateFeedResult<T>(
    T? Data = default,
    UpdateFeedStatus Status = UpdateFeedStatus.Unknown,
    string? ETag = null,
    DateTimeOffset? CheckedAtUtc = null,
    DateTimeOffset? RetryAfterUtc = null,
    string? Error = null) where T : class;

internal sealed record ManagerUpdateInfo(string Name, Version Version, string ApiUrl, string DownloadUrl, string HtmlUrl, string Sha, long Size);
internal sealed record FootholdReleaseInfo(long Id, string Tag, string Title, string HtmlUrl)
{
    public IReadOnlyList<MissionReleaseAsset> Assets { get; init; } = [];
    public bool AssetMetadataLoaded { get; init; }
    public bool FilesEnvelopeMetadataLoaded { get; init; }
    public MissionReleaseAsset? FilesEnvelopeAsset { get; init; }
    public string? FilesEnvelopeError { get; init; }
}

internal sealed record UpdateNotificationState
{
    public bool AutomaticChecksEnabled { get; init; } = true;
    public bool? HasCompletedInteractiveLaunch { get; init; }
    public long? AcknowledgedFootholdReleaseId { get; init; }
    public string? AcknowledgedFootholdTag { get; init; }
    public string? HighestImportedFootholdTag { get; init; }
    public string? SkippedManagerVersion { get; init; }
    public UpdateFeedResult<ManagerUpdateInfo> Manager { get; init; } = new();
    public UpdateFeedResult<FootholdReleaseInfo> Foothold { get; init; } = new();
    public UpdateFeedResult<FilePatchEnvelope> FilesEnvelope { get; init; } = new();
    public string? FilesEnvelopeAssetIdentity { get; init; }
}

internal sealed record UpdateCheckResult(UpdateNotificationState State, Version? LocalVersion, string? PersistenceError = null)
{
    public bool ManagerCheckedThisOperation { get; init; }
    public bool AllowUnknownMissionNotice { get; init; }
    public UpdateFeedResult<ManagerUpdateInfo> Manager => State.Manager;
    public UpdateFeedResult<FootholdReleaseInfo> Foothold => State.Foothold;
    public UpdateFeedResult<FilePatchEnvelope> FilesEnvelope => State.FilesEnvelope;
    public bool ManagerVerifiedCurrent => Manager.Status == UpdateFeedStatus.Fresh && Manager.Error is null
        && Manager.Data is { } manager && LocalVersion is { } local && manager.Version <= local;
    public bool FilesEnvelopeAvailable => Foothold.Status == UpdateFeedStatus.Fresh && FilesEnvelope.Status == UpdateFeedStatus.Fresh
        && FilesEnvelope.Data is { } envelope && Foothold.Data?.Tag == envelope.ReleaseTag;
    public bool AutomaticChecksEnabled => State.AutomaticChecksEnabled;
    public long? AcknowledgedFootholdReleaseId => State.AcknowledgedFootholdReleaseId;
    public string? AcknowledgedFootholdTag => State.AcknowledgedFootholdTag;
    public string? SkippedManagerVersion => State.SkippedManagerVersion;
    public bool ManagerUpdateDownloadAvailable => Manager.Data is { } manager && LocalVersion is { } local
        && manager.Version > local;
    public bool ManagerUpdateAvailable => ManagerUpdateDownloadAvailable
        && Manager.Data!.Version.ToString(4) != SkippedManagerVersion;
    public bool FootholdReleaseImported => ImportedFootholdVersion is { } imported && Foothold.Data is { } release
        && ManagerBuildInfo.TryParseReleaseVersion(release.Tag.TrimStart('v', 'V'), out var latest) && imported >= latest;
    public Version? ImportedFootholdVersion => ManagerBuildInfo.TryParseReleaseVersion(State.HighestImportedFootholdTag?.TrimStart('v', 'V'), out var imported) ? imported : null;
    public bool FootholdReleaseAcknowledged => Foothold.Data is { } release
        && (AcknowledgedFootholdReleaseId is { } id ? release.Id == id : release.Tag == AcknowledgedFootholdTag);
    public bool FootholdUpdateAvailable => Foothold.Data is { } release
        && ManagerBuildInfo.TryParseReleaseVersion(release.Tag.TrimStart('v', 'V'), out var latest)
        && !FootholdReleaseAcknowledged
        && (ImportedFootholdVersion is { } imported ? latest > imported : AllowUnknownMissionNotice);
    public bool HasNotifications => ManagerUpdateAvailable || FootholdUpdateAvailable;
}

internal sealed class UpdateNotificationStore
{
    private const int MaximumStoreBytes = 8 * 1024 * 1024;
    private static readonly JsonSerializerOptions JsonOptions = new() { WriteIndented = true, MaxDepth = 32 };

    public UpdateNotificationStore(string? path = null)
    {
        Path = System.IO.Path.GetFullPath(path ?? System.IO.Path.Combine(RuntimeSettings.SettingsDirectory, "update-notifications.json"));
    }

    public string Path { get; }

    public UpdateNotificationState Load()
    {
        if (!File.Exists(Path)) return new();
        var info = new FileInfo(Path);
        if (info.Length > MaximumStoreBytes) throw new InvalidDataException("The update cache is too large.");
        var state = JsonSerializer.Deserialize<UpdateNotificationState>(File.ReadAllText(Path), JsonOptions)
            ?? throw new InvalidDataException("The update cache is empty.");
        return GitHubUpdateChecker.ValidateCachedState(state);
    }

    public void Save(UpdateNotificationState state)
    {
        var json = JsonSerializer.Serialize(state, JsonOptions);
        if (System.Text.Encoding.UTF8.GetByteCount(json) > MaximumStoreBytes) throw new InvalidDataException("The update cache is too large.");
        AtomicFile.WriteUtf8Text(Path, json);
    }
}
