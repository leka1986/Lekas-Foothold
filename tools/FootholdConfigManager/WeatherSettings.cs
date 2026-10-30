namespace FootholdConfigManager;

internal sealed class WeatherWind
{
    public double SpeedMps { get; set; }
    public double DirectionTo { get; set; }
}

internal sealed class WeatherFogFrame
{
    public double TimeSeconds { get; set; }
    public double VisibilityMeters { get; set; } = 1500;
    public double ThicknessMeters { get; set; } = 200;
}

internal sealed class WeatherPressureSystem
{
    public double CenterX { get; set; }
    public double CenterZ { get; set; }
    public double PressureExcessPa { get; set; } = -1150;
    public double PressureSpreadMeters { get; set; } = 900000;
    public double Ellipticity { get; set; } = 1;
    public double RotationRadians { get; set; }
}

internal sealed class WeatherSettings
{
    public string CloudMode { get; set; } = "preset";
    public string? CloudPreset { get; set; } = "Preset8";
    public double CloudBaseMeters { get; set; } = 5460;
    public double CloudBaseMinimumMeters { get; set; }
    public double CloudBaseMaximumMeters { get; set; } = 30000;
    public double CloudThicknessMeters { get; set; } = 610;
    public int CloudDensity { get; set; } = 5;
    public int Precipitation { get; set; }
    public WeatherWind GroundWind { get; set; } = new() { SpeedMps = 2 * KnotsToMps, DirectionTo = 138 };
    public WeatherWind Wind2000 { get; set; } = new() { SpeedMps = 8 * KnotsToMps, DirectionTo = 286 };
    public WeatherWind Wind8000 { get; set; } = new() { SpeedMps = 9 * KnotsToMps, DirectionTo = 18 };
    public double TemperatureC { get; set; } = 15;
    public double PressureMmHg { get; set; } = 762;
    public double VisibilityMeters { get; set; } = 80000;
    public double TurbulenceMps { get; set; }
    public string FogMode { get; set; } = "off";
    public List<WeatherFogFrame> FogFrames { get; set; } = new() { new() };
    public bool DustEnabled { get; set; }
    public double DustVisibilityMeters { get; set; } = 300;
    public string HaloMode { get; set; } = "auto";
    public string? HaloCrystalPreset { get; set; }
    public bool DynamicWeather { get; set; }
    public int DynamicType { get; set; }
    public List<WeatherPressureSystem> PressureSystems { get; set; } = new() { new() };
    public bool ChangeDateTime { get; set; }
    public bool ChangeMissionDate { get; set; } = true;
    public DateTime MissionDate { get; set; } = DateTime.Today;
    public double StartTimeSeconds { get; set; } = 8 * 3600 + 45 * 60;

    public const double KnotsToMps = 1852d / 3600;
    public const double FeetToMeters = .3048;
    public const double InHgToMmHg = 25.4;
    public const double HPaToMmHg = .750061683;

    public void Validate()
    {
        if (GroundWind is null || Wind2000 is null || Wind8000 is null || FogFrames is null || PressureSystems is null
            || FogFrames.Any(frame => frame is null) || PressureSystems.Any(system => system is null))
            throw new InvalidDataException("Weather settings contain an incomplete wind layer, fog schedule or pressure system.");
        if (CloudMode is not ("preset" or "clear" or "custom")) throw new InvalidDataException("Choose a valid cloud mode.");
        if (FogMode is not ("off" or "auto" or "manual")) throw new InvalidDataException("Choose a valid fog mode.");
        if (!DynamicWeather)
        {
            InRange(CloudBaseMeters, 0, 30000, "Cloud base");
            if (CloudMode == "preset")
            {
                if (string.IsNullOrWhiteSpace(CloudPreset)) throw new InvalidDataException("Choose a cloud preset.");
                InRange(CloudBaseMeters, CloudBaseMinimumMeters, CloudBaseMaximumMeters, "Cloud base for this preset");
            }
            if (CloudMode == "custom")
            {
                InRange(CloudThicknessMeters, 200, 2000, "Cloud thickness");
                InRange(CloudDensity, 0, 10, "Cloud density");
                InRange(Precipitation, 0, 4, "Precipitation");
            }
            foreach (var wind in new[] { GroundWind, Wind2000, Wind8000 })
            {
                if (wind is null) throw new InvalidDataException("All three wind layers are required.");
                InRange(wind.SpeedMps, 0, 100, "Wind speed");
                InRange(wind.DirectionTo, 0, 359.999999, "Wind direction");
            }
        }
        InRange(TemperatureC, -80, 60, "Temperature");
        InRange(PressureMmHg, 500, 850, "Pressure");
        InRange(VisibilityMeters, 1, 100000, "Visibility");
        InRange(TurbulenceMps, 0, 100, "Turbulence");
        if (DustEnabled) InRange(DustVisibilityMeters, 300, 3000, "Dust visibility");
        if (FogMode == "manual")
        {
            if (FogFrames.Count == 0) throw new InvalidDataException("Add at least one manual fog time.");
            var previous = -1d;
            foreach (var frame in FogFrames)
            {
                InRange(frame.TimeSeconds, 0, 172800, "Fog time");
                if (frame.TimeSeconds <= previous) throw new InvalidDataException("Manual fog times must be in increasing order.");
                previous = frame.TimeSeconds;
                InRange(frame.VisibilityMeters, 0, 100000, "Fog visibility");
                InRange(frame.ThicknessMeters, 0, 5000, "Fog thickness");
            }
        }
        if (string.IsNullOrWhiteSpace(HaloMode)) throw new InvalidDataException("Choose an ice halo mode.");
        if (HaloMode is not ("off" or "auto") && string.IsNullOrWhiteSpace(HaloCrystalPreset))
            throw new InvalidDataException("Choose an ice crystal preset.");
        if (DynamicWeather)
        {
            InRange(DynamicType, 0, 2, "Dynamic weather type");
            if (DynamicType != 2 && PressureSystems.Count == 0) throw new InvalidDataException("Add a pressure system.");
            foreach (var system in PressureSystems)
            {
                InRange(system.CenterX, -100000000, 100000000, "Pressure center X");
                InRange(system.CenterZ, -100000000, 100000000, "Pressure center Z");
                InRange(system.PressureExcessPa, -100000, 100000, "Pressure excess");
                InRange(system.PressureSpreadMeters, 1, 10000000, "Pressure spread");
                InRange(system.Ellipticity, .01, 100, "Ellipticity");
                InRange(system.RotationRadians, -100, 100, "Pressure system rotation");
            }
        }
        if (ChangeDateTime) InRange(StartTimeSeconds, 0, 86399, "Mission start time");
    }

