using System.Diagnostics;

namespace FootholdConfigManager;

internal sealed partial class WeatherWindow : Form
{
    private readonly WeatherProfileStore _store = new();
    private readonly WeatherPreferences _preferences;
    private readonly string? _missionScripting;
    private readonly Func<string, Action, Button> _makeButton;
    private readonly Action<Form> _style;
    private float _uiScale;
    private float _weatherUiScale;
    private readonly Func<string?>? _eraProvider;
    private Font _boldFont;
    private bool _updating = true;
    private bool _busy;
    internal bool IsBusy => _busy;
    private bool _profileStorageAvailable = true;
    private DcsWeatherCatalog? _catalog;
    private string? _lastOutput;
    private string? _startupWarning;
    private Action? _backToConfig;
    private readonly Panel[] _tabLayoutOwners;
    private Task? _initializationTask;
    private IWin32Window DialogOwner => TopLevel ? this : TopLevelControl ?? this;

    public WeatherWindow(string? missionScripting, Font font, Func<string, Action, Button> makeButton, Action<Form> style, float uiScale = 1, Func<string?>? eraProvider = null)
    {
        _missionScripting = missionScripting;
        _makeButton = makeButton;
        _style = style;
        _uiScale = _weatherUiScale = uiScale;
        _eraProvider = eraProvider;
        _bodyFont = new Font(font.FontFamily, 10f * uiScale);
        _captionFont = new Font(font.FontFamily, 9f * uiScale);
        Font = _bodyFont;
        _boldFont = new Font(_bodyFont, FontStyle.Bold);
        try { _preferences = _store.Load(); _preferences.Current.Validate(); }
        catch (Exception ex) when (ex is InvalidDataException or IOException or UnauthorizedAccessException or System.Text.Json.JsonException or ArgumentException)
        {
            _preferences = new WeatherPreferences();
            _profileStorageAvailable = false;
            _startupWarning = "Weather profiles could not be read and have been left unchanged: " + ex.Message;
        }
        Text = "Mission settings · Foothold Config Manager";
        Name = "WeatherWindow";
        DoubleBuffered = true;
        StartPosition = FormStartPosition.CenterParent;
        AutoScaleMode = AutoScaleMode.Dpi;
        AutoScaleDimensions = new SizeF(96, 96);
        var area = Screen.PrimaryScreen?.WorkingArea ?? new Rectangle(0, 0, 1920, 1080);
        MinimumSize = new Size(Math.Min(S(850), area.Width - 30), Math.Min(S(650), area.Height - 60));
        ClientSize = new Size(Math.Min(S(1000), area.Width - 50), Math.Min(S(820), area.Height - 80));
        _missionOptions = _preferences.MissionOptions;
        BuildShell();
        _baseUnit.SelectedIndex = _preferences.CloudBaseUnit;
        _pressureUnit.SelectedIndex = _preferences.PressureUnit;
        _windConvention.SelectedIndex = _preferences.WindConvention;
        _workspaceTabs.SelectedIndex = _preferences.WorkspaceTab;

        PopulateProfiles();
        _updating = true;
        if (_preferences.WeatherProfileName is { } profileName)
            _profiles.SelectedItem = _profiles.Items.OfType<WeatherNamedProfile>().FirstOrDefault(profile => profile.Name == profileName)
                ?? _profiles.Items[0];
        ApplySettings(_preferences.Current);
        _updating = true;
        _changeTime.Checked = _preferences.ApplyDateTime ?? _preferences.Current.ChangeDateTime;
        _changeDate.Checked = _preferences.ApplyDateTime.HasValue ? _preferences.Current.ChangeMissionDate : _preferences.Current.ChangeDateTime && _preferences.Current.ChangeMissionDate;
        if (_preferences.DateTime is { } rememberedTime)
        {
            _changeDate.Checked = rememberedTime.ChangeDate;
            _date.SetDateValue(rememberedTime.MissionDate.Date < _date.MinDate ? _date.MinDate
                : rememberedTime.MissionDate.Date > _date.MaxDate ? _date.MaxDate : rememberedTime.MissionDate.Date);
            SelectedStartTime = TimeSpan.FromSeconds(rememberedTime.StartTimeSeconds);
        }
        _updating = false;
        _style(this);
        ApplyWeatherChrome(this);
        WireWeatherBackgroundFocus();
        _browse.Enabled = false;
        if (_startupWarning is not null) SetStatus(_startupWarning, true);
        Shown += async (_, _) =>
        {
            if (TopLevel) FitWeatherToScreen();
            try { await EnsureInitializedAsync(CancellationToken.None); }
            catch (Exception error) when (error is InvalidDataException or IOException or UnauthorizedAccessException or ArgumentException)
            { if (!IsDisposed) SetStatus("Mission settings could not finish loading. " + error.Message, true); }
        };
        FormClosing += (_, args) => args.Cancel = !SaveBeforeLeaving();
        RefreshOptionVisibility();
        ApplyUiZoom(_uiScale);

        // Batch the retained tab contents like Config's cached category panels.
        // Hook after saved-tab restoration and chrome/zoom have created the owners.
        _tabLayoutOwners = Descendants(_workspaceTabs).OfType<Panel>().ToArray();
        var tabLayoutPending = false;
        _workspaceTabs.Selecting += (_, _) =>
        {
            tabLayoutPending = true;
            foreach (var owner in _tabLayoutOwners) owner.SuspendLayout();
        };
        _workspaceTabs.SelectedIndexChanged += (_, _) =>
        {
            if (!tabLayoutPending) return;
            tabLayoutPending = false;
            for (var i = _tabLayoutOwners.Length - 1; i >= 0; i--)
                _tabLayoutOwners[i].ResumeLayout(false);
            _workspaceTabs.SelectedTab!.PerformLayout();
        };
    }

