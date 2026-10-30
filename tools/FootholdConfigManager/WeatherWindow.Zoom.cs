namespace FootholdConfigManager;

internal sealed partial class WeatherWindow
{
    private bool _zooming;
    private (ScrollableControl Control, Point Position, float Ratio)[]? _zoomScroll;

    private readonly Dictionary<Control, ZoomGeometry> _zoomGeometry = new();
    private sealed record ZoomGeometry(float Scale, bool WeatherContent, Padding Margin, Padding Padding, Size Minimum, Size Maximum,
        Size Size, float FontSize, FontStyle FontStyle, string FontFamily, Size TabSize, float[] Columns, float[] Rows);

    // Called only by the manager's zoom transaction. Retain controls, native input
    // state, catalog and decoded pictures; absolute baselines prevent round-trip drift.
    internal void ApplyUiZoom(float scale, bool deferGalleryLayout = false)
    {
        var weatherScale = Math.Max(.7f, scale - .1f);
        if (Math.Abs(scale - _uiScale) < .0001f && Math.Abs(weatherScale - _weatherUiScale) < .0001f) return;
        var controls = new[] { (Control)this }.Concat(Descendants(this))
            .Where(c => c.Parent is not NumericUpDown && c is not IDataGridViewEditingControl &&
                !(c.Parent is DataGridView grid && ReferenceEquals(c, grid.EditingPanel)) &&
                !(c.Parent is WeatherDateTimeInput dateInput && dateInput.OwnsDateTextEditor(c))).ToArray();
        foreach (var stale in _zoomGeometry.Keys.Where(c => c.IsDisposed).ToArray()) _zoomGeometry.Remove(stale);
        foreach (var control in controls)
        {
            if (!_zoomGeometry.ContainsKey(control))
            {
                var weatherContent = ReferenceEquals(control, _weatherBody) || control.Parent is { } parent && _zoomGeometry.TryGetValue(parent, out var parentGeometry) && parentGeometry.WeatherContent;
                _zoomGeometry.Add(control, new(weatherContent ? _weatherUiScale : _uiScale, weatherContent, control.Margin, control.Padding, control.MinimumSize, control.MaximumSize,
                    control.Size, control.Font.Size, control.Font.Style, control.Font.FontFamily.Name,
                    control is TabControl tabs ? tabs.ItemSize : Size.Empty,
                    control is TableLayoutPanel table ? table.ColumnStyles.Cast<ColumnStyle>().Select(s => s.SizeType == SizeType.Absolute ? s.Width : -1).ToArray() : Array.Empty<float>(),
                    control is TableLayoutPanel rows ? rows.RowStyles.Cast<RowStyle>().Select(s => s.SizeType == SizeType.Absolute ? s.Height : -1).ToArray() : Array.Empty<float>()));
            }
            control.SuspendLayout();
        }
        var scroll = controls.OfType<ScrollableControl>().Where(c => c.AutoScroll)
            .Select(c => (Control:c, Position:c.AutoScrollPosition, Ratio:_zoomGeometry[c].WeatherContent ? weatherScale / _weatherUiScale : scale / _uiScale)).ToArray();
        _zoomScroll = scroll;

        foreach (var owned in new[] { _bodyFont, _captionFont, _boldFont })
            _zoomFontCache.TryAdd((owned.FontFamily.Name, (float)Math.Round(owned.Size,4), owned.Style),owned);
        var fonts = _zoomFontCache;

        _zooming = true;
        _uiScale = scale;
        _weatherUiScale = weatherScale;
        try
        {
            _windLayout.AutoSize = true;
            foreach (var control in controls)
            {
                var baseline = _zoomGeometry[control];
                var targetScale = baseline.WeatherContent ? weatherScale : scale;
                var factor = targetScale / baseline.Scale;
                int Z(int value) => (int)Math.Round(value * factor);
                Size SizeAt(Size value) => new(Z(value.Width), Z(value.Height));
                Padding Pad(Padding p) => new(Z(p.Left), Z(p.Top), Z(p.Right), Z(p.Bottom));
                control.Margin = Pad(baseline.Margin); control.Padding = Pad(baseline.Padding);
                control.MinimumSize = Size.Empty;
                control.MaximumSize = SizeAt(baseline.Maximum);
                control.MinimumSize = SizeAt(baseline.Minimum);
                var valueText = control is ComboBox || control is WeatherCheckBox && control.AccessibleName?.EndsWith(" value", StringComparison.Ordinal) == true;
                var fontSize = control is NumericUpDown or WeatherDateTimeInput
                    ? (10f + MainForm.ValueFontPointsAtZoom(scale)) * scale
                    : baseline.FontSize * factor + (valueText ? MainForm.ValueFontPointsAtZoom(scale) * scale : 0f);
                control.Font = GetCachedZoomFont(baseline.FontFamily, fontSize, baseline.FontStyle);
                if (ReferenceEquals(control, _fogGrid))
                {
                    _fogGrid.DefaultCellStyle.Font = WeatherValueFont;
                    if (_fogGrid.EditingControl is IDataGridViewEditingControl editor)
                        editor.ApplyCellStyleToEditingControl(_fogGrid.CurrentCell.InheritedStyle);
                }
                if (!control.AutoSize && control != this && control is not WeatherCloudCard)
                {
                    if (control.Dock == DockStyle.Top || control.Dock == DockStyle.Bottom) control.Height = Z(baseline.Size.Height);
                    else if (control.Dock == DockStyle.Left || control.Dock == DockStyle.Right) control.Width = Z(baseline.Size.Width);
                    else if (control.Dock == DockStyle.None && control.Parent is not NumericUpDown) control.Size = SizeAt(baseline.Size);
                }
                if (control is TableLayoutPanel table)
                {
                    for (var i=0; i<baseline.Columns.Length && i<table.ColumnStyles.Count; i++)
                        if (baseline.Columns[i]>=0 && !(ReferenceEquals(table, _weatherBody) && i == 1) && !(ReferenceEquals(table, _windLayout) && i is 1 or 3)) table.ColumnStyles[i].Width=Z((int)Math.Round(baseline.Columns[i]));
                    for (var i=0; i<baseline.Rows.Length && i<table.RowStyles.Count; i++)
                        if (baseline.Rows[i]>=0) table.RowStyles[i].Height=Z((int)Math.Round(baseline.Rows[i]));
                }
                if (control is TabControl tabs) tabs.ItemSize = SizeAt(baseline.TabSize);
                if (control is ComboBox combo) combo.ItemHeight=Math.Max((int)Math.Round(24 * targetScale), combo.Font.Height + 4);
                if (control is WeatherInputFrame frame) frame.Inset=(int)Math.Round((frame.Input is ComboBox ? 3 : 9) * targetScale);
            }
            _bodyFont=Font; _boldFont=fonts.Values.FirstOrDefault(f=>f.Bold && Math.Abs(f.Size-Font.Size)<.1f) ?? new Font(Font,FontStyle.Bold);
            _captionFont=fonts.Values.FirstOrDefault(f=>Math.Abs(f.Size-9*weatherScale)<.1f) ?? new Font(Font.FontFamily,9*weatherScale);

        }
        finally
        {
            foreach (var control in controls.Reverse()) control.ResumeLayout(false);
            foreach (var frame in controls.OfType<WeatherInputFrame>()) frame.PerformLayout();
            _root.Height = Math.Max(S(650), _root.Parent?.ClientSize.Height ?? S(650));
            _root.PerformLayout();
            Controls[0].PerformLayout();

        }
        if (!deferGalleryLayout) FinishUiZoom();
    }

    // The manager calls this after its outer containers have their final sizes.
    internal void FinishUiZoom()
    {
        if (!_zooming) return;
        try
        {
            LayoutWeatherColumns();
            _zooming = false;
            LayoutWindColumns();
            _windLayout.PerformLayout();
            LayoutCloudCards();
            foreach (var item in _zoomScroll!)
                item.Control.AutoScrollPosition = new Point((int)Math.Round(-item.Position.X * item.Ratio), (int)Math.Round(-item.Position.Y * item.Ratio));
        }
        finally { _zooming = false; _zoomScroll = null; Invalidate(true); }
    }
    private Font WeatherValueFont => GetCachedZoomFont(Font.FontFamily.Name, (10f + MainForm.ValueFontPointsAtZoom(_uiScale)) * _uiScale, FontStyle.Regular);

    private Font GetCachedZoomFont(string family, float size, FontStyle style)
    {
        var key = (family, (float)Math.Round(size, 4), style);
        if (!_zoomFontCache.TryGetValue(key, out var font))
            _zoomFontCache.Add(key, font = new Font(key.family, key.Item2, key.style));
        return font;
    }

    private readonly Dictionary<(string Family, float Size, FontStyle Style), Font> _zoomFontCache = new();
}