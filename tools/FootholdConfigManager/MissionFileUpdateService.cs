namespace FootholdConfigManager;

// Presentation facts are separate from the retained inspection and verified writer below.
internal enum FileUpdateInspectionState { Checking, Compatible, Incompatible, Unknown, Error, Stale }
internal sealed record FileUpdateInspection(string Path, string GroupId, string GroupName, string GroupSummary,
    string FriendlyName, FileUpdateInspectionState State, string Reason, string? ProposedOutputName);
internal sealed record MissionFilesUpdatesPresentation(bool ManagerVerifiedCurrent, string ManagerStatus,
    string ReleaseTitle, bool FilesOnlyAvailable, IReadOnlyList<(string Id, string Name, string Provenance)> Instances);

// A header is an availability hint only; no mission archive is opened here.
internal sealed record MissionConfigHeaderInput(string Id, string Name, string ConfigPath, bool IsCurrent, string? CurrentReleaseTag);
internal sealed record MissionConfigHeaderFact(string Id, string Name, string ConfigPath, string? ReleaseTag, string Status, bool Possible);
internal static class MissionConfigHeaders
{
    internal const int MaximumHeaderBytes = 4096;
    internal static IReadOnlyList<MissionConfigHeaderFact> Read(IReadOnlyList<MissionConfigHeaderInput> inputs,
        IReadOnlySet<string> supportedTags, CancellationToken token, Func<string, Stream>? open = null)
    {
        var facts = new List<MissionConfigHeaderFact>(inputs.Count);
        var found = false;
        foreach (var input in inputs)
        {
            token.ThrowIfCancellationRequested();
            string? tag = null;
            var status = "Not checked";
            if (!found)
            {
                try
                {
                    tag = input.IsCurrent ? input.CurrentReleaseTag : ReadFirstLine(input.ConfigPath, open);
                    status = tag is null ? "Unknown release" : tag;
                }
                catch (Exception error) when (error is IOException or UnauthorizedAccessException or System.Text.DecoderFallbackException or ArgumentException)
                { status = "Config unavailable"; }
            }
            var possible = tag is not null && supportedTags.Contains(tag);
            if (possible) { found = true; status += " · possible update"; }
            facts.Add(new(input.Id, input.Name, input.ConfigPath, tag, status, possible));
        }
        return facts.AsReadOnly();
    }
    private static string? ReadFirstLine(string path, Func<string, Stream>? open)
    {
        using var stream = open is null ? File.OpenRead(path) : open(path);
        var bytes = new byte[MaximumHeaderBytes];
        var count = 0;
        var ended = false;
        while (count < bytes.Length)
        {
            // Read only the prefix; invalid bytes in the body must not affect the header.
            var value = stream.ReadByte();
            if (value < 0) { ended = true; break; }
            bytes[count++] = (byte)value;
            if (value is 10 or 13) { count--; ended = true; break; }
        }
        if (!ended) return null;
        var offset = count >= 3 && bytes[0] == 0xef && bytes[1] == 0xbb && bytes[2] == 0xbf ? 3 : 0;
        return ConfigDocument.ParseMissionReleaseTag(new System.Text.UTF8Encoding(false, true).GetString(bytes, offset, count - offset));
    }
}

