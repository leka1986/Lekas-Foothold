using System.Drawing.Drawing2D;
using System.Windows.Forms;

namespace FootholdConfigManager;

internal sealed partial class MainForm
{

    private static Color PrimaryActionColor => IsDarkPalette() ? Color.FromArgb(0, 102, 235) : BrandColor;
    private Button? _previewCommentsButton;

    private void LayoutPreviewFooter()
    {
        if (_statusPanel is not TableLayoutPanel footer || _rootLayout is null ||
            _configSearchSurface is null || _previewCommentsButton is null) return;
        var missionSettings = _weatherWindow is { Visible: true };
        var wrapped = _previewCommentsButton.Visible && !missionSettings && ClientSize.Width < Zoomed(1070);
        footer.SuspendLayout();
        var updateWidth = _updatesButton is PreviewButton { HasUpdateNotice: true } notice
            ? TextRenderer.MeasureText(notice.Text, notice.Font, Size.Empty, TextFormatFlags.SingleLine | TextFormatFlags.NoPadding).Width
              + TextRenderer.MeasureText("NEW", notice.Font, Size.Empty, TextFormatFlags.SingleLine | TextFormatFlags.NoPadding).Width
              + Math.Max(68, Zoomed(68)) + notice.Margin.Horizontal
            : Zoomed(116);
        var widths = new[] { 190, 0, 180, 42, 130, 60, 116, 0 };
        for (var column = 0; column < widths.Length; column++)
            if (column != 1) SetColumnWidth(footer, column, column == 5
                ? Math.Max(Zoomed(widths[column]), TextRenderer.MeasureText("About", Font, Size.Empty,
                    TextFormatFlags.SingleLine | TextFormatFlags.NoPadding).Width + 14 + Zoomed(2) * 2)
                : widths[column] == 0 ? 0 : Zoomed(widths[column]));
        SetColumnWidth(footer, 6, updateWidth);
        var wrapUpdates = _updatesButton is not null && footer.ClientSize.Width > 0 &&
            footer.ColumnStyles.Cast<ColumnStyle>().Where(style => style.SizeType == SizeType.Absolute).Sum(style => style.Width)
                + Zoomed(100) > footer.ClientSize.Width;
        if (wrapUpdates) SetColumnWidth(footer, 6, 0);
        if (_updatesButton is not null)
        {
            footer.SetColumnSpan(_updatesButton, 1);
            footer.SetCellPosition(_updatesButton, new TableLayoutPanelCellPosition(wrapUpdates ? 2 : 6, wrapUpdates ? 1 : 0));
            footer.SetColumnSpan(_updatesButton, wrapUpdates ? 5 : 1);
            _updatesButton.Dock = wrapUpdates ? DockStyle.Right : DockStyle.Fill;
            _updatesButton.Width = Math.Max(1, updateWidth - _updatesButton.Margin.Horizontal);
        }
        SetRowHeight(footer, 0, Zoomed(40));
        SetRowHeight(footer, 1, wrapped || wrapUpdates ? Zoomed(40) : 0);
        SetRowHeight(_rootLayout, 2, Zoomed(wrapped || wrapUpdates ? 80 : 40));
        footer.SetCellPosition(_previewCommentsButton, new TableLayoutPanelCellPosition(wrapped ? 0 : 7, wrapped ? 1 : 0));
        footer.ResumeLayout();
        ApplyConfigSearchBarSizing();
        LayoutUpdatesPanel();
    }

    private string GetPreviewComments()
    {
        var items = GetDesignerItems(GetSelectedCategoryName(), includeTableRows: false);
        return string.Join(Environment.NewLine + Environment.NewLine, items.Select(item =>
        {
            var description = GetConfigSearchItemDescription(item);
            var rowComments = item.Entries.Select(entry => (Entry: entry, Help: GetConfigSearchEntryDescription(entry)))
                .Where(row => !string.IsNullOrWhiteSpace(row.Help))
                .Select(row => row.Entry.DisplayName + ": " + row.Help);
            return item.Label + Environment.NewLine + description + Environment.NewLine +
                string.Join(Environment.NewLine + Environment.NewLine, rowComments);
        }));
    }

