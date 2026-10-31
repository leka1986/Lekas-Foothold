using System.Diagnostics;

namespace FootholdConfigManager;

internal static class UserExeExporter
{
    public static string Export(ConfigDocument document, string outputPath, string buildMode)
    {
        if (!ManagerBuildInfo.TryParseReleaseVersion(document.Metadata.FooterVersion, out var releaseVersion))
        {
            throw new InvalidOperationException("Enter a numeric release version (for example 2.1.2 or 2.1.2.1) in the Designer before exporting.");
        }
        var projectDir = FindProjectDirectory() ??
                         throw new InvalidOperationException("Could not find FootholdConfigManager.csproj. Export is available only from the admin/source copy of the tool.");
        var exportDir = Path.Combine(Path.GetTempPath(), "FootholdConfigManagerExport-" + Guid.NewGuid().ToString("N"));
        var buildDir = Path.Combine(exportDir, "source");
        var publishDir = Path.Combine(exportDir, "publish");

        try
        {
            PrepareBuildSource(projectDir, buildDir, document.Metadata.ToJson(), buildMode, releaseVersion);

            Directory.CreateDirectory(publishDir);
            var result = RunDotnetPublish(buildDir, publishDir);
            if (result.ExitCode != 0)
            {
                throw new InvalidOperationException("dotnet publish failed:" + Environment.NewLine + result.Output);
            }

            var builtExe = Path.Combine(publishDir, "FootholdConfigManager.exe");
            if (!File.Exists(builtExe))
            {
                throw new FileNotFoundException("Published EXE was not found.", builtExe);
            }

            Directory.CreateDirectory(Path.GetDirectoryName(outputPath) ?? ".");
            File.Copy(builtExe, outputPath, overwrite: true);
            return outputPath;
        }
        finally
        {
            TryDeleteDirectory(exportDir);
        }
    }

    internal static void PrepareBuildSource(string projectDirectory, string buildDirectory,
        string metadataJson, string buildMode, Version releaseVersion)
    {
        Directory.CreateDirectory(buildDirectory);
        foreach (var sourceFile in Directory.EnumerateFiles(projectDirectory))
        {
            File.Copy(sourceFile, Path.Combine(buildDirectory, Path.GetFileName(sourceFile)));
        }

        var configDirectory = Path.Combine(Path.GetDirectoryName(buildDirectory)!, "test-configs");
        Directory.CreateDirectory(configDirectory);
        foreach (var configFileName in RuntimeSettings.SupportedConfigFileNames)
        {
            File.Copy(Path.Combine(projectDirectory, "..", "test-configs", configFileName),
                Path.Combine(configDirectory, configFileName));
        }

        File.WriteAllText(Path.Combine(buildDirectory, "EmbeddedGuiMetadata.json"), metadataJson);
        File.WriteAllText(Path.Combine(buildDirectory, "EmbeddedBuildMode.txt"), buildMode);
        File.WriteAllText(Path.Combine(buildDirectory, "ManagerVersion.txt"), releaseVersion.ToString(4));
    }

    private static (int ExitCode, string Output) RunDotnetPublish(string projectDir, string publishDir)
    {
        using var process = new Process();
        process.StartInfo.FileName = "dotnet";
        process.StartInfo.WorkingDirectory = projectDir;
        process.StartInfo.UseShellExecute = false;
        process.StartInfo.CreateNoWindow = true;
        process.StartInfo.RedirectStandardOutput = true;
        process.StartInfo.RedirectStandardError = true;
        process.StartInfo.ArgumentList.Add("publish");
        process.StartInfo.ArgumentList.Add("FootholdConfigManager.csproj");
        process.StartInfo.ArgumentList.Add("-c");
        process.StartInfo.ArgumentList.Add("Release");
        process.StartInfo.ArgumentList.Add("-r");
        process.StartInfo.ArgumentList.Add("win-x64");
        process.StartInfo.ArgumentList.Add("-p:PublishSingleFile=true");
        process.StartInfo.ArgumentList.Add("-p:SelfContained=false");
        process.StartInfo.ArgumentList.Add("-p:PublishReadyToRun=false");
        process.StartInfo.ArgumentList.Add("-p:DebugType=None");
        process.StartInfo.ArgumentList.Add("-p:DebugSymbols=false");
        process.StartInfo.ArgumentList.Add("-o");
        process.StartInfo.ArgumentList.Add(publishDir);

        process.Start();
        var standardOutput = process.StandardOutput.ReadToEndAsync();
        var standardError = process.StandardError.ReadToEndAsync();
        process.WaitForExit();
        var output = standardOutput.GetAwaiter().GetResult() + standardError.GetAwaiter().GetResult();
        return (process.ExitCode, output);
    }

    internal static string? FindProjectDirectory()
    {
        var dir = new FileInfo(Environment.ProcessPath!).Directory;
        while (dir is not null)
        {
            var candidate = Path.Combine(dir.FullName, "FootholdConfigManager.csproj");
            if (File.Exists(candidate))
            {
                return dir.FullName;
            }

            dir = dir.Parent;
        }

        return null;
    }

    private static void TryDeleteDirectory(string path)
    {
        try
        {
            if (Directory.Exists(path))
            {
                Directory.Delete(path, recursive: true);
            }
        }
        catch
        {
            // Best-effort cleanup only; export result is already determined.
        }
    }
}