// Persist the ONE exact raw envelope. Typed immutable facts are derived once on admission/restart;
// JSON reformatting by the history store cannot change the raw contract digest.
[System.Text.Json.Serialization.JsonConverter(typeof(FilePatchEnvelopeCacheConverter))]
internal sealed class FilePatchEnvelope
{
    internal const int MaximumBytes = 1024 * 1024;
    public string RawJson { get; }
    private readonly int _contractOffset, _contractLength;
    [System.Text.Json.Serialization.JsonIgnore] public string ReleaseTag { get; }
    [System.Text.Json.Serialization.JsonIgnore] public string ContractSha256 { get; }
    [System.Text.Json.Serialization.JsonIgnore] public FilePatchContract Contract { get; }
    [System.Text.Json.Serialization.JsonIgnore] public FilePatchPayload Payload { get; }
    [System.Text.Json.Serialization.JsonIgnore] public IReadOnlySet<string> SupportedReleaseTags { get; }
    [System.Text.Json.Serialization.JsonConstructor]
    public FilePatchEnvelope(string rawJson)
    {
        if (rawJson is null || System.Text.Encoding.UTF8.GetByteCount(rawJson) > MaximumBytes) throw Invalid("Envelope is too large.");
        using var doc = System.Text.Json.JsonDocument.Parse(rawJson, new() { MaxDepth = 32 });
        var root = doc.RootElement;
        Shape(root, "schemaVersion", "kind", "releaseTag", "contractSha256", "contract", "payload");
        if (root.GetProperty("schemaVersion").GetInt32() != 1 || Text(root,"kind") != "foothold-files-envelope") throw Invalid("Unsupported envelope schema.");
        ReleaseTag = Tag(root, "releaseTag"); ContractSha256 = HashText(root, "contractSha256");
        var contract = root.GetProperty("contract");
        var contractText = contract.GetRawText();
        _contractOffset = rawJson.IndexOf(contractText, StringComparison.Ordinal);
        _contractLength = contractText.Length;
        var contractBytes = System.Text.Encoding.UTF8.GetBytes(contractText);
        if (Digest(contractBytes) != ContractSha256) throw Invalid("Contract digest differs.");
        Shape(contract, "schemaVersion", "kind", "releaseTag", "blobs", "comparisonPolicyId", "targets");
        if (contract.GetProperty("schemaVersion").GetInt32() != 1 || Text(contract,"kind") != "foothold-files"
            || Tag(contract,"releaseTag") != ReleaseTag || Text(contract,"comparisonPolicyId") != "foothold-author-files-v1") throw Invalid("Unsupported contract identity/policy.");
        var blobs = new List<FilePatchBlob>();
        var blobEntries = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var b in Array(contract,"blobs",4096))
        {
            Shape(b,"id","entry","role","length","sha256");
            var role = Text(b,"role");
            if (role is not ("script" or "config" or "compat-mission" or "compat-resource-map")) throw Invalid("Unknown blob role.");
            var blob = new FilePatchBlob(Text(b,"id"), SafePath(b,"entry"), role, Length(b,"length"), HashText(b,"sha256"));
            if (!blobEntries.Add(blob.Entry)) throw Invalid("Duplicate blob entry.");
            blobs.Add(blob);
        }
        var byId = blobs.ToDictionary(b => b.Id, StringComparer.Ordinal);
        var targets = new List<FilePatchTarget>(); var families = new HashSet<string>(StringComparer.Ordinal);
        foreach (var t in Array(contract,"targets",256))
        {
            Shape(t,"familyId","theatre","baseLayoutId","targetScriptVersion","authorTargetMizSha256","missionProof","resourceMapProof","replacements","supportedSources");
            var family = Text(t,"familyId"); if (!families.Add(family)) throw Invalid("Duplicate family.");
            var theatre = Text(t,"theatre"); var layout = Text(t,"baseLayoutId"); var version = ScriptVersion(t,"targetScriptVersion");
            var missionProof = Reference(t,"missionProof",byId,"compat-mission");
            var mapProof = Reference(t,"resourceMapProof",byId,"compat-resource-map");
            var replacements = new List<FilePatchReplacement>();
            var paths = new HashSet<string>(StringComparer.OrdinalIgnoreCase); var keys = new HashSet<string>(StringComparer.Ordinal);
            foreach (var r in Array(t,"replacements",4096))
            {
                Shape(r,"blobId","memberPath","resourceKey","configVariant");
                var id = Text(r,"blobId"); var path = SafePath(r,"memberPath"); var key = Text(r,"resourceKey");
                var variant = r.GetProperty("configVariant").ValueKind == System.Text.Json.JsonValueKind.Null ? null : Text(r,"configVariant");
                if (!paths.Add(path) || !keys.Add(key) || !byId.TryGetValue(id,out var blob)
                    || blob.Role is not ("script" or "config") || (blob.Role == "config") != (variant is not null)
                    || variant is not null && (!RuntimeSettings.SupportedConfigFileNames.Contains(variant, StringComparer.Ordinal) || !path.EndsWith("/" + variant,StringComparison.Ordinal))) throw Invalid("Invalid replacement binding.");
                replacements.Add(new(id,path,key,variant));
            }
            var sources = new List<FilePatchSupportedSource>();
            var sourceIdentities = new HashSet<string>(StringComparer.Ordinal);
            foreach (var s in Array(t,"supportedSources",256))
            {
                Shape(s,"sourceReleaseTag","scriptVersion","baseLayoutId","authorSourceMizSha256","scriptMembers");
                var sourceVersion = ScriptVersion(s,"scriptVersion");
                if (Version.Parse(sourceVersion) >= Version.Parse(version) || Text(s,"baseLayoutId") != layout) throw Invalid("Invalid source transition.");
                var members = new List<FilePatchScriptMember>(); var names = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                foreach (var m in Array(s,"scriptMembers",4096))
                {
                    Shape(m,"memberPath","length","sha256"); var path = SafePath(m,"memberPath");
                    if (!path.EndsWith(".lua",StringComparison.OrdinalIgnoreCase) || !names.Add(path)
                        || RuntimeSettings.SupportedConfigFileNames.Any(c => path.EndsWith("/"+c,StringComparison.OrdinalIgnoreCase))) throw Invalid("Invalid script cohort.");
                    members.Add(new(path,Length(m,"length"),HashText(m,"sha256")));
                }
                // Equal certified same-family cohorts may support several global releases.
                // Owned-reference ambiguity requires payload facts and belongs to Task4.
                if (!sourceIdentities.Add(Tag(s,"sourceReleaseTag") + "|" + sourceVersion + "|" + layout))
                    throw Invalid("Duplicate supported source identity.");
                sources.Add(new(Tag(s,"sourceReleaseTag"), sourceVersion, layout, HashText(s,"authorSourceMizSha256"), members.AsReadOnly()));
            }
            targets.Add(new(family,theatre,layout,version,HashText(t,"authorTargetMizSha256"),missionProof,mapProof,replacements.AsReadOnly(),sources.AsReadOnly()));
        }
        Contract = new(1,"foothold-files",ReleaseTag,blobs.AsReadOnly(),"foothold-author-files-v1",targets.AsReadOnly());
        var payload = root.GetProperty("payload"); Shape(payload,"name","length","sha256");
        var name = Text(payload,"name");
        if (name != "Foothold-files-" + ReleaseTag + ".zip") throw Invalid("Payload name differs from release.");
        var payloadLength = Length(payload,"length");
        if (payloadLength == 0) throw Invalid("Payload ZIP must not be empty.");
        Payload = new(name,payloadLength,HashText(payload,"sha256"));
        // Header normalization is a hint only; exact wire/global identities above stay unchanged.
        SupportedReleaseTags = System.Collections.Frozen.FrozenSet.ToFrozenSet(targets.SelectMany(t=>t.SupportedSources)
            .Select(s=>ConfigDocument.ParseMissionReleaseTag("-- Foothold release: "+s.SourceReleaseTag)!),StringComparer.Ordinal);
        RawJson = rawJson;
    }
    internal static FilePatchEnvelope Parse(ReadOnlyMemory<byte> bytes, string? releaseTag = null)
    {
        if (bytes.Length > MaximumBytes || bytes.Span.StartsWith(new byte[] {239,187,191})) throw Invalid("Invalid envelope encoding/size.");
        FilePatchEnvelope envelope;
        try { envelope = new(new System.Text.UTF8Encoding(false,true).GetString(bytes.Span)); }
        catch (Exception error) when (error is System.Text.Json.JsonException or InvalidOperationException or KeyNotFoundException or ArgumentException or FormatException or OverflowException)
        { throw Invalid("Invalid schema1 envelope: " + error.Message); }
        if (releaseTag is not null && envelope.ReleaseTag != releaseTag) throw Invalid("Envelope release differs.");
        return envelope;
    }
    internal byte[] GetContractBytes()
    {
        return System.Text.Encoding.UTF8.GetBytes(RawJson.Substring(_contractOffset, _contractLength));
    }
    internal static string Digest(ReadOnlySpan<byte> bytes) => Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(bytes)).ToLowerInvariant();
    private static InvalidDataException Invalid(string message) => new(message);
    private static void Shape(System.Text.Json.JsonElement element, params string[] fields)
    {
        if (element.ValueKind != System.Text.Json.JsonValueKind.Object) throw Invalid("Expected object.");
        var seen = new HashSet<string>(StringComparer.Ordinal);
        foreach (var p in element.EnumerateObject()) if (!fields.Contains(p.Name,StringComparer.Ordinal) || !seen.Add(p.Name)) throw Invalid("Unknown/duplicate property: " + p.Name);
        if (seen.Count != fields.Length) throw Invalid("Missing property.");
    }
    private static string Text(System.Text.Json.JsonElement e,string name)
    {
        var p=e.GetProperty(name);
        if (p.ValueKind != System.Text.Json.JsonValueKind.String || p.GetString() is not { Length: > 0 and <= 1024 } text) throw Invalid("Invalid " + name);
        return text;
    }
    private static string HashText(System.Text.Json.JsonElement e,string name)
    { var text=Text(e,name); if (text.Length!=64 || text.Any(c => c is not (>= '0' and <= '9') and not (>= 'a' and <= 'f'))) throw Invalid("Invalid digest."); return text; }
    private static string Tag(System.Text.Json.JsonElement e,string name)
    { var text=Text(e,name); if (!text.StartsWith('v') || !ManagerBuildInfo.TryParseReleaseVersion(text[1..],out var version)
            || "v"+version.ToString(text.Split('.').Length)!=text) throw Invalid("Noncanonical release tag."); return text; }
    private static string ScriptVersion(System.Text.Json.JsonElement e,string name)
    { var text=Text(e,name); if (!ManagerBuildInfo.TryParseReleaseVersion(text,out var version) || version.ToString(text.Split('.').Length)!=text) throw Invalid("Invalid script version."); return text; }
    private static long Length(System.Text.Json.JsonElement e,string name)
    { if (!e.GetProperty(name).TryGetInt64(out var value) || value < 0 || value > MissionReleaseAsset.MaximumSize) throw Invalid("Invalid length."); return value; }
    private static string SafePath(System.Text.Json.JsonElement e,string name)
    { var path=Text(e,name); if (path.Contains('\\') || path.Contains(':') || path.StartsWith('/') || path.Split('/').Any(s=>s is "" or "." or ".." || s.Any(c=>char.IsControl(c)) || s.Trim()!=s)) throw Invalid("Unsafe path."); return path; }
    private static System.Text.Json.JsonElement.ArrayEnumerator Array(System.Text.Json.JsonElement e,string name,int maximum)
    { var p=e.GetProperty(name); if (p.ValueKind != System.Text.Json.JsonValueKind.Array || p.GetArrayLength() is < 1 || p.GetArrayLength()>maximum) throw Invalid("Invalid " + name); return p.EnumerateArray(); }
    private static string Reference(System.Text.Json.JsonElement e,string name,IReadOnlyDictionary<string,FilePatchBlob> blobs,string role)
    { var id=Text(e,name); if (!blobs.TryGetValue(id,out var blob) || blob.Role!=role) throw Invalid("Invalid proof reference."); return id; }
}
internal sealed record FilePatchBlob(string Id,string Entry,string Role,long Length,string Sha256);
internal sealed record FilePatchReplacement(string BlobId,string MemberPath,string ResourceKey,string? ConfigVariant);
internal sealed record FilePatchScriptMember(string MemberPath,long Length,string Sha256);
internal sealed record FilePatchSupportedSource(string SourceReleaseTag,string ScriptVersion,string BaseLayoutId,string AuthorSourceMizSha256,IReadOnlyList<FilePatchScriptMember> ScriptMembers);
internal sealed record FilePatchTarget(string FamilyId,string Theatre,string BaseLayoutId,string TargetScriptVersion,string AuthorTargetMizSha256,string MissionProof,string ResourceMapProof,IReadOnlyList<FilePatchReplacement> Replacements,IReadOnlyList<FilePatchSupportedSource> SupportedSources);
internal sealed record FilePatchContract(int SchemaVersion,string Kind,string ReleaseTag,IReadOnlyList<FilePatchBlob> Blobs,string ComparisonPolicyId,IReadOnlyList<FilePatchTarget> Targets);
internal sealed record FilePatchPayload(string Name,long Length,string Sha256);
internal sealed class FilePatchEnvelopeCacheConverter : System.Text.Json.Serialization.JsonConverter<FilePatchEnvelope>
{
    public override FilePatchEnvelope Read(ref System.Text.Json.Utf8JsonReader reader, Type type, System.Text.Json.JsonSerializerOptions options)
    {
        using var doc = System.Text.Json.JsonDocument.ParseValue(ref reader);
        try
        {
            if (doc.RootElement.ValueKind != System.Text.Json.JsonValueKind.Object
                || doc.RootElement.EnumerateObject().Count() != 1
                || !doc.RootElement.TryGetProperty("RawJson",out var raw) || raw.ValueKind != System.Text.Json.JsonValueKind.String)
                throw new InvalidDataException("Missing exact envelope cache bytes.");
            var text=raw.GetString()!;
            return FilePatchEnvelope.Parse(System.Text.Encoding.UTF8.GetBytes(text));
        }
        catch (Exception error) when (error is InvalidDataException or System.Text.Json.JsonException or ArgumentException or InvalidOperationException or KeyNotFoundException or FormatException or OverflowException)
        { return null!; } // Drop only this optional cache value; business history stays readable.
    }
    public override void Write(System.Text.Json.Utf8JsonWriter writer,FilePatchEnvelope value,System.Text.Json.JsonSerializerOptions options)
    { writer.WriteStartObject(); writer.WriteString("RawJson",value.RawJson); writer.WriteEndObject(); }
}