    private void ShowPreviewComments()
    {
        using var dialog = new Form { Text = "Comments · " + GetSelectedCategoryName(), Font = Font,
            StartPosition = FormStartPosition.CenterParent, ClientSize = new Size(Zoomed(680), Zoomed(480)),
            MinimizeBox = false, MaximizeBox = false, Padding = new Padding(Zoomed(16)) };
        var content = new TextBox { Multiline = true, ReadOnly = true, WordWrap = true,
            ScrollBars = ScrollBars.Vertical, Dock = DockStyle.Fill, Text = GetPreviewComments(), BorderStyle = BorderStyle.None };
        var close = MakeButton("Close", () => dialog.Close());
        close.Dock = DockStyle.Bottom;
        close.Height = Zoomed(36);
        dialog.Controls.Add(content);
        dialog.Controls.Add(close);
        dialog.CancelButton = close;
        ApplyDialogChrome(dialog);
        dialog.ShowDialog(this);
    }

    // Keep Button's keyboard, accessibility and click contracts; only paint the preview surface.
    private sealed class PreviewButton : Button
    {
        public PreviewButton()
        {
            Padding = new Padding(28, 0, 8, 0);
            SetStyle(ControlStyles.UserPaint | ControlStyles.AllPaintingInWmPaint |
                ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw, true);
        }
        private bool _hasUpdateNotice;
        internal bool HasUpdateNotice
        {
            get => _hasUpdateNotice;
            set { if (_hasUpdateNotice != value) { _hasUpdateNotice = value; Invalidate(); } }
        }
        private bool _hover;
        private bool _pressed;

        protected override void OnMouseEnter(EventArgs e) { _hover = true; Invalidate(); base.OnMouseEnter(e); }
        protected override void OnMouseLeave(EventArgs e) { _hover = _pressed = false; Invalidate(); base.OnMouseLeave(e); }
        protected override void OnMouseDown(MouseEventArgs e) { _pressed = e.Button == MouseButtons.Left; Invalidate(); base.OnMouseDown(e); }
        protected override void OnMouseUp(MouseEventArgs e) { _pressed = false; Invalidate(); base.OnMouseUp(e); }

