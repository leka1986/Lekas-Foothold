namespace FootholdConfigManager;

internal sealed partial class WeatherWindow
{
    private Func<string>? _mizInitialDirectory;
    private Action<string>? _rememberMizPath;
    private readonly CheckBox _importWeatherAndTime = new WeatherCheckBox
        { Name = "MissionImportWeatherAndTime", Text = "Weather, date & time", AutoSize = true, Checked = true, UseMnemonic = false };
    private readonly CheckBox _importOptions = new WeatherCheckBox
        { Name = "MissionImportOptions", Text = "Mission options", AutoSize = true, Checked = true };
    private readonly Label _importMessage = new()
        { Name = "MissionImportStatus", AutoSize = true, MaximumSize = new Size(700, 0) };

    internal void ConfigureMizBrowsing(Func<string> initialDirectory, Action<string> rememberPath)
    {
        _mizInitialDirectory = initialDirectory;
        _rememberMizPath = rememberPath;
    }

    private string? SelectMizPath(string title)
    {
        using var dialog = new OpenFileDialog
        {
            Title = title, Filter = "DCS mission (*.miz)|*.miz", CheckFileExists = true,
            InitialDirectory = _mizInitialDirectory?.Invoke() ?? RuntimeSettings.GetBestInitialDirectory()
        };
        if (dialog.ShowDialog(DialogOwner) != DialogResult.OK) return null;
        try { _rememberMizPath?.Invoke(dialog.FileName); }
        catch (Exception error) when (error is IOException or UnauthorizedAccessException)
        {
            MessageBox.Show(DialogOwner, "The selected folder could not be remembered. " + error.Message,
                "MIZ browser settings", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
        return dialog.FileName;
    }

    private TabPage BuildMizImportTab()
    {
        var content = new TableLayoutPanel
        {
            Name = "MissionImportFields", Dock = DockStyle.Top, AutoSize = true, ColumnCount = 1,
            MaximumSize = new Size(S(820), 0), Padding = new Padding(S(8))
        };
        content.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        content.Controls.Add(Heading("Import settings from a MIZ"), 0, 0);
        content.Controls.Add(new Label
        {
            Text = "Choose what to import into the editors. The source mission stays unchanged.\nReview or edit the imported values, then use Browse below to apply them to a MIZ.",
            AutoSize = true, MaximumSize = new Size(S(700), 0), Margin = new Padding(0, S(8), 0, S(24))
        }, 0, 1);
        _importWeatherAndTime.Margin = _importOptions.Margin = new Padding(0, S(10), 0, S(10));
        content.Controls.Add(_importWeatherAndTime, 0, 2);
        content.Controls.Add(_importOptions, 0, 3);
        var browse = Button("Browse MIZ…", BrowseImportMiz, "MissionImportBrowse");
        browse.UseMnemonic = false;
        browse.Anchor = AnchorStyles.Left;
        browse.Margin = new Padding(0, S(16), 0, S(20));
        content.Controls.Add(browse, 0, 4);
        _importMessage.MaximumSize = new Size(S(700), 0);
        content.Controls.Add(_importMessage, 0, 5);
        void UpdateSelection()
        {
            browse.Enabled = _importWeatherAndTime.Checked || _importOptions.Checked;
            RefreshSummary();
        }
        _importWeatherAndTime.CheckedChanged += (_, _) => UpdateSelection();
        _importOptions.CheckedChanged += (_, _) => UpdateSelection();
        var viewport = new Panel { Name = "MissionImportScroll", AutoScroll = true };
        viewport.Controls.Add(content);
        var page = new TabPage("Import MIZ") { Padding = new Padding(S(12)) };
        page.Controls.Add(new WeatherScrollHost(viewport) { Dock = DockStyle.Fill });
        return page;
    }

    private async void BrowseImportMiz()
    {
        if (_busy) return;
        if (SelectMizPath("Import mission settings from a MIZ") is { } path)
            await ImportMizSettingsAsync(path, _importWeatherAndTime.Checked, _importOptions.Checked);
    }

    internal async Task ImportMizSettingsAsync(string path, bool includeWeatherAndTime, bool includeMissionOptions)
    {
        if (_busy) return;
        SetBusy(true);
        _importMessage.Text = "Reading " + Path.GetFileName(path) + "…";
        try
        {
            var imported = await Task.Run(() => WeatherMizService.ReadSettings(path, includeWeatherAndTime, includeMissionOptions));
            if (IsDisposed) return;
            // Check every selected group before touching any retained editor controls.
            if (imported.Weather is { } weather) ValidateImportedWeather(weather, imported.DateTime!);
            imported.Options?.Validate();
            if (imported.Options is { } options)
            {
                _applyMissionOptionsDraft(options);
                _applyMissionOptions.Checked = true;
            }
            if (imported.Weather is { } selectedWeather)
            {
                selectedWeather.ChangeDateTime = true;
                selectedWeather.ChangeMissionDate = true;
                selectedWeather.MissionDate = imported.DateTime!.MissionDate;
                selectedWeather.StartTimeSeconds = imported.DateTime.StartTimeSeconds;
                ApplySettings(selectedWeather);
                _applyWeather.Checked = true;
            }
            RefreshApplyAvailability();
            RefreshSummary();
            _importMessage.Text = "Imported " + Path.GetFileName(path) + ". Review the selected settings on their tabs."
                + (imported.DateTime is { } time && time.StartTimeSeconds % 60 != 0
                    ? " Start time uses the editor’s hour and minute precision." : "");
            SetStatus(_importMessage.Text);
        }
        catch (Exception error) when (error is InvalidDataException or IOException or UnauthorizedAccessException or ArgumentException
            or NotSupportedException or System.Security.SecurityException)
        {
            if (!IsDisposed)
            {
                _importMessage.Text = "Settings were not imported. " + error.Message;
                SetStatus(_importMessage.Text, true);
            }
        }
        finally { if (!IsDisposed) SetBusy(false); }
    }

    private void ValidateImportedWeather(WeatherSettings weather, MissionDateTimeSettings dateTime)
    {
        weather.Validate();
        dateTime.Validate();
        if (_catalog is null) throw new InvalidDataException("Load a DCS installation before importing weather.");
        var cloud = _cloudPreset.Items.Cast<CloudChoice>().SingleOrDefault(item => item.Mode == weather.CloudMode
            && (item.Preset is null || item.Preset.Id == weather.CloudPreset));
        if (cloud is null) throw new InvalidDataException("This DCS installation does not contain cloud preset " + weather.CloudPreset + ".");
        if (cloud.Preset is { } preset && (weather.CloudBaseMeters < preset.MinimumBaseMeters || weather.CloudBaseMeters > preset.MaximumBaseMeters))
            throw new InvalidDataException("The imported cloud base is outside the supported range for " + preset.Name + ".");
        Check(_thickness, weather.CloudThicknessMeters, "Cloud thickness");
        Check(_density, weather.CloudDensity, "Cloud density");
        if (weather.Precipitation < 0 || weather.Precipitation >= _precipitation.Items.Count)
            throw new InvalidDataException("The imported precipitation is not supported by this editor.");
        var winds = new[] { weather.Wind8000, weather.Wind2000, weather.GroundWind };
        for (var index = 0; index < winds.Length; index++)
        {
            Check(_windSpeed[index], winds[index].SpeedMps / WeatherSettings.KnotsToMps, "Wind speed");
            Check(_windDirection[index], (winds[index].DirectionTo + (_windConvention.SelectedIndex == 1 ? 180 : 0)) % 360, "Wind direction");
        }
        Check(_temperature, weather.TemperatureC, "Temperature");
        var pressureFactor = _pressureUnit.SelectedIndex == 0 ? WeatherSettings.InHgToMmHg
            : _pressureUnit.SelectedIndex == 1 ? WeatherSettings.HPaToMmHg : 1;
        Check(_pressure, weather.PressureMmHg / pressureFactor, "Pressure");
        Check(_visibility, weather.VisibilityMeters / 1000, "Visibility");
        Check(_turbulence, weather.TurbulenceMps / WeatherSettings.KnotsToMps, "Turbulence");
        Check(_dustVisibility, weather.DustVisibilityMeters, "Dust visibility");
        if (!_haloMode.Items.Cast<DcsHaloPreset>().Any(item => item.Id == weather.HaloMode)
            || weather.HaloMode is not ("off" or "auto") && !_crystals.Items.Cast<DcsHaloPreset>().Any(item => item.Id == weather.HaloCrystalPreset))
            throw new InvalidDataException("This DCS installation does not contain the imported ice halo or crystal preset.");
        if (dateTime.MissionDate.Date < _date.MinDate || dateTime.MissionDate.Date > _date.MaxDate)
            throw new InvalidDataException("The imported mission date is outside this editor’s supported range.");

        static void Check(NumericUpDown control, double value, string label)
        {
            if (!double.IsFinite(value) || value < (double)control.Minimum || value > (double)control.Maximum)
                throw new InvalidDataException(label + " is outside this editor’s supported range.");
        }
    }
}
