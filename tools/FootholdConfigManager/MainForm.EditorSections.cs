using System.Drawing;
using System.Windows.Forms;

namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private bool _layingOutEditorContent;
    private bool _editorViewportLayoutPending;

    private Button? _editorWidthGrip;
    private bool _editorWidthDragging;
    private int _editorWidthStartX;
    private int _editorWidthStartWidth;
    private int _editorWidthStartPreference;

    private void InitializeEditorWidthGrip()
    {
        var grip = new PreviewButton
        {
            Name = "EditorWidthGrip", Text = "", Width = Zoomed(10), Cursor = Cursors.SizeWE,
            FlatStyle = FlatStyle.Flat, TabStop = true, Visible = false,
            AccessibleName = "Resize editor width for all categories",
            AccessibleDescription = "Drag, or use Left and Right. Home restores automatic width."
        };
        grip.FlatAppearance.BorderSize = 0;
        _editorWidthGrip = grip;
        _formHost.Parent!.Controls.Add(grip);
        _toolTip.SetToolTip(grip, "Resize editor width for all categories. Double-click or press Home for automatic width.");
        grip.Paint += (_, e) =>
        {
            using var pen = new Pen(grip.Focused || _editorWidthDragging ? HelpTextColor : BorderColor, 2);
            e.Graphics.DrawLine(pen, grip.Width / 2, 4, grip.Width / 2, Math.Max(4, grip.Height - 4));
        };
        grip.MouseDown += (_, e) =>
        {
            if (e.Button != MouseButtons.Left || _formHost.Controls.Count != 1 || _formHost.Controls[0] is not TableLayoutPanel panel) return;
            if (e.Clicks == 2) { ResetEditorContentWidth(); return; }
            _editorWidthStartX = grip.PointToScreen(e.Location).X;
            _editorWidthStartWidth = panel.ClientSize.Width - panel.Padding.Horizontal;
            _editorWidthStartPreference = _settings.EditorContentWidth;
            _editorWidthDragging = true;
            grip.Capture = true;
        };
        grip.MouseMove += (_, e) =>
        {
            if (_editorWidthDragging && (grip.PointToScreen(e.Location).X != _editorWidthStartX || _settings.EditorContentWidth != _editorWidthStartPreference))
                SetEditorContentWidth(_editorWidthStartWidth + 2 * (grip.PointToScreen(e.Location).X - _editorWidthStartX));
        };
        void FinishDrag()
        {
            if (!_editorWidthDragging) return;
            _editorWidthDragging = false;
            grip.Capture = false;
            if (_settings.EditorContentWidth != _editorWidthStartPreference) SaveEditorLayoutPreferences();
            grip.Invalidate();
        }
        grip.MouseUp += (_, e) => { if (e.Button == MouseButtons.Left) FinishDrag(); };
        grip.MouseCaptureChanged += (_, _) => { if (!grip.Capture) FinishDrag(); };
        grip.PreviewKeyDown += (_, e) => e.IsInputKey = e.KeyCode is Keys.Left or Keys.Right or Keys.Home;
        grip.KeyDown += (_, e) =>
        {
            if (e.KeyCode == Keys.Home) ResetEditorContentWidth();
            else if (e.KeyCode is Keys.Left or Keys.Right && _formHost.Controls.Count == 1 && _formHost.Controls[0] is TableLayoutPanel panel)
            {
                SetEditorContentWidth(panel.ClientSize.Width - panel.Padding.Horizontal + (e.KeyCode == Keys.Right ? Zoomed(20) : -Zoomed(20)));
                SaveEditorLayoutPreferences();
            }
            else return;
            e.Handled = true;
            e.SuppressKeyPress = true;
        };
    }

    private void PositionEditorWidthGrip(TableLayoutPanel panel)
    {
        if (_editorWidthGrip is not { } grip || !ReferenceEquals(panel.Parent, _formHost)) return;
        var left = _formHost.Left + panel.Right - panel.Padding.Right + Zoomed(4);
        var top = Zoomed(50);
        grip.SetBounds(left, top, Zoomed(10), Math.Max(Zoomed(30), _formHost.ClientSize.Height - top - Zoomed(30)));
        grip.BackColor = MainBackground;
        grip.Visible = left >= 0 && grip.Right <= grip.Parent!.ClientSize.Width;
        grip.BringToFront();
    }

    private void SetEditorContentWidth(int physicalWidth)
    {
        _settings.EditorContentWidth = Math.Clamp((int)Math.Round(physicalWidth * UiZoomBaselinePercent / _uiZoomPercent), 1075, 4500);
        if (_formHost.Controls.Count == 1 && _formHost.Controls[0] is TableLayoutPanel { Name: "EditorContent" } panel)
            LayoutEditorContent(panel);
    }

    private void SaveEditorLayoutPreferences() => _settings.Save();

    private void ResetEditorContentWidth()
    {
        _settings.EditorContentWidth = 0;
        if (_formHost.Controls.Count == 1 && _formHost.Controls[0] is TableLayoutPanel { Name: "EditorContent" } panel)
            LayoutEditorContent(panel);
        SaveEditorLayoutPreferences();
    }


    private void LayoutEditorContent(TableLayoutPanel panel, bool force = false)
    {
        if (_layingOutEditorContent || panel.ClientSize.Width <= 0) return;

        var gap = Zoomed(15);
        var minimum = Math.Max(0, panel.MinimumSize.Width - panel.Padding.Horizontal);
        // Keep the editor width fixed while the clipped native scrollbar appears or disappears.
        var scrollInset = ReferenceEquals(panel.Parent, _formHost) && _formHost.Parent is WeatherScrollHost scrollHost
            ? _formHost.ClientSize.Width - scrollHost.ClientSize.Width : 0;
        var viewport = ReferenceEquals(panel.Parent, _formHost)
            ? _formHost.ClientSize.Width - _formHost.Padding.Horizontal - scrollInset : panel.ClientSize.Width;
        var inset = Math.Max(Zoomed(60), (int)Math.Round(viewport * 0.12));
        var available = Math.Max(0, viewport - inset * 2);
        if (_settings.EditorContentWidth > 0)
        {
            available = Math.Min(available, Zoomed(_settings.EditorContentWidth));
            inset = Math.Max(inset, (viewport - available) / 2);
        }
        // Keep the accepted reference size per column; extra room changes layout, not typography.
        var columns = Math.Clamp((available + gap) / (Zoomed(1150) + gap), 1, 3);
        var padding = new Padding(inset, panel.Padding.Top, inset, panel.Padding.Bottom);
        var maximum = new Size(Math.Max(minimum + padding.Horizontal, viewport), 0);
        if (!force && panel.ColumnCount == columns)
        {
            if (panel.Padding != padding || panel.MaximumSize != maximum)
            {
                EditorSection.RunLayoutPass(() =>
                {
                    _layingOutEditorContent = true;
                    var owner = panel.Parent;
                    owner?.SuspendLayout();
                    panel.SuspendLayout();
                    try
                    {
                        panel.MaximumSize = maximum;
                        panel.Padding = padding;
                        panel.MinimumSize = new Size(minimum + padding.Horizontal, panel.MinimumSize.Height);
                        if (ReferenceEquals(owner, _formHost))
                        {
                            _formHost.AutoScrollMinSize = new Size(panel.MinimumSize.Width, 0);
                        }
                    }
                    finally
                    {
                        panel.ResumeLayout(false);
                        owner?.ResumeLayout(false);
                        try {
                            panel.PerformLayout();
                            owner?.PerformLayout();
                        }
                        finally { _layingOutEditorContent = false; }
                    }
                });
            }
            PositionEditorWidthGrip(panel);
            ReconcileEditorViewportAfterLayout(panel, viewport + scrollInset);
            return;
        }
        _layingOutEditorContent = true;
        panel.SuspendLayout();
        try
        {
            panel.MaximumSize = maximum;
            panel.Padding = padding;
            panel.MinimumSize = new Size(minimum + padding.Horizontal, panel.MinimumSize.Height);
            panel.ColumnCount = columns;
            panel.ColumnStyles.Clear();
            for (var column = 0; column < columns; column++)
                panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100F / columns));
            var row = 0;
            var warehouse = panel.Controls[WarehouseWeaponEditorName];
            foreach (var child in panel.Controls.Cast<Control>().Where(child => child is not EditorSection && child != warehouse))
            {
                panel.SetCellPosition(child, new TableLayoutPanelCellPosition(0, row++));
                panel.SetColumnSpan(child, columns);
            }
            var sections = panel.Controls.OfType<EditorSection>().ToArray();
            var warehouseAfter = warehouse is null ? null :
                sections.FirstOrDefault(section => section.Key == "ForbiddWeaponsInAllEra");
            var tabIndex = 0;
            bool CanShareRow(EditorSection section)
            {
                if (ReferenceEquals(section, warehouseAfter) || !section.Collapsible ||
                    section.Body.MinimumSize.Width > available / columns) return false;
                var grids = EnumerateChildControls<DataGridView>(section.Body).Take(2).ToArray();
                return grids.Length == 1 && grids[0].Columns.GetColumnCount(DataGridViewElementStates.Visible) <= 2;
            }
            void Place(EditorSection section, int column, int span)
            {
                section.TabIndex = tabIndex++;
                panel.SetCellPosition(section, new TableLayoutPanelCellPosition(column, row));
                panel.SetColumnSpan(section, span);
                section.Margin = new Padding(0, 0, column + span < columns ? gap : 0, gap);
            }
            void PlaceWarehouse()
            {
                if (warehouse is null) return;
                warehouse.TabIndex = tabIndex++;
                panel.SetCellPosition(warehouse, new TableLayoutPanelCellPosition(0, row++));
                panel.SetColumnSpan(warehouse, columns);
            }
            for (var index = 0; index < sections.Length;)
            {
                var section = sections[index];
                if (columns == 1 || !CanShareRow(section))
                {
                    Place(section, 0, columns);
                    if (!section.Collapsible) section.ArrangeSettingsColumns(columns);
                    index++;
                    row++;
                    if (ReferenceEquals(section, warehouseAfter)) PlaceWarehouse();
                    continue;
                }
                var end = index + 1;
                while (end < sections.Length && CanShareRow(sections[end])) end++;
                while (index < end)
                {
                    var count = Math.Min(columns, end - index);
                    var column = 0;
                    for (var slot = 0; slot < count; slot++)
                    {
                        var span = (columns - column) / (count - slot);
                        Place(sections[index++], column, span);
                        column += span;
                    }
                    row++;
                }
            }
            if (warehouseAfter is null) PlaceWarehouse();
            panel.RowCount = row;
            if (ReferenceEquals(panel.Parent, _formHost))
                _formHost.AutoScrollMinSize = new Size(panel.MinimumSize.Width, 0);
        }
        finally
        {
            try { EditorSection.RunLayoutPass(() => panel.ResumeLayout(true)); }
            finally { _layingOutEditorContent = false; }
        }
        PositionEditorWidthGrip(panel);
        ReconcileEditorViewportAfterLayout(panel, viewport + scrollInset);
    }
    private void ReconcileEditorViewportAfterLayout(TableLayoutPanel panel, int viewport)
    {
        if (_editorViewportLayoutPending || !ReferenceEquals(panel.Parent, _formHost) || !_formHost.IsHandleCreated ||
            viewport == _formHost.ClientSize.Width - _formHost.Padding.Horizontal) return;
        _editorViewportLayoutPending = true;
        _formHost.BeginInvoke((Action)(() =>
        {
            try { if (!panel.IsDisposed && ReferenceEquals(panel.Parent, _formHost)) LayoutEditorContent(panel); }
            finally { _editorViewportLayoutPending = false; }
        }));
    }
    private void ApplySavedEditorGridWidths(DataGridView grid)
    {
        if (grid.Tag is not string key || _settings.EditorGridColumnWidths.GetValueOrDefault(key) is not { } widths) return;
        foreach (DataGridViewColumn column in grid.Columns)
        {
            if (!widths.TryGetValue(column.Name, out var width) || width <= 0) continue;
            if (column.AutoSizeMode != DataGridViewAutoSizeColumnMode.None) column.AutoSizeMode = DataGridViewAutoSizeColumnMode.None;
            var physicalWidth = Math.Max(column.MinimumWidth, Zoomed(Math.Clamp(width, 40, 4500)));
            if (column.Width != physicalWidth) column.Width = physicalWidth;
        }
    }

    private void ReconcileEditorGridLayout(DataGridView grid)
    {
        if (grid.Parent is TableLayoutPanel { Tag: TableEditorBinding } group)
        {
            ApplyCompactTableLayout(group, grid);
            if (ContainingEditorSection(group) is { } section)
                section.Body.MinimumSize = new Size(group.MinimumSize.Width + section.Body.Padding.Horizontal, 0);
        }
        for (var parent = grid.Parent; parent is not null; parent = parent.Parent)
        {
            if (parent is not TableLayoutPanel { Name: "EditorContent" } content) continue;
            var sections = content.Controls.OfType<EditorSection>().ToArray();
            if (sections.Length > 0)
                content.MinimumSize = new Size(sections.Max(section => section.Body.MinimumSize.Width) + content.Padding.Horizontal, 0);
            LayoutEditorContent(content, force: true);
            break;
        }
    }
    private void ResetEditorGridColumnWidths(DataGridView grid)
    {
        _settings.EditorGridColumnWidths.Remove((string)grid.Tag!);
        // Reuse the grid's retained default-layout handler, including font-dependent measurements.
        ((SmoothDataGridView)grid).OnColumnWidthPreferencesReset();
        ReconcileEditorGridLayout(grid);
        SaveEditorLayoutPreferences();
    }

    private void ConfigureEditorGridPreferences(Control panel)
    {
        foreach (var grid in EnumerateChildControls<DataGridView>(panel).Cast<SmoothDataGridView>())
        {
            if (grid.Tag is not string key) continue;
            var defaults = grid.Columns.Cast<DataGridViewColumn>()
                .ToDictionary(column => column.Name, column => (column.AutoSizeMode, column.Width, column.FillWeight), StringComparer.Ordinal);
            var choices = grid.Columns.OfType<DataGridViewComboBoxColumn>().ToArray();
            foreach (var choice in choices) ConfigureFillColumn(choice, choice.Width);
            grid.AllowUserToResizeColumns = true;
            grid.ScrollBars = ScrollBars.Both;
            foreach (DataGridViewColumn column in grid.Columns) column.Resizable = DataGridViewTriState.True;
            var applying = false;
            var changed = false;
            string? draggedColumn = null;
            Font? measuredValueFont = null;
            Font? measuredHeaderFont = null;
            var choiceWidths = new Dictionary<string, int>(StringComparer.Ordinal);
            void RestoreWidths(bool force = false)
            {
                if (applying || grid.IsDisposed || grid.Disposing) return;
                var headerFont = grid.ColumnHeadersDefaultCellStyle.Font ?? grid.Font;
                var valueFont = grid.DefaultCellStyle.Font ?? grid.Font;
                if (!force && ReferenceEquals(valueFont, measuredValueFont) && ReferenceEquals(headerFont, measuredHeaderFont))
                {
                    ApplySavedEditorGridWidths(grid);
                    return;
                }
                applying = true;
                grid.SuspendLayout();
                try
                {

                    if (!ReferenceEquals(valueFont, measuredValueFont) || !ReferenceEquals(headerFont, measuredHeaderFont))
                    {
                        measuredValueFont = valueFont;
                        measuredHeaderFont = headerFont;
                        foreach (var choice in choices)
                            choiceWidths[choice.Name] = Math.Max(GetTableHeaderWidth(choice, headerFont),
                                Math.Max(choice.GetPreferredWidth(DataGridViewAutoSizeColumnMode.AllCells, true) + 12,
                                    choice.Items.Cast<object>().Select(item => TextRenderer.MeasureText(item.ToString(), valueFont,
                                        Size.Empty, TextFormatFlags.SingleLine | TextFormatFlags.NoPadding | TextFormatFlags.NoPrefix).Width)
                                        .DefaultIfEmpty(0).Max() + 36));
                    }
                    foreach (DataGridViewColumn column in grid.Columns)
                    {
                        column.MinimumWidth = Math.Max(40, GetTableHeaderWidth(column, headerFont));
                        column.AutoSizeMode = defaults[column.Name].AutoSizeMode;
                        column.FillWeight = defaults[column.Name].FillWeight;
                        if (column.AutoSizeMode != DataGridViewAutoSizeColumnMode.Fill)
                            column.Width = Math.Max(column.MinimumWidth, defaults[column.Name].Width);
                    }
                    var visibleChoices = choices.Where(column => column.Visible).ToArray();
                    if (visibleChoices.Length > 0 && grid.Columns["name"] is { } name)
                    {
                        ConfigureFixedColumn(name, Math.Max(name.MinimumWidth, Zoomed(275)));
                        name.MinimumWidth = GetTableHeaderWidth(name, headerFont);
                        foreach (var choice in choices)
                        {
                            choice.MinimumWidth = choiceWidths[choice.Name];
                            choice.Tag = choice.MinimumWidth;
                            choice.AutoSizeMode = DataGridViewAutoSizeColumnMode.None;
                            choice.Width = choice.MinimumWidth;
                        }
                        visibleChoices[^1].AutoSizeMode = DataGridViewAutoSizeColumnMode.Fill;
                    }
                    ApplySavedEditorGridWidths(grid);
                }
                finally { grid.ResumeLayout(); applying = false; }
            }
            void FinishResize()
            {
                draggedColumn = null;
                if (!changed) return;
                changed = false;
                RestoreWidths();
                ReconcileEditorGridLayout(grid);
                SaveEditorLayoutPreferences();
            }
            grid.MouseDown += (_, e) =>
            {
                if (e.Button != MouseButtons.Left) return;
                var hit = grid.HitTest(e.X, e.Y);
                if (hit.Type != DataGridViewHitTestType.ColumnHeader || hit.ColumnIndex < 0) return;
                var column = grid.Columns[hit.ColumnIndex];
                var bounds = grid.GetColumnDisplayRectangle(column.Index, false);
                if (Math.Abs(e.X - bounds.Left) < 5)
                    column = grid.Columns.GetPreviousColumn(column, DataGridViewElementStates.Visible, DataGridViewElementStates.None) ?? column;
                draggedColumn = column.Name;
            };
            grid.ColumnWidthChanged += (_, e) =>
            {
                if (applying || e.Column.Name != draggedColumn) return;
                if (!_settings.EditorGridColumnWidths.TryGetValue(key, out var widths) || widths is null)
                    _settings.EditorGridColumnWidths[key] = widths = new(StringComparer.Ordinal);
                widths[e.Column.Name] = Math.Clamp((int)Math.Round(e.Column.Width * UiZoomBaselinePercent / _uiZoomPercent), 40, 4500);
                changed = true;
            };
            grid.MouseUp += (_, _) => FinishResize();
            grid.MouseCaptureChanged += (_, _) => { if (!grid.Capture) FinishResize(); };
            grid.FontChanged += (_, _) => RestoreWidths();
            grid.DefaultCellStyleChanged += (_, _) => RestoreWidths();
            grid.ColumnHeadersDefaultCellStyleChanged += (_, _) => RestoreWidths();
            grid.VisibleChanged += (_, _) => { if (grid.Visible) ApplySavedEditorGridWidths(grid); };
            grid.ColumnStateChanged += (_, e) => { if (e.StateChanged == DataGridViewElementStates.Visible) RestoreWidths(force: true); };
            grid.ColumnWidthPreferencesReset += (_, _) => RestoreWidths(force: true);
            grid.ColumnHeaderMouseClick += (_, e) =>
            {
                if (e.Button != MouseButtons.Right) return;
                var menu = new ContextMenuStrip { ShowImageMargin = false };
                menu.Items.Add("Reset column widths", null, (_, _) => ResetEditorGridColumnWidths(grid));
                menu.Closed += (_, _) => menu.Dispose();
                StyleToolbarMenu(menu);
                menu.Show(grid, grid.PointToClient(Cursor.Position));
            };
            RestoreWidths();
        }
    }
    // Share the existing single-operation measurement scope with nested editor layouts.
    private sealed class EditorLayoutPanel : TableLayoutPanel
    {
        private int _layoutGeneration;
        protected override void OnLayout(LayoutEventArgs e)
        {
            WarehouseLayoutProbe.Count(WarehouseLayoutProbe.Counter.EditorLayout);
            _layoutGeneration++;
            base.OnLayout(e);
        }
        protected override void OnSizeChanged(EventArgs e) { _layoutGeneration++; base.OnSizeChanged(e); }
        protected override void OnFontChanged(EventArgs e) { _layoutGeneration++; base.OnFontChanged(e); }
        protected override void OnPaddingChanged(EventArgs e) { _layoutGeneration++; base.OnPaddingChanged(e); }
        protected override void OnControlAdded(ControlEventArgs e) { _layoutGeneration++; base.OnControlAdded(e); }
        protected override void OnControlRemoved(ControlEventArgs e) { _layoutGeneration++; base.OnControlRemoved(e); }
        public override Size GetPreferredSize(Size proposedSize)
        {
            WarehouseLayoutProbe.Count(WarehouseLayoutProbe.Counter.EditorMeasure);
            var measurements = EditorSection._expansionMeasurements;
            var generation = _layoutGeneration;
            var key = ((TableLayoutPanel)this, proposedSize, ClientSize.Width, false, generation, MinimumSize, MaximumSize);
            if (measurements is not null && measurements.TryGetValue(key, out var previous)) return previous;
            var size = base.GetPreferredSize(proposedSize);
            if (measurements is not null && generation == _layoutGeneration && key.Width == ClientSize.Width)
                measurements[key] = size;
            return size;
        }
    }
    // Presentation state belongs to retained category controls, not a second data cache.
    private sealed class EditorSection : TableLayoutPanel
    {
        [ThreadStatic]
        internal static Dictionary<(TableLayoutPanel Section, Size Proposed, int Width, bool Expanded, int Generation, Size Minimum, Size Maximum), Size>? _expansionMeasurements;
        private readonly TableLayoutPanel _heading;
        private readonly Button? _toggle;
        private readonly int _inset;
        private System.Drawing.Drawing2D.GraphicsPath? _outline;
        private bool _expanded = true;
        internal readonly TableLayoutPanel Body;
        internal string Key { get; }
        internal bool Collapsible { get; }
        internal bool NeedsPalette { get; private set; } = true;
        internal FlowLayoutPanel? EditorHeader { get; private set; }

        public bool Expanded
        {
            get => _expanded;
            set
            {
                if (!Collapsible || _expanded == value) return;
                SuspendLayout();
                _expanded = value;
                Body.Visible = value;
                RowStyles[1].SizeType = value ? SizeType.AutoSize : SizeType.Absolute;
                RowStyles[1].Height = 0;
                _toggle!.Text = value ? "▾" : "▸";
                _toggle.AccessibleName = (value ? "Collapse " : "Expand ") + AccessibleName;
                // TableLayout asks repeatedly for the same retained sections in one pass.
                // Keep measurements only until this expansion/collapse finishes.
                RunLayoutPass(() => ResumeLayout(true));
            }
        }

        internal static void RunLayoutPass(Action layout)
        {
            var previous = _expansionMeasurements;
            _expansionMeasurements ??= new();
            try { layout(); }
            finally { _expansionMeasurements = previous; }
        }

        internal EditorSection(string key, string title, bool collapsible, int inset, Font? font)
        {
            Key = key;
            Collapsible = collapsible;
            _inset = inset;
            Name = "EditorSection:" + key;
            AccessibleName = title;
            Dock = DockStyle.Top;
            AutoSize = true;
            AutoSizeMode = AutoSizeMode.GrowAndShrink;
            ColumnCount = 1;
            RowCount = 2;
            Padding = new Padding(1);
            Margin = new Padding(0, 0, 0, inset);
            ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            RowStyles.Add(new RowStyle(SizeType.AutoSize));
            RowStyles.Add(new RowStyle(SizeType.AutoSize));
            _heading = new EditorLayoutPanel { Dock = DockStyle.Top, AutoSize = true,
                ColumnCount = collapsible ? 2 : 1, Margin = new Padding(0), Padding = new Padding(inset, inset * 3 / 4, inset, inset * 3 / 4) };
            if (collapsible)
            {
                _heading.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
                _toggle = new PreviewButton { Text = "▾", AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink,
                    FlatStyle = FlatStyle.Flat, Padding = new Padding(1), Margin = new Padding(0, 0, inset / 2, 0),
                    AccessibleName = "Collapse " + title, UseVisualStyleBackColor = false };
                _toggle.FlatAppearance.BorderSize = 0;
                _toggle.Click += (_, _) => Expanded = !Expanded;
                _heading.Controls.Add(_toggle, 0, 0);
            }
            _heading.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            if (!collapsible)
            {
                var label = new Label { Text = title, AutoSize = true, Margin = new Padding(0), Font = font! };
                _heading.Controls.Add(label);
                label.Disposed += (_, _) => font!.Dispose();
            }
            Body = new EditorLayoutPanel { Dock = DockStyle.Top, AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink,
                ColumnCount = 1, Padding = collapsible ? new Padding(inset) : Padding.Empty, Margin = new Padding(0, 1, 0, 0) };
            Body.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            Controls.Add(_heading, 0, 0);
            Controls.Add(Body, 0, 1);
            SetStyle(ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw, true);
        }

        internal void AttachEditor(Control editor, FlowLayoutPanel? header, int row = 0)
        {
            SuspendLayout();
            _heading.SuspendLayout();
            Body.SuspendLayout();
            try
            {
                if (header is not null && EditorHeader is null)
                {
                    EditorHeader = header;
                    var group = (TableLayoutPanel)editor;
                    group.Controls.Remove(header);
                    group.RowStyles[0].SizeType = SizeType.Absolute;
                    group.RowStyles[0].Height = 0;
                    header.AutoSize = true;
                    header.Dock = DockStyle.Top;
                    header.Margin = new Padding(0);
                    header.Padding = new Padding(0);
                    _heading.Controls.Add(header, 1, 0);
                    _heading.SetColumnSpan(header, 1);
                    _heading.SetRowSpan(header, 1);
                    _heading.SetCellPosition(header, new TableLayoutPanelCellPosition(1, 0));
                    _toggle!.Font = header.Controls.OfType<Label>().First().Font;
                    header.Controls.OfType<Label>().First().Click += (_, _) => Expanded = !Expanded;
                }
                if (!ReferenceEquals(editor.Parent, Body))
                {
                    Body.Controls.Add(editor);
                    NeedsPalette = true;
                }
                Body.SetRow(editor, row);
                Body.Controls.SetChildIndex(editor, row);
                editor.Margin = new Padding(0, Collapsible || row == 0 ? 0 : 1, 0, 0);
                editor.Padding = Collapsible ? Padding.Empty : new Padding(_inset, _inset * 2 / 3, _inset, _inset * 2 / 3);
                if (Collapsible)
                {
                    editor.Dock = DockStyle.Top;
                    Body.MinimumSize = new Size(editor.MinimumSize.Width + Body.Padding.Horizontal, 0);
                }
            }
            finally
            {
                _heading.ResumeLayout(false);
                Body.ResumeLayout(false);
                RunLayoutPass(() => ResumeLayout(true));
            }
        }

        internal void ArrangeSettingsColumns(int columns)
        {
            var editors = Body.Controls.Cast<Control>().ToArray();
            // Multiline/custom controls retain a whole row at their existing scale.
            if (editors.Any(editor => editor is not TableLayoutPanel { ColumnCount: 2 })) columns = 1;
            columns = Math.Max(1, Math.Min(columns, editors.Length));
            Body.SuspendLayout();
            try
            {
                Body.ColumnCount = columns;
                Body.ColumnStyles.Clear();
                for (var column = 0; column < columns; column++)
                    Body.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100F / columns));
                Body.RowCount = (editors.Length + columns - 1) / columns;
                Body.RowStyles.Clear();
                for (var row = 0; row < Body.RowCount; row++) Body.RowStyles.Add(new RowStyle(SizeType.AutoSize));
                for (var index = 0; index < editors.Length; index++)
                {
                    var column = index % columns;
                    Body.SetCellPosition(editors[index], new TableLayoutPanelCellPosition(column, index / columns));
                    var span = index == editors.Length - 1 ? columns - column : 1;
                    Body.SetColumnSpan(editors[index], span);
                    editors[index].Margin = new Padding(0, index >= columns ? 1 : 0, column + span < columns ? 1 : 0, 0);
                    editors[index].TabIndex = index;
                    editors[index].Dock = DockStyle.Fill;
                }
            }
            finally { Body.ResumeLayout(true); }
        }
        internal void ApplySectionPalette()
        {
            BackColor = Body.BackColor = _heading.BackColor = EditorBackground;
            ForeColor = PrimaryTextColor;
            foreach (var control in EnumerateChildControls<Control>(this))
            {
                if ((control is Panel or Label or CheckBox) &&
                    !Equals(control.Tag, ImportedNewHighlightTag) && !Equals(control.Tag, ImportedNewBadgeTag))
                    control.BackColor = EditorBackground;
                if (control is Label { Name: "SectionDescription" or "SectionExample" }) control.ForeColor = HelpTextColor;
            }
            if (!Collapsible) Body.BackColor = BorderColor;
            if (_toggle is not null)
            {
                _toggle.BackColor = EditorBackground;
                _toggle.ForeColor = PrimaryTextColor;
                _toggle.FlatAppearance.MouseOverBackColor = HeaderBackground;
                _toggle.FlatAppearance.MouseDownBackColor = SelectionBackground;
            }
            Invalidate();
            NeedsPalette = false;
        }

        protected override void OnSizeChanged(EventArgs args)
        {
            base.OnSizeChanged(args);
            _outline?.Dispose();
            _outline = Width < 2 || Height < 2 ? null :
                ConfigSearchSurface.RoundedRectangle(new RectangleF(.5f, .5f, Width - 1, Height - 1), 5);
            var previous = Region;
            Region = _outline is null ? null : new Region(_outline);
            previous?.Dispose();
        }

        public override Size GetPreferredSize(Size proposedSize)
        {
            WarehouseLayoutProbe.Count(WarehouseLayoutProbe.Counter.SectionMeasure);
            var measurements = _expansionMeasurements;
            var key = ((TableLayoutPanel)this, proposedSize, ClientSize.Width, _expanded, 0, MinimumSize, MaximumSize);
            if (measurements is not null && measurements.TryGetValue(key, out var previous)) return previous;
            var size = base.GetPreferredSize(proposedSize);
            if (measurements is not null) measurements[key] = size;
            return size;
        }

        protected override void OnPaint(PaintEventArgs args)
        {
            base.OnPaint(args);
            if (_outline is null) return;
            args.Graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
            using var pen = new Pen(BorderColor);
            args.Graphics.DrawPath(pen, _outline);
            if (Body.Visible) args.Graphics.DrawLine(pen, 1, _heading.Bottom, Width - 2, _heading.Bottom);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                var previous = Region;
                Region = null;
                previous?.Dispose();
                _outline?.Dispose();
                _outline = null;
            }
            base.Dispose(disposing);
        }
    }

    private static EditorSection? ContainingEditorSection(Control editor)
    {
        for (var parent = editor.Parent; parent is not null; parent = parent.Parent)
            if (parent is EditorSection section) return section;
        return null;
    }

    private static Control RevealEditorSection(Control editor)
    {
        if (ContainingEditorSection(editor) is not { Collapsible: true } section) return editor;
        section.Expanded = true;
        return section;
    }

    private void ArrangeEditorSections(TableLayoutPanel panel, string category, IReadOnlyList<DesignerItem> items, bool applyPalette = false)
    {
        if (panel.Tag is not Dictionary<string, OptionsMarkerTarget> targets) return;
        var existing = panel.Controls.OfType<EditorSection>().ToDictionary(section => section.Key, StringComparer.Ordinal);
        var retained = new List<EditorSection>();
        var warehouseLocations = panel.Controls[WarehouseWeaponEditorName];
        EditorSection? scalarSection = null;
        var scalarRow = 0;
        var revealNewItems = HasUnseenImportedNewEntries(category);
        foreach (var item in items)
        {
            if (!targets.TryGetValue(item.Key, out var target)) continue;
            var grid = item.IsGroup || item.StringListTable is not null || item.StageTable is not null;
            var missionHeading = !grid && category.Equals("Mission options", StringComparison.OrdinalIgnoreCase)
                ? item.Key switch
                {
                    "Era" or "PvP" or "FootholdLocale" => "General",
                    "StartNormal" or "StartFromIncirlik" or "RemoveSouthSyria" => "Starting conditions",
                    _ => "Mission rules"
                } : null;
            if (missionHeading is not null && scalarSection?.AccessibleName != missionHeading) scalarSection = null;
            var key = grid ? item.Key : scalarSection?.Key ?? "settings:" + item.Key;
            if (grid || scalarSection is null)
            {
                var collapseEmpty = item.StringListTable is { Key: "WarehouseWeaponCaps" or "ForbiddWeaponsInAllEra", Items.Count: 0 };
                if (!existing.TryGetValue(key, out var section))
                {
                    var title = grid ? target.Title.Text : missionHeading ?? (category.Equals("CSAR", StringComparison.OrdinalIgnoreCase) ? "Rescue settings"
                        : category.Equals("Ground Units", StringComparison.OrdinalIgnoreCase) ? (retained.Count == 0 ? "Ground groups and targets" : "Air defense behavior")
                        : category.Equals("AI Flights", StringComparison.OrdinalIgnoreCase) ? "Flight behavior"
                        : retained.Count == 0 ? "General settings" : "Additional settings");
                    section = new EditorSection(key, title, grid, Zoomed(15), grid ? null :
                        new Font(Font.FontFamily, (11.25F + EditorFontIncreasePoints) * _uiZoomPercent / 100F, FontStyle.Bold));
                    if (collapseEmpty ||
                        item.StringListTable is { } aircraft && IsEquipmentList(aircraft.Key) && !IsWeaponList(aircraft.Key) &&
                        target.Editor.Controls.Find("EquipmentChoices:" + aircraft.Key, searchAllChildren: true)
                            .FirstOrDefault() is DataGridView { RowCount: 0 })
                    {
                        section.Expanded = false;
                        collapseEmpty = true;
                    }
                }
                panel.Controls.Add(section);
                panel.SetRow(section, retained.Count + 1);
                panel.Controls.SetChildIndex(section, retained.Count + 1);
                retained.Add(section);
                scalarSection = grid ? null : section;
                scalarRow = 0;
                if (grid)
                {
                    section.AttachEditor(target.Editor, target.Header);
                    if (revealNewItems && !collapseEmpty) section.Expanded = true;
                    continue;
                }
            }
            scalarSection!.AttachEditor(target.Editor, null, scalarRow++);
        }
        foreach (var section in retained)
        {
            section.Body.RowCount = section.Body.Controls.Count;
            if (applyPalette && section.NeedsPalette) section.ApplySectionPalette();
        }
        foreach (var section in existing.Values.Where(section => !retained.Contains(section)))
            ControlTreeDisposer.Dispose(section, _toolTip);
        panel.RowCount = retained.Count + 1 + (warehouseLocations is null ? 0 : 1);
        if (warehouseLocations is not null)
        {
            panel.SetRow(warehouseLocations, retained.Count + 1);
            panel.Controls.SetChildIndex(warehouseLocations, retained.Count + 1);
        }
        var minimum = retained.Select(section => section.Body.MinimumSize.Width + panel.Padding.Horizontal).DefaultIfEmpty(0).Max();
        panel.MinimumSize = new Size(minimum, 0);
        if (ReferenceEquals(panel.Parent, _formHost)) _formHost.AutoScrollMinSize = new Size(minimum, 0);
        LayoutEditorContent(panel, force: true);
    }
}
