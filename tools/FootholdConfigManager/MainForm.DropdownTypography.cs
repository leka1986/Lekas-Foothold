namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    internal const float AdditionalValueFontPoints = 1f;
    internal static float ValueFontPointsAtZoom(float scale) => AdditionalValueFontPoints + (Math.Abs(scale - 1f) < .0001f ? 1f : 0f);
    private readonly Dictionary<(int Zoom, float ExtraPoints), Font> _configDropdownFonts = new();

    private Font ConfigDropdownFont => GetConfigValueFont(1f + ValueFontPointsAtZoom(_uiZoomPercent / 100f));
    private Font ConfigCellValueFont => GetConfigValueFont(ValueFontPointsAtZoom(_uiZoomPercent / 100f));

    private Font GetConfigValueFont(float extraPoints)
    {
        var key = (_uiZoomPercent, extraPoints);
        if (!_configDropdownFonts.TryGetValue(key, out var font))
            _configDropdownFonts.Add(key, font = new Font("Segoe UI", BaseFontSize * _uiZoomPercent / UiZoomBaselinePercent + extraPoints * _uiZoomPercent / 100f));
        return font;
    }

    private void StyleConfigDropdown(ComboBox combo)
    {
        combo.Font = ConfigDropdownFont;
        combo.DrawMode = DrawMode.OwnerDrawFixed;
        combo.DrawItem -= DrawComboBoxItem;
        combo.DrawItem += DrawComboBoxItem;
        combo.ItemHeight = combo.Font.Height + 4;
        combo.DropDown -= SizeConfigDropdown;
        combo.DropDown += SizeConfigDropdown;
    }

    private static void SizeConfigDropdown(object? sender, EventArgs args)
    {
        var combo = (ComboBox)sender!;
        combo.DropDownWidth = GetComboBoxDropDownWidth(combo);
    }

    private static void StyleConfigChoiceCell(DataGridViewComboBoxCell cell, MainForm owner)
    {
        cell.Style.Font = owner.ConfigDropdownFont;
        cell.OwningRow.MinimumHeight = Math.Max(cell.OwningRow.MinimumHeight, owner.ConfigDropdownFont.Height + 6);
    }
}