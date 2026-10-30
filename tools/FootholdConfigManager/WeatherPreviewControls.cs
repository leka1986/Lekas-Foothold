using System.Drawing.Drawing2D;

namespace FootholdConfigManager;

internal sealed class WeatherPreviewTabs : TabControl
{
    public WeatherPreviewTabs()
    {
        SetStyle(ControlStyles.UserPaint | ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw, true);
        SizeMode = TabSizeMode.Fixed;
    }

    internal Color Surface { get; set; } = Color.FromArgb(20, 26, 35);
    internal Color Accent { get; set; } = Color.FromArgb(86, 156, 214);
    internal Color LineColor { get; set; } = Color.FromArgb(57, 72, 91);
    internal Color SelectedSurface { get; set; } = Color.FromArgb(24, 32, 43);

    protected override void OnSelectedIndexChanged(EventArgs e)
    {
        base.OnSelectedIndexChanged(e);
        Invalidate();
    }

    protected override void OnPaint(PaintEventArgs e)
    {
        e.Graphics.Clear(Surface);
        var bottom = TabCount == 0 ? 0 : GetTabRect(0).Bottom;
        using var line = new Pen(LineColor);
        e.Graphics.DrawLine(line, 0, bottom, Width, bottom);
        for (var i = 0; i < TabCount; i++)
        {
            var rect = GetTabRect(i);
            if (i == SelectedIndex)
            {
                using var surface = new SolidBrush(SelectedSurface);
                e.Graphics.FillRectangle(surface, rect);
                using var accent = new SolidBrush(Accent);
                e.Graphics.FillRectangle(accent, rect.Left, rect.Bottom - 3, rect.Width, 3);
            }
            TextRenderer.DrawText(e.Graphics, TabPages[i].Text, Font, rect,
                TabPages[i].Enabled ? ForeColor : SystemColors.GrayText,
                TextFormatFlags.HorizontalCenter | TextFormatFlags.VerticalCenter | TextFormatFlags.NoPrefix);
            if (Focused && SelectedIndex == i) ControlPaint.DrawFocusRectangle(e.Graphics, Rectangle.Inflate(rect, -5, -5), ForeColor, BackColor);
        }
    }
}

internal sealed class WeatherInputFrame : Panel
{
    private readonly Panel _editorViewport = new();
    private bool _hover;
    internal WeatherInputFrame(Control input, int height)
    {
        Input = input;
        Height = height;
        SetStyle(ControlStyles.UserPaint | ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw, true);
        _editorViewport.Controls.Add(input);
        Controls.Add(_editorViewport);
        input.Dock = DockStyle.None;
        input.Margin = Padding.Empty;
        input.MouseEnter += (_, _) => { _hover = true; Invalidate(); };
        input.MouseLeave += (_, _) => { _hover = false; Invalidate(); };
        input.Enter += (_, _) => Invalidate();
        input.Leave += (_, _) => Invalidate();
        input.EnabledChanged += (_, _) => Invalidate();
    }

    internal Control Input { get; }
    internal Color BorderColor { get; set; }
    internal Color FocusColor { get; set; }
    internal int Inset { get; set; } = 8;

    protected override void OnLayout(LayoutEventArgs levent)
    {
        base.OnLayout(levent);
        if (Input is null) return;
        var height = Input.PreferredSize.Height;
        _editorViewport.BackColor = BackColor;
        _editorViewport.SetBounds(Inset, Math.Max(1, (Height - height) / 2), Math.Max(1, Width - Inset * 2), height);
        var spinnerWidth = Input is WeatherNumberBox { ShowSpinner: false } ? SystemInformation.VerticalScrollBarWidth + 4 : 0;
        Input.SetBounds(0, 0, _editorViewport.Width + spinnerWidth, height);
    }

