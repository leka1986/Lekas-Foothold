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
        var suggested = settings is null ? WeatherExportNames.SuggestOptions(context.InputPath, era, dateTime is null ? null : dateTime.ChangeStartTime != false ? dateTime.StartTimeSeconds : context.SourceStartTimeSeconds, includeOptions)
            : WeatherExportNames.Suggest(context.InputPath, era, cloudName, settings, context.SourceStartTimeSeconds);
        using var dialog = new Form
        {
            Name = "WeatherExportNameDialog", Text = "Export mission", Font = Font,
            StartPosition = FormStartPosition.CenterParent, MinimizeBox = false, MaximizeBox = false,
            FormBorderStyle = FormBorderStyle.FixedDialog, ClientSize = new Size(S(660), S(290))
        };
        var body = new TableLayoutPanel { Dock = DockStyle.Fill, Padding = new Padding(S(18)), ColumnCount = 1, RowCount = 8, AutoScroll = true };
        body.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        var name = new TextBox { Name = "WeatherExportNameInput", Dock = DockStyle.Fill,
            Text = context.ExistingChoice?.FileName ?? suggested, Margin = new Padding(0, S(8), 0, S(12)) };
        var error = new Label { AutoSize = true, MaximumSize = new Size(S(620), 0), ForeColor = Color.Firebrick, Margin = new Padding(0, S(8), 0, S(8)) };
        void Complete(bool keepBoth)
        {
            try
            {
                var normalized = WeatherExportNames.Normalize(name.Text, context.InputPath, directory, keepBoth);
                if (!keepBoth && File.Exists(Path.Combine(directory, normalized)))
                    throw new InvalidDataException("That name already exists. Choose Keep both or another name.");
                name.Text = normalized;
                result = new WeatherMizExportChoice(normalized, directory, keepBoth);
                dialog.DialogResult = DialogResult.OK;
            }
            catch (Exception ex) when (ex is InvalidDataException or ArgumentException or NotSupportedException or PathTooLongException)
            { error.Text = ex.Message; name.Focus(); }
        }
        var ok = Button("OK", () => Complete(false), "WeatherExportNameOk");
        var keepBoth = Button("Keep both", () => Complete(true), "WeatherExportKeepBoth");
        var chooseName = Button("Choose another name", () => { name.Focus(); name.SelectAll(); }, "WeatherExportChooseName");
        var install = new CheckBox { Name = "WeatherExportInstallInstance", Text = "Install in selected instance’s Missions folder",
            AutoSize = true, Enabled = instanceAvailable, MaximumSize = new Size(S(620), 0), Margin = new Padding(0, S(8), 0, S(4)) };
        install.Checked = instanceAvailable && context.ExistingChoice is { } previous
            && Path.GetFullPath(previous.Directory).Equals(Path.GetFullPath(instanceDirectory!), StringComparison.OrdinalIgnoreCase);
        directory = install.Checked ? instanceDirectory! : sourceDirectory;
        var cancel = Button("Cancel", () => dialog.DialogResult = DialogResult.Cancel, "WeatherExportNameCancel");
        body.Controls.Add(new Label { Text = "Name your mission", AutoSize = true, Font = _boldFont }, 0, 0);
        body.Controls.Add(name, 0, 1);
        var preview = new Label { Name = "WeatherExportNamePreview", AutoSize = true, MaximumSize = new Size(S(620), 0) };
        void RefreshPreview()
        {
            try
            {
                var normalized = WeatherExportNames.Normalize(name.Text, context.InputPath, directory, true);
                var candidate = Path.Combine(directory, normalized);
                var exists = candidate.Equals(context.InputPath, StringComparison.OrdinalIgnoreCase) || File.Exists(candidate);
                preview.Text = "New mission: " + candidate;
                error.Text = exists ? "This filename already exists. Choose Keep both, another name, or Cancel." : "";
                ok.Enabled = !exists;
                keepBoth.Visible = chooseName.Visible = exists;
            }
            catch (Exception ex) when (ex is InvalidDataException or ArgumentException or NotSupportedException or PathTooLongException)
            { preview.Text = "Choose a valid new mission filename."; error.Text = ex.Message; ok.Enabled = false; keepBoth.Visible = chooseName.Visible = false; }
            FitHeight();
        }
        name.TextChanged += (_, _) => RefreshPreview();
        install.CheckedChanged += (_, _) => { directory = install.Checked ? instanceDirectory! : sourceDirectory; RefreshPreview(); };
        body.Controls.Add(preview, 0, 2);
        body.Controls.Add(new Label { Text = "Manager Era: " + (string.IsNullOrWhiteSpace(era) ? "not selected" : era), AutoSize = true }, 0, 3);

        body.Controls.Add(install, 0, 4);
        body.Controls.Add(new Label { Name = "WeatherExportDestinationHelp", AutoSize = true, MaximumSize = new Size(S(620), 0),
            Text = instanceAvailable ? "" : "Select an instance with an available Missions folder to install there.", Margin = new Padding(0, 0, 0, S(4)) }, 0, 5);
        body.Controls.Add(error, 0, 6);
        var actions = Row(ok, keepBoth, chooseName, cancel);
        actions.FlowDirection = FlowDirection.RightToLeft;
        body.Controls.Add(actions, 0, 7);
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
        dialog.Shown += (_, _) => { RefreshPreview(); name.Focus(); name.Select(0, Path.GetFileNameWithoutExtension(name.Text).Length); };
        return dialog.ShowDialog(DialogOwner) == DialogResult.OK ? result : null;
    }
}