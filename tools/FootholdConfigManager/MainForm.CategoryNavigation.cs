using System.Drawing;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    [StructLayout(LayoutKind.Sequential)]
    private struct PaintInfo
    {
        public IntPtr Hdc;
        public int Erase;
        public RectangleEdges Area;
        public int Restore, Incremental;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 32)] public byte[] Reserved;
    }
    [StructLayout(LayoutKind.Sequential)]
    private struct RectangleEdges { public int Left, Top, Right, Bottom; }
    [DllImport("user32.dll")] private static extern IntPtr BeginPaint(IntPtr window, out PaintInfo paint);
    [DllImport("user32.dll")] private static extern bool EndPaint(IntPtr window, ref PaintInfo paint);

    // Keep native ListBox selection, scrolling and DrawItem callbacks; compose its client frame off-screen.
    private sealed class CategoryNavigationListBox : ListBox
    {

        private readonly System.Windows.Forms.Timer _hoverTimer = new() { Interval = 16 };
        private int _hoverIndex = -1;
        private Point _pointer;
        private bool _hasPointer;
        private bool _composingClient;
        private IntPtr _composingTarget;
        private float _hoverTop, _startTop, _targetTop, _opacity, _startOpacity, _targetOpacity;
        private long _started;
        private int _duration;
        private float PixelScale => Font.SizeInPoints / BaseFontSize * DeviceDpi / 96f;
        private Rectangle HoverDamage => Rectangle.Ceiling(new RectangleF(0, _hoverTop - 2, ClientSize.Width, ItemHeight + 4));

        public CategoryNavigationListBox()
        {
            _hoverTimer.Tick += (_, _) => AdvanceHover();
        }

        [DllImport("user32.dll")]
        private static extern bool SystemParametersInfo(uint action, uint parameter, out bool value, uint flags);

        protected override void OnMouseMove(MouseEventArgs e)
        {
            base.OnMouseMove(e);
            _pointer = e.Location;
            _hasPointer = true;
            MoveHover(IndexFromPoint(e.Location));
        }

        protected override void OnMouseLeave(EventArgs e)
        {
            base.OnMouseLeave(e);
            _hasPointer = false;
            MoveHover(-1);
        }

        private void MoveHover(int index)
        {
            if (SystemInformation.HighContrast || index == _hoverIndex) return;
            // Continue from the last displayed frame when the pointer changes direction.
            _hoverIndex = index;
            _startOpacity = _opacity;
            _targetOpacity = index < 0 ? 0 : 1;
            _startTop = _hoverTop;
            _targetTop = index < 0 ? _hoverTop : GetItemRectangle(index).Top;
            // First entry has no previous row to slide from.
            if (_opacity == 0) _startTop = _hoverTop = _targetTop;
            _started = System.Diagnostics.Stopwatch.GetTimestamp();
            _duration = index < 0 ? 90 : 160;
            if (SystemParametersInfo(0x1042, 0, out var animate, 0) && animate)
                _hoverTimer.Start();
            else
                AdvanceHover(true);
        }

        private void AdvanceHover(bool finish = false)
        {
            if (!_hoverTimer.Enabled && !finish) return;
            var damage = HoverDamage;
            var progress = finish ? 1 : Math.Min(1, System.Diagnostics.Stopwatch.GetElapsedTime(_started).TotalMilliseconds / _duration);
            var eased = (float)(1 - Math.Pow(1 - progress, 3));
            _hoverTop = _startTop + (_targetTop - _startTop) * eased;
            _opacity = _startOpacity + (_targetOpacity - _startOpacity) * eased;
            Invalidate(Rectangle.Union(damage, HoverDamage));
            if (progress >= 1) _hoverTimer.Stop();
        }

        private void ResetHover()
        {
            _hoverTimer.Stop();
            _hoverIndex = -1;
            _hasPointer = false;
            var damage = HoverDamage;
            _opacity = 0;
            Invalidate(damage);
        }

        protected override void OnSizeChanged(EventArgs e)
        {
            base.OnSizeChanged(e);
            ResetHover();
            Invalidate();
        }

        protected override void OnFontChanged(EventArgs e)
        {
            base.OnFontChanged(e);
            ResetHover();
        }

        protected override void OnVisibleChanged(EventArgs e)
        {
            base.OnVisibleChanged(e);
            if (!Visible) ResetHover();
        }

        protected override void OnHandleDestroyed(EventArgs e)
        {
            ResetHover();
            base.OnHandleDestroyed(e);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing) _hoverTimer.Dispose();
            base.Dispose(disposing);
        }

        protected override void OnDrawItem(DrawItemEventArgs e)
        {
            if (SystemInformation.HighContrast)
            {
                base.OnDrawItem(e);
                return;
            }
            if (_composingClient)
            {
                // A focused native ListBox also draws its selected row directly during WM_PRINTCLIENT.
                // Only rows targeting our actual client buffer may bypass their own buffering.
                var destination = e.Graphics.GetHdc();
                e.Graphics.ReleaseHdc(destination);
                if (destination == _composingTarget)
                {
                    base.OnDrawItem(e);
                    return;
                }
            }
            // Native selection can draw a row directly, outside WM_PAINT. Buffer that path too.
            using var frame = BufferedGraphicsManager.Current.Allocate(e.Graphics, e.Bounds);
            frame.Graphics.Clear(BackColor);
            base.OnDrawItem(new DrawItemEventArgs(frame.Graphics, e.Font, e.Bounds, e.Index, e.State, e.ForeColor, e.BackColor));
            frame.Graphics.SetClip(e.Bounds);
            DrawHover(frame.Graphics);
            frame.Render(e.Graphics);
        }
        private void DrawHover(Graphics graphics)
        {
            if (_opacity <= 0 || SystemInformation.HighContrast) return;
            var inset = Math.Max(3, (int)Math.Round(6 * PixelScale));
            var verticalInset = Math.Max(2, (int)Math.Round(3 * PixelScale));
            var bounds = new RectangleF(inset, (int)Math.Round(_hoverTop) + verticalInset,
                ClientSize.Width - 2 * inset - 1, ItemHeight - 2 * verticalInset - 1);
            if (bounds.Width <= 0 || bounds.Height <= 0) return;
            var border = IsDarkPalette() ? Color.FromArgb(93, 122, 151) : ControlBorderColor;
            using var pen = new Pen(Color.FromArgb((int)Math.Round(255 * _opacity), border));
            using var path = ConfigSearchSurface.RoundedRectangle(bounds, 3 * PixelScale);
            graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
            graphics.DrawPath(pen, path);
        }
        protected override void WndProc(ref Message message)
        {
            if (SystemInformation.HighContrast)
            {
                base.WndProc(ref message);
                return;
            }
            switch (message.Msg)
            {
                case 0x0014: // WM_ERASEBKGND: the completed client frame includes its background.
                    message.Result = new IntPtr(1);
                    return;
                case 0x000F: // WM_PAINT
                    var hdc = BeginPaint(Handle, out var paint);
                    try { DrawBufferedClient(hdc); }
                    finally { EndPaint(Handle, ref paint); }
                    message.Result = IntPtr.Zero;
                    return;
                case 0x0317: // WM_PRINT
                case 0x0318: // WM_PRINTCLIENT, including native captures.
                    DrawBufferedClient(message.WParam);
                    return;
            }
            base.WndProc(ref message);
            if (_hasPointer && message.Msg is 0x0115 or 0x020A or 0x0197 or 0x0186 or 0x0100)
            {
                // Native scrolling/selection may change which row is under a stationary pointer.
                var pointer = _pointer;
                ResetHover();
                _hasPointer = true;
                MoveHover(IndexFromPoint(pointer));
            }
        }

        private void DrawBufferedClient(IntPtr hdc)
        {
            if (ClientSize.Width <= 0 || ClientSize.Height <= 0) return;
            using var frame = BufferedGraphicsManager.Current.Allocate(hdc, ClientRectangle);
            frame.Graphics.Clear(BackColor);
            var target = frame.Graphics.GetHdc();
            try
            {
                var print = Message.Create(Handle, 0x0318, target, new IntPtr(4 | 8));
                _composingTarget = target;
                _composingClient = true;
                base.WndProc(ref print);
            }
            finally { _composingClient = false; _composingTarget = IntPtr.Zero; frame.Graphics.ReleaseHdc(target); }
            DrawHover(frame.Graphics);
            frame.Render(hdc);
        }
    }
}
