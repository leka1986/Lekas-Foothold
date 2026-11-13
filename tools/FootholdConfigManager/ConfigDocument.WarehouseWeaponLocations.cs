namespace FootholdConfigManager;

internal sealed partial class ConfigDocument
{
    internal bool HasWarehouseWeaponLocationTables() =>
        TryFindTableBlock(WarehouseWeaponLocations.RulesKey, out _, out _) &&
        TryFindTableBlock(WarehouseWeaponLocations.CatalogKey, out _, out _);

    internal bool TryReadWarehouseWeaponLocations(out WarehouseWeaponLocations? settings)
    {
        settings = null;
        if (!TryGetTableBlockText(WarehouseWeaponLocations.RulesKey, out var rules) ||
            !TryGetTableBlockText(WarehouseWeaponLocations.CatalogKey, out var catalog))
        {
            return false;
        }

        settings = new WarehouseWeaponLocations(rules, catalog);
        return true;
    }

    internal bool SetWarehouseWeaponRulesText(string text)
    {
        if (!TryFindTableBlock(WarehouseWeaponLocations.RulesKey, out var start, out var end))
            return false;

        var replacement = text.Split('\n');
        var count = end - start + 1;
        _lines.RemoveRange(start, count);
        _lines.InsertRange(start, replacement);
        ShiftLineIndexes(end + 1, replacement.Length - count);
        _hasStructuralChanges = true;
        return true;
    }
}
