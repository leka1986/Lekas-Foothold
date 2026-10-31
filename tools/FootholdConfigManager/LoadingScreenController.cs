namespace FootholdConfigManager;

internal sealed class LoadingScreenController : IDisposable
{
    internal LoadingScreenForm Presentation { get; }
    private CancellationTokenSource? _activeCancellation;
    private Form? _owner;
    private bool _ownerWasEnabled;
    private RadarLoadingForm? _radar;
    private int _modalDepth;

    internal LoadingScreenController(int pictureIndex)
    {
        Presentation = new LoadingScreenForm(pictureIndex);
        Presentation.CancelRequested += (_, _) => _activeCancellation?.Cancel();
    }

    internal async Task RunAsync(Form? owner, string stage,
        Func<IProgress<LoadingProgress>, CancellationToken, Task> work, CancellationToken cancellationToken)
    {
        if (_activeCancellation is not null) throw new InvalidOperationException("Loading work is already active.");
        using var cancellation = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        _activeCancellation = cancellation;
        _owner = owner;
        _ownerWasEnabled = owner?.Enabled == true;
        try
        {
            cancellation.Token.ThrowIfCancellationRequested();
            if (owner is not null)
            {
                _radar = await RadarLoadingForm.ShowAsync(owner, Presentation.LoadingIcon, stage, cancellation.Cancel);
            }
            SetOwnerPreparing(true);
            Report(new LoadingProgress(stage));
            if (owner is null) Presentation.Show();
            if (_radar is null) Presentation.Update(); // Paint real feedback before synchronous native construction.
            await Task.Yield();
            var progress = new Progress<LoadingProgress>(value =>
            {
                if (_activeCancellation == cancellation) Report(value);
            });
            await work(progress, cancellation.Token);
            cancellation.Token.ThrowIfCancellationRequested();
        }
        finally
        {
            _activeCancellation = null; // Reject queued progress before the radar STA destroys its HWND.
            if (_radar is not null) await _radar.CloseAsync();
            else if (!Presentation.IsDisposed)
            {
                Presentation.Hide();
                Presentation.Owner = null;
            }
            SetOwnerPreparing(false);
            _radar = null;
            _owner = null;
        }
    }

    private void Report(LoadingProgress progress)
    {
        if (_radar is not null) _radar.Report(progress);
        else Presentation.Report(progress);
    }

    private void SetOwnerPreparing(bool preparing)
    {
        if (_owner is not { IsDisposed: false } owner) return;
        owner.Enabled = preparing ? false : _ownerWasEnabled;
    }

    internal IDisposable SuspendForModal()
    {
        if (_activeCancellation is null) return new ModalScope(null);
        if (_modalDepth++ == 0)
        {
            if (_radar is not null) _radar.Pause();
            else Presentation.Hide();
            SetOwnerPreparing(false);
        }
        return new ModalScope(this);
    }

    internal IDisposable SuspendForModal(Form dialog)
    {
        if (_activeCancellation is null) return new ModalScope(null);
        EventHandler? shown = null;
        if (_modalDepth++ == 0)
        {
            SetOwnerPreparing(false); // Let ShowDialog establish normal modal ownership while loading stays visible.
            shown = (_, _) =>
            {
                dialog.Refresh();
                if (_radar is not null) _radar.Pause();
                else Presentation.Hide();
            };
            dialog.Shown += shown;
        }
        return new ModalScope(this, dialog, shown);
    }

    private sealed class ModalScope(LoadingScreenController? controller, Form? dialog = null, EventHandler? shown = null) : IDisposable
    {
        private LoadingScreenController? _controller = controller;
        private Form? _dialog = dialog;
        private EventHandler? _shown = shown;
        public void Dispose()
        {
            if (_dialog is not null && _shown is not null) _dialog.Shown -= _shown;
            _dialog = null;
            _shown = null;
            var owner = _controller;
            _controller = null;
            if (owner is null || --owner._modalDepth != 0 || owner._activeCancellation is null) return;
            owner.SetOwnerPreparing(true);
            if (owner._radar is not null) owner._radar.ResumeLoading();
            else { owner.Presentation.Show(); owner.Presentation.Update(); }
        }
    }

    public void Dispose()
    {
        _activeCancellation?.Cancel();
        _radar?.CloseAsync().GetAwaiter().GetResult();
        Presentation.Dispose();
    }
}
