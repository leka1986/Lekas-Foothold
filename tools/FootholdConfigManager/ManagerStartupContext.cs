namespace FootholdConfigManager;

internal sealed class ManagerStartupContext : ApplicationContext
{
    private readonly SingleInstanceCoordinator _owner;
    private readonly LoadingScreenController _loading;
    private readonly bool _requestAdmin;
    private readonly CancellationTokenSource _lifetime = new();
    private MainForm? _manager;
    private bool _disposed;

    internal ManagerStartupContext(SingleInstanceCoordinator owner, LoadingScreenController loading, bool requestAdmin)
    {
        _owner = owner;
        _loading = loading;
        _requestAdmin = requestAdmin;
        MainForm = loading.Presentation;
        loading.Presentation.Shown += OnLoadingShown;
    }

    private async void OnLoadingShown(object? sender, EventArgs args)
    {
        _loading.Presentation.Shown -= OnLoadingShown;
        try { await StartAsync(); }
        catch (OperationCanceledException)
        {
            _manager?.Dispose();
            ExitThread();
        }
        catch (Exception error)
        {
            _loading.Presentation.Hide();
            MessageBox.Show("The manager could not finish loading." + Environment.NewLine + error.Message,
                "Foothold Config Manager", MessageBoxButtons.OK, MessageBoxIcon.Error);
            _manager?.Dispose();
            ExitThread();
        }
    }

    private async Task StartAsync()
    {
        try
        {
            await _loading.RunAsync(null, "Loading configuration…", async (progress, cancellationToken) =>
            {
                cancellationToken.ThrowIfCancellationRequested();
                ExperimentBootstrap.PrepareOwnerData(); // Only the admitted owner seeds config copies.
                var manager = _manager = new MainForm(_requestAdmin);
                manager.ConfigureStartupPreparation(_loading);
                manager.ShowInTaskbar = false;
                manager.Opacity = 0;
                manager.Enabled = false;
                manager.AttachSingleInstance(_owner);
                _owner.SetStartupPresentation(_loading.Presentation);
                // Common dialogs remain owned by the real manager and can rise above its splash.
                _loading.Presentation.Owner = manager;
                manager.FormClosed += (_, _) => { if (!_disposed) _lifetime.Cancel(); };
                manager.Show();
                // Re-register the splash with the shell after attaching its hidden owner.
                _loading.Presentation.Icon = manager.Icon;
                _loading.Presentation.Hide();
                _loading.Presentation.Show();
                _loading.Presentation.Refresh(); // Paint the photo and child controls before synchronous preparation.
                await manager.PrepareConfigViewsAsync(progress, cancellationToken);
                await manager.PrepareMissionSettingsAsync(progress, cancellationToken);
                cancellationToken.ThrowIfCancellationRequested();
                manager.PerformLayout();
                MainForm = manager;
            }, _lifetime.Token);
            _owner.SetStartupPresentation(null);
            _manager!.CompleteStartupPreparation();
            _manager.Enabled = true;
            _manager.ShowInTaskbar = true;
            _manager.Opacity = 1;
            _manager.Update();
            _manager.Activate();
            _ = _manager.BeginUpdateChecksAsync();
        }
        finally { _owner.SetStartupPresentation(null); }
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing && !_disposed)
        {
            _disposed = true;
            _lifetime.Cancel();
            _lifetime.Dispose();
        }
        base.Dispose(disposing);
    }
}