    internal void ShowWorkspace()
    {
        foreach (var owner in _tabLayoutOwners) owner.SuspendLayout();
        try { Show(); }
        finally
        {
            for (var i = _tabLayoutOwners.Length - 1; i >= 0; i--)
                _tabLayoutOwners[i].ResumeLayout(false);
            _workspaceTabs.SelectedTab!.PerformLayout();
        }
    }

    internal Task EnsureInitializedAsync(CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ObjectDisposedException.ThrowIf(IsDisposed, this);
        _initializationTask ??= DetectInstallationsAsync();
        return _initializationTask.WaitAsync(cancellationToken);
    }

    internal async Task PrepareViewsAsync(CancellationToken cancellationToken)
    {
        await EnsureInitializedAsync(cancellationToken);
        cancellationToken.ThrowIfCancellationRequested();
        ObjectDisposedException.ThrowIf(IsDisposed, this);
        var tabs = Descendants(_workspaceTabs).OfType<TabControl>().Prepend(_workspaceTabs)
            .Select(tab => (Control: tab, Selected: tab.SelectedIndex)).ToArray();
        try
        {
            foreach (var tab in tabs)
                for (var index = 0; index < tab.Control.TabPages.Count; index++)
                {
                    cancellationToken.ThrowIfCancellationRequested();
                    ObjectDisposedException.ThrowIf(IsDisposed, this);
                    tab.Control.SelectedIndex = index;
                    tab.Control.SelectedTab!.CreateControl();
                    tab.Control.SelectedTab.PerformLayout();
                    tab.Control.SelectedTab.Update();
                    await Task.Yield();
                }
        }
        finally
        {
            if (!IsDisposed)
                foreach (var tab in tabs.Reverse()) tab.Control.SelectedIndex = tab.Selected;
        }
    }

    internal int SelectedWeatherTab { get => _preferences.WeatherTab; set => _preferences.WeatherTab = Math.Clamp(value, 0, 2); }

    internal void RefreshOwnerTheme()
    {
        _style(this);
        ApplyWeatherChrome(this);
        RenderCloudSelection();
    }

