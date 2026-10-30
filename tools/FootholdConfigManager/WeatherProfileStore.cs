using System.Text.Encodings.Web;
using System.Text.Json;

namespace FootholdConfigManager;

internal sealed class WeatherNamedProfile
{
    public string Name { get; set; } = "";
    public WeatherSettings Settings { get; set; } = new();
    public override string ToString() => Name;
}

internal sealed class WeatherPreferences
{
    public string? DcsInstallationPath { get; set; }
    public bool DcsInstallationIsExplicit { get; set; }
    public bool ReplaceOriginal { get; set; }
    public int WeatherLayoutVersion { get; set; }
    public WeatherSettings Current { get; set; } = new();
    public List<WeatherNamedProfile> Profiles { get; set; } = new();
    public MissionOptionsSettings MissionOptions { get; set; } = new();
    public bool ApplyWeather { get; set; } = true;
    public bool ApplyMissionOptions { get; set; }
    public bool? ApplyDateTime { get; set; }
    public MissionDateTimeSettings? DateTime { get; set; }
    public int WorkspaceTab { get; set; }
    public int WeatherTab { get; set; }
    public int CloudBaseUnit { get; set; }
    public int PressureUnit { get; set; }
    public int WindConvention { get; set; }
    public string? WeatherProfileName { get; set; }

    internal void Validate()
    {
        if (Current is null || Profiles is null || MissionOptions is null
            || Profiles.Any(profile => profile is null || profile.Settings is null || string.IsNullOrWhiteSpace(profile.Name)))
            throw new InvalidDataException("The weather profiles file contains an invalid profile or mission options.");
        Current.Validate();
        MissionOptions.Validate();
        DateTime?.Validate();
        foreach (var profile in Profiles) profile.Settings.Validate();
        if (WorkspaceTab is < 0 or > 1 || WeatherTab is < 0 or > 3 || CloudBaseUnit is < 0 or > 1
            || PressureUnit is < 0 or > 2 || WindConvention is < 0 or > 1)
            throw new InvalidDataException("The mission settings file contains an invalid view selection.");
    }
}

internal sealed class WeatherProfileStore
{
    private static readonly JsonSerializerOptions Json = new()
    {
        WriteIndented = true,
        Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping
    };
    public string FilePath { get; }
    public WeatherProfileStore(string? directory = null) =>
        FilePath = Path.Combine(directory ?? RuntimeSettings.SettingsDirectory, "weather.json");

    public WeatherPreferences Load()
    {
        if (!File.Exists(FilePath)) return new WeatherPreferences();
        try
        {
            var preferences = JsonSerializer.Deserialize<WeatherPreferences>(File.ReadAllText(FilePath), Json)
                ?? throw new InvalidDataException("The weather profiles file is empty.");
            preferences.Validate();
            return preferences;
        }
        catch (JsonException ex) { throw new InvalidDataException("The weather profiles file could not be read. It has been left unchanged.", ex); }
    }

    public void Save(WeatherPreferences preferences)
    {
        preferences.Validate();
        AtomicFile.WriteUtf8Text(FilePath, JsonSerializer.Serialize(preferences, Json));
    }
}
