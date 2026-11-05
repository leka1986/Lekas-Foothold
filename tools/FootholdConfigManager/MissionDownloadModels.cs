namespace FootholdConfigManager;

internal sealed record MissionReleaseAsset(long Id, string Name, long Size, Uri DownloadUri, string? Sha256)
{
    internal const long MaximumSize = 2L * 1024 * 1024 * 1024;
}
internal sealed record MissionArchiveMember(string Name, long Length, string Sha256, DateTimeOffset Timestamp, int Attributes);
internal sealed record InspectedMissionArchive(IReadOnlyList<MissionArchiveMember> Members,
    IReadOnlyDictionary<string, byte[]> Captures, string Sha256, long Length);
internal sealed record PreparedConfigMember(string Name, string Variant, byte[] Bytes, string Sha256);
internal sealed record PreparedMissionTemplate(string SourcePath, string Name, MissionReleaseAsset Asset,
    byte[] MissionBytes, byte[]? OptionsBytes, IReadOnlyList<PreparedConfigMember> ConfigMembers,
    IReadOnlyList<MissionArchiveMember> Members, string Sha256);
internal sealed record PreparedMissionPackage(MissionReleaseAsset Asset, string ZipPath, IReadOnlyList<PreparedMissionTemplate> Templates)
{
    public string Sha256 { get; init; } = "";
    public long CapturedBytes { get; init; }
    public long StagedBytes { get; init; }
}

internal sealed class PreparedMissionDownload : IDisposable
{
    private readonly string _stageDirectory;
    private readonly MissionPackageLimits _limits;
    internal long CapturedBytes { get; set; }
    internal long AvailableCapturedBytes => _limits.CapturedBytes - CapturedBytes;
    internal long StagedBytes { get; set; }
    private bool _disposed;
    private readonly Dictionary<string, string> _cleanupWarnings = new(StringComparer.OrdinalIgnoreCase);
    internal IReadOnlyList<string> CleanupWarnings => _cleanupWarnings.Values.ToArray();
    internal Dictionary<long, PreparedMissionPackage> Packages { get; } = new();
    internal HashSet<long> InvalidatedPackageIds { get; } = new();
    public IReadOnlyList<PreparedMissionTemplate> Templates { get; internal set; } = [];
    internal string StageDirectory => _stageDirectory;
    internal bool IsDisposed => _disposed;
    internal PreparedMissionDownload(string stageDirectory) : this(stageDirectory, MissionPackageLimits.Default) { }
    internal PreparedMissionDownload(string stageDirectory, MissionPackageLimits limits)
    {
        _stageDirectory = stageDirectory;
        _limits = limits;
    }

    internal bool InvalidateConsumedPath(string path)
    {
        path = Path.GetFullPath(path);
        foreach (var package in Packages.Values)
        {
            if (!package.ZipPath.Equals(path, StringComparison.OrdinalIgnoreCase)
                && !package.Templates.Any(template => template.SourcePath.Equals(path, StringComparison.OrdinalIgnoreCase))) continue;
            InvalidatedPackageIds.Add(package.Asset.Id);
            return true;
        }
        return false;
    }

    internal void ReserveCapturedBytes(long length)
    {
        if (length < 0 || length > _limits.CapturedBytes - CapturedBytes)
            throw new InvalidDataException("The selected downloads exceed the total preparation memory limit. Select fewer ZIPs.");
        CapturedBytes += length;
    }

    internal void ReserveStagedBytes(long length)
    {
        if (length < 0 || length > _limits.StagedBytes - StagedBytes)
            throw new InvalidDataException("The selected downloads exceed the total temporary-file limit. Select fewer ZIPs.");
        StagedBytes += length;
    }
    internal void ReleaseCapturedBytes(long length)
    {
        if (length < 0 || length > CapturedBytes) throw new InvalidOperationException("Captured-byte ownership is unbalanced.");
        CapturedBytes -= length;
    }
    public void Dispose()
    {
        _disposed = true;
        Packages.Clear();
        InvalidatedPackageIds.Clear();
        Templates = [];
        if (TryDeleteDirectory(_stageDirectory)) _cleanupWarnings.Clear();
    }