    internal void EmbedInManager(Action backToConfig)
    {
        _backToConfig = backToConfig;
        TopLevel = false;
        FormBorderStyle = FormBorderStyle.None;
        MinimumSize = Size.Empty;
        Dock = DockStyle.Fill;
        Margin = Padding.Empty;
        _zoomGeometry.Remove(this);
        _close.Text = "Back to Config";
        _close.Width = TextRenderer.MeasureText(_close.Text, Font).Width + S(36);
        _zoomGeometry.Remove(_close);
    }

    internal bool SaveBeforeLeaving(bool requireSaved = false)
    {
        if (_busy) { SetStatus("Please wait for the current weather operation to finish."); return false; }
        try { CommitSelectedMissionDate(); }
        catch (InvalidDataException ex)
        {
            SetStatus((requireSaved ? "Zoom could not change. " : "Mission settings could not be saved. ") + ex.Message, true);
            return false;
        }
        if (requireSaved && (!_profileStorageAvailable || (_applyWeather.Checked && _catalog is null)))
        {
            SetStatus("Zoom could not change because the current weather settings cannot be saved yet.", true);
            return false;
        }
        if (_profileStorageAvailable)
        {
            try { SavePreferences(_legacyDynamicSettings ?? (_catalog is null ? null : ReadSettings())); }
            catch (Exception ex) when (ex is InvalidDataException or IOException or UnauthorizedAccessException or ArgumentException)
            {
                SetStatus((requireSaved ? "Zoom could not change. " : "Mission settings could not be saved. ") + ex.Message, true);
                return false;
            }
        }
        return true;
    }

    internal void LeaveWeather()
    {
        if (_backToConfig is null) Close();
        else if (SaveBeforeLeaving()) _backToConfig();
    }

    private async Task DetectInstallationsAsync()
    {
        if (_busy) return;
        SetBusy(true);
        IReadOnlyList<string> installations;
        try
        {
            installations = await Task.Run(() => DcsWeatherCatalog.DetectInstallations(_preferences.DcsInstallationIsExplicit ? _preferences.DcsInstallationPath : null, _missionScripting));
            if (IsDisposed) return;
            _updating = true;
            _installation.Items.Clear();
            foreach (var path in installations) _installation.Items.Add(path);
            _updating = false;
            _installStatus.Text = installations.Count == 0 ? "DCS installation · choose a folder to load presets" : "DCS installation · loading presets…";
        }
        catch (Exception ex) when (ex is InvalidDataException or IOException or UnauthorizedAccessException or ArgumentException)
        {
            installations = Array.Empty<string>();
            if (!IsDisposed) SetStatus("DCS detection could not finish. Choose the installation folder manually. " + ex.Message, true);
        }
        finally { if (!IsDisposed) { _updating = false; SetBusy(false); } }
        if (!IsDisposed && installations.Count > 0)
            await LoadInstallationAsync(installations[0], _preferences.DcsInstallationIsExplicit
                && string.Equals(installations[0], _preferences.DcsInstallationPath, StringComparison.OrdinalIgnoreCase));
    }

