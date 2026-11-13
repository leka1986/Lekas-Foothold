using System.Runtime.InteropServices;

namespace FootholdConfigManager;

// Only Windows' recycle operation is exposed; there is deliberately no permanent-delete fallback.
internal static class MissionRecycleBin
{
    internal static Task<IReadOnlyList<(string Path, string? Error)>> MoveAsync(IReadOnlyList<MissionPathIdentity> sources, CancellationToken token)
    {
        var completion = new TaskCompletionSource<IReadOnlyList<(string Path, string? Error)>>(TaskCreationOptions.RunContinuationsAsynchronously);
        var thread = new Thread(() =>
        {
            var results = new List<(string Path, string? Error)>();
            foreach (var source in sources)
            {
                if (token.IsCancellationRequested) break;
                try { Move(source); results.Add((source.Path, null)); }
                catch (Exception error) { results.Add((source.Path, error.Message)); }
            }
            completion.SetResult(results.AsReadOnly());
        }) { IsBackground = true, Name = "Foothold mission Recycle Bin" };
        thread.SetApartmentState(ApartmentState.STA); thread.Start();
        return completion.Task;
    }

    internal static string Move(MissionPathIdentity source)
    {
        var path = Path.GetFullPath(source.Path);
        if (!source.Exists || source.Sha256 is null || !(path.EndsWith(".miz", StringComparison.OrdinalIgnoreCase)
            || path.EndsWith(".miz.orig", StringComparison.OrdinalIgnoreCase)))
            throw new InvalidDataException("Select a previously checked MIZ file.");
        var root = Path.GetPathRoot(path)!;
        if (root.StartsWith(@"\\", StringComparison.Ordinal) || new DriveInfo(root).DriveType != DriveType.Fixed)
            throw new IOException("The Recycle Bin is unavailable for this location. The file was not deleted.");
        var attributes = File.GetAttributes(path);
        if ((attributes & (FileAttributes.Directory | FileAttributes.ReparsePoint)) != 0)
            throw new IOException("Folders and linked files cannot be recycled here.");
        for (var directory = Path.GetDirectoryName(path); directory is not null; directory = Path.GetDirectoryName(directory))
            if ((File.GetAttributes(directory) & FileAttributes.ReparsePoint) != 0)
                throw new IOException("Linked folders cannot be recycled here.");
        IFileOperation? operation = null; IShellItem? item = null;
        using var sink = new RecycleSink(source);
        try
        {
            operation = (IFileOperation)Activator.CreateInstance(Type.GetTypeFromCLSID(new("3ad05575-8857-4850-9277-11b85bdb8e09"), true)!)!;
            // FOFX_RECYCLEONDELETE + EARLYFAILURE, ALLOWUNDO, SILENT, NOERRORUI,
            // NOCONFIRMATION, NO_CONNECTED_ELEMENTS and NORECURSION. No shell permanent-delete confirmation.
            operation.SetOperationFlags(0x00080000 | 0x00100000 | 0x0040 | 0x0004 | 0x0400 | 0x0010 | 0x2000 | 0x1000);
            var iid = typeof(IShellItem).GUID;
            SHCreateItemFromParsingName(path, IntPtr.Zero, ref iid, out item);
            operation.DeleteItem(item, sink); operation.PerformOperations();
            operation.GetAnyOperationsAborted(out var aborted);
            if (aborted || sink.Error is not null || sink.RecycledPath is null)
                throw new IOException(sink.Error ?? "The Recycle Bin operation was cancelled or unavailable. No permanent deletion was attempted.");
            return sink.RecycledPath;
        }
        catch (COMException error) when (sink.Error is not null) { throw new IOException(sink.Error, error); }
        finally
        {
            if (item is not null) Marshal.ReleaseComObject(item);
            if (operation is not null) Marshal.ReleaseComObject(operation);
        }
    }

    [ComVisible(true), ClassInterface(ClassInterfaceType.None)]
    private sealed class RecycleSink(MissionPathIdentity source) : IFileOperationProgressSink, IDisposable
    {
        private FileStream? _held;
        internal string? Error { get; private set; }
        internal string? RecycledPath { get; private set; }
        public int PreDeleteItem(uint flags, IShellItem item)
        {
            // TSF_DELETE_RECYCLE_IF_POSSIBLE must be present in the actual shell operation.
            if ((flags & 0x80) == 0) { Error = "The Recycle Bin is unavailable. The file was not deleted."; return unchecked((int)0x80004004); }
            try
            {
                item.GetDisplayName(0x80058000, out var path);
                if (!path.Equals(source.Path, StringComparison.OrdinalIgnoreCase)) throw new IOException("The selected source path changed.");
                _held = new FileStream(source.Path, FileMode.Open, FileAccess.Read, FileShare.Read | FileShare.Delete);
                source.RequireUnchanged(_held);
                return 0;
            }
            catch (Exception error) { Error = error.Message; Dispose(); return unchecked((int)0x80004004); }
        }
        public int PostDeleteItem(uint flags, IShellItem item, int result, IShellItem? recycled)
        {
            Dispose();
            if (result < 0) Error = Marshal.GetExceptionForHR(result)?.Message ?? "Could not recycle the selected file.";
            else if (recycled is not null)
                try { recycled.GetDisplayName(0x80058000, out var path); RecycledPath = path; }
                catch (COMException error) { Error = error.Message; }
            return 0;
        }
        public void Dispose() { _held?.Dispose(); _held = null; }
        public int StartOperations() => 0;
        public int FinishOperations(int result) => 0;
        public int PreRenameItem(uint flags, IShellItem item, string name) => 0;
        public int PostRenameItem(uint flags, IShellItem item, string name, int result, IShellItem? created) => 0;
        public int PreMoveItem(uint flags, IShellItem item, IShellItem destination, string name) => 0;
        public int PostMoveItem(uint flags, IShellItem item, IShellItem destination, string name, int result, IShellItem? created) => 0;
        public int PreCopyItem(uint flags, IShellItem item, IShellItem destination, string name) => 0;
        public int PostCopyItem(uint flags, IShellItem item, IShellItem destination, string name, int result, IShellItem? created) => 0;
        public int PreNewItem(uint flags, IShellItem destination, string name) => 0;
        public int PostNewItem(uint flags, IShellItem destination, string name, string template, uint attributes, int result, IShellItem? created) => 0;
        public int UpdateProgress(uint total, uint completed) => 0;
        public int ResetTimer() => 0;
        public int PauseTimer() => 0;
        public int ResumeTimer() => 0;
    }

