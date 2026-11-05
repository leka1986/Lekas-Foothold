using System.Diagnostics;

namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private Button? _updatesButton;
    private Panel? _updatesPanel;
    private TableLayoutPanel? _updatesContent;
    private Font? _updatesHeadingFont, _updatesSectionFont;
    private Label? _updatesHeading, _updatesManagerTitle, _updatesManagerDetail, _updatesFootholdTitle, _updatesFootholdDetail, _updatesStatus;
    private Button? _updatesManagerAction, _updatesSkip, _updatesReleaseAction, _updatesDismiss, _updatesCheck;
    private CheckBox? _updatesAutomatic;
    private Button? _updatesDownloadAction;
    private readonly CancellationTokenSource _updatesLifetime = new();
    private GitHubUpdateChecker? _updateChecker;
    private UpdateCheckResult? _updatesResult;
    private Task? _updatesStartupTask;
    private bool _updatesBusy, _updatesRendering, _updatesInstalling, _updatesDisposed, _updatesPreparingReveal;
    private string? _updatesError;
    private MissionConfigHeaderInput[] _missionConfigHeaderInputs = [];
    private IReadOnlyList<MissionConfigHeaderFact> _missionConfigHeaderFacts = [];
    private long _missionConfigHeaderGeneration;

    private MissionConfigHeaderInput[] CaptureMissionConfigHeaderInputs()
    {
        IReadOnlyList<ServerProfileSettings> profiles = _settings.ServerProfiles.Count == 0
            ? new[] { GetMissionDownloadFallback() } : _settings.ServerProfiles;
        return profiles.Where(profile => profile.ConfigPath.Length > 0).Select(profile =>
        {
            var current = _document is not null && PathsEqual(profile.ConfigPath, _document.Path);
            return new MissionConfigHeaderInput(profile.Id, profile.Name, profile.ConfigPath, current,
                current ? _document!.MissionReleaseTag : null);
        }).ToArray();
    }
    private void ReconcileMissionConfigHeaderInputs()
    {
        var inputs = CaptureMissionConfigHeaderInputs();
        if (_missionConfigHeaderInputs.SequenceEqual(inputs)) return;
        var previous = _missionConfigHeaderInputs;
        _missionConfigHeaderInputs = inputs;
        _missionConfigHeaderGeneration++;
        _missionConfigHeaderFacts = _missionConfigHeaderFacts.Where(fact => inputs.Any(input =>
            input.Id == fact.Id && PathsEqual(input.ConfigPath,fact.ConfigPath)
            && previous.Any(old => old.Id == input.Id && PathsEqual(old.ConfigPath,input.ConfigPath)
                && old.IsCurrent == input.IsCurrent && old.CurrentReleaseTag == input.CurrentReleaseTag))).ToArray();
        RefreshUpdatesPresentation();
    }
    private void InvalidateMissionConfigHeaders(IEnumerable<string> paths)
    {
        var changed = paths.ToArray();
        _missionConfigHeaderGeneration++;
        _missionConfigHeaderFacts = _missionConfigHeaderFacts.Where(fact => !changed.Any(path => PathsEqual(path,fact.ConfigPath))).ToArray();
    }
    private static string MissionFilesScanStatus(string groupId, MissionFilesPreparation? preparation)
    {
        if (preparation is null) return "Missions not scanned";
        var rows = preparation.Rows.Where(row => row.GroupId == groupId).ToArray();
        var status = "Last scan: " + rows.Length + " MIZs, "
            + rows.Count(row => preparation.Compatible.ContainsKey(row.Path)) + " compatible";
        var group = preparation.Groups.FirstOrDefault(group => group.Id == groupId);
        if (group is not null && group.Status != "No MIZ files" && !group.Status.EndsWith(" MIZ files", StringComparison.Ordinal))
            status += " · " + group.Status;
        return status;
    }
    private async Task ReadMissionConfigHeadersAsync(UpdateCheckResult result, CancellationToken token)
    {
        ReconcileMissionConfigHeaderInputs();
        var generation = _missionConfigHeaderGeneration;
        var inputs = _missionConfigHeaderInputs;
        if (!result.FilesEnvelopeAvailable || result.FilesEnvelope.Data is not { } envelope) return;
        var facts = await Task.Run(() => MissionConfigHeaders.Read(inputs,envelope.SupportedReleaseTags,token),token);
        if (IsDisposed || Disposing || generation != _missionConfigHeaderGeneration
            || !inputs.SequenceEqual(CaptureMissionConfigHeaderInputs())) return;
        _missionConfigHeaderFacts = facts;
    }

    private Form? _managerUpdateNotice;
    private Form? _managerNoticeModal;
    private Version? _managerNoticePendingVersion;
    private readonly HashSet<Version> _announcedManagerVersions = new();

    internal Task BeginUpdateChecksAsync() => _updatesStartupTask ??= BeginUpdateChecksCoreAsync();

    private async Task BeginUpdateChecksCoreAsync()
    {
        await Task.Yield(); // Even a warm cache is presented after the interactive startup handoff.
        if (IsDisposed || Disposing) return;
        Activated += OnManagerNoticeReadinessChanged;
        Deactivate += OnManagerNoticeReadinessChanged;
        EnabledChanged += OnManagerNoticeReadinessChanged;
        VisibleChanged += OnManagerNoticeReadinessChanged;
        Resize += OnManagerNoticeReadinessChanged;
        FontChanged += OnManagerNoticeAppearanceChanged;
        BackColorChanged += OnManagerNoticeAppearanceChanged;
        var token = _updatesLifetime.Token;
        try
        {
            _updateChecker ??= new GitHubUpdateChecker(ManagerBuildInfo.ReleaseVersion);
            PresentUpdateResult(await _updateChecker.BeginInteractiveLaunchAsync(token));
            if (!IsDisposed && !Disposing && _updatesResult?.AutomaticChecksEnabled == true)
                await CheckForUpdatesAsync(force: true);
        }
        catch (OperationCanceledException) when (token.IsCancellationRequested) { }
        catch (Exception error) { if (!IsDisposed && !Disposing) { _updatesError = error.Message; RefreshUpdatesPresentation(); } }
    }

    private async Task CheckForUpdatesAsync(bool force)
    {
        if (_updateChecker is null || IsDisposed || Disposing) return;
        var token = _updatesLifetime.Token;
        _updatesBusy = true;
        _updatesError = null;
        RefreshMissionDownloadSelection();
        if (_missionFilesPanel is not null) RefreshMissionFilesSelection();
        RefreshUpdatesPresentation();
        UpdateCheckResult? completed = null;
        try
        {
            var result = await _updateChecker.CheckAsync(force, token);
            result = (await _updateChecker.GetCurrentAsync(token)) with { ManagerCheckedThisOperation = result.ManagerCheckedThisOperation };
            completed = result;
            if (!IsDisposed && !Disposing && result.AutomaticChecksEnabled && result.ManagerUpdateAvailable &&
                result.ManagerCheckedThisOperation && result.Manager.Status == UpdateFeedStatus.Fresh)
                _managerNoticePendingVersion = result.Manager.Data!.Version;
        }
        catch (OperationCanceledException) when (token.IsCancellationRequested) { }
        catch (Exception error) { if (!IsDisposed && !Disposing) _updatesError = error.Message; }
        finally
        {
            if (!IsDisposed && !Disposing)
            {
                _updatesBusy = false;
                if (completed is not null) PresentUpdateResult(completed);
                else RefreshUpdatesPresentation();
                RefreshMissionDownloadSelection();
                if (_missionFilesPanel is not null) RefreshMissionFilesSelection();
            }
        }
    }

    private void PresentUpdateResult(UpdateCheckResult result)
    {
        if (IsDisposed || Disposing) return;
        if (_updatesResult?.ImportedFootholdVersion is { } imported &&
            (result.ImportedFootholdVersion is not { } incoming || incoming < imported))
            result = result with { State = result.State with { HighestImportedFootholdTag = _updatesResult.State.HighestImportedFootholdTag }, PersistenceError = _updatesResult.PersistenceError };
        _updatesResult = result;
        RefreshUpdatesPresentation();
    }

    private async Task RunUpdateActionAsync(Func<GitHubUpdateChecker, CancellationToken, Task<UpdateCheckResult>> action)
    {
        if (_updateChecker is null || IsDisposed || Disposing) return;
        var token = _updatesLifetime.Token;
        try { var result = await action(_updateChecker, token); _updatesError = null; PresentUpdateResult(result); }
        catch (OperationCanceledException) when (token.IsCancellationRequested) { }
        catch (Exception error) { if (!IsDisposed && !Disposing) { _updatesError = error.Message; RefreshUpdatesPresentation(); } }
    }

    private void RecordImportedMissionRelease(ConfigDocument source)
    {
        if (source.MissionReleaseTag is not { } tag) return;
        _updateChecker ??= new GitHubUpdateChecker(ManagerBuildInfo.ReleaseVersion);
        try
        {
            // Synchronous import/install paths share this already-loaded source and one atomic history write.
            PresentUpdateResult(_updateChecker.RecordImportedFootholdAsync(tag, _updatesLifetime.Token).GetAwaiter().GetResult());
        }
        catch (OperationCanceledException) when (_updatesLifetime.IsCancellationRequested) { }
        catch (Exception error) { _updatesError = error.Message; RefreshUpdatesPresentation(); }
    }
    private async void ShowUpdatesPanel()
    {
        if (_mainSplit is null) return;
        if (_updatesPanel is { Visible: true })
        {
            LeaveUpdatesPanel();
            return;
        }
        if (_weatherWindow is { Visible: true })
        {
            _weatherWindow.LeaveWeather();
            if (_weatherWindow.Visible) return;
        }
        if (_updatesPanel is null) BuildUpdatesPanel();
        ReconcileMissionConfigHeaderInputs();
        PrepareUpdatesReveal();
        _updatesPanel!.Visible = true;
        _updatesPanel.BringToFront();
        _updatesPanel.SelectNextControl(null, true, true, true, true);
        await BeginUpdateChecksAsync();
        if (IsDisposed || Disposing || _updatesPanel is not { Visible: true } || _updatesContent is not { Visible: true }
            || _missionDownloadBusy || _configLoadingOperation || _updatesInstalling || _updatesBusy
            || _updatesResult is not { FilesEnvelopeAvailable: true }
            || (CaptureMissionFilesRoots().Length == 0 && CaptureMissionFilesExternalPaths().Length == 0)) return;
        _missionDownloadJob = OpenMissionFilesAsync(refreshInventory: true, showUpdater: false);
        await _missionDownloadJob;
    }

    private void PrepareUpdatesReveal()
    {
        _updatesPreparingReveal = true;
        try { RefreshUpdatesPresentation(); }
        finally { _updatesPreparingReveal = false; }
    }

    private void LeaveUpdatesPanel()
    {
        _missionReleaseRefreshContext = null;
        _updatesPanel!.Visible = false;
    }

    private void BuildUpdatesPanel()
    {
        EnsureMissionDownloadLifetime();
        _updatesPanel = new Panel { Name = "UpdatesPanel", Dock = DockStyle.Fill, AutoScroll = true, BackColor = MainBackground, Visible = false };
        _updatesPanel.SizeChanged += (_, _) => LayoutUpdatesPanel();
        _mainSplit!.Panel2.Controls.Add(_updatesPanel);
        MissionFilesOpenRequested += () => _missionDownloadJob = OpenMissionFilesAsync();
        BuildMissionFilesUpdatesView(() => MissionFilesOpenRequested?.Invoke(), async () =>
        {
            if (_updatesResult?.Foothold.Data is { AssetMetadataLoaded: true, Assets.Count: > 0 } release)
                await OpenMissionDownloadsAsync(release);
        }, () => _ = OpenFootholdReleaseAsync(), LeaveUpdatesPanel, () => _ = CheckForUpdatesAsync(force: true));
        _updatesContent = _missionFilesUpdatesView!;
        _updatesPanel.Controls.Add(_updatesContent);
        _updatesHeading = EnumerateChildControls<Label>(_updatesContent).First(label => label.Text == "Updates");
        _updatesManagerTitle = EnumerateChildControls<Label>(_updatesContent).First(label => label.Text == "Foothold Config Manager");
        _updatesManagerDetail = _missionFilesManagerText;
        _updatesFootholdTitle = _missionFilesReleaseTitle;
        _updatesFootholdDetail = _missionFilesReleaseDetail;
        _updatesManagerAction = MissionFilesButton("FilesUpdatesManagerAction", AppMode.IsExportedUserBuild ? "Update Manager" : "View download", () => _ = UpdateManagerFromNoticeAsync());
        _updatesSkip = MissionFilesButton("FilesUpdatesSkip", "Skip this version", () =>
        {
            if (_updatesResult?.Manager.Data is { } displayed)
                _ = RunUpdateActionAsync((checker, token) => checker.SkipManagerAsync(displayed.Version, token));
        });
        _missionFilesManagerActions!.Controls.AddRange([_updatesManagerAction, _updatesSkip]);
        _updatesDismiss = MissionFilesButton("FilesUpdatesDismiss", "Dismiss this release", () =>
        {
            if (_updatesResult?.Foothold.Data is { } displayed)
                _ = RunUpdateActionAsync((checker, token) => checker.AcknowledgeFootholdAsync(displayed.Id, displayed.Tag, token));
        });
        _missionFilesReleaseActions!.Controls.Add(_updatesDismiss);
        _updatesReleaseAction = EnumerateChildControls<Button>(_updatesContent).Single(button => button.Name == "FilesUpdatesNotes");
        _updatesDownloadAction = EnumerateChildControls<Button>(_updatesContent).Single(button => button.Name == "FilesUpdatesDownload");
        _updatesDownloadAction.Name = "DownloadMissionsAction";
        ((PreviewButton)_updatesDownloadAction).AccentOutline = true;
        _updatesAutomatic = EnumerateChildControls<CheckBox>(_updatesContent).Single(check => check.Name == "FilesUpdatesAutomatic");
        _updatesAutomatic.CheckedChanged += (_, _) =>
        {
            if (_updatesRendering) return;
            var enabled = _updatesAutomatic.Checked;
            _ = RunUpdateActionAsync((checker, token) => checker.SetAutomaticChecksAsync(enabled, token));
        };
        _updatesCheck = EnumerateChildControls<Button>(_updatesContent).Single(button => button.Name == "FilesUpdatesCheck");
        _updatesStatus = MissionFilesLabel("");
        AddMissionFilesControl(_updatesContent, _updatesStatus);
        LayoutUpdatesPanel();
    }

    private void LayoutUpdatesPanel()
    {
        if (_updatesPanel is null || _updatesContent is null) return;
        var oldHeading = _updatesHeadingFont;
        var oldSection = _updatesSectionFont;
        var changedFont = _updatesHeadingFont is null || Math.Abs(_updatesHeadingFont.Size - Font.Size * 1.55F) > 0.01F;
        if (changedFont)
        {
            _updatesHeadingFont = new Font(Font.FontFamily, Font.Size * 1.55F, FontStyle.Bold);
            _updatesSectionFont = new Font(Font, FontStyle.Bold);
        }
        // The retained Task1 component owns its cached presentation fonts.
        if (changedFont) { LayoutMissionDownloads(); oldHeading?.Dispose(); oldSection?.Dispose(); }
        if (!_updatesPreparingReveal && (!_updatesPanel.Visible || !_updatesContent.Visible)) return;
        _updatesContent.Padding = new Padding(Zoomed(24));
        var width = Math.Max(1, _updatesPanel.ClientSize.Width - _updatesContent.Padding.Horizontal - Zoomed(18));
        foreach (var label in EnumerateChildControls<Label>(_updatesContent)) label.MaximumSize = new Size(width, 0);
        foreach (var action in _updatesContent.Controls.OfType<FlowLayoutPanel>()) action.MaximumSize = new Size(width, 0);
    }

    private void RefreshUpdatesPresentation()
    {
        if (IsDisposed || Disposing) return;
        if (_updateChecker is { } checker && _updatesResult is { } retained) _updatesResult = checker.AgeSnapshot(retained);
        var result = _updatesResult;
        var managerNotice = result?.ManagerUpdateAvailable == true;
        var missionNotice = result?.FootholdUpdateAvailable == true;
        var hasNotice = managerNotice || missionNotice;
        var caption = managerNotice && missionNotice ? "New updates available"
            : managerNotice ? "Manager update available" : missionNotice ? "New mission release" : "Updates";
        if (_updatesButton is PreviewButton updateButton)
        {
            var changed = updateButton.Text != caption || updateButton.HasUpdateNotice != hasNotice;
            updateButton.HasUpdateNotice = hasNotice;
            updateButton.Text = caption;
            updateButton.AccessibleName = caption;
            if (changed)
            {
                LayoutPreviewHeader();
                updateButton.Update(); // Flush the invalidation raised by the text/notice change without waiting for hover.
            }
        }
        RefreshManagerUpdateNotice();
        RefreshMissionReleaseActions();
        if (_updatesPanel is null || _updatesContent is null
            || !_updatesPreparingReveal && (!_updatesPanel.Visible || !_updatesContent.Visible)) return;
        var layouts = new Control?[] { _updatesPanel, _updatesContent, _missionFilesUpdatesDetails, _missionFilesUpdateInstances }
            .Concat(_missionFilesUpdateInstanceRows.Values.Select(row => (Control?)row.Row)).ToArray();
        foreach (var control in layouts) control?.SuspendLayout();
        try
        {
        if (result is null)
        {
            _missionFilesUpdatesDetails!.Visible = false;
            _updatesStatus!.Text = _updatesError ?? (_updatesBusy ? "Checking GitHub…" : "Loading saved update information…");
            _updatesManagerAction!.Visible = _updatesSkip!.Visible = _updatesReleaseAction!.Visible = _updatesDismiss!.Visible = false;
            _missionFilesDownloadsSection!.Visible = false;
            _updatesDownloadAction!.Visible = false;
            _updatesAutomatic!.Enabled = false;
            PresentMissionFilesUpdates(new(false,"Update information has not been checked yet.","Foothold mission releases",false,[]));
            LayoutUpdatesPanel();
            return;
        }
        _updatesAutomatic!.Enabled = true;
        _updatesRendering = true;
        try
        {
            var manager = result.Manager.Data;
            _updatesManagerTitle!.Text = "Foothold Config Manager";
            _updatesManagerDetail!.Text = FeedDetail(result.Manager, manager is null ? "No published Manager version was found." : "Running " + ManagerBuildInfo.VersionText + " · GitHub " + manager.Version.ToString(manager.Version.Revision == 0 ? 3 : 4));
            _updatesManagerAction!.Text = AppMode.IsExportedUserBuild ? "Update Manager" : "View download";
            _updatesManagerAction.Visible = result.ManagerUpdateDownloadAvailable;
            _updatesSkip!.Visible = result.ManagerUpdateAvailable;
            _updatesManagerAction.Enabled = !_updatesInstalling && !_missionDownloadBusy;
            _updatesSkip.Enabled = !_updatesInstalling;
            var release = result.Foothold.Data;
            _updatesFootholdTitle!.Text = release is null ? "Foothold mission releases" : release.Title + (result.FootholdUpdateAvailable ? " is available" : "");
            _updatesFootholdDetail!.Text = FeedDetail(result.Foothold, release is null ? "No release information is available." : result.FootholdUpdateAvailable ? "View the release notes and download the maps you use." : result.ImportedFootholdVersion is null && !result.FootholdReleaseAcknowledged ? "No mission version has been recorded yet. You can view the latest release here." : result.FootholdReleaseImported ? "This release has already been imported. All map downloads remain available on GitHub." : "You have already seen this release. All map downloads remain available on GitHub.");
            if (result.FilesEnvelope.Error is { } filesError) _updatesFootholdDetail.Text += " Files-only update check: " + filesError;
            else if (release?.FilesEnvelopeAsset is not null && result.FilesEnvelope.Status != UpdateFeedStatus.Fresh)
                _updatesFootholdDetail.Text += " Files-only: " + FeedDetail(result.FilesEnvelope,"Ready to check mission files.");
            _updatesDownloadAction!.Visible = release is not null;
            _missionFilesDownloadsSection!.Visible = release is not null;
            _updatesDownloadAction.Enabled = release is { AssetMetadataLoaded: true, Assets.Count: > 0 } && !_missionDownloadBusy && !_updatesInstalling;
            _updatesDownloadAction.Text = release?.AssetMetadataLoaded == false ? "Check again to load maps" : "Download missions";
            _updatesReleaseAction!.Visible = release is not null;
            _updatesDismiss!.Visible = result.FootholdUpdateAvailable;
            _updatesAutomatic!.Checked = result.AutomaticChecksEnabled;
            _updatesCheck!.Enabled = !_updatesBusy && !_updatesInstalling;
            _updatesStatus!.Text = _updatesInstalling ? "Preparing the Manager update…" : _updatesBusy ? "Checking GitHub…" : _updatesError ?? result.PersistenceError ?? (result.AutomaticChecksEnabled ? "Checks GitHub on every startup. Check again refreshes now." : "Automatic checks are off. Use Check again to check GitHub.");
            var filesAvailable = result.FilesEnvelopeAvailable;
            var roots = CaptureMissionFilesRoots();
            var externalPaths = CaptureMissionFilesExternalPaths();
            var preparation = HasCurrentMissionFilesPreparation(result, roots, externalPaths) ? _missionFilesPreparation : null;
            var compatibleCount = preparation?.Compatible.Count ?? 0;
            var compatibleGroups = preparation?.Rows
                .Where(row => preparation.Compatible.ContainsKey(row.Path))
                .Select(row => row.GroupId).ToHashSet(StringComparer.Ordinal);
            var sourceRows = roots.Where(root => compatibleGroups?.Contains(root.Id) == true)
                .Select(root => (root.Id, root.Name, MissionFilesScanStatus(root.Id, preparation))).ToList();
            if (compatibleGroups?.Contains("external") == true)
                sourceRows.Add(("external", "Added missions", MissionFilesScanStatus("external", preparation)));
            _missionFilesUpdatesDetails!.Visible = filesAvailable;
            _missionFilesUpdatesScanStatus!.Text = preparation is null
                ? roots.Length == 0 && externalPaths.Length == 0 ? "No mission folders found. Add a mission folder to check."
                    : "Check your mission folders for compatible MIZs."
                : compatibleCount == 0 ? "No compatible missions found in the folders checked."
                : compatibleCount == 1 ? "1 compatible mission found" : $"{compatibleCount} compatible missions found";
            _missionFilesPreservationCallout!.Visible = compatibleCount > 0;
            var canOpenFiles = filesAvailable && MissionFilesOpenRequested is not null
                && !_updatesBusy && !_missionDownloadBusy && !_updatesInstalling && !_configLoadingOperation;
            _missionFilesUpdatesOpen!.Visible = compatibleCount > 0;
            _missionFilesUpdatesOpen.Enabled = _missionFilesUpdatesAddFolder!.Enabled = _missionFilesUpdatesAddMiz!.Enabled = canOpenFiles;
            _missionFilesUpdatesCheckMissions!.Enabled = canOpenFiles && (roots.Length > 0 || externalPaths.Length > 0);
            var managerText = _updatesBusy ? "Checking GitHub…" : result.Manager.Status == UpdateFeedStatus.Fresh && manager is not null && result.ManagerUpdateDownloadAvailable
                ? "Manager " + manager.Version.ToString(manager.Version.Revision == 0 ? 3 : 4) + (result.ManagerUpdateAvailable ? " is available" : " · reminder skipped")
                : _updatesManagerDetail.Text;
            PresentMissionFilesUpdates(new(!_updatesBusy && result.ManagerVerifiedCurrent, managerText, _updatesFootholdTitle.Text, compatibleCount > 0,
                sourceRows.ToArray()));

        }
        finally { _updatesRendering = false; }
        LayoutUpdatesPanel();
        }
        finally { foreach (var control in layouts.Reverse()) if (control is { IsDisposed: false }) control.ResumeLayout(true); }
    }

    private static string FeedDetail<T>(UpdateFeedResult<T> feed, string good) where T : class => feed.Status switch
    {
        UpdateFeedStatus.Unknown => feed.Error ?? "Not checked yet.",
        UpdateFeedStatus.Stale => "Saved information · " + (feed.Error ?? "Could not refresh this check."),
        UpdateFeedStatus.Backoff => "Check paused until " + feed.RetryAfterUtc?.ToLocalTime().ToString("g") + ". " + (feed.Error ?? "Saved information is shown."),
        _ => good
    };

    private static void OpenUpdatePage(string address)
    {
        if (!Uri.TryCreate(address, UriKind.Absolute, out var uri) || uri.Scheme != Uri.UriSchemeHttps ||
            uri.Host != "github.com" || !uri.AbsolutePath.StartsWith("/leka1986/Lekas-Foothold/", StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException("The GitHub update link is not valid.");
        Process.Start(new ProcessStartInfo(uri.AbsoluteUri) { UseShellExecute = true });
    }

    private Task OpenFootholdReleaseAsync() => _updatesResult?.Foothold.Data is { } release
        ? OpenFootholdReleaseAsync(release) : Task.CompletedTask;

    private async Task OpenFootholdReleaseAsync(FootholdReleaseInfo release)
    {
        try { OpenUpdatePage(release.HtmlUrl); await RunUpdateActionAsync((checker, token) => checker.AcknowledgeFootholdAsync(release.Id, release.Tag, token)); }
        catch (Exception error) { if (!IsDisposed && !Disposing) { _updatesError = error.Message; RefreshUpdatesPresentation(); } }
    }

    private async Task UpdateManagerFromNoticeAsync()
    {
        if (_updatesResult is not { ManagerUpdateDownloadAvailable: true } result
            || result.Manager.Data is not { } manager || _updatesInstalling || _missionDownloadBusy) return;
        try
        {
            if (!AppMode.IsExportedUserBuild) { OpenUpdatePage(manager.HtmlUrl); return; }
            if (MessageBox.Show(this, "Download and install Manager " + manager.Version.ToString(manager.Version.Revision == 0 ? 3 : 4) + "? The Manager will save your changes, close and restart at its current location.",
                "Update Manager", MessageBoxButtons.OKCancel, MessageBoxIcon.Information) != DialogResult.OK) return;
            _updatesInstalling = true;
            _updatesError = null;
            RefreshUpdatesPresentation();
            var token = _updatesLifetime.Token;
            using var prepared = await ManagerSelfUpdater.PrepareAsync(new ManagerSelfUpdateCandidate(manager.Name, manager.Version.ToString(4), manager.Sha, manager.Size), token);
            if (IsDisposed || Disposing) return;
            HideCurrentGridSelectionHighlights(); // Reuse Save's active table-edit commit contract.
            if (HasChanges() && MessageBox.Show(this, "Save the current configuration before updating the Manager?", "Update Manager",
                    MessageBoxButtons.OKCancel, MessageBoxIcon.Question) != DialogResult.OK) return;
            if (_document is not null) SaveConfig();
            if (!_lastConfigSaveSucceeded && _document is not null || HasChanges()) { _updatesError = "The configuration or its preset was not saved. The Manager was kept open."; return; }
            await prepared.StartHelperAsync(token);
            if (IsDisposed || Disposing) return;
            var closed = false;
            Exception? closeFailure = null;
            void Authorize(object? sender, FormClosedEventArgs args)
            {
                closed = true;
                try { prepared.AuthorizeAfterFormClosed(); }
                catch (Exception error) { closeFailure = error; }
            }
            FormClosed += Authorize;
            try
            {
                Close(); // Existing FormClosing handlers may cancel; only FormClosed authorizes replacement.
                if (!closed) _updatesError = "Closing was cancelled. No Manager update was installed.";
                if (closeFailure is not null)
                    MessageBox.Show("The update could not start. Your original Manager was kept." + Environment.NewLine + closeFailure.Message,
                        "Update Manager", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
            finally { FormClosed -= Authorize; }
        }
        catch (OperationCanceledException) { if (!IsDisposed && !Disposing) _updatesError = "The update was cancelled. Your original Manager was kept."; }
        catch (Exception error) { if (!IsDisposed && !Disposing) _updatesError = error.Message; }
        finally { if (!IsDisposed && !Disposing) { _updatesInstalling = false; RefreshUpdatesPresentation(); } }
    }

    private sealed class ManagerUpdateNoticeForm : Form
    {
        protected override bool ShowWithoutActivation => true;
    }

    private void OnManagerNoticeReadinessChanged(object? sender, EventArgs args)
    {
        RefreshManagerUpdateNotice();
        // Native dialogs can activate their owner just before re-enabling its HWND.
        if (!_updatesDisposed && !IsDisposed && !Disposing && IsHandleCreated &&
            (_managerNoticePendingVersion is not null || _managerUpdateNotice is not null))
            BeginInvoke((Action)RefreshManagerUpdateNotice);
    }

    private void OnManagerNoticeAppearanceChanged(object? sender, EventArgs args)
    {
        if (_managerUpdateNotice is { IsDisposed: false } notice) LayoutManagerUpdateNotice(notice);
    }

    private void TrackManagerNoticeModal(Form? modal)
    {
        if (ReferenceEquals(_managerNoticeModal, modal)) return;
        if (_managerNoticeModal is not null) _managerNoticeModal.FormClosed -= OnManagerNoticeModalClosed;
        _managerNoticeModal = modal;
        if (modal is not null) modal.FormClosed += OnManagerNoticeModalClosed;
    }

    private void OnManagerNoticeModalClosed(object? sender, FormClosedEventArgs args)
    {
        TrackManagerNoticeModal(null);
        // A modal's owner can be re-enabled before ShowDialog has finished hiding it.
        if (!_updatesDisposed && !IsDisposed && !Disposing && IsHandleCreated)
            BeginInvoke((Action)RefreshManagerUpdateNotice);
    }

    private void RefreshManagerUpdateNotice()
    {
        if (_updatesDisposed || IsDisposed || Disposing) return;
        var result = _updatesResult;
        var manager = result?.Manager.Data;
        if (result?.AutomaticChecksEnabled != true || !result.ManagerUpdateAvailable ||
            result.Manager.Status != UpdateFeedStatus.Fresh || _updatesInstalling)
        {
            TrackManagerNoticeModal(null);
            _managerNoticePendingVersion = null;
            _managerUpdateNotice?.Close();
            return;
        }
        if (_managerUpdateNotice?.Tag is Version shown && shown != manager!.Version)
            _managerUpdateNotice.Close();
        if (_managerNoticePendingVersion is { } pending && pending != manager!.Version)
            _managerNoticePendingVersion = null;
        if (_managerUpdateNotice is null && (_managerNoticePendingVersion is null ||
            _announcedManagerVersions.Contains(manager!.Version))) return;

        var modal = OwnedForms.FirstOrDefault(owned => owned.Visible && owned.Modal);
        TrackManagerNoticeModal(modal);
        var ready = !_startupPreparationPending && !_configLoadingOperation && Visible && Enabled && Opacity == 1 &&
            SingleInstanceCoordinator.IsWindowEnabled(Handle) &&
            WindowState != FormWindowState.Minimized && modal is null;
        if (!ready)
        {
            _managerUpdateNotice?.Hide();
            return;
        }
        if (_managerUpdateNotice is { } existing)
        {
            if (!existing.Visible) { LayoutManagerUpdateNotice(existing); existing.Show(); }
            return;
        }
        if (_updatesBusy) return;

        var notice = new ManagerUpdateNoticeForm
        {
            Name = "ManagerUpdateNotice", Text = "New Manager available", Tag = manager!.Version,
            StartPosition = FormStartPosition.Manual, FormBorderStyle = FormBorderStyle.FixedDialog,
            ShowInTaskbar = false, MinimizeBox = false, MaximizeBox = false, Font = Font,
            AutoScaleMode = AutoScaleMode.None
        };
        var content = new TableLayoutPanel { Dock = DockStyle.Fill, ColumnCount = 1, RowCount = 2 };
        content.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        content.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        content.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        var version = manager.Version.ToString(manager.Version.Revision == 0 ? 3 : 4);
        content.Controls.Add(new Label
        {
            AutoSize = true, Dock = DockStyle.Fill, Margin = Padding.Empty,
            Text = "Foothold Config Manager " + version + " is available." + Environment.NewLine + Environment.NewLine +
                "You are running " + ManagerBuildInfo.VersionText + ". Would you like to update?"
        });
        var actions = new FlowLayoutPanel { Dock = DockStyle.Fill, AutoSize = true, WrapContents = true, Margin = Padding.Empty };
        var update = MakeButton(AppMode.IsExportedUserBuild ? "Update Manager" : "View download", () =>
        {
            notice.Close();
            _ = UpdateManagerFromNoticeAsync(); // The existing action owns confirmation, Save and updater authorization.
        });
        var later = MakeButton("Later", () => notice.Close());
        actions.Controls.Add(update);
        actions.Controls.Add(later);
        content.Controls.Add(actions);
        notice.Controls.Add(content);
        notice.AcceptButton = update;
        notice.CancelButton = later;
        notice.FormClosed += (_, _) => { if (ReferenceEquals(_managerUpdateNotice, notice)) _managerUpdateNotice = null; };
        _managerUpdateNotice = notice;
        LayoutManagerUpdateNotice(notice);
        _announcedManagerVersions.Add(manager.Version);
        _managerNoticePendingVersion = null;
        notice.Show(this);
    }

    private void LayoutManagerUpdateNotice(Form notice)
    {
        notice.SuspendLayout();
        try
        {
            notice.Font = Font;
            notice.Padding = new Padding(Zoomed(18));
            notice.ClientSize = FittedDialogClientSize(500, 210, 360, 190);
            foreach (var button in notice.Controls.OfType<TableLayoutPanel>().Single().Controls
                .OfType<FlowLayoutPanel>().Single().Controls.OfType<Button>())
            {
                button.Dock = DockStyle.None;
                button.Margin = new Padding(0, Zoomed(12), Zoomed(10), 0);
                SizeDialogButton(button, 110);
            }
            ApplyDialogChrome(notice);
            var area = Screen.FromControl(this).WorkingArea;
            notice.Location = new Point(Math.Clamp(Left + (Width - notice.Width) / 2, area.Left, Math.Max(area.Left, area.Right - notice.Width)),
                Math.Clamp(Top + (Height - notice.Height) / 2, area.Top, Math.Max(area.Top, area.Bottom - notice.Height)));
        }
        finally { notice.ResumeLayout(true); }
    }

    private void DisposeUpdates()
    {
        if (_updatesDisposed) return;
        _updatesDisposed = true;
        Activated -= OnManagerNoticeReadinessChanged;
        Deactivate -= OnManagerNoticeReadinessChanged;
        EnabledChanged -= OnManagerNoticeReadinessChanged;
        VisibleChanged -= OnManagerNoticeReadinessChanged;
        Resize -= OnManagerNoticeReadinessChanged;
        FontChanged -= OnManagerNoticeAppearanceChanged;
        BackColorChanged -= OnManagerNoticeAppearanceChanged;
        TrackManagerNoticeModal(null);
        _managerNoticePendingVersion = null;
        _managerUpdateNotice?.Dispose();
        _managerUpdateNotice = null;
        DisposeMissionDownloadState();
        _updatesLifetime.Cancel();
        _updatesLifetime.Dispose();
        _updatesHeadingFont?.Dispose();
        _updatesSectionFont?.Dispose();
    }
}
