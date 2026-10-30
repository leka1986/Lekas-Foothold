namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private long _configPreparationVersion;
    private readonly HashSet<string> _preparedUnviewedCategories = new(StringComparer.OrdinalIgnoreCase);
    private LoadingScreenController? _loadingScreen;
    private bool _startupPreparationPending;

    internal void ConfigureStartupPreparation(LoadingScreenController loading)
    {
        _loadingScreen = loading;
        _startupPreparationPending = true;
    }

    internal void CompleteStartupPreparation()
    {
        var wasPending = _startupPreparationPending;
        _startupPreparationPending = false;
        if (wasPending) CompleteCategoryPresentation(GetSelectedCategoryName());
        if (_singleInstance is not null) _singleInstance.ModelReady(_requestAdminOnLoad);
        else if (_requestAdminOnLoad) UnlockAdminDesigner();
    }

    private void CompleteCategoryPresentation(string categoryName)
    {
        if (_optionsViewedCategory is not null || !_optionsPending.ContainsKey(categoryName))
            _optionsViewedCategory = categoryName;
        ApplyOptionsMarkers();
        if (!_preparedUnviewedCategories.Remove(categoryName)) return;
        var items = GetDesignerItems(categoryName, includeTableRows: false);
        AcknowledgeDisplayedImportedNewItems();
        AcknowledgeDisplayedBucketNewItems(categoryName, items);
        RefreshNewCategoryVisibility(categoryName, items);
        _categoryList.Invalidate();
    }

    internal async Task PrepareConfigViewsAsync(IProgress<LoadingProgress> progress, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        if (_document is null) return;
        var document = _document;
        var version = _configPreparationVersion;
        var categories = _categoryList.Items.Cast<object>().Select(GetCategoryItemName).ToArray();
        _categoryPanelRecency.EnsureCapacityAtLeast(Math.Max(1, categories.Length));
        var rendered = _renderedCategoryName;
        var viewed = _optionsViewedCategory;
        var activeCategory = _activeImportedNewCategoryName;
        var activeKeys = _activeImportedNewEntryKeys.ToArray();
        SaveRenderedCategoryScroll();
        var scroll = _categoryScrollPositions.ToArray();
        try
        {
            for (var index = 0; index < categories.Length; index++)
            {
                cancellationToken.ThrowIfCancellationRequested();
                if (IsDisposed || Disposing || !ReferenceEquals(document, _document) || version != _configPreparationVersion)
                    throw new OperationCanceledException("Config preparation became obsolete.");
                var category = categories[index];
                progress.Report(new LoadingProgress("Preparing " + GetCategoryDisplayName(category) + "…", index, categories.Length));
                RenderCategory(category, force: false, preparing: true);
                _formHost.PerformLayout();
                _formHost.Update();
                await Task.Yield();
            }
            progress.Report(new LoadingProgress("Configuration views ready", categories.Length, categories.Length));
        }
        finally
        {
            if (!IsDisposed && !Disposing && ReferenceEquals(document, _document) && version == _configPreparationVersion)
            {
                _activeImportedNewEntryKeys.Clear();
                _activeImportedNewEntryKeys.UnionWith(activeKeys);
                _activeImportedNewCategoryName = activeCategory;
                _optionsViewedCategory = viewed;
                if (rendered is not null) RenderCategory(rendered, force: false, preparing: true);
                _categoryScrollPositions.Clear();
                foreach (var position in scroll) _categoryScrollPositions[position.Key] = position.Value;
                if (rendered is not null) RestoreCategoryScroll(rendered, _uiViewGeneration.Current);
                _optionsViewedCategory = viewed;
            }
            _loadingForm = false;
        }
    }
}
