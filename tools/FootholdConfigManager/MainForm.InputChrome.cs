using System.Drawing.Drawing2D;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    // Paint the closed native face once, into a buffer. The original HWND still
    // owns keyboard input, selection, popup lifetime and numeric auto-repeat.
    internal sealed class InputChrome : NativeWindow
    {
        private static readonly ConditionalWeakTable<Control, InputChrome> Owners = new();
        private static readonly ConditionalWeakTable<DataGridView, StrongBox<Point>> GridHover = new();
        internal static Color HoverSurface => HeaderBackground;
        internal static Color PressedSurface => SelectionBackground;
        private readonly Control _target;
        private readonly Control _input;
        private readonly bool _weatherSlider;
        private bool _hover;
        private bool _pressed;
        [ThreadStatic] private static ChoiceInputMode? _choiceInputMode;
        private int _pointerY;
        private PopupScrollbarWindow? _popupScrollbar;

        private InputChrome(Control target, Control input)
        {
            _target = target; _input = input;
            _weatherSlider = input is TrackBar { Name: "WeatherCloudBaseSlider" or "MissionBirdsSlider" };
            target.HandleCreated += (_, _) => AssignHandle(target.Handle);
            target.HandleDestroyed += (_, _) => { _popupScrollbar?.Dispose(); ReleaseHandle(); };
            if (input is not NumericUpDown)
            {
                target.MouseEnter += (_, _) => { _hover = true; target.Invalidate(); };
                target.MouseLeave += (_, _) => { _hover = _pressed = false; target.Invalidate(); };
                target.MouseMove += (_, e) =>
                {
                    if (input is NumericUpDown && (_pointerY < target.Height / 2) != (e.Y < target.Height / 2)) target.Invalidate();
                    if (input is ComboBox && UpdateChoiceHover(e.Location)) target.Invalidate();
                    _pointerY = e.Y;
                };
                target.MouseDown += (_, e) => { _pressed = e.Button == MouseButtons.Left; target.Invalidate(); };
                target.MouseUp += (_, _) => { _pressed = false; target.Invalidate(); };
                target.MouseCaptureChanged += (_, _) => { if (!target.Capture) { _pressed = false; target.Invalidate(); } };
            }
            input.GotFocus += (_, _) => target.Invalidate();
            input.LostFocus += (_, _) => target.Invalidate();
            input.EnabledChanged += (_, _) => target.Invalidate();
            if (input is ComboBox combo)
            {
                var mode = _choiceInputMode ??= new ChoiceInputMode();
                if (combo.Focused) mode.FocusedChoice = combo;
                combo.GotFocus += (_, _) => mode.FocusedChoice = combo;
                combo.LostFocus += (_, _) => { if (ReferenceEquals(mode.FocusedChoice, combo)) mode.FocusedChoice = null; };
                combo.SelectedIndexChanged += (_, _) => target.Invalidate();
                combo.TextChanged += (_, _) => target.Invalidate();
                combo.DropDown += (_, _) =>
                {
                    (_popupScrollbar ??= new PopupScrollbarWindow(combo)).Attach();
                    target.Invalidate();
                };
                combo.DropDownClosed += (_, _) => { _popupScrollbar?.CancelInstantOpening(); _popupScrollbar?.EndDrag(); _pressed = false; UpdateChoiceHover(target.PointToClient(Control.MousePosition), rearm: true); target.Invalidate(); };
                combo.Disposed += (_, _) => { _popupScrollbar?.Dispose(); if (ReferenceEquals(mode.FocusedChoice, combo)) mode.FocusedChoice = null; };
            }
            if (target.IsHandleCreated) AssignHandle(target.Handle);
        }

        internal static void Apply(Control input)
        {
            if (input is ComboBox { DropDownStyle: ComboBoxStyle.DropDownList } || input is TrackBar { Orientation: Orientation.Horizontal })
                Owners.GetValue(input, key => new InputChrome(key, key));
            else if (input is NumericUpDown number)
            {
                foreach (Control child in number.Controls)
                    if (child is not TextBox) Owners.GetValue(child, key => new InputChrome(key, number));
            }
        }

        protected override void WndProc(ref Message message)
        {
            if (_input is ComboBox combo && message.Msg is 0x0201 or 0x0203 or 0x0100 or 0x0104)
                SetChoiceMouseFocus(combo, message.Msg is 0x0201 or 0x0203);
            if (_input is ComboBox && message.Msg == 0x02A3) // WM_MOUSELEAVE can arrive without a managed MouseLeave.
            {
                _hover = _pressed = false;
                _target.Invalidate();
                if (_target.Parent?.Parent is WeatherInputFrame frame) frame.ClearHover();
            }
            // UpDownButtons forwards managed mouse events to its parent. Observe
            // its native messages so every numeric stepper owns its actual hot half.
            if (_input is NumericUpDown)
            {
                if (message.Msg == 0x0200)
                {
                    var x = (short)message.LParam.ToInt64();
                    var y = (short)(message.LParam.ToInt64() >> 16);
                    var inside = _target.ClientRectangle.Contains(x, y);
                    var changed = _hover != inside || inside && (_pointerY < _target.Height / 2) != (y < _target.Height / 2);
                    _hover = inside; _pointerY = y;
                    if (changed) _target.Invalidate();
                }
                else if (message.Msg == 0x02A3) { _hover = _pressed = false; _target.Invalidate(); }
                else if (message.Msg == 0x0201) { _pressed = true; _target.Invalidate(); }
                else if (message.Msg is 0x0202 or 0x0215) { _pressed = false; _target.Invalidate(); }
            }
            if (message.Msg == 0x0014) { message.Result = new IntPtr(1); return; } // WM_ERASEBKGND
            if (message.Msg == 0x000F)
            {
                // This painter owns the whole rail, not the native thumb-only dirty region.
                if (_weatherSlider) _target.Invalidate();
                var dc = BeginPaint(Handle, out var paint);
                try
                {
                    if (dc != IntPtr.Zero)
                    {
                        using var graphics = Graphics.FromHdc(dc);
                        using var buffer = BufferedGraphicsManager.Current.Allocate(graphics, _target.ClientRectangle);
                        Draw(buffer.Graphics); buffer.Render(graphics);
                    }
                }
                finally { EndPaint(Handle, ref paint); }
                message.Result = IntPtr.Zero; return;
            }
            if (message.Msg is 0x0317 or 0x0318 && message.WParam != IntPtr.Zero)
            {
                using var graphics = Graphics.FromHdc(message.WParam); Draw(graphics);
                message.Result = IntPtr.Zero; return;
            }
            if (_weatherSlider && message.Msg == 0x0201)
            {
                GetTrackRectangle(_input.Handle, 0x0419, IntPtr.Zero, out var thumb);
                var point = new Point((short)message.LParam.ToInt64(), (short)(message.LParam.ToInt64() >> 16));
                var dx = point.X - (thumb.Left + thumb.Right) / 2f;
                var dy = point.Y - (thumb.Top + thumb.Bottom) / 2f;
                var radius = SliderThumbRadius;
                if (dx * dx + dy * dy <= radius * radius && !Rectangle.FromLTRB(thumb.Left, thumb.Top, thumb.Right, thumb.Bottom).Contains(point))
                {
                    // The painted circle extends beyond the native thumb: retain native tracking at its nearest edge.
                    var x = Math.Clamp(point.X, thumb.Left, thumb.Right - 1);
                    var y = Math.Clamp(point.Y, thumb.Top, thumb.Bottom - 1);
                    message.LParam = new IntPtr((y << 16) | (x & 0xffff));
                }
            }
            base.WndProc(ref message);
            if (_input is ComboBox && message.Msg == 0x2111 && ((long)message.WParam >> 16 & 0xffff) == 7)
                _popupScrollbar?.PrepareInstantOpening(); // Reflected CBN_DROPDOWN, after native height preparation.
            // Native tracking can draw incrementally outside WM_PAINT. Replace that
            // transient paint with one complete themed frame after the native update.
            if (_weatherSlider && message.Msg is 0x0200 or 0x0201 or 0x0202 or 0x0113) _target.Invalidate();
        }

        private void Draw(Graphics graphics)
        {
            var bounds = _target.ClientRectangle;
            if (bounds.Width < 2 || bounds.Height < 2) return;
            if (_input is ComboBox combo)
            {
                var framed = combo.Parent?.Parent is WeatherInputFrame;
                DrawChoice(graphics, bounds, combo.Text, combo.Font, combo.BackColor, combo.ForeColor,
                    combo.Enabled, _hover, ShowChoiceFocus(combo), !framed, combo.DeviceDpi / 96f);
            }
            else if (_input is TrackBar slider) DrawSlider(graphics,slider);
            else
            {
                DrawStepper(graphics, bounds, _input.BackColor, _input.Enabled, _hover, _pressed, _pointerY, _input.DeviceDpi / 96f);
            }
        }

        private bool UpdateChoiceHover(Point point, bool rearm = false)
        {
            var hover = _target.ClientRectangle.Contains(point);
            var changed = _hover != hover;
            _hover = hover;
            if (hover && (changed || rearm)) PopupScrollbarWindow.TrackClientLeave(_target.Handle);
            return changed;
        }

        internal static void SetChoiceMouseFocus(ComboBox combo, bool mouseFocus)
        {
            if (_choiceInputMode is not { } mode || !Owners.TryGetValue(combo, out var owner) || mode.MouseInput == mouseFocus) return;
            mode.MouseInput = mouseFocus;
            owner._target.Invalidate();
            if (owner._target.Parent?.Parent is WeatherInputFrame frame) frame.Invalidate();
        }

        // Keep keyboard/open-popup cues separate from ordinary mouse focus.
        internal static bool ShowChoiceFocus(ComboBox combo) => combo.DroppedDown || combo.Focused
            && _choiceInputMode is { MouseInput: false };

        private sealed class ChoiceInputMode : IMessageFilter
        {
            internal bool MouseInput = true;
            internal ComboBox? FocusedChoice;
            internal ChoiceInputMode() => Application.AddMessageFilter(this);

            public bool PreFilterMessage(ref Message message)
            {
                bool mouse;
                if (message.Msg is 0x0100 or 0x0104) mouse = false;
                else if (message.Msg is >= 0x0200 and <= 0x020E or >= 0x00A0 and <= 0x00AD) mouse = true;
                else return false;
                if (FocusedChoice is { IsDisposed: false } combo) SetChoiceMouseFocus(combo, mouse);
                else MouseInput = mouse;
                return false;
            }
        }

        internal static void DrawStepper(Graphics graphics, Rectangle bounds, Color surface, bool enabled,
            bool hover, bool pressed, int pointerY, float scale)
        {
            using (var background = new SolidBrush(surface)) graphics.FillRectangle(background, bounds);
            using (var group = ConfigSearchSurface.RoundedRectangle(RectangleF.Inflate(bounds, -1, -1), 3 * scale))
            using (var background = new SolidBrush(enabled ? ButtonBackground : surface)) graphics.FillPath(background, group);
            using (var separator = new Pen(ControlBorderColor))
                graphics.DrawLine(separator, 4 * scale, bounds.Height / 2f, bounds.Width - 4 * scale, bounds.Height / 2f);
            for (var half = 0; half < 2; half++)
            {
                var cell = new Rectangle(0, half * bounds.Height / 2, bounds.Width, bounds.Height / 2);
                var hot = hover && (pointerY < bounds.Height / 2 ? 0 : 1) == half && enabled;
                if (hot)
                {
                    using var shape = ConfigSearchSurface.RoundedRectangle(RectangleF.Inflate(cell, -1, -1), 3 * scale);
                    using var fill = new SolidBrush(pressed ? SelectionBackground : HeaderBackground);
                    graphics.FillPath(fill, shape);
                }
                Chevron(graphics, cell, enabled ? PrimaryTextColor : HelpTextColor, half == 0, scale * 1.3f);
            }
        }
        private float SliderThumbRadius => (_hover || _pressed ? 8 : 7) * _input.DeviceDpi / 96f;

        private void DrawSlider(Graphics graphics, TrackBar slider)
        {
            graphics.Clear(slider.BackColor);
            GetTrackRectangle(slider.Handle,0x0419,IntPtr.Zero,out var thumb); // TBM_GETTHUMBRECT
            GetTrackRectangle(slider.Handle,0x041A,IntPtr.Zero,out var channel); // TBM_GETCHANNELRECT
            var scale=slider.DeviceDpi/96f;
            var x=(thumb.Left+thumb.Right)/2f;var y=(thumb.Top+thumb.Bottom)/2f;
            graphics.SmoothingMode=SmoothingMode.AntiAlias;
            using var rail=new Pen(ControlBorderColor,4*scale){StartCap=LineCap.Round,EndCap=LineCap.Round};
            using var progress=new Pen(slider.Enabled?BrandColor:HelpTextColor,4*scale){StartCap=LineCap.Round,EndCap=LineCap.Round};
            graphics.DrawLine(rail,channel.Left,y,channel.Right,y);
            if(x>channel.Left) graphics.DrawLine(progress,channel.Left,y,Math.Min(x,channel.Right),y);
            var radius=SliderThumbRadius;
            using var fill=new SolidBrush(slider.Enabled?BrandColor:HelpTextColor);
            graphics.FillEllipse(fill,x-radius,y-radius,radius*2,radius*2);
            if (slider.Focused && _weatherSlider && !slider.Capture)
            {
                using var focus = new Pen(BrandColor, scale);
                graphics.DrawEllipse(focus, x-radius-3*scale, y-radius-3*scale, 2*radius+6*scale, 2*radius+6*scale);
            }
            else if (slider.Focused && !_weatherSlider)
                ControlPaint.DrawFocusRectangle(graphics,Rectangle.Inflate(slider.ClientRectangle,-2,-2),BrandColor,slider.BackColor);
        }

        internal static void DrawNumberFrame(Graphics graphics, Rectangle bounds, Color surface, bool active, float scale) =>
            DrawFrame(graphics, bounds, surface, active ? BrandColor : ControlBorderColor, scale);

        internal static void DrawFrame(Graphics graphics, Rectangle bounds, Color surface, Color line, float scale)
        {
            graphics.SmoothingMode = SmoothingMode.AntiAlias;
            using var shape = ConfigSearchSurface.RoundedRectangle(new RectangleF(bounds.X + .5f, bounds.Y + .5f,
                Math.Max(1,bounds.Width - 1), Math.Max(1,bounds.Height - 1)), 4 * scale);
            using var fill = new SolidBrush(surface); using var pen = new Pen(line);
            graphics.FillPath(fill,shape); graphics.DrawPath(pen,shape);
        }

        private static void DrawChoice(Graphics graphics, Rectangle bounds, string text, Font font, Color surface, Color foreground,
            bool enabled, bool hover, bool focused, bool border, float scale)
        {
            using (var background = new SolidBrush(surface)) graphics.FillRectangle(background,bounds);
            var line = focused && enabled ? BrandColor : hover && enabled ? HelpTextColor : ControlBorderColor;
            if (border) DrawFrame(graphics,bounds,surface,line,scale);
            var arrowWidth = Math.Min(Math.Max(20,(int)(26 * scale)),Math.Max(14,bounds.Width / 4));
            var arrow = new Rectangle(bounds.Right-arrowWidth,bounds.Top,arrowWidth,bounds.Height);
            if (enabled && (hover || focused))
            {
                using var shape = ConfigSearchSurface.RoundedRectangle(RectangleF.Inflate(arrow,-2,-3),3*scale);
                using var fill = new SolidBrush(focused ? SelectionBackground : HeaderBackground);graphics.FillPath(fill,shape);
            }
            var inset = Math.Max(4,(int)(7*scale));
            TextRenderer.DrawText(graphics,text,font,new Rectangle(bounds.Left+inset,bounds.Top,
                Math.Max(1,bounds.Width-arrowWidth-inset),bounds.Height),enabled?foreground:HelpTextColor,
                TextFormatFlags.Left|TextFormatFlags.VerticalCenter|TextFormatFlags.EndEllipsis|TextFormatFlags.NoPrefix|TextFormatFlags.NoPadding|TextFormatFlags.PreserveGraphicsClipping);
            Chevron(graphics,arrow,enabled?foreground:HelpTextColor,false,scale);
        }

        private static void Chevron(Graphics graphics, Rectangle bounds, Color color, bool up, float scale)
        {
            graphics.SmoothingMode=SmoothingMode.AntiAlias;
            var x=bounds.Left+bounds.Width/2f;var y=bounds.Top+bounds.Height/2f;
            var half=Math.Min(3.5f*scale,Math.Min(bounds.Width,bounds.Height)/3f);
            using var pen=new Pen(color,Math.Max(1.2f,1.35f*scale)){StartCap=LineCap.Round,EndCap=LineCap.Round,LineJoin=LineJoin.Round};
            var sign=up?-1:1;
            graphics.DrawLines(pen,new[]{new PointF(x-half,y-sign*half/2),new PointF(x,y+sign*half/2),new PointF(x+half,y-sign*half/2)});
        }

        internal static void EnterGridChoice(object? sender, DataGridViewCellEventArgs e)
        {
            if (sender is not DataGridView grid || e.RowIndex < 0 || e.ColumnIndex < 0 ||
                grid[e.ColumnIndex,e.RowIndex] is not DataGridViewComboBoxCell) return;
            GridHover.GetValue(grid,_ => new StrongBox<Point>(new Point(-1,-1))).Value = new Point(e.ColumnIndex,e.RowIndex);
            grid.InvalidateCell(e.ColumnIndex,e.RowIndex);
        }

        internal static void LeaveGridChoice(object? sender, DataGridViewCellEventArgs e)
        {
            if (sender is not DataGridView grid || !GridHover.TryGetValue(grid,out var hover) ||
                hover.Value != new Point(e.ColumnIndex,e.RowIndex)) return;
            hover.Value = new Point(-1,-1);
            grid.InvalidateCell(e.ColumnIndex,e.RowIndex);
        }

        internal static void PaintGridChoice(object? sender, DataGridViewCellPaintingEventArgs e)
        {
            if (sender is not DataGridView grid || e.RowIndex < 0 || e.ColumnIndex < 0 ||
                grid[e.ColumnIndex,e.RowIndex] is not DataGridViewComboBoxCell) return;
            if (grid.IsCurrentCellInEditMode && grid.CurrentCellAddress == new Point(e.ColumnIndex,e.RowIndex)) return;
            var state = e.Graphics!.Save();
            try
            {
            e.Graphics.SetClip(e.ClipBounds,CombineMode.Intersect);
            e.Paint(e.ClipBounds,DataGridViewPaintParts.Background|DataGridViewPaintParts.Border);
            var selected=(e.State&DataGridViewElementStates.Selected)!=0;
            var bounds=Rectangle.Inflate(e.CellBounds,-2,-2);
            var surface=selected?e.CellStyle!.SelectionBackColor:e.CellStyle!.BackColor;
            var foreground=selected?e.CellStyle.SelectionForeColor:e.CellStyle.ForeColor;
            var cell = new Point(e.ColumnIndex,e.RowIndex);
            var hot = GridHover.TryGetValue(grid,out var hover) && hover.Value == cell;
            var focused = grid.CurrentCellAddress == cell && grid.ContainsFocus;
            DrawChoice(e.Graphics,bounds,e.FormattedValue?.ToString()??"",e.CellStyle.Font??grid.Font,surface,foreground,
                grid.Enabled,hot,focused,true,grid.DeviceDpi/96f);
            e.Paint(e.ClipBounds,e.PaintParts & (DataGridViewPaintParts.Focus | DataGridViewPaintParts.ErrorIcon));
            e.Handled=true;
            }
            finally { e.Graphics.Restore(state); }
        }

        [StructLayout(LayoutKind.Sequential)] private struct NativeRect { internal int Left,Top,Right,Bottom; }
        [DllImport("user32.dll",EntryPoint="SendMessageW")] private static extern IntPtr GetTrackRectangle(IntPtr window,uint message,IntPtr wParam,out NativeRect bounds);
        [StructLayout(LayoutKind.Sequential)] internal struct PaintData
        {
            internal IntPtr Dc; internal int Erase;
            internal int Left,Top,Right,Bottom; internal int Restore,IncUpdate;
            [MarshalAs(UnmanagedType.ByValArray,SizeConst=32)] internal byte[] Reserved;
        }
        [DllImport("user32.dll")] internal static extern IntPtr BeginPaint(IntPtr window,out PaintData paint);
        [DllImport("user32.dll")] internal static extern bool EndPaint(IntPtr window,ref PaintData paint);
    }
}
