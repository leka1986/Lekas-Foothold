namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private sealed record MissionTemplateItem(PreparedMissionTemplate Template)
    {
        public override string ToString() => Template.Asset.Name + " · " + Template.Name;
    }

    private Form CreateMissionDownloadDialog(string title, string action, Control body, out Button confirm)
    {
        var area = Screen.FromControl(this).WorkingArea;
        var dialog = new Form { Text = title, Name = "MissionDownloadReview", StartPosition = FormStartPosition.CenterParent,
            Font = Font, AutoScaleMode = AutoScaleMode.None, ShowInTaskbar = false, MinimizeBox = false, MaximizeBox = false,
            ClientSize = new Size(Math.Min(Zoomed(880), area.Width - 50), Math.Min(Zoomed(590), area.Height - 90)) };
        var root = new TableLayoutPanel { Dock = DockStyle.Fill, ColumnCount = 1, RowCount = 2, Padding = new Padding(Zoomed(16)) };
        root.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        root.RowStyles.Add(new RowStyle(SizeType.Percent, 100)); root.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        body.Dock = DockStyle.Fill;
        root.Controls.Add(body, 0, 0);
        var actions = new FlowLayoutPanel { AutoSize = true, Dock = DockStyle.Fill, FlowDirection = FlowDirection.RightToLeft, WrapContents = true };
        confirm = MakeButton(action, () => { }); confirm.Name = "MissionDownloadConfirm"; confirm.DialogResult = DialogResult.OK;
        var cancel = MakeButton("Cancel", () => { }); cancel.DialogResult = DialogResult.Cancel;
        foreach (var button in new[] { confirm, cancel })
        {
            button.Dock = DockStyle.None;
            SizeDialogButton(button, 110);
            button.Margin = new Padding(Zoomed(8), Zoomed(10), 0, 0);
            actions.Controls.Add(button);
        }
        root.Controls.Add(actions, 0, 1); dialog.Controls.Add(root);
        dialog.AcceptButton = confirm; dialog.CancelButton = cancel;
        ApplyDialogChrome(dialog);
        return dialog;
    }

    private Form CreateMissionDownloadNameDialog(ReviewedMissionDownload reviewed, MissionVariantPlan output,
        Func<Form, DialogResult>? showConflict = null)
    {
        MissionPathIdentity? captured = null;
        return CreateMissionNameDialog(output.Template.SourcePath, output.OutputPath, (dialog, path) =>
        {
            if (reviewed.Outputs.Any(plan => !ReferenceEquals(plan, output) && PathsEqual(plan.OutputPath, path))
                || reviewed.ZipOutputs.Values.Any(zip => PathsEqual(zip, path)))
                throw new InvalidDataException("Another selected output already uses this filename. Choose another name.");
            if (captured is null || !PathsEqual(captured.Path, path))
                captured = reviewed.Identities.TryGetValue(path, out var known) ? known : MissionPathIdentity.Capture(path);
            if (captured.Exists)
            {
                var warehouseSource = IsMissionDownloadWarehouseSource(reviewed, path);
                using var conflict = CreateMissionDownloadConflictDialog(path, warehouseSource);
                var decision = showConflict is null ? conflict.ShowDialog(dialog) : showConflict(conflict);
                if (decision == DialogResult.Retry) return;
                if (decision != DialogResult.OK) { dialog.Tag = null; dialog.DialogResult = DialogResult.Cancel; return; }
                if (warehouseSource) throw new InvalidDataException("This mission is selected as a warehouse source. Choose another name to preserve it.");
            }
            captured.RequireUnchanged();
            dialog.Tag = (path, captured.Exists ? MissionCollisionPolicy.AskReplace : MissionCollisionPolicy.KeepBoth, captured);
            dialog.DialogResult = DialogResult.OK;
        });
    }

    private Form CreateMissionFileNameDialog(string sourcePath, string outputPath, IReadOnlyCollection<string> reservedPaths)
    {
        EnsureWeatherWindow();
        var directory = Path.GetDirectoryName(outputPath)!;
        var proposed = Path.GetFileName(outputPath);
        var name = WeatherExportNames.AvailableName(directory, proposed);
        for (var number = 2; reservedPaths.Any(path => PathsEqual(path, Path.Combine(directory, name)))
            || Directory.Exists(Path.Combine(directory, name)); number++)
            name = WeatherExportNames.AvailableName(directory, WeatherExportNames.NumberedName(proposed, number));
        return CreateMissionNameDialog(sourcePath, Path.Combine(directory, name), (dialog, path) =>
        {
            if (reservedPaths.Any(reserved => PathsEqual(reserved, path)))
                throw new InvalidDataException("An original mission or another selected output already uses this filename. Choose another name.");
            if (File.Exists(path))
                throw new InvalidDataException("A mission with this filename already exists. Choose another name to keep it unchanged.");
            dialog.Tag = path;
            dialog.DialogResult = DialogResult.OK;
        }, sourceContext: sourcePath);
    }

    private Form CreateMissionNameDialog(string sourcePath, string outputPath, Action<Form, string> approve, string? sourceContext = null)
    {
        var scale = _uiZoomPercent / 100f;
        var directory = Path.GetDirectoryName(outputPath)!;
        var body = new TableLayoutPanel { ColumnCount = 1, RowCount = 4, AutoScroll = true };
        body.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        for (var row = 0; row < 4; row++) body.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        var heading = new Label { Text = "Name your mission", AutoSize = true, Dock = DockStyle.Top };
        body.Controls.Add(heading, 0, 0);
        var name = new TextBox { Name = "MissionDownloadNameInput", Text = Path.GetFileName(outputPath), Dock = DockStyle.Fill,
            Margin = new Padding(0, (int)Math.Round(8 * scale), 0, (int)Math.Round(12 * scale)) };
        var preview = new Label { Name = "MissionDownloadNamePreview", AutoSize = true, MaximumSize = new Size((int)Math.Round(620 * scale), 0) };
        var error = new Label { Name = "MissionDownloadNameError", AutoSize = true, MaximumSize = preview.MaximumSize,
            ForeColor = IsDarkPalette() ? Color.FromArgb(255, 135, 135) : Color.Firebrick, Margin = new Padding(0, (int)Math.Round(8 * scale), 0, (int)Math.Round(8 * scale)) };
        body.Controls.Add(name, 0, 1); body.Controls.Add(preview, 0, 2); body.Controls.Add(error, 0, 3);
        var dialog = CreateMissionDownloadDialog("Name mission", "OK", body, out var confirm);
        dialog.Name = "MissionDownloadName";
        dialog.Font = _weatherWindow!.Font;
        var headingFont = new Font(dialog.Font, FontStyle.Bold);
        heading.Font = headingFont;
        dialog.Disposed += (_, _) => headingFont.Dispose();
        dialog.FormBorderStyle = FormBorderStyle.FixedDialog;
        var area = Screen.FromControl(this).WorkingArea;
        dialog.ClientSize = new Size(Math.Min((int)Math.Round(660 * scale), area.Width - 50), dialog.ClientSize.Height);
        var root = (TableLayoutPanel)dialog.Controls[0];
        root.Padding = new Padding((int)Math.Round(18 * scale));
        root.RowStyles[0].SizeType = SizeType.AutoSize;
        body.AutoSize = true; body.AutoSizeMode = AutoSizeMode.GrowAndShrink; body.Dock = DockStyle.Top; body.Margin = Padding.Empty;
        var actions = (FlowLayoutPanel)root.GetControlFromPosition(0, 1)!;
        actions.Dock = DockStyle.Top; actions.Margin = Padding.Empty;
        foreach (var button in new[] { confirm, (Button)dialog.CancelButton! })
        {
            button.Font = dialog.Font; button.AutoSize = false; button.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            button.MinimumSize = new Size((int)Math.Round(80 * scale), (int)Math.Round(32 * scale));
            button.Size = new Size(Math.Max((int)Math.Round(80 * scale), TextRenderer.MeasureText(button.Text, dialog.Font).Width + (int)Math.Round(36 * scale)), (int)Math.Round(32 * scale));
            button.Margin = new Padding((int)Math.Round(4 * scale), 0, 0, 0);
        }
        _weatherWindow.ApplyWeatherChrome(dialog);
        error.ForeColor = IsDarkPalette() ? Color.FromArgb(255, 135, 135) : Color.Firebrick;
        void FitHeight()
        {
            root.PerformLayout(); body.PerformLayout();
            var height = root.GetPreferredSize(new Size(dialog.ClientSize.Width, 0)).Height;
            dialog.ClientSize = new Size(dialog.ClientSize.Width, Math.Min(area.Height - (int)Math.Round(60 * scale), height + (int)Math.Round(4 * scale)));
        }
        confirm.DialogResult = DialogResult.None;
        var sourcePrefix = sourceContext is null ? "" : "Source: " + sourceContext + Environment.NewLine;
        string Normalize()
        {
            var normalized = WeatherExportNames.Normalize(name.Text, sourcePath, directory, keepBoth: false);
            if (normalized.Length > 255) throw new InvalidDataException("The mission filename is too long. Choose a shorter name.");
            return normalized;
        }
        void RefreshPreview()
        {
            dialog.Tag = null;
            try { preview.Text = sourcePrefix + "Install to: " + Path.Combine(directory, Normalize()); error.Text = ""; confirm.Enabled = true; }
            catch (Exception failure) when (failure is InvalidDataException or ArgumentException or NotSupportedException or PathTooLongException)
            { preview.Text = sourcePrefix + "Choose a valid mission filename."; error.Text = failure.Message; confirm.Enabled = false; }
        }
        name.TextChanged += (_, _) => RefreshPreview();
        confirm.Click += (_, _) =>
        {
            try
            {
                var path = Path.GetFullPath(Path.Combine(directory, Normalize()));
                if (Directory.Exists(path)) throw new InvalidDataException("A folder has this name. Choose another mission filename.");
                approve(dialog, path);
                if (dialog.DialogResult == DialogResult.None) name.Focus();
            }
            catch (Exception failure) when (failure is InvalidDataException or IOException or UnauthorizedAccessException or ArgumentException or NotSupportedException)
            { error.Text = failure.Message; dialog.Tag = null; name.Focus(); }
        };
        name.TextChanged += (_, _) => FitHeight();
        error.TextChanged += (_, _) => FitHeight();
        RefreshPreview();
        FitHeight();
        dialog.Shown += (_, _) => { name.Focus(); name.Select(0, Path.GetFileNameWithoutExtension(name.Text).Length); };
        return dialog;
    }

    private Form CreateMissionDownloadConflictDialog(string path, bool warehouseSource)
    {
        var body = new TableLayoutPanel { ColumnCount = 1, RowCount = 2, AutoSize = true };
        body.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        body.Controls.Add(new Label { AutoSize = true, Dock = DockStyle.Top, MaximumSize = new Size(Zoomed(570), 0),
            Text = "A mission with this filename already exists:" + Environment.NewLine + path,
            Margin = new Padding(0, 0, 0, Zoomed(12)) }, 0, 0);
        body.Controls.Add(new Label { AutoSize = true, Dock = DockStyle.Top, MaximumSize = new Size(Zoomed(570), 0),
            Text = warehouseSource ? "This mission is selected as a warehouse source. Choose another name to preserve it."
                : "Overwrite replaces this mission after validation. Change name returns to the filename editor and keeps your typed name." }, 0, 1);
        var dialog = CreateMissionDownloadDialog("Mission already exists", "Overwrite", body, out var overwrite);
        dialog.Name = "MissionDownloadConflict";
        dialog.ClientSize = new Size(Math.Min(dialog.ClientSize.Width, Zoomed(640)), Math.Min(dialog.ClientSize.Height, Zoomed(260)));
        overwrite.Name = "MissionDownloadOverwrite";
        overwrite.Enabled = !warehouseSource;
        var rename = MakeButton("Change name", () => { });
        rename.Name = "MissionDownloadRename";
        rename.DialogResult = DialogResult.Retry;
        rename.Dock = DockStyle.None;
        SizeDialogButton(rename, 110);
        rename.Margin = overwrite.Margin;
        overwrite.Parent!.Controls.Add(rename);
        overwrite.Parent.Controls.SetChildIndex(rename, 1);
        dialog.AcceptButton = rename;
        dialog.ActiveControl = rename;
        ApplyDialogChrome(dialog);
        return dialog;
    }

    private Form CreateMissionTemplateDialog(PreparedMissionDownload prepared, IReadOnlyList<MissionReleaseAsset> assets)
    {
        var body = new TableLayoutPanel { ColumnCount = 1, RowCount = 2 };
        body.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        body.RowStyles.Add(new RowStyle(SizeType.AutoSize)); body.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        body.Controls.Add(new Label { Text = "Choose the actual missions to install. ZIPs with several missions require an explicit selection.",
            AutoSize = true, Dock = DockStyle.Top, MaximumSize = new Size(Zoomed(780), 0), Margin = new Padding(0, 0, 0, Zoomed(12)) }, 0, 0);
        var choices = new CheckedListBox { Name = "MissionDownloadTemplates", CheckOnClick = true, IntegralHeight = false,
            HorizontalScrollbar = true, Dock = DockStyle.Fill };
        foreach (var asset in assets)
        {
            var templates = prepared.Packages[asset.Id].Templates;
            foreach (var template in templates) choices.Items.Add(new MissionTemplateItem(template), templates.Count == 1);
        }
        body.Controls.Add(choices, 0, 1);
        var dialog = CreateMissionDownloadDialog("Choose missions from the release", "Continue", body, out var confirm);
        confirm.Enabled = choices.CheckedItems.Count > 0;
        choices.ItemCheck += (_, e) => confirm.Enabled = choices.CheckedItems.Count + (e.NewValue == CheckState.Checked ? 1 : -1) > 0;
        return dialog;
    }

    private static (MissionConfigTarget Target, bool Selected)[] MissionConfigTargetChoices(
        IReadOnlyList<PreparedMissionTemplate> templates, IReadOnlyList<ServerProfileSettings> instances)
    {
        var variants = templates.SelectMany(t => t.ConfigMembers).Select(m => m.Variant).Distinct(StringComparer.OrdinalIgnoreCase).ToArray();
        return instances.SelectMany(instance => variants.Select(variant =>
        {
            var path = ResolveMatchingCopyTargetPath(instance.ConfigPath, variant);
            return (new MissionConfigTarget(instance.Name, path), PathsEqual(path, instance.ConfigPath));
        })).ToArray();
    }

    private static MissionConfigSource[] MissionConfigSourceChoices(IReadOnlyList<PreparedMissionTemplate> templates, string variant)
        => templates.SelectMany(t => t.ConfigMembers.Where(m => m.Variant.Equals(variant, StringComparison.OrdinalIgnoreCase))
            .Select(m => new MissionConfigSource(t, m))).GroupBy(s => s.Member.Sha256, StringComparer.OrdinalIgnoreCase).Select(g => g.First()).ToArray();

    private Form CreateMissionConfigDialog(IReadOnlyList<PreparedMissionTemplate> templates, IReadOnlyList<ServerProfileSettings> instances)
    {
        var body = new TableLayoutPanel { ColumnCount = 1, RowCount = 3 };
        body.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        body.RowStyles.Add(new RowStyle(SizeType.AutoSize)); body.RowStyles.Add(new RowStyle(SizeType.Percent, 52));
        body.RowStyles.Add(new RowStyle(SizeType.Percent, 48));
        body.Controls.Add(new Label { AutoSize = true, Dock = DockStyle.Top, MaximumSize = new Size(Zoomed(780), 0),
            Text = "Choose the Config target or defaults source needed to continue. Each instance keeps its current values." }, 0, 0);
        var targets = new CheckedListBox { Name = "MissionDownloadConfigPaths", Dock = DockStyle.Fill, CheckOnClick = true,
            HorizontalScrollbar = true, IntegralHeight = false, Margin = new Padding(0, Zoomed(12), 0, Zoomed(12)) };
        var variants = templates.SelectMany(t => t.ConfigMembers).Select(m => m.Variant).Distinct(StringComparer.OrdinalIgnoreCase).ToArray();
        foreach (var choice in MissionConfigTargetChoices(templates, instances))
            targets.Items.Add(choice.Target, choice.Selected);
        body.Controls.Add(targets, 0, 1);
        var sources = new TableLayoutPanel { Name = "MissionDownloadConfigSources", Dock = DockStyle.Fill, AutoScroll = true, ColumnCount = 1 };
        sources.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        foreach (var variant in variants)
        {
            var label = new Label { Text = "Defaults source · " + variant, AutoSize = true, Dock = DockStyle.Top };
            sources.Controls.Add(label);
            var choice = new WeatherChoiceBox { Name = "MissionConfigSource-" + variant, Tag = variant, Dock = DockStyle.Top,
                DropDownStyle = ComboBoxStyle.DropDownList };
            var candidates = MissionConfigSourceChoices(templates, variant);
            choice.Items.AddRange(candidates.Cast<object>().ToArray());
            if (candidates.Length == 1) choice.SelectedIndex = 0;
            sources.Controls.Add(choice);
            StyleInput(choice); StyleConfigDropdown(choice);
        }
        body.Controls.Add(sources, 0, 2);
        var dialog = CreateMissionDownloadDialog("Choose Config targets and defaults", "Continue", body, out var confirm);
        void Refresh(CheckState? newState = null, int index = -1)
        {
            var selected = targets.Items.Cast<MissionConfigTarget>().Where((_, i) =>
                i == index ? newState == CheckState.Checked : targets.GetItemChecked(i)).ToArray();
            foreach (var choice in sources.Controls.OfType<ComboBox>())
                choice.Enabled = selected.Any(t => Path.GetFileName(t.Path).Equals((string)choice.Tag!, StringComparison.OrdinalIgnoreCase));
            confirm.Enabled = selected.Length > 0 && sources.Controls.OfType<ComboBox>().Where(c => c.Enabled).All(c => c.SelectedItem is MissionConfigSource);
        }
        targets.ItemCheck += (_, e) => Refresh(e.NewValue, e.Index);
        foreach (var choice in sources.Controls.OfType<ComboBox>()) choice.SelectedIndexChanged += (_, _) => Refresh();
        Refresh();
        return dialog;
    }

    private Form CreateMissionInstallReview(ReviewedMissionDownload reviewed)
    {
        var body = new TableLayoutPanel { ColumnCount = 1, RowCount = 4 };
        body.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        body.RowStyles.Add(new RowStyle(SizeType.AutoSize)); body.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        body.RowStyles.Add(new RowStyle(SizeType.AutoSize)); body.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        body.Controls.Add(new Label { AutoSize = true, Dock = DockStyle.Top, MaximumSize = new Size(Zoomed(780), 0),
            Text = "Review the exact paths below. Successful earlier files remain installed if a later file fails or the job is cancelled." }, 0, 0);
        var lines = reviewed.Outputs.Select(p => (p.CollisionPolicy == MissionCollisionPolicy.Skip && p.ReviewedIdentity?.Exists == true ? "Skip: " : "Mission: ") + p.OutputPath)
            .Concat(reviewed.ZipOutputs.Values.Select(p => "ZIP: " + p))
            .Concat(reviewed.Imports.SelectMany(g => g.Plans).Select(p => (p.CreateMissing ? "Create Config: " : "Update Config, keep current: ") + p.Current.Path));
        var details = new TextBox { Name = "MissionDownloadExactPaths", ReadOnly = true, Multiline = true, WordWrap = false,
            ScrollBars = ScrollBars.Both, Dock = DockStyle.Fill, Text = string.Join(Environment.NewLine, lines), Margin = new Padding(0, Zoomed(12), 0, Zoomed(12)) };
        var warehouseChoices = new Dictionary<long, ComboBox>();
        if (reviewed.Selection.CopyWarehouses && !reviewed.Selection.ZipOnly)
        {
            var scroll = new Panel { Name = "MissionWarehouseReviewScroll", Dock = DockStyle.Fill, AutoScroll = true };
            var content = new TableLayoutPanel { Name = "MissionWarehouseReviewContent", ColumnCount = 1,
                RowCount = 1, AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink, Dock = DockStyle.Top };
            content.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            content.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(180)));
            details.Dock = DockStyle.Fill;
            content.Controls.Add(details, 0, 0);
            warehouseChoices = AddMissionWarehouseReviewSources(reviewed, content);
            scroll.Controls.Add(content);
            body.Controls.Add(scroll, 0, 1);
        }
        else body.Controls.Add(details, 0, 1);
        var create = new CheckBox { Name = "MissionDownloadApproveCreation", AutoSize = true, Dock = DockStyle.Top,
            Text = "Create the " + reviewed.Creations.Count + " listed new Config file(s)", Visible = reviewed.Creations.Count > 0 };
        var replace = new CheckBox { Name = "MissionDownloadApproveReplacement", AutoSize = true, Dock = DockStyle.Top,
            Text = "Back up and replace the " + reviewed.Replacements.Count + " existing file(s)", Visible = reviewed.Replacements.Count > 0 };
        body.Controls.Add(create, 0, 2); body.Controls.Add(replace, 0, 3);
        var dialog = CreateMissionDownloadDialog("Review mission installation", reviewed.Selection.ZipOnly ? "Save ZIPs" : "Install", body, out var confirm);
        void Refresh()
        {
            reviewed.CreationApproved = reviewed.Creations.Count == 0 || create.Checked;
            reviewed.ReplacementApproved = reviewed.Replacements.Count == 0 || replace.Checked;
            confirm.Enabled = reviewed.CreationApproved && reviewed.ReplacementApproved && reviewed.RevisedWarehouseSources is null;
        }
        var recheck = MakeButton("Check sources again", () => { });
        recheck.Name = "MissionWarehouseReviewRecheck";
        recheck.DialogResult = DialogResult.Retry;
        recheck.Dock = DockStyle.None;
        recheck.Visible = false;
        SizeDialogButton(recheck, 145);
        recheck.Margin = new Padding(Zoomed(8), Zoomed(10), 0, 0);
        confirm.Parent!.Controls.Add(recheck);
        foreach (var choice in warehouseChoices.Values)
            choice.SelectedIndexChanged += (_, _) =>
            {
                var current = warehouseChoices.ToDictionary(pair => pair.Key,
                    pair => (pair.Value.SelectedItem as MissionWarehouseSource)?.Path);
                var changed = current.Any(pair => !string.Equals(pair.Value,
                    reviewed.Selection.WarehouseSources.GetValueOrDefault(pair.Key), StringComparison.OrdinalIgnoreCase));
                reviewed.RevisedWarehouseSources = changed ? current : null;
                foreach (var pair in current)
                    UpdateMissionWarehouseReviewDetail(dialog, pair.Key, pair.Value,
                        !string.Equals(pair.Value, reviewed.Selection.WarehouseSources.GetValueOrDefault(pair.Key), StringComparison.OrdinalIgnoreCase));
                recheck.Visible = changed;
                create.Checked = replace.Checked = false;
                Refresh();
            };
        create.CheckedChanged += (_, _) => Refresh(); replace.CheckedChanged += (_, _) => Refresh(); Refresh();
        return dialog;
    }
}
