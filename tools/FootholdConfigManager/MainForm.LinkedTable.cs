using System.Globalization;
using System.Windows.Forms;
namespace FootholdConfigManager;
internal sealed partial class MainForm
{
    // Owned by the cached category editor. Source entries are resolved once, never from a cell event.
    private sealed class LinkedTableData
    {
        public required List<ConfigTupleField> Fields { get; init; }
        public required List<ConfigEntry> Entries { get; init; }
        public required Dictionary<ConfigEntry, LinkedCellTarget?[]> Rows { get; init; }
        public required Dictionary<ConfigEntry, List<ConfigEntry>> Owners { get; init; }
        public required HashSet<string> SourceKeys { get; init; }
    }

    // -1 selects the whole entry; null in Rows means no available target.
    private sealed record LinkedCellTarget(ConfigEntry Entry, int MemberIndex);

    private ConfigDocument? _linkedDataDocument;
    private Dictionary<string, LinkedTableData>? _linkedDataByKey;

    private int _linkedStructureVersion;
    private void InvalidateLinkedTableData() { _linkedDataByKey = null; _linkedStructureVersion++; }

    private LinkedTableData? GetLinkedTableData(string key)
    {
        EnsureLinkedTableData();
        return _linkedDataByKey!.GetValueOrDefault(key);
    }

