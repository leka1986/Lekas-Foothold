#if !FOOTHOLD_USER_BUILD
using System.Diagnostics;
using System.Text;
using System.Text.Json;

namespace FootholdConfigManager;

internal sealed record SignedReleaseCommandResult(int ExitCode, string Output);

internal interface ISignedReleaseCommandRunner
{
    Task<SignedReleaseCommandResult> RunAsync(string executable, IReadOnlyList<string> arguments, string? input,
        TimeSpan timeout, CancellationToken cancellationToken);
}

internal interface ISignedReleaseVerifier
{
    Task VerifyAsync(string path, Version version, CancellationToken cancellationToken);
}

internal sealed class SignedReleaseCommandRunner : ISignedReleaseCommandRunner
{
    public async Task<SignedReleaseCommandResult> RunAsync(string executable, IReadOnlyList<string> arguments, string? input,
        TimeSpan timeout, CancellationToken cancellationToken)
    {
        using var limit = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        limit.CancelAfter(timeout);
        using var process = new Process
        {
            StartInfo = new ProcessStartInfo(executable)
            {
                UseShellExecute = false, CreateNoWindow = true, WindowStyle = ProcessWindowStyle.Hidden,
                RedirectStandardOutput = true, RedirectStandardError = true, RedirectStandardInput = true,
                StandardOutputEncoding = Encoding.UTF8, StandardErrorEncoding = Encoding.UTF8
            }
        };
        foreach (var argument in arguments) process.StartInfo.ArgumentList.Add(argument);
        // Disable prompts and pagers; authentication stays in the owner's existing gh credential store.
        process.StartInfo.Environment["GH_PROMPT_DISABLED"] = "1";
        process.StartInfo.Environment["GH_PAGER"] = "cat";
        try
        {
            cancellationToken.ThrowIfCancellationRequested();
            if (!process.Start()) throw new IOException("Could not start the release command.");
            var output = ReadBoundedAsync(process.StandardOutput, limit.Token);
            var error = ReadBoundedAsync(process.StandardError, limit.Token);
            if (input is not null) await process.StandardInput.WriteAsync(input.AsMemory(), limit.Token).ConfigureAwait(false);
            process.StandardInput.Close();
            await process.WaitForExitAsync(limit.Token).ConfigureAwait(false);
            var text = await output.ConfigureAwait(false);
            await error.ConfigureAwait(false); // Drain, but never expose authentication or command diagnostics in UI/logs.
            return new(process.ExitCode, text);
        }
        catch (OperationCanceledException) when (!cancellationToken.IsCancellationRequested)
        {
            throw new TimeoutException("The release command timed out. Check connectivity and Resume the saved job if it was submitted.");
        }
        finally
        {
            try { if (process.Id > 0 && !process.HasExited) { process.Kill(entireProcessTree: true); process.WaitForExit(2000); } }
            catch (Exception e) when (e is InvalidOperationException or System.ComponentModel.Win32Exception) { }
        }
    }

    private static async Task<string> ReadBoundedAsync(StreamReader reader, CancellationToken token)
    {
        var output = new StringBuilder();
        var buffer = new char[8192];
        int length;
        while ((length = await reader.ReadAsync(buffer.AsMemory(), token).ConfigureAwait(false)) != 0)
        {
            if (output.Length + length > 32 * 1024 * 1024) throw new InvalidDataException("The release command response exceeded its limit.");
            output.Append(buffer, 0, length);
        }
        return output.ToString();
    }
}

internal sealed class SignedReleaseVerifier(ISignedReleaseCommandRunner runner) : ISignedReleaseVerifier
{
    public async Task VerifyAsync(string path, Version version, CancellationToken cancellationToken)
    {
        var info = FileVersionInfo.GetVersionInfo(path);
        var fileVersion = new Version(info.FileMajorPart, info.FileMinorPart, info.FileBuildPart, info.FilePrivatePart);
        var productVersion = new Version(info.ProductMajorPart, info.ProductMinorPart, info.ProductBuildPart, info.ProductPrivatePart);
        if (fileVersion != version || productVersion != version)
            throw new InvalidDataException("The executable's file/product version does not match the requested release.");
        var directory = Path.Combine(Path.GetTempPath(), "FootholdSignatureCheck-" + Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(directory);
        try
        {
            var script = Path.Combine(directory, "Verify.ps1");
            AtomicFile.WriteUtf8Text(script, """
                param([Parameter(Mandatory=$true)][string]$ExecutablePath)
                $ErrorActionPreference = 'Stop'
                $signature = Get-AuthenticodeSignature -LiteralPath $ExecutablePath
                $subject = ''
                if ($null -ne $signature.SignerCertificate) {
                    $subject = $signature.SignerCertificate.GetNameInfo([System.Security.Cryptography.X509Certificates.X509NameType]::SimpleName, $false)
                }
                @{ status=$signature.Status.ToString(); type=$signature.SignatureType.ToString(); subject=$subject } | ConvertTo-Json -Compress
                """);
            var powershell = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.System), "WindowsPowerShell", "v1.0", "powershell.exe");
            var result = await runner.RunAsync(powershell, ["-NoLogo", "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass",
                "-File", script, "-ExecutablePath", path], null, TimeSpan.FromSeconds(60), cancellationToken).ConfigureAwait(false);
            if (result.ExitCode != 0) throw new InvalidDataException("Windows could not verify the release signature.");
            using var parsed = JsonDocument.Parse(result.Output);
            var signature = parsed.RootElement;
            if (signature.GetProperty("status").GetString() != "Valid" || signature.GetProperty("type").GetString() != "Authenticode"
                || signature.GetProperty("subject").GetString() != "SignPath Foundation")
                throw new InvalidDataException("The release requires a valid, trusted embedded SignPath Foundation Authenticode signature.");
        }
        finally { Directory.Delete(directory, recursive: true); }
    }
}
#endif
