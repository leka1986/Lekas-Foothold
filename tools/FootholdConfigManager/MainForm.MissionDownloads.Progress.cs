namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private int _missionMapUpdateRevision;
    private IReadOnlyList<MissionMapUpdate> _missionAvailableMapUpdates = [];

    private void RefreshMissionCompletionState()
    {
        var available = MissionUpdateProgress.Available(_settings.MissionMapUpdates);
        if (_missionAvailableMapUpdates.SequenceEqual(available)) return;
        _missionAvailableMapUpdates = available;
        _missionMapUpdateRevision++;
    }

    private string? RememberMissionMapUpdates(IReadOnlyList<MissionMapUpdate> updates)
    {
        if (updates.Count == 0) return null;
        foreach (var update in updates) MissionUpdateProgress.Record(_settings, update);
        RefreshMissionCompletionState();
        try { _settings.Save(); return null; }
        catch (Exception error) { return "Mission copies were created, but map progress could not be saved: " + error.Message; }
    }

    private Label? _missionMapProgressSummary, _missionRemainingMaps, _missionCompletedMaps, _missionCompletedHint;
    private (long ReleaseId, string Tag, string InstanceId, string InstanceName, int Revision)? _missionMapProgressContext;

    private void RefreshMissionDownloadProgress(ServerProfileSettings? destination)
    {
        if (_missionDownloadRelease is not { } release || _missionAssetRows is null) return;
        var context = (release.Id, release.Tag, destination?.Id ?? "", destination?.Name ?? "", _missionMapUpdateRevision);
        if (_missionMapProgressContext == context) return;
        _missionMapProgressContext = context;
        var folder = destination is null ? null : RuntimeSettings.ResolveMissionsDirectory(destination);
        var inspected = _missionFilesPreparedRelease is { } scanned && SameMissionFilesRelease(release, scanned)
            ? _missionFilesPreparation?.Rows ?? [] : [];
        var found = folder is not null && _missionWarehouseCatalogs.TryGetValue(Path.GetFullPath(folder), out var catalog)
            ? MissionUpdateProgress.CurrentMaps(catalog, inspected) : new HashSet<(string, Version)>();
        var remaining = new List<CheckBox>();
        var completed = new List<CheckBox>();
        foreach (var check in _missionAssetChecks.Values)
        {
            var map = (MissionMapCheckBox)check;
            var asset = (MissionReleaseAsset)check.Tag!;
            var mapName = MissionWarehouseService.GetMapVariant(asset.Name);
            var version = MissionUpdateProgress.MissionVersion(asset.Name);
            var update = destination is null || mapName is null || version is null ? null
                : MissionUpdateProgress.Find(_missionAvailableMapUpdates, destination.Id, release.Tag, mapName, version)
                    ?? _missionAvailableMapUpdates.LastOrDefault(item => item.Map == mapName
                        && item.ReleaseTag.Equals(release.Tag, StringComparison.OrdinalIgnoreCase)
                        && MissionUpdateProgress.MatchesVersion(item, version)
                        && folder is not null && item.MissionsDirectory is not null && PathsEqual(item.MissionsDirectory, folder));
            map.CompletionText = update is not null ? "Already updated · " + update.Method
                : mapName is not null && version is not null && found.Contains((mapName, version)) ? "Current version found · Missions folder" : "";
            map.AccessibleDescription = asset.Name + (map.CompletionText.Length == 0 ? "" : "; " + map.CompletionText);
            (map.CompletionText.Length == 0 ? remaining : completed).Add(check);
        }
        _missionMapProgressSummary!.Text = destination is null ? "Choose an instance to see its update progress."
            : completed.Count + " of " + _missionAssetChecks.Count + " maps already updated for " + destination.Name;
        _missionRemainingMaps!.Text = "Remaining to update (" + remaining.Count + ")";
        _missionCompletedMaps!.Text = "Already updated (" + completed.Count + ")";
        _missionCompletedMaps.Visible = _missionCompletedHint!.Visible = completed.Count > 0;
        _missionAssetRows.SuspendLayout();
        try
        {
            _missionAssetRows.RowCount = _missionAssetChecks.Count + 3;
            _missionAssetRows.RowStyles.Clear();
            for (var row = 0; row < _missionAssetRows.RowCount; row++)
                _missionAssetRows.RowStyles.Add(new RowStyle(SizeType.AutoSize));
            var index = 0;
            _missionAssetRows.SetCellPosition(_missionRemainingMaps, new TableLayoutPanelCellPosition(0, index++));
            foreach (var check in remaining) _missionAssetRows.SetCellPosition(check, new TableLayoutPanelCellPosition(0, index++));
            _missionAssetRows.SetCellPosition(_missionCompletedMaps, new TableLayoutPanelCellPosition(0, index++));
            _missionAssetRows.SetCellPosition(_missionCompletedHint, new TableLayoutPanelCellPosition(0, index++));
            foreach (var check in completed) _missionAssetRows.SetCellPosition(check, new TableLayoutPanelCellPosition(0, index++));
        }
        finally { _missionAssetRows.ResumeLayout(true); }
        LayoutMissionDownloads();
    }

    private void SelectRemainingMissionMaps()
    {
        if (_missionDownloadsRendering || _missionDownloadBusy) return;
        UpdateMissionDownloadPresentation(() =>
        {
            _missionDownloadsRendering = true;
            try
            {
                foreach (var check in _missionAssetChecks.Values)
                    check.Checked = ((MissionMapCheckBox)check).CompletionText.Length == 0;
            }
            finally { _missionDownloadsRendering = false; }
            RefreshMissionDownloadSelection();
        });
    }
}
