namespace FootholdConfigManager;

internal sealed partial class WeatherWindow
{
    private WeatherMizExportChoice? PromptExportName(WeatherMizNamingContext context, WeatherSettings? settings, string? era, string? cloudName, MissionDateTimeSettings? dateTime = null, bool includeOptions = true)
    {
        var sourceDirectory = Path.GetDirectoryName(context.InputPath)!;
        var instanceDirectory = _exportDestinationProvider?.Invoke();
        var instanceAvailable = instanceDirectory is not null && Path.IsPathFullyQualified(instanceDirectory) && Directory.Exists(instanceDirectory);
        var directory = sourceDirectory;
        WeatherMizExportChoice? result = null;
        var originalsAvailable = WeatherMizService.BotOriginalsAvailable(context.InputPath, instanceDirectory);
        var saveOriginal = new WeatherCheckBox { Name = "WeatherExportSaveOriginal", Text = "Save as DCSServerBot original (.miz.orig)",
            AutoSize = true, MaximumSize = new Size(S(620), 0), Visible = originalsAvailable,
            Checked = originalsAvailable && context.ExistingChoice?.SaveAsOriginal == true, Margin = new Padding(0, S(4), 0, S(12)) };
        var suggested = settings is null ? WeatherExportNames.SuggestOptions(context.InputPath, era, dateTime is null ? null : dateTime.ChangeStartTime != false ? dateTime.StartTimeSeconds : context.SourceStartTimeSeconds, includeOptions)
            : WeatherExportNames.Suggest(context.InputPath, era, cloudName, settings, context.SourceStartTimeSeconds);
        using var dialog = new Form
        {
            Name = "WeatherExportNameDialog", Text = "Export mission", Font = Font,
            StartPosition = FormStartPosition.CenterParent, MinimizeBox = false, MaximizeBox = false,
            FormBorderStyle = FormBorderStyle.FixedDialog, ClientSize = new Size(S(660), S(290))
        };
        var body = new TableLayoutPanel { Dock = DockStyle.Fill, Padding = new Padding(S(18)), ColumnCount = 1, RowCount = 10, AutoScroll = true };
        body.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        var name = new TextBox { Name = "WeatherExportNameInput", Dock = DockStyle.Fill,
            Text = context.ExistingChoice?.FileName ?? suggested, Margin = new Padding(0, S(8), 0, S(12)) };
        var error = new Label { AutoSize = true, MaximumSize = new Size(S(620), 0), ForeColor = Color.Firebrick, Margin = new Padding(0, S(8), 0, S(8)) };
        void Complete(bool keepBoth)
        {
            try
            {
                var original = originalsAvailable && saveOriginal.Checked;
                var normalized = WeatherExportNames.Normalize(name.Text, context.InputPath, directory, keepBoth || original, original);
                var candidate = Path.GetFullPath(Path.Combine(directory, normalized));
                MissionPathIdentity? replacement = null;
                if (!keepBoth && File.Exists(candidate))
                {
                    if (!original) throw new InvalidDataException("That name already exists. Choose Keep both or another name.");
                    replacement = MissionPathIdentity.Capture(candidate);
                    if (MessageBox.Show(dialog, "Apply the selected settings to this DCSServerBot original?" + Environment.NewLine
                        + Environment.NewLine + Path.GetFileName(candidate), "Replace the original?", MessageBoxButtons.YesNo,
                        MessageBoxIcon.Question, MessageBoxDefaultButton.Button2) != DialogResult.Yes) return;
                }
                name.Text = normalized;
                result = new WeatherMizExportChoice(normalized, directory, keepBoth)
                { SaveAsOriginal = original, OriginalMissionsDirectory = instanceDirectory, ReplacementIdentity = replacement };
                dialog.DialogResult = DialogResult.OK;
            }
            catch (Exception ex) when (ex is InvalidDataException or IOException or UnauthorizedAccessException or ArgumentException or NotSupportedException)
            { error.Text = ex.Message; name.Focus(); }
        }
        var ok = Button("Save copy", () => Complete(false), "WeatherExportNameOk");
        var keepBoth = Button("Keep both", () => Complete(true), "WeatherExportKeepBoth");
        var chooseName = Button("Choose another name", () => { name.Focus(); name.SelectAll(); }, "WeatherExportChooseName");
        var install = new CheckBox { Name = "WeatherExportInstallInstance", Text = "Install in selected instance’s Missions folder",
            AutoSize = true, Enabled = instanceAvailable, MaximumSize = new Size(S(620), 0), Margin = new Padding(0, S(8), 0, S(4)) };
        install.Checked = instanceAvailable && context.ExistingChoice is { } previous
            && Path.GetFullPath(previous.Directory).Equals(Path.GetFullPath(instanceDirectory!), StringComparison.OrdinalIgnoreCase);
        directory = install.Checked ? instanceDirectory! : sourceDirectory;
        var cancel = Button("Cancel", () => dialog.DialogResult = DialogResult.Cancel, "WeatherExportNameCancel");
        body.Controls.Add(new Label { Name = "WeatherExportSource", Text = (originalsAvailable ? "DCSServerBot detected for this mission folder" + Environment.NewLine : "")
            + "Source: " + Path.GetFileName(context.InputPath), AutoSize = true, MaximumSize = new Size(S(620), 0) }, 0, 0);
        body.Controls.Add(saveOriginal, 0, 1);
        body.Controls.Add(new Label { Text = "Name your mission", AutoSize = true, Font = _boldFont }, 0, 2);
        body.Controls.Add(name, 0, 3);
        var originalName = Button("Use original name", () => {
            name.Text = WeatherExportNames.WithMissionExtension(Path.GetFileName(context.InputPath), saveOriginal.Checked);
        }, "WeatherExportUseOriginalName");
        originalName.Width += S(24);
        originalName.Anchor = AnchorStyles.Left;
        body.Controls.Add(originalName, 0, 4);
        var preview = new Label { Name = "WeatherExportNamePreview", AutoSize = true, MaximumSize = new Size(S(620), 0) };
        void RefreshPreview()
        {
            try
            {
                var original = originalsAvailable && saveOriginal.Checked;
                var normalized = WeatherExportNames.Normalize(name.Text, context.InputPath, directory, true, original);
                var candidate = Path.Combine(directory, normalized);
                var exists = candidate.Equals(context.InputPath, StringComparison.OrdinalIgnoreCase) || File.Exists(candidate);
                var replace = original && exists;
                preview.Text = (replace ? "Replace selected original: " : "New copy: ") + candidate;
                error.Text = replace ? ""
                    : exists ? "This filename already exists. Choose Keep both, another name, or Cancel." : "";
                ok.Text = replace ? "Replace original…" : "Save copy";
                ok.Width = Math.Max(S(80), TextRenderer.MeasureText(ok.Text, Font).Width + S(40));
                error.ForeColor = replace ? dialog.ForeColor : dialog.BackColor.GetBrightness() < .5f ? Color.FromArgb(255, 135, 135) : Color.Firebrick;
                ok.Enabled = !exists || replace;
                keepBoth.Visible = chooseName.Visible = exists && !original;
            }
            catch (Exception ex) when (ex is InvalidDataException or ArgumentException or NotSupportedException or PathTooLongException)
            { preview.Text = "Choose a valid new mission filename."; error.Text = ex.Message; ok.Enabled = false; keepBoth.Visible = chooseName.Visible = false; }
            FitHeight();
        }
        name.TextChanged += (_, _) => RefreshPreview();
        saveOriginal.CheckedChanged += (_, _) => {
            name.Text = WeatherExportNames.WithMissionExtension(name.Text, saveOriginal.Checked);
            RefreshPreview();
        };
        install.CheckedChanged += (_, _) => { directory = install.Checked ? instanceDirectory! : sourceDirectory; RefreshPreview(); };
        body.Controls.Add(preview, 0, 5);
        body.Controls.Add(install, 0, 6);
        body.Controls.Add(new Label { Name = "WeatherExportDestinationHelp", AutoSize = true, MaximumSize = new Size(S(620), 0),
            Text = instanceAvailable ? "" : "Select an instance with an available Missions folder to install there.", Margin = new Padding(0, 0, 0, S(4)) }, 0, 7);
        body.Controls.Add(error, 0, 8);
        var actions = Row(ok, keepBoth, chooseName, cancel);
        actions.FlowDirection = FlowDirection.RightToLeft;
        body.Controls.Add(actions, 0, 9);
        for (var row = 0; row < body.RowCount; row++) body.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        dialog.Controls.Add(body);
        dialog.AcceptButton = ok;
        dialog.CancelButton = cancel;
        _style(dialog);
        ApplyWeatherChrome(dialog);
        if (dialog.BackColor.GetBrightness() < .5f) error.ForeColor = Color.FromArgb(255, 135, 135);
        void FitHeight()
        {
            body.PerformLayout();
            var height = body.GetPreferredSize(new Size(dialog.ClientSize.Width, 0)).Height;
            var available = Screen.FromControl(dialog).WorkingArea.Height - S(60);
            dialog.ClientSize = new Size(dialog.ClientSize.Width, Math.Min(available, Math.Max(S(290), height + S(4))));
        }
        RefreshPreview();
        dialog.Shown += (_, _) => { RefreshPreview(); name.Focus(); name.Select(0, WeatherExportNames.MissionStem(name.Text).Length); };
        return dialog.ShowDialog(DialogOwner) == DialogResult.OK ? result : null;
    }
}