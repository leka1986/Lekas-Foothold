namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private const float EditorFontIncreasePoints = 2f;
    internal const float AdditionalValueFontPoints = 1f;
    internal static float ValueFontPointsAtZoom(float scale) => AdditionalValueFontPoints + (Math.Abs(scale - 1f) < .0001f ? 1f : 0f);
    private readonly Dictionary<(int Zoom, float ExtraPoints, FontStyle Style), Font> _configDropdownFonts = new();

    private Font ConfigDropdownFont => GetConfigValueFont(1f + ValueFontPointsAtZoom(_uiZoomPercent / 100f));
    private Font ConfigCellValueFont => GetConfigValueFont(ValueFontPointsAtZoom(_uiZoomPercent / 100f));
    private Font ConfigGridHeaderFont => GetConfigValueFont(ValueFontPointsAtZoom(_uiZoomPercent / 100f), FontStyle.Bold);

    private Font GetConfigValueFont(float extraPoints, FontStyle style = FontStyle.Regular)
    {
        var key = (_uiZoomPercent, extraPoints, style);
        if (!_configDropdownFonts.TryGetValue(key, out var font))
            _configDropdownFonts.Add(key, font = new Font("Segoe UI",
                BaseFontSize * _uiZoomPercent / UiZoomBaselinePercent + (extraPoints + EditorFontIncreasePoints) * _uiZoomPercent / 100f, style));
        return font;
    }

    private void StyleConfigDropdown(ComboBox combo)
    {
        combo.Font = combo is DataGridViewComboBoxEditingControl && ContainingEditorSection(combo) is not null
            ? GetConfigValueFont(1.35f) : ConfigDropdownFont;
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

    private static void StyleConfigChoiceCell(DataGridViewComboBoxCell cell, MainForm owner, Font? knownFont = null)
    {
        var font = knownFont ?? (cell.DataGridView is { } grid && ContainingEditorSection(grid) is not null
            ? owner.GetConfigValueFont(1.35f) : owner.ConfigDropdownFont);
        cell.Style.Font = font;
        cell.OwningRow.MinimumHeight = Math.Max(cell.OwningRow.MinimumHeight, font.Height + 6);
    }
}
