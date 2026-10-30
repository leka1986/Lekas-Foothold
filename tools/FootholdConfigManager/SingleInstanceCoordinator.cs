using System.ComponentModel;
using System.Diagnostics;
using System.Globalization;
using System.IO.Pipes;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Security.Principal;
using System.Text;
using Microsoft.Win32.SafeHandles;

namespace FootholdConfigManager;

internal sealed class SingleInstanceCoordinator : IDisposable
{
    internal enum Reply : byte { Accepted = 0, Closing = 1, Incompatible = 2, Rejected = 3 }
    private enum Notification { Accepted, Retry, Failed }
    private const int ActivationBudgetMs = 2500;
    private readonly object _sync = new();
    private readonly int _staThread = Environment.CurrentManagedThreadId;
    private readonly uint _sessionId;
    private readonly SecurityIdentifier _userSid;
    private readonly Mutex _mutex;
    private readonly string _pipeName;
    private readonly CancellationTokenSource _shutdown = new();
    private NamedPipeServerStream? _pipe;
    private Task? _listener;
    private bool _ownsMutex;
    private bool _closing;
    private bool _disposed;
    private bool _pendingReveal;
    private bool _pendingAdmin;
    private bool _adminInFlight;
    private bool _modelReady;
    private bool _drainPosted;
    private Exception? _listenerFailure;
    private bool _failureReported;
    private WindowsFormsSynchronizationContext? _dispatcher; // Borrowed, never disposed.
    private Form? _form; // Read only on the original STA.
    private Form? _startupPresentation; // Borrowed on the original STA; does not change owner admission.
    private Action? _adminAction;
    private Func<bool>? _adminSafe;
    private bool _idleAttached;
    internal bool IsOwner => _ownsMutex;
    internal int SecondaryResult { get; private set; } = 3;
    internal string FailureReason { get; private set; } = "The manager owning this data folder could not be contacted. Switch to it or close it normally before retrying.";

    private SingleInstanceCoordinator(string effectiveDirectory)
    {
        if (Thread.CurrentThread.GetApartmentState() != ApartmentState.STA)
            throw new InvalidOperationException("Single-instance admission must run on the original STA.");
        using var identity = WindowsIdentity.GetCurrent();
        using var process = Process.GetCurrentProcess();
        _sessionId = checked((uint)process.SessionId);
        _userSid = identity.User ?? throw new InvalidOperationException("Current Windows user SID is unavailable.");
        var digest = BuildIdentity(effectiveDirectory, _userSid.Value, process.SessionId);
        _pipeName = "FootholdConfigManager." + digest + ".activate";
        _mutex = new Mutex(false, @"Local\FootholdConfigManager." + digest);
    }

