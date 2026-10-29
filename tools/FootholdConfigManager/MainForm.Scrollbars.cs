using System.Drawing;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private sealed partial class SmoothDataGridView
    {
        private SlimScrollbarWindow _verticalScrollbar = null!;
        private SlimScrollbarWindow _horizontalScrollbar = null!;

        private void InitializeScrollbarPresentation()
        {
            _verticalScrollbar = new SlimScrollbarWindow(VerticalScrollBar, true);
            _horizontalScrollbar = new SlimScrollbarWindow(HorizontalScrollBar, false);
        }

        public void RefreshScrollbarTheme()
        {
            _verticalScrollbar.Refresh();
            _horizontalScrollbar.Refresh();
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                _verticalScrollbar.Dispose();
                _horizontalScrollbar.Dispose();
            }
            base.Dispose(disposing);
        }
    }

    // The grid still owns scrolling, range calculation, validation and accessibility.
    // This presents its real ScrollBar controls with an arrow-free track and thumb.
    private sealed class SlimScrollbarWindow : NativeWindow, IDisposable
    {
        private static readonly Action<ScrollBar, ScrollEventArgs> RaiseScroll =
            typeof(ScrollBar).GetMethod("OnScroll", BindingFlags.Instance | BindingFlags.NonPublic)!
                .CreateDelegate<Action<ScrollBar, ScrollEventArgs>>();
        private readonly bool _vertical;
        private bool _hover;
        private bool _dragging;
        private int _grabOffset;

        public ScrollBar ScrollBar { get; }
        private int MaximumValue => Math.Max(ScrollBar.Minimum, ScrollBar.Maximum - ScrollBar.LargeChange + 1);
        private float Scale => ScrollBar.Font.SizeInPoints / BaseFontSize * ScrollBar.DeviceDpi / 96f;
        private int Length => _vertical ? ScrollBar.ClientSize.Height : ScrollBar.ClientSize.Width;

        public Rectangle ThumbBounds
        {
            get
            {
                if (!ScrollBar.Enabled || MaximumValue <= ScrollBar.Minimum || Length <= 0) return Rectangle.Empty;
                var cross = _vertical ? ScrollBar.ClientSize.Width : ScrollBar.ClientSize.Height;
                if (cross < 5) return Rectangle.Empty;
                var thumbLength = Math.Clamp((int)Math.Round((double)Length * ScrollBar.LargeChange /
                    (ScrollBar.Maximum - ScrollBar.Minimum + 1)), Math.Min(Length, (int)Math.Round(24 * Scale)), Length);
                var thumbWidth = Math.Clamp((int)Math.Round(12 * Scale), 4, cross - 2);
                var position = (int)Math.Round((double)(Length - thumbLength) *
                    (ScrollBar.Value - ScrollBar.Minimum) / (MaximumValue - ScrollBar.Minimum));
                return _vertical
                    ? new Rectangle((cross - thumbWidth) / 2, position, thumbWidth, thumbLength)
                    : new Rectangle(position, (cross - thumbWidth) / 2, thumbLength, thumbWidth);
            }
        }

        public SlimScrollbarWindow(ScrollBar scrollBar, bool vertical)
        {
            ScrollBar = scrollBar;
            _vertical = vertical;
            scrollBar.HandleCreated += Attach;
            scrollBar.HandleDestroyed += Detach;
            scrollBar.ValueChanged += Changed;
            scrollBar.SizeChanged += Changed;
            scrollBar.FontChanged += Changed;
            scrollBar.EnabledChanged += Changed;
            scrollBar.VisibleChanged += Changed;
            if (scrollBar.IsHandleCreated) AssignHandle(scrollBar.Handle);
        }

        private void Attach(object? sender, EventArgs args) => AssignHandle(ScrollBar.Handle);
        private void Detach(object? sender, EventArgs args)
        {
            _dragging = false;
            _hover = false;
            ReleaseHandle();
        }

        private void Changed(object? sender, EventArgs args) => Refresh();
        public void Refresh()
        {
            ScrollBar.Invalidate();
            if (ScrollBar.IsHandleCreated && ScrollBar.Visible) ScrollBar.Update();
        }

        private void Draw(IntPtr hdc)
        {
            using var frame = BufferedGraphicsManager.Current.Allocate(hdc, ScrollBar.ClientRectangle);
            var graphics = frame.Graphics;
            using var trackBrush = new SolidBrush(HeaderBackground);
            graphics.FillRectangle(trackBrush, ScrollBar.ClientRectangle);
            var thumb = ThumbBounds;
            if (thumb.IsEmpty)
            {
                frame.Render(hdc);
                return;
            }
            graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
            using var path = ConfigSearchSurface.RoundedRectangle(thumb, Math.Min(thumb.Width, thumb.Height) / 2f);
            using var brush = new SolidBrush(_hover || _dragging ? PrimaryTextColor :
                IsDarkPalette() ? HelpTextColor : Color.FromArgb(100, 117, 137));
            graphics.FillPath(brush, path);
            frame.Render(hdc);
        }

        private void RequestScroll(ScrollEventType type, int value)
        {
            var args = new ScrollEventArgs(type, ScrollBar.Value, Math.Clamp(value, ScrollBar.Minimum, MaximumValue),
                _vertical ? ScrollOrientation.VerticalScroll : ScrollOrientation.HorizontalScroll);
            // Reuse the existing Scroll handlers, including their adjusted row limits.
            RaiseScroll(ScrollBar, args);
            ScrollBar.Value = Math.Clamp(args.NewValue, ScrollBar.Minimum, MaximumValue);
            Refresh();
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
                case 0x00E9: // SBM_SETSCROLLINFO: native updates must not paint the old scrollbar.
                    var redraw = message.WParam != IntPtr.Zero;
                    message.WParam = IntPtr.Zero;
                    base.WndProc(ref message);
                    if (redraw) Refresh();
                    return;
                case 0x000F: // WM_PAINT
                    var hdc = BeginPaint(Handle, out var paint);
                    try { Draw(hdc); }
                    finally { EndPaint(Handle, ref paint); }
                    message.Result = IntPtr.Zero;
                    return;
                case 0x0317: // WM_PRINT
                case 0x0318: // WM_PRINTCLIENT (including DrawToBitmap)
                    Draw(message.WParam);
                    return;
                case 0x0014: // WM_ERASEBKGND
                    message.Result = new IntPtr(1);
                    return;
                case 0x0201: // WM_LBUTTONDOWN
                case 0x0203: // WM_LBUTTONDBLCLK (the second press can start another drag)
                    if (!ScrollBar.Enabled) return;
                    var point = new Point(unchecked((short)(long)message.LParam), unchecked((short)((long)message.LParam >> 16)));
                    var thumb = ThumbBounds;
                    var coordinate = _vertical ? point.Y : point.X;
                    var start = _vertical ? thumb.Top : thumb.Left;
                    var end = _vertical ? thumb.Bottom : thumb.Right;
                    if (coordinate >= start && coordinate < end && !thumb.IsEmpty)
                    {
                        _grabOffset = coordinate - start;
                        _dragging = true;
                        ScrollBar.Capture = true;
                        Refresh();
                    }
                    else
                    {
                        var before = coordinate < start;
                        RequestScroll(before ? ScrollEventType.LargeDecrement : ScrollEventType.LargeIncrement,
                            ScrollBar.Value + (before ? -ScrollBar.LargeChange : ScrollBar.LargeChange));
                    }
                    return;
                case 0x0200: // WM_MOUSEMOVE
                    if (!_hover)
                    {
                        _hover = true;
                        var tracking = new MouseTracking { Size = (uint)Marshal.SizeOf<MouseTracking>(), Flags = 2, Window = Handle };
                        TrackMouseEvent(ref tracking);
                    }
                    if (_dragging)
                    {
                        var mouse = _vertical ? unchecked((short)((long)message.LParam >> 16)) : unchecked((short)(long)message.LParam);
                        var bounds = ThumbBounds;
                        var travel = Length - (_vertical ? bounds.Height : bounds.Width);
                        if (travel > 0)
                            RequestScroll(ScrollEventType.ThumbTrack, ScrollBar.Minimum +
                                (int)Math.Round((double)Math.Clamp(mouse - _grabOffset, 0, travel) / travel * (MaximumValue - ScrollBar.Minimum)));
                    }
                    Refresh();
                    return;
                case 0x0202: // WM_LBUTTONUP
                    if (_dragging)
                    {
                        _dragging = false;
                        ScrollBar.Capture = false;
                        RequestScroll(ScrollEventType.EndScroll, ScrollBar.Value);
                    }
                    return;
                case 0x0215: // WM_CAPTURECHANGED
                    _dragging = false;
                    Refresh();
                    break;
                case 0x02A3: // WM_MOUSELEAVE
                    _hover = false;
                    Refresh();
                    break;
            }
            base.WndProc(ref message);
        }

        public void Dispose()
        {
            ScrollBar.HandleCreated -= Attach;
            ScrollBar.HandleDestroyed -= Detach;
            ScrollBar.ValueChanged -= Changed;
            ScrollBar.SizeChanged -= Changed;
            ScrollBar.FontChanged -= Changed;
            ScrollBar.EnabledChanged -= Changed;
            ScrollBar.VisibleChanged -= Changed;
            ReleaseHandle();
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct MouseTracking { public uint Size, Flags; public IntPtr Window; public uint HoverTime; }
        [DllImport("user32.dll")] private static extern bool TrackMouseEvent(ref MouseTracking tracking);
    }
}
