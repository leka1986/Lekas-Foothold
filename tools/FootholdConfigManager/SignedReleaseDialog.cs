#if !FOOTHOLD_USER_BUILD
using System.Diagnostics;

namespace FootholdConfigManager;

internal sealed class SignedReleaseDialog : Form
{
    private readonly ISignedReleaseService _service;
    private readonly string _projectDirectory;
    private readonly string _metadataJson;
    private readonly bool _persistJob;
    private readonly Func<SignedReleaseJob?> _loadLastJob;
    private readonly TextBox _versionBox = new() { Name = "ReleaseVersion", Text = "2.1.6", Dock = DockStyle.Fill };
    private readonly TextBox _outputBox = new() { Name = "ReleaseOutput", Dock = DockStyle.Fill };
    private readonly Label _stageLabel = new() { Name = "ReleaseStage", Text = "Check the one-time setup to get started.", AutoSize = true, Dock = DockStyle.Fill };
    private readonly Label _jobLabel = new() { Name = "ReleaseJob", AutoSize = true, Dock = DockStyle.Fill };
    private readonly TextBox _details = new() { Name = "ReleaseDetails", Multiline = true, ReadOnly = true, ScrollBars = ScrollBars.Vertical, Dock = DockStyle.Fill };
    private readonly ProgressBar _progress = new() { Name = "ReleaseProgress", Dock = DockStyle.Fill, Height = 7, Style = ProgressBarStyle.Continuous };
    private readonly Button _checkButton;
    private readonly Button _buildButton;
    private readonly Button _resumeButton;
    private readonly Button _publishButton;
    private readonly Button _stopButton;
    private readonly Button _openBuildButton;
    private readonly Button _openFolderButton;
    private CancellationTokenSource? _operation;
    private SignedReleaseJob? _job;
    private bool _setupReady;
    private bool _closeAfterOperation;
    private bool _published;
    private bool _verifiedReady;
    private Font _headingFont;
    private string? _runUrl;