    internal bool TryDeleteDirectory(string directory)
    {
        try
        {
            if (Directory.Exists(directory)) Directory.Delete(directory, recursive: true);
            _cleanupWarnings.Remove(directory);
            return true;
        }
        catch (Exception error) when (error is IOException or UnauthorizedAccessException)
        {
            var warning = "Temporary download files could not be removed at " + directory + ": " + error.Message;
            _cleanupWarnings[directory] = warning;
            System.Diagnostics.Trace.TraceWarning(warning);
            return false;
        }
    }
}
internal sealed record MissionWarehouseSource(string Path, DateTime LastWriteTimeUtc, long Length)
{
    public override string ToString() => System.IO.Path.GetFileName(Path);
}
internal sealed record MissionWarehouseCopy(MissionPathIdentity SourceIdentity, byte[] Bytes, string Sha256,
    string Theatre, string SourceName);

internal enum MissionOutputMode { Original, OptionsOnly, Profile }
internal enum MissionCollisionPolicy { KeepBoth, AskReplace, Skip }
internal sealed record ProfileMissionSnapshot(string Name, WeatherSettings Settings);
internal sealed record MissionVariantPlan(PreparedMissionTemplate Template, string OutputPath, MissionOutputMode Mode,
    ProfileMissionSnapshot? Profile, MissionCollisionPolicy CollisionPolicy, bool ApplyCurrentMissionOptions)
{
    public MissionPathIdentity? ReviewedIdentity { get; init; }
    public MissionWarehouseCopy? WarehouseCopy { get; init; }
}
internal sealed record MissionConfigTarget(string Name, string Path)
{
    public override string ToString() => Name + " · " + System.IO.Path.GetFileName(Path);
}
internal sealed record MissionConfigSource(PreparedMissionTemplate Template, PreparedConfigMember Member)
{
    public override string ToString() => Template.Name + " · " + Member.Name;
}
internal sealed record MissionDownloadSelection
{
    public required FootholdReleaseInfo Release { get; init; }
    public required PreparedMissionDownload Prepared { get; init; }
    public required IReadOnlyList<MissionReleaseAsset> Assets { get; init; }
    public required IReadOnlyList<PreparedMissionTemplate> Templates { get; init; }
    public required ServerProfileSettings Destination { get; init; }
    public required string MissionDirectory { get; init; }
    public IReadOnlyList<MissionConfigTarget> ConfigTargets { get; init; } = [];
    public IReadOnlyDictionary<string, MissionConfigSource> ConfigSources { get; init; } = new Dictionary<string, MissionConfigSource>();
    public IReadOnlyList<ProfileMissionSnapshot> Profiles { get; init; } = [];
    public bool ApplyCurrentMissionOptions { get; init; }
    public MissionOptionsSettings? CurrentMissionOptions { get; init; }
    public bool UpdateConfig { get; init; }
    public bool CopyWarehouses { get; init; }
    public IReadOnlyDictionary<long, string?> WarehouseSources { get; init; } = new Dictionary<long, string?>();
    public MissionCollisionPolicy CollisionPolicy { get; init; }
    public bool CheckMissionCollisions { get; init; }
    public bool KeepZip { get; init; }
    public bool ZipOnly { get; init; }
    public bool OpenFolder { get; init; }
    public string ZipDirectory { get; init; } = "";
}
internal sealed class MissionDownloadResult
{
    public List<string> Installed { get; } = new();
    public List<string> Skipped { get; } = new();
    public List<string> Failed { get; } = new();
    public List<string> UpdatedConfigs { get; } = new();
    public List<string> FailedConfigs { get; } = new();
    public List<string> SavedZips { get; } = new();
    public List<string> Warnings { get; } = new();
    public bool Cancelled { get; set; }
}

internal sealed record MissionPathIdentity(string Path, bool Exists, long Length, string? Sha256)
{
    internal static MissionPathIdentity Capture(string path, byte[]? knownBytes = null, FileShare sharing = FileShare.Read)
    {
        path = System.IO.Path.GetFullPath(path);
        if (knownBytes is not null) return new(path, true, knownBytes.LongLength,
            Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(knownBytes)));
        if (!File.Exists(path)) return new(path, false, 0, null);
        using var file = new FileStream(path, FileMode.Open, FileAccess.Read, sharing);
        return new(path, true, file.Length, Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(file)));
    }

    internal void RequireUnchanged(FileStream? ownedReservation = null)
    {
        var current = Capture(Path, sharing: ownedReservation is null ? FileShare.Read : FileShare.ReadWrite | FileShare.Delete);
        if (current.Exists != Exists || current.Length != Length || !string.Equals(current.Sha256, Sha256, StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException("This file changed after review. Prepare and review again: " + Path);
    }
}