    internal static string BuildIdentity(string directory, string sid, int session)
    {
        ArgumentException.ThrowIfNullOrEmpty(sid);
        var full = Path.GetFullPath(directory);
        var root = Path.GetPathRoot(full) ?? throw new ArgumentException("Effective data directory has no root.", nameof(directory));
        var trimmed = full.TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
        var rootTrimmed = root.TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
        full = trimmed.Equals(rootTrimmed, StringComparison.OrdinalIgnoreCase)
            ? rootTrimmed + Path.DirectorySeparatorChar : trimmed;
        var framed = string.Join('\0', "FootholdConfigManager", sid, session.ToString(CultureInfo.InvariantCulture), full.ToUpperInvariant());
        return Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(framed)));
    }

    internal static SingleInstanceCoordinator Enter(string effectiveDirectory, bool requestAdmin)
    {
        var result = new SingleInstanceCoordinator(effectiveDirectory);
        try
        {
            if (result.TryOwn(0)) { result.StartListener(); return result; }
            var elapsed = Stopwatch.StartNew();
            using var deadline = new CancellationTokenSource(ActivationBudgetMs);
            while (elapsed.ElapsedMilliseconds < ActivationBudgetMs)
            {
                var remaining = ActivationBudgetMs - checked((int)elapsed.ElapsedMilliseconds);
                var outcome = result.NotifyAsync(requestAdmin, Math.Min(100, remaining), deadline.Token).GetAwaiter().GetResult();
                if (outcome == Notification.Accepted) { result.SecondaryResult = 0; return result; }
                if (outcome == Notification.Failed) return result;
                remaining = ActivationBudgetMs - checked((int)elapsed.ElapsedMilliseconds);
                // This wait and every successful acquisition stay on the original STA.
                if (remaining > 0 && result.TryOwn(Math.Min(50, remaining))) { result.StartListener(); return result; }
            }
            return result;
        }
        catch { result.Dispose(); throw; }
    }

    private bool TryOwn(int timeout)
    {
        AssertSta();
        try { _ownsMutex = _mutex.WaitOne(timeout); }
        catch (AbandonedMutexException) { _ownsMutex = true; }
        return _ownsMutex;
    }

    private void StartListener()
    {
        AssertSta();
        // Endpoint creation is synchronous and precedes every MainForm/store constructor.
        var pipe = new NamedPipeServerStream(_pipeName, PipeDirection.InOut, 1,
            PipeTransmissionMode.Byte, PipeOptions.Asynchronous | PipeOptions.CurrentUserOnly, 64, 64);
        _pipe = pipe;
        var stop = _shutdown.Token;
        _listener = Task.Run(() => ListenAsync(pipe, stop));
    }

    internal static Reply DecodeRequest(ReadOnlySpan<byte> bytes, out bool admin)
    {
        admin = false;
        if (bytes.Length != 8 || bytes[0] != 70 || bytes[1] != 67 || bytes[2] != 77 || bytes[3] != 65 ||
            (bytes[5] & ~1) != 0 || bytes[6] != 0 || bytes[7] != 0) return Reply.Rejected;
        if (bytes[4] != 1) return Reply.Incompatible;
        admin = (bytes[5] & 1) != 0;
        return Reply.Accepted;
    }

    private async Task ListenAsync(NamedPipeServerStream pipe, CancellationToken stop)
    {
        try
        {
            while (!stop.IsCancellationRequested)
            {
                await pipe.WaitForConnectionAsync(stop).ConfigureAwait(false);
                try
                {
                    using var clientDeadline = CancellationTokenSource.CreateLinkedTokenSource(stop);
                    clientDeadline.CancelAfter(500);
                    var token = clientDeadline.Token;
                    var status = Reply.Rejected;
                    if (PeerSession(pipe.SafePipeHandle, server: false, out _))
                    {
                        var frame = new byte[8];
                        await pipe.ReadExactlyAsync(frame, token).ConfigureAwait(false);
                        status = DecodeRequest(frame, out var admin);
                        if (status == Reply.Accepted)
                        {
                            lock (_sync)
                            {
                                if (_closing) status = Reply.Closing;
                                else
                                {
                                    _pendingReveal = true;
                                    if (admin && !_adminInFlight) _pendingAdmin = true;
                                }
                            }
                            if (status == Reply.Accepted) ScheduleDrain();
                        }
                    }
                    var reply = new byte[] { 70, 67, 77, 82, 1, (byte)status, 0, 0 };
                    await pipe.WriteAsync(reply, token).ConfigureAwait(false);
                    // Let the peer read the reply and close; discard trailing bytes within the same connection deadline.
                    await pipe.CopyToAsync(Stream.Null, 64, token).ConfigureAwait(false);
                }
                catch (OperationCanceledException) when (!stop.IsCancellationRequested) { }
                catch (IOException) { } // Malformed/partial/disconnected client; no owner fallback.
                finally
                {
                    if (!stop.IsCancellationRequested) pipe.Disconnect(); // Also resets Broken state.
                }
            }
        }
        catch (OperationCanceledException) when (stop.IsCancellationRequested) { }
        catch (ObjectDisposedException) when (stop.IsCancellationRequested) { }
        catch (Exception error)
        {
            lock (_sync) { if (_closing) return; _listenerFailure = error; }
            ScheduleDrain(); // Existing UI exception/crash path; mutex remains held.
        }
    }

    private async Task<Notification> NotifyAsync(bool admin, int connectTimeout, CancellationToken deadline)
    {
        try
        {
            using var client = new NamedPipeClientStream(".", _pipeName, PipeDirection.InOut,
                PipeOptions.Asynchronous | PipeOptions.CurrentUserOnly, TokenImpersonationLevel.Identification);
            await client.ConnectAsync(connectTimeout, deadline).ConfigureAwait(false);
            if (!PeerSession(client.SafePipeHandle, server: true, out var pid))
            {
                FailureReason = "The manager activation endpoint could not be verified for this Windows user/session. Query access may be denied across elevation contexts.";
                return Notification.Failed;
            }
            _ = AllowSetForegroundWindow(pid); // Eligibility/foreground success are separate from queue acceptance.
            await client.WriteAsync(new byte[] { 70, 67, 77, 65, 1, admin ? (byte)1 : (byte)0, 0, 0 }, deadline).ConfigureAwait(false);
            var reply = new byte[8];
            await client.ReadExactlyAsync(reply, deadline).ConfigureAwait(false);
            if (reply[0] != 70 || reply[1] != 67 || reply[2] != 77 || reply[3] != 82 || reply[4] != 1 || reply[6] != 0 || reply[7] != 0)
            {
                FailureReason = "The running manager uses an incompatible activation protocol. Close it normally before retrying.";
                return Notification.Failed;
            }
            if ((Reply)reply[5] == Reply.Accepted) return Notification.Accepted;
            if ((Reply)reply[5] == Reply.Closing) return Notification.Retry;
            FailureReason = (Reply)reply[5] == Reply.Incompatible
                ? "The running manager uses an incompatible activation protocol. Close it normally before retrying."
                : "The running manager rejected this activation request. Switch to it or close it normally before retrying.";
            return Notification.Failed;
        }
        catch (TimeoutException) { return Notification.Retry; }
        catch (OperationCanceledException) { return Notification.Retry; }
        catch (UnauthorizedAccessException)
        {
            FailureReason = "Activation was denied for this Windows user or elevation context. Switch to the existing manager or close it normally before retrying.";
            return Notification.Failed;
        }
        catch (IOException) { return Notification.Retry; }
    }

    private bool PeerSession(SafePipeHandle handle, bool server, out uint pid)
    {
        var ok = server ? GetNamedPipeServerProcessId(handle, out pid) : GetNamedPipeClientProcessId(handle, out pid);
        if (!ok || pid == 0 || !ProcessIdToSessionId(pid, out var session) || session != _sessionId) return false;
        using var process = OpenProcess(0x1000, false, pid); // PROCESS_QUERY_LIMITED_INFORMATION only.
        if (process.IsInvalid) return false;
        var opened = OpenProcessToken(process, 0x0008, out var token); // TOKEN_QUERY only.
        using (token)
        {
            if (!opened || token.IsInvalid) return false;
            try
            {
                // BCL User queries TOKEN_USER; CurrentUserOnly's Owner/group check is not sufficient.
                using var peer = new WindowsIdentity(token.DangerousGetHandle());
                return peer.User is { } user && _userSid.Equals(user);
            }
            catch (System.Security.SecurityException) { return false; }
            catch (ArgumentException) { return false; }
        }
    }

    internal void BindUi(Form form, WindowsFormsSynchronizationContext dispatcher, Action adminAction, Func<bool> adminSafe)
    {
        AssertSta();
        lock (_sync)
        {
            if (!_ownsMutex || _dispatcher is not null || _closing) throw new InvalidOperationException("Owner UI attachment is one-time before closing.");
            _form = form; _dispatcher = dispatcher; _adminAction = adminAction; _adminSafe = adminSafe;
        }
        UpdateIdleSubscription();
        ScheduleDrain();
    }

    internal void ModelReady(bool requestAdmin)
    {
        AssertSta();
        lock (_sync)
        {
            if (_closing) return;
            _modelReady = true;
            if (requestAdmin && !_adminInFlight) { _pendingAdmin = true; _pendingReveal = true; }
        }
        UpdateIdleSubscription();
        ScheduleDrain();
    }

    internal void PresentationChanged() { AssertSta(); ScheduleDrain(); }

    internal void SetStartupPresentation(Form? presentation)
    {
        AssertSta();
        _startupPresentation = presentation;
        ScheduleDrain();
    }

    private void ScheduleDrain()
    {
        WindowsFormsSynchronizationContext? dispatcher;
        lock (_sync)
        {
            if (_closing || _drainPosted || _dispatcher is null ||
                (!_pendingReveal && !_pendingAdmin && (_listenerFailure is null || _failureReported))) return;
            _drainPosted = true;
            dispatcher = _dispatcher;
        }
        try { dispatcher.Post(_ => DrainUi(), null); }
        catch (InvalidAsynchronousStateException) when (_shutdown.IsCancellationRequested) { }
        catch (ObjectDisposedException) when (_shutdown.IsCancellationRequested) { }
    }

    private void DrainUi()
    {
        AssertSta();
        Exception? failure;
        lock (_sync)
        {
            _drainPosted = false;
            if (_closing) return;
            failure = _failureReported ? null : _listenerFailure;
            if (failure is not null) _failureReported = true;
        }
        try
        {
            if (failure is not null) throw new IOException("The single-instance activation listener stopped. This process still owns the data folder; close it normally before reopening.", failure);
            var form = _form;
            if (form is null || form.IsDisposed || !form.IsHandleCreated) return;
            var main = form.Handle; // Never captured/read on the worker.
            bool reveal;
            lock (_sync) reveal = _pendingReveal;
            if (reveal)
            {
                Restore(main); // Owned popups hidden by owner minimization become discoverable again.
                var target = PresentationTarget(main);
                if (_startupPresentation is { IsDisposed: false, Visible: true, IsHandleCreated: true } startup &&
                    (target == IntPtr.Zero || target == main))
                    target = PresentationTarget(startup.Handle);
                if (target != IntPtr.Zero)
                {
                    lock (_sync) _pendingReveal = false;
                    Reveal(main, target);
                }
            }
            bool ready;
            lock (_sync) ready = !_closing && _modelReady && _pendingAdmin && !_adminInFlight;
            if (ready && form.Visible && form.Enabled && IsWindowEnabled(main) && PresentationTarget(main) == main && _adminSafe!())
            {
                lock (_sync)
                {
                    if (_closing || !_pendingAdmin || _adminInFlight) return;
                    _pendingAdmin = false; _adminInFlight = true;
                }
                try { _adminAction!(); }
                finally { lock (_sync) _adminInFlight = false; }
            }
        }
        finally { UpdateIdleSubscription(); }
    }

    private void UpdateIdleSubscription()
    {
        AssertSta();
        bool needed;
        lock (_sync) needed = !_closing && _dispatcher is not null && (_pendingReveal || _pendingAdmin);
        if (needed == _idleAttached) return;
        if (needed) Application.Idle += OnIdle;
        else Application.Idle -= OnIdle;
        _idleAttached = needed;
    }
    private void OnIdle(object? sender, EventArgs args) => DrainUi();

    internal void BeginClosing()
    {
        AssertSta();
        lock (_sync)
        {
            if (_closing) return;
            _closing = true; _pendingReveal = false; _pendingAdmin = false;
        }
        UpdateIdleSubscription();
        _shutdown.Cancel();
        _pipe?.Dispose();
    }

    public void Dispose()
    {
        AssertSta();
        if (_disposed) return;
        _disposed = true;
        BeginClosing();
        try { if (_listener is not null && !_listener.Wait(500)) { /* Canceled, pipe closed; no UI Send can block cleanup. */ } }
        finally
        {
            try { if (_ownsMutex) { _ownsMutex = false; _mutex.ReleaseMutex(); } }
            finally { _mutex.Dispose(); _shutdown.Dispose(); _form = null; _dispatcher = null; }
        }
    }
    private void AssertSta()
    {
        if (Environment.CurrentManagedThreadId != _staThread) throw new InvalidOperationException("Owner lifetime/UI operation left its original STA.");
    }

    private static IntPtr PresentationTarget(IntPtr main)
    {
        if (!IsWindow(main)) return IntPtr.Zero;
        var seen = new HashSet<IntPtr> { main };
        var current = main;
        var target = IntPtr.Zero;
        for (var depth = 0; depth < 32; depth++)
        {
            var popup = GetLastActivePopup(current);
            if (popup == current || popup == IntPtr.Zero || !OwnedBy(popup, main) || !IsWindowVisible(popup) || !IsWindowEnabled(popup))
                popup = GetWindow(current, 6); // GW_ENABLEDPOPUP, including native common dialogs.
            if (popup == current || popup == IntPtr.Zero || !OwnedBy(popup, main) || !seen.Add(popup)) break;
            if (IsWindowVisible(popup) && IsWindowEnabled(popup)) target = popup;
            current = popup;
        }
        if (target != IntPtr.Zero) return target;
        return IsWindowVisible(main) && IsWindowEnabled(main) ? main : IntPtr.Zero;
    }
    private static bool OwnedBy(IntPtr window, IntPtr main)
    {
        _ = GetWindowThreadProcessId(window, out var pid);
        if (pid != (uint)Environment.ProcessId) return false;
        for (var depth = 0; depth < 32 && window != IntPtr.Zero; depth++)
        {
            if (window == main) return true;
            window = GetWindow(window, 4); // GW_OWNER.
        }
        return false;
    }
    private static void Reveal(IntPtr main, IntPtr target)
    {
        Restore(main);
        if (target != main) Restore(target);
        _ = SetForegroundWindow(target);
        var foreground = GetForegroundWindow();
        if (OwnedBy(foreground, main) && IsWindowVisible(foreground) && IsWindowEnabled(foreground)) return;
        var flash = new FlashInfo { Size = (uint)Marshal.SizeOf<FlashInfo>(), Window = main, Flags = 3, Count = 3, Timeout = 0 };
        _ = FlashWindowEx(ref flash); // Finite notification, no TopMost/input attachment trick.
    }
    private static void Restore(IntPtr window)
    {
        if (!IsIconic(window)) return;
        var placement = new WindowPlacement { Length = (uint)Marshal.SizeOf<WindowPlacement>() };
        if (!GetWindowPlacement(window, ref placement)) return;
        _ = ShowWindow(window, (placement.Flags & 2) != 0 ? 3 : 9); // Restore prior OS placement; never force Normal.
    }

    [StructLayout(LayoutKind.Sequential)] private struct Point { public int X, Y; }
    [StructLayout(LayoutKind.Sequential)] private struct Rect { public int Left, Top, Right, Bottom; }
    [StructLayout(LayoutKind.Sequential)] private struct WindowPlacement
    { public uint Length, Flags, ShowCommand; public Point Minimum, Maximum; public Rect Normal; }
    [StructLayout(LayoutKind.Sequential)] private struct FlashInfo
    { public uint Size; public IntPtr Window; public uint Flags, Count, Timeout; }
    [DllImport("kernel32.dll", SetLastError = true)] [return: MarshalAs(UnmanagedType.Bool)] private static extern bool GetNamedPipeServerProcessId(SafePipeHandle pipe, out uint pid);
    [DllImport("kernel32.dll", SetLastError = true)] [return: MarshalAs(UnmanagedType.Bool)] private static extern bool GetNamedPipeClientProcessId(SafePipeHandle pipe, out uint pid);
    [DllImport("kernel32.dll", SetLastError = true)] [return: MarshalAs(UnmanagedType.Bool)] private static extern bool ProcessIdToSessionId(uint pid, out uint session);
    [DllImport("kernel32.dll", SetLastError = true)] private static extern SafeProcessHandle OpenProcess(uint access, [MarshalAs(UnmanagedType.Bool)] bool inheritHandle, uint pid);
    [DllImport("advapi32.dll", SetLastError = true)] [return: MarshalAs(UnmanagedType.Bool)] private static extern bool OpenProcessToken(SafeProcessHandle process, uint access, out SafeAccessTokenHandle token);
    [DllImport("user32.dll")] [return: MarshalAs(UnmanagedType.Bool)] private static extern bool AllowSetForegroundWindow(uint pid);
    [DllImport("user32.dll")] private static extern IntPtr GetWindow(IntPtr window, uint command);
    [DllImport("user32.dll")] private static extern IntPtr GetLastActivePopup(IntPtr window);
    [DllImport("user32.dll")] private static extern IntPtr GetAncestor(IntPtr window, uint flags);
    [DllImport("user32.dll")] private static extern uint GetWindowThreadProcessId(IntPtr window, out uint pid);
    [DllImport("user32.dll")] [return: MarshalAs(UnmanagedType.Bool)] private static extern bool IsWindow(IntPtr window);
    [DllImport("user32.dll")] [return: MarshalAs(UnmanagedType.Bool)] private static extern bool IsWindowVisible(IntPtr window);
    [DllImport("user32.dll")] [return: MarshalAs(UnmanagedType.Bool)] private static extern bool IsWindowEnabled(IntPtr window);
    [DllImport("user32.dll")] [return: MarshalAs(UnmanagedType.Bool)] private static extern bool IsIconic(IntPtr window);
    [DllImport("user32.dll")] [return: MarshalAs(UnmanagedType.Bool)] private static extern bool SetForegroundWindow(IntPtr window);
    [DllImport("user32.dll")] private static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] [return: MarshalAs(UnmanagedType.Bool)] private static extern bool GetWindowPlacement(IntPtr window, ref WindowPlacement placement);
    [DllImport("user32.dll")] [return: MarshalAs(UnmanagedType.Bool)] private static extern bool ShowWindow(IntPtr window, int command);
    [DllImport("user32.dll")] [return: MarshalAs(UnmanagedType.Bool)] private static extern bool FlashWindowEx(ref FlashInfo info);
}