    internal SignedReleaseDialog(string projectDirectory, string metadataJson,
        ISignedReleaseService? service = null, SignedReleaseJob? initialJob = null, Func<SignedReleaseJob?>? loadLastJob = null)
    {
        _projectDirectory = projectDirectory;
        _metadataJson = metadataJson;
        _service = service ?? new SignedReleaseService();
        _persistJob = service is null;
        _loadLastJob = loadLastJob ?? (_persistJob ? SignedReleaseService.LoadLastJob : () => null);
        Text = "Build signed Manager release";
        Name = "SignedReleaseDialog";
        StartPosition = FormStartPosition.CenterParent;
        AutoScaleMode = AutoScaleMode.Font;
        MinimumSize = new Size(650, 510);
        ClientSize = new Size(780, 590);
        MinimizeBox = false;
        ShowInTaskbar = false;
        _outputBox.Text = Path.Combine(RuntimeSettings.SettingsDirectory, "Signed releases");

        var scroll = new Panel { Name = "ReleaseScroll", Dock = DockStyle.Fill, AutoScroll = true };
        var root = new TableLayoutPanel { Name = "ReleaseLayout", Dock = DockStyle.Top, AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink, Padding = new Padding(18), ColumnCount = 1, RowCount = 10 };
        for (var i = 0; i < 10; i++) root.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        root.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        scroll.Controls.Add(root);
        Controls.Add(scroll);
        _headingFont = new Font(Font, FontStyle.Bold);
        var title = new Label { Text = "Build, approve, then publish", AutoSize = true, Dock = DockStyle.Fill, Font = _headingFont, Margin = new Padding(0, 0, 0, 8) };
        root.Controls.Add(title, 0, 0);
        var explanation = new Label
        {
            Text = "Build uploads only the Manager source and selected Designer settings to a new GitHub build branch. GitHub compiles and tests it; you approve signing in SignPath. Publishing the download is a separate step.",
            AutoSize = true, Dock = DockStyle.Fill, Margin = new Padding(0, 0, 0, 12)
        };
        root.Controls.Add(explanation, 0, 1);
        var inputs = new TableLayoutPanel { Dock = DockStyle.Fill, AutoSize = true, ColumnCount = 3, RowCount = 3, Margin = new Padding(0, 0, 0, 8) };
        inputs.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        inputs.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        inputs.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        inputs.Controls.Add(new Label { Text = "Release version", AutoSize = true, Anchor = AnchorStyles.Left, Margin = new Padding(0, 4, 12, 8) }, 0, 0);
        inputs.Controls.Add(_versionBox, 1, 0);
        inputs.SetColumnSpan(_versionBox, 2);
        inputs.Controls.Add(new Label { Text = "Save signed EXE to", AutoSize = true, Anchor = AnchorStyles.Left, Margin = new Padding(0, 4, 12, 8) }, 0, 1);
        inputs.Controls.Add(_outputBox, 1, 1);
        var browse = MakeButton("Browse…", "BrowseReleaseOutput");
        browse.Click += (_, _) =>
        {
            using var chooser = new FolderBrowserDialog { Description = "Choose where to save the verified signed Manager EXE", SelectedPath = _outputBox.Text, UseDescriptionForTitle = true };
            if (chooser.ShowDialog(this) == DialogResult.OK) _outputBox.Text = chooser.SelectedPath;
        };
        inputs.Controls.Add(browse, 2, 1);
        inputs.Controls.Add(new Label { Text = "Manager source", AutoSize = true, Anchor = AnchorStyles.Left, Margin = new Padding(0, 4, 12, 8) }, 0, 2);
        var sourcePath = new TextBox { Name = "ReleaseSource", Text = projectDirectory, ReadOnly = true, Dock = DockStyle.Fill };
        inputs.Controls.Add(sourcePath, 1, 2);
        inputs.SetColumnSpan(sourcePath, 2);
        root.Controls.Add(inputs, 0, 2);
        var actions = MakeFlow();
        _checkButton = MakeButton("Check setup", "CheckReleaseSetup");
        _buildButton = MakeButton("Build signed release", "StartSignedRelease");
        _resumeButton = MakeButton("Resume last build", "ResumeSignedRelease");
        _stopButton = MakeButton("Stop watching", "StopWatchingRelease");
        _checkButton.Click += async (_, _) => await CheckSetupAsync();
        _buildButton.Click += async (_, _) => await BuildReleaseAsync();
        _resumeButton.Click += async (_, _) => await ResumeReleaseAsync();
        _stopButton.Click += (_, _) => _operation?.Cancel();
        actions.Controls.AddRange(new Control[] { _checkButton, _buildButton, _resumeButton, _stopButton });
        root.Controls.Add(actions, 0, 3);
        _stageLabel.Margin = new Padding(0, 8, 0, 6);
        root.Controls.Add(_stageLabel, 0, 4);
        _progress.Margin = new Padding(0, 0, 0, 10);
        root.Controls.Add(_progress, 0, 5);
        _details.Height = 115;
        _details.MinimumSize = new Size(0, 105);
        root.Controls.Add(_details, 0, 6);
        _jobLabel.Margin = new Padding(0, 8, 0, 8);
        root.Controls.Add(_jobLabel, 0, 7);
        var links = MakeFlow();
        _openBuildButton = MakeButton("Open build", "OpenReleaseBuild");
        _openBuildButton.Click += (_, _) => OpenUrl(_runUrl);
        var signPath = MakeButton("Approve in SignPath", "OpenSignPathApproval");
        signPath.Click += (_, _) => OpenUrl("https://app.signpath.io/");
        _openFolderButton = MakeButton("Open output folder", "OpenReleaseOutput");
        _openFolderButton.Click += (_, _) =>
        {
            var folder = _job?.SignedExePath is { } file ? Path.GetDirectoryName(file)! : _outputBox.Text;
            if (Directory.Exists(folder)) Process.Start(new ProcessStartInfo(folder) { UseShellExecute = true });
        };
        var setupHelp = MakeButton("Setup instructions", "OpenReleaseSetup");
        setupHelp.Click += (_, _) =>
        {
            var guide = Path.Combine(_projectDirectory, "SIGNED_RELEASE_SETUP.md");
            _stageLabel.Text = "One-time setup instructions";
            _details.Text = File.Exists(guide) ? File.ReadAllText(guide) :
                "1. Apply at https://signpath.org/apply and wait for Foundation acceptance.\r\n" +
                "2. Install foothold-manager-signed.yml on the GitHub repository's default branch.\r\n" +
                "3. Configure the SignPath project/trusted GitHub build, allowed release branches and manual approval.\r\n" +
                "4. Add the repository SignPath variables and SIGNPATH_API_TOKEN secret, then click Check setup.\r\n" +
                "Build requests do not publish the EXE download. A verified result enables Publish download.";
        };
        links.Controls.AddRange(new Control[] { _openBuildButton, signPath, _openFolderButton, setupHelp });
        root.Controls.Add(links, 0, 8);
        var publication = MakeFlow();
        _publishButton = MakeButton("Publish download…", "PublishSignedRelease");
        _publishButton.Click += async (_, _) =>
        {
            if (_job is null) return;
            if (MessageBox.Show(this, "Publish the verified signed Manager " + _job.Version + " EXE to the existing GitHub download folder?", "Publish Manager download", MessageBoxButtons.OKCancel, MessageBoxIcon.Question) == DialogResult.OK)
                await PublishDownloadAsync();
        };
        var close = MakeButton("Close", "CloseSignedRelease");
        close.Click += (_, _) => Close();
        publication.Controls.AddRange(new Control[] { _publishButton, close });
        root.Controls.Add(publication, 0, 9);
        try { _job = initialJob ?? _loadLastJob(); }
        catch (Exception error) { AppendDetail("Last build could not be restored: " + error.Message); }
        if (_job is not null)
        {
            _versionBox.Text = _job.Version;
            _outputBox.Text = _job.OutputDirectory;
            if (_job.RunId > 0) _runUrl = BuildUrl(_job.RunId);
            _stageLabel.Text = "Last build restored. Resume to check its result.";
        }
        UpdateButtons();
        FontChanged += (_, _) =>
        {
            var previous = _headingFont;
            _headingFont = new Font(Font, FontStyle.Bold);
            title.Font = _headingFont;
            previous.Dispose();
        };
        void FitContent()
        {
            var width = Math.Max(260, scroll.ClientSize.Width - root.Padding.Horizontal - SystemInformation.VerticalScrollBarWidth);
            explanation.MaximumSize = _stageLabel.MaximumSize = _jobLabel.MaximumSize = new Size(width, 0);
            root.MaximumSize = new Size(Math.Max(300, scroll.ClientSize.Width - SystemInformation.VerticalScrollBarWidth), 0);
        }
        scroll.SizeChanged += (_, _) => FitContent();
        Shown += (_, _) => FitContent();
        FitContent();
    }