    internal async Task LoadInstallationAsync(string path, bool? explicitSelection = null)
    {
        if (_busy) return;
        try { CommitSelectedMissionDate(); }
        catch (InvalidDataException ex) { SetStatus(ex.Message, true); return; }
        SetBusy(true);
        try
        {
            var settings = _legacyDynamicSettings ?? (_catalog is null ? _preferences.Current : ReadSettings());
            var timeSelection = (_changeTime.Checked, ChangeDate: _changeDate.Checked, Date: _date.Value, Draft: _date.DateDraftText, Start: SelectedStartTime);
            var catalog = await Task.Run(() => DcsWeatherCatalog.Load(path));
            if (IsDisposed) return;
            _catalog = catalog;
            _updating = true;
            if (!_installation.Items.Contains(catalog.InstallationPath)) _installation.Items.Add(catalog.InstallationPath);
            _installation.SelectedItem = catalog.InstallationPath;
            _updating = false;
            PopulateClouds(settings);
            PopulateHaloChoices(settings);
            ApplySettings(settings);
            // Catalog changes repopulate weather choices; independent time stays owned by its controls.
            _updating = true;
            _changeTime.Checked = timeSelection.Checked;
            _changeDate.Checked = timeSelection.ChangeDate;
            _date.SetDateValue(timeSelection.Date);
            _date.RestoreDateDraft(timeSelection.Draft);
            SelectedStartTime = timeSelection.Start;
            _updating = false;
            RefreshOptionVisibility();
            RefreshSummary();
            _preferences.DcsInstallationPath = catalog.InstallationPath;
            if (explicitSelection.HasValue) _preferences.DcsInstallationIsExplicit = explicitSelection.Value;
            _installStatus.Text = "DCS installation · " + catalog.CloudPresets.Count + " cloud presets loaded"
                + (catalog.UsesClientPreviewAssets ? " · previews from client installation" : "");
            _style(this);
            ApplyWeatherChrome(this);
            RenderCloudSelection();
            if (_startupWarning is null) SetStatus("");
        }
        catch (Exception ex) when (ex is InvalidDataException or IOException or UnauthorizedAccessException or ArgumentException)
        {
            if (!IsDisposed)
            {
                _updating = true;
                if (_catalog is not null) _installation.SelectedItem = _catalog.InstallationPath;
                _updating = false;
                SetStatus(ex.Message, true);
                if (_catalog is null) _installStatus.Text = "DCS installation · presets not loaded";
            }
        }
        finally { if (!IsDisposed) { _updating = false; SetBusy(false); RefreshSummary(); } }
    }

    private async void ChooseInstallation()
    {
        if (_busy) return;
        using var dialog = new FolderBrowserDialog
        {
            Description = "Choose the main DCS installation folder (not Saved Games).",
            SelectedPath = _catalog?.InstallationPath ?? @"C:\Games\DCS World Server",
            UseDescriptionForTitle = true
        };
        if (dialog.ShowDialog(DialogOwner) == DialogResult.OK) await LoadInstallationAsync(dialog.SelectedPath, true);
    }

    private async void RefreshInstallation()
    {
        if (_installation.SelectedItem is string path) await LoadInstallationAsync(path);
        else await DetectInstallationsAsync();
    }

    private async void BrowseMiz()
    {
        if (_busy) return;
        using var dialog = new OpenFileDialog { Title = "Apply mission settings to a MIZ", Filter = "DCS mission (*.miz)|*.miz", CheckFileExists = true };
        if (dialog.ShowDialog(DialogOwner) == DialogResult.OK) await ApplyMizAsync(dialog.FileName);
    }

    internal async Task ApplyMizAsync(string path)
    {
        if (_busy) return;
        WeatherSettings? settings;
        MissionDateTimeSettings? dateTime;
        MissionOptionsSettings? options;
        try
        {
            CommitSelectedMissionDate();
            settings = _applyWeather.Checked ? ReadSettings() : null;
            options = _applyMissionOptions.Checked ? ReadMissionOptions() : null;
            dateTime = _changeTime.Checked ? new MissionDateTimeSettings { ChangeDate = _changeDate.Checked, MissionDate = _date.Value.Date, StartTimeSeconds = SelectedStartTime.TotalSeconds } : null;
            dateTime?.Validate();
            if (settings is null && options is null && dateTime is null) throw new InvalidDataException("Choose Weather, Date & time, Mission options, or a combination to apply.");
        }
        catch (Exception ex) when (ex is InvalidDataException or IOException or ArgumentException)
        { SetStatus(ex.Message, true); return; }
        SetBusy(true);
        SetStatus("Preparing mission settings for " + Path.GetFileName(path) + "…");
        try
        {
            string? preferenceWarning = null;
            if (_profileStorageAvailable)
            {
                try { SavePreferences(settings, options); }
                catch (Exception ex) when (ex is InvalidDataException or IOException or UnauthorizedAccessException)
                { preferenceWarning = " Settings could not be remembered: " + ex.Message; }
            }
            var era = _eraProvider?.Invoke();
            var cloudName = _cloudPreset.SelectedItem?.ToString();
            var result = await Task.Run(() => WeatherMizService.ApplySettings(path, settings, options, dateTime,
                context => (string?)Invoke(new Func<string?>(() => PromptExportName(context, settings, era, cloudName, dateTime, options is not null)))));
            if (result is null) { if (!IsDisposed) SetStatus("Export cancelled. Original mission unchanged."); return; }
            if (IsDisposed) return;
            _lastOutput = result.OutputPath;
            _openOutput.Visible = true;
            SetStatus("Created: " + result.OutputPath + preferenceWarning);
        }
        catch (Exception ex) when (ex is InvalidDataException or IOException or UnauthorizedAccessException or ArgumentException
            or NotSupportedException or System.Security.SecurityException)
        {
            if (!IsDisposed) SetStatus("Mission settings were not applied. " + ex.Message, true);
        }
        finally { if (!IsDisposed) SetBusy(false); }
    }