    private static void InRange(double value, double minimum, double maximum, string label)
    {
        if (!double.IsFinite(value) || value < minimum || value > maximum)
            throw new InvalidDataException(label + " must be between " + minimum + " and " + maximum + ".");
    }

    public void ApplyTo(LuaDataTable weather)
    {
        Validate();
        weather.Set("atmosphere_type", DynamicWeather ? 1d : 0d);
        weather.Set("type_weather", DynamicWeather ? (double)DynamicType : 0d);
        if (DynamicWeather)
        {
            var previousSystems = weather.Get("cyclones") as LuaDataTable;
            var systems = new LuaDataTable();
            if (previousSystems is not null)
                foreach (var pair in previousSystems.Entries.Where(pair => pair.Key is not double)) systems.Set(pair.Key, pair.Value);
            if (DynamicType != 2)
                for (var i = 0; i < PressureSystems.Count; i++)
                {
                    var system = PressureSystems[i];
                    var data = previousSystems?.Get((double)i + 1) as LuaDataTable ?? new LuaDataTable();
                    data.Set("centerX", system.CenterX);
                    data.Set("centerZ", system.CenterZ);
                    data.Set("pressure_excess", system.PressureExcessPa);
                    data.Set("pressure_spread", system.PressureSpreadMeters);
                    data.Set("ellipticity", system.Ellipticity);
                    data.Set("rotation", system.RotationRadians);
                    systems.Set((double)i + 1, data);
                }
            weather.Set("cyclones", systems);
        }
        else
        {
            var clouds = weather.Table("clouds");
            clouds.Set("base", CloudBaseMeters);
            if (CloudMode == "preset") clouds.Set("preset", CloudPreset);
            else clouds.Remove("preset");
            clouds.Set("thickness", CloudMode == "custom" ? CloudThicknessMeters : 200d);
            clouds.Set("density", CloudMode == "custom" ? (double)CloudDensity : 0d);
            clouds.Set("iprecptns", CloudMode == "custom" ? (double)Precipitation : 0d);
            var wind = weather.Table("wind");
            SetWind(wind.Table("atGround"), GroundWind);
            SetWind(wind.Table("at2000"), Wind2000);
            SetWind(wind.Table("at8000"), Wind8000);
        }
        weather.Table("season").Set("temperature", TemperatureC);
        weather.Set("qnh", PressureMmHg);
        weather.Table("visibility").Set("distance", VisibilityMeters);
        weather.Set("groundTurbulence", TurbulenceMps * 10);
        weather.Set("enable_fog", false);
        var fog = weather.Table("fog2");
        fog.Set("mode", FogMode == "off" ? 1d : FogMode == "auto" ? 2d : 4d);
        if (FogMode == "manual")
        {
            var previousFrames = fog.Get("manual") as LuaDataTable;
            var frames = new LuaDataTable();
            if (previousFrames is not null)
                foreach (var pair in previousFrames.Entries.Where(pair => pair.Key is not double)) frames.Set(pair.Key, pair.Value);
            for (var i = 0; i < FogFrames.Count; i++)
            {
                var frame = FogFrames[i];
                var entry = previousFrames?.Get((double)i + 1) as LuaDataTable ?? new LuaDataTable();
                entry.Set("time", frame.TimeSeconds);
                entry.Set("visibility", frame.VisibilityMeters);
                entry.Set("thickness", frame.ThicknessMeters);
                frames.Set((double)i + 1, entry);
            }
            fog.Set("manual", frames);
        }
        else fog.Remove("manual");
        weather.Set("enable_dust", DustEnabled);
        weather.Set("dust_density", DustEnabled ? DustVisibilityMeters : 0d);
        var halo = weather.Table("halo");
        halo.Set("preset", HaloMode);
        if (HaloMode is "off" or "auto") halo.Remove("crystalsPreset");
        else halo.Set("crystalsPreset", HaloCrystalPreset);
    }

    private static void SetWind(LuaDataTable table, WeatherWind wind)
    {
        table.Set("speed", wind.SpeedMps);
        table.Set("dir", wind.DirectionTo);
    }
}
