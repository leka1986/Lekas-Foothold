using System.Drawing;
using System.Windows.Forms;

namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    // The normal render and condition reconciliation share editor construction.
    private void AddCategoryItemEditor(TableLayoutPanel panel, string categoryName, DesignerItem item)
    {
        if (item.StringListTable is not null)
        {
            panel.Controls.Add(RegisterOptionsTarget(panel, BuildStringListEditor(item.StringListTable), item.Key));
            return;
        }

        if (item.StageTable is not null)
        {
            panel.Controls.Add(RegisterOptionsTarget(panel, BuildStageTableEditor(item.StageTable), item.Key));
            return;
        }

        if (item.IsGroup)
        {
            var editor = MarkConfigSearchTarget(item.Key.Equals("CallsignOverrides", StringComparison.Ordinal)
                ? BuildCallsignOverridesEditor(item.Key, item.Entries)
                : BuildLinkedOrStandardTableEditor(item.Key, item.Entries, item.Linked), item.Key);
            if (categoryName.Equals("Mission Rules", StringComparison.OrdinalIgnoreCase))
                PrepareTemplateEditor(editor, item);
            panel.Controls.Add(RegisterOptionsTarget(panel, editor, item.Key));
            if (item.Linked is not null)
            {
                void KeepLinkedTableReachable()
                {
                    var width = editor.MinimumSize.Width + editor.Margin.Horizontal + panel.Padding.Horizontal;
                    if (panel.MinimumSize.Width < width) panel.MinimumSize = new Size(width, panel.MinimumSize.Height);
                    if (ReferenceEquals(panel.Parent, _formHost)) _formHost.AutoScrollMinSize = new Size(panel.MinimumSize.Width, 0);
                }
                editor.SizeChanged += (_, _) => KeepLinkedTableReachable();
                KeepLinkedTableReachable();
            }
            return;
        }

        var entry = item.Entries.FirstOrDefault();
        if (entry is not null)
        {
            panel.Controls.Add(RegisterOptionsTarget(panel, BuildEntryEditor(entry), item.Key, entry));
        }
    }

    private bool TryRefreshConditionCategory(string categoryName, IReadOnlySet<string> targetKeys)
    {
        if (!_categoryPanelCache.TryGetValue(categoryName, out var cached)) return true;
        // Global/theme/designer invalidations retain their original rebuild contract.
        if (_dirtyCategoryPanels.Contains(categoryName) || cached is not TableLayoutPanel panel ||
            categoryName.Equals("Difficulty Stages", StringComparison.OrdinalIgnoreCase)) return false;
        var items = GetDesignerItems(categoryName, includeTableRows: false);
        var targets = panel.Tag as Dictionary<string, OptionsMarkerTarget>;
        if (targets is null && panel.Controls.Count != 1) return false;
        if (items.Any(item => item.IsGroup && item.StageTable is null &&
            targets?.TryGetValue(item.Key, out var target) == true && target.Editor.Tag is not TableEditorBinding)) return false;

        var activeKeys = _activeImportedNewEntryKeys.ToArray();
        var activeCategory = _activeImportedNewCategoryName;
        var wasLoading = _loadingForm;
        var isDisplayed = ReferenceEquals(panel.Parent, _formHost);
        var scroll = _formHost.AutoScrollPosition;
        var membershipChanged = false;
        RefreshNewCategoryVisibility(categoryName, items);
        _activeImportedNewEntryKeys.Clear();
        if (string.Equals(activeCategory, categoryName, StringComparison.OrdinalIgnoreCase)) _activeImportedNewEntryKeys.UnionWith(activeKeys);
        if (_newCategoryVisibility.TryGetValue(categoryName, out var visible)) _activeImportedNewEntryKeys.UnionWith(visible.EntryKeys);
        _activeImportedNewCategoryName = HasUnseenImportedNewEntries(categoryName) ? categoryName : null;
        _loadingForm = true;
        panel.SuspendLayout();
        try
        {
            var keys = items.Select(item => item.Key).ToHashSet(StringComparer.Ordinal);
            if (targets is not null)
                foreach (var key in targets.Keys.Where(key => !keys.Contains(key)).ToArray())
                {
                    membershipChanged = true;
                    var obsolete = targets[key].Editor;
                    targets.Remove(key);
                    panel.Controls.Remove(obsolete);
                    ControlTreeDisposer.Dispose(obsolete, _toolTip);
                }

            for (var index = 0; index < items.Count; index++)
            {
                var item = items[index];
                if (targets?.TryGetValue(item.Key, out var target) != true)
                {
                    membershipChanged = true;
                    AddCategoryItemEditor(panel, categoryName, item);
                    targets = (Dictionary<string, OptionsMarkerTarget>)panel.Tag!;
                    target = targets[item.Key];
                    ApplyThemeToControl(target.Editor, restyleButtons: false, configOwner: this);
                    WireBackgroundDehighlightHandlers(target.Editor);
                }
                else if (target!.Editor.Tag is TableEditorBinding table &&
                    (table.Entries is null || !table.Entries.SequenceEqual(item.Entries) ||
                     targetKeys.Contains(item.Key) || item.Linked?.SourceKeys.Overlaps(targetKeys) == true))
                {
                    table.Linked = item.Linked;
                    // Add/Remove actions capture this owned view list when the editor is built.
                    var entries = table.Entries!;
                    if (!entries.SequenceEqual(item.Entries))
                    {
                        entries.Clear();
                        entries.AddRange(item.Entries);
                    }
                    // Refresh choices/lock facts first; row sync reuses those final model facts.
                    ApplyTableEditorLockState(table);
                    RefreshTableGrid(table.Grid, entries);
                }
                panel.SetRow(target.Editor, index + 1);
                panel.Controls.SetChildIndex(target.Editor, index + 1);
            }
            panel.RowCount = items.Count + 1;
            if (membershipChanged)
            {
                var width = targets?.Values.Where(target => target.Editor.Tag is TableEditorBinding { Linked: not null })
                    .Select(target => target.Editor.MinimumSize.Width + target.Editor.Margin.Horizontal + panel.Padding.Horizontal)
                    .DefaultIfEmpty(0).Max() ?? 0;
                panel.MinimumSize = new Size(width, panel.MinimumSize.Height);
                if (isDisplayed) _formHost.AutoScrollMinSize = new Size(width, 0);
            }
            if (HasUnseenImportedNewEntries(categoryName)) _preparedUnviewedCategories.Add(categoryName);
            ApplyOptionsMarkers(new[] { categoryName });
        }
        catch
        {
            // A partially reconciled view must never be advertised as reusable.
            MarkCategoryPanelDirty(categoryName);
            return false;
        }
        finally
        {
            _loadingForm = wasLoading;
            _activeImportedNewEntryKeys.Clear();
            _activeImportedNewEntryKeys.UnionWith(activeKeys);
            _activeImportedNewCategoryName = activeCategory;
            panel.ResumeLayout(performLayout: isDisplayed);
            if (isDisplayed) _formHost.AutoScrollPosition = new Point(-scroll.X, -scroll.Y);
        }
        return true;
    }
}
