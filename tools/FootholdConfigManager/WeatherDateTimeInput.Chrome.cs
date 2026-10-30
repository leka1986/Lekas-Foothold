using System.Drawing.Imaging;
using System.Runtime.InteropServices;

namespace FootholdConfigManager;

internal sealed partial class WeatherDateTimeInput
{
    private Bitmap? _nativeSurface;
    private ImageAttributes? _nativePalette;
    private (Color Surface, Color Text, Color Selection) _paletteColors;
    private DateStepperWindow? _stepper;
    private IntPtr _nativeFont;

    private void DrawThemed(Graphics graphics)
    {
        if (DirectDateTextEntry) { DrawClosed(graphics); return; }
        if (!ContainsFocus) { DrawClosed(graphics); _stepper?.DrawInParent(graphics); return; }
        if (Width < 1 || Height < 1) return;
        if (_nativeSurface is null || _nativeSurface.Size != ClientSize)
        {
            _nativeSurface?.Dispose();
            _nativeSurface = new Bitmap(Width, Height, PixelFormat.Format32bppRgb);
        }
        using (var native = Graphics.FromImage(_nativeSurface))
        {
            native.Clear(SystemColors.Window);
            var dc = native.GetHdc();
            try
            {
                // Retain native field selection, keyboard editing and hit testing.
                // Render offscreen so the native white surface is never presented.
                var print = Message.Create(Handle, 0x0318, dc, new IntPtr(0x000C));
                base.WndProc(ref print);
            }
            finally { native.ReleaseHdc(dc); }
        }
        var selection = SurfaceColor.GetBrightness() < .5f ? Color.FromArgb(86,156,214) : Color.FromArgb(30,120,167);
        var colors = (SurfaceColor, ForeColor, selection);
        if (_nativePalette is null || _paletteColors != colors)
        {
            _nativePalette?.Dispose();
            _nativePalette = new ImageAttributes();
            // Neutral native antialiasing follows the themed text/surface gradient.
            // The selected segment retains its native geometry and a readable accent.
            var palette = new ColorMap[257];
            for (var level = 0; level < 256; level++)
                palette[level] = new ColorMap { OldColor = Color.FromArgb(level,level,level),
                    NewColor = Color.FromArgb(
                        ForeColor.R + (SurfaceColor.R - ForeColor.R) * level / 255,
                        ForeColor.G + (SurfaceColor.G - ForeColor.G) * level / 255,
                        ForeColor.B + (SurfaceColor.B - ForeColor.B) * level / 255) };
            palette[256] = new ColorMap { OldColor = SystemColors.Highlight, NewColor = selection };
            _nativePalette.SetRemapTable(palette);
            _paletteColors = colors;
        }
        graphics.DrawImage(_nativeSurface, ClientRectangle, 0, 0, Width, Height, GraphicsUnit.Pixel, _nativePalette);
        _stepper?.DrawInParent(graphics);
    }

    protected override void OnHandleCreated(EventArgs e)
    {
        base.OnHandleCreated(e);
        ApplyNativeFont();
        var info = new PickerInfo { Size = Marshal.SizeOf<PickerInfo>() };
        GetPickerInfo(Handle, 0x100E, IntPtr.Zero, ref info);
        if (info.Spin != IntPtr.Zero) _stepper = new DateStepperWindow(this, info.Spin);
        RefreshDateTextAppearance();
    }

    protected override void OnHandleDestroyed(EventArgs e)
    {
        _stepper?.ReleaseHandle();
        _stepper = null;
        ResetDateCalendarState();
        base.OnHandleDestroyed(e);
        if (_nativeFont != IntPtr.Zero) { DeleteObject(_nativeFont); _nativeFont = IntPtr.Zero; }
    }

    protected override void OnFontChanged(EventArgs e)
    {
        base.OnFontChanged(e);
        if (IsHandleCreated) ApplyNativeFont();
        RefreshDateTextAppearance();
    }

