using System.Drawing;
using System.Windows.Forms;

namespace FootholdConfigManager;

internal sealed class WheelSafeComboBox : ComboBox
{
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
