using System.Globalization;
using System.Drawing.Drawing2D;

namespace FootholdConfigManager;

internal sealed partial class WeatherWindow
{
    private readonly NumericUpDown[] _windSpeed = new NumericUpDown[3];
    private readonly NumericUpDown[] _windDirection = new NumericUpDown[3];
    private TableLayoutPanel _windLayout = null!;
    private readonly WeatherWindDial[] _windArrow = new WeatherWindDial[3];
    private ComboBox _windConvention = null!;
    private NumericUpDown _wind500Speed = null!;
    private NumericUpDown _wind500Direction = null!;
    private int _previousConvention;
    private NumericUpDown _temperature = null!;
    private NumericUpDown _pressure = null!;
    private ComboBox _pressureUnit = null!;
    private double _pressureMmHg = 762;
    private NumericUpDown _visibility = null!;
    private NumericUpDown _turbulence = null!;
    private ComboBox _fogMode = null!;
    private readonly DataGridView _fogGrid = new MainForm.SmoothDataGridView() { Name = "WeatherFogSchedule", AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill, RowHeadersWidth = 28 };
    private Control _fogFields = null!;
    private readonly ComboBox _haloMode = new WeatherChoiceBox() { Name = "WeatherHalo", DropDownStyle = ComboBoxStyle.DropDownList, Dock = DockStyle.Top };
    private readonly ComboBox _crystals = new WeatherChoiceBox() { Name = "WeatherCrystals", DropDownStyle = ComboBoxStyle.DropDownList, Dock = DockStyle.Top };
    private Control _crystalFields = null!;
    private readonly CheckBox _dust = new WeatherCheckBox() { Name = "WeatherDust", Text = "Enable dust storm", AutoSize = true };
    private NumericUpDown _dustVisibility = null!;
    private Control _dustFields = null!;
    private readonly CheckBox _changeTime = new WeatherCheckBox() { Name = "WeatherChangeTime", Text = "Date & time", UseMnemonic = false, AutoSize = true };
    private readonly CheckBox _changeDate = new WeatherCheckBox() { Name = "WeatherChangeDate", Text = "Change mission date", AutoSize = true };
    private readonly WeatherDateTimeInput _date = new() { Name = "WeatherDate", Format = DateTimePickerFormat.Custom, CustomFormat = "yyyy-MM-dd", Dock = DockStyle.Top, DirectDateTextEntry = true, TabStop = false };
    private TableLayoutPanel _time = null!;

