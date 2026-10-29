namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private sealed record NewCategoryVisibility(HashSet<string> EntryKeys, bool HasBucketItems);
    private readonly Dictionary<string, NewCategoryVisibility> _newCategoryVisibility = new(StringComparer.OrdinalIgnoreCase);

    private Action? _releaseManagedNewReview;

    private void BindManagedNewReview(ConfigDocument document)
    {
        _releaseManagedNewReview?.Invoke();
        _releaseManagedNewReview = null;
        if (!_pendingNewItemStore.Configs.TryGetValue(document.Path, out var pending)) return;
        var targets = document.StringListTables.Where(table => table.ManagedSource is not null && pending.ContainsKey(table.Key));
        foreach (var group in targets.GroupBy(table => table.ManagedSource!))
        {
            var source = group.Key;
            var categories = group.Select(table => table.Section).Distinct(StringComparer.OrdinalIgnoreCase).ToArray();
            void Refresh()
            {
                if (IsDisposed || Disposing || !ReferenceEquals(_document, document)) return;
                foreach (var category in categories)
                    RefreshNewCategoryVisibility(category, GetDesignerItems(category, includeTableRows: false));
                _categoryList.Invalidate();
            }
            source.ManagedValuesChanged += Refresh;
            _releaseManagedNewReview += () => source.ManagedValuesChanged -= Refresh;
        }
    }

    private void RefreshNewCategoryVisibility(string category, IReadOnlyList<DesignerItem> items)
    {
        _newCategoryVisibility.Remove(category);
        if (_document is null) return;
        var hasImported = _unseenImportedNewEntryKeysByCategory.Count > 0;
        var hasStored = _pendingNewItemStore.Configs.TryGetValue(_document.Path, out var stored) && stored.Count > 0;
        if (!hasImported && !hasStored) return;

        var visibleKeys = new HashSet<string>(StringComparer.Ordinal);
        var hasBucketItems = false;
        // Linked cells can display an entry in a different category from its source.
        // Keep the original pending identity; admission decides its current displayed owner.
        void Admit(string key)
        {
            if (_unseenImportedNewEntryKeysByCategory.Values.Any(keys => keys.Contains(key))) visibleKeys.Add(key);
        }
        foreach (var item in items)
        {
            Admit(item.Key);
            if (hasImported)
            {
                foreach (var entry in item.Entries)
                {
                    if (item.IsGroup && !IsTableRowVisible(entry)) continue;
                    Admit(entry.DisplayKey);
                    if (item.Linked is not null)
                        foreach (var cell in item.Linked.Rows[entry])
                            if (cell?.Entry is { } target && IsLinkedTargetVisible(target)) Admit(target.DisplayKey);
                }
            }
            if (!hasBucketItems && _pendingNewItemSession is not null &&
                item.StringListTable is { } table && IsCommentWhenVisiblePolicy(table) &&
                stored?.TryGetValue(table.Key, out var values) == true)
            {
                var managed = _document.GetManagedStringListValues(table);
                hasBucketItems = values.Any(value => managed?.Contains(value) != true && _pendingNewItemSession.IsPending(table.Key, value));
            }
        }
        if (visibleKeys.Count > 0 || hasBucketItems)
            _newCategoryVisibility[category] = new(visibleKeys, hasBucketItems);
    }

    private void AcknowledgeDisplayedImportedNewItems()
    {
        foreach (var visible in _newCategoryVisibility.Values) visible.EntryKeys.ExceptWith(_activeImportedNewEntryKeys);
        foreach (var category in _unseenImportedNewEntryKeysByCategory.Keys.ToArray())
        {
            var pending = _unseenImportedNewEntryKeysByCategory[category];
            pending.ExceptWith(_activeImportedNewEntryKeys);
            if (pending.Count == 0) _unseenImportedNewEntryKeysByCategory.Remove(category);
        }
    }
}