    [DllImport("shell32.dll", CharSet = CharSet.Unicode, PreserveSig = false)]
    private static extern void SHCreateItemFromParsingName(string path, IntPtr context, ref Guid iid, [MarshalAs(UnmanagedType.Interface)] out IShellItem item);

    [ComImport, Guid("43826d1e-e718-42ee-bc55-a1e261c37bfe"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    private interface IShellItem
    {
        void BindToHandler(IntPtr context, ref Guid handler, ref Guid iid, out IntPtr result);
        void GetParent(out IShellItem parent);
        void GetDisplayName(uint kind, [MarshalAs(UnmanagedType.LPWStr)] out string name);
        void GetAttributes(uint mask, out uint attributes);
        void Compare(IShellItem item, uint hint, out int order);
    }

    [ComImport, Guid("947aab5f-0a5c-4c13-b4d6-4bf7836fc9f8"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    private interface IFileOperation
    {
        void Advise(IFileOperationProgressSink sink, out uint cookie);
        void Unadvise(uint cookie);
        void SetOperationFlags(uint flags);
        void SetProgressMessage([MarshalAs(UnmanagedType.LPWStr)] string message);
        void SetProgressDialog(IntPtr dialog);
        void SetProperties(IntPtr properties);
        void SetOwnerWindow(IntPtr window);
        void ApplyPropertiesToItem(IShellItem item);
        void ApplyPropertiesToItems(IntPtr items);
        void RenameItem(IShellItem item, [MarshalAs(UnmanagedType.LPWStr)] string name, IFileOperationProgressSink sink);
        void RenameItems(IntPtr items, [MarshalAs(UnmanagedType.LPWStr)] string name);
        void MoveItem(IShellItem item, IShellItem destination, [MarshalAs(UnmanagedType.LPWStr)] string name, IFileOperationProgressSink sink);
        void MoveItems(IntPtr items, IShellItem destination);
        void CopyItem(IShellItem item, IShellItem destination, [MarshalAs(UnmanagedType.LPWStr)] string name, IFileOperationProgressSink sink);
        void CopyItems(IntPtr items, IShellItem destination);
        void DeleteItem(IShellItem item, IFileOperationProgressSink sink);
        void DeleteItems(IntPtr items);
        void NewItem(IShellItem destination, uint attributes, [MarshalAs(UnmanagedType.LPWStr)] string name, [MarshalAs(UnmanagedType.LPWStr)] string template, IFileOperationProgressSink sink);
        void PerformOperations();
        void GetAnyOperationsAborted([MarshalAs(UnmanagedType.Bool)] out bool aborted);
    }

    [ComVisible(true), Guid("04b0f1a7-9490-44bc-96e1-4296a31252e2"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    private interface IFileOperationProgressSink
    {
        [PreserveSig] int StartOperations();
        [PreserveSig] int FinishOperations(int result);
        [PreserveSig] int PreRenameItem(uint flags, IShellItem item, [MarshalAs(UnmanagedType.LPWStr)] string name);
        [PreserveSig] int PostRenameItem(uint flags, IShellItem item, [MarshalAs(UnmanagedType.LPWStr)] string name, int result, IShellItem? created);
        [PreserveSig] int PreMoveItem(uint flags, IShellItem item, IShellItem destination, [MarshalAs(UnmanagedType.LPWStr)] string name);
        [PreserveSig] int PostMoveItem(uint flags, IShellItem item, IShellItem destination, [MarshalAs(UnmanagedType.LPWStr)] string name, int result, IShellItem? created);
        [PreserveSig] int PreCopyItem(uint flags, IShellItem item, IShellItem destination, [MarshalAs(UnmanagedType.LPWStr)] string name);
        [PreserveSig] int PostCopyItem(uint flags, IShellItem item, IShellItem destination, [MarshalAs(UnmanagedType.LPWStr)] string name, int result, IShellItem? created);
        [PreserveSig] int PreDeleteItem(uint flags, IShellItem item);
        [PreserveSig] int PostDeleteItem(uint flags, IShellItem item, int result, IShellItem? recycled);
        [PreserveSig] int PreNewItem(uint flags, IShellItem destination, [MarshalAs(UnmanagedType.LPWStr)] string name);
        [PreserveSig] int PostNewItem(uint flags, IShellItem destination, [MarshalAs(UnmanagedType.LPWStr)] string name, [MarshalAs(UnmanagedType.LPWStr)] string template, uint attributes, int result, IShellItem? created);
        [PreserveSig] int UpdateProgress(uint total, uint completed);
        [PreserveSig] int ResetTimer();
        [PreserveSig] int PauseTimer();
        [PreserveSig] int ResumeTimer();
    }
}
