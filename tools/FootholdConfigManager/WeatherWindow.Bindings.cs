using System.Globalization;

namespace FootholdConfigManager;

internal sealed partial class WeatherWindow
{
    private WeatherSettings? _legacyDynamicSettings;

    internal WeatherSettings ReadSettings()
    {
        if (_legacyDynamicSettings is not null)
            throw new InvalidDataException("This saved profile uses dynamic weather. Choose a static profile, or turn off Apply Weather to edit mission options only.");
        if (_catalog is null || _cloudPreset.SelectedItem is not CloudChoice cloud)
            throw new InvalidDataException("Choose a DCS installation and load its presets first.");
        if (!_fogGrid.EndEdit())
            throw new InvalidDataException("Finish editing the weather table before dropping a MIZ.");
        CommitSelectedMissionDate();
        var settings = new WeatherSettings
        {
            CloudMode = cloud.Mode, CloudPreset = cloud.Preset?.Id, CloudBaseMeters = _baseMeters,
            CloudBaseMinimumMeters = cloud.Preset?.MinimumBaseMeters ?? 0,
            CloudBaseMaximumMeters = cloud.Preset?.MaximumBaseMeters ?? 30000,
            CloudThicknessMeters = (double)_thickness.Value, CloudDensity = (int)_density.Value,
            Precipitation = _precipitation.SelectedIndex,
            Wind8000 = Wind(0), Wind2000 = Wind(1), GroundWind = Wind(2),
            TemperatureC = (double)_temperature.Value, PressureMmHg = _pressureMmHg,
            VisibilityMeters = (double)_visibility.Value * 1000,
            TurbulenceMps = (double)_turbulence.Value * WeatherSettings.KnotsToMps,
            FogMode = _fogMode.SelectedIndex == 0 ? "off" : _fogMode.SelectedIndex == 1 ? "auto" : "manual",
            DustEnabled = _dust.Checked, DustVisibilityMeters = (double)_dustVisibility.Value,
            HaloMode = (_haloMode.SelectedItem as DcsHaloPreset)?.Id ?? "auto",
            HaloCrystalPreset = (_crystals.SelectedItem as DcsHaloPreset)?.Id,
            ChangeDateTime = _changeTime.Checked, ChangeMissionDate = _changeDate.Checked, MissionDate = _date.Value.Date,
            StartTimeSeconds = SelectedStartTime.TotalSeconds
        };
        if (settings.FogMode == "manual")
            settings.FogFrames = _fogGrid.Rows.Cast<DataGridViewRow>().Where(row => !row.IsNewRow).Select(row =>
                new WeatherFogFrame { TimeSeconds = FogSeconds(row.Cells[0].Value),
                    VisibilityMeters = GridNumber(row.Cells[1].Value), ThicknessMeters = GridNumber(row.Cells[2].Value) }).ToList();
        settings.Validate();
        if (settings.DustEnabled && settings.FogMode != "off")
            throw new InvalidDataException("DCS cannot enable fog and dust at the same time. Turn one off before exporting.");
        return settings;

        WeatherWind Wind(int index) => new()
        {
            SpeedMps = (double)_windSpeed[index].Value * WeatherSettings.KnotsToMps,
            DirectionTo = ((double)_windDirection[index].Value + (_windConvention.SelectedIndex == 1 ? 180 : 0)) % 360
        };
    }

