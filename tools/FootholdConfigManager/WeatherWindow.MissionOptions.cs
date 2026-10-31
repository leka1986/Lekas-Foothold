using System.Text.Json;

namespace FootholdConfigManager;

internal sealed partial class WeatherWindow
{
    private readonly TabControl _workspaceTabs = new WeatherPreviewTabs { Name = "MissionWorkspaceTabs", Dock = DockStyle.Fill };
    private readonly CheckBox _applyWeather = new WeatherCheckBox() { Name = "WeatherApplyWeather", Text = "Weather", AutoSize = true };
    private readonly CheckBox _applyMissionOptions = new WeatherCheckBox() { Name = "WeatherApplyMissionOptions", Text = "Mission options", AutoSize = true };
    private MissionOptionsSettings _missionOptions = new();
    private Action<MissionOptionsSettings> _applyMissionOptionsDraft = null!;

    private sealed record MissionChoice<T>(string Label, T Value)
    {
        public override string ToString() => Label;
    }

    private sealed class MissionOptionsLayout : TableLayoutPanel
    {
        internal event EventHandler? LayoutCompleted;

        protected override void OnLayout(LayoutEventArgs args)
        {
            base.OnLayout(args);
            LayoutCompleted?.Invoke(this, EventArgs.Empty);
        }
    }

