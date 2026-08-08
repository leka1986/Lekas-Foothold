using System.Text;

namespace FootholdConfigManager;

internal static class AtomicFile
{
    public static void WriteUtf8Text(string destinationPath, string contents)
    {
        WriteStaged(
            destinationPath,
            temporaryPath => File.WriteAllText(temporaryPath, contents, new UTF8Encoding(false)));
    }

    public static void Copy(string sourcePath, string destinationPath)
    {
        WriteStaged(
            destinationPath,
            temporaryPath => File.Copy(sourcePath, temporaryPath, overwrite: false));
    }

    public static void WriteStaged(string destinationPath, Action<string> writeTemporaryFile)
    {
        var fullDestinationPath = Path.GetFullPath(destinationPath);
        var destinationDirectory = Path.GetDirectoryName(fullDestinationPath)
                                   ?? throw new InvalidOperationException("The destination directory could not be resolved.");
        Directory.CreateDirectory(destinationDirectory);
        var temporaryPath = fullDestinationPath + ".tmp-" + Guid.NewGuid().ToString("N");
        try
        {
            writeTemporaryFile(temporaryPath);
            if (!File.Exists(temporaryPath))
            {
                throw new InvalidOperationException("The staged file was not written.");
            }

            Commit(temporaryPath, fullDestinationPath);
        }
        finally
        {
            if (File.Exists(temporaryPath))
            {
                File.Delete(temporaryPath);
            }
        }
    }

    private static void Commit(string temporaryPath, string destinationPath)
    {
        if (!File.Exists(destinationPath))
        {
            File.Move(temporaryPath, destinationPath);
            return;
        }

        try
        {
            File.Replace(temporaryPath, destinationPath, destinationBackupFileName: null, ignoreMetadataErrors: true);
        }
        catch (PlatformNotSupportedException)
        {
            File.Move(temporaryPath, destinationPath, overwrite: true);
        }
    }
}