// Immutable caller snapshots. Discovery and inspection happen only on explicit preparation/refresh.
internal sealed record MissionFilesApplyItem(string SourcePath, string? OutputPath, string? Sha256, string? Error)
{
    public IReadOnlyDictionary<string, string> ConfigSha256 { get; init; } = new Dictionary<string, string>();
}
internal sealed record MissionFilesApplyResult(IReadOnlyList<MissionFilesApplyItem> Items, bool Cancelled);
internal sealed record MissionFilesRoot(string Id, string Name, string MissionsDirectory)
{
    public bool IncludeDcsServerBotOriginals { get; init; }
}
internal sealed record MissionFilesGroup(string Id, string Name, string Directory, string Status)
{
    public bool HasDcsServerBotFolder { get; init; }
}
internal sealed record MissionFilesTargetProof(FilePatchTarget Target,
    IReadOnlyDictionary<string, MissionScriptReferenceFacts.Binding> Bindings,
    IReadOnlyDictionary<string, string> ExecutionFacts);
internal sealed record MissionFilesPreparedRow(MissionPathIdentity Identity, DateTime LastWriteTimeUtc,
    FilePatchTarget Target, IReadOnlyList<MissionArchiveMember> Members,
    IReadOnlyList<PreparedConfigMember> ConfigMembers,
    IReadOnlyDictionary<string, MissionScriptReferenceFacts.Binding> Bindings)
{
    public IReadOnlyList<string> SourceScriptVersions { get; init; } = [];
    public string? DefaultOutputDirectory { get; init; }
}
internal sealed record MissionFilesPreparation(IReadOnlyList<FileUpdateInspection> Rows,
    IReadOnlyList<MissionFilesGroup> Groups, IReadOnlyDictionary<string, MissionFilesPreparedRow> Compatible);
internal sealed record MissionFilesWork(int Downloads, int Inventories, int Archives, int LiteralParses, int BodyParses, int BodyReuses, int TaskExtractions, int TaskBodyHashes, int TaskBodyReuses);

// One release/payload and row cache; no UI callbacks or destination writes belong to this owner.
internal sealed class MissionFileUpdateService : IDisposable
{
    private readonly MissionDownloadService _transport;
    private readonly MissionPackageLimits _limits;
    private readonly string _stageParent;
    private PreparedMissionDownload? _quota;
    private (long Id, string Tag, string Payload, string Contract)? _key;
    private string? _inventoryKey;
    private string? _admittedEnvelope;
    private MissionReleaseAsset? _admittedAsset;
    private readonly Dictionary<string, (long Length, DateTime Time, FileUpdateInspection View, MissionFilesPreparedRow? Facts)> _rows = new(StringComparer.OrdinalIgnoreCase);
    private FilePatchContract? _contract;
    private IReadOnlyList<MissionFilesTargetProof> _proofs = [];
    private IReadOnlyDictionary<string, byte[]> _payload = new Dictionary<string, byte[]>();
    private bool _busy, _disposed;
    private int _downloads, _inventories, _archives, _literalParses, _bodyParses, _bodyReuses;
    private int _taskExtractions, _taskBodyHashes, _taskBodyReuses;
    internal MissionFilesWork Work => new(_downloads, _inventories, _archives, _literalParses, _bodyParses, _bodyReuses, _taskExtractions, _taskBodyHashes, _taskBodyReuses);
    internal long CapturedBytes => _quota?.CapturedBytes ?? 0;
    internal long StagedBytes => _quota?.StagedBytes ?? 0;
    internal IReadOnlyDictionary<string, byte[]> Payload => _payload;
    internal MissionFilesPreparation? Prepared { get; private set; }
    internal MissionFileUpdateService()
    {
        _limits = MissionPackageLimits.Default;
        _stageParent = Path.Combine(Path.GetTempPath(), "Foothold-FilesUpdates");
        _transport = new();
    }
    internal MissionFileUpdateService(System.Net.Http.HttpClient client, string stageParent, MissionPackageLimits? limits = null)
    {
        _limits = limits ?? MissionPackageLimits.Default;
        _stageParent = Path.GetFullPath(stageParent);
        _transport = new(client, _stageParent, _limits);
    }

