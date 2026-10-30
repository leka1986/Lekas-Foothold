namespace FootholdConfigManager;

internal sealed partial class WeatherWindow
{
    private sealed record CloudChoice(string Mode, DcsCloudPreset? Preset)
    {
        public override string ToString() => Preset?.Name ?? (Mode == "clear" ? "No clouds" : "Custom / legacy clouds");
    }

    private readonly ComboBox _cloudPreset = new WeatherChoiceBox() { Name = "WeatherCloudPreset", DropDownStyle = ComboBoxStyle.DropDownList, Dock = DockStyle.Top };
    private ComboBox _baseUnit = null!;
    private NumericUpDown _base = null!;
    private readonly TrackBar _baseSlider = new() { Name = "WeatherCloudBaseSlider", Dock = DockStyle.Top, TickStyle = TickStyle.None };
    private readonly PictureBox _preview = new() { Dock = DockStyle.Top, SizeMode = PictureBoxSizeMode.Zoom };
    private readonly Label _selectedCloud = new() { AutoSize = true };
    private readonly Label _baseRange = new() { AutoSize = true };
    private readonly FlowLayoutPanel _gallery = new() { Name = "WeatherCloudGallery", Dock = DockStyle.Fill, AutoScroll = true, WrapContents = true };
    private readonly Dictionary<string, Image> _images = new(StringComparer.OrdinalIgnoreCase);
    private NumericUpDown _thickness = null!;
    private NumericUpDown _density = null!;
    private ComboBox _precipitation = null!;
    private TableLayoutPanel _cloudLayout = null!;
    private Control _legacyFields = null!;
    private TableLayoutPanel _cloudSide = null!;
    private double _baseMeters = 5460;

