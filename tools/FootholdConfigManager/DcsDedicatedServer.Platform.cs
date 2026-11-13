using System.ComponentModel;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;
using Loretta.CodeAnalysis.Lua.Syntax;
using Microsoft.Win32;
using Microsoft.Win32.SafeHandles;

namespace FootholdConfigManager;

// Optional external integration: unknown or inaccessible OS state never certifies a target.
internal sealed partial class DcsDedicatedServerPlatform : IDcsDedicatedServerPlatform
{
    internal static bool IsDedicatedInstallation(string directory) =>
        File.Exists(Path.Combine(directory, "bin", "DCS_server.exe"))
        && File.Exists(Path.Combine(directory, "dcs_variant.txt"))
        && File.ReadAllText(Path.Combine(directory, "dcs_variant.txt")).Trim() is var variant
        && (variant.StartsWith("dcs_server.", StringComparison.OrdinalIgnoreCase)
            || variant.Equals("openbeta_server", StringComparison.OrdinalIgnoreCase));

    internal static int ReadWebGuiPort(string? text)
    {
        if (text is null) return 8088;
        var root = WeatherLua.Parse(text, "autoexec.cfg");
        var assignments = root.DescendantNodes().OfType<AssignmentStatementSyntax>()
            .Where(s => s.Variables.Any(v => v.ToString().Contains("webgui_port", StringComparison.Ordinal))).ToArray();
        if (assignments.Length == 0) return 8088;
        var direct = root.Statements.Statements.OfType<AssignmentStatementSyntax>().ToArray();
        if (assignments.Length != 1 || !direct.Contains(assignments[0])
            || assignments[0].Variables.Count != 1 || assignments[0].Variables[0].ToString() != "webgui_port"
            || assignments[0].EqualsValues.Values.Count != 1
            || assignments[0].EqualsValues.Values[0] is not LiteralExpressionSyntax literal
            || WeatherLua.Read(literal) is not double port || port != Math.Truncate(port) || port < 1 || port > 65535)
            throw new InvalidDataException("The dedicated server control port is not one unambiguous literal setting.");
        return (int)port;
    }

