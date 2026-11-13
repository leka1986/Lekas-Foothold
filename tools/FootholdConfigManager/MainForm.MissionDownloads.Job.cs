using System.Diagnostics;

namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private MissionDownloadService? _missionDownloadService;
    private Task? _missionDownloadJob;
    private CancellationTokenSource? _missionDownloadCancellation;
    private bool _missionDownloadBusy, _missionCloseRequested;

    private async Task RunMissionDownloadJobAsync()
    {
        if (_missionDownloadBusy || _configLoadingOperation || _updatesInstalling || _updatesBusy || _missionDownloadRelease is null) return;
        var assets = _missionAssetChecks.Values.Where(check => check.Checked).Select(check => (MissionReleaseAsset)check.Tag!).ToArray();
        if (assets.Length == 0) return;
        var zipOnly = _missionZipOnly!.Checked;
        var registerServer = !zipOnly && CanOfferDownloadServerRegistration && _missionDownloadRegisterServer?.Checked == true;
        var destination = (_missionDestination!.SelectedItem as InstanceItem)?.Profile;
        if (!zipOnly && destination is null) return;
        var instances = SelectedMissionConfigTargets.Select(item => item.Profile).ToArray();
        if (!zipOnly && _missionUpdateConfig!.Checked && instances.Length == 0)
        { MessageBox.Show(this, "Select the instances whose Config files should be updated.", "Download missions"); return; }
        HideCurrentGridSelectionHighlights();
        if (!zipOnly && (_missionUpdateConfig!.Checked || _missionUseProfiles!.Checked || _missionApplyOptions!.Checked) && HasChanges())
        { MessageBox.Show(this, "Save or reload pending configuration changes before preparing modified missions.", "Download missions"); return; }
        var zipDirectory = zipOnly || _missionKeepZip!.Checked
            ? Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "Downloads") : "";
        if (!zipOnly && _missionUseProfiles!.Checked && _missionProfileChoices.Any(choice => choice.SelectedItem is not WeatherNamedProfile))
        { MessageBox.Show(this, "Choose each saved profile, or turn profile missions off.", "Download missions"); return; }
        var selectedProfiles = !zipOnly && _missionUseProfiles!.Checked
            ? _missionProfileChoices.Select(choice => choice.SelectedItem as WeatherNamedProfile
                ?? throw new InvalidDataException("Choose each saved profile."))
                .Select(profile => new ProfileMissionSnapshot(profile.Name, profile.Settings)).ToArray()
            : Array.Empty<ProfileMissionSnapshot>();
        if (!zipOnly && _missionUseProfiles!.Checked && selectedProfiles.Length == 0)
        { MessageBox.Show(this, "Add at least one saved profile, or turn profile missions off.", "Download missions"); return; }
        var release = _missionDownloadRelease;
        var applyOptions = !zipOnly && _missionApplyOptions!.Checked;
        var options = applyOptions ? _weatherWindow!.ReadMissionOptions() : null;
        var updateConfig = !zipOnly && _missionUpdateConfig!.Checked;
        var copyWarehouses = !zipOnly && _missionCopyWarehouses?.Checked == true;
        var warehouseSources = CaptureMissionWarehouseChoices();
        var collision = (MissionCollisionPolicy)_missionCollision!.SelectedIndex;
        var keepZip = _missionKeepZip!.Checked;
        var openFolder = _missionOpenFolder!.Checked;
        var missionDirectory = destination is null ? "" : RuntimeSettings.ResolveMissionsDirectory(destination) ?? "";
        var frozenDestination = destination is null ? new ServerProfileSettings { Name = "Downloads" }
            : new ServerProfileSettings { Id = destination.Id, Name = destination.Name,
                ConfigPath = destination.ConfigPath, MissionDirectory = missionDirectory };
        try { if (!zipOnly) missionDirectory = CaptureCustomMissionOutputDirectory() ?? missionDirectory; }
        catch (InvalidDataException error) { _missionDownloadSummary!.Text = error.Message; return; }
        var registrationTargets = registerServer ? CaptureDownloadServerRegistrationTargets() : [];
        _missionDownloadBusy = true;
        _missionDownloadsPanel!.Enabled = false;
        _missionDownloadResultDetails!.Hide();
        _missionDownloadResultsToggle!.Hide();
        _missionDownloadResultsToggle.Text = "Show installed files";
        UpdateMissionDownloadLocation(null);
        _missionDownloadCancellation = CancellationTokenSource.CreateLinkedTokenSource(_updatesLifetime.Token);
        var cancellation = _missionDownloadCancellation;
        RefreshUpdatesPresentation();
        ReviewedMissionDownload? reviewed = null;
        MissionDownloadResult? result = null;
        IReadOnlyList<DcsServerActionOutcome> serverOutcomes = [];
        try
        {
            _missionDownloadService ??= new MissionDownloadService();
            await RunConfigLoadingAsync(async (progress, token) =>
            {
                var prepared = await _missionDownloadService.PrepareAsync(release, assets, progress, token);
                token.ThrowIfCancellationRequested();
                IReadOnlyList<PreparedMissionTemplate> templates = prepared.Templates;
                token.ThrowIfCancellationRequested();
                IReadOnlyList<MissionConfigTarget> targets = [];
                IReadOnlyDictionary<string, MissionConfigSource> sources = new Dictionary<string, MissionConfigSource>();
                if (updateConfig)
                {
                    var choices = MissionConfigTargetChoices(templates, instances);
                    if (choices.Length == 0) throw new InvalidDataException("The selected missions contain no Config defaults to update.");
                    targets = choices.Where(choice => choice.Selected).Select(choice => choice.Target).ToArray();
                    if (targets.Count == 0)
                        throw new InvalidDataException("These mission defaults do not match the selected instances’ current Normal/WW2 Config. "
                            + "Select an instance using the matching Config, or turn Update Config after download off.");
                    var candidates = targets.Select(target => Path.GetFileName(target.Path)).Distinct(StringComparer.OrdinalIgnoreCase)
                        .ToDictionary(variant => variant, variant => MissionConfigSourceChoices(templates, variant), StringComparer.OrdinalIgnoreCase);
                    if (targets.Count > 0 && candidates.Values.All(items => items.Length == 1))
                        sources = candidates.ToDictionary(pair => pair.Key, pair => pair.Value[0], StringComparer.OrdinalIgnoreCase);
                    else
                    {
                        using var dialog = CreateMissionConfigDialog(templates, instances);
                        using var modal = _loadingScreen?.SuspendForModal(dialog);
                        if (dialog.ShowDialog(this) != DialogResult.OK) return;
                        targets = dialog.Controls.Find("MissionDownloadConfigPaths", true).OfType<CheckedListBox>().Single()
                            .CheckedItems.Cast<MissionConfigTarget>().ToArray();
                        sources = dialog.Controls.Find("MissionDownloadConfigSources", true).Single().Controls.OfType<ComboBox>()
                            .Where(choice => choice.Enabled).ToDictionary(choice => (string)choice.Tag!,
                                choice => (MissionConfigSource)choice.SelectedItem!, StringComparer.OrdinalIgnoreCase);
                    }
                }
                var selection = new MissionDownloadSelection { Release = release, Assets = assets, Prepared = prepared, Templates = templates,
                    Destination = frozenDestination, MissionDirectory = missionDirectory,
                    ConfigTargets = targets, ConfigSources = sources, Profiles = selectedProfiles,
                    ApplyCurrentMissionOptions = applyOptions, CurrentMissionOptions = options, UpdateConfig = updateConfig,
                    CopyWarehouses = copyWarehouses, WarehouseSources = warehouseSources,
                    CollisionPolicy = zipOnly ? collision : MissionCollisionPolicy.KeepBoth, CheckMissionCollisions = !zipOnly,
                    KeepZip = keepZip, ZipOnly = zipOnly, OpenFolder = openFolder, ZipDirectory = zipDirectory };
                while (true)
                {
                    var candidate = await PrepareReviewedMissionDownloadAsync(selection, progress, token);
                    token.ThrowIfCancellationRequested();
                    if (selection.CheckMissionCollisions)
                    {
                        if (!ResolveMissionDownloadCollisions(candidate, output =>
                        {
                            token.ThrowIfCancellationRequested();
                            using var dialog = CreateMissionDownloadNameDialog(candidate, output);
                            using var modal = _loadingScreen?.SuspendForModal(dialog);
                            if (dialog.ShowDialog(this) != DialogResult.OK) return null;
                            token.ThrowIfCancellationRequested();
                            return ((string OutputPath, MissionCollisionPolicy Policy, MissionPathIdentity Identity)?)dialog.Tag;
                        })) break;
                        candidate.CreationApproved = true;
                        candidate.ReplacementApproved = true;
                        reviewed = candidate;
                        break;
                    }
                    if (collision != MissionCollisionPolicy.AskReplace)
                    {
                        candidate.CreationApproved = true;
                        candidate.ReplacementApproved = false;
                        reviewed = candidate;
                        break;
                    }
                    using var reviewDialog = CreateMissionInstallReview(candidate);
                    using var reviewModal = _loadingScreen?.SuspendForModal(reviewDialog);
                    var decision = reviewDialog.ShowDialog(this);
                    if (decision == DialogResult.Retry && candidate.RevisedWarehouseSources is not null)
                    {
                        ApplyMissionWarehouseReviewChoices(candidate.RevisedWarehouseSources);
                        selection = selection with { WarehouseSources = candidate.RevisedWarehouseSources };
                        continue;
                    }
                    if (decision == DialogResult.OK) reviewed = candidate;
                    break;
                }
            }, cancellation.Token, "Preparing mission downloads…", finishCommittedPreparation: true, errorTitle: "Download missions");
            if (reviewed is not null && !cancellation.IsCancellationRequested && !IsDisposed && !Disposing)
                await RunConfigLoadingAsync(async (progress, token) =>
                {
                    result = await ExecuteMissionDownloadAsync(reviewed, progress, token);
                    try
                    {
                        if (registerServer && !result.Cancelled && !token.IsCancellationRequested)
                            serverOutcomes = await RegisterCreatedMissionsAsync(result.Installed, registrationTargets, progress, token);
                    }
                    finally
                    {
                        try { await RefreshMissionFilesAfterFullInstallAsync(result.Installed); }
                        catch (OperationCanceledException) when (_updatesLifetime.IsCancellationRequested || _missionCloseRequested) { }
                        catch (Exception error) { result.Warnings.Add("Could not refresh mission update status: " + error.Message); }
                    }
                }, cancellation.Token, "Installing missions…", finishCommittedPreparation: true, errorTitle: "Download missions");
        }
        catch (OperationCanceledException) when (cancellation.IsCancellationRequested) { }
        catch (Exception error)
        {
            if (!IsDisposed && !Disposing) MessageBox.Show(this, error.Message, "Download missions", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
        finally
        {
            _missionDownloadBusy = false;
            _missionDownloadCancellation = null;
            cancellation.Dispose();
            if (!IsDisposed && !Disposing)
            {
                _missionDownloadsPanel.Enabled = true;
                if (result is not null && result.Installed.Count > 0) RecordInstalledMissionWarehouseSources(result.Installed);
                if (result is not null && reviewed is not null && !zipOnly)
                {
                    _missionDownloadsRendering = true;
                    try
                    {
                        foreach (var group in reviewed.Outputs.GroupBy(output => output.Template.Asset.Id))
                            if (group.All(output => result.Installed.Contains(output.OutputPath, StringComparer.OrdinalIgnoreCase))
                                && _missionAssetChecks.TryGetValue(group.Key, out var check)) check.Checked = false;
                    }
                    finally { _missionDownloadsRendering = false; }
                }
                RefreshMissionDownloadSelection();
                if (result is null) _missionDownloadSummary!.Text = "No installation started. Your prepared downloads remain available to try again.";
                else
                {
                    _missionDownloadSummary!.Text = (result.Cancelled ? "Cancelled · " : "Finished · ") + result.Installed.Count
                        + " mission(s), " + result.UpdatedConfigs.Count + " Config(s), " + result.SavedZips.Count + " ZIP(s).";
                    var lines = result.Installed.Select(path => "Installed: " + path)
                        .Concat(result.UpdatedConfigs.Select(path => "Config updated: " + path))
                        .Concat(result.SavedZips.Select(path => "ZIP saved: " + path))
                        .Concat(result.Skipped.Select(path => "Skipped: " + path))
                        .Concat(result.Failed.Select(path => "Not installed: " + path))
                        .Concat(result.FailedConfigs.Select(path => "Config not updated: " + path))
                        .Concat(result.Warnings.Select(warning => "Warning: " + warning))
                        .Concat(serverOutcomes.Select(FormatServerRegistrationOutcome));
                    _missionDownloadResultDetails.Text = string.Join(Environment.NewLine, lines);
                    _missionDownloadResultsToggle!.Show();
                }
                if (_missionDownloadService is not null && _missionDownloadService.CleanupWarnings.Count > 0)
                {
                    _missionDownloadResultDetails.Text += Environment.NewLine + string.Join(Environment.NewLine,
                        _missionDownloadService.CleanupWarnings.Select(warning => "Warning: " + warning));
                    _missionDownloadResultsToggle!.Show();
                }
                UpdateMissionDownloadLocation(result);
                RefreshUpdatesPresentation();
                if (openFolder && result is not null && (result.Installed.Count > 0 || result.SavedZips.Count > 0))
                {
                    var folder = Path.GetDirectoryName(result.Installed.Concat(result.SavedZips).First())!;
                    OpenMissionDownloadFolder(folder);
                }
            }
            if (_updatesDisposed) DisposeMissionDownloadState();
            if (_missionCloseRequested && !IsDisposed && !Disposing) { _missionCloseRequested = false; Close(); }
        }
    }

    private void UpdateMissionDownloadLocation(MissionDownloadResult? result)
    {
        _missionDownloadResultFolder = result?.Installed.FirstOrDefault() is { } path ? Path.GetDirectoryName(path) : null;
        _missionDownloadOpenLocation!.Enabled = _missionDownloadResultFolder is not null;
        _missionDownloadOpenLocation.Visible = _missionDownloadResultFolder is not null;
    }

    private void OpenMissionDownloadFolder(string folder)
    {
        try { Process.Start(new ProcessStartInfo(folder) { UseShellExecute = true }); }
        catch (Exception error) { _missionDownloadSummary!.Text += Environment.NewLine + "Could not open the result folder: " + error.Message; }
    }

    private bool _missionDownloadLifetimeRegistered;
    private void EnsureMissionDownloadLifetime()
    {
        if (_missionDownloadLifetimeRegistered) return;
        LoadCustomMissionOutputFolder();
        LoadMissionSourceFolders();
        FormClosing += OnMissionDownloadClosing;
        _missionDownloadLifetimeRegistered = true;
    }
    private void OnMissionDownloadClosing(object? sender, FormClosingEventArgs e)
    {
        if (!_missionDownloadBusy && _missionFilesBackgroundTask is not { IsCompleted: false }) return;
        _missionFilesScan?.Cancellation.Cancel();
        if (e.CloseReason == CloseReason.WindowsShutDown) { _missionDownloadCancellation?.Cancel(); return; }
        e.Cancel = true;
        _missionCloseRequested = true;
        _missionDownloadCancellation?.Cancel();
    }

    private void DisposeMissionDownloadState()
    {
        _missionDownloadCancellation?.Cancel();
        _missionFilesScan?.Cancellation.Cancel();
        if (_missionDownloadBusy || _missionFilesScan is not null) return; // Settle shared scan work before disposing its service.
        _missionDownloadService?.Dispose();
        _missionDownloadService = null;
        _missionFilesService?.Dispose();
        _missionFilesService = null;
        _missionFilesPreparation = null;
    }
}
