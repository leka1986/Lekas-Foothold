using System.Drawing.Drawing2D;

namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    // Job-local incoming documents only; every output receives a separate working copy.
    internal static Func<PreparedConfigMember, byte[], string, byte[]> CreateMissionFilesConfigMerger()
    {
        var incoming = new Dictionary<(string Variant, byte[] Bytes), ConfigDocument>();
        return (current, defaults, snapshotPath) =>
        {
            var key = (current.Variant, defaults); // byte[] equality is reference identity; service verified these retained bytes.
            if (!incoming.TryGetValue(key, out var clean))
            {
                clean = ConfigDocument.LoadText(snapshotPath, new System.Text.UTF8Encoding(false, true).GetString(defaults));
                clean.RepairStringListSeparators();
                clean.PrepareTupleChoiceMigration();
                var errors = clean.ValidateForImport(new List<string>());
                if (errors.Count > 0) throw new InvalidDataException(string.Join(Environment.NewLine, errors.Take(8)));
                incoming.Add(key, clean);
            }
            var embedded = ConfigDocument.LoadText(snapshotPath,
                new System.Text.UTF8Encoding(false, true).GetString(current.Bytes), clean.Metadata);
            // No proven previous embedded baseline: reuse the existing nullable-default policy.
            var plan = PrepareInstanceImport(embedded, clean.CreateWorkingCopy(), null, current.Variant);
            ApplyInstanceImportChoices(plan);
            plan.Output.SaveImportedSnapshotTo(snapshotPath, plan.Preview.ImportWarnings);
            return File.ReadAllBytes(snapshotPath);
        };
    }
    // Detached optional plans only. Task6 commits them after an applicable MIZ succeeds.
    private sealed record MissionFilesInstancePlan(string Path, IReadOnlyList<string> SourcePaths,
        InstanceImportPlan? Plan, string? Error)
    {
        public ConfigDocument? CleanSource { get; init; }
        public string? ConfigVariant { get; init; }
        public string? SourceSha256 { get; init; }
    }
    private static IReadOnlyList<MissionFilesInstancePlan> PrepareMissionFilesInstancePlans(
        MissionFilesPreparation preparation, IReadOnlyDictionary<string, byte[]> payload,
        IReadOnlyList<(string SourcePath, MissionConfigTarget Target)> targets, string workingDirectory,
        CancellationToken token)
    {
        var results = new List<MissionFilesInstancePlan>();
        var previousSources = LoadStoredRestoreDefaultsSources();
        var incoming = new Dictionary<string, ConfigDocument>(StringComparer.Ordinal);
        var genericDefaults = new Dictionary<string, byte[]>(StringComparer.Ordinal);
        foreach (var group in targets.GroupBy(t => Path.GetFullPath(t.Target.Path), StringComparer.OrdinalIgnoreCase))
        {
            token.ThrowIfCancellationRequested();
            var paths = group.Select(t => Path.GetFullPath(t.SourcePath)).Distinct(StringComparer.OrdinalIgnoreCase).ToArray();
            try
            {
                var variant = RuntimeSettings.SupportedConfigFileNames.Single(v => v.Equals(Path.GetFileName(group.Key), StringComparison.OrdinalIgnoreCase));
                var candidates = paths.Select(path => preparation.Compatible.TryGetValue(path, out var row)
                    ? row.Target.Replacements.Single(r => r.ConfigVariant == variant).BlobId
                    : throw new InvalidDataException("Optional Config source is not an admitted selected mission."))
                    .Select(id =>
                    {
                        if (!genericDefaults.TryGetValue(id, out var bytes))
                            genericDefaults.Add(id, bytes = MissionVersionStamp.Remove(payload[id]));
                        return bytes;
                    }).DistinctBy(bytes => FilePatchEnvelope.Digest(bytes)).ToArray();
                if (candidates.Length != 1) throw new InvalidDataException("Conflicting incoming defaults for this instance Config.");
                var identity = MissionPathIdentity.Capture(group.Key);
                if (!identity.Exists) throw new InvalidDataException("The optional instance Config is unavailable.");
                var sourceSha256 = FilePatchEnvelope.Digest(candidates[0]);
                var sourceKey = variant + "|" + sourceSha256;
                if (!incoming.TryGetValue(sourceKey, out var clean))
                {
                    clean = ConfigDocument.LoadText(Path.Combine(workingDirectory, sourceSha256, variant), new System.Text.UTF8Encoding(false, true).GetString(candidates[0]));
                    clean.RepairStringListSeparators(); clean.PrepareTupleChoiceMigration();
                    incoming.Add(sourceKey, clean);
                }
                var current = ConfigDocument.LoadText(group.Key, File.ReadAllText(group.Key, new System.Text.UTF8Encoding(false, true)), clean.Metadata);
                identity.RequireUnchanged();
                var previousInfo = SelectStoredMizDefaultsForConfig(previousSources, group.Key);
                var previous = previousInfo is null ? null : TryLoadStoredMizDefaults(previousInfo);
                var plan = PrepareInstanceImport(current, clean.CreateWorkingCopy(), previous, group.First().Target.Name);
                plan.ReviewedIdentity = identity;
                ApplyInstanceImportChoices(plan);
                var errors = plan.Output.ValidateForImport(plan.Preview.ImportWarnings);
                if (errors.Count > 0) throw new InvalidDataException(string.Join(Environment.NewLine, errors.Take(8)));
                results.Add(new(group.Key, Array.AsReadOnly(paths), plan, null)
                { CleanSource = clean, ConfigVariant = variant, SourceSha256 = sourceSha256 });
            }
            catch (Exception error) when (error is InvalidDataException or IOException or UnauthorizedAccessException or InvalidOperationException or ArgumentException or System.Text.DecoderFallbackException)
            { results.Add(new(group.Key, Array.AsReadOnly(paths), null, error.Message)); }
        }
        return results.AsReadOnly();
    }
    private MissionFileUpdateService? _missionFilesService;
    private MissionFilesPreparation? _missionFilesPreparation;
    private MissionFilesPreparation? _missionFilesPresentedPreparation;
    private FootholdReleaseInfo? _missionFilesPreparedRelease;
    private string? _missionFilesPreparedEnvelope;
    private MissionFilesRoot[] _missionFilesPreparedRoots = [];
    private string[] _missionFilesPreparedExternalPaths = [];
    private string[] _missionFilesExternalPaths = [];
    private bool _missionFilesIncludeDcsServerBotOriginals;
    private WeatherCheckBox? _missionFilesDcsServerBotOriginals;
    private IReadOnlyList<string> _missionSourceFolders = Array.Empty<string>();
    private string? _missionSourceFoldersError;
    private Label? _missionFilesResult;
    private FlowLayoutPanel? _missionFilesResultRow;
    private ManagerVerifiedGlyph? _missionFilesResultGlyph;
    private long _missionFilesOperationGeneration;

    private sealed class MissionFilesScanJob(FootholdReleaseInfo release, FilePatchEnvelope envelope,
        MissionFilesRoot[] roots, string[] external, CancellationToken lifetime)
    {
        internal readonly FootholdReleaseInfo Release = release;
        internal readonly FilePatchEnvelope Envelope = envelope;
        internal readonly MissionFilesRoot[] Roots = roots;
        internal readonly string[] External = external;
        internal readonly CancellationTokenSource Cancellation = CancellationTokenSource.CreateLinkedTokenSource(lifetime);
        internal Task<MissionFilesPreparation> Work = null!;
        internal FileUpdateInspection? Latest;
        internal IProgress<FileUpdateInspection>? Observer;
        internal int Waiters;
        internal bool Matches(FootholdReleaseInfo next, FilePatchEnvelope contract, MissionFilesRoot[] folders, string[] paths) =>
            SameMissionFilesRelease(Release, next) && Envelope.RawJson == contract.RawJson
            && Roots.SequenceEqual(folders) && External.SequenceEqual(paths, StringComparer.OrdinalIgnoreCase);
    }
    private MissionFilesScanJob? _missionFilesScan;
    private Task? _missionFilesBackgroundTask;

    private void BeginSilentMissionScan()
    {
        if (_updatesDisposed || IsDisposed || Disposing || !_settings.AutomaticMissionScan
            || _missionFilesBackgroundTask is { IsCompleted: false } || _missionDownloadBusy || _configLoadingOperation || _updatesInstalling
            || _updatesResult is not { FilesEnvelopeAvailable: true } result) return;
        EnsureMissionDownloadLifetime();
        var roots = CaptureMissionRoots(scanSourcesOnly: true);
        var external = CaptureMissionFilesExternalPaths();
        if ((roots.Length == 0 && external.Length == 0) || HasCurrentMissionFilesPreparation(result, roots, external)) return;
        _missionFilesBackgroundTask = ScanSilentlyAsync(result, roots, external);
    }
    private async Task ScanSilentlyAsync(UpdateCheckResult result, MissionFilesRoot[] roots, string[] external)
    {
        try
        {
            var release = result.Foothold.Data!;
            var envelope = result.FilesEnvelope.Data!;
            var prepared = await PrepareMissionFilesSharedAsync(release, envelope, roots, external, null, _updatesLifetime.Token, false);
            if (TryAdoptMissionFilesPreparation(release, envelope, roots, external, prepared))
            {
                RefreshMissionCompletionState();
                RefreshMissionFilesCompletionRows();
                RefreshUpdatesPresentation();
            }
        }
        catch (OperationCanceledException) { }
        catch (Exception error)
        {
            if (!_updatesDisposed && !IsDisposed && !Disposing)
            { _updatesError = "Could not check missions: " + error.Message; RefreshUpdatesPresentation(); }
        }
        finally
        {
            _missionFilesBackgroundTask = null;
            if (_updatesDisposed) DisposeMissionDownloadState();
            if (_missionCloseRequested && !_missionDownloadBusy && !IsDisposed && !Disposing)
            { _missionCloseRequested = false; Close(); }
        }
    }
    private async Task<MissionFilesPreparation> PrepareMissionFilesSharedAsync(FootholdReleaseInfo release, FilePatchEnvelope envelope,
        MissionFilesRoot[] roots, string[] external, IProgress<FileUpdateInspection>? progress, CancellationToken token, bool refreshInventory)
    {
        if (_missionFilesScan is { } previous && !previous.Matches(release, envelope, roots, external))
        {
            previous.Cancellation.Cancel();
            try { await previous.Work; }
            catch (OperationCanceledException) { }
            token.ThrowIfCancellationRequested();
        }
        if (_missionFilesScan is null || !_missionFilesScan.Matches(release, envelope, roots, external))
        {
            var created = new MissionFilesScanJob(release, envelope, roots, external, _updatesLifetime.Token);
            _missionFilesScan = created;
            _missionFilesService ??= new MissionFileUpdateService();
            created.Work = _missionFilesService.PrepareAsync(release, envelope, roots,
                new Progress<FileUpdateInspection>(row => { created.Latest = row; created.Observer?.Report(row); }),
                created.Cancellation.Token, refreshInventory, external);
        }
        var scan = _missionFilesScan;
        scan.Waiters++;
        if (progress is not null) { scan.Observer = progress; if (scan.Latest is not null) progress.Report(scan.Latest); }
        using var cancellation = token.Register(() => scan.Cancellation.Cancel());
        try { return await scan.Work.WaitAsync(token); }
        finally
        {
            cancellation.Dispose();
            if (ReferenceEquals(scan.Observer, progress)) scan.Observer = null;
            if (--scan.Waiters == 0)
            {
                if (!scan.Work.IsCompleted)
                {
                    scan.Cancellation.Cancel();
                    try { await scan.Work; } catch (Exception) { } // Settle abandoned work before the service can be reused/disposed.
                }
                if (ReferenceEquals(_missionFilesScan, scan)) _missionFilesScan = null;
                scan.Cancellation.Dispose();
            }
        }
    }
    private bool TryAdoptMissionFilesPreparation(FootholdReleaseInfo release, FilePatchEnvelope envelope,
        MissionFilesRoot[] roots, string[] external, MissionFilesPreparation prepared)
    {
        if (_updatesDisposed || IsDisposed || Disposing || _updatesResult is not { FilesEnvelopeAvailable: true } current
            || !SameMissionFilesRelease(release, current.Foothold.Data) || current.FilesEnvelope.Data!.RawJson != envelope.RawJson
            || !roots.SequenceEqual(CaptureMissionRoots(scanSourcesOnly: true))
            || !external.SequenceEqual(CaptureMissionFilesExternalPaths(), StringComparer.OrdinalIgnoreCase)
            || !ReferenceEquals(_missionFilesService?.Prepared, prepared)) return false;
        if (!ReferenceEquals(_missionFilesPreparation, prepared)) _missionMapUpdateRevision++;
        _missionFilesPreparation = prepared;
        _missionFilesPreparedRelease = release;
        _missionFilesPreparedEnvelope = envelope.RawJson;
        _missionFilesPreparedRoots = roots;
        _missionFilesPreparedExternalPaths = external;
        return true;
    }

    private void LoadMissionSourceFolders()
    {
        try { _missionSourceFolders = MissionSourceFolderStore.Load(); }
        catch (Exception error) when (error is IOException or InvalidDataException or UnauthorizedAccessException or ArgumentException or NotSupportedException or System.Text.Json.JsonException)
        { _missionSourceFoldersError = "Could not load mission source folders: " + error.Message; }
    }
    private void ApplyMissionSourceFolders(IReadOnlyList<string> folders)
    {
        if (_missionDownloadBusy) throw new InvalidOperationException("Wait for the current mission operation to finish before changing its source folders.");
        _missionSourceFolders = MissionSourceFolderStore.Save(folders);
        _missionSourceFoldersError = null;
        ReconcileMissionSourceFolders();
        RefreshUpdatesPresentation();
    }
    private void ApplyMissionScanPreferences(bool? automaticScan = null)
    {
        if (_updatesRendering || _missionDownloadBusy || _configLoadingOperation || _updatesInstalling || _updatesBusy) return;
        var custom = _missionFilesUpdatesCustomSources!.Checked;
        var automatic = automaticScan ?? _settings.AutomaticMissionScan;
        var previous = (_settings.MissionScanCustomSourcesOnly, _settings.AutomaticMissionScan);
        if (previous == (custom, automatic)) return;
        _settings.MissionScanCustomSourcesOnly = custom;
        _settings.AutomaticMissionScan = automatic;
        var aged = false;
        if (_updateChecker is { } checker && _updatesResult is { } retained)
        {
            _updatesResult = checker.AgeSnapshot(retained);
            aged = _updatesResult.State != retained.State;
        }
        if (_updatesError is not null || aged) RefreshUpdatesPresentation();
        else UpdateMissionFilesUpdatesLayout(() => {
            PresentMissionScanPreferences();
            if (_settings.MissionScanCustomSourcesOnly != previous.MissionScanCustomSourcesOnly && _updatesResult is { } result)
            {
                RefreshUpdatesButtonPresentation(result);
                RefreshMissionScanPresentation(result, _missionFilesManagerGlyph!.Visible, _missionFilesManagerText!.Text);
            }
        }, _settings.MissionScanCustomSourcesOnly != previous.MissionScanCustomSourcesOnly
            ? [_missionFilesUpdatesAllSources!, _missionFilesUpdatesCustomSources!, _missionFilesUpdatesScopeHint!,
                _missionFilesUpdateInstances!, _missionFilesUpdatesScanStatus!, _missionFilesBadge!,
                _missionFilesUpdatesCheckMissions!, _missionFilesUpdatesOpen!]
            : [_missionFilesUpdatesAutoScan!, _missionFilesUpdatesAutoHint!]);
        try { _settings.Save(); }
        catch (Exception error) when (error is IOException or UnauthorizedAccessException)
        {
            (_settings.MissionScanCustomSourcesOnly, _settings.AutomaticMissionScan) = previous;
            _updatesError = "Could not save mission scan choices: " + error.Message;
            RefreshUpdatesPresentation();
        }
    }
    private void PresentMissionScanPreferences()
    {
        var rendering = _updatesRendering;
        _updatesRendering = true;
        try
        {
            _missionFilesUpdatesAllSources!.Checked = !_settings.MissionScanCustomSourcesOnly;
            _missionFilesUpdatesCustomSources!.Checked = _settings.MissionScanCustomSourcesOnly;
            _missionFilesUpdatesAutoScan!.Text = _settings.AutomaticMissionScan ? "Auto scan: On" : "Auto scan: Off";
            ((PreviewButton)_missionFilesUpdatesAutoScan).SelectionEmphasis = _settings.AutomaticMissionScan;
            _missionFilesUpdatesAutoScan.AccessibleDescription = _settings.AutomaticMissionScan
                ? "On. Scan missions silently after startup. Updates reuses the results. This choice is remembered."
                : "Off. Scan only when you choose Scan now. This choice is remembered.";
            _missionFilesUpdatesScopeHint!.Text = _settings.MissionScanCustomSourcesOnly
                ? "Default instance folders will not be scanned. Add the folders or MIZ files you want to check."
                : "Scan all detected instance Missions folders, plus the custom sources below.";
            _missionFilesUpdatesAutoHint!.Text = _settings.AutomaticMissionScan
                ? "Scans silently after startup; Updates reuses the results." : "Scan only when you choose Scan now.";
            var available = !_updatesBusy && !_missionDownloadBusy && !_configLoadingOperation && !_updatesInstalling;
            _missionFilesUpdatesSourcesBody!.Enabled = _missionFilesUpdatesAutoScan.Enabled = available;
        }
        finally { _updatesRendering = rendering; }
    }
    private string? _missionUnresolvedFolders;
    private MissionFilesRoot[] CaptureMissionFilesRoots() => CaptureMissionRoots(scanSourcesOnly: false);
    private MissionFilesRoot[] CaptureMissionRoots(bool scanSourcesOnly)
    {
        IReadOnlyList<ServerProfileSettings> profiles = _settings.ServerProfiles.Count == 0
            ? new[] { GetMissionDownloadFallback() } : _settings.ServerProfiles;
        if (_settings.ServerProfiles.Count > 0 && _document is not null && FindCurrentInstanceProfile() is null)
            profiles = profiles.Append(GetMissionDownloadFallback()).ToArray();
        var resolved = profiles.Select(profile => (Profile: profile, Directory: RuntimeSettings.ResolveInstanceMissionsDirectory(profile))).ToArray();
        var customOnly = scanSourcesOnly && _settings.MissionScanCustomSourcesOnly;
        _missionUnresolvedFolders = string.Join(Environment.NewLine, resolved.Where(item => !customOnly && item.Directory is null)
            .Select(item => item.Profile.Name + ": Missions folder could not be determined. Add its mission folder to include it in this check."));
        return resolved.Where(item => !customOnly && item.Directory is not null)
            .Select(item => new MissionFilesRoot(item.Profile.Id, item.Profile.Name, item.Directory!))
            .Concat(_missionSourceFolders.Select(folder => {
                var owner = resolved.FirstOrDefault(item => item.Directory is not null && PathsEqual(item.Directory, folder)).Profile;
                return new MissionFilesRoot(owner?.Id ?? "source-folder:" + folder.ToUpperInvariant(), owner?.Name ?? folder, folder);
            }))
            .DistinctBy(root => Path.TrimEndingDirectorySeparator(Path.GetFullPath(root.MissionsDirectory)), StringComparer.OrdinalIgnoreCase)
            .Select(root => root with { IncludeDcsServerBotOriginals = _missionFilesIncludeDcsServerBotOriginals }).ToArray();
    }
    private string[] CaptureMissionFilesExternalPaths() => _missionFilesExternalPaths.Select(Path.GetFullPath)
        .Distinct(StringComparer.OrdinalIgnoreCase).ToArray();
    private static bool SameMissionFilesRelease(FootholdReleaseInfo? expected, FootholdReleaseInfo? actual) =>
        expected is not null && actual is not null && expected.Id == actual.Id && expected.Tag == actual.Tag
        && expected.FilesEnvelopeAsset == actual.FilesEnvelopeAsset;
    private bool HasCurrentMissionFilesPreparation(UpdateCheckResult result, MissionFilesRoot[] roots, string[] externalPaths) =>
        result.FilesEnvelopeAvailable && _missionFilesPreparation is { } preparation
        && ReferenceEquals(_missionFilesService?.Prepared, preparation) && SameMissionFilesRelease(_missionFilesPreparedRelease, result.Foothold.Data)
        && _missionFilesPreparedEnvelope == result.FilesEnvelope.Data!.RawJson && _missionFilesPreparedRoots.SequenceEqual(roots)
        && _missionFilesPreparedExternalPaths.SequenceEqual(externalPaths, StringComparer.OrdinalIgnoreCase);
    private async Task OpenMissionFilesAsync(bool refreshInventory = false, bool showUpdater = true)
    {
        if (_updatesDisposed || _missionDownloadBusy || _configLoadingOperation || _updatesInstalling || _updatesBusy
            || _updatesResult is not { FilesEnvelopeAvailable: true } result) return;
        EnsureMissionDownloadLifetime();
        await RefreshDedicatedRegistrationTargetsAsync();
        if (_updatesDisposed || IsDisposed || Disposing || _configLoadingOperation || _missionDownloadBusy || _updatesInstalling || _updatesBusy) return;
        if (_missionFilesPanel is null) MissionFilesAddRequested += () => _missionDownloadJob = AddMissionFilesAsync();
        BuildMissionFilesView(() => _missionDownloadJob = CreateMissionFilesAsync());
        if (showUpdater) ShowMissionFilesView();
        var release = result.Foothold.Data!;
        var envelope = result.FilesEnvelope.Data!;
        var roots = CaptureMissionRoots(scanSourcesOnly: true);
        ReconcileMissionSourceFolders();
        var externalPaths = CaptureMissionFilesExternalPaths();
        RefreshMissionCompletionState();
        if (!refreshInventory && HasCurrentMissionFilesPreparation(result, roots, externalPaths))
        { RefreshMissionFilesCompletionRows(); return; }
        _missionFilesPreparation = null;
        _missionFilesApplied = null;
        _missionFilesResultGlyph!.Visible = false;
        _missionFilesOpenFolder!.Visible = _missionFilesDetails!.Visible = _missionFilesDetailsToggle!.Visible = false;
        _missionFilesDetailsToggle.Text = "Show details";
        _missionDownloadBusy = true;
        _missionFilesDcsServerBotOriginals!.Enabled = false;
        var generation = ++_missionFilesOperationGeneration;
        _missionDownloadCancellation = CancellationTokenSource.CreateLinkedTokenSource(_updatesLifetime.Token);
        var cancellation = _missionDownloadCancellation;
        RefreshUpdatesPresentation();
        _missionFilesResult!.Text = "Checking your missions…";
        try
        {
            await RunConfigLoadingAsync(async (progress, token) =>
            {
                try
                {
                    var prepared = await PrepareMissionFilesSharedAsync(release, envelope, roots, externalPaths,
                        new Progress<FileUpdateInspection>(row => {
                            if (!_updatesDisposed && generation == _missionFilesOperationGeneration)
                                progress.Report(new LoadingProgress("Checking " + row.FriendlyName + "…"));
                        }), token, refreshInventory);
                    token.ThrowIfCancellationRequested();
                    if (_updatesDisposed || generation != _missionFilesOperationGeneration) return;
                    if (!TryAdoptMissionFilesPreparation(release, envelope, roots, externalPaths, prepared))
                    { _missionFilesResult.Text = "The release or instances changed. Return to Updates to check again."; return; }
                    RefreshMissionFilesCompletionRows();
                    PresentMissionFilesRelease(release.Tag.TrimStart('v', 'V'));
                    _missionFilesResult.Text = prepared.Rows.Count == 0 ? "No MIZ files found. Add MIZ files to check another folder."
                        : _missionFilesState.Candidates.Values.Count(row => row.State == FileUpdateInspectionState.Compatible) + " compatible mission(s).";
                    var unavailable = prepared.Groups.Where(group => group.Status != "No MIZ files" && !group.Status.EndsWith(" MIZ files", StringComparison.Ordinal));
                    foreach (var group in unavailable) _missionFilesResult.Text += Environment.NewLine + group.Name + ": " + group.Status;
                }
                catch (OperationCanceledException) { if (!_updatesDisposed) _missionFilesResult.Text = "Mission check cancelled. Return to try again."; }
                catch (Exception error) { if (!_updatesDisposed) _missionFilesResult.Text = "Could not check missions: " + error.Message; }
            }, cancellation.Token, "Checking existing missions…");
        }
        finally
        {
            _missionDownloadBusy = false;
            _missionDownloadCancellation = null;
            cancellation.Dispose();
            if (!_updatesDisposed && !IsDisposed && !Disposing && generation == _missionFilesOperationGeneration)
            {
                if (_missionFilesPreparation is null)
                    ReconcileMissionFileRows(_missionFilesState.Candidates.Values.Select(row => row with {
                        State = FileUpdateInspectionState.Stale, Reason = "Check these missions again.", ProposedOutputName = null }).ToArray(), generation);
                RefreshMissionFilesSelection();
                RefreshUpdatesPresentation();
                SetStatus(_missionFilesResult.Text);
            }
            if (_updatesDisposed) DisposeMissionDownloadState();
            if (_missionCloseRequested && !IsDisposed && !Disposing) { _missionCloseRequested = false; Close(); }
        }
    }
    private MissionFilesApplyResult? _missionFilesApplied;
    private Button? _missionFilesOpenFolder, _missionFilesDetailsToggle;
    private Label? _missionFilesDetails;
    private async Task RefreshMissionFilesAfterFullInstallAsync(IReadOnlyList<string> installed)
    {
        if (installed.Count == 0 || _updatesDisposed || IsDisposed || Disposing) return;

        // Reproject the admitted results immediately, including stock copies installed under their suggested names.
        RefreshMissionFilesCompletionRows();
        RefreshUpdatesPresentation();
        if (_missionFilesBackgroundTask is { IsCompleted: false } background) await background;
        if (_updatesDisposed || _missionCloseRequested || IsDisposed || Disposing ||
            _missionFilesPreparation is null || _updatesResult is not { FilesEnvelopeAvailable: true } current) return;

        var roots = CaptureMissionRoots(scanSourcesOnly: true);
        var externalPaths = CaptureMissionFilesExternalPaths();
        if (!installed.Any(path => externalPaths.Any(external => PathsEqual(external, path))
            || roots.Any(root => PathsEqual(root.MissionsDirectory, Path.GetDirectoryName(path)!)))) return;

        // Reuse the release payload and unchanged archive inspections, including for custom output names and replacements.
        var release = current.Foothold.Data!;
        var envelope = current.FilesEnvelope.Data!;
        var refreshed = await PrepareMissionFilesSharedAsync(release, envelope, roots, externalPaths,
            null, _updatesLifetime.Token, refreshInventory: true);
        if (!TryAdoptMissionFilesPreparation(release, envelope, roots, externalPaths, refreshed)) return;
        RefreshMissionFilesCompletionRows();
        RefreshUpdatesPresentation();
    }

    private void RefreshMissionFilesCompletionRows()
    {
        if (_missionFilesPreparation is not { } prepared) return;
        var projected = MissionUpdateProgress.Project(prepared, _missionAvailableMapUpdates, _missionFilesPreparedRelease!.Tag);
        var summaries = projected.GroupBy(row => row.GroupId).ToDictionary(group => group.Key, group =>
            string.Join(Environment.NewLine, group.Where(row => row.State == FileUpdateInspectionState.Compatible).Select(row => {
                var facts = prepared.Compatible[Path.GetFullPath(row.Path)];
                var versions = facts.SourceScriptVersions;
                var version = versions.Count == 1 ? versions[0] : "Supported versions";
                return (row.ObservedMap ?? MissionWarehouseService.GetMapVariant(facts.Target) ?? facts.Target.Theatre)
                    + " • " + version + " → " + facts.Target.TargetScriptVersion;
            }).Distinct(StringComparer.Ordinal)));
        _missionFilesPresentedPreparation = prepared with { Rows = projected.Select(row => row with {
            GroupSummary = row.IsCurrentVersion ? row.ObservedMap + " • " + row.ObservedMissionVersion
                : summaries[row.GroupId].Length == 0 ? "Other missions" : summaries[row.GroupId] }).ToArray() };
        if (_missionFilesPanel is not null) ReconcileMissionFileRows(_missionFilesPresentedPreparation.Rows, _missionFilesOperationGeneration);
    }
    private async Task AddMissionFilesAsync(bool showUpdater = true)
    {
        if (_missionDownloadBusy || _configLoadingOperation || _updatesDisposed) return;
        using var picker = new OpenFileDialog { Title = "Add MIZ files", Filter = "DCS missions (*.miz)|*.miz", Multiselect = true };
        if (picker.ShowDialog(this) != DialogResult.OK) return;
        _missionFilesExternalPaths = _missionFilesExternalPaths.Concat(picker.FileNames.Select(Path.GetFullPath))
            .Distinct(StringComparer.OrdinalIgnoreCase).ToArray();
        if (!showUpdater && !_settings.AutomaticMissionScan) { RefreshUpdatesPresentation(); return; }
        await OpenMissionFilesAsync(showUpdater: showUpdater);
    }
    private async Task AddMissionSourceFolderAsync(bool showUpdater = true)
    {
        if (_missionDownloadBusy || _configLoadingOperation || _updatesDisposed) return;
        using var picker = new FolderBrowserDialog { Description = "Choose a folder containing your mission files",
            SelectedPath = _missionSourceFolders.LastOrDefault() ?? RuntimeSettings.GetBestInitialDirectory() };
        if (picker.ShowDialog(this) != DialogResult.OK) return;
        try { ApplyMissionSourceFolders(_missionSourceFolders.Append(picker.SelectedPath).ToArray()); }
        catch (Exception error) when (error is IOException or InvalidDataException or UnauthorizedAccessException or ArgumentException or NotSupportedException)
        {
            _missionSourceFoldersError = "Could not remember mission source folders: " + error.Message;
            ReconcileMissionSourceFolders(); return;
        }
        if (!showUpdater && !_settings.AutomaticMissionScan) { RefreshUpdatesPresentation(); return; }
        await OpenMissionFilesAsync(showUpdater: showUpdater);
    }
    private async Task RemoveMissionSourceFolderAsync(string folder, bool showUpdater = true)
    {
        if (_missionDownloadBusy || _configLoadingOperation || _updatesDisposed) return;
        try { ApplyMissionSourceFolders(_missionSourceFolders.Where(path => !PathsEqual(path, folder)).ToArray()); }
        catch (Exception error) when (error is IOException or InvalidDataException or UnauthorizedAccessException or ArgumentException or NotSupportedException)
        {
            _missionSourceFoldersError = "Could not remember mission source folders: " + error.Message;
            ReconcileMissionSourceFolders(); return;
        }
        if (!showUpdater && !_settings.AutomaticMissionScan) { RefreshUpdatesPresentation(); return; }
        await OpenMissionFilesAsync(showUpdater: showUpdater);
    }
    private async Task CreateMissionFilesAsync()
    {
        if (_updatesDisposed || _missionDownloadBusy || _configLoadingOperation || _updatesInstalling
            || _missionFilesPreparation is not { } preparation || _missionFilesPreparedRelease is not { } release) return;
        var paths = SelectedMissionFilePaths;
        var registerServer = CanOfferFilesServerRegistration && _missionFilesRegisterServer?.Checked == true;
        if (paths.Count == 0 || paths.Any(path => !preparation.Compatible.ContainsKey(path))) return;
        _missionFilesResultGlyph!.Visible = false;
        var roots = CaptureMissionRoots(scanSourcesOnly: true);
        if (_updatesResult is not { } current || !HasCurrentMissionFilesPreparation(current, roots, CaptureMissionFilesExternalPaths()))
        { _missionFilesResult!.Text = "The release or instances changed. Return to Updates and check these missions again."; return; }
        string? outputDirectory;
        try { outputDirectory = CaptureCustomMissionOutputDirectory(); }
        catch (InvalidDataException error) { _missionFilesResult!.Text = error.Message; return; }
        var reinstallPaths = paths.Where(path => preparation.Compatible[path].IsCurrentVersion).ToArray();
        var allowReinstallation = reinstallPaths.Length > 0;
        if (reinstallPaths.Length > 0 && outputDirectory is null && MessageBox.Show(this,
            "Reinstall release script files in these currently installed missions?\n\n" + string.Join("\n", reinstallPaths)
            + "\n\nThese files will be replaced. Everything except the managed script files and embedded Config update stays the same.",
            "Reinstall current scripts?", MessageBoxButtons.YesNo, MessageBoxIcon.Question, MessageBoxDefaultButton.Button2) != DialogResult.Yes) return;
        var targets = new List<(string SourcePath, MissionConfigTarget Target)>();
        var outcomes = new List<string>();
        var registrationTargets = registerServer ? CaptureFilesServerRegistrationTargets() : [];
        MissionFilesApplyResult? committedMissions = null;
        var configOutcomes = new Dictionary<string, (string State, string Reason)>(StringComparer.OrdinalIgnoreCase);
        string? configPreparationError = null;
        if (_missionFilesState.UpdateInstanceConfigs)
        {
            IReadOnlyList<ServerProfileSettings> profiles = _settings.ServerProfiles.Count == 0
                ? new[] { GetMissionDownloadFallback() } : _settings.ServerProfiles;
            var instanceOwners = profiles.Select(profile => (Profile: profile, Directory: RuntimeSettings.ResolveInstanceMissionsDirectory(profile)))
                .Where(item => item.Directory is not null).ToArray();
            foreach (var path in paths)
            {
                var row = preparation.Rows.Single(row => PathsEqual(row.Path, path));
                var owners = instanceOwners.Where(item => path.StartsWith(
                    Path.TrimEndingDirectorySeparator(item.Directory!) + Path.DirectorySeparatorChar, StringComparison.OrdinalIgnoreCase)).ToArray();
                if (row.GroupId == "external" || row.GroupId.StartsWith("source-folder:", StringComparison.Ordinal) || owners.Length != 1)
                { configOutcomes["for " + path] = ("skipped", "no unambiguous instance owner."); continue; }
                var owner = owners[0].Profile;
                if (string.IsNullOrEmpty(owner.ConfigPath))
                { configOutcomes["for " + path] = ("skipped", "no instance Config selected."); continue; }
                targets.Add((path, new MissionConfigTarget(owner.Name, owner.ConfigPath)));
                configOutcomes.TryAdd(Path.GetFullPath(owner.ConfigPath), (string.Empty, string.Empty));
            }
            if (_document is not null && targets.Any(target => PathsEqual(target.Target.Path, _document.Path)))
            {
                HideCurrentGridSelectionHighlights();
                if (HasChanges())
                { _missionFilesResult!.Text = "Save or reload pending configuration changes before updating the active instance Config, or turn Also update instance Configs off."; return; }
            }
        }
        EnsureMissionDownloadLifetime();
        _missionDownloadBusy = true;
        _missionFilesDcsServerBotOriginals!.Enabled = false;
        _missionFilesOpenFolder!.Visible = false;
        _missionFilesDetails!.Visible = _missionFilesDetailsToggle!.Visible = false;
        _missionFilesDetailsToggle.Text = "Show details";
        _missionFilesApplied = null;
        var generation = ++_missionFilesOperationGeneration;
        var activePath = _document?.Path;
        var updated = new List<InstanceImportPlan>();
        var cancelled = false;
        _missionDownloadCancellation = CancellationTokenSource.CreateLinkedTokenSource(_updatesLifetime.Token);
        var cancellation = _missionDownloadCancellation;
        RefreshUpdatesPresentation();
        _missionFilesResult!.Text = "Creating updated copies…";
        try
        {
            await RunConfigLoadingAsync(async (progress, token) =>
            {
                try
                {
                    var outputNames = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
                    var reservedPaths = preparation.Rows.Select(row => row.Path).ToHashSet(StringComparer.OrdinalIgnoreCase);
                    foreach (var path in paths)
                    {
                        token.ThrowIfCancellationRequested();
                        var row = preparation.Rows.Single(row => PathsEqual(row.Path, path));
                        if (row.IsCurrentVersion && outputDirectory is null)
                        { outputNames.Add(path, Path.GetFileName(path)); continue; }
                        var directory = outputDirectory ?? preparation.Compatible[path].DefaultOutputDirectory ?? Path.GetDirectoryName(path)!;
                        using var dialog = CreateMissionFileNameDialog(path, Path.Combine(directory, row.ProposedOutputName!), reservedPaths);
                        using var modal = _loadingScreen?.SuspendForModal(dialog);
                        if (dialog.ShowDialog(this) != DialogResult.OK) { cancelled = true; return; }
                        token.ThrowIfCancellationRequested();
                        var outputPath = (string)dialog.Tag!;
                        outputNames.Add(path, Path.GetFileName(outputPath));
                        reservedPaths.Add(outputPath);
                    }
                    // The targets and their previous-default snapshots belong only to this admitted job.
                    IReadOnlyList<MissionFilesInstancePlan> plans = [];
                    if (targets.Count > 0)
                    {
                        try
                        {
                            plans = await Task.Run(() => PrepareMissionFilesInstancePlans(preparation, _missionFilesService!.Payload,
                                targets, Path.Combine(RuntimeSettings.SettingsDirectory, "FilesImports", Guid.NewGuid().ToString("N")), token), token);
                        }
                        catch (OperationCanceledException) { throw; }
                        catch (Exception error) { configPreparationError = error.Message; }
                    }
                    var applied = await _missionFilesService!.ApplyWithOutputNamesAsync(preparation, paths, CreateMissionFilesConfigMerger(),
                        new Progress<MissionFilesApplyItem>(item => {
                            if (!_updatesDisposed && generation == _missionFilesOperationGeneration)
                                progress.Report(new LoadingProgress("Creating " + Path.GetFileName(item.SourcePath) + "…"));
                        }), token, outputDirectory, outputNames, allowCurrentReinstallation: allowReinstallation);
                    _missionFilesApplied = applied;
                    committedMissions = applied;
                    RecordInstalledMissionWarehouseSources(applied.Items.Where(item => item.OutputPath is not null && item.Error is null)
                        .Select(item => item.OutputPath!).ToArray());
                    if (RememberMissionMapUpdates(MissionUpdateProgress.FilesOnly(preparation, roots, release.Tag, applied)) is { } progressWarning)
                        outcomes.Add(progressWarning);
                    cancelled = applied.Cancelled;
                    var successes = applied.Items.Where(item => item.OutputPath is not null).Select(item => item.SourcePath).ToHashSet(StringComparer.OrdinalIgnoreCase);
                    foreach (var plan in plans)
                    {
                        if (!plan.SourcePaths.Any(successes.Contains))
                        { configOutcomes[plan.Path] = ("skipped", "No applicable mission copy succeeded."); continue; }
                        if (plan.Error is not null) { configOutcomes[plan.Path] = ("failed", plan.Error); continue; }
                        token.ThrowIfCancellationRequested();
                        if (_updatesDisposed) return;
                        try
                        {
                            var committed = await CommitInstanceImportPlans([plan.Plan!], plan.CleanSource!, plan.CleanSource!.Path,
                                null, progress, token, recordRelease: false);
                            updated.AddRange(committed.Updated);
                            configOutcomes[plan.Path] = committed.Updated.Count > 0 ? ("updated", "Saved instance Config.")
                                : committed.Failed.Count > 0 ? ("failed", string.Join("; ", committed.Failed))
                                : ("skipped", "No Config change was committed.");
                            outcomes.AddRange(committed.Warnings);
                        }
                        catch (OperationCanceledException) { throw; }
                        catch (Exception error) { configOutcomes[plan.Path] = ("failed", error.Message); }
                    }
                }
                catch (OperationCanceledException) { cancelled = true; }
                catch (Exception error) { outcomes.Add("Could not finish: " + error.Message); }
                finally
                {
                    var active = activePath is null ? null : updated.FirstOrDefault(plan => PathsEqual(plan.Current.Path, activePath));
                    if (active is not null && !_updatesDisposed && !IsDisposed && !Disposing)
                    {
                        try { LoadConfig(active.Current.Path); ApplyImportedNewMarkers(CaptureImportedNewMarkers(active.Preview)); }
                        catch (Exception error) { outcomes.Add("The active Config was updated, but its view could not be reloaded: " + error.Message); }
                    }
                    if (_missionFilesApplied?.Items.Any(item => item.OutputPath is not null) == true && !_updatesDisposed)
                    {
                        _updateChecker ??= new GitHubUpdateChecker(ManagerBuildInfo.ReleaseVersion);
                        try
                        {
                            var state = await _updateChecker.RecordImportedFootholdAsync(release.Tag, CancellationToken.None);
                            if (!_updatesDisposed) PresentUpdateResult(state);
                            if (state.PersistenceError is not null) outcomes.Add(state.PersistenceError);
                        }
                        catch (Exception error) { outcomes.Add("Mission copies were created, but release history could not be saved: " + error.Message); }
                    }
                }
                if (registerServer && !cancelled && committedMissions is { Cancelled: false } completed
                    && !token.IsCancellationRequested && generation == _missionFilesOperationGeneration)
                    outcomes.AddRange((await RegisterCreatedMissionsAsync(completed.Items.Where(item => item.OutputPath is not null
                        && preparation.Rows.Any(row => row.Path.Equals(item.SourcePath, StringComparison.OrdinalIgnoreCase)
                            && registrationTargets.Any(target => target.Id == row.GroupId)))
                        .Select(item => item.OutputPath!).ToArray(), registrationTargets, progress, token)).Select(FormatServerRegistrationOutcome));
                if (committedMissions?.Items.Any(item => item.OutputPath is not null && PathsEqual(item.SourcePath, item.OutputPath)) == true
                    && !token.IsCancellationRequested && !_updatesDisposed)
                {
                    // Reinspect changed paths once after commit; unchanged archives and the payload stay cached.
                    var refreshed = await PrepareMissionFilesSharedAsync(release, current.FilesEnvelope.Data!, roots,
                        CaptureMissionFilesExternalPaths(), null, token, refreshInventory: true);
                    TryAdoptMissionFilesPreparation(release, current.FilesEnvelope.Data!, roots, CaptureMissionFilesExternalPaths(), refreshed);
                }
            }, cancellation.Token, "Creating updated mission copies…", finishCommittedPreparation: true, errorTitle: "Update existing missions");
        }
        finally
        {
            _missionDownloadBusy = false;
            _missionDownloadCancellation = null;
            cancellation.Dispose();
            if (!_updatesDisposed && !IsDisposed && !Disposing && generation == _missionFilesOperationGeneration)
            {
                var items = _missionFilesApplied?.Items ?? [];
                var count = items.Count(item => item.OutputPath is not null);
                PresentMissionFilesOutcomes(paths, configOutcomes, outcomes, cancelled, configPreparationError);
                RefreshMissionCompletionState();
                RefreshMissionFilesCompletionRows();
                var failed = items.Where(item => item.Error is not null).ToDictionary(item => item.SourcePath, StringComparer.OrdinalIgnoreCase);
                if (failed.Count > 0)
                    ReconcileMissionFileRows(_missionFilesState.Candidates.Values.Select(row => failed.TryGetValue(row.Path, out var item)
                        ? row with { State = FileUpdateInspectionState.Error, Reason = item.Error! } : row).ToArray(), generation);
                RefreshMissionFilesSelection(); RefreshUpdatesPresentation();
                if (_missionFilesPanel is { Visible: true } resultPanel && WindowState != FormWindowState.Minimized)
                {
                    resultPanel.ScrollControlIntoView(_missionFilesResultRow!);
                    _missionFilesState.ScrollPosition = resultPanel.AutoScrollPosition;
                }
                SetStatus((cancelled ? "Cancelled · " : "") + count + (items.Any(item => item.OutputPath is not null && PathsEqual(item.SourcePath, item.OutputPath))
                    ? " mission script operations completed." : " updated mission copies created."));
            }
            if (_updatesDisposed) DisposeMissionDownloadState();
            if (_missionCloseRequested && !IsDisposed && !Disposing) { _missionCloseRequested = false; Close(); }
        }
    }
    // Final projection uses only the admitted selection and recorded results, never another inspection.
    private void PresentMissionFilesOutcomes(IReadOnlyList<string> paths,
        IReadOnlyDictionary<string, (string State, string Reason)> configOutcomes,
        IReadOnlyList<string> outcomes, bool cancelled, string? configPreparationError)
    {
        var items = (_missionFilesApplied?.Items ?? []).ToDictionary(item => item.SourcePath, StringComparer.OrdinalIgnoreCase);
        var details = new List<string>();
        var created = 0; var reinstalled = 0; var failed = 0; var cancelledCount = 0; var skipped = 0;
        foreach (var path in paths)
        {
            if (items.TryGetValue(path, out var item))
            {
                if (item.OutputPath is not null) { created++; if (PathsEqual(path, item.OutputPath)) reinstalled++; details.Add((PathsEqual(path, item.OutputPath) ? "Reinstalled: " : "Created: ") + path + " → " + item.OutputPath); }
                else { failed++; details.Add("MIZ failed: " + path + " — " + item.Error); }
            }
            else if (cancelled) { cancelledCount++; details.Add("MIZ cancelled: " + path + " — Operation cancelled before this copy was committed."); }
            else { skipped++; details.Add("MIZ skipped: " + path + " — Operation ended before this copy was attempted; see operation details."); }
        }
        var configUpdated = 0; var configFailed = 0; var configCancelled = 0; var configSkipped = 0;
        foreach (var (path, recorded) in configOutcomes)
        {
            var (state, reason) = recorded;
            if (state.Length == 0)
                (state, reason) = configPreparationError is not null ? ("failed", configPreparationError)
                    : cancelled ? ("cancelled", "Operation cancelled before this target was committed.")
                    : ("skipped", "Operation ended before this target was committed; see operation details.");
            switch (state)
            {
                case "updated": configUpdated++; break;
                case "failed": configFailed++; break;
                case "cancelled": configCancelled++; break;
                case "skipped": configSkipped++; break;
            }
            details.Add("Config " + state + ": " + path + " — " + reason);
        }
        _missionFilesResult!.Text = (cancelled ? "Cancelled · " : "") + (created - reinstalled) + " updated copies created; "
            + (reinstalled > 0 ? reinstalled + " missions reinstalled; " : "")
            + failed + " failed; " + cancelledCount + " cancelled; " + skipped + " skipped." + (reinstalled == 0 ? " Your original missions were kept." : "")
            + (configOutcomes.Count == 0 ? "" : " Instance Configs: " + configUpdated + " updated; " + configFailed
                + " failed; " + configCancelled + " cancelled; " + configSkipped + " skipped.");
        _missionFilesDetails!.Text = string.Join(Environment.NewLine, details.Concat(outcomes));
        _missionFilesDetailsToggle!.Visible = _missionFilesDetails.Text.Length > 0;
        _missionFilesResultGlyph!.Visible = created > 0 && !cancelled && failed == 0 && skipped == 0
            && configFailed == 0 && configCancelled == 0 && configSkipped == 0 && outcomes.Count == 0;
        _missionFilesOpenFolder!.Visible = created > 0;
    }
    private Panel? _missionFilesPanel;
    private TableLayoutPanel? _missionFilesPage, _missionFilesColumns, _missionFilesLeft, _missionFilesRight, _missionFilesCard, _missionFilesGroups, _missionFilesInstalledGroups;
    private TableLayoutPanel? _missionFilesAction;
    private FlowLayoutPanel? _missionFilesSourcesActions;
    private TableLayoutPanel? _missionFilesSourceFolders;
    private Label? _missionFilesSourceError;
    private readonly Dictionary<string, (Panel Surface, Label Path)> _missionSourceFolderRows = new(StringComparer.OrdinalIgnoreCase);
    private Panel? _missionFilesSummaryArea;
    private Label? _missionFilesSubtitle, _missionFilesSummary, _missionFilesOutput;
    private Button? _missionFilesCreate, _missionFilesOtherToggle;
    private Button? _missionFilesInstalledToggle;
    private Label? _missionFilesOriginalsHint;
    private readonly MissionFilesViewState _missionFilesState = new();
    private readonly Dictionary<string, MissionFileRow> _missionFileRows = new(StringComparer.OrdinalIgnoreCase);
    private readonly Dictionary<string, MissionFileGroup> _missionFileGroups = new(StringComparer.Ordinal);
    private readonly Dictionary<Label, (float Scale, FontStyle Style)> _missionFilesLabels = new();
    private bool _missionFilesRendering, _missionFilesArranging, _missionFilesFontLifetime;
    private long _missionFilesGeneration = -1;
    private (int Width, int Zoom, bool Dark)? _missionFilesAppearance;
    private IReadOnlyList<string> SelectedMissionFilePaths => Array.AsReadOnly(_missionFilesState.Selected.ToArray());

    private sealed class MissionFilesViewState
    {
        internal readonly Dictionary<string, FileUpdateInspection> Candidates = new(StringComparer.OrdinalIgnoreCase);
        internal readonly HashSet<string> Selected = new(StringComparer.OrdinalIgnoreCase);
        internal readonly HashSet<string> Collapsed = new(StringComparer.Ordinal);
        internal bool ShowOtherMissions;
        internal bool ShowInstalled;
        internal bool UpdateInstanceConfigs;
        internal Point ScrollPosition;
    }
    private sealed record MissionFileRow(Panel Surface, WeatherCheckBox Check, Label Name, Label File, Label Status);
    private sealed record MissionFileGroup(TableLayoutPanel Surface, TableLayoutPanel Rows, WeatherCheckBox Check,
        Button Disclosure, Label Summary, Label Name);

    private static TableLayoutPanel MissionFilesColumn(string name, bool cacheMeasurements = false)
    {
        TableLayoutPanel column = cacheMeasurements ? new EditorLayoutPanel() : new TableLayoutPanel();
        column.Name = name; column.AutoSize = true; column.AutoSizeMode = AutoSizeMode.GrowAndShrink;
        column.ColumnCount = 1; column.RowCount = 0; column.Margin = Padding.Empty; column.Dock = DockStyle.Top;
        column.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        return column;
    }
    private static void AddMissionFilesControl(TableLayoutPanel column, Control control)
    {
        column.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        column.Controls.Add(control, 0, column.RowCount++);
    }
    private Label MissionFilesLabel(string text, float scale = 1, FontStyle style = FontStyle.Regular)
    {
        var label = new Label { Text = text, AutoSize = true, Dock = DockStyle.Top, Margin = new Padding(0, 3, 0, 5) };
        _missionFilesLabels.Add(label, (scale * (scale >= 1.2f ? 1.5f : 1.35f), style));
        return label;
    }
    private Button MissionFilesButton(string name, string text, Action action, bool emphasis = false)
    {
        var button = MakeButton(text, action);
        button.Name = name; button.Dock = DockStyle.None; button.AutoSize = false;
        ((PreviewButton)button).ActionEmphasis = emphasis;
        return button;
    }
    private void ReconcileMissionSourceFolders()
    {
        if (_missionFilesSourceFolders is null) return;
        var removed = _missionSourceFolderRows.Keys.Where(path => !_missionSourceFolders.Contains(path, StringComparer.OrdinalIgnoreCase)).ToArray();
        var added = _missionSourceFolders.Where(path => !_missionSourceFolderRows.ContainsKey(path)).ToArray();
        _missionFilesSourceError!.Text = string.Join(Environment.NewLine,
            new[] { _missionSourceFoldersError, _missionUnresolvedFolders }.Where(text => !string.IsNullOrEmpty(text)));
        _missionFilesSourceError.Visible = _missionFilesSourceError.Text.Length > 0;
        if (removed.Length == 0 && added.Length == 0) return;
        var layouts = new List<Control> { _missionFilesPanel!, _missionFilesPage!, _missionFilesColumns!, _missionFilesLeft!, _missionFilesSourceFolders };
        layouts.AddRange(_missionSourceFolderRows.Values.Select(row => (Control)row.Surface));
        foreach (var control in layouts) control.SuspendLayout();
        try
        {
            foreach (var path in removed)
            {
                var old = _missionSourceFolderRows[path];
                _missionFilesLabels.Remove(old.Path);
                old.Surface.Dispose(); _missionSourceFolderRows.Remove(path);
            }
            foreach (var path in added)
            {
                var identity = path.ToUpperInvariant();
                var row = new Panel { Name = "MissionFilesSourceFolder-" + identity, Dock = DockStyle.Top, Margin = Padding.Empty };
                row.SuspendLayout(); layouts.Add(row);
                var label = MissionFilesLabel(path, .92f);
                label.Dock = DockStyle.None;
                row.Controls.Add(label);
                row.Controls.Add(MissionFilesButton("MissionFilesRemoveSourceFolder-" + identity, "Remove",
                    () => _missionDownloadJob = RemoveMissionSourceFolderAsync(path)));
                _missionSourceFolderRows.Add(path, (row, label));
                _missionFilesSourceFolders.Controls.Add(row);
            }
            _missionFilesSourceFolders.RowStyles.Clear();
            _missionFilesSourceFolders.RowCount = _missionSourceFolders.Count;
            for (var index = 0; index < _missionSourceFolders.Count; index++)
            {
                _missionFilesSourceFolders.RowStyles.Add(new RowStyle(SizeType.AutoSize));
                _missionFilesSourceFolders.SetCellPosition(_missionSourceFolderRows[_missionSourceFolders[index]].Surface, new TableLayoutPanelCellPosition(0, index));
            }
            LayoutMissionFiles(force: true);
        }
        finally { foreach (var control in layouts.AsEnumerable().Reverse()) if (!control.IsDisposed) control.ResumeLayout(true); }
    }
    private void BuildMissionFilesView(Action createCopies)
    {
        if (_missionFilesPanel is not null) return;
        if (_updatesPanel is null) BuildUpdatesPanel();
        _missionFilesPanel = new MissionDownloadSurface { Name = "MissionFilesPanel", Dock = DockStyle.Fill, AutoScroll = true, Visible = false };
        _updatesPanel!.Controls.Add(_missionFilesPanel);
        _missionFilesPage = MissionFilesColumn("MissionFilesPage", cacheMeasurements: true);
        _missionFilesPage.SuspendLayout();
        _missionFilesPage.Dock = DockStyle.None;
        _missionFilesPanel.Controls.Add(_missionFilesPage);
        var header = new TableLayoutPanel { Name = "MissionFilesHeader", AutoSize = true, Dock = DockStyle.Top, ColumnCount = 2, RowCount = 3, Margin = Padding.Empty };
        header.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        header.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        var title = MissionFilesLabel("Update existing missions", 1.6f, FontStyle.Bold);
        header.Controls.Add(title, 0, 0);
        header.SetColumnSpan(title, 2);
        header.Controls.Add(MissionFilesButton("MissionFilesBack", "Back to Updates", () => {
            _missionFilesState.ScrollPosition = _missionFilesPanel.AutoScrollPosition;
            PrepareUpdatesReveal();
            _missionFilesPanel.Hide(); _updatesContent!.Show(); _updatesPanel!.AutoScroll = true; LayoutUpdatesPanel();
        }), 1, 2);
        header.GetControlFromPosition(1, 2)!.Anchor = AnchorStyles.Top | AnchorStyles.Right;
        AddMissionFilesControl(_missionFilesPage, header);
        _missionFilesSubtitle = MissionFilesLabel("Files-only update", 1.2f, FontStyle.Bold);

        _missionFilesColumns = new EditorLayoutPanel { AutoSize = true, Dock = DockStyle.Top, ColumnCount = 2, Margin = Padding.Empty };
        _missionFilesColumns.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 61));
        _missionFilesColumns.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 39));
        _missionFilesLeft = MissionFilesColumn("MissionFilesLeft", cacheMeasurements: true);
        _missionFilesRight = MissionFilesColumn("MissionFilesRight", cacheMeasurements: true);
        _missionFilesCard = MissionFilesColumn("MissionFilesCard", cacheMeasurements: true);
        _missionFilesCard.Paint += (_, e) => {
            using var pen = new Pen(BorderColor);
            using var shape = ConfigSearchSurface.RoundedRectangle(new RectangleF(.5f, .5f, Math.Max(1, _missionFilesCard.Width - 1), Math.Max(1, _missionFilesCard.Height - 1)), 5);
            e.Graphics.DrawPath(pen, shape);
            foreach (var label in _missionFilesCard.Controls.OfType<Label>().Where(label => label.Text is "What will change" or "Kept from your missions" or "Original MIZs stay untouched."))
                e.Graphics.DrawLine(pen, _missionFilesCard.Padding.Left, label.Top - Zoomed(3), _missionFilesCard.Width - _missionFilesCard.Padding.Right, label.Top - Zoomed(3));
        };
        AddMissionFilesControl(_missionFilesRight, _missionFilesCard);
        _missionFilesColumns.Controls.Add(_missionFilesLeft, 0, 0); _missionFilesColumns.Controls.Add(_missionFilesRight, 1, 0);
        AddMissionFilesControl(_missionFilesPage, _missionFilesColumns);
        header.Controls.Add(_missionFilesSubtitle, 0, 1);
        header.SetColumnSpan(_missionFilesSubtitle, 2);
        header.Controls.Add(MissionFilesLabel("Select your missions. New copies keep your existing mission setup."), 0, 2);
        var selection = new TableLayoutPanel { AutoSize = true, Dock = DockStyle.Top, ColumnCount = 3, Margin = Padding.Empty };
        selection.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        selection.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize)); selection.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        selection.Controls.Add(MissionFilesLabel("Missions to update", 1.2f, FontStyle.Bold), 0, 0);
        selection.Controls.Add(MissionFilesButton("MissionFilesSelectAll", "Select all", () => SelectMissionFiles(true)), 1, 0);
        selection.Controls.Add(MissionFilesButton("MissionFilesClear", "Clear", () => SelectMissionFiles(false)), 2, 0);
        AddMissionFilesControl(_missionFilesLeft, selection);
        _missionFilesDcsServerBotOriginals = new WeatherCheckBox { Name = "MissionFilesDcsServerBotOriginals",
            Text = "Include DCSServerBot originals", AutoSize = true, Dock = DockStyle.Top, Visible = false, Enabled = false };
        _missionFilesDcsServerBotOriginals.CheckedChanged += (_, _) =>
        {
            if (_missionFilesRendering) return;
            if (_updatesDisposed || _missionDownloadBusy || _configLoadingOperation || _updatesBusy || _updatesInstalling
                || _updatesResult is not { FilesEnvelopeAvailable: true }
                || _missionFilesPreparation?.Groups.Any(group => group.HasDcsServerBotFolder) != true)
            { RefreshMissionFilesSelection(); return; }
            _missionFilesIncludeDcsServerBotOriginals = _missionFilesDcsServerBotOriginals.Checked;
            _missionDownloadJob = OpenMissionFilesAsync(refreshInventory: true);
        };
        _toolTip.SetToolTip(_missionFilesDcsServerBotOriginals,
            "Read .miz.orig backups from discovered .dcssb folders. New .miz copies save to the owning Missions folder unless Custom Folder is enabled.");
        AddMissionFilesControl(_missionFilesLeft, _missionFilesDcsServerBotOriginals);
        _missionFilesOtherToggle = MissionFilesButton("MissionFilesOtherToggle", "› Show other missions (0)", () => {
            _missionFilesState.ShowOtherMissions = !_missionFilesState.ShowOtherMissions;
            RefreshMissionFilesSelection();
        });
        _missionFilesOtherToggle.Visible = false;
        AddMissionFilesControl(_missionFilesLeft, _missionFilesOtherToggle);
        _missionFilesGroups = MissionFilesColumn("MissionFilesGroups", cacheMeasurements: true);
        AddMissionFilesControl(_missionFilesLeft, _missionFilesGroups);
        _missionFilesInstalledToggle = MissionFilesButton("MissionFilesInstalledToggle", "› Show currently installed (0)", () => {
            _missionFilesState.ShowInstalled = !_missionFilesState.ShowInstalled;
            RefreshMissionFilesSelection();
        });
        _missionFilesInstalledToggle.Visible = false;
        AddMissionFilesControl(_missionFilesLeft, _missionFilesInstalledToggle);
        _missionFilesInstalledGroups = MissionFilesColumn("MissionFilesInstalledGroups", cacheMeasurements: true);
        AddMissionFilesControl(_missionFilesLeft, _missionFilesInstalledGroups);
        _missionFilesSourcesActions = new FlowLayoutPanel { Name = "MissionFilesSourcesActions", AutoSize = true,
            AutoSizeMode = AutoSizeMode.GrowAndShrink, Dock = DockStyle.Top, Margin = Padding.Empty, WrapContents = true };
        _missionFilesSourcesActions.Controls.Add(MissionFilesButton("MissionFilesAdd", "Add MIZ files…", () => MissionFilesAddRequested?.Invoke()));
        _missionFilesSourcesActions.Controls.Add(MissionFilesButton("MissionFilesAddSourceFolder", "Add source folder…",
            () => _missionDownloadJob = AddMissionSourceFolderAsync()));
        _missionFilesSourcesActions.Controls.Add(MissionFilesButton("MissionFilesRefreshMissions", "Refresh missions",
            () => _missionDownloadJob = OpenMissionFilesAsync(refreshInventory: true)));
        AddMissionFilesControl(_missionFilesLeft, _missionFilesSourcesActions);
        _missionFilesDeleteDivider = new Panel { Name = "MissionFilesDeleteDivider", Height = 1, Dock = DockStyle.Top, Margin = new Padding(0, Zoomed(12), 0, 0) };
        AddMissionFilesControl(_missionFilesLeft, _missionFilesDeleteDivider);
        _missionFilesDeleteRow = new TableLayoutPanel { Name = "MissionFilesDeleteRow", AutoSize = true, Dock = DockStyle.Top, ColumnCount = 2, Margin = Padding.Empty };
        _missionFilesDeleteRow.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        _missionFilesDeleteRow.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        _missionFilesDeleteCount = MissionFilesLabel("No missions selected", .92f);
        _missionFilesDelete = MissionFilesButton("MissionFilesDelete", "Delete selected…", () => _missionDownloadJob = DeleteSelectedMissionFilesAsync());
        _missionFilesDelete.Enabled = false;
        _missionFilesDelete.Anchor = AnchorStyles.Top | AnchorStyles.Right;
        _missionFilesDelete.AccessibleDescription = "Move selected source missions to the Recycle Bin after confirmation. Refuses deletion if recycling is unavailable.";
        _missionFilesDeleteRow.Controls.Add(_missionFilesDeleteCount, 0, 0);
        _missionFilesDeleteRow.Controls.Add(_missionFilesDelete, 1, 0);
        AddMissionFilesControl(_missionFilesLeft, _missionFilesDeleteRow);
        AddMissionFilesControl(_missionFilesLeft, MissionFilesLabel("Moves selected source files to the Recycle Bin after confirmation.", .92f));
        _missionFilesSourceFolders = MissionFilesColumn("MissionFilesSourceFolders");
        AddMissionFilesControl(_missionFilesLeft, _missionFilesSourceFolders);
        _missionFilesSourceError = MissionFilesLabel("", .92f);
        _missionFilesSourceError.Visible = false;
        AddMissionFilesControl(_missionFilesLeft, _missionFilesSourceError);
        AddMissionFilesControl(_missionFilesLeft, MissionFilesLabel("Other missions can be selected for deletion, but cannot receive script updates.", .92f));
        AddMissionFilesControl(_missionFilesCard, MissionFilesLabel("Create updated copies", 1.2f, FontStyle.Bold));
        AddMissionFilesControl(_missionFilesCard, MissionFilesLabel("Output location", 1, FontStyle.Bold));
        AddMissionFilesControl(_missionFilesCard, MissionFilesLabel("Beside each original mission\nEach instance keeps its own Missions folder."));
        _missionFilesCustomFolder = new WeatherCheckBox { Name = "MissionFilesCustomFolder", Text = "Custom Folder",
            AutoSize = true, Dock = DockStyle.Top };
        _missionFilesCustomFolder.CheckedChanged += (_, _) => SetCustomMissionOutputMode(_missionFilesCustomFolder!.Checked);
        AddMissionFilesControl(_missionFilesCard, _missionFilesCustomFolder);
        _missionFilesCustomOutputPath = MissionFilesLabel("");
        _missionFilesCustomOutputPath.Name = "MissionFilesCustomOutputPath";
        AddMissionFilesControl(_missionFilesCard, _missionFilesCustomOutputPath);
        _missionFilesChooseOutputFolder = MissionFilesButton("MissionFilesChooseOutputFolder", "Choose Folder…", ChooseCustomMissionOutputFolder);
        _missionFilesChooseOutputFolder.Click += async (_, _) => await RefreshDedicatedRegistrationTargetsAsync();
        AddMissionFilesControl(_missionFilesCard, _missionFilesChooseOutputFolder);
        _missionFilesRegisterServer = CreateServerRegistrationChoice("MissionFilesRegisterServer");
        AddMissionFilesControl(_missionFilesCard, _missionFilesRegisterServer);
        _missionFilesServerHint = MissionFilesLabel("", .92f);
        _missionFilesServerHint.Name = "MissionFilesServerHint";
        AddMissionFilesControl(_missionFilesCard, _missionFilesServerHint);
        AddMissionFilesControl(_missionFilesCard, MissionFilesLabel("What will change", 1, FontStyle.Bold));
        AddMissionFilesControl(_missionFilesCard, MissionFilesLabel("•  Common and map setup scripts\n•  Embedded Config updated; current values kept\n•  Release version in the new filename"));
        var configs = new WeatherCheckBox { Name = "MissionFilesUpdateConfigs", Text = "Also update instance Configs", AutoSize = true, Dock = DockStyle.Top };
        configs.CheckedChanged += (_, _) => _missionFilesState.UpdateInstanceConfigs = configs.Checked;
        AddMissionFilesControl(_missionFilesCard, configs);
        AddMissionFilesControl(_missionFilesCard, MissionFilesLabel("Selected instances only; keep current settings.", .92f));
        AddMissionFilesControl(_missionFilesCard, MissionFilesLabel("Kept from your missions", 1, FontStyle.Bold));
        var keptMissionDetails = MissionFilesLabel("•  Units • weather • date & time\n•  Mission options • warehouses");
        keptMissionDetails.UseMnemonic = false;
        AddMissionFilesControl(_missionFilesCard, keptMissionDetails);
        _missionFilesOriginalsHint = MissionFilesLabel("Original MIZs stay untouched.");
        AddMissionFilesControl(_missionFilesCard, _missionFilesOriginalsHint);
        var action = _missionFilesAction = new TableLayoutPanel { Name = "MissionFilesAction", AutoSize = true, Dock = DockStyle.Top, ColumnCount = 1 };
        action.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        var summary = _missionFilesSummaryArea = new Panel { Name = "MissionFilesSummaryArea", Dock = DockStyle.Top };
        _missionFilesSummary = MissionFilesLabel("0 new mission copies", 1.05f, FontStyle.Bold);
        _missionFilesOutput = MissionFilesLabel("");
        _missionFilesSummary.AutoSize = _missionFilesOutput.AutoSize = false;
        _missionFilesSummary.Dock = _missionFilesOutput.Dock = DockStyle.None;
        summary.Controls.AddRange([_missionFilesSummary, _missionFilesOutput]);
        _missionFilesCreate = MissionFilesButton("MissionFilesCreate", "Create updated copies", () => {
            if (_missionFilesState.Selected.Count > 0) createCopies();
        }, true);
        _missionFilesCreate.Enabled = false;
        _missionFilesCreate.Anchor = AnchorStyles.Top | AnchorStyles.Right;
        AddMissionFilesControl(_missionFilesRight, _missionFilesCreate);
        action.Padding = new Padding(0, Zoomed(10), 0, 0);
        action.Paint += (_, e) => { using var pen = new Pen(BorderColor); e.Graphics.DrawLine(pen, 0, 0, action.Width, 0); };
        action.Controls.Add(summary, 0, 0);
        AddMissionFilesControl(_missionFilesPage, action);
        _missionFilesResult = MissionFilesLabel("", .92f);
        _missionFilesResult.Name = "MissionFilesResult";

        _missionFilesOpenFolder = MissionFilesButton("MissionFilesOpenFolder", "Open mission folder", () => {
            var path = _missionFilesApplied?.Items.FirstOrDefault(item => item.OutputPath is not null)?.OutputPath;
            if (path is null) return;
            try { System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo(Path.GetDirectoryName(path)!) { UseShellExecute = true }); }
            catch (Exception error)
            {
                _missionFilesResultGlyph!.Visible = false;
                _missionFilesResult.Text += Environment.NewLine + "Could not open mission folder: " + error.Message;
            }
        });
        _missionFilesOpenFolder.Visible = false;
        _missionFilesResultGlyph = new ManagerVerifiedGlyph { Name = "MissionFilesSuccessGlyph", Visible = false };
        _missionFilesResultRow = new FlowLayoutPanel { Name = "MissionFilesResultRow", Dock = DockStyle.Top, AutoSize = true, Margin = Padding.Empty };
        _missionFilesResultRow.Controls.AddRange([_missionFilesResultGlyph, _missionFilesResult, _missionFilesOpenFolder]);
        AddMissionFilesControl(_missionFilesPage, _missionFilesResultRow);
        _missionFilesDetails = MissionFilesLabel("", .92f);
        _missionFilesDetails.Name = "MissionFilesDetails";
        _missionFilesDetails.Visible = false;
        _missionFilesDetailsToggle = MissionFilesButton("MissionFilesDetailsToggle", "Show details", () => {
            _missionFilesDetails.Visible = !_missionFilesDetails.Visible;
            _missionFilesDetailsToggle!.Text = _missionFilesDetails.Visible ? "Hide details" : "Show details";
        });
        _missionFilesDetailsToggle.Visible = false;
        AddMissionFilesControl(_missionFilesPage, _missionFilesDetailsToggle);
        AddMissionFilesControl(_missionFilesPage, _missionFilesDetails);
        _missionFilesPanel.Scroll += (_, _) => _missionFilesState.ScrollPosition = _missionFilesPanel.AutoScrollPosition;
        _missionFilesPanel.SizeChanged += (_, _) =>
        {
            if (_missionFilesPanel.Visible && _missionFilesAppearance != (_missionFilesPanel.Width, _uiZoomPercent, _darkMode))
            {
                LayoutMissionFiles();
                if (_missionFilesPanel.IsHandleCreated)
                    _missionFilesPanel.BeginInvoke((Action)(() =>
                    {
                        if (!_missionFilesPanel.IsDisposed && !_missionFilesPanel.Disposing && _missionFilesPanel.Visible)
                            _missionFilesPanel.PerformLayout();
                    }));
            }
        };
        _missionFilesPanel.FontChanged += (_, _) => LayoutMissionFiles();
        _missionFilesPanel.BackColorChanged += (_, _) => LayoutMissionFiles();
        _missionFilesPage.ResumeLayout(false); // The first layout below sizes the completed page.
        EnsureMissionFilesFontLifetime();
        RefreshCustomMissionOutputControls();
        ReconcileMissionSourceFolders();
        LayoutMissionFiles();
    }
    private void EnsureMissionFilesFontLifetime()
    {
        if (_missionFilesFontLifetime) return;
        _missionFilesFontLifetime = true;
        Disposed += (_, _) => { foreach (var font in _missionPresentationFonts.Values) font.Dispose(); _missionPresentationFonts.Clear(); };
    }
    private event Action? MissionFilesAddRequested;
    private void PresentMissionFilesRelease(string release) => _missionFilesSubtitle!.Text = "Files-only update • Foothold " + release;
    private void ShowMissionFilesView()
    {
        var scroll = _missionFilesState.ScrollPosition;
        var layouts = new Control[] { _updatesPanel!, _missionFilesPanel!, _missionFilesPage!, _missionFilesColumns!, _missionFilesLeft!, _missionFilesGroups!,
            _missionFilesSourcesActions!, _missionFilesSourceFolders! }
            .Concat(_missionSourceFolderRows.Values.Select(row => (Control)row.Surface))
            .Concat(_missionFileGroups.Values.SelectMany(group => new Control[] { group.Surface, group.Rows })).ToArray();
        foreach (var control in layouts) control.SuspendLayout();
        try
        {
        _updatesContent!.Hide(); _updatesPanel!.AutoScroll = false; _updatesPanel.Show(); _updatesPanel.BringToFront();
        _missionFilesPanel!.Show(); _missionFilesPanel.BringToFront(); LayoutMissionFiles();
        }
        finally
        {
            foreach (var control in layouts.Reverse()) if (!control.IsDisposed) control.ResumeLayout(true);
        }
        _missionFilesPanel.AutoScrollPosition = new Point(-scroll.X, -scroll.Y);
    }
    private void ReconcileMissionFileRows(IReadOnlyList<FileUpdateInspection> rows, long generation)
    {
        if (generation < _missionFilesGeneration) return;
        _missionFilesGeneration = generation;
        var incoming = rows.ToDictionary(row => Path.GetFullPath(row.Path), StringComparer.OrdinalIgnoreCase);
        var removed = _missionFileRows.Keys.Where(path => !incoming.ContainsKey(path)).ToArray();
        var changed = incoming.Where(pair => !_missionFilesState.Candidates.TryGetValue(pair.Key, out var current) || current != pair.Value).ToArray();
        if (removed.Length == 0 && changed.Length == 0) { LayoutMissionFiles(); return; }
        var geometryChanged = removed.Length > 0 || changed.Any(pair =>
            !_missionFilesState.Candidates.TryGetValue(pair.Key, out var previous) || previous.GroupId != pair.Value.GroupId
            || previous.GroupName != pair.Value.GroupName || previous.GroupSummary != pair.Value.GroupSummary || previous.FriendlyName != pair.Value.FriendlyName || previous.IsCurrentVersion != pair.Value.IsCurrentVersion
            || (!_missionFilesState.ShowOtherMissions && ((previous is { State: FileUpdateInspectionState.Compatible, ProposedOutputName: not null })
                != (pair.Value is { State: FileUpdateInspectionState.Compatible, ProposedOutputName: not null }))));
        List<Control>? layouts = null;
        if (geometryChanged)
        {
            layouts = [_missionFilesPanel!, _missionFilesPage!, _missionFilesColumns!, _missionFilesLeft!, _missionFilesGroups!, _missionFilesInstalledGroups!];
            foreach (var group in _missionFileGroups.Values) { layouts.Add(group.Surface); layouts.Add(group.Rows); }
            foreach (var control in layouts) control.SuspendLayout();
        }
        try
        {
        foreach (var path in removed)
        {
            var old = _missionFileRows[path];
            _missionFilesLabels.Remove(old.Name); _missionFilesLabels.Remove(old.File); _missionFilesLabels.Remove(old.Status);
            old.Surface.Dispose(); _missionFileRows.Remove(path); _missionFilesState.Selected.Remove(path); _missionFilesState.Candidates.Remove(path);
        }
        foreach (var (path, candidate) in changed)
        {
            _missionFilesState.Candidates[path] = candidate;
            var presentationGroup = candidate.IsCurrentVersion ? "installed:" + candidate.GroupId : candidate.GroupId;
            if (!_missionFileGroups.TryGetValue(presentationGroup, out var group))
            {
                var surface = MissionFilesColumn("MissionFilesInstance-" + presentationGroup, cacheMeasurements: true);
                var header = new TableLayoutPanel { AutoSize = true, Dock = DockStyle.Top, ColumnCount = 3, Margin = Padding.Empty };
                header.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize)); header.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
                header.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
                var groupId = presentationGroup;
                var body = MissionFilesColumn("MissionFilesChildren-" + groupId, cacheMeasurements: true);
                if (layouts is not null)
                {
                    surface.SuspendLayout(); body.SuspendLayout(); layouts.Add(surface); layouts.Add(body);
                }
                var disclosure = MissionFilesButton("MissionFilesGroupToggle-" + groupId, "⌄", () => {
                    if (!_missionFilesState.Collapsed.Add(groupId)) _missionFilesState.Collapsed.Remove(groupId);
                    var expanded = !_missionFilesState.Collapsed.Contains(groupId);
                    body.Visible = expanded;
                    _missionFileGroups[groupId].Disclosure.Text = expanded ? "⌄" : "›";
                });
                var check = new WeatherCheckBox { Name = "MissionFilesGroup-" + groupId, ThreeState = true, AutoSize = false, Size = new Size(Zoomed(24), Zoomed(32)) };
                check.CheckStateChanged += (_, _) => { if (!_missionFilesRendering) SelectMissionFiles(check.CheckState == CheckState.Checked, groupId); };
                var heading = MissionFilesColumn("MissionFilesGroupHeading-" + groupId);
                var groupName = MissionFilesLabel(candidate.GroupName, 1.05f, FontStyle.Bold);
                AddMissionFilesControl(heading, groupName);
                var detail = MissionFilesLabel(candidate.GroupSummary, .92f);
                AddMissionFilesControl(heading, detail);
                header.Controls.Add(disclosure, 0, 0); header.Controls.Add(check, 1, 0); header.Controls.Add(heading, 2, 0);
                AddMissionFilesControl(surface, header); AddMissionFilesControl(surface, body);
                group = new MissionFileGroup(surface, body, check, disclosure, detail, groupName);
                _missionFileGroups.Add(groupId, group); AddMissionFilesControl(candidate.IsCurrentVersion ? _missionFilesInstalledGroups! : _missionFilesGroups!, surface);
            }
            group.Name.Text = candidate.GroupName; group.Summary.Text = candidate.GroupSummary;
            if (!_missionFileRows.TryGetValue(path, out var row))
            {
                var check = new WeatherCheckBox { Name = "MissionFileRow-" + path, Text = "", AccessibleName = candidate.FriendlyName };
                var surface = new Panel { Name = "MissionFileSurface-" + path, Dock = DockStyle.Top, Margin = new Padding(0, 0, 0, 1) };
                var name = MissionFilesLabel(candidate.FriendlyName, 1, FontStyle.Bold);
                var file = MissionFilesLabel(Path.GetFileName(path), .9f);
                var status = MissionFilesLabel(candidate.Reason, .9f);
                name.Dock = file.Dock = status.Dock = DockStyle.None;
                surface.Controls.AddRange([check, name, file, status]);
                row = new MissionFileRow(surface, check, name, file, status);
                _missionFileRows.Add(path, row);
                AddMissionFilesControl(group.Rows, surface);
                check.CheckedChanged += (_, _) => {
                    if (_missionFilesRendering) return;
                    if (check.Checked && check.Enabled)
                        _missionFilesState.Selected.Add(path);
                    else _missionFilesState.Selected.Remove(path);
                    RefreshMissionFilesSelection();
                };
            }
            if (row.Surface.Parent != group.Rows) { row.Surface.Parent!.Controls.Remove(row.Surface); AddMissionFilesControl(group.Rows, row.Surface); }
            if (!geometryChanged)
            {
                var measured = TextRenderer.MeasureText(candidate.Reason, row.Status.Font);
                geometryChanged = measured.Width > row.Surface.Width - row.Status.Left - Zoomed(4)
                    || measured.Height > row.Surface.Height - Zoomed(12);
            }
            row.Surface.SuspendLayout();
            try
            {
                row.Name.Text = candidate.FriendlyName; row.File.Text = Path.GetFileName(path); row.Status.Text = candidate.IsCurrentVersion ? "Currently installed" : candidate.State == FileUpdateInspectionState.Updated ? "Already updated" : candidate.State.ToString();
                _toolTip.SetToolTip(row.Status, candidate.Reason);
                row.Check.Enabled = candidate.SourceIdentity is not null
                    || candidate.ProposedOutputName is not null && (candidate.IsCurrentVersion || candidate.State == FileUpdateInspectionState.Compatible);
                if (!row.Check.Enabled) _missionFilesState.Selected.Remove(path);
            }
            finally { row.Surface.ResumeLayout(false); }
        }
        foreach (var id in _missionFileGroups.Keys.Where(id => !incoming.Values.Any(row => (row.IsCurrentVersion ? "installed:" + row.GroupId : row.GroupId) == id)).ToArray())
        {
            var group = _missionFileGroups[id];
            foreach (var label in EnumerateChildControls<Control>(group.Surface).OfType<Label>()) _missionFilesLabels.Remove(label);
            group.Surface.Dispose(); _missionFileGroups.Remove(id); _missionFilesState.Collapsed.Remove(id);
        }
        foreach (var table in _missionFileGroups.Values.Select(group => group.Rows).Append(_missionFilesGroups!).Append(_missionFilesInstalledGroups!))
        {
            var children = table.Controls.Cast<Control>().OrderBy(control => table.GetRow(control)).ToArray();
            if (table.RowStyles.Count == children.Length && children.Select((child, index) => table.GetRow(child) == index).All(position => position)) continue;
            table.SuspendLayout(); table.RowStyles.Clear();
            for (var index = 0; index < children.Length; index++)
            { table.SetCellPosition(children[index], new TableLayoutPanelCellPosition(0, index)); table.RowStyles.Add(new RowStyle(SizeType.AutoSize)); }
            table.RowCount = children.Length; table.ResumeLayout(true);
        }
        RefreshMissionFilesSelection(); LayoutMissionFiles(force: geometryChanged);
        }
        finally
        {
            if (layouts is not null)
                for (var index = layouts.Count - 1; index >= 0; index--)
                    if (!layouts[index].IsDisposed) layouts[index].ResumeLayout(true);
        }
    }
    private void SelectMissionFiles(bool selected, string? groupId = null)
    {
        foreach (var (path, candidate) in _missionFilesState.Candidates)
        {
            if (groupId is not null && (candidate.IsCurrentVersion ? "installed:" + candidate.GroupId : candidate.GroupId) != groupId) continue;
            if (selected && (candidate.ProposedOutputName is not null && (candidate.IsCurrentVersion
                ? _missionFilesState.ShowInstalled : candidate.State == FileUpdateInspectionState.Compatible)
                || _missionFilesState.ShowOtherMissions && !candidate.IsCurrentVersion && candidate.SourceIdentity is not null))
                _missionFilesState.Selected.Add(path);
            else _missionFilesState.Selected.Remove(path);
        }
        RefreshMissionFilesSelection();
    }
    private void RefreshMissionFilesSelection()
    {
        RefreshServerRegistrationChoices();
        _missionFilesRendering = true;
        var layouts = new Control[] { _updatesPanel!, _missionFilesPanel!, _missionFilesPage!, _missionFilesColumns!, _missionFilesLeft!,
            _missionFilesRight!, _missionFilesGroups!, _missionFilesInstalledGroups!, _missionFilesAction!, _missionFilesSummaryArea! }
            .Concat(_missionFileGroups.Values.SelectMany(group => new Control[] { group.Surface, group.Rows })).ToArray();
        foreach (var control in layouts) control.SuspendLayout();
        try
        {
            var originalsAvailable = _missionFilesPreparation?.Groups.Any(group => group.HasDcsServerBotFolder) == true;
            _missionFilesDcsServerBotOriginals!.Checked = _missionFilesIncludeDcsServerBotOriginals;
            _missionFilesDcsServerBotOriginals.Visible = originalsAvailable;
            _missionFilesDcsServerBotOriginals.Enabled = originalsAvailable && !_updatesDisposed && !_missionDownloadBusy
                && !_configLoadingOperation && !_updatesBusy && !_updatesInstalling && _updatesResult?.FilesEnvelopeAvailable == true;
            var otherCount = 0; var installedCount = 0;
            foreach (var (path, row) in _missionFileRows)
            {
                var currentVersion = _missionFilesState.Candidates[path].IsCurrentVersion;
                var compatible = _missionFilesState.Candidates[path] is { State: FileUpdateInspectionState.Compatible, ProposedOutputName: not null };
                if (currentVersion) installedCount++; else if (!compatible) otherCount++;
                row.Surface.Visible = currentVersion ? _missionFilesState.ShowInstalled : compatible || _missionFilesState.ShowOtherMissions;
                row.Check.Enabled = !_missionDownloadBusy && !_configLoadingOperation
                    && (currentVersion || compatible || _missionFilesState.Candidates[path].SourceIdentity is not null);
                if (!row.Check.Enabled && !_missionDownloadBusy && !_configLoadingOperation) _missionFilesState.Selected.Remove(path);
                row.Status.ForeColor = currentVersion ? BrandColor : compatible ? (_darkMode ? Color.FromArgb(91, 230, 90) : Color.FromArgb(30, 119, 44)) : HelpTextColor;
                var selected = _missionFilesState.Selected.Contains(path);
                if (row.Check.Checked != selected || row.Surface.BackColor != (selected ? (_darkMode ? Color.FromArgb(26, 45, 61) : SelectionBackground) : MainBackground))
                {
                    row.Check.Checked = selected;
                    row.Surface.BackColor = selected ? (_darkMode ? Color.FromArgb(26, 45, 61) : SelectionBackground) : MainBackground;
                    foreach (Control child in row.Surface.Controls) child.BackColor = row.Surface.BackColor;
                    row.Surface.Invalidate(true);
                }
            }
            foreach (var (id, group) in _missionFileGroups)
            {
                var installedGroup = id.StartsWith("installed:", StringComparison.Ordinal);
                var eligible = _missionFilesState.Candidates.Where(pair => (pair.Value.IsCurrentVersion ? "installed:" + pair.Value.GroupId : pair.Value.GroupId) == id
                    && (pair.Value.ProposedOutputName is not null && (installedGroup || pair.Value.State == FileUpdateInspectionState.Compatible)
                        || _missionFilesState.ShowOtherMissions && !pair.Value.IsCurrentVersion && pair.Value.SourceIdentity is not null)).Select(pair => pair.Key).ToArray();
                group.Surface.Visible = installedGroup ? _missionFilesState.ShowInstalled : eligible.Length > 0 || _missionFilesState.ShowOtherMissions;
                var count = eligible.Count(_missionFilesState.Selected.Contains);
                group.Check.Enabled = eligible.Length > 0 && !_missionDownloadBusy && !_configLoadingOperation;
                var state = count == 0 ? CheckState.Unchecked : count == eligible.Length ? CheckState.Checked : CheckState.Indeterminate;
                if (group.Check.CheckState != state) group.Check.CheckState = state;
            }
            _missionFilesOtherToggle!.Visible = otherCount > 0;
            var otherCaption = (_missionFilesState.ShowOtherMissions ? "⌄ Hide" : "› Show") + " other missions (" + otherCount + ")";
            if (_missionFilesOtherToggle.Text != otherCaption)
            {
                _missionFilesOtherToggle.Text = otherCaption;
                _missionFilesOtherToggle.Width = Math.Max(
                    TextRenderer.MeasureText("› Show other missions (" + otherCount + ")", _missionFilesOtherToggle.Font).Width,
                    TextRenderer.MeasureText("⌄ Hide other missions (" + otherCount + ")", _missionFilesOtherToggle.Font).Width) + Zoomed(28);
            }
            _missionFilesInstalledToggle!.Visible = installedCount > 0;
            var installedCaption = (_missionFilesState.ShowInstalled ? "⌄ Hide" : "› Show") + " currently installed (" + installedCount + ")";
            if (_missionFilesInstalledToggle.Text != installedCaption)
            {
                _missionFilesInstalledToggle.Text = installedCaption;
                _missionFilesInstalledToggle.Width = TextRenderer.MeasureText("› Show currently installed (" + installedCount + ")", _missionFilesInstalledToggle.Font).Width + Zoomed(28);
            }
            var updatePaths = _missionFilesState.Selected.Where(path => _missionFilesState.Candidates[path] is { ProposedOutputName: not null } candidate
                && (candidate.IsCurrentVersion || candidate.State == FileUpdateInspectionState.Compatible)).ToArray();
            var reinstalls = updatePaths.Count(path => _missionFilesState.Candidates[path].IsCurrentVersion);
            _missionFilesOriginalsHint!.Text = reinstalls > 0 ? "Reinstallation asks before replacing a current mission." : "Original MIZs stay untouched.";
            _missionFilesSummary!.Text = reinstalls > 0 ? updatePaths.Length + " selected · " + reinstalls + " to reinstall" : updatePaths.Length + " new mission copies";
            _missionFilesCreate!.Text = reinstalls > 0 ? "Apply selected scripts" : "Create updated copies";
            _missionFilesOutput!.Text = updatePaths.Select(path => _missionFilesState.Candidates[path].ProposedOutputName).FirstOrDefault() ?? "";
            _missionFilesCreate!.Enabled = updatePaths.Length > 0 && updatePaths.Length == _missionFilesState.Selected.Count
                && !_missionDownloadBusy && !_configLoadingOperation;
            _missionFilesDeleteCount!.Text = _missionFilesState.Selected.Count == 0 ? "No missions selected"
                : _missionFilesState.Selected.Count + (_missionFilesState.Selected.Count == 1 ? " mission selected" : " missions selected");
            _missionFilesDelete!.Enabled = _missionFilesState.Selected.Count > 0 && CanDeleteMissionFiles;
            _missionFilesSourcesActions!.Enabled = _missionFilesSourceFolders!.Enabled = !_missionDownloadBusy && !_configLoadingOperation;
        }
        finally
        {
            EditorSection.RunLayoutPass(() => {
                for (var index = layouts.Length - 1; index >= 0; index--) layouts[index].ResumeLayout(true);
            });
            _missionFilesRendering = false;
        }
    }
    private void LayoutMissionFiles(bool force = false)
    {
        if (_missionFilesPanel is null || _missionFilesArranging || _missionFilesPage is null) return;
        var stamp = (_missionFilesPanel.Width, _uiZoomPercent, _darkMode);
        if (!force && _missionFilesAppearance == stamp) return;
        _missionFilesArranging = true;
        var sourceLayouts = new Control?[] { _missionFilesSourcesActions, _missionFilesSourceFolders }
            .Concat(_missionSourceFolderRows.Values.Select(row => (Control?)row.Surface)).ToArray();
        foreach (var control in sourceLayouts) control?.SuspendLayout();
        try
        {
            _missionFilesPage.SuspendLayout();
            var pageWidth = Math.Max(100, _missionFilesPanel.ClientSize.Width - SystemInformation.VerticalScrollBarWidth - Zoomed(8));
            _missionFilesPage.Padding = new Padding(Zoomed(24));
            _missionFilesPage.MaximumSize = new Size(pageWidth, 0);
            _missionFilesPage.MinimumSize = new Size(pageWidth, 0);
            _missionFilesPage.Width = pageWidth;
            var width = Math.Max(100, _missionFilesPage.Width - _missionFilesPage.Padding.Horizontal);
            var configChoice = _missionFilesCard!.Controls.OfType<WeatherCheckBox>().Single(check => check.Name == "MissionFilesUpdateConfigs");
            configChoice.Font = MissionPresentationFont(1f, FontStyle.Regular);
            _missionFilesCard.Padding = new Padding(Zoomed(16));
            if (_missionFilesRegisterServer is not null) _missionFilesRegisterServer.Font = configChoice.Font;
            var minimumCardWidth = Math.Max(configChoice.GetPreferredSize(Size.Empty).Width,
                (CanOfferFilesServerRegistration ? _missionFilesRegisterServer?.GetPreferredSize(Size.Empty).Width ?? 0 : 0)) + _missionFilesCard.Padding.Horizontal + configChoice.Margin.Horizontal;
            var narrow = width < Zoomed(860) || width * 39 / 100 < minimumCardWidth;
            _missionFilesColumns!.SuspendLayout();
            _missionFilesColumns.Width = width;
            _missionFilesColumns.MinimumSize = new Size(width, 0); _missionFilesColumns.MaximumSize = new Size(width, 0);
            _missionFilesColumns.ColumnCount = narrow ? 1 : 2;
            _missionFilesColumns.RowCount = narrow ? 2 : 1;
            _missionFilesColumns.ColumnStyles.Clear();
            _missionFilesColumns.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, narrow ? 100 : 61));
            if (!narrow) _missionFilesColumns.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 39));
            _missionFilesColumns.SetCellPosition(_missionFilesLeft!, new TableLayoutPanelCellPosition(0, 0));
            _missionFilesColumns.SetCellPosition(_missionFilesRight!, new TableLayoutPanelCellPosition(narrow ? 0 : 1, narrow ? 1 : 0));
            var leftWidth = narrow ? width : width * 61 / 100 - Zoomed(18);
            var rightWidth = narrow ? width : width * 39 / 100;
            _missionFilesLeft!.Margin = new Padding(0, 0, narrow ? 0 : Zoomed(18), Zoomed(18));
            _missionFilesLeft.MinimumSize = new Size(leftWidth, 0); _missionFilesLeft.MaximumSize = new Size(leftWidth, 0);
            _missionFilesCard.MinimumSize = new Size(rightWidth, 0); _missionFilesCard.MaximumSize = new Size(rightWidth, 0);
            _missionFilesRight!.MinimumSize = new Size(rightWidth, 0); _missionFilesRight.MaximumSize = new Size(rightWidth, 0);
            foreach (var label in EnumerateChildControls<Label>(_missionFilesPage))
            {
                var appearance = _missionFilesLabels[label];
                label.Font = MissionPresentationFont(appearance.Scale * MissionPageLabelScale, appearance.Style);
                label.ForeColor = PrimaryTextColor; label.BackColor = label.Parent!.BackColor;
                label.MaximumSize = new Size(label.Parent == _missionFilesCard ? Math.Max(50, rightWidth - _missionFilesCard.Padding.Horizontal) : Math.Max(50, leftWidth - Zoomed(50)), 0);
                label.Margin = new Padding(0, Zoomed(3), 0, Zoomed(6));
            }
            foreach (var button in EnumerateChildControls<Control>(_missionFilesPage).OfType<Button>())
            {
                button.Font = MissionPresentationFont(1f, FontStyle.Regular); StyleButton(button);
                button.Size = new Size(TextRenderer.MeasureText(button.Text, button.Font).Width + Zoomed(26),
                    Math.Max(Zoomed(34), button.Font.Height + Zoomed(10)));
                button.Margin = new Padding(0, Zoomed(4), Zoomed(8), Zoomed(6));
                if (button.Name == "MissionFilesDelete")
                {
                    button.Width += Zoomed(22);
                    button.ForeColor = SystemInformation.HighContrast ? SystemColors.ControlText
                        : _darkMode ? Color.FromArgb(243, 160, 167) : Color.FromArgb(165, 45, 53);
                    button.FlatAppearance.BorderColor = SystemInformation.HighContrast ? SystemColors.ControlText
                        : _darkMode ? Color.FromArgb(126, 82, 92) : Color.FromArgb(184, 118, 125);
                }
                else if (button.Name == "MissionFilesBack") SizeMissionBackButton(button);
                else if (button.Name is "MissionFilesSelectAll" or "MissionFilesClear" or "MissionFilesOtherToggle" or "MissionFilesInstalledToggle" or "MissionFilesOpenFolder" || button.Name.StartsWith("MissionFilesGroupToggle-", StringComparison.Ordinal))
                { button.FlatAppearance.BorderSize = 0; button.BackColor = MainBackground; button.ForeColor = BrandColor;
                    if (!button.Name.StartsWith("MissionFilesGroupToggle-", StringComparison.Ordinal)) button.Font = MissionPresentationFont(1f, FontStyle.Underline); }
            }
            _missionFilesResultRow!.MaximumSize = new Size(width, 0);
            _missionFilesResultGlyph!.Size = new Size(Zoomed(22), Zoomed(22));
            _missionFilesResultGlyph.Margin = new Padding(0, Zoomed(3), Zoomed(6), 0);
            _missionFilesSourcesActions!.MaximumSize = new Size(leftWidth, 0);
            _missionFilesSourceFolders!.MaximumSize = new Size(leftWidth, 0);
            _missionFilesDeleteDivider!.BackColor = BorderColor;
            _missionFilesDeleteRow!.MinimumSize = _missionFilesDeleteRow.MaximumSize = new Size(leftWidth, 0);
            _missionFilesDeleteRow.Padding = new Padding(0, Zoomed(12), 0, 0);
            _missionFilesDeleteCount!.MaximumSize = new Size(Math.Max(50, leftWidth - _missionFilesDelete!.Width - Zoomed(20)), 0);
            foreach (var row in _missionSourceFolderRows.Values)
            {
                row.Surface.MinimumSize = row.Surface.MaximumSize = new Size(leftWidth, 0);
                var remove = row.Surface.Controls.OfType<Button>().Single();
                var pathWidth = Math.Max(50, leftWidth - remove.Width - remove.Margin.Horizontal - row.Path.Margin.Horizontal);
                row.Path.MaximumSize = new Size(pathWidth, 0);
                row.Path.SetBounds(0, Zoomed(3), pathWidth, row.Path.GetPreferredSize(new Size(pathWidth, 0)).Height);
                remove.Location = new Point(leftWidth - remove.Width - remove.Margin.Horizontal, Zoomed(4));
                row.Surface.Height = Math.Max(row.Path.Bottom, remove.Bottom) + Zoomed(6);
            }
            foreach (var check in EnumerateChildControls<Control>(_missionFilesPage).OfType<WeatherCheckBox>())
            { check.Font = MissionPresentationFont(1f, FontStyle.Regular); check.ForeColor = PrimaryTextColor; check.BackColor = check.Parent!.BackColor; check.DisabledTextColor = HelpTextColor; }
            foreach (var row in _missionFileRows.Values)
            {
                var statusWidth = TextRenderer.MeasureText(row.Status.Text, row.Status.Font).Width + Zoomed(8);
                var textWidth = Math.Max(70, leftWidth - Zoomed(54) - statusWidth);
                row.Name.MaximumSize = row.File.MaximumSize = new Size(textWidth, 0);
                row.Name.SetBounds(Zoomed(50), Zoomed(4), textWidth, row.Name.GetPreferredSize(new Size(textWidth, 0)).Height);
                row.File.SetBounds(Zoomed(50), row.Name.Bottom, textWidth, row.File.GetPreferredSize(new Size(textWidth, 0)).Height);
                row.Surface.Height = row.File.Bottom + Zoomed(7);
                row.Check.SetBounds(Zoomed(14), Zoomed(10), Zoomed(24), Zoomed(24));
                row.Status.Location = new Point(leftWidth - statusWidth, Zoomed(12));
            }
            _missionFilesPage.BackColor = _missionFilesPanel.BackColor = MainBackground;
            _missionFilesAction!.MinimumSize = new Size(width, 0); _missionFilesAction.MaximumSize = new Size(width, 0);
            var summaryWidth = Math.Max(50, width - _missionFilesSummaryArea!.Margin.Horizontal);
            _missionFilesSummary!.MaximumSize = _missionFilesOutput!.MaximumSize = new Size(summaryWidth, 0);
            var summaryHeight = Math.Max(Zoomed(34), _missionFilesSummary.GetPreferredSize(new Size(summaryWidth, 0)).Height);
            _missionFilesSummaryArea!.AutoSize = false;
            _missionFilesSummaryArea.MinimumSize = _missionFilesSummaryArea.MaximumSize = new Size(summaryWidth, Math.Max(Zoomed(105), summaryHeight + Zoomed(71)));
            _missionFilesSummary.SetBounds(0, 0, summaryWidth, summaryHeight);
            _missionFilesOutput.SetBounds(0, summaryHeight, summaryWidth, Zoomed(65));
            _missionFilesCard.BackColor = EditorBackground;
            foreach (Control child in _missionFilesCard.Controls) child.BackColor = EditorBackground;
            _missionFilesColumns.ResumeLayout(true);
            _missionFilesAppearance = stamp;
            RefreshMissionFilesSelection();
        }
        finally
        {
            foreach (var control in sourceLayouts.Reverse()) if (control is { IsDisposed: false }) control.ResumeLayout(true);
            _missionFilesPage.ResumeLayout(true); _missionFilesArranging = false;
        }
    }
    // Task 3 attaches this same retained component to the live feed; no success is inferred here.
    private TableLayoutPanel? _missionFilesUpdatesView, _missionFilesUpdateInstances;
    private Label? _missionFilesManagerText, _missionFilesReleaseTitle, _missionFilesBadge;
    private ManagerVerifiedGlyph? _missionFilesManagerGlyph;
    private FlowLayoutPanel? _missionFilesManagerActions, _missionFilesReleaseActions;
    private Label? _missionFilesReleaseDetail;
    private TableLayoutPanel? _missionFilesUpdatesDetails;
    private TableLayoutPanel? _missionFilesDownloadsSection;
    private Label? _missionFilesUpdatesScanStatus;
    private TableLayoutPanel? _missionFilesPreservationCallout;
    private TableLayoutPanel? _missionFilesUpdatesSourcesBody;
    private Button? _missionFilesUpdatesSourcesToggle;
    private bool _missionFilesUpdatesSourcesExpanded;
    private Button? _missionFilesUpdatesCheckMissions, _missionFilesUpdatesAddFolder, _missionFilesUpdatesOpen;
    private Button? _missionFilesUpdatesAddMiz;
    private RadioButton? _missionFilesUpdatesAllSources, _missionFilesUpdatesCustomSources;
    private Button? _missionFilesUpdatesAutoScan;
    private Label? _missionFilesUpdatesScopeHint, _missionFilesUpdatesAutoHint;
    private event Action? MissionFilesOpenRequested;
    private readonly Dictionary<string, (TableLayoutPanel Row, Label Name, Label Provenance, RowStyle Style)> _missionFilesUpdateInstanceRows = new(StringComparer.Ordinal);
    private string[] _missionFilesUpdateInstanceOrder = [];
    private (int Width, int Zoom, bool Dark)? _missionFilesUpdatesAppearance;
    private (int Width, int Zoom)? _missionFilesUpdatesRowMeasurements;
    private Control[]? _missionFilesUpdatesLayouts;
    private Control[] MissionFilesUpdatesLayouts => _missionFilesUpdatesLayouts ??=
        EnumerateChildControls<Control>(_missionFilesUpdatesView!)
            .Prepend(_missionFilesUpdatesView!).Prepend(_updatesPanel!).ToArray();
    private void UpdateMissionFilesUpdatesLayout(Action change, params Control[] repaint)
    {
        var host = _updatesPanel!;
        var view = _missionFilesUpdatesView!;
        var layouts = MissionFilesUpdatesLayouts;
        var bounds = repaint.Length == 0 ? [] : layouts.Select(control => control.Bounds).ToArray();
        var deferPainting = host.IsHandleCreated && host.Visible;
        var deferPagePainting = deferPainting && repaint.Length > 0 && view.IsHandleCreated;
        if (deferPagePainting) SendZoomRedrawMessage(view.Handle, 0x000B, IntPtr.Zero, IntPtr.Zero);
        if (deferPainting) SendZoomRedrawMessage(host.Handle, 0x000B, IntPtr.Zero, IntPtr.Zero);
        try
        {
        EditorSection.RunLayoutPass(() =>
        {
            foreach (var control in layouts) if (control is ScrollableControl) control.SuspendLayout();
            try { change(); }
            finally
            {
                // A child settles while every ancestor is still suspended, ending at the host.
                foreach (var control in layouts.Reverse())
                    if (control is ScrollableControl && control != view && control != host && !control.IsDisposed) control.ResumeLayout(true);
                if (bounds.Length > 0 && view.Visible && view.Width == bounds[1].Width)
                {
                    // Local scan choices change only this retained section; the other page rows are unchanged.
                    var details = _missionFilesUpdatesDetails!;
                    var delta = details.GetPreferredSize(new Size(details.Width, 0)).Height - details.Height;
                    view.Height += delta;
                    view.ResumeLayout(delta != 0);
                }
                else if (!view.IsDisposed) view.ResumeLayout(true);
                if (!host.IsDisposed) host.ResumeLayout(true);
                SizeMissionFilesUpdatesView();
            }
        });
        }
        finally
        {
            if (deferPainting && host.IsHandleCreated && !host.IsDisposed)
            {
                if (deferPagePainting && view.IsHandleCreated && !view.IsDisposed)
                    SendZoomRedrawMessage(view.Handle, 0x000B, new IntPtr(1), IntPtr.Zero);
                SendZoomRedrawMessage(host.Handle, 0x000B, new IntPtr(1), IntPtr.Zero);
                if (repaint.Length == 0 || view.Location != bounds[1].Location || view.Width != bounds[1].Width)
                    host.Invalidate(true);
                else
                {
                    if (view.Height < bounds[1].Height)
                        host.Invalidate(new Rectangle(view.Left, view.Bottom, view.Width, bounds[1].Height - view.Height));
                    if (view.Height > bounds[1].Height)
                        view.Invalidate(new Rectangle(0, bounds[1].Height, view.Width, view.Height - bounds[1].Height));
                }
                for (var index = 2; index < bounds.Length; index++)
                    if (!layouts[index].IsDisposed && layouts[index].Bounds != bounds[index])
                    {
                        var previous = bounds[index];
                        var current = layouts[index].Bounds;
                        if (previous.X == current.X && previous.Width == current.Width)
                        {
                            if (current.Top > previous.Top)
                                layouts[index].Parent!.Invalidate(new Rectangle(previous.X, previous.Y, previous.Width, Math.Min(previous.Height, current.Top - previous.Top)));
                            if (current.Bottom < previous.Bottom)
                                layouts[index].Parent!.Invalidate(new Rectangle(previous.X, Math.Max(previous.Top, current.Bottom), previous.Width, previous.Bottom - Math.Max(previous.Top, current.Bottom)));
                        }
                        else layouts[index].Parent!.Invalidate(previous);
                        layouts[index].Invalidate(layouts[index].Location != bounds[index].Location || layouts[index].Width != bounds[index].Width);
                    }
                foreach (var control in repaint) { control.Invalidate(true); control.Update(); }
                host.Update();
            }
        }
    }
    private void SizeMissionFilesUpdatesView()
    {
        var view = _missionFilesUpdatesView!;
        if (!view.Visible) return;
        var rows = _missionFilesUpdateInstances!;
        var measurements = (rows.ClientSize.Width, _uiZoomPercent);
        if (_missionFilesUpdatesRowMeasurements != measurements)
        {
            rows.SuspendLayout();
            try
            {
                foreach (var item in _missionFilesUpdateInstanceRows.Values)
                    item.Row.Height = item.Row.GetPreferredSize(new Size(Math.Max(1, measurements.Width - item.Row.Margin.Horizontal), 0)).Height;
                _missionFilesUpdatesRowMeasurements = measurements;
            }
            finally { rows.ResumeLayout(true); }
        }
        view.Height = view.Controls.Cast<Control>().Where(control => control.Visible)
            .Select(control => control.Bottom + control.Margin.Bottom).DefaultIfEmpty(view.Padding.Top).Max() + view.Padding.Bottom;
    }
    private void BuildMissionFilesUpdatesView(Action openFiles, Action download, Action notes, Action back, Action checkAgain)
    {
        if (_missionFilesUpdatesView is not null) return;
        EnsureMissionFilesFontLifetime();
        _missionFilesUpdatesView = MissionFilesColumn("MissionFilesUpdatesView", cacheMeasurements: true);
        _missionFilesUpdatesView.Padding = new Padding(Zoomed(24));
        var header = new TableLayoutPanel { AutoSize = true, Dock = DockStyle.Top, ColumnCount = 2 };
        header.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100)); header.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        header.Controls.Add(MissionFilesLabel("Updates", 1.6f, FontStyle.Bold), 0, 0);
        header.Controls.Add(MissionFilesButton("FilesUpdatesBack", "Back to configuration", back), 1, 0);
        AddMissionFilesControl(_missionFilesUpdatesView, header);
        AddMissionFilesControl(_missionFilesUpdatesView, MissionFilesLabel("Foothold Config Manager", 1.2f, FontStyle.Bold));
        var manager = new FlowLayoutPanel { Dock = DockStyle.Top, AutoSize = true, Margin = new Padding(0, Zoomed(3), 0, Zoomed(20)) };
        _missionFilesManagerGlyph = new ManagerVerifiedGlyph { Name = "ManagerVerifiedCurrent", Size = new Size(Zoomed(22), Zoomed(22)), Visible = false };
        _missionFilesManagerText = MissionFilesLabel("Update information has not been checked yet.");
        manager.Controls.AddRange([_missionFilesManagerGlyph, _missionFilesManagerText]);
        AddMissionFilesControl(_missionFilesUpdatesView, manager);
        _missionFilesManagerActions = new FlowLayoutPanel { AutoSize = true, Dock = DockStyle.Top };
        AddMissionFilesControl(_missionFilesUpdatesView, _missionFilesManagerActions);
        AddMissionFilesControl(_missionFilesUpdatesView, new Panel { Name = "FilesUpdatesManagerDivider", Height = 1, Dock = DockStyle.Top, Margin = new Padding(0, 0, 0, Zoomed(16)) });
        var release = new FlowLayoutPanel { AutoSize = true, Dock = DockStyle.Top };
        _missionFilesReleaseTitle = MissionFilesLabel("Foothold mission releases", 1.4f, FontStyle.Bold);
        _missionFilesBadge = MissionFilesLabel("FILES-ONLY UPDATE", .9f, FontStyle.Bold);
        _missionFilesBadge.Padding = new Padding(Zoomed(8), Zoomed(4), Zoomed(8), Zoomed(4));
        _missionFilesBadge.Dock = DockStyle.None; _missionFilesBadge.Anchor = AnchorStyles.Left;
        release.Controls.Add(_missionFilesReleaseTitle);
        AddMissionFilesControl(_missionFilesUpdatesView, release);
        _missionFilesReleaseDetail = MissionFilesLabel("");
        AddMissionFilesControl(_missionFilesUpdatesView, _missionFilesReleaseDetail);
        _missionFilesReleaseActions = new FlowLayoutPanel { AutoSize = true, Dock = DockStyle.Top };
        AddMissionFilesControl(_missionFilesUpdatesView, _missionFilesReleaseActions);
        _missionFilesUpdatesDetails = MissionFilesColumn("MissionFilesUpdatesDetails", cacheMeasurements: true);
        _missionFilesUpdatesDetails.Visible = false;
        AddMissionFilesControl(_missionFilesUpdatesView, _missionFilesUpdatesDetails);
        _missionFilesPreservationCallout = MissionFilesColumn("MissionFilesUpdateActionCard", cacheMeasurements: true);
        _missionFilesPreservationCallout.Margin = new Padding(0, Zoomed(14), 0, Zoomed(10));
        _missionFilesPreservationCallout.Padding = new Padding(Zoomed(18));
        _missionFilesPreservationCallout.Paint += (_, e) => {
            using var pen = new Pen(BorderColor);
            using var shape = ConfigSearchSurface.RoundedRectangle(new RectangleF(.5f, .5f,
                Math.Max(1, _missionFilesPreservationCallout.Width - 1), Math.Max(1, _missionFilesPreservationCallout.Height - 1)), 5);
            e.Graphics.DrawPath(pen, shape);
        };
        var methodHeading = new FlowLayoutPanel { AutoSize = true, Dock = DockStyle.Top };
        var methodTitle = MissionFilesLabel("Keep your mission setup", 1.2f, FontStyle.Bold);
        methodTitle.Dock = DockStyle.None; methodTitle.Anchor = AnchorStyles.Left;
        methodHeading.Controls.AddRange([methodTitle, _missionFilesBadge]);
        AddMissionFilesControl(_missionFilesPreservationCallout, methodHeading);
        AddMissionFilesControl(_missionFilesPreservationCallout,
            MissionFilesLabel("Update the script files while keeping everything else the same."));
        var actions = new FlowLayoutPanel { AutoSize = true, Dock = DockStyle.Top, Margin = new Padding(0, Zoomed(6), 0, 0) };
        _missionFilesUpdatesOpen = MissionFilesButton("FilesUpdatesOpen", "Update existing missions", openFiles);
        ((PreviewButton)_missionFilesUpdatesOpen).AccentOutline = true;
        _missionFilesUpdatesScanStatus = MissionFilesLabel("");
        _missionFilesUpdatesScanStatus.Dock = DockStyle.None; _missionFilesUpdatesScanStatus.Anchor = AnchorStyles.Left;
        _missionFilesUpdatesScanStatus.Margin = new Padding(Zoomed(12), Zoomed(8), 0, Zoomed(5));
        actions.Controls.AddRange([_missionFilesUpdatesOpen, _missionFilesUpdatesScanStatus]);
        AddMissionFilesControl(_missionFilesPreservationCallout, actions);
        _missionFilesUpdatesSourcesBody = MissionFilesColumn("MissionFilesUpdatesSourcesBody", cacheMeasurements: true);
        _missionFilesUpdatesSourcesBody.Visible = _missionFilesUpdatesSourcesExpanded;
        _missionFilesUpdatesSourcesToggle = MissionFilesButton("FilesUpdatesSourcesToggle", "Scan options ▾", () => {
            UpdateMissionFilesUpdatesLayout(() => {
                _missionFilesUpdatesSourcesExpanded = !_missionFilesUpdatesSourcesExpanded;
                _missionFilesUpdatesSourcesBody.Visible = _missionFilesUpdatesSourcesExpanded;
                _missionFilesUpdatesSourcesToggle!.Text = _missionFilesUpdatesSourcesExpanded ? "Scan options ▴" : "Scan options ▾";
            }, _missionFilesUpdatesSourcesToggle!, _missionFilesUpdatesSourcesBody!);
        });
        _missionFilesUpdatesSourcesToggle.AccessibleName = "Scan options";
        _missionFilesUpdatesSourcesToggle.AccessibleDescription = "Show or hide the retained mission scan details.";
        AddMissionFilesControl(_missionFilesUpdatesDetails, MissionFilesLabel("Mission sources", 1f, FontStyle.Bold));
        var scanToolbar = new TableLayoutPanel { Name = "FilesUpdatesScanToolbar", AutoSize = true, Dock = DockStyle.Top, ColumnCount = 3, Margin = Padding.Empty };
        scanToolbar.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        scanToolbar.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize)); scanToolbar.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        _missionFilesUpdatesCheckMissions = MissionFilesButton("FilesUpdatesCheckMissions", "Scan now",
            () => _missionDownloadJob = OpenMissionFilesAsync(refreshInventory: true, showUpdater: false));
        ((PreviewButton)_missionFilesUpdatesCheckMissions).AccentOutline = true;
        _missionFilesUpdatesAutoScan = MissionFilesButton("FilesUpdatesAutoScan", "Auto scan: On",
            () => ApplyMissionScanPreferences(!_settings.AutomaticMissionScan));
        _missionFilesUpdatesAutoScan.AccessibleName = "Scan missions automatically when opening Updates";
        scanToolbar.Controls.Add(_missionFilesUpdatesCheckMissions, 0, 0);
        scanToolbar.Controls.Add(_missionFilesUpdatesAutoScan, 1, 0); scanToolbar.Controls.Add(_missionFilesUpdatesSourcesToggle, 2, 0);
        AddMissionFilesControl(_missionFilesUpdatesDetails, scanToolbar);
        _missionFilesUpdatesAutoHint = MissionFilesLabel("", .92f);
        AddMissionFilesControl(_missionFilesUpdatesDetails, _missionFilesUpdatesAutoHint);
        AddMissionFilesControl(_missionFilesUpdatesSourcesBody, MissionFilesLabel("Where to scan", 1f, FontStyle.Bold));
        var scope = new FlowLayoutPanel { AutoSize = true, Dock = DockStyle.Top };
        _missionFilesUpdatesAllSources = new WeatherRadioButton { Name = "FilesUpdatesAllSources", Text = "Instance Missions folders and custom sources", AutoSize = true,
            Checked = !_settings.MissionScanCustomSourcesOnly };
        _missionFilesUpdatesCustomSources = new WeatherRadioButton { Name = "FilesUpdatesCustomSources", Text = "Custom sources only", AutoSize = true,
            Checked = _settings.MissionScanCustomSourcesOnly };
        scope.Controls.AddRange([_missionFilesUpdatesAllSources, _missionFilesUpdatesCustomSources]);
        AddMissionFilesControl(_missionFilesUpdatesSourcesBody, scope);
        _missionFilesUpdatesScopeHint = MissionFilesLabel("", .92f);
        AddMissionFilesControl(_missionFilesUpdatesSourcesBody, _missionFilesUpdatesScopeHint);
        AddMissionFilesControl(_missionFilesUpdatesSourcesBody, MissionFilesLabel(
            "Keep missions elsewhere? Add a mission folder or choose MIZ files to include them.", .92f));
        var sourceActions = new FlowLayoutPanel { AutoSize = true, Dock = DockStyle.Top };
        _missionFilesUpdatesAddFolder = MissionFilesButton("FilesUpdatesAddFolder", "Add mission folder…",
            () => _missionDownloadJob = AddMissionSourceFolderAsync(showUpdater: false));
        _missionFilesUpdatesAddMiz = MissionFilesButton("FilesUpdatesAddMiz", "Add MIZ files…",
            () => _missionDownloadJob = AddMissionFilesAsync(showUpdater: false));
        sourceActions.Controls.AddRange([_missionFilesUpdatesAddFolder, _missionFilesUpdatesAddMiz]);
        AddMissionFilesControl(_missionFilesUpdatesSourcesBody, sourceActions);
        _missionFilesUpdateInstances = MissionFilesColumn("MissionFilesUpdateInstances", cacheMeasurements: true);
        AddMissionFilesControl(_missionFilesUpdatesSourcesBody, _missionFilesUpdateInstances);
        AddMissionFilesControl(_missionFilesUpdatesSourcesBody, MissionFilesLabel(
            "Folder scans look for Foothold in the filename. Select renamed MIZ files directly.", .92f));
        AddMissionFilesControl(_missionFilesUpdatesDetails, _missionFilesUpdatesSourcesBody);
        _missionFilesUpdatesAllSources.CheckedChanged += (_, _) => { if (_missionFilesUpdatesAllSources.Checked) ApplyMissionScanPreferences(); };
        _missionFilesUpdatesCustomSources.CheckedChanged += (_, _) => { if (_missionFilesUpdatesCustomSources.Checked) ApplyMissionScanPreferences(); };
        AddMissionFilesControl(_missionFilesUpdatesDetails, _missionFilesPreservationCallout);
        _missionFilesDownloadsSection = MissionFilesColumn("MissionFilesDownloadsSection", cacheMeasurements: true);
        AddMissionFilesControl(_missionFilesDownloadsSection, new Panel { Name = "FilesUpdatesDownloadsDivider",
            Height = 1, Dock = DockStyle.Top, Margin = new Padding(0, Zoomed(12), 0, Zoomed(10)) });
        AddMissionFilesControl(_missionFilesDownloadsSection, MissionFilesLabel("Update by downloading a full mission", 1.2f, FontStyle.Bold));
        AddMissionFilesControl(_missionFilesDownloadsSection, MissionFilesLabel("Download the latest mission for your map."));
        AddMissionFilesControl(_missionFilesDownloadsSection, BuildMissionUpdatesCallout("Bring your warehouse stock with you",
            "Copy your warehouse from a compatible older mission, including modded items."));
        var downloadActions = new FlowLayoutPanel { AutoSize = true, Dock = DockStyle.Top };
        downloadActions.Controls.AddRange([MissionFilesButton("FilesUpdatesDownload", "Download missions", download),
            MissionFilesButton("FilesUpdatesNotes", "View release notes", notes)]);
        AddMissionFilesControl(_missionFilesDownloadsSection, downloadActions);
        AddMissionFilesControl(_missionFilesUpdatesView, _missionFilesDownloadsSection);
        AddMissionFilesControl(_missionFilesUpdatesView, new Panel { Name = "FilesUpdatesFooterDivider", Height = 1, Dock = DockStyle.Top, Margin = new Padding(0, 0, 0, Zoomed(12)) });
        var footer = new FlowLayoutPanel { AutoSize = true, Dock = DockStyle.Top };
        // MainForm.Updates binds this retained preference to the existing checker/store.
        footer.Controls.Add(new WeatherCheckBox { Name = "FilesUpdatesAutomatic", Text = "Check for Manager updates on every startup", AutoSize = true });
        footer.Controls.Add(MissionFilesButton("FilesUpdatesCheck", "Check again", checkAgain));
        AddMissionFilesControl(_missionFilesUpdatesView, footer);
    }
    private TableLayoutPanel BuildMissionUpdatesCallout(string title, string detail)
    {
        var callout = MissionFilesColumn("FilesUpdatesCallout", cacheMeasurements: true);
        callout.Margin = new Padding(0, Zoomed(6), 0, Zoomed(6));
        callout.Padding = new Padding(Zoomed(12), Zoomed(5), Zoomed(12), Zoomed(5));
        callout.Paint += (_, e) =>
        {
            using var accent = new SolidBrush(BrandColor);
            e.Graphics.FillRectangle(accent, 0, 0, Zoomed(3), callout.Height);
        };
        AddMissionFilesControl(callout, MissionFilesLabel(title, 1.4f, FontStyle.Bold));
        AddMissionFilesControl(callout, MissionFilesLabel(detail, 1.1f));
        return callout;
    }
    private void PresentMissionFilesUpdates(MissionFilesUpdatesPresentation presentation)
    {
        _missionFilesManagerGlyph!.Visible = presentation.ManagerVerifiedCurrent;
        _missionFilesManagerText!.Text = presentation.ManagerVerifiedCurrent ? "Your Manager is up to date" : presentation.ManagerStatus;
        _missionFilesReleaseTitle!.Text = presentation.ReleaseTitle;
        _missionFilesBadge!.Visible = presentation.FilesOnlyAvailable;
        _missionFilesUpdatesScanStatus!.ForeColor = presentation.FilesOnlyAvailable && !SystemInformation.HighContrast
            ? _darkMode ? Color.FromArgb(148, 213, 180) : Color.FromArgb(25, 113, 77) : PrimaryTextColor;
        var incoming = presentation.Instances.ToDictionary(instance => instance.Id, StringComparer.Ordinal);
        if (incoming.Count == 0) _missionFilesUpdateInstances!.Hide();
        var retained = _settings.ServerProfiles.Select(profile => profile.Id).Append(GetMissionDownloadFallback().Id)
            .Concat(_missionSourceFolders.Select(folder => "source-folder:" + folder.ToUpperInvariant()))
            .Concat(_missionFilesExternalPaths.Select(path => "source-file:" + path.ToUpperInvariant())).ToHashSet(StringComparer.Ordinal);
        foreach (var id in _missionFilesUpdateInstanceRows.Keys.Where(id => !incoming.ContainsKey(id)).ToArray())
        {
            var removed = _missionFilesUpdateInstanceRows[id];
            if (retained.Contains(id)) { if (incoming.Count > 0) removed.Row.Visible = false; continue; }
            _missionFilesLabels.Remove(removed.Name); _missionFilesLabels.Remove(removed.Provenance);
            removed.Row.Dispose(); _missionFilesUpdateInstanceRows.Remove(id);
            _missionFilesUpdatesLayouts = null;
        }
        var created = false;
        foreach (var (id, name, provenance) in presentation.Instances)
        {
            if (!_missionFilesUpdateInstanceRows.TryGetValue(id, out var item))
            {
                var removable = id.StartsWith("source-folder:", StringComparison.Ordinal) || id.StartsWith("source-file:", StringComparison.Ordinal);
                var row = new TableLayoutPanel { Name = "MissionFilesUpdateInstance-" + id, AutoSize = false, Dock = DockStyle.Top, ColumnCount = removable ? 3 : 2 };
                row.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 65)); row.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 35));
                if (removable) row.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
                var nameLabel = MissionFilesLabel(name); var provenanceLabel = MissionFilesLabel(provenance);
                row.Controls.Add(nameLabel, 0, 0); row.Controls.Add(provenanceLabel, 1, 0);
                if (removable)
                    row.Controls.Add(MissionFilesButton("FilesUpdatesRemoveSource-" + id, "Remove", () => {
                        if (id.StartsWith("source-folder:", StringComparison.Ordinal))
                            _missionDownloadJob = RemoveMissionSourceFolderAsync(name, showUpdater: false);
                        else
                        {
                            _missionFilesExternalPaths = _missionFilesExternalPaths.Where(path => !PathsEqual(path, name)).ToArray();
                            RefreshUpdatesPresentation();
                        }
                    }), 2, 0);
                row.Paint += (_, e) => { using var pen = new Pen(BorderColor); e.Graphics.DrawLine(pen, 0, row.Height - 1, row.Width, row.Height - 1); };
                item = (row, nameLabel, provenanceLabel, new RowStyle(SizeType.AutoSize));
                _missionFilesUpdateInstanceRows.Add(id, item); created = true;
                _missionFilesUpdatesLayouts = null;
                _missionFilesUpdatesRowMeasurements = null;
            }
            if (item.Name.Text != name) { item.Name.Text = name; _missionFilesUpdatesRowMeasurements = null; }
            if (item.Provenance.Text != provenance) { item.Provenance.Text = provenance; _missionFilesUpdatesRowMeasurements = null; }
            item.Row.Visible = true;
        }
        _missionFilesUpdateInstances!.Visible = incoming.Count > 0;
        var incomingOrder = presentation.Instances.Select(instance => instance.Id).ToArray();
        var order = _missionFilesUpdateInstanceOrder.Where(incoming.ContainsKey).SequenceEqual(incomingOrder)
            ? _missionFilesUpdateInstanceOrder.Where(_missionFilesUpdateInstanceRows.ContainsKey).ToArray()
            : incomingOrder.Concat(_missionFilesUpdateInstanceRows.Keys.Where(id => !incoming.ContainsKey(id))).ToArray();
        if (!_missionFilesUpdateInstanceOrder.SequenceEqual(order))
        {
            _missionFilesUpdateInstances!.SuspendLayout(); _missionFilesUpdateInstances.RowStyles.Clear();
            for (var index = 0; index < order.Length; index++)
            {
                var item = _missionFilesUpdateInstanceRows[order[index]];
                if (item.Row.Parent != _missionFilesUpdateInstances) _missionFilesUpdateInstances.Controls.Add(item.Row, 0, index);
                else _missionFilesUpdateInstances.SetCellPosition(item.Row, new TableLayoutPanelCellPosition(0, index));
                _missionFilesUpdateInstances.RowStyles.Add(item.Style);
            }
            _missionFilesUpdateInstances.RowCount = order.Length;
            _missionFilesUpdateInstanceOrder = order; _missionFilesUpdateInstances.ResumeLayout(true);
        }
        var updatesAppearance = (_missionFilesUpdatesView!.Width, _uiZoomPercent, _darkMode);
        if (!created && _missionFilesUpdatesAppearance == updatesAppearance) return;
        _missionFilesUpdatesAppearance = updatesAppearance;
        _missionFilesUpdatesRowMeasurements = null;
        _missionFilesUpdatesView!.BackColor = MainBackground;
        foreach (var label in EnumerateChildControls<Label>(_missionFilesUpdatesView))
        {
            var appearance = _missionFilesLabels[label];
            label.Font = MissionPresentationFont(appearance.Scale * MissionPageLabelScale, appearance.Style);
            label.ForeColor = PrimaryTextColor;
            label.MaximumSize = new Size(Math.Max(100, _missionFilesUpdatesView.Width - Zoomed(60)), 0);
        }
        _missionFilesPreservationCallout!.BackColor = EditorBackground;
        foreach (var label in EnumerateChildControls<Label>(_missionFilesPreservationCallout)) label.BackColor = EditorBackground;
        foreach (var row in EnumerateChildControls<FlowLayoutPanel>(_missionFilesPreservationCallout)) row.BackColor = EditorBackground;
        _missionFilesUpdatesScanStatus.ForeColor = presentation.FilesOnlyAvailable && !SystemInformation.HighContrast
            ? _darkMode ? Color.FromArgb(148, 213, 180) : Color.FromArgb(25, 113, 77) : PrimaryTextColor;
        _missionFilesBadge.BackColor = _darkMode ? Color.FromArgb(63, 223, 202) : Color.FromArgb(8, 122, 115);
        _missionFilesBadge.ForeColor = _darkMode ? Color.FromArgb(7, 46, 42) : Color.White;
        foreach (var button in EnumerateChildControls<Button>(_missionFilesUpdatesView))
        {
            button.Font = MissionPresentationFont(1f, button.Name == "FilesUpdatesNotes" ? FontStyle.Underline : FontStyle.Regular);
            StyleButton(button);
            button.Size = new Size(TextRenderer.MeasureText(button.Text, button.Font).Width + Zoomed(26),
                Math.Max(Zoomed(34), button.Font.Height + Zoomed(10)));
            if (button.Name is "FilesUpdatesCheckMissions" or "FilesUpdatesAutoScan" or "FilesUpdatesSourcesToggle")
            {
                button.Padding = new Padding(Zoomed(14), Zoomed(7), Zoomed(14), Zoomed(7));
                var caption = button.Name == "FilesUpdatesAutoScan" ? "Auto scan: Off" : button.Text;
                button.Size = new Size(TextRenderer.MeasureText(caption, button.Font).Width + Math.Max(14, button.Font.Height) + button.Padding.Horizontal + button.Padding.Top,
                    Math.Max(Zoomed(40), button.Font.Height + Zoomed(16)));
                if (_darkMode)
                {
                    button.BackColor = Color.FromArgb(32, 46, 60); button.ForeColor = Color.FromArgb(216, 231, 247);
                    button.FlatAppearance.MouseOverBackColor = Color.FromArgb(43, 64, 83);
                }
                else
                {
                    button.BackColor = Color.FromArgb(232, 240, 246);
                    button.FlatAppearance.MouseOverBackColor = Color.FromArgb(217, 231, 242);
                    if (button.Name == "FilesUpdatesCheckMissions")
                    {
                        button.BackColor = Color.FromArgb(234, 244, 244);
                        button.FlatAppearance.MouseOverBackColor = Color.FromArgb(219, 236, 235);
                    }
                }
            }
            else if (button.Name == "FilesUpdatesBack")
            {
                SizeMissionBackButton(button);
            }
            else if (button.Name == "FilesUpdatesNotes")
            { button.FlatAppearance.BorderSize = 0; button.BackColor = MainBackground; button.ForeColor = BrandColor; }
        }
        foreach (var callout in EnumerateChildControls<TableLayoutPanel>(_missionFilesUpdatesView).Where(panel => panel.Name == "FilesUpdatesCallout"))
        {
            callout.BackColor = EditorBackground;
            foreach (Control label in callout.Controls)
            {
                label.BackColor = EditorBackground;
                ((Label)label).MaximumSize = new Size(Math.Max(100, _missionFilesUpdatesView.Width - Zoomed(84)), 0);
            }
        }
        foreach (var divider in EnumerateChildControls<Panel>(_missionFilesUpdatesView).Where(panel => panel.Name.EndsWith("Divider", StringComparison.Ordinal))) divider.BackColor = BorderColor;
        foreach (var check in EnumerateChildControls<WeatherCheckBox>(_missionFilesUpdatesView))
        { check.Font = MissionPresentationFont(1f, FontStyle.Regular); check.ForeColor = PrimaryTextColor; check.BackColor = MainBackground; }
        foreach (var radio in EnumerateChildControls<RadioButton>(_missionFilesUpdatesView))
        {
            radio.Font = MissionPresentationFont(1f, FontStyle.Regular); radio.ForeColor = PrimaryTextColor; radio.BackColor = MainBackground;
            radio.AutoSize = false;
            radio.Size = new Size(TextRenderer.MeasureText(radio.Text, radio.Font).Width + Math.Max(Zoomed(14), radio.Font.Height - 1) + Zoomed(10),
                Math.Max(Zoomed(24), radio.Font.Height + Zoomed(4)));
        }
    }
    private sealed class ManagerVerifiedGlyph : Control
    {
        internal ManagerVerifiedGlyph() { DoubleBuffered = true; SetStyle(ControlStyles.SupportsTransparentBackColor, true); BackColor = Color.Transparent; }
        protected override void OnPaint(PaintEventArgs e)
        {
            e.Graphics.SmoothingMode = SmoothingMode.AntiAlias;
            var box = Rectangle.Inflate(ClientRectangle, -1, -1);
            using var fill = new SolidBrush(SystemInformation.HighContrast ? SystemColors.Highlight : Color.FromArgb(83, 215, 79));
            e.Graphics.FillEllipse(fill, box);
            using var tick = new Pen(SystemInformation.HighContrast ? SystemColors.HighlightText : Color.FromArgb(12, 48, 20), Math.Max(1.6f, Width / 12f))
                { StartCap = LineCap.Round, EndCap = LineCap.Round, LineJoin = LineJoin.Round };
            e.Graphics.DrawLines(tick, [new PointF(Width * .27f, Height * .51f), new PointF(Width * .44f, Height * .67f), new PointF(Width * .75f, Height * .33f)]);
        }
    }
}
