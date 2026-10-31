namespace FootholdConfigManager;

internal sealed partial class WeatherWindow
{
    private Font _bodyFont;
    private Font _captionFont;
    private void ApplyWeatherChrome(Control target)
    {
        var dark = BackColor.GetBrightness() < .5f;
        var line = dark ? Color.FromArgb(57, 72, 91) : Color.FromArgb(134, 151, 166);
        var accent = dark ? Color.FromArgb(86, 156, 214) : Color.FromArgb(30, 120, 167);
        var secondary = dark ? Color.FromArgb(165, 182, 202) : Color.FromArgb(70, 90, 109);
        var controls = Descendants(target).ToArray();
        var layoutOwners = new[] { target }.Concat(controls.OfType<Panel>()).ToArray();
        foreach (var owner in layoutOwners) owner.SuspendLayout();
        try
        {
            foreach (var control in controls)
            {
                if (control is IDataGridViewEditingControl || control.Parent is WeatherDateTimeInput dateInput && dateInput.OwnsDateTextEditor(control)) continue;
                if (control is ComboBox combo)
                {
                    combo.ItemHeight = Math.Max(InputSize(combo, 24), combo.Font.Height + 4);
                }
                if (control is CheckBox check)
                {
                    check.FlatStyle = FlatStyle.Standard;
                    if (check is WeatherCheckBox weatherCheck) weatherCheck.DisabledTextColor = secondary;
                }
                if (control is RadioButton radio) radio.FlatStyle = FlatStyle.Standard;
                if (control is WeatherWindDial dial)
                {
                    dial.AccentColor = accent;
                    dial.LineColor = secondary;
                    dial.Invalidate();
                }
                if (control is TrackBar slider) MainForm.InputChrome.Apply(slider);
                if (control is NumericUpDown number)
                {
                    number.Font = WeatherValueFont;
                    number.BorderStyle = BorderStyle.None;
                    number.Layout -= ExpandNumberEditor;
                    number.Layout += ExpandNumberEditor;
                }
                if (control is TextBox textBox && textBox.Parent is not NumericUpDown) textBox.BorderStyle = BorderStyle.None;
                if (control is ComboBox or NumericUpDown or DateTimePicker || control is TextBox && control.Parent is not NumericUpDown && control.Parent is not DataGridView)
                {
                    if (control.Parent is not WeatherInputFrame && control.Parent?.Parent is not WeatherInputFrame) FrameInput(control);
                }
            }
        }
        finally
        {
            for (var i = layoutOwners.Length - 1; i >= 0; i--)
                layoutOwners[i].ResumeLayout(false);
            target.PerformLayout();
        }
        foreach (var picker in Descendants(target).OfType<WeatherDateTimeInput>())
        {
            picker.Font = WeatherValueFont;
            picker.SurfaceColor = _cloudPreset.BackColor;
            picker.ForeColor = ForeColor;
            picker.Invalidate();
        }
        foreach (var caption in Descendants(target).OfType<Label>().Where(label => ReferenceEquals(label.Font, _captionFont))) caption.ForeColor = secondary;
        foreach (var frame in Descendants(target).OfType<WeatherInputFrame>())
        {
            frame.BackColor = frame.Input is WeatherDateTimeInput picker ? picker.SurfaceColor : frame.Input.BackColor;
            frame.BorderColor = line;
            frame.FocusColor = accent;
            frame.Inset = InputSize(frame, frame.Input is ComboBox ? 3 : 9);
            frame.PerformLayout();
            frame.Invalidate();
        }
        if (ReferenceEquals(target, this))
        {
            _fogGrid.DefaultCellStyle.Font = WeatherValueFont;
            _fogGrid.AutoSizeRowsMode = DataGridViewAutoSizeRowsMode.AllCells;
            _summary.ForeColor = secondary;
            _baseRange.ForeColor = secondary;
            _installStatus.ForeColor = secondary;
            _drop.BackColor = dark ? Color.FromArgb(24, 32, 43) : Color.FromArgb(211, 221, 231);
            foreach (Control child in Descendants(_drop)) child.BackColor = _drop.BackColor;
            foreach (var tabs in Descendants(this).OfType<WeatherPreviewTabs>())
            {
                tabs.Surface = BackColor;
                tabs.Accent = accent;
                tabs.LineColor = line;
                tabs.SelectedSurface = _drop.BackColor;
                tabs.Invalidate();
            }

        }
    }

    private void FrameInput(Control input)
    {
        var parent = input.Parent!;
        var dock = input.Dock;
        var margin = input.Margin;
        var width = dock == DockStyle.None ? Math.Max(input.Width, InputSize(input, 104)) : input.Width;
        var anchor = input.Anchor;
        var tabIndex = input.TabIndex;
        var table = parent as TableLayoutPanel;
        var position = table?.GetPositionFromControl(input);
        var columnSpan = table?.GetColumnSpan(input) ?? 1;
        var rowSpan = table?.GetRowSpan(input) ?? 1;
        var index = parent.Controls.GetChildIndex(input);
        parent.Controls.Remove(input);
        var inputHeight = InputSize(input, input is NumericUpDown && input.Name != "MissionBirds" ? 40 : 36);
        var frame = new WeatherInputFrame(input, inputHeight) { Dock = dock, Margin = margin, Width = width, MinimumSize = dock == DockStyle.None ? new Size(width, inputHeight) : Size.Empty, Anchor = anchor, TabIndex = tabIndex };
        if (ReferenceEquals(table, _windLayout) && input is NumericUpDown)
        {
            frame.Dock = DockStyle.None;
            frame.Anchor = AnchorStyles.None;
            frame.MinimumSize = new Size(0, inputHeight);
            frame.MaximumSize = new Size(W(104), 0);
        }
        if (table is not null && position is { } cell)
        {
            table.Controls.Add(frame, cell.Column, cell.Row);
            table.SetColumnSpan(frame, columnSpan);
            table.SetRowSpan(frame, rowSpan);
        }
        else
        {
            parent.Controls.Add(frame);
            parent.Controls.SetChildIndex(frame, index);
        }
        AttachDrop(frame, false);
    }

    private static void ExpandNumberEditor(object? sender, LayoutEventArgs args)
    {
        var number = (NumericUpDown)sender!;
        if (number is WeatherNumberBox { ShowSpinner: true }) return;
        foreach (Control child in number.Controls)
            if (child is TextBox) child.SetBounds(0, 0, number.ClientSize.Width, number.ClientSize.Height);
    }

    private static IEnumerable<Control> Descendants(Control control)
    {
        foreach (Control child in control.Controls)
        {
            yield return child;
            foreach (var nested in Descendants(child)) yield return nested;
        }
    }

    private void FitWeatherToScreen()
    {
        var area = Screen.FromControl(this).WorkingArea;
        Size = new Size(Math.Min(Width, area.Width - 24), Math.Min(Height, area.Height - 24));
        Location = new Point(Math.Clamp(Left, area.Left + 12, area.Right - Width - 12), Math.Clamp(Top, area.Top + 12, area.Bottom - Height - 12));
    }
}