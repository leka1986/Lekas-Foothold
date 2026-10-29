using System.Globalization;

namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    // Provenance of automatic edits. Review state remains in the existing options baseline.
    private sealed record AutomaticAircraftChange(ConfigStringListTable Table, string Value, bool WasCommented, string Reason)
    {
        public bool Saved { get; set; }
    }
    private sealed record RequiredAircraftUpdate(List<string> TargetKeys, RequiredValueSources? Sources,
        Dictionary<ConfigStringListTable, RequiredValueResolution> Facts, List<AutomaticAircraftChange> Changes);
    private readonly Dictionary<(string Table, string Value), AutomaticAircraftChange> _automaticAircraftChanges = new();

    private RequiredAircraftUpdate ActivateRequiredAircraft(ConfigEntry? source)
    {
        EnsureOptionsBaseline();
        var document = _document!;
        RequiredValueSources? sources = null;
        RequiredValueSources GetSources() => sources ??= new RequiredValueSources(document.Entries);
        var targetKeys = source is null
            ? document.StringListTables.Where(table => table.RequiredValueRules.Count > 0).Select(table => table.Key).ToList()
            : GetDependentEditorTargetKeysCore(source, GetSources);
        var keys = targetKeys.ToHashSet(StringComparer.Ordinal);
        var factsByTable = new Dictionary<ConfigStringListTable, RequiredValueResolution>();
        var changes = new List<AutomaticAircraftChange>();
        foreach (var table in document.StringListTables)
        {
            if (!keys.Contains(table.Key) || table.RequiredValueRules.Count == 0) continue;
            var facts = document.ResolveRequiredValues(table, GetSources());
            factsByTable[table] = facts;
            if (facts.Errors.Count > 0 || !string.IsNullOrWhiteSpace(table.GuiVisibleWhen) && !VisibleWhenMatches(table.GuiVisibleWhen)) continue;
            var managed = document.GetManagedStringListValues(table);
            var active = table.Items.Select(item => item.Value).ToHashSet(StringComparer.Ordinal);
            IReadOnlyList<string>? order = null;
            foreach (var value in facts.Values.Keys)
            {
                if (managed?.Contains(value) == true || !active.Add(value)) continue;
                var commented = table.CommentedItems.Any(item => item.Value == value);
                order ??= _stringListCatalog.GetValues(document, table.Key);
                document.ActivateStringListValue(table, value, order);
                var reason = string.Join("; ", facts.ReasonsFor(value).Select(item => item.Text).Distinct(StringComparer.Ordinal));
                var change = new AutomaticAircraftChange(table, value, commented, reason);
                _automaticAircraftChanges[(table.Key, value)] = change;
                changes.Add(change);
            }
        }
        return new(targetKeys, sources, factsByTable, changes);
    }

    private void GroupAutomaticAircraftUndo(RequiredAircraftUpdate update, ConfigEntry? source, string? oldValue,
        UndoStep? sourceUndo, int afterSourceCount)
    {
        if (update.Changes.Count == 0 && _undoStack.Count <= afterSourceCount) return;
        var steps = new List<UndoStep>();
        while (_undoStack.Count > afterSourceCount) steps.Add(_undoStack.Pop());
        if (sourceUndo is not null)
        {
            if (!ReferenceEquals(_undoStack.Peek(), sourceUndo)) throw new InvalidOperationException("The source edit's Undo step changed during automatic aircraft activation.");
            steps.Add(_undoStack.Pop());
        }
        var document = _document!;
        var changes = update.Changes;
        SetUndoAction(source is null ? "activate required aircraft" : "edit " + source.DisplayName + " and required aircraft", () =>
        {
            foreach (var step in steps) step.Action();
            if (source is not null && sourceUndo is null) source.ValueText = oldValue!;
            var sources = new RequiredValueSources(document.Entries);
            foreach (var tableChanges in changes.GroupBy(change => change.Table))
            {
                var facts = document.ResolveRequiredValues(tableChanges.Key, sources);
                foreach (var change in tableChanges)
                {
                    // A later, still-enabled source can continue to require this aircraft.
                    if (facts.IsRequired(change.Value)) continue;
                    if (FindActiveStringListItem(change.Table, change.Value) is { } active)
                    {
                        if (change.WasCommented) document.DeactivateStringListItem(change.Table, active, facts);
                        else document.RemoveStringListItem(change.Table, active, facts);
                    }
                    if (_automaticAircraftChanges.TryGetValue((change.Table.Key, change.Value), out var current) && ReferenceEquals(current, change))
                        _automaticAircraftChanges.Remove((change.Table.Key, change.Value));
                }
            }
        }, () =>
        {
            foreach (var step in steps) step.RefreshAction?.Invoke();
            using var transition = BeginOptionsTransition("Undo automatic aircraft activation");
            var keys = changes.Select(change => change.Table.Key).Distinct(StringComparer.Ordinal).ToList();
            RefreshDependentEditorEntries(Array.Empty<ConfigEntry>(), new(keys, null, new(), changes));
        }, source is not null ? null : () =>
        {
            var sources = new RequiredValueSources(document.Entries);
            foreach (var tableChanges in changes.GroupBy(change => change.Table))
            {
                var facts = document.ResolveRequiredValues(tableChanges.Key, sources);
                foreach (var change in tableChanges)
                    if (facts.IsRequired(change.Value)) return facts.RemovalMessage(change.Value);
            }
            return null;
        });
    }

    private Dictionary<string, AutomaticAircraftChange>? ReadAutomaticAircraftValues(ConfigStringListTable? table)
    {
        if (table is null || _automaticAircraftChanges.Count == 0) return null;
        Dictionary<string, AutomaticAircraftChange>? result = null;
        foreach (var item in table.Items)
            if (_automaticAircraftChanges.TryGetValue((table.Key, item.Value), out var change) && ReferenceEquals(change.Table, table))
                (result ??= new(StringComparer.Ordinal))[item.Value] = change;
        return result;
    }

    private IReadOnlyDictionary<string, AutomaticAircraftChange>? AutomaticAircraftHighlights(ConfigStringListTable table) =>
        _optionsPending.GetValueOrDefault(table.Section)?.FirstOrDefault(notice => notice.Block.Key == table.Key)?.Aircraft;

    private List<AutomaticAircraftChange> UnreviewedAutomaticAircraft() => _optionsPending
        .Where(pair => !string.Equals(pair.Key, _optionsViewedCategory, StringComparison.OrdinalIgnoreCase))
        .SelectMany(pair => pair.Value).Where(notice => notice.Aircraft is not null)
        .SelectMany(notice => notice.Aircraft!.Values).Where(change => !change.Saved).Distinct().ToList();

    private bool ConfirmAutomaticAircraftSave(out List<AutomaticAircraftChange> confirmed)
    {
        confirmed = UnreviewedAutomaticAircraft();
        if (confirmed.Count == 0) return true;
        using var dialog = new Form
        {
            Text = "Review automatic aircraft changes", StartPosition = FormStartPosition.CenterParent,
            ShowInTaskbar = false, MinimizeBox = false, MaximizeBox = false,
            Size = new Size(Zoomed(670), Zoomed(360)), MinimumSize = new Size(Zoomed(520), Zoomed(300)),
            BackColor = MainBackground, ForeColor = PrimaryTextColor, Font = Font
        };
        var layout = new TableLayoutPanel { Dock = DockStyle.Fill, ColumnCount = 1, RowCount = 3, Padding = new Padding(Zoomed(18)) };
        layout.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        layout.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        layout.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        var title = new Label { AutoSize = true, Text = "Saving includes " + confirmed.Count.ToString(CultureInfo.InvariantCulture) + " automatic aircraft change" + (confirmed.Count == 1 ? "" : "s"), Margin = new Padding(0, 0, 0, Zoomed(14)) };
        var details = new ListView { Dock = DockStyle.Fill, View = View.Details, FullRowSelect = true,
            BackColor = EditorBackground, ForeColor = PrimaryTextColor, HeaderStyle = ColumnHeaderStyle.Nonclickable };
        details.Columns.Add("Aircraft", Zoomed(180)); details.Columns.Add("Activated in", Zoomed(160)); details.Columns.Add("Required by AI", Zoomed(230));
        foreach (var change in confirmed)
            details.Items.Add(new ListViewItem(new[] { change.Value, change.Table.GuiLabel ?? change.Table.Key, change.Reason }));
        var actions = new FlowLayoutPanel { AutoSize = true, Dock = DockStyle.Fill, FlowDirection = FlowDirection.RightToLeft, WrapContents = false, Padding = new Padding(0, Zoomed(14), 0, 0) };
        Button Action(string text, DialogResult result)
        {
            var button = new Button { Text = text, AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink,
                Padding = new Padding(Zoomed(10), Zoomed(5), Zoomed(10), Zoomed(5)), DialogResult = result,
                BackColor = ButtonBackground, ForeColor = PrimaryTextColor, FlatStyle = FlatStyle.Flat, Margin = new Padding(Zoomed(7), 0, 0, 0) };
            button.FlatAppearance.BorderColor = BorderColor;return button;
        }
        var cancel = Action("Cancel", DialogResult.Cancel);
        var save = Action("Save these changes", DialogResult.Yes);
        var review = Action("Review aircraft", DialogResult.Retry);
        actions.Controls.AddRange(new Control[] { cancel, save, review });
        layout.Controls.Add(title, 0, 0); layout.Controls.Add(details, 0, 1); layout.Controls.Add(actions, 0, 2);
        dialog.Controls.Add(layout); dialog.AcceptButton = save; dialog.CancelButton = cancel;
        var result = dialog.ShowDialog(this);
        if (result == DialogResult.Retry)
        {
            var first = confirmed[0];
            JumpToConfigSearchResult(new ConfigSearchResult(first.Table.Key, null, first.Value, first.Table.Section, GetCategoryDisplayName(first.Table.Section), "", 0, 0));
            foreach (var grid in EnumerateChildControls<DataGridView>(_formHost))
                if (grid.Parent?.Tag is StringListRequirementBinding binding && ReferenceEquals(binding.Table, first.Table))
                { SelectBucketRowByValue(binding.Active, first.Value);break; }
        }
        return result == DialogResult.Yes;
    }
}
