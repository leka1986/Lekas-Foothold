namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private CheckBox? _missionCopyWarehouses;
    private TableLayoutPanel? _missionWarehouseRows;
    private Label? _missionWarehouseHint;
    private readonly Dictionary<long, ComboBox> _missionWarehouseChoices = new();
    private readonly Dictionary<long, TableLayoutPanel> _missionWarehouseSourceRows = new();
    private readonly Dictionary<long, Label> _missionWarehouseSourceDetails = new();
    private readonly Dictionary<long, string> _missionWarehousePopulatedFolders = new();
    private readonly Dictionary<string, IReadOnlyList<MissionWarehouseSource>> _missionWarehouseCatalogs = new(StringComparer.OrdinalIgnoreCase);
    private readonly Dictionary<string, DateTime> _missionWarehouseCatalogTimes = new(StringComparer.OrdinalIgnoreCase);
    private readonly Dictionary<string, Dictionary<string, IReadOnlyList<MissionWarehouseSource>>> _missionWarehouseMatches = new(StringComparer.OrdinalIgnoreCase);
    private readonly Dictionary<string, Dictionary<long, string?>> _missionWarehouseSelections = new(StringComparer.OrdinalIgnoreCase);
    private IReadOnlyList<MissionWarehouseSource> _missionWarehouseCatalog = [];
    private string? _missionWarehouseFolder;
    private Task? _missionWarehouseDiscovery;

    private void BuildMissionWarehouseControls(TableLayoutPanel changes, Action<TableLayoutPanel, Control> add)
    {
        _missionCopyWarehouses = new WeatherCheckBox { DisabledTextColor = HelpTextColor, Name = "MissionDownloadCopyWarehouses",
            Text = "Copy warehouses from older missions", AutoSize = true };
        const string warehouseHelp = "Copies the entire warehouse file from the selected older mission into the newly downloaded MIZ, including all warehouse items, fuel, and unlimited supply settings. The older mission stays unchanged.";
        var help = MakeHelpButton(_missionCopyWarehouses.Text, warehouseHelp);
        help.Name = "MissionDownloadWarehouseHelp";
        help.AccessibleName = "Help for copying warehouses";
        help.Click += (_, _) => _toolTip.ShowFor(help, warehouseHelp);
        var option = new FlowLayoutPanel { Name = "MissionDownloadWarehouseOption", AutoSize = true,
            AutoSizeMode = AutoSizeMode.GrowAndShrink, Dock = DockStyle.Top };
        option.Controls.AddRange([_missionCopyWarehouses, help]);
        _missionWarehouseHint = new Label { Name = "MissionWarehouseHint", AutoSize = true, Dock = DockStyle.Top,
            Tag = "MissionDownloadMuted",
            Text = "Copy the whole warehouse file: stock, fuel and unlimited settings. The older MIZ stays unchanged." };
        _missionWarehouseRows = new TableLayoutPanel { Name = "MissionWarehouseSources", ColumnCount = 1,
            Dock = DockStyle.Top, AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink, Visible = false };
        _missionWarehouseRows.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        add(changes, option);
        add(changes, _missionWarehouseHint);
        add(changes, _missionWarehouseRows);
        _missionCopyWarehouses.CheckedChanged += async (_, _) =>
        {
            if (_missionDownloadsRendering) return;
            if (_missionCopyWarehouses!.Checked && _missionZipOnly?.Checked != true
                && _missionAssetChecks.Values.Any(check => check.Checked)
                && !_configLoadingOperation && !_missionDownloadBusy && !_updatesInstalling
                && _missionWarehouseDiscovery is not { IsCompleted: false } && !IsDisposed && !Disposing)
            {
                var profile = (_missionDestination?.SelectedItem as InstanceItem)?.Profile;
                var folder = profile is null ? null : RuntimeSettings.ResolveMissionsDirectory(profile);
                if (folder is not null)
                {
                    folder = Path.GetFullPath(folder);
                    if (_missionWarehouseFolder is not null && PathsEqual(_missionWarehouseFolder, folder))
                        foreach (var (id, check) in _missionAssetChecks)
                            if (check.Checked && _missionWarehouseChoices.TryGetValue(id, out var choice)
                                && choice.SelectedItem is MissionWarehouseSource)
                                UpdateMissionWarehouseChoice(id);
                    ForgetMissionWarehouseCatalog(folder);
                }
            }
            RefreshMissionDownloadSelection();
            await EnsureMissionWarehouseSourcesAsync();
        };

    }

    private Task EnsureMissionWarehouseSourcesAsync()
    {
        if (_missionDownloadRelease is null || _missionZipOnly?.Checked == true
            || _missionDownloadsRendering || IsDisposed || Disposing) return Task.CompletedTask;
        if (_missionWarehouseDiscovery is { IsCompleted: false }) return AwaitDiscoveryAsync(_missionWarehouseDiscovery);
        var profile = (_missionDestination?.SelectedItem as InstanceItem)?.Profile;
        var folder = profile is null ? null : RuntimeSettings.ResolveMissionsDirectory(profile);
        if (folder is null) { RefreshMissionDownloadSelection(); return Task.CompletedTask; }
        folder = Path.GetFullPath(folder);
        if (_missionWarehouseCatalogs.TryGetValue(folder, out var cached)
            && _missionWarehouseCatalogTimes.TryGetValue(folder, out var stamp))
        {
            var fresh = false;
            try { fresh = stamp == Directory.GetLastWriteTimeUtc(folder); }
            catch (Exception error) when (error is IOException or UnauthorizedAccessException) { }
            if (fresh)
            {
                if (!string.Equals(_missionWarehouseFolder, folder, StringComparison.OrdinalIgnoreCase))
                    UseMissionWarehouseCatalog(folder, cached);
                return Task.CompletedTask;
            }
        }
        if (_configLoadingOperation || _missionDownloadBusy || _updatesInstalling) return Task.CompletedTask;
        ForgetMissionWarehouseCatalog(folder);
        _missionWarehouseDiscovery = DiscoverAsync(folder);
        return _missionWarehouseDiscovery;

        async Task AwaitDiscoveryAsync(Task pending)
        {
            await pending;
            await EnsureMissionWarehouseSourcesAsync();
        }

        async Task DiscoverAsync(string requestedFolder)
        {
            await RunConfigLoadingAsync(async (progress, token) =>
            {
                progress.Report(new LoadingProgress("Scanning mission folder…"));
                var captured = await Task.Run(() => (Stamp: Directory.GetLastWriteTimeUtc(requestedFolder),
                    Sources: MissionWarehouseService.DiscoverSources(requestedFolder, token)), token);
                var catalog = captured.Sources;
                token.ThrowIfCancellationRequested();
                _missionWarehouseCatalogs[requestedFolder] = catalog;
                _missionWarehouseCatalogTimes[requestedFolder] = captured.Stamp;
                _missionMapUpdateRevision++;
                if (IsDisposed || Disposing) return;
                var current = (_missionDestination?.SelectedItem as InstanceItem)?.Profile;
                if (current is not null && PathsEqual(RuntimeSettings.ResolveMissionsDirectory(current) ?? "", requestedFolder))
                    UseMissionWarehouseCatalog(requestedFolder, catalog);
            }, _updatesLifetime.Token, "Scanning mission folder…", errorTitle: "Mission folder");
            if (!IsDisposed && !Disposing) RefreshMissionDownloadSelection();
        }
    }

    private void ForgetMissionWarehouseCatalog(string folder)
    {
        folder = Path.GetFullPath(folder);
        _missionWarehouseCatalogs.Remove(folder);
        _missionWarehouseCatalogTimes.Remove(folder);
        _missionMapUpdateRevision++;
        _missionWarehouseMatches.Remove(folder);
        foreach (var id in _missionWarehousePopulatedFolders.Where(pair => PathsEqual(pair.Value, folder)).Select(pair => pair.Key).ToArray())
            _missionWarehousePopulatedFolders.Remove(id);
        if (_missionWarehouseFolder is not null && PathsEqual(_missionWarehouseFolder, folder))
        {
            _missionWarehouseFolder = null;
            _missionWarehouseCatalog = [];
        }
    }

    private void RecordInstalledMissionWarehouseSources(IReadOnlyList<string> paths)
    {
        foreach (var group in paths.Select(Path.GetFullPath).GroupBy(path => Path.GetDirectoryName(path)!, StringComparer.OrdinalIgnoreCase))
        {
            if (!_missionWarehouseCatalogs.TryGetValue(group.Key, out var catalog)) continue;
            var updated = catalog.ToDictionary(source => source.Path, StringComparer.OrdinalIgnoreCase);
            DateTime folderStamp;
            try
            {
                foreach (var path in group)
                {
                    var file = new FileInfo(path);
                    updated[path] = new MissionWarehouseSource(file.FullName, file.LastWriteTimeUtc, file.Length);
                }
                folderStamp = Directory.GetLastWriteTimeUtc(group.Key);
            }
            catch (Exception error) when (error is IOException or UnauthorizedAccessException)
            {
                ForgetMissionWarehouseCatalog(group.Key);
                continue;
            }
            var active = _missionWarehouseFolder is not null && PathsEqual(_missionWarehouseFolder, group.Key);
            ForgetMissionWarehouseCatalog(group.Key);
            var sources = Array.AsReadOnly(updated.Values.ToArray());
            _missionWarehouseCatalogs[group.Key] = sources;
            _missionWarehouseCatalogTimes[group.Key] = folderStamp;
            if (active)
            {
                _missionWarehouseFolder = group.Key;
                _missionWarehouseCatalog = sources;
            }
        }
    }

    private void UseMissionWarehouseCatalog(string folder, IReadOnlyList<MissionWarehouseSource> catalog)
    {
        _missionWarehouseFolder = folder;
        _missionWarehouseCatalog = catalog;
        RefreshMissionDownloadSelection();
    }

    private void RefreshMissionWarehousePresentation()
    {
        if (_missionCopyWarehouses is null || _missionWarehouseRows is null) return;
        var hasMaps = _missionAssetChecks.Values.Any(check => check.Checked);
        var enabled = hasMaps && _missionZipOnly?.Checked != true;
        if (!hasMaps && _missionCopyWarehouses.Checked)
        {
            var rendering = _missionDownloadsRendering;
            _missionDownloadsRendering = true;
            try { _missionCopyWarehouses.Checked = false; }
            finally { _missionDownloadsRendering = rendering; }
        }
        _missionCopyWarehouses.Enabled = enabled;
        var visible = enabled && _missionCopyWarehouses.Checked;
        _missionWarehouseRows.Visible = visible;
        _missionWarehouseHint!.Visible = visible;
        if (!visible) return;

        var profile = (_missionDestination?.SelectedItem as InstanceItem)?.Profile;
        var folder = profile is null ? null : RuntimeSettings.ResolveMissionsDirectory(profile);
        var ready = folder is not null && string.Equals(_missionWarehouseFolder, folder, StringComparison.OrdinalIgnoreCase);
        var hint = ready
            ? "Older MIZs in this folder, matched by map and variant. Most recently modified match suggested. Compatibility is checked before installation."
            : folder is null ? "Choose a mission folder to find older matching missions." : "Scanning mission folder…";
        if (_missionWarehouseHint.Text != hint) _missionWarehouseHint.Text = hint;
        if (!ready) { foreach (var row in _missionWarehouseSourceRows.Values) row.Visible = false; return; }

        var rowIndex = 0;
        foreach (var (id, check) in _missionAssetChecks)
        {
            if (check.Checked)
            {
                if (!_missionWarehouseChoices.ContainsKey(id)) CreateMissionWarehouseRow(id, (MissionReleaseAsset)check.Tag!);
                if (!_missionWarehousePopulatedFolders.TryGetValue(id, out var populated)
                    || !string.Equals(populated, folder, StringComparison.OrdinalIgnoreCase))
                    PopulateMissionWarehouseRow(id, (MissionReleaseAsset)check.Tag!, folder!);
            }
            if (!_missionWarehouseSourceRows.TryGetValue(id, out var row)) continue;
            if (_missionWarehouseRows.GetRow(row) != rowIndex) _missionWarehouseRows.SetRow(row, rowIndex);
            rowIndex++;
            row.Visible = check.Checked;
        }
    }

    private void CreateMissionWarehouseRow(long id, MissionReleaseAsset asset)
    {
        var width = Math.Max(100, _missionDownloadRight!.Width - _missionDownloadRight.Padding.Horizontal);
        var row = new TableLayoutPanel { Name = "MissionWarehouseRow-" + id, Tag = asset, ColumnCount = 1,
            AutoSize = false, AutoSizeMode = AutoSizeMode.GrowAndShrink, Dock = DockStyle.Top,
            BackColor = EditorBackground, ForeColor = PrimaryTextColor, Margin = Padding.Empty, Width = width };
        row.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        var title = new Label { Text = "Older " + MissionAssetCaption(asset).Title + " mission", AutoSize = true, UseMnemonic = false, Dock = DockStyle.Top,
            Font = MissionPresentationFont(1, FontStyle.Bold), ForeColor = PrimaryTextColor, MaximumSize = new Size(width, 0) };
        var choice = new WeatherChoiceBox { Name = "MissionWarehouseSource-" + id, DropDownStyle = ComboBoxStyle.DropDownList,
            Dock = DockStyle.Top, Width = width, AccessibleName = title.Text };
        var detail = new Label { Name = "MissionWarehouseDetail-" + id, AutoSize = false, UseMnemonic = false, Dock = DockStyle.Top,
            Tag = "MissionDownloadMuted", ForeColor = HelpTextColor, MaximumSize = new Size(width, 0),
            Font = MissionPresentationFont(.92f, FontStyle.Regular) };
        foreach (var control in new Control[] { title, choice, detail })
        {
            control.Margin = new Padding(0, 0, 0, Zoomed(9));
            row.RowStyles.Add(new RowStyle(SizeType.AutoSize));
            row.Controls.Add(control, 0, row.RowCount++);
        }
        StyleInput(choice);
        StyleConfigDropdown(choice);
        _missionStyledInputs.Add(choice);
        _missionWarehouseRows!.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        _missionWarehouseRows.Controls.Add(row, 0, _missionWarehouseRows.RowCount++);
        _missionWarehouseSourceRows[id] = row;
        _missionWarehouseChoices[id] = choice;
        _missionWarehouseSourceDetails[id] = detail;
        choice.SelectedIndexChanged += (_, _) => UpdateMissionWarehouseChoice(id);
    }

    private void PopulateMissionWarehouseRow(long id, MissionReleaseAsset asset, string folder)
    {
        var choice = _missionWarehouseChoices[id];
        if (!_missionWarehouseMatches.TryGetValue(folder, out var matches))
            _missionWarehouseMatches[folder] = matches = new(StringComparer.Ordinal);
        var variant = MissionWarehouseService.GetMapVariant(asset.Name) ?? "";
        if (!matches.TryGetValue(variant, out var items))
            matches[variant] = items = MissionWarehouseService.FindSources(asset.Name, _missionWarehouseCatalog);
        var hasSaved = _missionWarehouseSelections.TryGetValue(folder, out var selections)
            && selections.TryGetValue(id, out _);
        var selected = hasSaved ? selections![id] : null;
        _missionDownloadsRendering = true;
        try
        {
            choice.BeginUpdate();
            try
            {
                choice.Items.Clear();
                choice.Items.AddRange(items.Cast<object>().ToArray());
                choice.SelectedItem = hasSaved && selected is not null
                    ? items.FirstOrDefault(item => PathsEqual(item.Path, selected))
                    : items.FirstOrDefault();
            }
            finally { choice.EndUpdate(); }
            _missionWarehousePopulatedFolders[id] = folder;
        }
        finally { _missionDownloadsRendering = false; }
        SizeMissionWarehouseDetail(id);
        UpdateMissionWarehouseChoice(id, remember: false);
    }

    private void UpdateMissionWarehouseChoice(long id, bool remember = true)
    {
        if (_missionDownloadsRendering) return;
        var choice = _missionWarehouseChoices[id];
        choice.Enabled = choice.Items.Count > 0;
        var source = choice.SelectedItem as MissionWarehouseSource;
        var text = MissionWarehouseSourceDetail(source);
        var detail = _missionWarehouseSourceDetails[id];
        if (detail.Text != text) detail.Text = text;
        if (remember && _missionWarehouseFolder is { } folder)
        {
            if (!_missionWarehouseSelections.TryGetValue(folder, out var selections))
                _missionWarehouseSelections[folder] = selections = new();
            if (source is not null) selections[id] = source.Path;
            else selections.Remove(id);
        }
        if (!_missionPresentationUpdating) ApplyMissionWarehousePrepareGate();
    }

    private static string MissionWarehouseSourceDetail(MissionWarehouseSource? source) => source is null
        ? "No matching older mission found. Change folder, or turn off Copy warehouses."
        : Path.GetFileName(source.Path) + Environment.NewLine + "Last modified " + source.LastWriteTimeUtc.ToLocalTime().ToString("g");

    private void LayoutMissionWarehouseRows(int columnWidth)
    {
        foreach (var (id, detail) in _missionWarehouseSourceDetails)
        {
            detail.MaximumSize = new Size(columnWidth, 0);
            SizeMissionWarehouseDetail(id);
        }
    }

    private void SizeMissionWarehouseDetail(long id)
    {
        var detail = _missionWarehouseSourceDetails[id];
        var width = Math.Max(1, detail.MaximumSize.Width);
        var height = Measure(MissionWarehouseSourceDetail(null));
        foreach (var source in _missionWarehouseChoices[id].Items.OfType<MissionWarehouseSource>())
            height = Math.Max(height, Measure(MissionWarehouseSourceDetail(source)));
        var size = new Size(width, Math.Max(detail.Font.Height * 2, height + 2));
        // Label.Text restores requested bounds even without AutoSize; retain the measured row geometry.
        detail.MinimumSize = Size.Empty;
        detail.MaximumSize = size;
        detail.MinimumSize = size;
        detail.Size = size;
        var row = _missionWarehouseSourceRows[id];
        row.Size = new Size(width, row.GetPreferredSize(new Size(width, 0)).Height);

        int Measure(string text) => TextRenderer.MeasureText(text, detail.Font, new Size(width, int.MaxValue),
            TextFormatFlags.WordBreak | TextFormatFlags.NoPrefix | TextFormatFlags.TextBoxControl).Height;
    }

    private void ApplyMissionWarehousePrepareGate()
    {
        if (_missionCopyWarehouses?.Checked != true || _missionZipOnly?.Checked == true || _missionPrepare is null) return;
        var profile = (_missionDestination?.SelectedItem as InstanceItem)?.Profile;
        var folder = profile is null ? null : RuntimeSettings.ResolveMissionsDirectory(profile);
        var ready = folder is not null && string.Equals(folder, _missionWarehouseFolder, StringComparison.OrdinalIgnoreCase);
        var selected = _missionAssetChecks.Where(pair => pair.Value.Checked).Select(pair => pair.Key);
        var valid = ready && selected.All(id => _missionWarehouseChoices.TryGetValue(id, out var choice)
            && choice.SelectedItem is MissionWarehouseSource);
        var basic = !_missionDownloadBusy && !_updatesInstalling && !_configLoadingOperation && !_updatesBusy
            && _missionAssetChecks.Values.Any(check => check.Checked) && profile is not null
            && (!_missionCustomFolderEnabled || _missionCustomOutputFolder is not null && _missionCustomOutputError is null)
            && (_missionUseProfiles?.Checked != true || _missionProfileChoices.All(choice => choice.SelectedItem is WeatherNamedProfile));
        _missionPrepare.Enabled = basic && valid;
    }

    private IReadOnlyDictionary<long, string?> CaptureMissionWarehouseChoices()
    {
        var result = new Dictionary<long, string?>();
        if (_missionCopyWarehouses?.Checked != true || _missionZipOnly?.Checked == true) return result;
        var destination = (_missionDestination?.SelectedItem as InstanceItem)?.Profile;
        var folder = destination is null ? null : RuntimeSettings.ResolveMissionsDirectory(destination);
        if (folder is null || !string.Equals(folder, _missionWarehouseFolder, StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException("Find older missions in the current destination folder before preparing.");
        foreach (var (id, check) in _missionAssetChecks)
        {
            if (!check.Checked) continue;
            if (!_missionWarehouseChoices.TryGetValue(id, out var choice))
                throw new InvalidDataException("Find older missions before preparing warehouse copies.");
            if (choice.SelectedItem is MissionWarehouseSource source) result[id] = source.Path;
            else throw new InvalidDataException("Choose an older mission for " + check.Text + ", change folder, or turn off Copy warehouses.");
        }
        return result;
    }
    private void ApplyMissionWarehouseReviewChoices(IReadOnlyDictionary<long, string?> sources)
    {
        _missionDownloadsRendering = true;
        try
        {
            foreach (var (id, path) in sources)
            {
                if (!_missionWarehouseChoices.TryGetValue(id, out var choice)) continue;
                choice.SelectedItem = path is null ? choice.Items.OfType<MissionWarehouseSource>().FirstOrDefault()
                    : choice.Items.OfType<MissionWarehouseSource>().FirstOrDefault(item => PathsEqual(item.Path, path));
            }
        }
        finally { _missionDownloadsRendering = false; }
        foreach (var id in sources.Keys.Where(_missionWarehouseChoices.ContainsKey)) UpdateMissionWarehouseChoice(id);
    }

    private static void UpdateMissionWarehouseReviewDetail(Form dialog, long assetId, string? selectedPath, bool changed)
    {
        var detail = dialog.Controls.Find("MissionWarehouseReviewDetail-" + assetId, true).OfType<Label>().Single();
        detail.Text = changed
            ? (selectedPath ?? "Use the downloaded mission's warehouse file.") + Environment.NewLine
                + "Source changed. Check sources again before installing."
            : (string)detail.Tag!;
    }

    private Dictionary<long, ComboBox> AddMissionWarehouseReviewSources(ReviewedMissionDownload reviewed, TableLayoutPanel content)
    {
        var result = new Dictionary<long, ComboBox>();
        foreach (var group in reviewed.Outputs.GroupBy(output => output.Template.Asset.Id))
        {
            var template = group.First().Template;
            var copy = group.First().WarehouseCopy;
            var title = new Label { Text = MissionAssetCaption(template.Asset).Title + " · warehouse source", AutoSize = true, UseMnemonic = false,
                Dock = DockStyle.Top, Margin = new Padding(0, Zoomed(14), 0, Zoomed(7)) };
            var choice = new WeatherChoiceBox { Name = "MissionWarehouseReviewSource-" + group.Key, DropDownStyle = ComboBoxStyle.DropDownList,
                Dock = DockStyle.Top, Margin = new Padding(0, 0, 0, Zoomed(7)), AccessibleName = title.Text };
            choice.Items.Add("Use the new mission's warehouses");
            if (_missionWarehouseChoices.TryGetValue(group.Key, out var draft))
                choice.Items.AddRange(draft.Items.OfType<MissionWarehouseSource>().Cast<object>().ToArray());
            var sourcePath = reviewed.Selection.WarehouseSources.GetValueOrDefault(group.Key);
            choice.SelectedItem = sourcePath is null ? choice.Items[0]
                : choice.Items.OfType<MissionWarehouseSource>().FirstOrDefault(item => PathsEqual(item.Path, sourcePath));
            if (choice.SelectedIndex < 0)
                throw new InvalidDataException("The reviewed warehouse source is no longer in the selected folder catalogue.");
            var detail = new Label { Name = "MissionWarehouseReviewDetail-" + group.Key, AutoSize = true, UseMnemonic = false, Dock = DockStyle.Top,
                Text = copy is null ? "Use the downloaded mission's warehouse file."
                    : copy.SourceIdentity.Path + Environment.NewLine + copy.Theatre
                        + " · map, warehouse IDs and referenced units/groups checked. Whole warehouse file will be copied.",
                MaximumSize = new Size(Zoomed(760), 0), ForeColor = HelpTextColor, Margin = new Padding(0, 0, 0, Zoomed(10)) };
            detail.Tag = detail.Text;
            StyleInput(choice);
            StyleConfigDropdown(choice);
            foreach (var control in new Control[] { title, choice, detail })
            {
                content.RowStyles.Add(new RowStyle(SizeType.AutoSize));
                content.Controls.Add(control, 0, content.RowCount++);
            }
            result[group.Key] = choice;
        }
        return result;
    }

}
