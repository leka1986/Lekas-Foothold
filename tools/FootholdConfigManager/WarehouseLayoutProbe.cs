using System.Collections.Concurrent;
using System.Diagnostics;

namespace FootholdConfigManager;

// Enabled by a marker beside the diagnostic executable.
internal sealed class WarehouseLayoutProbe : IDisposable
{
    internal enum Counter { EditorLayout, EditorMeasure, SectionMeasure, PickerSize, MatchToolbar, ScrollbarPaint, ScrollbarDrag }

    private static WarehouseLayoutProbe? _instance;
    private readonly ConcurrentQueue<string> _messages = new();
    private readonly long[] _counts = new long[Enum.GetValues<Counter>().Length];
    private readonly System.Windows.Forms.Timer _heartbeat = new() { Interval = 250 };
    private readonly System.Threading.Timer _writer;
    private readonly string _path;
    private readonly object _writeLock = new();
    private readonly Process _process = Process.GetCurrentProcess();
    private Scope? _active;
    private string _lastOperation = "startup";
    private long _lastPulse = Stopwatch.GetTimestamp();
    private TimeSpan _lastCpu;
    private long _lastReport;
    private bool _stalled;
    private int _linesWritten;
    private bool _closed;

    private WarehouseLayoutProbe(string path)
    {
        _path = path;
        File.WriteAllText(path, $"{DateTimeOffset.Now:O} START pid={Environment.ProcessId} version={ManagerBuildInfo.VersionText}{Environment.NewLine}");
        _heartbeat.Tick += (_, _) => Volatile.Write(ref _lastPulse, Stopwatch.GetTimestamp());
        _heartbeat.Start();
        _writer = new System.Threading.Timer(_ => Flush(), null, 250, 250);
    }

    internal static bool Enabled => _instance is not null;

    internal static WarehouseLayoutProbe? StartIfEnabled()
    {
        var directory = AppContext.BaseDirectory;
        if (!File.Exists(Path.Combine(directory, "warehouse-layout-probe.enabled"))) return null;
        try
        {
            return _instance = new WarehouseLayoutProbe(Path.Combine(directory, $"warehouse-layout-{Environment.ProcessId}.log"));
        }
        catch (IOException) { return null; }
        catch (UnauthorizedAccessException) { return null; }
    }

    internal static IDisposable? Enter(string name, string? detail = null)
    {
        if (_instance is not { } probe) return null;
        var scope = new Scope(probe, name, probe._active);
        Volatile.Write(ref probe._active, scope);
        probe.Record("BEGIN " + name + (detail is null ? "" : " " + detail));
        return scope;
    }

    internal static void Note(string message) => _instance?.Record(message);

    internal static void Count(Counter counter)
    {
        if (_instance is { } probe) Interlocked.Increment(ref probe._counts[(int)counter]);
    }

    private void Record(string message)
    {
        Volatile.Write(ref _lastOperation, message);
        if (_messages.Count < 256) _messages.Enqueue($"{DateTimeOffset.Now:O} {message}");
    }

    private void Flush()
    {
        lock (_writeLock)
        {
            if (_closed) return;
            var now = Stopwatch.GetTimestamp();
            var pulseAge = Stopwatch.GetElapsedTime(Volatile.Read(ref _lastPulse), now);
            if (pulseAge.TotalSeconds >= 2 && (_lastReport == 0 || Stopwatch.GetElapsedTime(_lastReport, now).TotalSeconds >= 3))
            {
                var scopeNames = new List<string>();
                for (var scope = Volatile.Read(ref _active); scope is not null; scope = scope.Parent)
                    scopeNames.Add(scope.Name);
                _process.Refresh();
                var cpu = _process.TotalProcessorTime;
                var counts = string.Join(" ", Enum.GetValues<Counter>().Select(counter =>
                    $"{counter}={Interlocked.Read(ref _counts[(int)counter])}"));
                _messages.Enqueue($"{DateTimeOffset.Now:O} UI STALL {pulseAge.TotalMilliseconds:F0}ms " +
                    $"scope={string.Join(" <- ", scopeNames)} last={Volatile.Read(ref _lastOperation)} " +
                    $"cpu-total-ms={cpu.TotalMilliseconds:F0} cpu-delta-ms={(cpu - _lastCpu).TotalMilliseconds:F0} " +
                    $"working-set-mb={_process.WorkingSet64 / 1048576} {counts}");
                _lastCpu = cpu;
                _lastReport = now;
                _stalled = true;
            }
            else if (pulseAge.TotalSeconds < 2 && _stalled)
            {
                _messages.Enqueue($"{DateTimeOffset.Now:O} UI RECOVERED");
                _stalled = false;
                _lastReport = 0;
            }
            if (_messages.IsEmpty) return;
            try
            {
                // Keep the most recent activity when a long run reaches the size limit.
                if (_linesWritten >= 3000)
                {
                    File.Move(_path, _path + ".previous", overwrite: true);
                    _linesWritten = 0;
                }
                using var output = new StreamWriter(_path, append: true);
                while (_messages.TryDequeue(out var message))
                {
                    output.WriteLine(message);
                    _linesWritten++;
                }
            }
            catch (IOException) { }
            catch (UnauthorizedAccessException) { }
        }
    }

    public void Dispose()
    {
        _heartbeat.Dispose();
        _writer.Dispose();
        Record("STOP");
        lock (_writeLock)
        {
            Flush();
            _closed = true;
            _process.Dispose();
            _instance = null;
        }
    }

    private sealed class Scope(WarehouseLayoutProbe owner, string name, Scope? parent) : IDisposable
    {
        private readonly long _start = Stopwatch.GetTimestamp();
        internal string Name { get; } = name;
        internal Scope? Parent { get; } = parent;
        public void Dispose()
        {
            Volatile.Write(ref owner._active, Parent);
            owner.Record($"END {Name} {Stopwatch.GetElapsedTime(_start).TotalMilliseconds:F1}ms");
        }
    }
}