    private Control BuildWind()
    {
        _windConvention = Choice("WeatherWindConvention", false, "Blows to · DCS editor", "Comes from · METAR");
        var layout = _windLayout = new MissionOptionsLayout { Name = "WeatherWindLayers", Dock = DockStyle.Top, AutoSize = true, ColumnCount = 4, Margin = Padding.Empty };
        layout.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, W(112)));
        layout.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50));
        layout.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, W(60)));
        layout.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50));
        layout.Controls.Add(new Label { Text = "Wind", Font = _boldFont, AutoSize = true, Margin = new Padding(0, W(8), 0, W(14)) }, 0, 0);
        _windConvention.Dock = DockStyle.Top;
        _windConvention.Items[0] = "Blows to · DCS";
        _windConvention.Items[1] = "Comes from · METAR";
        layout.Controls.Add(_windConvention, 1, 0);
        layout.SetColumnSpan(_windConvention, 3);
        var headers = new[] { "Altitude", "Knots", "", "Direction °" };
        for (var i = 0; i < 4; i++) layout.Controls.Add(new Label { Text = headers[i], AutoSize = true, Anchor = i is 1 or 3 ? AnchorStyles.None : AnchorStyles.Left, Margin = new Padding(0, W(12), 0, W(8)) }, i, 1);
        var names = new[] { "26,000 ft", "6,600 ft", "Ground" };
        var metres = new[] { "8,000 m", "2,000 m", "33 ft / 10 m" };
        for (var i = 0; i < 3; i++)
        {
            var index = i;
            _windSpeed[i] = Number("WeatherWindSpeed" + i, 0, 194, i == 0 ? 9 : i == 1 ? 8 : 2);
            _windDirection[i] = Number("WeatherWindDirection" + i, 0, 359, i == 0 ? 18 : i == 1 ? 286 : 138);
            ((WeatherNumberBox)_windSpeed[i]).ShowSpinner = true;
            ((WeatherNumberBox)_windDirection[i]).ShowSpinner = true;
            _windSpeed[i].Increment = 1;
            _windArrow[i] = new WeatherWindDial { Name = "WeatherWindDial" + i, Width = W(48), Height = W(48),
                Anchor = AnchorStyles.None, AccessibleName = names[i] + " wind blows-to direction", BearingTo = (double)_windDirection[i].Value };
            _windArrow[i].BearingChanged += (_, _) =>
            {
                _windDirection[index].Value = (decimal)(Math.Round(_windArrow[index].BearingTo + (_windConvention.SelectedIndex == 1 ? 180 : 0)) % 360);
            };
            _windArrow[i].DragCompleted += (_, _) => OptionsChanged();
            _windDirection[i].ValueChanged += (_, _) =>
            {
                if (!_windArrow[index].IsDragging)
                    _windArrow[index].BearingTo = ((double)_windDirection[index].Value + (_windConvention.SelectedIndex == 1 ? 180 : 0)) % 360;
            };
            var altitude = new TableLayoutPanel { Dock = DockStyle.Top, AutoSize = true, ColumnCount = 1, Margin = new Padding(0, W(12), 0, W(12)) };
            altitude.Controls.Add(new Label { Text = names[i], AutoSize = true, Margin = new Padding(0) }, 0, 0);
            altitude.Controls.Add(new Label { Text = metres[i], Font = _captionFont, AutoSize = true, Margin = new Padding(0, W(3), 0, 0) }, 0, 1);
            var row = i == 2 ? 5 : i + 2;
            layout.Controls.Add(altitude, 0, row);
            _windSpeed[i].Dock = _windDirection[i].Dock = DockStyle.Top;
            _windSpeed[i].Width = _windDirection[i].Width = W(104);
            _windSpeed[i].Margin = _windDirection[i].Margin = new Padding(0, W(10), W(4), W(10));
            layout.Controls.Add(_windSpeed[i], 1, row);
            layout.Controls.Add(_windArrow[i], 2, row);
            layout.Controls.Add(_windDirection[i], 3, row);
        }
        var linkedAltitude = new TableLayoutPanel { Dock = DockStyle.Top, AutoSize = true, ColumnCount = 1, Margin = new Padding(0, W(12), 0, W(12)) };
        linkedAltitude.Controls.Add(new Label { Text = "1,600 ft", AutoSize = true, Margin = Padding.Empty }, 0, 0);
        linkedAltitude.Controls.Add(new Label { Text = "500 m · linked", Font = _captionFont, AutoSize = true, Margin = new Padding(0, W(3), 0, 0) }, 0, 1);
        layout.Controls.Add(linkedAltitude, 0, 4);
        _wind500Speed = Number("WeatherWindSpeed500", 0,
            (decimal)Math.Ceiling(WeatherWindCoupling.GroundTo500((double)_windSpeed[2].Maximum * WeatherSettings.KnotsToMps) / WeatherSettings.KnotsToMps), 0, 0, notify: false);
        _wind500Direction = Number("WeatherWindDirection500", 0, 359, 138);
        ((WeatherNumberBox)_wind500Speed).ShowSpinner = true;
        _wind500Speed.Increment = 1;
        _wind500Direction.Enabled = false;
        _wind500Speed.Margin = _wind500Direction.Margin = new Padding(0, W(10), W(4), W(10));
        layout.Controls.Add(_wind500Speed, 1, 4);
        layout.Controls.Add(_wind500Direction, 3, 4);
        _windSpeed[2].ValueChanged += (_, _) => { if (!_updating) RefreshLinkedWind(); };
        _windDirection[2].ValueChanged += (_, _) => { if (!_updating) RefreshLinkedWind(); };
        _wind500Speed.ValueChanged += (_, _) =>
        {
            if (_updating) return;
            _updating = true;
            try
            {
                var groundKnots = (decimal)(WeatherWindCoupling.Level500ToGround((double)_wind500Speed.Value * WeatherSettings.KnotsToMps) / WeatherSettings.KnotsToMps);
                _windSpeed[2].Value = Math.Clamp(groundKnots, _windSpeed[2].Minimum, _windSpeed[2].Maximum);
            }
            finally { _updating = false; }
            OptionsChanged();
        };
        var note = new Label { Text = "Ground and 1,600-ft speeds are linked. Upper layers stay independent. Circles show where the wind blows.", AutoSize = true, Margin = new Padding(0, W(18), 0, 0) };
        layout.Controls.Add(note, 0, 6);
        layout.SetColumnSpan(note, 4);
        layout.Layout += (_, _) =>
        {
            var width = layout.ClientSize.Width;
            if (!_zooming && width > 0 && _zoomGeometry.ContainsKey(layout) && note.Top > 0)
                layout.AutoSize = false;
            note.MaximumSize = new Size(Math.Max(1, layout.ClientSize.Width), 0);
            LayoutWindColumns();
        };
        ((MissionOptionsLayout)layout).LayoutCompleted += (_, _) =>
        {
            var width = layout.ClientSize.Width;
            if (!_zooming && width > 0 && _zoomGeometry.ContainsKey(layout) && note.Top > 0)
            {
                if (!layout.AutoSize) layout.Height = note.Top + note.GetPreferredSize(new Size(Math.Max(1, width - note.Margin.Horizontal), 0)).Height + note.Margin.Bottom;
            }
        };
        layout.Paint += (_, args) =>
        {
            using var separator = new Pen(BackColor.GetBrightness() < .5f ? Color.FromArgb(57, 72, 91) : Color.FromArgb(134, 151, 166));
            var y = layout.Padding.Top;
            var heights = layout.GetRowHeights();
            for (var row = 0; row < heights.Length; row++)
            {
                y += heights[row];
                if (row is >= 1 and <= 4) args.Graphics.DrawLine(separator, layout.Padding.Left, y, layout.Width - layout.Padding.Right, y);
            }
        };
        _windConvention.SelectedIndexChanged += (_, _) =>
        {
            if (_updating || _previousConvention == _windConvention.SelectedIndex) return;
            _updating = true;
            foreach (var direction in _windDirection) direction.Value = (direction.Value + 180) % 360;
            _wind500Direction.Value = _windDirection[2].Value;
            _previousConvention = _windConvention.SelectedIndex;
            _updating = false;
            OptionsChanged();
        };
        return layout;
    }

    private void LayoutWindColumns()
    {
        var width = _windLayout.ClientSize.Width;
        var altitude = Math.Clamp(width / 4, W(72), W(112));
        var dial = W(60);
        _windLayout.ColumnStyles[0].Width = altitude;
        _windLayout.ColumnStyles[2].Width = dial;
        // Refresh the owned wrappers after zoom or a narrow/wide resize; do not retain a shrunken width.
        var inputWidth = Math.Min(W(104), Math.Max(1, (width - altitude - dial) / 2 - W(4)));
        foreach (Control control in _windLayout.Controls)
            if (control is WeatherInputFrame { Input: NumericUpDown } frame)
            {
                frame.MaximumSize = new Size(W(104), 0);
                frame.Width = inputWidth;
            }
    }
    private void RefreshLinkedWind()
    {
        var previous = _updating;
        _updating = true;
        try
        {
            _wind500Speed.Value = (decimal)(WeatherWindCoupling.GroundTo500((double)_windSpeed[2].Value * WeatherSettings.KnotsToMps) / WeatherSettings.KnotsToMps);
            _wind500Direction.Value = _windDirection[2].Value;
        }
        finally { _updating = previous; }
    }

    private Control BuildAtmosphere()
    {
        _temperature = Number("WeatherTemperature", -80, 60, 15, 1);
        _pressure = Number("WeatherPressure", 19, 34, 30, 2, notify: false);
        _pressureUnit = Choice("WeatherPressureUnit", false, "inHg", "hPa", "mmHg");
        _visibility = Number("WeatherVisibility", .1m, 100, 80, 1);
        _turbulence = Number("WeatherTurbulence", 0, 194, 0, 2);
        _fogMode = Choice("WeatherFog", false, "Off", "Automatic", "Manual");
        _dustVisibility = Number("WeatherDustVisibility", 300, 3000, 300);
        _haloMode.Items.AddRange(new object[] { new DcsHaloPreset("off", "Off", null), new DcsHaloPreset("auto", "Automatic", null) });
        _haloMode.SelectedIndex = 1;
        var pressure = new TableLayoutPanel { Dock = DockStyle.Top, AutoSize = true, ColumnCount = 2 };
        pressure.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 65));
        pressure.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 35));
        pressure.Controls.Add(_pressure, 0, 0);
        pressure.Controls.Add(_pressureUnit, 1, 0);
        var layout = new TableLayoutPanel { Dock = DockStyle.Top, AutoSize = true, ColumnCount = 1 };
        layout.Controls.Add(Fields(1, ("Temperature (°C)", _temperature), ("QNH", pressure),
            ("Visibility (km)", _visibility), ("Turbulence (knots)", _turbulence),
            ("Fog", _fogMode), ("Ice halo", _haloMode)), 0, 0);
        ConfigureGrid(_fogGrid, ("After mission start (HH:mm:ss)", typeof(string)), ("Visibility (m)", typeof(double)), ("Thickness (m)", typeof(double)));
        _fogGrid.Rows.Add("00:00", 1500d, 200d);
        _fogFields = GridGroup("Manual fog schedule · 00:00:00 means mission start", _fogGrid, W(140));
        layout.Controls.Add(_fogFields, 0, 1);
        _crystalFields = Fields(1, ("Ice crystal preset", _crystals));
        layout.Controls.Add(_crystalFields, 0, 2);
        _dust.Margin = new Padding(W(10), W(12), 0, W(5));
        layout.Controls.Add(_dust, 0, 3);
        _dustFields = Fields(1, ("Dust visibility (metres)", _dustVisibility));
        layout.Controls.Add(_dustFields, 0, 4);
        _fogMode.SelectedIndexChanged += (_, _) => { RefreshOptionVisibility(); OptionsChanged(); };
        _haloMode.SelectedIndexChanged += (_, _) => { RefreshOptionVisibility(); OptionsChanged(); };
        _crystals.SelectedIndexChanged += (_, _) => OptionsChanged();
        _dust.CheckedChanged += (_, _) => { RefreshOptionVisibility(); OptionsChanged(); };
        _pressure.ValueChanged += (_, _) =>
        {
            if (_updating) return;
            _pressureMmHg = (double)_pressure.Value * PressureFactor();
            OptionsChanged();
        };
        _pressureUnit.SelectedIndexChanged += (_, _) => { if (!_updating) { RenderPressure(); OptionsChanged(); } };
        return layout;
    }

    private Control BuildTime()
    {
        _time = BuildTimeEditor();
        _time.Font = Font;
        var panel = new TableLayoutPanel { Dock = DockStyle.Top, AutoSize = true, ColumnCount = 1, Padding = new Padding(W(6)) };
        _changeDate.Margin = new Padding(W(8), W(8), 0, W(8));
        panel.Controls.Add(_changeDate, 0, 0);
        panel.Controls.Add(new Label { Text = "Leave the date off to keep the dropped mission's date.", AutoSize = true, Margin = new Padding(W(8)) }, 0, 1);
        panel.Controls.Add(Fields(1, ("Mission date", _date), ("Start time · local mission time", _time)), 0, 2);
        _changeTime.CheckedChanged += (_, _) => { RefreshOptionVisibility(); MissionDateInputChanged(); };
        _changeDate.CheckedChanged += (_, _) => { RefreshOptionVisibility(); MissionDateInputChanged(); };
        _date.ValueChanged += (_, _) => MissionDateInputChanged();
        _date.DateDraftChanged += (_, _) => MissionDateInputChanged();
        _date.DateTextRejected += message => { if (IsMissionDateSelected) SetStatus(message, true); };
        return panel;
    }

    private void ConfigureGrid(DataGridView grid, params (string Name, Type Type)[] columns)
    {
        grid.Dock = DockStyle.Fill;
        grid.AllowUserToAddRows = grid.AllowUserToDeleteRows = true;
        grid.BackgroundColor = BackColor;
        foreach (var column in columns)
            grid.Columns.Add(new DataGridViewTextBoxColumn { HeaderText = column.Name, ValueType = column.Type, SortMode = DataGridViewColumnSortMode.NotSortable });
        grid.CellValueChanged += (_, _) => OptionsChanged();
        grid.RowsRemoved += (_, _) => OptionsChanged();
        grid.DataError += (_, args) => { args.ThrowException = false; SetStatus("Check the values in the weather table.", error: true); };
    }

    private static Control GridGroup(string heading, DataGridView grid, int height)
    {
        var panel = new Panel { Dock = DockStyle.Top, Height = height, Margin = new Padding(8, 6, 8, 12) };
        var label = new Label { Text = heading, Dock = DockStyle.Top, Height = 28 };
        panel.Controls.Add(grid);
        panel.Controls.Add(label);
        return panel;
    }

    private double PressureFactor() => _pressureUnit.SelectedIndex == 0 ? WeatherSettings.InHgToMmHg
        : _pressureUnit.SelectedIndex == 1 ? WeatherSettings.HPaToMmHg : 1;

    private void RenderPressure()
    {
        var previous = _updating;
        _updating = true;
        try
        {
            var factor = PressureFactor();
            _pressure.DecimalPlaces = _pressureUnit.SelectedIndex == 0 ? 2 : 1;
            _pressure.Minimum = Math.Min(_pressure.Minimum, (decimal)(500 / factor));
            _pressure.Maximum = (decimal)(850 / factor);
            _pressure.Minimum = (decimal)(500 / factor);
            _pressure.Value = Math.Clamp((decimal)(_pressureMmHg / factor), _pressure.Minimum, _pressure.Maximum);
        }
        finally { _updating = previous; }
    }

    private void RefreshOptionVisibility()
    {
        if (_fogFields is null) return;
        _fogFields.Visible = _fogMode.SelectedIndex == 2;
        _crystalFields.Visible = _haloMode.SelectedItem is DcsHaloPreset halo && halo.Id is not ("auto" or "off");
        _dustFields.Visible = _dust.Checked;
        _dust.Enabled = _dust.Checked || _fogMode.SelectedIndex == 0;
        _fogMode.Enabled = !_dust.Checked || _fogMode.SelectedIndex != 0;
        _changeDate.Enabled = _timeHours.Enabled = _timeMinutes.Enabled = _changeTime.Checked;
        _date.Enabled = _changeTime.Checked && _changeDate.Checked;
        RefreshApplyAvailability();
    }
}
