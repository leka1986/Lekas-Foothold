using System.Drawing.Drawing2D;

namespace FootholdConfigManager;

internal sealed partial class WeatherWindow : Form
{
    private readonly ComboBox _installation = new WeatherChoiceBox() { Name = "WeatherInstallation", DropDownStyle = ComboBoxStyle.DropDownList, Dock = DockStyle.Fill };
    private readonly ComboBox _profiles = new WeatherChoiceBox() { Name = "WeatherProfiles", DropDownStyle = ComboBoxStyle.DropDownList, Dock = DockStyle.Fill };
    private TableLayoutPanel _weatherBody = null!;
    private Control _cloudWeatherSection = null!;
    private Control _atmosphereSection = null!;
    private readonly Panel _drop = new() { Name = "WeatherDrop", Dock = DockStyle.Top, AutoSize = true, Padding = new Padding(10, 6, 10, 6), Margin = new Padding(0, 6, 0, 0) };
    private readonly Label _installStatus = new() { AutoSize = true, Text = "DCS installation · detecting presets…" };
    private readonly Label _summary = new() { Name = "WeatherSummary", Dock = DockStyle.Fill, AutoEllipsis = true, TextAlign = ContentAlignment.MiddleLeft };
    private readonly Label _status = new() { Name = "WeatherStatus", Visible = false, Dock = DockStyle.Fill, AutoEllipsis = true, TextAlign = ContentAlignment.MiddleLeft };
    private Button _browse = null!;
    private Button _close = null!;
    private Button _openOutput = null!;
    private TableLayoutPanel _root = null!;

    private int S(int pixels) => (int)Math.Round(pixels * _uiScale);
    private int W(int pixels) => (int)Math.Round(pixels * _weatherUiScale);
    private int InputSize(Control control, int pixels) => (int)Math.Round(pixels * (_weatherBody.Contains(control) ? _weatherUiScale : _uiScale));
    private void LayoutWeatherColumns() => _weatherBody.ColumnStyles[1].Width = Math.Max(W(350), _weatherBody.ClientSize.Width * (_uiScale < 1 ? .46f : .39f));

    private Button Button(string text, Action action, string? name = null)
    {
        var button = _makeButton(text, action);
        button.Name = name ?? "";
        button.Font = Font;
        button.AutoSize = false;
        button.Dock = DockStyle.None;
        button.Anchor = AnchorStyles.Top | AnchorStyles.Right;
        button.MinimumSize = new Size(S(80), S(32));
        button.Size = new Size(Math.Max(S(80), TextRenderer.MeasureText(text, Font).Width + S(36)), S(32));
        button.Margin = new Padding(S(4), 0, 0, 0);
        return button;
    }

    private NumericUpDown Number(string name, decimal min, decimal max, decimal value, int decimals = 0, bool notify = true)
    {
        var number = new WeatherNumberBox
        {
            Name = name, Minimum = min, Maximum = max, Value = value, DecimalPlaces = decimals,
            Increment = decimals > 0 ? (decimal)Math.Pow(.1, decimals) : 1,
            Dock = DockStyle.Top, Width = S(150), ThousandsSeparator = true
        };
        if (notify) number.ValueChanged += (_, _) => OptionsChanged();
        return number;
    }

    private ComboBox Choice(string name, params string[] choices) => Choice(name, true, choices);

    private ComboBox Choice(string name, bool notify, params string[] choices)
    {
        var combo = new WeatherChoiceBox { Name = name, DropDownStyle = ComboBoxStyle.DropDownList, Dock = DockStyle.Top };
        combo.Items.AddRange(choices);
        if (choices.Length > 0) combo.SelectedIndex = 0;
        if (notify) combo.SelectedIndexChanged += (_, _) => OptionsChanged();
        return combo;
    }

    private TableLayoutPanel Fields(params (string Label, Control Input)[] fields) => Fields(2, fields);

