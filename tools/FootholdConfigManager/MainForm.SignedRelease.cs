#if !FOOTHOLD_USER_BUILD
namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private void OpenSignedReleaseDialog()
    {
        if (!_adminUnlocked || AppMode.IsExportedUserBuild || _document is null) return;
        var projectDirectory = UserExeExporter.FindProjectDirectory();
        if (projectDirectory is null)
        {
            MessageBox.Show(this, "Open this action from the admin/source copy of the Manager.", "Signed Manager release", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }
        using var dialog = new SignedReleaseDialog(projectDirectory, _document.Metadata.ToJson()) { Font = Font };
        ApplyDialogChrome(dialog);
        using var modal = _loadingScreen?.SuspendForModal();
        dialog.ShowDialog(this);
    }
}
#endif