    internal bool IsBusy => _operation is not null;
    internal bool CanPublish => _publishButton.Enabled;
    internal string StageText => _stageLabel.Text;
    internal string DetailsText => _details.Text;
    internal SignedReleaseJob? Job => _job;

    internal Task CheckSetupAsync() => RunOperationAsync("Checking setup…", async token =>
    {
        _setupReady = false;
        var setup = await _service.CheckSetupAsync(token);
        _setupReady = setup.Ready;
        SetStatus(setup.Message);
        if (setup.LatestVersion is { } latest && ManagerBuildInfo.TryParseReleaseVersion(_versionBox.Text, out var selected) && selected <= latest)
            _versionBox.Text = new Version(latest.Major, latest.Minor, checked(latest.Build + 1)).ToString(3);
    });

    internal Task BuildReleaseAsync() => RunOperationAsync("Preparing release…", async token =>
    {
        if (!ManagerBuildInfo.TryParseReleaseVersion(_versionBox.Text, out var version) || version <= new Version(2, 1, 5, 0))
            throw new InvalidOperationException("Choose a numeric release version newer than 2.1.5, for example 2.1.6.");
        _job = null;
        _published = false;
        _verifiedReady = false;
        var request = new SignedReleaseRequest(_projectDirectory, _metadataJson, _versionBox.Text.Trim(), _outputBox.Text.Trim());
        _job = await _service.BuildAsync(request, CreateProgress(), token);
        AcceptResult();
    });

    internal Task ResumeReleaseAsync() => RunOperationAsync("Checking last build…", async token =>
    {
        if (_job is null) throw new InvalidOperationException("There is no release build to resume.");
        _verifiedReady = false;
        _job = await _service.ResumeAsync(_job, CreateProgress(), token);
        AcceptResult();
    });

    // The explicit Publish button performs the confirmation; tests call this operation with a fake service.
    internal Task PublishDownloadAsync() => RunOperationAsync("Publishing verified download…", async token =>
    {
        if (!_verifiedReady || _job?.SignedExePath is null || _job.SignedSha256 is null || _published)
            throw new InvalidOperationException("Build and verify a signed EXE before publishing it.");
        await _service.PublishAsync(_job, CreateProgress(), token);
        _published = true;
        SetStatus("Published Manager " + _job.Version + ". Players can discover it through the existing update check.");
    });

    private async Task RunOperationAsync(string status, Func<CancellationToken, Task> operation)
    {
        if (IsBusy || IsDisposed) return;
        using var cancellation = new CancellationTokenSource();
        _operation = cancellation;
        SetStatus(status);
        _progress.Style = ProgressBarStyle.Marquee;
        UpdateButtons();
        try { await operation(cancellation.Token); }
        catch (OperationCanceledException) when (cancellation.IsCancellationRequested)
        {
            RestoreSavedJob();
            SetStatus("Stopped watching. A build already started on GitHub can continue; use Resume last build.");
        }
        catch (Exception error)
        {
            RestoreSavedJob();
            SetStatus(error.Message);
        }
        finally
        {
            _operation = null;
            if (!IsDisposed)
            {
                _progress.Style = ProgressBarStyle.Continuous;
                UpdateButtons();
                if (_closeAfterOperation) Close();
            }
        }
    }

