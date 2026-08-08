namespace FootholdConfigManager;

internal sealed class UiViewGeneration
{
    public long Current { get; private set; }

    public long Next()
    {
        Current++;
        return Current;
    }

    public bool IsCurrent(long generation) => generation == Current;
}
