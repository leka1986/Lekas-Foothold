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
        if (toolTip is EditorHelpToolTip help) help.HideFor(control);
        toolTip.SetToolTip(control, null);
        foreach (Control child in control.Controls)
        {
            ClearToolTips(child, toolTip);
        }
    }
}

internal sealed class EditorHelpToolTip : ToolTip
{
    private Control? _owner;

    public void ShowFor(Control owner, string text)
    {
        if (!owner.IsHandleCreated || !owner.Visible || owner.Disposing) return;
        if (_owner is { } previous) HideFor(previous);
        Show(text, owner, owner.Width + 6, 0, AutoPopDelay);
        _owner = owner;
        owner.VisibleChanged += OwnerVisibilityChanged;
        owner.HandleDestroyed += OwnerHandleDestroyed;
    }

    public void HideFor(Control owner)
    {
        if (!ReferenceEquals(_owner, owner)) return;
        ReleaseOwner();
        if (owner.IsHandleCreated && !owner.IsDisposed) Hide(owner);
        StopTimer();
    }

    private void OwnerVisibilityChanged(object? sender, EventArgs e)
    {
        if (sender is Control { Visible: false } owner) HideFor(owner);
    }

    private void OwnerHandleDestroyed(object? sender, EventArgs e)
    {
        if (!ReferenceEquals(_owner, sender)) return;
        ReleaseOwner();
        // The HWND is going away. Cancel the timer without asking WinForms to resolve it.
        StopTimer();
    }

    private void ReleaseOwner()
    {
        if (_owner is not { } owner) return;
        _owner = null;
        owner.VisibleChanged -= OwnerVisibilityChanged;
        owner.HandleDestroyed -= OwnerHandleDestroyed;
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing) ReleaseOwner();
        base.Dispose(disposing);
    }
}
