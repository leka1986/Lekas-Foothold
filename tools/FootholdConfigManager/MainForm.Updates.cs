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

    internal Task BeginUpdateChecksAsync() => _updatesStartupTask ??= BeginUpdateChecksCoreAsync();

    private async Task BeginUpdateChecksCoreAsync()
    {
        await Task.Yield(); // Even a warm cache is presented after the interactive startup handoff.
        if (IsDisposed || Disposing) return;
        var token = _updatesLifetime.Token;
        try
        {
            _updateChecker ??= new GitHubUpdateChecker(ManagerBuildInfo.ReleaseVersion);
            PresentUpdateResult(await _updateChecker.GetCurrentAsync(token));
            if (!IsDisposed && !Disposing) await CheckForUpdatesAsync(force: false);
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
        try { PresentUpdateResult(await _updateChecker.CheckAsync(force, token)); }
        catch (OperationCanceledException) when (token.IsCancellationRequested) { }
        catch (Exception error) { if (!IsDisposed && !Disposing) _updatesError = error.Message; }
        finally { if (!IsDisposed && !Disposing) { _updatesBusy = false; RefreshUpdatesPresentation(); } }
    }

    private void PresentUpdateResult(UpdateCheckResult result)
    {
        if (IsDisposed || Disposing) return;
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

    private void ShowUpdatesPanel()
    {
        if (_mainSplit is null) return;
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
        _updatesAutomatic = new CheckBox { Text = "Check for updates automatically", AutoSize = true, Margin = new Padding(0, Zoomed(10), 0, Zoomed(8)) };
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
        var count = result is null ? 0 : (result.ManagerUpdateAvailable ? 1 : 0) + (result.FootholdUpdateAvailable ? 1 : 0);
        var caption = count == 0 ? "Updates" : "Updates · " + count;
        if (_updatesButton is not null && _updatesButton.Text != caption) { _updatesButton.Text = caption; LayoutPreviewFooter(); }
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
            _updatesFootholdDetail!.Text = FeedDetail(result.Foothold, release is null ? "No release information is available." : result.FootholdUpdateAvailable ? "View the release notes and download the maps you use." : "You have already seen this release. All map downloads remain available on GitHub.");
            _updatesReleaseAction!.Visible = release is not null;
            _updatesDismiss!.Visible = result.FootholdUpdateAvailable;
            _updatesAutomatic!.Checked = result.AutomaticChecksEnabled;
            _updatesCheck!.Enabled = !_updatesBusy && !_updatesInstalling;
            _updatesStatus!.Text = _updatesInstalling ? "Preparing the Manager update…" : _updatesBusy ? "Checking GitHub…" : _updatesError ?? result.PersistenceError ?? "Checks use saved results for up to 24 hours. Check again requests a refresh.";
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

    private void DisposeUpdates()
    {
        if (_updatesDisposed) return;
        _updatesDisposed = true;
        _updatesLifetime.Cancel();
        _updatesLifetime.Dispose();
        _updatesHeadingFont?.Dispose();
        _updatesSectionFont?.Dispose();
    }
}