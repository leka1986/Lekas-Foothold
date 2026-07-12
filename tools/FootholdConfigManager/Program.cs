namespace FootholdConfigManager;

internal static class Program
{
    [STAThread]
    private static int Main(string[] args)
    {
        if (args.Length > 0 && args[0].Equals("--self-test-merge", StringComparison.OrdinalIgnoreCase))
        {
            return MainForm.RunMergeRegressionSelfTest();
        }

        if (args.Length > 0 && args[0].Equals("--check", StringComparison.OrdinalIgnoreCase))
        {
            var settings = RuntimeSettings.Load();
            var path = args.Length > 1
                ? args[1]
                : settings.FindRememberedConfig() ??
                  RuntimeSettings.FindSavedGamesConfigs().FirstOrDefault() ??
                  ConfigDocument.FindDefaultConfig();
            if (path is null)
            {
                return 2;
            }

            var document = ConfigDocument.Load(path);
            return document.Validate().Count == 0 ? 0 : 1;
        }

        if (args.Length > 0 && args[0].Equals("--audit", StringComparison.OrdinalIgnoreCase))
        {
            var settings = RuntimeSettings.Load();
            var path = args.Length > 1
                ? args[1]
                : settings.FindRememberedConfig() ??
                  RuntimeSettings.FindSavedGamesConfigs().FirstOrDefault() ??
                  ConfigDocument.FindDefaultConfig();
            if (path is null)
            {
                return 2;
            }

            var logPath = args.Length > 2
                ? args[2]
                : System.IO.Path.Combine(AppContext.BaseDirectory, "FootholdConfigManager.audit.log");
            var document = ConfigDocument.Load(path);
            var lines = document.BuildAuditLines(out var ok);
            Directory.CreateDirectory(System.IO.Path.GetDirectoryName(logPath) ?? ".");
            File.WriteAllLines(logPath, lines);
            Console.WriteLine(logPath);
            return ok ? 0 : 1;
        }

        var requestAdminOnLoad = args.Any(arg => arg.Equals("--admin", StringComparison.OrdinalIgnoreCase));

        InstallCrashLogging();
        ApplicationConfiguration.Initialize();
        Application.Run(new MainForm(requestAdminOnLoad));
        return 0;
    }

    private static void InstallCrashLogging()
    {
        Application.SetUnhandledExceptionMode(UnhandledExceptionMode.CatchException);
        Application.ThreadException += (_, args) =>
        {
            var logPath = WriteCrashLog("ui-thread", args.Exception);
            MessageBox.Show(
                "Foothold Config Manager crashed. A crash log was written to:" + Environment.NewLine + logPath,
                "Foothold Config Manager",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error);
        };
        AppDomain.CurrentDomain.UnhandledException += (_, args) =>
        {
            if (args.ExceptionObject is Exception ex)
            {
                WriteCrashLog("unhandled", ex);
            }
        };
        TaskScheduler.UnobservedTaskException += (_, args) =>
        {
            WriteCrashLog("task", args.Exception);
            args.SetObserved();
        };
    }

    private static string WriteCrashLog(string source, Exception exception)
    {
        try
        {
            var directory = Path.Combine(RuntimeSettings.SettingsDirectory, "logs");
            Directory.CreateDirectory(directory);
            PruneCrashLogs(directory);
            var path = Path.Combine(directory, "crash-" + DateTime.Now.ToString("yyyyMMdd-HHmmss-fff") + ".log");
            File.WriteAllText(path,
                "Foothold Config Manager crash" + Environment.NewLine +
                "Time: " + DateTime.Now.ToString("O") + Environment.NewLine +
                "Source: " + source + Environment.NewLine +
                "Executable: " + (Environment.ProcessPath ?? AppContext.BaseDirectory) + Environment.NewLine +
                "Version: " + typeof(Program).Assembly.GetName().Version + Environment.NewLine +
                Environment.NewLine +
                exception);
            return path;
        }
        catch
        {
            return Path.Combine(RuntimeSettings.SettingsDirectory, "logs");
        }
    }

    private static void PruneCrashLogs(string directory)
    {
        foreach (var file in Directory.GetFiles(directory, "crash-*.log")
                     .OrderByDescending(File.GetLastWriteTimeUtc)
                     .Skip(20))
        {
            File.Delete(file);
        }
    }
}
