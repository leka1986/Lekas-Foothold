using System.Drawing;
using System.Windows.Forms;

namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private void ApplyInitialResponsiveZoom()
    {
        // Load runs after the restored target HWND has its monitor DPI, before startup view preparation.
        var workingArea = Screen.FromControl(this).WorkingArea;
        SetUiZoom(ResolveStartupZoomPercent(_settings.UiZoomUserSelected == true ? _settings.UiZoomPercent : 0, workingArea, DeviceDpi), persist: false);
        ApplyCategoryNavigationWidth();
    }

    internal static int ResolveStartupZoomPercent(int preferredZoomPercent, Rectangle workingArea, int monitorDpi)
    {
        if (preferredZoomPercent > 0) return Math.Clamp(preferredZoomPercent, 80, 130);
        // Zero requests automatic sizing; a manual choice always wins, including on a small monitor.
        // PerMonitorV2 work-area coordinates are pixels; compare their available height at 96 DPI.
        var logicalHeight = workingArea.Height * 96d / monitorDpi;
        return logicalHeight <= 1080 ? 80 : 100;
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

    private bool _categoryNavigationWidthMoving;

    private void InitializeCategoryNavigationWidth(SplitContainer split)
    {
        split.SplitterMoving += (_, _) => _categoryNavigationWidthMoving = true;
        split.SplitterMoved += (_, _) =>
        {
            if (!_categoryNavigationWidthMoving || IsDisposed || Disposing) return;
            _categoryNavigationWidthMoving = false;
            var width = Math.Max(1, (int)Math.Round(split.SplitterDistance * UiZoomBaselinePercent / (double)_uiZoomPercent));
            if (_settings.CategoryNavigationWidth == width) return;
            _settings.CategoryNavigationWidth = width;
            SaveEditorLayoutPreferences();
        };
        split.KeyDown += (_, e) => { if (e.KeyCode == Keys.Escape) _categoryNavigationWidthMoving = false; };
        split.MouseCaptureChanged += (_, _) =>
        {
            if (!_categoryNavigationWidthMoving || split.Capture || !split.IsHandleCreated) return;
            // Mouse-up may release capture before SplitterMoved; clear a cancelled drag after that handoff.
            split.BeginInvoke((Action)(() => _categoryNavigationWidthMoving = false));
        };
    }

    private void ApplyCategoryNavigationWidth()
    {
        if (_mainSplit is null || _mainSplit.ClientSize.Width <
            _mainSplit.Panel1MinSize + _mainSplit.Panel2MinSize + _mainSplit.SplitterWidth) return;
        _categoryNavigationWidthMoving = false;
        // No saved preference keeps the original automatic sidebar sizing.
        var desiredWidth = Zoomed(_settings.CategoryNavigationWidth > 0 ? _settings.CategoryNavigationWidth
            : Screen.FromControl(this).Bounds.Height == 1080 ? 280 : 260);
        var maxWidth = _settings.CategoryNavigationWidth > 0
            ? _mainSplit.ClientSize.Width - _mainSplit.Panel2MinSize - _mainSplit.SplitterWidth
            : Math.Min(Math.Max(Zoomed(210), ClientSize.Width / 3),
                _mainSplit.ClientSize.Width - _mainSplit.Panel2MinSize - _mainSplit.SplitterWidth);
        var width = Math.Max(_mainSplit.Panel1MinSize, Math.Min(desiredWidth, maxWidth));
        if (_mainSplit.SplitterDistance != width) _mainSplit.SplitterDistance = width;
    }
}