        protected override void OnPaint(PaintEventArgs e)
        {
            if (Width < 2 || Height < 2) return;
            e.Graphics.Clear(Parent?.BackColor ?? MainBackground);
            e.Graphics.SmoothingMode = SmoothingMode.AntiAlias;
            var primary = Text == "Add row";
            var updateNotice = HasUpdateNotice && Enabled;
            var noticeFill = SystemInformation.HighContrast ? SystemColors.Highlight : IsDarkPalette() ? Color.FromArgb(63, 223, 202) : Color.FromArgb(8, 122, 115);
            var fillColor = !Enabled ? BackColor : updateNotice ? noticeFill : primary ? PrimaryActionColor
                : _pressed ? FlatAppearance.MouseDownBackColor : _hover ? FlatAppearance.MouseOverBackColor : BackColor;
            var textColor = !Enabled ? HelpTextColor : updateNotice ? (SystemInformation.HighContrast ? SystemColors.HighlightText : IsDarkPalette() ? Color.FromArgb(7, 46, 42) : Color.White) : primary ? Color.White : ForeColor;
            using var shape = ConfigSearchSurface.RoundedRectangle(new RectangleF(0.5F, 0.5F, Width - 1, Height - 1), 5);
            using var fill = new SolidBrush(fillColor);
            e.Graphics.FillPath(fill, shape);
            if (primary || updateNotice || FlatAppearance.BorderSize > 0)
            {
                using var border = new Pen(updateNotice ? noticeFill : primary ? PrimaryActionColor : FlatAppearance.BorderColor, primary || updateNotice ? 1 : FlatAppearance.BorderSize);
                e.Graphics.DrawPath(border, shape);
            }
            if (updateNotice)
            {
                var badgeSize = TextRenderer.MeasureText("NEW", Font, Size.Empty, TextFormatFlags.SingleLine | TextFormatFlags.NoPadding);
                var badge = new Rectangle(Width - badgeSize.Width - 21, (Height - Font.Height - 6) / 2, badgeSize.Width + 12, Font.Height + 6);
                using var badgeBorder = new Pen(textColor);
                e.Graphics.DrawRectangle(badgeBorder, badge);
                TextRenderer.DrawText(e.Graphics, "NEW", Font, badge, textColor,
                    TextFormatFlags.SingleLine | TextFormatFlags.HorizontalCenter | TextFormatFlags.VerticalCenter | TextFormatFlags.NoPadding);
                var updateIconSize = Math.Min(18, Math.Max(12, Height - 14));
                DrawToolbarIcon(e.Graphics, ToolbarIconKind.Import, new Rectangle(9, (Height - updateIconSize) / 2, updateIconSize, updateIconSize), textColor);
                var textLeft = 9 + updateIconSize + 7;
                TextRenderer.DrawText(e.Graphics, Text, Font, new Rectangle(textLeft, 0, Math.Max(1, badge.Left - textLeft - 7), Height), textColor,
                    TextFormatFlags.SingleLine | TextFormatFlags.VerticalCenter | TextFormatFlags.NoPadding | TextFormatFlags.EndEllipsis);
                if (Focused) ControlPaint.DrawFocusRectangle(e.Graphics, Rectangle.Inflate(ClientRectangle, -4, -4), textColor, fillColor);
                return;
            }
            if (Text is "Dark mode" or "Light mode")
            {
                DrawCategoryIcon(e.Graphics, Text == "Dark mode" ? "Moon" : "Sun",
                    new Rectangle((Width - 18) / 2, (Height - 18) / 2, 18, 18), textColor);
                if (Focused) ControlPaint.DrawFocusRectangle(e.Graphics, Rectangle.Inflate(ClientRectangle, -5, -5), textColor, fillColor);
                return;
            }
            var iconName = Text switch
            {
                "Add row" => "Add", "Remove selected" => "Remove", "Presets..." => "Presets",
                "Manage ▼" => "Mission options", "Copy To..." => "Copy", "Comments" => "Message Of The Day",
                _ => ""
            };
            var iconSize = Math.Min(18, Math.Max(12, Height - 14));
            var textSize = TextRenderer.MeasureText(Text, Font, Size.Empty, TextFormatFlags.SingleLine | TextFormatFlags.NoPadding);
            var gap = iconName.Length == 0 ? 0 : iconSize + 7;
            var left = Math.Max(7, (Width - textSize.Width - gap) / 2);
            if (gap > 0) DrawCategoryIcon(e.Graphics, iconName,
                new Rectangle(left, (Height - iconSize) / 2, iconSize, iconSize), textColor);
            TextRenderer.DrawText(e.Graphics, Text, Font, new Rectangle(left + gap, 0, Math.Max(0, Width - left - gap - 7), Height),
                textColor, TextFormatFlags.SingleLine | TextFormatFlags.VerticalCenter | TextFormatFlags.EndEllipsis | TextFormatFlags.NoPadding);
            if (Focused) ControlPaint.DrawFocusRectangle(e.Graphics, Rectangle.Inflate(ClientRectangle, -5, -5), textColor, fillColor);
        }
    }

    private void UpdateTemplateHeading(Control editor, DesignerItem item)
    {
        var header = editor.Tag is TableEditorBinding binding ? binding.Header
            : editor.Controls.OfType<FlowLayoutPanel>().FirstOrDefault();
        var label = header?.Controls.OfType<Label>().FirstOrDefault();
        if (label is null) return;
        label.Text = item.Label;
    }

    private void ApplyTemplateAppearance(Control editor, DesignerItem item)
    {
        UpdateTemplateHeading(editor, item);
        static void ApplyGridAppearance(DataGridView grid)
        {
            if (grid.Columns.Count == 2 && grid.Columns[1] is DataGridViewCheckBoxColumn)
            {
                grid.Columns[0].HeaderText = "Template name";
                grid.Columns[1].DefaultCellStyle.Alignment = DataGridViewContentAlignment.MiddleCenter;
            }
        }
        if (editor.Tag is TableEditorBinding binding)
        {
            ApplyGridAppearance(binding.Grid);
            return;
        }

        foreach (var grid in EnumerateChildControls<DataGridView>(editor))
        {
            ApplyGridAppearance(grid);
        }
    }

