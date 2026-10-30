using System.Globalization;
using System.Runtime.InteropServices;

namespace FootholdConfigManager;

internal sealed partial class WeatherDateTimeInput
{
    private TextBox? _dateTextEditor;
    private bool _updatingDateText, _openingDateCalendar, _dateCalendarOpen;
    private bool _dateCalendarAccepted, _dateCalendarValueChanged;
    private string? _calendarDraftText;

    internal event EventHandler? DateDraftChanged;
    internal event Action<string>? DateTextRejected;

    internal bool DirectDateTextEntry
    {
        get => _dateTextEditor is not null;
        set
        {
            if (value == DirectDateTextEntry) return;
            if (!value)
            {
                var editor = _dateTextEditor!;
                _dateTextEditor = null;
                Controls.Remove(editor);
                editor.Dispose();
                _calendarDraftText = null;
                _dateCalendarOpen = _dateCalendarAccepted = _dateCalendarValueChanged = false;
                return;
            }
            var text = new TextBox
            {
                Name = "WeatherDateText", BorderStyle = BorderStyle.None, HideSelection = true,
                AccessibleName = "Mission date, yyyy-MM-dd", Text = DateText(Value), Font = Font,
                BackColor = SurfaceColor, ForeColor = ForeColor
            };
            _dateTextEditor = text;
            text.TextChanged += (_, _) =>
            {
                if (!_updatingDateText) DateDraftChanged?.Invoke(this, EventArgs.Empty);
            };
            text.Leave += (_, _) =>
            {
                if (_openingDateCalendar || _dateCalendarOpen) return;
                if (!TryCommitDateText(out var error)) DateTextRejected?.Invoke(error!);
            };
            text.KeyDown += (_, args) =>
            {
                if (args.KeyCode == Keys.F4 || args.Alt && args.KeyCode == Keys.Down)
                {
                    args.Handled = args.SuppressKeyPress = true;
                    _openingDateCalendar = true;
                    try
                    {
                        if (!Focus() || !Focused) throw new InvalidOperationException("The mission date calendar could not receive focus.");
                        AccessibilityObject.DoDefaultAction();
                    }
                    finally { _openingDateCalendar = false; }
                }
                else if (args.KeyCode == Keys.Enter)
                {
                    args.Handled = args.SuppressKeyPress = true;
                    if (!TryCommitDateText(out var error)) DateTextRejected?.Invoke(error!);
                }
                else if (args.KeyCode == Keys.Escape)
                {
                    args.Handled = args.SuppressKeyPress = true;
                    RestoreCommittedDateText();
                }
            };
            text.MouseEnter += (_, args) => OnMouseEnter(args);
            text.MouseLeave += (_, args) => OnMouseLeave(args);
            Controls.Add(text);
            RefreshDateTextAppearance();
        }
    }

    internal bool OwnsDateTextEditor(Control control) => ReferenceEquals(control, _dateTextEditor);
    internal string DateDraftText => _dateTextEditor?.Text ?? DateText(Value);
    internal bool HasValidDateDraft => TryReadDateDraft(out _, out _);
    internal string? DateDraftError { get { TryReadDateDraft(out _, out var error); return error; } }
    internal string DateDraftSummary => TryReadDateDraft(out var date, out _) ? DateText(date) : "Invalid date (yyyy-MM-dd)";

    internal void CommitDateText()
    {
        if (!TryCommitDateText(out var error)) throw new InvalidDataException(error);
    }

    internal void SetDateValue(DateTime value)
    {
        Value = value;
        RestoreCommittedDateText(); // Same-value assignments do not raise native ValueChanged.
    }

    internal void RestoreCommittedDateText() => SetDateDraft(DateText(Value), notify: true);
    internal void RestoreDateDraft(string text) => SetDateDraft(text, notify: true);

