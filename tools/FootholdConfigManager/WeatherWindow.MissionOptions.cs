using System.Text.Json;

namespace FootholdConfigManager;

internal sealed partial class WeatherWindow
{
    private readonly TabControl _workspaceTabs = new WeatherPreviewTabs { Name = "MissionWorkspaceTabs", Dock = DockStyle.Fill };
    private readonly CheckBox _applyWeather = new WeatherCheckBox() { Name = "WeatherApplyWeather", Text = "Weather", AutoSize = true };
    private readonly CheckBox _applyMissionOptions = new WeatherCheckBox() { Name = "WeatherApplyMissionOptions", Text = "Mission options", AutoSize = true };
    private MissionOptionsSettings _missionOptions = new();

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
        var help = new Label { Text = "Enforce makes the mission use the value on the right. Unchecked means this option is not enforced.",
            AutoSize = true, Dock = DockStyle.Top, Margin = new Padding(0, 0, 0, S(16)) };
        table.Controls.Add(help, 0, row++); table.SetColumnSpan(help, 3);
        table.Controls.Add(new Label { Text = "Enforce", AutoSize = true, Font = _boldFont, Anchor = AnchorStyles.None }, 1, row);
        table.Controls.Add(new Label { Text = "Option", AutoSize = true, Font = _boldFont }, 0, row);
        table.Controls.Add(new Label { Text = "Value", AutoSize = true, Font = _boldFont, Anchor = AnchorStyles.Right }, 2, row++);
        separatorRows.Add(row - 1);
        var radios = new List<RadioButton>();
        var enforceF10 = Enforce("F10View", _missionOptions.F10View, Array.Empty<Control>());
        table.Controls.Add(enforceF10, 1, row);
        var f10Label = Label("F10 View Options");
        table.Controls.Add(f10Label, 0, row++);
        separatorRows.Add(row - 1);
        foreach (var choice in MissionOptionsSettings.F10Choices)
        {
            var radio = new WeatherRadioButton { Name = "MissionF10_" + choice.Value, AutoSize = false, Size = new Size(S(22), S(28)),
                CheckAlign = ContentAlignment.MiddleRight, Anchor = AnchorStyles.Right, Margin = new Padding(0, S(3), 0, S(3)),
                AccessibleName = choice.Label, Checked = _missionOptions.F10View.Value == choice.Value, Enabled = _missionOptions.F10View.Enforce };
            radio.CheckedChanged += (_, _) => { if (radio.Checked) { _missionOptions.F10View.Value = choice.Value; RefreshSummary(); } };
            radios.Add(radio);
            var label = Label(choice.Label); label.Margin = new Padding(S(12), S(3), 0, S(3));
            table.Controls.Add(label, 0, row); table.Controls.Add(radio, 2, row++);
        }
        enforceF10.CheckedChanged += (_, _) => { foreach (var radio in radios) radio.Enabled = enforceF10.Checked; };
        AddBoolean("BattleDamage", "Battle Damage Assessment", _missionOptions.BattleDamage);
        AddBoolean("EasyCommunication", "Easy Communication", _missionOptions.EasyCommunication);
        Group("General");
        AddChoice("Labels", "Labels", _missionOptions.Labels, MissionOptionsSettings.LabelChoices);
        AddChoice("SpottingDots", "Spotting Dots", _missionOptions.SpottingDots, MissionOptionsSettings.SpottingChoices);
        AddChoice("CivilTraffic", "Civ. Traffic", _missionOptions.CivilTraffic, MissionOptionsSettings.TrafficChoices);
        Group("Modules · Supercarrier");
        AddBoolean("DeckCrew", "Enable deck crew", _missionOptions.DeckCrew);
        AddBoolean("Carrier1Mc", "Enable 1MC", _missionOptions.Carrier1Mc);
        table.LayoutCompleted += (_, _) =>
        {
            separatorPositions.Clear();
            var heights = table.GetRowHeights(); var y = table.Padding.Top;
            for (var index = 0; index < heights.Length; index++) { y += heights[index]; if (separatorRows.Contains(index)) separatorPositions.Add(y); }
            table.Invalidate();
        };
        table.Paint += (_, args) =>
        {
            using var line = new Pen(table.BackColor.GetBrightness() < .5f ? Color.FromArgb(57, 72, 91) : Color.FromArgb(134, 151, 166));
            foreach (var y in separatorPositions) args.Graphics.DrawLine(line, table.Padding.Left, y, table.Width - table.Padding.Right, y);
        };
        var viewport = new Panel { Name = "MissionOptionsScroll", AutoScroll = true };
        viewport.Controls.Add(table);
        var page = new TabPage("Mission options") { Padding = new Padding(S(12)) };
        page.Controls.Add(new WeatherScrollHost(viewport) { Dock = DockStyle.Fill });
        return page;

