namespace FootholdConfigManager;

internal static class ControlTreeDisposer
{
    public static void Dispose(Control root, ToolTip toolTip)
    {
        ClearToolTips(root, toolTip);
        root.Parent?.Controls.Remove(root);
        root.Dispose();
    }

    private static void ClearToolTips(Control control, ToolTip toolTip)
    {
        toolTip.SetToolTip(control, null);
        foreach (Control child in control.Controls)
        {
            ClearToolTips(child, toolTip);
        }
    }
}