    private bool CanApplySelection => (!IsMissionDateSelected || _date.HasValidDateDraft) && (_applyWeather.Checked ? _catalog is not null && _legacyDynamicSettings is null : _applyMissionOptions.Checked || _changeTime.Checked);

    private void RefreshApplyAvailability()
    {
        _browse.Enabled = !_busy && CanApplySelection;
        var weatherAvailable = _catalog is not null && _legacyDynamicSettings is null;
        _cloudLayout.Enabled = _cloudWeatherSection.Enabled = _atmosphereSection.Enabled = weatherAvailable;
    }

    private void SetBusy(bool busy)
    {
        _busy = busy;
        _root.Enabled = !busy;
        UseWaitCursor = busy;
        RefreshApplyAvailability();
    }

    private void SetStatus(string text, bool error = false)
    {
        _status.Text = text;
        _status.Visible = !string.IsNullOrWhiteSpace(text);
        _status.ForeColor = error ? (BackColor.GetBrightness() < .5f ? Color.FromArgb(255, 135, 135) : Color.Firebrick) : ForeColor;
    }

    private void SavePreferences(WeatherSettings? settings, MissionOptionsSettings? options = null)
    {
        CommitSelectedMissionDate();
        _preferences.Current = settings is not null && !ReferenceEquals(settings, _legacyDynamicSettings) ? settings
            : System.Text.Json.JsonSerializer.Deserialize<WeatherSettings>(System.Text.Json.JsonSerializer.Serialize(settings ?? _preferences.Current))!;
        _preferences.DateTime = new MissionDateTimeSettings
        {
            ChangeDate = _changeDate.Checked, MissionDate = _date.Value.Date,
            StartTimeSeconds = SelectedStartTime.TotalSeconds
        };
        if (_legacyDynamicSettings is null)
        {
            _preferences.Current.ChangeDateTime = _changeTime.Checked;
            _preferences.Current.ChangeMissionDate = _changeDate.Checked;
            _preferences.Current.MissionDate = _date.Value.Date;
            _preferences.Current.StartTimeSeconds = SelectedStartTime.TotalSeconds;
        }
        _preferences.ApplyDateTime = _changeTime.Checked;
        _preferences.MissionOptions = options ?? ReadMissionOptions();
        _preferences.ApplyWeather = _applyWeather.Checked;
        _preferences.ApplyMissionOptions = _applyMissionOptions.Checked;
        _preferences.WorkspaceTab = _workspaceTabs.SelectedIndex;
        // Preserve the legacy tab preference; this version uses one scrolling weather page.
        _preferences.WeatherLayoutVersion = 2;
        _preferences.CloudBaseUnit = _baseUnit.SelectedIndex;
        _preferences.PressureUnit = _pressureUnit.SelectedIndex;
        _preferences.WindConvention = _windConvention.SelectedIndex;
        _preferences.WeatherProfileName = (_profiles.SelectedItem as WeatherNamedProfile)?.Name;
        _store.Save(_preferences);
    }

