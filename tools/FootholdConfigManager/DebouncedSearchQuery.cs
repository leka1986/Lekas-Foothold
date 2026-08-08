namespace FootholdConfigManager;

internal sealed class DebouncedSearchQuery
{
    private string? _query;

    public void Schedule(string query)
    {
        _query = query;
    }

    public bool TryTake(out string query)
    {
        if (_query is null)
        {
            query = "";
            return false;
        }

        query = _query;
        _query = null;
        return true;
    }

    public void Clear()
    {
        _query = null;
    }
}
