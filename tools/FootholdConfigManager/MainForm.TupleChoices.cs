namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private TupleChoiceSnapshot? GetTupleChoiceSnapshot(string key, RequiredValueSources? sources = null)
    {
        if (!_document!.HasTupleChoices(key)) return null;
        if (_optionsTupleChoices?.TryGetValue(key, out var known) == true) return known;
        var snapshot = _document!.ResolveTupleChoices(key, sources);
        if (_optionsTupleChoices is not null) _optionsTupleChoices[key] = snapshot;
        return snapshot;
    }

    private void RefreshTupleChoiceColumns(TableEditorBinding binding, RequiredValueSources? sources = null, TupleChoiceSnapshot? prepared = null)
    {
        var snapshot = prepared ?? GetTupleChoiceSnapshot(binding.Key, sources);
        binding.TupleChoices = snapshot;
        if (snapshot is null) return;
        foreach (var entry in binding.Entries!) _document!.ConfigureTupleChoiceFields(entry, snapshot);
        foreach (var state in snapshot.Fields.Values)
        {
            if (binding.Grid.Columns["field" + state.Spec.Index] is not DataGridViewComboBoxColumn column) continue;
            column.Visible = state.Visible;
        }
    }

    private void ApplyTupleChoiceRow(TableEditorBinding binding, DataGridViewRow row, ConfigEntry entry, bool locked, IReadOnlyList<string>? knownValues = null)
    {
        if (binding.TupleChoices is not { } snapshot) return;
        var values = knownValues ?? entry.GetTupleValues();
        foreach (var state in snapshot.Fields.Values)
        {
            var cell = (DataGridViewComboBoxCell)row.Cells["field" + state.Spec.Index];
            var literal = values.ElementAtOrDefault(state.Spec.Index) ?? "nil";
            var display = state.Find(literal)?.Display;
            var placeholder = state.Choices.Count == 0 ? "No enabled templates" : "Select an enabled template";
            SetTableCellValue(cell, null);
            cell.Items.Clear();
            foreach (var choice in state.Choices) cell.Items.Add(choice.Display);
            if (display is null) cell.Items.Add(placeholder);
            SetTableCellValue(cell, display ?? placeholder);
            cell.ReadOnly = locked || !state.Admits(entry.Key);
        }
    }

    private static string? TableTupleChoiceDisplay(DataGridView grid, int index, ConfigTupleField field, string value) =>
        grid.Parent?.Tag is TableEditorBinding { TupleChoices: not null } binding && binding.TupleChoices.Fields.ContainsKey(index)
            ? binding.TupleChoices.Fields[index].Find(value)?.Display : FindChoiceDisplay(field, value);

    private void RefreshTupleChoiceBindings(string? changedList = null)
    {
        if (_document is null) return;
        var bindings = _categoryPanelCache.Values.Distinct().SelectMany(EnumerateChildControls<TableLayoutPanel>)
            .Select(panel => panel.Tag).OfType<TableEditorBinding>()
            .Where(binding => _document.HasTupleChoices(binding.Key) &&
                (changedList is null || binding.TupleChoices?.Fields.Values.Any(state => state.Spec.ActiveLists.Contains(changedList)) == true)).Distinct().ToList();
        if (bindings.Count == 0) return;
        RequiredValueSources? sources = null;
        foreach (var binding in bindings)
        {
            if (_optionsTupleChoices?.TryGetValue(binding.Key, out var prepared) == true)
                ApplyTableEditorLockState(binding, prepared: prepared);
            else ApplyTableEditorLockState(binding, sources ??= new RequiredValueSources(_document.Entries));
        }
    }

    private void ApplyTupleChoiceDefaults(ConfigEntry? source)
    {
        if (_document is null || source is not null && !IsEraSourceEntry(source)) return;
        if (!_document.TupleChoiceTargets.Any()) return;
        using var transition = BeginOptionsTransition("Escort templates");
        var sources = new RequiredValueSources(_document.Entries);
        var changes = new List<TupleChoiceChange>();
        foreach (var key in _document.TupleChoiceTargets)
            changes.AddRange(_document.PlanTupleChoiceChanges(key, GetTupleChoiceSnapshot(key, sources)!, legacyOnly: source is null));
        if (changes.Count == 0) return;
        foreach (var change in changes)
        {
            change.Entry.ValueText = change.After;
            _optionsAffected!.Add(change.Entry.EffectiveCategory);
        }
        SetUndoAction("update escort templates", () =>
        {
            foreach (var change in changes) change.Entry.ValueText = change.Before;
        }, () =>
        {
            RefreshTupleChoiceBindings();
            RefreshVisibleTableRows(changes.Select(change => change.Entry));
        });
        RefreshTupleChoiceBindings();
        RefreshVisibleTableRows(changes.Select(change => change.Entry));
    }
}
