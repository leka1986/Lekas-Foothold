using System.Diagnostics;
using System.Text.Json;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;

namespace FootholdConfigManager;

internal static partial class ManagerSelfUpdater
{
    internal static string GetInstallPath(string currentPath, ManagerSelfUpdateCandidate candidate)
    {
        ValidateCandidate(candidate);
        return Path.Combine(Path.GetDirectoryName(Path.GetFullPath(currentPath))!, candidate.Name);
    }

    // Called only after the owning Manager process has exited. The new EXE has not been started.
    internal static InstalledManagerUpdate FinalizeInstalledUpdate(string stage, ManagerUpdateManifest manifest)
    {
        var name = manifest.DownloadFileName ?? throw new InvalidDataException("The downloaded Manager filename is missing.");
        var candidate = new ManagerSelfUpdateCandidate(name, name.Length > 28 ? name[24..^4] : "", manifest.GitBlobSha, manifest.DownloadSize);
        var installed = GetInstallPath(manifest.TargetPath, candidate);
        if (!SamePath(installed, manifest.TargetPath) && File.Exists(installed))
            throw new IOException("A file already exists at " + installed + ". No existing file was overwritten.");
        if (FileSha256(manifest.TargetPath) != manifest.DownloadSha256)
            throw new InvalidDataException("The installed Manager changed before naming completion.");
        var transaction = new InstalledManagerUpdate(manifest.TargetPath, installed, manifest.DownloadSha256);
        try
        {
            transaction.Shortcuts.AddRange(FindUpdateShortcuts(manifest.TargetPath, installed));
            for (var index = 0; index < transaction.Shortcuts.Count; index++)
                AtomicFile.WriteStaged(Path.Combine(stage, "shortcut-" + index + ".lnk"), temporary => File.WriteAllBytes(temporary, transaction.Shortcuts[index].Bytes));
            AtomicFile.WriteUtf8Text(Path.Combine(stage, "shortcut-recovery.json"), JsonSerializer.Serialize(transaction.Shortcuts.Select((edit, index) =>
                new { edit.OriginalPath, edit.NewPath, Backup = "shortcut-" + index + ".lnk" })));
            if (!SamePath(installed, manifest.TargetPath))
            {
                File.Move(manifest.TargetPath, installed, overwrite: false);
                transaction.Moved = true;
            }
            object shell = Activator.CreateInstance(Type.GetTypeFromProgID("WScript.Shell")!)!;
            try
            {
                foreach (var edit in transaction.Shortcuts)
                {
                    object? link = null;
                    try
                    {
                        dynamic dynamicShell = shell; link = dynamicShell.CreateShortcut(edit.OriginalPath);
                        dynamic shortcut = link;
                        edit.Changed = true;
                        shortcut.TargetPath = installed;
                        var icon = (string)shortcut.IconLocation;
                        var comma = icon.LastIndexOf(',');
                        var iconPath = (comma < 0 ? icon : icon[..comma]).Trim('"');
                        if (iconPath.Length > 0 && SamePath(iconPath, manifest.TargetPath))
                            shortcut.IconLocation = installed + (comma < 0 ? "" : icon[comma..]);
                        shortcut.Save();
                    }
                    finally { if (link is not null) Marshal.FinalReleaseComObject(link); }
                    if (!SamePath(edit.OriginalPath, edit.NewPath))
                    {
                        File.Move(edit.OriginalPath, edit.NewPath, overwrite: false);
                        edit.Moved = true;
                    }
                }
            }
            finally { Marshal.FinalReleaseComObject(shell); }
            return transaction;
        }
        catch { transaction.Rollback(); throw; }
    }

