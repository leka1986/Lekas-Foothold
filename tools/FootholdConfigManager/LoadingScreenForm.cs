using System.Drawing.Drawing2D;

namespace FootholdConfigManager;

internal sealed class LoadingScreenForm : Form
{
    internal Image LoadingIcon => _icon;
    private readonly Image _photo;
    private readonly Image _icon;
    private readonly Label _status;
    private readonly LoadingIndicator _progress;
    internal Rectangle PhotoSourceBounds { get; }
    internal event EventHandler? CancelRequested;

    public LoadingScreenForm(int pictureIndex)
    {
        var names = new[] { "apache-sunset-source.jpg", "apache-action-source.png", "carrier-launch-source.jpg" };
        if (pictureIndex is < 0 or > 2) throw new ArgumentOutOfRangeException(nameof(pictureIndex));
        _photo = LoadAsset(names[pictureIndex]);
        _icon = LoadAsset("foothold-manager-icon.png");
        var cropTop = pictureIndex == 0 ? 90 : pictureIndex == 1 ? 135 : 0;
        PhotoSourceBounds = new Rectangle(0, cropTop, _photo.Width, _photo.Height - cropTop);
        Text = "Loading · Foothold Config Manager";
        Name = "FootholdLoadingScreen";
        FormBorderStyle = FormBorderStyle.None;
        StartPosition = FormStartPosition.Manual;
        AutoScaleMode = AutoScaleMode.Dpi;
        AutoScaleDimensions = new SizeF(96, 96);
        DoubleBuffered = true;
        BackColor = Color.FromArgb(18, 25, 31);
        ForeColor = Color.White;
        Font = new Font("Segoe UI", 10);
        var header = new TableLayoutPanel { Dock = DockStyle.Top, AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink, MinimumSize = new Size(0, 76), ColumnCount = 2, RowCount = 1, Padding = new Padding(20, 10, 20, 10) };
        header.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 64));
        header.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        header.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        header.Controls.Add(new PictureBox { Image = _icon, Dock = DockStyle.Fill, SizeMode = PictureBoxSizeMode.Zoom }, 0, 0);
        var title = new Label { Text = "FOOTHOLD", AutoSize = true, Font = new Font("Segoe UI", 23, FontStyle.Bold), Margin = new Padding(10, 0, 0, 0) };
        var subtitle = new Label { Text = "CONFIG MANAGER", AutoSize = true, ForeColor = Color.FromArgb(212, 223, 228), Margin = new Padding(13, 0, 0, 0) };
        var titles = new FlowLayoutPanel { Dock = DockStyle.Fill, AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink, FlowDirection = FlowDirection.TopDown, WrapContents = false };
        titles.Controls.Add(title);
        titles.Controls.Add(subtitle);
        header.Controls.Add(titles, 1, 0);
        var footer = new TableLayoutPanel { Dock = DockStyle.Bottom, Height = 68, Padding = new Padding(20, 10, 20, 12), ColumnCount = 2, RowCount = 2 };
        footer.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        footer.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        footer.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        footer.RowStyles.Add(new RowStyle(SizeType.Absolute, 5));
        _status = new Label { Text = "Loading configuration…", Dock = DockStyle.Fill, AutoEllipsis = true, TextAlign = ContentAlignment.MiddleLeft };
        _progress = new LoadingIndicator { Dock = DockStyle.Fill, Margin = new Padding(0), AccessibleName = "Loading progress", AccessibleRole = AccessibleRole.ProgressBar };
        footer.Controls.Add(_status, 0, 0);
        footer.Controls.Add(new Label { Text = "By Leka", AutoSize = true, Anchor = AnchorStyles.Right | AnchorStyles.Bottom, ForeColor = Color.FromArgb(190, 202, 210), Margin = new Padding(18, 0, 0, 2) }, 1, 0);
        footer.Controls.Add(_progress, 0, 1);
        Controls.Add(header);
        Controls.Add(footer);
        Shown += (_, _) => FitToWorkArea();
        DpiChanged += (_, _) => FitToWorkArea();
        FormClosing += (_, args) => { args.Cancel = true; CancelRequested?.Invoke(this, EventArgs.Empty); };
        Disposed += (_, _) => { _photo.Dispose(); _icon.Dispose(); };
        FitToWorkArea();
    }

    private static Image LoadAsset(string name)
    {
        using var stream = typeof(LoadingScreenForm).Assembly.GetManifestResourceStream("FootholdConfigManager.Splash." + name)
            ?? throw new InvalidOperationException("Loading artwork is missing: " + name);
        using var image = Image.FromStream(stream);
        return new Bitmap(image);
    }

    private void FitToWorkArea()
    {
        var area = Owner is null ? Screen.FromPoint(Cursor.Position).WorkingArea : Screen.FromControl(Owner).WorkingArea;
        var scale = DeviceDpi / 96f;
        var width = Math.Min((int)(900 * scale), Math.Max(1, area.Width - (int)(40 * scale)));
        var height = Math.Min((int)(650 * scale), Math.Max(1, area.Height - (int)(40 * scale)));
        Bounds = new Rectangle(area.X + (area.Width - width) / 2, area.Y + (area.Height - height) / 2, width, height);
    }

    internal void Report(LoadingProgress progress)
    {
        _status.Text = progress.Stage;
        _progress.Report(progress);
        _status.Update();
        _progress.Update();
    }

    protected override void OnPaint(PaintEventArgs args)
    {
        base.OnPaint(args);
        var header = Controls[0].Height;
        var footer = Controls[1].Height;
        var available = new Rectangle(0, header, ClientSize.Width, Math.Max(1, ClientSize.Height - header - footer));
        var ratio = Math.Min((float)available.Width / PhotoSourceBounds.Width, (float)available.Height / PhotoSourceBounds.Height);
        var width = (int)(PhotoSourceBounds.Width * ratio);
        var height = (int)(PhotoSourceBounds.Height * ratio);
        var destination = new Rectangle((ClientSize.Width - width) / 2, available.Top + (available.Height - height) / 2, width, height);
        args.Graphics.InterpolationMode = InterpolationMode.HighQualityBicubic;
        args.Graphics.DrawImage(_photo, destination, PhotoSourceBounds, GraphicsUnit.Pixel);
    }

    private sealed class LoadingIndicator : Control
    {
        private readonly System.Windows.Forms.Timer _animation = new() { Interval = 50 };
        private int _phase;
        private int _completed;
        private int? _total;

        internal LoadingIndicator()
        {
            DoubleBuffered = true;
            BackColor = Color.FromArgb(28, 65, 68);
            _animation.Tick += (_, _) => { _phase = (_phase + Math.Max(1, DeviceDpi / 24)) % Math.Max(1, Width + Width / 4); Invalidate(); };
        }

        internal void Report(LoadingProgress progress)
        {
            _total = progress.Total is > 0 ? progress.Total : null;
            _completed = _total is { } total ? Math.Clamp(progress.Completed, 0, total) : 0;
            AccessibleDescription = _total is { } count ? _completed + " of " + count : "Working";
            _animation.Enabled = Visible && _total is null;
            Invalidate();
        }

        protected override void OnVisibleChanged(EventArgs args)
        {
            base.OnVisibleChanged(args);
            _animation.Enabled = Visible && _total is null;
        }

        protected override void OnPaint(PaintEventArgs args)
        {
            base.OnPaint(args);
            using var brush = new SolidBrush(Color.FromArgb(26, 201, 190));
            if (_total is { } total) args.Graphics.FillRectangle(brush, 0, 0, (int)((long)Width * _completed / total), Height);
            else args.Graphics.FillRectangle(brush, _phase - Width / 4, 0, Math.Max(1, Width / 4), Height);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing) _animation.Dispose();
            base.Dispose(disposing);
        }
    }
}

internal readonly record struct LoadingProgress(string Stage, int Completed = 0, int? Total = null);
