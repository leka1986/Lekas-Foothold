namespace FootholdConfigManager;

// Keep WinForms' scrolling, wheel handling and focus navigation. Its native
// non-client bar sits outside this clipped viewport; the manager's existing
// scrollbar presenter draws the synchronized real ScrollBar control beside it.
internal sealed class WeatherScrollHost : Panel
{
    private readonly ScrollableControl _content;
    private readonly VScrollBar _bar = new();
    private readonly MainForm.SlimScrollbarWindow _presentation;
    private bool _syncing;

    internal WeatherScrollHost(ScrollableControl content)
    {
        _content = content;
        _content.Dock = DockStyle.None;
        _content.AutoScroll = true;
        _content.Padding = new Padding(content.Padding.Left, content.Padding.Top, content.Padding.Right + _bar.Width, content.Padding.Bottom);
        _presentation = new MainForm.SlimScrollbarWindow(_bar, true);
        Controls.Add(_content);
        Controls.Add(_bar);
        _bar.ValueChanged += (_, _) =>
        {
            if (!_syncing) _content.AutoScrollPosition = new Point(0, _bar.Value);
        };
        _content.Layout += ContentLayout;
        _content.Scroll += ContentScroll;
        _content.MouseWheel += ContentLayout;
        _content.SizeChanged += ContentLayout;
        _bar.BringToFront();
    }

    protected override void OnLayout(LayoutEventArgs levent)
    {
        base.OnLayout(levent);
        if (_content is null) return;
        _content.SetBounds(0, 0, ClientSize.Width + _bar.Width, ClientSize.Height);
        _bar.SetBounds(Math.Max(0, ClientSize.Width - _bar.Width), 0, _bar.Width, ClientSize.Height);
        SyncRange();
    }

    internal static void SynchronizeParent(Control source)
    {
        for (var parent = source.Parent; parent is not null; parent = parent.Parent)
            if (parent is WeatherScrollHost host) { host.SyncRange(); return; }
    }

    private void ContentLayout(object? sender, EventArgs args) => SyncRange();
    private void ContentScroll(object? sender, ScrollEventArgs args) => SyncRange();

    private void SyncRange()
    {
        if (_syncing || _content.ClientSize.Height <= 0) return;
        _syncing = true;
        try
        {
            var extent = _content.DisplayRectangle.Height;
            var page = _content.ClientSize.Height;
            var maximum = Math.Max(0, extent - page);
            _bar.Minimum = 0;
            _bar.Maximum = Math.Max(0, extent - 1);
            _bar.LargeChange = Math.Max(1, page);
            _bar.SmallChange = Math.Max(1, Font.Height * 3);
            _bar.Value = Math.Clamp(-_content.AutoScrollPosition.Y, 0, maximum);
            _bar.Visible = maximum > 0;
            _presentation.Refresh();
        }
        finally { _syncing = false; }
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing)
        {
            _content.Layout -= ContentLayout;
            _content.Scroll -= ContentScroll;
            _content.MouseWheel -= ContentLayout;
            _content.SizeChanged -= ContentLayout;
            _presentation.Dispose();
        }
        base.Dispose(disposing);
    }
}