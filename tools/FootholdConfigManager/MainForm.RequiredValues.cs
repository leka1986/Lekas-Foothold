using System.Drawing;
using System.Windows.Forms;
namespace FootholdConfigManager;
internal sealed partial class MainForm
{
    private sealed class StringListRequirementBinding(ConfigStringListTable table, DataGridView active, DataGridView inactive, Button deactivate, Button remove, FlowLayoutPanel reasons)
    {
        internal ConfigStringListTable Table { get; } = table;
        internal DataGridView Active { get; } = active;
        internal DataGridView Inactive { get; } = inactive;
        internal Button Deactivate { get; } = deactivate;
        internal Button Remove { get; } = remove;
        internal FlowLayoutPanel Reasons { get; } = reasons;
        internal RequiredValueResolution Facts { get; set; } = RequiredValueResolution.Empty;
        internal DataGridView? Selected { get; set; }
        internal RequiredReasonsPresentation? Presentation { get; set; }
        internal string? BlockedValue { get; set; }
        internal string? ExpandedValue { get; set; }
    }
    // Owned by the cached bucket binding; never retained beyond its editor/document.
    private sealed record RequiredReasonPresentation(ConfigEntry? Source, bool SourceIsField, bool Admitted, string Reason, string Text);
    private sealed record RequiredReasonsPresentation(DataGridView Selected, string? Value, int MaximumWidth, int Zoom, Font Font, Color Color,
        List<RequiredReasonPresentation> Reasons, bool Blocked, bool Expanded);
    private sealed record RequiredUseReview(ConfigDocument Document, ConfigStringListTable Table, string Value, string Category, HashSet<ConfigEntry> Sources);
    private RequiredUseReview? _requiredUseReview;

    private bool IsRequiredUseHighlighted(ConfigEntry entry) =>
        _requiredUseReview is { } review && ReferenceEquals(review.Document, _document) && review.Sources.Contains(entry);

