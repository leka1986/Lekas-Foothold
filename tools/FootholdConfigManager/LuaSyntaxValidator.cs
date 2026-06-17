using System.Diagnostics;
using System.Globalization;
using System.Text;

namespace FootholdConfigManager;

internal static class LuaSyntaxValidator
{
    private const int TimeoutMilliseconds = 30000;
    private const long MaxLogBytes = 512 * 1024;

    public static List<string> Validate(string luaText, string displayPath)
    {
        var checker = FindLuaChecker();
        if (checker is null)
        {
            LogDiagnostic(displayPath, "", "", luaText.Length, "SKIPPED", "No Lua syntax checker was found.");
            return new List<string>();
        }

        var tempDir = Path.Combine(Path.GetTempPath(), "FootholdConfigManager");
        var tempPath = Path.Combine(tempDir, "syntax-" + Guid.NewGuid().ToString("N") + ".lua");
        var startedAt = DateTime.Now;
        var stopwatch = Stopwatch.StartNew();
        try
        {
            Directory.CreateDirectory(tempDir);
            File.WriteAllText(tempPath, luaText, new UTF8Encoding(false));
            LogDiagnostic(displayPath, checker.Path, tempPath, luaText.Length, "START", "Lua syntax check started.");

            using var process = new Process();
            process.StartInfo = new ProcessStartInfo
            {
                FileName = checker.Path,
                WorkingDirectory = System.IO.Path.GetDirectoryName(checker.Path) ?? Environment.CurrentDirectory,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true
            };
            if (checker.Kind == LuaCheckerKind.Luac)
            {
                process.StartInfo.ArgumentList.Add("-p");
            }
            else
            {
                process.StartInfo.ArgumentList.Add("-e");
                process.StartInfo.ArgumentList.Add("local chunk, err = loadfile(...); if not chunk then io.stderr:write(err); os.exit(1); end");
            }

            process.StartInfo.ArgumentList.Add(tempPath);

            process.Start();
            if (!process.WaitForExit(TimeoutMilliseconds))
            {
                var processId = TryGetProcessId(process);
                try
                {
                    process.Kill(entireProcessTree: true);
                }
                catch
                {
                    // The process may have exited between WaitForExit and Kill.
                }

                LogDiagnostic(
                    displayPath,
                    checker.Path,
                    tempPath,
                    luaText.Length,
                    "TIMEOUT",
                    "Timed out after " + TimeoutMilliseconds.ToString(CultureInfo.InvariantCulture) +
                    " ms. Process ID: " + processId +
                    ". Started: " + startedAt.ToString("O", CultureInfo.InvariantCulture) +
                    ". Elapsed: " + stopwatch.ElapsedMilliseconds.ToString(CultureInfo.InvariantCulture) + " ms.");
                return new List<string> { "Lua syntax check timed out. Diagnostic log: " + GetLogPath() };
            }

            var output = process.StandardOutput.ReadToEnd();
            var error = process.StandardError.ReadToEnd();
            if (process.ExitCode == 0)
            {
                LogDiagnostic(
                    displayPath,
                    checker.Path,
                    tempPath,
                    luaText.Length,
                    "OK",
                    "Elapsed: " + stopwatch.ElapsedMilliseconds.ToString(CultureInfo.InvariantCulture) + " ms.");
                return new List<string>();
            }

            var message = FormatLuaError(output, error, tempPath, displayPath);
            LogDiagnostic(
                displayPath,
                checker.Path,
                tempPath,
                luaText.Length,
                "FAILED",
                "Exit code: " + process.ExitCode.ToString(CultureInfo.InvariantCulture) +
                ". Elapsed: " + stopwatch.ElapsedMilliseconds.ToString(CultureInfo.InvariantCulture) + " ms." +
                Environment.NewLine +
                "Output: " + Truncate(output) +
                Environment.NewLine +
                "Error: " + Truncate(error));
            return new List<string> { "Lua syntax: " + message };
        }
        catch (Exception ex)
        {
            LogDiagnostic(displayPath, checker.Path, tempPath, luaText.Length, "ERROR", ex.ToString());
            return new List<string> { "Lua syntax check failed to run: " + ex.Message };
        }
        finally
        {
            try
            {
                if (File.Exists(tempPath))
                {
                    File.Delete(tempPath);
                }
            }
            catch
            {
                // Temporary cleanup failure should not affect validation.
            }
        }
    }

    private static string TryGetProcessId(Process process)
    {
        try
        {
            return process.Id.ToString(CultureInfo.InvariantCulture);
        }
        catch
        {
            return "unknown";
        }
    }

