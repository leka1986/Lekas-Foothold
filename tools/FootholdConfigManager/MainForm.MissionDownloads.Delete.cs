namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private Panel? _missionFilesDeleteDivider;
    private TableLayoutPanel? _missionFilesDeleteRow;
    private Label? _missionFilesDeleteCount;
    private Button? _missionFilesDelete;
    private bool CanDeleteMissionFiles => !_updatesDisposed && !_missionDownloadBusy && !_configLoadingOperation
        && !_updatesBusy && !_updatesInstalling && _missionFilesScan is null && _missionFilesPreparation is not null
        && ReferenceEquals(_missionFilesPreparation, _missionFilesService?.Prepared);

    private Form CreateMissionDeleteDialog(IReadOnlyList<MissionPathIdentity> sources)
    {
        var body = new TableLayoutPanel { ColumnCount = 1, RowCount = 3, Margin = Padding.Empty };
        body.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        body.RowStyles.Add(new RowStyle(SizeType.AutoSize)); body.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        body.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        body.Controls.Add(new Label { Text = "Are you sure you want to move the selected mission" + (sources.Count == 1 ? "" : "s") + " to the Recycle Bin?",
            Dock = DockStyle.Top, AutoSize = true, MaximumSize = new Size(Zoomed(580), 0), Margin = new Padding(0, 0, 0, Zoomed(12)) }, 0, 0);
        body.Controls.Add(new TextBox { Name = "MissionDeletePaths", Multiline = true, ReadOnly = true, Dock = DockStyle.Fill,
            ScrollBars = ScrollBars.Vertical, WordWrap = true, Text = string.Join(Environment.NewLine, sources.Select(source => source.Path)) }, 0, 1);
        body.Controls.Add(new Label { Text = "If the Recycle Bin is unavailable, the file will not be deleted.", Dock = DockStyle.Top,
            AutoSize = true, MaximumSize = new Size(Zoomed(580), 0), Margin = new Padding(0, Zoomed(12), 0, 0) }, 0, 2);
        var dialog = CreateMissionDownloadDialog(sources.Count == 1 ? "Delete selected mission?" : "Delete selected missions?", "Yes", body, out var yes);
        dialog.Name = "MissionDeleteReview"; dialog.Font = MissionPresentationFont(1f, FontStyle.Regular);
        var no = ((Button)dialog.CancelButton!); no.Name = "MissionDeleteNo"; no.Text = "No"; no.DialogResult = DialogResult.No;
        yes.Name = "MissionDeleteYes"; yes.DialogResult = DialogResult.Yes;
        yes.ForeColor = SystemInformation.HighContrast ? SystemColors.ControlText : _darkMode ? Color.FromArgb(243,160,167) : Color.FromArgb(165,45,53);
        dialog.AcceptButton = no; dialog.ActiveControl = no;
        var area = Screen.FromControl(this).WorkingArea;
        dialog.ClientSize = new Size(Math.Min(Zoomed(650), area.Width - 50), Math.Min(Zoomed(310), area.Height - 90));
        return dialog;
    }

    private async Task DeleteSelectedMissionFilesAsync(Func<Form, DialogResult>? showConfirmation = null)
    {
        if (!CanDeleteMissionFiles || _missionFilesState.Selected.Count == 0) return;
        var preparation = _missionFilesPreparation!;
        var sources = _missionFilesState.Selected.Select(path => preparation.Compatible.TryGetValue(path, out var row)
            ? row.Identity : preparation.Rows.Single(item => PathsEqual(item.Path, path)).SourceIdentity!).ToArray();
        using (var dialog = CreateMissionDeleteDialog(sources))
            if ((showConfirmation is null ? dialog.ShowDialog(this) : showConfirmation(dialog)) != DialogResult.Yes) return;
        if (!CanDeleteMissionFiles || !ReferenceEquals(preparation, _missionFilesPreparation)) return;
        _missionDownloadBusy = true;
        var generation = ++_missionFilesOperationGeneration;
        using var cancellation = CancellationTokenSource.CreateLinkedTokenSource(_updatesLifetime.Token);
        _missionDownloadCancellation = cancellation;
        RefreshMissionFilesSelection();
        _missionFilesCreate!.Enabled = false; // A recycle job must not overlap output creation.
        try
        {
            var results = await MissionRecycleBin.MoveAsync(sources, cancellation.Token);
            if (_updatesDisposed || IsDisposed || Disposing) return;
            var recycled = results.Where(item => item.Error is null).Select(item => item.Path).ToHashSet(StringComparer.OrdinalIgnoreCase);
            if (recycled.Count > 0)
            {
                _missionFilesPreparation = _missionFilesService!.ForgetRecycledSources(recycled);
                _missionFilesExternalPaths = _missionFilesExternalPaths.Where(path => !recycled.Contains(path)).ToArray();
                _missionFilesPreparedExternalPaths = CaptureMissionFilesExternalPaths();
                foreach (var folder in recycled.Select(path => Path.GetDirectoryName(path)!).Distinct(StringComparer.OrdinalIgnoreCase))
                    ForgetMissionWarehouseCatalog(folder);
                RefreshMissionCompletionState(); RefreshMissionFilesCompletionRows();
            }
            _missionFilesResult!.Text = recycled.Count + " mission" + (recycled.Count == 1 ? "" : "s") + " moved to the Recycle Bin. "
                + results.Count(item => item.Error is not null) + " not deleted."
                + (results.Count < sources.Length ? " Remaining files were cancelled." : "");
            _missionFilesDetails!.Text = string.Join(Environment.NewLine, results.Select(item => item.Error is null
                ? "Recycled: " + item.Path : "Not deleted: " + item.Path + " — " + item.Error));
            _missionFilesDetailsToggle!.Visible = results.Count > 0;
            _missionFilesDetails.Visible = false; _missionFilesDetailsToggle.Text = "Show details";
            _missionFilesResultGlyph!.Visible = recycled.Count == sources.Length;
            _missionFilesOpenFolder!.Visible = false;
            SetStatus(_missionFilesResult.Text);
        }
        catch (Exception error)
        {
            if (!_updatesDisposed) _missionFilesResult!.Text = "Could not recycle selected missions: " + error.Message;
        }
        finally
        {
            _missionDownloadBusy = false; _missionDownloadCancellation = null;
            if (!_updatesDisposed && !IsDisposed && !Disposing && generation == _missionFilesOperationGeneration)
            { RefreshMissionFilesSelection(); RefreshUpdatesPresentation(); }
            if (_updatesDisposed) DisposeMissionDownloadState();
            if (_missionCloseRequested && !IsDisposed && !Disposing) { _missionCloseRequested = false; Close(); }
        }
    }
}
