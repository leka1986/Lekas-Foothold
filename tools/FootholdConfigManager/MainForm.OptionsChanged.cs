using System.Drawing;
using System.Globalization;
using System.Windows.Forms;

namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    // Review state belongs to the open document, never to cached/disposable controls.
    private sealed record OptionRowState(bool Visible, string Policy);
    private sealed record OptionBlockState(string Key, string Label, bool Locked, string Reason,
        Dictionary<ConfigEntry, OptionRowState> Rows, Dictionary<string, AutomaticAircraftChange>? Aircraft = null);
    private sealed record OptionNotice(OptionBlockState Block, string Status, Dictionary<string, string> Causes,
        HashSet<ConfigEntry> Rows, int Shown, int Hidden, int Locked, int Unlocked,
        Dictionary<string, AutomaticAircraftChange>? Aircraft = null)
    {
        public string Cause => string.Join("; ", Causes.Values.Distinct(StringComparer.Ordinal));
        public string Details => Aircraft is { Count: > 0 } ? Aircraft.Count.ToString(CultureInfo.InvariantCulture) + " aircraft activated for AI" : Rows.Count > 0 && Shown == 0 && Hidden == 0 && Locked == 0 && Unlocked == 0
            ? Rows.Count.ToString(CultureInfo.InvariantCulture) + (Rows.Count == 1 ? " row updated" : " rows updated")
            : $"{Shown} shown, {Hidden} hidden, {Locked} locked, {Unlocked} unlocked rows";
    }
    private sealed record OptionsMarkerTarget(Control Editor, FlowLayoutPanel Header, Label Title, Label Marker, ConfigEntry? Entry)
    {
        public int Number { get; set; }
    }
    private ConfigDocument? _optionsDocument;
    private readonly Dictionary<string, Dictionary<string, OptionBlockState>> _optionsReviewed = new(StringComparer.OrdinalIgnoreCase);
    private readonly Dictionary<string, Dictionary<string, OptionBlockState>> _optionsCurrent = new(StringComparer.OrdinalIgnoreCase);
    private readonly Dictionary<string, List<OptionNotice>> _optionsPending = new(StringComparer.OrdinalIgnoreCase);
    private readonly HashSet<ConfigEntry> _optionsKnownEntries = new();
    private string? _optionsViewedCategory;
    private string _optionsCause = "Config conditions changed";
    private int _optionsTransitionDepth;
    private HashSet<string>? _optionsAffected;
    // Synchronous mutation-only memo: native rendering and review consume the same facts.
    // It is discarded at the end of the operation, including exceptional exits.
    private Dictionary<string, TupleChoiceSnapshot?>? _optionsTupleChoices;
    private Dictionary<string, bool>? _optionsVisibilityFacts;
    private Dictionary<string, (bool Locked, string Reason)>? _optionsLockFacts;

    private sealed class OptionsTransition : IDisposable
    {
        private MainForm? _owner;
        public OptionsTransition(MainForm owner) { _owner = owner; }
        public void Dispose() { var owner = _owner; _owner = null; owner?.FinishOptionsTransition(); }
    }

    private IDisposable BeginOptionsTransition(string cause)
    {
        if (_optionsTransitionDepth++ == 0)
        {
            _optionsCause = cause;
            _optionsAffected = new(StringComparer.OrdinalIgnoreCase);
            _optionsTupleChoices = new(StringComparer.Ordinal);
            _optionsVisibilityFacts = new(StringComparer.Ordinal);
            _optionsLockFacts = new(StringComparer.Ordinal);
        }
        return new OptionsTransition(this);
    }

    private bool ReadOptionsLockFact(string key, ConfigEntry? entry, out string reason)
    {
        if (_optionsLockFacts?.TryGetValue(key, out var known) == true)
        { reason = known.Reason; return known.Locked; }
        var locked = TryGetEditorLockReason(key, out reason, entry);
        if (_optionsLockFacts is not null) _optionsLockFacts[key] = (locked, reason);
        return locked;
    }

    private void AddOptionsLockCategories(IReadOnlySet<string> targetKeys)
    {
        if (_document is null) return;
        foreach (var target in _document.Entries)
            if (targetKeys.Contains(target.DisplayKey) || targetKeys.Contains(target.ParentKey))
                _optionsAffected!.Add(target.EffectiveCategory);
        foreach (var table in _document.StageTables)
            if (targetKeys.Contains(table.Key)) _optionsAffected!.Add(table.Section);
        EnsureLinkedTableData();
        foreach (var linked in _linkedDataByKey!.Values)
            if (linked.SourceKeys.Overlaps(targetKeys) || linked.Owners.Keys.Any(target => targetKeys.Contains(target.DisplayKey)))
                foreach (var primary in linked.Rows.Keys) _optionsAffected!.Add(primary.EffectiveCategory);
    }

    private void AddOptionsDependencies(IEnumerable<ConfigEntry> entries)
    {
        RequiredValueSources? sources = null;
        RequiredValueSources GetRequiredSources() => sources ??= new RequiredValueSources(_document!.Entries);
        Dictionary<string, List<(string SourceKey, List<string> Values)>>? parsedRules = null;
        List<(string SourceKey, List<string> Values)> GetParsedRules(string text)
        {
            parsedRules ??= new(StringComparer.Ordinal);
            if (!parsedRules.TryGetValue(text, out var rules))
                parsedRules[text] = rules = ParseVisibleWhenRules(text);
            return rules;
        }
        foreach (var entry in entries)
        {
            _optionsAffected!.UnionWith(GetCategoriesContainingVisibleWhenSource(entry, GetParsedRules));
            AddOptionsLockCategories(GetDependentEditorTargetKeysCore(entry, GetRequiredSources, GetParsedRules).ToHashSet(StringComparer.Ordinal));
        }
    }

    private void FinishOptionsTransition()
    {
        if (--_optionsTransitionDepth != 0) return;
        try
        {
            if (!ReferenceEquals(_optionsDocument, _document)) return;
            foreach (var category in _optionsAffected!)
                RefreshOptionsCategory(category, _optionsCause);
            if (_document is not null) _optionsKnownEntries.UnionWith(_document.Entries);
            if (_optionsAffected.Count > 0)
            {
                _categoryList.Invalidate();
                ApplyOptionsMarkers(_optionsAffected);
            }
            else _categoryList.Invalidate();
        }
        finally
        {
            _optionsAffected = null;
            _optionsTupleChoices = null;
            _optionsVisibilityFacts = null;
            _optionsLockFacts = null;
        }
    }

    private void EnsureOptionsBaseline()
    {
        if (ReferenceEquals(_optionsDocument, _document)) return;
        _optionsDocument = _document;
        _optionsReviewed.Clear();
        _optionsCurrent.Clear();
        _optionsPending.Clear();
        _optionsKnownEntries.Clear();
        _automaticAircraftChanges.Clear();
        _requiredUseReview = null;
        _optionsViewedCategory = null;
        if (_document is not null)
        {
            _optionsKnownEntries.UnionWith(_document.Entries);
            foreach (var category in GetDesignerCategoryNames())
            {
                var blocks = ReadOptionsCategory(category);
                _optionsReviewed[category] = blocks;
                _optionsCurrent[category] = blocks;
            }
        }
        _categoryList.Invalidate();
    }

    private Dictionary<string, OptionBlockState> ReadOptionsCategory(string category)
    {
        var blocks = new Dictionary<string, OptionBlockState>(StringComparer.Ordinal);
        if (_document is null || IsCategoryHidden(category)) return blocks;
        foreach (var item in GetDesignerItems(category, includeTableRows: false))
        {
            var reason = "";
            var locked = item.IsGroup ? ShouldLockTableEditor(item.Key, out reason) :
                item.Entries.FirstOrDefault() is { } scalar && ShouldLockEntryEditor(scalar, out reason);
            var tupleChoices = GetTupleChoiceSnapshot(item.Key);
            var rows = new Dictionary<ConfigEntry, OptionRowState>();
            if (item.IsGroup)
            {
                foreach (var entry in item.Entries)
                {
                    var visible = IsTableRowVisible(entry);
                    var rowLocked = locked || ShouldLockEntryEditor(entry, out _);
                    rowLocked |= tupleChoices is not null && !tupleChoices.Admits(entry.Key);
                    var policy = rowLocked ? "locked" : "editable";
                    if (tupleChoices is not null)
                    {
                        var values = entry.GetTupleValues();
                        foreach (var field in tupleChoices.Fields.Values.Where(field => field.Visible))
                            policy += "|" + (field.Admits(entry.Key) ? "editable" : "locked") + "|selection=" + values.ElementAtOrDefault(field.Spec.Index);
                    }
                    if (item.Linked is not null && visible && !rowLocked)
                    {
                        policy += "|" + string.Join("|", item.Linked.Rows[entry].Select(cell => cell?.Entry).Select(target =>
                            target is null || !IsLinkedTargetVisible(target) ? "hidden" :
                            ShouldLockTableEditor(target.ParentKey, out _) || ShouldLockEntryEditor(target, out _) ? "locked" : "editable"));
                    }
                    rows[entry] = new(visible, policy);
                }
            }
            blocks[item.Key] = new(item.Key, item.Label, locked, reason, rows, ReadAutomaticAircraftValues(item.StringListTable));
        }
        return blocks;
    }

    private void RefreshOptionsCategory(string category, string cause)
    {
        var current = ReadOptionsCategory(category);
        _optionsCurrent[category] = current;
        if (!_optionsReviewed.TryGetValue(category, out var baseline))
            _optionsReviewed[category] = baseline = new(StringComparer.Ordinal);
        var prior = _optionsPending.GetValueOrDefault(category);
        var notices = new List<OptionNotice>();
        foreach (var block in current.Values)
        {
            var oldNotice = prior?.FirstOrDefault(n => n.Block.Key == block.Key);
            var beforeAircraft = baseline.GetValueOrDefault(block.Key)?.Aircraft;
            var aircraft = block.Aircraft?.Where(pair => beforeAircraft?.TryGetValue(pair.Key, out var previous) != true || !ReferenceEquals(previous, pair.Value))
                .ToDictionary(pair => pair.Key, pair => pair.Value, StringComparer.Ordinal);
            if (aircraft?.Count == 0) aircraft = null;
            var causes = new Dictionary<string, string>(StringComparer.Ordinal);
            void RememberCause(string component, bool unchanged)
            {
                causes[component] = unchanged && oldNotice?.Causes.TryGetValue(component, out var originalCause) == true
                    ? originalCause : cause;
            }
            var changedRows = new HashSet<ConfigEntry>();
            var shown = 0; var hidden = 0; var locked = 0; var unlocked = 0;
            string status;
            if (!baseline.TryGetValue(block.Key, out var before))
            {
                // Structural additions seed silently; conditions revealing existing identities notify.
                if (block.Rows.Count > 0 && !block.Rows.Keys.Any(_optionsKnownEntries.Contains) ||
                    block.Rows.Count == 0 && _document?.Entries.FirstOrDefault(e => e.DisplayKey == block.Key) is { } entry && !_optionsKnownEntries.Contains(entry))
                { baseline[block.Key] = block; continue; }
                status = "Shown";
                RememberCause("block", oldNotice?.Status == "Shown");
            }
            else if (block.Locked != before.Locked)
            {
                status = block.Locked ? "Locked" : "Unlocked";
                RememberCause("block", oldNotice?.Block.Locked == block.Locked);
            }
            else
            {
                foreach (var row in block.Rows)
                {
                    if (!before.Rows.TryGetValue(row.Key, out var oldRow))
                    {
                        if (!_optionsKnownEntries.Contains(row.Key)) { before.Rows[row.Key] = row.Value; continue; }
                        oldRow = new(false, "");
                    }
                    if (!row.Value.Visible)
                    {
                        if (oldRow.Visible)
                        {
                            changedRows.Add(row.Key); hidden++;
                            RememberCause(row.Key.DisplayKey + "@visible", oldNotice?.Block.Rows.GetValueOrDefault(row.Key)?.Visible == false);
                        }
                        continue;
                    }
                    if (!oldRow.Visible)
                    {
                        changedRows.Add(row.Key); shown++;
                        RememberCause(row.Key.DisplayKey + "@visible", oldNotice?.Block.Rows.GetValueOrDefault(row.Key)?.Visible == true);
                    }
                    else if (row.Value.Policy != oldRow.Policy)
                    {
                        changedRows.Add(row.Key);
                        var previous = oldRow.Policy.Split('|');
                        var next = row.Value.Policy.Split('|');
                        var priorPolicy = oldNotice?.Block.Rows.GetValueOrDefault(row.Key)?.Policy.Split('|');
                        var becameLocked = false; var becameEditable = false;
                        for (var i = 0; i < Math.Max(previous.Length, next.Length); i++)
                        {
                            var oldCell = i < previous.Length ? previous[i] : previous[0];
                            var newCell = i < next.Length ? next[i] : next[0];
                            becameLocked |= newCell == "locked" && oldCell != "locked";
                            becameEditable |= newCell == "editable" && oldCell == "locked";
                            if (newCell != oldCell)
                            {
                                var priorCell = priorPolicy is null ? null : i < priorPolicy.Length ? priorPolicy[i] : priorPolicy[0];
                                RememberCause(row.Key.DisplayKey + "@" + i.ToString(CultureInfo.InvariantCulture), priorCell == newCell);
                            }
                        }
                        if (becameLocked) locked++;
                        if (becameEditable) unlocked++;
                    }
                }
                if (changedRows.Count == 0 && aircraft is null) continue;
                status = aircraft is not null ? "Activated for AI" : "Changed";
            }
            if (aircraft is not null)
            {
                status = "Activated for AI";
                RememberCause("aircraft", false);
            }
            notices.Add(new(block, status, causes, changedRows, shown, hidden, locked, unlocked, aircraft));
        }
        if (notices.Count == 0) _optionsPending.Remove(category); else _optionsPending[category] = notices;
    }

    private void OptionsCategoryDisplayed(string category, string? previousCategory)
    {
        if (_requiredUseReview is { } review && (!ReferenceEquals(review.Document, _document) ||
            !string.Equals(review.Category, category, StringComparison.OrdinalIgnoreCase))) _requiredUseReview = null;
        // Only an actual successful user navigation acknowledges the previous view.
        var clearAircraft = previousCategory is not null && _optionsPending.GetValueOrDefault(previousCategory)?.Any(notice => notice.Aircraft is not null) == true;
        if (previousCategory is { } previous && !string.Equals(previous, category, StringComparison.OrdinalIgnoreCase))
        {
            if (_optionsCurrent.TryGetValue(previous, out var current)) _optionsReviewed[previous] = current;
            _optionsPending.Remove(previous);
        }
        _optionsViewedCategory = category;
        _categoryList.Invalidate();
        ApplyOptionsMarkers(new[] { category, previousCategory ?? category });
        if (clearAircraft && !string.Equals(previousCategory, category, StringComparison.OrdinalIgnoreCase) && _categoryPanelCache.TryGetValue(previousCategory!, out var panel))
            foreach (var group in EnumerateChildControls<TableLayoutPanel>(panel))
                if (group.Tag is StringListRequirementBinding binding) RefreshRequiredValueBinding(binding, facts: binding.Facts);
    }

    private int OptionsCategoryCount(string category) =>
        !string.Equals(category, _optionsViewedCategory, StringComparison.OrdinalIgnoreCase) &&
        _optionsPending.TryGetValue(category, out var pending) ? pending.Count : 0;

    private Control RegisterOptionsTarget(TableLayoutPanel owner, Control editor, string key, ConfigEntry? entry = null)
    {
        if (owner.Tag is not Dictionary<string, OptionsMarkerTarget> targets)
        {
            owner.Tag = targets = new(StringComparer.Ordinal);
            owner.Paint += PaintOptionsRails;
        }
        var header = editor.Tag is TableEditorBinding table ? table.Header :
            (FlowLayoutPanel)((TableLayoutPanel)editor).GetControlFromPosition(0, 0)!;
        var title = (Label)header.Controls[0];
        var markerFont = new Font(Font, FontStyle.Bold);
        var marker = new Label { Name = "OptionsChangedMarker", AutoSize = true, Visible = false,
            Font = markerFont, Margin = new Padding(Zoomed(3), Zoomed(6), Zoomed(6), 0) };
        marker.Disposed += (_, _) => markerFont.Dispose();
        var titleBreak = header.GetFlowBreak(title);
        header.Controls.Add(marker);
        header.Controls.SetChildIndex(marker, 1);
        if (titleBreak)
        {
            header.SetFlowBreak(title, false);
            header.SetFlowBreak(marker, true);
        }
        targets[key] = new(editor, header, title, marker, entry);
        return MarkConfigSearchTarget(editor, key);
    }

    private void PaintOptionsRails(object? sender, PaintEventArgs args)
    {
        if (sender is not TableLayoutPanel { Tag: Dictionary<string, OptionsMarkerTarget> targets }) return;
        var state = args.Graphics.Save();
        args.Graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
        try
        {
            var radius = Zoomed(10);
            var textColor = IsDarkPalette() ? MainBackground : Color.White;
            foreach (var target in targets.Values)
            {
                if (target.Entry is { } entry && IsRequiredUseHighlighted(entry))
                {
                    using var sourcePen = new Pen(BrandColor, Math.Max(2, Zoomed(3)));
                    args.Graphics.DrawLine(sourcePen, target.Editor.Left - Zoomed(5), target.Editor.Top,
                        target.Editor.Left - Zoomed(5), target.Editor.Bottom);
                }
                if (target.Number == 0 || !target.Marker.Visible) continue;
                var centerX = target.Editor.Left - Zoomed(12);
                var centerY = target.Editor.Top + target.Header.Top + target.Title.Top + target.Title.Font.Height / 2;
                var circle = new Rectangle(centerX - radius, centerY - radius, radius * 2, radius * 2);
                var bottom = Math.Max(centerY + radius, target.Editor.Bottom - target.Editor.Padding.Bottom);
                if (!args.ClipRectangle.IntersectsWith(Rectangle.FromLTRB(circle.Left, circle.Top, circle.Right, bottom))) continue;
                var accent = target.Marker.Text == "Locked" ? LockedTextColor : BrandColor;
                using var brush = new SolidBrush(accent);
                using var pen = new Pen(accent, Math.Max(2, Zoomed(3)));
                args.Graphics.DrawLine(pen, centerX, centerY, centerX, bottom);
                args.Graphics.FillEllipse(brush, circle);
                TextRenderer.DrawText(args.Graphics, target.Number.ToString(CultureInfo.InvariantCulture), target.Marker.Font,
                    circle, textColor, TextFormatFlags.HorizontalCenter | TextFormatFlags.VerticalCenter | TextFormatFlags.NoPadding);
            }
        }
        finally { args.Graphics.Restore(state); }
    }
    private void ApplyOptionsMarkers(IEnumerable<string>? categories = null)
    {
        foreach (var category in categories ?? new[] { GetSelectedCategoryName() })
        {
            if (!_categoryPanelCache.TryGetValue(category, out var panel) || panel.IsDisposed ||
                panel.Tag is not Dictionary<string, OptionsMarkerTarget> targets) continue;
            var pending = _optionsPending.GetValueOrDefault(category);
            if (pending is null && targets.Values.All(target => target.Number == 0)) continue;
            panel.SuspendLayout();
            try
            {
                var number = 0;
                foreach (var target in targets)
                {
                    var notice = pending?.FirstOrDefault(n => n.Block.Key == target.Key);
                    var marker = target.Value.Marker;
                    target.Value.Number = notice is null ? 0 : ++number;
                    if (notice is null) marker.Visible = false;
                    else
                    {
                        marker.Text = notice.Status;
                        marker.BackColor = target.Value.Header.BackColor;
                        marker.ForeColor = notice.Status == "Locked" ? LockedTextColor : IsDarkPalette() ? PrimaryTextColor : BrandColor;
                        marker.Visible = true;
                        _toolTip.SetToolTip(marker, notice.Status + (notice.Status == "Changed" || notice.Aircraft is not null ? " · " + notice.Details : "") +
                            Environment.NewLine + notice.Cause + (notice.Block.Reason.Length > 0 ? Environment.NewLine + notice.Block.Reason : ""));
                    }
                    if (target.Value.Editor.Tag is TableEditorBinding tableBinding)
                    {
                        tableBinding.Grid.Invalidate();
                    }
                    else if (target.Value.Editor.Tag is StringListRequirementBinding aircraftBinding)
                    {
                        RefreshRequiredValueBinding(aircraftBinding, facts: aircraftBinding.Facts);
                        aircraftBinding.Active.Invalidate();
                    }
                }
            }
            finally { panel.ResumeLayout(true); }
            panel.Invalidate();
        }
    }

    private void PaintOptionsRowMarker(object? sender, DataGridViewRowPostPaintEventArgs args)
    {
        if (sender is not DataGridView grid) return;
        if (grid.Parent?.Tag is StringListRequirementBinding aircraft && grid.Rows[args.RowIndex].Tag is StringListBucketItem item)
        {
            if (AutomaticAircraftHighlights(aircraft.Table)?.ContainsKey(item.Value) != true) return;
            using var accent = new SolidBrush(BrandColor);
            args.Graphics.FillRectangle(accent, args.RowBounds.Left, args.RowBounds.Top, Math.Max(2, Zoomed(3)), args.RowBounds.Height);
            return;
        }
        if (grid.Parent?.Tag is not TableEditorBinding binding || grid.Rows[args.RowIndex].Tag is not ConfigEntry entry) return;
        var pending = _optionsPending.GetValueOrDefault(entry.EffectiveCategory);
        if (!IsRequiredUseHighlighted(entry) && pending?.Any(n => n.Block.Key == binding.Key && n.Rows.Contains(entry)) != true) return;
        using var brush = new SolidBrush(BrandColor);
        args.Graphics.FillRectangle(brush, args.RowBounds.Left, args.RowBounds.Top, Math.Max(2, Zoomed(3)), args.RowBounds.Height);
    }
}