    private static void LogDiagnostic(string displayPath, string luaExe, string tempPath, int textLength, string status, string details)
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
                "Time: " + DateTime.Now.ToString("O", CultureInfo.InvariantCulture) + Environment.NewLine +
                "Status: " + status + Environment.NewLine +
                "Config: " + displayPath + Environment.NewLine +
                "Lua: " + luaExe + Environment.NewLine +
                "Temp: " + tempPath + Environment.NewLine +
                "Bytes: " + textLength.ToString(CultureInfo.InvariantCulture) + Environment.NewLine +
                "Executable: " + (Environment.ProcessPath ?? AppContext.BaseDirectory) + Environment.NewLine +
                "Working directory: " + Environment.CurrentDirectory + Environment.NewLine +
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

    private static string Truncate(string text)
    {
        text = text.Trim();
        return text.Length <= 2000 ? text : text[..2000] + "...";
    }

    private static LuaChecker? FindLuaChecker()
    {
        var configuredLuac = Environment.GetEnvironmentVariable("FOOTHOLD_CONFIG_MANAGER_LUAC");
        if (!string.IsNullOrWhiteSpace(configuredLuac) && File.Exists(configuredLuac))
        {
            return new LuaChecker(configuredLuac, LuaCheckerKind.Luac);
        }

        var configured = Environment.GetEnvironmentVariable("FOOTHOLD_CONFIG_MANAGER_LUA");
        if (!string.IsNullOrWhiteSpace(configured) && File.Exists(configured))
        {
            return new LuaChecker(configured, LuaCheckerKind.Lua);
        }

        foreach (var candidate in GetLuaCheckerCandidates())
        {
            if (File.Exists(candidate))
            {
                return new LuaChecker(
                    candidate,
                    System.IO.Path.GetFileName(candidate).Equals("luac.exe", StringComparison.OrdinalIgnoreCase)
                        ? LuaCheckerKind.Luac
                        : LuaCheckerKind.Lua);
            }
        }

        return null;
    }

    private static IEnumerable<string> GetLuaCheckerCandidates()
    {
        var programFilesX86 = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86);
        if (!string.IsNullOrWhiteSpace(programFilesX86))
        {
            yield return System.IO.Path.Combine(programFilesX86, "Lua", "5.1", "luac.exe");
            yield return Path.Combine(programFilesX86, "Lua", "5.1", "lua.exe");
        }

        var programFiles = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles);
        if (!string.IsNullOrWhiteSpace(programFiles))
        {
            yield return System.IO.Path.Combine(programFiles, "Lua", "5.1", "luac.exe");
            yield return Path.Combine(programFiles, "Lua", "5.1", "lua.exe");
        }

        var path = Environment.GetEnvironmentVariable("PATH") ?? "";
        foreach (var directory in path.Split(Path.PathSeparator))
        {
            if (string.IsNullOrWhiteSpace(directory))
            {
                continue;
            }

            yield return Path.Combine(directory.Trim(), "luac.exe");
            yield return Path.Combine(directory.Trim(), "lua.exe");
        }
    }

    private sealed record LuaChecker(string Path, LuaCheckerKind Kind);

    private enum LuaCheckerKind
    {
        Lua,
        Luac
    }

    private static string FormatLuaError(string output, string error, string tempPath, string displayPath)
    {
        var text = string.Join(
                Environment.NewLine,
                new[] { error, output }.Where(item => !string.IsNullOrWhiteSpace(item)))
            .Trim();
        if (string.IsNullOrWhiteSpace(text))
        {
            return "Lua exited with an error.";
        }

        var lines = text.Split(new[] { "\r\n", "\n", "\r" }, StringSplitOptions.RemoveEmptyEntries)
            .Select(line => line.Trim())
            .Where(line => line.Length > 0 && !line.StartsWith("stack traceback:", StringComparison.OrdinalIgnoreCase))
            .Where(line => !line.StartsWith("[C]:", StringComparison.Ordinal))
            .ToList();
        var message = lines.FirstOrDefault() ?? text;
        var display = string.IsNullOrWhiteSpace(displayPath) ? "Foothold Config.lua" : displayPath;
        var tempFileName = Path.GetFileName(tempPath);
        var tempFileIndex = message.IndexOf(tempFileName, StringComparison.OrdinalIgnoreCase);
        if (tempFileIndex >= 0)
        {
            return display + message[(tempFileIndex + tempFileName.Length)..];
        }

        message = message.Replace(tempPath, display, StringComparison.OrdinalIgnoreCase);
        return message;
    }
}