    public DcsCapabilitySnapshot CaptureCapabilities(CancellationToken token)
    {
        var installations = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var identities = new List<DcsProcessIdentity>();
        string? unavailable = null;
        foreach (var hive in new[] { Registry.CurrentUser, Registry.LocalMachine })
        foreach (var product in new[] { "DCS World Server", "DCS World OpenBeta Server" })
        {
            token.ThrowIfCancellationRequested();
            try
            {
                using var key = hive.OpenSubKey(@"SOFTWARE\Eagle Dynamics\" + product);
                if (key?.GetValue("Path") is string path && IsDedicatedInstallation(path))
                    installations.Add(CanonicalPath(path));
            }
            catch (Exception error) when (Unavailable(error)) { unavailable = "Some dedicated-server installation information is unavailable."; }
        }
        foreach (var process in Process.GetProcessesByName("DCS_server"))
        {
            using (process)
            {
                token.ThrowIfCancellationRequested();
                try
                {
                    var module = process.MainModule;
                    if (module is null) { unavailable = "Some running dedicated-server information is unavailable."; continue; }
                    var executable = CanonicalPath(module.FileName);
                    var installation = Directory.GetParent(Path.GetDirectoryName(executable)!)!.FullName;
                    if (!IsDedicatedInstallation(installation)) continue;
                    installations.Add(installation);
                    identities.Add(new(process.Id, process.StartTime.ToFileTimeUtc(), executable, installation));
                }
                catch (Exception error) when (Unavailable(error)) { unavailable = "Some running dedicated-server information is unavailable."; }
            }
        }
        return new(installations.ToArray(), identities, unavailable);
    }

    public DcsLocalTargetIdentity? ResolveLocalTarget(DcsServerTarget target, DcsCapabilitySnapshot snapshot, CancellationToken token)
    {
        token.ThrowIfCancellationRequested();
        var profile = Directory.GetParent(Path.GetFullPath(target.MissionsDirectory))?.FullName;
        if (profile is null) return null;
        var log = Path.Combine(profile, "Logs", "dcs.log");
        if (!File.Exists(log)) return null;
        var owners = LogOwners(log);
        var identities = snapshot.Processes.Where(process => owners.Any(owner => process.ProcessId == owner.Pid
            && process.StartFileTime == owner.Start)).Take(2).ToArray();
        if (identities.Length != 1) return null;
        var identity = identities[0];
        if (!IsCurrent(identity)) return null;
        var autoexec = Path.Combine(profile, "Config", "autoexec.cfg");
        if (File.Exists(autoexec) && new FileInfo(autoexec).Length > 1024 * 1024)
            throw new InvalidDataException("The server control settings are too large to verify.");
        var port = ReadWebGuiPort(File.Exists(autoexec) ? File.ReadAllText(autoexec) : null);
        token.ThrowIfCancellationRequested();
        return new(target, identity, new Uri("http://127.0.0.1:" + port + "/"), CanonicalPath(target.MissionsDirectory));
    }

    public bool IsCurrent(DcsProcessIdentity identity)
    {
        try
        {
            using var process = Process.GetProcessById(identity.ProcessId);
            return process.MainModule is { } module && process.StartTime.ToFileTimeUtc() == identity.StartFileTime
                && CanonicalPath(module.FileName).Equals(identity.ExecutablePath, StringComparison.OrdinalIgnoreCase);
        }
        catch (Exception error) when (Unavailable(error)) { return false; }
    }

    public string CanonicalPath(string path)
    {
        if (!Path.IsPathFullyQualified(path)) throw new InvalidDataException("A server path must be absolute.");
        using var handle = CreateFile(Path.GetFullPath(path), 0, 7, IntPtr.Zero, 3, 0x02000000, IntPtr.Zero);
        if (handle.IsInvalid) throw new Win32Exception(Marshal.GetLastWin32Error());
        var buffer = new StringBuilder(32768);
        var count = GetFinalPathNameByHandle(handle, buffer, (uint)buffer.Capacity, 0);
        if (count == 0 || count >= buffer.Capacity) throw new Win32Exception(Marshal.GetLastWin32Error());
        var result = buffer.ToString();
        if (result.StartsWith(@"\\?\UNC\", StringComparison.OrdinalIgnoreCase)) result = @"\\" + result[8..];
        else if (result.StartsWith(@"\\?\", StringComparison.Ordinal)) result = result[4..];
        return Path.TrimEndingDirectorySeparator(result);
    }

    private static (int Pid, long Start)[] LogOwners(string path)
    {
        var key = new StringBuilder(33);
        if (RmStartSession(out var session, 0, key) != 0) throw new IOException("Could not verify the dedicated-server log owner.");
        try
        {
            if (RmRegisterResources(session, 1, [path], 0, null, 0, null) != 0)
                throw new IOException("Could not inspect the dedicated-server log.");
            uint count = 0, reason = 0;
            var status = RmGetList(session, out var needed, ref count, null, ref reason);
            if (status == 0 && needed == 0) return [];
            if (status != 234 || needed > 64) throw new IOException("The server log owner is unavailable.");
            var entries = new RmProcessInfo[needed]; count = needed;
            if (RmGetList(session, out needed, ref count, entries, ref reason) != 0)
                throw new IOException("The server log owner changed during verification.");
            return entries.Take((int)count).Select(p => (p.Process.Pid,
                ((long)(uint)p.Process.Start.dwHighDateTime << 32) | (uint)p.Process.Start.dwLowDateTime)).ToArray();
        }
        finally { RmEndSession(session); }
    }

    internal static bool Unavailable(Exception error) => error is IOException or InvalidDataException or UnauthorizedAccessException
        or Win32Exception or InvalidOperationException or ArgumentException or System.Security.SecurityException;

    [StructLayout(LayoutKind.Sequential)] private struct RmUniqueProcess
    { public int Pid; public System.Runtime.InteropServices.ComTypes.FILETIME Start; }
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)] private struct RmProcessInfo
    {
        public RmUniqueProcess Process;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 256)] public string AppName;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 64)] public string ServiceName;
        public uint ApplicationType, AppStatus, SessionId;
        [MarshalAs(UnmanagedType.Bool)] public bool Restartable;
    }
    [DllImport("kernel32.dll", EntryPoint = "CreateFileW", CharSet = CharSet.Unicode, SetLastError = true)]
    private static extern SafeFileHandle CreateFile(string path, uint access, uint share, IntPtr security, uint disposition, uint flags, IntPtr template);
    [DllImport("kernel32.dll", EntryPoint = "GetFinalPathNameByHandleW", CharSet = CharSet.Unicode, SetLastError = true)]
    private static extern uint GetFinalPathNameByHandle(SafeFileHandle handle, StringBuilder path, uint size, uint flags);
    [DllImport("rstrtmgr.dll", CharSet = CharSet.Unicode)] private static extern int RmStartSession(out uint session, uint flags, StringBuilder key);
    [DllImport("rstrtmgr.dll", CharSet = CharSet.Unicode)] private static extern int RmRegisterResources(uint session, uint count, string[] paths, uint appCount, RmUniqueProcess[]? apps, uint serviceCount, string[]? services);
    [DllImport("rstrtmgr.dll")] private static extern int RmGetList(uint session, out uint needed, ref uint count, [In, Out] RmProcessInfo[]? entries, ref uint reason);
    [DllImport("rstrtmgr.dll")] private static extern int RmEndSession(uint session);
}