    private void EnsureLinkedTableData()
    {
        if (_linkedDataByKey is not null && ReferenceEquals(_linkedDataDocument, _document)) return;
        _linkedDataDocument = _document;
        _linkedDataByKey = new(StringComparer.Ordinal);
        if (_document is null) return;
        var primaryGroups = _document.Entries.Where(entry => string.Equals(entry.ParentGuiEditor, "linkedTable", StringComparison.OrdinalIgnoreCase))
            .GroupBy(entry => entry.ParentKey).ToList();
        if (primaryGroups.Count == 0) return;
        var fieldsByParent = primaryGroups.ToDictionary(group => group.Key,
            group => ConfigDocument.ReadGuiFieldTableFields(group.First().ParentGuiFields, linked: true), StringComparer.Ordinal);
        var neededParents = fieldsByParent.SelectMany(pair => pair.Value.Select(field => field.Key == "self" || field.Key!.StartsWith("self.", StringComparison.Ordinal) ? pair.Key : field.Key!))
            .ToHashSet(StringComparer.Ordinal);
        var byParent = _document.Entries.Where(entry => neededParents.Contains(entry.ParentKey))
            .GroupBy(entry => entry.ParentKey).ToDictionary(group => group.Key,
                group => group.GroupBy(entry => entry.Key).ToDictionary(sameKey => sameKey.Key, sameKey => sameKey.Last(), StringComparer.Ordinal), StringComparer.Ordinal);
        var sharedOwners = new Dictionary<ConfigEntry, List<ConfigEntry>>();
        foreach (var group in byParent)
        {
            var first = group.Value.Values.First();
            if (!string.Equals(first.ParentGuiEditor, "linkedTable", StringComparison.OrdinalIgnoreCase)) continue;
            var fields = fieldsByParent[group.Key];
            if (fields.Count == 0) continue;
            var memberFields = fields.Where(field => field.Key!.StartsWith("self.", StringComparison.Ordinal)).ToList();
            if (memberFields.Count > 0 && group.Value.Values.Any(entry =>
                !entry.ValueText.TrimStart().StartsWith("{", StringComparison.Ordinal) ||
                memberFields.Any(field => !entry.TupleFields.Any(member => member.Key == field.Key![5..])))) continue;
            var rows = new Dictionary<ConfigEntry, LinkedCellTarget?[]>();
            var owners = new Dictionary<ConfigEntry, List<ConfigEntry>>();
            var entries = group.Value.Values.ToList();
            foreach (var primary in entries)
            {
                var aliases = new Dictionary<string, string>(StringComparer.Ordinal);
                foreach (var part in (primary.GuiLinkedKeys ?? "").Split(';', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
                {
                    var pieces = part.Split(':', 2, StringSplitOptions.TrimEntries);
                    if (pieces.Length == 2) aliases[pieces[0]] = pieces[1];
                }
                var targets = new LinkedCellTarget?[fields.Count];
                for (var i = 0; i < fields.Count; i++)
                {
                    var member = fields[i].Key!.StartsWith("self.", StringComparison.Ordinal);
                    var parent = fields[i].Key == "self" || member ? group.Key : fields[i].Key!;
                    var targetKey = aliases.GetValueOrDefault(parent, primary.Key);
                    if (fields[i].Key == "self" || member)
                        targets[i] = new LinkedCellTarget(primary, member ? primary.TupleFields.FindIndex(field => field.Key == fields[i].Key![5..]) : -1);
                    else if (byParent.TryGetValue(parent, out var source) && source.GetValueOrDefault(targetKey) is { } external)
                        targets[i] = new LinkedCellTarget(external, -1);
                    if (targets[i]?.Entry is { } target)
                    {
                        if (!sharedOwners.TryGetValue(target, out var allAffected)) sharedOwners[target] = allAffected = new();
                        owners[target] = allAffected;
                        if (!allAffected.Contains(primary)) allAffected.Add(primary);
                    }
                }
                rows[primary] = targets;
            }
            _linkedDataByKey[group.Key] = new LinkedTableData { Entries = entries, Fields = fields, Rows = rows, Owners = owners,
                SourceKeys = fields.Select(field => field.Key == "self" || field.Key!.StartsWith("self.", StringComparison.Ordinal)
                    ? group.Key : field.Key!).ToHashSet(StringComparer.Ordinal) };
        }
    }

    private static void BuildLinkedTableColumns(DataGridView grid, LinkedTableData linked)
    {
        grid.Columns.Add("name", "Item"); grid.Columns["name"].ReadOnly = true;
        ConfigureFillColumn(grid.Columns["name"], 260);
        for (var i = 0; i < linked.Fields.Count; i++)
        {
            var field = linked.Fields[i];
            if (field.Kind == ConfigTupleFieldKind.Boolean)
                grid.Columns.Add(new DataGridViewCheckBoxColumn { Name = "linked" + i, HeaderText = field.Name });
            else grid.Columns.Add("linked" + i, field.Name);
            ConfigureFixedColumn(grid.Columns["linked" + i], field.Kind == ConfigTupleFieldKind.Boolean ? 85 : 95);
            if (field.Kind == ConfigTupleFieldKind.Number) grid.Columns["linked" + i].DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleLeft;
            grid.Columns["linked" + i].ToolTipText = linked.Rows.Values.Select(targets => targets[i]?.Entry.ParentDescription).FirstOrDefault(description => !string.IsNullOrWhiteSpace(description)) ?? "";
        }
    }

    private void ConfigureLinkedTableHelp(TableEditorBinding binding)
    {
        var note = new Label { AutoSize = true, ForeColor = HelpTextColor, Margin = new Padding(0, 4, 0, 0) };
        binding.SharedNote = note;
        binding.Header.Controls.Add(note);
        ConfigureHelpSizing((TableLayoutPanel)binding.Grid.Parent!, note);
        binding.Grid.CurrentCellChanged += (_, _) => UpdateLinkedSharedNote(binding);
    }

    private void UpdateLinkedSharedNote(TableEditorBinding binding)
    {
        var note = binding.SharedNote;
        if (note is null) return;
        if (binding.Linked is null) { note.Text = ""; note.Visible = false; return; }
        var cell = binding.Grid.CurrentCell;
        var owner = cell?.Tag as ConfigEntry;
        if (owner is not null && binding.Linked.Owners.TryGetValue(owner, out var affected) && affected.Count > 1)
        {
            note.Text = "Shared " + binding.Grid.Columns[cell!.ColumnIndex].HeaderText + ": " + GetTableRowDisplayName(owner) + " (" + affected.Count + " items).";
            _toolTip.SetToolTip(note, owner.DisplayKey + Environment.NewLine + "Affects: " + string.Join(", ", affected.Select(entry => GetTableRowDisplayName(entry) + " [" + entry.DisplayKey + "]")) + ".");
        }
        else { note.Text = ""; _toolTip.SetToolTip(note, ""); }
        note.Visible = note.Text.Length > 0;
    }

    private bool IsLinkedTargetVisible(ConfigEntry target) => IsTableRowVisible(target) &&
        (string.IsNullOrWhiteSpace(target.ParentGuiVisibleWhen) || VisibleWhenMatches(target.ParentGuiVisibleWhen));

    private bool CanEditLinkedCell(TableEditorBinding binding, DataGridViewCell? cell, out string reason)
    {
        reason = "";
        if (cell is null || cell.ColumnIndex <= 0 || cell.OwningRow.Tag is not ConfigEntry primary ||
            cell.Tag is not ConfigEntry target || binding.Grid.ReadOnly || !IsTableRowVisible(primary) ||
            ShouldLockEntryEditor(primary, out reason)) return false;
        if (ReferenceEquals(primary, target)) return !ShouldLockTableEditor(target.ParentKey, out reason);
        return IsLinkedTargetVisible(target) && !ShouldLockTableEditor(target.ParentKey, out reason) &&
            !ShouldLockEntryEditor(target, out reason);
    }

    private sealed record LinkedEntryPolicy(bool Visible, bool Locked, string Reason);
    private sealed record LinkedDisplayPolicy(
        Dictionary<string, (bool Locked, string Reason)> Tables,
        Dictionary<ConfigEntry, LinkedEntryPolicy> Entries,
        Dictionary<ConfigEntry, List<string>> Members);

    private LinkedDisplayPolicy ReadLinkedDisplayPolicy(TableEditorBinding binding, string? primaryLockReason = null)
    {
        var tables = new Dictionary<string, (bool Locked, string Reason)>(StringComparer.Ordinal);
        foreach (var parent in binding.Linked!.SourceKeys)
        {
            if (parent == binding.Key) tables[parent] = (binding.Grid.ReadOnly, primaryLockReason ?? binding.DisplayedHelpText ?? "");
            else tables[parent] = (ShouldLockTableEditor(parent, out var reason), reason);
        }
        var entries = new Dictionary<ConfigEntry, LinkedEntryPolicy>();
        var members = new Dictionary<ConfigEntry, List<string>>();
        var hasMembers = binding.Linked.Fields.Any(field => field.Key!.StartsWith("self.", StringComparison.Ordinal));
        foreach (var entry in binding.Linked.Rows.Keys.Concat(binding.Linked.Owners.Keys).Distinct())
        {
            var visible = IsLinkedTargetVisible(entry);
            var locked = ShouldLockEntryEditor(entry, out var reason);
            entries[entry] = new LinkedEntryPolicy(visible, locked, reason);
            if (hasMembers && binding.Linked.Rows.ContainsKey(entry)) members[entry] = entry.GetTupleValues();
        }
        return new LinkedDisplayPolicy(tables, entries, members);
    }

    private void AddLinkedTableRow(TableEditorBinding binding, ConfigEntry primary, LinkedDisplayPolicy policy)
    {
        var index = binding.Grid.Rows.Add();
        UpdateLinkedTableRow(binding, binding.Grid.Rows[index], primary, policy);
    }

    private void UpdateLinkedTableRow(TableEditorBinding binding, DataGridViewRow row, ConfigEntry primary, LinkedDisplayPolicy? policy = null)
    {
        row.Tag = primary;
        row.Cells["name"].Value = GetTableRowDisplayName(primary);
        row.DefaultCellStyle.BackColor = IsImportedNewEntryHighlighted(primary) ? GetNewHighlightBackColor() : IsDarkPalette() ? EditorBackground : System.Drawing.Color.Empty;
        var targets = binding.Linked!.Rows[primary];
        for (var i = 0; i < targets.Length; i++) row.Cells[i + 1].Tag = targets[i]?.Entry;
        ApplyLinkedRowPolicy(binding, row, primary, policy, targets);
    }

    private void ApplyLinkedRowPolicy(TableEditorBinding binding, DataGridViewRow row, ConfigEntry primary, LinkedDisplayPolicy? knownPolicy = null,
        LinkedCellTarget?[]? knownTargets = null)
    {
        var policy = knownPolicy ?? ReadLinkedDisplayPolicy(binding);
        var targets = knownTargets ?? binding.Linked!.Rows[primary];
        var primaryState = policy.Entries[primary];
        var primaryLocked = primaryState.Locked;
        var primaryReason = primaryState.Reason;
        var primaryVisible = primaryState.Visible;
        RefreshControlValue(() =>
        {
            if (row.ReadOnly != primaryLocked) row.ReadOnly = primaryLocked;
            row.DefaultCellStyle.ForeColor = primaryLocked ? HelpTextColor : PrimaryTextColor;
            row.Cells[0].ToolTipText = primaryLocked ? primaryReason : primary.Key;
            for (var i = 0; i < binding.Linked!.Fields.Count; i++)
            {
                var cell = row.Cells[i + 1];
                var resolved = targets[i];
                var target = resolved?.Entry;
                var targetState = target is null ? null : policy.Entries[target];
                var visible = targetState?.Visible == true;
                var targetLocked = targetState?.Locked == true;
                var tableState = target is null ? (Locked: false, Reason: "") : policy.Tables[target.ParentKey];
                var editable = visible && primaryVisible && !primaryLocked && !targetLocked && !tableState.Locked && !binding.Grid.ReadOnly;
                var reason = primaryLocked ? primaryReason : targetLocked ? targetState!.Reason : tableState.Reason;
                if (!editable && ReferenceEquals(binding.Grid.CurrentCell, cell)) binding.Grid.CancelEdit();
                if (cell.ReadOnly == editable) cell.ReadOnly = !editable;
                cell.Style.ForeColor = editable ? PrimaryTextColor : HelpTextColor;
                cell.ToolTipText = target is null ? "No editable Config entry; controlled by mission." :
                    !visible ? "Unavailable under current Config conditions." :
                    !editable ? reason : target.DisplayKey;
                var value = !visible ? "—" : resolved!.MemberIndex < 0 ? target!.ValueText : policy.Members[target!][resolved.MemberIndex];
                if (binding.Linked.Fields[i].Kind == ConfigTupleFieldKind.Boolean)
                    SetTableCellValue(cell, visible && value.Equals("true", StringComparison.OrdinalIgnoreCase) &&
                        (!targetLocked || !string.Equals(target!.GuiDisabledValue, "false", StringComparison.OrdinalIgnoreCase)));
                else SetTableCellValue(cell, value);
                if (target is not null && binding.Linked.Owners[target].Count > 1)
                    cell.ToolTipText += Environment.NewLine + "Shared setting; affects " + string.Join(", ", binding.Linked.Owners[target].Select(entry => GetTableRowDisplayName(entry) + " [" + entry.DisplayKey + "]")) + ".";
            }
        });
        if (ReferenceEquals(binding.Grid.CurrentRow, row))
            binding.RemoveButton.Enabled = !binding.Grid.ReadOnly && !primaryLocked;
    }

    private void ApplyLinkedCellEdit(TableEditorBinding binding, DataGridViewRow row, int columnIndex)
    {
        if (columnIndex <= 0 || row.Tag is not ConfigEntry primary) return;
        var cell = row.Cells[columnIndex];
        if (!CanEditLinkedCell(binding, cell, out _) || cell.Tag is not ConfigEntry target)
        {
            ApplyLinkedRowPolicy(binding, row, primary); return;
        }
        var field = binding.Linked!.Fields[columnIndex - 1];
        var resolved = binding.Linked.Rows[primary][columnIndex - 1]!;
        var value = field.Kind == ConfigTupleFieldKind.Boolean ? cell.Value is true ? "true" : "false" : cell.Value?.ToString()?.Trim() ?? "";
        if (field.Kind == ConfigTupleFieldKind.Number && field.DefaultValue is not null && resolved.MemberIndex >= 0)
            value = NormalizeNumberCell(value, field.DefaultValue);
        else if (field.Kind == ConfigTupleFieldKind.Number && NormalizeNumberCell(value, "") == "")
        {
            ApplyLinkedRowPolicy(binding, row, primary); return;
        }
        var previous = target.ValueText;
        if (resolved.MemberIndex >= 0)
        {
            var values = target.GetTupleValues();
            if (values[resolved.MemberIndex] == value) return;
            values[resolved.MemberIndex] = value;
            target.SetTupleValues(values);
            value = target.ValueText;
        }
        else
        {
            if (previous == value) return;
            target.ValueText = value;
        }
        SetEntryValueUndoAction(target, "edit " + target.DisplayName, previous, value,
            () => RefreshVisibleTableRows(new[] { target }));
        using var optionsTransition = BeginOptionsTransition(target.DisplayName);
        RefreshVisibleTableRows(new[] { target });
        RefreshDependentEditors(target);
        SetChangedStatus();
        if (!RefreshVisibleWhenTargets(target)) RefreshConfigSearchResultsIfOpen();
    }
    private List<DesignerItem> CombineLinkedDesignerItems(List<DesignerItem> items)
    {
        EnsureLinkedTableData();
        var represented = GetRepresentedLinkedEntries();
        foreach (var item in items.Where(item => item.IsGroup))
        {
            item.Linked = _linkedDataByKey!.GetValueOrDefault(item.Key);
            if (item.Linked is null) item.Entries.RemoveAll(represented.Contains);
        }
        return items.Where(item => !item.IsGroup || item.StageTable is not null || item.Entries.Count > 0).ToList();
    }

    private HashSet<ConfigEntry> GetRepresentedLinkedEntries()
    {
        var represented = new HashSet<ConfigEntry>();
        var advanced = ShouldIncludeAdvancedEntries();
        foreach (var linked in _linkedDataByKey!.Values)
        {
            var first = linked.Entries.FirstOrDefault(entry => (_testingUnlocked || !entry.GuiTesting) && (advanced || !entry.IsAdvanced));
            if (first is null || IsCategoryHidden(first.EffectiveCategory) ||
                !string.IsNullOrWhiteSpace(first.ParentGuiVisibleWhen) && !VisibleWhenMatches(first.ParentGuiVisibleWhen)) continue;
            foreach (var primary in linked.Rows.Where(pair => (_testingUnlocked || !pair.Key.GuiTesting) && (advanced || !pair.Key.IsAdvanced)))
                represented.UnionWith(primary.Value.OfType<LinkedCellTarget>().Select(target => target.Entry));
        }
        return represented;
    }

    private List<ConfigEntry> FilterLinkedSecondaryEntries(string key, List<ConfigEntry> entries)
    {
        EnsureLinkedTableData();
        if (_linkedDataByKey!.ContainsKey(key) || _linkedDataByKey.Count == 0) return entries;
        var represented = GetRepresentedLinkedEntries();
        return entries.Where(entry => !represented.Contains(entry)).ToList();
    }

    private string GetLinkedSearchDescription(DesignerItem item, ConfigEntry entry)
    {
        var description = GetConfigSearchEntryDescription(entry);
        if (item.Linked is null) return description;
        return description + " " + string.Join(" ", item.Linked.Rows[entry]
            .OfType<LinkedCellTarget>().Select(target => target.Entry).Distinct()
            .Where(IsLinkedTargetVisible)
            .Select(target => target.DisplayKey + " " + target.ValueText));
    }

    private bool RefreshLinkedTableStructure(bool linkedStructure, string parentKey)
    {
        if (!linkedStructure && !_categoryPanelCache.Values.Distinct()
            .SelectMany(EnumerateChildControls<TableLayoutPanel>).Select(panel => panel.Tag)
            .OfType<TableEditorBinding>().Any(binding => binding.Linked?.SourceKeys.Contains(parentKey) == true)) return false;
        // Structural changes can expose orphan source entries in other categories.
        MarkAllCategoryPanelsDirty();
        ReloadCategoriesPreservingSelection(refreshSelectedCategory: true);
        return true;
    }

}
