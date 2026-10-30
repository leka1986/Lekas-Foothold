namespace FootholdConfigManager;

internal sealed partial class WeatherWindow
{
    private void WireWeatherBackgroundFocus()
    {
        MouseDown += HandleWeatherBackgroundMouseDown;
        foreach (var control in Descendants(this))
            if (control is WeatherInputFrame || control is Panel or Label or PictureBox && !IsWeatherEditorSurface(control))
                control.MouseDown += HandleWeatherBackgroundMouseDown;
    }

    private bool IsWeatherEditorSurface(Control control)
    {
        for (var current = control; current is not null && current != this; current = current.Parent)
            if (current is WeatherInputFrame or WeatherWindDial or NumericUpDown or TextBoxBase or ComboBox
                or DateTimePicker or TrackBar or DataGridView or ButtonBase or ScrollBar)
                return true;
        return false;
    }

    private void HandleWeatherBackgroundMouseDown(object? sender, MouseEventArgs args)
    {
        if (args.Button == MouseButtons.Left) _root.Parent!.Focus();
    }
}