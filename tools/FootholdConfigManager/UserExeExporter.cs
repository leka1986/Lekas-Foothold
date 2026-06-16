using System.Diagnostics;

namespace FootholdConfigManager;

internal static class UserExeExporter
{
    public static string Export(ConfigDocument document, string outputPath, string buildMode)
    {
        var projectDir = FindProjectDirectory() ??
                         throw new InvalidOperationException("Could not find FootholdConfigManager.csproj. Export is available only from the admin/source copy of the tool.");
        var metadataPath = Path.Combine(projectDir, "EmbeddedGuiMetadata.json");
        var buildModePath = Path.Combine(projectDir, "EmbeddedBuildMode.txt");
        var publishDir = Path.Combine(projectDir, "bin", "UserExport-" + DateTime.Now.ToString("yyyyMMdd-HHmmss"));

        try
        {
            File.WriteAllText(metadataPath, document.Metadata.ToJson());
            File.WriteAllText(buildModePath, buildMode);

            Directory.CreateDirectory(publishDir);
            var result = RunDotnetPublish(projectDir, publishDir);
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
            TryDeleteFile(metadataPath);
            TryDeleteFile(buildModePath);
            TryDeleteDirectory(publishDir);
        }
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
        var output = process.StandardOutput.ReadToEnd() + process.StandardError.ReadToEnd();
        process.WaitForExit();
        return (process.ExitCode, output);
    }

    private static string? FindProjectDirectory()
    {
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
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

    private static void TryDeleteFile(string path)
    {
        try
        {
            if (File.Exists(path))
            {
                File.Delete(path);
            }
        }
        catch
        {
            // Best-effort cleanup only; export result is already determined.
        }
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