    private HashSet<ConfigEntry> ReadRequiredUseSources(RequiredValueResolution facts, string value, string category)
    {
        var sources = new HashSet<ConfigEntry>();
        foreach (var reason in facts.ReasonsFor(value))
        {
            if (reason.Source is not { } source || !string.Equals(source.EffectiveCategory, category, StringComparison.OrdinalIgnoreCase)) continue;
            var isField = string.IsNullOrEmpty(source.ParentKey) || ShouldRenderRecordTableAsEntries(source.ParentKey, reason.SourceEntries);
            if (IsRequiredSourceAdmitted(source, isField)) sources.Add(source);
        }
        return sources;
    }
    private void AddRequiredStatusColumn(DataGridView grid)
    {
        grid.Columns.Add("required", "Status");
        grid.Columns["required"].Width = Zoomed(108);
        grid.Columns["required"].SortMode = DataGridViewColumnSortMode.NotSortable;
    }
    private string? RequiredRemovalRejection(ConfigStringListTable table, string value)
    {
        var facts = _document?.ResolveRequiredValues(table);
        return facts?.IsRequired(value) == true ? facts.RemovalMessage(value) : null;
    }
    private bool RejectRequiredRemoval(ConfigStringListTable table, string value)
    {
        var rejection = RequiredRemovalRejection(table, value);
        if (rejection is null) return false;
        SetStatus(rejection); return true;
    }
    private void RefreshRequiredValueBinding(StringListRequirementBinding binding, RequiredValueSources? sources = null, RequiredValueResolution? facts = null)
    {
        if (_document is null || binding.Active.IsDisposed) return;
        binding.Facts = facts ?? _document.ResolveRequiredValues(binding.Table, sources);
        var automatic = AutomaticAircraftHighlights(binding.Table);
        foreach (DataGridViewRow row in binding.Active.Rows)
            if (row.Tag is StringListBucketItem item)
            {
                var activated = automatic?.ContainsKey(item.Value) == true;
                var cell = row.Cells["required"];
                cell.Value = activated ? "Activated for AI" : binding.Facts.IsRequired(item.Value) ? "Used by AI" : "";
                cell.Style.BackColor = activated ? IsDarkPalette() ? Color.FromArgb(35, 59, 80) : Color.FromArgb(225, 240, 250) : Color.Empty;
                cell.Style.ForeColor = activated ? BrandColor : Color.Empty;
            }
        ShowRequiredValueReasons(binding, binding.Selected ?? binding.Active);
    }
    private void ShowRequiredValueReasons(StringListRequirementBinding binding, DataGridView selected)
    {
        binding.Selected = selected;
        binding.Deactivate.Enabled = binding.Active.CurrentRow?.Tag is StringListBucketItem;
        var item = selected.CurrentRow?.Tag as StringListBucketItem;
        binding.Remove.Enabled = item is not null && !binding.Facts.IsRequired(item.Value);
        var value = item?.Value;
        if (binding.Presentation is { } previous && (previous.Value != value || !ReferenceEquals(previous.Selected, selected)))
        { binding.BlockedValue = null; binding.ExpandedValue = null; }
        var blocked = value is not null && binding.BlockedValue == value;
        var expanded = value is not null && binding.ExpandedValue == value;
        var maximumWidth = Math.Max(Zoomed(240), binding.Reasons.Parent!.Width - Zoomed(24));
        var reasons = new List<RequiredReasonPresentation>();
        if (item is not null)
        foreach (var reason in binding.Facts.ReasonsFor(item.Value))
        {
            // Admission controls only presentation/navigation. Hidden sources still require the exact value.
            var source = reason.Source;
            var sourceIsField = source is not null && (string.IsNullOrEmpty(source.ParentKey) || ShouldRenderRecordTableAsEntries(source.ParentKey, reason.SourceEntries));
            var admitted = source is not null && IsRequiredSourceAdmitted(source, sourceIsField);
            var context = source is not null && admitted && !string.IsNullOrEmpty(source.ParentKey) ? GetConfiguredGroupLabel(source.ParentKey) + " / " + reason.Text : reason.Text;
            var text = "Used by AI · " + (source is not null && !admitted ? "Enabled option" : context);
            reasons.Add(new(source, sourceIsField, admitted, reason.Text, text + (admitted ? " · Here" : "")));
        }
        if (binding.Presentation is { } shown && ReferenceEquals(shown.Selected, selected) && shown.Value == value &&
            shown.MaximumWidth == maximumWidth && shown.Zoom == _uiZoomPercent && shown.Font.Equals(binding.Reasons.Font) &&
            shown.Color == PrimaryTextColor && shown.Blocked == blocked && shown.Expanded == expanded && shown.Reasons.SequenceEqual(reasons)) return;
        binding.Reasons.SuspendLayout();
        foreach (Control old in binding.Reasons.Controls.Cast<Control>().ToArray()) old.Dispose();
        if (item is not null && binding.Facts.IsRequired(item.Value))
        {
            var notice = new FlowLayoutPanel { AutoSize = true, FlowDirection = FlowDirection.TopDown, WrapContents = false,
                MaximumSize = new Size(maximumWidth, 0), Padding = new Padding(Zoomed(12)), Margin = new Padding(0, Zoomed(6), 0, Zoomed(6)),
                BackColor = blocked ? IsDarkPalette() ? Color.FromArgb(48, 42, 36) : Color.FromArgb(255, 245, 222) : EditorBackground };
            var headingFont = new Font(Font, FontStyle.Bold);
            var heading = new Label { Name = "RequiredAircraftNotice", AutoSize = true, MaximumSize = new Size(Math.Max(1, maximumWidth - Zoomed(30)), 0),
                Text = blocked ? "Cannot deactivate " + value : value + " is required by AI", Font = headingFont,
                ForeColor = blocked ? IsDarkPalette() ? Color.FromArgb(255, 199, 120) : Color.FromArgb(128, 75, 0) : PrimaryTextColor };
            heading.Disposed += (_, _) => headingFont.Dispose();
            notice.Controls.Add(heading);
            notice.Controls.Add(new Label { AutoSize = true, MaximumSize = heading.MaximumSize, ForeColor = PrimaryTextColor,
                Text = "Change or disable its AI uses before moving it to Not active.", Margin = new Padding(0, Zoomed(4), 0, Zoomed(8)) });
            var review = new LinkLabel { Name = "RequiredAircraftReviewAll", AutoSize = true, Text = "Review all uses",
                LinkColor = BrandColor, ActiveLinkColor = BrandColor, VisitedLinkColor = BrandColor, LinkBehavior = LinkBehavior.AlwaysUnderline };
            review.LinkClicked += (_, _) =>
            {
                binding.ExpandedValue = value;
                ShowRequiredValueReasons(binding, selected);
                if (reasons.FirstOrDefault(reason => reason.Admitted) is { } first)
                    ReviewRequiredUses(binding, value!, first.Source!, first.SourceIsField);
            };
            notice.Controls.Add(review);
            binding.Reasons.Controls.Add(notice);
        }
        if (expanded)
        foreach (var category in reasons.Where(reason => reason.Admitted).GroupBy(reason => reason.Source!.EffectiveCategory, StringComparer.OrdinalIgnoreCase))
        {
            var first = category.First();
            var count = category.Select(reason => reason.Source!).Distinct().Count();
            var link = new LinkLabel { Name = "RequiredAircraftCategory:" + category.Key, AutoSize = true, MaximumSize = new Size(maximumWidth, 0),
                Text = GetCategoryDisplayName(category.Key) + " · " + count + (count == 1 ? " AI use" : " AI uses"),
                LinkColor = BrandColor, ActiveLinkColor = BrandColor, VisitedLinkColor = BrandColor, LinkBehavior = LinkBehavior.AlwaysUnderline,
                Margin = new Padding(0, Zoomed(8), 0, Zoomed(3)) };
            link.LinkClicked += (_, _) => ReviewRequiredUses(binding, value!, first.Source!, first.SourceIsField);
            binding.Reasons.Controls.Add(link);
        }
        if (expanded)
        foreach (var reason in reasons)
        {
            var line = new LinkLabel { AutoSize = true, MaximumSize = new Size(maximumWidth, 0), Text = reason.Text, LinkBehavior = LinkBehavior.AlwaysUnderline, ForeColor = PrimaryTextColor, LinkColor = PrimaryTextColor, ActiveLinkColor = PrimaryTextColor, VisitedLinkColor = PrimaryTextColor, Margin = new Padding(0, Zoomed(2), 0, Zoomed(2)) };
            line.Links.Clear();
            if (reason.Admitted)
            {
                line.Links.Add(line.Text.Length - 4, 4);
                var heldSource = reason.Source!;
                var sourceIsField = reason.SourceIsField;
                line.LinkClicked += (_, _) =>
                {
                    ReviewRequiredUses(binding, value!, heldSource, sourceIsField);
                };
            }
            binding.Reasons.Controls.Add(line);
        }
        binding.Reasons.ResumeLayout(true);
        binding.Presentation = new(selected, value, maximumWidth, _uiZoomPercent, binding.Reasons.Font, PrimaryTextColor, reasons, blocked, expanded);
        if (binding.Active.Parent is TableLayoutPanel group) ApplyStringListBucketLayout(group, binding.Active, binding.Inactive);
    }
    private void ReviewRequiredUses(StringListRequirementBinding binding, string value, ConfigEntry source, bool isField)
    {
        if (_document is null || !_document.StringListTables.Contains(binding.Table) || !_document.Entries.Contains(source) || !IsRequiredSourceAdmitted(source, isField)) return;
        var current = _document.ResolveRequiredValues(binding.Table);
        if (!current.ReasonsFor(value).Any(reason => ReferenceEquals(reason.Source, source))) return;
        var category = source.EffectiveCategory;
        var sources = ReadRequiredUseSources(current, value, category);
        _requiredUseReview = new(_document, binding.Table, value, category, sources);
        JumpToConfigSearchResult(new ConfigSearchResult(isField ? source.DisplayKey : source.ParentKey,
            isField ? null : source.DisplayKey, source.DisplayName, category, GetCategoryDisplayName(category), "", 0, 0));
        _formHost.Invalidate(true);
    }
    private bool IsRequiredSourceAdmitted(ConfigEntry source, bool isField)
    {
        if (!IsTableRowVisible(source)) return false;
        return IsDesignerItemVisible(new DesignerItem(isField ? source.DisplayKey : source.ParentKey, source.DisplayName, source.EffectiveCategory, !isField, new List<ConfigEntry> { source }));
    }
}