    internal async Task<MissionFilesPreparation> PrepareAsync(FootholdReleaseInfo release, FilePatchEnvelope envelope,
        IReadOnlyList<MissionFilesRoot> roots, IProgress<FileUpdateInspection> progress, CancellationToken token,
        bool refreshInventory = false, IReadOnlyList<string>? externalPaths = null)
    {
        ObjectDisposedException.ThrowIf(_disposed, this);
        if (_busy) throw new InvalidOperationException("Files preparation is already running.");
        token.ThrowIfCancellationRequested();
        // The checker supplies an admitted canonical same-release JSON asset, never a manifest URL.
        var asset = release.FilesEnvelopeAsset ?? throw new InvalidDataException("Missing admitted envelope asset.");
        var canonical = new Uri("https://github.com/leka1986/Lekas-Foothold/releases/download/" + release.Tag + "/foothold-files.json");
        var inputs = roots.Select(r => r with { MissionsDirectory = Path.GetFullPath(r.MissionsDirectory) }).ToArray();
        var external = (externalPaths ?? []).Select(Path.GetFullPath).Distinct(StringComparer.OrdinalIgnoreCase).ToArray();
        var inventoryKey = System.Text.Json.JsonSerializer.Serialize(new { inputs, external });
        var key = (release.Id, release.Tag, envelope.Payload.Sha256, envelope.ContractSha256);
        if (_key == key && _inventoryKey == inventoryKey && Prepared is not null && !refreshInventory
            && _admittedEnvelope == envelope.RawJson && _admittedAsset == asset) return Prepared;
        var envelopeBytes = System.Text.Encoding.UTF8.GetBytes(envelope.RawJson);
        if (envelope.ReleaseTag != release.Tag || asset.DownloadUri != canonical || asset.Name != "foothold-files.json"
            || asset.Size != envelopeBytes.LongLength || asset.Sha256 != FilePatchEnvelope.Digest(envelopeBytes))
            throw new InvalidDataException("The envelope differs from its admitted release identity.");
        Prepared = null; _inventoryKey = null;
        _busy = true;
        try
        {
            if (_key != key)
            {
                Clear();
                var directory = Path.Combine(_stageParent, Guid.NewGuid().ToString("N"));
                Directory.CreateDirectory(directory);
                _quota = new(directory, _limits);
                try
                {
                    _quota.ReserveStagedBytes(envelope.Payload.Length);
                    var path = Path.Combine(directory, "payload.zip");
                    var uri = new Uri(canonical, Uri.EscapeDataString(envelope.Payload.Name));
                    _downloads++;
                    var digest = await _transport.DownloadAsync(uri, envelope.Payload.Length, envelope.Payload.Sha256, path, token).ConfigureAwait(false);
                    await Task.Run(() => AdmitPayload(envelope, path, digest, token), token).ConfigureAwait(false);
                    _key = key;
                }
                catch { Clear(); throw; }
            }
            var result = await Task.Run(() => Inventory(inputs, external, progress, token), token).ConfigureAwait(false);
            Prepared = result;
            _inventoryKey = inventoryKey;
            _admittedEnvelope = envelope.RawJson; _admittedAsset = asset;
            return result;
        }
        finally { _busy = false; }
    }

    internal const string ReceiptPath = "l10n/DEFAULT/foothold-files-receipt.json";
    internal Task<MissionFilesApplyResult> ApplyAsync(MissionFilesPreparation preparation,
        IReadOnlyList<string> selectedPaths, Func<PreparedConfigMember, byte[], string, byte[]> merge,
        IProgress<MissionFilesApplyItem> progress, CancellationToken token) =>
        ApplyWithOutputDirectoryAsync(preparation, selectedPaths, merge, progress, token, null);

    internal Task<MissionFilesApplyResult> ApplyWithOutputDirectoryAsync(MissionFilesPreparation preparation,
        IReadOnlyList<string> selectedPaths, Func<PreparedConfigMember, byte[], string, byte[]> merge,
        IProgress<MissionFilesApplyItem> progress, CancellationToken token, string? outputDirectory) =>
        ApplyWithOutputNamesAsync(preparation, selectedPaths, merge, progress, token, outputDirectory, null);

    internal async Task<MissionFilesApplyResult> ApplyWithOutputNamesAsync(MissionFilesPreparation preparation,
        IReadOnlyList<string> selectedPaths, Func<PreparedConfigMember, byte[], string, byte[]> merge,
        IProgress<MissionFilesApplyItem> progress, CancellationToken token, string? outputDirectory,
        IReadOnlyDictionary<string, string>? outputNames)
    {
        ObjectDisposedException.ThrowIf(_disposed, this);
        if (_busy) throw new InvalidOperationException("A files-only operation is already running.");
        if (!ReferenceEquals(preparation, Prepared) || _key is null) throw new InvalidDataException("Prepare this release and inventory again.");
        var rows = selectedPaths.Select(Path.GetFullPath).Distinct(StringComparer.OrdinalIgnoreCase).Select(path =>
        {
            if (!preparation.Compatible.TryGetValue(path, out var row) || !_rows.TryGetValue(path, out var cached)
                || !ReferenceEquals(row, cached.Facts)) throw new InvalidDataException("The selected row is not owned by this preparation: " + path);
            return row;
        }).ToArray();
        string? directory = null;
        if (outputDirectory is not null)
        {
            if (!Path.IsPathFullyQualified(outputDirectory) || !Directory.Exists(outputDirectory))
                throw new DirectoryNotFoundException("Choose an available custom mission output folder.");
            directory = Path.GetFullPath(outputDirectory);
            var cleanupRoot = Path.TrimEndingDirectorySeparator(Path.GetFullPath(_stageParent));
            if (directory.Equals(cleanupRoot, StringComparison.OrdinalIgnoreCase)
                || directory.StartsWith(cleanupRoot + Path.DirectorySeparatorChar, StringComparison.OrdinalIgnoreCase))
                throw new InvalidDataException("Choose an output folder outside the temporary files-only preparation folder.");
        }
        Dictionary<string, string>? names = null;
        if (outputNames is not null)
        {
            if (outputNames.Count != rows.Length)
                throw new InvalidDataException("Choose one output filename for each selected mission, without extra missions.");
            names = new(StringComparer.OrdinalIgnoreCase);
            foreach (var row in rows)
            {
                if (!outputNames.TryGetValue(row.Identity.Path, out var requested))
                    throw new InvalidDataException("Choose an output filename for each selected mission.");
                var name = WeatherExportNames.Normalize(requested, row.Identity.Path,
                    directory ?? row.DefaultOutputDirectory ?? Path.GetDirectoryName(row.Identity.Path)!, keepBoth: false);
                if (name.Length > 255) throw new InvalidDataException("The mission filename is too long. Choose a shorter name.");
                names.Add(row.Identity.Path, name);
            }
        }
        _busy = true;
        try
        {
            return await Task.Run(() =>
            {
                var results = new List<MissionFilesApplyItem>();
                var cancelled = false;
                foreach (var row in rows)
                {
                    if (token.IsCancellationRequested) { cancelled = true; break; }
                    MissionFilesApplyItem item;
                    try { item = WriteCopy(row, merge, token, directory ?? row.DefaultOutputDirectory ?? Path.GetDirectoryName(row.Identity.Path)!, names?[row.Identity.Path]); }
                    catch (OperationCanceledException) when (token.IsCancellationRequested) { cancelled = true; break; }
                    catch (Exception error) when (error is InvalidDataException or IOException or UnauthorizedAccessException or InvalidOperationException or ArgumentException or System.Text.DecoderFallbackException)
                    { item = new(row.Identity.Path, null, null, error.Message); }
                    results.Add(item);
                    // Move is the commit point. Report it before observing subsequent cancellation.
                    progress.Report(item);
                }
                return new MissionFilesApplyResult(results.AsReadOnly(), cancelled || token.IsCancellationRequested);
            }).ConfigureAwait(false);
        }
        finally { _busy = false; }
    }

