namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private bool _configLoadingOperation;
    private bool _deferCategoryPresentation;

    private async Task RunConfigLoadingAsync(Func<IProgress<LoadingProgress>, CancellationToken, Task> work, CancellationToken cancellationToken, string stage = "Updating configuration…")
    {
        if (_configLoadingOperation) return;
        var document = _document;
        _configLoadingOperation = true;
        RefreshManagerUpdateNotice();
        _deferCategoryPresentation = _loadingScreen is not null;
        try
        {
            if (_loadingScreen is null)
            {
                await work(new Progress<LoadingProgress>(), cancellationToken);
                return;
            }
            await _loadingScreen.RunAsync(this, stage, async (progress, token) =>
            {
                await work(progress, token);
                // Only a committed reload needs new views; picker/preview cancellation stays cheap.
                if (!ReferenceEquals(document, _document))
                {
                    await PrepareConfigViewsAsync(progress, token);
                    await PrepareMissionSettingsAsync(progress, token);
                }
            }, cancellationToken);
        }
        catch (OperationCanceledException) { SetStatus("Configuration preparation cancelled."); }
        catch (Exception error)
        {
            using var modal = _loadingScreen?.SuspendForModal();
            MessageBox.Show(this, error.Message, "Update Config", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
        finally
        {
            _deferCategoryPresentation = false;
            _configLoadingOperation = false;
            _singleInstance?.SetStartupPresentation(null);
            if (!IsDisposed && !Disposing && _loadingScreen is not null)
                CompleteCategoryPresentation(GetSelectedCategoryName());
            RefreshManagerUpdateNotice();
        }
    }
}