    private static string DateText(DateTime value) => value.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);

    private bool TryReadDateDraft(out DateTime date, out string? error)
    {
        date = Value.Date;
        error = null;
        if (_dateTextEditor is null) return true;
        if (!DateTime.TryParseExact(_dateTextEditor.Text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out date))
        {
            error = "Enter a valid mission date as yyyy-MM-dd.";
            return false;
        }
        if (date < MinDate.Date || date > MaxDate.Date)
        {
            error = "Mission date must be between " + DateText(MinDate) + " and " + DateText(MaxDate) + ".";
            return false;
        }
        return true;
    }

    private bool TryCommitDateText(out string? error)
    {
        if (_dateTextEditor is null) { error = null; return true; }
        if (!TryReadDateDraft(out var date, out error)) return false;
        Value = date;
        RestoreCommittedDateText();
        return true;
    }

    private void SetDateDraft(string text, bool notify)
    {
        if (_dateTextEditor is null || _dateTextEditor.Text == text) return;
        _updatingDateText = true;
        try { _dateTextEditor.Text = text; }
        finally { _updatingDateText = false; }
        if (notify) DateDraftChanged?.Invoke(this, EventArgs.Empty);
    }

    protected override void OnValueChanged(EventArgs args)
    {
        if (_dateTextEditor is not null)
        {
            if (_dateCalendarOpen) _dateCalendarValueChanged = true;
            SetDateDraft(DateText(Value), notify: false);
        }
        base.OnValueChanged(args);
    }

    protected override void OnDropDown(EventArgs args)
    {
        if (_dateTextEditor is not null)
        {
            _calendarDraftText = _dateTextEditor.Text;
            _dateCalendarAccepted = _dateCalendarValueChanged = false;
            _dateCalendarOpen = true;
        }
        base.OnDropDown(args);
    }

    protected override void OnCloseUp(EventArgs args)
    {
        if (_dateTextEditor is not null && _dateCalendarOpen)
        {
            _dateCalendarOpen = false;
            if (_dateCalendarAccepted || _dateCalendarValueChanged) RestoreCommittedDateText();
            else if (_calendarDraftText is { } draft) RestoreDateDraft(draft);
            ResetDateCalendarState();
        }
        base.OnCloseUp(args);
        if (_dateTextEditor is not null && IsHandleCreated && !Disposing)
            BeginInvoke(() =>
            {
                if (!IsDisposed && Focused && !_dateCalendarOpen) _dateTextEditor?.Focus();
            });
    }

    protected override void OnGotFocus(EventArgs args)
    {
        base.OnGotFocus(args);
        if (!_openingDateCalendar && !_dateCalendarOpen) _dateTextEditor?.Focus();
    }

    private void ResetDateCalendarState()
    {
        _calendarDraftText = null;
        _openingDateCalendar = _dateCalendarOpen = _dateCalendarAccepted = _dateCalendarValueChanged = false;
    }

    private bool HandleDateTextMessage(ref Message message)
    {
        if (_dateTextEditor is null) return false;
        if (message.Msg == 0x004E && message.LParam != IntPtr.Zero && _dateCalendarOpen &&
            Marshal.PtrToStructure<DateTextNotification>(message.LParam).Code == -746) // actual MCN_SELECT
        {
            _dateCalendarAccepted = true;
            base.WndProc(ref message);
            RestoreCommittedDateText(); // Acceptance of the same native date need not raise ValueChanged.
            return true;
        }
        if (message.Msg == 0x0201)
        {
            var point = new Point((short)message.LParam.ToInt64(), (short)(message.LParam.ToInt64() >> 16));
            if (DateCalendarButtonBounds().Contains(point))
            {
                _openingDateCalendar = true;
                try { base.WndProc(ref message); }
                finally { _openingDateCalendar = false; }
                return true;
            }
        }
        return false;
    }

    private Rectangle DateCalendarButtonBounds()
    {
        if (!IsHandleCreated) return Rectangle.Empty;
        var info = new PickerInfo { Size = Marshal.SizeOf<PickerInfo>() };
        GetPickerInfo(Handle, 0x100E, IntPtr.Zero, ref info);
        return Rectangle.FromLTRB(info.Button.Left, info.Button.Top, info.Button.Right, info.Button.Bottom);
    }

    private void RefreshDateTextAppearance()
    {
        if (_dateTextEditor is not { IsDisposed: false } text) return;
        text.BackColor = SurfaceColor;
        text.ForeColor = ForeColor;
        text.Font = Font;
        PositionDateTextEditor();
    }

    private void PositionDateTextEditor()
    {
        if (_dateTextEditor is not { IsDisposed: false } text || !IsHandleCreated) return;
        var button = DateCalendarButtonBounds();
        text.Visible = button.Width > 0 && button.Left > 4;
        if (!text.Visible) return;
        text.SetBounds(3, Math.Max(0, (ClientSize.Height - text.PreferredHeight) / 2), button.Left - 4, text.PreferredHeight);
    }

    protected override void OnSizeChanged(EventArgs args) { base.OnSizeChanged(args); PositionDateTextEditor(); }
    protected override void OnVisibleChanged(EventArgs args)
    {
        base.OnVisibleChanged(args);
        if (Visible) PositionDateTextEditor();
    }
    protected override void OnForeColorChanged(EventArgs args) { base.OnForeColorChanged(args); RefreshDateTextAppearance(); }

    private void DrawDateTextForPrint(Graphics graphics)
    {
        if (_dateTextEditor is not { Visible: true } text) return;
        using var image = new Bitmap(text.Width, text.Height);
        text.DrawToBitmap(image, text.ClientRectangle);
        graphics.DrawImageUnscaled(image, text.Location);
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct DateTextNotification { public IntPtr From; public UIntPtr Id; public int Code; }
}