    private MissionFilesApplyItem WriteCopy(MissionFilesPreparedRow row,
        Func<PreparedConfigMember, byte[], string, byte[]> merge, CancellationToken token, string outputDirectory, string? outputName)
    {
        using var source = new FileStream(row.Identity.Path, FileMode.Open, FileAccess.Read, FileShare.Read);
        try { row.Identity.RequireUnchanged(); }
        catch (InvalidDataException) { Evict(row.Identity.Path); Prepared = null; throw; }
        var expected = new Dictionary<string, byte[]>(StringComparer.Ordinal);
        var captureStart = _quota!.CapturedBytes;
        var stageStart = _quota.StagedBytes;
        string? stage = null;
        var stageOwned = false;
        var scratchOwned = false;
        var scratch = Path.Combine(_quota.StageDirectory, "merge-" + Guid.NewGuid().ToString("N") + ".lua");
        try
        {
            foreach (var replacement in row.Target.Replacements)
            {
                token.ThrowIfCancellationRequested();
                var bytes = _payload[replacement.BlobId];
                var blob = _contract!.Blobs.Single(b => b.Id == replacement.BlobId);
                if (bytes.LongLength != blob.Length || FilePatchEnvelope.Digest(bytes) != blob.Sha256)
                    throw new InvalidDataException("The retained payload changed.");
                if (replacement.ConfigVariant is not null)
                {
                    var current = row.ConfigMembers.Single(c => c.Name == replacement.MemberPath && c.Variant == replacement.ConfigVariant);
                    if (!FilePatchEnvelope.Digest(current.Bytes).Equals(current.Sha256, StringComparison.OrdinalIgnoreCase))
                        throw new InvalidDataException("The embedded Config snapshot changed.");
                    _quota.ReserveStagedBytes(_limits.MemberBytes); // Bound the serializer's transient working snapshot.
                    try
                    {
                        using (new FileStream(scratch, FileMode.CreateNew, FileAccess.Write, FileShare.None)) { scratchOwned = true; }
                        bytes = merge(current, bytes, scratch);
                        if (bytes.LongLength > _limits.MemberBytes || new FileInfo(scratch).Length != bytes.LongLength)
                            throw new InvalidDataException("The merged Config exceeds its working-snapshot limit.");
                    }
                    finally
                    {
                        try { if (scratchOwned && File.Exists(scratch)) File.Delete(scratch); scratchOwned = false; }
                        finally { _quota.StagedBytes -= _limits.MemberBytes; }
                    }
                    var configText = new System.Text.UTF8Encoding(false, true).GetString(bytes);
                    if (ConfigDocument.ParseMissionReleaseTag(configText.Split('\n', 2)[0].TrimEnd('\r')) != ConfigDocument.ParseMissionReleaseTag("-- Foothold release: " + _key!.Value.Tag))
                        throw new InvalidDataException("The merged Config has the wrong global release stamp.");
                    if (LuaSyntaxValidator.Validate(configText, current.Variant).Count != 0)
                        throw new InvalidDataException("The merged Config contains invalid Lua.");
                    _quota.ReserveCapturedBytes(bytes.LongLength);
                }
                expected.Add(replacement.MemberPath, bytes);
            }
            var receipt = System.Text.Json.JsonSerializer.SerializeToUtf8Bytes(new
            {
                schemaVersion = 1, familyId = row.Target.FamilyId, baseLayoutId = row.Target.BaseLayoutId,
                scriptVersion = row.Target.TargetScriptVersion, releaseTag = _key!.Value.Tag, payloadSha256 = _key.Value.Payload
            });
            expected.Add(ReceiptPath, receipt);
            var expectedHashes = expected.ToDictionary(p => p.Key, p => FilePatchEnvelope.Digest(p.Value), StringComparer.Ordinal);
            // Reserve an upper bound before AtomicFile creates its adjacent temporary file.
            var bound = checked(source.Length + expected.Values.Sum(b => 2L * b.Length) + row.Members.Count * 1024L + 65536L);
            _quota.ReserveStagedBytes(bound);
            stage = Path.Combine(outputDirectory, Path.GetFileName(row.Identity.Path) + ".foothold-stage-" + Guid.NewGuid().ToString("N"));
            using (new FileStream(stage, FileMode.CreateNew, FileAccess.Write, FileShare.None)) { stageOwned = true; }
            AtomicFile.WriteStaged(stage, temporary =>
            {
                using (var copy = new FileStream(temporary, FileMode.CreateNew, FileAccess.Write, FileShare.None))
                { source.Position = 0; source.CopyTo(copy); }
                token.ThrowIfCancellationRequested();
                using var archive = System.IO.Compression.ZipFile.Open(temporary, System.IO.Compression.ZipArchiveMode.Update);
                var existingReceipt = archive.GetEntry(ReceiptPath);
                if (existingReceipt is not null)
                {
                    if (existingReceipt.Length > 4096) throw new InvalidDataException("Unrecognized reserved receipt member.");
                    try
                    {
                        using var input = existingReceipt.Open();
                        using var json = System.Text.Json.JsonDocument.Parse(input);
                        RequireReceipt(json.RootElement);
                    }
                    catch (Exception error) when (error is System.Text.Json.JsonException or InvalidOperationException or KeyNotFoundException or FormatException)
                    { throw new InvalidDataException("Unrecognized reserved receipt member.", error); }
                }
                foreach (var entry in expected)
                {
                    token.ThrowIfCancellationRequested();
                    var member = archive.GetEntry(entry.Key);
                    if (member is null && entry.Key != ReceiptPath) throw new InvalidDataException("Missing declared replacement member.");
                    member ??= archive.CreateEntry(entry.Key);
                    using var output = member.Open();
                    output.SetLength(0); output.Write(entry.Value);
                }
            });
            var actualLength = new FileInfo(stage).Length;
            if (actualLength > bound) throw new InvalidDataException("Staged MIZ exceeded its reservation.");
            _quota.StagedBytes -= bound - actualLength;
            _archives++;
            var verified = _transport.InspectArchive(stage, _quota, _ => false, true, token);
            var originals = row.Members.ToDictionary(m => m.Name, StringComparer.Ordinal);
            var names = originals.Keys.Append(ReceiptPath).ToHashSet(StringComparer.Ordinal);
            if (!names.SetEquals(verified.Members.Select(m => m.Name))) throw new InvalidDataException("Staged member membership differs.");
            foreach (var member in verified.Members)
            {
                if (expected.TryGetValue(member.Name, out var bytes))
                {
                    if (member.Length != bytes.LongLength || !member.Sha256.Equals(expectedHashes[member.Name], StringComparison.OrdinalIgnoreCase))
                        throw new InvalidDataException("Staged replacement verification failed: " + member.Name);
                }
                else if (member != originals[member.Name]) throw new InvalidDataException("An unowned PLAYER member changed: " + member.Name);
                if (originals.TryGetValue(member.Name, out var original) && (member.Timestamp != original.Timestamp || member.Attributes != original.Attributes))
                    throw new InvalidDataException("Member attributes changed: " + member.Name);
            }
            // The source handle still denies writes/deletion; unchanged PLAYER root/map fingerprints carry the admitted proof.
            var name = outputName ?? ProposeOutputName(row.Identity.Path, row.Target.TargetScriptVersion);
            for (var number = 1; ; number++)
            {
                token.ThrowIfCancellationRequested();
                var final = Path.Combine(outputDirectory, WeatherExportNames.NumberedName(name, number));
                try
                {
                    File.Move(stage!, final, overwrite: false);
                    stage = null;
                    return new(row.Identity.Path, final, verified.Sha256, null)
                    {
                        ConfigSha256 = System.Collections.Frozen.FrozenDictionary.ToFrozenDictionary(row.Target.Replacements.Where(r => r.ConfigVariant is not null)
                            .ToDictionary(r => r.ConfigVariant!, r => expectedHashes[r.MemberPath], StringComparer.Ordinal), StringComparer.Ordinal)
                    };
                }
                catch (IOException) when (File.Exists(final)) { } // Retry this SAME verified stage only.
            }
        }
        finally
        {
            try
            {
                if (stageOwned && stage is not null && File.Exists(stage)) File.Delete(stage);
                if (scratchOwned && File.Exists(scratch)) File.Delete(scratch);
            }
            finally
            {
                _quota.ReleaseCapturedBytes(_quota.CapturedBytes - captureStart);
                _quota.StagedBytes = stageStart;
            }
        }
    }
    private static void RequireReceipt(System.Text.Json.JsonElement root)
    {
        var fields = new[] { "schemaVersion", "familyId", "baseLayoutId", "scriptVersion", "releaseTag", "payloadSha256" };
        var properties = root.EnumerateObject().ToArray();
        if (properties.Length != fields.Length || !properties.Select(p => p.Name).ToHashSet(StringComparer.Ordinal).SetEquals(fields)
            || root.GetProperty("schemaVersion").GetInt32() != 1
            || fields.Skip(1).Any(f => root.GetProperty(f).ValueKind != System.Text.Json.JsonValueKind.String || string.IsNullOrWhiteSpace(root.GetProperty(f).GetString()))
            || !ManagerBuildInfo.TryParseReleaseVersion(root.GetProperty("scriptVersion").GetString()!, out _)
            || ConfigDocument.ParseMissionReleaseTag("-- Foothold release: " + root.GetProperty("releaseTag").GetString()) is null
            || root.GetProperty("payloadSha256").GetString() is not { Length: 64 } digest
            || digest.Any(c => c is not (>= '0' and <= '9') and not (>= 'a' and <= 'f')))
            throw new InvalidDataException("Unrecognized reserved receipt member.");
    }
    private void AdmitPayload(FilePatchEnvelope envelope, string path, string digest, CancellationToken token)
    {
        var declared = envelope.Contract.Blobs.ToDictionary(b => b.Entry, StringComparer.Ordinal);
        _archives++;
        var archive = _transport.InspectArchive(path, _quota!, n => n == "contract.json" || declared.ContainsKey(n), false, token, digest);
        if (archive.Members.Count != declared.Count + 1 || archive.Members.Any(m => m.Name != "contract.json" && !declared.ContainsKey(m.Name))
            || !archive.Captures.TryGetValue("contract.json", out var contract) || !contract.AsSpan().SequenceEqual(envelope.GetContractBytes()))
            throw new InvalidDataException("Payload members or exact contract bytes differ from the envelope.");
        foreach (var member in archive.Members)
        {
            MissionScriptReferenceFacts.SafePath(member.Name);
            if (member.Name == "contract.json") continue;
            var blob = declared[member.Name];
            if (member.Length != blob.Length || !member.Sha256.Equals(blob.Sha256, StringComparison.OrdinalIgnoreCase))
                throw new InvalidDataException("Payload blob differs from its declared length/digest.");
        }
        var blobs = envelope.Contract.Blobs.ToDictionary(b => b.Id, b => archive.Captures[b.Entry], StringComparer.Ordinal);
        var proofs = new List<MissionFilesTargetProof>();
        foreach (var target in envelope.Contract.Targets)
        {
            token.ThrowIfCancellationRequested();
            var names = target.SupportedSources.SelectMany(s => s.ScriptMembers.Select(m => m.MemberPath))
                .Concat(target.Replacements.Select(r => r.MemberPath)).ToHashSet(StringComparer.Ordinal);
            var (theatre, facts, execution) = ReadProof(blobs[target.MissionProof], blobs[target.ResourceMapProof], names, trustedPayload: true);
            if (theatre != target.Theatre || target.Replacements.Any(r => !facts.Bindings.TryGetValue(r.ResourceKey, out var b) || b.MemberPath != r.MemberPath))
                throw new InvalidDataException("Target proof does not bind the declared replacements/theatre.");
            proofs.Add(new(target, facts.BindingsByMember, execution));
        }
        var retained = envelope.Contract.Blobs.Where(b => b.Role is "script" or "config")
            .ToDictionary(b => b.Id, b => blobs[b.Id], StringComparer.Ordinal);
        _quota!.ReleaseCapturedBytes(archive.Captures.Values.Sum(b => (long)b.Length) - retained.Values.Sum(b => (long)b.Length));
        _payload = System.Collections.Frozen.FrozenDictionary.ToFrozenDictionary(retained, StringComparer.Ordinal);
        _proofs = proofs.AsReadOnly();
        _contract = envelope.Contract;
    }

