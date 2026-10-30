using System.Globalization;

namespace FootholdConfigManager;

internal static class SplashPictureSequence
{
    internal static int SelectAndAdvance(string statePath)
    {
        var index = 0;
        try
        {
            if (File.Exists(statePath) && int.TryParse(File.ReadAllText(statePath), out var saved) && saved is >= 0 and < 3)
                index = saved;
            AtomicFile.WriteUtf8Text(statePath, ((index + 1) % 3).ToString(CultureInfo.InvariantCulture));
        }
        catch (Exception error) when (error is IOException or UnauthorizedAccessException)
        {
            System.Diagnostics.Trace.WriteLine("Private splash sequence could not be saved: " + error.Message);
        }
        return index;
    }
}