    private static void DrawCategoryIcon(Graphics graphics, string name, Rectangle bounds, Color color)
    {
        var saved = graphics.Save();
        graphics.TranslateTransform(bounds.X, bounds.Y);
        graphics.ScaleTransform(bounds.Width / 20F, bounds.Height / 20F);
        graphics.SmoothingMode = SmoothingMode.AntiAlias;
        using var pen = new Pen(color, 1.35F) { StartCap = LineCap.Round, EndCap = LineCap.Round, LineJoin = LineJoin.Round };
        void Lines(params PointF[] points) => graphics.DrawLines(pen, points);
        switch (name)
        {
            case "Moon":
                graphics.DrawArc(pen, 3, 3, 14, 14, 35, 280);
                graphics.DrawArc(pen, 7, 0, 13, 13, 83, 204); break;
            case "Sun":
                graphics.DrawEllipse(pen, 6, 6, 8, 8);
                for (var i = 0; i < 8; i++) { var a = i * Math.PI / 4; graphics.DrawLine(pen,
                    10 + (float)Math.Cos(a) * 7, 10 + (float)Math.Sin(a) * 7, 10 + (float)Math.Cos(a) * 9, 10 + (float)Math.Sin(a) * 9); } break;
            case "Add":
            case "CSAR":
                graphics.DrawLine(pen, 10, 3, 10, 17); graphics.DrawLine(pen, 3, 10, 17, 10); break;
            case "Remove":
                graphics.DrawRectangle(pen, 6, 6, 9, 11); graphics.DrawLine(pen, 4, 4, 17, 4);
                graphics.DrawLine(pen, 8, 2, 13, 2); graphics.DrawLine(pen, 9, 8, 9, 14); graphics.DrawLine(pen, 12, 8, 12, 14); break;
            case "Presets":
                foreach (var x in new[] { 3, 12 }) foreach (var y in new[] { 3, 12 }) graphics.DrawRectangle(pen, x, y, 5, 5); break;
            case "Copy":
                graphics.DrawRectangle(pen, 3, 3, 10, 12); graphics.DrawRectangle(pen, 7, 7, 10, 12); break;
            case "Mission options":
                graphics.DrawEllipse(pen, 5, 5, 10, 10); graphics.DrawEllipse(pen, 8, 8, 4, 4);
                for (var i = 0; i < 8; i++) { var a = i * Math.PI / 4; graphics.DrawLine(pen,
                    10 + (float)Math.Cos(a) * 6, 10 + (float)Math.Sin(a) * 6, 10 + (float)Math.Cos(a) * 9, 10 + (float)Math.Sin(a) * 9); } break;
            case "Difficulty":
                graphics.DrawRectangle(pen, 3, 12, 3, 5); graphics.DrawRectangle(pen, 8, 8, 3, 9); graphics.DrawRectangle(pen, 13, 3, 3, 14); break;
            case "Difficulty advanced":
                for (var i = 0; i < 3; i++) { var y = 4 + i * 6; graphics.DrawLine(pen, 2, y, 18, y); graphics.DrawEllipse(pen, i == 1 ? 5 : 12, y - 2, 4, 4); } break;
            case "Message Of The Day":
                Lines(new(3, 3), new(17, 3), new(17, 14), new(8, 14), new(3, 18), new(3, 3)); break;
            case "Welcome Message Callsigns":
                graphics.DrawEllipse(pen, 7, 2, 6, 6); graphics.DrawArc(pen, 3, 10, 14, 14, 180, 180); graphics.DrawLine(pen, 3, 17, 17, 17); break;
            case "Escort":
            case "Aircraft / Weapons":
                Lines(new(10, 2), new(12, 8), new(18, 12), new(18, 14), new(12, 12), new(12, 16), new(14, 18), new(10, 17),
                    new(6, 18), new(8, 16), new(8, 12), new(2, 14), new(2, 12), new(8, 8), new(10, 2)); break;
            case "Logistics / Warehouse":
                Lines(new(3, 6), new(10, 2), new(17, 6), new(17, 14), new(10, 18), new(3, 14), new(3, 6), new(10, 10), new(17, 6));
                graphics.DrawLine(pen, 10, 10, 10, 18); break;
            case "Shop / Rewards":
                Lines(new(2, 3), new(4, 3), new(6, 13), new(16, 13), new(18, 6), new(5, 6));
                graphics.DrawEllipse(pen, 6, 16, 2, 2); graphics.DrawEllipse(pen, 14, 16, 2, 2); break;
            case "CTLD":
                graphics.DrawRectangle(pen, 2, 5, 10, 10); graphics.DrawRectangle(pen, 12, 9, 6, 6);
                graphics.DrawEllipse(pen, 4, 14, 4, 4); graphics.DrawEllipse(pen, 13, 14, 4, 4); break;
            case "Flight Time":
                graphics.DrawEllipse(pen, 2, 2, 16, 16); Lines(new(10, 5), new(10, 10), new(14, 12)); break;
            case "Tankers":
                graphics.DrawRectangle(pen, 4, 3, 9, 15); graphics.DrawRectangle(pen, 6, 5, 5, 4);
                Lines(new(13, 5), new(17, 8), new(17, 15), new(15, 15), new(15, 10)); break;
            case "EWRS":
                graphics.DrawLine(pen, 10, 8, 10, 18); graphics.DrawEllipse(pen, 8, 5, 4, 4);
                graphics.DrawArc(pen, 4, 2, 12, 12, 130, 100); graphics.DrawArc(pen, 4, 2, 12, 12, -50, 100);
                graphics.DrawArc(pen, 1, -1, 18, 18, 135, 90); graphics.DrawArc(pen, 1, -1, 18, 18, -45, 90); break;
            case "AIEN":
                graphics.DrawRectangle(pen, 5, 5, 10, 10);
                for (var i = 0; i < 3; i++) { var d = 7 + i * 3; graphics.DrawLine(pen, d, 2, d, 5); graphics.DrawLine(pen, d, 15, d, 18);
                    graphics.DrawLine(pen, 2, d, 5, d); graphics.DrawLine(pen, 15, d, 18, d); } break;
            case "F10 Map":
                Lines(new(2, 4), new(7, 2), new(13, 5), new(18, 3), new(18, 16), new(13, 18), new(7, 15), new(2, 17), new(2, 4));
                graphics.DrawLine(pen, 7, 2, 7, 15); graphics.DrawLine(pen, 13, 5, 13, 18); break;
            case "Frequencies":
                graphics.DrawRectangle(pen, 2, 7, 16, 10); graphics.DrawLine(pen, 4, 7, 14, 2);
                graphics.DrawEllipse(pen, 5, 10, 4, 4); graphics.DrawLine(pen, 12, 10, 15, 10);
                graphics.DrawLine(pen, 12, 13, 15, 13); break;
            case "Carriers":
                graphics.DrawLine(pen, 2, 10, 18, 10); graphics.DrawLine(pen, 3, 10, 5, 16);
                graphics.DrawLine(pen, 5, 16, 15, 16); graphics.DrawLine(pen, 15, 16, 18, 10);
                graphics.DrawRectangle(pen, 11, 6, 4, 4); graphics.DrawLine(pen, 13, 3, 13, 6);
                graphics.DrawLine(pen, 3, 13, 17, 13); break;
            case "Admin Commands":
                graphics.DrawRectangle(pen, 2, 3, 16, 14);
                graphics.DrawLine(pen, 5, 7, 8, 10); graphics.DrawLine(pen, 8, 10, 5, 13);
                graphics.DrawLine(pen, 11, 13, 15, 13); break;
            default:
                graphics.DrawRectangle(pen, 5, 2, 11, 16); graphics.DrawLine(pen, 8, 6, 13, 6);
                graphics.DrawLine(pen, 8, 10, 13, 10); graphics.DrawLine(pen, 8, 14, 13, 14); break;
        }
        graphics.Restore(saved);
    }
}