    private MissionFilesPreparation Inventory(MissionFilesRoot[] roots, string[] external,
        IProgress<FileUpdateInspection> progress, CancellationToken token)
    {
        var groups = new List<MissionFilesGroup>();
        var views = new List<FileUpdateInspection>();
        var paths = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var directories = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var explicitlyAdded = external.ToHashSet(StringComparer.OrdinalIgnoreCase);
        bool IsCandidate(string path) => Path.GetFileName(path).Contains("Foothold", StringComparison.OrdinalIgnoreCase)
            || explicitlyAdded.Contains(path);
        foreach (var root in roots)
        {
            token.ThrowIfCancellationRequested();
            if (!directories.Add(Path.TrimEndingDirectorySeparator(root.MissionsDirectory))) continue;
            var botFolder = Path.Combine(root.MissionsDirectory, ".dcssb");
            var hasBotFolder = false;
            try
            {
                _inventories++;
                hasBotFolder = Directory.Exists(botFolder);
                var sources = MissionWarehouseService.DiscoverSources(root.MissionsDirectory, token)
                    .Where(source => IsCandidate(source.Path)).ToArray();
                groups.Add(new(root.Id, root.Name, root.MissionsDirectory, sources.Length == 0 ? "No MIZ files" : sources.Length + " MIZ files")
                { HasDcsServerBotFolder = hasBotFolder });
                foreach (var source in sources) Add(source, root.Id, root.Name, root.MissionsDirectory);
                if (root.IncludeDcsServerBotOriginals && hasBotFolder)
                {
                    _inventories++;
                    var sourceCount = sources.Length;
                    foreach (var path in Directory.EnumerateFiles(botFolder, "*.miz.orig", SearchOption.TopDirectoryOnly))
                    {
                        token.ThrowIfCancellationRequested();
                        if (!IsCandidate(path)) continue;
                        sourceCount++;
                        var info = new FileInfo(path);
                        try { Add(new(info.FullName, info.LastWriteTimeUtc, info.Length), root.Id, root.Name, botFolder, root.MissionsDirectory); }
                        catch (Exception error) when (error is IOException or UnauthorizedAccessException)
                        {
                            Evict(path);
                            if (paths.Add(path)) views.Add(new(path, root.Id, root.Name, botFolder, "DCSServerBot original · " + Path.GetFileName(path), FileUpdateInspectionState.Error, error.Message, null));
                        }
                    }
                    groups[^1] = groups[^1] with { Status = sourceCount == 0 ? "No MIZ files" : sourceCount + " MIZ files" };
                }
            }
            catch (Exception error) when (error is IOException or UnauthorizedAccessException)
            {
                groups.RemoveAll(group => group.Id == root.Id);
                groups.Add(new(root.Id, root.Name, root.MissionsDirectory, error.Message) { HasDcsServerBotFolder = hasBotFolder });
            }
        }
        foreach (var path in external)
        {
            token.ThrowIfCancellationRequested();
            if (path.EndsWith(".orig", StringComparison.OrdinalIgnoreCase))
            {
                if (!paths.Add(path)) continue;
                Evict(path);
                views.Add(new(path, "external", "Added missions", "No instance Config owner", Path.GetFileName(path), FileUpdateInspectionState.Unknown,
                    "Enable DCSServerBot originals for this file's discovered owning Missions folder.", null));
                continue;
            }
            var info = new FileInfo(path);
            try { Add(new(path, info.LastWriteTimeUtc, info.Length), "external", "Added missions", "No instance Config owner"); }
            catch (Exception error) when (error is IOException or UnauthorizedAccessException)
            { views.Add(new(path, "external", "Added missions", "No instance Config owner", Path.GetFileName(path), FileUpdateInspectionState.Error, error.Message, null)); }
        }
        foreach (var path in _rows.Keys.Where(p => !paths.Contains(p)).ToArray()) Evict(path);
        var compatible = _rows.Where(p => paths.Contains(p.Key) && p.Value.Facts is not null).ToDictionary(p => p.Key, p => p.Value.Facts!, StringComparer.OrdinalIgnoreCase);
        return new(views.AsReadOnly(), groups.AsReadOnly(), System.Collections.Frozen.FrozenDictionary.ToFrozenDictionary(compatible, StringComparer.OrdinalIgnoreCase));

        void Add(MissionWarehouseSource source, string id, string name, string summary, string? defaultOutputDirectory = null)
        {
            token.ThrowIfCancellationRequested();
            if (!paths.Add(source.Path)) return;
            if (_rows.TryGetValue(source.Path, out var cached) && cached.Length == source.Length && cached.Time == source.LastWriteTimeUtc && cached.View.State != FileUpdateInspectionState.Error)
            {
                var facts = cached.Facts;
                if (facts is not null && facts.DefaultOutputDirectory != defaultOutputDirectory)
                    facts = facts with { DefaultOutputDirectory = defaultOutputDirectory };
                var projected = cached.View with { GroupId = id, GroupName = name, GroupSummary = summary,
                    FriendlyName = (defaultOutputDirectory is null ? "" : "DCSServerBot original · ") + Path.GetFileName(source.Path) };
                _rows[source.Path] = (cached.Length, cached.Time, projected, facts);
                views.Add(projected);
                return;
            }
            Evict(source.Path);
            var checking = new FileUpdateInspection(source.Path, id, name, summary,
                (defaultOutputDirectory is null ? "" : "DCSServerBot original · ") + Path.GetFileName(source.Path), FileUpdateInspectionState.Checking, "Checking mission scripts and references", null);
            progress.Report(checking);
            var before = _quota!.CapturedBytes;
            MissionFilesPreparedRow? row = null;
            FileUpdateInspection view;
            try
            {
                _archives++;
                var archive = _transport.InspectArchive(source.Path, _quota, n => n is "mission" or "l10n/DEFAULT/mapResource" || IsConfig(n), true, token);
                foreach (var member in archive.Members) MissionScriptReferenceFacts.SafePath(member.Name);
                if (!archive.Captures.TryGetValue("l10n/DEFAULT/mapResource", out var map)) throw new InvalidDataException("Missing resource map.");
                var members = archive.Members.ToDictionary(m => m.Name, StringComparer.Ordinal);
                var (theatre, facts, execution) = ReadProof(archive.Captures["mission"], map, members.Keys.ToHashSet(StringComparer.Ordinal));
                var matches = _proofs.Select(p => (Proof: p, Sources: p.Target.Theatre == theatre
                    ? p.Target.SupportedSources.Where(s => s.ScriptMembers.All(m => members.TryGetValue(m.MemberPath, out var actual)
                        && actual.Length == m.Length && actual.Sha256.Equals(m.Sha256, StringComparison.OrdinalIgnoreCase))).ToArray() : []))
                    .Where(p => p.Sources.Length > 0 && SameFacts(p.Proof.ExecutionFacts, execution)
                        && p.Proof.Bindings.Keys.ToHashSet(StringComparer.Ordinal).SetEquals(facts.BindingsByMember.Keys)).ToArray();
                if (matches.Length != 1) throw new InvalidDataException(matches.Length == 0 ? "No certified complete script cohort and owned-reference match." : "Ambiguous family/target proof.");
                var target = matches[0].Proof.Target;
                if (target.Replacements.Any(r => !members.ContainsKey(r.MemberPath))) throw new InvalidDataException("Missing replacement member.");
                var outputName = ProposeOutputName(source.Path, target.TargetScriptVersion);
                var configs = archive.Captures.Where(p => IsConfig(p.Key)).Select(p => new PreparedConfigMember(p.Key,
                    RuntimeSettings.SupportedConfigFileNames.First(n => Path.GetFileName(p.Key).Equals(n, StringComparison.OrdinalIgnoreCase)), p.Value, members[p.Key].Sha256)).ToArray();
                var after = new FileInfo(source.Path);
                if (archive.Length != source.Length || after.Length != source.Length || after.LastWriteTimeUtc != source.LastWriteTimeUtc)
                    throw new InvalidDataException("Mission changed during inspection; refresh this path.");
                row = new(new(source.Path, true, archive.Length, archive.Sha256), source.LastWriteTimeUtc, target, archive.Members, Array.AsReadOnly(configs), facts.BindingsByMember)
                { SourceScriptVersions = Array.AsReadOnly(matches[0].Sources.Select(source => source.ScriptVersion).Distinct(StringComparer.Ordinal).ToArray()),
                    DefaultOutputDirectory = defaultOutputDirectory };
                view = checking with { State = FileUpdateInspectionState.Compatible, Reason = target.FamilyId + " · certified script content → " + target.TargetScriptVersion,
                    ProposedOutputName = outputName };
            }
            catch (Exception error) when (error is InvalidDataException or IOException or UnauthorizedAccessException or ArgumentException or System.Text.DecoderFallbackException)
            { view = checking with { State = error is IOException or UnauthorizedAccessException ? FileUpdateInspectionState.Error : FileUpdateInspectionState.Unknown, Reason = error.Message }; }
            finally { _quota.ReleaseCapturedBytes(_quota.CapturedBytes - before - (row?.ConfigMembers.Sum(c => (long)c.Bytes.Length) ?? 0)); }
            _rows[source.Path] = (source.Length, source.LastWriteTimeUtc, view, row);
            views.Add(view);
            progress.Report(view);
        }
    }

