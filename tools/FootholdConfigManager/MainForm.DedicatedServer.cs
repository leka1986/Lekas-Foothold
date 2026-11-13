namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private Task? _dedicatedCapabilityTask;
    private DcsCapabilitySnapshot? _dedicatedCapabilitySnapshot;
    private DcsDedicatedServerService? _dedicatedServerService;
    private (DcsServerTarget Target, string CanonicalDirectory)[] _dedicatedVerifiedTargets = [];
    private (DcsCapabilitySnapshot Snapshot, DcsRegistrationTargetState[] States, string? CustomFolder)? _dedicatedTargetSource;
    private string? _dedicatedCanonicalCustomFolder;
    private int _dedicatedTargetCaptureRevision;
    private WeatherCheckBox? _missionDownloadRegisterServer, _missionFilesRegisterServer;
    private Label? _missionDownloadServerHint, _missionFilesServerHint;

    private WeatherCheckBox CreateServerRegistrationChoice(string name)
    {
        var choice = new WeatherCheckBox { Name = name, Text = "Add created missions to the server list",
            AutoSize = true, Dock = DockStyle.Top, Checked = false, Visible = false };
        _toolTip.SetToolTip(choice, "After saving, add each new MIZ to the verified dedicated instance\u2019s server list. Running missions stay running. For a verified stopped instance, update its saved list. Load the mission later through DCS or ServerBot.");
        return choice; // Checking is intent only: no discovery, HTTP, settings write or view rebuild.
    }

    internal Task BeginDedicatedCapabilityCaptureAsync() => _dedicatedCapabilityTask ??= CaptureDedicatedCapabilityAsync();

    private async Task CaptureDedicatedCapabilityAsync()
    {
        var token = _updatesLifetime.Token;
        try
        {
            var snapshot = await Task.Run(() => new DcsDedicatedServerPlatform().CaptureCapabilities(token), token);
            if (token.IsCancellationRequested || _updatesDisposed || IsDisposed || Disposing) return;
            _dedicatedCapabilitySnapshot = snapshot;
            await CaptureDedicatedRegistrationTargetsAsync(snapshot);
        }
        catch (OperationCanceledException) when (token.IsCancellationRequested) { }
        catch (Exception error) when (DcsDedicatedServerPlatform.Unavailable(error))
        { /* An optional discovery failure must not fail startup or create a guessed server binding. */ }
    }

    internal async Task RefreshDedicatedRegistrationTargetsAsync()
    {
        await BeginDedicatedCapabilityCaptureAsync();
        if (_updatesDisposed || IsDisposed || Disposing || _dedicatedCapabilitySnapshot is not { } snapshot) return;
        await CaptureDedicatedRegistrationTargetsAsync(snapshot);
    }

    private async Task CaptureDedicatedRegistrationTargetsAsync(DcsCapabilitySnapshot snapshot)
    {
        if (snapshot.DedicatedInstallations.Count == 0 && snapshot.Processes.Count == 0)
        {
            ++_dedicatedTargetCaptureRevision;
            _dedicatedVerifiedTargets = [];
            _dedicatedTargetSource = null;
            _dedicatedCanonicalCustomFolder = null;
            RefreshServerRegistrationChoices();
            return;
        }
        var targets = CaptureServerRegistrationTargets(CaptureMissionFilesRoots());
        var customFolder = _missionCustomOutputFolder;
        var previousSource = _dedicatedTargetSource;
        var previousTargets = _dedicatedVerifiedTargets;
        var previousCustom = _dedicatedCanonicalCustomFolder;
        var revision = ++_dedicatedTargetCaptureRevision;
        var token = _updatesLifetime.Token;
        try
        {
            var result = await Task.Run(() =>
            {
                var platform = new DcsDedicatedServerPlatform();
                var states = targets.Select(platform.CaptureRegistrationTargetState).ToArray();
                string? canonicalCustom = null;
                if (customFolder is not null)
                    try { canonicalCustom = platform.CanonicalPath(customFolder); }
                    catch (Exception error) when (DcsDedicatedServerPlatform.Unavailable(error)) { }
                if (previousSource is { } previous
                    && (ReferenceEquals(previous.Snapshot, snapshot) || previous.Snapshot.UnavailableReason == snapshot.UnavailableReason
                        && previous.Snapshot.DedicatedInstallations.SequenceEqual(snapshot.DedicatedInstallations, StringComparer.OrdinalIgnoreCase)
                        && previous.Snapshot.Processes.SequenceEqual(snapshot.Processes))
                    && previous.States.SequenceEqual(states) && previous.CustomFolder == customFolder && previousCustom == canonicalCustom)
                    return (Targets: previousTargets, CustomFolder: canonicalCustom, States: states);
                var verified = new List<(DcsServerTarget Target, string CanonicalDirectory)>();
                foreach (var target in targets)
                {
                    token.ThrowIfCancellationRequested();
                    if (platform.CaptureRegistrationTarget(target, snapshot, token) is { } directory)
                        verified.Add((target, directory));
                }
                return (Targets: verified.ToArray(), CustomFolder: canonicalCustom, States: states);
            }, token);
            if (revision != _dedicatedTargetCaptureRevision || token.IsCancellationRequested || _updatesDisposed || IsDisposed || Disposing) return;
            _dedicatedVerifiedTargets = result.Targets;
            _dedicatedCanonicalCustomFolder = result.CustomFolder;
            _dedicatedTargetSource = (snapshot, result.States, customFolder);
            RefreshServerRegistrationChoices();
        }
        catch (OperationCanceledException) when (token.IsCancellationRequested) { }
    }

    private bool CanOfferDownloadServerRegistration => CaptureDownloadServerRegistrationTargets().Length > 0;
    private bool CanOfferFilesServerRegistration => CaptureFilesServerRegistrationTargets().Length > 0;
    private bool CanOfferServerRegistration => CanOfferDownloadServerRegistration || CanOfferFilesServerRegistration;

    // Selection/layout consumes only retained target proof. No discovery or transport belongs here.
    private DcsServerTarget[] CaptureDownloadServerRegistrationTargets()
    {
        if (_missionZipOnly?.Checked == true || (_missionDestination?.SelectedItem as InstanceItem)?.Profile is not { } destination
            || RuntimeSettings.ResolveMissionsDirectory(destination) is not { } directory
            || RuntimeSettings.ResolveInstanceMissionsDirectory(destination) is not { } instanceDirectory) return [];
        return _dedicatedVerifiedTargets.Where(proof => proof.Target.MissionsDirectory.Equals(instanceDirectory, StringComparison.OrdinalIgnoreCase)
            && CanOfferDedicatedOutput(proof, directory)).Select(proof => proof.Target).ToArray();
    }

    private DcsServerTarget[] CaptureFilesServerRegistrationTargets()
    {
        if (_missionFilesPreparation is not { } preparation) return [];
        var targets = new Dictionary<string, DcsServerTarget>(StringComparer.OrdinalIgnoreCase);
        foreach (var path in _missionFilesState.Selected)
        {
            if (!_missionFilesState.Candidates.TryGetValue(path, out var candidate)
                || candidate is not { State: FileUpdateInspectionState.Compatible, ProposedOutputName: not null }
                || !preparation.Compatible.TryGetValue(path, out var source)) continue;
            foreach (var proof in _dedicatedVerifiedTargets)
                if (proof.Target.Id == candidate.GroupId && DcsDedicatedServerService.ContainsPath(proof.Target.MissionsDirectory, path)
                    && CanOfferDedicatedOutput(proof, source.DefaultOutputDirectory ?? Path.GetDirectoryName(path)!))
                    targets.TryAdd(proof.Target.MissionsDirectory, proof.Target);
        }
        return targets.Values.ToArray();
    }

    private bool CanOfferDedicatedOutput((DcsServerTarget Target, string CanonicalDirectory) proof, string directory)
    {
        if (_missionCustomFolderEnabled)
        {
            if (_missionCustomOutputError is not null || _dedicatedTargetSource?.CustomFolder != _missionCustomOutputFolder
                || _dedicatedCanonicalCustomFolder is not { } custom) return false;
            return custom.Equals(proof.CanonicalDirectory, StringComparison.OrdinalIgnoreCase)
                || DcsDedicatedServerService.ContainsPath(proof.CanonicalDirectory, custom);
        }
        directory = Path.GetFullPath(directory);
        return directory.Equals(proof.Target.MissionsDirectory, StringComparison.OrdinalIgnoreCase)
            || DcsDedicatedServerService.ContainsPath(proof.Target.MissionsDirectory, directory);
    }

    private void RefreshServerRegistrationChoices()
    {
        var downloadAvailable = CanOfferDownloadServerRegistration;
        var filesAvailable = CanOfferFilesServerRegistration;
        var downloadChanged = _missionDownloadRegisterServer is { } download && download.Visible != downloadAvailable;
        var filesChanged = _missionFilesRegisterServer is { } files && files.Visible != filesAvailable;
        const string hint = "Verified dedicated target. The server is checked again after saving.";
        var busy = _missionDownloadBusy || _configLoadingOperation || _updatesBusy || _updatesInstalling || _updatesDisposed;
        if (_missionDownloadRegisterServer is not null)
        {
            _missionDownloadRegisterServer.Visible = downloadAvailable;
            _missionDownloadRegisterServer.Enabled = !busy;
        }
        if (_missionDownloadServerHint is not null)
        {
            _missionDownloadServerHint.Text = hint;
            _missionDownloadServerHint.Visible = downloadAvailable;
        }
        if (_missionFilesRegisterServer is not null)
        {
            _missionFilesRegisterServer.Visible = filesAvailable;
            _missionFilesRegisterServer.Enabled = !busy;
        }
        if (_missionFilesServerHint is not null)
        {
            _missionFilesServerHint.Text = hint;
            _missionFilesServerHint.Visible = filesAvailable;
        }
        if (downloadChanged && _missionDownloadsPanel?.Visible == true) LayoutMissionDownloads();
        if (filesChanged && _missionFilesPanel?.Visible == true) LayoutMissionFiles(force: true);
    }

    private async Task<IReadOnlyList<DcsServerActionOutcome>> RegisterCreatedMissionsAsync(
        IReadOnlyList<string> outputs, IReadOnlyList<DcsServerTarget> targets,
        IProgress<LoadingProgress> progress, CancellationToken token)
    {
        // Bot originals are inputs for the bot, never playable mission-list entries.
        outputs = outputs.Where(path => path.EndsWith(".miz", StringComparison.OrdinalIgnoreCase)).ToArray();
        if (outputs.Count == 0 || token.IsCancellationRequested || _missionCloseRequested
            || _updatesDisposed || IsDisposed || Disposing) return [];
        progress.Report(new LoadingProgress("Adding saved missions to the server list…"));
        _dedicatedServerService ??= new(new DcsDedicatedServerPlatform(), (endpoint, installation) => new(endpoint, installation));
        // Reuse the admitted save job's radar/CTS. No second overlay or detached post-save job.
        var results = await Task.Run(() => _dedicatedServerService.RegisterSavedMissionsAsync(outputs, targets, token), token);
        if (!token.IsCancellationRequested && !_updatesDisposed && !IsDisposed && !Disposing)
        {
            _dedicatedCapabilitySnapshot = _dedicatedServerService.LastCapabilities ?? _dedicatedCapabilitySnapshot;
            if (_dedicatedCapabilitySnapshot is { } snapshot) await CaptureDedicatedRegistrationTargetsAsync(snapshot);
        }
        return results;
    }

    private static DcsServerTarget[] CaptureServerRegistrationTargets(IReadOnlyList<MissionFilesRoot> roots) =>
        roots.Where(root => !root.Id.StartsWith("source-folder:", StringComparison.Ordinal))
            .Select(root => new DcsServerTarget(root.Id, root.Name, root.MissionsDirectory)).ToArray();

    private static string FormatServerRegistrationOutcome(DcsServerActionOutcome outcome) =>
        "Server list · " + Path.GetFileName(outcome.OutputPath) + " · " + outcome.RegistrationState + ": " + outcome.Message;
}