    protected override void OnPaint(PaintEventArgs e)
    {
        base.OnPaint(e);
        var line = Input.Enabled && (Input.ContainsFocus || _hover) ? FocusColor : BorderColor;
        MainForm.InputChrome.DrawFrame(e.Graphics, ClientRectangle, BackColor, line, DeviceDpi / 96f);
    }
}
internal sealed class WeatherCloudCard : Button
{
    private bool _hover;
    protected override void OnMouseEnter(EventArgs e) { _hover = true; Invalidate(); base.OnMouseEnter(e); }
    protected override void OnMouseLeave(EventArgs e) { _hover = false; Invalidate(); base.OnMouseLeave(e); }
    protected override void OnPaint(PaintEventArgs e)
    {
        e.Graphics.Clear(_hover ? FlatAppearance.MouseOverBackColor : BackColor);
        var imageHeight = Math.Min(Height - Font.Height * 2 - 10, (int)(Width / 1.95));
        if (Image is not null) e.Graphics.DrawImage(Image, new Rectangle(2, 2, Width - 4, Math.Max(1, imageHeight)));
        TextRenderer.DrawText(e.Graphics, Text, Font, new Rectangle(8, imageHeight + 7, Width - 16, Height - imageHeight - 9), ForeColor,
            TextFormatFlags.WordBreak | TextFormatFlags.Left | TextFormatFlags.NoPrefix);
        using var border = new Pen(FlatAppearance.BorderColor, FlatAppearance.BorderSize);
        e.Graphics.DrawRectangle(border, 1, 1, Width - 2, Height - 2);
        if (Focused) ControlPaint.DrawFocusRectangle(e.Graphics, Rectangle.Inflate(ClientRectangle, -5, -5), ForeColor, BackColor);
    }
}
internal sealed class WeatherCheckBox : CheckBox
{
    private bool _hot, _pressed;
    internal Color DisabledTextColor { get; set; } = Color.FromArgb(145, 160, 177);
    public WeatherCheckBox() => DoubleBuffered = true;
    protected override void OnMouseEnter(EventArgs e) { _hot = true; Invalidate(); base.OnMouseEnter(e); }
    protected override void OnMouseLeave(EventArgs e) { _hot = _pressed = false; Invalidate(); base.OnMouseLeave(e); }
    protected override void OnMouseDown(MouseEventArgs e) { _pressed = e.Button == MouseButtons.Left; Invalidate(); base.OnMouseDown(e); }
    protected override void OnMouseUp(MouseEventArgs e) { _pressed = false; Invalidate(); base.OnMouseUp(e); }
    protected override void OnMouseCaptureChanged(EventArgs e) { if (!Capture) _pressed = false; Invalidate(); base.OnMouseCaptureChanged(e); }
    public override Size GetPreferredSize(Size proposedSize)
    {
        var text = string.IsNullOrEmpty(Text) ? Size.Empty : TextRenderer.MeasureText(Text, Font, Size.Empty, TextFormatFlags.NoPrefix);
        return new Size(GlyphSize(this) + (text.Width > 0 ? text.Width + 6 : 4), Math.Max(GlyphSize(this), text.Height) + 4);
    }
    protected override void OnPaint(PaintEventArgs e) => PaintToggle(this, e.Graphics, Checked, false, CheckAlign, _hot, _pressed, DisabledTextColor, ShowFocusCues);