    private void ApplyNativeFont()
    {
        // Native ClearType assumes a white background. Grayscale antialiasing
        // keeps recolored glyph edges clean without changing global font settings.
        var font = new NativeFont();
        Font.ToLogFont(font);
        font.Quality = 4; // ANTIALIASED_QUALITY
        var replacement = CreateFontIndirect(font);
        if (replacement == IntPtr.Zero) throw new System.ComponentModel.Win32Exception();
        SendFont(Handle, 0x0030, replacement, IntPtr.Zero);
        if (_nativeFont != IntPtr.Zero) DeleteObject(_nativeFont);
        _nativeFont = replacement;
    }
    protected override void OnEnabledChanged(EventArgs e)
    {
        base.OnEnabledChanged(e);
        _stepper?.Invalidate();
        RefreshDateTextAppearance();
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing)
        {
            _nativeSurface?.Dispose();
            _nativeSurface = null;
            _nativePalette?.Dispose();
            _nativePalette = null;
        }
        base.Dispose(disposing);
    }

    private sealed class DateStepperWindow : NativeWindow
    {
        private readonly WeatherDateTimeInput _owner;
        private bool _hover, _pressed;
        private int _pointerY;
        internal DateStepperWindow(WeatherDateTimeInput owner, IntPtr handle) { _owner = owner; AssignHandle(handle); }
        internal void Invalidate() { if (Handle != IntPtr.Zero) InvalidateRect(Handle, IntPtr.Zero, false); }
        protected override void WndProc(ref Message m)
        {
            if (m.Msg == 0x0200)
            {
                _pointerY = (short)(m.LParam.ToInt64() >> 16);
                if (!_hover)
                {
                    var track = new MouseTracking { Size = Marshal.SizeOf<MouseTracking>(), Flags = 2, Window = Handle };
                    TrackMouseEvent(ref track);
                }
                _hover = true; Invalidate();
            }
            else if (m.Msg == 0x02A3) { _hover = _pressed = false; Invalidate(); }
            else if (m.Msg == 0x0201) { _pressed = true; Invalidate(); }
            else if (m.Msg is 0x0202 or 0x0215) { _pressed = false; Invalidate(); }
            if (m.Msg == 0x0014) { m.Result = new IntPtr(1); return; }
            if (m.Msg == 0x000F)
            {
                var dc = MainForm.InputChrome.BeginPaint(Handle, out var paint);
                try
                {
                    if (dc != IntPtr.Zero) { using var graphics = Graphics.FromHdc(dc); Draw(graphics); }
                }
                finally { MainForm.InputChrome.EndPaint(Handle, ref paint); }
                m.Result = IntPtr.Zero; return;
            }
            if (m.Msg is 0x0317 or 0x0318 && m.WParam != IntPtr.Zero)
            {
                using var graphics = Graphics.FromHdc(m.WParam); Draw(graphics);
                m.Result = IntPtr.Zero; return;
            }
            base.WndProc(ref m);
        }
        internal void DrawInParent(Graphics graphics)
        {
            if (Handle == IntPtr.Zero) return;
            GetWindowRect(Handle, out var rect);
            var origin = _owner.PointToClient(new Point(rect.Left, rect.Top));
            var state = graphics.Save();
            try
            {
                graphics.TranslateTransform(origin.X, origin.Y);
                MainForm.InputChrome.DrawStepper(graphics, new Rectangle(0,0,rect.Right-rect.Left,rect.Bottom-rect.Top),
                    _owner.SurfaceColor, _owner.Enabled, _hover, _pressed, _pointerY, _owner.DeviceDpi / 96f);
            }
            finally { graphics.Restore(state); }
        }

        private void Draw(Graphics graphics)
        {
            GetClientRect(Handle, out var rect);
            var bounds = new Rectangle(0,0,rect.Right,rect.Bottom);
            if (bounds.Width < 1 || bounds.Height < 1) return;
            using var buffer = BufferedGraphicsManager.Current.Allocate(graphics, bounds);
            MainForm.InputChrome.DrawStepper(buffer.Graphics, bounds, _owner.SurfaceColor, _owner.Enabled,
                _hover, _pressed, _pointerY, _owner.DeviceDpi / 96f);
            buffer.Render(graphics);
        }
    }

    [StructLayout(LayoutKind.Sequential)] private struct NativeRect { public int Left,Top,Right,Bottom; }
    [StructLayout(LayoutKind.Sequential)] private struct PickerInfo
    {
        public int Size; public NativeRect Check; public int CheckState; public NativeRect Button; public int ButtonState;
        public IntPtr Edit, Spin, Calendar;
    }
    [StructLayout(LayoutKind.Sequential)] private struct MouseTracking { public int Size,Flags; public IntPtr Window; public int HoverTime; }
    [DllImport("user32.dll", EntryPoint="SendMessageW")] private static extern IntPtr GetPickerInfo(IntPtr handle,uint message,IntPtr wParam,ref PickerInfo info);
    [DllImport("user32.dll")] private static extern bool GetClientRect(IntPtr handle,out NativeRect rect);
    [DllImport("user32.dll")] private static extern bool InvalidateRect(IntPtr handle,IntPtr rect,bool erase);
    [DllImport("user32.dll")] private static extern bool TrackMouseEvent(ref MouseTracking tracking);
    [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)] private sealed class NativeFont
    {
        public int Height,Width,Escapement,Orientation,Weight;
        public byte Italic,Underline,StrikeOut,CharacterSet,OutPrecision,ClipPrecision,Quality,PitchAndFamily;
        [MarshalAs(UnmanagedType.ByValTStr,SizeConst=32)] public string FaceName = "";
    }
    [DllImport("gdi32.dll", CharSet=CharSet.Unicode)] private static extern IntPtr CreateFontIndirect([In] NativeFont font);
    [DllImport("gdi32.dll")] private static extern bool DeleteObject(IntPtr handle);
    [DllImport("user32.dll", EntryPoint="SendMessageW")] private static extern IntPtr SendFont(IntPtr handle,uint message,IntPtr wParam,IntPtr lParam);
    [DllImport("user32.dll")] private static extern bool GetWindowRect(IntPtr handle,out NativeRect rect);
}
