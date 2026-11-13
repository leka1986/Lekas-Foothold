using System.Drawing;
using System.Windows.Forms;

namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    internal sealed partial class SmoothDataGridView
    {
        internal Action<int>? ToggleEquipmentRow { get; set; }
        internal Func<DataGridView, int, string?>? EquipmentRowId { get; set; }
        internal Func<DataGridView, int, string?>? EquipmentRowChange { get; set; }

        protected override AccessibleObject CreateAccessibilityInstance() =>
            ToggleEquipmentRow is null ? base.CreateAccessibilityInstance() : new EquipmentListAccessibleObject(this);

        protected override void WndProc(ref Message m)
        {
            const int getObject = 0x003D, uiaRootObjectId = -25;
            if (m.Msg == getObject && unchecked((int)m.LParam) == uiaRootObjectId && ToggleEquipmentRow is not null)
            {
                // Use the Windows accessibility bridge for the viewport list. The native
                // grid provider walks every logical row, including unmaterialized rows.
                DefWndProc(ref m);
                return;
            }
            base.WndProc(ref m);
        }

        private sealed class EquipmentListAccessibleObject(SmoothDataGridView grid) : DataGridViewAccessibleObject(grid)
        {
            public override AccessibleRole Role => AccessibleRole.List;

            public override int GetChildCount() => grid.DisplayedRowCount(includePartialRow: true);

            public override AccessibleObject? GetChild(int index) =>
                (uint)index < (uint)GetChildCount() ? GetRow(grid.FirstDisplayedScrollingRowIndex + index) : null;

            public override AccessibleObject? GetFocused() =>
                grid.Focused ? GetRow(grid.CurrentCellAddress.Y) ?? this : null;

            public override AccessibleObject GetSelected() => GetRow(grid.CurrentCellAddress.Y) ?? this;

            public override AccessibleObject HitTest(int x, int y)
            {
                var point = grid.PointToClient(new Point(x, y));
                return GetRow(grid.HitTest(point.X, point.Y).RowIndex) ?? this;
            }

            public override AccessibleObject? Navigate(AccessibleNavigation direction) => direction switch
            {
                AccessibleNavigation.FirstChild => GetChild(0),
                AccessibleNavigation.LastChild => GetChild(GetChildCount() - 1),
                _ => base.Navigate(direction)
            };

            private AccessibleObject? GetRow(int row) => IsDisplayed(row) ? new EquipmentRowAccessibleObject(this, row) : null;

            private bool IsDisplayed(int row)
            {
                var first = grid.FirstDisplayedScrollingRowIndex;
                return first >= 0 && row >= first && row - first < GetChildCount();
            }

            private string? GetId(int row) => grid.EquipmentRowId?.Invoke(grid, row) ?? grid[1, row].Value as string;

            private sealed class EquipmentRowAccessibleObject(EquipmentListAccessibleObject list, int row) : AccessibleObject
            {
                private readonly string? _id = list.GetId(row);

                private bool Available => list.IsDisplayed(row) && StringComparer.Ordinal.Equals(_id, list.GetId(row));
                private bool Checked => Available && list.OwnerGrid[0, row].Value is true;

                public override AccessibleObject Parent => list;
                public override string? Name { get => Available ? list.OwnerGrid[1, row].Value as string : _id; set { } }
                public override string? Description => Available &&
                    list.OwnerGrid.EquipmentRowChange?.Invoke(list.OwnerGrid, row) is { } change
                    ? string.IsNullOrEmpty(_id) ? change : _id + " · " + change
                    : _id;
                public override string DefaultAction => Checked ? "Uncheck" : "Check";
                public override AccessibleRole Role => AccessibleRole.CheckButton;
                public override AccessibleStates State => Available
                    ? AccessibleStates.Focusable | (Checked ? AccessibleStates.Checked : AccessibleStates.None) |
                      (list.OwnerGrid.Focused && list.OwnerGrid.CurrentCellAddress.Y == row ? AccessibleStates.Focused : AccessibleStates.None)
                    : AccessibleStates.Offscreen | AccessibleStates.Unavailable;
                public override Rectangle Bounds => Available
                    ? list.OwnerGrid.RectangleToScreen(list.OwnerGrid.GetRowDisplayRectangle(row, cutOverflow: true))
                    : Rectangle.Empty;

                public override AccessibleObject? Navigate(AccessibleNavigation direction) => direction switch
                {
                    AccessibleNavigation.Next or AccessibleNavigation.Down => list.GetRow(row + 1),
                    AccessibleNavigation.Previous or AccessibleNavigation.Up => list.GetRow(row - 1),
                    _ => null
                };

                public override void DoDefaultAction()
                {
                    if (Available) list.OwnerGrid.ToggleEquipmentRow!(row);
                }
            }

            private SmoothDataGridView OwnerGrid => grid;
        }
    }
}