    private void RestoreSavedJob()
    {
        _verifiedReady = false;
        try
        {
            _job = _loadLastJob() ?? _job;
            if (_job is { RunId: > 0 }) _runUrl = BuildUrl(_job.RunId);
        }
        catch (Exception error) { AppendDetail("Last build status could not be restored: " + error.Message); }
    }

    private IProgress<SignedReleaseProgress> CreateProgress()
    {
        var operation = _operation;
        return new Progress<SignedReleaseProgress>(value =>
        {
            if (IsDisposed || Disposing || !ReferenceEquals(_operation, operation) || operation is null) return;
            if (value.RunUrl is { } url) _runUrl = url;
            SetStatus(value.Stage + ": " + value.Message);
            UpdateButtons();
        });
    }

    private void AcceptResult()
    {
        if (_job is null) throw new InvalidOperationException("GitHub did not return a release build.");
        _verifiedReady = _job.SignedExePath is not null && _job.SignedSha256 is not null;
        if (_persistJob) SignedReleaseService.SaveLastJob(_job);
        if (_job.RunId > 0) _runUrl = BuildUrl(_job.RunId);
        SetStatus(_job.SignedExePath is null ? "Build saved. Resume to check its result." : "Signed EXE verified and ready. Try it before publishing the download.");
    }

    private void SetStatus(string status)
    {
        if (IsDisposed) return;
        _stageLabel.Text = status;
        AppendDetail(status);
    }

    private void AppendDetail(string text)
    {
        if (IsDisposed) return;
        if (_details.TextLength > 24000) _details.Text = _details.Text[^12000..];
        _details.AppendText((_details.TextLength == 0 ? "" : Environment.NewLine) + text);
    }

    private void UpdateButtons()
    {
        var busy = IsBusy;
        _checkButton.Enabled = !busy;
        _buildButton.Enabled = !busy && _setupReady;
        _resumeButton.Enabled = !busy && _job is not null;
        _publishButton.Enabled = !busy && _verifiedReady && !_published && _job?.SignedExePath is not null && _job.SignedSha256 is not null;
        _stopButton.Enabled = busy;
        _versionBox.ReadOnly = _outputBox.ReadOnly = busy;
        _openBuildButton.Enabled = _runUrl is not null;
        _openFolderButton.Enabled = _job?.SignedExePath is not null;
        _jobLabel.Text = _job is null ? "No download is published by Build signed release." : "Manager " + _job.Version + " · " + _job.CommitSha[..Math.Min(12, _job.CommitSha.Length)] + (_job.RunId > 0 ? " · GitHub run " + _job.RunId : "");
    }

    protected override void OnFormClosing(FormClosingEventArgs e)
    {
        if (IsBusy)
        {
            _closeAfterOperation = true;
            _operation!.Cancel();
            e.Cancel = true;
            SetStatus("Stopping local work before closing…");
        }
        base.OnFormClosing(e);
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing)
        {
            _operation?.Cancel();
            _headingFont.Dispose();
        }
        base.Dispose(disposing);
    }

    private void OpenUrl(string? value)
    {
        if (value is null || !Uri.TryCreate(value, UriKind.Absolute, out var uri) || uri.Scheme != "https" ||
            !(uri.Host == "app.signpath.io" || uri.Host == "signpath.org" ||
              uri.Host == "github.com" && uri.AbsolutePath.StartsWith("/leka1986/Lekas-Foothold/actions/runs/", StringComparison.Ordinal)))
        {
            SetStatus("No verified build link is available yet.");
            return;
        }
        Process.Start(new ProcessStartInfo(uri.AbsoluteUri) { UseShellExecute = true });
    }

    private static string BuildUrl(long runId) => "https://github.com/leka1986/Lekas-Foothold/actions/runs/" + runId;
    private static FlowLayoutPanel MakeFlow() => new() { Dock = DockStyle.Fill, AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink, WrapContents = true, Margin = new Padding(0, 5, 0, 5) };
    private static Button MakeButton(string text, string name) => new() { Name = name, Text = text, AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink, MinimumSize = new Size(100, 31), Margin = new Padding(0, 0, 8, 5), Dock = DockStyle.None };
}
#endif