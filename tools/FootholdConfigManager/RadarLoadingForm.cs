using System.Diagnostics;
using System.Drawing.Drawing2D;
using System.Runtime.InteropServices;

namespace FootholdConfigManager;

// Owns one frozen client frame; the manager itself keeps its HWND, opacity and taskbar entry.
internal sealed class RadarLoadingForm : Form
{
    private readonly Bitmap _backdrop;
    private readonly Image _icon; // Private copy for the animation STA.
    private readonly System.Windows.Forms.Timer _animation = new() { Interval = 33 };
    private readonly Stopwatch _clock = new();
    private readonly Font _statusFont = new("Segoe UI", 10);
    private Bitmap? _face;
    private Bitmap? _sweep;
    private Rectangle _radarBounds;
    private Rectangle _statusBounds;
    private string _stage = "Loading…";
    private bool _finishing;
    private int _closeRequested;
    private readonly Color _managerBackground;
    private readonly TaskCompletionSource _closed = new(TaskCreationOptions.RunContinuationsAsynchronously);
    private readonly bool _motionEnabled;
    [DllImport("user32.dll")]
    private static extern bool SystemParametersInfo(uint action, uint parameter, out bool value, uint flags);
    private static readonly PointF[] Contacts = [new(.239f, .182f), new(.757f, .581f), new(.411f, .886f)];
    internal event EventHandler? CancelRequested;
    internal bool IsAnimating => _animation.Enabled;
    protected override bool ShowWithoutActivation => true;

    internal static Task<RadarLoadingForm> ShowAsync(Form manager, Image icon, string stage, Action cancel)
    {
        Bitmap backdrop;
        using (var window = new Bitmap(manager.Width, manager.Height))
        {
            manager.DrawToBitmap(window, new Rectangle(Point.Empty, window.Size));
            var client = manager.PointToScreen(Point.Empty);
            client.Offset(-manager.Left, -manager.Top);
            backdrop = window.Clone(new Rectangle(client, manager.ClientSize), System.Drawing.Imaging.PixelFormat.Format32bppArgb);
        }
        var iconCopy = new Bitmap(icon);
        var bounds = manager.RectangleToScreen(manager.ClientRectangle);
        var background = manager.BackColor;
        var ownerHandle = manager.Handle;
        var shown = new TaskCompletionSource<RadarLoadingForm>(TaskCreationOptions.RunContinuationsAsynchronously);
        var thread = new Thread(() =>
        {
            RadarLoadingForm? radar = null;
            try
            {
                radar = new RadarLoadingForm(backdrop, iconCopy, bounds, background);
                radar._stage = stage;
                radar.CancelRequested += (_, _) => cancel();
                radar.Shown += (_, _) => shown.TrySetResult(radar);
                radar.Show(new RadarOwnerWindow(ownerHandle));
                Application.Run(radar);
            }
            catch (Exception error) { shown.TrySetException(error); }
            finally
            {
                if (radar is null) { backdrop.Dispose(); iconCopy.Dispose(); }
                else { radar.Dispose(); radar._closed.TrySetResult(); }
            }
        }) { IsBackground = true, Name = "Foothold loading radar" };
        thread.SetApartmentState(ApartmentState.STA);
        thread.Start();
        return shown.Task;
    }

    private sealed class RadarOwnerWindow(IntPtr handle) : IWin32Window { public IntPtr Handle => handle; }