    private Control BuildClouds()
    {
        _gallery.SizeChanged += (_, _) => LayoutCloudCards();
        _base = Number("WeatherCloudBase", 0, 100000, 17913, notify: false);
        _baseUnit = Choice("WeatherCloudBaseUnit", false, "feet", "metres");
        _thickness = Number("WeatherCloudThickness", 200, 2000, 610);
        _density = Number("WeatherCloudDensity", 0, 10, 5);
        _precipitation = Choice("WeatherPrecipitation", "None", "Rain", "Thunderstorm", "Snow", "Snowstorm");
        _preview.Height = W(88);
        _cloudLayout = new TableLayoutPanel { Dock = DockStyle.Fill, ColumnCount = 1, RowCount = 2, MinimumSize = new Size(0, W(220)) };
        _cloudLayout.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        _cloudLayout.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        _cloudLayout.RowStyles.Add(new RowStyle(SizeType.Absolute, 0));
        var left = new TableLayoutPanel { Dock = DockStyle.Fill, ColumnCount = 1, RowCount = 2, Margin = new Padding(0, 0, W(12), 0) };
        left.RowStyles.Add(new RowStyle(SizeType.Absolute, W(66)));
        left.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        var choice = new TableLayoutPanel { Dock = DockStyle.Fill, ColumnCount = 1, RowCount = 2 };
        choice.Controls.Add(new Label { Text = "Cloud preset", AutoSize = true }, 0, 0);
        choice.Controls.Add(_cloudPreset, 0, 1);
        left.Controls.Add(choice, 0, 0);
        left.Controls.Add(new WeatherScrollHost(_gallery) { Dock = DockStyle.Fill }, 0, 1);
        var side = _cloudSide = new TableLayoutPanel { Name = "WeatherCloudAndWind", Dock = DockStyle.Top, ColumnCount = 1, AutoSize = true, Margin = Padding.Empty };
        side.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        _selectedCloud.Font = _boldFont;
        _selectedCloud.MaximumSize = new Size(W(230), 0);
        _selectedCloud.Margin = new Padding(0, W(8), 0, W(12));
        var previewRow = new TableLayoutPanel { Name = "WeatherSelectedPreset", Dock = DockStyle.Top, Height = W(160), ColumnCount = 2, Margin = Padding.Empty };
        previewRow.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 60));
        previewRow.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 40));
        _preview.Dock = DockStyle.Fill;
        _selectedCloud.Anchor = AnchorStyles.Left;
        _selectedCloud.Margin = new Padding(W(12), 0, 0, 0);
        previewRow.Controls.Add(_preview, 0, 0);
        previewRow.Controls.Add(_selectedCloud, 1, 0);
        side.Controls.Add(previewRow, 0, 0);
        side.Controls.Add(new Label { Text = "Cloud base", AutoSize = true, Margin = new Padding(0, W(10), 0, W(6)) }, 0, 1);
        var baseRow = new TableLayoutPanel { Dock = DockStyle.Top, Height = W(48), ColumnCount = 2 };
        baseRow.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        baseRow.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, W(86)));
        baseRow.Controls.Add(_base, 0, 0);
        baseRow.Controls.Add(_baseUnit, 1, 0);
        side.Controls.Add(baseRow, 0, 2);
        side.Controls.Add(_baseSlider, 0, 3);
        side.Controls.Add(_baseRange, 0, 4);
        var wind = BuildWind();
        wind.Margin = new Padding(0, W(18), 0, 0);
        side.Controls.Add(wind, 0, 5);
        _legacyFields = Fields(("Thickness (metres)", _thickness), ("Density (0–10)", _density), ("Precipitation", _precipitation));
        _legacyFields.Visible = false;
        _cloudLayout.SizeChanged += (_, _) => UpdateCloudMinimum();
        _cloudLayout.ParentChanged += (_, _) =>
        {
            if (_cloudLayout.Parent is { } viewport) viewport.SizeChanged += (_, _) => UpdateCloudMinimum();
        };
        _cloudLayout.Controls.Add(left, 0, 0);
        _cloudLayout.Controls.Add(_legacyFields, 0, 1);
        _cloudPreset.SelectedIndexChanged += (_, _) =>
        {
            if (_updating) return;
            if (_cloudPreset.SelectedItem is CloudChoice selected)
                _baseMeters = selected.Preset?.DefaultBaseMeters ?? 1500;
            RenderCloudSelection();
            OptionsChanged();
        };
        _base.ValueChanged += (_, _) =>
        {
            if (_updating) return;
            _baseMeters = (double)_base.Value * (_baseUnit.SelectedIndex == 0 ? WeatherSettings.FeetToMeters : 1);
            RenderBase();
            OptionsChanged();
        };
        _baseUnit.SelectedIndexChanged += (_, _) => { if (!_updating) { RenderBase(); OptionsChanged(); } };
        EventHandler commitBaseSlider = (_, _) =>
        {
            if (_updating) return;
            if (_baseSlider.Capture)
            {
                _updating = true;
                try { _base.Value = _baseSlider.Value; }
                finally { _updating = false; }
                return;
            }
            _baseMeters = _baseSlider.Value * (_baseUnit.SelectedIndex == 0 ? WeatherSettings.FeetToMeters : 1);
            RenderBase();
            OptionsChanged();
        };
        _baseSlider.Scroll += commitBaseSlider;
        _baseSlider.MouseCaptureChanged += commitBaseSlider;
        return _cloudLayout;
    }

    private void PopulateClouds(WeatherSettings settings)
    {
        var wasUpdating = _updating;
        _updating = true;
        try
        {
            _preview.Image = null;
            foreach (Control control in _gallery.Controls.Cast<Control>().ToArray()) control.Dispose();
            _gallery.Controls.Clear();
            foreach (var image in _images.Values) image.Dispose();
            _images.Clear();
            _cloudPreset.Items.Clear();
            _cloudPreset.Items.Add(new CloudChoice("clear", null));
            foreach (var preset in _catalog!.CloudPresets
                .GroupBy(preset => preset.Name.TrimEnd('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ' '), StringComparer.OrdinalIgnoreCase)
                .SelectMany(group => group))
            {
                var choice = new CloudChoice("preset", preset);
                _cloudPreset.Items.Add(choice);
                var button = new WeatherCloudCard
                {
                    Text = preset.Name, Tag = preset.Id, Width = W(178), Height = W(125),
                    Margin = new Padding(W(4)), TextAlign = ContentAlignment.BottomCenter,
                    ImageAlign = ContentAlignment.TopCenter, TextImageRelation = TextImageRelation.ImageAboveText,
                    FlatStyle = FlatStyle.Flat, Image = GetImage(preset.ThumbnailPath, thumbnail: true),
                    UseVisualStyleBackColor = false
                };
                button.Click += (_, _) => _cloudPreset.SelectedItem = choice;
                _gallery.Controls.Add(button);
                AttachDrop(button);
            }
            _cloudPreset.Items.Add(new CloudChoice("custom", null));
            var selected = _cloudPreset.Items.Cast<CloudChoice>().FirstOrDefault(choice =>
                choice.Mode == settings.CloudMode && (choice.Preset is null || choice.Preset.Id == settings.CloudPreset));
            _cloudPreset.SelectedItem = selected ?? _cloudPreset.Items.Cast<CloudChoice>().First(choice => choice.Preset is not null);
            _baseMeters = settings.CloudBaseMeters;
        }
        finally { _updating = wasUpdating; }
        LayoutCloudCards();
        RenderCloudSelection();
    }

    private void LayoutCloudCards()
    {
        if (_zooming) return;
        // Reserve the shared bar gutter once; native bar visibility must not change card widths.
        var available = _gallery.Parent!.ClientSize.Width - SystemInformation.VerticalScrollBarWidth;
        if (available <= 0) return;
        var margin = _gallery.Controls.Count > 0 ? _gallery.Controls[0].Margin.Horizontal : 2 * W(4);
        var columns = _uiScale > 1 ? Math.Clamp(available / W(168), 1, 3)
            : Math.Max(1, (int)Math.Ceiling(available / (double)(W(190) + margin)));
        var width = Math.Max(W(100), (available - columns * margin) / columns);
        _gallery.SuspendLayout();
        foreach (Button card in _gallery.Controls)
            card.Size = new Size(width, (int)(width / 1.95) + W(40));
        _gallery.ResumeLayout();
    }

    private void RenderCloudSelection()
    {
        if (_cloudPreset.SelectedItem is not CloudChoice choice) return;
        _selectedCloud.Text = choice.ToString();
        _preview.Image = GetImage(choice.Preset?.ThumbnailPath, thumbnail: false);
        _preview.Visible = _preview.Image is not null;
        _legacyFields.Visible = choice.Mode == "custom";
        _cloudLayout.RowStyles[1].Height = choice.Mode == "custom" ? W(220) : 0;
        foreach (Button button in _gallery.Controls)
        {
            var selected = Equals(button.Tag, choice.Preset?.Id);
            button.FlatAppearance.BorderSize = selected ? 2 : 1;
            button.FlatAppearance.BorderColor = selected ? (BackColor.GetBrightness() < .5f ? Color.FromArgb(86, 156, 214) : Color.FromArgb(30, 120, 167)) : ControlPaint.Light(BackColor, .2f);
        }
        UpdateCloudMinimum();
        RenderBase();
    }

    private void UpdateCloudMinimum()
    {
        if (_zooming) return;
        _cloudLayout.MinimumSize = new Size(0, W(220));
    }

    private void RenderBase()
    {
        if (_cloudPreset.SelectedItem is not CloudChoice choice) return;
        var wasUpdating = _updating;
        _updating = true;
        try
        {
            var factor = _baseUnit.SelectedIndex == 0 ? WeatherSettings.FeetToMeters : 1;
            var minMeters = choice.Preset?.MinimumBaseMeters ?? 0;
            var maxMeters = choice.Preset?.MaximumBaseMeters ?? 30000;
            _baseMeters = Math.Clamp(_baseMeters, minMeters, maxMeters);
            var min = (decimal)Math.Ceiling(minMeters / factor);
            var max = (decimal)Math.Floor(maxMeters / factor);
            if (max < min) max = min;
            _base.Minimum = Math.Min(_base.Minimum, min);
            _base.Maximum = max;
            _base.Minimum = min;
            _base.Value = Math.Clamp((decimal)Math.Round(_baseMeters / factor), min, max);
            _baseSlider.Minimum = Math.Min(_baseSlider.Minimum, (int)min);
            _baseSlider.Maximum = (int)max;
            _baseSlider.Minimum = (int)min;
            _baseSlider.Value = Math.Clamp((int)_base.Value, (int)min, (int)max);
            _base.Enabled = _baseSlider.Enabled = choice.Mode != "clear" && min != max;
            _baseRange.Text = choice.Mode == "clear" ? "Clear sky" : "Range: " + min.ToString("N0") + "–" + max.ToString("N0") + " " + (_baseUnit.SelectedIndex == 0 ? "ft" : "m");
        }
        finally { _updating = wasUpdating; }
    }

    private Image? GetImage(string? path, bool thumbnail)
    {
        if (path is null) return null;
        var key = path; // Gallery and preview share the original; paint scales it for the current zoom.
        if (_images.TryGetValue(key, out var cached)) return cached;
        try
        {
            using var stream = new MemoryStream(File.ReadAllBytes(path));
            using var source = Image.FromStream(stream);
            var image = new Bitmap(source);
            _images.Add(key, image);
            return image;
        }
        catch (Exception ex) when (ex is IOException or UnauthorizedAccessException or ArgumentException)
        {
            return null;
        }
    }
}
