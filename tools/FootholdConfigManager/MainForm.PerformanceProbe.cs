using System.Diagnostics;
using System.Text.Json;

namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    internal static int RunPerformanceProbe(IReadOnlyList<string> requestedPaths)
    {
        var paths = requestedPaths.Count > 0
            ? requestedPaths
            : new[]
            {
                Path.Combine(Environment.CurrentDirectory, "Utils", RuntimeSettings.DefaultConfigFileName),
                Path.Combine(Environment.CurrentDirectory, "Utils", RuntimeSettings.Ww2ConfigFileName)
            };
        var failed = false;
        foreach (var path in paths)
        {
            try
            {
                Console.WriteLine(JsonSerializer.Serialize(
                    MeasurePerformance(path),
                    new JsonSerializerOptions { WriteIndented = true }));
            }
            catch (Exception ex)
            {
                failed = true;
                Console.Error.WriteLine(path + ": " + ex.Message);
            }
        }

        return failed ? 1 : 0;
    }

    private static PerformanceProbeResult MeasurePerformance(string configPath)
    {
        var fullPath = Path.GetFullPath(configPath);
        ForceManagedCollection();
        var shellAllocationStart = GC.GetAllocatedBytesForCurrentThread();
        var shellStopwatch = Stopwatch.StartNew();
        using var form = new MainForm();
        shellStopwatch.Stop();
        var shellAllocatedBytes = GC.GetAllocatedBytesForCurrentThread() - shellAllocationStart;
        _ = form.Handle;

        ConfigDocument.Load(fullPath);
        var parseMeasurement = MeasureMedianPerOperation(
            7,
            10,
            _ => ConfigDocument.Load(fullPath));
        var document = ConfigDocument.Load(fullPath);
        form._document = document;
        form.LoadCategories(renderSelection: false);

        form.InvalidateConfigSearchIndex();
        var coldSearch = MeasureOnce(() => form.BuildConfigSearchResults("engineer"));
        var searchQueries = new[] { "engineer", "mission", "map", "spawn", "difficulty" };
        foreach (var query in searchQueries)
        {
            form.BuildConfigSearchResults(query);
        }

        var warmSearch = MeasureMedianPerOperation(
            7,
            200,
            iteration => form.BuildConfigSearchResults(searchQueries[iteration % searchQueries.Length]));

        for (var index = 0; index < form._categoryList.Items.Count; index++)
        {
            form.SelectCategoryIndexForPerformanceProbe(index);
            form.RenderSelectedCategory();
        }

        form.ClearCategoryPanelCache();
        var categoryConstruction = MeasureOnce(() =>
        {
            for (var index = 0; index < form._categoryList.Items.Count; index++)
            {
                form.SelectCategoryIndexForPerformanceProbe(index);
                form.RenderSelectedCategory();
            }
        });
        var cachedPanelCount = form._categoryPanelCache.Count;

        var cacheHitTraversal = MeasureOnce(() =>
        {
            for (var index = form._categoryList.Items.Count - 1; index >= 0; index--)
            {
                form.SelectCategoryIndexForPerformanceProbe(index);
                form.RenderSelectedCategory();
            }
        });

        ForceManagedCollection();
        var retainedManagedBytes = GC.GetTotalMemory(forceFullCollection: false);
        var cachedControlCount = form._categoryPanelCache.Values
            .Distinct()
            .Sum(CountControlTree);
        var cachedGridCount = form._categoryPanelCache.Values
            .Distinct()
            .Sum(panel => EnumerateChildControls<DataGridView>(panel).Count());
        var supportedZoomSmokeFailure = form.RunSupportedZoomSmoke();

        var result = new PerformanceProbeResult(
            fullPath,
            form._categoryList.Items.Count,
            cachedPanelCount,
            shellStopwatch.Elapsed.TotalMilliseconds,
            shellAllocatedBytes,
            parseMeasurement.Milliseconds,
            parseMeasurement.AllocatedBytes,
            coldSearch.Milliseconds,
            coldSearch.AllocatedBytes,
            warmSearch.Milliseconds,
            warmSearch.AllocatedBytes,
            categoryConstruction.Milliseconds,
            categoryConstruction.AllocatedBytes,
            cacheHitTraversal.Milliseconds,
            cacheHitTraversal.AllocatedBytes,
            retainedManagedBytes,
            cachedControlCount,
            cachedGridCount,
            supportedZoomSmokeFailure is null,
            supportedZoomSmokeFailure);

        form.RestoreConfigSearchHighlight();
        form.DisposeConfigSearchRefreshTimer();
        form.ClearCategoryPanelCache();
        return result;
    }

    private string? RunSupportedZoomSmoke()
    {
        foreach (var zoomPercent in new[] { 80, 90, 100, 110, 120, 130, 140, 150 })
        {
            SetUiZoom(zoomPercent, persist: false);
            for (var index = 0; index < _categoryList.Items.Count; index++)
            {
                SelectCategoryIndexForPerformanceProbe(index);
                RenderSelectedCategory();
            }

            if (_categoryPanelCache.Count > CategoryPanelCacheCapacity ||
                _searchBox.Width <= 0 ||
                _searchBox.Height <= 0 ||
                _categoryList.Width <= 0 ||
                _formHost.Width <= 0)
            {
                return "Zoom " + zoomPercent + " produced invalid hidden-form dimensions or exceeded the cache cap: " +
                       "cache=" + _categoryPanelCache.Count +
                       ", search=" + _searchBox.Size +
                       ", categories=" + _categoryList.Size +
                       ", host=" + _formHost.Size + ".";
            }

            var smokeItem = GetConfigSearchIndex().FirstOrDefault();
            var searchResult = smokeItem is null
                ? null
                : BuildConfigSearchResults(smokeItem.TargetKey)
                    .FirstOrDefault(result =>
                        result.CanNavigate &&
                        result.RowKey is null &&
                        result.TargetKey.Equals(smokeItem.TargetKey, StringComparison.Ordinal));
            if (searchResult is null)
            {
                return "Zoom " + zoomPercent + " could not find a real top-level search result.";
            }

            JumpToConfigSearchResult(searchResult);
            Application.DoEvents();
            Application.DoEvents();
            var target = _formHost.Controls
                .Find(ConfigSearchTargetNamePrefix + searchResult.TargetKey, searchAllChildren: true)
                .FirstOrDefault();
            if (target is null || target.IsDisposed || !_formHost.Contains(target) ||
                !string.Equals(_renderedCategoryName, searchResult.CategoryName, StringComparison.OrdinalIgnoreCase))
            {
                return "Zoom " + zoomPercent + " did not attach and locate the selected search target.";
            }
        }

        return null;
    }

    private void SelectCategoryIndexForPerformanceProbe(int index)
    {
        _loadingCategories = true;
        try
        {
            _categoryList.SelectedIndex = index;
        }
        finally
        {
            _loadingCategories = false;
        }
    }

    private static ProbeMeasurement MeasureOnce(Action action)
    {
        ForceManagedCollection();
        var allocationStart = GC.GetAllocatedBytesForCurrentThread();
        var stopwatch = Stopwatch.StartNew();
        action();
        stopwatch.Stop();
        return new ProbeMeasurement(
            stopwatch.Elapsed.TotalMilliseconds,
            GC.GetAllocatedBytesForCurrentThread() - allocationStart);
    }

    private static ProbeMeasurement MeasureMedianPerOperation(
        int sampleCount,
        int operationsPerSample,
        Action<int> operation)
    {
        var samples = new List<ProbeMeasurement>(sampleCount);
        for (var sample = 0; sample < sampleCount; sample++)
        {
            var measurement = MeasureOnce(() =>
            {
                for (var operationIndex = 0; operationIndex < operationsPerSample; operationIndex++)
                {
                    operation(operationIndex);
                }
            });
            samples.Add(new ProbeMeasurement(
                measurement.Milliseconds / operationsPerSample,
                measurement.AllocatedBytes / operationsPerSample));
        }

        return new ProbeMeasurement(
            samples.Select(sample => sample.Milliseconds).Order().ElementAt(sampleCount / 2),
            samples.Select(sample => sample.AllocatedBytes).Order().ElementAt(sampleCount / 2));
    }

    private static int CountControlTree(Control control)
    {
        return 1 + control.Controls.Cast<Control>().Sum(CountControlTree);
    }

    private static void ForceManagedCollection()
    {
        GC.Collect();
        GC.WaitForPendingFinalizers();
        GC.Collect();
    }

    private sealed record ProbeMeasurement(double Milliseconds, long AllocatedBytes);

    private sealed record PerformanceProbeResult(
        string ConfigPath,
        int VisibleCategoryCount,
        int CachedPanelCount,
        double ShellMilliseconds,
        long ShellAllocatedBytes,
        double ParseMilliseconds,
        long ParseAllocatedBytes,
        double ColdSearchMilliseconds,
        long ColdSearchAllocatedBytes,
        double WarmSearchMillisecondsPerQuery,
        long WarmSearchAllocatedBytesPerQuery,
        double FirstAllCategoriesMilliseconds,
        long FirstAllCategoriesAllocatedBytes,
        double CacheHitTraversalMilliseconds,
        long CacheHitTraversalAllocatedBytes,
        long RetainedManagedBytes,
        int CachedControlCount,
        int CachedGridCount,
        bool SupportedZoomSmokePassed,
        string? SupportedZoomSmokeFailure);
}