    private RadarLoadingForm(Bitmap backdrop, Image icon, Rectangle bounds, Color background)
    {
        _backdrop = backdrop;
        _icon = icon;
        _managerBackground = background;
        _motionEnabled = !SystemInformation.HighContrast && SystemParametersInfo(0x1042, 0, out var animate, 0) && animate;
        Name = "FootholdRadarLoading";
        Text = "Loading · Foothold Config Manager";
        FormBorderStyle = FormBorderStyle.None;
        StartPosition = FormStartPosition.Manual;
        ShowInTaskbar = false;
        AutoScaleMode = AutoScaleMode.None;
        DoubleBuffered = true;
        ForeColor = background.GetBrightness() < .5f ? Color.White : Color.FromArgb(20, 26, 35);
        Font = _statusFont;
        KeyPreview = true;
        AccessibleName = "Configuration loading";
        AccessibleRole = AccessibleRole.ProgressBar;
        Bounds = bounds;
        SizeChanged += (_, _) => ArrangeRadar();
        DpiChanged += (_, _) => { _face?.Dispose(); _face = null; ArrangeRadar(); };
        _animation.Tick += (_, _) => Invalidate(_radarBounds);
        KeyDown += (_, args) => { if (args.KeyCode == Keys.Escape) CancelRequested?.Invoke(this, EventArgs.Empty); };
        FormClosing += (_, args) => { if (!_finishing) { args.Cancel = true; CancelRequested?.Invoke(this, EventArgs.Empty); } };
        ArrangeRadar();
    }

    private void ArrangeRadar()
    {
        var size = Math.Max(32, (int)Math.Round(64 * DeviceDpi / 96d));
        _radarBounds = new Rectangle((ClientSize.Width - size) / 2, (ClientSize.Height - size) / 2 - 20, size, size);
        _statusBounds = new Rectangle(8, _radarBounds.Bottom + (int)(14 * DeviceDpi / 96d), Math.Max(1, ClientSize.Width - 16), Math.Max(32, Font.Height * 3));
        if (_face?.Width != size) BuildRadar(size);
        Invalidate();
    }

    private void BuildRadar(int size)
    {
        _face?.Dispose();
        _sweep?.Dispose();
        _face = new Bitmap(size, size);
        using (var graphics = Graphics.FromImage(_face))
        {
            graphics.SmoothingMode = SmoothingMode.AntiAlias;
            graphics.InterpolationMode = InterpolationMode.HighQualityBicubic;
            graphics.DrawImage(_icon, new Rectangle(0, 0, size, size));
            var screen = RadarScreen(size);
            using var background = new SolidBrush(Color.FromArgb(3, 30, 25));
            graphics.FillEllipse(background, screen);
            var saved = graphics.Save();
            graphics.SetClip(screen, CombineMode.Intersect);
            using var circleClip = new GraphicsPath();
            circleClip.AddEllipse(screen);
            graphics.SetClip(circleClip, CombineMode.Intersect);
            using var grid = new Pen(Color.FromArgb(23, 119, 106), Math.Max(.45f, size / 300f));
            for (var line = 1; line < 10; line++)
            {
                var step = line / 10f;
                graphics.DrawLine(grid, screen.Left + screen.Width * step, screen.Top, screen.Left + screen.Width * step, screen.Bottom);
                graphics.DrawLine(grid, screen.Left, screen.Top + screen.Height * step, screen.Right, screen.Top + screen.Height * step);
            }
            using var ring = new Pen(Color.FromArgb(37, 183, 161), Math.Max(.5f, size / 240f));
            for (var fraction = 1; fraction <= 4; fraction++)
            {
                var diameter = screen.Width * fraction / 4f;
                graphics.DrawEllipse(ring, screen.Left + (screen.Width - diameter) / 2, screen.Top + (screen.Height - diameter) / 2, diameter, diameter);
            }
            graphics.Restore(saved);
        }
        // Bake the fading wedge once per DPI/size; each animation frame only rotates it.
        _sweep = new Bitmap(size, size);
        using var sweepGraphics = Graphics.FromImage(_sweep);
        sweepGraphics.SmoothingMode = SmoothingMode.AntiAlias;
        for (var degree = -70; degree < 0; degree++)
        {
            var opacity = (int)(210 * Math.Pow((degree + 70) / 70d, 2));
            using var brush = new SolidBrush(Color.FromArgb(opacity, 65, 255, 211));
            sweepGraphics.FillPie(brush, RadarScreen(size), degree, 1.3f);
        }
    }

    private static RectangleF RadarScreen(int size) => new(size * .212f, size * .222f, size * .554f, size * .554f);

    internal void Report(LoadingProgress progress)
    {
        if (InvokeRequired)
        {
            BeginInvoke(() => { if (!IsDisposed) Report(progress); });
            return;
        }
        _stage = progress.Stage;
        AccessibleDescription = _stage;
        Invalidate(_statusBounds);
        Update();
    }

