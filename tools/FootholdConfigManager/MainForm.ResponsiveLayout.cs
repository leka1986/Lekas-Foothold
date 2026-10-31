using System.Drawing;
using System.Windows.Forms;

namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private void ApplyInitialResponsiveZoom()
    {
        // Load runs after the restored target HWND has its monitor DPI, before startup view preparation.
        var workingArea = Screen.FromControl(this).WorkingArea;
        SetUiZoom(ResolveStartupZoomPercent(_settings.UiZoomPercent, workingArea, DeviceDpi), persist: false);
        ApplyCategoryNavigationWidth();
    }

    internal static int ResolveStartupZoomPercent(int preferredZoomPercent, Rectangle workingArea, int monitorDpi)
    {
        // PerMonitorV2 work-area coordinates are pixels; compare their available height at 96 DPI.
        var logicalHeight = workingArea.Height * 96d / monitorDpi;
        return logicalHeight <= 1080 ? 80 : Math.Clamp(preferredZoomPercent, 80, 130);
    }

    internal static int FindWorkingAreaIndexForBounds(Rectangle bounds, IReadOnlyList<Rectangle> workingAreas)
    {
        var selected = -1;
        long largestArea = 0;
        for (var index = 0; index < workingAreas.Count; index++)
        {
            var overlap = Rectangle.Intersect(bounds, workingAreas[index]);
            var area = (long)overlap.Width * overlap.Height;
            if (area <= largestArea) continue;
            largestArea = area;
            selected = index;
        }
        return selected;
    }

    private void ApplyCategoryNavigationWidth()
    {
        if (_mainSplit is null || _mainSplit.ClientSize.Width <
            _mainSplit.Panel1MinSize + _mainSplit.Panel2MinSize + _mainSplit.SplitterWidth) return;
        // Preserve the original sidebar sizing, with only a small increase on 1080p displays.
        var desiredWidth = Zoomed(Screen.FromControl(this).Bounds.Height == 1080 ? 280 : 260);
        var maxWidth = Math.Max(Zoomed(210), ClientSize.Width / 3);
        var width = Math.Min(desiredWidth, maxWidth);
        if (_mainSplit.SplitterDistance != width) _mainSplit.SplitterDistance = width;
    }
}