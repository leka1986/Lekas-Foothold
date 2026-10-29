namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private static string CreatePreviewSampleConfigs()
    {
        var directory = Path.Combine(RuntimeSettings.SettingsDirectory, "PreviewConfigs");
        foreach (var name in RuntimeSettings.SupportedConfigFileNames)
        {
            var path = Path.Combine(directory, name);
            if (File.Exists(path)) continue; // Preserve edits to the preview's own copies.
            using var resource = typeof(MainForm).Assembly.GetManifestResourceStream("FootholdConfigManager.Preview." + name)
                ?? throw new InvalidOperationException("The preview sample is missing: " + name);
            AtomicFile.WriteStaged(path, temporaryPath =>
            {
                using var destination = new FileStream(temporaryPath, FileMode.CreateNew, FileAccess.Write);
                resource.CopyTo(destination);
            });
        }
        return Path.Combine(directory, RuntimeSettings.DefaultConfigFileName);
    }
}