    internal void Pause() => Invoke(Hide);
    internal void ResumeLoading() => Invoke(() => { Show(); Update(); });
    internal Task CloseAsync()
    {
        if (Interlocked.Exchange(ref _closeRequested, 1) == 0 && !IsDisposed)
            BeginInvoke(() => { _finishing = true; Close(); });
        return _closed.Task;
    }

    protected override void OnVisibleChanged(EventArgs args)
    {
        base.OnVisibleChanged(args);
        if (Visible) _clock.Start(); else _clock.Stop();
        _animation.Enabled = Visible && _motionEnabled;
    }

    protected override void OnPaint(PaintEventArgs args)
    {
        base.OnPaint(args);
        var graphics = args.Graphics;
        graphics.DrawImage(_backdrop, ClientRectangle);
        using var dim = new SolidBrush(Color.FromArgb(35, _managerBackground));
        graphics.FillRectangle(dim, ClientRectangle);
        graphics.SmoothingMode = SmoothingMode.AntiAlias;
        graphics.InterpolationMode = InterpolationMode.HighQualityBicubic;
        graphics.DrawImageUnscaled(_face!, _radarBounds.Location);
        var screen = RadarScreen(_radarBounds.Width);
        screen.Offset(_radarBounds.Location);
        var angle = 45f + (float)(_clock.Elapsed.TotalSeconds % 3 * 120);
        var state = graphics.Save();
        graphics.TranslateTransform(screen.Left + screen.Width / 2, screen.Top + screen.Height / 2);
        graphics.RotateTransform(angle);
        graphics.TranslateTransform(-(screen.Left + screen.Width / 2), -(screen.Top + screen.Height / 2));
        graphics.DrawImageUnscaled(_sweep!, _radarBounds.Location);
        graphics.Restore(state);
        foreach (var contact in Contacts)
        {
            var bearing = (float)(Math.Atan2(contact.Y - .5, contact.X - .5) * 180 / Math.PI);
            var sincePass = (angle - bearing + 720) % 360;
            var alpha = _motionEnabled ? Math.Clamp(1 - sincePass / 126f, 0, 1) : .65f;
            if (alpha <= 0) continue;
            var diameter = Math.Max(2, screen.Width * .07f);
            using var glow = new SolidBrush(Color.FromArgb((int)(alpha * 80), 55, 255, 191));
            using var dot = new SolidBrush(Color.FromArgb((int)(alpha * 255), 200, 255, 241));
            var x = screen.Left + screen.Width * contact.X;
            var y = screen.Top + screen.Height * contact.Y;
            graphics.FillEllipse(glow, x - diameter, y - diameter, diameter * 2, diameter * 2);
            graphics.FillEllipse(dot, x - diameter / 2, y - diameter / 2, diameter, diameter);
        }
        // Preserve the original fixed aircraft in the middle of the branded radar.
        var aircraft = new RectangleF(.438f, .435f, .095f, .145f);
        graphics.DrawImage(_icon,
            new RectangleF(_radarBounds.Left + aircraft.X * _radarBounds.Width, _radarBounds.Top + aircraft.Y * _radarBounds.Height, aircraft.Width * _radarBounds.Width, aircraft.Height * _radarBounds.Height),
            new RectangleF(aircraft.X * _icon.Width, aircraft.Y * _icon.Height, aircraft.Width * _icon.Width, aircraft.Height * _icon.Height), GraphicsUnit.Pixel);
        TextRenderer.DrawText(graphics, _stage, Font, _statusBounds, ForeColor,
            TextFormatFlags.HorizontalCenter | TextFormatFlags.Top | TextFormatFlags.WordBreak | TextFormatFlags.NoPrefix);
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing)
        {
            _animation.Dispose();
            _backdrop.Dispose();
            _icon.Dispose();
            _face?.Dispose();
            _sweep?.Dispose();
            _statusFont.Dispose();
        }
        base.Dispose(disposing);
    }
}
