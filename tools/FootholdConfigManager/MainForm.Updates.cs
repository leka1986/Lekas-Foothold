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
    private readonly CancellationTokenSource _updatesLifetime = new();
    private GitHubUpdateChecker? _updateChecker;
    private UpdateCheckResult? _updatesResult;
    private Task? _updatesStartupTask;
    private bool _updatesBusy, _updatesRendering, _updatesInstalling, _updatesDisposed;
    private string? _updatesError;
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
            PresentUpdateResult(await _updateChecker.GetCurrentAsync(token));
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
        RefreshUpdatesPresentation();
        try
        {
            var result = await _updateChecker.CheckAsync(force, token);
            PresentUpdateResult(result);
            if (!IsDisposed && !Disposing && result.AutomaticChecksEnabled && result.ManagerUpdateAvailable &&
                result.ManagerCheckedThisOperation && result.Manager.Status == UpdateFeedStatus.Fresh)
                _managerNoticePendingVersion = result.Manager.Data!.Version;
        }
        catch (OperationCanceledException) when (token.IsCancellationRequested) { }
        catch (Exception error) { if (!IsDisposed && !Disposing) _updatesError = error.Message; }
        finally { if (!IsDisposed && !Disposing) { _updatesBusy = false; RefreshUpdatesPresentation(); } }
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
        try { PresentUpdateResult(await action(_updateChecker, token)); }
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
    private void ShowUpdatesPanel()
    {
        if (_mainSplit is null) return;
        if (_weatherWindow is { Visible: true })
        {
            _weatherWindow.LeaveWeather();
            if (_weatherWindow.Visible) return;
        }
        if (_updatesPanel is null) BuildUpdatesPanel();
        _updatesPanel!.Visible = true;
        _updatesPanel.BringToFront();
        _updatesPanel.SelectNextControl(null, true, true, true, true);
        LayoutUpdatesPanel();
        RefreshUpdatesPresentation();
        _ = BeginUpdateChecksAsync();
    }

    private void BuildUpdatesPanel()
    {
        _updatesPanel = new Panel { Name = "UpdatesPanel", Dock = DockStyle.Fill, AutoScroll = true, BackColor = MainBackground };
        _updatesContent = new TableLayoutPanel { Dock = DockStyle.Top, AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink, ColumnCount = 1 };
        _updatesContent.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        _updatesPanel.Controls.Add(_updatesContent);
        _updatesPanel.SizeChanged += (_, _) => LayoutUpdatesPanel();
        _mainSplit!.Panel2.Controls.Add(_updatesPanel);
        Label TextLabel(string text)
        {
            var label = new Label { Text = text, AutoSize = true, Margin = new Padding(0, Zoomed(6), 0, Zoomed(8)) };
            _updatesContent.Controls.Add(label);
            return label;
        }
        FlowLayoutPanel Actions(params Control[] controls)
        {
            var actions = new FlowLayoutPanel { AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink, WrapContents = true, Dock = DockStyle.Top, Margin = new Padding(0, 0, 0, Zoomed(20)) };
            foreach (var control in controls) control.Dock = DockStyle.None;
            actions.Controls.AddRange(controls);
            _updatesContent.Controls.Add(actions);
            return actions;
        }
        _updatesHeading = TextLabel("Updates");
        var back = MakeButton("Back to configuration", () => _updatesPanel.Visible = false);
        Actions(back);
        TextLabel("Updates are checked quietly after startup. Your mission files and settings stay in place.");
        _updatesManagerTitle = TextLabel("Foothold Config Manager");
        _updatesManagerDetail = TextLabel("Update information has not been checked yet.");
        _updatesManagerAction = MakeButton("View download", () => _ = UpdateManagerFromNoticeAsync());
        _updatesSkip = MakeButton("Skip this version", () =>
        {
            if (_updatesResult?.Manager.Data is { } displayed)
                _ = RunUpdateActionAsync((checker, token) => checker.SkipManagerAsync(displayed.Version, token));
        });
        Actions(_updatesManagerAction, _updatesSkip);
        _updatesFootholdTitle = TextLabel("Foothold mission releases");
        _updatesFootholdDetail = TextLabel("Release information has not been checked yet.");
        _updatesReleaseAction = MakeButton("View release", () => _ = OpenFootholdReleaseAsync());
        _updatesDismiss = MakeButton("Dismiss this release", () =>
        {
            if (_updatesResult?.Foothold.Data is { } displayed)
                _ = RunUpdateActionAsync((checker, token) => checker.AcknowledgeFootholdAsync(displayed.Id, displayed.Tag, token));
        });
        Actions(_updatesReleaseAction, _updatesDismiss);
        _updatesAutomatic = new CheckBox { Text = "Check for updates on every startup", AutoSize = true, Margin = new Padding(0, Zoomed(10), 0, Zoomed(8)) };
        _updatesAutomatic.CheckedChanged += (_, _) =>
        {
            if (_updatesRendering) return;
            var enabled = _updatesAutomatic.Checked;
            _ = RunUpdateActionAsync((checker, token) => checker.SetAutomaticChecksAsync(enabled, token));
        };
        _updatesContent.Controls.Add(_updatesAutomatic);
        _updatesCheck = MakeButton("Check again", () => _ = CheckForUpdatesAsync(force: true));
        Actions(_updatesCheck);
        _updatesStatus = TextLabel("");
        ApplyThemeToControl(_updatesPanel, restyleButtons: true);
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
        if (_updatesHeading is not null) _updatesHeading.Font = _updatesHeadingFont!;
        if (_updatesManagerTitle is not null) _updatesManagerTitle.Font = _updatesSectionFont!;
        if (_updatesFootholdTitle is not null) _updatesFootholdTitle.Font = _updatesSectionFont!;
        if (changedFont) { oldHeading?.Dispose(); oldSection?.Dispose(); }
        _updatesContent.Padding = new Padding(Zoomed(24));
        var width = Math.Max(1, _updatesPanel.ClientSize.Width - _updatesContent.Padding.Horizontal - Zoomed(18));
        foreach (var label in _updatesContent.Controls.OfType<Label>()) label.MaximumSize = new Size(width, 0);
        foreach (var action in _updatesContent.Controls.OfType<FlowLayoutPanel>())
        {
            action.MaximumSize = new Size(width, 0);
            foreach (var button in action.Controls.OfType<Button>())
            {
                button.Dock = DockStyle.None;
                button.Font = Font;
                button.Width = Math.Max(Zoomed(110), TextRenderer.MeasureText(button.Text, Font).Width + Zoomed(28));
                button.Height = Zoomed(34);
                button.Margin = new Padding(0, Zoomed(4), Zoomed(10), Zoomed(4));
            }
        }
    }

    private void RefreshUpdatesPresentation()
    {
        if (IsDisposed || Disposing) return;
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
                LayoutPreviewFooter();
                updateButton.Update(); // Flush the invalidation raised by the text/notice change without waiting for hover.
            }
        }
        RefreshManagerUpdateNotice();
        if (_updatesPanel is null) return;
        if (result is null)
        {
            _updatesStatus!.Text = _updatesError ?? (_updatesBusy ? "Checking GitHub…" : "Loading saved update information…");
            _updatesManagerAction!.Visible = _updatesSkip!.Visible = _updatesReleaseAction!.Visible = _updatesDismiss!.Visible = false;
            _updatesAutomatic!.Enabled = false;
            return;
        }
        _updatesAutomatic!.Enabled = true;
        _updatesRendering = true;
        try
        {
            var manager = result.Manager.Data;
            _updatesManagerTitle!.Text = result.ManagerUpdateAvailable ? "Manager " + manager!.Version.ToString(manager.Version.Revision == 0 ? 3 : 4) + " is available" : "Foothold Config Manager " + ManagerBuildInfo.VersionText;
            _updatesManagerDetail!.Text = FeedDetail(result.Manager, manager is null ? "No published Manager version was found." : "Running " + ManagerBuildInfo.VersionText + " · GitHub " + manager.Version.ToString(manager.Version.Revision == 0 ? 3 : 4));
            _updatesManagerAction!.Text = AppMode.IsExportedUserBuild ? "Update Manager" : "View download";
            _updatesManagerAction.Visible = _updatesSkip!.Visible = result.ManagerUpdateAvailable;
            _updatesManagerAction.Enabled = !_updatesInstalling;
            _updatesSkip.Enabled = !_updatesInstalling;
            var release = result.Foothold.Data;
            _updatesFootholdTitle!.Text = release is null ? "Foothold mission releases" : release.Title + (result.FootholdUpdateAvailable ? " is available" : "");
            _updatesFootholdDetail!.Text = FeedDetail(result.Foothold, release is null ? "No release information is available." : result.FootholdUpdateAvailable ? "View the release notes and download the maps you use." : result.ImportedFootholdVersion is null ? "Mission notifications start after importing a release-tagged MIZ or config. You can view the latest release here." : result.FootholdReleaseImported ? "This release has already been imported. All map downloads remain available on GitHub." : "You have already seen this release. All map downloads remain available on GitHub.");
            _updatesReleaseAction!.Visible = release is not null;
            _updatesDismiss!.Visible = result.FootholdUpdateAvailable;
            _updatesAutomatic!.Checked = result.AutomaticChecksEnabled;
            _updatesCheck!.Enabled = !_updatesBusy && !_updatesInstalling;
            _updatesStatus!.Text = _updatesInstalling ? "Preparing the Manager update…" : _updatesBusy ? "Checking GitHub…" : _updatesError ?? result.PersistenceError ?? (result.AutomaticChecksEnabled ? "Checks GitHub on every startup. Check again refreshes now." : "Automatic checks are off. Use Check again to check GitHub.");
        }
        finally { _updatesRendering = false; }
        LayoutUpdatesPanel();
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

    private async Task OpenFootholdReleaseAsync()
    {
        if (_updatesResult?.Foothold.Data is not { } release) return;
        try { OpenUpdatePage(release.HtmlUrl); await RunUpdateActionAsync((checker, token) => checker.AcknowledgeFootholdAsync(release.Id, release.Tag, token)); }
        catch (Exception error) { if (!IsDisposed && !Disposing) { _updatesError = error.Message; RefreshUpdatesPresentation(); } }
    }

    private async Task UpdateManagerFromNoticeAsync()
    {
        if (_updatesResult?.Manager.Data is not { } manager || !_updatesResult.ManagerUpdateAvailable || _updatesInstalling) return;
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
        _updatesLifetime.Cancel();
        _updatesLifetime.Dispose();
        _updatesHeadingFont?.Dispose();
        _updatesSectionFont?.Dispose();
    }
}