    private TabPage BuildMissionOptionsTab()
    {
        var table = new MissionOptionsLayout { Name = "MissionOptionsTable", Dock = DockStyle.Top, AutoSize = true, ColumnCount = 3, Padding = new Padding(S(8)), MaximumSize = new Size(S(820), 0) };
        table.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        table.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, S(72)));
        table.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, S(230)));
        var row = 0;
        var separatorRows = new HashSet<int>();
        var separatorPositions = new List<int>();
        var resetters = new List<Action<MissionOptionsSettings>>();
        var groupHeaders = new List<(Label Title, int Row)>();
        var groupFrames = new List<(Rectangle Frame, Rectangle Header)>();
        var restore = Button("Restore Foothold defaults", () =>
        {
            if (MessageBox.Show(DialogOwner,
                    "Restore Mission options to the Foothold defaults?" + Environment.NewLine + Environment.NewLine +
                    "This replaces the current Mission options in the Manager. Weather, date and time stay unchanged.",
                    "Restore Foothold defaults", MessageBoxButtons.YesNo, MessageBoxIcon.Question,
                    MessageBoxDefaultButton.Button2) != DialogResult.Yes) return;
            var defaults = MissionOptionsSettings.CreateFootholdDefaults();
            _applyMissionOptionsDraft(defaults);
            RefreshSummary();
            SetStatus("Caucasus Foothold mission option defaults restored. Export a MIZ to apply them.");
        }, "MissionRestoreDefaults");
        var help = new Label { Text = "Enforce makes the mission use the value on the right. Unchecked means this option is not enforced.",
            AutoSize = true, Dock = DockStyle.Top, Margin = new Padding(0, 0, 0, S(16)) };
        help.MaximumSize = new Size(S(550), 0);
        table.Controls.Add(help, 0, row); table.SetColumnSpan(help, 2);
        table.Controls.Add(restore, 2, row++);
        table.Controls.Add(new Label { Text = "Enforce", AutoSize = true, Font = _boldFont, Anchor = AnchorStyles.None }, 1, row);
        table.Controls.Add(new Label { Text = "Option", AutoSize = true, Font = _boldFont }, 0, row);
        table.Controls.Add(new Label { Text = "Value", AutoSize = true, Font = _boldFont, Anchor = AnchorStyles.Right }, 2, row++);
        separatorRows.Add(row - 1);
        Group("General");
        AddBoolean("CrashRecovery", "Crash auto-recovery", options => options.CrashRecovery);
        AddBoolean("ExternalViews", "External Views", options => options.ExternalViews);
        var radios = new List<RadioButton>();
        var enforceF10 = Enforce("F10View", _missionOptions.F10View, Array.Empty<Control>());
        table.Controls.Add(enforceF10, 1, row);
        var f10Label = Label("F10 View Options");
        table.Controls.Add(f10Label, 0, row++);
        separatorRows.Add(row - 1);
        var editExtended = new Button { Name = "MissionExtendedF10Edit", FlatStyle = FlatStyle.Flat, UseVisualStyleBackColor = false };
        editExtended.Click += (_, _) => ShowExtendedF10Options();
        editExtended.MinimumSize = Size.Empty;
        editExtended.Size = new Size(S(32), S(28));
        editExtended.Margin = new Padding(0, 0, S(6), 0);
        editExtended.AccessibleName = "Configure Extended F10 view";
        editExtended.AccessibleDescription = "Configure visibility by role for the Extended F10 view.";
        var extendedTip = new ToolTip();
        extendedTip.SetToolTip(editExtended, "Configure Extended F10");
        editExtended.Disposed += (_, _) => extendedTip.Dispose();
        editExtended.Paint += (_, args) =>
        {
            var scale = Math.Min(editExtended.ClientSize.Width / 32f, editExtended.ClientSize.Height / 28f);
            var iconColor = !editExtended.Enabled ? SystemColors.GrayText
                : BackColor.GetBrightness() < .5f ? editExtended.ForeColor : ((WeatherPreviewTabs)_workspaceTabs).Accent;
            using var pen = new Pen(iconColor, Math.Max(1, scale));
            args.Graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
            Gear(12 * scale, 18 * scale, 8 * scale);
            Gear(23 * scale, 9 * scale, 5.5f * scale);
            void Gear(float x, float y, float radius)
            {
                var points = new PointF[32];
                for (var index = 0; index < points.Length; index++)
                {
                    var angle = index * Math.PI / 16;
                    var edge = index % 4 is 0 or 3 ? radius * .72f : radius;
                    points[index] = new PointF(x + (float)Math.Cos(angle) * edge, y + (float)Math.Sin(angle) * edge);
                }
                args.Graphics.DrawPolygon(pen, points);
                args.Graphics.DrawEllipse(pen, x - radius * .32f, y - radius * .32f, radius * .64f, radius * .64f);
            }
        };
        void UpdateExtendedAvailability() => editExtended.Enabled = _missionOptions.F10View.Enforce && _missionOptions.F10View.Value == "optview_extended";
        UpdateExtendedAvailability();
        foreach (var choice in MissionOptionsSettings.F10Choices.Append((Label: "Extended", Value: "optview_extended")))
        {
            var radio = new WeatherRadioButton { Name = "MissionF10_" + choice.Value, AutoSize = false, Size = new Size(S(22), S(24)),
                CheckAlign = ContentAlignment.MiddleRight, Anchor = AnchorStyles.Right, Margin = new Padding(0, S(4), S(12), S(4)),
                AccessibleName = choice.Label, Tag = choice.Value, Checked = _missionOptions.F10View.Value == choice.Value, Enabled = _missionOptions.F10View.Enforce };
            radio.CheckedChanged += (_, _) =>
            {
                if (!radio.Checked) return;
                foreach (var peer in radios)
                    if (!ReferenceEquals(peer, radio)) peer.Checked = false;
                _missionOptions.F10View.Value = choice.Value;
                UpdateExtendedAvailability();
                RefreshSummary();
            };
            radios.Add(radio);
            var label = Label(choice.Label); label.Margin = new Padding(S(24), S(4), 0, S(4));
            table.Controls.Add(label, 0, row);
            if (choice.Value == "optview_extended")
            {
                radio.Margin = Padding.Empty;
                var actions = Row(editExtended, radio);
                actions.Name = "MissionExtendedF10Actions";
                actions.Dock = DockStyle.None; actions.Anchor = AnchorStyles.Right; actions.WrapContents = false;
                actions.Margin = new Padding(0, S(2), S(12), S(2));
                table.Controls.Add(actions, 2, row++);
            }
            else table.Controls.Add(radio, 2, row++);
        }
        enforceF10.CheckedChanged += (_, _) => { foreach (var radio in radios) radio.Enabled = enforceF10.Checked; UpdateExtendedAvailability(); };
        resetters.Add(defaults =>
        {
            _missionOptions.F10View.Value = defaults.F10View.Value;
            _missionOptions.F10View.Enforce = defaults.F10View.Enforce;
            foreach (var radio in radios) radio.Checked = (string)radio.Tag! == defaults.F10View.Value;
            enforceF10.Checked = defaults.F10View.Enforce;
            foreach (var radio in radios) radio.Enabled = defaults.F10View.Enforce;
        });
        AddChoice("Labels", "Labels", options => options.Labels, MissionOptionsSettings.LabelChoices);
        AddChoice("SpottingDots", "Spotting Dots", options => options.SpottingDots, MissionOptionsSettings.SpottingChoices);
        AddBoolean("SimplifiedFlight", "Simplified Flight Model", options => options.SimplifiedFlight);
        AddBoolean("Immortal", "Immortal", options => options.Immortal);
        AddBoolean("UnlimitedFuel", "Unlimited Fuel", options => options.UnlimitedFuel);
        AddBoolean("UnlimitedWeapons", "Unlimited Weapons", options => options.UnlimitedWeapons);
        AddBoolean("EasyCommunication", "Easy Communication", options => options.EasyCommunication);
        AddBoolean("RadioAssists", "Radio Assists", options => options.RadioAssists);
        AddBoolean("UnrestrictedSatnav", "Unrestricted SATNAV", options => options.UnrestrictedSatnav);
        AddBoolean("Padlock", "Padlock", options => options.Padlock);
        AddBoolean("WakeTurbulence", "Wake turbulence", options => options.WakeTurbulence);
        AddChoice("GEffects", "G-Effects", options => options.GEffects, MissionOptionsSettings.GEffectChoices);
        AddBoolean("RandomFailures", "Random System Failures", options => options.RandomFailures);
        AddBoolean("GWarmUp", "G Warm-Up In The Air", options => options.GWarmUp);
        AddBoolean("MiniHud", "Mini HUD", options => options.MiniHud);
        AddBoolean("CockpitVisualRecon", "Cockpit Visual Recon Mode", options => options.CockpitVisualRecon);
        AddBoolean("F10UserMarks", "F10 Map User Marks", options => options.F10UserMarks);
        AddChoice("CivilTraffic", "Civ. Traffic", options => options.CivilTraffic, MissionOptionsSettings.TrafficChoices);
        AddBirds();
        Group("Overlays");
        AddBoolean("CockpitStatusBar", "Cockpit Status Bar", options => options.CockpitStatusBar);
        AddBoolean("BattleDamage", "Battle Damage Assessment", options => options.BattleDamage);
        Group("Modules · Supercarrier");
        AddBoolean("DeckCrew", "Enable deck crew", options => options.DeckCrew);
        AddBoolean("Carrier1Mc", "Enable 1MC", options => options.Carrier1Mc);
        _applyMissionOptionsDraft = settings =>
        {
            var previous = _updating;
            _updating = true;
            try
            {
                foreach (var reset in resetters) reset(settings);
                _missionOptions.ExtendedF10 = settings.ExtendedF10;
            }
            finally { _updating = previous; }
        };
        table.LayoutCompleted += (_, _) =>
        {
            separatorPositions.Clear();
            groupFrames.Clear();
            var heights = table.GetRowHeights(); var y = table.Padding.Top;
            var tops = new int[heights.Length + 1]; tops[0] = y;
            for (var index = 0; index < heights.Length; index++)
            {
                y += heights[index]; tops[index + 1] = y;
                if (separatorRows.Contains(index)) separatorPositions.Add(y);
            }
            for (var index = 0; index < groupHeaders.Count; index++)
            {
                var group = groupHeaders[index];
                var top = tops[group.Row] + group.Title.Margin.Top;
                var bottom = index + 1 < groupHeaders.Count ? tops[groupHeaders[index + 1].Row] : tops[^1];
                var frame = new Rectangle(table.Padding.Left, top, Math.Max(0, table.ClientSize.Width - table.Padding.Horizontal - 1), Math.Max(0, bottom - top));
                groupFrames.Add((frame, new Rectangle(frame.Left, top, frame.Width, group.Title.Height)));
            }
            table.Invalidate();
        };
        table.Paint += (_, args) =>
        {
            using var line = new Pen(table.BackColor.GetBrightness() < .5f ? Color.FromArgb(57, 72, 91) : Color.FromArgb(134, 151, 166));
            using var headerFill = new SolidBrush(_drop.BackColor);
            foreach (var group in groupFrames)
            {
                args.Graphics.FillRectangle(headerFill, group.Header);
                args.Graphics.DrawRectangle(line, group.Frame);
                args.Graphics.DrawLine(line, group.Frame.Left, group.Header.Bottom, group.Frame.Right, group.Header.Bottom);
            }
            foreach (var y in separatorPositions) args.Graphics.DrawLine(line, table.Padding.Left, y, table.Width - table.Padding.Right, y);
        };
        var viewport = new Panel { Name = "MissionOptionsScroll", AutoScroll = true };
        viewport.Controls.Add(table);
        var page = new TabPage("Mission options") { Padding = new Padding(S(12)) };
        page.Controls.Add(new WeatherScrollHost(viewport) { Dock = DockStyle.Fill });
        return page;

        Label Label(string text) => new() { Text = text, AutoSize = true, Anchor = AnchorStyles.Left, Margin = new Padding(S(12), S(2), S(8), S(2)) };
        void Group(string text)
        {
            var title = new Label { Name = "MissionOptionsGroup" + text.Split(' ')[0], Text = text, AutoSize = true, Font = _boldFont,
                Dock = DockStyle.Fill, MinimumSize = new Size(0, S(38)), Padding = new Padding(S(12), S(6), S(12), S(6)),
                Margin = new Padding(0, S(20), 0, 0), UseMnemonic = false };
            title.Paint += (_, args) =>
            {
                args.Graphics.Clear(_drop.BackColor);
                TextRenderer.DrawText(args.Graphics, title.Text, title.Font,
                    Rectangle.Inflate(title.ClientRectangle, -title.Padding.Left, 0), title.ForeColor,
                    TextFormatFlags.Left | TextFormatFlags.VerticalCenter | TextFormatFlags.SingleLine | TextFormatFlags.NoPrefix);
            };
            groupHeaders.Add((title, row));
            table.Controls.Add(title, 0, row++); table.SetColumnSpan(title, 3);
        }
        CheckBox Enforce<T>(string key, MissionOption<T> option, params Control[] values)
        {
            var check = new WeatherCheckBox { Name = "MissionEnforce" + key, AutoSize = false, Size = new Size(S(26), S(40)),
                Anchor = AnchorStyles.None, CheckAlign = ContentAlignment.MiddleCenter, Checked = option.Enforce, AccessibleName = "Enforce " + key, Margin = new Padding(0, S(2), 0, S(2)) };
            foreach (var value in values) value.Enabled = option.Enforce;
            check.CheckedChanged += (_, _) => { option.Enforce = check.Checked; foreach (var value in values) value.Enabled = check.Checked; RefreshSummary(); };
            return check;
        }
        void AddChoice<T>(string key, string label, Func<MissionOptionsSettings, MissionOption<T>> select, (string Label, T Value)[] choices)
        {
            var option = select(_missionOptions);
            var value = new WeatherChoiceBox { Name = "Mission" + key, DropDownStyle = ComboBoxStyle.DropDownList, Dock = DockStyle.None, Anchor = AnchorStyles.Left | AnchorStyles.Right, Width = S(230),
                Margin = new Padding(0, S(2), S(12), S(2)), AccessibleName = label + " value" };
            foreach (var choice in choices) value.Items.Add(new MissionChoice<T>(choice.Label, choice.Value));
            value.SelectedItem = value.Items.Cast<MissionChoice<T>>().Single(item => EqualityComparer<T>.Default.Equals(item.Value, option.Value));
            value.SelectedIndexChanged += (_, _) => { option.Value = ((MissionChoice<T>)value.SelectedItem!).Value; RefreshSummary(); };
            var enforce = Enforce(key, option, value);
            table.Controls.Add(Label(label), 0, row); table.Controls.Add(enforce, 1, row); table.Controls.Add(value, 2, row++);
            resetters.Add(defaults =>
            {
                var saved = select(defaults);
                option.Value = saved.Value; option.Enforce = saved.Enforce;
                value.SelectedItem = value.Items.Cast<MissionChoice<T>>().Single(item => EqualityComparer<T>.Default.Equals(item.Value, saved.Value));
                enforce.Checked = saved.Enforce; value.Enabled = saved.Enforce;
            });
            separatorRows.Add(row - 1);
        }
        void AddBirds()
        {
            var option = _missionOptions.Birds;
            var number = Number("MissionBirds", 0, 1000, option.Value, notify: false);
            ((WeatherNumberBox)number).ShowSpinner = false;
            number.Increment = 10; number.Dock = DockStyle.None; number.Width = S(90);
            number.AccessibleName = "Birds value"; number.Margin = new Padding(0, S(2), S(4), S(2));
            var slider = new TrackBar { Name = "MissionBirdsSlider", Minimum = 0, Maximum = 1000,
                SmallChange = 10, LargeChange = 100, TickStyle = TickStyle.None, Value = option.Value,
                AutoSize = false, Width = S(108), Height = S(36), Anchor = AnchorStyles.Left, AccessibleName = "Birds slider", Margin = new Padding(0, S(2), 0, S(2)) };
            number.ValueChanged += (_, _) =>
            {
                if (_updating) return;
                option.Value = (int)number.Value; slider.Value = option.Value; RefreshSummary();
            };
            EventHandler commitBirdsSlider = (_, _) =>
            {
                if (_updating) return;
                if (slider.Capture)
                {
                    _updating = true;
                    try { number.Value = slider.Value; }
                    finally { _updating = false; }
                    return;
                }
                option.Value = slider.Value;
                _updating = true;
                try { number.Value = option.Value; }
                finally { _updating = false; }
                RefreshSummary();
            };
            slider.Scroll += commitBirdsSlider;
            slider.MouseCaptureChanged += commitBirdsSlider;
            var values = Row(number, slider); values.WrapContents = false; values.Dock = DockStyle.None; values.Anchor = AnchorStyles.Right;
            values.Margin = new Padding(0, 0, S(12), 0);
            var enforce = Enforce("Birds", option, number, slider);
            table.Controls.Add(Label("BIRDS %"), 0, row); table.Controls.Add(enforce, 1, row); table.Controls.Add(values, 2, row++);
            separatorRows.Add(row - 1);
            resetters.Add(defaults =>
            {
                option.Value = defaults.Birds.Value; option.Enforce = defaults.Birds.Enforce;
                number.Value = option.Value; slider.Value = option.Value;
                enforce.Checked = option.Enforce; number.Enabled = slider.Enabled = option.Enforce;
            });
        }
        void AddBoolean(string key, string label, Func<MissionOptionsSettings, MissionOption<bool>> select)
        {
            var option = select(_missionOptions);
            var value = new WeatherCheckBox { Name = "Mission" + key, Text = option.Value ? "On" : "Off", AutoSize = true,
                CheckAlign = ContentAlignment.MiddleRight, TextAlign = ContentAlignment.MiddleLeft, Anchor = AnchorStyles.Right,
                Checked = option.Value, AccessibleName = label + " value", Margin = new Padding(0, S(2), S(12), S(2)) };
            value.CheckedChanged += (_, _) => { option.Value = value.Checked; value.Text = value.Checked ? "On" : "Off"; RefreshSummary(); };
            var enforce = Enforce(key, option, value);
            table.Controls.Add(Label(label), 0, row); table.Controls.Add(enforce, 1, row); table.Controls.Add(value, 2, row++);
            resetters.Add(defaults =>
            {
                var saved = select(defaults);
                option.Value = saved.Value; option.Enforce = saved.Enforce;
                value.Checked = saved.Value; value.Text = saved.Value ? "On" : "Off";
                enforce.Checked = saved.Enforce; value.Enabled = saved.Enforce;
            });
            separatorRows.Add(row - 1);
        }
    }

    private void ShowExtendedF10Options()
    {
        var draft = JsonSerializer.Deserialize<Dictionary<int, ExtendedF10RoleOptions>>(JsonSerializer.Serialize(_missionOptions.ExtendedF10))!;
        using var dialog = new Form { Name = "MissionExtendedF10Dialog", Text = "Extended F10 view options",
            StartPosition = FormStartPosition.CenterParent, FormBorderStyle = FormBorderStyle.FixedDialog,
            MinimizeBox = false, MaximizeBox = false, ShowInTaskbar = false, Font = Font,
            ClientSize = new Size(S(600), S(440)), AutoScaleMode = AutoScaleMode.Dpi };
        var body = new TableLayoutPanel { Dock = DockStyle.Fill, ColumnCount = 1, RowCount = 4, Padding = new Padding(S(14)) };
        body.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        body.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        body.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        body.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        body.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        var roles = new WeatherChoiceBox { Name = "MissionF10Role", Dock = DockStyle.Top,
            DropDownStyle = ComboBoxStyle.DropDownList, AccessibleName = "F10 role" };
        foreach (var role in new[] { (Id: 5, Label: "Spectator"), (Id: 1, Label: "Pilot"), (Id: 6, Label: "Airboss/LSO"),
            (Id: 2, Label: "Forward observer"), (Id: 3, Label: "Tactical commander"), (Id: 4, Label: "Observer") })
            roles.Items.Add(new MissionChoice<int>(role.Label, role.Id));
        var views = new WeatherChoiceBox { Name = "MissionF10RoleView", Dock = DockStyle.Top,
            DropDownStyle = ComboBoxStyle.DropDownList, AccessibleName = "Role F10 view" };
        foreach (var choice in MissionOptionsSettings.F10Choices) views.Items.Add(new MissionChoice<string>(choice.Label, choice.Value));
        body.Controls.Add(new Label { Text = "Choose an F10 view and visible unit layers for each role.",
            AutoSize = true, Dock = DockStyle.Top, Margin = new Padding(0, 0, 0, S(10)) }, 0, 0);
        body.Controls.Add(Fields(("Role", roles), ("F10 view", views)), 0, 1);
        var layers = new TableLayoutPanel { Dock = DockStyle.Top, AutoSize = true, ColumnCount = 4, RowCount = 6, Margin = Padding.Empty };
        layers.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        for (var column = 0; column < 3; column++) layers.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, S(100)));
        var sides = new[] { "Allies", "Enemies", "Neutral" };
        for (var side = 0; side < sides.Length; side++)
            layers.Controls.Add(new Label { Text = sides[side], AutoSize = true, Anchor = AnchorStyles.None }, side + 1, 0);
        var types = new[] { "Planes", "Helicopters", "Ground", "Naval", "Weapons" };
        var checks = new CheckBox[15];
        var syncing = false;
        ExtendedF10RoleOptions SelectedRole() => draft[((MissionChoice<int>)roles.SelectedItem!).Value];
        void RefreshRole()
        {
            syncing = true;
            try
            {
                var role = SelectedRole();
                views.SelectedItem = views.Items.Cast<MissionChoice<string>>().Single(choice => choice.Value == role.View);
                for (var bit = 0; bit < checks.Length; bit++)
                {
                    var enabled = role.View is not ("optview_onlymap" or "optview_myaircraft")
                        && (role.View != "optview_onlyallies" || bit % 3 == 0);
                    checks[bit].Enabled = enabled;
                    checks[bit].Checked = enabled && role.VisibleUnitLayers[bit];
                }
            }
            finally { syncing = false; }
        }
        for (var type = 0; type < types.Length; type++)
        {
            layers.Controls.Add(new Label { Text = types[type], AutoSize = true, Anchor = AnchorStyles.Left,
                Margin = new Padding(0, S(8), S(8), S(8)) }, 0, type + 1);
            for (var side = 0; side < sides.Length; side++)
            {
                var bit = type * 3 + side;
                var check = checks[bit] = new WeatherCheckBox { Name = "MissionF10Layer" + bit, AutoSize = false,
                    Size = new Size(S(26), S(28)), Anchor = AnchorStyles.None, CheckAlign = ContentAlignment.MiddleCenter,
                    AccessibleName = types[type] + " " + sides[side] };
                check.CheckedChanged += (_, _) => { if (!syncing) SelectedRole().VisibleUnitLayers[bit] = check.Checked; };
                layers.Controls.Add(check, side + 1, type + 1);
            }
        }
        roles.SelectedIndexChanged += (_, _) => RefreshRole();
        views.SelectedIndexChanged += (_, _) =>
        {
            if (syncing) return;
            SelectedRole().View = ((MissionChoice<string>)views.SelectedItem!).Value;
            RefreshRole();
        };
        body.Controls.Add(layers, 0, 2);
        var ok = Button("OK", () => dialog.DialogResult = DialogResult.OK, "MissionF10Accept");
        var cancel = Button("Cancel", () => dialog.DialogResult = DialogResult.Cancel, "MissionF10Cancel");
        var actions = Row(cancel, ok); actions.FlowDirection = FlowDirection.RightToLeft;
        body.Controls.Add(actions, 0, 3);
        dialog.Controls.Add(body); dialog.AcceptButton = ok; dialog.CancelButton = cancel;
        roles.SelectedIndex = 0;
        _style(dialog); ApplyWeatherChrome(dialog);
        if (dialog.ShowDialog(DialogOwner) == DialogResult.OK)
        {
            _missionOptions.ExtendedF10 = draft;
            RefreshSummary();
        }
    }

    internal MissionOptionsSettings ReadMissionOptions()
    {
        _missionOptions.Validate();
        return JsonSerializer.Deserialize<MissionOptionsSettings>(JsonSerializer.Serialize(_missionOptions))!;
    }
}