    private static int GlyphSize(Control c) => Math.Max((int)Math.Round(14 * c.DeviceDpi / 96f), c.Font.Height - 1);
    internal static void PaintToggle(Control c, Graphics graphics, bool selected, bool radio, ContentAlignment align, bool hot, bool pressed, Color disabledText, bool showFocus)
    {
        graphics.Clear(c.BackColor);
        graphics.SmoothingMode = SmoothingMode.AntiAlias;
        var dark = c.BackColor.GetBrightness() < .5f;
        var accent = dark ? Color.FromArgb(86, 156, 214) : Color.FromArgb(30, 120, 167);
        var outline = dark ? Color.FromArgb(145, 160, 177) : Color.FromArgb(100, 119, 136);
        var size = Math.Min(Math.Min(c.Width - 2, c.Height - 2), GlyphSize(c));
        if (size < 2) return;
        var right = align is ContentAlignment.TopRight or ContentAlignment.MiddleRight or ContentAlignment.BottomRight;
        var x = right ? c.Width - size - 1 : align == ContentAlignment.MiddleCenter ? (c.Width - size) / 2 : 1;
        var box = new Rectangle(x, (c.Height - size) / 2, size, size);
        var edge = c.Enabled && hot ? accent : outline;
        var fill = selected ? (c.Enabled ? hot ? pressed ? ControlPaint.Dark(accent, .1f) : ControlPaint.Light(accent, .2f) : accent : outline) : hot && c.Enabled ? ControlPaint.Light(c.BackColor, pressed ? .2f : .1f) : c.BackColor;
        if (radio)
        {
            using var brush = new SolidBrush(hot && c.Enabled ? ControlPaint.Light(c.BackColor, .1f) : c.BackColor); using var pen = new Pen(selected && c.Enabled ? accent : edge, c.DeviceDpi / 96f);
            graphics.FillEllipse(brush, box); graphics.DrawEllipse(pen, box);
            if (selected) { using var dot = new SolidBrush(c.Enabled ? accent : outline); graphics.FillEllipse(dot, Rectangle.Inflate(box, -3, -3)); }
        }
        else
        {
            MainForm.InputChrome.DrawFrame(graphics, box, fill, selected ? fill : edge, c.DeviceDpi / 96f);
            if (selected)
            {
                using var tick = new Pen(c.BackColor, Math.Max(1.6f, size / 8f)) { StartCap = LineCap.Round, EndCap = LineCap.Round, LineJoin = LineJoin.Round };
                graphics.DrawLines(tick, new[] { new PointF(box.Left + size * .24f, box.Top + size * .51f), new PointF(box.Left + size * .43f, box.Top + size * .72f), new PointF(box.Left + size * .79f, box.Top + size * .27f) });
            }
        }
        var textBounds = new Rectangle(right ? 0 : box.Right + 6, 0, Math.Max(0, c.Width - size - 7), c.Height);
        TextRenderer.DrawText(graphics, c.Text, c.Font, textBounds, c.Enabled ? c.ForeColor : disabledText, TextFormatFlags.Left | TextFormatFlags.VerticalCenter | TextFormatFlags.SingleLine | TextFormatFlags.NoPrefix);
        if (c.Focused && showFocus) ControlPaint.DrawFocusRectangle(graphics, Rectangle.Inflate(c.ClientRectangle, -1, -1), c.ForeColor, c.BackColor);
    }
}

internal sealed class WeatherRadioButton : RadioButton
{
    private bool _hot, _pressed;
    public WeatherRadioButton() => DoubleBuffered = true;
    protected override void OnMouseEnter(EventArgs e) { _hot = true; Invalidate(); base.OnMouseEnter(e); }
    protected override void OnMouseLeave(EventArgs e) { _hot = _pressed = false; Invalidate(); base.OnMouseLeave(e); }
    protected override void OnMouseDown(MouseEventArgs e) { _pressed = e.Button == MouseButtons.Left; Invalidate(); base.OnMouseDown(e); }
    protected override void OnMouseUp(MouseEventArgs e) { _pressed = false; Invalidate(); base.OnMouseUp(e); }
    protected override void OnMouseCaptureChanged(EventArgs e) { if (!Capture) _pressed = false; Invalidate(); base.OnMouseCaptureChanged(e); }
    protected override void OnPaint(PaintEventArgs e) => WeatherCheckBox.PaintToggle(this, e.Graphics, Checked, true, CheckAlign, _hot, _pressed, ForeColor, ShowFocusCues);
}
internal sealed class WeatherNumberBox : WheelSafeNumericUpDown
{
    private bool _padToTwoDigits;
    internal bool ShowSpinner { get; set; }
    internal bool PadToTwoDigits
    {
        get => _padToTwoDigits;
        set { _padToTwoDigits = value; UpdateEditText(); }
    }

