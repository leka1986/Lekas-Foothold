namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    // Produced by the existing cell issue path; survives view disposal, resets with the document.
    private readonly Dictionary<string, HashSet<(ConfigEntry Entry, int Index)>> _tableChoiceAttention = new(StringComparer.OrdinalIgnoreCase);

    private int TableChoiceAttentionCount(string category, string? key = null) =>
        _tableChoiceAttention.TryGetValue(category, out var issues)
            ? key is null ? issues.Count : issues.Count(issue => issue.Entry.ParentKey == key) : 0;

    private void UpdateTableChoiceAttention(DataGridView grid, ConfigEntry entry, int index, bool unresolved)
    {
        var category = entry.EffectiveCategory;
        var actionable = unresolved && !grid.ReadOnly &&
            grid.Parent?.Tag is TableEditorBinding { TupleChoices: not null } binding &&
            binding.TupleChoices.Fields.TryGetValue(index, out var field) && field.Admits(entry.Key) &&
            entry.GetTupleValues().FirstOrDefault()?.Equals("true", StringComparison.OrdinalIgnoreCase) == true;
        if (!_tableChoiceAttention.TryGetValue(category, out var issues))
        {
            if (!actionable) return;
            _tableChoiceAttention[category] = issues = new();
        }
        var changed = actionable ? issues.Add((entry, index)) : issues.Remove((entry, index));
        if (issues.Count == 0) _tableChoiceAttention.Remove(category);
        if (!changed) return;
        if (_optionsAffected is { } affected) { affected.Add(category); return; }
        ApplyOptionsMarkers(new[] { category });
        _categoryList.Invalidate();
    }

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
            if (cell is TableTupleChoiceCell nativeCell) nativeCell.ClearNativeFormattingIssue();
            var literal = values.ElementAtOrDefault(state.Spec.Index) ?? "nil";
            var display = state.DisplayStored(literal);
            var placeholder = state.Choices.Count == 0 ? "No enabled templates" : "Select an enabled template";
            var items = state.Choices.Select(choice => choice.Display).ToList();
            if (display is null) items.Add(placeholder);
            else if (!items.Contains(display)) items.Add(display);
            // Keep the native editing control's selected item during a committed row refresh.
            if (cell.Value is not null && !items.Contains(cell.Value.ToString()!)) SetTableCellValue(cell, null);
            foreach (var item in items)
                if (!cell.Items.Contains(item)) cell.Items.Add(item);
            foreach (var item in cell.Items.Cast<object>().Where(item => !items.Contains(item.ToString()!)).ToArray())
                cell.Items.Remove(item);
            SetTableCellValue(cell, display ?? placeholder);
            cell.ReadOnly = locked || !state.Admits(entry.Key);
            if (state.Find(literal) is null && !state.IsDynamic(literal) && state.Visible)
            {
                RecordTableChoiceIssue(binding.Grid, cell, entry, state.Spec.Index, entry.TupleFields[state.Spec.Index], literal, display ?? placeholder);
                PublishTableChoiceIssue(binding.Grid, cell);
            }
            else
            {
                ClearTableChoiceIssue(binding.Grid, cell);
                UpdateTableChoiceAttention(binding.Grid, entry, state.Spec.Index, false);
            }
        }
    }

    private void SetTableTupleChoiceValue(DataGridView grid, DataGridViewCell valueCell, int index, ConfigTupleField field, string value)
    {
        if (valueCell is TableTupleChoiceCell nativeCell) nativeCell.ClearNativeFormattingIssue();
        if (grid.Parent?.Tag is TableEditorBinding { TupleChoices: not null } binding && binding.TupleChoices.Fields.ContainsKey(index))
        {
            SetTableCellValue(valueCell, TableTupleChoiceDisplay(grid, index, field, value));
            return;
        }

        var cell = (DataGridViewComboBoxCell)valueCell;
        var display = FindChoiceDisplay(field, value);
        if (cell.Items.Contains(display) && cell.ErrorText.Length == 0)
        {
            SetTableCellValue(cell, display);
            ClearTableChoiceIssue(grid, cell);
            return;
        }
        SetTableCellValue(cell, null);
        cell.Items.Clear();
        foreach (var choice in field.Choices) cell.Items.Add(choice.Display);
        if (!cell.Items.Contains(display))
        {
            display = "Unavailable: " + value;
            while (cell.Items.Contains(display)) display = "Unavailable: " + display;
            cell.Items.Add(display);
            RecordTableChoiceIssue(grid, cell, (ConfigEntry)cell.OwningRow.Tag!, index, field, value, display);
        }
        else
        {
            ClearTableChoiceIssue(grid, cell);
        }
        SetTableCellValue(cell, display);
        PublishTableChoiceIssue(grid, cell);
    }

    // Only tuple choice columns use this cell; valid formatting remains the native implementation.
    private sealed class TableTupleChoiceCell : DataGridViewComboBoxCell
    {
        private TableChoiceIssue? _nativeFormattingIssue;
        private string? _nativeFormattingValue;
        public TableTupleChoiceCell() { } // Native Clone constructs the runtime type through its public constructor.
        internal void MarkNativeFormattingIssue(string value, TableChoiceIssue issue)
        { _nativeFormattingValue = value; _nativeFormattingIssue = issue; }
        internal void ClearNativeFormattingIssue()
        { _nativeFormattingIssue = null; _nativeFormattingValue = null; }
        public override object Clone()
        {
            var clone = (TableTupleChoiceCell)base.Clone();
            clone.ClearNativeFormattingIssue();
            return clone;
        }
        protected override object? GetFormattedValue(object? value, int rowIndex, ref DataGridViewCellStyle cellStyle,
            System.ComponentModel.TypeConverter? valueTypeConverter, System.ComponentModel.TypeConverter? formattedValueTypeConverter,
            DataGridViewDataErrorContexts context)
        {
            var formatted = base.GetFormattedValue(value, rowIndex, ref cellStyle, valueTypeConverter, formattedValueTypeConverter, context);
            return _nativeFormattingIssue is { } issue && Equals(value, _nativeFormattingValue) ? issue.Presentation : formatted;
        }
    }

    private sealed record TableChoiceNativeError(string ExceptionText, DataGridViewDataErrorContexts Context,
        string CellValue, string ActualType, string ExpectedType)
    {
        // Keep the first actual context; a later sizing/paint request is not a new occurrence of the same failure.
        internal bool SameFailure(TableChoiceNativeError other) => ExceptionText == other.ExceptionText &&
            CellValue == other.CellValue && ActualType == other.ActualType && ExpectedType == other.ExpectedType;
    }

    private void HandleTableChoiceDataError(DataGridView grid, DataGridViewDataErrorEventArgs args)
    {
        // Preserve the previous empty-handler policy for cells outside the localized tuple subclass.
        if (args.RowIndex < 0 || args.RowIndex >= grid.Rows.Count || args.ColumnIndex < 0 || args.ColumnIndex >= grid.Columns.Count ||
            grid.Rows[args.RowIndex].Cells[args.ColumnIndex] is not TableTupleChoiceCell cell) return;
        var exception = args.Exception ?? throw new InvalidOperationException("Table DataError did not provide an exception.");
        if (grid.Rows[args.RowIndex].Tag is not ConfigEntry entry ||
            !grid.Columns[args.ColumnIndex].Name.StartsWith("field", StringComparison.Ordinal) ||
            !int.TryParse(grid.Columns[args.ColumnIndex].Name.AsSpan(5), out var index) || index < 0 || index >= entry.TupleFields.Count ||
            entry.TupleFields[index].Kind != ConfigTupleFieldKind.Choice)
        {
            SetStatus("Table " + grid.Tag + " could not display a cell: " + exception.Message);
            args.ThrowException = true;
            return;
        }
        var field = entry.TupleFields[index];
        var raw = entry.GetTupleValues().ElementAtOrDefault(index) ?? "nil";
        var value = cell.Value;
        var display = TableTupleChoiceDisplay(grid, index, field, raw);
        var presentation = display is not null && field.Choices.Any(choice => choice.Display == display) ? display : "Unavailable: " + raw;
        if (grid.ContextMenuStrip?.Tag is TableChoiceMenuState state && state.Issues.TryGetValue(cell, out var prior) &&
            ReferenceEquals(prior.Entry, entry) && prior.Raw == raw) presentation = prior.Presentation;
        var native = new TableChoiceNativeError(exception.ToString(), args.Context, value?.ToString() ?? "<null>",
            value?.GetType().FullName ?? "<null>", cell.ValueType?.FullName ?? "<null>");
        var issue = RecordTableChoiceIssue(grid, cell, entry, index, field, raw, presentation, native);
        PublishTableChoiceIssue(grid, cell);
        // Recover only the exact unbound string-membership formatting branch. No schema coercion or commit suppression.
        if (exception.GetType() == typeof(ArgumentException) &&
            (args.Context & DataGridViewDataErrorContexts.Formatting) != 0 &&
            (args.Context & (DataGridViewDataErrorContexts.Parsing | DataGridViewDataErrorContexts.Commit)) == 0 &&
            cell.DataSource is null && cell.ValueMember.Length == 0 && cell.DisplayMember.Length == 0 &&
            (cell.ValueType == typeof(object) || cell.ValueType == typeof(string)) && value is string failed &&
            failed.Length != 0 && !cell.Items.Contains(failed))
        {
            cell.MarkNativeFormattingIssue(failed, issue);
            args.ThrowException = false;
            return;
        }
        args.ThrowException = true;
    }
    private sealed class TableChoiceIssue
    {
        public TableChoiceIssue(ConfigEntry entry, int index, ConfigTupleField field, string raw, string presentation, TableChoiceNativeError? nativeError = null)
        { Entry = entry; Index = index; Choices = field.Choices; Raw = raw; Presentation = presentation; NativeError = nativeError;
            Summary = nativeError is null ? "Saved value " + raw + " is not in the available choices. Right-click this cell for Copy details."
                : "This saved choice could not be displayed normally. Raw value retained. Right-click this cell for Copy details."; }
        public ConfigEntry Entry { get; }
        public int Index { get; }
        public IReadOnlyList<ConfigChoice> Choices { get; set; }
        public string Raw { get; }
        public string Presentation { get; }
        public TableChoiceNativeError? NativeError { get; }
        public DateTime ObservedUtc { get; } = DateTime.UtcNow;
        public string? Details { get; set; }
        public string Summary { get; }
    }

    private sealed class TableChoiceMenuState
    {
        public Dictionary<DataGridViewCell, TableChoiceIssue> Issues { get; } = new();
        public DataGridViewCell? Target { get; set; }
        public bool PointerRequest { get; set; }
    }

    private TableChoiceMenuState EnsureTableChoiceMenu(DataGridView grid)
    {
        if (grid.ContextMenuStrip?.Tag is TableChoiceMenuState existing) return existing;
        var state = new TableChoiceMenuState();
        var menu = new ContextMenuStrip { ShowImageMargin = false, ShowCheckMargin = false, Tag = state };
        var copy = new ToolStripMenuItem("Copy details");
        menu.Items.Add(copy);
        grid.ContextMenuStrip = menu;
        grid.CellMouseDown += (_, args) =>
        {
            if (args.Button == MouseButtons.Right)
            {
                state.PointerRequest = true;
                state.Target = args.RowIndex >= 0 && args.ColumnIndex >= 0 ? grid.Rows[args.RowIndex].Cells[args.ColumnIndex] : null;
            }
        };
        menu.Opening += (_, args) =>
        {
            StyleToolbarMenu(menu);
            var cell = state.PointerRequest ? state.Target : grid.CurrentCell;
            state.PointerRequest = false;
            if (cell is null || !ReferenceEquals(cell.DataGridView, grid) || !state.Issues.TryGetValue(cell, out var issue))
            { state.Target = null; copy.Tag = null; args.Cancel = true; return; }
            PublishTableChoiceIssue(grid, cell);
            copy.Tag = new WeakReference<DataGridViewCell>(cell);
        };
        menu.Closed += (_, _) => state.Target = null;
        copy.Click += (_, _) =>
        {
            if (copy.Tag is not WeakReference<DataGridViewCell> target || !target.TryGetTarget(out var cell) ||
                !ReferenceEquals(cell.DataGridView, grid) || !state.Issues.TryGetValue(cell, out var issue))
            { SetStatus("That table issue is no longer current."); return; }
            var details = BuildTableChoiceDetails(grid, cell, issue);
            try { Clipboard.SetText(details); }
            catch (System.Runtime.InteropServices.ExternalException ex) { SetStatus("Could not copy details: " + ex.Message); return; }
            SetStatus("Copied table issue details.");
            copy.Tag = null;
        };
        grid.RowsRemoved += (_, _) =>
        {
            foreach (var cell in state.Issues.Keys.Where(cell => !ReferenceEquals(cell.DataGridView, grid) || cell.RowIndex < 0).ToArray())
            {
                var issue = state.Issues[cell];
                state.Issues.Remove(cell);
                UpdateTableChoiceAttention(grid, issue.Entry, issue.Index, false);
            }
            state.Target = null;
            copy.Tag = null;
        };
        grid.Disposed += (_, _) =>
        {
            state.Issues.Clear();
            state.Target = null;
            copy.Tag = null;
            menu.Dispose();
        };
        return state;
    }

    private TableChoiceIssue RecordTableChoiceIssue(DataGridView grid, DataGridViewComboBoxCell cell, ConfigEntry entry, int index, ConfigTupleField field, string raw, string presentation, TableChoiceNativeError? nativeError = null)
    {
        var state = EnsureTableChoiceMenu(grid);
        UpdateTableChoiceAttention(grid, entry, index, true);
        if (state.Issues.TryGetValue(cell, out var previous) && ReferenceEquals(previous.Entry, entry) &&
            previous.Raw == raw && previous.Presentation == presentation &&
            (previous.NativeError is null ? nativeError is null : nativeError is not null && previous.NativeError.SameFailure(nativeError)))
        {
            var sameChoices = ReferenceEquals(previous.Choices, field.Choices) ||
                previous.Choices.Count == field.Choices.Count && previous.Choices.Zip(field.Choices).All(pair =>
                    pair.First.Literal == pair.Second.Literal && pair.First.Display == pair.Second.Display);
            if (sameChoices) { previous.Choices = field.Choices; cell.ErrorText = previous.Summary; return previous; }
        }
        var issue = new TableChoiceIssue(entry, index, field, raw, presentation, nativeError);
        state.Issues[cell] = issue;
        cell.ErrorText = issue.Summary;
        return issue;
    }

    private void ClearTableChoiceIssue(DataGridView grid, DataGridViewCell cell)
    {
        if (cell is TableTupleChoiceCell nativeCell) nativeCell.ClearNativeFormattingIssue();
        if (grid.ContextMenuStrip?.Tag is TableChoiceMenuState state && state.Issues.Remove(cell, out var issue))
            UpdateTableChoiceAttention(grid, issue.Entry, issue.Index, false);
        cell.ErrorText = "";
    }

    private void PublishTableChoiceIssues(DataGridView grid, DataGridViewRow row)
    {
        if (grid.ContextMenuStrip?.Tag is not TableChoiceMenuState state || state.Issues.Count == 0) return;
        foreach (DataGridViewCell cell in row.Cells) PublishTableChoiceIssue(grid, cell);
    }

    private void PublishTableChoiceIssue(DataGridView grid, DataGridViewCell cell)
    {
        if (grid.ContextMenuStrip?.Tag is not TableChoiceMenuState state || !state.Issues.TryGetValue(cell, out var issue) ||
            issue.Details is not null || !ReferenceEquals(cell.DataGridView, grid) || cell.RowIndex < 0) return;
        issue.Details = BuildTableChoiceDetails(grid, cell, issue);
        var error = WriteTableChoiceDiagnostic(issue.Details);
        SetStatus(error is null
            ? "Unavailable saved choice in " + issue.Entry.DisplayKey + ". Right-click the marked cell for Copy details."
            : "Table issue details are available, but the local diagnostic could not be written: " + error);
    }

    private string BuildTableChoiceDetails(DataGridView grid, DataGridViewCell cell, TableChoiceIssue issue)
    {
        var column = grid.Columns[cell.ColumnIndex];
        var assembly = typeof(MainForm).Assembly;
        var lines = new List<string>
        {
            "Foothold Config Manager table choice diagnostic",
            "Observed UTC: " + issue.ObservedUtc.ToString("O", System.Globalization.CultureInfo.InvariantCulture),
            "Build: " + assembly.GetName().Version + "; module " + assembly.ManifestModule.ModuleVersionId,
            "Executable: " + (Environment.ProcessPath ?? ""),
            "Build mode: " + (AppMode.IsExportedUserBuild ? "User" : "Admin/source"),
            "Visible version: " + (_document?.Metadata.FooterVersion ?? ""),
            "Config: " + (_document?.Path ?? ""),
            "Category: " + issue.Entry.EffectiveCategory,
            "Table: " + (grid.Tag as string ?? issue.Entry.ParentKey),
            "Entry: " + issue.Entry.DisplayKey,
            "Row key: " + issue.Entry.Key + "; source line: " + (issue.Entry.LineIndex + 1).ToString(System.Globalization.CultureInfo.InvariantCulture),
            "UI row: " + cell.RowIndex.ToString(System.Globalization.CultureInfo.InvariantCulture),
            "Column: " + column.Name + " [" + column.HeaderText + "]; UI index: " + cell.ColumnIndex.ToString(System.Globalization.CultureInfo.InvariantCulture),
            "Tuple field index: " + issue.Index.ToString(System.Globalization.CultureInfo.InvariantCulture),
            "Raw Lua literal: " + issue.Raw,
            "Presented value: " + issue.Presentation,
            "Cell value type: " + (cell.ValueType?.FullName ?? ""),
            "Visible: " + column.Visible + "; read-only: " + (grid.ReadOnly || cell.OwningRow.ReadOnly || cell.ReadOnly),
            issue.NativeError is null ? "Context: unavailable-choice projection; no DataError exception was suppressed"
                : "Context: actual native DataError; raw model value retained",
            "Issue: " + issue.Summary,
            "Declared choices:"
        };
        if (issue.NativeError is { } native)
            lines.InsertRange(lines.Count - 1, new[] { "DataError context: " + native.Context,
                "Failing cell value: " + native.CellValue, "Actual cell value type: " + native.ActualType,
                "Expected ValueType: " + native.ExpectedType, "Exception: " + native.ExceptionText });
        lines.AddRange(issue.Choices.Select(choice => "  " + choice.Literal + " => " + choice.Display));
        lines.Add("Actual cell items:");
        lines.AddRange(((DataGridViewComboBoxCell)cell).Items.Cast<object>().Select(item => "  " + item));
        lines.Add("Local diagnostic: " + Path.Combine(RuntimeSettings.SettingsDirectory, "logs", "table-compatibility-latest.log"));
        return string.Join(Environment.NewLine, lines);
    }

    private static string? WriteTableChoiceDiagnostic(string details)
    {
        try
        {
            var directory = Path.Combine(RuntimeSettings.SettingsDirectory, "logs");
            Directory.CreateDirectory(directory);
            File.WriteAllText(Path.Combine(directory, "table-compatibility-latest.log"), details, new System.Text.UTF8Encoding(false));
            return null;
        }
        catch (Exception ex) { return ex.Message; }
    }

    private static string? TableTupleChoiceDisplay(DataGridView grid, int index, ConfigTupleField field, string value) =>
        grid.Parent?.Tag is TableEditorBinding { TupleChoices: not null } binding && binding.TupleChoices.Fields.ContainsKey(index)
            ? binding.TupleChoices.Fields[index].DisplayStored(value) : FindChoiceDisplay(field, value);

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
        if (_document is null || source is not null && !IsEraSourceEntry(source) && source.ParentKey is not ("BlueCapPlaneEnabled" or "RedCapPlaneEnabled")) return;
        if (!_document.TupleChoiceTargets.Any()) return;
        using var transition = BeginOptionsTransition("Escort templates");
        var sources = new RequiredValueSources(_document.Entries);
        var changes = new List<TupleChoiceChange>();
        foreach (var key in _document.TupleChoiceTargets)
            changes.AddRange(_document.PlanTupleChoiceChanges(key, GetTupleChoiceSnapshot(key, sources)!, legacyOnly: source is null || !IsEraSourceEntry(source)));
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
            using var undoTransition = BeginOptionsTransition("Undo escort template selection");
            foreach (var change in changes) _optionsAffected!.Add(change.Entry.EffectiveCategory);
            RefreshTupleChoiceBindings();
            RefreshVisibleTableRows(changes.Select(change => change.Entry));
        });
        RefreshTupleChoiceBindings();
        RefreshVisibleTableRows(changes.Select(change => change.Entry));
    }
}
