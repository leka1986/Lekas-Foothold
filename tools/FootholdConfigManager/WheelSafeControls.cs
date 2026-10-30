using System.Drawing;
using System.Windows.Forms;

namespace FootholdConfigManager;

internal class WheelSafeComboBox : ComboBox
{
    private const int WmPaint = 0x000F;
    private const int WmPrint = 0x0317;
    private const int WmPrintClient = 0x0318;
    public Color OutlineColor { get; set; } = Color.Empty;

    protected override void WndProc(ref Message message)
    {
        base.WndProc(ref message);
        var printing = message.Msg is WmPrint or WmPrintClient;
        if ((message.Msg == WmPaint || printing) && !OutlineColor.IsEmpty && Width > 1 && Height > 1)
        {
            using var graphics = printing && message.WParam != IntPtr.Zero
                ? Graphics.FromHdc(message.WParam)
                : Graphics.FromHwnd(Handle);
            using var pen = new Pen(OutlineColor);
            graphics.DrawRectangle(pen, 0, 0, Width - 1, Height - 1);
        }
    }

    protected override void OnMouseWheel(MouseEventArgs e)
    {
        WheelRedirector.RedirectToScrollableParent(this, e);
    }
}

internal class WheelSafeNumericUpDown : NumericUpDown
{
    private bool _frameHover;
    private TextBox? _stepperEdit;
    private Control? _stepperButtons;
    private bool _arrangingStepper;

    public WheelSafeNumericUpDown()
    {
        SetStyle(ControlStyles.OptimizedDoubleBuffer | ControlStyles.AllPaintingInWmPaint, true);
        _stepperEdit = Controls.OfType<TextBox>().Single();
        _stepperButtons = Controls.Cast<Control>().Single(child => child is not TextBox);
        foreach (Control child in Controls)
        {
            child.MouseEnter += (_, _) => SetFrameHover(true);
            child.MouseLeave += (_, _) => SetFrameHover(false);
        }
    }

    protected override void OnLayout(LayoutEventArgs e)
    {
        if (_arrangingStepper) return;
        _arrangingStepper = this is not WeatherNumberBox { ShowSpinner: false };
        try { base.OnLayout(e); }
        finally { _arrangingStepper = false; }
        ArrangeStepper();
    }

    protected override void OnTextBoxResize(object? source, EventArgs e)
    {
        if (_arrangingStepper) return;
        _arrangingStepper = this is not WeatherNumberBox { ShowSpinner: false };
        try { base.OnTextBoxResize(source, e); }
        finally { _arrangingStepper = false; }
        ArrangeStepper();
    }

    protected override void OnFontChanged(EventArgs e)
    {
        if (_arrangingStepper) return;
        _arrangingStepper = this is not WeatherNumberBox { ShowSpinner: false };
        try { base.OnFontChanged(e); }
        finally { _arrangingStepper = false; }
        ArrangeStepper();
    }

    protected override void OnHandleCreated(EventArgs e)
    {
        if (_arrangingStepper) return;
        _arrangingStepper = this is not WeatherNumberBox { ShowSpinner: false };
        try { base.OnHandleCreated(e); }
        finally { _arrangingStepper = false; }
        ArrangeStepper();
    }

    protected override void RescaleConstantsForDpi(int oldDpi, int newDpi)
    {
        if (_arrangingStepper) return;
        _arrangingStepper = this is not WeatherNumberBox { ShowSpinner: false };
        try { base.RescaleConstantsForDpi(oldDpi, newDpi); }
        finally { _arrangingStepper = false; }
        PerformLayout();
    }

    private void ArrangeStepper()
    {
        // Base construction can lay out before our child references are assigned.
        if (_arrangingStepper || _stepperEdit is null || _stepperButtons is null || this is WeatherNumberBox { ShowSpinner: false }) return;
        var edit = _stepperEdit.Bounds;
        var buttons = _stepperButtons.Bounds;
        var requestedWidth = Math.Max(LogicalToDeviceUnits(24), (int)Math.Ceiling(Font.Height * 1.5));
        var availableWidth = edit.Width + buttons.Width - Math.Max(Font.Height, LogicalToDeviceUnits(16));
        var extra = Math.Min(requestedWidth, Math.Max(buttons.Width, availableWidth)) - buttons.Width;
        if (extra == 0) return;
        _arrangingStepper = true;
        try
        {
            if (buttons.Left >= edit.Left) buttons.X -= extra;
            else edit.X += extra;
            buttons.Width += extra;
            edit.Width -= extra;
            // Keep the original HWNDs and native repeat/keyboard behavior. Suppress
            // only our resize callback so UpDownBase does not reset this split.
            _stepperEdit.Bounds = edit;
            _stepperButtons.Bounds = buttons;
        }
        finally { _arrangingStepper = false; }
    }

    private void SetFrameHover(bool hover)
    {
        if (_frameHover == hover) return;
        _frameHover = hover;
        Invalidate();
    }

    protected override void OnMouseEnter(EventArgs e) { base.OnMouseEnter(e); SetFrameHover(true); }
    protected override void OnMouseLeave(EventArgs e) { base.OnMouseLeave(e); SetFrameHover(false); }
    protected override void OnEnter(EventArgs e) { base.OnEnter(e); Invalidate(); }
    protected override void OnLeave(EventArgs e) { base.OnLeave(e); Invalidate(); }
    protected override void OnEnabledChanged(EventArgs e) { base.OnEnabledChanged(e); Invalidate(); }

    protected override void OnPaint(PaintEventArgs e)
    {
        base.OnPaint(e);
        // Weather already supplies its own outer frame. Keep native border metrics
        // for Config fields and replace only their final painted appearance.
        if (BorderStyle != BorderStyle.None)
        {
            e.Graphics.Clear(BackColor);
            MainForm.InputChrome.DrawNumberFrame(e.Graphics, ClientRectangle, BackColor,
                Enabled && (ContainsFocus || _frameHover), DeviceDpi / 96f);
        }
    }

    protected override void OnMouseWheel(MouseEventArgs e)
    {
        WheelRedirector.RedirectToScrollableParent(this, e);
    }
}

internal static class WheelRedirector
{
    public static void RedirectToScrollableParent(Control source, MouseEventArgs e)
    {
        if (e is HandledMouseEventArgs handled)
        {
            handled.Handled = true;
        }

        var scrollable = FindScrollableParent(source);
        if (scrollable is null || !scrollable.VerticalScroll.Visible)
        {
            return;
        }

        var currentX = -scrollable.AutoScrollPosition.X;
        var currentY = -scrollable.AutoScrollPosition.Y;
        var step = Math.Max(1, SystemInformation.MouseWheelScrollLines) * 24;
        var maxY = Math.Max(0, scrollable.VerticalScroll.Maximum - scrollable.VerticalScroll.LargeChange + 1);
        var targetY = Math.Clamp(currentY - Math.Sign(e.Delta) * step, 0, maxY);
        scrollable.AutoScrollPosition = new Point(currentX, targetY);
    }

    private static ScrollableControl? FindScrollableParent(Control source)
    {
        for (var parent = source.Parent; parent is not null; parent = parent.Parent)
        {
            if (parent is ScrollableControl { AutoScroll: true } scrollable)
            {
                return scrollable;
            }
        }

        return null;
    }
}
