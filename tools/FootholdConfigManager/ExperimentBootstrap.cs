namespace FootholdConfigManager;

internal static class ExperimentBootstrap
{
    internal static bool IsIsolated => AppContext.GetData("FootholdManager3.Experiment") is true;

    internal static void Initialize(bool useNormalData)
    {
#if FOOTHOLD_USER_BUILD
        useNormalData = true; // Exported releases use the normal per-user store without shortcut arguments.
#endif
        if (!useNormalData) { Initialize(); return; }
        // Explicit desktop opt-in uses RuntimeSettings' existing normal root.
        // A harness-supplied directory still wins, so tests never require real user data.
        AppContext.SetData("FootholdManager3.Experiment", false);
    }

    internal static void Initialize()
    {
        AppContext.SetData("FootholdManager3.Experiment", true);
        // A harness-supplied root must win, before any settings/store/coordinator access.
        if (AppContext.GetData("FootholdManager3.DataDirectory") is string) return;
        var directory = GetDataDirectory(AppContext.BaseDirectory);
        AppContext.SetData("FootholdManager3.DataDirectory", directory);
        Directory.CreateDirectory(directory);
    }

    internal static string GetDataDirectory(string executableDirectory)
    {
        var identity = Path.GetFullPath(executableDirectory).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar).ToUpperInvariant();
        var digest = Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(System.Text.Encoding.UTF8.GetBytes(identity)))[..16];
        return Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "Foothold Manager 2.0 Preview", "S65-" + digest);
    }

    internal static void PrepareOwnerData()
    {
#if !FOOTHOLD_USER_BUILD
        if (!IsIsolated) return;
        if (!File.Exists(RuntimeSettings.SettingsPath))
        {
            var configPath = MainForm.CreatePreviewSampleConfigs();
            var settings = new RuntimeSettings { DarkMode = true };
            settings.RememberConfig(configPath);
        }
#endif
    }
}
