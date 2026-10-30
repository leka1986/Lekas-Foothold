using System.Drawing.Drawing2D;

namespace FootholdConfigManager;

// Like the manager's ToolbarIconButton, this control owns and buffers its
// drawing. Native input controls keep their existing manager painting path.
internal sealed class WeatherWindDial : Control
{
    private double _bearingTo;
    private bool _hover;
    internal bool IsDragging { get; private set; }
    internal Color AccentColor { get; set; } = SystemColors.Highlight;
    internal Color LineColor { get; set; } = SystemColors.ControlDark;
    internal event EventHandler? BearingChanged;
    internal event EventHandler? DragCompleted;

    internal WeatherWindDial()
    {
        TabStop = true;
        Cursor = Cursors.Hand;
        AccessibleRole = AccessibleRole.Dial;
        SetStyle(ControlStyles.UserPaint | ControlStyles.AllPaintingInWmPaint |
            ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw | ControlStyles.Selectable, true);
    }

    internal double BearingTo
    {
        get => _bearingTo;
        set
        {
            var normalized = ((value % 360) + 360) % 360;
            if (_bearingTo == normalized) return;
            _bearingTo = normalized;
            Invalidate();
        }
    }

    private void SetBearing(double value)
    {
        var before = BearingTo;
        BearingTo = value;
        if (before != BearingTo) BearingChanged?.Invoke(this, EventArgs.Empty);
    }

    private void TrackPointer(Point point)
    {
        var x = point.X - ClientSize.Width / 2f;
        var y = point.Y - ClientSize.Height / 2f;
        // A bearing is undefined at the center; retain the last direction.
        var deadZone = Math.Max(3, DeviceDpi / 32f);
        if (x * x + y * y < deadZone * deadZone) return;
        SetBearing(Math.Atan2(x, -y) * 180 / Math.PI);
    }

    protected override void OnMouseDown(MouseEventArgs e)
    {
        base.OnMouseDown(e);
        if (!Enabled || e.Button != MouseButtons.Left) return;
        Focus();
        IsDragging = true;
        Capture = true;
        TrackPointer(e.Location);
        Invalidate();
    }

    protected override void OnMouseMove(MouseEventArgs e)
    {
        base.OnMouseMove(e);
        if (IsDragging && Capture) TrackPointer(e.Location);
    }

    protected override void OnMouseUp(MouseEventArgs e)
    {
        base.OnMouseUp(e);
        if (!IsDragging || e.Button != MouseButtons.Left) return;
        TrackPointer(e.Location);
        EndDrag();
    }

    private void EndDrag()
    {
        if (!IsDragging) return;
        IsDragging = false;
        Capture = false;
        Invalidate();
        DragCompleted?.Invoke(this, EventArgs.Empty);
    }

    protected override void OnMouseCaptureChanged(EventArgs e)
    {
        base.OnMouseCaptureChanged(e);
        if (!Capture) EndDrag();
    }

    protected override void OnEnabledChanged(EventArgs e)
    {
        base.OnEnabledChanged(e);
        if (!Enabled) EndDrag();
        Invalidate();
    }

    protected override void OnVisibleChanged(EventArgs e)
    {
        base.OnVisibleChanged(e);
        if (!Visible) EndDrag();
    }

    protected override bool IsInputKey(Keys keyData) => (keyData & Keys.KeyCode) is
        Keys.Left or Keys.Right or Keys.Up or Keys.Down or Keys.Home || base.IsInputKey(keyData);

    protected override void OnKeyDown(KeyEventArgs e)
    {
        var step = e.Shift ? 10 : 1;
        switch (e.KeyCode)
        {
            case Keys.Right: case Keys.Up: SetBearing(Math.Round(BearingTo) + step); break;
            case Keys.Left: case Keys.Down: SetBearing(Math.Round(BearingTo) - step); break;
            case Keys.Home: SetBearing(0); break;
            default: base.OnKeyDown(e); return;
        }
        e.Handled = e.SuppressKeyPress = true;
    }

    protected override void OnMouseWheel(MouseEventArgs e)
    {
        WheelRedirector.RedirectToScrollableParent(this, e);
        WeatherScrollHost.SynchronizeParent(this);
    }

    protected override void OnMouseEnter(EventArgs e) { _hover = true; Invalidate(); base.OnMouseEnter(e); }
    protected override void OnMouseLeave(EventArgs e) { _hover = false; Invalidate(); base.OnMouseLeave(e); }

    protected override void OnGotFocus(EventArgs e) { base.OnGotFocus(e); Invalidate(); }
    protected override void OnLostFocus(EventArgs e) { base.OnLostFocus(e); Invalidate(); }

    protected override void OnPaint(PaintEventArgs e)
    {
        base.OnPaint(e);
        var size = Math.Min(ClientSize.Width, ClientSize.Height);
        var scale = size / 48f;
        var center = new PointF(ClientSize.Width / 2f, ClientSize.Height / 2f);
        var ringWidth = Math.Max(1f, scale * 1.2f);
        if (Focused && ShowFocusCues) ringWidth += Math.Max(.5f, scale * .5f);
        var radius = Math.Max(1f, size / 2f - Math.Max(2.5f, scale * 3f) - ringWidth / 2f);
        var circle = new RectangleF(center.X - radius, center.Y - radius, radius * 2f, radius * 2f);
        var angle = BearingTo * Math.PI / 180;
        var direction = new PointF((float)Math.Sin(angle), -(float)Math.Cos(angle));
        var delta = new PointF(direction.X * radius * .64f, direction.Y * radius * .64f);
        var tip = new PointF(center.X + delta.X, center.Y + delta.Y);
        var headLength = Math.Max(3f, scale * 4f);
        var headSide = headLength * .58f;
        var headBase = new PointF(tip.X - direction.X * headLength, tip.Y - direction.Y * headLength);
        e.Graphics.SmoothingMode = SmoothingMode.AntiAlias;
        e.Graphics.PixelOffsetMode = PixelOffsetMode.HighQuality;
        if (Enabled && (_hover || IsDragging))
        {
            using var fill = new SolidBrush(IsDragging ? MainForm.InputChrome.PressedSurface : MainForm.InputChrome.HoverSurface);
            e.Graphics.FillEllipse(fill, circle);
        }
        using var ring = new Pen(Enabled ? (_hover || IsDragging || Focused ? AccentColor : LineColor) : SystemColors.GrayText, ringWidth);
        using var arrow = new Pen(Enabled ? AccentColor : SystemColors.GrayText, Math.Max(1.4f, scale * 1.7f))
        {
            StartCap = LineCap.Round, EndCap = LineCap.Round, LineJoin = LineJoin.Round
        };
        e.Graphics.DrawEllipse(ring, circle);
        e.Graphics.DrawLine(arrow, center.X - delta.X * .7f, center.Y - delta.Y * .7f, tip.X, tip.Y);
        e.Graphics.DrawLines(arrow, new[]
        {
            new PointF(headBase.X - direction.Y * headSide, headBase.Y + direction.X * headSide),
            tip,
            new PointF(headBase.X + direction.Y * headSide, headBase.Y - direction.X * headSide)
        });
    }
}
