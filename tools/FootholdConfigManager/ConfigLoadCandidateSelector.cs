namespace FootholdConfigManager;

internal sealed record ConfigLoadFailure(string Path, string Error);

internal sealed record ConfigLoadSelection(
    string? Path,
    ConfigDocument? Document,
    IReadOnlyList<ConfigLoadFailure> Failures);

internal static class ConfigLoadCandidateSelector
{
    public static ConfigLoadSelection Select(IEnumerable<string> candidatePaths)
    {
        var failures = new List<ConfigLoadFailure>();
        var seenPaths = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var candidatePath in candidatePaths.Where(path => !string.IsNullOrWhiteSpace(path)))
        {
            string fullPath;
            try
            {
                fullPath = Path.GetFullPath(candidatePath);
            }
            catch (Exception ex)
            {
                failures.Add(new ConfigLoadFailure(candidatePath, ex.Message));
                continue;
            }

            if (!seenPaths.Add(fullPath))
            {
                continue;
            }

            try
            {
                return new ConfigLoadSelection(fullPath, ConfigDocument.Load(fullPath), failures);
            }
            catch (Exception ex)
            {
                failures.Add(new ConfigLoadFailure(fullPath, ex.Message));
            }
        }

        return new ConfigLoadSelection(null, null, failures);
    }
}