        Label Label(string text) => new() { Text = text, AutoSize = true, Anchor = AnchorStyles.Left, Margin = new Padding(0, S(6), S(8), S(6)) };
        void Group(string text)
        {
            var title = new Label { Text = text, AutoSize = true, Font = _boldFont, Margin = new Padding(0, S(14), 0, S(6)) };
            table.Controls.Add(title, 0, row++); table.SetColumnSpan(title, 3);
        }
        CheckBox Enforce<T>(string key, MissionOption<T> option, params Control[] values)
        {
            var check = new WeatherCheckBox { Name = "MissionEnforce" + key, AutoSize = false, Size = new Size(S(26), S(28)),
                Anchor = AnchorStyles.None, CheckAlign = ContentAlignment.MiddleCenter, Checked = option.Enforce, AccessibleName = "Enforce " + key, Margin = new Padding(0, S(4), 0, S(4)) };
            foreach (var value in values) value.Enabled = option.Enforce;
            check.CheckedChanged += (_, _) => { option.Enforce = check.Checked; foreach (var value in values) value.Enabled = check.Checked; RefreshSummary(); };
            return check;
        }
        void AddChoice<T>(string key, string label, MissionOption<T> option, (string Label, T Value)[] choices)
        {
            var value = new WeatherChoiceBox { Name = "Mission" + key, DropDownStyle = ComboBoxStyle.DropDownList, Dock = DockStyle.Top,
                Margin = new Padding(0, S(5), 0, S(5)), AccessibleName = label + " value" };
            foreach (var choice in choices) value.Items.Add(new MissionChoice<T>(choice.Label, choice.Value));
            value.SelectedItem = value.Items.Cast<MissionChoice<T>>().Single(item => EqualityComparer<T>.Default.Equals(item.Value, option.Value));
            value.SelectedIndexChanged += (_, _) => { option.Value = ((MissionChoice<T>)value.SelectedItem!).Value; RefreshSummary(); };
            table.Controls.Add(Label(label), 0, row); table.Controls.Add(Enforce(key, option, value), 1, row); table.Controls.Add(value, 2, row++);
            separatorRows.Add(row - 1);
        }
        void AddBoolean(string key, string label, MissionOption<bool> option)
        {
            var value = new WeatherCheckBox { Name = "Mission" + key, Text = option.Value ? "On" : "Off", AutoSize = true,
                CheckAlign = ContentAlignment.MiddleRight, TextAlign = ContentAlignment.MiddleLeft, Anchor = AnchorStyles.Right,
                Checked = option.Value, AccessibleName = label + " value", Margin = new Padding(0, S(5), 0, S(5)) };
            value.CheckedChanged += (_, _) => { option.Value = value.Checked; value.Text = value.Checked ? "On" : "Off"; RefreshSummary(); };
            table.Controls.Add(Label(label), 0, row); table.Controls.Add(Enforce(key, option, value), 1, row); table.Controls.Add(value, 2, row++);
            separatorRows.Add(row - 1);
        }
    }

    internal MissionOptionsSettings ReadMissionOptions()
    {
        _missionOptions.Validate();
        return JsonSerializer.Deserialize<MissionOptionsSettings>(JsonSerializer.Serialize(_missionOptions))!;
    }
}