    private TableLayoutPanel Fields(int columns, params (string Label, Control Input)[] fields)
    {
        var table = new TableLayoutPanel { Dock = DockStyle.Top, AutoSize = true, ColumnCount = columns, Padding = new Padding(2, 6, 2, 6) };
        for (var column = 0; column < columns; column++) table.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100f / columns));
        for (var i = 0; i < fields.Length; i++)
        {
            var group = new TableLayoutPanel { Dock = DockStyle.Top, AutoSize = true, ColumnCount = 1, Margin = new Padding(0, S(8), S(20), S(14)) };
            group.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            group.Controls.Add(new Label { Text = fields[i].Label, AutoSize = true, Margin = new Padding(0, 0, 0, S(6)) }, 0, 0);
            group.Controls.Add(fields[i].Input, 0, 1);
            table.Controls.Add(group, i % columns, i / columns);
        }
        table.ParentChanged += (_, _) =>
        {
            if (table.Parent is not { } parent) return;
            void FitWidth(object? sender, EventArgs args) => table.MaximumSize = new Size(Math.Max(1, parent.ClientSize.Width - table.Margin.Horizontal - parent.Padding.Horizontal), 0);
            parent.SizeChanged += FitWidth;
            FitWidth(parent, EventArgs.Empty);
        };
        return table;
    }

    private static FlowLayoutPanel Row(params Control[] controls)
    {
        var row = new FlowLayoutPanel { AutoSize = true, Dock = DockStyle.Top, WrapContents = true, Margin = new Padding(0) };
        row.Controls.AddRange(controls);
        return row;
    }

    private Control Heading(string text) => new Label { Text = text, UseMnemonic = false, AutoSize = true, Margin = new Padding(0, S(20), 0, S(8)), Font = _boldFont };

    private void BuildShell()
    {
        _root = new TableLayoutPanel { Dock = DockStyle.Fill, Padding = new Padding(S(12)), ColumnCount = 1, RowCount = 3 };
        _root.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        _root.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        _root.RowStyles.Add(new RowStyle(SizeType.Absolute, S(28)));
        _root.RowStyles.Add(new RowStyle(SizeType.AutoSize, 0));
        // Preserve useful control space when the unchanged Config minimum window is
        // shorter than this workspace at a large zoom; use the same scroll presenter.
        var viewport = new MainForm.BackgroundFocusPanel { Name = "MissionSettingsScroll", AutoScroll = true };
        _root.Dock = DockStyle.Top;
        _root.Height = S(650);
        viewport.Controls.Add(_root);
        viewport.Layout += (_, _) => _root.Height = Math.Max(S(650), viewport.ClientSize.Height);
        Controls.Add(new WeatherScrollHost(viewport) { Dock = DockStyle.Fill });
        _workspaceTabs.ItemSize = new Size(S(142), S(38));
        var weatherPage = new TabPage("Weather") { Padding = Padding.Empty };
        var weatherBody = _weatherBody = new TableLayoutPanel { Name = "WeatherBody", Dock = DockStyle.Fill, ColumnCount = 2, RowCount = 2, Margin = Padding.Empty };
        weatherBody.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        weatherBody.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, S(390)));
        weatherBody.RowStyles.Add(new RowStyle(SizeType.Absolute, S(132)));
        weatherBody.SizeChanged += (_, _) => LayoutWeatherColumns();
        weatherBody.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        weatherPage.Controls.Add(weatherBody);
        _workspaceTabs.TabPages.Add(weatherPage);
        _workspaceTabs.TabPages.Add(BuildMissionOptionsTab());
        var workspace = new Panel { Dock = DockStyle.Fill, Margin = Padding.Empty };
        workspace.Controls.Add(_workspaceTabs);
        _close = Button("Close", LeaveWeather, "WeatherClose");
        workspace.Controls.Add(_close);
        workspace.Layout += (_, _) =>
        {
            _close.Location = new Point(Math.Max(0, workspace.ClientSize.Width - _close.Width - S(4)), S(3));
            _close.BringToFront();
        };
        _root.Controls.Add(workspace, 0, 0);

        var install = new TableLayoutPanel { Name = "WeatherTopFields", Dock = DockStyle.Fill, ColumnCount = 2, RowCount = 4, Margin = new Padding(0, 0, S(16), 0), MaximumSize = new Size(S(680), 0) };
        install.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        install.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        install.RowStyles.Add(new RowStyle(SizeType.Absolute, S(22)));
        install.RowStyles.Add(new RowStyle(SizeType.Absolute, S(40)));
        install.RowStyles.Add(new RowStyle(SizeType.Absolute, S(22)));
        install.RowStyles.Add(new RowStyle(SizeType.Absolute, S(40)));
        install.Controls.Add(_installStatus, 0, 0);
        install.SetColumnSpan(_installStatus, 2);
        _installation.AccessibleName = "DCS installation";
        _installation.DropDownWidth = S(520);
        install.Controls.Add(_installation, 0, 1);
        var installActions = Row(Button("Choose…", ChooseInstallation), Button("Refresh", RefreshInstallation));
        installActions.WrapContents = false;
        install.Controls.Add(installActions, 1, 1);
        _installation.SelectedIndexChanged += async (_, _) =>
        {
            if (!_updating && _installation.SelectedItem is string path) await LoadInstallationAsync(path, true);
        };
        weatherBody.Controls.Add(install, 0, 0);

        var profileLabel = new Label { Text = "Weather profile", Dock = DockStyle.Fill, TextAlign = ContentAlignment.MiddleLeft };
        install.Controls.Add(profileLabel, 0, 2); install.SetColumnSpan(profileLabel, 2);
        _profiles.AccessibleName = "Weather profile";
        _profiles.DropDownWidth = S(400);
        install.Controls.Add(_profiles, 0, 3);
        install.Controls.Add(Button("Save profile…", SaveProfile), 1, 3);
        _profiles.SelectedIndexChanged += (_, _) =>
        {
            if (!_updating && _profiles.SelectedItem is WeatherNamedProfile profile) ApplySettings(profile.Settings);
        };

        weatherBody.Controls.Add(BuildClouds(), 0, 1);
        _cloudWeatherSection = _cloudSide;

        _cloudSide = new TableLayoutPanel { Name = "WeatherRightSettings", Dock = DockStyle.Top, AutoSize = true, ColumnCount = 1, Margin = Padding.Empty };
        _cloudSide.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        var timeHeading = Heading("Date & time"); timeHeading.Margin = new Padding(0, 0, 0, S(8));
        _cloudSide.Controls.Add(timeHeading, 0, 0);
        var time = BuildTime();
        _cloudSide.Controls.Add(time, 0, 1);
        _cloudWeatherSection.Margin = new Padding(0, S(18), 0, 0);
        _cloudSide.Controls.Add(_cloudWeatherSection, 0, 2);
        _cloudSide.Controls.Add(Heading("Atmosphere"), 0, 3);
        _atmosphereSection = BuildAtmosphere();
        _cloudSide.Controls.Add(_atmosphereSection, 0, 4);
        var sideViewport = new Panel { Name = "WeatherDetailsScroll", AutoScroll = true };
        sideViewport.Controls.Add(_cloudSide);
        var sideHost = new WeatherScrollHost(sideViewport) { Name = "WeatherDetailsHost", Dock = DockStyle.Fill, Margin = new Padding(S(14), S(8), 0, 0) };
        weatherBody.Controls.Add(sideHost, 1, 0);
        weatherBody.SetRowSpan(sideHost, 2);

        var dropLayout = new TableLayoutPanel { Dock = DockStyle.Top, AutoSize = true, ColumnCount = 4, RowCount = 3, Margin = Padding.Empty };
        dropLayout.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, S(245)));
        dropLayout.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        dropLayout.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        dropLayout.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        var dropTitle = new Label { Text = "Choose settings, then drop a .miz", AutoSize = true, Font = _boldFont, Margin = Padding.Empty };
        var dropHelp = new Label { Text = "New MIZ · original unchanged", AutoSize = true, Margin = Padding.Empty };
        dropLayout.Controls.Add(dropTitle, 0, 0);
        dropLayout.Controls.Add(dropHelp, 0, 1);
        _browse = Button("Browse…", BrowseMiz, "WeatherBrowse");
        _browse.Anchor = AnchorStyles.Right;
        dropLayout.Controls.Add(_browse, 3, 0);
        dropLayout.SetRowSpan(_browse, 2);
        _drop.Controls.Add(dropLayout);
        _applyWeather.Checked = _preferences.ApplyWeather;
        _applyMissionOptions.Checked = _preferences.ApplyMissionOptions;
        _applyWeather.CheckedChanged += (_, _) => { RefreshApplyAvailability(); RefreshSummary(); };
        _applyMissionOptions.CheckedChanged += (_, _) => { RefreshApplyAvailability(); RefreshSummary(); };
        var apply = new TableLayoutPanel { AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink,
            ColumnCount = 4, RowCount = 1, Anchor = AnchorStyles.Right, Margin = Padding.Empty };
        apply.Controls.Add(new Label { Text = "Apply:", AutoSize = true, Anchor = AnchorStyles.Left,
            TextAlign = ContentAlignment.MiddleLeft }, 0, 0);
        _applyWeather.Anchor = _changeTime.Anchor = _applyMissionOptions.Anchor = AnchorStyles.Left;
        apply.Controls.Add(_applyWeather, 1, 0);
        apply.Controls.Add(_changeTime, 2, 0);
        apply.Controls.Add(_applyMissionOptions, 3, 0);
        dropLayout.Controls.Add(apply, 2, 0);
        dropLayout.SetRowSpan(apply, 2);
        _openOutput = Button("Open output folder", OpenOutputFolder);
        _openOutput.Visible = false;
        var statusArea = new TableLayoutPanel { Dock = DockStyle.Fill, AutoSize = true,
            ColumnCount = 1, RowCount = 2, Margin = new Padding(S(12), 0, S(12), 0) };
        statusArea.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        statusArea.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        statusArea.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        _status.MinimumSize = new Size(0, S(32));
        _status.Margin = Padding.Empty;
        statusArea.Controls.Add(_status, 0, 0);
        statusArea.Controls.Add(_openOutput, 0, 1);
        dropLayout.Controls.Add(statusArea, 1, 0);
        dropLayout.SetRowSpan(statusArea, 2);
        var stackedStatus = false;
        dropLayout.Layout += (_, _) =>
        {
            var stack = dropLayout.ClientSize.Width < S(525) + apply.PreferredSize.Width + _browse.Width;
            if (stack != stackedStatus)
            {
                stackedStatus = stack;
                dropLayout.SuspendLayout();
                dropLayout.ColumnStyles[0].SizeType = stack ? SizeType.Percent : SizeType.Absolute;
                dropLayout.ColumnStyles[0].Width = stack ? 100 : S(245);
                dropLayout.ColumnStyles[1].SizeType = stack ? SizeType.Absolute : SizeType.Percent;
                dropLayout.ColumnStyles[1].Width = stack ? 0 : 100;
                dropLayout.SetColumnSpan(dropTitle, stack ? 2 : 1);
                dropLayout.SetColumnSpan(dropHelp, stack ? 2 : 1);
                dropLayout.SetRowSpan(statusArea, stack ? 1 : 2);
                dropLayout.SetCellPosition(statusArea, new TableLayoutPanelCellPosition(stack ? 0 : 1, stack ? 2 : 0));
                dropLayout.SetColumnSpan(statusArea, stack ? 4 : 1);
                dropLayout.ResumeLayout(false);
            }
            if (!stack && dropLayout.ColumnStyles[0].Width != S(245)) dropLayout.ColumnStyles[0].Width = S(245);
            var width = Math.Max(1, dropLayout.GetColumnWidths()[0]);
            var limit = new Size(width, 0);
            if (dropTitle.MaximumSize != limit) dropTitle.MaximumSize = dropHelp.MaximumSize = limit;
        };
        _workspaceTabs.SelectedIndexChanged += (_, _) => RefreshSummary();
        _drop.Paint += (_, args) =>
        {
            using var pen = new Pen(SystemColors.Highlight) { DashStyle = DashStyle.Dash };
            args.Graphics.DrawRectangle(pen, 0, 0, _drop.Width - 1, _drop.Height - 1);
        };
        _root.Controls.Add(_summary, 0, 1);
        _root.Controls.Add(_drop, 0, 2);
        AttachDrop(this);


    }

    internal DragDropEffects WeatherDropEffect(DragEventArgs args) =>
        !_busy && CanApplySelection && args.Data?.GetData(DataFormats.FileDrop) is string[] paths
            && paths.Length == 1 && Path.GetExtension(paths[0]).Equals(".miz", StringComparison.OrdinalIgnoreCase)
            ? DragDropEffects.Copy : DragDropEffects.None;

    internal Task ApplyDroppedMizAsync(DragEventArgs args) => WeatherDropEffect(args) == DragDropEffects.Copy
        ? ApplyMizAsync(((string[])args.Data!.GetData(DataFormats.FileDrop)!)[0]) : Task.CompletedTask;

    private void AttachDrop(Control control, bool includeChildren = true)
    {
        control.AllowDrop = true;
        control.DragEnter += (_, args) => args.Effect = WeatherDropEffect(args);
        control.DragDrop += async (_, args) => await ApplyDroppedMizAsync(args);
        if (includeChildren) foreach (Control child in control.Controls) AttachDrop(child);
    }
}
