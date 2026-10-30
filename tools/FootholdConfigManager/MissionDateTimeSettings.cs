namespace FootholdConfigManager;

internal sealed class MissionDateTimeSettings
{
    public bool ChangeDate { get; set; }
    public DateTime MissionDate { get; set; } = DateTime.Today;
    public double StartTimeSeconds { get; set; }

    internal void Validate()
    {
        if (!double.IsFinite(StartTimeSeconds) || StartTimeSeconds < 0 || StartTimeSeconds > 86399)
            throw new InvalidDataException("Mission start time must be between 00:00:00 and 23:59:59.");
    }
}