namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private Panel? _missionDownloadsPanel;
    private TableLayoutPanel? _missionDownloadLayout, _missionDownloadLeft, _missionDownloadRight, _missionDownloadRightColumn, _missionProfileRows;
    private ComboBox? _missionDestination, _missionCollision;
    private Label? _missionDirectory, _missionDownloadSummary, _missionZipNames;
    private TableLayoutPanel? _missionAssetRows, _missionDownloadPage, _missionFileOptions, _missionDownloadAction;
    private Label? _missionDownloadSubtitle, _missionDownloadSelectionCount;
    private Label? _missionProfileHint;
    private Button? _missionChooseTargets, _missionFileOptionsToggle, _missionDownloadOpenFolder;
    private bool _missionTargetsExpanded, _missionFileOptionsExpanded = true;
    private bool _missionTargetsManual;
    private Button? _missionZipToggle;
    private Button? _missionRefreshRelease, _missionChangelog;
    private TableLayoutPanel? _missionSelectionActions;
    private FlowLayoutPanel? _missionSelectionLinks, _missionReleaseActions;
    private Label? _missionReleaseStatus;
    private object? _missionReleaseRefreshContext;
    private Label? _missionDownloadResultDetails;
    private Button? _missionDownloadResultsToggle, _missionDownloadOpenLocation;
    private string? _missionDownloadResultFolder;
    private TableLayoutPanel? _missionTargets;
    private readonly List<CheckBox> _missionTargetChecks = new();
    private IEnumerable<InstanceItem> SelectedMissionConfigTargets => _missionTargetChecks.Where(check => check.Checked).Select(check => (InstanceItem)check.Tag!);
    private CheckBox? _missionUseProfiles, _missionApplyOptions, _missionUpdateConfig, _missionKeepZip, _missionOpenFolder, _missionZipOnly;
    private Button? _missionAddProfile, _missionPrepare;
    private FootholdReleaseInfo? _missionDownloadRelease;
    private IReadOnlyList<WeatherNamedProfile> _missionAvailableProfiles = [];
    private (WeatherWindow Window, int Revision)? _missionProfilesSource;
    private (string Id, string Name, string ConfigPath, string? MissionDirectory)[] _missionInstanceSnapshot = [];
    private (int Width, int Zoom, bool Dark)? _missionDownloadAppearance;
    private (int Zoom, bool Dark)? _missionInputAppearance;
    private readonly HashSet<Control> _missionStyledInputs = new();
    private bool _missionPresentationUpdating;
    private readonly Dictionary<long, CheckBox> _missionAssetChecks = new();
    private readonly List<ComboBox> _missionProfileChoices = new();
    private bool _missionDownloadsRendering, _missionDownloadsArranging;
    private int _missionNextProfileId;
    private readonly Dictionary<(float Points, FontStyle Style), Font> _missionPresentationFonts = new();
    private bool _missionCustomFolderEnabled;
    private string? _missionCustomOutputFolder, _missionCustomOutputError;
    private CheckBox? _missionDownloadCustomFolder, _missionFilesCustomFolder;
    private Button? _missionDownloadChooseOutputFolder, _missionFilesChooseOutputFolder;
    private Label? _missionDownloadCustomOutputPath, _missionFilesCustomOutputPath;

    private void LoadCustomMissionOutputFolder()
    {
        try { _missionCustomOutputFolder = MissionOutputFolderStore.Load(); }
        catch (Exception error) when (error is IOException or InvalidDataException or UnauthorizedAccessException or ArgumentException or NotSupportedException or System.Text.Json.JsonException)
        { _missionCustomOutputError = "Could not load the custom output folder: " + error.Message; }
    }

    private string? CaptureCustomMissionOutputDirectory()
    {
        if (!_missionCustomFolderEnabled) return null;
        if (_missionCustomOutputError is { } error) throw new InvalidDataException(error);
        return _missionCustomOutputFolder ?? throw new InvalidDataException(
            "Choose a Custom Folder before creating missions.");
    }

    private void ApplyCustomMissionOutputFolder(string folder)
    {
        if (_missionDownloadBusy) throw new InvalidOperationException("Wait for the current mission operation to finish before changing its output folder.");
        _missionCustomOutputFolder = MissionOutputFolderStore.Save(folder);
        _missionCustomOutputError = null;
        RefreshCustomMissionOutputControls();
    }

    private void ChooseCustomMissionOutputFolder()
    {
        if (_missionDownloadBusy) return;
        using var dialog = new FolderBrowserDialog { Description = "Choose where to save new mission copies",
            SelectedPath = _missionCustomOutputFolder ?? RuntimeSettings.GetBestInitialDirectory() };
        if (dialog.ShowDialog(this) != DialogResult.OK) return;
        try { ApplyCustomMissionOutputFolder(dialog.SelectedPath); }
        catch (Exception error) when (error is IOException or InvalidDataException or UnauthorizedAccessException or ArgumentException or NotSupportedException)
        {
            _missionCustomOutputError = "Could not remember the custom output folder: " + error.Message;
            RefreshCustomMissionOutputControls();
        }
    }

    private void SetCustomMissionOutputMode(bool enabled)
    {
        if (_missionCustomFolderEnabled == enabled) return;
        if (!_missionDownloadBusy) _missionCustomFolderEnabled = enabled;
        RefreshCustomMissionOutputControls();
        RefreshServerRegistrationChoices();
    }

    private void RefreshCustomMissionOutputControls()
    {
        if (_missionDownloadCustomFolder is null && _missionFilesCustomFolder is null) return;
        UpdateMissionDownloadPresentation(() =>
        {
            _missionFilesCard?.SuspendLayout();
            try
            {
                foreach (var (check, path, choose) in new[] {
                    (_missionDownloadCustomFolder, _missionDownloadCustomOutputPath, _missionDownloadChooseOutputFolder),
                    (_missionFilesCustomFolder, _missionFilesCustomOutputPath, _missionFilesChooseOutputFolder) })
                {
                    if (check is null) continue;
                    check.Checked = _missionCustomFolderEnabled;
                    check.Enabled = !_missionDownloadBusy;
                    path!.Text = _missionCustomOutputError ?? _missionCustomOutputFolder ?? "Choose a folder for the new mission copies.";
                    path.Visible = _missionCustomFolderEnabled || _missionCustomOutputError is not null;
                    choose!.Visible = _missionCustomFolderEnabled;
                    choose.Enabled = !_missionDownloadBusy;
                }
            }
            finally { _missionFilesCard?.ResumeLayout(true); }
        });
        RefreshMissionDownloadSelection();
    }

    private const float MissionPageLabelScale = .72f;

    private Font MissionPresentationFont(float multiplier, FontStyle style)
    {
        var points = ConfigCellValueFont.Size * multiplier;
        if (!_missionPresentationFonts.TryGetValue((points, style), out var font))
            _missionPresentationFonts.Add((points, style), font = new Font(ConfigCellValueFont.FontFamily, points, style));
        return font;
    }

    private void SizeMissionBackButton(Button button) =>
        SizeNavigationButton(button, MissionPresentationFont(1f, FontStyle.Regular), _uiZoomPercent / 100f);

    private async Task OpenMissionDownloadsAsync(FootholdReleaseInfo release)
    {
        RefreshMissionCompletionState();
        if (_configLoadingOperation || _missionDownloadBusy || _updatesInstalling) return;
        await RefreshDedicatedRegistrationTargetsAsync();
        if (_updatesDisposed || IsDisposed || Disposing || _configLoadingOperation || _missionDownloadBusy || _updatesInstalling) return;
        if (_missionDownloadsPanel is not null)
        {
            ShowMissionDownloads(release);
            await EnsureMissionWarehouseSourcesAsync();
            return;
        }
        await RunConfigLoadingAsync((progress, token) =>
        {
            token.ThrowIfCancellationRequested();
            progress.Report(new LoadingProgress("Loading release…"));
            ShowMissionDownloads(release);
            return Task.CompletedTask;
        }, _updatesLifetime.Token, "Loading release…", errorTitle: "Download missions");
        if (!IsDisposed && !Disposing) RefreshMissionReleaseActions();
        await EnsureMissionWarehouseSourcesAsync();
    }

    private bool IsMissionReleaseRefreshCurrent(object context, FootholdReleaseInfo displayed) =>
        ReferenceEquals(_missionReleaseRefreshContext, context) && ReferenceEquals(_missionDownloadRelease, displayed);

    private async Task RefreshMissionDownloadReleaseAsync()
    {
        if (_updatesBusy || _missionDownloadBusy || _updatesInstalling || _configLoadingOperation || IsDisposed || Disposing
            || _missionDownloadsPanel is null || _missionDownloadRelease is not { } displayed) return;
        var page = _missionDownloadsPanel;
        var context = new object();
        _missionReleaseRefreshContext = context;
        try
        {
            await CheckForUpdatesAsync(force: true);
            if (IsDisposed || Disposing || !ReferenceEquals(page, _missionDownloadsPanel) || !IsMissionReleaseRefreshCurrent(context, displayed)
                || _updatesBusy || _missionDownloadBusy || _updatesInstalling || _configLoadingOperation || !page.Visible
                || _updatesContent?.Visible != false) return;
            if (_updatesResult?.Foothold.Data is { AssetMetadataLoaded: true, Assets.Count: > 0 } release)
            {
                ShowMissionDownloads(release);
                await EnsureMissionWarehouseSourcesAsync();
            }
        }
        finally
        {
            if (ReferenceEquals(_missionReleaseRefreshContext, context)) _missionReleaseRefreshContext = null;
            if (!IsDisposed && !Disposing) RefreshMissionReleaseActions();
        }
    }

    private void RefreshMissionReleaseActions()
    {
        if (_missionRefreshRelease is null) return;
        var idle = !_updatesBusy && !_missionDownloadBusy && !_updatesInstalling && !_configLoadingOperation;
        _missionRefreshRelease.Text = _updatesBusy ? "Refreshing…" : "Refresh release";
        _missionRefreshRelease.Enabled = idle && _missionDownloadRelease is not null;
        _missionChangelog!.Enabled = idle && _missionDownloadRelease is not null;
        _missionReleaseStatus!.Text = _updatesBusy ? "Checking GitHub…" : _updatesError
            ?? (_updatesResult is { } result ? FeedDetail(result.Foothold, "Release information is up to date.") : "");
    }
    private void UpdateMissionDownloadPresentation(Action change)
    {
        if (_missionPresentationUpdating) { change(); return; }
        _missionPresentationUpdating = true;
        var host = _updatesPanel!;
        var layouts = new Control?[] { host, _missionDownloadsPanel, _missionDownloadPage,
            _missionDownloadLayout, _missionDownloadLeft, _missionAssetRows, _missionDownloadRightColumn, _missionDownloadRight,
            _missionProfileRows, _missionTargets,
            _missionWarehouseRows?.Parent, _missionWarehouseRows }.Concat(_missionWarehouseSourceRows.Values).ToArray();
        var downloadVisible = _missionDownloadsPanel?.Visible == true;
        var scrollPosition = _missionDownloadsPanel?.AutoScrollPosition;
        var appearance = _missionDownloadAppearance;
        var deferPainting = host.IsHandleCreated && host.Visible;
        var previousCardBounds = deferPainting && downloadVisible && _missionDownloadRight is { IsHandleCreated: true }
            ? _missionDownloadsPanel!.RectangleToClient(_missionDownloadRight.RectangleToScreen(_missionDownloadRight.ClientRectangle))
            : Rectangle.Empty;
        if (deferPainting) SendZoomRedrawMessage(host.Handle, 0x000B, IntPtr.Zero, IntPtr.Zero);
        foreach (var layout in layouts) layout?.SuspendLayout();
        try { change(); }
        finally
        {
            try { foreach (var layout in layouts.Reverse()) layout?.ResumeLayout(true); }
            finally
            {
                _missionPresentationUpdating = false;
                if (deferPainting && host.IsHandleCreated)
                {
                    SendZoomRedrawMessage(host.Handle, 0x000B, new IntPtr(1), IntPtr.Zero);
                    if (downloadVisible && _missionDownloadsPanel!.Visible
                        && scrollPosition == _missionDownloadsPanel.AutoScrollPosition && appearance == _missionDownloadAppearance)
                    {
                        host.Invalidate(true);
                        var currentCardBounds = _missionDownloadsPanel.RectangleToClient(
                            _missionDownloadRight!.RectangleToScreen(_missionDownloadRight.ClientRectangle));
                        if (currentCardBounds != previousCardBounds) _missionDownloadRight.Invalidate(true);
                        if (!currentCardBounds.Contains(previousCardBounds))
                        {
                            using var vacated = new Region(previousCardBounds);
                            vacated.Exclude(currentCardBounds);
                            _missionDownloadsPanel.Invalidate(vacated, true);
                        }
                    }
                    else host.Invalidate(true);
                    host.Update();
                }
            }
        }
    }

    private ServerProfileSettings GetMissionDownloadFallback()
    {
        if (FindCurrentInstanceProfile() is { } saved) return saved;
        var configPath = _document?.Path ?? "";
        var id = configPath.Length == 0 ? "mission-download-folder" : RuntimeSettings.CreateStableProfileId(configPath);
        var profile = _missionDestination?.Items.Cast<InstanceItem>().Select(item => item.Profile).FirstOrDefault(item => item.Id == id)
            ?? new ServerProfileSettings { Id = id, Name = configPath.Length == 0 ? "Custom folder" : GuessInstanceName(configPath) };
        profile.ConfigPath = configPath;
        return profile;
    }

    private void ShowMissionDownloads(FootholdReleaseInfo release)
    {
        if (_mainSplit is null) return;
        _missionReleaseRefreshContext = null;
        if (_weatherWindow is { Visible: true })
        {
            _weatherWindow.LeaveWeather();
            if (_weatherWindow.Visible) return;
        }
        if (_updatesPanel is null) BuildUpdatesPanel();
        var contentChanged = _missionDownloadsPanel is null;
        if (_missionDownloadsPanel is null) BuildMissionDownloads();
        EnsureWeatherWindow();
        UpdateMissionDownloadPresentation(() =>
        {
            _missionDownloadsRendering = true;
            try
            {
                var profileSource = (_weatherWindow!, _weatherWindow!.NamedProfilesRevision);
                IReadOnlyList<ServerProfileSettings> profiles = _settings.ServerProfiles.Count == 0
                    ? new[] { GetMissionDownloadFallback() } : _settings.ServerProfiles;
                var instances = profiles.Select(profile => (profile.Id, profile.Name, profile.ConfigPath, profile.MissionDirectory)).ToArray();
                if (contentChanged || !_missionInstanceSnapshot.SequenceEqual(instances))
                {
                    ApplyMissionInstanceSnapshot(profiles, instances);
                    contentChanged = true;
                }
                if (_missionProfilesSource != profileSource) ApplyMissionProfileSnapshot(profileSource);
                if (_missionDownloadRelease is null || _missionDownloadRelease.Id != release.Id || _missionDownloadRelease.Tag != release.Tag
                    || !_missionDownloadRelease.Assets.SequenceEqual(release.Assets))
                {
                    var retained = _missionAssetChecks.Values.Where(c => c.Checked).Select(c => (MissionReleaseAsset)c.Tag!).ToHashSet();
                    foreach (var check in _missionAssetChecks.Values) check.Dispose();
                    _missionAssetChecks.Clear();
                    _missionAssetRows!.RowStyles.Clear();
                    _missionAssetRows.RowCount = 0;
                    _missionDownloadRelease = release with { Assets = Array.AsReadOnly(release.Assets.ToArray()) };
                    _missionMapProgressContext = null;
                    _missionDownloadSubtitle!.Text = "Full mission download • Foothold " + release.Tag.TrimStart('v', 'V');
                    foreach (var asset in _missionDownloadRelease.Assets)
                    {
                        var caption = MissionAssetCaption(asset);
                        var mapTitle = MissionMapTitle(asset, caption.Title);
                        var check = new MissionMapCheckBox { Name = "MissionAsset-" + asset.Id, Text = mapTitle,
                            Eras = caption.Eras, SizeText = (asset.Size / (asset.Size < 1048576 ? 1024d : 1048576d))
                                .ToString("0.0", System.Globalization.CultureInfo.InvariantCulture) + (asset.Size < 1048576 ? " KB" : " MB"),
                            Tag = asset, Checked = retained.Contains(asset), AutoSize = true, Dock = DockStyle.Top,
                            AccessibleName = mapTitle, AccessibleDescription = asset.Name };
                        check.CheckedChanged += (_, _) => RefreshMissionDownloadSelection();
                        _missionAssetChecks.Add(asset.Id, check);
                        _missionAssetRows!.RowStyles.Add(new RowStyle(SizeType.AutoSize));
                        _missionAssetRows.Controls.Add(check, 0, _missionAssetRows.RowCount++);
                    }
                    var removed = _missionWarehouseSourceRows.Keys.Where(id => !_missionAssetChecks.TryGetValue(id, out var check)
                        || (MissionReleaseAsset)_missionWarehouseSourceRows[id].Tag! != (MissionReleaseAsset)check.Tag!).ToArray();
                    foreach (var id in removed)
                    {
                        if (_missionAssetChecks.ContainsKey(id))
                            foreach (var selections in _missionWarehouseSelections.Values) selections.Remove(id);
                        _missionStyledInputs.Remove(_missionWarehouseChoices[id]);
                        _missionWarehouseRows!.Controls.Remove(_missionWarehouseSourceRows[id]);
                        _missionWarehouseSourceRows[id].Dispose();
                        _missionWarehouseSourceRows.Remove(id);
                        _missionWarehouseChoices.Remove(id);
                        _missionWarehouseSourceDetails.Remove(id);
                        _missionWarehousePopulatedFolders.Remove(id);
                    }
                    if (removed.Length > 0)
                    {
                        _missionWarehouseRows!.RowStyles.Clear();
                        _missionWarehouseRows.RowCount = 0;
                        foreach (var row in _missionWarehouseSourceRows.Values)
                        {
                            _missionWarehouseRows.RowStyles.Add(new RowStyle(SizeType.AutoSize));
                            _missionWarehouseRows.SetCellPosition(row, new TableLayoutPanelCellPosition(0, _missionWarehouseRows.RowCount++));
                        }
                    }
                    _missionZipNames!.Text = string.Join(Environment.NewLine, _missionDownloadRelease.Assets.Select(asset => asset.Name));
                    contentChanged = true;
                }
            }
            finally { _missionDownloadsRendering = false; }
            _updatesPanel!.AutoScroll = false;
            _updatesContent!.Hide();
            _updatesPanel.Show();
            _missionDownloadsPanel!.Bounds = _updatesPanel.ClientRectangle;
            _missionDownloadsPanel.Show();
            _missionDownloadsPanel.BringToFront();
            _updatesPanel.BringToFront();
            RefreshMissionDownloadSelection();
            if (contentChanged || _missionDownloadAppearance != (_missionDownloadsPanel.Width, _uiZoomPercent, _darkMode))
                LayoutMissionDownloads();
        });
    }

    private void ApplyMissionInstanceSnapshot(IReadOnlyList<ServerProfileSettings> profiles,
        (string Id, string Name, string ConfigPath, string? MissionDirectory)[] instances)
    {
        var selected = (_missionDestination!.SelectedItem as InstanceItem)?.Profile.Id;
        var checkedTargets = SelectedMissionConfigTargets.Select(i => i.Profile.Id).ToHashSet();
        _missionDestination.Items.Clear();
        foreach (var check in _missionTargetChecks) check.Dispose();
        _missionTargetChecks.Clear();
        _missionTargets!.Controls.Clear();
        _missionTargets.RowStyles.Clear();
        _missionTargets.RowCount = 0;
        foreach (var profile in profiles)
        {
            var item = new InstanceItem(profile);
            _missionDestination.Items.Add(item);
            if (profile.ConfigPath.Length > 0) AddMissionConfigTarget(item, checkedTargets.Contains(profile.Id));
        }
        _missionDestination.SelectedItem = _missionDestination.Items.Cast<InstanceItem>()
            .FirstOrDefault(i => i.Profile.Id == selected) ?? _missionDestination.Items.Cast<InstanceItem>()
            .FirstOrDefault(i => PathsEqual(i.Profile.ConfigPath, _document?.Path ?? "")) ?? _missionDestination.Items.Cast<object>().FirstOrDefault();
        if (!_missionTargetsManual) ApplyAutomaticMissionConfigTarget();
        if (selected is not null && (_missionDestination.SelectedItem as InstanceItem)?.Profile.Id != selected)
            _missionCopyWarehouses!.Checked = false;
        _missionInstanceSnapshot = instances;
        _missionDownloadAppearance = null;
    }

    private void RefreshCachedMissionInstances()
    {
        var headerGeneration = _missionConfigHeaderGeneration;
        ReconcileMissionConfigHeaderInputs();
        if (headerGeneration == _missionConfigHeaderGeneration) RefreshUpdatesPresentation();
        if (_missionDownloadsPanel is null || IsDisposed || Disposing) return;
        IReadOnlyList<ServerProfileSettings> profiles = _settings.ServerProfiles.Count == 0
            ? new[] { GetMissionDownloadFallback() } : _settings.ServerProfiles;
        var instances = profiles.Select(profile => (profile.Id, profile.Name, profile.ConfigPath, profile.MissionDirectory)).ToArray();
        if (_missionInstanceSnapshot.SequenceEqual(instances)) return;
        UpdateMissionDownloadPresentation(() =>
        {
            _missionDownloadsRendering = true;
            try { ApplyMissionInstanceSnapshot(profiles, instances); }
            finally { _missionDownloadsRendering = false; }
            RefreshMissionDownloadSelection();
            if (_missionDownloadsPanel.Visible) LayoutMissionDownloads();
        });
    }

    private void ApplyMissionProfileSnapshot((WeatherWindow Window, int Revision) source)
    {
        _missionAvailableProfiles = source.Window.CaptureNamedProfiles();
        foreach (var box in _missionProfileChoices)
        {
            PopulateMissionProfileChoice(box);
            box.Parent!.Controls.OfType<Label>().Single().Text = box.SelectedItem is WeatherNamedProfile profile
                ? MissionProfileSummary(profile) : "Choose a saved profile.";
        }
        _missionProfilesSource = source;
    }

    private void RefreshCachedMissionProfiles()
    {
        if (_missionDownloadsPanel is null || IsDisposed || Disposing) return;
        var source = (_weatherWindow!, _weatherWindow!.NamedProfilesRevision);
        if (_missionProfilesSource == source) return;
        UpdateMissionDownloadPresentation(() =>
        {
            _missionDownloadsRendering = true;
            try { ApplyMissionProfileSnapshot(source); }
            finally { _missionDownloadsRendering = false; }
            RefreshMissionDownloadSelection();
        });
    }

    private static string MissionMapTitle(MissionReleaseAsset asset, string title)
    {
        if (title == asset.Name) return title;
        var versions = Path.GetFileNameWithoutExtension(asset.Name).Split('_')
            .Select(part => part.StartsWith('v') || part.StartsWith('V') ? part[1..] : part)
            .Where(part => ManagerBuildInfo.TryParseReleaseVersion(part, out _)).ToArray();
        return versions.Length == 1 ? title + " " + versions[0] : title;
    }

    private static (string Title, string Eras) MissionAssetCaption(MissionReleaseAsset asset)
    {
        var title = MissionWarehouseService.GetMapVariant(asset.Name) ?? asset.Name;
        var eras = new[] { ("Coldwar", "Cold War"), ("Gulfwar", "Gulf War"), ("Modern", "Modern"), ("Vietnam", "Vietnam"), ("WWII", "WWII") }
            .Where(pair => asset.Name.Contains(pair.Item1, StringComparison.OrdinalIgnoreCase)).Select(pair => pair.Item2);
        var description = string.Join(" · ", eras);
        return (title, description.Length == 0 ? "ZIP from this release" : description);
    }

    private sealed class MissionMapCheckBox : CheckBox
    {
        internal string Eras { get; init; } = "";
        internal string SizeText { get; init; } = "";
        internal string CompletionText { get; set; } = "";
        internal Font? TitleFont { get; set; }
        internal Font? DetailFont { get; set; }

        internal MissionMapCheckBox() =>
            SetStyle(ControlStyles.UserPaint | ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw, true);

        protected override void OnCheckedChanged(EventArgs e) { base.OnCheckedChanged(e); Invalidate(); }

        protected override void OnPaint(PaintEventArgs e)
        {
            var background = Checked ? SelectionBackground : MainBackground;
            e.Graphics.Clear(background);
            var state = Enabled
                ? Checked ? System.Windows.Forms.VisualStyles.CheckBoxState.CheckedNormal : System.Windows.Forms.VisualStyles.CheckBoxState.UncheckedNormal
                : Checked ? System.Windows.Forms.VisualStyles.CheckBoxState.CheckedDisabled : System.Windows.Forms.VisualStyles.CheckBoxState.UncheckedDisabled;
            var glyph = CheckBoxRenderer.GetGlyphSize(e.Graphics, state);
            var padding = Math.Max(8, Font.Height / 2);
            CheckBoxRenderer.DrawCheckBox(e.Graphics, new Point(padding, (Height - glyph.Height) / 2), state);
            var titleFont = TitleFont ?? Font;
            var detailFont = DetailFont ?? Font;
            var sizeWidth = TextRenderer.MeasureText(SizeText, detailFont).Width + padding;
            var x = padding * 2 + glyph.Width;
            var textWidth = Math.Max(1, Width - x - sizeWidth - padding);
            var top = Math.Max(0, (Height - titleFont.Height - detailFont.Height * (CompletionText.Length == 0 ? 1 : 2) - 2) / 2);
            var textColor = Checked ? SelectionText : PrimaryTextColor;
            TextRenderer.DrawText(e.Graphics, Text, titleFont, new Rectangle(x, top, textWidth, titleFont.Height),
                textColor, TextFormatFlags.SingleLine | TextFormatFlags.EndEllipsis | TextFormatFlags.NoPrefix);
            TextRenderer.DrawText(e.Graphics, Eras, detailFont, new Rectangle(x, top + titleFont.Height + 2, textWidth, detailFont.Height),
                Checked ? SelectionText : HelpTextColor, TextFormatFlags.SingleLine | TextFormatFlags.EndEllipsis | TextFormatFlags.NoPrefix);
            if (CompletionText.Length > 0)
                TextRenderer.DrawText(e.Graphics, "✓ " + CompletionText, detailFont,
                    new Rectangle(x, top + titleFont.Height + detailFont.Height + 4, textWidth, detailFont.Height),
                    SystemInformation.HighContrast ? textColor : IsDarkPalette() ? Color.FromArgb(148, 213, 180) : Color.FromArgb(25, 113, 77), TextFormatFlags.SingleLine | TextFormatFlags.EndEllipsis | TextFormatFlags.NoPrefix);
            TextRenderer.DrawText(e.Graphics, SizeText, detailFont, new Rectangle(Width - sizeWidth - padding, 0, sizeWidth, Height),
                Checked ? SelectionText : HelpTextColor, TextFormatFlags.Right | TextFormatFlags.VerticalCenter | TextFormatFlags.SingleLine);
            using var border = new Pen(BorderColor);
            e.Graphics.DrawLine(border, 0, Height - 1, Width, Height - 1);
            if (Focused && ShowFocusCues) ControlPaint.DrawFocusRectangle(e.Graphics, Rectangle.Inflate(ClientRectangle, -2, -2), textColor, background);
        }
    }

    private sealed class MissionDownloadSurface : Panel
    {
        internal MissionDownloadSurface() => DoubleBuffered = true;
        protected override CreateParams CreateParams
        {
            get { var parameters = base.CreateParams; parameters.ExStyle |= 0x02000000; return parameters; }
        }
    }

    private void AddMissionConfigTarget(InstanceItem item, bool selected)
    {
        var check = new WeatherCheckBox { Name = "MissionDownloadTarget-" + item.Profile.Id, Text = item.Profile.Name,
            Tag = item, Checked = selected, AutoSize = true, Dock = DockStyle.Top, DisabledTextColor = HelpTextColor };
        check.CheckedChanged += (_, _) =>
        {
            if (_missionDownloadsRendering) return;
            _missionTargetsManual = true;
            RefreshMissionDownloadSelection();
        };
        _missionTargetChecks.Add(check);
        _missionTargets!.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        _missionTargets.Controls.Add(check, 0, _missionTargets.RowCount++);
    }

    private void ApplyAutomaticMissionConfigTarget()
    {
        var destination = _missionDestination!.SelectedItem as InstanceItem;
        foreach (var check in _missionTargetChecks)
            check.Checked = ReferenceEquals(check.Tag, destination);
    }

    private void BuildMissionDownloads()
    {
        _missionDownloadsPanel = new MissionDownloadSurface { Name = "MissionDownloadsPanel", Dock = DockStyle.Fill, AutoScroll = true, Visible = false };
        _missionDownloadsPanel.Disposed += (_, _) =>
        {
            foreach (var font in _missionPresentationFonts.Values) font.Dispose();
            _missionPresentationFonts.Clear();
            _missionStyledInputs.Clear();
        };
        _missionDownloadLayout = new TableLayoutPanel { Name = "MissionDownloadColumns", Dock = DockStyle.Top,
            AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink, ColumnCount = 2, RowCount = 1 };
        _missionDownloadLayout.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 60));
        _missionDownloadLayout.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 40));
        _missionDownloadLeft = Column(); _missionDownloadRight = Column();
        _missionDownloadRight.Name = "MissionDownloadDestinationCard";
        _missionDownloadRight.Paint += (_, e) =>
        {
            if (_missionDownloadRight.Width < 2 || _missionDownloadRight.Height < 2) return;
            using var border = new Pen(BorderColor);
            e.Graphics.DrawRectangle(border, 0, 0, _missionDownloadRight.Width - 1, _missionDownloadRight.Height - 1);
        };
        _missionDownloadRightColumn = Column();
        _missionDownloadRightColumn.Name = "MissionDownloadDestinationColumn";
        Add(_missionDownloadRightColumn, _missionDownloadRight);
        _missionDownloadLayout.Controls.Add(_missionDownloadLeft, 0, 0);
        _missionDownloadLayout.Controls.Add(_missionDownloadRightColumn, 1, 0);
        _missionDownloadPage = Column();
        _missionDownloadPage.Dock = DockStyle.None;
        _missionDownloadPage.Name = "MissionDownloadPage";
        _missionDownloadsPanel.Controls.Add(_missionDownloadPage);
        _updatesPanel!.Controls.Add(_missionDownloadsPanel);
        EnsureMissionDownloadLifetime();
        _missionDownloadsPanel.SizeChanged += (_, _) =>
        {
            if (_missionDownloadsPanel.Visible && _missionDownloadAppearance != (_missionDownloadsPanel.Width, _uiZoomPercent, _darkMode))
            {
                LayoutMissionDownloads();
                if (_missionDownloadsPanel.IsHandleCreated)
                    _missionDownloadsPanel.BeginInvoke((Action)(() =>
                    {
                        if (!_missionDownloadsPanel.IsDisposed && !_missionDownloadsPanel.Disposing && _missionDownloadsPanel.Visible)
                            _missionDownloadsPanel.PerformLayout();
                    }));
            }
        };
        _missionDownloadsPanel.FontChanged += (_, _) => LayoutMissionDownloads();
        _missionDownloadsPanel.BackColorChanged += (_, _) => LayoutMissionDownloads();
        var title = Heading("Download missions");
        title.Name = "MissionDownloadTitle";
        var header = new TableLayoutPanel { Name = "MissionDownloadHeader", Dock = DockStyle.Top, AutoSize = true, ColumnCount = 2, RowCount = 3 };
        header.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        header.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        header.Controls.Add(title, 0, 0);
        header.SetColumnSpan(title, 2);
        var back = MakeButton("Back to Updates", () =>
        {
            UpdateMissionDownloadPresentation(() =>
            {
                _missionReleaseRefreshContext = null;
                PrepareUpdatesReveal();
                _missionDownloadsPanel.Hide();
                _updatesPanel!.AutoScroll = true;
                _updatesContent!.Show();
            });
        });
        back.Name = "MissionDownloadBack";
        back.Dock = DockStyle.None;
        back.Anchor = AnchorStyles.Top | AnchorStyles.Right;
        header.Controls.Add(back, 1, 2);
        Add(_missionDownloadPage, header);
        _missionDownloadSubtitle = Heading("Full mission download");
        _missionDownloadSubtitle.Name = "MissionDownloadSubtitle";
        header.Controls.Add(_missionDownloadSubtitle, 0, 1);
        header.SetColumnSpan(_missionDownloadSubtitle, 2);
        header.Controls.Add(Text("Choose your maps and where they should be installed."), 0, 2);
        Add(_missionDownloadPage, _missionDownloadLayout);
        Add(_missionDownloadLeft, Heading("Maps in this release"));
        Add(_missionDownloadLeft, Text("From the ZIPs attached to the GitHub release"));
        _missionSelectionActions = new TableLayoutPanel { Name = "MissionDownloadSelectionActions", AutoSize = true, Dock = DockStyle.Top, ColumnCount = 2, RowCount = 2 };
        _missionSelectionActions.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        _missionSelectionActions.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        _missionSelectionActions.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        _missionSelectionActions.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        _missionSelectionLinks = new FlowLayoutPanel { AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink, WrapContents = false };
        var remaining = MakeButton("Select remaining", SelectRemainingMissionMaps);
        remaining.Name = "MissionDownloadSelectRemaining";
        _missionSelectionLinks.Controls.Add(remaining);
        _missionSelectionLinks.Controls.Add(MakeButton("Select all", () => SelectMissionMaps(true)));
        _missionSelectionLinks.Controls.Add(MakeButton("Clear", () => SelectMissionMaps(false)));
        _missionReleaseActions = new FlowLayoutPanel { Name = "MissionDownloadReleaseActions", AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink,
            WrapContents = false, Anchor = AnchorStyles.Top | AnchorStyles.Right };
        _missionRefreshRelease = MakeButton("Refresh release", () => _ = RefreshMissionDownloadReleaseAsync());
        _missionRefreshRelease.Name = "MissionDownloadRefreshRelease";
        _missionChangelog = MakeButton("Changelog", () => _ = OpenFootholdReleaseAsync(_missionDownloadRelease!));
        _missionChangelog.Name = "MissionDownloadChangelog";
        _missionReleaseActions.Controls.Add(_missionRefreshRelease);
        _missionReleaseActions.Controls.Add(_missionChangelog);
        _missionSelectionActions.Controls.Add(_missionSelectionLinks, 0, 0);
        _missionSelectionActions.Controls.Add(_missionReleaseActions, 1, 0);
        Add(_missionDownloadLeft, _missionSelectionActions);
        _missionReleaseStatus = Text("");
        _missionReleaseStatus.Name = "MissionDownloadReleaseStatus";
        Add(_missionDownloadLeft, _missionReleaseStatus);
        _missionMapProgressSummary = Text("");
        _missionMapProgressSummary.Name = "MissionDownloadMapProgress";
        Add(_missionDownloadLeft, _missionMapProgressSummary);
        _missionAssetRows = Column();
        _missionRemainingMaps = Heading("Remaining to update");
        _missionRemainingMaps.Name = "MissionDownloadRemainingMaps";
        _missionCompletedMaps = Heading("Already updated");
        _missionCompletedMaps.Name = "MissionDownloadCompletedMaps";
        _missionCompletedMaps.Visible = false;
        _missionCompletedHint = Text("Current-release copies were found or created for this instance. You can still download the full mission.");
        _missionCompletedHint.Name = "MissionDownloadCompletedHint";
        _missionCompletedHint.Visible = false;
        Add(_missionAssetRows, _missionRemainingMaps);
        Add(_missionAssetRows, _missionCompletedMaps);
        Add(_missionAssetRows, _missionCompletedHint);
        Add(_missionDownloadLeft, _missionAssetRows);
        _missionZipNames = Text("");
        _missionZipNames.Name = "MissionDownloadZipNames";
        _missionZipNames.Visible = false;
        _missionZipToggle = MakeButton("▸ Show release ZIP filenames", () =>
        {
            _missionZipNames.Visible = !_missionZipNames.Visible;
            _missionZipToggle!.Text = (_missionZipNames.Visible ? "▾ Hide" : "▸ Show") + " release ZIP filenames";
        });
        _missionZipToggle.Name = "MissionDownloadZipToggle";
        _missionZipToggle.Dock = DockStyle.None;
        Add(_missionDownloadLeft, _missionZipToggle);
        Add(_missionDownloadLeft, _missionZipNames);
        Add(_missionDownloadRight, Heading("Destination"));
        Add(_missionDownloadRight, Text("Install to instance"));
        _missionDestination = Choice("MissionDownloadInstance");
        _missionDestination.SelectedIndexChanged += async (_, _) =>
        {
            if (_missionDownloadsRendering) return;
            _missionDownloadsRendering = true;
            try
            {
                _missionCopyWarehouses!.Checked = false;
                if (!_missionTargetsManual) ApplyAutomaticMissionConfigTarget();
            }
            finally { _missionDownloadsRendering = false; }
            RefreshMissionDownloadSelection();
            await RefreshDedicatedRegistrationTargetsAsync();
            await EnsureMissionWarehouseSourcesAsync();
        };
        Add(_missionDownloadRight, _missionDestination);
        var folder = Column();
        Add(folder, Text("Mission folder"));
        _missionDirectory = Text(""); _missionDirectory.Name = "MissionDownloadDirectory";
        _missionDirectory.Paint += (_, e) =>
        {
            if (_missionDirectory.Width < 2 || _missionDirectory.Height < 2) return;
            using var border = new Pen(BorderColor);
            e.Graphics.DrawRectangle(border, 0, 0, _missionDirectory.Width - 1, _missionDirectory.Height - 1);
        };
        Add(folder, _missionDirectory);
        var change = MakeButton("Change folder…", () =>
        {
            var destination = (_missionDestination.SelectedItem as InstanceItem)?.Profile ?? GetMissionDownloadFallback();
            using var dialog = new FolderBrowserDialog { Description = "Choose this instance's mission destination",
                SelectedPath = RuntimeSettings.ResolveMissionsDirectory(destination) ?? RuntimeSettings.GetBestInitialDirectory() };
            if (dialog.ShowDialog(this) != DialogResult.OK) return;
            ApplyMissionDownloadFolder(destination, dialog.SelectedPath);
        });
        change.Click += async (_, _) => { await RefreshDedicatedRegistrationTargetsAsync(); await EnsureMissionWarehouseSourcesAsync(); };
        change.Name = "MissionDownloadChangeFolder";
        change.Dock = DockStyle.None;
        var folderActions = new FlowLayoutPanel { Name = "MissionDownloadFolderActions", AutoSize = true,
            AutoSizeMode = AutoSizeMode.GrowAndShrink, Dock = DockStyle.Top, WrapContents = true };
        folderActions.Controls.Add(change);
        _missionDownloadOpenFolder = MakeButton("Open folder", () =>
        {
            if (_missionDownloadOpenFolder!.Tag is string directory) OpenMissionDownloadFolder(directory);
        });
        _missionDownloadOpenFolder.Name = "MissionDownloadOpenFolder";
        _missionDownloadOpenFolder.Enabled = false;
        folderActions.Controls.Add(_missionDownloadOpenFolder);
        Add(folder, folderActions);
        _missionDownloadCustomFolder = new WeatherCheckBox { Name = "MissionDownloadCustomFolder", Text = "Custom Folder",
            AutoSize = true, Dock = DockStyle.Top, DisabledTextColor = HelpTextColor };
        _missionDownloadCustomFolder.CheckedChanged += (_, _) => SetCustomMissionOutputMode(_missionDownloadCustomFolder!.Checked);
        Add(folder, _missionDownloadCustomFolder);
        _missionDownloadCustomOutputPath = Text("");
        _missionDownloadCustomOutputPath.Name = "MissionDownloadCustomOutputPath";
        Add(folder, _missionDownloadCustomOutputPath);
        _missionDownloadChooseOutputFolder = MakeButton("Choose Folder…", ChooseCustomMissionOutputFolder);
        _missionDownloadChooseOutputFolder.Name = "MissionDownloadChooseOutputFolder";
        _missionDownloadChooseOutputFolder.Click += async (_, _) => await RefreshDedicatedRegistrationTargetsAsync();
        _missionDownloadChooseOutputFolder.Dock = DockStyle.None;
        Add(folder, _missionDownloadChooseOutputFolder);
        Add(_missionDownloadRight, Separator());
        _missionUseProfiles = Check("MissionDownloadUseProfiles", "Use saved weather and time profiles", false);
        Add(_missionDownloadRight, _missionUseProfiles);
        _missionProfileHint = Text("One mission per profile · Up to 5");
        Add(_missionDownloadRight, _missionProfileHint);
        _missionProfileRows = Column();
        Add(_missionDownloadRight, _missionProfileRows);
        _missionAddProfile = MakeButton("+ Add profile", AddMissionProfileRow);
        _missionAddProfile.Name = "MissionDownloadAddProfile";
        Add(_missionDownloadRight, _missionAddProfile);
        AddMissionProfileRow();
        Add(_missionDownloadRight, Separator());
        Add(_missionDownloadRight, folder);
        var changes = Column();
        Add(changes, Heading("Changes to apply"));
        _missionApplyOptions = Check("MissionDownloadApplyOptions", "Apply current Mission options", false);
        Add(changes, _missionApplyOptions);
        _missionUpdateConfig = Check("MissionDownloadUpdateConfig", "Update Config after download", false);
        Add(changes, _missionUpdateConfig);
        Add(changes, Text("Keep each instance’s current settings"));
        _missionChooseTargets = MakeButton("▸ Config instances to update", () =>
        {
            _missionTargetsExpanded = !_missionTargetsExpanded;
            RefreshMissionDownloadSelection();
        });
        _missionChooseTargets.Name = "MissionDownloadChooseTargets";
        _missionChooseTargets.Dock = DockStyle.None;
        Add(changes, _missionChooseTargets);
        _missionTargets = new TableLayoutPanel { Name = "MissionDownloadTargets", ColumnCount = 1, Dock = DockStyle.Top,
            AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink, Margin = Padding.Empty };
        _missionTargets.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        Add(changes, _missionTargets);
        BuildMissionWarehouseControls(changes, Add);
        _missionDownloadRegisterServer = CreateServerRegistrationChoice("MissionDownloadRegisterServer");
        Add(changes, _missionDownloadRegisterServer);
        _missionDownloadServerHint = Text("");
        _missionDownloadServerHint.Name = "MissionDownloadServerHint";
        Add(changes, _missionDownloadServerHint);
        _missionFileOptionsToggle = null;
        _missionFileOptions = Column();
        Add(_missionDownloadRight, _missionFileOptions);
        _missionCollision = Choice("MissionDownloadCollision");
        _missionCollision.Items.AddRange(new object[] { "Keep both — rename the new file", "Replace only after review", "Skip existing files" });
        _missionCollision.SelectedIndex = 0;
        _missionKeepZip = Check("MissionDownloadKeepZip", "Keep downloaded ZIPs", false);
        _missionOpenFolder = Check("MissionDownloadOpenFolder", "Open the result folder when finished", false);
        _missionZipOnly = Check("MissionDownloadZipOnly", "Save ZIPs only", false);
        Add(_missionFileOptions, _missionKeepZip);
        Add(_missionDownloadRight, Separator());
        Add(_missionDownloadRight, changes);
        Add(_missionDownloadPage, Separator());
        _missionDownloadAction = new TableLayoutPanel { Name = "MissionDownloadAction", AutoSize = true,
            Dock = DockStyle.Fill, ColumnCount = 1, RowCount = 1 };
        _missionDownloadAction.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        var selectionSummary = Column();
        _missionDownloadSelectionCount = Heading("0 missions selected");
        _missionDownloadSelectionCount.Name = "MissionDownloadSelectionCount";
        Add(selectionSummary, _missionDownloadSelectionCount);
        _missionDownloadSummary = Text(""); _missionDownloadSummary.Name = "MissionDownloadSummary";
        Add(selectionSummary, _missionDownloadSummary);
        _missionDownloadAction.Controls.Add(selectionSummary, 0, 0);
        _missionPrepare = MakeButton("Download and install", () => _missionDownloadJob = RunMissionDownloadJobAsync());
        _missionPrepare.Name = "MissionDownloadPrepare";
        _missionPrepare.Enabled = false;
        _missionPrepare.AutoSize = false;
        ((PreviewButton)_missionPrepare).ActionEmphasis = true;
        Add(_missionDownloadRightColumn, _missionPrepare);
        _missionPrepare.Anchor = AnchorStyles.Top | AnchorStyles.Right;
        Add(_missionDownloadPage, _missionDownloadAction);
        _missionDownloadAction.Anchor = AnchorStyles.Left | AnchorStyles.Right | AnchorStyles.Top;
        _missionDownloadResultsToggle = MakeButton("Show installed files", () => UpdateMissionDownloadPresentation(() =>
        {
            _missionDownloadResultDetails!.Visible = !_missionDownloadResultDetails.Visible;
            _missionDownloadResultsToggle!.Text = _missionDownloadResultDetails.Visible ? "Hide installed files" : "Show installed files";
        }));
        _missionDownloadResultsToggle.Name = "MissionDownloadResultsToggle";
        _missionDownloadResultsToggle.Visible = false;
        var resultActions = new FlowLayoutPanel { Name = "MissionDownloadResultActions", AutoSize = true, Dock = DockStyle.Top, WrapContents = true };
        resultActions.Controls.Add(_missionDownloadResultsToggle);
        _missionDownloadOpenLocation = MakeButton("Open mission location", () =>
        {
            if (_missionDownloadResultFolder is { } folder) OpenMissionDownloadFolder(folder);
        });
        _missionDownloadOpenLocation.Name = "MissionDownloadOpenLocation";
        _missionDownloadOpenLocation.Enabled = false;
        _missionDownloadOpenLocation.Visible = false;
        resultActions.Controls.Add(_missionDownloadOpenLocation);
        Add(_missionDownloadPage, resultActions);
        _missionDownloadResultDetails = new Label { Name = "MissionDownloadResults", AutoSize = true, UseMnemonic = false,
            Tag = "MissionDownloadMuted", Dock = DockStyle.Top, Visible = false };
        Add(_missionDownloadPage, _missionDownloadResultDetails);
        RefreshCustomMissionOutputControls();

        static TableLayoutPanel Column()
        {
            var table = new TableLayoutPanel { Dock = DockStyle.Top, AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink, ColumnCount = 1, RowCount = 0 };
            table.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            return table;
        }
        static void Add(TableLayoutPanel column, Control control)
        {
            control.Anchor = AnchorStyles.Left | AnchorStyles.Top;
            column.RowStyles.Add(new RowStyle(SizeType.AutoSize));
            column.Controls.Add(control, 0, column.RowCount++);
        }
        static Panel Separator() => new() { Dock = DockStyle.Top, Height = 1, Tag = ToolbarSeparatorTag };
        static Label Text(string text) => new() { Text = text, AutoSize = true, Dock = DockStyle.Top,
            Tag = text is "Install to instance" or "Mission folder" or "If a file with the same name exists" ? "MissionDownloadCaption" : "MissionDownloadMuted" };
        static Label Heading(string text) => new() { Text = text, AutoSize = true, Dock = DockStyle.Top, Tag = "MissionDownloadHeading" };
        void SelectMissionMaps(bool selected)
        {
            var changed = _missionAssetChecks.Values.Where(check => check.Checked != selected).ToArray();
            UpdateMissionDownloadPresentation(() =>
            {
                _missionDownloadsRendering = true;
                try { foreach (var check in changed) check.Checked = selected; }
                finally { _missionDownloadsRendering = false; }
                RefreshMissionDownloadSelection();
            });
            foreach (var check in changed) check.Invalidate();
        }
        CheckBox Check(string name, string text, bool value)
        {
            var box = new WeatherCheckBox { Name = name, Text = text, Checked = value, AutoSize = true, Dock = DockStyle.Top, DisabledTextColor = HelpTextColor };
            box.CheckedChanged += (_, _) =>
            {
                if (_missionDownloadsRendering) return;
                if (ReferenceEquals(box, _missionUpdateConfig) && box.Checked && !_missionTargetChecks.Any(check => check.Checked))
                {
                    _missionTargetsManual = false;
                    _missionDownloadsRendering = true;
                    try { ApplyAutomaticMissionConfigTarget(); }
                    finally { _missionDownloadsRendering = false; }
                }
                RefreshMissionDownloadSelection();
            };
            return box;
        }
        static ComboBox Choice(string name) => new WeatherChoiceBox { Name = name, DropDownStyle = ComboBoxStyle.DropDownList, Dock = DockStyle.Top };
    }

    private void ApplyMissionDownloadFolder(ServerProfileSettings destination, string folder)
    {
        UpdateMissionDownloadPresentation(() =>
        {
            _missionDownloadsRendering = true;
            try
            {
                ForgetMissionWarehouseCatalog(folder);
                var previousFolder = destination.MissionDirectory;
                var folderChanged = previousFolder != folder;
                destination.MissionDirectory = folder;
                var item = _missionDestination!.Items.Cast<InstanceItem>().FirstOrDefault(candidate => ReferenceEquals(candidate.Profile, destination));
                if (item is null)
                {
                    item = new InstanceItem(destination);
                    _missionDestination.Items.Add(item);
                    if (destination.ConfigPath.Length > 0) AddMissionConfigTarget(item, _missionTargetChecks.Count == 0);
                }
                _missionDestination.SelectedItem = item;
                if (folderChanged && _settings.ServerProfiles.Contains(destination))
                {
                    try { _settings.Save(); }
                    catch { destination.MissionDirectory = previousFolder; throw; }
                }
                for (var index = 0; index < _missionInstanceSnapshot.Length; index++)
                {
                    var instance = _missionInstanceSnapshot[index];
                    if (instance.Id != destination.Id || instance.Name != destination.Name || instance.ConfigPath != destination.ConfigPath) continue;
                    _missionInstanceSnapshot[index] = (instance.Id, instance.Name, instance.ConfigPath, folder);
                    break;
                }
            }
            finally { _missionDownloadsRendering = false; }
            RefreshMissionDownloadSelection();
        });
    }

    private void AddMissionProfileRow()
    {
        if (_missionProfileChoices.Count == 5) return;
        UpdateMissionDownloadPresentation(() =>
        {
            var id = _missionNextProfileId++;
            var row = new TableLayoutPanel { Name = "MissionProfileRow-" + id, Dock = DockStyle.Top, AutoSize = true,
                AutoSizeMode = AutoSizeMode.GrowAndShrink, ColumnCount = 2, RowCount = 2 };
            row.Paint += (_, e) =>
            {
                using var border = new Pen(BorderColor);
                e.Graphics.DrawLine(border, 0, row.Height - 1, row.Width, row.Height - 1);
            };
            row.RowStyles.Add(new RowStyle(SizeType.AutoSize));
            row.RowStyles.Add(new RowStyle(SizeType.AutoSize));
            row.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            row.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
            var choice = new WeatherChoiceBox { Name = "MissionProfile-" + id, DropDownStyle = ComboBoxStyle.DropDownList, Dock = DockStyle.Fill };
            var remove = MakeButton("×", () =>
            {
                UpdateMissionDownloadPresentation(() =>
                {
                    _missionProfileChoices.Remove(choice);
                    _missionStyledInputs.Remove(choice);
                    _missionProfileRows!.Controls.Remove(row);
                    row.Dispose();
                    RefreshMissionDownloadSelection();
                });
            });
            remove.Name = "MissionDownloadRemoveProfile-" + id;
            remove.AccessibleName = "Remove profile";
            row.Controls.Add(choice, 0, 0); row.Controls.Add(remove, 1, 0);
            var summary = new Label { Name = "MissionProfileSummary-" + id, AutoSize = true, Dock = DockStyle.Top, Tag = "MissionDownloadMuted" };
            row.Controls.Add(summary, 0, 1);
            row.SetColumnSpan(summary, 2);
            _missionProfileChoices.Add(choice);
            PopulateMissionProfileChoice(choice);
            summary.Text = choice.SelectedItem is WeatherNamedProfile selected ? MissionProfileSummary(selected) : "Choose a saved profile.";
            choice.SelectedIndexChanged += (_, _) =>
            {
                summary.Text = choice.SelectedItem is WeatherNamedProfile profile ? MissionProfileSummary(profile) : "Choose a saved profile.";
                RefreshMissionDownloadSelection();
            };
            if (_missionDownloadAppearance is not null)
            {
                var contentWidth = Math.Max(1, _missionDownloadPage!.Width - _missionDownloadPage.Padding.Horizontal);
                var rightWidth = Math.Max(120, contentWidth * (_missionDownloadLayout!.ColumnCount == 1 ? 100 : 40) / 100);
                StyleMissionProfileRow(row, Math.Max(1, rightWidth - _missionDownloadRight!.Padding.Horizontal));
            }
            _missionProfileRows!.RowStyles.Add(new RowStyle(SizeType.AutoSize));
            _missionProfileRows.Controls.Add(row, 0, _missionProfileRows.RowCount++);
            RefreshMissionDownloadSelection();
        });
    }

    private static string MissionProfileSummary(WeatherNamedProfile profile)
    {
        var settings = profile.Settings;
        var weather = settings.CloudMode == "clear" ? "Clear sky" : settings.CloudMode == "preset"
            ? "Saved cloud preset" : "Custom clouds";
        var time = settings.ChangeDateTime
            ? (settings.ChangeStartTime != false ? TimeSpan.FromSeconds(settings.StartTimeSeconds).ToString(@"hh\:mm", System.Globalization.CultureInfo.InvariantCulture) : "Keep mission time")
                + " · " + (settings.ChangeMissionDate ? settings.MissionDate.ToString("d MMM yyyy", System.Globalization.CultureInfo.InvariantCulture) : "Keep mission date")
            : "Keep mission date & time";
        return weather + " · " + time;
    }

    private void PopulateMissionProfileChoice(ComboBox box)
    {
        var firstPopulation = box.Items.Count == 0;
        var name = (box.SelectedItem as WeatherNamedProfile)?.Name;
        box.Items.Clear();
        box.Items.AddRange(_missionAvailableProfiles.Cast<object>().ToArray());
        box.SelectedItem = box.Items.Cast<WeatherNamedProfile>().FirstOrDefault(p => p.Name == name)
            ?? (firstPopulation ? box.Items.Cast<object>().FirstOrDefault() : null);
    }

    private void RefreshMissionDownloadSelection()
    {
        if (_missionDownloadsRendering || _missionDirectory is null) return;
        UpdateMissionDownloadPresentation(() =>
        {
            var destination = (_missionDestination?.SelectedItem as InstanceItem)?.Profile;
            var missionDirectory = destination is null ? null : RuntimeSettings.ResolveMissionsDirectory(destination);
            var hasMissionOutput = destination is not null && (_missionCustomFolderEnabled
                ? _missionCustomOutputFolder is not null && _missionCustomOutputError is null : missionDirectory is not null);
            _missionDirectory.Text = destination is null ? "Choose a destination instance." :
                missionDirectory ?? "Choose the Missions folder for this instance.";
            if (_missionDownloadOpenFolder is not null)
            {
                _missionDownloadOpenFolder.Tag = hasMissionOutput ? _missionCustomFolderEnabled ? _missionCustomOutputFolder : missionDirectory : null;
                _missionDownloadOpenFolder.Enabled = hasMissionOutput;
            }
            RefreshMissionDownloadProgress(destination);
            RefreshServerRegistrationChoices();
            var zipOnly = _missionZipOnly?.Checked == true;
            var hasConfig = !string.IsNullOrWhiteSpace(destination?.ConfigPath ?? _document?.Path);
            if (!zipOnly && !hasConfig)
            {
                _missionDownloadsRendering = true;
                try
                {
                    if (_missionUseProfiles is not null) _missionUseProfiles.Checked = false;
                    if (_missionApplyOptions is not null) _missionApplyOptions.Checked = false;
                    if (_missionUpdateConfig is not null) _missionUpdateConfig.Checked = false;
                }
                finally { _missionDownloadsRendering = false; }
            }
            var profilesVisible = !zipOnly && hasConfig && _missionUseProfiles?.Checked == true;
            if (_missionProfileRows is not null) { _missionProfileRows.Enabled = profilesVisible; _missionProfileRows.Visible = profilesVisible; }
            if (_missionProfileHint is not null) _missionProfileHint.Visible = profilesVisible;
            if (_missionAddProfile is not null) _missionAddProfile.Visible = profilesVisible;
            if (_missionAddProfile is not null) _missionAddProfile.Enabled = !zipOnly && _missionUseProfiles?.Checked == true && _missionProfileChoices.Count < 5;
            if (_missionUseProfiles is not null) _missionUseProfiles.Enabled = !zipOnly && hasConfig;
            if (_missionApplyOptions is not null) _missionApplyOptions.Enabled = !zipOnly && hasConfig;
            if (_missionUpdateConfig is not null) _missionUpdateConfig.Enabled = !zipOnly && hasConfig;
            var showTargets = !zipOnly && hasConfig && _missionUpdateConfig?.Checked == true;
            if (_missionTargets is not null) { _missionTargets.Enabled = showTargets; _missionTargets.Visible = showTargets && _missionTargetsExpanded; }
            if (_missionChooseTargets is not null)
            {
                _missionChooseTargets.Visible = showTargets;
                _missionChooseTargets.Text = (_missionTargetsExpanded ? "▾" : "▸") + " Config instances to update (" + _missionTargetChecks.Count(check => check.Checked) + ")";
            }
            if (_missionFileOptions is not null) _missionFileOptions.Visible = _missionFileOptionsExpanded;
            if (_missionFileOptionsToggle is not null) _missionFileOptionsToggle.Text = (_missionFileOptionsExpanded ? "▾" : "▸") + " Files and download options";
            RefreshMissionWarehousePresentation();
            if (_missionPrepare is not null && (_missionCopyWarehouses?.Checked != true || zipOnly))
                _missionPrepare.Enabled = !_missionDownloadBusy && !_updatesInstalling && !_updatesBusy
                    && _missionAssetChecks.Values.Any(check => check.Checked) && (zipOnly || hasMissionOutput)
                    && (zipOnly || _missionUseProfiles?.Checked != true || _missionProfileChoices.All(choice => choice.SelectedItem is WeatherNamedProfile));
            if (_missionDownloadSummary is not null)
            {
                var selectedCount = _missionAssetChecks.Values.Count(check => check.Checked);
                var selectionUnit = zipOnly ? "ZIP" : "map";
                _missionDownloadSelectionCount!.Text = $"{selectedCount} {selectionUnit}{(selectedCount == 1 ? "" : "s")} selected";
                _missionDownloadSummary.Text = (zipOnly ? "ZIPs only; no mission installation." : _missionUseProfiles?.Checked == true
                        ? _missionProfileChoices.Count + " profile(s) per selected mission template." : "One mission per selected template.")
                    + Environment.NewLine + "If a mission filename exists, choose Overwrite, Rename, or Cancel."
                    + (!zipOnly && !hasConfig ? Environment.NewLine + "Open a Config to use saved profiles, Mission options, or Config updates." : "");
            }
            ApplyMissionWarehousePrepareGate();
            RefreshMissionReleaseActions();
        });
    }

    private void StyleMissionProfileRow(TableLayoutPanel row, int columnWidth)
    {
        var bodyFont = ConfigCellValueFont;
        var choice = row.Controls.OfType<ComboBox>().Single();
        var remove = row.Controls.OfType<Button>().Single();
        var summary = row.Controls.OfType<Label>().Single();
        row.SuspendLayout();
        try
        {
            row.Margin = Padding.Empty;
            row.BackColor = EditorBackground;
            row.ForeColor = PrimaryTextColor;
            row.Font = bodyFont;
            row.Padding = new Padding(0, Zoomed(8), 0, Zoomed(10));
            choice.Margin = new Padding(0, 0, 0, Zoomed(12));
            choice.ForeColor = PrimaryTextColor;
            if (_missionStyledInputs.Add(choice) || choice.DrawMode != DrawMode.OwnerDrawFixed)
            {
                StyleInput(choice);
                StyleConfigDropdown(choice);
            }
            summary.Margin = new Padding(0, 0, 0, Zoomed(12));
            summary.BackColor = EditorBackground;
            summary.ForeColor = HelpTextColor;
            summary.Font = GetConfigValueFont(1f);
            summary.MaximumSize = new Size(columnWidth, 0);
            remove.BackColor = EditorBackground;
            remove.ForeColor = PrimaryTextColor;
            remove.Font = bodyFont;
            remove.Dock = DockStyle.None;
            remove.Height = choice.Height;
            remove.Width = Math.Min(columnWidth, Math.Max(DialogButtonWidth(remove.Text, 28),
                TextRenderer.MeasureText(remove.Text, remove.Font).Width + Zoomed(28)));
            remove.Margin = new Padding(Zoomed(6), 0, 0, Zoomed(12));
        }
        finally { row.ResumeLayout(true); }
    }

    private void LayoutMissionDownloads()
    {
        if (IsDisposed || Disposing || _missionDownloadsArranging || _missionDownloadsPanel is null
            || _missionDownloadsPanel.IsDisposed || _missionDownloadsPanel.Disposing || _missionDownloadLayout is null || _missionDownloadPage is null) return;
        _missionDownloadsArranging = true;
        try
        {
            _missionDownloadLayout.SuspendLayout();
            var width = Math.Max(1, _missionDownloadsPanel.Width - SystemInformation.VerticalScrollBarWidth - Zoomed(18));
            _missionDownloadPage.MinimumSize = Size.Empty;
            _missionDownloadPage.MaximumSize = new Size(width, 0);
            _missionDownloadPage.MinimumSize = new Size(width, 0);
            _missionDownloadPage.Width = width;
            _missionDownloadPage.Padding = new Padding(Zoomed(24));
            _missionDownloadPage.Margin = Padding.Empty;
            var contentWidth = Math.Max(1, width - _missionDownloadPage.Padding.Horizontal);
            _missionDownloadLayout.Padding = Padding.Empty;
            _missionDownloadLayout.Margin = Padding.Empty;
            if (_missionDownloadRegisterServer is not null) _missionDownloadRegisterServer.Font = MissionPresentationFont(1f, FontStyle.Regular);
            var serverChoiceWidth = CanOfferDownloadServerRegistration ? (_missionDownloadRegisterServer?.GetPreferredSize(Size.Empty).Width ?? 0) + Zoomed(40) : 0;
            var narrow = contentWidth < Zoomed(860) || contentWidth * 40 / 100 < serverChoiceWidth;
            _missionDownloadLayout.ColumnCount = narrow ? 1 : 2;
            _missionDownloadLayout.RowCount = narrow ? 2 : 1;
            _missionDownloadLayout.ColumnStyles.Clear();
            _missionDownloadLayout.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, narrow ? 100 : 60));
            if (!narrow) _missionDownloadLayout.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 40));
            _missionDownloadLayout.SetCellPosition(_missionDownloadRightColumn!, new TableLayoutPanelCellPosition(narrow ? 0 : 1, narrow ? 1 : 0));
            var leftWidth = Math.Max(120, contentWidth * (narrow ? 100 : 60) / 100 - (narrow ? 0 : Zoomed(24)));
            var rightWidth = Math.Max(120, contentWidth * (narrow ? 100 : 40) / 100);
            _missionDownloadRightColumn!.MinimumSize = new Size(rightWidth, 0);
            _missionDownloadRightColumn.MaximumSize = new Size(rightWidth, 0);
            _missionDownloadRight!.Padding = new Padding(Zoomed(20));
            var inputAppearance = (_uiZoomPercent, _darkMode);
            if (_missionInputAppearance != inputAppearance)
            {
                _missionStyledInputs.Clear();
                _missionInputAppearance = inputAppearance;
            }
            var bodyFont = MissionPresentationFont(1f, FontStyle.Regular);
            var smallFont = MissionPresentationFont(1.3f * MissionPageLabelScale, FontStyle.Regular);
            var titleFont = MissionPresentationFont(2.4f * MissionPageLabelScale, FontStyle.Bold);
            var sectionFont = MissionPresentationFont(1.8f * MissionPageLabelScale, FontStyle.Bold);
            var nameFont = MissionPresentationFont(1f, FontStyle.Bold);
            var linkFont = MissionPresentationFont(1f, FontStyle.Underline);
            foreach (var control in Descendants(_missionDownloadsPanel))
            {
                var inCard = ReferenceEquals(control, _missionDownloadRight) || _missionDownloadRight.Contains(control);
                var columnWidth = inCard ? Math.Max(1, rightWidth - _missionDownloadRight.Padding.Horizontal) : leftWidth;
                if (ReferenceEquals(control.Parent, _missionDownloadRightColumn)) columnWidth = rightWidth;
                if (ReferenceEquals(control.Parent, _missionDownloadPage) || control.Parent?.Name == "MissionDownloadHeader") columnWidth = contentWidth;
                if (control is TableLayoutPanel profileRow && profileRow.Name.StartsWith("MissionProfileRow-", StringComparison.Ordinal))
                {
                    StyleMissionProfileRow(profileRow, columnWidth);
                    continue;
                }
                if (control.Parent is TableLayoutPanel rowParent && rowParent.Name.StartsWith("MissionProfileRow-", StringComparison.Ordinal)) continue;
                control.Margin = control is TableLayoutPanel or FlowLayoutPanel ? Padding.Empty : new Padding(0, 0, 0, Zoomed(12));
                var link = control is Button action && (action.Text is "Select remaining" or "Select all" or "Clear"
                    || action.Name is "MissionDownloadZipToggle" or "MissionDownloadChooseTargets" or "MissionDownloadFileOptionsToggle" or "MissionDownloadResultsToggle" or "MissionDownloadOpenLocation");
                if (control is not ComboBox and not TextBoxBase and not ListBox)
                    control.BackColor = control.Name == "MissionDownloadDirectory" ? InputBackground : inCard ? EditorBackground : MainBackground;
                control.ForeColor = control.Name != "MissionDownloadDirectory" && (link || control is Label { Tag: "MissionDownloadMuted" })
                    ? HelpTextColor : PrimaryTextColor;
                if (control is Label text)
                    text.Font = text.Name == "MissionDownloadTitle" ? titleFont : text.Name == "MissionDownloadDirectory" ? bodyFont
                        : Equals(text.Tag, "MissionDownloadHeading") ? sectionFont : Equals(text.Tag, "MissionDownloadMuted") ? smallFont : bodyFont;
                else if (control is Button actionButton) actionButton.Font = actionButton.Text is "Select remaining" or "Select all" or "Clear" ? linkFont : bodyFont;
                else if (control is CheckBox or TableLayoutPanel or FlowLayoutPanel) control.Font = bodyFont;
                if (control is WeatherCheckBox themedCheck)
                {
                    themedCheck.DisabledTextColor = HelpTextColor;
                }
                if (control.Name is "MissionDownloadResultActions" or "MissionDownloadSelectionActions" or "MissionDownloadWarehouseOption" or "MissionDownloadFolderActions")
                {
                    control.MaximumSize = new Size(columnWidth, 0);
                    control.Width = columnWidth;
                }
                if (control is Label or CheckBox) control.MaximumSize = new Size(columnWidth, 0);
                if (control is Label label)
                {
                    if (Equals(label.Tag, "MissionDownloadHeading") && label.Name != "MissionDownloadTitle")
                        label.Margin = new Padding(0, Zoomed(8), 0, Zoomed(14));
                    if (label.Name == "MissionDownloadDirectory") label.Padding = new Padding(Zoomed(9));
                }
                if (control is Panel separator && Equals(separator.Tag, ToolbarSeparatorTag))
                {
                    separator.BackColor = BorderColor;
                    separator.Height = 1;
                    separator.Margin = new Padding(0, Zoomed(12), 0, Zoomed(16));
                }
                if (control is MissionMapCheckBox map)
                {
                    map.Font = bodyFont;
                    map.DetailFont = smallFont;
                    map.TitleFont = nameFont;
                    map.MinimumSize = new Size(0, Math.Max(Zoomed(50), map.Font.Height + map.DetailFont.Height + Zoomed(14))
                        + (map.CompletionText.Length == 0 ? 0 : map.DetailFont.Height + 2));
                    map.Height = map.MinimumSize.Height;
                    map.Margin = Padding.Empty;
                    map.MaximumSize = Size.Empty;
                    map.Invalidate();
                }
                if (control is TextBoxBase or ListBox or ComboBox &&
                    (_missionStyledInputs.Add(control) || control is ComboBox { DrawMode: not DrawMode.OwnerDrawFixed }))
                {
                    StyleInput(control);
                    if (control is ComboBox choice) StyleConfigDropdown(choice);
                }
                if (control is Button button)
                {
                    button.Dock = DockStyle.None;
                    button.Height = Math.Max(Zoomed(34), bodyFont.Height + Zoomed(10));
                    button.Width = Math.Min(columnWidth, Math.Max(
                        DialogButtonWidth(button.Text, 100),
                        TextRenderer.MeasureText(button.Text, button.Font).Width + Zoomed(28)));
                    if (button.Name == "MissionDownloadWarehouseHelp")
                    {
                        StyleButton(button);
                        button.MinimumSize = Size.Empty;
                        button.Padding = Padding.Empty;
                        button.TextAlign = ContentAlignment.MiddleCenter;
                        button.Font = bodyFont;
                        var glyph = TextRenderer.MeasureText(button.Text, button.Font);
                        var helpSize = Math.Max(Zoomed(26), Math.Max(glyph.Width, glyph.Height) + Zoomed(10));
                        button.Size = new Size(helpSize, helpSize);
                        button.Margin = new Padding(Zoomed(6), 0, 0, Zoomed(12));
                    }
                    else if (button.Name == "MissionDownloadBack")
                    {
                        SizeMissionBackButton(button);
                        button.Margin = new Padding(Zoomed(6), 0, 0, Zoomed(12));
                    }
                    else if (button.Name is "MissionDownloadRefreshRelease" or "MissionDownloadChangelog")
                    {
                        SizeMissionBackButton(button);
                        button.Margin = new Padding(Zoomed(6), 0, 0, Zoomed(12));
                    }
                    if (button.Parent?.Name == "MissionDownloadFolderActions")
                        button.Margin = new Padding(0, 0, Zoomed(8), Zoomed(12));
                    if (link)
                    {
                        if (button is PreviewButton disclosure) disclosure.KeyboardFocusOnly = true;
                        button.FlatStyle = FlatStyle.Flat;
                        button.FlatAppearance.BorderSize = 0;
                        button.FlatAppearance.MouseOverBackColor = inCard ? InputBackground : EditorBackground;
                        button.Padding = Padding.Empty;
                        var caption = ReferenceEquals(button, _missionChooseTargets)
                            ? "▾ Config instances to update (" + _missionTargetChecks.Count + ")" : button.Text;
                        button.Width = Math.Min(columnWidth, TextRenderer.MeasureText(caption, button.Font).Width + Zoomed(16));
                        button.TextAlign = ContentAlignment.MiddleLeft;
                        button.ForeColor = HelpTextColor;
                    }
                }
            }
            _missionSelectionActions!.MinimumSize = new Size(leftWidth, 0);
            var stackActions = _missionSelectionLinks!.GetPreferredSize(Size.Empty).Width + _missionReleaseActions!.GetPreferredSize(Size.Empty).Width > leftWidth;
            _missionSelectionActions.SetColumnSpan(_missionSelectionLinks, stackActions ? 2 : 1);
            _missionSelectionActions.SetColumnSpan(_missionReleaseActions, stackActions ? 2 : 1);
            _missionSelectionActions.SetCellPosition(_missionReleaseActions, new TableLayoutPanelCellPosition(stackActions ? 0 : 1, stackActions ? 1 : 0));
            _missionSelectionActions.PerformLayout();
            var summaryWidth = contentWidth;
            _missionDownloadSelectionCount!.MaximumSize = new Size(summaryWidth, 0);
            _missionDownloadSummary!.MaximumSize = new Size(summaryWidth, 0);
            LayoutMissionWarehouseRows(Math.Max(1, rightWidth - _missionDownloadRight.Padding.Horizontal));
            _missionDownloadLeft!.Margin = narrow ? new Padding(0, 0, 0, Zoomed(24)) : new Padding(0, 0, Zoomed(24), 0);
            _missionDownloadRight.Margin = Padding.Empty;
            _missionDownloadRight.BackColor = EditorBackground;
            _missionDownloadRight.Invalidate();


            if (_missionAddProfile is not null) _missionAddProfile.Margin = new Padding(0, Zoomed(12), 0, Zoomed(12));
        }
        finally
        {
            _missionDownloadLayout.ResumeLayout(true);
            _missionDownloadsArranging = false;
        }
        _missionDownloadAppearance = (_missionDownloadsPanel.Width, _uiZoomPercent, _darkMode);

        static IEnumerable<Control> Descendants(Control root)
        {
            foreach (Control child in root.Controls)
            {
                yield return child;
                foreach (var nested in Descendants(child)) yield return nested;
            }
        }
    }
}