    private void PopulateProfiles()
    {
        _updating = true;
        _profiles.Items.Clear();
        _profiles.Items.Add("Custom weather");
        _profiles.Items.Add(new WeatherNamedProfile { Name = "Clear & calm", Settings = new WeatherSettings
        {
            CloudMode = "clear", TemperatureC = 20, GroundWind = new(), Wind2000 = new(), Wind8000 = new()
        }});
        _profiles.Items.Add(new WeatherNamedProfile { Name = "Scattered & breezy", Settings = new WeatherSettings() });
        _profiles.Items.Add(new WeatherNamedProfile { Name = "Overcast & rain", Settings = new WeatherSettings
        {
            CloudPreset = "RainyPreset1", CloudBaseMeters = 900, TemperatureC = 10, FogMode = "auto",
            GroundWind = new() { SpeedMps = 8 * WeatherSettings.KnotsToMps, DirectionTo = 138 },
            Wind2000 = new() { SpeedMps = 15 * WeatherSettings.KnotsToMps, DirectionTo = 286 },
            Wind8000 = new() { SpeedMps = 25 * WeatherSettings.KnotsToMps, DirectionTo = 18 }
        }});
        foreach (var profile in _preferences.Profiles) _profiles.Items.Add(profile);
        _profiles.SelectedIndex = 0;
        _updating = false;
    }

    private void SaveProfile()
    {
        try
        {
            if (!_profileStorageAvailable) throw new InvalidDataException(_startupWarning ?? "Weather profile storage is unavailable.");
            var settings = ReadSettings();
            using var dialog = new Form { Text = "Save weather profile", StartPosition = FormStartPosition.CenterParent,
                ClientSize = new Size(S(420), S(150)), Font = Font, MinimizeBox = false, MaximizeBox = false };
            var name = new TextBox { Dock = DockStyle.Top, Margin = new Padding(0, 8, 0, 12) };
            var body = new TableLayoutPanel { Dock = DockStyle.Fill, Padding = new Padding(S(14)), ColumnCount = 1, RowCount = 3 };
            body.Controls.Add(new Label { Text = "Profile name", AutoSize = true }, 0, 0);
            body.Controls.Add(name, 0, 1);
            var save = Button("Save", () => { if (!string.IsNullOrWhiteSpace(name.Text)) dialog.DialogResult = DialogResult.OK; });
            var cancel = Button("Cancel", () => dialog.DialogResult = DialogResult.Cancel);
            body.Controls.Add(Row(save, cancel), 0, 2);
            dialog.Controls.Add(body);
            dialog.AcceptButton = save;
            dialog.CancelButton = cancel;
            _style(dialog);
            ApplyWeatherChrome(dialog);
            if (dialog.ShowDialog(DialogOwner) != DialogResult.OK) return;
            var label = name.Text.Trim();
            if (label is "Clear & calm" or "Scattered & breezy" or "Overcast & rain" or "Custom weather")
                throw new InvalidDataException("Choose a different name for your saved profile.");
            var profile = _preferences.Profiles.FirstOrDefault(item => item.Name.Equals(label, StringComparison.OrdinalIgnoreCase));
            if (profile?.Settings.DynamicWeather == true)
                throw new InvalidDataException("That name belongs to an unsupported dynamic profile. Choose a new name to keep the original profile.");
            if (profile is null) { profile = new WeatherNamedProfile { Name = label }; _preferences.Profiles.Add(profile); }
            profile.Settings = settings;
            SavePreferences(settings);
            PopulateProfiles();
            _profiles.SelectedItem = profile;
            SetStatus("Saved weather profile: " + label);
        }
        catch (Exception ex) when (ex is InvalidDataException or IOException or UnauthorizedAccessException or ArgumentException)
        { SetStatus(ex.Message, true); }
    }

    private void OpenOutputFolder()
    {
        if (_lastOutput is not null)
            Process.Start(new ProcessStartInfo { FileName = Path.GetDirectoryName(_lastOutput)!, UseShellExecute = true });
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing)
        {
            _preview.Image = null;
            foreach (var image in _images.Values) image.Dispose();
            _images.Clear();
            foreach (var font in _zoomFontCache.Values.Concat(new[] { _bodyFont, _captionFont, _boldFont }).Distinct()) font.Dispose();
            _zoomGeometry.Clear();
        }
        base.Dispose(disposing);
    }
}