    private (string Theatre, MissionScriptReferenceFacts.Result Bindings, IReadOnlyDictionary<string, string> Execution) ReadProof(byte[] missionBytes, byte[] mapBytes, IReadOnlySet<string> members, bool trustedPayload = false)
    {
        var mission = ReadLiteral(missionBytes, "mission");
        var map = ReadLiteral(mapBytes, "mapResource");
        var tasks = trustedPayload ? MissionScriptReferenceFacts.ReadTaskProof(mission) : MissionScriptReferenceFacts.ProduceTasks(mission);
        if (!trustedPayload) { _taskExtractions++; _taskBodyHashes += tasks.BodyHashes; _taskBodyReuses += tasks.BodyReuses; }
        if (tasks.Error is not null) throw new InvalidDataException(tasks.Error);
        var theatre = mission.Get("theatre") as string ?? throw new InvalidDataException("Missing literal theatre.");
        var facts = MissionScriptReferenceFacts.Produce(mission, map, members);
        _bodyParses += facts.BodyParses.Actions + facts.BodyParses.Other; _bodyReuses += facts.BodyParses.Reused;
        if (facts.Error is not null) throw new InvalidDataException(facts.Error);
        // Compare only executable trigger facts and owned references, never PLAYER geometry/settings.
        var normalized = new Dictionary<string, string>(StringComparer.Ordinal);
        foreach (var field in new[] { "theatre", "trig", "trigrules" })
            MissionScriptReferenceFacts.Flatten(mission.Get(field), MissionScriptReferenceFacts.KeyPath("mission", field), normalized, facts.PathOverrides);
        var execution = new Dictionary<string, string>(MissionScriptReferenceFacts.ProjectOwnedReferences(normalized, facts.Bindings.Values), StringComparer.Ordinal);
        foreach (var pair in normalized.Where(p => p.Key.StartsWith("mission[\"trig\"]", StringComparison.Ordinal))) execution[pair.Key] = pair.Value;
        // Editor-only executable additions are also unsupported, even before DCS recompiles them.
        var rules = (LuaDataTable)mission.Get("trigrules")!;
        foreach (var rule in rules.Entries)
        foreach (var field in new[] { "actions", "rules", "predicate", "eventlist" })
        {
            if (rule.Value is not LuaDataTable table) throw new InvalidDataException("Nonliteral editor rule.");
            var prefix = MissionScriptReferenceFacts.KeyPath(MissionScriptReferenceFacts.KeyPath("mission[\"trigrules\"]", rule.Key), field);
            execution[prefix] = normalized.GetValueOrDefault(prefix, "missing");
            foreach (var pair in normalized.Where(p => p.Key.StartsWith(prefix + "[", StringComparison.Ordinal))) execution[pair.Key] = pair.Value;
        }
        execution["taskExecutables-v1"] = MissionScriptReferenceFacts.TaskSignature(tasks);
        return (theatre, facts, System.Collections.Frozen.FrozenDictionary.ToFrozenDictionary(execution, StringComparer.Ordinal));

    }