    private static IEnumerable<UpdateShortcutEdit> FindUpdateShortcuts(string original, string installed)
    {
        var folders = new[] { Path.GetDirectoryName(original)!, Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory) }
            .Where(Directory.Exists).Distinct(StringComparer.OrdinalIgnoreCase);
        object shell = Activator.CreateInstance(Type.GetTypeFromProgID("WScript.Shell")!)!;
        try
        {
            foreach (var folder in folders)
            foreach (var path in Directory.EnumerateFiles(folder, "*.lnk", SearchOption.TopDirectoryOnly))
            {
                if ((File.GetAttributes(path) & FileAttributes.ReparsePoint) != 0) continue;
                object? link = null;
                string target;
                try { dynamic dynamicShell = shell; link = dynamicShell.CreateShortcut(path); dynamic shortcut = link; target = (string)shortcut.TargetPath; }
                finally { if (link is not null) Marshal.FinalReleaseComObject(link); }
                if (string.IsNullOrEmpty(target) || !SamePath(target, original)) continue;
                var label = Path.GetFileNameWithoutExtension(path);
                var newPath = Regex.IsMatch(label, @"\AFoothold Config Manager [0-9]+\.[0-9]+\.[0-9]+(?:\.[0-9]+)?\z", RegexOptions.CultureInvariant)
                    ? Path.Combine(folder, Path.GetFileNameWithoutExtension(installed) + ".lnk") : path;
                if (!SamePath(newPath, path) && File.Exists(newPath)) throw new IOException("A shortcut already exists at " + newPath);
                yield return new(path, newPath, File.ReadAllBytes(path));
            }
        }
        finally { Marshal.FinalReleaseComObject(shell); }
    }

    internal sealed class InstalledManagerUpdate(string originalPath, string installedPath, string sha256)
    {
        internal string InstalledPath { get; } = installedPath;
        internal bool Moved { get; set; }
        internal List<UpdateShortcutEdit> Shortcuts { get; } = [];
        internal void Rollback()
        {
            var errors = new List<Exception>();
            foreach (var edit in Shortcuts.AsEnumerable().Reverse().Where(edit => edit.Changed))
            {
                try
                {
                    if (edit.Moved) { File.Move(edit.NewPath, edit.OriginalPath, overwrite: false); edit.Moved = false; }
                    AtomicFile.WriteStaged(edit.OriginalPath, temporary => File.WriteAllBytes(temporary, edit.Bytes));
                    edit.Changed = false;
                }
                catch (Exception error) when (error is IOException or UnauthorizedAccessException) { errors.Add(error); }
            }
            if (Moved)
            {
                try
                {
                    if (FileSha256(InstalledPath) != sha256) throw new InvalidDataException("The renamed Manager changed; recovery files were kept.");
                    File.Move(InstalledPath, originalPath, overwrite: false);
                    Moved = false;
                }
                catch (Exception error) when (error is IOException or UnauthorizedAccessException) { errors.Add(error); }
            }
            if (errors.Count > 0) throw new IOException("Some update paths could not be restored. Shortcut originals are in the recovery folder.", new AggregateException(errors));
        }
    }
    internal sealed class UpdateShortcutEdit(string originalPath, string newPath, byte[] bytes)
    {
        internal string OriginalPath { get; } = originalPath;
        internal string NewPath { get; } = newPath;
        internal byte[] Bytes { get; } = bytes;
        internal bool Changed { get; set; }
        internal bool Moved { get; set; }
    }
    internal const string CompletionArgument = "--manager-update-stage";
    private sealed record StartupReceipt(int ProcessId, long StartUtcTicks, string Executable, string Version);

    private static ManagerSelfUpdateCandidate DownloadCandidate(ManagerUpdateManifest manifest)
    {
        var name = manifest.DownloadFileName ?? throw new InvalidDataException("Missing downloaded filename.");
        return new(name, name.Length > 28 ? name[24..^4] : "", manifest.GitBlobSha, manifest.DownloadSize);
    }

    private static PreparedManagerUpdate PrepareVerifiedHandoff(string stage, string target, ManagerSelfUpdateCandidate candidate,
        string downloadSha256, string? legacyRecoveryStage = null)
    {
        var install = GetInstallPath(target, candidate);
        if (!SamePath(install, target) && File.Exists(install)) throw new IOException("A Manager already exists at " + install + ". Open that file instead; no file was overwritten.");
        var originalSha256 = FileSha256(target);
        var helper = Path.Combine(stage, "update-helper.exe");
        AtomicFile.Copy(target, helper);
        if (FileSha256(helper) != originalSha256) throw new InvalidDataException("The private helper did not match the running Manager.");
        using var current = Process.GetCurrentProcess();
        var manifest = new ManagerUpdateManifest(Path.GetFileName(stage)[StagePrefix.Length..], target, current.Id, current.StartTime.ToUniversalTime().Ticks,
            Path.GetFullPath(Environment.CurrentDirectory), ApprovedRestartArguments(Environment.GetCommandLineArgs().Skip(1)),
            originalSha256, originalSha256, downloadSha256, candidate.GitBlobSha.ToLowerInvariant(), candidate.Size, 120, 120)
        { DownloadFileName = candidate.Name, RequireStartupReady = true, LegacyRecoveryStage = legacyRecoveryStage };
        AtomicFile.WriteUtf8Text(Path.Combine(stage, "update.json"), JsonSerializer.Serialize(manifest));
        return new PreparedManagerUpdate(stage, manifest);
    }

    private static void WaitForConfirmedStartup(Process process, EventWaitHandle started, string stage, ManagerUpdateManifest manifest, string installed)
    {
        using var exited = new ManualResetEvent(false);
        EventHandler onExit = (_, _) => exited.Set();
        process.Exited += onExit;
        try
        {
            process.EnableRaisingEvents = true;
            if (process.HasExited || WaitHandle.WaitAny([started, exited], TimeSpan.FromSeconds(manifest.StartupTimeoutSeconds)) != 0 || process.HasExited)
                throw new IOException("The updated Manager did not reach its visible main window. The previous version will be restored.");
            var path = Path.Combine(stage, "startup-ready.json");
            if (new FileInfo(path).Length > 4096) throw new InvalidDataException("Invalid startup confirmation.");
            var receipt = JsonSerializer.Deserialize<StartupReceipt>(File.ReadAllText(path)) ?? throw new InvalidDataException("Missing startup confirmation.");
            var version = ValidateCandidate(DownloadCandidate(manifest));
            if (receipt.ProcessId != process.Id || receipt.StartUtcTicks != process.StartTime.ToUniversalTime().Ticks ||
                !SamePath(receipt.Executable, installed) || !ManagerBuildInfo.TryParseReleaseVersion(receipt.Version, out var actual) || actual != version)
                throw new InvalidDataException("Startup confirmation did not identify the installed Manager version.");
        }
        finally { process.Exited -= onExit; }
    }

    // Runs once, only at the existing main-window reveal boundary. Ordinary startups do no completion I/O.
    internal static async Task CompleteStartupAsync()
    {
        if (!AppMode.IsExportedUserBuild) return;
        var args = Environment.GetCommandLineArgs();
        var index = Array.IndexOf(args, CompletionArgument);
        if (index < 0) return;
        string? stage = null;
        try
        {
            if (index + 1 >= args.Length) throw new InvalidDataException("Missing startup completion manifest.");
            var manifest = ReadUpdateManifest(args[index + 1], out stage, completing: true);
            if (!manifest.RequireStartupReady) throw new InvalidDataException("The update did not request a startup confirmation.");
            VerifyStagedPayload(Environment.ProcessPath!, manifest);
            if (ManagerBuildInfo.ReleaseVersion != ValidateCandidate(DownloadCandidate(manifest))) throw new InvalidDataException("The installed executable contains a different Manager version.");
            using var started = EventWaitHandle.OpenExisting(EventName(manifest.StageId, "started"));
            using var finished = EventWaitHandle.OpenExisting(EventName(manifest.StageId, "finished"));
            using (var self = Process.GetCurrentProcess())
                AtomicFile.WriteUtf8Text(Path.Combine(stage, "startup-ready.json"), JsonSerializer.Serialize(new StartupReceipt(self.Id, self.StartTime.ToUniversalTime().Ticks, Environment.ProcessPath!, ManagerBuildInfo.VersionText)));
            started.Set();
            if (!await Task.Run(() => finished.WaitOne(TimeSpan.FromSeconds(15)))) throw new IOException("The update helper did not finish. Recovery files were kept.");
            var resultPath = Path.Combine(stage, "recovery-result.json");
            var result = JsonSerializer.Deserialize<ManagerUpdateRecoveryResult>(File.ReadAllText(resultPath)) ?? throw new InvalidDataException("Missing update result.");
            if (!result.Success || !SamePath(result.TargetPath, Environment.ProcessPath!)) throw new IOException(result.Message);
            await WaitForHelperExitAsync(stage, result);
            await Task.Run(() =>
            {
                var logs = Path.Combine(RuntimeSettings.SettingsDirectory, "logs");
                Directory.CreateDirectory(logs);
                AtomicFile.WriteUtf8Text(Path.Combine(logs, "manager-update-last.json"), JsonSerializer.Serialize(result));
                if (manifest.LegacyRecoveryStage is not null)
                {
                    ReadLegacyRecovery(manifest.LegacyRecoveryStage, manifest.TargetPath, manifest.OriginalSha256);
                    DeleteOwnedStage(manifest.LegacyRecoveryStage);
                }
                DeleteOwnedStage(stage);
                if (Directory.Exists(stage) || manifest.LegacyRecoveryStage is not null && Directory.Exists(manifest.LegacyRecoveryStage))
                    throw new IOException("Windows kept an update recovery folder. The updated Manager is already running.");
            });
        }
        catch (Exception error) when (error is IOException or UnauthorizedAccessException or InvalidDataException or ArgumentException or
            InvalidOperationException or System.ComponentModel.Win32Exception or System.Security.SecurityException or JsonException or WaitHandleCannotBeOpenedException)
        {
            MessageBox.Show("The Manager opened, but update completion needs attention." + Environment.NewLine + error.Message +
                Environment.NewLine + "Recovery files: " + stage, "Manager update", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
    }

    private static async Task WaitForHelperExitAsync(string stage, ManagerUpdateRecoveryResult result)
    {
        Process helper;
        try { helper = Process.GetProcessById(result.HelperProcessId); }
        catch (ArgumentException) { return; }
        using (helper)
        {
            try
            {
                if (helper.HasExited) return;
                var startTicks = helper.StartTime.ToUniversalTime().Ticks;
                var path = helper.MainModule?.FileName;
                if (helper.HasExited) return; // Exit can race either identity-property read after finished was signalled.
                if (startTicks != result.HelperStartUtcTicks || path is null || !SamePath(path, Path.Combine(stage, "update-helper.exe")))
                    throw new InvalidDataException("The completion helper identity changed; recovery files were kept.");
            }
            catch (Exception error) when ((error is InvalidOperationException or System.ComponentModel.Win32Exception) && helper.HasExited) { return; }
            using var timeout = new CancellationTokenSource(TimeSpan.FromSeconds(10));
            try { await helper.WaitForExitAsync(timeout.Token); }
            catch (OperationCanceledException) { throw new IOException("The completion helper did not exit; recovery files were kept."); }
        }
    }

    // Older public updaters start the new binary at the old filename. Hand off before any UI/data startup.
    internal static bool TryCompleteLegacyHandoff(string[] args, out int exitCode)
    {
        exitCode = 0;
        if (!AppMode.IsExportedUserBuild || args.Contains(CompletionArgument) || ManagerBuildInfo.ReleaseVersion is null) return false;
        var target = Path.GetFullPath(Environment.ProcessPath!);
        var name = "Foothold Config Manager " + ManagerBuildInfo.VersionText + ".exe";
        if (Path.GetFileName(target).Equals(name, StringComparison.OrdinalIgnoreCase)) return false;
        var directory = Path.GetDirectoryName(target)!;
        string? currentHash = null;
        foreach (var legacyStage in Directory.EnumerateDirectories(directory, StagePrefix + "*", SearchOption.TopDirectoryOnly))
        {
            ManagerUpdateManifest legacy;
            try
            {
                var path = Path.Combine(legacyStage, "update.json");
                if (!File.Exists(path) || new FileInfo(path).Length > 64 * 1024) continue;
                legacy = JsonSerializer.Deserialize<ManagerUpdateManifest>(File.ReadAllText(path))!;
                if (legacy is null || legacy.DownloadFileName is not null || !SamePath(legacy.TargetPath, target)) continue;
                currentHash ??= FileSha256(target);
                legacy = ReadLegacyRecovery(legacyStage, target, currentHash);
            }
            catch (Exception error) when (error is IOException or UnauthorizedAccessException or InvalidDataException or JsonException or ArgumentException) { continue; }
            var stage = Path.Combine(directory, StagePrefix + Guid.NewGuid().ToString("N"));
            try
            {
                CreatePrivateDirectory(stage);
                AtomicFile.Copy(target, Path.Combine(stage, "manager-update.exe"));
                var candidate = new ManagerSelfUpdateCandidate(name, ManagerBuildInfo.VersionText, legacy.GitBlobSha, legacy.DownloadSize);
                using var prepared = PrepareVerifiedHandoff(stage, target, candidate, currentHash!, legacyStage);
                prepared.StartHelperAsync(CancellationToken.None).GetAwaiter().GetResult();
                prepared.AuthorizeStartupMigrationExit();
                return true; // Program.Main exits; only then may the verified helper change filenames.
            }
            catch (Exception error) when (error is IOException or UnauthorizedAccessException or InvalidDataException or ArgumentException or InvalidOperationException or System.ComponentModel.Win32Exception)
            {
                DeleteOwnedStage(stage);
                MessageBox.Show("The new Manager is installed, but its filename could not be finalized." + Environment.NewLine + error.Message +
                    Environment.NewLine + "Recovery files: " + legacyStage, "Manager update", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return false;
            }
        }
        return false;
    }

    private static ManagerUpdateManifest ReadLegacyRecovery(string stage, string target, string downloadHash)
    {
        var name = Path.GetFileName(stage);
        if (!name.StartsWith(StagePrefix, StringComparison.Ordinal) || !Guid.TryParseExact(name[StagePrefix.Length..], "N", out _) ||
            !SamePath(Path.GetDirectoryName(stage)!, Path.GetDirectoryName(target)!) || (File.GetAttributes(stage) & FileAttributes.ReparsePoint) != 0)
            throw new InvalidDataException("The legacy recovery folder is not an owned sibling.");
        var path = Path.Combine(stage, "update.json");
        if (new FileInfo(path).Length > 64 * 1024) throw new InvalidDataException("Invalid legacy recovery manifest.");
        foreach (var file in new[] { path, Path.Combine(stage, "previous-manager.exe"), Path.Combine(stage, "update-helper.exe") })
            if ((File.GetAttributes(file) & FileAttributes.ReparsePoint) != 0) throw new InvalidDataException("Legacy recovery files cannot be links.");
        var manifest = JsonSerializer.Deserialize<ManagerUpdateManifest>(File.ReadAllText(path)) ?? throw new InvalidDataException("Invalid legacy recovery manifest.");
        if (manifest.StageId != name[StagePrefix.Length..] || manifest.DownloadFileName is not null || !SamePath(manifest.TargetPath, target) ||
            manifest.DownloadSha256 != downloadHash || !IsSha256(manifest.OriginalSha256) || manifest.HelperSha256 != manifest.OriginalSha256 ||
            File.Exists(Path.Combine(stage, "manager-update.exe")) || FileSha256(Path.Combine(stage, "previous-manager.exe")) != manifest.OriginalSha256 ||
            FileSha256(Path.Combine(stage, "update-helper.exe")) != manifest.HelperSha256)
            throw new InvalidDataException("Legacy recovery does not identify this completed installation.");
        return manifest;
    }

}
