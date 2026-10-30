using System.Runtime.InteropServices;

namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    // Native list selection and wheel/keyboard scrolling stay with the combo.
    // Its non-client bar uses the same geometry and paint as the manager's bars.
    internal sealed class PopupScrollbarWindow : NativeWindow, IDisposable
    {
        private readonly ComboBox _owner;
        private bool _hover, _dragging;
        private bool _instantOpening;
        private int _grabOffset;
        private IntPtr _previousCapture;

        internal PopupScrollbarWindow(ComboBox owner) => _owner = owner;
        internal void Attach()
        {
            var info = new ComboInfo { Size = Marshal.SizeOf<ComboInfo>() };
            if (!GetComboBoxInfo(_owner.Handle, ref info) || info.List == IntPtr.Zero) return;
            if (Handle != info.List) { ReleaseHandle(); AssignHandle(info.List); }
        }

        internal void PrepareInstantOpening() => _instantOpening = true;
        internal void CancelInstantOpening() => _instantOpening = false;

        private bool Geometry(out Rectangle bar, out Rectangle thumb, out ScrollInfo scroll)
        {
            bar = thumb = Rectangle.Empty;
            scroll = new ScrollInfo { Size = (uint)Marshal.SizeOf<ScrollInfo>(), Mask = 7 };
            var info = new BarInfo { Size = (uint)Marshal.SizeOf<BarInfo>() };
            if (!GetWindowRect(Handle, out var window) || !GetScrollBarInfo(Handle, -5, ref info) ||
                !GetScrollInfo(Handle, 1, ref scroll) || info.Bounds.Right <= info.Bounds.Left) return false;
            bar = new Rectangle(info.Bounds.Left - window.Left, info.Bounds.Top - window.Top,
                info.Bounds.Right - info.Bounds.Left, info.Bounds.Bottom - info.Bounds.Top);
            thumb = SlimScrollbarWindow.CalculateThumbBounds(true, bar.Size, scroll.Min, scroll.Max,
                (int)scroll.Page, scroll.Position, _owner.Font.SizeInPoints / BaseFontSize * _owner.DeviceDpi / 96f, true);
            if (!thumb.IsEmpty) thumb.Offset(bar.Location);
            return !thumb.IsEmpty;
        }

        private void Draw(IntPtr providedDc = default)
        {
            if (!Geometry(out var bar, out var thumb, out _)) return;
            var dc = providedDc != IntPtr.Zero ? providedDc : GetWindowDC(Handle);
            if (dc == IntPtr.Zero) return;
            try
            {
                using var graphics = Graphics.FromHdc(dc);
                using var buffer = BufferedGraphicsManager.Current.Allocate(graphics, bar);
                SlimScrollbarWindow.DrawPresentation(buffer.Graphics, bar, thumb, _hover || _dragging);
                buffer.Render(graphics);
                if (GetWindowRect(Handle, out var window))
                {
                    using var border = new Pen(ControlBorderColor);
                    graphics.DrawRectangle(border, 0, 0, window.Right - window.Left - 1, window.Bottom - window.Top - 1);
                }
            }
            finally { if (providedDc == IntPtr.Zero) ReleaseDC(Handle, dc); }
        }

        private Point Pointer(IntPtr packed, bool client)
        {
            var point = new NativePoint { X = unchecked((short)(long)packed), Y = unchecked((short)((long)packed >> 16)) };
            if (client) ClientToScreen(Handle, ref point);
            GetWindowRect(Handle, out var window);
            return new Point(point.X - window.Left, point.Y - window.Top);
        }

        private void ScrollTo(int value, ScrollInfo info)
        {
            var maximum = Math.Max(info.Min, info.Max - (int)info.Page + 1);
            SendMessage(Handle, 0x0197, new IntPtr(Math.Clamp(value, info.Min, maximum)), IntPtr.Zero); // LB_SETTOPINDEX
            Draw();
        }

        internal void EndDrag()
        {
            if (!_dragging) return;
            _dragging = false;
            if (GetCapture() == Handle && _previousCapture != Handle)
            {
                if (_owner.DroppedDown && _previousCapture != IntPtr.Zero) SetCapture(_previousCapture);
                else ReleaseCapture();
            }
        }

        protected override void WndProc(ref Message message)
        {
            if (message.Msg == 0x0047 && _instantOpening) // WM_WINDOWPOSCHANGED: retain native final placement.
            {
                base.WndProc(ref message);
                _instantOpening = false;
                if (!IsWindowVisible(Handle)) ShowWindow(Handle, 4); // Skip the slide by showing without activation.
                return;
            }
            if (SystemInformation.HighContrast) { base.WndProc(ref message); return; }
            switch (message.Msg)
            {
                case 0x0085: // WM_NCPAINT: never flash the native white track first.
                    if (Geometry(out _, out _, out _)) { Draw(); message.Result = IntPtr.Zero; return; }
                    break;
                case 0x00A1: // WM_NCLBUTTONDOWN
                case 0x00A3: // WM_NCLBUTTONDBLCLK
                case 0x0201: // Captured popup input arrives as client mouse messages.
                case 0x0203:
                    if (Geometry(out var bar, out var thumb, out var info))
                    {
                        var point = Pointer(message.LParam, message.Msg is 0x0201 or 0x0203);
                        if (!bar.Contains(point)) break;
                        var y = point.Y;
                        if (y >= thumb.Top && y < thumb.Bottom)
                        {
                            _grabOffset = y - thumb.Top; _dragging = true;
                            _previousCapture = GetCapture();
                            if (_previousCapture != Handle) SetCapture(Handle);
                        }
                        else ScrollTo(info.Position + (y < thumb.Top ? -(int)info.Page : (int)info.Page), info);
                        Draw(); message.Result = IntPtr.Zero; return;
                    }
                    break;
                case 0x00A0: // WM_NCMOUSEMOVE
                    if ((int)message.WParam == 7)
                    {
                        if (!_hover)
                        {
                            var tracking = new Tracking { Size = (uint)Marshal.SizeOf<Tracking>(), Flags = 2 | 16, Window = Handle };
                            TrackMouseEvent(ref tracking);
                        }
                        _hover = true; Draw(); message.Result = IntPtr.Zero; return;
                    }
                    break;
                case 0x02A2: // WM_NCMOUSELEAVE
                    _hover = false; Draw(); message.Result = IntPtr.Zero; return;
                case 0x0200: // WM_MOUSEMOVE while captured
                    if (_dragging && Geometry(out var track, out var draggingThumb, out var range))
                    {
                        var travel = track.Height - draggingThumb.Height;
                        if (travel > 0) ScrollTo(range.Min + (int)Math.Round((double)Math.Clamp(
                            Pointer(message.LParam, true).Y - track.Top - _grabOffset, 0, travel) / travel *
                            (Math.Max(range.Min, range.Max - (int)range.Page + 1) - range.Min)), range);
                        message.Result = IntPtr.Zero; return;
                    }
                    if (Geometry(out var hoverBar, out _, out _) && hoverBar.Contains(Pointer(message.LParam, true)))
                    {
                        _hover = true; Draw(); message.Result = IntPtr.Zero; return;
                    }
                    if (_hover) { _hover = false; Draw(); }
                    break;
                case 0x0202: // WM_LBUTTONUP
                    if (_dragging) { EndDrag(); Draw(); message.Result = IntPtr.Zero; return; }
                    break;
                case 0x0215: _dragging = false; break; // WM_CAPTURECHANGED
            }
            base.WndProc(ref message);
            if (message.Msg is 0x000F or 0x0115 or 0x020A or 0x0100 or 0x0005) Draw();
            if (message.Msg == 0x0317 && message.WParam != IntPtr.Zero && ((long)message.LParam & 2) != 0) Draw(message.WParam);
        }

        public void Dispose() { CancelInstantOpening(); EndDrag(); ReleaseHandle(); }
        [StructLayout(LayoutKind.Sequential)] private struct NativeRect { public int Left, Top, Right, Bottom; }
        [StructLayout(LayoutKind.Sequential)] private struct NativePoint { public int X, Y; }
        [StructLayout(LayoutKind.Sequential)] private struct ComboInfo { public int Size; public NativeRect Item, Button; public int State; public IntPtr Combo, Edit, List; }
        [StructLayout(LayoutKind.Sequential)] private struct ScrollInfo { public uint Size, Mask; public int Min, Max; public uint Page; public int Position, TrackPosition; }
        [StructLayout(LayoutKind.Sequential)] private struct BarInfo { public uint Size; public NativeRect Bounds; public int ButtonSize, ThumbTop, ThumbBottom, Reserved; [MarshalAs(UnmanagedType.ByValArray, SizeConst = 6)] public uint[] State; }
        [StructLayout(LayoutKind.Sequential)] private struct Tracking { public uint Size, Flags; public IntPtr Window; public uint Time; }
        [DllImport("user32.dll")] private static extern bool GetComboBoxInfo(IntPtr window, ref ComboInfo info);
        [DllImport("user32.dll")] private static extern bool IsWindowVisible(IntPtr window);
        [DllImport("user32.dll")] private static extern bool ShowWindow(IntPtr window, int command);
        [DllImport("user32.dll")] private static extern bool GetWindowRect(IntPtr window, out NativeRect rect);
        [DllImport("user32.dll")] private static extern bool GetScrollBarInfo(IntPtr window, int objectId, ref BarInfo info);
        [DllImport("user32.dll")] private static extern bool GetScrollInfo(IntPtr window, int bar, ref ScrollInfo info);
        [DllImport("user32.dll")] private static extern IntPtr GetWindowDC(IntPtr window);
        [DllImport("user32.dll")] private static extern int ReleaseDC(IntPtr window, IntPtr dc);
        [DllImport("user32.dll")] private static extern bool ClientToScreen(IntPtr window, ref NativePoint point);
        [DllImport("user32.dll")] private static extern IntPtr GetCapture();
        [DllImport("user32.dll")] private static extern IntPtr SetCapture(IntPtr window);
        [DllImport("user32.dll")] private static extern bool ReleaseCapture();
        [DllImport("user32.dll")] private static extern bool TrackMouseEvent(ref Tracking tracking);
        [DllImport("user32.dll", EntryPoint = "SendMessageW")] private static extern IntPtr SendMessage(IntPtr window, uint message, IntPtr wParam, IntPtr lParam);
    }
}