    private void ApplySettings(WeatherSettings settings)
    {
        settings.Validate();
        _preferences.Current = settings;
        _legacyDynamicSettings = settings.DynamicWeather ? settings : null;
        _updating = true;
        try
        {
            if (_catalog is not null)
            {
                var choice = _cloudPreset.Items.Cast<CloudChoice>().FirstOrDefault(item =>
                    item.Mode == settings.CloudMode && (item.Preset is null || item.Preset.Id == settings.CloudPreset));
                _cloudPreset.SelectedItem = choice ?? _cloudPreset.Items.Cast<CloudChoice>().First(item => item.Preset is not null);
            }
            _baseMeters = settings.CloudBaseMeters;
            Set(_thickness, settings.CloudThicknessMeters);
            Set(_density, settings.CloudDensity);
            _precipitation.SelectedIndex = Math.Clamp(settings.Precipitation, 0, 4);
            var winds = new[] { settings.Wind8000, settings.Wind2000, settings.GroundWind };
            for (var i = 0; i < winds.Length; i++)
            {
                Set(_windSpeed[i], winds[i].SpeedMps / WeatherSettings.KnotsToMps);
                Set(_windDirection[i], (winds[i].DirectionTo + (_windConvention.SelectedIndex == 1 ? 180 : 0)) % 360);
                _windArrow[i].BearingTo = ((double)_windDirection[i].Value + (_windConvention.SelectedIndex == 1 ? 180 : 0)) % 360;
            }
            RefreshLinkedWind();
            _previousConvention = _windConvention.SelectedIndex;
            Set(_temperature, settings.TemperatureC);
            _pressureMmHg = settings.PressureMmHg;
            RenderPressure();
            Set(_visibility, settings.VisibilityMeters / 1000);
            Set(_turbulence, settings.TurbulenceMps / WeatherSettings.KnotsToMps);
            _fogMode.SelectedIndex = settings.FogMode == "off" ? 0 : settings.FogMode == "auto" ? 1 : 2;
            _fogGrid.Rows.Clear();
            foreach (var frame in settings.FogFrames)
                _fogGrid.Rows.Add(((int)(frame.TimeSeconds / 3600)).ToString("D2") + ":" + ((int)(frame.TimeSeconds % 3600 / 60)).ToString("D2") + ":" + ((int)(frame.TimeSeconds % 60)).ToString("D2"),
                    frame.VisibilityMeters, frame.ThicknessMeters);
            if (_fogGrid.Rows.Count == 1) _fogGrid.Rows.Add("00:00", 1500d, 200d);
            _haloMode.SelectedItem = _haloMode.Items.Cast<DcsHaloPreset>().FirstOrDefault(item => item.Id == settings.HaloMode)
                ?? _haloMode.Items.Cast<DcsHaloPreset>().First(item => item.Id == "auto");
            _crystals.SelectedItem = _crystals.Items.Cast<DcsHaloPreset>().FirstOrDefault(item => item.Id == settings.HaloCrystalPreset);
            if (_crystals.SelectedIndex < 0 && _crystals.Items.Count > 0) _crystals.SelectedIndex = 0;
            _dust.Checked = settings.DustEnabled;
            Set(_dustVisibility, settings.DustVisibilityMeters);
            _changeTime.Checked = settings.ChangeDateTime;
            _changeDate.Checked = settings.ChangeDateTime && settings.ChangeMissionDate;
            _date.SetDateValue(settings.MissionDate.Date < _date.MinDate ? _date.MinDate
                : settings.MissionDate.Date > _date.MaxDate ? _date.MaxDate : settings.MissionDate.Date);
            SelectedStartTime = TimeSpan.FromSeconds(Math.Clamp(settings.StartTimeSeconds, 0, 86399));
        }
        finally { _updating = false; }
        RenderCloudSelection();
        RefreshOptionVisibility();
        RefreshSummary();

        static void Set(NumericUpDown control, double value) =>
            control.Value = Math.Clamp((decimal)value, control.Minimum, control.Maximum);
    }