    protected override void UpdateEditText()
    {
        base.UpdateEditText();
        if (!_padToTwoDigits || UserEdit || DecimalPlaces != 0 || Hexadecimal) return;
        var formatted = Value.ToString("00", System.Globalization.CultureInfo.CurrentCulture);
        if (Text == formatted) return;
        ChangingText = true;
        Text = formatted;
    }
    protected override void OnMouseWheel(MouseEventArgs e)
    {
        base.OnMouseWheel(e);
        WeatherScrollHost.SynchronizeParent(this);
    }
}

internal sealed class WeatherChoiceBox : WheelSafeComboBox
{
    protected override void OnMouseWheel(MouseEventArgs e)
    {
        base.OnMouseWheel(e);
        WeatherScrollHost.SynchronizeParent(this);
    }
}

internal sealed partial class WeatherDateTimeInput : DateTimePicker
{
    private Color _surfaceColor = Color.FromArgb(30, 40, 53);
    internal Color SurfaceColor { get => _surfaceColor; set { _surfaceColor = value; RefreshDateTextAppearance(); } }

    protected override void WndProc(ref Message m)
    {
        if (HandleDateTextMessage(ref m)) return;
        if (m.Msg == 0x0014) { m.Result = new IntPtr(1); return; }
        if (m.Msg == 0x000F)
        {
            var dc = MainForm.InputChrome.BeginPaint(Handle, out var paint);
            try
            {
                if (dc != IntPtr.Zero)
                {
                    using var graphics = Graphics.FromHdc(dc);
                    using var buffer = BufferedGraphicsManager.Current.Allocate(graphics, ClientRectangle);
                    DrawThemed(buffer.Graphics);
                    buffer.Render(graphics);
                }
            }
            finally { MainForm.InputChrome.EndPaint(Handle, ref paint); }
            m.Result = IntPtr.Zero;
            return;
        }
        if ((m.Msg == 0x0317 || m.Msg == 0x0318) && m.WParam != IntPtr.Zero)
        {
            using var graphics = Graphics.FromHdc(m.WParam);
            DrawThemed(graphics);
            if (DirectDateTextEntry && (m.LParam.ToInt64() & 0x0010) != 0) DrawDateTextForPrint(graphics);
            m.Result = IntPtr.Zero;
            return;
        }
        base.WndProc(ref m);
    }
    protected override void OnLostFocus(EventArgs e) { base.OnLostFocus(e); Invalidate(); }

    private void DrawClosed(Graphics graphics)
    {
        if (ContainsFocus && !DirectDateTextEntry) return; // Retain native segment feedback only for the legacy mode.
        using var surface = new SolidBrush(SurfaceColor);
        graphics.FillRectangle(surface, ClientRectangle);
        var color = Enabled ? ForeColor : SystemColors.GrayText;
        if (!DirectDateTextEntry)
            TextRenderer.DrawText(graphics, Value.ToString(CustomFormat, System.Globalization.CultureInfo.CurrentCulture), Font,
                new Rectangle(3, 0, Math.Max(1, Width - 25), Height), color, TextFormatFlags.VerticalCenter | TextFormatFlags.NoPrefix);
        using var pen = new Pen(color, 1.2f);
        var x = Width - 12;
        var y = Height / 2;
        if (ShowUpDown)
        {
            graphics.DrawLines(pen, new[] { new Point(x - 3, y - 3), new Point(x, y - 6), new Point(x + 3, y - 3) });
            graphics.DrawLines(pen, new[] { new Point(x - 3, y + 3), new Point(x, y + 6), new Point(x + 3, y + 3) });
        }
        else
        {
            graphics.DrawRectangle(pen, x - 5, y - 5, 10, 10);
            graphics.DrawLine(pen, x - 5, y - 2, x + 5, y - 2);
        }
        if (Focused && !DirectDateTextEntry) ControlPaint.DrawFocusRectangle(graphics, new Rectangle(2, 2, Math.Max(1, Width - 23), Height - 4), color, SurfaceColor);
    }
}