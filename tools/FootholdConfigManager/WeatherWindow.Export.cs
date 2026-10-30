namespace FootholdConfigManager;

internal sealed partial class WeatherWindow
{
    private string? PromptExportName(WeatherMizNamingContext context, WeatherSettings? settings, string? era, string? cloudName, MissionDateTimeSettings? dateTime = null, bool includeOptions = true)
    {
        var directory = Path.GetDirectoryName(context.InputPath)!;
        var suggested = settings is null ? WeatherExportNames.SuggestOptions(context.InputPath, era, dateTime?.StartTimeSeconds, includeOptions)
            : WeatherExportNames.Suggest(context.InputPath, era, cloudName, settings, context.SourceStartTimeSeconds);
        using var dialog = new Form
        {
            Name = "WeatherExportNameDialog", Text = "Export mission", Font = Font,
            StartPosition = FormStartPosition.CenterParent, MinimizeBox = false, MaximizeBox = false,
            FormBorderStyle = FormBorderStyle.FixedDialog, ClientSize = new Size(S(660), S(290))
        };
        var body = new TableLayoutPanel { Dock = DockStyle.Fill, Padding = new Padding(S(18)), ColumnCount = 1, RowCount = 7 };
        body.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        var name = new TextBox { Name = "WeatherExportNameInput", Dock = DockStyle.Fill,
            Text = WeatherExportNames.AvailableName(directory, suggested), Margin = new Padding(0, S(8), 0, S(12)) };
        var error = new Label { AutoSize = true, MaximumSize = new Size(S(620), 0), ForeColor = Color.Firebrick, Margin = new Padding(0, S(8), 0, S(8)) };
        var ok = Button("OK", () =>
        {
            try
            {
                var normalized = WeatherExportNames.Normalize(name.Text, context.InputPath);
                if (File.Exists(Path.Combine(directory, normalized)))
                    throw new InvalidDataException("That name already exists. Choose another name to keep both missions.");
                name.Text = normalized;
                dialog.DialogResult = DialogResult.OK;
            }
            catch (Exception ex) when (ex is InvalidDataException or ArgumentException or NotSupportedException or PathTooLongException)
            { error.Text = ex.Message; name.Focus(); }
        }, "WeatherExportNameOk");
        var cancel = Button("Cancel", () => dialog.DialogResult = DialogResult.Cancel, "WeatherExportNameCancel");
        body.Controls.Add(new Label { Text = "Name your mission", AutoSize = true, Font = _boldFont }, 0, 0);
        body.Controls.Add(name, 0, 1);
        var preview = new Label { Name = "WeatherExportNamePreview", AutoSize = true, MaximumSize = new Size(S(620), S(60)) };
        void RefreshPreview()
        {
            try { preview.Text = "New mission: " + Path.Combine(directory, WeatherExportNames.Normalize(name.Text, context.InputPath)); }
            catch (Exception ex) when (ex is InvalidDataException or ArgumentException or NotSupportedException or PathTooLongException)
            { preview.Text = "Choose a valid new mission filename."; }
        }
        name.TextChanged += (_, _) => RefreshPreview();
        RefreshPreview();
        body.Controls.Add(preview, 0, 2);
        body.Controls.Add(new Label { Text = "Manager Era: " + (string.IsNullOrWhiteSpace(era) ? "not selected" : era), AutoSize = true }, 0, 3);

        body.Controls.Add(error, 0, 5);
        var actions = Row(ok, cancel);
        actions.FlowDirection = FlowDirection.RightToLeft;
        body.Controls.Add(actions, 0, 6);
        dialog.Controls.Add(body);
        dialog.AcceptButton = ok;
        dialog.CancelButton = cancel;
        _style(dialog);
        ApplyWeatherChrome(dialog);
        if (dialog.BackColor.GetBrightness() < .5f) error.ForeColor = Color.FromArgb(255, 135, 135);
        dialog.Shown += (_, _) => { name.Focus(); name.Select(0, Path.GetFileNameWithoutExtension(name.Text).Length); };
        return dialog.ShowDialog(DialogOwner) == DialogResult.OK ? name.Text : null;
    }
}