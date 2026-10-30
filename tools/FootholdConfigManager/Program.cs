namespace FootholdConfigManager;

internal static class Program
{
    [STAThread]
    private static int Main(string[] args)
    {
        if (ManagerSelfUpdater.TryRunHelper(args, out var updateExitCode)) return updateExitCode;
        try
        {
            ExperimentBootstrap.Initialize(args.Any(arg => arg.Equals("--normal-data", StringComparison.OrdinalIgnoreCase)));
        }
        catch (Exception error) when (error is IOException or UnauthorizedAccessException)
        {
            if (args.Length > 0) Console.Error.WriteLine(error.Message);
            else
            {
                ApplicationConfiguration.Initialize();
                MessageBox.Show("The experiment data folder could not be prepared." + Environment.NewLine + error.Message,
                    "Foothold Config Manager", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            return 3;
        }
#if !FOOTHOLD_USER_BUILD
        if (args.Length > 0 && args[0].Equals("--self-test-stability", StringComparison.OrdinalIgnoreCase))
        {
            return StabilityRegressionSelfTest.Run();
        }

        if (args.Length > 0 && args[0].Equals("--self-test-merge", StringComparison.OrdinalIgnoreCase))
        {
            return MainForm.RunMergeRegressionSelfTest();
        }

        if (args.Length > 0 && args[0].Equals("--performance-probe", StringComparison.OrdinalIgnoreCase))
        {
            ApplicationConfiguration.Initialize();
            return MainForm.RunPerformanceProbe(args.Skip(1).ToList());
        }
#endif

        if (args.Length > 0 && args[0].Equals("--check", StringComparison.OrdinalIgnoreCase))
        {
            var settings = RuntimeSettings.Load();
            var path = args.Length > 1
                ? args[1]
                : settings.FindRememberedConfig() ??
                  RuntimeSettings.FindSavedGamesConfigs().FirstOrDefault() ??
                  (ExperimentBootstrap.IsIsolated ? null : ConfigDocument.FindDefaultConfig());
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
                  (ExperimentBootstrap.IsIsolated ? null : ConfigDocument.FindDefaultConfig());
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

        SingleInstanceCoordinator instance;
        try
        {
            instance = SingleInstanceCoordinator.Enter(RuntimeSettings.SettingsDirectory, requestAdminOnLoad);
        }
        catch (Exception error) when (error is ArgumentException or IOException or UnauthorizedAccessException or
            System.ComponentModel.Win32Exception or InvalidOperationException or WaitHandleCannotBeOpenedException or System.Security.SecurityException)
        {
            ApplicationConfiguration.Initialize();
            MessageBox.Show("The manager could not take ownership of this data folder." + Environment.NewLine + error.Message,
                "Foothold Config Manager", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return 3;
        }
        using (instance)
        {
            if (!instance.IsOwner)
            {
                if (instance.SecondaryResult != 0)
                {
                    ApplicationConfiguration.Initialize();
                    MessageBox.Show(instance.FailureReason, "Foothold Config Manager", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
                return instance.SecondaryResult;
            }
            InstallCrashLogging();
            ApplicationConfiguration.Initialize();
            var picture = SplashPictureSequence.SelectAndAdvance(Path.Combine(RuntimeSettings.SettingsDirectory, "splash-next.txt"));
            using var loading = new LoadingScreenController(picture);
            using var startup = new ManagerStartupContext(instance, loading, requestAdminOnLoad);
            Application.Run(startup);
            return 0;
        }
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
                "Version: " + ManagerBuildInfo.VersionText + Environment.NewLine +
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