    private void PopulateHaloChoices(WeatherSettings settings)
    {
        var previous = _updating;
        _updating = true;
        try
        {
            _haloMode.Items.Clear();
            _haloMode.Items.Add(new DcsHaloPreset("off", "Off", null));
            _haloMode.Items.Add(new DcsHaloPreset("auto", "Automatic", null));
            foreach (var mode in _catalog!.HaloPresets) _haloMode.Items.Add(mode);
            _crystals.Items.Clear();
            foreach (var preset in _catalog.CrystalPresets) _crystals.Items.Add(preset);
            _haloMode.SelectedItem = _haloMode.Items.Cast<DcsHaloPreset>().FirstOrDefault(mode => mode.Id == settings.HaloMode)
                ?? _haloMode.Items.Cast<DcsHaloPreset>().First(mode => mode.Id == "auto");
            _crystals.SelectedItem = _crystals.Items.Cast<DcsHaloPreset>().FirstOrDefault(preset => preset.Id == settings.HaloCrystalPreset);
            if (_crystals.SelectedIndex < 0 && _crystals.Items.Count > 0) _crystals.SelectedIndex = 0;
        }
        finally { _updating = previous; }
    }

    private void OptionsChanged()
    {
        if (_updating || _busy) return;
        if (_windArrow.Any(dial => dial is { IsDragging: true })) return;
        if (_profiles.Items.Count > 0) _profiles.SelectedIndex = 0;
        RefreshSummary();
    }

    private void RefreshSummary()
    {
        if (_updating || _windSpeed[2] is null || _pressureUnit is null) return;
        var timeDescription = _changeTime.Checked
            ? (_changeDate.Checked ? _date.DateDraftSummary : "Keep mission date") + " · " + SelectedStartTime.ToString(@"hh\:mm\:ss")
            : "Keep mission date & time";
        if (!_applyWeather.Checked)
        {
            _summary.Text = _changeTime.Checked ? timeDescription + (_applyMissionOptions.Checked ? " · Mission options included" : "")
                : _applyMissionOptions.Checked ? "Mission options will be applied on drop." : "Select settings to apply.";
            return;
        }
        if (_workspaceTabs.SelectedIndex == 1)
        {
            _summary.Text = _applyMissionOptions.Checked ? "Mission options will be applied on drop." : "Mission options are not included in this export.";
            return;
        }
        if (_legacyDynamicSettings is not null) { _summary.Text = "Unsupported dynamic profile · choose a static profile, or apply mission options only."; return; }
        if (_catalog is null) { _summary.Text = "Choose a DCS installation to prepare weather."; return; }
        var cloud = _cloudPreset.SelectedItem as CloudChoice;
        var weather = (cloud?.ToString() ?? "Clouds") + " · " + _base.Value.ToString("N0") + " " + (_baseUnit.SelectedIndex == 0 ? "ft" : "m") + " base";
        _summary.Text = weather + " · ground wind " + _windSpeed[2].Value.ToString("0") + " kt · "
            + _temperature.Value.ToString("0.#") + " °C · " + _pressure.Value.ToString("0.##") + " " + _pressureUnit.Text + " · "
            + timeDescription;
    }

    private static double GridNumber(object? value)
    {
        if (value is null || !double.TryParse(Convert.ToString(value, CultureInfo.CurrentCulture),
                NumberStyles.Float | NumberStyles.AllowThousands, CultureInfo.CurrentCulture, out var number) || !double.IsFinite(number))
            throw new InvalidDataException("Complete each numeric weather-table cell, or delete the unused row.");
        return number;
    }

    private static double FogSeconds(object? value)
    {
        var parts = Convert.ToString(value, CultureInfo.InvariantCulture)?.Split(':');
        if (parts is null || parts.Length is < 2 or > 3
            || !int.TryParse(parts[0], out var hours) || !int.TryParse(parts[1], out var minutes)
            || hours < 0 || hours > 48 || minutes < 0 || minutes > 59)
            throw new InvalidDataException("Enter time after mission start as HH:mm or HH:mm:ss (for example 00:15:30).");
        var seconds = 0;
        if (parts.Length == 3 && (!int.TryParse(parts[2], out seconds) || seconds < 0 || seconds > 59))
            throw new InvalidDataException("Invalid fog time seconds.");
        return hours * 3600 + minutes * 60 + seconds;
    }
}
