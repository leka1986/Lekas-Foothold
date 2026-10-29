using System.Drawing;
using System.Windows.Forms;

namespace FootholdConfigManager;

internal sealed class WheelSafeComboBox : ComboBox
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

internal sealed class WheelSafeNumericUpDown : NumericUpDown
{
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