    // Writer reuses this validated base proposal and NumberedName for Keep Both collisions.
    internal static string ProposeOutputName(string sourcePath, string targetVersion)
    {
        var sourceName = Path.GetFileName(sourcePath);
        if (sourceName.EndsWith(".miz.orig", StringComparison.OrdinalIgnoreCase)) sourceName = sourceName[..^5];
        var tokens = Path.GetFileNameWithoutExtension(sourceName).Split('_');
        var versionIndex = -1;
        for (var i = 0; i < tokens.Length; i++)
        {
            var token = tokens[i];
            var version = token.Length > 0 && token[0] is 'v' or 'V' ? token[1..] : token;
            if (version != version.Trim() || !ManagerBuildInfo.TryParseReleaseVersion(version, out _)) continue;
            if (versionIndex >= 0) throw new InvalidDataException("The mission filename has ambiguous version tokens.");
            versionIndex = i;
        }
        if (versionIndex >= 0)
        {
            var old = tokens[versionIndex];
            tokens[versionIndex] = (old[0] is 'v' or 'V' ? old[..1] : "") + targetVersion;
        }
        var stem = string.Join('_', tokens);
        if (versionIndex < 0) stem += "_" + targetVersion;
        var proposed = stem + Path.GetExtension(sourceName);
        var validated = WeatherExportNames.Normalize(proposed, sourcePath, Path.GetDirectoryName(Path.GetFullPath(sourcePath))!, keepBoth: true);
        if (validated != proposed) throw new InvalidDataException("The proposed mission filename requires unsupported normalization.");
        return validated;
    }

    private LuaDataTable ReadLiteral(byte[] bytes, string name)
    {
        _literalParses++;
        var root = WeatherLua.Parse(new System.Text.UTF8Encoding(false, true).GetString(bytes), name);
        if (root.Statements.Statements.Count != 1 || root.Statements.Statements[0] is not Loretta.CodeAnalysis.Lua.Syntax.AssignmentStatementSyntax assignment
            || assignment.Variables.Count != 1 || assignment.Variables[0] is not Loretta.CodeAnalysis.Lua.Syntax.IdentifierNameSyntax identifier
            || identifier.Identifier.Text != name || assignment.EqualsValues.Values.Count != 1
            || assignment.EqualsValues.Values[0] is not Loretta.CodeAnalysis.Lua.Syntax.TableConstructorExpressionSyntax literal)
            throw new InvalidDataException("Expected one literal assignment in " + name);
        return WeatherLua.ReadTable(literal, rejectDuplicates: true);
    }
    private static bool IsConfig(string path) => RuntimeSettings.SupportedConfigFileNames.Any(n => Path.GetFileName(path).Equals(n, StringComparison.OrdinalIgnoreCase));
    private static bool SameFacts(IReadOnlyDictionary<string, string> expected, IReadOnlyDictionary<string, string> actual)
        => expected.Count == actual.Count && expected.All(p => actual.TryGetValue(p.Key, out var value) && value == p.Value);
    private void Evict(string path)
    {
        if (_rows.Remove(path, out var row) && row.Facts is not null) _quota!.ReleaseCapturedBytes(row.Facts.ConfigMembers.Sum(c => (long)c.Bytes.Length));
    }
    private void Clear()
    {
        Prepared = null; _inventoryKey = null; _key = null; _contract = null; _admittedEnvelope = null; _admittedAsset = null; _rows.Clear(); _proofs = []; _payload = new Dictionary<string, byte[]>();
        if (_quota is null) return;
        _quota.ReleaseCapturedBytes(_quota.CapturedBytes);
        _quota.Dispose();
        if (Directory.Exists(_quota.StageDirectory)) throw new IOException("The previous files-only stage could not be removed: " + _quota.StageDirectory);
        _quota = null;
    }
    public void Dispose()
    {
        if (_busy) throw new InvalidOperationException("Cancel and finish preparation before disposal.");
        Clear(); _transport.Dispose(); _disposed = true;
    }
}
