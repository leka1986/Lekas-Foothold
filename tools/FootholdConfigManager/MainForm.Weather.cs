namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private WeatherWindow? _weatherWindow;
    private Panel? _weatherWorkspace;
    private Control? _configWorkspace;
    private bool _configZoomRefreshPending;
    [System.Runtime.InteropServices.DllImport("user32.dll", EntryPoint = "SendMessageW")]
    private static extern IntPtr SendZoomRedrawMessage(IntPtr window, uint message, IntPtr wParam, IntPtr lParam);

    private void ShowWeatherWindow()
    {
        if (_weatherWindow is { Visible: true })
        {
            _weatherWindow.LeaveWeather();
            return;
        }
        EnsureWeatherWindow();
        _configWorkspace!.Hide();
        _previewCommentsButton!.Visible = false;
        _weatherWindow!.ShowWorkspace();
        _weatherWindow.BringToFront();
        _weatherWindow.Select();
        LayoutPreviewFooter();
    }

    private void EnsureWeatherWindow()
    {
        if (_weatherWorkspace is null)
        {
            var root = _rootLayout!;
            _configWorkspace = root.GetControlFromPosition(0, 1)!;
            _weatherWorkspace = new Panel { Name = "ManagerWorkspace", Dock = DockStyle.Fill, Margin = _configWorkspace.Margin };
            _configWorkspace.SuspendLayout();
            root.SuspendLayout();
            _weatherWorkspace.SuspendLayout();
            try
            {
                root.Controls.Remove(_configWorkspace);
                _weatherWorkspace.Controls.Add(_configWorkspace);
                root.Controls.Add(_weatherWorkspace, 0, 1);
            }
            finally
            {
                _weatherWorkspace.ResumeLayout(false);
                root.ResumeLayout();
                _configWorkspace.ResumeLayout(ReferenceEquals(_configWorkspace.Parent, _weatherWorkspace));
            }
            FormClosing += (_, args) =>
            {
                if (_weatherWindow is { IsDisposed: false } && !_weatherWindow.SaveBeforeLeaving()) args.Cancel = true;
            };
        }
        if (_weatherWindow is null || _weatherWindow.IsDisposed)
        {
            var window = new WeatherWindow(_settings.MissionScriptingPath, Font, MakeButton, ApplyDialogChrome, _uiZoomPercent / 100f,
                () => FindEntry("Era")?.ValueText ?? (GetCurrentConfigFileName(_document) == RuntimeSettings.Ww2ConfigFileName ? "WW2" : null));
            window.ConfigureMizBrowsing(
                () => GetExistingInitialDirectory(_settings.LastMizDirectory) ?? (_document is null
                    ? RuntimeSettings.GetBestInitialDirectory() : Path.GetDirectoryName(_document.Path)!),
                path => { _settings.LastMizDirectory = Path.GetDirectoryName(path); _settings.Save(); });
            window.EmbedInManager(ShowConfigWorkspace);
            _weatherWindow = window;
            _weatherWorkspace.Controls.Add(window);
        }
    }

    internal async Task PrepareMissionSettingsAsync(IProgress<LoadingProgress> progress, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        EnsureWeatherWindow();
        var window = _weatherWindow!;
        var wasVisible = window.Visible;
        var configWasVisible = _configWorkspace!.Visible;
        try
        {
            progress.Report(new LoadingProgress("Loading Mission settings…"));
            window.ShowWorkspace();
            await window.PrepareViewsAsync(cancellationToken);
            progress.Report(new LoadingProgress("Mission settings ready", 1, 1));
        }
        finally
        {
            if (!window.IsDisposed && !wasVisible) window.Hide();
            if (!IsDisposed && !Disposing && configWasVisible)
            {
                _configWorkspace.Show();
                _configWorkspace.BringToFront();
            }
        }
    }

    private void RefreshWeatherZoom()
    {
        if (_weatherWindow is not { IsDisposed: false }) return;
        _weatherWindow.ApplyUiZoom(_uiZoomPercent / 100f, deferGalleryLayout: true);
    }

    private void ShowConfigWorkspace()
    {
        _weatherWindow!.Hide();
        if (_configZoomRefreshPending)
        {
            RefreshCurrentView();
            _configZoomRefreshPending = false;
        }
        _configWorkspace!.Show();
        _previewCommentsButton!.Visible = false;
        _configWorkspace.BringToFront();
        LayoutPreviewFooter();
    }
}
