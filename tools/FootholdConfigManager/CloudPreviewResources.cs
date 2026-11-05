namespace FootholdConfigManager;

internal static class CloudPreviewResources
{
    private const string Prefix = "FootholdConfigManager.CloudPreviews.";
    private static readonly HashSet<string> Names = LoadManifest();

    internal static Stream? TryOpen(string resourceName) => Names.TryGetValue(resourceName, out var name)
        ? typeof(CloudPreviewResources).Assembly.GetManifestResourceStream(Prefix + name) : null;

    private static HashSet<string> LoadManifest()
    {
        using var stream = typeof(CloudPreviewResources).Assembly.GetManifestResourceStream(Prefix + "Manifest")
            ?? throw new InvalidDataException("The bundled cloud preview manifest is missing.");
        using var reader = new StreamReader(stream);
        return reader.ReadToEnd().Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries)
            .ToHashSet(StringComparer.OrdinalIgnoreCase);
    }
}