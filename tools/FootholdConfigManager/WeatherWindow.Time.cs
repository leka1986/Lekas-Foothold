namespace FootholdConfigManager;

internal sealed partial class WeatherWindow
{
    private NumericUpDown _timeHours = null!;
    private NumericUpDown _timeMinutes = null!;

    private bool IsMissionDateSelected => _changeTime.Checked && _changeDate.Checked;

    private void CommitSelectedMissionDate()
    {
        if (IsMissionDateSelected) _date.CommitDateText();
    }

    private void MissionDateInputChanged()
    {
        if (_updating || _busy) return;
        RefreshApplyAvailability();
        OptionsChanged();
        var error = IsMissionDateSelected ? _date.DateDraftError : null;
        SetStatus(error ?? (IsMissionDateSelected ? "Mission date updated." : "Mission date will be kept unchanged."), error is not null);
    }

    private TimeSpan SelectedStartTime
    {
        get => new((int)_timeHours.Value, (int)_timeMinutes.Value, 0);
        set
        {
            var previous = _updating;
            _updating = true;
            try
            {
                _timeHours.Value = value.Hours;
                _timeMinutes.Value = value.Minutes;
            }
            finally { _updating = previous; }
        }
    }

    private TableLayoutPanel BuildTimeEditor()
    {
        _timeHours = Number("WeatherStartHours", 0, 23, 8);
        _timeMinutes = Number("WeatherStartMinutes", 0, 59, 45);
        foreach (var number in new[] { _timeHours, _timeMinutes })
        {
            var editor = (WeatherNumberBox)number;
            editor.ShowSpinner = true;
            editor.PadToTwoDigits = true;
            editor.Margin = Padding.Empty;
        }
        _timeHours.AccessibleName = "Start time hours";
        _timeMinutes.AccessibleName = "Start time minutes";
        var time = new TableLayoutPanel { Name = "WeatherStartTime", Dock = DockStyle.Top, AutoSize = true,
            ColumnCount = 3, RowCount = 2, MaximumSize = new Size(W(188), 0), Margin = Padding.Empty };
        time.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, W(86)));
        time.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, W(16)));
        time.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, W(86)));
        time.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        time.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        time.Controls.Add(new Label { Text = "Hours", AutoSize = true, Font = _captionFont,
            Margin = new Padding(0, 0, 0, W(6)) }, 0, 0);
        time.Controls.Add(new Label { Text = "Minutes", AutoSize = true, Font = _captionFont,
            Margin = new Padding(0, 0, 0, W(6)) }, 2, 0);
        time.Controls.Add(_timeHours, 0, 1);
        time.Controls.Add(new Label { Text = ":", Dock = DockStyle.Fill, TextAlign = ContentAlignment.MiddleCenter,
            Margin = Padding.Empty }, 1, 1);
        time.Controls.Add(_timeMinutes, 2, 1);
        return time;
    }
}