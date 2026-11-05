namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private bool _configLoadingOperation;
    private bool _deferCategoryPresentation;
    internal Control? LoadingForegroundSurface => _updatesPanel is { Visible: true } ? _updatesPanel : null;

    private async Task RunConfigLoadingAsync(Func<IProgress<LoadingProgress>, CancellationToken, Task> work, CancellationToken cancellationToken, string stage = "Updating configuration…", bool finishCommittedPreparation = false, string errorTitle = "Update Config")
    {
        if (_configLoadingOperation) return;
        var document = _document;
        Func<IProgress<LoadingProgress>, CancellationToken, Task> admittedWork = finishCommittedPreparation ? CompleteCommittedWorkAsync : work;
        _configLoadingOperation = true;
        RefreshManagerUpdateNotice();
        _deferCategoryPresentation = _loadingScreen is not null;
        try
        {
            if (_loadingScreen is null)
            {
                await admittedWork(new Progress<LoadingProgress>(), cancellationToken);
                return;
            }
            await _loadingScreen.RunAsync(this, stage, async (progress, token) =>
            {
                await admittedWork(progress, token);
                // Only a committed reload needs new views; picker/preview cancellation stays cheap.
                if (!finishCommittedPreparation && !ReferenceEquals(document, _document))
                {
                    await PrepareConfigViewsAsync(progress, token);
                    await PrepareMissionSettingsAsync(progress, token);
                }
            }, cancellationToken);
        }
        catch (OperationCanceledException) { SetStatus("Configuration preparation cancelled."); }
        catch (Exception error)
        {
            if (!IsDisposed && !Disposing)
            {
                using var modal = _loadingScreen?.SuspendForModal();
                MessageBox.Show(this, error.Message, errorTitle, MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
        finally
        {
            _deferCategoryPresentation = false;
            _configLoadingOperation = false;
            _singleInstance?.SetStartupPresentation(null);
            if (!IsDisposed && !Disposing && _loadingScreen is not null)
                CompleteCategoryPresentation(GetSelectedCategoryName());
            if (_updatesPanel is { Visible: true } && _updatesContent is { Visible: true })
                RefreshUpdatesPresentation();
            else
                RefreshManagerUpdateNotice();
        }
        async Task CompleteCommittedWorkAsync(IProgress<LoadingProgress> progress, CancellationToken token)
        {
            try { await work(progress, token); }
            finally
            {
                if (!IsDisposed && !Disposing && !ReferenceEquals(document, _document))
                {
                    await PrepareConfigViewsAsync(progress, CancellationToken.None);
                    await PrepareMissionSettingsAsync(progress, CancellationToken.None);
                }
            }
        }    }
}
