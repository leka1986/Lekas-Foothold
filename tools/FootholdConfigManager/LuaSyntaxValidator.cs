using Loretta.CodeAnalysis;
using Loretta.CodeAnalysis.Lua;
using System.Diagnostics;
using System.Globalization;
using System.Text;

namespace FootholdConfigManager;

internal static class LuaSyntaxValidator
{
    private const int MaxDiagnostics = 50;
    private const long MaxLogBytes = 512 * 1024;
    private static readonly LuaParseOptions ParseOptions = new(LuaSyntaxOptions.Lua51);

    public static List<string> Validate(string luaText, string displayPath)
    {
        return ValidateCore(luaText, displayPath, ParseErrors);
    }

    internal static List<string> ValidateCore(
        string luaText,
        string displayPath,
        Func<string, string, IEnumerable<string>> parser)
    {
        var path = string.IsNullOrWhiteSpace(displayPath)
            ? "Foothold Config.lua"
            : displayPath;
        var stopwatch = Stopwatch.StartNew();
        try
        {
            var errors = parser(luaText, path).Take(MaxDiagnostics).ToList();
            LogDiagnostic(path, luaText.Length, errors.Count == 0 ? "OK" : "FAILED",
                "Backend: Loretta Lua 5.1. Elapsed: " +
                stopwatch.ElapsedMilliseconds.ToString(CultureInfo.InvariantCulture) +
                " ms. Errors: " + errors.Count.ToString(CultureInfo.InvariantCulture) + ".");
            return errors;
        }
        catch (Exception ex)
        {
            LogDiagnostic(path, luaText.Length, "ERROR",
                "Backend: Loretta Lua 5.1. Exception type: " +
                (ex.GetType().FullName ?? ex.GetType().Name) + Environment.NewLine +
                (ex.StackTrace ?? "No stack trace."));
            return new List<string>
            {
                "Lua syntax validation failed internally (" + ex.GetType().Name + ")."
            };
        }
    }

    private static IEnumerable<string> ParseErrors(string luaText, string displayPath)
    {
        var syntaxTree = LuaSyntaxTree.ParseText(luaText, ParseOptions, displayPath);
        foreach (var diagnostic in syntaxTree.GetDiagnostics())
        {
            if (diagnostic.Severity != DiagnosticSeverity.Error)
            {
                continue;
            }

            var start = diagnostic.Location.GetLineSpan().StartLinePosition;
            yield return "Lua syntax: " + displayPath +
                "(" + (start.Line + 1).ToString(CultureInfo.InvariantCulture) +
                "," + (start.Character + 1).ToString(CultureInfo.InvariantCulture) +
                "): " + diagnostic.GetMessage();
        }
    }

    private static void LogDiagnostic(string displayPath, int textLength, string status, string details)
    {
        var forceLog = (Environment.GetEnvironmentVariable("FOOTHOLD_CONFIG_MANAGER_LUA_LOG") ?? "")
            .Equals("1", StringComparison.Ordinal);
        if (AppMode.IsExportedUserBuild && !forceLog)
        {
            return;
        }

        try
        {
            var directory = Path.Combine(RuntimeSettings.SettingsDirectory, "logs");
            Directory.CreateDirectory(directory);
            var path = GetLogPath();
            TrimLog(path);
            File.AppendAllText(
                path,
                "Status: " + status + Environment.NewLine +
                "Config: " + displayPath + Environment.NewLine +
                "Bytes: " + textLength.ToString(CultureInfo.InvariantCulture) + Environment.NewLine +
                details + Environment.NewLine +
                Environment.NewLine,
                new UTF8Encoding(false));
        }
        catch
        {
            // Diagnostics must never break validation.
        }
    }

    private static string GetLogPath()
    {
        return Path.Combine(RuntimeSettings.SettingsDirectory, "logs", "lua-syntax.log");
    }

    private static void TrimLog(string path)
    {
        if (!File.Exists(path))
        {
            return;
        }

        var file = new FileInfo(path);
        if (file.Length <= MaxLogBytes)
        {
            return;
        }

        var archivedPath = Path.Combine(file.DirectoryName ?? ".", "lua-syntax.previous.log");
        File.Copy(path, archivedPath, overwrite: true);
        File.WriteAllText(path, "", new UTF8Encoding(false));
    }
}
