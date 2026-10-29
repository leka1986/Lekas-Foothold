namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private void BindManagedStringListRefresh(ConfigStringListTable table, Control owner, Action<IReadOnlySet<string>> refresh)
    {
        var source = table.ManagedSource;
        if (source is null) return;
        var document = _document!;
        void Refresh()
        {
            if (owner.IsDisposed || !ReferenceEquals(_document, document)) return;
            var values = document.GetManagedStringListValues(table);
            if (values is not null) refresh(values);
        }
        source.ManagedValuesChanged += Refresh;
        owner.Disposed += (_, _) => source.ManagedValuesChanged -= Refresh;
    }
}
