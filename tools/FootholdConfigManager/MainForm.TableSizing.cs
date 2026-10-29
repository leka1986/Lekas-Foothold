using System.Windows.Forms;

namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private sealed partial class SmoothDataGridView
    {
        private TableLayoutPanel? _compactHeightGroup;
        private Action? _compactHeightLayout;
        private bool _compactHeightPending;
        private bool _updatingCompactHeight;
        private bool _compactHeightDirty;

        public bool HasCompactHeightLayout => _compactHeightLayout is not null;
        public int CompactHorizontalScrollbarHeight => HorizontalScrollBar.Visible ? HorizontalScrollBar.Height : 0;

        public void ConfigureCompactHeightLayout(TableLayoutPanel group, Action layout)
        {
            if (_compactHeightGroup != group)
            {
                if (_compactHeightGroup is not null) _compactHeightGroup.Layout -= CompactGroupLayout;
                group.Layout += CompactGroupLayout;
            }
            if (_compactHeightGroup is null)
            {
                RowsAdded += (_, _) => RequestCompactHeightLayout();
                RowsRemoved += (_, _) => RequestCompactHeightLayout();
                RowHeightChanged += (_, _) => RequestCompactHeightLayout();
                RowStateChanged += (_, args) =>
                {
                    if ((args.StateChanged & DataGridViewElementStates.Visible) != 0) RequestCompactHeightLayout();
                };
                ColumnHeadersHeightChanged += (_, _) => RequestCompactHeightLayout();
                HorizontalScrollBar.VisibleChanged += (_, _) => RequestCompactHeightLayout();
            }
            _compactHeightGroup = group;
            // Refresh calls replace the measurement, retaining one owner per displayed grid.
            _compactHeightLayout = layout;
            UpdateCompactHeightLayout();
            RequestCompactHeightLayout();
        }

        protected override void OnFontChanged(EventArgs args)
        {
            base.OnFontChanged(args);
            foreach (DataGridViewRow row in Rows) SizeContentRow(row);
        }

        protected override void OnRowsAdded(DataGridViewRowsAddedEventArgs args)
        {
            base.OnRowsAdded(args);
            for (var index = args.RowIndex; index < args.RowIndex + args.RowCount; index++)
                SizeContentRow(Rows[index]);
        }

        private void SizeContentRow(DataGridViewRow row)
        {
            var height = Math.Max(RowTemplate.Height,
                row.GetPreferredHeight(row.Index, DataGridViewAutoSizeRowMode.AllCellsExceptHeader, true));
            if (row.Height != height) row.Height = height;
        }

        private void CompactGroupLayout(object? sender, LayoutEventArgs args) => RequestCompactHeightLayout();

        protected override void OnHandleDestroyed(EventArgs args)
        {
            _compactHeightPending = false;
            base.OnHandleDestroyed(args);
        }

        protected override void OnLayout(LayoutEventArgs args)
        {
            base.OnLayout(args);
            RequestCompactHeightLayout();
        }

        private void RequestCompactHeightLayout()
        {
            if (_updatingCompactHeight) { _compactHeightDirty = true; return; }
            if (_compactHeightPending || !HasCompactHeightLayout || !IsHandleCreated || IsDisposed) return;
            _compactHeightPending = true;
            BeginInvoke((Action)(() =>
            {
                _compactHeightPending = false;
                if (!IsDisposed) UpdateCompactHeightLayout();
            }));
        }

        private void UpdateCompactHeightLayout()
        {
            if (_updatingCompactHeight) return;
            _updatingCompactHeight = true;
            _compactHeightDirty = false;
            try { _compactHeightLayout!(); }
            finally
            {
                _updatingCompactHeight = false;
                if (_compactHeightDirty) RequestCompactHeightLayout();
            }
        }
    }
}
