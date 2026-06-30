using System.Drawing;
using System.Globalization;
using System.IO.Compression;
using System.Text.RegularExpressions;
using System.Text.Json;
using System.Windows.Forms;

namespace FootholdConfigManager;

internal sealed class MainForm : Form
{
    private const string AdminPassword = "configfoothold";
    private const string DiscordInviteUrl = "https://discord.gg/cshgmgXuxE";
    private const string GitHubRepositoryUrl = "https://github.com/leka1986/Lekas-Foothold";
    private const int TableActionColumnWidth = 168;
    private const int TableActionButtonWidth = 148;
    private const float BaseFontSize = 9F;
    private const string ToolbarSeparatorTag = "ToolbarSeparator";
    private const string AboutLinkTag = "AboutLink";
    private const string ImportedNewHighlightTag = "ImportedNewHighlight";
    private const string ImportedNewBadgeTag = "ImportedNewBadge";
    private static readonly JsonSerializerOptions StoredDefaultsJsonOptions = new() { WriteIndented = true };
    private static string StoredDefaultsDirectory => Path.Combine(RuntimeSettings.SettingsDirectory, "MizDefaults");
    private static string StoredDefaultsIndexPath => Path.Combine(StoredDefaultsDirectory, "index.json");
    private static Color MainBackground = Color.FromArgb(221, 229, 234);
    private static Color EditorBackground = Color.FromArgb(238, 243, 246);
    private static Color InputBackground = Color.FromArgb(248, 251, 253);
    private static Color PrimaryTextColor = Color.FromArgb(17, 24, 39);
    private static Color HelpTextColor = Color.FromArgb(61, 75, 89);
    private static Color BorderColor = Color.FromArgb(134, 151, 166);
    private static Color ButtonBackground = Color.FromArgb(236, 242, 246);
    private static Color HeaderBackground = Color.FromArgb(207, 220, 229);
    private static Color SelectionBackground = Color.FromArgb(36, 71, 102);
    private static Color SelectionText = Color.White;
    private static Color UndoBackground = Color.FromArgb(244, 232, 203);
    private static Color UndoMutedBorder = Color.FromArgb(176, 128, 48);
    private static Color UndoMutedText = Color.FromArgb(102, 75, 30);
    private static Color SavePendingBackground = Color.FromArgb(218, 235, 249);
    private static Color SavePendingHoverBackground = Color.FromArgb(202, 226, 246);
    private static Color SavePendingBorder = Color.FromArgb(30, 115, 216);
    private static Color BrandColor = Color.FromArgb(30, 136, 183);

    private sealed record UndoStep(
        string Description,
        Action Action,
        Action? RefreshAction,
        string? CollapseKey = null,
        string? BeforeValue = null,
        string? AfterValue = null,
        int CollapseGeneration = 0);
    private sealed record StringListBucketItem(string Value, ConfigStringListItem? Item, bool IsActive, bool CatalogOnly);
    private sealed record ImportedNewEntryMarker(string Category, string DisplayKey);
    private sealed record ConfigVariantItem(string Label, string Path)
    {
        public override string ToString()
        {
            return Label;
        }
    }

    private enum MissingInstanceRecoveryKind
    {
        Cancel,
        SelectPath,
        Remove
    }

    private sealed record MissingInstanceRecovery(MissingInstanceRecoveryKind Kind, string? Path);

    private sealed record ExtractedMizConfig(string Path, string ConfigFileName);

    private sealed record FirstRunMizCandidate(string Path, DateTime Modified)
    {
        public override string ToString()
        {
            return Modified.ToString("yyyy-MM-dd HH:mm", CultureInfo.InvariantCulture) + "  " + System.IO.Path.GetFileName(Path);
        }
    }

    private sealed record FirstRunInstanceCandidate(string Name, string ProfilePath, int Score)
    {
        public string SavesPath => System.IO.Path.Combine(ProfilePath, "Missions", "Saves");
        public string ConfigPath => ConfigPathFor(RuntimeSettings.DefaultConfigFileName);

        public string ConfigPathFor(string configFileName)
        {
            return System.IO.Path.Combine(SavesPath, configFileName);
        }

        public override string ToString()
        {
            return Name + "  ->  " + SavesPath;
        }
    }

    private enum DcsDesanitizeStatus
    {
        FileNotSelected,
        FileMissing,
        NotDesanitized,
        PartiallyDesanitized,
        Desanitized,
        UnknownFormat
    }

    private enum ToolbarIconKind
    {
        Open,
        Reload,
        Validate,
        Import,
        Install,
        Restore,
        Undo,
        Save
    }

    private sealed class ToolbarIconButton : Control
    {
        private bool _hover;
        private bool _pressed;

        public ToolbarIconButton(ToolbarIconKind iconKind)
        {
            IconKind = iconKind;
            TabStop = true;
            SetStyle(
                ControlStyles.UserPaint |
                ControlStyles.AllPaintingInWmPaint |
                ControlStyles.OptimizedDoubleBuffer |
                ControlStyles.ResizeRedraw |
                ControlStyles.Selectable,
                true);
        }

        public ToolbarIconKind IconKind { get; }

        public Color NormalBackColor { get; set; }
        public Color NormalBorderColor { get; set; }
        public Color HoverBackColor { get; set; }
        public Color HoverBorderColor { get; set; }
        public Color PressedBackColor { get; set; }

        protected override void OnMouseEnter(EventArgs e)
        {
            _hover = true;
            Cursor = Cursors.Hand;
            Invalidate();
            base.OnMouseEnter(e);
        }

        protected override void OnMouseLeave(EventArgs e)
        {
            _hover = false;
            _pressed = false;
            Invalidate();
            base.OnMouseLeave(e);
        }

        protected override void OnMouseDown(MouseEventArgs mevent)
        {
            if (mevent.Button == MouseButtons.Left)
            {
                _pressed = true;
                Invalidate();
            }

            base.OnMouseDown(mevent);
        }

        protected override void OnMouseUp(MouseEventArgs mevent)
        {
            _pressed = false;
            Invalidate();
            base.OnMouseUp(mevent);
        }

        protected override void OnEnabledChanged(EventArgs e)
        {
            _hover = false;
            _pressed = false;
            Cursor = Enabled ? Cursors.Hand : Cursors.Default;
            Invalidate();
            base.OnEnabledChanged(e);
        }

        protected override void OnKeyDown(KeyEventArgs e)
        {
            if (Enabled && (e.KeyCode == Keys.Enter || e.KeyCode == Keys.Space))
            {
                OnClick(EventArgs.Empty);
                e.Handled = true;
            }

            base.OnKeyDown(e);
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            var bounds = ClientRectangle;
            if (bounds.Width <= 0 || bounds.Height <= 0)
            {
                return;
            }

            var darkPalette = IsDarkPalette();
            var hoverBackColor = HoverBackColor.IsEmpty ? HeaderBackground : HoverBackColor;
            var pressedBackColor = PressedBackColor.IsEmpty ? SelectionBackground : PressedBackColor;
            var fillColor = Enabled
                ? darkPalette
                    ? (_pressed ? pressedBackColor : _hover ? hoverBackColor : NormalBackColor)
                    : (_pressed ? pressedBackColor : _hover ? hoverBackColor : NormalBackColor)
                : ButtonBackground;
            var textColor = Enabled ? ForeColor : HelpTextColor;

            e.Graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
            e.Graphics.TextRenderingHint = System.Drawing.Text.TextRenderingHint.ClearTypeGridFit;

            using var fill = new SolidBrush(fillColor);
            e.Graphics.FillRectangle(fill, bounds);
            var borderColor = Enabled && (_hover || _pressed)
                ? HoverBorderColor.IsEmpty ? BrandColor : HoverBorderColor
                : NormalBorderColor.IsEmpty ? BorderColor : NormalBorderColor;
            using var border = new Pen(borderColor, _pressed ? 2 : 1);
            e.Graphics.DrawRectangle(border, bounds.X, bounds.Y, bounds.Width - 1, bounds.Height - 1);

            var undoIcon = IconKind == ToolbarIconKind.Undo;
            var iconSize = undoIcon
                ? Math.Min(22, Math.Max(18, bounds.Height - 10))
                : Math.Min(17, Math.Max(13, bounds.Height - 16));
            var textGap = undoIcon ? Math.Max(7, bounds.Height / 5) : 5;
            var textPadding = undoIcon ? Math.Max(7, bounds.Height / 5) : 14;
            var measuredText = TextRenderer.MeasureText(Text, Font, new Size(int.MaxValue, bounds.Height), TextFormatFlags.SingleLine | TextFormatFlags.NoPadding);
            var contentWidth = iconSize + textGap + measuredText.Width;
            var iconX = undoIcon
                ? bounds.X + Math.Max(textPadding, (bounds.Width - contentWidth) / 2)
                : bounds.X + 6;
            var iconY = bounds.Y + Math.Max(0, (bounds.Height - iconSize) / 2);
            var iconBounds = new Rectangle(iconX, iconY, iconSize, iconSize);
            DrawToolbarIcon(e.Graphics, IconKind, iconBounds, textColor);

            var textX = iconX + iconSize + textGap;
            var rightPadding = undoIcon ? textPadding : 14;
            var textBounds = new Rectangle(
                textX,
                bounds.Y,
                Math.Max(0, bounds.Right - rightPadding - textX),
                bounds.Height);
            TextRenderer.DrawText(
                e.Graphics,
                Text,
                Font,
                textBounds,
                textColor,
                TextFormatFlags.SingleLine |
                TextFormatFlags.VerticalCenter |
                TextFormatFlags.EndEllipsis |
                TextFormatFlags.NoPadding |
                TextFormatFlags.NoPrefix);
        }
    }

    private sealed class EditorLockRule
    {
        public EditorLockRule(string targetKey, string sourceKey, string reason, params string[] lockedSourceValues)
        {
            TargetKey = targetKey;
            SourceKey = sourceKey;
            Reason = reason;
            LockedSourceValues = lockedSourceValues;
        }

        public string TargetKey { get; }
        public string SourceKey { get; }
        public string Reason { get; }
        public IReadOnlyList<string> LockedSourceValues { get; }

        public bool IsLockedBy(ConfigEntry? source)
        {
            return source is not null &&
                   LockedSourceValues.Any(value => source.ValueText.Equals(value, StringComparison.OrdinalIgnoreCase));
        }
    }

    // Add future "lock this editor/table when that setting is true/false/value" rules here.
    // Future category-panel cache work should dirty the TargetKey category when SourceKey changes.
    private static readonly EditorLockRule[] EditorLockRules =
    {
        new("UseC130LoadAndUnload", "WarehouseLogistics", "Locked while Warehouse Logistics is enabled.", "true"),
        new("AllowedToCarrySupplies", "WarehouseLogistics", "Locked while Warehouse Logistics is enabled.", "true"),
        new("AllowMods", "Era", "Locked while Era is Gulfwar or Coldwar.", "Gulfwar", "Coldwar"),
        new("ChanceAiAttackHelo", "InvisibleA10", "Locked while Invisible A10 is enabled.", "true")
    };

    private sealed class SmoothDataGridView : DataGridView
    {
        public SmoothDataGridView()
        {
            DoubleBuffered = true;
        }
    }

    private sealed class BackgroundFocusPanel : Panel
    {
        public BackgroundFocusPanel()
        {
            SetStyle(ControlStyles.Selectable, true);
            TabStop = false;
        }
    }

    private sealed class ThemeIconButton : Control
    {
        private readonly System.Windows.Forms.Timer _animationTimer = new() { Interval = 15 };
        private bool _darkMode;
        private bool _hover;
        private bool _pressed;
        private float _animationProgress = 1F;

        public ThemeIconButton()
        {
            SetStyle(ControlStyles.AllPaintingInWmPaint |
                     ControlStyles.OptimizedDoubleBuffer |
                     ControlStyles.ResizeRedraw |
                     ControlStyles.Selectable |
                     ControlStyles.UserPaint, true);
            Cursor = Cursors.Hand;
            TabStop = true;
            _animationTimer.Tick += (_, _) =>
            {
                _animationProgress = Math.Min(1F, _animationProgress + 0.12F);
                if (_animationProgress >= 1F)
                {
                    _animationTimer.Stop();
                }

                Invalidate();
            };
        }

        public void SetDarkMode(bool darkMode)
        {
            if (_darkMode != darkMode)
            {
                _darkMode = darkMode;
                _animationProgress = 0F;
                _animationTimer.Start();
            }

            Invalidate();
        }

        protected override void OnMouseEnter(EventArgs e)
        {
            _hover = true;
            Invalidate();
            base.OnMouseEnter(e);
        }

        protected override void OnMouseLeave(EventArgs e)
        {
            _hover = false;
            _pressed = false;
            Invalidate();
            base.OnMouseLeave(e);
        }

        protected override void OnMouseDown(MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left)
            {
                _pressed = true;
                Invalidate();
            }

            base.OnMouseDown(e);
        }

        protected override void OnMouseUp(MouseEventArgs e)
        {
            _pressed = false;
            Invalidate();
            base.OnMouseUp(e);
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            base.OnPaint(e);
            var g = e.Graphics;
            g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
            using var background = new SolidBrush(_pressed ? SelectionBackground : _hover ? HeaderBackground : ButtonBackground);
            using var border = new Pen(BorderColor);
            var buttonBounds = new Rectangle(1, 1, Width - 3, Height - 3);
            g.FillRectangle(background, buttonBounds);
            g.DrawRectangle(border, buttonBounds);

            var size = Math.Max(12, Math.Min(Width, Height) - 12);
            var cx = Width / 2F;
            var cy = Height / 2F;
            var pulse = (float)Math.Sin(_animationProgress * Math.PI);
            var angle = _animationProgress * 180F;
            g.TranslateTransform(cx, cy);
            g.RotateTransform(angle);
            g.ScaleTransform(1F + pulse * 0.08F, 1F + pulse * 0.08F);

            if (_darkMode)
            {
                DrawMoon(g, size);
            }
            else
            {
                DrawSun(g, size);
            }

            g.ResetTransform();
        }

        private static void DrawSun(Graphics g, int size)
        {
            using var icon = new Pen(Color.FromArgb(245, 174, 66), 2F);
            using var fill = new SolidBrush(Color.FromArgb(255, 207, 94));
            var radius = size / 4F;
            var outer = size / 2F - 1F;
            g.FillEllipse(fill, -radius, -radius, radius * 2F, radius * 2F);
            g.DrawEllipse(icon, -radius, -radius, radius * 2F, radius * 2F);

            for (var i = 0; i < 8; i++)
            {
                var a = i * Math.PI / 4D;
                var x1 = (float)Math.Cos(a) * (radius + 3F);
                var y1 = (float)Math.Sin(a) * (radius + 3F);
                var x2 = (float)Math.Cos(a) * outer;
                var y2 = (float)Math.Sin(a) * outer;
                g.DrawLine(icon, x1, y1, x2, y2);
            }
        }

        private static void DrawMoon(Graphics g, int size)
        {
            using var moon = new SolidBrush(Color.FromArgb(188, 210, 255));
            using var cutout = new SolidBrush(ButtonBackground);
            var radius = size / 2F - 2F;
            g.FillEllipse(moon, -radius, -radius, radius * 2F, radius * 2F);
            g.FillEllipse(cutout, -radius / 4F, -radius - 1F, radius * 2F, radius * 2F);
        }
    }

    private sealed class CategorySpec
    {
        public CategorySpec(string name, params string[] keys)
        {
            Name = name;
            Keys = keys.ToList();
        }

        public string Name { get; }
        public List<string> Keys { get; }
    }

    private sealed class DesignerItem
    {
        public DesignerItem(
            string key,
            string label,
            string category,
            bool isGroup,
            List<ConfigEntry> entries,
            ConfigStringListTable? stringListTable = null,
            ConfigStageTable? stageTable = null)
        {
            Key = key;
            Label = label;
            Category = category;
            IsGroup = isGroup;
            Entries = entries;
            StringListTable = stringListTable;
            StageTable = stageTable;
        }

        public string Key { get; }
        public string Label { get; }
        public string Category { get; }
        public bool IsGroup { get; }
        public List<ConfigEntry> Entries { get; }
        public ConfigStringListTable? StringListTable { get; }
        public ConfigStageTable? StageTable { get; }

        public override string ToString()
        {
            return Label;
        }
    }

    private sealed class CategoryOrderItem
    {
        public CategoryOrderItem(string name, bool hidden, string label)
        {
            Name = name;
            Hidden = hidden;
            Label = string.IsNullOrWhiteSpace(label) ? name : label;
        }

        public string Name { get; }
        public bool Hidden { get; set; }
        public string Label { get; }

        public override string ToString()
        {
            return Hidden ? Label + " (hidden)" : Label;
        }
    }

    private sealed class CategoryListItem
    {
        public CategoryListItem(string name, string label)
        {
            Name = name;
            Label = string.IsNullOrWhiteSpace(label) ? name : label;
        }

        public string Name { get; }
        public string Label { get; }

        public override string ToString()
        {
            return Label;
        }
    }

    private sealed class StageTableItem
    {
        public StageTableItem(ConfigStageTable table)
        {
            Table = table;
        }

        public ConfigStageTable Table { get; }

        public override string ToString()
        {
            return Table.GuiLabel ?? GetDefaultGroupLabel(Table.Key);
        }
    }

    private sealed record StageDifficultyButtonTag(string TableKey, string Difficulty);

    private sealed class InstanceItem
    {
        public InstanceItem(ServerProfileSettings profile)
        {
            Profile = profile;
        }

        public ServerProfileSettings Profile { get; }

        public override string ToString()
        {
            return Profile.Name;
        }
    }

    private sealed class CopyTargetItem
    {
        public CopyTargetItem(ServerProfileSettings profile)
        {
            Profile = profile;
        }

        public ServerProfileSettings Profile { get; }

        public override string ToString()
        {
            return Profile.Name + "  " + Profile.ConfigPath;
        }
    }

    private enum CopyChangeKind
    {
        Entry,
        Table
    }

    private sealed class CopyChange
    {
        public CopyChange(CopyChangeKind kind, string key, string label, string summary, string currentText, string sourceText)
        {
            Kind = kind;
            Key = key;
            Label = label;
            Summary = summary;
            CurrentText = currentText;
            SourceText = sourceText;
            Id = kind.ToString() + ":" + key;
        }

        public CopyChangeKind Kind { get; }
        public string Key { get; }
        public string Label { get; }
        public string Summary { get; }
        public string CurrentText { get; }
        public string SourceText { get; }
        public string Id { get; }
    }

    private sealed class RestoreDefaultItem
    {
        public RestoreDefaultItem(CopyChangeKind kind, string key, string label, string category, string summary, int order, bool isChanged)
        {
            Kind = kind;
            Key = key;
            Label = label;
            Category = category;
            Summary = summary;
            Order = order;
            IsChanged = isChanged;
            Id = kind.ToString() + ":" + key;
        }

        public CopyChangeKind Kind { get; }
        public string Key { get; }
        public string Label { get; }
        public string Category { get; }
        public string Summary { get; }
        public int Order { get; }
        public bool IsChanged { get; }
        public string Id { get; }
    }

    private sealed class RestoreDefaultsSelection
    {
        public RestoreDefaultsSelection(StoredMizDefaultsInfo defaults, List<RestoreDefaultItem> selectedItems)
        {
            Defaults = defaults;
            SelectedItems = selectedItems;
        }

        public StoredMizDefaultsInfo Defaults { get; }
        public List<RestoreDefaultItem> SelectedItems { get; }
    }

    private sealed class CopyTargetPlan
    {
        public CopyTargetPlan(ServerProfileSettings profile, string targetPath, List<CopyChange> changes, string? loadError = null, bool contentMatches = true)
        {
            Profile = profile;
            TargetPath = targetPath;
            Changes = changes;
            LoadError = loadError;
            ContentMatches = contentMatches;
            SelectedChangeIds = changes.Select(change => change.Id).ToHashSet(StringComparer.Ordinal);
            IsTargetSelected = loadError is null;
        }

        public ServerProfileSettings Profile { get; }
        public string TargetPath { get; }
        public List<CopyChange> Changes { get; }
        public HashSet<string> SelectedChangeIds { get; }
        public string? LoadError { get; }
        public bool ContentMatches { get; }
        public bool IsTargetSelected { get; set; }
        public bool IsExpanded { get; set; }

        public int SelectedChangeCount => Changes.Count(change => SelectedChangeIds.Contains(change.Id));
    }

    private sealed class MizMergePreview
    {
        public List<MizKeptValue> KeptValues { get; } = new();
        public List<ConfigEntry> NewEntries { get; } = new();
        public List<(string Table, int ItemCount)> KeptStringListTables { get; } = new();
        public List<MizKeptTableBlock> KeptTableBlocks { get; } = new();
        public List<(string Key, string Value)> PreservedTableRows { get; } = new();
        public List<(string Table, string Value)> PreservedListItems { get; } = new();
        public List<(string Key, string Value)> SkippedOldValues { get; } = new();
        public int UnchangedCount { get; set; }
    }

    private sealed class StoredMizDefaultsIndex
    {
        public List<StoredMizDefaultsInfo> Items { get; set; } = new();
    }

    private sealed class StoredMizDefaultsInfo
    {
        public string Id { get; set; } = "";
        public string SourceKind { get; set; } = "miz";
        public string MizName { get; set; } = "";
        public string MizPath { get; set; } = "";
        public string ConfigFileName { get; set; } = RuntimeSettings.DefaultConfigFileName;
        public string ConfigPath { get; set; } = "";
        public DateTime StoredAt { get; set; }
    }

    private sealed class MizKeptValue
    {
        public MizKeptValue(ConfigEntry entry, string currentValue, string newDefault)
        {
            Entry = entry;
            Key = entry.DisplayKey;
            CurrentValue = currentValue;
            NewDefault = newDefault;
        }

        public ConfigEntry Entry { get; }
        public string Key { get; }
        public string CurrentValue { get; }
        public string NewDefault { get; }
    }

    private sealed class MizKeptTableBlock
    {
        public MizKeptTableBlock(string key, string currentBlock, string newDefaultBlock, int currentItemCount, int newDefaultItemCount)
        {
            Key = key;
            CurrentBlock = currentBlock;
            NewDefaultBlock = newDefaultBlock;
            CurrentItemCount = currentItemCount;
            NewDefaultItemCount = newDefaultItemCount;
        }

        public string Key { get; }
        public string CurrentBlock { get; }
        public string NewDefaultBlock { get; }
        public int CurrentItemCount { get; }
        public int NewDefaultItemCount { get; }
    }

    private sealed class SelectableValueChoice
    {
        public SelectableValueChoice(string key, string selectedValue, string otherValue, string helpText)
        {
            Key = key;
            SelectedValue = selectedValue;
            OtherValue = otherValue;
            HelpText = helpText;
        }

        public string Key { get; }
        public string SelectedValue { get; }
        public string OtherValue { get; }
        public string HelpText { get; }
        public bool Selected { get; set; } = true;
    }

    private readonly List<CategorySpec> _categories = new()
    {
        new CategorySpec("Basic Setup",
            "FootholdLocale",
            "Era",
            "StartNormal",
            "AutoRestart",
            "NoSA10AndSA11",
            "NoTorM2AndPantsir",
            "NoSA15",
            "DisableMantis",
            "UseStatics",
            "PVE_Only",
            "Allow_Red_CTLD",
            "AllowMods",
            "CreditLosewhenKilled",
            "CreditLosewhenKilledAmount",
            "RankLoseWhenKilled",
            "RankLoseWhenKilledAmount",
            "SplashDamage",
            "ShowKills",
            "StoreLimit",
            "RankingSystem",
            "FriendlyFireRankPenalty",
            "InvisibleA10",
            "CarrierRankRequirement",
            "AllowTarawaToMoveFreely"),
        new CategorySpec("Message Of The Day",
            "MessageOfTheDay.enabled",
            "MessageOfTheDay.durationSec",
            "MessageOfTheDay.intervalSec",
            "MessageOfTheDay.text"),
        new CategorySpec("Welcome Message settings",
            "CallsignOverrides"),
        new CategorySpec("Difficulty",
            "GlobalSettings.difficultyScaling",
            "GlobalSettings.supplyDifficultyScaling",
            "CapDifficulty",
            "CasDifficulty",
            "SeadDifficulty",
            "RunwayStrikeDifficulty",
            "FriendlyCapSupport",
            "FriendlyCasSupport",
            "FriendlySeadSupport",
            "AiPlaneSkill",
            "AiGroundSkill",
            "HideSAMOnMFD",
            "RedReactiveDifficulty"),
        new CategorySpec("Difficulty Stages",
            "CapLimitStages",
            "RedCasLimitStages",
            "RedSeadLimitStages",
            "RedRunwayStrikeLimitStages",
            "BlueCapSupportStages",
            "BlueCasSupportStages",
            "BlueSeadSupportStages"),
        new CategorySpec("Escort",
            "EscortTypeByPlayerType",
            "EscortTakeoffFromGround"),
        new CategorySpec("Logistics / Warehouse",
            "WarehouseLogistics",
            "UseC130LoadAndUnload",
            "AIDeliveryamount",
            "SuppliesCargoTransport",
            "StrictSmartWeaponsInventory",
            "WarehouseWeaponCaps",
            "AutoFillResources",
            "NoAIBlueSupplies",
            "WarningNoSupplies"),
        new CategorySpec("Shop / Rewards",
            "AllowAdminBuy",
            "RewardContribution",
            "RefuelReward",
            "ShopPrices",
            "ShopRankRequirements",
            "AIAttackTakeoffFromGround",
            "AIAttackTakeoffFromGroundExtraNM",
            "AllowScriptedSupplies"),
        new CategorySpec("Flight Time",
            "RewardFlightTime",
            "FlightTimeRewardPerMinute",
            "RewardAllAircraft",
            "AllowedFlightTimeReward"),
        new CategorySpec("CTLD",
            "CTLDCost",
            "CTLDPrices",
            "CaptureZoneWithEngineer",
            "CTLDUnitCapabilities",
            "MAX_AT_SPAWN",
            "MAX_SAVED_FARPS",
            "IRIS_RESTORE_UNIT_HEALTH_ON_MERGE"),
        new CategorySpec("CSAR",
            "AllowedCsar",
            "CsarPilotSpawnWithoutCreditsChance",
            "Max_CSAR_At_Once",
            "Max_CSAR_AT_Mission_Restart",
            "PilotWeight",
            "CsarHoverDistance",
            "CsarGuidanceDistance",
            "CsarHoverHeight",
            "CsarHoverSeconds",
            "CsarHostileInfantryChance"),
        new CategorySpec("Tankers",
            "TexacoSpeed",
            "ArcoSpeed"),
        new CategorySpec("EWRS",
            "ewrs_maxRangeKm",
            "ewrs_maxRangeNm",
            "ewrs_defaultAircraftRangeLimit",
            "ewrs_defaultHelicopterRangeLimit",
            "ewrs_messageUpdateInterval",
            "ewrs_messageDisplayTime",
            "ewrs_restrictToOneReference",
            "ewrs_defaultReference",
            "ewrs_defaultMeasurements",
            "ewrs_defaultShowTankers",
            "ewrs_enableRedTeam",
            "ewrs_enableBlueTeam",
            "ewrs_disableMessageWhenNoThreats",
            "ewrs_onDemand",
            "ewrs_maxThreatDisplay",
            "ewrs_allowBogeyDope",
            "ewrs_allowFriendlyPicture",
            "ewrs_maxFriendlyDisplay",
            "ewrs_showType",
            "ewrs_hiddenFriendlyReportingNames",
            "ewrs_specialPlaneTypes"),
        new CategorySpec("AIEN",
            "AIEN.config.dontInitialize",
            "AIEN.config.blueAI",
            "AIEN.config.redAI",
            "AIEN.config.dismount",
            "AIEN.config.message_feed",
            "AIEN.config.initiative"),
        new CategorySpec("Aircraft / Weapons",
            "allowedPlanes",
            "allowedPlanesRed",
            "restockAircraft",
            "restrictedWeapons",
            "ForbiddWeaponsInAllEra"),
        new CategorySpec("Admin Designer"),
        new CategorySpec("Raw Values")
    };

    private readonly TextBox _pathBox = new();
    private readonly ComboBox _instanceBox = new WheelSafeComboBox();
    private readonly ComboBox _configVariantBox = new WheelSafeComboBox();
    private readonly TextBox _searchBox = new();
    private readonly TextBox _rawSearchBox = new();
    private readonly ComboBox _sectionFilter = new WheelSafeComboBox();
    private readonly CheckBox _changedOnly = new();
    private readonly CheckBox _showAdvanced = new();
    private readonly ComboBox _presetBox = new WheelSafeComboBox();
    private readonly DataGridView _grid = new SmoothDataGridView();
    private readonly TextBox _keyBox = new();
    private readonly TextBox _sectionBox = new();
    private readonly TextBox _descriptionBox = new();
    private readonly TextBox _valueBox = new();
    private readonly ComboBox _choiceBox = new WheelSafeComboBox();
    private readonly CheckBox _boolBox = new();
    private readonly TableLayoutPanel _multiplierPanel = new();
    private readonly NumericUpDown _redMultiplier = new WheelSafeNumericUpDown();
    private readonly NumericUpDown _blueMultiplier = new WheelSafeNumericUpDown();
    private readonly Label _redMultiplierText = new();
    private readonly Label _blueMultiplierText = new();
    private readonly TableLayoutPanel _tuplePanel = new();
    private readonly ListBox _categoryList = new();
    private readonly Panel _formHost = new BackgroundFocusPanel();
    private readonly ToolTip _toolTip = new()
    {
        AutoPopDelay = 30000,
        InitialDelay = 0,
        ReshowDelay = 0,
        ShowAlways = true
    };
    private readonly Label _status = new();
    private readonly FlowLayoutPanel _footerLinks = new();
    private readonly Label _brandLabel = new();
    private readonly Label _footerVersionLabel = new();
    private readonly Label _discordLabel = new();
    private readonly Label _zoomLabel = new();
    private ThemeIconButton? _themeButton;
    private Button? _dcsDesanitizeButton;
    private Button? _themeModeButton;
    private ToolbarIconButton? _undoButton;
    private ToolbarIconButton? _saveButton;
    private readonly List<Control> _topToolbarButtons = new();
    private Control? _leftToolsPanel;
    private TableLayoutPanel? _rootLayout;
    private TableLayoutPanel? _topAreaLayout;
    private TableLayoutPanel? _toolbarLayout;
    private TableLayoutPanel? _instanceLayout;
    private TableLayoutPanel? _zoomLayout;
    private DcsDesanitizeStatus _dcsDesanitizeStatus = DcsDesanitizeStatus.FileNotSelected;
    private SplitContainer? _mainSplit;
    private Panel? _statusPanel;

    private ConfigDocument? _document;
    private ConfigEntry? _activeEntry;
    private readonly RuntimeSettings _settings = RuntimeSettings.Load();
    private readonly StringListCatalogStore _stringListCatalog = StringListCatalogStore.Load();
    private readonly bool _requestAdminOnLoad;
    private bool _adminUnlocked;
    private bool _loadingEntry;
    private bool _loadingForm;
    private bool _loadingInstances;
    private bool _loadingConfigVariants;
    private bool _loadingCategories;
    private bool _gridConfigured;
    private bool _rawSearchBound;
    private bool _advancedToggleBound;
    private string? _renderedCategoryName;
    private string? _activeImportedNewCategoryName;
    private Control? _rawEditorRoot;
    private readonly Dictionary<string, Control> _categoryPanelCache = new(StringComparer.OrdinalIgnoreCase);
    private readonly HashSet<string> _dirtyCategoryPanels = new(StringComparer.OrdinalIgnoreCase);
    private readonly Dictionary<string, Point> _categoryScrollPositions = new(StringComparer.OrdinalIgnoreCase);
    private readonly Dictionary<string, HashSet<string>> _unseenImportedNewEntryKeysByCategory = new(StringComparer.OrdinalIgnoreCase);
    private readonly HashSet<string> _activeImportedNewEntryKeys = new(StringComparer.Ordinal);
    private readonly Dictionary<string, string> _viewedStageDifficulties = new(StringComparer.Ordinal);
    private readonly List<(ConfigTupleField Field, Control Control)> _tupleControls = new();
    private Action? _designerSaveAction;
    private string? _designerSelectedKey;
    private string? _designerSelectedCategory;
    private string? _hoverStatusRestore;
    private int _brandClickCount;
    private DateTime _lastBrandClickUtc = DateTime.MinValue;
    private readonly Stack<UndoStep> _undoStack = new();
    private int _undoCollapseGeneration;
    private bool _restoringUndo;
    private int _uiZoomPercent;
    private bool _darkMode;
    private string? _lastUiMapSignature;

    public MainForm(bool requestAdminOnLoad = false)
    {
        _requestAdminOnLoad = requestAdminOnLoad;
        Text = "Foothold Config Manager";
        ApplyApplicationIcon();
        MinimumSize = new Size(1100, 720);
        StartPosition = FormStartPosition.CenterScreen;
        _uiZoomPercent = Math.Clamp(_settings.UiZoomPercent, 80, 150);
        _darkMode = _settings.DarkMode;
        ApplyThemePalette();
        Font = new Font("Segoe UI", BaseFontSize * _uiZoomPercent / 100F);
        BackColor = MainBackground;
        ForeColor = PrimaryTextColor;
        ApplySavedWindowSize();

        BuildUi();
        ApplyThemeToShell();
        RefreshDcsDesanitizeStatus(updateStatusLine: false);
        EnableMizDragDrop();
        FormClosing += (_, _) => SaveWindowSize();
        Load += (_, _) =>
        {
            RefreshDcsDesanitizeStatus(updateStatusLine: false);
            LoadDefaultConfig();
            if (_requestAdminOnLoad)
            {
                UnlockAdminDesigner();
            }
        };
    }

    private void ApplyApplicationIcon()
    {
        try
        {
            var icon = Icon.ExtractAssociatedIcon(Application.ExecutablePath);
            if (icon is not null)
            {
                Icon = icon;
            }
        }
        catch
        {
            // The window can still run with the default icon if extraction fails.
        }
    }

    private void ApplyThemePalette()
    {
        if (_darkMode)
        {
            MainBackground = Color.FromArgb(37, 37, 38);
            EditorBackground = Color.FromArgb(30, 30, 30);
            InputBackground = Color.FromArgb(45, 45, 48);
            PrimaryTextColor = Color.FromArgb(230, 230, 230);
            HelpTextColor = Color.FromArgb(198, 198, 198);
            BorderColor = Color.FromArgb(80, 80, 86);
            ButtonBackground = Color.FromArgb(45, 45, 48);
            HeaderBackground = Color.FromArgb(51, 51, 51);
            SelectionBackground = Color.FromArgb(38, 79, 120);
            SelectionText = Color.White;
            UndoBackground = Color.FromArgb(79, 63, 28);
            UndoMutedBorder = Color.FromArgb(126, 95, 45);
            UndoMutedText = Color.FromArgb(222, 197, 141);
            SavePendingBackground = Color.FromArgb(41, 57, 73);
            SavePendingHoverBackground = Color.FromArgb(48, 70, 92);
            SavePendingBorder = Color.FromArgb(86, 156, 214);
            BrandColor = Color.FromArgb(86, 156, 214);
            return;
        }

        MainBackground = Color.FromArgb(221, 229, 234);
        EditorBackground = Color.FromArgb(238, 243, 246);
        InputBackground = Color.FromArgb(248, 251, 253);
        PrimaryTextColor = Color.FromArgb(17, 24, 39);
        HelpTextColor = Color.FromArgb(61, 75, 89);
        BorderColor = Color.FromArgb(134, 151, 166);
        ButtonBackground = Color.FromArgb(236, 242, 246);
        HeaderBackground = Color.FromArgb(207, 220, 229);
        SelectionBackground = Color.FromArgb(36, 71, 102);
        SelectionText = Color.White;
        UndoBackground = Color.FromArgb(244, 232, 203);
        UndoMutedBorder = Color.FromArgb(176, 128, 48);
        UndoMutedText = Color.FromArgb(102, 75, 30);
        SavePendingBackground = Color.FromArgb(218, 235, 249);
        SavePendingHoverBackground = Color.FromArgb(202, 226, 246);
        SavePendingBorder = Color.FromArgb(30, 115, 216);
        BrandColor = Color.FromArgb(30, 136, 183);
    }

    private void ToggleTheme()
    {
        _darkMode = !_darkMode;
        _settings.DarkMode = _darkMode;
        _settings.Save();
        ApplyThemePalette();
        ApplyThemeToShell();
        ClearCategoryPanelCache();
        RefreshCurrentView();
        SetStatus(_darkMode ? "Dark mode enabled." : "Light mode enabled.");
    }

    private void ApplyThemeToShell()
    {
        BackColor = MainBackground;
        ForeColor = PrimaryTextColor;
        ApplyThemeToControl(this, restyleButtons: true);
        RestyleStageDifficultyButtons(this);
        _status.ForeColor = PrimaryTextColor;
        _zoomLabel.ForeColor = PrimaryTextColor;
        _descriptionBox.ForeColor = HelpTextColor;
        _formHost.BackColor = MainBackground;
        if (_leftToolsPanel is not null)
        {
            _leftToolsPanel.BackColor = EditorBackground;
        }

        UpdateFooterLabels();
        UpdateThemeButtonState();
        UpdateDcsDesanitizeButtonState();
        UpdateEditActionButtonStates();
    }

    private static void ApplyThemeToControl(Control control, bool restyleButtons)
    {
        switch (control)
        {
            case TextBoxBase:
            case ComboBox:
            case NumericUpDown:
            case ListBox:
                StyleInput(control);
                break;

            case ListView listView:
                StyleListView(listView);
                break;

            case DataGridView grid:
                ApplyGridTheme(grid);
                break;

            case TabControl tabControl:
                StyleTabControl(tabControl);
                break;

            case ToolbarIconButton toolbarIconButton:
                StyleToolbarIconButton(toolbarIconButton);
                break;

            case Button button when restyleButtons:
                StyleButton(button);
                break;

            case CheckBox checkBox:
                checkBox.BackColor = MainBackground;
                checkBox.ForeColor = PrimaryTextColor;
                break;

            case Panel separator when Equals(separator.Tag, ToolbarSeparatorTag):
                separator.BackColor = BorderColor;
                separator.ForeColor = PrimaryTextColor;
                break;

            case Label label when Equals(label.Tag, ImportedNewBadgeTag):
                label.BackColor = GetNewBadgeBackColor();
                label.ForeColor = GetNewBadgeTextColor();
                break;

            case Label label when Equals(label.Tag, ImportedNewHighlightTag):
                label.BackColor = GetNewHighlightBackColor();
                label.ForeColor = PrimaryTextColor;
                break;

            case Label label:
                label.BackColor = MainBackground;
                label.ForeColor = Equals(label.Tag, AboutLinkTag) ? Color.DodgerBlue : PrimaryTextColor;
                break;

            case SplitContainer split:
                split.BackColor = BorderColor;
                split.Panel1.BackColor = MainBackground;
                split.Panel2.BackColor = MainBackground;
                break;

            default:
                if (control is Panel or TableLayoutPanel or FlowLayoutPanel or TabControl or TabPage)
                {
                    control.BackColor = Equals(control.Tag, ImportedNewHighlightTag)
                        ? GetNewHighlightBackColor()
                        : MainBackground;
                }

                control.ForeColor = PrimaryTextColor;
                break;
        }

        foreach (Control child in control.Controls)
        {
            ApplyThemeToControl(child, restyleButtons);
        }
    }

    private void UpdateThemeButtonState()
    {
        if (_themeButton is not null)
        {
            _themeButton.BackColor = MainBackground;
            _themeButton.ForeColor = PrimaryTextColor;
            _themeButton.SetDarkMode(_darkMode);
            _toolTip.SetToolTip(_themeButton, _darkMode ? "Switch to light mode." : "Switch to dark mode.");
        }

        if (_themeModeButton is not null)
        {
            _themeModeButton.Text = _darkMode ? "Dark mode" : "Light mode";
            _toolTip.SetToolTip(_themeModeButton, _darkMode ? "Switch to light mode." : "Switch to dark mode.");
        }
    }

    private void UpdateEditActionButtonStates()
    {
        var hasChanges = HasChanges();
        UpdateUndoButtonState(hasChanges);
        UpdateSaveButtonState(hasChanges);
    }

    private void UpdateUndoButtonState(bool hasChanges)
    {
        if (_undoButton is null)
        {
            return;
        }

        _undoButton.Enabled = _undoStack.Count > 0;
        StyleToolbarIconButton(_undoButton);
        if (_undoButton.Enabled)
        {
            if (hasChanges)
            {
                _undoButton.NormalBackColor = UndoBackground;
                _undoButton.NormalBorderColor = UndoMutedBorder;
                _undoButton.HoverBackColor = SavePendingHoverBackground;
                _undoButton.HoverBorderColor = UndoMutedBorder;
                _undoButton.ForeColor = PrimaryTextColor;
            }
            else
            {
                _undoButton.NormalBackColor = ButtonBackground;
                _undoButton.NormalBorderColor = UndoMutedBorder;
                _undoButton.HoverBackColor = HeaderBackground;
                _undoButton.HoverBorderColor = UndoMutedBorder;
                _undoButton.ForeColor = UndoMutedText;
            }
        }

        _undoButton.Invalidate();
    }

    private void UpdateSaveButtonState(bool hasChanges)
    {
        if (_saveButton is null)
        {
            return;
        }

        StyleToolbarIconButton(_saveButton);
        if (hasChanges)
        {
            _saveButton.NormalBackColor = SavePendingBackground;
            _saveButton.NormalBorderColor = SavePendingBorder;
            _saveButton.HoverBackColor = SavePendingHoverBackground;
            _saveButton.HoverBorderColor = SavePendingBorder;
            _saveButton.PressedBackColor = SelectionBackground;
        }
        else
        {
            _saveButton.HoverBorderColor = BorderColor;
        }

        _saveButton.Invalidate();
    }

    private void BuildUi()
    {
        var root = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 1,
            RowCount = 3,
            Padding = new Padding(10),
            BackColor = MainBackground
        };
        _rootLayout = root;
        root.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(76)));
        root.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        root.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(34)));
        Controls.Add(root);

        root.Controls.Add(BuildTopArea(), 0, 0);
        root.Controls.Add(BuildMainArea(), 0, 1);

        root.Controls.Add(BuildStatusBar(), 0, 2);
        ApplyZoomLayoutSizes();
    }

    private Control BuildTopArea()
    {
        var panel = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 1,
            RowCount = 2,
            Margin = new Padding(0),
            Padding = new Padding(0),
            BackColor = MainBackground
        };
        _topAreaLayout = panel;
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(40)));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(32)));
        panel.Controls.Add(BuildToolbar(), 0, 0);
        panel.Controls.Add(BuildInstanceBar(), 0, 1);
        return panel;
    }

    private void EnableMizDragDrop()
    {
        AllowDrop = true;
        DragEnter += (_, args) =>
        {
            args.Effect = HasDraggedMiz(args) ? DragDropEffects.Copy : DragDropEffects.None;
        };
        DragDrop += (_, args) =>
        {
            var path = GetDraggedMizPath(args);
            if (path is not null)
            {
                InstallConfigFromMiz(path);
            }
        };
    }

    private static bool HasDraggedMiz(DragEventArgs args)
    {
        return GetDraggedMizPath(args) is not null;
    }

    private static string? GetDraggedMizPath(DragEventArgs args)
    {
        if (args.Data?.GetData(DataFormats.FileDrop) is not string[] paths)
        {
            return null;
        }

        return paths.FirstOrDefault(path => path.EndsWith(".miz", StringComparison.OrdinalIgnoreCase));
    }

    private Control BuildToolbar()
    {
        var panel = new TableLayoutPanel { Dock = DockStyle.Fill, ColumnCount = 2, BackColor = MainBackground };
        _toolbarLayout = panel;
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));

        var actions = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            AutoSize = true,
            WrapContents = false,
            FlowDirection = FlowDirection.LeftToRight,
            Margin = new Padding(0),
            Padding = new Padding(0),
            BackColor = MainBackground
        };
        _topToolbarButtons.Clear();
        actions.Controls.Add(MakeToolbarButton("Open", OpenConfig, "Select a Foothold Config.lua file to edit.", ToolbarIconKind.Open));
        actions.Controls.Add(MakeToolbarButton("Reload", ReloadConfig, "Reload the current config from disk and discard unsaved changes after confirmation.", ToolbarIconKind.Reload));
        actions.Controls.Add(MakeToolbarSeparator());
        actions.Controls.Add(MakeToolbarButton("Validate", ValidateConfig, "Check editable values for basic formatting errors before saving.", ToolbarIconKind.Validate));
        actions.Controls.Add(MakeToolbarButton("Import Config File", ImportValuesFromOldConfig, "Import Foothold Config.lua from another config file.", ToolbarIconKind.Import));
        actions.Controls.Add(MakeToolbarButton("Import MIZ Config", InstallConfigFromMiz, "Import Foothold Config.lua from a .miz file.", ToolbarIconKind.Install));
        actions.Controls.Add(MakeToolbarButton("Restore Defaults", RestoreConfigDefaults, "Restore from a default Foothold Config.lua previously stored during Import MIZ Config.", ToolbarIconKind.Restore));
        actions.Controls.Add(MakeToolbarSeparator());
        _undoButton = MakeToolbarButton("Undo", UndoLastChange, "Revert the last unsaved edit, add, or remove action.", ToolbarIconKind.Undo);
        actions.Controls.Add(_undoButton);
        _saveButton = MakeToolbarButton("Save", SaveConfig, "Write pending changes to the current config.", ToolbarIconKind.Save);
        actions.Controls.Add(_saveButton);
        UpdateEditActionButtonStates();
        actions.Controls.Add(MakeToolbarSeparator());
        panel.Controls.Add(actions, 0, 0);

        _pathBox.Dock = DockStyle.Fill;
        _pathBox.ReadOnly = true;
        StyleInput(_pathBox);
        SetToolbarHelp(_pathBox, "Current Foothold config file.");
        panel.Controls.Add(_pathBox, 1, 0);
        return panel;
    }

    private Control MakeToolbarSeparator()
    {
        var separator = new Panel
        {
            BackColor = BorderColor,
            Tag = ToolbarSeparatorTag
        };
        ApplyToolbarSeparatorSizing(separator);
        return separator;
    }

    private Button MakeToolbarButton(string text, Action action, string helpText)
    {
        var button = MakeButton(text, action);
        SetToolbarHelp(button, helpText);
        return button;
    }

    private Button MakeTopToolbarButton(string text, Action action, string helpText, int minimumWidth)
    {
        var button = MakeButton(text, action);
        button.Dock = DockStyle.None;
        SizeTopToolbarButton(button, minimumWidth);
        _topToolbarButtons.Add(button);
        SetToolbarHelp(button, helpText);
        return button;
    }

    private void SizeTopToolbarButton(Control button, int minimumWidth)
    {
        ApplyTopToolbarFont(button);
        button.Width = button is ToolbarIconButton
            ? ToolbarIconButtonWidth(button.Text, minimumWidth, button.Font)
            : TopToolbarButtonWidth(button.Text, minimumWidth, button.Font);
        button.Height = Math.Max(Zoomed(32), button.Font.Height + Zoomed(10));
        button.Margin = new Padding(Zoomed(3), Zoomed(2), Zoomed(3), 0);
        if (button is Button b)
            b.TextAlign = ContentAlignment.MiddleCenter;
    }

    private void ApplyTopToolbarFont(Control control)
    {
        var targetSize = (BaseFontSize + 0.75F) * _uiZoomPercent / 100F;
        if (Math.Abs(control.Font.Size - targetSize) > 0.05F)
        {
            control.Font = new Font("Segoe UI", targetSize);
        }
    }

    private int GetTopToolbarButtonMinimum(string text)
    {
        return text switch
        {
            "Open" => 60,
            "Reload" => 60,
            "Validate" => 60,
            "Import Config File" => 60,
            "Import MIZ Config" => 60,
            "Restore Defaults" => 60,
            "Undo" => 78,
            "Save" => 60,
            _ => 60
        };
    }

    private void ApplyToolbarSeparatorSizing(Control control)
    {
        if (Equals(control.Tag, ToolbarSeparatorTag))
        {
            control.Width = Math.Max(Zoomed(2), 2);
            control.Height = Math.Max(Zoomed(24), Font.Height + Zoomed(6));
            control.Margin = new Padding(Zoomed(7), Zoomed(5), Zoomed(7), 0);
            control.BackColor = BorderColor;
        }

        foreach (Control child in control.Controls)
        {
            ApplyToolbarSeparatorSizing(child);
        }
    }

    private ToolbarIconButton MakeToolbarButton(string text, Action action, string helpText, ToolbarIconKind iconKind)
    {
        var button = new ToolbarIconButton(iconKind)
        {
            Text = text,
            Dock = DockStyle.None,
            Margin = new Padding(2, Zoomed(2), 2, 0)
        };
        StyleToolbarIconButton(button);
        SizeTopToolbarButton(button, GetTopToolbarButtonMinimum(text));
        _topToolbarButtons.Add(button);
        button.Click += (_, _) => action();
        SetToolbarHelp(button, helpText);
        return button;
    }

    private Control BuildInstanceBar()
    {
        var panel = new TableLayoutPanel { Dock = DockStyle.Fill, ColumnCount = 9, BackColor = MainBackground };
        _instanceLayout = panel;
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, LabelColumnWidth("Instance", 70)));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, LabelColumnWidth("Config", 55)));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, ToolbarButtonWidth("Normal", 95)));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, ToolbarButtonWidth("Advanced", 105)));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, ToolbarButtonWidth("Open File Location", 150)));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, ToolbarButtonWidth("Add", 90)));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, ToolbarButtonWidth("Remove", 100)));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, ToolbarButtonWidth("Copy To...", 110)));

        panel.Controls.Add(MakeLabel("Instance"), 0, 0);
        _instanceBox.Dock = DockStyle.Fill;
        _instanceBox.DropDownStyle = ComboBoxStyle.DropDownList;
        StyleInput(_instanceBox);
        _instanceBox.SelectedIndexChanged += (_, _) => SwitchInstance();
        SetToolbarHelp(_instanceBox, "Select a saved server/config instance.");
        panel.Controls.Add(_instanceBox, 1, 0);
        panel.Controls.Add(MakeLabel("Config"), 2, 0);
        _configVariantBox.Dock = DockStyle.Fill;
        _configVariantBox.DropDownStyle = ComboBoxStyle.DropDownList;
        StyleInput(_configVariantBox);
        _configVariantBox.SelectedIndexChanged += (_, _) => SwitchConfigVariant();
        SetToolbarHelp(_configVariantBox, "Switch between normal and WW2 configs in the same instance folder.");
        panel.Controls.Add(_configVariantBox, 3, 0);
        _showAdvanced.Text = "Advanced";
        _showAdvanced.Dock = DockStyle.Fill;
        BindAdvancedToggle();
        panel.Controls.Add(_showAdvanced, 4, 0);
        panel.Controls.Add(MakeInstanceToolbarButton("Open File Location", OpenCurrentConfigLocation, "Open Explorer with the current Foothold config selected."), 5, 0);
        panel.Controls.Add(MakeInstanceToolbarButton("Add", AddInstance, "Add another Foothold config instance."), 6, 0);
        panel.Controls.Add(MakeInstanceToolbarButton("Remove", RemoveInstance, "Remove the selected instance from this list. The config file is not deleted."), 7, 0);
        panel.Controls.Add(MakeInstanceToolbarButton("Copy To...", CopyCurrentConfigToInstances, "Replace selected instance configs with the currently open saved config. No backup is created."), 8, 0);
        RefreshInstanceList();
        RefreshConfigVariantList();
        return panel;
    }

    private Button MakeInstanceToolbarButton(string text, Action action, string helpText)
    {
        var button = MakeToolbarButton(text, action, helpText);
        button.Cursor = Cursors.Hand;
        button.MouseEnter += (_, _) =>
        {
            if (button.Enabled && IsDarkPalette())
            {
                button.FlatAppearance.BorderColor = BrandColor;
            }
        };
        button.MouseLeave += (_, _) =>
        {
            button.FlatAppearance.BorderColor = BorderColor;
        };
        return button;
    }

    private void OpenCurrentConfigLocation()
    {
        var path = GetCurrentConfigLocationPath();
        if (string.IsNullOrWhiteSpace(path))
        {
            MessageBox.Show(this, "Open or select a config first.", "Open File Location", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

        try
        {
            path = Path.GetFullPath(path);
            if (File.Exists(path))
            {
                System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
                {
                    FileName = "explorer.exe",
                    Arguments = "/select,\"" + path + "\"",
                    UseShellExecute = true
                });
                SetStatus("Opened file location.");
                return;
            }

            var directory = Directory.Exists(path)
                ? path
                : Path.GetDirectoryName(path);
            if (!string.IsNullOrWhiteSpace(directory) && Directory.Exists(directory))
            {
                System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
                {
                    FileName = "explorer.exe",
                    Arguments = "\"" + directory + "\"",
                    UseShellExecute = true
                });
                SetStatus("Opened config folder.");
                return;
            }

            MessageBox.Show(this, "Config path does not exist:\n" + path, "Open File Location", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Open File Location failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private string? GetCurrentConfigLocationPath()
    {
        if (_document is not null)
        {
            return _document.Path;
        }

        if (_instanceBox.SelectedItem is InstanceItem item)
        {
            return item.Profile.ConfigPath;
        }

        return string.IsNullOrWhiteSpace(_pathBox.Text) ? null : _pathBox.Text;
    }

    private void BindAdvancedToggle()
    {
        if (_advancedToggleBound)
        {
            return;
        }

        _showAdvanced.CheckedChanged += (_, _) => HandleAdvancedToggleChanged();
        _advancedToggleBound = true;
    }

    private void HandleAdvancedToggleChanged()
    {
        MarkAllCategoryPanelsDirty();
        var selectedCategory = GetSelectedCategoryName();
        var refreshCurrentCategory = DoesAdvancedToggleAffectCategory(selectedCategory);
        ReloadCategoriesPreservingSelection(refreshCurrentCategory);
        if (IsRawCategorySelected())
        {
            RefreshGrid();
        }
    }

    private void ZoomOut()
    {
        SetUiZoom(_uiZoomPercent - 10, persist: true);
    }

    private void ZoomIn()
    {
        SetUiZoom(_uiZoomPercent + 10, persist: true);
    }

    private void SetUiZoom(int percent, bool persist)
    {
        _uiZoomPercent = Math.Clamp(percent, 80, 150);
        Font = new Font("Segoe UI", BaseFontSize * _uiZoomPercent / 100F);
        UpdateZoomLabel();
        ApplyZoomLayoutSizes();
        if (persist)
        {
            _settings.UiZoomPercent = _uiZoomPercent;
            _settings.Save();
        }

        ClearCategoryPanelCache();
        RefreshCurrentView();
    }

    private void UpdateZoomLabel()
    {
        _zoomLabel.Text = _uiZoomPercent.ToString(CultureInfo.InvariantCulture) + "%";
    }

    private int Zoomed(int value)
    {
        return Math.Max(1, (int)Math.Ceiling(value * _uiZoomPercent / 100.0));
    }

    private int ToolbarButtonWidth(string text, int minimum)
    {
        return Math.Max(Zoomed(minimum), TextRenderer.MeasureText(text, Font).Width + Zoomed(34));
    }

    private int TopToolbarButtonWidth(string text, int minimum, Font font)
    {
        return Math.Max(Zoomed(minimum), TextRenderer.MeasureText(text, font).Width + Zoomed(26));
    }

    private int ToolbarIconButtonWidth(string text, int minimum, Font font)
    {
        var textWidth = TextRenderer.MeasureText(text, font, new Size(int.MaxValue, int.MaxValue), TextFormatFlags.SingleLine | TextFormatFlags.NoPadding | TextFormatFlags.NoPrefix).Width;
        // Match ToolbarIconButton.OnPaint: 6 left + 17 icon + 5 gap + 14 right.
        return Math.Max(Zoomed(minimum), textWidth + 46);
    }

    private int LabelColumnWidth(string text, int minimum)
    {
        return Math.Max(Zoomed(minimum), TextRenderer.MeasureText(text, Font).Width + Zoomed(12));
    }

    private int DialogButtonWidth(string text, int minimum = 96)
    {
        return Math.Max(Zoomed(minimum), TextRenderer.MeasureText(text, Font).Width + Zoomed(44));
    }

    private int DialogButtonHeight()
    {
        return Math.Max(Zoomed(30), Font.Height + Zoomed(12));
    }

    private void SizeDialogButton(Button button, int minimumWidth = 96)
    {
        button.Width = DialogButtonWidth(button.Text, minimumWidth);
        button.Height = DialogButtonHeight();
        button.MinimumSize = new Size(button.Width, button.Height);
    }

    private static int GetComboBoxDropDownWidth(ComboBox comboBox)
    {
        var width = comboBox.Width;
        foreach (var item in comboBox.Items)
        {
            width = Math.Max(width, TextRenderer.MeasureText(item?.ToString() ?? "", comboBox.Font).Width + SystemInformation.VerticalScrollBarWidth + 24);
        }

        return width;
    }

    private void ApplyDialogChrome(Form dialog)
    {
        dialog.Icon = Icon;
        dialog.BackColor = MainBackground;
        dialog.ForeColor = PrimaryTextColor;
        ApplyThemeToControl(dialog, restyleButtons: true);
    }

    private void ApplyZoomLayoutSizes()
    {
        if (_rootLayout is not null)
        {
            SetRowHeight(_rootLayout, 0, Zoomed(76));
            SetRowHeight(_rootLayout, 2, Zoomed(34));
        }

        if (_topAreaLayout is not null)
        {
            SetRowHeight(_topAreaLayout, 0, Zoomed(40));
            SetRowHeight(_topAreaLayout, 1, Zoomed(32));
        }

        if (_toolbarLayout is not null)
        {
            if (_toolbarLayout.ColumnStyles.Count >= 2)
            {
                _toolbarLayout.ColumnStyles[0].SizeType = SizeType.AutoSize;
                _toolbarLayout.ColumnStyles[1].SizeType = SizeType.Percent;
                _toolbarLayout.ColumnStyles[1].Width = 100;
            }

            foreach (var button in _topToolbarButtons)
            {
                SizeTopToolbarButton(button, GetTopToolbarButtonMinimum(button.Text));
            }

            foreach (Control control in _toolbarLayout.Controls)
            {
                ApplyToolbarSeparatorSizing(control);
            }
        }

        ApplyCategoryListSizing();

        if (_instanceLayout is not null)
        {
            SetColumnWidth(_instanceLayout, 0, LabelColumnWidth("Instance", 70));
            SetColumnWidth(_instanceLayout, 4, ShouldShowAdvancedToggle() ? ToolbarButtonWidth("Advanced", 105) : 0);
            SetColumnWidth(_instanceLayout, 5, ToolbarButtonWidth("Open File Location", 150));
            SetColumnWidth(_instanceLayout, 6, ToolbarButtonWidth("Add", 90));
            SetColumnWidth(_instanceLayout, 7, ToolbarButtonWidth("Remove", 100));
            SetColumnWidth(_instanceLayout, 8, ToolbarButtonWidth("Copy To...", 110));
            ApplyConfigVariantSelectorVisibility(_configVariantBox.Items.Count > 1);
        }

        if (_mainSplit is not null)
        {
            var desiredWidth = Zoomed(250);
            var maxWidth = Math.Max(Zoomed(210), ClientSize.Width / 3);
            _mainSplit.SplitterDistance = Math.Min(desiredWidth, maxWidth);
        }

        if (_zoomLayout is not null)
        {
            _zoomLayout.Height = Zoomed(32);
        }

        if (_leftToolsPanel is TableLayoutPanel toolsPanel)
        {
            toolsPanel.Padding = new Padding(0, Zoomed(5), 0, Zoomed(6));
            SetRowHeight(toolsPanel, 0, Zoomed(6));
            SetRowHeight(toolsPanel, 1, Zoomed(34));
            SetRowHeight(toolsPanel, 2, Zoomed(34));
            SetRowHeight(toolsPanel, 3, Zoomed(34));
            SetRowHeight(toolsPanel, 4, Zoomed(34));
        }

        LayoutFooterLinks();
    }

    private static void SetColumnWidth(TableLayoutPanel panel, int index, int width)
    {
        if (panel.ColumnStyles.Count <= index)
        {
            return;
        }

        panel.ColumnStyles[index].SizeType = SizeType.Absolute;
        panel.ColumnStyles[index].Width = width;
    }

    private static void SetRowHeight(TableLayoutPanel panel, int index, int height)
    {
        if (panel.RowStyles.Count <= index)
        {
            return;
        }

        panel.RowStyles[index].SizeType = SizeType.Absolute;
        panel.RowStyles[index].Height = height;
    }

    private void ApplySavedWindowSize()
    {
        if (_settings.WindowWidth <= 0 || _settings.WindowHeight <= 0)
        {
            return;
        }

        var workingArea = Screen.PrimaryScreen?.WorkingArea ?? new Rectangle(0, 0, 1920, 1080);
        var width = Math.Clamp(_settings.WindowWidth, MinimumSize.Width, Math.Max(MinimumSize.Width, workingArea.Width));
        var height = Math.Clamp(_settings.WindowHeight, MinimumSize.Height, Math.Max(MinimumSize.Height, workingArea.Height));
        Size = new Size(width, height);
    }

    private void SaveWindowSize()
    {
        var size = WindowState == FormWindowState.Normal ? Size : RestoreBounds.Size;
        _settings.WindowWidth = Math.Max(MinimumSize.Width, size.Width);
        _settings.WindowHeight = Math.Max(MinimumSize.Height, size.Height);
        _settings.Save();
    }

    private void SetToolbarHelp(Control control, string helpText)
    {
        _toolTip.SetToolTip(control, helpText);
        control.MouseEnter += (_, _) =>
        {
            _hoverStatusRestore = _status.Text;
            SetStatus(helpText);
        };
        control.MouseLeave += (_, _) =>
        {
            if (_hoverStatusRestore is null)
            {
                return;
            }

            SetStatus(_hoverStatusRestore);
            _hoverStatusRestore = null;
        };
    }

    private Control BuildStatusBar()
    {
        var panel = new Panel
        {
            Dock = DockStyle.Fill,
            BackColor = MainBackground
        };
        _statusPanel = panel;

        _status.Dock = DockStyle.Fill;
        _status.TextAlign = ContentAlignment.MiddleLeft;
        _status.ForeColor = PrimaryTextColor;
        panel.Controls.Add(_status);
        return panel;
    }

    private void UpdateFooterLabels()
    {
        var version = _document?.Metadata.FooterVersion?.Trim() ?? "";
        _footerVersionLabel.Text = version;
        _footerVersionLabel.Visible = !string.IsNullOrWhiteSpace(version);
    }

    private void LayoutFooterLinks()
    {
        if (_footerLinks.IsDisposed)
        {
            return;
        }

        var topMargin = Zoomed(7);
        _brandLabel.Margin = new Padding(0, topMargin, Zoomed(10), 0);
        _footerVersionLabel.Margin = new Padding(0, topMargin, Zoomed(10), 0);
        _discordLabel.Margin = new Padding(0, topMargin, 0, 0);
        _footerLinks.Height = Zoomed(32);

        var width = TextRenderer.MeasureText(_brandLabel.Text, Font).Width + Zoomed(10) +
                    TextRenderer.MeasureText(_discordLabel.Text, Font).Width + Zoomed(16);
        if (_footerVersionLabel.Visible)
        {
            width += TextRenderer.MeasureText(_footerVersionLabel.Text, Font).Width + Zoomed(10);
        }

        _footerLinks.Width = Math.Max(Zoomed(130), width);
    }

    private void OpenDiscordInvite()
    {
        try
        {
            System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
            {
                FileName = DiscordInviteUrl,
                UseShellExecute = true
            });
            SetStatus("Opened Discord invite.");
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Open Discord failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private void OpenGitHubRepository()
    {
        try
        {
            System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
            {
                FileName = GitHubRepositoryUrl,
                UseShellExecute = true
            });
            SetStatus("Opened GitHub repository.");
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Open GitHub failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private void RefreshDcsDesanitizeStatus(bool updateStatusLine)
    {
        _dcsDesanitizeStatus = CheckDcsDesanitizeStatus(_settings.MissionScriptingPath);
        UpdateDcsDesanitizeButtonState();
        if (updateStatusLine)
        {
            SetStatus("MissionScripting: " + GetDcsDesanitizeStatusText(_dcsDesanitizeStatus) + ".");
        }
    }

    private void UpdateDcsDesanitizeButtonState()
    {
        if (_dcsDesanitizeButton is null)
        {
            return;
        }

        _dcsDesanitizeButton.Text = _dcsDesanitizeStatus switch
        {
            DcsDesanitizeStatus.Desanitized => "MissionScripting OK",
            DcsDesanitizeStatus.NotDesanitized => "MissionScripting not desanitized",
            DcsDesanitizeStatus.PartiallyDesanitized => "MissionScripting partial",
            DcsDesanitizeStatus.FileMissing => "MissionScripting missing",
            DcsDesanitizeStatus.UnknownFormat => "MissionScripting check file",
            _ => "MissionScripting"
        };
        SetToolbarHelp(_dcsDesanitizeButton, "Required for mission persistence/save files. Status: " + GetDcsDesanitizeStatusText(_dcsDesanitizeStatus) + ".");
    }

    private static string GetDcsDesanitizeStatusText(DcsDesanitizeStatus status)
    {
        return status switch
        {
            DcsDesanitizeStatus.Desanitized => "Desanitized",
            DcsDesanitizeStatus.NotDesanitized => "Not desanitized",
            DcsDesanitizeStatus.PartiallyDesanitized => "Partially desanitized",
            DcsDesanitizeStatus.FileMissing => "File missing",
            DcsDesanitizeStatus.UnknownFormat => "Unknown format",
            _ => "File not selected"
        };
    }

    private static DcsDesanitizeStatus CheckDcsDesanitizeStatus(string? path)
    {
        if (string.IsNullOrWhiteSpace(path))
        {
            return DcsDesanitizeStatus.FileNotSelected;
        }

        if (!File.Exists(path))
        {
            return DcsDesanitizeStatus.FileMissing;
        }

        try
        {
            var text = File.ReadAllText(path);
            var states = new[]
            {
                FindCommentedModuleLine(text, "io"),
                FindCommentedModuleLine(text, "lfs"),
                FindCommentedGlobalNilLine(text, "require"),
                FindCommentedGlobalNilLine(text, "loadlib"),
                FindCommentedGlobalNilLine(text, "package")
            };

            if (states.Any(state => state is null))
            {
                return DcsDesanitizeStatus.UnknownFormat;
            }

            var commentedCount = states.Count(state => state == true);
            if (commentedCount == states.Length)
            {
                return DcsDesanitizeStatus.Desanitized;
            }

            return commentedCount == 0
                ? DcsDesanitizeStatus.NotDesanitized
                : DcsDesanitizeStatus.PartiallyDesanitized;
        }
        catch
        {
            return DcsDesanitizeStatus.UnknownFormat;
        }
    }

    private static bool? FindCommentedModuleLine(string text, string moduleName)
    {
        var pattern = @"(?m)^\s*(?<comment>--\s*)?sanitizeModule\(\s*['""]" + Regex.Escape(moduleName) + @"['""]\s*\)\s*$";
        var match = Regex.Match(text, pattern);
        return match.Success ? match.Groups["comment"].Success : null;
    }

    private static bool? FindCommentedGlobalNilLine(string text, string name)
    {
        var pattern = @"(?m)^\s*(?<comment>--\s*)?_G\[\s*['""]" + Regex.Escape(name) + @"['""]\s*\]\s*=\s*nil\s*$";
        var match = Regex.Match(text, pattern);
        return match.Success ? match.Groups["comment"].Success : null;
    }

    private string GetMissionScriptingInitialDirectory()
    {
        var currentPath = _settings.MissionScriptingPath;
        if (!string.IsNullOrWhiteSpace(currentPath))
        {
            var directory = Path.GetDirectoryName(currentPath);
            if (!string.IsNullOrWhiteSpace(directory) && Directory.Exists(directory))
            {
                return directory;
            }
        }

        var candidates = new[]
        {
            @"C:\Games\DCS World Server\Scripts",
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), "Eagle Dynamics", "DCS World Server", "Scripts"),
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), "Eagle Dynamics", "DCS World", "Scripts"),
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86), "Eagle Dynamics", "DCS World", "Scripts")
        };

        return candidates.FirstOrDefault(Directory.Exists) ?? RuntimeSettings.GetBestInitialDirectory();
    }

    private bool SelectMissionScriptingFile()
    {
        using var dialog = new OpenFileDialog
        {
            Title = "Select MissionScripting.lua",
            Filter = "MissionScripting.lua|MissionScripting.lua|Lua files (*.lua)|*.lua|All files (*.*)|*.*",
            InitialDirectory = GetMissionScriptingInitialDirectory(),
            FileName = "MissionScripting.lua",
            CheckFileExists = true
        };

        if (dialog.ShowDialog(this) != DialogResult.OK)
        {
            return false;
        }

        var fullPath = Path.GetFullPath(dialog.FileName);
        if (!Path.GetFileName(fullPath).Equals("MissionScripting.lua", StringComparison.OrdinalIgnoreCase))
        {
            MessageBox.Show(this, "Select the MissionScripting.lua file.", "MissionScripting.lua", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return false;
        }

        _settings.MissionScriptingPath = fullPath;
        _settings.Save();
        RefreshDcsDesanitizeStatus(updateStatusLine: true);
        return true;
    }

    private static string ApplyDcsDesanitizeText(string text)
    {
        text = CommentUncommentedLine(text, @"sanitizeModule\(\s*['""]io['""]\s*\)");
        text = CommentUncommentedLine(text, @"sanitizeModule\(\s*['""]lfs['""]\s*\)");
        text = CommentUncommentedLine(text, @"_G\[\s*['""]require['""]\s*\]\s*=\s*nil");
        text = CommentUncommentedLine(text, @"_G\[\s*['""]loadlib['""]\s*\]\s*=\s*nil");
        text = CommentUncommentedLine(text, @"_G\[\s*['""]package['""]\s*\]\s*=\s*nil");
        return text;
    }

    private static string CommentUncommentedLine(string text, string codePattern)
    {
        var pattern = @"(?m)^(?<indent>\s*)(?<code>" + codePattern + @"\s*)$";
        return Regex.Replace(text, pattern, match => match.Groups["indent"].Value + "--" + match.Groups["code"].Value);
    }

    private bool ApplyDcsDesanitize()
    {
        var path = _settings.MissionScriptingPath;
        var status = CheckDcsDesanitizeStatus(path);
        if (status is DcsDesanitizeStatus.FileNotSelected)
        {
            MessageBox.Show(this, "Select MissionScripting.lua first.", "MissionScripting.lua", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return false;
        }

        if (status is DcsDesanitizeStatus.FileMissing)
        {
            MessageBox.Show(this, "MissionScripting.lua was not found at the selected path.", "MissionScripting.lua", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return false;
        }

        if (status is DcsDesanitizeStatus.UnknownFormat)
        {
            MessageBox.Show(this, "MissionScripting.lua has an unexpected format. No file was changed.", "MissionScripting.lua", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return false;
        }

        if (status is DcsDesanitizeStatus.Desanitized)
        {
            MessageBox.Show(this, "MissionScripting.lua is already desanitized.", "MissionScripting.lua", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return true;
        }

        try
        {
            var text = File.ReadAllText(path!);
            var updated = ApplyDcsDesanitizeText(text);
            if (string.Equals(text, updated, StringComparison.Ordinal))
            {
                MessageBox.Show(this, "No matching sanitized lines were changed.", "MissionScripting.lua", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return false;
            }

            File.WriteAllText(path!, updated);
            RefreshDcsDesanitizeStatus(updateStatusLine: true);
            return _dcsDesanitizeStatus is DcsDesanitizeStatus.Desanitized;
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "MissionScripting.lua failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
            RefreshDcsDesanitizeStatus(updateStatusLine: false);
            return false;
        }
    }

    private void OpenMissionScriptingLocation()
    {
        var path = _settings.MissionScriptingPath;
        if (string.IsNullOrWhiteSpace(path) || !File.Exists(path))
        {
            MessageBox.Show(this, "MissionScripting.lua was not found at the selected path.", "MissionScripting.lua", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return;
        }

        try
        {
            System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
            {
                FileName = "explorer.exe",
                Arguments = "/select,\"" + path + "\"",
                UseShellExecute = true
            });
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Open file location failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private void ShowDcsDesanitizeDialog()
    {
        if (string.IsNullOrWhiteSpace(_settings.MissionScriptingPath))
        {
            SelectMissionScriptingFile();
        }

        RefreshDcsDesanitizeStatus(updateStatusLine: false);
        using var dialog = new Form
        {
            Text = "MissionScripting.lua",
            StartPosition = FormStartPosition.CenterParent,
            FormBorderStyle = FormBorderStyle.FixedDialog,
            MinimizeBox = false,
            MaximizeBox = false,
            ClientSize = new Size(Zoomed(720), Zoomed(282)),
            Font = Font,
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        };

        var panel = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 1,
            RowCount = 5,
            Padding = new Padding(Zoomed(14)),
            BackColor = MainBackground
        };
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(34)));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(34)));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(38)));
        panel.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(50)));
        dialog.Controls.Add(panel);

        panel.Controls.Add(new Label
        {
            Text = "MissionScripting.lua",
            Dock = DockStyle.Fill,
            Font = new Font(Font, FontStyle.Bold),
            TextAlign = ContentAlignment.MiddleLeft,
            ForeColor = PrimaryTextColor,
            BackColor = MainBackground
        }, 0, 0);

        var statusLabel = new Label
        {
            Dock = DockStyle.Fill,
            TextAlign = ContentAlignment.MiddleLeft,
            ForeColor = PrimaryTextColor,
            BackColor = MainBackground
        };
        panel.Controls.Add(statusLabel, 0, 1);

        var pathBox = new TextBox
        {
            Dock = DockStyle.Fill,
            ReadOnly = true,
            BackColor = InputBackground,
            ForeColor = PrimaryTextColor,
            BorderStyle = BorderStyle.FixedSingle
        };
        panel.Controls.Add(pathBox, 0, 2);

        panel.Controls.Add(new Label
        {
            Text = "Required for mission persistence/save files. Apply desanitize enables file access by commenting out io, lfs, require, loadlib, and package. os remains sanitized.",
            Dock = DockStyle.Fill,
            ForeColor = HelpTextColor,
            BackColor = MainBackground
        }, 0, 3);

        var buttons = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 5,
            RowCount = 1,
            Padding = new Padding(0, Zoomed(7), 0, 0),
            Margin = new Padding(0),
            BackColor = MainBackground
        };
        for (var column = 0; column < buttons.ColumnCount; column++)
        {
            buttons.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 20));
        }

        buttons.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        panel.Controls.Add(buttons, 0, 4);

        var closeButton = new Button { Text = "Close", DialogResult = DialogResult.OK };
        var applyButton = new Button { Text = "Apply desanitize" };
        var checkButton = new Button { Text = "Check again" };
        var selectButton = new Button { Text = "Select file" };
        var openButton = new Button { Text = "Open location" };
        foreach (var button in new[] { closeButton, applyButton, checkButton, selectButton, openButton })
        {
            SizeDialogButton(button, button == applyButton ? 132 : 112);
            button.Dock = DockStyle.Fill;
            button.Margin = new Padding(Zoomed(3), 0, Zoomed(3), 0);
            StyleButton(button);
            EnableButtonInteractiveChrome(button);
        }

        void RefreshDialog()
        {
            RefreshDcsDesanitizeStatus(updateStatusLine: false);
            statusLabel.Text = "Status: " + GetDcsDesanitizeStatusText(_dcsDesanitizeStatus);
            pathBox.Text = string.IsNullOrWhiteSpace(_settings.MissionScriptingPath) ? "(not selected)" : _settings.MissionScriptingPath;
            applyButton.Enabled = _dcsDesanitizeStatus is DcsDesanitizeStatus.NotDesanitized or DcsDesanitizeStatus.PartiallyDesanitized;
            openButton.Enabled = _dcsDesanitizeStatus is not DcsDesanitizeStatus.FileNotSelected;
        }

        selectButton.Click += (_, _) =>
        {
            SelectMissionScriptingFile();
            RefreshDialog();
        };
        checkButton.Click += (_, _) => RefreshDialog();
        applyButton.Click += (_, _) =>
        {
            ApplyDcsDesanitize();
            RefreshDialog();
        };
        openButton.Click += (_, _) => OpenMissionScriptingLocation();

        buttons.Controls.Add(selectButton, 0, 0);
        buttons.Controls.Add(openButton, 1, 0);
        buttons.Controls.Add(checkButton, 2, 0);
        buttons.Controls.Add(applyButton, 3, 0);
        buttons.Controls.Add(closeButton, 4, 0);

        RefreshDialog();
        dialog.AcceptButton = closeButton;
        ApplyDialogChrome(dialog);
        dialog.ShowDialog(this);
    }

    private void ShowAboutDialog()
    {
        using var dialog = new Form
        {
            Text = "About",
            StartPosition = FormStartPosition.CenterParent,
            FormBorderStyle = FormBorderStyle.FixedDialog,
            MinimizeBox = false,
            MaximizeBox = false,
            ClientSize = new Size(Zoomed(360), Zoomed(190)),
            Font = Font,
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        };

        var panel = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 1,
            RowCount = 5,
            Padding = new Padding(Zoomed(14)),
            BackColor = MainBackground
        };
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(34)));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(28)));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(28)));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(34)));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(46)));
        dialog.Controls.Add(panel);

        panel.Controls.Add(new Label
        {
            Text = "Foothold Config Manager",
            Dock = DockStyle.Fill,
            Font = new Font(Font, FontStyle.Bold),
            ForeColor = PrimaryTextColor,
            BackColor = MainBackground
        }, 0, 0);

        var version = _document?.Metadata.FooterVersion?.Trim();
        panel.Controls.Add(new Label
        {
            Text = string.IsNullOrWhiteSpace(version) ? "Version unavailable" : version,
            Dock = DockStyle.Fill,
            ForeColor = HelpTextColor,
            BackColor = MainBackground
        }, 0, 1);

        var byLabel = new Label
        {
            Text = "By Leka",
            Dock = DockStyle.Fill,
            ForeColor = BrandColor,
            BackColor = MainBackground,
            Cursor = Cursors.Hand
        };
        byLabel.Click += (_, _) => HandleBrandClick();
        _toolTip.SetToolTip(byLabel, "Triple-click to open the admin password prompt.");
        panel.Controls.Add(byLabel, 0, 2);

        var linkPanel = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            FlowDirection = FlowDirection.LeftToRight,
            WrapContents = false,
            Padding = new Padding(0, Zoomed(4), 0, 0),
            Margin = new Padding(0),
            BackColor = MainBackground
        };
        var discordLink = MakeAboutLink("Discord", OpenDiscordInvite, "Open Foothold Discord.");
        var gitHubLink = MakeAboutLink("GitHub", OpenGitHubRepository, "Open the Foothold GitHub repository.");
        discordLink.Margin = new Padding(0, 0, Zoomed(16), 0);
        gitHubLink.Margin = new Padding(0);
        linkPanel.Controls.Add(discordLink);
        linkPanel.Controls.Add(gitHubLink);
        panel.Controls.Add(linkPanel, 0, 3);

        var buttonPanel = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 1,
            RowCount = 1,
            Padding = new Padding(0, Zoomed(7), 0, 0),
            Margin = new Padding(0),
            BackColor = MainBackground
        };
        buttonPanel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        buttonPanel.RowStyles.Add(new RowStyle(SizeType.Percent, 100));

        var closeButton = new Button
        {
            Text = "Close",
            DialogResult = DialogResult.OK
        };
        SizeDialogButton(closeButton, 110);
        closeButton.Anchor = AnchorStyles.Right;
        closeButton.Margin = new Padding(0);
        StyleButton(closeButton);
        EnableButtonInteractiveChrome(closeButton);
        buttonPanel.Controls.Add(closeButton, 0, 0);
        panel.Controls.Add(buttonPanel, 0, 4);

        dialog.AcceptButton = closeButton;
        ApplyDialogChrome(dialog);
        dialog.ShowDialog(this);
    }

    private Label MakeAboutLink(string text, Action action, string helpText)
    {
        var label = new Label
        {
            Text = text,
            AutoSize = true,
            ForeColor = Color.DodgerBlue,
            Font = new Font(Font, FontStyle.Underline),
            BackColor = MainBackground,
            Cursor = Cursors.Hand,
            Tag = AboutLinkTag
        };
        label.Click += (_, _) => action();
        SetToolbarHelp(label, helpText);
        return label;
    }

    private Control BuildZoomStatusControl()
    {
        var panel = new TableLayoutPanel
        {
            Width = Zoomed(252),
            Height = Zoomed(32),
            ColumnCount = 7,
            Margin = new Padding(0),
            Padding = new Padding(0),
            BackColor = MainBackground
        };
        _zoomLayout = panel;
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, ToolbarButtonWidth("A-", 42)));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, Math.Max(Zoomed(62), TextRenderer.MeasureText("150%", Font).Width + Zoomed(16))));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, ToolbarButtonWidth("A+", 42)));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, Zoomed(10)));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, Zoomed(36)));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50));

        panel.Controls.Add(MakeStatusZoomButton("A-", ZoomOut, "Make manager text smaller."), 1, 0);
        _zoomLabel.TextAlign = ContentAlignment.MiddleCenter;
        _zoomLabel.Dock = DockStyle.Fill;
        _zoomLabel.Margin = new Padding(0);
        _zoomLabel.ForeColor = PrimaryTextColor;
        SetToolbarHelp(_zoomLabel, "Current manager text zoom.");
        UpdateZoomLabel();
        panel.Controls.Add(_zoomLabel, 2, 0);
        panel.Controls.Add(MakeStatusZoomButton("A+", ZoomIn, "Make manager text larger."), 3, 0);
        _themeButton = new ThemeIconButton
        {
            Dock = DockStyle.Fill,
            Margin = new Padding(2, 1, 2, 0)
        };
        _themeButton.Click += (_, _) => ToggleTheme();
        SetToolbarHelp(_themeButton, "Toggle light/dark mode.");
        UpdateThemeButtonState();
        panel.Controls.Add(_themeButton, 5, 0);
        return panel;
    }

    private Button MakeStatusZoomButton(string text, Action action, string helpText)
    {
        var button = new Button
        {
            Text = text,
            Dock = DockStyle.Fill,
            Margin = new Padding(2, 1, 2, 0)
        };
        StyleButton(button);
        EnableButtonInteractiveChrome(button);
        button.AutoEllipsis = true;
        button.Click += (_, _) => action();
        SetToolbarHelp(button, helpText);
        return button;
    }

    private static void EnableButtonInteractiveChrome(Button button)
    {
        button.Cursor = button.Enabled ? Cursors.Hand : Cursors.Default;
        button.MouseEnter += (_, _) =>
        {
            if (button.Enabled)
            {
                button.FlatAppearance.BorderColor = BrandColor;
            }
        };
        button.MouseLeave += (_, _) =>
        {
            button.FlatAppearance.BorderColor = BorderColor;
        };
        button.EnabledChanged += (_, _) =>
        {
            button.Cursor = button.Enabled ? Cursors.Hand : Cursors.Default;
            button.FlatAppearance.BorderColor = BorderColor;
        };
    }

    private static void StyleButton(Button button)
    {
        button.UseVisualStyleBackColor = false;
        button.BackColor = ButtonBackground;
        button.ForeColor = button.Enabled ? PrimaryTextColor : HelpTextColor;
        button.FlatStyle = FlatStyle.Flat;
        button.FlatAppearance.BorderColor = BorderColor;
        button.FlatAppearance.MouseOverBackColor = HeaderBackground;
        button.FlatAppearance.MouseDownBackColor = SelectionBackground;
    }

    private static void StyleToolbarIconButton(ToolbarIconButton button)
    {
        button.NormalBackColor = ButtonBackground;
        button.NormalBorderColor = Color.Empty;
        button.HoverBackColor = Color.Empty;
        button.HoverBorderColor = Color.Empty;
        button.PressedBackColor = Color.Empty;
        button.BackColor = MainBackground;
        button.ForeColor = button.Enabled ? PrimaryTextColor : HelpTextColor;
        button.Invalidate();
    }

    private static void DrawToolbarIcon(Graphics graphics, ToolbarIconKind iconKind, Rectangle bounds, Color color)
    {
        var sx = bounds.Width / 18F;
        var sy = bounds.Height / 18F;
        PointF Point(float x, float y) => new(bounds.Left + (x * sx), bounds.Top + (y * sy));
        RectangleF Rect(float x, float y, float width, float height) =>
            new(bounds.Left + (x * sx), bounds.Top + (y * sy), width * sx, height * sy);

        using var pen = new Pen(color, Math.Max(1.4F, bounds.Width / 10F))
        {
            StartCap = System.Drawing.Drawing2D.LineCap.Round,
            EndCap = System.Drawing.Drawing2D.LineCap.Round,
            LineJoin = System.Drawing.Drawing2D.LineJoin.Round
        };
        using var brush = new SolidBrush(color);

        switch (iconKind)
        {
            case ToolbarIconKind.Open:
                graphics.DrawLines(pen, new[]
                {
                    Point(2.5F, 5.5F),
                    Point(6.5F, 5.5F),
                    Point(8.0F, 7.0F),
                    Point(15.5F, 7.0F),
                    Point(15.5F, 14.5F),
                    Point(2.5F, 14.5F),
                    Point(2.5F, 5.5F)
                });
                graphics.DrawLine(pen, Point(2.5F, 7.0F), Point(15.5F, 7.0F));
                break;

            case ToolbarIconKind.Reload:
                graphics.DrawArc(pen, Rect(3.0F, 3.0F, 12.0F, 12.0F), 35, 285);
                graphics.DrawLines(pen, new[]
                {
                    Point(12.5F, 2.5F),
                    Point(15.5F, 3.5F),
                    Point(14.5F, 6.5F)
                });
                break;

            case ToolbarIconKind.Validate:
                graphics.DrawLines(pen, new[]
                {
                    Point(9.0F, 2.0F),
                    Point(14.5F, 4.5F),
                    Point(13.5F, 11.5F),
                    Point(9.0F, 15.5F),
                    Point(4.5F, 11.5F),
                    Point(3.5F, 4.5F),
                    Point(9.0F, 2.0F)
                });
                graphics.DrawLines(pen, new[]
                {
                    Point(6.0F, 9.0F),
                    Point(8.0F, 11.0F),
                    Point(12.0F, 7.0F)
                });
                break;

            case ToolbarIconKind.Import:
                graphics.DrawLine(pen, Point(9.0F, 2.5F), Point(9.0F, 10.5F));
                graphics.DrawLines(pen, new[]
                {
                    Point(5.5F, 7.5F),
                    Point(9.0F, 11.0F),
                    Point(12.5F, 7.5F)
                });
                graphics.DrawLines(pen, new[]
                {
                    Point(3.0F, 12.0F),
                    Point(3.0F, 15.0F),
                    Point(15.0F, 15.0F),
                    Point(15.0F, 12.0F)
                });
                break;

            case ToolbarIconKind.Install:
                graphics.DrawRectangle(pen, Rect(4.0F, 10.0F, 10.0F, 5.0F));
                graphics.DrawLine(pen, Point(9.0F, 2.5F), Point(9.0F, 9.5F));
                graphics.DrawLines(pen, new[]
                {
                    Point(5.8F, 6.8F),
                    Point(9.0F, 10.0F),
                    Point(12.2F, 6.8F)
                });
                graphics.FillRectangle(brush, Rect(7.0F, 12.0F, 4.0F, 1.5F));
                break;

            case ToolbarIconKind.Restore:
                graphics.DrawArc(pen, Rect(3.0F, 3.0F, 12.0F, 12.0F), 80, 270);
                graphics.DrawLines(pen, new[]
                {
                    Point(4.0F, 4.5F),
                    Point(3.0F, 8.0F),
                    Point(6.5F, 7.2F)
                });
                graphics.DrawLine(pen, Point(9.0F, 6.0F), Point(9.0F, 9.5F));
                graphics.DrawLine(pen, Point(9.0F, 9.5F), Point(11.5F, 11.0F));
                break;

            case ToolbarIconKind.Undo:
                graphics.DrawLines(pen, new[]
                {
                    Point(7.0F, 11.0F),
                    Point(3.2F, 7.2F),
                    Point(7.0F, 3.4F)
                });
                graphics.DrawLine(pen, Point(3.2F, 7.2F), Point(10.8F, 7.2F));
                graphics.DrawLines(pen, new[]
                {
                    Point(10.8F, 7.2F),
                    Point(13.8F, 7.2F),
                    Point(14.9F, 10.0F),
                    Point(14.2F, 12.6F),
                    Point(12.0F, 14.2F),
                    Point(9.2F, 14.2F)
                });
                break;

            case ToolbarIconKind.Save:
                graphics.DrawRectangle(pen, Rect(3.0F, 3.0F, 12.0F, 12.0F));
                graphics.DrawRectangle(pen, Rect(5.0F, 4.5F, 7.0F, 3.5F));
                graphics.DrawLine(pen, Point(6.0F, 13.0F), Point(12.0F, 13.0F));
                break;
        }
    }

    private static Bitmap CreateToolbarIcon(ToolbarIconKind iconKind, Color color)
    {
        var bitmap = new Bitmap(18, 18);
        using var graphics = Graphics.FromImage(bitmap);
        graphics.Clear(Color.Transparent);
        graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
        using var pen = new Pen(color, 1.8F)
        {
            StartCap = System.Drawing.Drawing2D.LineCap.Round,
            EndCap = System.Drawing.Drawing2D.LineCap.Round,
            LineJoin = System.Drawing.Drawing2D.LineJoin.Round
        };
        using var brush = new SolidBrush(color);

        switch (iconKind)
        {
            case ToolbarIconKind.Open:
                graphics.DrawLines(pen, new[]
                {
                    new PointF(2.5F, 5.5F),
                    new PointF(6.5F, 5.5F),
                    new PointF(8.0F, 7.0F),
                    new PointF(15.5F, 7.0F),
                    new PointF(15.5F, 14.5F),
                    new PointF(2.5F, 14.5F),
                    new PointF(2.5F, 5.5F)
                });
                graphics.DrawLine(pen, 2.5F, 7.0F, 15.5F, 7.0F);
                break;

            case ToolbarIconKind.Reload:
                graphics.DrawArc(pen, 3.0F, 3.0F, 12.0F, 12.0F, 35, 285);
                graphics.DrawLines(pen, new[]
                {
                    new PointF(12.5F, 2.5F),
                    new PointF(15.5F, 3.5F),
                    new PointF(14.5F, 6.5F)
                });
                break;

            case ToolbarIconKind.Validate:
                graphics.DrawLines(pen, new[]
                {
                    new PointF(9.0F, 2.0F),
                    new PointF(14.5F, 4.5F),
                    new PointF(13.5F, 11.5F),
                    new PointF(9.0F, 15.5F),
                    new PointF(4.5F, 11.5F),
                    new PointF(3.5F, 4.5F),
                    new PointF(9.0F, 2.0F)
                });
                graphics.DrawLines(pen, new[]
                {
                    new PointF(6.0F, 9.0F),
                    new PointF(8.0F, 11.0F),
                    new PointF(12.0F, 7.0F)
                });
                break;

            case ToolbarIconKind.Import:
                graphics.DrawLine(pen, 9.0F, 2.5F, 9.0F, 10.5F);
                graphics.DrawLines(pen, new[]
                {
                    new PointF(5.5F, 7.5F),
                    new PointF(9.0F, 11.0F),
                    new PointF(12.5F, 7.5F)
                });
                graphics.DrawLines(pen, new[]
                {
                    new PointF(3.0F, 12.0F),
                    new PointF(3.0F, 15.0F),
                    new PointF(15.0F, 15.0F),
                    new PointF(15.0F, 12.0F)
                });
                break;

            case ToolbarIconKind.Install:
                graphics.DrawRectangle(pen, 4.0F, 10.0F, 10.0F, 5.0F);
                graphics.DrawLine(pen, 9.0F, 2.5F, 9.0F, 9.5F);
                graphics.DrawLines(pen, new[]
                {
                    new PointF(5.8F, 6.8F),
                    new PointF(9.0F, 10.0F),
                    new PointF(12.2F, 6.8F)
                });
                graphics.FillRectangle(brush, 7.0F, 12.0F, 4.0F, 1.5F);
                break;

            case ToolbarIconKind.Restore:
                graphics.DrawArc(pen, 3.0F, 3.0F, 12.0F, 12.0F, 80, 270);
                graphics.DrawLines(pen, new[]
                {
                    new PointF(4.0F, 4.5F),
                    new PointF(3.0F, 8.0F),
                    new PointF(6.5F, 7.2F)
                });
                graphics.DrawLine(pen, 9.0F, 6.0F, 9.0F, 9.5F);
                graphics.DrawLine(pen, 9.0F, 9.5F, 11.5F, 11.0F);
                break;

            case ToolbarIconKind.Undo:
                graphics.DrawLines(pen, new[]
                {
                    new PointF(7.0F, 5.0F),
                    new PointF(3.5F, 8.5F),
                    new PointF(7.0F, 12.0F)
                });
                graphics.DrawArc(pen, 5.0F, 5.0F, 10.0F, 8.0F, 185, 235);
                break;

            case ToolbarIconKind.Save:
                graphics.DrawRectangle(pen, 3.0F, 3.0F, 12.0F, 12.0F);
                graphics.DrawRectangle(pen, 5.0F, 4.5F, 7.0F, 3.5F);
                graphics.DrawLine(pen, 6.0F, 13.0F, 12.0F, 13.0F);
                break;
        }

        return bitmap;
    }

    private static void StyleInput(Control control)
    {
        control.BackColor = control is ListBox ? EditorBackground : InputBackground;
        control.ForeColor = PrimaryTextColor;
        if (control is ComboBox comboBox)
        {
            comboBox.DrawItem -= DrawComboBoxItem;
            if (IsDarkPalette())
            {
                comboBox.FlatStyle = FlatStyle.Flat;
                comboBox.DrawMode = DrawMode.OwnerDrawFixed;
                comboBox.DrawItem += DrawComboBoxItem;
            }
            else
            {
                comboBox.FlatStyle = FlatStyle.Popup;
                comboBox.DrawMode = DrawMode.Normal;
            }

            comboBox.Invalidate();
        }
    }

    private static bool IsDarkPalette()
    {
        return MainBackground.GetBrightness() < 0.35f;
    }

    private static void DrawComboBoxItem(object? sender, DrawItemEventArgs args)
    {
        if (sender is not ComboBox comboBox)
        {
            return;
        }

        var selected = (args.State & DrawItemState.Selected) == DrawItemState.Selected;
        var backColor = selected ? SelectionBackground : InputBackground;
        var foreColor = selected ? SelectionText : PrimaryTextColor;
        using var backBrush = new SolidBrush(backColor);
        args.Graphics.FillRectangle(backBrush, args.Bounds);

        var text = args.Index >= 0 && args.Index < comboBox.Items.Count
            ? comboBox.Items[args.Index]?.ToString() ?? ""
            : comboBox.Text;
        TextRenderer.DrawText(
            args.Graphics,
            text,
            comboBox.Font,
            args.Bounds,
            foreColor,
            TextFormatFlags.Left | TextFormatFlags.VerticalCenter | TextFormatFlags.EndEllipsis);

        if ((args.State & DrawItemState.Focus) == DrawItemState.Focus)
        {
            args.DrawFocusRectangle();
        }
    }

    private static void ApplyGridTheme(DataGridView grid)
    {
        grid.BackgroundColor = EditorBackground;
        grid.GridColor = BorderColor;
        grid.BorderStyle = BorderStyle.FixedSingle;
        grid.AllowUserToResizeRows = false;
        grid.AutoSizeRowsMode = DataGridViewAutoSizeRowsMode.None;
        grid.RowTemplate.Resizable = DataGridViewTriState.False;
        grid.EnableHeadersVisualStyles = false;
        grid.DefaultCellStyle.BackColor = EditorBackground;
        grid.DefaultCellStyle.ForeColor = PrimaryTextColor;
        grid.DefaultCellStyle.SelectionBackColor = SelectionBackground;
        grid.DefaultCellStyle.SelectionForeColor = SelectionText;
        grid.AlternatingRowsDefaultCellStyle.BackColor = EditorBackground;
        grid.AlternatingRowsDefaultCellStyle.ForeColor = PrimaryTextColor;
        grid.ColumnHeadersDefaultCellStyle.BackColor = HeaderBackground;
        grid.ColumnHeadersDefaultCellStyle.ForeColor = PrimaryTextColor;
        grid.ColumnHeadersDefaultCellStyle.SelectionBackColor = HeaderBackground;
        grid.ColumnHeadersDefaultCellStyle.SelectionForeColor = PrimaryTextColor;
        grid.RowHeadersDefaultCellStyle.BackColor = HeaderBackground;
        grid.RowHeadersDefaultCellStyle.ForeColor = PrimaryTextColor;
        grid.RowHeadersDefaultCellStyle.SelectionBackColor = HeaderBackground;
        grid.RowHeadersDefaultCellStyle.SelectionForeColor = PrimaryTextColor;
        grid.EditingControlShowing -= ApplyGridEditingControlTheme;
        grid.EditingControlShowing += ApplyGridEditingControlTheme;
        grid.CellMouseClick -= OpenGridComboBoxCellOnFirstClick;
        grid.CellMouseClick += OpenGridComboBoxCellOnFirstClick;
        grid.CellMouseDown -= EditCurrentGridCellOnClick;
        grid.CellMouseDown += EditCurrentGridCellOnClick;
        grid.Enter -= RestoreGridSelectionHighlight;
        grid.Enter += RestoreGridSelectionHighlight;
        grid.MouseDown -= RestoreGridSelectionHighlightOnMouseDown;
        grid.MouseDown += RestoreGridSelectionHighlightOnMouseDown;
        grid.Leave -= HideGridSelectionHighlight;
        grid.Leave += HideGridSelectionHighlight;

        foreach (DataGridViewColumn column in grid.Columns)
        {
            ApplyGridColumnTheme(column);
        }

        foreach (DataGridViewRow row in grid.Rows)
        {
            row.Resizable = DataGridViewTriState.False;
        }

        SetGridSelectionHighlight(grid, grid.Focused);
    }

    private static void StyleListView(ListView listView)
    {
        listView.BackColor = EditorBackground;
        listView.ForeColor = PrimaryTextColor;
        listView.BorderStyle = BorderStyle.FixedSingle;
        listView.OwnerDraw = true;
        listView.DrawColumnHeader -= DrawListViewColumnHeader;
        listView.DrawColumnHeader += DrawListViewColumnHeader;
        listView.DrawItem -= DrawListViewItemDefault;
        listView.DrawItem += DrawListViewItemDefault;
        listView.DrawSubItem -= DrawListViewSubItemDefault;
        listView.DrawSubItem += DrawListViewSubItemDefault;
    }

    private static void DrawListViewColumnHeader(object? sender, DrawListViewColumnHeaderEventArgs e)
    {
        using var fill = new SolidBrush(HeaderBackground);
        using var border = new Pen(BorderColor);
        e.Graphics.FillRectangle(fill, e.Bounds);
        e.Graphics.DrawRectangle(border, e.Bounds.X, e.Bounds.Y, e.Bounds.Width - 1, e.Bounds.Height - 1);

        var textBounds = new Rectangle(e.Bounds.X + 5, e.Bounds.Y, Math.Max(0, e.Bounds.Width - 10), e.Bounds.Height);
        TextRenderer.DrawText(
            e.Graphics,
            e.Header?.Text ?? "",
            e.Font,
            textBounds,
            PrimaryTextColor,
            TextFormatFlags.Left | TextFormatFlags.VerticalCenter | TextFormatFlags.EndEllipsis);
    }

    private static void DrawListViewItemDefault(object? sender, DrawListViewItemEventArgs e)
    {
        e.DrawDefault = true;
    }

    private static void DrawListViewSubItemDefault(object? sender, DrawListViewSubItemEventArgs e)
    {
        e.DrawDefault = true;
    }

    private void HideCurrentGridSelectionHighlights()
    {
        foreach (var grid in EnumerateChildControls<DataGridView>(_formHost))
        {
            EndCurrentGridEdit(grid);
            SetGridSelectionHighlight(grid, focused: false);
        }
    }

    private void HandleBackgroundMouseDown(object? sender, MouseEventArgs args)
    {
        if (args.Button == MouseButtons.Left)
        {
            _formHost.Focus();
            HideCurrentGridSelectionHighlights();
        }
    }

    private void WireBackgroundDehighlightHandlers(Control root)
    {
        foreach (Control child in root.Controls)
        {
            if (IsBackgroundDehighlightControl(child))
            {
                child.MouseDown -= HandleBackgroundMouseDown;
                child.MouseDown += HandleBackgroundMouseDown;
            }

            if (child is not DataGridView)
            {
                WireBackgroundDehighlightHandlers(child);
            }
        }
    }

    private static bool IsBackgroundDehighlightControl(Control control)
    {
        return control is Panel or Label;
    }

    private static void EndCurrentGridEdit(DataGridView grid)
    {
        if (grid.EditingControl is ComboBox comboBox)
        {
            comboBox.DroppedDown = false;
        }

        if (grid.IsCurrentCellDirty)
        {
            grid.CommitEdit(DataGridViewDataErrorContexts.Commit);
        }

        if (grid.IsCurrentCellInEditMode)
        {
            grid.EndEdit(DataGridViewDataErrorContexts.Commit);
        }
    }

    private static IEnumerable<T> EnumerateChildControls<T>(Control root)
        where T : Control
    {
        foreach (Control child in root.Controls)
        {
            if (child is T match)
            {
                yield return match;
            }

            foreach (var nested in EnumerateChildControls<T>(child))
            {
                yield return nested;
            }
        }
    }

    private static void RestoreGridSelectionHighlight(object? sender, EventArgs args)
    {
        if (sender is DataGridView grid)
        {
            SetGridSelectionHighlight(grid, focused: true);
        }
    }

    private static void RestoreGridSelectionHighlightOnMouseDown(object? sender, MouseEventArgs args)
    {
        if (args.Button == MouseButtons.Left)
        {
            RestoreGridSelectionHighlight(sender, args);
        }
    }

    private static void HideGridSelectionHighlight(object? sender, EventArgs args)
    {
        if (sender is DataGridView grid)
        {
            SetGridSelectionHighlight(grid, focused: false);
        }
    }

    private static void SetGridSelectionHighlight(DataGridView grid, bool focused)
    {
        var selectionBackColor = focused ? SelectionBackground : EditorBackground;
        var selectionForeColor = focused ? SelectionText : PrimaryTextColor;
        grid.DefaultCellStyle.SelectionBackColor = selectionBackColor;
        grid.DefaultCellStyle.SelectionForeColor = selectionForeColor;
        grid.AlternatingRowsDefaultCellStyle.SelectionBackColor = selectionBackColor;
        grid.AlternatingRowsDefaultCellStyle.SelectionForeColor = selectionForeColor;

        foreach (DataGridViewColumn column in grid.Columns)
        {
            column.DefaultCellStyle.SelectionBackColor = selectionBackColor;
            column.DefaultCellStyle.SelectionForeColor = selectionForeColor;
        }

        grid.Invalidate();
    }

    private static void ApplyGridColumnTheme(DataGridViewColumn column)
    {
        column.DefaultCellStyle.BackColor = EditorBackground;
        column.DefaultCellStyle.ForeColor = PrimaryTextColor;
        column.DefaultCellStyle.SelectionBackColor = SelectionBackground;
        column.DefaultCellStyle.SelectionForeColor = SelectionText;

        if (column is DataGridViewComboBoxColumn comboColumn)
        {
            comboColumn.FlatStyle = IsDarkPalette() ? FlatStyle.Flat : FlatStyle.Standard;
            comboColumn.DisplayStyle = DataGridViewComboBoxDisplayStyle.DropDownButton;
            comboColumn.DisplayStyleForCurrentCellOnly = false;
        }
    }

    private static void ApplyGridEditingControlTheme(object? sender, DataGridViewEditingControlShowingEventArgs args)
    {
        StyleInput(args.Control);
    }

    private static void OpenGridComboBoxCellOnFirstClick(object? sender, DataGridViewCellMouseEventArgs args)
    {
        if (sender is not DataGridView grid ||
            args.Button != MouseButtons.Left ||
            args.RowIndex < 0 ||
            args.ColumnIndex < 0 ||
            grid.ReadOnly)
        {
            return;
        }

        var cell = grid.Rows[args.RowIndex].Cells[args.ColumnIndex];
        if (grid.Columns[args.ColumnIndex] is not DataGridViewComboBoxColumn &&
            cell is not DataGridViewComboBoxCell)
        {
            return;
        }

        if (cell.ReadOnly)
        {
            return;
        }

        grid.CurrentCell = cell;
        grid.BeginEdit(true);
        if (grid.EditingControl is ComboBox comboBox)
        {
            comboBox.DroppedDown = true;
        }
    }

    private static void EditCurrentGridCellOnClick(object? sender, DataGridViewCellMouseEventArgs args)
    {
        if (sender is not DataGridView grid ||
            args.Button != MouseButtons.Left ||
            args.RowIndex < 0 ||
            args.ColumnIndex < 0 ||
            grid.ReadOnly ||
            grid.IsCurrentCellInEditMode ||
            grid.CurrentCell is null ||
            grid.CurrentCell.RowIndex != args.RowIndex ||
            grid.CurrentCell.ColumnIndex != args.ColumnIndex)
        {
            return;
        }

        var cell = grid.Rows[args.RowIndex].Cells[args.ColumnIndex];
        if (cell.ReadOnly || grid.Columns[args.ColumnIndex].ReadOnly)
        {
            return;
        }

        if (grid.Columns[args.ColumnIndex] is DataGridViewComboBoxColumn ||
            cell is DataGridViewComboBoxCell)
        {
            return;
        }

        grid.BeginEdit(true);
    }

    private static void StyleTabControl(TabControl tabControl)
    {
        tabControl.BackColor = MainBackground;
        tabControl.DrawItem -= DrawTabControlItem;
        if (IsDarkPalette())
        {
            tabControl.DrawMode = TabDrawMode.OwnerDrawFixed;
            tabControl.DrawItem += DrawTabControlItem;
        }
        else
        {
            tabControl.DrawMode = TabDrawMode.Normal;
        }

        foreach (TabPage page in tabControl.TabPages)
        {
            page.BackColor = MainBackground;
            page.ForeColor = PrimaryTextColor;
            page.UseVisualStyleBackColor = false;
        }
    }

    private static void DrawTabControlItem(object? sender, DrawItemEventArgs args)
    {
        if (sender is not TabControl tabControl || args.Index < 0 || args.Index >= tabControl.TabPages.Count)
        {
            return;
        }

        var selected = args.Index == tabControl.SelectedIndex;
        var backColor = selected ? InputBackground : MainBackground;
        var foreColor = selected ? PrimaryTextColor : HelpTextColor;
        var bounds = args.Bounds;
        using var backBrush = new SolidBrush(backColor);
        args.Graphics.FillRectangle(backBrush, bounds);

        TextRenderer.DrawText(
            args.Graphics,
            tabControl.TabPages[args.Index].Text,
            tabControl.Font,
            bounds,
            foreColor,
            TextFormatFlags.HorizontalCenter | TextFormatFlags.VerticalCenter | TextFormatFlags.EndEllipsis);

        using var borderPen = new Pen(BorderColor);
        args.Graphics.DrawRectangle(borderPen, bounds.X, bounds.Y, bounds.Width - 1, bounds.Height - 1);
    }

    private void HandleBrandClick()
    {
        var now = DateTime.UtcNow;
        if ((now - _lastBrandClickUtc).TotalMilliseconds > 1200)
        {
            _brandClickCount = 0;
        }

        _lastBrandClickUtc = now;
        _brandClickCount++;
        if (_brandClickCount < 3)
        {
            return;
        }

        _brandClickCount = 0;
        UnlockAdminDesigner();
    }

    private void UnlockAdminDesigner()
    {
        if (AppMode.IsExportedUserBuild)
        {
            MessageBox.Show(this, "Admin Designer is not included in this exported user build.", "Admin Designer", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

        if (_adminUnlocked)
        {
            SelectCategory("Admin Designer");
            return;
        }

        var password = PromptForAdminPassword();
        if (password is null)
        {
            return;
        }

        if (!password.Equals(AdminPassword, StringComparison.Ordinal))
        {
            MessageBox.Show(this, "Wrong admin password.", "Admin Designer", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return;
        }

        _adminUnlocked = true;
        ReloadCategoriesPreservingSelection();
        SelectCategory("Admin Designer");
        SetStatus("Admin Designer unlocked.");
    }

    private string? PromptForAdminPassword()
    {
        using var dialog = new Form
        {
            Text = "Admin Designer",
            StartPosition = FormStartPosition.CenterParent,
            FormBorderStyle = FormBorderStyle.FixedDialog,
            MinimizeBox = false,
            MaximizeBox = false,
            ClientSize = new Size(340, 118),
            Font = Font
        };

        var label = new Label
        {
            Text = "Password",
            AutoSize = true,
            Location = new Point(12, 14)
        };
        dialog.Controls.Add(label);

        var passwordBox = new TextBox
        {
            Location = new Point(12, 36),
            Width = 316,
            UseSystemPasswordChar = true
        };
        dialog.Controls.Add(passwordBox);

        var okButton = new Button
        {
            Text = "OK",
            DialogResult = DialogResult.OK,
            Location = new Point(166, 76),
            Width = 76
        };
        dialog.Controls.Add(okButton);

        var cancelButton = new Button
        {
            Text = "Cancel",
            DialogResult = DialogResult.Cancel,
            Location = new Point(252, 76),
            Width = 76
        };
        dialog.Controls.Add(cancelButton);

        dialog.AcceptButton = okButton;
        dialog.CancelButton = cancelButton;
        dialog.Shown += (_, _) => passwordBox.Focus();
        return dialog.ShowDialog(this) == DialogResult.OK ? passwordBox.Text : null;
    }

    private Control BuildFilterBar()
    {
        var panel = new TableLayoutPanel { Dock = DockStyle.Fill, ColumnCount = 10, BackColor = MainBackground };
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 70));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 34));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 75));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 26));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 105));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 110));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 80));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 40));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 95));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 95));

        panel.Controls.Add(MakeLabel("Search"), 0, 0);
        _searchBox.Dock = DockStyle.Fill;
        StyleInput(_searchBox);
        _searchBox.TextChanged += (_, _) => RefreshGrid();
        panel.Controls.Add(_searchBox, 1, 0);

        panel.Controls.Add(MakeLabel("Section"), 2, 0);
        _sectionFilter.Dock = DockStyle.Fill;
        _sectionFilter.DropDownStyle = ComboBoxStyle.DropDownList;
        StyleInput(_sectionFilter);
        _sectionFilter.SelectedIndexChanged += (_, _) => RefreshGrid();
        panel.Controls.Add(_sectionFilter, 3, 0);

        _changedOnly.Text = "Changed only";
        _changedOnly.Dock = DockStyle.Fill;
        _changedOnly.CheckedChanged += (_, _) => RefreshGrid();
        panel.Controls.Add(_changedOnly, 4, 0);

        _showAdvanced.Text = "Advanced";
        _showAdvanced.Dock = DockStyle.Fill;
        BindAdvancedToggle();
        panel.Controls.Add(_showAdvanced, 5, 0);

        panel.Controls.Add(MakeLabel("Preset"), 6, 0);
        _presetBox.Dock = DockStyle.Fill;
        StyleInput(_presetBox);
        panel.Controls.Add(_presetBox, 7, 0);
        panel.Controls.Add(MakeButton("Apply", ApplyPreset), 8, 0);
        panel.Controls.Add(MakeButton("Save Preset", SavePreset), 9, 0);
        return panel;
    }

    private Control BuildMainArea()
    {
        var split = new SplitContainer
        {
            Dock = DockStyle.Fill,
            SplitterDistance = Zoomed(250),
            FixedPanel = FixedPanel.Panel1,
            BackColor = BorderColor
        };
        _mainSplit = split;

        var leftRail = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 1,
            RowCount = 2,
            BackColor = MainBackground,
            Padding = new Padding(0)
        };
        leftRail.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        leftRail.RowStyles.Add(new RowStyle(SizeType.AutoSize));

        _categoryList.Dock = DockStyle.Fill;
        _categoryList.BorderStyle = BorderStyle.FixedSingle;
        _categoryList.DrawMode = DrawMode.OwnerDrawFixed;
        _categoryList.IntegralHeight = false;
        ApplyCategoryListSizing();
        StyleInput(_categoryList);
        _categoryList.DrawItem += DrawCategoryListItem;
        _categoryList.MouseEnter += (_, _) => _categoryList.Invalidate();
        _categoryList.MouseLeave += (_, _) => _categoryList.Invalidate();
        _categoryList.GotFocus += (_, _) => _categoryList.Invalidate();
        _categoryList.LostFocus += (_, _) => _categoryList.Invalidate();
        _categoryList.SelectedIndexChanged += (_, _) =>
        {
            if (!_loadingCategories)
            {
                PrepareImportedNewMarkersForCategory(GetSelectedCategoryName());
                RenderSelectedCategory();
            }
        };
        split.Panel1.BackColor = MainBackground;
        leftRail.Controls.Add(_categoryList, 0, 0);
        leftRail.Controls.Add(BuildLeftToolsPanel(), 0, 1);
        split.Panel1.Controls.Add(leftRail);

        _formHost.Dock = DockStyle.Fill;
        _formHost.AutoScroll = true;
        _formHost.BackColor = MainBackground;
        _formHost.MouseDown += HandleBackgroundMouseDown;
        split.Panel2.BackColor = MainBackground;
        split.Panel2.Controls.Add(_formHost);
        return split;
    }

    private Control BuildLeftToolsPanel()
    {
        var panel = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            AutoSize = true,
            ColumnCount = 1,
            RowCount = 5,
            BackColor = EditorBackground,
            Padding = new Padding(0, Zoomed(5), 0, Zoomed(6)),
            Margin = new Padding(0)
        };
        _leftToolsPanel = panel;
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(6)));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(34)));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(34)));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(34)));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(34)));

        panel.Controls.Add(new Panel
        {
            Dock = DockStyle.Fill,
            BackColor = BorderColor,
            Margin = new Padding(0, 0, 0, Zoomed(4))
        }, 0, 0);

        _dcsDesanitizeButton = MakeLeftToolButton("MissionScripting", ShowDcsDesanitizeDialog, "Required for mission persistence/save files.");
        panel.Controls.Add(_dcsDesanitizeButton, 0, 1);
        panel.Controls.Add(BuildLeftToolModeRow(), 0, 2);
        panel.Controls.Add(BuildLeftToolZoomRow(), 0, 3);
        panel.Controls.Add(BuildLeftToolLinkRow(), 0, 4);
        return panel;
    }

    private Control BuildLeftToolModeRow()
    {
        var row = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 1,
            BackColor = EditorBackground,
            Margin = new Padding(0)
        };
        row.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));

        _themeModeButton = MakeLeftToolButton(_darkMode ? "Dark mode" : "Light mode", ToggleTheme, _darkMode ? "Switch to light mode." : "Switch to dark mode.");
        row.Controls.Add(_themeModeButton, 0, 0);
        return row;
    }

    private Control BuildLeftToolZoomRow()
    {
        var row = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 3,
            BackColor = EditorBackground,
            Margin = new Padding(0)
        };
        row.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 33.33F));
        row.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 33.34F));
        row.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 33.33F));

        row.Controls.Add(MakeStatusZoomButton("A-", ZoomOut, "Make manager text smaller."), 0, 0);
        _zoomLabel.TextAlign = ContentAlignment.MiddleCenter;
        _zoomLabel.Dock = DockStyle.Fill;
        _zoomLabel.Margin = new Padding(0);
        _zoomLabel.AutoEllipsis = true;
        _zoomLabel.ForeColor = PrimaryTextColor;
        _zoomLabel.BackColor = EditorBackground;
        SetToolbarHelp(_zoomLabel, "Current manager text zoom.");
        UpdateZoomLabel();
        row.Controls.Add(_zoomLabel, 1, 0);
        row.Controls.Add(MakeStatusZoomButton("A+", ZoomIn, "Make manager text larger."), 2, 0);
        _zoomLayout = row;
        return row;
    }

    private Control BuildLeftToolLinkRow()
    {
        var row = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 1,
            BackColor = EditorBackground,
            Margin = new Padding(0)
        };
        row.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        row.Controls.Add(MakeLeftToolButton("About", ShowAboutDialog, "Show app version, author, Discord, and GitHub."), 0, 0);
        return row;
    }

    private Button MakeLeftToolButton(string text, Action action, string helpText)
    {
        var button = MakeButton(text, action);
        button.Dock = DockStyle.Fill;
        button.Margin = new Padding(Zoomed(2), Zoomed(2), Zoomed(2), Zoomed(2));
        button.TextAlign = ContentAlignment.MiddleCenter;
        EnableButtonInteractiveChrome(button);
        SetToolbarHelp(button, helpText);
        return button;
    }

    private void ApplyCategoryListSizing()
    {
        var targetSize = (BaseFontSize + 1F) * _uiZoomPercent / 100F;
        if (Math.Abs(_categoryList.Font.Size - targetSize) > 0.05F)
        {
            _categoryList.Font = new Font("Segoe UI", targetSize);
        }

        _categoryList.ItemHeight = Math.Max(Zoomed(28), _categoryList.Font.Height + Zoomed(10));
    }

    private void DrawCategoryListItem(object? sender, DrawItemEventArgs args)
    {
        if (sender is not ListBox list || args.Index < 0 || args.Index >= list.Items.Count)
        {
            return;
        }

        var selected = (args.State & DrawItemState.Selected) == DrawItemState.Selected;
        var focused = (args.State & DrawItemState.Focus) == DrawItemState.Focus;
        var backColor = selected
            ? (IsDarkPalette() ? Color.FromArgb(28, 49, 56) : SelectionBackground)
            : EditorBackground;
        var textColor = selected ? SelectionText : PrimaryTextColor;

        using var backBrush = new SolidBrush(backColor);
        args.Graphics.FillRectangle(backBrush, args.Bounds);

        if (selected)
        {
            using var accentBrush = new SolidBrush(SelectionBackground);
            args.Graphics.FillRectangle(
                accentBrush,
                args.Bounds.X,
                args.Bounds.Y,
                Math.Max(Zoomed(3), 2),
                args.Bounds.Height);
        }

        var itemName = GetCategoryItemName(list.Items[args.Index]);
        var displayText = list.Items[args.Index]?.ToString() ?? "";
        var hasNewMarker = HasUnseenImportedNewEntries(itemName);
        var textBounds = new Rectangle(
            args.Bounds.X + Zoomed(8),
            args.Bounds.Y,
            Math.Max(0, args.Bounds.Width - Zoomed(12)),
            args.Bounds.Height);
        if (hasNewMarker)
        {
            var badgeText = "NEW";
            var badgeSize = TextRenderer.MeasureText(args.Graphics, badgeText, args.Font);
            var badgeWidth = badgeSize.Width + Zoomed(12);
            var badgeHeight = Math.Min(args.Bounds.Height - Zoomed(8), badgeSize.Height + Zoomed(4));
            var badgeBounds = new Rectangle(
                args.Bounds.Right - badgeWidth - Zoomed(8),
                args.Bounds.Y + Math.Max(0, (args.Bounds.Height - badgeHeight) / 2),
                badgeWidth,
                badgeHeight);
            textBounds.Width = Math.Max(0, badgeBounds.Left - textBounds.Left - Zoomed(6));

            using var badgeBrush = new SolidBrush(GetNewBadgeBackColor());
            using var badgePen = new Pen(GetNewBadgeBorderColor());
            args.Graphics.FillRectangle(badgeBrush, badgeBounds);
            args.Graphics.DrawRectangle(badgePen, badgeBounds);
            TextRenderer.DrawText(
                args.Graphics,
                badgeText,
                args.Font,
                badgeBounds,
                GetNewBadgeTextColor(),
                TextFormatFlags.HorizontalCenter | TextFormatFlags.VerticalCenter | TextFormatFlags.NoPadding);
        }

        TextRenderer.DrawText(
            args.Graphics,
            displayText,
            args.Font,
            textBounds,
            textColor,
            TextFormatFlags.Left | TextFormatFlags.VerticalCenter | TextFormatFlags.EndEllipsis);

        if (focused)
        {
            using var focusPen = new Pen(BorderColor);
            var focusBounds = args.Bounds;
            focusBounds.Width -= 1;
            focusBounds.Height -= 1;
            args.Graphics.DrawRectangle(focusPen, focusBounds);
        }
    }

    private static Color GetNewHighlightBackColor()
    {
        return IsDarkPalette() ? Color.FromArgb(42, 56, 46) : Color.FromArgb(221, 247, 231);
    }

    private static Color GetNewBadgeBackColor()
    {
        return IsDarkPalette() ? Color.FromArgb(30, 96, 68) : Color.FromArgb(187, 247, 208);
    }

    private static Color GetNewBadgeBorderColor()
    {
        return IsDarkPalette() ? Color.FromArgb(74, 222, 128) : Color.FromArgb(34, 197, 94);
    }

    private static Color GetNewBadgeTextColor()
    {
        return IsDarkPalette() ? Color.FromArgb(220, 252, 231) : Color.FromArgb(20, 83, 45);
    }

    private void ConfigureGrid()
    {
        if (_gridConfigured)
        {
            return;
        }

        _gridConfigured = true;
        _grid.Dock = DockStyle.Fill;
        _grid.AllowUserToAddRows = false;
        _grid.AllowUserToDeleteRows = false;
        _grid.ReadOnly = true;
        _grid.MultiSelect = false;
        _grid.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
        _grid.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
        _grid.RowHeadersVisible = false;
        _grid.Columns.Clear();
        _grid.Columns.Add("section", "Section");
        _grid.Columns.Add("key", "Key");
        _grid.Columns.Add("value", "Value");
        _grid.Columns.Add("type", "Type");
        _grid.Columns.Add("comment", "Comment");
        _grid.Columns["section"].FillWeight = 22;
        _grid.Columns["key"].FillWeight = 35;
        _grid.Columns["value"].FillWeight = 18;
        _grid.Columns["type"].FillWeight = 12;
        _grid.Columns["comment"].FillWeight = 38;
        ApplyGridTheme(_grid);
        _grid.SelectionChanged += (_, _) => SelectGridEntry();
        _grid.CellDoubleClick += (_, _) => _valueBox.Focus();
    }

    private Control BuildDetailsPanel()
    {
        var panel = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 1,
            RowCount = 10,
            Padding = new Padding(10),
            BackColor = MainBackground
        };
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 22));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 30));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 22));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 30));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 22));
        panel.RowStyles.Add(new RowStyle(SizeType.Percent, 45));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 22));
        panel.RowStyles.Add(new RowStyle(SizeType.Percent, 35));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 38));
        panel.RowStyles.Add(new RowStyle(SizeType.Percent, 20));

        panel.Controls.Add(MakeLabel("Key"), 0, 0);
        _keyBox.Dock = DockStyle.Fill;
        _keyBox.ReadOnly = true;
        StyleInput(_keyBox);
        panel.Controls.Add(_keyBox, 0, 1);

        panel.Controls.Add(MakeLabel("Section"), 0, 2);
        _sectionBox.Dock = DockStyle.Fill;
        _sectionBox.ReadOnly = true;
        StyleInput(_sectionBox);
        panel.Controls.Add(_sectionBox, 0, 3);

        panel.Controls.Add(MakeLabel("Comments"), 0, 4);
        _descriptionBox.Dock = DockStyle.Fill;
        _descriptionBox.Multiline = true;
        _descriptionBox.ScrollBars = ScrollBars.Vertical;
        _descriptionBox.ReadOnly = true;
        _descriptionBox.BackColor = EditorBackground;
        _descriptionBox.ForeColor = HelpTextColor;
        panel.Controls.Add(_descriptionBox, 0, 5);

        panel.Controls.Add(MakeLabel("Value"), 0, 6);
        var valuePanel = new Panel { Dock = DockStyle.Fill, BackColor = MainBackground };
        _valueBox.Dock = DockStyle.Fill;
        _valueBox.Multiline = true;
        _valueBox.ScrollBars = ScrollBars.Vertical;
        StyleInput(_valueBox);
        _choiceBox.Dock = DockStyle.Top;
        StyleInput(_choiceBox);
        _choiceBox.SelectedIndexChanged += (_, _) => ApplyChoiceChange();
        _boolBox.Dock = DockStyle.Top;
        _boolBox.CheckedChanged += (_, _) => ApplyBoolChange();
        ConfigureMultiplierPanel();
        ConfigureTuplePanel();
        valuePanel.Controls.Add(_valueBox);
        valuePanel.Controls.Add(_choiceBox);
        valuePanel.Controls.Add(_boolBox);
        valuePanel.Controls.Add(_multiplierPanel);
        valuePanel.Controls.Add(_tuplePanel);
        panel.Controls.Add(valuePanel, 0, 7);

        var buttons = new FlowLayoutPanel { Dock = DockStyle.Fill, FlowDirection = FlowDirection.RightToLeft, BackColor = MainBackground };
        buttons.Controls.Add(MakeButton("Apply Value", ApplyEntryValue));
        buttons.Controls.Add(MakeButton("Reset Value", ResetEntryValue));
        panel.Controls.Add(buttons, 0, 8);
        return panel;
    }

    private void ConfigureMultiplierPanel()
    {
        _multiplierPanel.Dock = DockStyle.Fill;
        _multiplierPanel.BackColor = MainBackground;
        _multiplierPanel.Visible = false;
        _multiplierPanel.ColumnCount = 3;
        _multiplierPanel.RowCount = 2;
        _multiplierPanel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 55));
        _multiplierPanel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 90));
        _multiplierPanel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        _multiplierPanel.RowStyles.Add(new RowStyle(SizeType.Absolute, 34));
        _multiplierPanel.RowStyles.Add(new RowStyle(SizeType.Absolute, 34));

        ConfigureMultiplierInput(_redMultiplier, _redMultiplierText);
        ConfigureMultiplierInput(_blueMultiplier, _blueMultiplierText);
        _redMultiplier.ValueChanged += (_, _) => UpdateMultiplierText();
        _blueMultiplier.ValueChanged += (_, _) => UpdateMultiplierText();

        _multiplierPanel.Controls.Add(MakeLabel("RED"), 0, 0);
        _multiplierPanel.Controls.Add(_redMultiplier, 1, 0);
        _multiplierPanel.Controls.Add(_redMultiplierText, 2, 0);
        _multiplierPanel.Controls.Add(MakeLabel("BLUE"), 0, 1);
        _multiplierPanel.Controls.Add(_blueMultiplier, 1, 1);
        _multiplierPanel.Controls.Add(_blueMultiplierText, 2, 1);
    }

    private static void ConfigureMultiplierInput(NumericUpDown input, Label label)
    {
        input.Dock = DockStyle.Fill;
        input.DecimalPlaces = 2;
        input.Increment = 0.05m;
        input.Minimum = 0.1m;
        input.Maximum = 5m;
        label.Dock = DockStyle.Fill;
        label.TextAlign = ContentAlignment.MiddleLeft;
        label.ForeColor = HelpTextColor;
    }

    private void ConfigureTuplePanel()
    {
        _tuplePanel.Dock = DockStyle.Fill;
        _tuplePanel.BackColor = MainBackground;
        _tuplePanel.Visible = false;
        _tuplePanel.AutoScroll = true;
        _tuplePanel.ColumnCount = 2;
        _tuplePanel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 150));
        _tuplePanel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
    }

    private static Label MakeLabel(string text)
    {
        return new Label
        {
            Text = text,
            TextAlign = ContentAlignment.MiddleLeft,
            Dock = DockStyle.Fill,
            ForeColor = PrimaryTextColor,
            BackColor = MainBackground
        };
    }

    private static Button MakeButton(string text, Action action)
    {
        var button = new Button
        {
            Text = text,
            Dock = DockStyle.Fill,
            Margin = new Padding(3),
            AutoEllipsis = true
        };
        StyleButton(button);
        button.Click += (_, _) => action();
        return button;
    }

    private void LoadDefaultConfig()
    {
        var path = _settings.FindRememberedConfig();
        if (path is not null)
        {
            LoadConfig(path);
            return;
        }

        var savedGamesConfigs = RuntimeSettings.FindSavedGamesConfigs();
        if (savedGamesConfigs.Count == 1)
        {
            LoadConfig(savedGamesConfigs[0]);
            return;
        }

        if (savedGamesConfigs.Count > 1)
        {
            var result = PromptForConfigPath(savedGamesConfigs);
            path = result.Path;
            if (result.AddAll)
            {
                var added = AddDetectedInstances(savedGamesConfigs, path);
                if (path is not null)
                {
                    LoadConfig(path);
                    SetStatus("Added " + added.ToString(CultureInfo.InvariantCulture) + " detected instance(s).");
                    return;
                }
            }

            if (path is not null)
            {
                LoadConfig(path);
                return;
            }

            SetStatus("Multiple Foothold configs found. Use Open to select one.");
            return;
        }

        path = AppMode.IsExportedUserBuild ? null : ConfigDocument.FindDefaultConfig();
        if (path is null)
        {
            var install = PromptForFirstRunInstall();
            if (install is not null && InstallInitialConfigFromMiz(install.Value.MizPath, install.Value.Instance))
            {
                return;
            }

            SetStatus("Foothold Config.lua was not found. Use Open, or restart and install from a Foothold MIZ.");
            return;
        }

        LoadConfig(path);
    }

    private (string MizPath, FirstRunInstanceCandidate Instance)? PromptForFirstRunInstall()
    {
        var mizCandidates = FindFirstRunMizCandidates();
        var instanceCandidates = FindFirstRunInstanceCandidates();
        string? selectedMizPath = null;
        FirstRunInstanceCandidate? selectedInstance = null;

        using var dialog = new Form
        {
            Text = "Install Foothold Config",
            StartPosition = FormStartPosition.CenterParent,
            FormBorderStyle = FormBorderStyle.Sizable,
            MinimizeBox = false,
            MaximizeBox = true,
            ClientSize = new Size(900, 560),
            MinimumSize = new Size(760, 500),
            Font = Font,
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        };

        var root = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 1,
            RowCount = 6,
            Padding = new Padding(12),
            BackColor = MainBackground
        };
        root.RowStyles.Add(new RowStyle(SizeType.Absolute, 54));
        root.RowStyles.Add(new RowStyle(SizeType.Percent, 42));
        root.RowStyles.Add(new RowStyle(SizeType.Absolute, 12));
        root.RowStyles.Add(new RowStyle(SizeType.Percent, 42));
        root.RowStyles.Add(new RowStyle(SizeType.Absolute, 54));
        root.RowStyles.Add(new RowStyle(SizeType.Absolute, 48));
        dialog.Controls.Add(root);

        root.Controls.Add(new Label
        {
            Text = "No Foothold Config.lua is configured yet. Choose the Foothold mission MIZ, then choose the DCS/Saved Games instance to install into.",
            Dock = DockStyle.Fill,
            ForeColor = PrimaryTextColor
        }, 0, 0);

        var mizPanel = BuildFirstRunChoicePanel("Foothold MIZ", out var mizList, out var browseMizButton);
        root.Controls.Add(mizPanel, 0, 1);
        foreach (var candidate in mizCandidates)
        {
            mizList.Items.Add(candidate);
        }

        var instancePanel = BuildFirstRunChoicePanel("DCS / Saved Games instance", out var instanceList, out var browseInstanceButton);
        root.Controls.Add(instancePanel, 0, 3);
        foreach (var candidate in instanceCandidates)
        {
            instanceList.Items.Add(candidate);
        }

        var targetLabel = new Label
        {
            Dock = DockStyle.Fill,
            ForeColor = HelpTextColor,
            AutoEllipsis = true
        };
        root.Controls.Add(targetLabel, 0, 4);

        var buttons = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            FlowDirection = FlowDirection.RightToLeft,
            WrapContents = false,
            Padding = new Padding(0, 8, 0, 0),
            BackColor = MainBackground
        };
        var installButton = new Button
        {
            Text = "Install",
            DialogResult = DialogResult.OK,
            Width = 100,
            Enabled = false
        };
        var cancelButton = new Button
        {
            Text = "Cancel",
            DialogResult = DialogResult.Cancel,
            Width = 100
        };
        buttons.Controls.Add(cancelButton);
        buttons.Controls.Add(installButton);
        root.Controls.Add(buttons, 0, 5);

        void UpdateSelection()
        {
            selectedMizPath = mizList.SelectedItem is FirstRunMizCandidate miz ? miz.Path : selectedMizPath;
            selectedInstance = instanceList.SelectedItem as FirstRunInstanceCandidate ?? selectedInstance;
            targetLabel.Text = selectedInstance is null
                ? "Target: choose an instance."
                : "Target folder: " + selectedInstance.SavesPath;
            installButton.Enabled = !string.IsNullOrWhiteSpace(selectedMizPath) && selectedInstance is not null;
        }

        mizList.SelectedIndexChanged += (_, _) => UpdateSelection();
        instanceList.SelectedIndexChanged += (_, _) => UpdateSelection();
        browseMizButton.Click += (_, _) =>
        {
            using var fileDialog = new OpenFileDialog
            {
                Title = "Select Foothold mission MIZ",
                Filter = "DCS mission (*.miz)|*.miz|All files (*.*)|*.*",
                FileName = "*.miz",
                InitialDirectory = GetExistingInitialDirectory(selectedMizPath) ?? RuntimeSettings.GetBestInitialDirectory()
            };
            if (fileDialog.ShowDialog(dialog) != DialogResult.OK)
            {
                return;
            }

            var fullPath = Path.GetFullPath(fileDialog.FileName);
            var candidate = new FirstRunMizCandidate(fullPath, File.GetLastWriteTime(fullPath));
            AddOrSelectListItem(mizList, candidate, item => item.Path.Equals(fullPath, StringComparison.OrdinalIgnoreCase));
            UpdateSelection();
        };
        browseInstanceButton.Click += (_, _) =>
        {
            using var folderDialog = new FolderBrowserDialog
            {
                Description = "Select the DCS Saved Games instance folder",
                SelectedPath = RuntimeSettings.GetBestInitialDirectory()
            };
            if (folderDialog.ShowDialog(dialog) != DialogResult.OK)
            {
                return;
            }

            if (IsLikelySavedGamesRoot(folderDialog.SelectedPath))
            {
                MessageBox.Show(dialog, "Select an instance folder inside Saved Games, such as Dedicated1, DCS, or DCS.dcs_serverrelease.", "Install Foothold Config", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }

            var candidate = BuildCustomInstanceCandidate(folderDialog.SelectedPath);
            AddOrSelectListItem(instanceList, candidate, item => item.ProfilePath.Equals(candidate.ProfilePath, StringComparison.OrdinalIgnoreCase));
            UpdateSelection();
        };

        if (mizList.Items.Count > 0)
        {
            mizList.SelectedIndex = 0;
        }

        if (instanceList.Items.Count > 0)
        {
            instanceList.SelectedIndex = 0;
        }

        UpdateSelection();
        dialog.AcceptButton = installButton;
        dialog.CancelButton = cancelButton;
        ApplyThemeToControl(dialog, restyleButtons: true);
        ApplyDialogChrome(dialog);
        return dialog.ShowDialog(this) == DialogResult.OK && selectedMizPath is not null && selectedInstance is not null
            ? (selectedMizPath, selectedInstance)
            : null;
    }

    private static TableLayoutPanel BuildFirstRunChoicePanel(string title, out ListBox list, out Button browseButton)
    {
        var panel = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 2,
            RowCount = 2,
            BackColor = MainBackground
        };
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 110));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 26));
        panel.RowStyles.Add(new RowStyle(SizeType.Percent, 100));

        panel.Controls.Add(new Label
        {
            Text = title,
            Dock = DockStyle.Fill,
            ForeColor = PrimaryTextColor
        }, 0, 0);

        browseButton = new Button
        {
            Text = "Browse...",
            Dock = DockStyle.Fill
        };
        panel.Controls.Add(browseButton, 1, 0);

        list = new ListBox
        {
            Dock = DockStyle.Fill,
            IntegralHeight = false,
            HorizontalScrollbar = true
        };
        panel.Controls.Add(list, 0, 1);
        panel.SetColumnSpan(list, 2);
        return panel;
    }

    private static string? GetExistingInitialDirectory(string? path)
    {
        if (string.IsNullOrWhiteSpace(path))
        {
            return null;
        }

        var directory = File.Exists(path) ? Path.GetDirectoryName(path) : path;
        return !string.IsNullOrWhiteSpace(directory) && Directory.Exists(directory)
            ? directory
            : null;
    }

    private static void AddOrSelectListItem<T>(ListBox list, T item, Func<T, bool> predicate)
    {
        for (var i = 0; i < list.Items.Count; i++)
        {
            if (list.Items[i] is T existing && predicate(existing))
            {
                list.SelectedIndex = i;
                return;
            }
        }

        list.Items.Insert(0, item!);
        list.SelectedIndex = 0;
    }

    private void OpenConfig()
    {
        using var dialog = new OpenFileDialog
        {
            Filter = "Lua config (*.lua)|*.lua|All files (*.*)|*.*",
            FileName = GetCurrentConfigFileName(_document),
            InitialDirectory = _document is null
                ? GetInitialOpenDirectory()
                : Path.GetDirectoryName(_document.Path)
        };

        if (dialog.ShowDialog(this) == DialogResult.OK)
        {
            LoadConfig(dialog.FileName);
        }
    }

    private string GetInitialOpenDirectory()
    {
        var remembered = _settings.FindRememberedConfig();
        if (!string.IsNullOrWhiteSpace(remembered))
        {
            return Path.GetDirectoryName(remembered) ?? RuntimeSettings.GetBestInitialDirectory();
        }

        return RuntimeSettings.GetBestInitialDirectory();
    }

    private static bool IsSupportedConfigFileName(string fileName)
    {
        return RuntimeSettings.SupportedConfigFileNames
            .Any(supported => supported.Equals(fileName, StringComparison.OrdinalIgnoreCase));
    }

    private static string GetCurrentConfigFileName(ConfigDocument? document)
    {
        if (document is null)
        {
            return RuntimeSettings.DefaultConfigFileName;
        }

        var fileName = Path.GetFileName(document.Path);
        return IsSupportedConfigFileName(fileName)
            ? fileName
            : RuntimeSettings.DefaultConfigFileName;
    }

    private static string GetConfigVariantLabel(string pathOrFileName)
    {
        var fileName = Path.GetFileName(pathOrFileName);
        if (fileName.Equals(RuntimeSettings.Ww2ConfigFileName, StringComparison.OrdinalIgnoreCase))
        {
            return "WW2";
        }

        if (fileName.Equals(RuntimeSettings.DefaultConfigFileName, StringComparison.OrdinalIgnoreCase))
        {
            return "Normal";
        }

        return fileName;
    }

    private static List<string> GetSiblingConfigPaths(string configPath)
    {
        var directory = Path.GetDirectoryName(configPath);
        if (string.IsNullOrWhiteSpace(directory))
        {
            return new List<string>();
        }

        return RuntimeSettings.SupportedConfigFileNames
            .Select(fileName => Path.Combine(directory, fileName))
            .Where(File.Exists)
            .Select(Path.GetFullPath)
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .OrderBy(path => path.EndsWith(RuntimeSettings.DefaultConfigFileName, StringComparison.OrdinalIgnoreCase) ? 0 : 1)
            .ToList();
    }

    private static string GetSiblingConfigPath(string configPath, string configFileName)
    {
        var directory = Path.GetDirectoryName(configPath);
        if (string.IsNullOrWhiteSpace(directory))
        {
            throw new InvalidOperationException("The current config path is invalid.");
        }

        return Path.GetFullPath(Path.Combine(directory, configFileName));
    }

    private static string GetConfigFamilyKey(string configPath)
    {
        var fullPath = Path.GetFullPath(configPath);
        return IsSupportedConfigFileName(Path.GetFileName(fullPath))
            ? Path.GetDirectoryName(fullPath) ?? fullPath
            : fullPath;
    }

    private (string? Path, bool AddAll) PromptForConfigPath(List<string> paths)
    {
        using var dialog = new Form
        {
            Text = "Select Foothold Config",
            StartPosition = FormStartPosition.CenterParent,
            FormBorderStyle = FormBorderStyle.FixedDialog,
            MinimizeBox = false,
            MaximizeBox = false,
            ClientSize = new Size(720, 330),
            Font = Font,
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        };
        var addAll = false;

        var label = new Label
        {
            Text = "Multiple Foothold Config.lua files were found. Select the one to edit.",
            Dock = DockStyle.Top,
            Height = 34,
            TextAlign = ContentAlignment.MiddleLeft,
            Padding = new Padding(10, 8, 10, 0),
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        };
        dialog.Controls.Add(label);

        var list = new ListBox
        {
            Dock = DockStyle.Top,
            Height = 230,
            HorizontalScrollbar = true
        };
        foreach (var path in paths)
        {
            list.Items.Add(FormatConfigChoice(path));
        }
        if (list.Items.Count > 0)
        {
            list.SelectedIndex = 0;
        }
        dialog.Controls.Add(list);

        var buttons = new FlowLayoutPanel
        {
            Dock = DockStyle.Bottom,
            FlowDirection = FlowDirection.RightToLeft,
            Height = 48,
            Padding = new Padding(8)
        };
        var okButton = new Button
        {
            Text = "Open",
            DialogResult = DialogResult.OK,
            Width = 90
        };
        var cancelButton = new Button
        {
            Text = "Cancel",
            DialogResult = DialogResult.Cancel,
            Width = 90
        };
        buttons.Controls.Add(okButton);
        var addAllButton = new Button
        {
            Text = "Add All (" + paths.Count.ToString(CultureInfo.InvariantCulture) + ")",
            Width = 110
        };
        addAllButton.Click += (_, _) =>
        {
            addAll = true;
            dialog.DialogResult = DialogResult.OK;
            dialog.Close();
        };
        buttons.Controls.Add(addAllButton);
        buttons.Controls.Add(cancelButton);
        dialog.Controls.Add(buttons);

        dialog.AcceptButton = okButton;
        dialog.CancelButton = cancelButton;
        list.DoubleClick += (_, _) => dialog.DialogResult = DialogResult.OK;
        ApplyThemeToControl(dialog, restyleButtons: true);
        var result = dialog.ShowDialog(this);
        return result == DialogResult.OK && list.SelectedIndex >= 0
            ? (paths[list.SelectedIndex], addAll)
            : (null, false);
    }

    private static string FormatConfigChoice(string path)
    {
        var modified = File.GetLastWriteTime(path).ToString("yyyy-MM-dd HH:mm", CultureInfo.InvariantCulture);
        return modified + "  " + path;
    }

    private void LoadConfig(string path)
    {
        try
        {
            ClearImportedNewMarkers();
            ClearCategoryPanelCache();
            _viewedStageDifficulties.Clear();
            _document = ConfigDocument.Load(path);
            var loadWarnings = _document.LoadWarnings.ToList();
            _pathBox.Text = path;
            LoadSections();
            LoadPresets();
            ApplyAdvancedToggleVisibility();
            UpdateFooterLabels();
            LoadCategories();
            _settings.RememberConfig(path);
            RefreshInstanceList();
            RefreshConfigVariantList();
            ClearUndo();
            if (loadWarnings.Count > 0)
            {
                SetStatus("Repaired config while loading. Use Save to write the repair.");
                MessageBox.Show(
                    this,
                    "The config was repaired while loading:" + Environment.NewLine +
                    string.Join(Environment.NewLine, loadWarnings) + Environment.NewLine + Environment.NewLine +
                    "Use Save to write the repair to the config file.",
                    "Config repaired",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning);
            }
            else
            {
                SetStatus($"Loaded {_document.Entries.Count.ToString(CultureInfo.InvariantCulture)} editable values.");
            }
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Load failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private void RefreshStringListCatalogFromDefaults(ConfigDocument document)
    {
        if (_stringListCatalog.RefreshFrom(document))
        {
            _stringListCatalog.Save();
        }
    }

    private void RefreshInstanceList()
    {
        _loadingInstances = true;
        try
        {
            var currentPath = _document is null ? "" : Path.GetFullPath(_document.Path);
            _instanceBox.Items.Clear();
            var selectedIndex = -1;
            foreach (var profile in _settings.ServerProfiles.OrderBy(profile => profile.Name, StringComparer.OrdinalIgnoreCase))
            {
                var item = new InstanceItem(profile);
                var index = _instanceBox.Items.Add(item);
                if (!string.IsNullOrWhiteSpace(currentPath) &&
                    Path.GetFullPath(profile.ConfigPath).Equals(currentPath, StringComparison.OrdinalIgnoreCase))
                {
                    selectedIndex = index;
                }
            }

            _instanceBox.SelectedIndex = selectedIndex;
        }
        finally
        {
            _loadingInstances = false;
        }
    }

    private void RefreshConfigVariantList()
    {
        _loadingConfigVariants = true;
        try
        {
            _configVariantBox.Items.Clear();
            if (_document is null)
            {
                _configVariantBox.Enabled = false;
                ApplyConfigVariantSelectorVisibility(false);
                return;
            }

            var currentPath = Path.GetFullPath(_document.Path);
            var variants = GetSiblingConfigPaths(currentPath);
            if (!variants.Any(path => path.Equals(currentPath, StringComparison.OrdinalIgnoreCase)))
            {
                variants.Insert(0, currentPath);
            }

            var selectedIndex = -1;
            foreach (var path in variants)
            {
                var item = new ConfigVariantItem(GetConfigVariantLabel(path), path);
                var index = _configVariantBox.Items.Add(item);
                if (path.Equals(currentPath, StringComparison.OrdinalIgnoreCase))
                {
                    selectedIndex = index;
                }
            }

            _configVariantBox.SelectedIndex = selectedIndex;
            var showSelector = _configVariantBox.Items.Count > 1;
            _configVariantBox.Enabled = showSelector;
            ApplyConfigVariantSelectorVisibility(showSelector);
        }
        finally
        {
            _loadingConfigVariants = false;
        }
    }

    private void ApplyConfigVariantSelectorVisibility(bool visible)
    {
        _configVariantBox.Visible = visible;
        if (_instanceLayout is not null && _instanceLayout.ColumnStyles.Count > 3)
        {
            _instanceLayout.ColumnStyles[2].Width = visible ? LabelColumnWidth("Config", 55) : 0;
            _instanceLayout.ColumnStyles[3].Width = visible ? ToolbarButtonWidth("Normal", 95) : 0;
        }
    }

    private void SwitchConfigVariant()
    {
        if (_loadingConfigVariants || _configVariantBox.SelectedItem is not ConfigVariantItem item)
        {
            return;
        }

        var targetPath = Path.GetFullPath(item.Path);
        if (_document is not null && Path.GetFullPath(_document.Path).Equals(targetPath, StringComparison.OrdinalIgnoreCase))
        {
            return;
        }

        if (HasChanges())
        {
            MessageBox.Show(this, "Save or reload pending changes before switching config type.", "Switch Config", MessageBoxButtons.OK, MessageBoxIcon.Information);
            RefreshConfigVariantList();
            return;
        }

        if (_instanceBox.SelectedItem is InstanceItem instanceItem)
        {
            instanceItem.Profile.ConfigPath = targetPath;
            _settings.Save();
        }

        LoadConfig(targetPath);
    }

    private void SwitchInstance()
    {
        if (_loadingInstances || _instanceBox.SelectedItem is not InstanceItem item)
        {
            return;
        }

        var targetPath = Path.GetFullPath(item.Profile.ConfigPath);
        if (_document is not null && Path.GetFullPath(_document.Path).Equals(targetPath, StringComparison.OrdinalIgnoreCase))
        {
            return;
        }

        if (HasChanges())
        {
            MessageBox.Show(this, "Save or reload pending changes before switching instance.", "Switch Instance", MessageBoxButtons.OK, MessageBoxIcon.Information);
            RefreshInstanceList();
            return;
        }

        if (!File.Exists(targetPath))
        {
            var recovery = PromptForMissingInstanceRecovery(item.Profile, targetPath);
            if (recovery.Kind == MissingInstanceRecoveryKind.SelectPath && !string.IsNullOrWhiteSpace(recovery.Path))
            {
                item.Profile.ConfigPath = Path.GetFullPath(recovery.Path);
                _settings.Save();
                LoadConfig(item.Profile.ConfigPath);
                return;
            }

            if (recovery.Kind == MissingInstanceRecoveryKind.Remove)
            {
                _settings.ServerProfiles.Remove(item.Profile);
                _settings.Save();
                RefreshInstanceList();
                SetStatus("Instance removed: " + item.Profile.Name);
                return;
            }

            RefreshInstanceList();
            return;
        }

        LoadConfig(targetPath);
    }

    private MissingInstanceRecovery PromptForMissingInstanceRecovery(ServerProfileSettings profile, string missingPath)
    {
        var alternatives = GetSiblingConfigPaths(missingPath)
            .Where(path => !path.Equals(missingPath, StringComparison.OrdinalIgnoreCase))
            .ToList();
        MissingInstanceRecovery result = new(MissingInstanceRecoveryKind.Cancel, null);

        using var dialog = new Form
        {
            Text = "Switch Instance",
            StartPosition = FormStartPosition.CenterParent,
            FormBorderStyle = FormBorderStyle.FixedDialog,
            MinimizeBox = false,
            MaximizeBox = false,
            ClientSize = new Size(Zoomed(720), Zoomed(alternatives.Count > 0 ? 340 : 250)),
            Font = Font,
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        };

        var panel = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            RowCount = alternatives.Count > 0 ? 3 : 2,
            ColumnCount = 1,
            Padding = new Padding(Zoomed(16)),
            BackColor = MainBackground
        };
        panel.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        if (alternatives.Count > 0)
        {
            panel.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        }
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, DialogButtonHeight() + Zoomed(24)));
        dialog.Controls.Add(panel);

        var message = new Label
        {
            Dock = DockStyle.Top,
            AutoSize = true,
            MaximumSize = new Size(Zoomed(660), 0),
            Text = "That instance config was not found:" + Environment.NewLine +
                   missingPath + Environment.NewLine + Environment.NewLine +
                   "Select a replacement config, remove the instance, or cancel.",
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        };
        panel.Controls.Add(message, 0, 0);

        ListBox? list = null;
        if (alternatives.Count > 0)
        {
            list = new ListBox
            {
                Dock = DockStyle.Fill,
                HorizontalScrollbar = true
            };
            foreach (var path in alternatives)
            {
                list.Items.Add(GetConfigVariantLabel(path) + "  " + path);
            }
            list.SelectedIndex = 0;
            panel.Controls.Add(list, 0, 1);
        }

        var buttons = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            FlowDirection = FlowDirection.RightToLeft,
            WrapContents = false,
            Padding = new Padding(0, Zoomed(10), 0, 0),
            BackColor = MainBackground
        };
        var cancelButton = new Button { Text = "Cancel", DialogResult = DialogResult.Cancel };
        SizeDialogButton(cancelButton);
        cancelButton.Margin = new Padding(Zoomed(3));
        buttons.Controls.Add(cancelButton);

        var removeButton = new Button { Text = "Remove instance" };
        SizeDialogButton(removeButton, 130);
        removeButton.Margin = new Padding(Zoomed(3));
        StyleButton(removeButton);
        removeButton.Click += (_, _) =>
        {
            result = new MissingInstanceRecovery(MissingInstanceRecoveryKind.Remove, null);
            dialog.DialogResult = DialogResult.OK;
            dialog.Close();
        };
        buttons.Controls.Add(removeButton);

        var selectButton = new Button { Text = "Select new file" };
        SizeDialogButton(selectButton, 125);
        selectButton.Margin = new Padding(Zoomed(3));
        StyleButton(selectButton);
        selectButton.Click += (_, _) =>
        {
            using var fileDialog = new OpenFileDialog
            {
                Title = "Select replacement config for " + profile.Name,
                Filter = "Foothold config (*.lua)|*.lua|All files (*.*)|*.*",
                FileName = RuntimeSettings.DefaultConfigFileName,
                InitialDirectory = Path.GetDirectoryName(missingPath) ?? RuntimeSettings.GetBestInitialDirectory()
            };
            if (fileDialog.ShowDialog(dialog) == DialogResult.OK)
            {
                result = new MissingInstanceRecovery(MissingInstanceRecoveryKind.SelectPath, fileDialog.FileName);
                dialog.DialogResult = DialogResult.OK;
                dialog.Close();
            }
        };
        buttons.Controls.Add(selectButton);

        if (alternatives.Count > 0)
        {
            var switchButton = new Button { Text = "Switch to selected" };
            SizeDialogButton(switchButton, 135);
            switchButton.Margin = new Padding(Zoomed(3));
            StyleButton(switchButton);
            switchButton.Click += (_, _) =>
            {
                if (list is not null && list.SelectedIndex >= 0)
                {
                    result = new MissingInstanceRecovery(MissingInstanceRecoveryKind.SelectPath, alternatives[list.SelectedIndex]);
                    dialog.DialogResult = DialogResult.OK;
                    dialog.Close();
                }
            };
            buttons.Controls.Add(switchButton);
            dialog.AcceptButton = switchButton;
            list!.DoubleClick += (_, _) => switchButton.PerformClick();
        }

        panel.Controls.Add(buttons, 0, alternatives.Count > 0 ? 2 : 1);
        dialog.CancelButton = cancelButton;
        ApplyThemeToControl(dialog, restyleButtons: true);

        return dialog.ShowDialog(this) == DialogResult.OK
            ? result
            : new MissingInstanceRecovery(MissingInstanceRecoveryKind.Cancel, null);
    }

    private void AddInstance()
    {
        using var dialog = new OpenFileDialog
        {
            Title = "Select Foothold Config.lua for this instance",
            Filter = "Lua config (*.lua)|*.lua|All files (*.*)|*.*",
            FileName = GetCurrentConfigFileName(_document),
            InitialDirectory = _document is null
                ? RuntimeSettings.GetBestInitialDirectory()
                : Path.GetDirectoryName(_document.Path)
        };

        if (dialog.ShowDialog(this) != DialogResult.OK)
        {
            return;
        }

        var path = Path.GetFullPath(dialog.FileName);
        var familyKey = GetConfigFamilyKey(path);
        var existing = _settings.ServerProfiles.FirstOrDefault(profile =>
            Path.GetFullPath(profile.ConfigPath).Equals(path, StringComparison.OrdinalIgnoreCase) ||
            GetConfigFamilyKey(profile.ConfigPath).Equals(familyKey, StringComparison.OrdinalIgnoreCase));
        var name = PromptForText("Add Instance", "Instance name", existing?.Name ?? GuessInstanceName(path))?.Trim();
        if (string.IsNullOrWhiteSpace(name))
        {
            return;
        }

        if (_settings.ServerProfiles.Any(profile =>
                !GetConfigFamilyKey(profile.ConfigPath).Equals(familyKey, StringComparison.OrdinalIgnoreCase) &&
                profile.Name.Equals(name, StringComparison.OrdinalIgnoreCase)))
        {
            MessageBox.Show(this, "An instance with that name already exists.", "Add Instance", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return;
        }

        if (existing is not null)
        {
            existing.Name = name;
            existing.ConfigPath = path;
        }
        else
        {
            _settings.ServerProfiles.Add(new ServerProfileSettings
            {
                Name = name,
                ConfigPath = path
            });
        }

        _settings.Save();
        RefreshInstanceList();
        SetStatus("Instance saved: " + name);
    }

    private int AddDetectedInstances(List<string> paths, string? preferredPath)
    {
        var existingNames = _settings.ServerProfiles
            .Select(profile => profile.Name)
            .ToHashSet(StringComparer.OrdinalIgnoreCase);
        var added = 0;
        foreach (var group in paths
                     .Select(Path.GetFullPath)
                     .Distinct(StringComparer.OrdinalIgnoreCase)
                     .GroupBy(GetConfigFamilyKey, StringComparer.OrdinalIgnoreCase))
        {
            var path = group.FirstOrDefault(item => !string.IsNullOrWhiteSpace(preferredPath) && PathsEqual(item, preferredPath)) ??
                       group.FirstOrDefault(item => Path.GetFileName(item).Equals(RuntimeSettings.DefaultConfigFileName, StringComparison.OrdinalIgnoreCase)) ??
                       group.First();
            var familyKey = GetConfigFamilyKey(path);
            if (_settings.ServerProfiles.Any(profile => GetConfigFamilyKey(profile.ConfigPath).Equals(familyKey, StringComparison.OrdinalIgnoreCase)))
            {
                continue;
            }

            var name = MakeUniqueInstanceName(GuessInstanceName(path), existingNames);
            existingNames.Add(name);
            _settings.ServerProfiles.Add(new ServerProfileSettings
            {
                Name = name,
                ConfigPath = path
            });
            added++;
        }

        _settings.Save();
        RefreshInstanceList();
        return added;
    }

    private void AddOrUpdateInstanceProfile(string name, string path)
    {
        path = Path.GetFullPath(path);
        var familyKey = GetConfigFamilyKey(path);
        var existing = _settings.ServerProfiles.FirstOrDefault(profile =>
            Path.GetFullPath(profile.ConfigPath).Equals(path, StringComparison.OrdinalIgnoreCase) ||
            GetConfigFamilyKey(profile.ConfigPath).Equals(familyKey, StringComparison.OrdinalIgnoreCase));
        if (existing is not null)
        {
            existing.Name = string.IsNullOrWhiteSpace(name) ? GuessInstanceName(path) : name.Trim();
            existing.ConfigPath = path;
        }
        else
        {
            var existingNames = _settings.ServerProfiles
                .Select(profile => profile.Name)
                .ToHashSet(StringComparer.OrdinalIgnoreCase);
            _settings.ServerProfiles.Add(new ServerProfileSettings
            {
                Name = MakeUniqueInstanceName(name, existingNames),
                ConfigPath = path
            });
        }

        _settings.Save();
        RefreshInstanceList();
    }

    private void UpdateSelectedInstanceConfigPath(string path)
    {
        if (_instanceBox.SelectedItem is not InstanceItem item)
        {
            return;
        }

        item.Profile.ConfigPath = Path.GetFullPath(path);
        _settings.Save();
    }

    private void RemoveInstance()
    {
        if (_instanceBox.SelectedItem is not InstanceItem item)
        {
            MessageBox.Show(this, "Select an instance to remove.", "Remove Instance", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

        if (MessageBox.Show(this, "Remove " + item.Profile.Name + " from the instance list? The config file will not be deleted.", "Remove Instance", MessageBoxButtons.YesNo, MessageBoxIcon.Question) != DialogResult.Yes)
        {
            return;
        }

        _settings.ServerProfiles.RemoveAll(profile => Path.GetFullPath(profile.ConfigPath).Equals(Path.GetFullPath(item.Profile.ConfigPath), StringComparison.OrdinalIgnoreCase));
        _settings.Save();
        RefreshInstanceList();
        SetStatus("Instance removed: " + item.Profile.Name);
    }

    private void CopyCurrentConfigToInstances()
    {
        if (_document is null)
        {
            MessageBox.Show(this, "Open the source config first.", "Copy To Instances", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

        if (HasChanges())
        {
            MessageBox.Show(this, "Save or reload pending changes before copying to other instances.", "Copy To Instances", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

        var sourcePath = Path.GetFullPath(_document.Path);
        var sourceConfigFileName = GetCurrentConfigFileName(_document);
        var targets = _settings.ServerProfiles
            .Where(profile => !ResolveMatchingCopyTargetPath(profile.ConfigPath, sourceConfigFileName).Equals(sourcePath, StringComparison.OrdinalIgnoreCase))
            .OrderBy(profile => profile.Name, StringComparer.OrdinalIgnoreCase)
            .ToList();
        if (targets.Count == 0)
        {
            MessageBox.Show(this, "Add at least one other instance first.", "Copy To Instances", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

        var plans = targets.Select(target => BuildCopyTargetPlan(_document, target, sourceConfigFileName)).ToList();
        var selectedPlans = PromptForCopyTargets(plans, GetConfigVariantLabel(sourceConfigFileName));
        if (selectedPlans is null || selectedPlans.Count == 0)
        {
            return;
        }

        var copied = new List<string>();
        var failed = new List<string>();
        foreach (var plan in selectedPlans.Where(plan => plan.IsTargetSelected && plan.LoadError is null && (plan.Changes.Count == 0 || plan.SelectedChangeCount > 0)))
        {
            try
            {
                ApplyCopyPlan(sourcePath, plan);
                copied.Add(plan.Profile.Name);
            }
            catch (Exception ex)
            {
                failed.Add(plan.Profile.Name + ": " + ex.Message);
            }
        }

        if (failed.Count > 0)
        {
            MessageBox.Show(
                this,
                "Copied to " + copied.Count.ToString(CultureInfo.InvariantCulture) + " instance(s)." + Environment.NewLine +
                Environment.NewLine +
                "Failed:" + Environment.NewLine +
                string.Join(Environment.NewLine, failed.Take(8)),
                "Copy To Instances",
                MessageBoxButtons.OK,
                MessageBoxIcon.Warning);
        }

        SetStatus("Copied selected config to " + copied.Count.ToString(CultureInfo.InvariantCulture) + " instance(s). No backup created.");
    }

    private static string ResolveMatchingCopyTargetPath(string profileConfigPath, string sourceConfigFileName)
    {
        var fullPath = Path.GetFullPath(profileConfigPath);
        if (!IsSupportedConfigFileName(sourceConfigFileName) || !IsSupportedConfigFileName(Path.GetFileName(fullPath)))
        {
            return fullPath;
        }

        var directory = Path.GetDirectoryName(fullPath);
        return string.IsNullOrWhiteSpace(directory)
            ? fullPath
            : Path.GetFullPath(Path.Combine(directory, sourceConfigFileName));
    }

    private CopyTargetPlan BuildCopyTargetPlan(ConfigDocument sourceDocument, ServerProfileSettings target, string sourceConfigFileName)
    {
        var targetPath = ResolveMatchingCopyTargetPath(target.ConfigPath, sourceConfigFileName);
        try
        {
            if (!File.Exists(targetPath))
            {
                return new CopyTargetPlan(target, targetPath, new List<CopyChange>(), GetConfigVariantLabel(sourceConfigFileName) + " config does not exist.");
            }

            var targetDocument = ConfigDocument.Load(targetPath);
            var contentMatches = NormalizeCopyText(File.ReadAllText(sourceDocument.Path)).Equals(
                NormalizeCopyText(File.ReadAllText(targetPath)),
                StringComparison.Ordinal);
            return new CopyTargetPlan(target, targetPath, BuildCopyChanges(sourceDocument, targetDocument), contentMatches: contentMatches);
        }
        catch (Exception ex)
        {
            return new CopyTargetPlan(target, targetPath, new List<CopyChange>(), ex.Message);
        }
    }

    private List<CopyChange> BuildCopyChanges(ConfigDocument sourceDocument, ConfigDocument targetDocument)
    {
        var changes = new List<(int Order, CopyChange Change)>();
        var tableKeys = new HashSet<string>(StringComparer.Ordinal);

        foreach (var table in sourceDocument.StringListTables)
        {
            TryAddTableCopyChange(sourceDocument, targetDocument, table.Key, table.GuiLabel ?? GetConfiguredGroupLabel(table.Key), table.StartLineIndex, changes);
            tableKeys.Add(table.Key);
        }

        foreach (var table in sourceDocument.StageTables)
        {
            TryAddTableCopyChange(sourceDocument, targetDocument, table.Key, table.GuiLabel ?? GetConfiguredGroupLabel(table.Key), table.StartLineIndex, changes);
            tableKeys.Add(table.Key);
        }

        foreach (var group in sourceDocument.Entries
                     .Where(entry => !string.IsNullOrWhiteSpace(entry.ParentKey))
                     .GroupBy(entry => GetCopyTableRootKey(entry.ParentKey), StringComparer.Ordinal))
        {
            if (tableKeys.Contains(group.Key))
            {
                continue;
            }

            var firstLine = group.Min(entry => entry.LineIndex);
            TryAddTableCopyChange(sourceDocument, targetDocument, group.Key, GetConfiguredGroupLabel(group.Key), firstLine, changes);
            tableKeys.Add(group.Key);
        }

        foreach (var sourceEntry in sourceDocument.Entries
                     .Where(entry => string.IsNullOrWhiteSpace(entry.ParentKey)))
        {
            var targetEntry = targetDocument.Entries.FirstOrDefault(entry => entry.DisplayKey.Equals(sourceEntry.DisplayKey, StringComparison.Ordinal));
            if (targetEntry is not null && StringComparer.Ordinal.Equals(sourceEntry.ValueText, targetEntry.ValueText))
            {
                continue;
            }

            var summary = targetEntry is null
                ? "will be added"
                : PreviewCopyValue(targetEntry.ValueText) + " -> " + PreviewCopyValue(sourceEntry.ValueText);
            changes.Add((
                sourceEntry.LineIndex,
                new CopyChange(
                    CopyChangeKind.Entry,
                    sourceEntry.DisplayKey,
                    sourceEntry.DisplayName,
                    summary,
                    targetEntry?.ValueText ?? "(not present)",
                    sourceEntry.ValueText)));
        }

        return changes
            .OrderBy(item => item.Order)
            .ThenBy(item => item.Change.Label, StringComparer.OrdinalIgnoreCase)
            .Select(item => item.Change)
            .ToList();
    }

    private static string GetCopyTableRootKey(string parentKey)
    {
        var index = parentKey.IndexOf('.', StringComparison.Ordinal);
        return index < 0 ? parentKey : parentKey[..index];
    }

    private void TryAddTableCopyChange(
        ConfigDocument sourceDocument,
        ConfigDocument targetDocument,
        string key,
        string label,
        int order,
        List<(int Order, CopyChange Change)> changes)
    {
        if (!sourceDocument.TryGetTableBlockText(key, out var sourceText))
        {
            return;
        }

        var targetHasTable = targetDocument.TryGetTableBlockText(key, out var targetText);
        if (targetHasTable && NormalizeCopyText(sourceText).Equals(NormalizeCopyText(targetText), StringComparison.Ordinal))
        {
            return;
        }

        changes.Add((
            order,
            new CopyChange(
                CopyChangeKind.Table,
                key,
                label,
                targetHasTable ? "table changed" : "table added",
                targetHasTable ? targetText : "(table not present)",
                sourceText)));
    }

    private static string NormalizeCopyText(string text)
    {
        return text.Replace("\r\n", "\n", StringComparison.Ordinal)
            .Replace('\r', '\n')
            .Trim();
    }

    private static string PreviewCopyValue(string value)
    {
        var trimmed = value.Replace("\r\n", "\\n", StringComparison.Ordinal)
            .Replace("\n", "\\n", StringComparison.Ordinal)
            .Replace("\r", "\\n", StringComparison.Ordinal)
            .Trim();
        if (trimmed.Length == 0)
        {
            return "(empty)";
        }

        return trimmed.Length <= 42 ? trimmed : trimmed[..39] + "...";
    }

    private static string NormalizeInspectText(string text)
    {
        return text.Replace("\r\n", "\n", StringComparison.Ordinal)
            .Replace('\r', '\n')
            .Trim();
    }

    private static string LimitInspectLines(string text, int maxLines)
    {
        var lines = NormalizeInspectText(text).Split('\n');
        if (lines.Length <= maxLines)
        {
            return string.Join(Environment.NewLine, lines);
        }

        return string.Join(Environment.NewLine, lines.Take(maxLines)) +
            Environment.NewLine +
            "... " + (lines.Length - maxLines).ToString(CultureInfo.InvariantCulture) + " more line(s)";
    }

    private static string BuildCompactLineDiff(string currentText, string sourceText, int maxLines)
    {
        var currentLines = NormalizeInspectText(currentText).Split('\n');
        var sourceLines = NormalizeInspectText(sourceText).Split('\n');
        var output = new List<string>();
        var max = Math.Max(currentLines.Length, sourceLines.Length);
        for (var i = 0; i < max && output.Count < maxLines; i++)
        {
            var current = i < currentLines.Length ? currentLines[i] : null;
            var source = i < sourceLines.Length ? sourceLines[i] : null;
            if (string.Equals(current, source, StringComparison.Ordinal))
            {
                continue;
            }

            output.Add("@@ line " + (i + 1).ToString(CultureInfo.InvariantCulture) + " @@");
            if (current is not null)
            {
                output.Add("- " + current);
            }

            if (source is not null)
            {
                output.Add("+ " + source);
            }
        }

        if (output.Count == 0)
        {
            return "Only whitespace or line ending differences were detected.";
        }

        if (output.Count >= maxLines)
        {
            output.Add("... more differences not shown");
        }

        return string.Join(Environment.NewLine, output);
    }

    private static string BuildCopyChangeDetailText(CopyChange change)
    {
        return string.Join(
            Environment.NewLine,
            new[]
            {
                change.Label,
                change.Summary,
                "",
                "Current:",
                LimitInspectLines(change.CurrentText, change.Kind == CopyChangeKind.Table ? 40 : 12),
                "",
                "Copy from source:",
                LimitInspectLines(change.SourceText, change.Kind == CopyChangeKind.Table ? 40 : 12),
                "",
                "First differences:",
                BuildCompactLineDiff(change.CurrentText, change.SourceText, change.Kind == CopyChangeKind.Table ? 80 : 30)
            });
    }

    private void ShowCopyChangeDetails(CopyChange change)
    {
        using var dialog = new Form
        {
            Text = change.Label + " Difference",
            StartPosition = FormStartPosition.CenterParent,
            FormBorderStyle = FormBorderStyle.Sizable,
            MinimizeBox = false,
            MaximizeBox = true,
            ClientSize = new Size(Zoomed(820), Zoomed(560)),
            MinimumSize = new Size(Zoomed(620), Zoomed(420)),
            Font = Font,
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        };

        var panel = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            RowCount = 3,
            ColumnCount = 1,
            Padding = new Padding(Zoomed(10)),
            BackColor = MainBackground
        };
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(34)));
        panel.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(54)));
        dialog.Controls.Add(panel);

        panel.Controls.Add(new Label
        {
            Text = change.Label + " - " + change.Summary,
            Dock = DockStyle.Fill,
            TextAlign = ContentAlignment.MiddleLeft,
            AutoEllipsis = true,
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        }, 0, 0);

        var textBox = new RichTextBox
        {
            Dock = DockStyle.Fill,
            ReadOnly = true,
            BorderStyle = BorderStyle.FixedSingle,
            ScrollBars = RichTextBoxScrollBars.Both,
            WordWrap = false,
            DetectUrls = false,
            Font = new Font(FontFamily.GenericMonospace, Font.Size),
            Text = BuildCopyChangeDetailText(change),
            BackColor = EditorBackground,
            ForeColor = PrimaryTextColor
        };
        panel.Controls.Add(textBox, 0, 1);

        var buttons = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            FlowDirection = FlowDirection.RightToLeft,
            WrapContents = false,
            Padding = new Padding(0, Zoomed(8), 0, 0),
            BackColor = MainBackground
        };
        var closeButton = new Button
        {
            Text = "Close",
            DialogResult = DialogResult.OK
        };
        SizeDialogButton(closeButton);
        buttons.Controls.Add(closeButton);
        panel.Controls.Add(buttons, 0, 2);

        ApplyDialogChrome(dialog);
        dialog.AcceptButton = closeButton;
        dialog.CancelButton = closeButton;
        dialog.ShowDialog(this);
    }

    private static void CopyValidatedConfigFile(string sourcePath, string targetPath)
    {
        var sourceDocument = ConfigDocument.Load(sourcePath);
        var errors = sourceDocument.Validate();
        if (errors.Count > 0)
        {
            throw new InvalidOperationException(
                "Source config failed validation. No file was changed." +
                Environment.NewLine +
                string.Join(Environment.NewLine, errors.Take(8)));
        }

        File.Copy(sourcePath, targetPath, overwrite: true);
    }

    private void ApplyCopyPlan(string sourcePath, CopyTargetPlan plan)
    {
        var selectedChanges = plan.Changes.Where(change => plan.SelectedChangeIds.Contains(change.Id)).ToList();
        if (plan.Changes.Count == 0)
        {
            CopyValidatedConfigFile(sourcePath, plan.TargetPath);
            return;
        }

        if (selectedChanges.Count == 0)
        {
            return;
        }

        if (selectedChanges.Count == plan.Changes.Count)
        {
            CopyValidatedConfigFile(sourcePath, plan.TargetPath);
            return;
        }

        var sourceDocument = ConfigDocument.Load(sourcePath);
        var output = ConfigDocument.Load(plan.TargetPath);
        foreach (var change in selectedChanges)
        {
            if (change.Kind == CopyChangeKind.Entry)
            {
                var sourceEntry = sourceDocument.Entries.FirstOrDefault(entry => entry.DisplayKey.Equals(change.Key, StringComparison.Ordinal));
                var outputEntry = output.Entries.FirstOrDefault(entry => entry.DisplayKey.Equals(change.Key, StringComparison.Ordinal));
                if (sourceEntry is null)
                {
                    throw new InvalidOperationException(change.Label + " is no longer in the source config. No file was changed.");
                }

                if (outputEntry is null)
                {
                    throw new InvalidOperationException(change.Label + " is not in the target config. Full copy is required to add missing config entries.");
                }

                outputEntry.ValueText = sourceEntry.ValueText;
                continue;
            }

            if (!output.ReplaceTableBlockFrom(sourceDocument, change.Key))
            {
                throw new InvalidOperationException(change.Label + " could not be copied into the target config. Full copy is required to add missing config tables.");
            }
        }

        output.Save();
    }

    private List<CopyTargetPlan>? PromptForCopyTargets(List<CopyTargetPlan> plans, string sourceConfigLabel)
    {
        using var dialog = new Form
        {
            Text = "Copy To Instances",
            StartPosition = FormStartPosition.CenterParent,
            FormBorderStyle = FormBorderStyle.Sizable,
            MinimizeBox = false,
            MaximizeBox = true,
            ClientSize = new Size(Zoomed(900), Zoomed(560)),
            MinimumSize = new Size(Zoomed(760), Zoomed(460)),
            Font = Font,
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        };

        var panel = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            RowCount = 3,
            ColumnCount = 1,
            Padding = new Padding(Zoomed(10))
        };
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(44)));
        panel.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(54)));
        dialog.Controls.Add(panel);

        panel.Controls.Add(new Label
        {
            Text = "Select instances to replace with the currently open " + sourceConfigLabel + " config. No backup will be created.",
            Dock = DockStyle.Fill,
            TextAlign = ContentAlignment.MiddleLeft,
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        }, 0, 0);

        var scrollPanel = new Panel
        {
            Dock = DockStyle.Fill,
            AutoScroll = true,
            BackColor = MainBackground
        };
        var rows = new TableLayoutPanel
        {
            Dock = DockStyle.Top,
            AutoSize = true,
            ColumnCount = 1,
            BackColor = MainBackground
        };
        rows.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        scrollPanel.Controls.Add(rows);
        panel.Controls.Add(scrollPanel, 0, 1);

        var buttons = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            FlowDirection = FlowDirection.RightToLeft,
            BackColor = MainBackground,
            WrapContents = false,
            Padding = new Padding(0, Zoomed(8), 0, 0)
        };
        var copyButton = new Button
        {
            Text = "Copy",
            DialogResult = DialogResult.OK
        };
        var cancelButton = new Button
        {
            Text = "Cancel",
            DialogResult = DialogResult.Cancel
        };
        SizeDialogButton(copyButton);
        SizeDialogButton(cancelButton);
        buttons.Controls.Add(copyButton);
        buttons.Controls.Add(cancelButton);
        panel.Controls.Add(buttons, 0, 2);

        var updatingSelectionUi = false;
        var targetCheckBoxes = new Dictionary<CopyTargetPlan, CheckBox>();
        var targetSummaryLabels = new Dictionary<CopyTargetPlan, Label>();
        var changeCheckBoxes = new Dictionary<(CopyTargetPlan Plan, string ChangeId), CheckBox>();

        void AddRow(Control control)
        {
            rows.RowStyles.Add(new RowStyle(SizeType.AutoSize));
            rows.Controls.Add(control, 0, rows.RowCount);
            rows.RowCount++;
        }

        string TargetSummary(CopyTargetPlan plan)
        {
            if (plan.LoadError is not null)
            {
                return plan.LoadError;
            }

            if (!plan.IsTargetSelected)
            {
                return "Not selected";
            }

            if (plan.Changes.Count == 0)
            {
                return plan.ContentMatches ? "No tracked value changes" : "Comments/format differs";
            }

            return plan.SelectedChangeCount == plan.Changes.Count
                ? plan.Changes.Count.ToString(CultureInfo.InvariantCulture) + " changes"
                : plan.SelectedChangeCount.ToString(CultureInfo.InvariantCulture) + " of " + plan.Changes.Count.ToString(CultureInfo.InvariantCulture) + " changes selected";
        }

        bool CanCopy(CopyTargetPlan plan)
        {
            return plan.IsTargetSelected && plan.LoadError is null && (plan.Changes.Count == 0 || plan.SelectedChangeCount > 0);
        }

        void UpdateCopyButton()
        {
            copyButton.Enabled = plans.Any(CanCopy);
        }

        void UpdateSelectionUi(CopyTargetPlan plan)
        {
            updatingSelectionUi = true;
            try
            {
                if (targetCheckBoxes.TryGetValue(plan, out var targetCheck) && targetCheck.Checked != plan.IsTargetSelected)
                {
                    targetCheck.Checked = plan.IsTargetSelected;
                }

                if (targetSummaryLabels.TryGetValue(plan, out var targetSummaryLabel))
                {
                    targetSummaryLabel.Text = TargetSummary(plan);
                }

                foreach (var change in plan.Changes)
                {
                    var isSelected = plan.SelectedChangeIds.Contains(change.Id);
                    if (changeCheckBoxes.TryGetValue((plan, change.Id), out var changeCheck) && changeCheck.Checked != isSelected)
                    {
                        changeCheck.Checked = isSelected;
                    }
                }
            }
            finally
            {
                updatingSelectionUi = false;
            }

            UpdateCopyButton();
        }

        void RebuildRows()
        {
            rows.SuspendLayout();
            try
            {
                rows.Controls.Clear();
                rows.RowStyles.Clear();
                rows.RowCount = 0;
                targetCheckBoxes.Clear();
                targetSummaryLabels.Clear();
                changeCheckBoxes.Clear();

                foreach (var plan in plans)
                {
                    var detailsColumnWidth = DialogButtonWidth("Hide details", 128);
                    var targetRow = new TableLayoutPanel
                    {
                        AutoSize = true,
                        Dock = DockStyle.Top,
                        ColumnCount = 4,
                        Padding = new Padding(0, Zoomed(4), 0, Zoomed(4)),
                        BackColor = MainBackground
                    };
                    targetRow.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, Zoomed(28)));
                    targetRow.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, Zoomed(220)));
                    targetRow.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
                    targetRow.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, detailsColumnWidth));

                    var targetCheck = new CheckBox
                    {
                        Checked = plan.IsTargetSelected,
                        Enabled = plan.LoadError is null,
                        Dock = DockStyle.Fill,
                        Margin = new Padding(0),
                        BackColor = MainBackground,
                        ForeColor = PrimaryTextColor
                    };
                    targetCheck.CheckedChanged += (_, _) =>
                    {
                        if (updatingSelectionUi)
                        {
                            return;
                        }

                        plan.IsTargetSelected = targetCheck.Checked;
                        if (targetCheck.Checked)
                        {
                            plan.SelectedChangeIds.Clear();
                            foreach (var change in plan.Changes)
                            {
                                plan.SelectedChangeIds.Add(change.Id);
                            }
                        }
                        else
                        {
                            plan.SelectedChangeIds.Clear();
                        }

                        UpdateSelectionUi(plan);
                    };
                    targetCheckBoxes[plan] = targetCheck;
                    targetRow.Controls.Add(targetCheck, 0, 0);

                    targetRow.Controls.Add(new Label
                    {
                        Text = plan.Profile.Name,
                        Dock = DockStyle.Fill,
                        TextAlign = ContentAlignment.MiddleLeft,
                        AutoEllipsis = true,
                        BackColor = MainBackground,
                        ForeColor = PrimaryTextColor
                    }, 1, 0);

                    var targetSummaryLabel = new Label
                    {
                        Text = TargetSummary(plan),
                        Dock = DockStyle.Fill,
                        TextAlign = ContentAlignment.MiddleLeft,
                        AutoEllipsis = true,
                        BackColor = MainBackground,
                        ForeColor = plan.LoadError is null ? HelpTextColor : Color.Firebrick
                    };
                    targetSummaryLabels[plan] = targetSummaryLabel;
                    targetRow.Controls.Add(targetSummaryLabel, 2, 0);

                    var detailsButton = new Button
                    {
                        Text = plan.IsExpanded ? "Hide details" : "Details",
                        Enabled = plan.Changes.Count > 0 || plan.LoadError is not null,
                        Dock = DockStyle.Fill,
                        Margin = new Padding(Zoomed(4), 0, 0, 0),
                        MinimumSize = new Size(detailsColumnWidth - Zoomed(4), DialogButtonHeight())
                    };
                    detailsButton.Click += (_, _) =>
                    {
                        var wasExpanded = plan.IsExpanded;
                        foreach (var item in plans)
                        {
                            item.IsExpanded = false;
                        }

                        plan.IsExpanded = !wasExpanded;
                        RebuildRows();
                    };
                    targetRow.Controls.Add(detailsButton, 3, 0);
                    AddRow(targetRow);

                    if (!plan.IsExpanded)
                    {
                        continue;
                    }

                    var detailPanel = new TableLayoutPanel
                    {
                        AutoSize = true,
                        Dock = DockStyle.Top,
                        ColumnCount = 4,
                        Padding = new Padding(Zoomed(32), 0, 0, Zoomed(8)),
                        BackColor = MainBackground
                    };
                    detailPanel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, Zoomed(28)));
                    detailPanel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, Zoomed(300)));
                    detailPanel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
                    detailPanel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, Zoomed(34)));

                    if (plan.LoadError is not null)
                    {
                        detailPanel.Controls.Add(new Label
                        {
                            Text = plan.LoadError + Environment.NewLine + plan.TargetPath,
                            Dock = DockStyle.Top,
                            AutoSize = true,
                            ForeColor = Color.Firebrick,
                            BackColor = MainBackground
                        }, 1, 0);
                    }
                    else
                    {
                        var detailRow = 0;
                        foreach (var change in plan.Changes)
                        {
                            var changeCheck = new CheckBox
                            {
                                Checked = plan.SelectedChangeIds.Contains(change.Id),
                                Enabled = true,
                                Dock = DockStyle.Fill,
                                Margin = new Padding(0),
                                BackColor = MainBackground,
                                ForeColor = PrimaryTextColor
                            };
                            changeCheck.CheckedChanged += (_, _) =>
                            {
                                if (updatingSelectionUi)
                                {
                                    return;
                                }

                                if (changeCheck.Checked)
                                {
                                    plan.SelectedChangeIds.Add(change.Id);
                                    plan.IsTargetSelected = true;
                                }
                                else
                                {
                                    plan.SelectedChangeIds.Remove(change.Id);
                                    if (plan.SelectedChangeCount == 0)
                                    {
                                        plan.IsTargetSelected = false;
                                    }
                                }

                                UpdateSelectionUi(plan);
                            };
                            changeCheckBoxes[(plan, change.Id)] = changeCheck;
                            detailPanel.Controls.Add(changeCheck, 0, detailRow);
                            var label = new Label
                            {
                                Text = change.Label,
                                Dock = DockStyle.Fill,
                                AutoEllipsis = true,
                                TextAlign = ContentAlignment.MiddleLeft,
                                BackColor = MainBackground,
                                ForeColor = PrimaryTextColor
                            };
                            detailPanel.Controls.Add(label, 1, detailRow);
                            var summaryLabel = new Label
                            {
                                Text = change.Summary,
                                Dock = DockStyle.Fill,
                                AutoEllipsis = true,
                                TextAlign = ContentAlignment.MiddleLeft,
                                BackColor = MainBackground,
                                ForeColor = HelpTextColor
                            };
                            detailPanel.Controls.Add(summaryLabel, 2, detailRow);
                            var inspectButton = new Button
                            {
                                Text = "?",
                                Dock = DockStyle.Fill,
                                Margin = new Padding(Zoomed(4), 0, 0, 0),
                                MinimumSize = new Size(Zoomed(28), DialogButtonHeight())
                            };
                            inspectButton.Click += (_, _) => ShowCopyChangeDetails(change);
                            _toolTip.SetToolTip(inspectButton, "View this difference.");
                            detailPanel.Controls.Add(inspectButton, 3, detailRow);

                            var hoverControls = new Control[] { changeCheck, label, summaryLabel };
                            void SetHover(bool hover)
                            {
                                var color = hover ? HeaderBackground : MainBackground;
                                foreach (var control in hoverControls)
                                {
                                    control.BackColor = color;
                                }
                            }

                            foreach (var control in hoverControls.Append(inspectButton))
                            {
                                control.MouseEnter += (_, _) => SetHover(true);
                                control.MouseLeave += (_, _) => SetHover(false);
                            }

                            detailRow++;
                        }
                    }

                    AddRow(detailPanel);
                }
            }
            finally
            {
                rows.ResumeLayout();
            }

            UpdateCopyButton();
            ApplyThemeToControl(dialog, restyleButtons: true);
        }

        ApplyDialogChrome(dialog);
        RebuildRows();
        dialog.AcceptButton = copyButton;
        dialog.CancelButton = cancelButton;
        if (dialog.ShowDialog(this) != DialogResult.OK)
        {
            return null;
        }

        return plans
            .Where(CanCopy)
            .ToList();
    }

    private static string GuessInstanceName(string path)
    {
        var directory = new DirectoryInfo(Path.GetDirectoryName(path) ?? "");
        if (directory.Name.Equals("Saves", StringComparison.OrdinalIgnoreCase) &&
            directory.Parent?.Name.Equals("Missions", StringComparison.OrdinalIgnoreCase) == true &&
            directory.Parent.Parent is not null)
        {
            return directory.Parent.Parent.Name;
        }

        while (directory is not null)
        {
            if (directory.Name.StartsWith("DCS", StringComparison.OrdinalIgnoreCase))
            {
                return directory.Name;
            }

            directory = directory.Parent;
        }

        return Path.GetFileName(Path.GetDirectoryName(path) ?? path);
    }

    private static string MakeUniqueInstanceName(string baseName, HashSet<string> existingNames)
    {
        var name = string.IsNullOrWhiteSpace(baseName) ? "Instance" : baseName.Trim();
        if (!existingNames.Contains(name))
        {
            return name;
        }

        for (var i = 2; ; i++)
        {
            var candidate = name + " " + i.ToString(CultureInfo.InvariantCulture);
            if (!existingNames.Contains(candidate))
            {
                return candidate;
            }
        }
    }

    private static List<FirstRunMizCandidate> FindFirstRunMizCandidates()
    {
        var paths = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var roots = new[]
        {
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "Downloads"),
            Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory),
            Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments),
            RuntimeSettings.GetBestInitialDirectory(),
            AppContext.BaseDirectory
        };

        foreach (var root in roots)
        {
            AddFootholdMizCandidates(paths, root, recursive: false);
        }

        var savedGames = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "Saved Games");
        if (Directory.Exists(savedGames))
        {
            try
            {
                foreach (var profile in Directory.EnumerateDirectories(savedGames))
                {
                    var missions = Path.Combine(profile, "Missions");
                    AddFootholdMizCandidates(paths, missions, recursive: true);
                }
            }
            catch
            {
                // Manual Browse remains available if a folder cannot be scanned.
            }
        }

        return paths
            .Select(path => new FirstRunMizCandidate(path, File.GetLastWriteTime(path)))
            .OrderByDescending(item => item.Modified)
            .ThenBy(item => item.Path, StringComparer.OrdinalIgnoreCase)
            .Take(50)
            .ToList();
    }

    private static void AddFootholdMizCandidates(HashSet<string> paths, string? directory, bool recursive)
    {
        if (string.IsNullOrWhiteSpace(directory) || !Directory.Exists(directory))
        {
            return;
        }

        try
        {
            foreach (var path in Directory.EnumerateFiles(directory, "*.miz", recursive ? SearchOption.AllDirectories : SearchOption.TopDirectoryOnly))
            {
                if (Path.GetFileNameWithoutExtension(path).Contains("Foothold", StringComparison.OrdinalIgnoreCase))
                {
                    paths.Add(Path.GetFullPath(path));
                }
            }
        }
        catch
        {
            // Manual Browse remains available if a folder cannot be scanned.
        }
    }

    private static List<FirstRunInstanceCandidate> FindFirstRunInstanceCandidates()
    {
        var savedGames = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "Saved Games");
        if (!Directory.Exists(savedGames))
        {
            return new List<FirstRunInstanceCandidate>();
        }

        var candidates = new List<FirstRunInstanceCandidate>();
        try
        {
            foreach (var directory in Directory.EnumerateDirectories(savedGames))
            {
                var score = GetDcsProfileScore(directory);
                if (score <= 0)
                {
                    continue;
                }

                candidates.Add(new FirstRunInstanceCandidate(new DirectoryInfo(directory).Name, Path.GetFullPath(directory), score));
            }
        }
        catch
        {
            // Manual Browse remains available if a folder cannot be scanned.
        }

        return candidates
            .OrderByDescending(item => item.Score)
            .ThenBy(item => item.Name, StringComparer.OrdinalIgnoreCase)
            .ToList();
    }

    private static int GetDcsProfileScore(string directory)
    {
        var hasMissions = Directory.Exists(Path.Combine(directory, "Missions"));
        var hasConfig = Directory.Exists(Path.Combine(directory, "Config"));
        var hasMissionEditor = Directory.Exists(Path.Combine(directory, "MissionEditor"));
        var hasScripts = Directory.Exists(Path.Combine(directory, "Scripts"));
        var hasMods = Directory.Exists(Path.Combine(directory, "Mods"));
        if (!hasMissions && !hasConfig && !hasMissionEditor && !hasScripts && !hasMods)
        {
            return 0;
        }

        var score = 0;
        foreach (var child in new[] { "Missions", "Config", "Logs", "MissionEditor", "Scripts", "Mods" })
        {
            if (Directory.Exists(Path.Combine(directory, child)))
            {
                score++;
            }
        }

        var name = new DirectoryInfo(directory).Name;
        if (name.Contains("DCS", StringComparison.OrdinalIgnoreCase) ||
            name.Contains("server", StringComparison.OrdinalIgnoreCase) ||
            name.Contains("dedicated", StringComparison.OrdinalIgnoreCase))
        {
            score++;
        }

        return score;
    }

    private static bool IsLikelySavedGamesRoot(string directory)
    {
        var info = new DirectoryInfo(Path.GetFullPath(directory));
        return info.Name.Equals("Saved Games", StringComparison.OrdinalIgnoreCase) &&
               !Directory.Exists(Path.Combine(info.FullName, "Missions"));
    }

    private static FirstRunInstanceCandidate BuildCustomInstanceCandidate(string selectedDirectory)
    {
        var profilePath = NormalizeDcsProfileDirectory(selectedDirectory);
        return new FirstRunInstanceCandidate(new DirectoryInfo(profilePath).Name, profilePath, 100);
    }

    private static string NormalizeDcsProfileDirectory(string selectedDirectory)
    {
        var directory = new DirectoryInfo(Path.GetFullPath(selectedDirectory));
        if (directory.Name.Equals("Saves", StringComparison.OrdinalIgnoreCase) &&
            directory.Parent?.Name.Equals("Missions", StringComparison.OrdinalIgnoreCase) == true &&
            directory.Parent.Parent is not null)
        {
            return directory.Parent.Parent.FullName;
        }

        if (directory.Name.Equals("Missions", StringComparison.OrdinalIgnoreCase) && directory.Parent is not null)
        {
            return directory.Parent.FullName;
        }

        return directory.FullName;
    }

    private void ReloadConfig()
    {
        if (_document is null)
        {
            LoadDefaultConfig();
            return;
        }

        if (HasChanges() && MessageBox.Show(this, "Discard unsaved changes and reload?", "Reload", MessageBoxButtons.YesNo, MessageBoxIcon.Question) != DialogResult.Yes)
        {
            return;
        }

        LoadConfig(_document.Path);
    }

    private void LoadCategories(bool renderSelection = true)
    {
        SetCategoryListItems(GetCategoryListNames(), preferredSelection: null);
        WriteAdminUiMapLog("load-categories");

        if (renderSelection)
        {
            RenderSelectedCategory(force: true);
        }
    }

    private List<string> GetCategoryListNames()
    {
        var names = GetVisibleCategoryNames();
        if (_adminUnlocked && !AppMode.IsExportedUserBuild)
        {
            names.Add("Admin Designer");
        }

        if (_showAdvanced.Checked && ShouldShowRawValuesCategory())
        {
            names.Add("Raw Values");
        }

        return names;
    }

    private bool SetCategoryListItems(IReadOnlyList<string> names, string? preferredSelection)
    {
        var restoredPreferredSelection = false;
        _loadingCategories = true;
        try
        {
            _categoryList.BeginUpdate();
            try
            {
                _categoryList.Items.Clear();
                foreach (var name in names)
                {
                    _categoryList.Items.Add(new CategoryListItem(name, GetCategoryDisplayName(name)));
                }

                var selectedIndex = names.Count > 0 ? 0 : -1;
                if (!string.IsNullOrWhiteSpace(preferredSelection))
                {
                    for (var i = 0; i < names.Count; i++)
                    {
                        if (!string.Equals(names[i], preferredSelection, StringComparison.OrdinalIgnoreCase) &&
                            !string.Equals(GetCategoryDisplayName(names[i]), preferredSelection, StringComparison.OrdinalIgnoreCase))
                        {
                            continue;
                        }

                        selectedIndex = i;
                        restoredPreferredSelection = true;
                        break;
                    }
                }

                _categoryList.SelectedIndex = selectedIndex;
            }
            finally
            {
                _categoryList.EndUpdate();
            }
        }
        finally
        {
            _loadingCategories = false;
        }

        return restoredPreferredSelection;
    }

    private bool CategoryListMatches(IReadOnlyList<string> names)
    {
        if (_categoryList.Items.Count != names.Count)
        {
            return false;
        }

        for (var i = 0; i < names.Count; i++)
        {
            if (!string.Equals(GetCategoryItemName(_categoryList.Items[i]), names[i], StringComparison.Ordinal) ||
                !string.Equals(_categoryList.Items[i]?.ToString(), GetCategoryDisplayName(names[i]), StringComparison.Ordinal))
            {
                return false;
            }
        }

        return true;
    }

    private List<string> GetVisibleCategoryNames()
    {
        var names = GetDesignerCategoryNames()
            .Where(name => !IsCategoryHidden(name))
            .Where(ShouldShowCategory)
            .ToList();

        return OrderCategoryNames(names);
    }

    private void ReloadCategoriesPreservingSelection(bool refreshSelectedCategory = false)
    {
        var selected = GetSelectedCategoryName();
        var names = GetCategoryListNames();
        if (CategoryListMatches(names))
        {
            if (refreshSelectedCategory)
            {
                MarkRenderedCategoryPanelDirty();
                RenderSelectedCategory(force: true);
            }

            WriteAdminUiMapLog("reload-categories");
            return;
        }

        MarkAllCategoryPanelsDirty();
        if (SetCategoryListItems(names, selected) && !refreshSelectedCategory)
        {
            WriteAdminUiMapLog("reload-categories");
            return;
        }

        WriteAdminUiMapLog("reload-categories");
        RenderSelectedCategory(force: refreshSelectedCategory);
    }

    private void WriteAdminUiMapLog(string reason)
    {
        if (AppMode.IsExportedUserBuild || !_adminUnlocked || _document is null)
        {
            return;
        }

        try
        {
            var visibleCategories = _categoryList.Items
                .Cast<object>()
                .Select(GetCategoryItemName)
                .Where(name => !string.IsNullOrWhiteSpace(name))
                .ToList();
            var lines = BuildAdminUiMapLines(reason, visibleCategories);
            var signature = string.Join("\n", lines.Where(line =>
                !line.StartsWith("Time:", StringComparison.Ordinal) &&
                !line.StartsWith("Reason:", StringComparison.Ordinal)));
            if (string.Equals(signature, _lastUiMapSignature, StringComparison.Ordinal))
            {
                return;
            }

            _lastUiMapSignature = signature;
            var directory = Path.Combine(RuntimeSettings.SettingsDirectory, "logs");
            Directory.CreateDirectory(directory);
            var timestamp = DateTime.Now.ToString("yyyyMMdd-HHmmss", CultureInfo.InvariantCulture);
            var timestampedPath = Path.Combine(directory, "ui-map-" + timestamp + ".log");
            var latestPath = Path.Combine(directory, "ui-map-latest.log");
            File.WriteAllLines(timestampedPath, lines);
            File.WriteAllLines(latestPath, lines);
            SetStatus("Admin UI map log written: " + latestPath);
        }
        catch (Exception ex)
        {
            SetStatus("Admin UI map log failed: " + ex.Message);
        }
    }

    private List<string> BuildAdminUiMapLines(string reason, IReadOnlyList<string> visibleCategories)
    {
        var lines = new List<string>
        {
            "Foothold Config Manager UI map",
            "Time: " + DateTime.Now.ToString("O", CultureInfo.InvariantCulture),
            "Reason: " + reason,
            "Build mode: " + (AppMode.IsExportedUserBuild ? "User" : "Admin/source"),
            "Admin unlocked: " + _adminUnlocked.ToString(CultureInfo.InvariantCulture),
            "Config: " + (_document?.Path ?? ""),
            "Advanced toggle visible: " + ShouldShowAdvancedToggle().ToString(CultureInfo.InvariantCulture),
            "Advanced toggle checked: " + _showAdvanced.Checked.ToString(CultureInfo.InvariantCulture),
            "Raw Values visible setting: " + ShouldShowRawValuesCategory().ToString(CultureInfo.InvariantCulture),
            "",
            "Visible left-menu categories:"
        };

        for (var i = 0; i < visibleCategories.Count; i++)
        {
            var categoryName = visibleCategories[i];
            lines.Add((i + 1).ToString(CultureInfo.InvariantCulture) + ". " +
                      GetCategoryDisplayName(categoryName) + " [" + categoryName + "] " +
                      "source=" + GetUiMapCategorySource(categoryName));
        }

        lines.Add("");
        lines.Add("Visible category items:");
        foreach (var categoryName in visibleCategories)
        {
            lines.Add("");
            lines.Add("[" + GetCategoryDisplayName(categoryName) + "] key=" + categoryName + " source=" + GetUiMapCategorySource(categoryName));
            var items = GetDesignerItems(categoryName, includeTableRows: true);
            if (items.Count == 0)
            {
                lines.Add("  (no logged normal GUI items)");
                continue;
            }

            for (var i = 0; i < items.Count; i++)
            {
                var item = items[i];
                var rowPrefix = item.Label.StartsWith("  ", StringComparison.Ordinal) ? "  row " : "  item ";
                lines.Add(rowPrefix + (i + 1).ToString(CultureInfo.InvariantCulture) + ". " +
                          item.Key + " | " + item.Label.Trim() +
                          " | source=" + GetUiMapItemSource(categoryName, item));
                AppendUiMapNestedDetails(lines, item);
            }
        }

        return lines;
    }

    private string GetUiMapCategorySource(string categoryName)
    {
        if (categoryName.Equals("Admin Designer", StringComparison.OrdinalIgnoreCase))
        {
            return "admin-only";
        }

        if (categoryName.Equals("Raw Values", StringComparison.OrdinalIgnoreCase))
        {
            return "raw-values-special";
        }

        if (HasConfigCategory(categoryName))
        {
            return _document?.Metadata.CategoryLayouts.ContainsKey(categoryName) == true
                ? "config-section+saved-designer-layout"
                : "config-section";
        }

        if (_document?.Metadata.CategoryLayouts.ContainsKey(categoryName) == true)
        {
            return "saved-designer-layout";
        }

        if (_categories.Any(category => category.Name.Equals(categoryName, StringComparison.OrdinalIgnoreCase)))
        {
            return "hardcoded-category-spec";
        }

        return "config-section";
    }

    private string GetUiMapItemSource(string categoryName, DesignerItem item)
    {
        if (!HasConfigCategory(categoryName) &&
            _document?.Metadata.CategoryLayouts.TryGetValue(categoryName, out var layout) == true &&
            layout.Items.Contains(item.Key, StringComparer.Ordinal))
        {
            return "saved-designer-layout";
        }

        var category = HasConfigCategory(categoryName)
            ? null
            : _categories.FirstOrDefault(candidate => candidate.Name.Equals(categoryName, StringComparison.OrdinalIgnoreCase));
        if (category is not null && category.Keys.Contains(item.Key, StringComparer.Ordinal))
        {
            return "hardcoded-category-spec";
        }

        if (item.StringListTable is not null)
        {
            return "config-string-list";
        }

        if (item.StageTable is not null)
        {
            return "config-stage-table";
        }

        if (item.IsGroup)
        {
            return "config-table-group";
        }

        return item.Label.StartsWith("  ", StringComparison.Ordinal)
            ? "config-table-row"
            : "config-entry";
    }

    private static void AppendUiMapNestedDetails(List<string> lines, DesignerItem item)
    {
        if (item.StringListTable is not null)
        {
            lines.Add("    string-list rows: " + item.StringListTable.Items.Count.ToString(CultureInfo.InvariantCulture));
            return;
        }

        if (item.StageTable is not null)
        {
            lines.Add("    stage rows: " + item.StageTable.Rows.Count.ToString(CultureInfo.InvariantCulture));
            return;
        }

        if (item.IsGroup && !item.Label.StartsWith("  ", StringComparison.Ordinal))
        {
            lines.Add("    table rows: " + item.Entries.Count.ToString(CultureInfo.InvariantCulture));
        }
    }

    private bool ShouldShowDynamicCategory(string categoryName)
    {
        if (_document is null || IsReservedCategory(categoryName) || IsFixedCategory(categoryName) || IsCategoryHidden(categoryName))
        {
            return false;
        }

        if (_document.Metadata.CategoryLayouts.TryGetValue(categoryName, out var layout))
        {
            return layout.Items.Count > 0;
        }

        var entries = GetRenderableCategoryEntries(categoryName).ToList();
        if (entries.Count == 0)
        {
            return false;
        }

        return ShouldIncludeAdvancedEntries() || entries.Any(entry => !entry.IsAdvanced);
    }

    private bool ShouldShowCategory(string categoryName)
    {
        if (_document is null || IsReservedCategory(categoryName) || IsCategoryHidden(categoryName))
        {
            return false;
        }

        if (HasConfigCategory(categoryName))
        {
            return HasVisibleConfigCategoryContent(categoryName);
        }

        return false;
    }

    private bool HasVisibleConfigCategoryContent(string categoryName)
    {
        if (_document is null)
        {
            return false;
        }

        if (_document.Entries.Any(entry =>
                entry.EffectiveCategory.Equals(categoryName, StringComparison.OrdinalIgnoreCase) &&
                (ShouldIncludeAdvancedEntries() || !entry.IsAdvanced)))
        {
            return true;
        }

        return _document.StringListTables.Any(table => table.Section.Equals(categoryName, StringComparison.OrdinalIgnoreCase)) ||
               _document.StageTables.Any(table => table.Section.Equals(categoryName, StringComparison.OrdinalIgnoreCase));
    }

    private bool DoesAdvancedToggleAffectCategory(string categoryName)
    {
        if (_document is null ||
            string.IsNullOrWhiteSpace(categoryName) ||
            IsReservedCategory(categoryName) ||
            IsFixedCategory(categoryName) ||
            _document.Metadata.CategoryLayouts.ContainsKey(categoryName))
        {
            return false;
        }

        return ShouldShowAdvancedToggle() &&
               GetRenderableCategoryEntries(categoryName).Any(entry => entry.IsAdvanced);
    }

    private bool IsCategoryHidden(string categoryName)
    {
        return _document?.Metadata.HiddenCategories.Any(name => name.Equals(categoryName, StringComparison.OrdinalIgnoreCase)) == true;
    }

    private bool ShouldIncludeAdvancedEntries()
    {
        return true;
    }

    private bool ShouldShowAdvancedToggle()
    {
        return false;
    }

    private bool ShouldShowRawValuesCategory()
    {
        return _document?.Metadata.RawValuesVisible ?? true;
    }

    private void ApplyAdvancedToggleVisibility()
    {
        var visible = ShouldShowAdvancedToggle();
        if (!visible && _showAdvanced.Checked)
        {
            _showAdvanced.Checked = false;
        }

        _showAdvanced.Visible = visible;
        ApplyZoomLayoutSizes();
    }

    private List<string> OrderCategoryNames(IEnumerable<string> names)
    {
        var distinctNames = names
            .Where(name => !string.IsNullOrWhiteSpace(name))
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();
        if (_document is null || _document.Metadata.CategoryOrder.Count == 0)
        {
            return distinctNames;
        }

        var ordered = new List<string>();
        foreach (var name in _document.Metadata.CategoryOrder)
        {
            var match = distinctNames.FirstOrDefault(candidate => candidate.Equals(name, StringComparison.OrdinalIgnoreCase));
            if (match is not null && !ordered.Contains(match, StringComparer.OrdinalIgnoreCase))
            {
                ordered.Add(match);
            }
        }

        ordered.AddRange(distinctNames.Where(name => !ordered.Contains(name, StringComparer.OrdinalIgnoreCase)));
        return ordered;
    }

    private bool IsFixedCategory(string categoryName)
    {
        return _categories.Any(category => category.Name.Equals(categoryName, StringComparison.OrdinalIgnoreCase));
    }

    private string GetCategoryDisplayName(string categoryName)
    {
        if (_document?.Metadata.CategoryLabels.TryGetValue(categoryName, out var label) == true &&
            !string.IsNullOrWhiteSpace(label))
        {
            return label;
        }

        return categoryName;
    }

    private string GetSelectedCategoryName()
    {
        return GetCategoryItemName(_categoryList.SelectedItem);
    }

    private static string GetCategoryItemName(object? item)
    {
        return item switch
        {
            CategoryListItem category => category.Name,
            CategoryOrderItem category => category.Name,
            _ => item?.ToString() ?? ""
        };
    }

    private void ClearImportedNewMarkers()
    {
        _unseenImportedNewEntryKeysByCategory.Clear();
        _activeImportedNewEntryKeys.Clear();
        _activeImportedNewCategoryName = null;
        _categoryList.Invalidate();
    }

    private void ApplyImportedNewMarkers(IReadOnlyList<ImportedNewEntryMarker> markers)
    {
        ClearImportedNewMarkers();
        foreach (var marker in markers)
        {
            if (string.IsNullOrWhiteSpace(marker.Category) || string.IsNullOrWhiteSpace(marker.DisplayKey))
            {
                continue;
            }

            if (!_unseenImportedNewEntryKeysByCategory.TryGetValue(marker.Category, out var keys))
            {
                keys = new HashSet<string>(StringComparer.Ordinal);
                _unseenImportedNewEntryKeysByCategory[marker.Category] = keys;
            }

            keys.Add(marker.DisplayKey);
        }

        foreach (var categoryName in _unseenImportedNewEntryKeysByCategory.Keys)
        {
            MarkCategoryPanelDirty(categoryName);
        }

        if (_unseenImportedNewEntryKeysByCategory.Count == 0)
        {
            return;
        }

        _categoryList.Invalidate();
        var selectedCategory = GetSelectedCategoryName();
        if (!string.IsNullOrWhiteSpace(selectedCategory) &&
            _unseenImportedNewEntryKeysByCategory.ContainsKey(selectedCategory))
        {
            PrepareImportedNewMarkersForCategory(selectedCategory);
            RenderSelectedCategory(force: true);
        }
    }

    private bool PrepareImportedNewMarkersForCategory(string categoryName)
    {
        var previousCategory = _activeImportedNewCategoryName;
        var changed = false;
        if (!string.IsNullOrWhiteSpace(previousCategory) &&
            !previousCategory.Equals(categoryName, StringComparison.OrdinalIgnoreCase))
        {
            MarkCategoryPanelDirty(previousCategory);
            changed = true;
        }

        _activeImportedNewEntryKeys.Clear();
        _activeImportedNewCategoryName = null;

        if (_unseenImportedNewEntryKeysByCategory.TryGetValue(categoryName, out var keys))
        {
            foreach (var key in keys)
            {
                _activeImportedNewEntryKeys.Add(key);
            }

            _unseenImportedNewEntryKeysByCategory.Remove(categoryName);
            _activeImportedNewCategoryName = categoryName;
            MarkCategoryPanelDirty(categoryName);
            changed = true;
        }

        if (changed)
        {
            _categoryList.Invalidate();
        }

        return changed;
    }

    private bool HasUnseenImportedNewEntries(string categoryName)
    {
        return _unseenImportedNewEntryKeysByCategory.TryGetValue(categoryName, out var keys) && keys.Count > 0;
    }

    private bool IsImportedNewEntryHighlighted(ConfigEntry entry)
    {
        return _activeImportedNewEntryKeys.Contains(entry.DisplayKey);
    }

    private static List<ImportedNewEntryMarker> CaptureImportedNewMarkers(MizMergePreview preview)
    {
        return preview.NewEntries
            .Where(entry => !string.IsNullOrWhiteSpace(entry.EffectiveCategory) &&
                            !string.IsNullOrWhiteSpace(entry.DisplayKey))
            .Select(entry => new ImportedNewEntryMarker(entry.EffectiveCategory, entry.DisplayKey))
            .Distinct()
            .ToList();
    }

    private static bool IsReservedCategory(string categoryName)
    {
        return categoryName.Equals("Admin Designer", StringComparison.OrdinalIgnoreCase) ||
               categoryName.Equals("Raw Values", StringComparison.OrdinalIgnoreCase);
    }

    private IEnumerable<ConfigEntry> GetRenderableCategoryEntries(string categoryName)
    {
        if (_document is null)
        {
            yield break;
        }

        var fixedKeys = HasConfigCategory(categoryName)
            ? new HashSet<string>(StringComparer.Ordinal)
            : GetFixedRenderedKeys();
        foreach (var entry in _document.Entries.Where(entry =>
                     entry.EffectiveCategory.Equals(categoryName, StringComparison.OrdinalIgnoreCase) &&
                     !fixedKeys.Contains(entry.DisplayKey)))
        {
            yield return entry;
        }
    }

    private HashSet<string> GetFixedRenderedKeys()
    {
        var keys = new HashSet<string>(StringComparer.Ordinal);
        if (_document is null)
        {
            return keys;
        }

        foreach (var category in _categories.Where(category => category.Name is not "Admin Designer" and not "Raw Values"))
        {
            foreach (var key in category.Keys)
            {
                var direct = FindEntry(key);
                if (direct is not null)
                {
                    keys.Add(direct.DisplayKey);
                }

                foreach (var child in FindGroupEntries(key))
                {
                    keys.Add(child.DisplayKey);
                }

                if (FindStringListTable(key) is not null)
                {
                    keys.Add(key);
                }

                if (FindStageTable(key) is not null)
                {
                    keys.Add(key);
                }
            }
        }

        return keys;
    }

    private void LoadSections()
    {
        _sectionFilter.Items.Clear();
        _sectionFilter.Items.Add("All sections");

        if (_document is not null)
        {
            foreach (var section in _document.Entries.Select(entry => entry.Section).Distinct().OrderBy(section => section))
            {
                _sectionFilter.Items.Add(section);
            }
        }

        _sectionFilter.SelectedIndex = 0;
    }

    private void LoadPresets()
    {
        _presetBox.Items.Clear();
        foreach (var name in PresetStore.ListPresetNames())
        {
            _presetBox.Items.Add(name);
        }
    }

    private bool ShouldCacheCategoryPanel(string categoryName)
    {
        return !IsReservedCategory(categoryName);
    }

    private bool TryShowCachedCategoryPanel(string categoryName)
    {
        if (!ShouldCacheCategoryPanel(categoryName) ||
            _dirtyCategoryPanels.Contains(categoryName) ||
            !_categoryPanelCache.TryGetValue(categoryName, out var panel) ||
            panel.IsDisposed)
        {
            return false;
        }

        SaveRenderedCategoryScroll();
        _loadingForm = true;
        try
        {
            _formHost.SuspendLayout();
            try
            {
                DetachFormHostControlsForRender();
                _formHost.Controls.Add(panel);
                _renderedCategoryName = categoryName;
            }
            finally
            {
                _formHost.ResumeLayout();
            }
        }
        finally
        {
            _loadingForm = false;
        }

        RestoreCategoryScroll(categoryName);
        return true;
    }

    private void DetachFormHostControlsForRender()
    {
        while (_formHost.Controls.Count > 0)
        {
            var control = _formHost.Controls[0];
            if (IsCachedCategoryPanel(control) || IsReusableRawEditorControl(control))
            {
                control.Parent = null;
            }
            else
            {
                DetachReusableRawEditorControls(control);
                control.Dispose();
            }
        }
    }

    private bool IsCachedCategoryPanel(Control control)
    {
        return _categoryPanelCache.Values.Any(panel => ReferenceEquals(panel, control));
    }

    private bool IsReusableRawEditorControl(Control control)
    {
        return ReferenceEquals(control, _rawEditorRoot) ||
               ReferenceEquals(control, _grid) ||
               ReferenceEquals(control, _rawSearchBox) ||
               ReferenceEquals(control, _valueBox) ||
               ReferenceEquals(control, _choiceBox) ||
               ReferenceEquals(control, _boolBox) ||
               ReferenceEquals(control, _multiplierPanel) ||
               ReferenceEquals(control, _tuplePanel) ||
               ReferenceEquals(control, _redMultiplier) ||
               ReferenceEquals(control, _blueMultiplier) ||
               ReferenceEquals(control, _redMultiplierText) ||
               ReferenceEquals(control, _blueMultiplierText);
    }

    private void DetachReusableRawEditorControls(Control root)
    {
        foreach (Control child in root.Controls.Cast<Control>().ToList())
        {
            DetachReusableRawEditorControls(child);
        }

        if (IsReusableRawEditorControl(root) && root.Parent is not null)
        {
            root.Parent = null;
        }
    }

    private void CacheCategoryPanel(string categoryName, Control panel)
    {
        if (!ShouldCacheCategoryPanel(categoryName))
        {
            return;
        }

        _categoryPanelCache[categoryName] = panel;
        _dirtyCategoryPanels.Remove(categoryName);
    }

    private void MarkRenderedCategoryPanelDirty()
    {
        if (!string.IsNullOrWhiteSpace(_renderedCategoryName) && ShouldCacheCategoryPanel(_renderedCategoryName))
        {
            _dirtyCategoryPanels.Add(_renderedCategoryName);
        }
    }

    private void MarkAllCategoryPanelsDirty()
    {
        foreach (var categoryName in _categoryPanelCache.Keys.ToList())
        {
            _dirtyCategoryPanels.Add(categoryName);
        }
    }

    private void MarkCategoryPanelDirty(string categoryName)
    {
        if (ShouldCacheCategoryPanel(categoryName))
        {
            _dirtyCategoryPanels.Add(categoryName);
        }
    }

    private void RemoveCachedCategoryPanel(string categoryName)
    {
        if (!_categoryPanelCache.TryGetValue(categoryName, out var panel))
        {
            _dirtyCategoryPanels.Remove(categoryName);
            _categoryScrollPositions.Remove(categoryName);
            return;
        }

        if (panel.Parent is not null)
        {
            panel.Parent = null;
        }

        panel.Dispose();
        _categoryPanelCache.Remove(categoryName);
        _dirtyCategoryPanels.Remove(categoryName);
        _categoryScrollPositions.Remove(categoryName);
    }

    private void ClearCategoryPanelCache()
    {
        foreach (var panel in _categoryPanelCache.Values.Distinct().ToList())
        {
            if (panel.Parent is not null)
            {
                panel.Parent.Controls.Remove(panel);
            }

            panel.Dispose();
        }

        _categoryPanelCache.Clear();
        _dirtyCategoryPanels.Clear();
        _categoryScrollPositions.Clear();
        _renderedCategoryName = null;
    }

    private void SaveRenderedCategoryScroll()
    {
        if (string.IsNullOrWhiteSpace(_renderedCategoryName) ||
            !ShouldCacheCategoryPanel(_renderedCategoryName) ||
            _formHost.Controls.Count == 0)
        {
            return;
        }

        var position = _formHost.AutoScrollPosition;
        _categoryScrollPositions[_renderedCategoryName] = new Point(-position.X, -position.Y);
    }

    private void RestoreCategoryScroll(string categoryName)
    {
        if (!_categoryScrollPositions.TryGetValue(categoryName, out var position))
        {
            return;
        }

        BeginInvoke(() => _formHost.AutoScrollPosition = position);
    }

    private void RenderSelectedCategory(bool force = false)
    {
        if (_document is null || _categoryList.SelectedItem is null)
        {
            return;
        }

        var categoryName = GetSelectedCategoryName();
        if (!force &&
            string.Equals(_renderedCategoryName, categoryName, StringComparison.Ordinal) &&
            !_dirtyCategoryPanels.Contains(categoryName))
        {
            return;
        }

        if (!force && TryShowCachedCategoryPanel(categoryName))
        {
            return;
        }

        SaveRenderedCategoryScroll();
        if (ShouldCacheCategoryPanel(categoryName) && (force || _dirtyCategoryPanels.Contains(categoryName)))
        {
            RemoveCachedCategoryPanel(categoryName);
        }

        _renderedCategoryName = categoryName;
        var category = _categories.FirstOrDefault(item => item.Name == categoryName);

        _loadingForm = true;
        DetachFormHostControlsForRender();

        void FinishRender()
        {
            _loadingForm = false;
            ApplyThemeToControl(_formHost, restyleButtons: false);
            WireBackgroundDehighlightHandlers(_formHost);
        }

        if (categoryName == "Admin Designer")
        {
            _formHost.Controls.Add(BuildAdminDesigner());
            FinishRender();
            return;
        }

        if (categoryName == "Raw Values")
        {
            _formHost.Controls.Add(BuildRawEditor());
            FinishRender();
            RefreshGrid();
            return;
        }

        var panel = new TableLayoutPanel
        {
            Dock = DockStyle.Top,
            AutoSize = true,
            ColumnCount = 1,
            Padding = new Padding(16)
        };
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        _formHost.Controls.Add(panel);
        CacheCategoryPanel(categoryName, panel);

        var title = new Label
        {
            Text = GetCategoryDisplayName(categoryName),
            Dock = DockStyle.Top,
            AutoSize = true,
            Font = new Font(Font, FontStyle.Bold),
            Padding = new Padding(0, 0, 0, 10)
        };
        panel.Controls.Add(title);

        if (categoryName.Equals("Difficulty Stages", StringComparison.OrdinalIgnoreCase))
        {
            var tables = GetDesignerItems(categoryName, includeTableRows: false)
                .Select(item => item.StageTable)
                .Where(table => table is not null)
                .Cast<ConfigStageTable>()
                .ToList();
            if (tables.Count > 0)
            {
                panel.Controls.Add(BuildStageTablesEditor(tables));
            }

            FinishRender();
            RestoreCategoryScroll(categoryName);
            return;
        }

        foreach (var item in GetDesignerItems(categoryName, includeTableRows: false))
        {
            if (item.StringListTable is not null)
            {
                panel.Controls.Add(BuildStringListEditor(item.StringListTable));
                continue;
            }

            if (item.StageTable is not null)
            {
                panel.Controls.Add(BuildStageTableEditor(item.StageTable));
                continue;
            }

            if (item.IsGroup)
            {
                panel.Controls.Add(item.Key.Equals("CallsignOverrides", StringComparison.Ordinal)
                    ? BuildCallsignOverridesEditor(item.Key, item.Entries)
                    : BuildTableEditor(item.Key, item.Entries));
                continue;
            }

            var entry = item.Entries.FirstOrDefault();
            if (entry is not null)
            {
                panel.Controls.Add(BuildEntryEditor(entry));
            }
        }

        FinishRender();
        RestoreCategoryScroll(categoryName);
    }

    private ConfigEntry? FindEntry(string key)
    {
        return _document?.Entries.FirstOrDefault(entry => entry.DisplayKey == key);
    }

    private List<ConfigEntry> FindChildren(string key)
    {
        return _document?.Entries
            .Where(entry => entry.ParentKey == key)
            .OrderBy(entry => entry.LineIndex)
            .ThenBy(entry => entry.Key, StringComparer.OrdinalIgnoreCase)
            .ToList() ?? new List<ConfigEntry>();
    }

    private List<ConfigEntry> FindGroupEntries(string key)
    {
        var children = FindChildren(key);
        if (children.Count > 0 || !key.Equals("CallsignOverrides", StringComparison.Ordinal))
        {
            return children;
        }

        return FindCallsignOverrideEntries();
    }

    private List<ConfigEntry> FindCallsignOverrideEntries()
    {
        return _document?.Entries
            .Where(entry => entry.DisplayKey.StartsWith("CallsignOverrides.", StringComparison.Ordinal) &&
                            entry.ParentKey.StartsWith("CallsignOverrides.", StringComparison.Ordinal))
            .OrderBy(GetCallsignAircraft, StringComparer.OrdinalIgnoreCase)
            .ThenBy(entry => entry.Key, StringComparer.OrdinalIgnoreCase)
            .ToList() ?? new List<ConfigEntry>();
    }

    private ConfigStringListTable? FindStringListTable(string key)
    {
        return _document?.StringListTables.FirstOrDefault(table => table.Key.Equals(key, StringComparison.Ordinal));
    }

    private ConfigStageTable? FindStageTable(string key)
    {
        return _document?.StageTables.FirstOrDefault(table => table.Key.Equals(key, StringComparison.Ordinal));
    }

    private Control BuildStageTablesEditor(List<ConfigStageTable> tables)
    {
        var panel = new TableLayoutPanel
        {
            AutoSize = true,
            Dock = DockStyle.Top,
            ColumnCount = 1,
            Padding = new Padding(0, 0, 0, 8)
        };
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));

        var selectorRow = new FlowLayoutPanel
        {
            AutoSize = true,
            Dock = DockStyle.Top,
            FlowDirection = FlowDirection.LeftToRight,
            WrapContents = false,
            Padding = new Padding(0, 0, 0, 8)
        };
        selectorRow.Controls.Add(new Label
        {
            Text = "Stage table",
            AutoSize = true,
            TextAlign = ContentAlignment.MiddleLeft,
            Margin = new Padding(0, 5, 8, 0)
        });

        var selector = new WheelSafeComboBox
        {
            DropDownStyle = ComboBoxStyle.DropDownList,
            Width = 320
        };
        foreach (var table in tables)
        {
            selector.Items.Add(new StageTableItem(table));
        }

        selectorRow.Controls.Add(selector);
        panel.Controls.Add(selectorRow);

        var host = new Panel
        {
            AutoSize = true,
            Dock = DockStyle.Top
        };
        panel.Controls.Add(host);

        void RenderSelection()
        {
            host.Controls.Clear();
            if (selector.SelectedItem is StageTableItem item)
            {
                host.Controls.Add(BuildStageTableEditor(item.Table));
                ApplyThemeToControl(host, restyleButtons: true);
                RestyleStageDifficultyButtons(host);
            }
        }

        selector.SelectedIndexChanged += (_, _) => RenderSelection();
        selector.SelectedIndex = 0;
        return panel;
    }

    private Control BuildStageTableEditor(ConfigStageTable table)
    {
        GuiMetadataEntry? metadata = null;
        _document?.Metadata.Entries.TryGetValue(table.Key, out metadata);
        var title = metadata?.Label ?? table.GuiLabel ?? GetConfiguredGroupLabel(table.Key);
        var helpText = !string.IsNullOrWhiteSpace(metadata?.Help) ? metadata.Help : table.Description;
        var group = new TableLayoutPanel
        {
            AutoSize = true,
            Dock = DockStyle.Top,
            ColumnCount = 1,
            Padding = new Padding(0, 0, 0, Zoomed(12))
        };
        group.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));

        var header = new FlowLayoutPanel
        {
            AutoSize = true,
            Dock = DockStyle.Top,
            FlowDirection = FlowDirection.LeftToRight,
            WrapContents = false,
            Padding = GetTableHeaderPadding()
        };
        header.Controls.Add(new Label
        {
            Text = title,
            AutoSize = true,
            TextAlign = ContentAlignment.MiddleLeft,
            Margin = GetTableHeaderLabelMargin()
        });
        if (!string.IsNullOrWhiteSpace(helpText))
        {
            header.Controls.Add(MakeHelpButton(title, helpText, table.Key));
        }

        group.Controls.Add(header);
        var stageHint = GetStageTableHint(table);
        if (!string.IsNullOrWhiteSpace(stageHint))
        {
            group.Controls.Add(MakeValueHint(stageHint));
        }

        var buttonRow = new FlowLayoutPanel
        {
            AutoSize = true,
            Dock = DockStyle.Top,
            FlowDirection = FlowDirection.LeftToRight,
            WrapContents = false,
            Padding = new Padding(0, 0, 0, 6)
        };
        var editorHost = new Panel
        {
            AutoSize = true,
            Dock = DockStyle.Top
        };
        var difficultyButtons = new Dictionary<string, Button>(StringComparer.OrdinalIgnoreCase);
        var selectedDifficulty = GetViewedStageDifficulty(table);

        void RenderDifficulty(string difficulty)
        {
            selectedDifficulty = NormalizeStageDifficulty(difficulty) ?? difficulty;
            _viewedStageDifficulties[table.Key] = selectedDifficulty;
            foreach (var pair in difficultyButtons)
            {
                ApplyStageDifficultyButtonStyle(pair.Value, table, pair.Key, selectedDifficulty);
            }

            var grid = EnumerateChildControls<DataGridView>(editorHost).FirstOrDefault();
            if (grid is null)
            {
                editorHost.Controls.Add(BuildStageDifficultyEditor(table, () => selectedDifficulty));
                ApplyThemeToControl(editorHost, restyleButtons: true);
                return;
            }

            RefreshStageGrid(grid, table, selectedDifficulty);
        }

        foreach (var difficulty in new[] { "easy", "medium", "hard" })
        {
            var display = GetStageDifficultyButtonText(table, difficulty);
            var button = MakeDesignerButton(display, () => RenderDifficulty(difficulty), 90);
            button.Tag = new StageDifficultyButtonTag(table.Key, difficulty);
            difficultyButtons[difficulty] = button;
            buttonRow.Controls.Add(button);
        }

        group.Controls.Add(buttonRow);
        group.Controls.Add(editorHost);
        RenderDifficulty(selectedDifficulty);
        group.Controls.Add(MakeValueHint("Rows are read from top to bottom. The first row where active players is less than or equal to Up to players controls the amount."));
        return group;
    }

    private string? GetStageActiveDifficulty(ConfigStageTable table)
    {
        if (string.IsNullOrWhiteSpace(table.LinkedSettingKey))
        {
            return null;
        }

        return NormalizeStageDifficulty(FindEntry(table.LinkedSettingKey)?.ValueText);
    }

    private string GetStageDifficultyButtonText(ConfigStageTable table, string difficulty)
    {
        var display = CultureInfo.InvariantCulture.TextInfo.ToTitleCase(difficulty);
        return string.Equals(GetStageActiveDifficulty(table), difficulty, StringComparison.OrdinalIgnoreCase)
            ? display + " (used)"
            : display;
    }

    private string GetViewedStageDifficulty(ConfigStageTable table)
    {
        return _viewedStageDifficulties.TryGetValue(table.Key, out var difficulty)
            ? NormalizeStageDifficulty(difficulty) ?? difficulty
            : GetStageActiveDifficulty(table) ?? "easy";
    }

    private void ApplyStageDifficultyButtonStyle(Button button, ConfigStageTable table, string difficulty, string viewedDifficulty)
    {
        button.Text = GetStageDifficultyButtonText(table, difficulty);
        StyleButton(button);
        button.FlatAppearance.BorderSize = 1;

        if (!difficulty.Equals(viewedDifficulty, StringComparison.OrdinalIgnoreCase))
        {
            return;
        }

        if (IsDarkPalette())
        {
            button.BackColor = SelectionBackground;
            button.ForeColor = SelectionText;
            button.FlatAppearance.BorderColor = SelectionBackground;
            return;
        }

        button.BackColor = HeaderBackground;
        button.ForeColor = PrimaryTextColor;
        button.FlatAppearance.BorderColor = SelectionBackground;
        button.FlatAppearance.BorderSize = 2;
        button.FlatAppearance.MouseOverBackColor = HeaderBackground;
        button.FlatAppearance.MouseDownBackColor = HeaderBackground;
    }

    private void RestyleStageDifficultyButtons(Control root)
    {
        foreach (var button in EnumerateChildControls<Button>(root))
        {
            if (button.Tag is not StageDifficultyButtonTag tag)
            {
                continue;
            }

            var table = FindStageTable(tag.TableKey);
            if (table is null)
            {
                continue;
            }

            ApplyStageDifficultyButtonStyle(button, table, tag.Difficulty, GetViewedStageDifficulty(table));
        }
    }

    private static string? NormalizeStageDifficulty(string? value)
    {
        foreach (var difficulty in new[] { "easy", "medium", "hard" })
        {
            if (string.Equals(value, difficulty, StringComparison.OrdinalIgnoreCase))
            {
                return difficulty;
            }
        }

        return null;
    }

    private Control BuildStageDifficultyEditor(ConfigStageTable table, Func<string> getDifficulty)
    {
        var difficulty = getDifficulty();
        var group = new TableLayoutPanel
        {
            AutoSize = true,
            Dock = DockStyle.Top,
            ColumnCount = 2,
            RowCount = 1,
            Padding = new Padding(8)
        };
        group.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, GetStageGridWidth()));
        group.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, TableActionColumnWidth));

        var playerColumnWidth = GetStagePlayerColumnWidth();
        var amountColumnWidth = GetStageAmountColumnWidth();
        var grid = new SmoothDataGridView
        {
            Tag = table.Key,
            Dock = DockStyle.Top,
            AllowUserToAddRows = false,
            AllowUserToDeleteRows = false,
            RowHeadersVisible = false,
            MultiSelect = false,
            AllowUserToResizeColumns = false,
            AllowUserToResizeRows = false,
            SelectionMode = DataGridViewSelectionMode.FullRowSelect,
            AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.None,
            Width = GetStageGridWidth(),
            Height = GetStageGridHeight(table, difficulty),
            RowTemplate = { Height = GetStageGridRowHeight() },
            ColumnHeadersHeight = GetStageGridHeaderHeight(),
            ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.DisableResizing
        };
        grid.Columns.Add("player", "Up to players");
        grid.Columns.Add("amount", "Amount");
        ConfigureLockedStageColumn(grid.Columns["player"], playerColumnWidth);
        ConfigureLockedStageColumn(grid.Columns["amount"], amountColumnWidth);
        grid.ScrollBars = GetStageDesiredGridHeight(table, difficulty) > grid.Height ? ScrollBars.Vertical : ScrollBars.None;
        group.Controls.Add(grid, 0, 0);

        RefreshStageGrid(grid, table, difficulty);
        group.Controls.Add(MakeTableActionPanel(
            MakeDesignerButton("Add row", () => AddStageRow(table, getDifficulty(), grid), TableActionButtonWidth),
            MakeDesignerButton("Remove selected", () => RemoveStageRow(table, grid), TableActionButtonWidth),
            MakeDesignerButton("Move up", () => MoveStageRow(table, grid, -1), TableActionButtonWidth),
            MakeDesignerButton("Move down", () => MoveStageRow(table, grid, 1), TableActionButtonWidth)), 1, 0);

        grid.CellValueChanged += (_, args) =>
        {
            if (_loadingForm || args.RowIndex < 0 || grid.Rows[args.RowIndex].Tag is not ConfigStageRow row)
            {
                return;
            }

            var oldPlayer = row.Player;
            var oldAmount = row.Amount;
            ApplyStageGridRow(grid.Rows[args.RowIndex], row);
            if (row.Player != oldPlayer || row.Amount != oldAmount)
            {
                SetUndoAction("edit " + GetConfiguredGroupLabel(table.Key), () =>
                {
                    row.Player = oldPlayer;
                    row.Amount = oldAmount;
                }, () => RefreshStageGrid(grid, table, getDifficulty()));
            }

            SetChangedStatus();
        };
        grid.DataError += (_, _) => { };
        return group;
    }

    private static List<ConfigStageRow> GetStageRows(ConfigStageTable table, string difficulty)
    {
        return table.Rows
            .Where(row => row.Difficulty.Equals(difficulty, StringComparison.OrdinalIgnoreCase))
            .OrderBy(row => row.LineIndex)
            .ToList();
    }

    private int GetStagePlayerColumnWidth()
    {
        return Math.Max(165, TextRenderer.MeasureText("Up to players", Font).Width + 38);
    }

    private int GetStageAmountColumnWidth()
    {
        return Math.Max(120, TextRenderer.MeasureText("Amount", Font).Width + 38);
    }

    private int GetStageGridWidth()
    {
        return GetStagePlayerColumnWidth() + GetStageAmountColumnWidth() + SystemInformation.VerticalScrollBarWidth + 12;
    }

    private static void ConfigureLockedStageColumn(DataGridViewColumn column, int width)
    {
        column.AutoSizeMode = DataGridViewAutoSizeColumnMode.None;
        column.Width = width;
        column.MinimumWidth = width;
        column.Resizable = DataGridViewTriState.False;
    }

    private static int GetStageGridMaxHeight()
    {
        return 360;
    }

    private int GetStageGridHeaderHeight()
    {
        return Math.Max(24, Font.Height + 12);
    }

    private int GetStageGridRowHeight()
    {
        return Math.Max(25, Font.Height + 9);
    }

    private int GetStageDesiredGridHeight(ConfigStageTable table, string difficulty)
    {
        var rows = Math.Max(1, GetStageRows(table, difficulty).Count);
        return GetStageGridHeaderHeight() + rows * GetStageGridRowHeight() + 4;
    }

    private int GetStageGridHeight(ConfigStageTable table, string difficulty)
    {
        var desired = GetStageDesiredGridHeight(table, difficulty);
        if (IsAutoTableHeight(table.Key))
        {
            return Math.Max(78, desired);
        }

        var maxVisibleRows = GetConfiguredMaxVisibleRows(table.Key);
        var maxHeight = maxVisibleRows > 0
            ? Math.Max(78, GetStageGridHeaderHeight() + maxVisibleRows * GetStageGridRowHeight() + 4)
            : GetStageGridMaxHeight();

        return Math.Min(maxHeight, Math.Max(78, desired));
    }

    private void RefreshStageGrid(DataGridView grid, ConfigStageTable table, string difficulty)
    {
        var wasLoading = _loadingForm;
        _loadingForm = true;
        try
        {
            var rows = GetStageRows(table, difficulty);
            SyncGridRows(grid, rows, AddStageGridRow, UpdateStageGridRow);

            grid.Height = GetStageGridHeight(table, difficulty);
            grid.ScrollBars = GetStageDesiredGridHeight(table, difficulty) > grid.Height ? ScrollBars.Vertical : ScrollBars.None;
        }
        finally
        {
            _loadingForm = wasLoading;
        }
    }

    private static void AddStageGridRow(DataGridView grid, ConfigStageRow row)
    {
        var index = grid.Rows.Add(
            ConfigStageRow.FormatDecimal(row.Player),
            ConfigStageRow.FormatDecimal(row.Amount));
        grid.Rows[index].Tag = row;
    }

    private static void UpdateStageGridRow(DataGridViewRow gridRow, ConfigStageRow row)
    {
        gridRow.Cells["player"].Value = ConfigStageRow.FormatDecimal(row.Player);
        gridRow.Cells["amount"].Value = ConfigStageRow.FormatDecimal(row.Amount);
        gridRow.Tag = row;
    }

    private static void SyncGridRows<T>(DataGridView grid, IReadOnlyList<T> items, Action<DataGridView, T> addRow, Action<DataGridViewRow, T> updateRow)
    {
        var firstDisplayedRowIndex = GetFirstDisplayedRowIndex(grid);
        grid.SuspendLayout();
        try
        {
            for (var i = 0; i < items.Count; i++)
            {
                if (i >= grid.Rows.Count)
                {
                    addRow(grid, items[i]);
                }
                else
                {
                    updateRow(grid.Rows[i], items[i]);
                }
            }

            while (grid.Rows.Count > items.Count)
            {
                grid.Rows.RemoveAt(grid.Rows.Count - 1);
            }

            RestoreFirstDisplayedRowIndex(grid, firstDisplayedRowIndex);
        }
        finally
        {
            grid.ResumeLayout();
        }
    }

    private static int GetFirstDisplayedRowIndex(DataGridView grid)
    {
        try
        {
            return grid.Rows.Count > 0 ? grid.FirstDisplayedScrollingRowIndex : -1;
        }
        catch (InvalidOperationException)
        {
            return -1;
        }
        catch (ArgumentOutOfRangeException)
        {
            return -1;
        }
    }

    private static void RestoreFirstDisplayedRowIndex(DataGridView grid, int rowIndex)
    {
        if (rowIndex < 0 || grid.Rows.Count == 0)
        {
            return;
        }

        try
        {
            grid.FirstDisplayedScrollingRowIndex = Math.Min(rowIndex, grid.Rows.Count - 1);
        }
        catch (InvalidOperationException)
        {
        }
        catch (ArgumentOutOfRangeException)
        {
        }
    }

    private static void ApplyStageGridRow(DataGridViewRow gridRow, ConfigStageRow row)
    {
        row.Player = ReadStageDecimalCell(gridRow.Cells["player"].Value, row.Player);
        row.Amount = ReadStageDecimalCell(gridRow.Cells["amount"].Value, row.Amount);
        gridRow.Cells["player"].Value = ConfigStageRow.FormatDecimal(row.Player);
        gridRow.Cells["amount"].Value = ConfigStageRow.FormatDecimal(row.Amount);
    }

    private static decimal ReadStageDecimalCell(object? value, decimal fallback)
    {
        var text = value?.ToString()?.Trim() ?? "";
        return decimal.TryParse(text, NumberStyles.Float, CultureInfo.InvariantCulture, out var parsed)
            ? parsed
            : fallback;
    }

    private void AddStageRow(ConfigStageTable table, string difficulty, DataGridView grid)
    {
        if (_document is null)
        {
            return;
        }

        try
        {
            var row = _document.AddStageRow(table, difficulty);
            RefreshStageGrid(grid, table, difficulty);
            SelectStageGridRow(grid, row);
            SetUndoAction("add stage row", () =>
            {
                _document.RemoveStageRow(table, row);
                RefreshStageGrid(grid, table, difficulty);
            });
            SetChangedStatus();
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Add stage row failed", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
    }

    private void RemoveStageRow(ConfigStageTable table, DataGridView grid)
    {
        if (_document is null || grid.CurrentRow?.Tag is not ConfigStageRow row)
        {
            return;
        }

        if (MessageBox.Show(this, "Remove the selected stage row?", "Remove stage row", MessageBoxButtons.YesNo, MessageBoxIcon.Question) != DialogResult.Yes)
        {
            return;
        }

        try
        {
            var difficulty = row.Difficulty;
            var player = row.Player;
            var amount = row.Amount;
            var selectedIndex = grid.CurrentRow.Index;
            _document.RemoveStageRow(table, row);
            RefreshStageGrid(grid, table, difficulty);
            SelectStageGridRowByIndex(grid, selectedIndex);
            SetUndoAction("remove stage row", () =>
            {
                var restored = _document.AddStageRow(table, difficulty, player, amount);
                RefreshStageGrid(grid, table, difficulty);
                SelectStageGridRow(grid, restored);
            });
            SetChangedStatus();
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Remove stage row failed", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
    }

    private void MoveStageRow(ConfigStageTable table, DataGridView grid, int delta)
    {
        if (_document is null || grid.CurrentRow?.Tag is not ConfigStageRow row)
        {
            return;
        }

        try
        {
            var difficulty = row.Difficulty;
            _document.MoveStageRow(table, row, delta);
            RefreshStageGrid(grid, table, difficulty);
            SelectStageGridRow(grid, row);
            SetUndoAction(delta < 0 ? "move stage row up" : "move stage row down", () =>
            {
                _document.MoveStageRow(table, row, -delta);
                RefreshStageGrid(grid, table, difficulty);
                SelectStageGridRow(grid, row);
            });
            SetChangedStatus();
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Move stage row failed", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
    }

    private static void SelectStageGridRowByIndex(DataGridView grid, int index)
    {
        if (grid.Rows.Count == 0)
        {
            return;
        }

        var rowIndex = Math.Clamp(index, 0, grid.Rows.Count - 1);
        grid.ClearSelection();
        grid.Rows[rowIndex].Selected = true;
        grid.CurrentCell = grid.Rows[rowIndex].Cells[0];
    }

    private static void SelectStageGridRow(DataGridView grid, ConfigStageRow row)
    {
        grid.ClearSelection();
        foreach (DataGridViewRow gridRow in grid.Rows)
        {
            if (!ReferenceEquals(gridRow.Tag, row))
            {
                continue;
            }

            gridRow.Selected = true;
            grid.CurrentCell = gridRow.Cells[0];
            return;
        }
    }

    private string GetStageTableHint(ConfigStageTable table)
    {
        if (!string.IsNullOrWhiteSpace(table.LinkedSettingKey) &&
            FindEntry(table.LinkedSettingKey) is { } linkedEntry)
        {
            return "Linked setting: " + linkedEntry.DisplayName + ". Controls amount by active player count.";
        }

        return GetStageTableHint(table.Key);
    }

    private static string GetStageTableHint(string key)
    {
        var linked = key switch
        {
            "CapLimitStages" => "Cap Difficulty",
            "RedCasLimitStages" => "CAS Difficulty",
            "RedSeadLimitStages" => "SEAD Difficulty",
            "RedRunwayStrikeLimitStages" => "Runway Strike Difficulty",
            "BlueCapSupportStages" => "Friendly CAP Support",
            "BlueCasSupportStages" => "Friendly CAS Support",
            "BlueSeadSupportStages" => "Friendly SEAD Support",
            _ => ""
        };

        return string.IsNullOrWhiteSpace(linked)
            ? "Controls amount by active player count."
            : "Linked setting: " + linked + ". Controls amount by active player count.";
    }

    private Control BuildEntryEditor(ConfigEntry entry)
    {
        var isNewImportEntry = IsImportedNewEntryHighlighted(entry);
        var headerBackColor = isNewImportEntry ? GetNewHighlightBackColor() : MainBackground;
        var group = new TableLayoutPanel
        {
            AutoSize = true,
            Dock = DockStyle.Top,
            ColumnCount = 1,
            Padding = new Padding(0, 0, 0, Zoomed(12)),
            BackColor = MainBackground
        };
        group.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));

        var header = new FlowLayoutPanel
        {
            Dock = DockStyle.Top,
            AutoSize = true,
            FlowDirection = FlowDirection.LeftToRight,
            WrapContents = false,
            Padding = GetTableHeaderPadding(),
            BackColor = headerBackColor,
            Tag = isNewImportEntry ? ImportedNewHighlightTag : null
        };

        var label = new Label
        {
            Text = entry.DisplayName,
            AutoSize = true,
            TextAlign = ContentAlignment.MiddleLeft,
            Margin = GetTableHeaderLabelMargin(),
            ForeColor = PrimaryTextColor,
            BackColor = headerBackColor,
            Tag = isNewImportEntry ? ImportedNewHighlightTag : null
        };
        SetHelp(label, entry);
        header.Controls.Add(label);
        if (isNewImportEntry)
        {
            header.Controls.Add(MakeNewBadgeLabel());
        }

        var description = EntryDescription(entry);
        if (!string.IsNullOrWhiteSpace(description))
        {
            var helpButton = MakeHelpButton(entry.DisplayName, description, entry.DisplayKey);
            header.Controls.Add(helpButton);
        }

        group.Controls.Add(header);

        var editor = BuildFriendlyControl(entry);
        SetHelp(editor, entry);
        if (ShouldLockEntryEditor(entry, out var lockReason))
        {
            editor.Enabled = false;
            SetToolbarHelp(editor, lockReason);
        }

        group.Controls.Add(editor);

        var help = new Label
        {
            Text = string.IsNullOrWhiteSpace(lockReason) ? FirstLine(description) : lockReason,
            AutoSize = false,
            Height = 36,
            Dock = DockStyle.Top,
            ForeColor = HelpTextColor,
            BackColor = MainBackground,
            Padding = new Padding(0, 4, 0, 0),
            Tag = null
        };
        SetHelp(help, entry);
        ConfigureEditableHelpControl(help, entry.DisplayKey, entry.DisplayName, description);
        group.Controls.Add(help);
        return group;
    }

    private bool ShouldLockEntryEditor(ConfigEntry entry, out string reason)
    {
        return TryGetEditorLockReason(entry.DisplayKey, out reason);
    }

    private bool ShouldLockTableEditor(string key, out string reason)
    {
        return TryGetEditorLockReason(key, out reason);
    }

    private bool TryGetEditorLockReason(string targetKey, out string reason)
    {
        foreach (var rule in EditorLockRules.Where(rule => rule.TargetKey.Equals(targetKey, StringComparison.Ordinal)))
        {
            if (rule.IsLockedBy(FindEntry(rule.SourceKey)))
            {
                reason = rule.Reason;
                return true;
            }
        }

        reason = "";
        return false;
    }

    private static bool EntryAffectsEditorLocks(ConfigEntry entry)
    {
        return EditorLockRules.Any(rule => rule.SourceKey.Equals(entry.DisplayKey, StringComparison.Ordinal));
    }

    private void RefreshDependentEditors(ConfigEntry entry)
    {
        var targetKeys = EditorLockRules
            .Where(rule => rule.SourceKey.Equals(entry.DisplayKey, StringComparison.Ordinal))
            .Select(rule => rule.TargetKey)
            .Distinct(StringComparer.Ordinal)
            .ToList();
        if (targetKeys.Count == 0)
        {
            return;
        }

        var affectedCategories = GetCategoriesContainingDesignerKeys(targetKeys);
        foreach (var categoryName in affectedCategories)
        {
            MarkCategoryPanelDirty(categoryName);
        }

        if (affectedCategories.Contains(GetSelectedCategoryName(), StringComparer.OrdinalIgnoreCase))
        {
            RenderSelectedCategory(force: true);
        }
    }

    private void RefreshLinkedStageEditors(ConfigEntry entry)
    {
        if (_document is null)
        {
            return;
        }

        var tableKeys = _document.StageTables
            .Where(table => string.Equals(table.LinkedSettingKey, entry.DisplayKey, StringComparison.Ordinal))
            .Select(table => table.Key)
            .ToHashSet(StringComparer.Ordinal);
        if (tableKeys.Count == 0)
        {
            return;
        }

        foreach (var root in _categoryPanelCache.Values.Append(_formHost).Distinct())
        {
            foreach (var button in EnumerateChildControls<Button>(root))
            {
                if (button.Tag is not StageDifficultyButtonTag tag || !tableKeys.Contains(tag.TableKey))
                {
                    continue;
                }

                var table = FindStageTable(tag.TableKey);
                if (table is not null)
                {
                    ApplyStageDifficultyButtonStyle(button, table, tag.Difficulty, GetViewedStageDifficulty(table));
                }
            }
        }
    }

    private List<string> GetCategoriesContainingDesignerKeys(IReadOnlyCollection<string> targetKeys)
    {
        return GetCategoryListNames()
            .Where(ShouldCacheCategoryPanel)
            .Where(categoryName => GetDesignerItems(categoryName, includeTableRows: false, includeAdvanced: true)
                .Any(item => DesignerItemMatchesAnyKey(item, targetKeys)))
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();
    }

    private static bool DesignerItemMatchesAnyKey(DesignerItem item, IReadOnlyCollection<string> targetKeys)
    {
        return targetKeys.Contains(item.Key, StringComparer.Ordinal) ||
               item.Entries.Any(entry =>
                   targetKeys.Contains(entry.DisplayKey, StringComparer.Ordinal) ||
                   targetKeys.Contains(entry.ParentKey, StringComparer.Ordinal));
    }

    private Control BuildFriendlyControl(ConfigEntry entry)
    {
        if (string.Equals(entry.ControlTypeOverride, "multiline", StringComparison.OrdinalIgnoreCase))
        {
            var multilineBox = new TextBox
            {
                Dock = DockStyle.Top,
                Height = 140,
                Multiline = true,
                ScrollBars = ScrollBars.Vertical,
                Text = entry.ValueText
            };
            multilineBox.TextChanged += (_, _) =>
            {
                ChangeEntryValue(
                    entry,
                    "edit " + entry.DisplayName,
                    () => entry.ValueText = multilineBox.Text,
                    () => RefreshControlValue(() => multilineBox.Text = entry.ValueText));
            };
            return multilineBox;
        }

        if (entry.IsLongText)
        {
            var textBox = new TextBox
            {
                Dock = DockStyle.Top,
                Height = 150,
                Multiline = true,
                ScrollBars = ScrollBars.Vertical,
                Text = entry.ValueText
            };
            textBox.TextChanged += (_, _) =>
            {
                ChangeEntryValue(
                    entry,
                    "edit " + entry.DisplayName,
                    () => entry.ValueText = textBox.Text,
                    () => RefreshControlValue(() => textBox.Text = entry.ValueText));
            };
            return textBox;
        }

        if (entry.IsSideMultiplier && entry.TryGetSideMultipliers(out var red, out var blue))
        {
            return BuildSideMultiplierControl(entry, red, blue);
        }

        if (entry.Choices.Count > 0)
        {
            var comboBox = new WheelSafeComboBox
            {
                DropDownStyle = ComboBoxStyle.DropDownList
            };
            foreach (var choice in entry.Choices)
            {
                comboBox.Items.Add(choice.Display);
            }

            comboBox.Text = entry.ValueText;
            ConfigureCompactEditor(comboBox, GetChoiceEditorWidth(entry));
            comboBox.SelectedIndexChanged += (_, _) =>
            {
                ChangeEntryValue(
                    entry,
                    "edit " + entry.DisplayName,
                    () => entry.ValueText = comboBox.Text,
                    () => RefreshControlValue(() =>
                    {
                        comboBox.Text = entry.ValueText;
                        RefreshLinkedStageEditors(entry);
                    }));
                RefreshLinkedStageEditors(entry);
            };
            return comboBox;
        }

        if (entry.Kind == ConfigValueKind.Boolean ||
            string.Equals(entry.ControlTypeOverride, "checkbox", StringComparison.OrdinalIgnoreCase))
        {
            var comboBox = new WheelSafeComboBox
            {
                DropDownStyle = ComboBoxStyle.DropDownList
            };
            comboBox.Items.Add("true");
            comboBox.Items.Add("false");
            comboBox.Text = FormatBooleanDisplay(entry.ValueText);
            ConfigureCompactEditor(comboBox, 170);
            comboBox.SelectedIndexChanged += (_, _) =>
            {
                ChangeEntryValue(
                    entry,
                    "edit " + entry.DisplayName,
                    () => entry.ValueText = ParseBooleanDisplay(comboBox.Text),
                    () => RefreshControlValue(() =>
                    {
                        comboBox.Text = FormatBooleanDisplay(entry.ValueText);
                        RefreshDependentEditors(entry);
                    }));
                RefreshDependentEditors(entry);
            };
            return comboBox;
        }

        if (entry.Kind == ConfigValueKind.Number ||
            string.Equals(entry.ControlTypeOverride, "number", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(entry.ControlTypeOverride, "percent", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(entry.ControlTypeOverride, "seconds", StringComparison.OrdinalIgnoreCase))
        {
            return BuildNumberControl(entry);
        }

        var plainTextBox = new TextBox
        {
            Text = entry.ValueText
        };
        ConfigureCompactEditor(plainTextBox, GetTextEditorWidth(entry));
        plainTextBox.TextChanged += (_, _) =>
        {
            ChangeEntryValue(
                entry,
                "edit " + entry.DisplayName,
                () => entry.ValueText = plainTextBox.Text,
                () => RefreshControlValue(() => plainTextBox.Text = entry.ValueText));
        };
        return plainTextBox;
    }

    private void ChangeEntryValue(ConfigEntry entry, string description, Action applyChange, Action? refreshAction = null)
    {
        if (_loadingForm)
        {
            return;
        }

        var oldValue = entry.ValueText;
        applyChange();
        var newValue = entry.ValueText;
        if (!StringComparer.Ordinal.Equals(newValue, oldValue))
        {
            SetEntryValueUndoAction(entry, description, oldValue, newValue, refreshAction);
        }

        SetChangedStatus();
    }

    private void RefreshControlValue(Action refresh)
    {
        var wasLoading = _loadingForm;
        _loadingForm = true;
        try
        {
            refresh();
        }
        finally
        {
            _loadingForm = wasLoading;
        }
    }

    private static void ConfigureCompactEditor(Control control, int width)
    {
        control.Dock = DockStyle.None;
        control.Anchor = AnchorStyles.Top | AnchorStyles.Left;
        control.Width = width;
    }

    private static int GetChoiceEditorWidth(ConfigEntry entry)
    {
        var longest = entry.Choices
            .Select(choice => choice.Display.Length)
            .DefaultIfEmpty(0)
            .Max();
        return Math.Max(180, Math.Min(420, longest * 8 + 58));
    }

    private static int GetTextEditorWidth(ConfigEntry entry)
    {
        var textLength = Math.Max(entry.ValueText.Length, 12);
        return Math.Max(220, Math.Min(520, textLength * 8 + 80));
    }

    private Control BuildSideMultiplierControl(ConfigEntry entry, decimal red, decimal blue)
    {
        var panel = new TableLayoutPanel
        {
            Dock = DockStyle.Top,
            AutoSize = true,
            ColumnCount = 3
        };
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 70));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 100));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));

        var redInput = CreateMultiplierInput(red);
        var blueInput = CreateMultiplierInput(blue);
        var redText = MakeValueHint(DescribeMultiplier(redInput.Value));
        var blueText = MakeValueHint(DescribeMultiplier(blueInput.Value));

        redInput.ValueChanged += (_, _) =>
        {
            redText.Text = DescribeMultiplier(redInput.Value);
            ChangeEntryValue(entry, "edit " + entry.DisplayName, () =>
                entry.SetSideMultipliers(redInput.Value, blueInput.Value),
                () => RefreshControlValue(() =>
                {
                    if (entry.TryGetSideMultipliers(out var restoredRed, out var restoredBlue))
                    {
                        redInput.Value = ClampMultiplier(restoredRed);
                        blueInput.Value = ClampMultiplier(restoredBlue);
                        redText.Text = DescribeMultiplier(redInput.Value);
                        blueText.Text = DescribeMultiplier(blueInput.Value);
                    }
                }));
        };
        blueInput.ValueChanged += (_, _) =>
        {
            blueText.Text = DescribeMultiplier(blueInput.Value);
            ChangeEntryValue(entry, "edit " + entry.DisplayName, () =>
                entry.SetSideMultipliers(redInput.Value, blueInput.Value),
                () => RefreshControlValue(() =>
                {
                    if (entry.TryGetSideMultipliers(out var restoredRed, out var restoredBlue))
                    {
                        redInput.Value = ClampMultiplier(restoredRed);
                        blueInput.Value = ClampMultiplier(restoredBlue);
                        redText.Text = DescribeMultiplier(redInput.Value);
                        blueText.Text = DescribeMultiplier(blueInput.Value);
                    }
                }));
        };

        panel.Controls.Add(MakeLabel("RED"), 0, 0);
        panel.Controls.Add(redInput, 1, 0);
        panel.Controls.Add(redText, 2, 0);
        panel.Controls.Add(MakeLabel("BLUE"), 0, 1);
        panel.Controls.Add(blueInput, 1, 1);
        panel.Controls.Add(blueText, 2, 1);
        return panel;
    }

    private static NumericUpDown CreateMultiplierInput(decimal value)
    {
        return new WheelSafeNumericUpDown
        {
            DecimalPlaces = 2,
            Increment = 0.05m,
            Minimum = 0.1m,
            Maximum = 5m,
            Value = ClampMultiplier(value),
            Dock = DockStyle.Fill
        };
    }

    private Control BuildNumberControl(ConfigEntry entry)
    {
        var panel = new TableLayoutPanel
        {
            Dock = DockStyle.Top,
            AutoSize = true,
            ColumnCount = 2
        };
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 130));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));

        var input = new WheelSafeNumericUpDown
        {
            Dock = DockStyle.Fill,
            DecimalPlaces = entry.ValueText.Contains('.', StringComparison.Ordinal) ? 2 : 0,
            Minimum = GetNumberMinimum(entry),
            Maximum = GetNumberMaximum(entry),
            Increment = entry.ValueText.Contains('.', StringComparison.Ordinal) ? 0.05m : 1m
        };
        if (decimal.TryParse(entry.ValueText, NumberStyles.Float, CultureInfo.InvariantCulture, out var value))
        {
            input.Value = Math.Max(input.Minimum, Math.Min(input.Maximum, value));
        }

        input.ValueChanged += (_, _) =>
        {
            ChangeEntryValue(entry, "edit " + entry.DisplayName, () =>
                entry.ValueText = input.Value.ToString(input.DecimalPlaces == 0 ? "0" : "0.##", CultureInfo.InvariantCulture),
                () => RefreshControlValue(() => SetNumericInputValue(input, entry)));
        };

        panel.Controls.Add(input, 0, 0);
        panel.Controls.Add(MakeValueHint(GetUnitHint(entry)), 1, 0);
        return panel;
    }

    private static void SetNumericInputValue(NumericUpDown input, ConfigEntry entry)
    {
        if (decimal.TryParse(entry.ValueText, NumberStyles.Float, CultureInfo.InvariantCulture, out var value))
        {
            input.Value = Math.Max(input.Minimum, Math.Min(input.Maximum, value));
        }
    }

    private static decimal GetNumberMinimum(ConfigEntry entry)
    {
        return entry.DisplayKey.Contains("Chance", StringComparison.OrdinalIgnoreCase) ||
               string.Equals(entry.ControlTypeOverride, "percent", StringComparison.OrdinalIgnoreCase)
            ? 0
            : -100000;
    }

    private static decimal GetNumberMaximum(ConfigEntry entry)
    {
        return entry.DisplayKey.Contains("Chance", StringComparison.OrdinalIgnoreCase) ||
               string.Equals(entry.ControlTypeOverride, "percent", StringComparison.OrdinalIgnoreCase)
            ? 100
            : 100000;
    }

    private static string GetUnitHint(ConfigEntry entry)
    {
        var text = EntryDescription(entry);
        if (entry.DisplayKey.Contains("Chance", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(entry.ControlTypeOverride, "percent", StringComparison.OrdinalIgnoreCase))
        {
            return "percent";
        }

        if (entry.DisplayKey.EndsWith("Sec", StringComparison.OrdinalIgnoreCase) ||
            text.Contains("seconds", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(entry.ControlTypeOverride, "seconds", StringComparison.OrdinalIgnoreCase))
        {
            return "seconds";
        }

        if (text.Contains("meters", StringComparison.OrdinalIgnoreCase))
        {
            return "meters";
        }

        if (entry.DisplayKey.EndsWith("NM", StringComparison.OrdinalIgnoreCase))
        {
            return "NM";
        }

        if (text.Contains("rank", StringComparison.OrdinalIgnoreCase))
        {
            return "rank";
        }

        if (text.Contains("credits", StringComparison.OrdinalIgnoreCase))
        {
            return "credits";
        }

        return "";
    }

    private static Label MakeValueHint(string text)
    {
        return new Label
        {
            Text = text,
            Dock = DockStyle.Fill,
            TextAlign = ContentAlignment.MiddleLeft,
            ForeColor = HelpTextColor,
            BackColor = MainBackground,
            Padding = new Padding(8, 0, 0, 0)
        };
    }

    private Label MakeNewBadgeLabel()
    {
        return new Label
        {
            Text = "NEW",
            AutoSize = true,
            TextAlign = ContentAlignment.MiddleCenter,
            Margin = new Padding(Zoomed(4), Zoomed(2), 0, 0),
            Padding = new Padding(Zoomed(5), Zoomed(1), Zoomed(5), Zoomed(1)),
            ForeColor = GetNewBadgeTextColor(),
            BackColor = GetNewBadgeBackColor(),
            BorderStyle = BorderStyle.FixedSingle,
            Tag = ImportedNewBadgeTag
        };
    }

    private Control BuildStringListEditor(ConfigStringListTable table)
    {
        return IsBucketStringListEditor(table)
            ? BuildStringListBucketEditor(table)
            : BuildSimpleStringListEditor(table);
    }

    private static bool IsBucketStringListEditor(ConfigStringListTable table)
    {
        return table.GuiEditor?.Equals("bucket", StringComparison.OrdinalIgnoreCase) == true;
    }

    private Control BuildStringListBucketEditor(ConfigStringListTable table)
    {
        GuiMetadataEntry? metadata = null;
        _document?.Metadata.Entries.TryGetValue(table.Key, out metadata);
        var title = metadata?.Label ?? table.GuiLabel ?? GetConfiguredGroupLabel(table.Key);
        var helpText = !string.IsNullOrWhiteSpace(metadata?.Help) ? metadata.Help : table.Description;
        DataGridView? activeGrid = null;
        DataGridView? inactiveGrid = null;
        var group = new TableLayoutPanel
        {
            Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right,
            Height = Math.Min(640, Math.Max(220, table.Items.Count * 26 + 76)),
            Width = GetStringListBucketEditorWidth(),
            ColumnCount = 4,
            RowCount = 2,
            Padding = new Padding(0, 0, 0, 8)
        };
        group.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50));
        group.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, Zoomed(54)));
        group.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50));
        group.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, TableActionColumnWidth));
        group.RowStyles.Add(new RowStyle(SizeType.Absolute, GetTableHeaderRowHeight()));
        group.RowStyles.Add(new RowStyle(SizeType.Percent, 100));

        var header = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            FlowDirection = FlowDirection.LeftToRight,
            WrapContents = false,
            Padding = GetTableHeaderPadding()
        };
        header.Controls.Add(new Label
        {
            Text = title,
            AutoSize = true,
            TextAlign = ContentAlignment.MiddleLeft,
            Margin = GetTableHeaderLabelMargin()
        });
        if (!string.IsNullOrWhiteSpace(helpText))
        {
            header.Controls.Add(MakeHelpButton(title, helpText, table.Key));
        }
        group.Controls.Add(header, 0, 0);

        group.Controls.Add(MakeStringListBucketHeader("Available / commented"), 2, 0);

        activeGrid = MakeStringListBucketGrid(table.Key, "Active");
        inactiveGrid = MakeStringListBucketGrid(table.Key + ":inactive", "Inactive");
        DataGridView? selectedBucketGrid = activeGrid;
        activeGrid.Enter += (_, _) => selectedBucketGrid = activeGrid;
        inactiveGrid.Enter += (_, _) => selectedBucketGrid = inactiveGrid;
        activeGrid.CellMouseDown += (_, _) => selectedBucketGrid = activeGrid;
        inactiveGrid.CellMouseDown += (_, _) => selectedBucketGrid = inactiveGrid;
        var movePanel = MakeStringListMovePanel(
            MakeDesignerButton(">", () => DeactivateStringListItemRow(table, activeGrid, inactiveGrid), Zoomed(42)),
            MakeDesignerButton("<", () => ActivateStringListItemRow(table, activeGrid, inactiveGrid), Zoomed(42)));
        _toolTip.SetToolTip(movePanel, "Move selected items between active and commented.");
        group.Controls.Add(activeGrid, 0, 1);
        group.Controls.Add(movePanel, 1, 1);
        group.Controls.Add(inactiveGrid, 2, 1);
        group.Controls.Add(MakeTableActionPanel(
            MakeDesignerButton("Add item", () => AddStringListItemRow(table, activeGrid, inactiveGrid), TableActionButtonWidth),
            MakeDesignerButton("Remove selected", () => RemoveStringListItemRow(table, activeGrid, inactiveGrid, selectedBucketGrid), TableActionButtonWidth)), 3, 1);

        RefreshStringListGrids(activeGrid, inactiveGrid, table);
        ApplyStringListBucketLayout(group, activeGrid, inactiveGrid);
        return group;
    }

    private Control BuildSimpleStringListEditor(ConfigStringListTable table)
    {
        GuiMetadataEntry? metadata = null;
        _document?.Metadata.Entries.TryGetValue(table.Key, out metadata);
        var title = metadata?.Label ?? table.GuiLabel ?? GetConfiguredGroupLabel(table.Key);
        var helpText = !string.IsNullOrWhiteSpace(metadata?.Help) ? metadata.Help : table.Description;
        DataGridView? grid = null;
        var group = new TableLayoutPanel
        {
            Anchor = AnchorStyles.Top | AnchorStyles.Left,
            Height = Math.Min(640, Math.Max(220, table.Items.Count * 26 + 76)),
            ColumnCount = 2,
            RowCount = 2,
            Padding = new Padding(0, 0, 0, 8)
        };
        group.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        group.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, TableActionColumnWidth));
        group.RowStyles.Add(new RowStyle(SizeType.Absolute, GetTableHeaderRowHeight()));
        group.RowStyles.Add(new RowStyle(SizeType.Percent, 100));

        var header = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            FlowDirection = FlowDirection.LeftToRight,
            WrapContents = false,
            Padding = GetTableHeaderPadding()
        };
        header.Controls.Add(new Label
        {
            Text = title,
            AutoSize = true,
            TextAlign = ContentAlignment.MiddleLeft,
            Margin = GetTableHeaderLabelMargin()
        });
        if (!string.IsNullOrWhiteSpace(helpText))
        {
            header.Controls.Add(MakeHelpButton(title, helpText, table.Key));
        }
        group.Controls.Add(header, 0, 0);

        grid = new SmoothDataGridView
        {
            Tag = table.Key,
            Dock = DockStyle.Fill,
            AllowUserToAddRows = false,
            AllowUserToDeleteRows = false,
            RowHeadersVisible = false,
            MultiSelect = false,
            ReadOnly = true,
            SelectionMode = DataGridViewSelectionMode.FullRowSelect,
            AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.None
        };
        grid.Columns.Add("value", "Value");
        ConfigureFillColumn(grid.Columns["value"], 540);
        ApplyCompactTableLayout(group, grid);
        group.Controls.Add(grid, 0, 1);
        group.Controls.Add(MakeTableActionPanel(
            MakeDesignerButton("Add item", () => AddSimpleStringListItemRow(table, grid), TableActionButtonWidth),
            MakeDesignerButton("Remove selected", () => RemoveSimpleStringListItemRow(table, grid), TableActionButtonWidth)), 1, 1);

        RefreshSimpleStringListGrid(grid, table);
        ApplyCompactTableLayout(group, grid, 220, 640, GetTableHeightPadding(76));
        return group;
    }

    private static Label MakeStringListBucketHeader(string text)
    {
        return new Label
        {
            Text = text,
            Dock = DockStyle.Fill,
            TextAlign = ContentAlignment.MiddleLeft,
            Padding = new Padding(0, 4, 0, 0),
            ForeColor = HelpTextColor,
            BackColor = MainBackground
        };
    }

    private static DataGridView MakeStringListBucketGrid(string tag, string headerText)
    {
        var grid = new SmoothDataGridView
        {
            Tag = tag,
            Dock = DockStyle.Fill,
            AllowUserToAddRows = false,
            AllowUserToDeleteRows = false,
            RowHeadersVisible = false,
            MultiSelect = false,
            ReadOnly = true,
            SelectionMode = DataGridViewSelectionMode.FullRowSelect,
            AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.None
        };
        grid.Columns.Add("value", headerText);
        ConfigureFillColumn(grid.Columns["value"], 300);
        return grid;
    }

    private static FlowLayoutPanel MakeStringListMovePanel(params Button[] buttons)
    {
        var panel = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            FlowDirection = FlowDirection.TopDown,
            WrapContents = false,
            Padding = new Padding(6, 42, 0, 0)
        };

        foreach (var button in buttons)
        {
            button.Margin = new Padding(0, 0, 0, 8);
            panel.Controls.Add(button);
        }

        return panel;
    }

    private int GetStringListBucketEditorWidth()
    {
        var availableWidth = _formHost.ClientSize.Width > 0
            ? _formHost.ClientSize.Width - 48
            : ClientSize.Width - 320;
        return Math.Max(760, availableWidth);
    }

    private void ApplyStringListBucketLayout(TableLayoutPanel group, DataGridView activeGrid, DataGridView inactiveGrid)
    {
        group.Width = GetStringListBucketEditorWidth();
        group.Height = Math.Max(
            GetTableActionMinimumHeight(group),
            GetStringListBucketHeight(activeGrid, inactiveGrid, 220, 640, GetTableHeightPadding(76)));
        inactiveGrid.Height = activeGrid.Height;
    }

    private int GetStringListBucketHeight(DataGridView activeGrid, DataGridView inactiveGrid, int minimumHeight, int maximumHeight, int heightPadding)
    {
        return Math.Max(
            GetConfiguredTableHeight(activeGrid, minimumHeight, maximumHeight, heightPadding),
            GetConfiguredTableHeight(inactiveGrid, minimumHeight, maximumHeight, heightPadding));
    }

    private static FlowLayoutPanel MakeTableActionPanel(params Button[] buttons)
    {
        var panel = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            FlowDirection = FlowDirection.TopDown,
            WrapContents = false,
            Padding = new Padding(8, 0, 0, 0)
        };

        foreach (var button in buttons)
        {
            button.Margin = new Padding(0, 0, 0, 8);
            panel.Controls.Add(button);
        }

        return panel;
    }

    private void AddSimpleStringListItemRow(ConfigStringListTable table, DataGridView? grid)
    {
        if (_document is null || grid is null)
        {
            return;
        }

        var value = PromptForText("Add list item", "Value");
        if (string.IsNullOrWhiteSpace(value))
        {
            return;
        }

        try
        {
            var item = _document.AddStringListItem(table, value.Trim());
            RefreshSimpleStringListGrid(grid, table);
            SelectGridRowByTag(grid, item);
            SetUndoAction("add " + value.Trim(), () =>
            {
                _document.RemoveStringListItem(table, item);
                RefreshSimpleStringListGrid(grid, table);
            });
            SetChangedStatus();
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Add item failed", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
    }

    private void RemoveSimpleStringListItemRow(ConfigStringListTable table, DataGridView? grid)
    {
        if (_document is null || grid?.CurrentRow?.Tag is not ConfigStringListItem item)
        {
            return;
        }

        if (MessageBox.Show(this, "Remove " + item.Value + " from this list?", "Remove item", MessageBoxButtons.YesNo, MessageBoxIcon.Question) != DialogResult.Yes)
        {
            return;
        }

        try
        {
            var removedValue = item.Value;
            var selectedIndex = grid.CurrentRow.Index;
            _document.RemoveStringListItem(table, item);
            RefreshSimpleStringListGrid(grid, table);
            SelectGridRowByIndex(grid, selectedIndex);
            SetUndoAction("remove " + removedValue, () =>
            {
                var restored = _document.AddStringListItem(table, removedValue);
                RefreshSimpleStringListGrid(grid, table);
                SelectGridRowByTag(grid, restored);
            });
            SetChangedStatus();
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Remove item failed", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
    }

    private void AddStringListItemRow(ConfigStringListTable table, DataGridView? activeGrid, DataGridView? inactiveGrid)
    {
        if (_document is null || activeGrid is null || inactiveGrid is null)
        {
            return;
        }

        var value = PromptForText("Add list item", "Value");
        if (string.IsNullOrWhiteSpace(value))
        {
            return;
        }

        try
        {
            var itemValue = value.Trim();
            _document.ActivateStringListValue(table, itemValue, _stringListCatalog.GetValues(_document, table.Key));
            if (_stringListCatalog.Add(_document, table.Key, itemValue))
            {
                _stringListCatalog.Save();
            }

            RefreshStringListGrids(activeGrid, inactiveGrid, table);
            SelectBucketRowByValue(activeGrid, itemValue);
            SetUndoAction("add " + itemValue, () =>
            {
                if (FindActiveStringListItem(table, itemValue) is { } active)
                {
                    _document.RemoveStringListItem(table, active);
                }

                RefreshStringListGrids(activeGrid, inactiveGrid, table);
            });
            SetChangedStatus();
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Add item failed", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
    }

    private void DeactivateStringListItemRow(ConfigStringListTable table, DataGridView? activeGrid, DataGridView? inactiveGrid)
    {
        if (_document is null ||
            activeGrid is null ||
            inactiveGrid is null ||
            activeGrid.CurrentRow?.Tag is not StringListBucketItem bucket ||
            bucket.Item is null)
        {
            return;
        }

        try
        {
            var itemValue = bucket.Value;
            _document.DeactivateStringListItem(table, bucket.Item);
            if (_stringListCatalog.Add(_document, table.Key, itemValue))
            {
                _stringListCatalog.Save();
            }

            RefreshStringListGrids(activeGrid, inactiveGrid, table);
            SelectBucketRowByValue(inactiveGrid, itemValue);
            SetUndoAction("comment " + itemValue, () =>
            {
                    _document.ActivateStringListValue(table, itemValue, _stringListCatalog.GetValues(_document, table.Key));
                RefreshStringListGrids(activeGrid, inactiveGrid, table);
                SelectBucketRowByValue(activeGrid, itemValue);
            });
            SetChangedStatus();
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Move item failed", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
    }

    private void ActivateStringListItemRow(ConfigStringListTable table, DataGridView? activeGrid, DataGridView? inactiveGrid)
    {
        if (_document is null ||
            activeGrid is null ||
            inactiveGrid is null ||
            inactiveGrid.CurrentRow?.Tag is not StringListBucketItem bucket)
        {
            return;
        }

        try
        {
            var itemValue = bucket.Value;
            _document.ActivateStringListValue(table, itemValue, _stringListCatalog.GetValues(_document, table.Key));
            if (_stringListCatalog.Add(_document, table.Key, itemValue))
            {
                _stringListCatalog.Save();
            }

            RefreshStringListGrids(activeGrid, inactiveGrid, table);
            SelectBucketRowByValue(activeGrid, itemValue);
            SetUndoAction("activate " + itemValue, () =>
            {
                if (FindActiveStringListItem(table, itemValue) is not { } active)
                {
                    return;
                }

                if (bucket.CatalogOnly)
                {
                    _document.RemoveStringListItem(table, active);
                }
                else
                {
                    _document.DeactivateStringListItem(table, active);
                }

                RefreshStringListGrids(activeGrid, inactiveGrid, table);
                SelectBucketRowByValue(inactiveGrid, itemValue);
            });
            SetChangedStatus();
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Move item failed", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
    }

    private void RemoveStringListItemRow(ConfigStringListTable table, DataGridView? activeGrid, DataGridView? inactiveGrid, DataGridView? selectedGrid)
    {
        if (_document is null || activeGrid is null || inactiveGrid is null)
        {
            return;
        }

        var removeInactive = ReferenceEquals(selectedGrid, inactiveGrid) || inactiveGrid.ContainsFocus;
        var bucket = removeInactive
            ? inactiveGrid.CurrentRow?.Tag as StringListBucketItem
            : (activeGrid.CurrentRow?.Tag as StringListBucketItem) ?? inactiveGrid.CurrentRow?.Tag as StringListBucketItem;
        if (bucket is null)
        {
            return;
        }

        if (MessageBox.Show(this, "Remove " + bucket.Value + " from this list and catalog?", "Remove item", MessageBoxButtons.YesNo, MessageBoxIcon.Question) != DialogResult.Yes)
        {
            return;
        }

        try
        {
            var removedValue = bucket.Value;
            var changedConfig = false;
            if (bucket.IsActive && bucket.Item is not null)
            {
                _document.RemoveStringListItem(table, bucket.Item);
                changedConfig = true;
            }
            else if (bucket.Item is not null)
            {
                _document.RemoveCommentedStringListItem(table, bucket.Item);
                changedConfig = true;
            }

            var catalogChanged = _stringListCatalog.Remove(_document, table.Key, removedValue);
            if (catalogChanged)
            {
                _stringListCatalog.Save();
            }

            RefreshStringListGrids(activeGrid, inactiveGrid, table);
            SetUndoAction("remove " + removedValue, () =>
            {
                if (bucket.IsActive)
                {
                    _document.AddStringListItem(table, removedValue);
                }
                else if (!bucket.CatalogOnly)
                {
                    _document.AddCommentedStringListItem(table, removedValue);
                }

                if (_stringListCatalog.Add(_document, table.Key, removedValue))
                {
                    _stringListCatalog.Save();
                }

                RefreshStringListGrids(activeGrid, inactiveGrid, table);
            });

            if (changedConfig)
            {
                SetChangedStatus();
            }
            else if (catalogChanged)
            {
                SetStatus("Removed " + removedValue + " from the saved catalog.");
            }
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Remove item failed", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
    }

    private Control BuildTableEditor(string key, List<ConfigEntry> entries)
    {
        GuiMetadataEntry? metadata = null;
        _document?.Metadata.Entries.TryGetValue(key, out metadata);
        var title = metadata?.Label ?? GetConfiguredGroupLabel(key);
        var helpText = !string.IsNullOrWhiteSpace(metadata?.Help)
            ? metadata.Help
            : entries.FirstOrDefault(entry => !string.IsNullOrWhiteSpace(entry.ParentDescription))?.ParentDescription ?? "";
        var isLocked = ShouldLockTableEditor(key, out var lockReason);
        DataGridView? grid = null;
        var group = new TableLayoutPanel
        {
            Anchor = AnchorStyles.Top | AnchorStyles.Left,
            Height = Math.Min(520, Math.Max(170, entries.Count * 26 + 70)),
            ColumnCount = 2,
            RowCount = 2,
            Padding = new Padding(0, 0, 0, 8)
        };
        group.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        group.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, TableActionColumnWidth));
        group.RowStyles.Add(new RowStyle(SizeType.Absolute, GetTableHeaderRowHeight()));
        group.RowStyles.Add(new RowStyle(SizeType.Percent, 100));

        var header = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            FlowDirection = FlowDirection.LeftToRight,
            WrapContents = false,
            Padding = GetTableHeaderPadding()
        };
        var label = new Label
        {
            Text = title,
            AutoSize = true,
            TextAlign = ContentAlignment.MiddleLeft,
            Margin = GetTableHeaderLabelMargin()
        };
        header.Controls.Add(label);
        if (!string.IsNullOrWhiteSpace(lockReason) || !string.IsNullOrWhiteSpace(helpText))
        {
            header.Controls.Add(MakeHelpButton(title, string.IsNullOrWhiteSpace(lockReason) ? helpText : lockReason, key));
        }
        group.Controls.Add(header, 0, 0);

        grid = new SmoothDataGridView
        {
            Tag = key,
            Dock = DockStyle.Fill,
            AllowUserToAddRows = false,
            AllowUserToDeleteRows = false,
            RowHeadersVisible = false,
            MultiSelect = false,
            ReadOnly = isLocked,
            SelectionMode = DataGridViewSelectionMode.FullRowSelect,
            AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.None
        };
        if (isLocked)
        {
            SetToolbarHelp(grid, lockReason);
        }
        group.Controls.Add(grid, 0, 1);
        BuildTableColumns(grid, entries);
        ApplyCompactTableLayout(group, grid);
        var addButton = MakeDesignerButton("Add row", () => AddTableEntryRow(key, entries, grid), TableActionButtonWidth);
        var removeButton = MakeDesignerButton("Remove selected", () => RemoveTableEntryRow(entries, grid), TableActionButtonWidth);
        if (isLocked)
        {
            addButton.Enabled = false;
            removeButton.Enabled = false;
        }
        group.Controls.Add(MakeTableActionPanel(addButton, removeButton), 1, 1);

        grid.SuspendLayout();
        try
        {
            foreach (var entry in entries)
            {
                AddTableRow(grid, entry);
            }
        }
        finally
        {
            grid.ResumeLayout();
        }

        ApplyCompactTableLayout(group, grid, 170, 520, GetTableHeightPadding(70));
        grid.CellValueChanged += (_, args) =>
        {
            if (_loadingForm || args.RowIndex < 0 || grid.Rows[args.RowIndex].Tag is not ConfigEntry entry)
            {
                return;
            }

            var oldValue = entry.ValueText;
            ApplyTableRow(grid.Rows[args.RowIndex], entry);
            if (!StringComparer.Ordinal.Equals(entry.ValueText, oldValue))
            {
                SetEntryValueUndoAction(entry, "edit " + entry.DisplayName, oldValue, entry.ValueText, () => RefreshTableGrid(grid, entries));
            }

            SetChangedStatus();
        };
        grid.CurrentCellDirtyStateChanged += (_, _) =>
        {
            if (grid.IsCurrentCellDirty)
            {
                grid.CommitEdit(DataGridViewDataErrorContexts.Commit);
            }
        };
        grid.DataError += (_, _) => { };
        return group;
    }

    private void AddTableEntryRow(string parentKey, List<ConfigEntry> entries, DataGridView? grid)
    {
        if (_document is null || grid is null || entries.Count == 0)
        {
            return;
        }

        var key = PromptForText("Add table row", "Item name");
        if (string.IsNullOrWhiteSpace(key))
        {
            return;
        }

        key = key.Trim();
        try
        {
            var template = entries[0];
            var entry = _document.AddTableEntry(parentKey, key, GetDefaultTableValue(entries), template);
            entries.Add(entry);
            AddTableRow(grid, entry);
            if (grid.Parent is TableLayoutPanel group)
            {
                ApplyCompactTableLayout(group, grid, 170, 520, GetTableHeightPadding(70));
            }

            grid.ClearSelection();
            grid.Rows[grid.Rows.Count - 1].Selected = true;
            SetUndoAction("add " + key, () =>
            {
                _document.RemoveEntry(entry);
                entries.Remove(entry);
                RefreshTableGrid(grid, entries);
            });
            SetChangedStatus();
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Add row failed", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
    }

    private void RemoveTableEntryRow(List<ConfigEntry> entries, DataGridView? grid)
    {
        if (_document is null || grid?.CurrentRow?.Tag is not ConfigEntry entry)
        {
            return;
        }

        if (MessageBox.Show(this, "Remove " + entry.Key + " from this table?", "Remove row", MessageBoxButtons.YesNo, MessageBoxIcon.Question) != DialogResult.Yes)
        {
            return;
        }

        try
        {
            var parentKey = entry.ParentKey;
            var key = entry.Key;
            var valueText = entry.ValueText;
            var template = entry;
            var selectedIndex = grid.CurrentRow.Index;
            _document.RemoveEntry(entry);
            entries.Remove(entry);
            RefreshTableGrid(grid, entries);
            SelectGridRowByIndex(grid, selectedIndex);
            SetUndoAction("remove " + key, () =>
            {
                var restored = _document.AddTableEntry(parentKey, key, valueText, template);
                entries.Add(restored);
                RefreshTableGrid(grid, entries);
                SelectGridRowByTag(grid, restored);
            });
            SetChangedStatus();
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Remove row failed", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
    }

    private void RefreshStringListGrids(DataGridView activeGrid, DataGridView inactiveGrid, ConfigStringListTable table)
    {
        var activeItems = GetStringListItemsInSourceOrder(table)
            .Select(item => new StringListBucketItem(item.Value, item, IsActive: true, CatalogOnly: false))
            .ToList();
        var inactiveItems = GetInactiveStringListBucketItems(table);

        SyncGridRows(activeGrid, activeItems, AddStringListBucketGridRow, UpdateStringListBucketGridRow);
        SyncGridRows(inactiveGrid, inactiveItems, AddStringListBucketGridRow, UpdateStringListBucketGridRow);

        if (activeGrid.Parent is TableLayoutPanel group)
        {
            ApplyStringListBucketLayout(group, activeGrid, inactiveGrid);
        }
    }

    private void RefreshSimpleStringListGrid(DataGridView grid, ConfigStringListTable table)
    {
        var items = GetStringListItemsInSourceOrder(table);
        SyncGridRows(grid, items, AddStringListGridRow, UpdateStringListGridRow);

        if (grid.Parent is TableLayoutPanel group)
        {
            ApplyCompactTableLayout(group, grid, 220, 640, GetTableHeightPadding(76));
        }
    }

    private List<StringListBucketItem> GetInactiveStringListBucketItems(ConfigStringListTable table)
    {
        var document = _document ?? throw new InvalidOperationException("No config is loaded.");
        var activeValues = table.Items
            .Select(item => item.Value)
            .ToHashSet(StringComparer.Ordinal);
        var commentedByValue = GetCommentedStringListItemsInSourceOrder(table)
            .GroupBy(item => item.Value, StringComparer.Ordinal)
            .ToDictionary(group => group.Key, group => group.First(), StringComparer.Ordinal);
        var values = new List<string>();
        foreach (var value in _stringListCatalog.GetValues(document, table.Key))
        {
            if (!values.Any(existing => existing.Equals(value, StringComparison.Ordinal)))
            {
                values.Add(value);
            }
        }

        foreach (var value in commentedByValue.Keys)
        {
            if (!values.Any(existing => existing.Equals(value, StringComparison.Ordinal)))
            {
                values.Add(value);
            }
        }

        return values
            .Where(value => !activeValues.Contains(value))
            .Select(value => commentedByValue.TryGetValue(value, out var item)
                ? new StringListBucketItem(value, item, IsActive: false, CatalogOnly: false)
                : new StringListBucketItem(value, null, IsActive: false, CatalogOnly: true))
            .ToList();
    }

    private static List<ConfigStringListItem> GetStringListItemsInSourceOrder(ConfigStringListTable table)
    {
        return table.Items
            .OrderBy(item => item.LineIndex)
            .ThenBy(item => item.StartIndex)
            .ToList();
    }

    private static List<ConfigStringListItem> GetCommentedStringListItemsInSourceOrder(ConfigStringListTable table)
    {
        return table.CommentedItems
            .OrderBy(item => item.LineIndex)
            .ThenBy(item => item.StartIndex)
            .ToList();
    }

    private static ConfigStringListItem? FindActiveStringListItem(ConfigStringListTable table, string value)
    {
        return table.Items.FirstOrDefault(item => item.Value.Equals(value, StringComparison.Ordinal));
    }

    private static void AddStringListGridRow(DataGridView grid, ConfigStringListItem item)
    {
        var rowIndex = grid.Rows.Add(item.Value);
        grid.Rows[rowIndex].Tag = item;
    }

    private static void UpdateStringListGridRow(DataGridViewRow row, ConfigStringListItem item)
    {
        row.Cells["value"].Value = item.Value;
        row.Tag = item;
    }

    private static void AddStringListBucketGridRow(DataGridView grid, StringListBucketItem item)
    {
        var rowIndex = grid.Rows.Add(item.Value);
        grid.Rows[rowIndex].Tag = item;
    }

    private static void UpdateStringListBucketGridRow(DataGridViewRow row, StringListBucketItem item)
    {
        row.Cells["value"].Value = item.Value;
        row.Tag = item;
    }

    private static void SelectBucketRowByValue(DataGridView grid, string value)
    {
        foreach (DataGridViewRow row in grid.Rows)
        {
            if (row.Tag is StringListBucketItem item && item.Value.Equals(value, StringComparison.Ordinal))
            {
                grid.ClearSelection();
                row.Selected = true;
                grid.CurrentCell = row.Cells[0];
                return;
            }
        }
    }

    private void RefreshTableGrid(DataGridView grid, List<ConfigEntry> entries)
    {
        SyncGridRows(grid, entries, AddTableRow, UpdateTableGridRow);

        if (grid.Parent is TableLayoutPanel group)
        {
            ApplyCompactTableLayout(group, grid, 170, 520, GetTableHeightPadding(70));
        }
    }

    private static void SelectGridRowByIndex(DataGridView grid, int index)
    {
        if (grid.Rows.Count == 0)
        {
            return;
        }

        var rowIndex = Math.Clamp(index, 0, grid.Rows.Count - 1);
        grid.ClearSelection();
        grid.Rows[rowIndex].Selected = true;
        grid.CurrentCell = grid.Rows[rowIndex].Cells[0];
    }

    private static void SelectGridRowByTag(DataGridView grid, object tag)
    {
        grid.ClearSelection();
        foreach (DataGridViewRow row in grid.Rows)
        {
            if (!ReferenceEquals(row.Tag, tag))
            {
                continue;
            }

            row.Selected = true;
            grid.CurrentCell = row.Cells[0];
            return;
        }
    }

    private string? PromptForText(string title, string labelText, string defaultText = "")
    {
        using var dialog = new Form
        {
            Text = title,
            StartPosition = FormStartPosition.CenterParent,
            FormBorderStyle = FormBorderStyle.FixedDialog,
            MinimizeBox = false,
            MaximizeBox = false,
            ClientSize = new Size(420, 122),
            Font = Font
        };

        dialog.Controls.Add(new Label
        {
            Text = labelText,
            AutoSize = true,
            Location = new Point(12, 14)
        });

        var textBox = new TextBox
        {
            Location = new Point(12, 38),
            Width = 396,
            Text = defaultText
        };
        dialog.Controls.Add(textBox);

        var okButton = new Button
        {
            Text = "Add",
            DialogResult = DialogResult.OK,
            Location = new Point(246, 78),
            Width = 76
        };
        var cancelButton = new Button
        {
            Text = "Cancel",
            DialogResult = DialogResult.Cancel,
            Location = new Point(332, 78),
            Width = 76
        };
        dialog.Controls.Add(okButton);
        dialog.Controls.Add(cancelButton);

        dialog.AcceptButton = okButton;
        dialog.CancelButton = cancelButton;
        dialog.Shown += (_, _) =>
        {
            textBox.Focus();
            textBox.SelectAll();
        };
        return dialog.ShowDialog(this) == DialogResult.OK ? textBox.Text : null;
    }

    private (string Aircraft, string Callsign)? PromptForCallsignRow(string defaultAircraft)
    {
        using var dialog = new Form
        {
            Text = "Add callsign",
            StartPosition = FormStartPosition.CenterParent,
            FormBorderStyle = FormBorderStyle.FixedDialog,
            MinimizeBox = false,
            MaximizeBox = false,
            ClientSize = new Size(460, 174),
            Font = Font,
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        };

        dialog.Controls.Add(new Label
        {
            Text = "Aircraft",
            AutoSize = true,
            Location = new Point(12, 14),
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        });
        var aircraftBox = new TextBox
        {
            Location = new Point(12, 38),
            Width = 436,
            Text = defaultAircraft
        };
        StyleInput(aircraftBox);
        dialog.Controls.Add(aircraftBox);

        dialog.Controls.Add(new Label
        {
            Text = "Callsign",
            AutoSize = true,
            Location = new Point(12, 72),
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        });
        var callsignBox = new TextBox
        {
            Location = new Point(12, 96),
            Width = 436
        };
        StyleInput(callsignBox);
        dialog.Controls.Add(callsignBox);

        var addButton = new Button
        {
            Text = "Add",
            DialogResult = DialogResult.OK,
            Location = new Point(286, 132),
            Width = 76
        };
        var cancelButton = new Button
        {
            Text = "Cancel",
            DialogResult = DialogResult.Cancel,
            Location = new Point(372, 132),
            Width = 76
        };
        StyleButton(addButton);
        StyleButton(cancelButton);
        dialog.Controls.Add(addButton);
        dialog.Controls.Add(cancelButton);

        dialog.AcceptButton = addButton;
        dialog.CancelButton = cancelButton;
        dialog.Shown += (_, _) =>
        {
            callsignBox.Focus();
            callsignBox.SelectAll();
        };

        if (dialog.ShowDialog(this) != DialogResult.OK)
        {
            return null;
        }

        var aircraft = aircraftBox.Text.Trim();
        var callsign = callsignBox.Text.Trim();
        return string.IsNullOrWhiteSpace(aircraft) || string.IsNullOrWhiteSpace(callsign)
            ? null
            : (aircraft, callsign);
    }

    private string? PromptForHelpText(string title, string defaultText)
    {
        using var dialog = new Form
        {
            Text = "Edit Help Text",
            StartPosition = FormStartPosition.CenterParent,
            FormBorderStyle = FormBorderStyle.Sizable,
            MinimizeBox = false,
            MaximizeBox = true,
            ClientSize = new Size(640, 420),
            MinimumSize = new Size(460, 300),
            Font = Font,
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        };

        dialog.Controls.Add(new Label
        {
            Text = title,
            AutoSize = true,
            Location = new Point(12, 12),
            ForeColor = PrimaryTextColor,
            BackColor = MainBackground
        });

        var textBox = new TextBox
        {
            Multiline = true,
            AcceptsReturn = true,
            AcceptsTab = true,
            ScrollBars = ScrollBars.Vertical,
            WordWrap = true,
            Text = defaultText,
            Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right,
            Location = new Point(12, 38),
            Size = new Size(616, 320)
        };
        StyleInput(textBox);
        dialog.Controls.Add(textBox);

        var saveButton = new Button
        {
            Text = "Save",
            DialogResult = DialogResult.OK,
            Anchor = AnchorStyles.Bottom | AnchorStyles.Right,
            Location = new Point(466, 378),
            Width = 76
        };
        var cancelButton = new Button
        {
            Text = "Cancel",
            DialogResult = DialogResult.Cancel,
            Anchor = AnchorStyles.Bottom | AnchorStyles.Right,
            Location = new Point(552, 378),
            Width = 76
        };
        StyleButton(saveButton);
        StyleButton(cancelButton);
        dialog.Controls.Add(saveButton);
        dialog.Controls.Add(cancelButton);

        dialog.AcceptButton = saveButton;
        dialog.CancelButton = cancelButton;
        dialog.Shown += (_, _) =>
        {
            textBox.Focus();
            textBox.SelectAll();
        };
        return dialog.ShowDialog(this) == DialogResult.OK ? textBox.Text : null;
    }

    private void EditHelpMetadata(string key, string title, string currentHelpText)
    {
        if (!_adminUnlocked || AppMode.IsExportedUserBuild || _document is null)
        {
            return;
        }

        _toolTip.Hide(this);
        var edited = PromptForHelpText(title, currentHelpText);
        if (edited is null)
        {
            return;
        }

        var metadata = _document.Metadata.GetOrCreate(key);
        metadata.Help = NullIfWhite(edited);
        _document.Metadata.RemoveIfEmpty(key);
        _document.Metadata.Save();
        _document.ApplyMetadata();
        RefreshCurrentView();
        SetStatus("Help text saved for " + title + ": " + _document.Metadata.Path);
    }

    private static string GetDefaultTableValue(List<ConfigEntry> entries)
    {
        var template = entries[0];
        if (entries.All(IsPriceRankEntry))
        {
            return "{ price = 0, reqRank = 1 }";
        }

        if (template.TupleFields.Count > 0)
        {
            return "{ " + string.Join(", ", template.TupleFields.Select(GetDefaultTupleValue)) + " }";
        }

        return template.Kind switch
        {
            ConfigValueKind.Boolean => "true",
            ConfigValueKind.Number => "0",
            ConfigValueKind.String => "",
            _ => "{}"
        };
    }

    private static string GetDefaultTupleValue(ConfigTupleField field)
    {
        return field.Kind switch
        {
            ConfigTupleFieldKind.Boolean => "false",
            ConfigTupleFieldKind.Choice => field.Choices.FirstOrDefault()?.Literal ?? "1",
            ConfigTupleFieldKind.Number => "0",
            _ => ""
        };
    }

    private Control BuildCallsignOverridesEditor(string key, List<ConfigEntry> entries)
    {
        GuiMetadataEntry? metadata = null;
        _document?.Metadata.Entries.TryGetValue(key, out metadata);
        var title = metadata?.Label ?? GetConfiguredGroupLabel(key);
        var helpText = !string.IsNullOrWhiteSpace(metadata?.Help)
            ? metadata.Help
            : entries.FirstOrDefault(entry => !string.IsNullOrWhiteSpace(entry.ParentDescription))?.ParentDescription ?? "";
        var group = new TableLayoutPanel
        {
            Anchor = AnchorStyles.Top | AnchorStyles.Left,
            Height = Math.Min(680, Math.Max(220, entries.Count * 26 + 76)),
            ColumnCount = 2,
            Padding = new Padding(0, 0, 0, 8)
        };
        group.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        group.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, TableActionColumnWidth));
        group.RowStyles.Add(new RowStyle(SizeType.Absolute, GetTableHeaderRowHeight()));
        group.RowStyles.Add(new RowStyle(SizeType.Percent, 100));

        var header = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            FlowDirection = FlowDirection.LeftToRight,
            WrapContents = false,
            Padding = GetTableHeaderPadding()
        };
        header.Controls.Add(new Label
        {
            Text = title,
            AutoSize = true,
            TextAlign = ContentAlignment.MiddleLeft,
            Margin = GetTableHeaderLabelMargin()
        });
        if (!string.IsNullOrWhiteSpace(helpText))
        {
            header.Controls.Add(MakeHelpButton(title, helpText, key));
        }
        group.Controls.Add(header, 0, 0);

        var grid = new SmoothDataGridView
        {
            Tag = key,
            Dock = DockStyle.Fill,
            AllowUserToAddRows = false,
            AllowUserToDeleteRows = false,
            RowHeadersVisible = false,
            AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.None
        };
        grid.Columns.Add("aircraft", "Aircraft");
        grid.Columns["aircraft"].ReadOnly = true;
        grid.Columns.Add("callsign", "Callsign");
        grid.Columns.Add("iff1", "IFF 1");
        grid.Columns.Add("iff2", "IFF 2");
        grid.Columns.Add("iff3", "IFF 3");
        grid.Columns.Add("iff4", "IFF 4");
        ConfigureFixedColumn(grid.Columns["aircraft"], 130);
        ConfigureFillColumn(grid.Columns["callsign"], 150);
        ConfigureFixedColumn(grid.Columns["iff1"], 70);
        ConfigureFixedColumn(grid.Columns["iff2"], 70);
        ConfigureFixedColumn(grid.Columns["iff3"], 70);
        ConfigureFixedColumn(grid.Columns["iff4"], 70);
        ApplyCompactTableLayout(group, grid);
        group.Controls.Add(grid, 0, 1);
        group.Controls.Add(MakeTableActionPanel(
            MakeDesignerButton("Add row", () => AddCallsignOverrideRow(key, entries, grid), TableActionButtonWidth),
            MakeDesignerButton("Remove selected", () => RemoveCallsignOverrideRow(entries, grid), TableActionButtonWidth)), 1, 1);

        RefreshCallsignGrid(grid, entries);

        ApplyCompactTableLayout(group, grid, 220, 680, GetTableHeightPadding(76));
        ConfigEntry? editingCallsignEntry = null;
        string editingCallsignOriginal = "";
        grid.CellDoubleClick += (_, args) =>
        {
            if (args.RowIndex < 0 ||
                args.ColumnIndex < 0 ||
                !grid.Columns[args.ColumnIndex].Name.Equals("callsign", StringComparison.Ordinal) ||
                grid.Rows[args.RowIndex].Tag is not ConfigEntry)
            {
                return;
            }

            var cell = grid.Rows[args.RowIndex].Cells[args.ColumnIndex];
            cell.ReadOnly = false;
            grid.CurrentCell = cell;
            grid.BeginEdit(true);
        };
        grid.CellBeginEdit += (_, args) =>
        {
            if (args.RowIndex < 0 ||
                args.ColumnIndex < 0 ||
                !grid.Columns[args.ColumnIndex].Name.Equals("callsign", StringComparison.Ordinal))
            {
                return;
            }

            var cell = grid.Rows[args.RowIndex].Cells[args.ColumnIndex];
            if (cell.ReadOnly ||
                grid.Rows[args.RowIndex].Tag is not ConfigEntry entry)
            {
                args.Cancel = true;
                return;
            }

            editingCallsignEntry = entry;
            editingCallsignOriginal = entry.Key;
        };
        grid.CellEndEdit += (_, args) =>
        {
            if (args.RowIndex < 0 ||
                args.ColumnIndex < 0 ||
                !grid.Columns[args.ColumnIndex].Name.Equals("callsign", StringComparison.Ordinal))
            {
                return;
            }

            var cell = grid.Rows[args.RowIndex].Cells[args.ColumnIndex];
            cell.ReadOnly = true;
            if (editingCallsignEntry is null)
            {
                return;
            }

            var oldEntry = editingCallsignEntry;
            var oldKey = editingCallsignOriginal;
            editingCallsignEntry = null;
            editingCallsignOriginal = "";

            var newKey = cell.Value?.ToString()?.Trim() ?? "";
            if (string.IsNullOrWhiteSpace(newKey) ||
                oldKey.Equals(newKey, StringComparison.Ordinal))
            {
                cell.Value = oldKey;
                return;
            }

            RenameCallsignOverrideFromGrid(entries, grid, oldEntry, oldKey, newKey, cell);
        };
        grid.CellValueChanged += (_, args) =>
        {
            if (_loadingForm || args.RowIndex < 0 || grid.Rows[args.RowIndex].Tag is not ConfigEntry entry)
            {
                return;
            }

            if (args.ColumnIndex >= 0 &&
                grid.Columns[args.ColumnIndex].Name.Equals("callsign", StringComparison.Ordinal))
            {
                return;
            }

            var oldValue = entry.ValueText;
            ApplyCallsignOverrideRow(grid.Rows[args.RowIndex], entry);
            if (!StringComparer.Ordinal.Equals(entry.ValueText, oldValue))
            {
                SetEntryValueUndoAction(entry, "edit " + entry.DisplayName, oldValue, entry.ValueText, () => RefreshCallsignGrid(grid, entries));
            }

            SetChangedStatus();
        };
        grid.DataError += (_, _) => { };
        return group;
    }

    private void RefreshCallsignGrid(DataGridView grid, List<ConfigEntry> entries)
    {
        var sortedEntries = entries
            .OrderBy(GetCallsignAircraft, StringComparer.OrdinalIgnoreCase)
            .ThenBy(entry => entry.Key, StringComparer.OrdinalIgnoreCase)
            .ToList();
        SyncGridRows(grid, sortedEntries, AddCallsignGridRow, UpdateCallsignGridRow);

        if (grid.Parent is TableLayoutPanel group)
        {
            ApplyCompactTableLayout(group, grid, 220, 680, GetTableHeightPadding(76));
        }
    }

    private void AddCallsignGridRow(DataGridView grid, ConfigEntry entry)
    {
        var values = entry.GetTupleValues();
        var rowIndex = grid.Rows.Add(
            GetCallsignAircraft(entry),
            entry.Key,
            values.Count > 0 ? values[0] : "",
            values.Count > 1 ? values[1] : "",
            values.Count > 2 ? values[2] : "",
            values.Count > 3 ? values[3] : "");
        grid.Rows[rowIndex].Tag = entry;
        grid.Rows[rowIndex].Cells["callsign"].ReadOnly = true;
        ApplyImportedNewRowHighlight(grid.Rows[rowIndex], entry);
    }

    private void UpdateCallsignGridRow(DataGridViewRow row, ConfigEntry entry)
    {
        var values = entry.GetTupleValues();
        row.Cells["aircraft"].Value = GetCallsignAircraft(entry);
        row.Cells["callsign"].Value = entry.Key;
        row.Cells["iff1"].Value = values.Count > 0 ? values[0] : "";
        row.Cells["iff2"].Value = values.Count > 1 ? values[1] : "";
        row.Cells["iff3"].Value = values.Count > 2 ? values[2] : "";
        row.Cells["iff4"].Value = values.Count > 3 ? values[3] : "";
        row.Tag = entry;
        row.Cells["callsign"].ReadOnly = true;
        ApplyImportedNewRowHighlight(row, entry);
    }

    private void RenameCallsignOverrideFromGrid(
        List<ConfigEntry> entries,
        DataGridView grid,
        ConfigEntry oldEntry,
        string oldKey,
        string newKey,
        DataGridViewCell editedCell)
    {
        if (_document is null)
        {
            editedCell.Value = oldKey;
            return;
        }

        try
        {
            var renamed = _document.RenameTableEntry(oldEntry, newKey);
            ReplaceEntryReference(entries, oldEntry, renamed);
            var validationErrors = _document.Validate();
            if (validationErrors.Count > 0)
            {
                var restored = _document.RenameTableEntry(renamed, oldKey);
                ReplaceEntryReference(entries, renamed, restored);
                RefreshCallsignGrid(grid, entries);
                SelectGridRowByTag(grid, restored);
                MessageBox.Show(this, string.Join(Environment.NewLine, validationErrors.Take(6)), "Rename callsign failed", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            RefreshCallsignGrid(grid, entries);
            SelectGridRowByTag(grid, renamed);
            SetUndoAction("rename " + oldKey, () =>
            {
                var restored = _document.RenameTableEntry(renamed, oldKey);
                ReplaceEntryReference(entries, renamed, restored);
                RefreshCallsignGrid(grid, entries);
                SelectGridRowByTag(grid, restored);
            });
            SetChangedStatus();
        }
        catch (Exception ex)
        {
            editedCell.Value = oldKey;
            MessageBox.Show(this, ex.Message, "Rename callsign failed", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
    }

    private static void ReplaceEntryReference(List<ConfigEntry> entries, ConfigEntry oldEntry, ConfigEntry newEntry)
    {
        var index = entries.IndexOf(oldEntry);
        if (index >= 0)
        {
            entries[index] = newEntry;
        }
    }

    private void AddCallsignOverrideRow(string parentKey, List<ConfigEntry> entries, DataGridView? grid)
    {
        if (_document is null || grid is null || entries.Count == 0)
        {
            return;
        }

        var defaultAircraft = grid.CurrentRow?.Cells["aircraft"].Value?.ToString() ?? GetCallsignAircraft(entries[0]);
        var result = PromptForCallsignRow(defaultAircraft);
        if (result is null)
        {
            return;
        }

        var aircraftParentKey = parentKey + "." + result.Value.Aircraft;
        var template = entries.FirstOrDefault(entry => entry.ParentKey.Equals(aircraftParentKey, StringComparison.Ordinal)) ?? entries[0];
        try
        {
            var entry = _document.AddTableEntry(aircraftParentKey, result.Value.Callsign, "{1000, 1001, 1002, 1003}", template);
            entries.Add(entry);
            RefreshCallsignGrid(grid, entries);
            SelectGridRowByTag(grid, entry);
            SetUndoAction("add " + result.Value.Callsign, () =>
            {
                _document.RemoveEntry(entry);
                entries.Remove(entry);
                RefreshCallsignGrid(grid, entries);
            });
            SetChangedStatus();
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Add callsign failed", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
    }

    private void RemoveCallsignOverrideRow(List<ConfigEntry> entries, DataGridView? grid)
    {
        if (_document is null || grid?.CurrentRow?.Tag is not ConfigEntry entry)
        {
            return;
        }

        if (MessageBox.Show(this, "Remove " + GetCallsignAircraft(entry) + " / " + entry.Key + "?", "Remove callsign", MessageBoxButtons.YesNo, MessageBoxIcon.Question) != DialogResult.Yes)
        {
            return;
        }

        try
        {
            var parentKey = entry.ParentKey;
            var key = entry.Key;
            var valueText = entry.ValueText;
            var template = entry;
            var selectedIndex = grid.CurrentRow.Index;
            _document.RemoveEntry(entry);
            entries.Remove(entry);
            RefreshCallsignGrid(grid, entries);
            SelectGridRowByIndex(grid, selectedIndex);
            SetUndoAction("remove " + key, () =>
            {
                var restored = _document.AddTableEntry(parentKey, key, valueText, template);
                entries.Add(restored);
                RefreshCallsignGrid(grid, entries);
                SelectGridRowByTag(grid, restored);
            });
            SetChangedStatus();
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Remove callsign failed", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
    }

    private static void ApplyCallsignOverrideRow(DataGridViewRow row, ConfigEntry entry)
    {
        entry.SetTupleValues(new[]
        {
            NormalizeIffCell(row.Cells["iff1"].Value?.ToString(), "0"),
            NormalizeIffCell(row.Cells["iff2"].Value?.ToString(), "0"),
            NormalizeIffCell(row.Cells["iff3"].Value?.ToString(), "0"),
            NormalizeIffCell(row.Cells["iff4"].Value?.ToString(), "0")
        });
    }

    private static string NormalizeIffCell(string? value, string fallback)
    {
        var text = value?.Trim() ?? "";
        return Regex.IsMatch(text, @"^\d+$") ? text : fallback;
    }

    private static void ConfigureFillColumn(DataGridViewColumn column, int minimumWidth)
    {
        column.AutoSizeMode = DataGridViewAutoSizeColumnMode.Fill;
        column.MinimumWidth = minimumWidth;
    }

    private static void ConfigureFixedColumn(DataGridViewColumn column, int width)
    {
        column.AutoSizeMode = DataGridViewAutoSizeColumnMode.None;
        column.Width = width;
        column.MinimumWidth = Math.Min(width, 48);
    }

    private static void ConfigureTableValueColumn(DataGridViewColumn column, ConfigValueKind kind)
    {
        if (kind == ConfigValueKind.Boolean)
        {
            ConfigureFixedColumn(column, 110);
            return;
        }

        if (kind == ConfigValueKind.Number)
        {
            ConfigureFixedColumn(column, 90);
            return;
        }

        ConfigureFillColumn(column, 170);
    }

    private static string FormatBooleanDisplay(string value)
    {
        return value.Equals("true", StringComparison.OrdinalIgnoreCase) ? "true" : "false";
    }

    private static string ParseBooleanDisplay(string value)
    {
        return value.Equals("true", StringComparison.OrdinalIgnoreCase) ||
               value.Equals("Enabled", StringComparison.OrdinalIgnoreCase)
            ? "true"
            : "false";
    }

    private static void ConfigureTupleValueColumn(DataGridViewColumn column, ConfigTupleField field)
    {
        switch (field.Kind)
        {
            case ConfigTupleFieldKind.Boolean:
                ConfigureFixedColumn(column, 92);
                break;

            case ConfigTupleFieldKind.Number:
                ConfigureFixedColumn(column, 90);
                break;

            case ConfigTupleFieldKind.Choice:
                var longestChoice = field.Choices
                    .Select(choice => choice.Display.Length)
                    .DefaultIfEmpty(field.Name.Length)
                    .Max();
                ConfigureFixedColumn(column, Math.Max(170, Math.Min(300, longestChoice * 9 + 60)));
                break;

            default:
                ConfigureFillColumn(column, 120);
                break;
        }
    }

    private void ApplyCompactTableLayout(TableLayoutPanel group, DataGridView grid)
    {
        var desiredWidth = grid.Columns
            .Cast<DataGridViewColumn>()
            .Where(column => column.Visible)
            .Sum(column => column.AutoSizeMode == DataGridViewAutoSizeColumnMode.Fill
                ? column.MinimumWidth
                : column.Width);
        desiredWidth += SystemInformation.VerticalScrollBarWidth + 28;
        if (group.ColumnCount > 1)
        {
            desiredWidth += TableActionColumnWidth;
        }

        var availableWidth = _formHost.ClientSize.Width > 0
            ? _formHost.ClientSize.Width - 48
            : ClientSize.Width - 280;
        group.Width = Math.Max(320, Math.Min(desiredWidth, Math.Max(320, availableWidth)));
    }

    private void ApplyCompactTableLayout(TableLayoutPanel group, DataGridView grid, int minimumHeight, int maximumHeight, int heightPadding)
    {
        ApplyCompactTableLayout(group, grid);
        group.Height = Math.Max(
            GetTableActionMinimumHeight(group),
            GetConfiguredTableHeight(grid, minimumHeight, maximumHeight, heightPadding));
    }

    private int GetTableHeaderRowHeight()
    {
        return Math.Max(Zoomed(32), Font.Height + Zoomed(10));
    }

    private Padding GetTableHeaderPadding()
    {
        return new Padding(0, 0, 0, Zoomed(5));
    }

    private Padding GetTableHeaderLabelMargin()
    {
        return new Padding(0, Zoomed(4), Zoomed(5), 0);
    }

    private int GetTableHeightPadding(int basePadding)
    {
        return Zoomed(basePadding);
    }

    private static int GetTableActionMinimumHeight(TableLayoutPanel group)
    {
        var headerHeight = group.RowStyles.Count > 0
            ? (int)Math.Ceiling(group.RowStyles[0].Height)
            : 0;
        var actionHeight = 0;
        foreach (Control control in group.Controls)
        {
            if (group.GetColumn(control) == 1 && group.GetRow(control) == 1)
            {
                actionHeight = Math.Max(actionHeight, GetControlStackMinimumHeight(control));
            }
        }

        return headerHeight + actionHeight + group.Padding.Vertical;
    }

    private static int GetControlStackMinimumHeight(Control control)
    {
        if (control is FlowLayoutPanel flow)
        {
            var height = flow.Padding.Vertical;
            foreach (Control child in flow.Controls)
            {
                if (!child.Visible)
                {
                    continue;
                }

                height += Math.Max(child.Height, Math.Max(child.MinimumSize.Height, child.GetPreferredSize(Size.Empty).Height)) +
                          child.Margin.Vertical;
            }

            return height;
        }

        return Math.Max(control.Height, Math.Max(control.MinimumSize.Height, control.GetPreferredSize(Size.Empty).Height)) +
               control.Margin.Vertical;
    }

    private int GetConfiguredTableHeight(DataGridView grid, int minimumHeight, int maximumHeight, int heightPadding)
    {
        var desiredHeight = GetTableRowsHeight(grid, grid.Rows.Count) + heightPadding;
        var contentMinimumHeight = GetTableRowsHeight(grid, Math.Min(Math.Max(grid.Rows.Count, 1), 1)) + heightPadding;
        var metadata = GetGridMetadata(grid);
        if (metadata is not null &&
            string.Equals(metadata.TableHeightMode, "Auto", StringComparison.OrdinalIgnoreCase))
        {
            return Math.Max(contentMinimumHeight, desiredHeight);
        }

        var cappedHeight = SnapTableHeightToFullRows(grid, maximumHeight, heightPadding);
        if (metadata?.TableMaxVisibleRows is > 0)
        {
            cappedHeight = Math.Max(contentMinimumHeight, GetTableRowsHeight(grid, metadata.TableMaxVisibleRows.Value) + heightPadding);
        }

        return Math.Min(cappedHeight, Math.Max(contentMinimumHeight, desiredHeight));
    }

    private static int SnapTableHeightToFullRows(DataGridView grid, int height, int heightPadding)
    {
        var availableRowsHeight = Math.Max(0, height - heightPadding);
        var rowHeight = GetAverageRowHeight(grid);
        if (rowHeight <= 0)
        {
            return height;
        }

        var fullRows = Math.Max(1, availableRowsHeight / rowHeight);
        return fullRows * rowHeight + heightPadding;
    }

    private static int GetTableRowsHeight(DataGridView grid, int rowCount)
    {
        if (rowCount <= 0)
        {
            return 0;
        }

        var rows = grid.Rows
            .Cast<DataGridViewRow>()
            .Where(row => row.Visible)
            .Take(rowCount)
            .ToList();
        if (rows.Count == rowCount)
        {
            return rows.Sum(row => row.Height);
        }

        var fallbackHeight = rows.Count > 0
            ? (int)Math.Round(rows.Average(row => row.Height))
            : grid.RowTemplate.Height > 0 ? grid.RowTemplate.Height : 22;
        return rows.Sum(row => row.Height) + (rowCount - rows.Count) * fallbackHeight;
    }

    private static int GetAverageRowHeight(DataGridView grid)
    {
        var rows = grid.Rows
            .Cast<DataGridViewRow>()
            .Where(row => row.Visible)
            .ToList();
        if (rows.Count > 0)
        {
            return Math.Max(1, (int)Math.Round(rows.Average(row => row.Height)));
        }

        return grid.RowTemplate.Height > 0 ? grid.RowTemplate.Height : 22;
    }

    private GuiMetadataEntry? GetGridMetadata(DataGridView grid)
    {
        if (_document is null || grid.Tag is not string key)
        {
            return null;
        }

        return _document.Metadata.Entries.TryGetValue(key, out var metadata) ? metadata : null;
    }

    private bool IsAutoTableHeight(string key)
    {
        return _document?.Metadata.Entries.TryGetValue(key, out var metadata) == true &&
               string.Equals(metadata.TableHeightMode, "Auto", StringComparison.OrdinalIgnoreCase);
    }

    private int GetConfiguredMaxVisibleRows(string key)
    {
        return _document?.Metadata.Entries.TryGetValue(key, out var metadata) == true &&
               metadata.TableMaxVisibleRows is > 0
            ? metadata.TableMaxVisibleRows.Value
            : 0;
    }

    private static void BuildTableColumns(DataGridView grid, List<ConfigEntry> entries)
    {
        grid.Columns.Clear();
        grid.Columns.Add("name", "Item");
        grid.Columns["name"].ReadOnly = true;

        if (entries.All(IsPriceRankEntry))
        {
            ConfigureFillColumn(grid.Columns["name"], 280);
            grid.Columns.Add("price", "Price");
            grid.Columns.Add("rank", "Rank");
            ConfigureFixedColumn(grid.Columns["price"], 90);
            ConfigureFixedColumn(grid.Columns["rank"], 70);
            return;
        }

        var firstTuple = entries.FirstOrDefault(entry => entry.TupleFields.Count > 0);
        if (firstTuple is not null)
        {
            ConfigureFillColumn(grid.Columns["name"], 150);
            for (var i = 0; i < firstTuple.TupleFields.Count; i++)
            {
                var field = firstTuple.TupleFields[i];
                if (field.Kind == ConfigTupleFieldKind.Boolean)
                {
                    grid.Columns.Add(new DataGridViewCheckBoxColumn { Name = "field" + i, HeaderText = field.Name });
                }
                else if (field.Kind == ConfigTupleFieldKind.Choice)
                {
                    var column = new DataGridViewComboBoxColumn { Name = "field" + i, HeaderText = field.Name };
                    foreach (var choice in field.Choices)
                    {
                        column.Items.Add(choice.Display);
                    }

                    grid.Columns.Add(column);
                }
                else
                {
                    grid.Columns.Add("field" + i, field.Name);
                }

                ConfigureTupleValueColumn(grid.Columns["field" + i], field);
            }

            return;
        }

        var firstKind = entries.First().Kind;
        var mixedValueKinds = entries.Any(entry => entry.Kind != firstKind);
        ConfigureFillColumn(grid.Columns["name"], 260);
        if (!mixedValueKinds && firstKind == ConfigValueKind.Boolean)
        {
            grid.Columns.Add(new DataGridViewComboBoxColumn
            {
                Name = "value",
                HeaderText = "Value",
                Items = { "true", "false" }
            });
        }
        else
        {
            grid.Columns.Add("value", "Value");
        }

        ConfigureTableValueColumn(grid.Columns["value"], mixedValueKinds ? ConfigValueKind.String : firstKind);
    }

    private static void ApplyTableValueCell(DataGridViewRow row, ConfigEntry entry)
    {
        var cell = row.Cells["value"];
        if (entry.Kind == ConfigValueKind.Boolean)
        {
            if (cell is not DataGridViewComboBoxCell)
            {
                var comboCell = new DataGridViewComboBoxCell();
                comboCell.Items.Add("true");
                comboCell.Items.Add("false");
                row.Cells["value"] = comboCell;
                cell = row.Cells["value"];
            }

            if (cell is DataGridViewComboBoxCell booleanCell)
            {
                booleanCell.FlatStyle = IsDarkPalette() ? FlatStyle.Flat : FlatStyle.Standard;
                booleanCell.Style.BackColor = EditorBackground;
                booleanCell.Style.ForeColor = PrimaryTextColor;
            }

            cell.Value = FormatBooleanDisplay(entry.ValueText);
            return;
        }

        if (cell is DataGridViewComboBoxCell &&
            row.DataGridView?.Columns["value"] is not DataGridViewComboBoxColumn)
        {
            row.Cells["value"] = new DataGridViewTextBoxCell();
            cell = row.Cells["value"];
        }

        cell.Value = entry.ValueText;
    }

    private void AddTableRow(DataGridView grid, ConfigEntry entry)
    {
        if (IsPriceRankEntry(entry) && TryReadPriceRank(entry.ValueText, out var price, out var rank))
        {
            var priceRankIndex = grid.Rows.Add(entry.Key, price, rank);
            grid.Rows[priceRankIndex].Tag = entry;
            ApplyTableRowTooltip(grid.Rows[priceRankIndex], entry);
            ApplyImportedNewRowHighlight(grid.Rows[priceRankIndex], entry);
            return;
        }

        if (entry.TupleFields.Count > 0)
        {
            var values = entry.GetTupleValues();
            var cells = new List<object> { entry.Key };
            for (var i = 0; i < entry.TupleFields.Count; i++)
            {
                var value = i < values.Count ? values[i] : "";
                var field = entry.TupleFields[i];
                if (field.Kind == ConfigTupleFieldKind.Boolean)
                {
                    cells.Add(value.Equals("true", StringComparison.OrdinalIgnoreCase));
                }
                else if (field.Kind == ConfigTupleFieldKind.Choice)
                {
                    cells.Add(FindChoiceDisplay(field, value));
                }
                else
                {
                    cells.Add(value);
                }
            }

            var index = grid.Rows.Add(cells.ToArray());
            grid.Rows[index].Tag = entry;
            ApplyTableRowTooltip(grid.Rows[index], entry);
            ApplyImportedNewRowHighlight(grid.Rows[index], entry);
            return;
        }

        var rowIndex = grid.Rows.Add(entry.Key, "");
        var row = grid.Rows[rowIndex];
        ApplyTableValueCell(row, entry);
        row.Tag = entry;
        ApplyTableRowTooltip(row, entry);
        ApplyImportedNewRowHighlight(row, entry);
    }

    private void UpdateTableGridRow(DataGridViewRow row, ConfigEntry entry)
    {
        if (IsPriceRankEntry(entry) && TryReadPriceRank(entry.ValueText, out var price, out var rank))
        {
            row.Cells["name"].Value = entry.Key;
            row.Cells["price"].Value = price;
            row.Cells["rank"].Value = rank;
            row.Tag = entry;
            ApplyTableRowTooltip(row, entry);
            ApplyImportedNewRowHighlight(row, entry);
            return;
        }

        row.Cells["name"].Value = entry.Key;
        if (entry.TupleFields.Count > 0)
        {
            var values = entry.GetTupleValues();
            for (var i = 0; i < entry.TupleFields.Count; i++)
            {
                var value = i < values.Count ? values[i] : "";
                var field = entry.TupleFields[i];
                if (field.Kind == ConfigTupleFieldKind.Boolean)
                {
                    row.Cells[i + 1].Value = value.Equals("true", StringComparison.OrdinalIgnoreCase);
                }
                else if (field.Kind == ConfigTupleFieldKind.Choice)
                {
                    row.Cells[i + 1].Value = FindChoiceDisplay(field, value);
                }
                else
                {
                    row.Cells[i + 1].Value = value;
                }
            }

            row.Tag = entry;
            ApplyTableRowTooltip(row, entry);
            ApplyImportedNewRowHighlight(row, entry);
            return;
        }

        ApplyTableValueCell(row, entry);
        row.Tag = entry;
        ApplyTableRowTooltip(row, entry);
        ApplyImportedNewRowHighlight(row, entry);
    }

    private void ApplyImportedNewRowHighlight(DataGridViewRow row, ConfigEntry entry)
    {
        row.DefaultCellStyle.BackColor = IsImportedNewEntryHighlighted(entry)
            ? GetNewHighlightBackColor()
            : EditorBackground;
        row.DefaultCellStyle.ForeColor = PrimaryTextColor;
    }

    private static void ApplyTableRowTooltip(DataGridViewRow row, ConfigEntry entry)
    {
        var tooltip = entry.InlineComment;
        foreach (DataGridViewCell cell in row.Cells)
        {
            cell.ToolTipText = tooltip;
        }
    }

    private static void ApplyTableRow(DataGridViewRow row, ConfigEntry entry)
    {
        if (IsPriceRankEntry(entry))
        {
            var price = row.Cells["price"].Value?.ToString()?.Trim() ?? "0";
            var rank = row.Cells["rank"].Value?.ToString()?.Trim() ?? "1";
            entry.ValueText = "{ price = " + NormalizeNumberCell(price, "0") + ", reqRank = " + NormalizeNumberCell(rank, "1") + " }";
            return;
        }

        if (entry.TupleFields.Count > 0)
        {
            var values = new List<string>();
            for (var i = 0; i < entry.TupleFields.Count; i++)
            {
                var field = entry.TupleFields[i];
                var value = row.Cells[i + 1].Value?.ToString() ?? "";
                if (field.Kind == ConfigTupleFieldKind.Boolean)
                {
                    values.Add(row.Cells[i + 1].Value is bool boolValue && boolValue ? "true" : "false");
                }
                else if (field.Kind == ConfigTupleFieldKind.Choice)
                {
                    values.Add(FindChoiceLiteral(field, value));
                }
                else
                {
                    values.Add(value);
                }
            }

            entry.SetTupleValues(values);
            return;
        }

        var cellValue = row.Cells[1].Value?.ToString() ?? "";
        entry.ValueText = entry.Kind == ConfigValueKind.Boolean
            ? ParseBooleanDisplay(cellValue)
            : cellValue;
    }

    private static bool IsPriceRankEntry(ConfigEntry entry)
    {
        return entry.ParentKey.Equals("CTLDPrices", StringComparison.Ordinal) &&
               TryReadPriceRank(entry.ValueText, out _, out _);
    }

    private static bool TryReadPriceRank(string value, out string price, out string rank)
    {
        price = "";
        rank = "";
        var priceMatch = Regex.Match(value, @"\bprice\s*=\s*(?<value>-?\d+(?:\.\d+)?)", RegexOptions.IgnoreCase);
        var rankMatch = Regex.Match(value, @"\breqRank\s*=\s*(?<value>-?\d+(?:\.\d+)?)", RegexOptions.IgnoreCase);
        if (!priceMatch.Success || !rankMatch.Success)
        {
            return false;
        }

        price = priceMatch.Groups["value"].Value;
        rank = rankMatch.Groups["value"].Value;
        return true;
    }

    private static string NormalizeNumberCell(string value, string fallback)
    {
        return Regex.IsMatch(value, @"^-?\d+(?:\.\d+)?$") ? value : fallback;
    }

    private Control BuildRawEditor()
    {
        if (_rawEditorRoot is not null && !_rawEditorRoot.IsDisposed)
        {
            return _rawEditorRoot;
        }

        var root = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 1,
            RowCount = 2
        };
        root.RowStyles.Add(new RowStyle(SizeType.Absolute, 36));
        root.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        root.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));

        var split = new SplitContainer
        {
            Dock = DockStyle.Fill,
            SplitterDistance = 720,
            FixedPanel = FixedPanel.Panel2
        };

        ConfigureGrid();
        split.Panel1.Controls.Add(_grid);
        split.Panel2.Controls.Add(BuildDetailsPanel());
        root.Controls.Add(BuildRawSearchBar(), 0, 0);
        root.Controls.Add(split, 0, 1);
        _rawEditorRoot = root;
        return root;
    }

    private Control BuildRawSearchBar()
    {
        var panel = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 3,
            Padding = new Padding(0, 0, 0, 4)
        };
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 70));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 82));

        panel.Controls.Add(MakeLabel("Search"), 0, 0);
        _rawSearchBox.Dock = DockStyle.Fill;
        _rawSearchBox.PlaceholderText = "Search key, value, section, or comment";
        if (!_rawSearchBound)
        {
            _rawSearchBox.TextChanged += (_, _) => RefreshGrid();
            _rawSearchBound = true;
        }
        panel.Controls.Add(_rawSearchBox, 1, 0);
        panel.Controls.Add(MakeButton("Clear", () => _rawSearchBox.Clear()), 2, 0);
        return panel;
    }

    private Control BuildAdminDesigner()
    {
        var panel = new TableLayoutPanel
        {
            Dock = DockStyle.Top,
            AutoSize = true,
            ColumnCount = 1,
            Padding = new Padding(16)
        };
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));

        panel.Controls.Add(new Label
        {
            Text = "Admin Designer",
            Dock = DockStyle.Top,
            AutoSize = true,
            Font = new Font(Font, FontStyle.Bold),
            Padding = new Padding(0, 0, 0, 8)
        });
        panel.Controls.Add(MakeValueHint("Edit how the normal GUI presents each config option. Save Designer writes Foothold Config.gui.json. Export User EXE builds a single-file manager with these designer choices embedded."));
        panel.Controls.Add(BuildLayoutDesigner());

        var designerCategoryBox = new WheelSafeComboBox
        {
            Dock = DockStyle.Top,
            DropDownStyle = ComboBoxStyle.DropDownList
        };
        foreach (var name in GetDesignerCategoryNames())
        {
            designerCategoryBox.Items.Add(name);
        }

        var itemSelector = new WheelSafeComboBox
        {
            Dock = DockStyle.Top,
            DropDownStyle = ComboBoxStyle.DropDownList
        };

        var showTableRowsBox = new CheckBox
        {
            Text = "Show table rows",
            Dock = DockStyle.Top,
            AutoSize = true,
            Padding = new Padding(0, 6, 0, 0)
        };

        var labelBox = MakeDesignerTextBox(singleLine: true);
        var controlTypeBox = new WheelSafeComboBox { Dock = DockStyle.Top, DropDownStyle = ComboBoxStyle.DropDownList };
        foreach (var type in new[] { "", "auto", "checkbox", "dropdown", "number", "percent", "seconds", "multiline", "table", "raw" })
        {
            controlTypeBox.Items.Add(type);
        }

        var advancedBox = new WheelSafeComboBox { Dock = DockStyle.Top, DropDownStyle = ComboBoxStyle.DropDownList };
        advancedBox.Items.Add("Use inferred");
        advancedBox.Items.Add("Basic");
        advancedBox.Items.Add("Advanced");

        var tableHeightModeBox = new WheelSafeComboBox { Dock = DockStyle.Top, DropDownStyle = ComboBoxStyle.DropDownList };
        tableHeightModeBox.Items.Add("Use default");
        tableHeightModeBox.Items.Add("Capped");
        tableHeightModeBox.Items.Add("Auto");

        var tableMaxVisibleRowsBox = new WheelSafeNumericUpDown
        {
            Dock = DockStyle.Top,
            Minimum = 0,
            Maximum = 500,
            Value = 0
        };

        var choicesBox = MakeDesignerTextBox(singleLine: false);
        choicesBox.Height = 110;
        var footerVersionBox = MakeDesignerTextBox(singleLine: true);
        footerVersionBox.Text = _document?.Metadata.FooterVersion ?? "";
        var advancedToggleVisibleBox = new CheckBox
        {
            Text = "Show Advanced checkbox in normal GUI",
            Dock = DockStyle.Top,
            AutoSize = true,
            Checked = _document?.Metadata.AdvancedToggleVisible ?? true,
            Padding = new Padding(0, 6, 0, 0)
        };
        var rawValuesVisibleBox = new CheckBox
        {
            Text = "Show Raw Values category when Advanced is enabled",
            Dock = DockStyle.Top,
            AutoSize = true,
            Checked = _document?.Metadata.RawValuesVisible ?? true,
            Padding = new Padding(0, 6, 0, 0)
        };

        var buttons = new FlowLayoutPanel
        {
            Dock = DockStyle.Top,
            Height = 42,
            FlowDirection = FlowDirection.LeftToRight,
            Padding = new Padding(0, 6, 0, 4),
            WrapContents = false
        };
        panel.Controls.Add(buttons);

        var saveAction = () =>
        {
            SaveDesignerMetadata(itemSelector.SelectedItem as DesignerItem, labelBox, controlTypeBox, advancedBox, tableHeightModeBox, tableMaxVisibleRowsBox, choicesBox, advancedToggleVisibleBox, rawValuesVisibleBox, footerVersionBox, previewAfterSave: false);
        };
        _designerSaveAction = saveAction;

        var saveButton = MakeDesignerButton("Save Designer", saveAction, 120);
        buttons.Controls.Add(saveButton);

        var previewButton = MakeDesignerButton("Preview In GUI", () =>
            SaveDesignerMetadata(itemSelector.SelectedItem as DesignerItem, labelBox, controlTypeBox, advancedBox, tableHeightModeBox, tableMaxVisibleRowsBox, choicesBox, advancedToggleVisibleBox, rawValuesVisibleBox, footerVersionBox, previewAfterSave: true), 120);
        buttons.Controls.Add(previewButton);

        var exportButton = MakeDesignerButton("Export User EXE", () =>
            ExportConfiguredExe(itemSelector.SelectedItem as DesignerItem, labelBox, controlTypeBox, advancedBox, tableHeightModeBox, tableMaxVisibleRowsBox, choicesBox, advancedToggleVisibleBox, rawValuesVisibleBox, footerVersionBox, "user"), 130);
        buttons.Controls.Add(exportButton);

        var exportAdminButton = MakeDesignerButton("Export Admin EXE", () =>
            ExportConfiguredExe(itemSelector.SelectedItem as DesignerItem, labelBox, controlTypeBox, advancedBox, tableHeightModeBox, tableMaxVisibleRowsBox, choicesBox, advancedToggleVisibleBox, rawValuesVisibleBox, footerVersionBox, "admin"), 135);
        buttons.Controls.Add(exportAdminButton);

        var clearButton = MakeDesignerButton("Clear Override", () =>
        {
            if (itemSelector.SelectedItem is DesignerItem item &&
                ClearDesignerMetadata(item.Key))
            {
                LoadDesignerItem(item, labelBox, controlTypeBox, advancedBox, tableHeightModeBox, tableMaxVisibleRowsBox, choicesBox);
            }
        }, 120);
        buttons.Controls.Add(clearButton);

        panel.Controls.Add(MakeDesignerLabel("GUI category"));
        panel.Controls.Add(designerCategoryBox);
        panel.Controls.Add(MakeDesignerLabel("GUI item"));
        panel.Controls.Add(itemSelector);
        panel.Controls.Add(showTableRowsBox);
        panel.Controls.Add(MakeDesignerLabel("Footer version"));
        panel.Controls.Add(footerVersionBox);
        // Advanced filtering is retired for the normal GUI. Keep these controls alive for
        // metadata compatibility, but do not show them in the designer.
        panel.Controls.Add(MakeDesignerLabel("Friendly label"));
        panel.Controls.Add(labelBox);
        panel.Controls.Add(MakeDesignerLabel("Control type"));
        panel.Controls.Add(controlTypeBox);
        panel.Controls.Add(MakeDesignerLabel("Table height mode"));
        panel.Controls.Add(tableHeightModeBox);
        panel.Controls.Add(MakeDesignerLabel("Max visible rows (0 = default)"));
        panel.Controls.Add(tableMaxVisibleRowsBox);
        panel.Controls.Add(MakeDesignerLabel("Dropdown choices, one per line: Display=LuaLiteral"));
        panel.Controls.Add(choicesBox);

        void reloadItems()
        {
            var categoryName = designerCategoryBox.SelectedItem?.ToString() ?? "";
            _designerSelectedCategory = categoryName;
            itemSelector.Items.Clear();
            foreach (var item in GetDesignerItems(categoryName, showTableRowsBox.Checked, includeAdvanced: true))
            {
                itemSelector.Items.Add(item);
            }

            var selectedIndex = 0;
            if (!string.IsNullOrWhiteSpace(_designerSelectedKey))
            {
                for (var i = 0; i < itemSelector.Items.Count; i++)
                {
                    if (itemSelector.Items[i] is DesignerItem item &&
                        item.Key.Equals(_designerSelectedKey, StringComparison.Ordinal))
                    {
                        selectedIndex = i;
                        break;
                    }
                }
            }

            itemSelector.SelectedIndex = itemSelector.Items.Count > 0 ? selectedIndex : -1;
        }

        designerCategoryBox.SelectedIndexChanged += (_, _) => reloadItems();
        showTableRowsBox.CheckedChanged += (_, _) => reloadItems();
        itemSelector.SelectedIndexChanged += (_, _) =>
        {
            if (itemSelector.SelectedItem is DesignerItem item)
            {
                _designerSelectedKey = item.Key;
                LoadDesignerItem(item, labelBox, controlTypeBox, advancedBox, tableHeightModeBox, tableMaxVisibleRowsBox, choicesBox);
            }
        };

        if (designerCategoryBox.Items.Count > 0)
        {
            var selectedIndex = 0;
            if (!string.IsNullOrWhiteSpace(_designerSelectedCategory))
            {
                for (var i = 0; i < designerCategoryBox.Items.Count; i++)
                {
                    if (string.Equals(designerCategoryBox.Items[i]?.ToString(), _designerSelectedCategory, StringComparison.Ordinal))
                    {
                        selectedIndex = i;
                        break;
                    }
                }
            }

            designerCategoryBox.SelectedIndex = selectedIndex;
        }

        return panel;
    }

    private Control BuildLayoutDesigner()
    {
        var tabs = new TabControl
        {
            Dock = DockStyle.Top,
            Height = 410,
            Padding = new Point(8, 4)
        };
        var tab = new TabPage("Layout");
        tabs.TabPages.Add(tab);
        tabs.TabPages.Add(BuildCategoryOrderTab());

        var panel = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 2,
            RowCount = 4,
            Padding = new Padding(10)
        };
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 120));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 24));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 32));
        panel.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 42));
        tab.Controls.Add(panel);

        panel.Controls.Add(MakeLabel("Category"), 0, 0);
        var categoryBox = new WheelSafeComboBox
        {
            Dock = DockStyle.Fill,
            DropDownStyle = ComboBoxStyle.DropDownList
        };
        foreach (var name in GetDesignerCategoryNames())
        {
            categoryBox.Items.Add(name);
        }
        panel.Controls.Add(categoryBox, 0, 1);

        var itemList = new ListBox
        {
            Dock = DockStyle.Fill,
            IntegralHeight = false,
            SelectionMode = SelectionMode.MultiExtended
        };
        SetToolbarHelp(itemList, "Ctrl-click selects multiple items. Shift-click selects a range.");
        panel.Controls.Add(itemList, 0, 2);
        panel.Controls.Add(MakeButton("New Category", () => AddDesignerCategory(categoryBox, itemList)), 1, 1);

        var moveButtons = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            RowCount = 7,
            ColumnCount = 1
        };
        for (var i = 0; i < 7; i++)
        {
            moveButtons.RowStyles.Add(new RowStyle(SizeType.Absolute, 34));
        }
        panel.Controls.Add(moveButtons, 1, 2);

        moveButtons.Controls.Add(MakeButton("Top", () => MoveLayoutItem(itemList, int.MinValue)), 0, 0);
        moveButtons.Controls.Add(MakeButton("Up", () => MoveLayoutItem(itemList, -1)), 0, 1);
        moveButtons.Controls.Add(MakeButton("Down", () => MoveLayoutItem(itemList, 1)), 0, 2);
        moveButtons.Controls.Add(MakeButton("Bottom", () => MoveLayoutItem(itemList, int.MaxValue)), 0, 3);
        moveButtons.Controls.Add(MakeButton("Add", () => AddLayoutItem(categoryBox.Text, itemList)), 0, 4);
        moveButtons.Controls.Add(MakeButton("Move to...", () => MoveLayoutItemToCategory(categoryBox.Text, itemList)), 0, 5);
        moveButtons.Controls.Add(MakeButton("Remove", () => RemoveLayoutItem(itemList)), 0, 6);

        var bottomButtons = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            FlowDirection = FlowDirection.LeftToRight
        };
        var saveButton = MakeDesignerButton("Save Layout", () => SaveDesignerLayout(categoryBox.Text, itemList), 120);
        var previewButton = MakeDesignerButton("Preview Layout", () =>
        {
            if (SaveDesignerLayout(categoryBox.Text, itemList))
            {
                SelectCategory(categoryBox.Text);
            }
        }, 120);
        bottomButtons.Controls.Add(saveButton);
        bottomButtons.Controls.Add(previewButton);
        panel.Controls.Add(bottomButtons, 0, 3);

        void reloadLayoutItems()
        {
            _designerSelectedCategory = categoryBox.Text;
            itemList.Items.Clear();
            foreach (var item in GetDesignerItems(categoryBox.Text, includeTableRows: false, includeAdvanced: true))
            {
                itemList.Items.Add(item);
            }

            if (itemList.Items.Count > 0)
            {
                itemList.SelectedIndex = 0;
            }
        }

        categoryBox.SelectedIndexChanged += (_, _) => reloadLayoutItems();
        if (categoryBox.Items.Count > 0)
        {
            var selectedIndex = 0;
            if (!string.IsNullOrWhiteSpace(_designerSelectedCategory))
            {
                for (var i = 0; i < categoryBox.Items.Count; i++)
                {
                    if (string.Equals(categoryBox.Items[i]?.ToString(), _designerSelectedCategory, StringComparison.Ordinal))
                    {
                        selectedIndex = i;
                        break;
                    }
                }
            }

            categoryBox.SelectedIndex = selectedIndex;
        }

        return tabs;
    }

    private TabPage BuildCategoryOrderTab()
    {
        var tab = new TabPage("Category Order");
        var panel = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 2,
            RowCount = 3,
            Padding = new Padding(10)
        };
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 120));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 24));
        panel.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 42));
        tab.Controls.Add(panel);

        panel.Controls.Add(MakeLabel("Left-side category order"), 0, 0);
        var categoryList = new ListBox
        {
            Dock = DockStyle.Fill,
            IntegralHeight = false
        };
        foreach (var name in GetDesignerCategoryNames())
        {
            categoryList.Items.Add(new CategoryOrderItem(name, IsCategoryHidden(name), GetCategoryDisplayName(name)));
        }
        if (categoryList.Items.Count > 0)
        {
            categoryList.SelectedIndex = 0;
        }
        panel.Controls.Add(categoryList, 0, 1);

        var buttons = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            RowCount = 8,
            ColumnCount = 1
        };
        for (var i = 0; i < 8; i++)
        {
            buttons.RowStyles.Add(new RowStyle(SizeType.Absolute, 34));
        }
        buttons.Controls.Add(MakeButton("Top", () => MoveLayoutItem(categoryList, int.MinValue)), 0, 0);
        buttons.Controls.Add(MakeButton("Up", () => MoveLayoutItem(categoryList, -1)), 0, 1);
        buttons.Controls.Add(MakeButton("Down", () => MoveLayoutItem(categoryList, 1)), 0, 2);
        buttons.Controls.Add(MakeButton("Bottom", () => MoveLayoutItem(categoryList, int.MaxValue)), 0, 3);
        buttons.Controls.Add(MakeButton("Hide", () => SetSelectedCategoryHidden(categoryList, hidden: true)), 0, 4);
        buttons.Controls.Add(MakeButton("Show", () => SetSelectedCategoryHidden(categoryList, hidden: false)), 0, 5);
        buttons.Controls.Add(MakeButton("Rename", () => RenameSelectedCategory(categoryList)), 0, 6);
        buttons.Controls.Add(MakeButton("Delete", () => DeleteSelectedCategory(categoryList)), 0, 7);
        panel.Controls.Add(buttons, 1, 1);

        var bottomButtons = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            FlowDirection = FlowDirection.LeftToRight
        };
        bottomButtons.Controls.Add(MakeDesignerButton("Save Categories", () => SaveCategoryOrder(categoryList, previewAfterSave: false), 130));
        bottomButtons.Controls.Add(MakeDesignerButton("Preview Categories", () => SaveCategoryOrder(categoryList, previewAfterSave: true), 140));
        panel.Controls.Add(bottomButtons, 0, 2);
        return tab;
    }

    private static void SetSelectedCategoryHidden(ListBox categoryList, bool hidden)
    {
        if (categoryList.SelectedItem is not CategoryOrderItem item)
        {
            return;
        }

        item.Hidden = hidden;
        var index = categoryList.SelectedIndex;
        categoryList.Items[index] = item;
        categoryList.SelectedIndex = index;
    }

    private bool SaveCategoryOrder(ListBox categoryList, bool previewAfterSave)
    {
        if (_document is null)
        {
            return false;
        }

        if (HasChanges())
        {
            MessageBox.Show(this, "Save or reload pending config value changes before editing designer layout.", "Admin Designer", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return false;
        }

        var items = categoryList.Items.OfType<CategoryOrderItem>().ToList();
        _document.Metadata.CategoryOrder = items.Select(item => item.Name).ToList();
        _document.Metadata.HiddenCategories = items
            .Where(item => item.Hidden && !IsReservedCategory(item.Name))
            .Select(item => item.Name)
            .ToList();
        _document.Metadata.Save();

        if (previewAfterSave)
        {
            ReloadCategoriesPreservingSelection();
        }
        SetStatus("Category order saved: " + _document.Metadata.Path);
        return true;
    }

    private void RenameSelectedCategory(ListBox categoryList)
    {
        if (_document is null || categoryList.SelectedItem is not CategoryOrderItem item)
        {
            return;
        }

        if (HasChanges())
        {
            MessageBox.Show(this, "Save or reload pending config value changes before editing designer layout.", "Admin Designer", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

        if (IsReservedCategory(item.Name))
        {
            MessageBox.Show(this, "This category cannot be renamed.", "Rename Category", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

        var currentDisplayName = GetCategoryDisplayName(item.Name);
        var newName = PromptForText("Rename Category", "New category name", currentDisplayName)?.Trim();
        if (string.IsNullOrWhiteSpace(newName) || newName.Equals(currentDisplayName, StringComparison.OrdinalIgnoreCase))
        {
            return;
        }

        if (IsFixedCategory(item.Name))
        {
            if (IsReservedCategory(newName) ||
                GetDesignerCategoryNames()
                    .Where(name => !name.Equals(item.Name, StringComparison.OrdinalIgnoreCase))
                    .Any(name => name.Equals(newName, StringComparison.OrdinalIgnoreCase) ||
                                 GetCategoryDisplayName(name).Equals(newName, StringComparison.OrdinalIgnoreCase)))
            {
                MessageBox.Show(this, "That category label already exists or is reserved.", "Rename Category", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }

            if (newName.Equals(item.Name, StringComparison.OrdinalIgnoreCase))
            {
                _document.Metadata.CategoryLabels.Remove(item.Name);
            }
            else
            {
                _document.Metadata.CategoryLabels[item.Name] = newName;
            }

            _document.Metadata.Save();
            var fixedIndex = categoryList.SelectedIndex;
            categoryList.Items[fixedIndex] = new CategoryOrderItem(item.Name, item.Hidden, GetCategoryDisplayName(item.Name));
            categoryList.SelectedIndex = fixedIndex;
            ReloadCategoriesPreservingSelection();
            SetStatus("Category label saved: " + item.Name + " -> " + newName);
            return;
        }

        if (IsReservedCategory(newName) ||
            GetDesignerCategoryNames().Any(name => name.Equals(newName, StringComparison.OrdinalIgnoreCase)) ||
            GetDesignerCategoryNames()
                .Where(name => !name.Equals(item.Name, StringComparison.OrdinalIgnoreCase))
                .Any(name => GetCategoryDisplayName(name).Equals(newName, StringComparison.OrdinalIgnoreCase)))
        {
            MessageBox.Show(this, "That category name already exists or is reserved.", "Rename Category", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

        if (_document.Metadata.CategoryLayouts.TryGetValue(item.Name, out var layout))
        {
            _document.Metadata.CategoryLayouts.Remove(item.Name);
            _document.Metadata.CategoryLayouts[newName] = layout;
        }

        ReplaceCategoryName(_document.Metadata.CategoryOrder, item.Name, newName);
        ReplaceCategoryName(_document.Metadata.HiddenCategories, item.Name, newName);
        foreach (var metadata in _document.Metadata.Entries.Values)
        {
            if (metadata.Category?.Equals(item.Name, StringComparison.OrdinalIgnoreCase) == true)
            {
                metadata.Category = newName;
            }
        }

        _document.Metadata.Save();
        _designerSelectedCategory = newName;
        var index = categoryList.SelectedIndex;
        categoryList.Items[index] = new CategoryOrderItem(newName, item.Hidden, GetCategoryDisplayName(newName));
        categoryList.SelectedIndex = index;
        ReloadCategoriesPreservingSelection();
        SetStatus("Category renamed: " + item.Name + " -> " + newName);
    }

    private void DeleteSelectedCategory(ListBox categoryList)
    {
        if (_document is null || categoryList.SelectedItem is not CategoryOrderItem item)
        {
            return;
        }

        if (HasChanges())
        {
            MessageBox.Show(this, "Save or reload pending config value changes before editing designer layout.", "Admin Designer", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

        if (IsReservedCategory(item.Name))
        {
            MessageBox.Show(this, "This category cannot be deleted.", "Delete Category", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

        if (IsFixedCategory(item.Name))
        {
            if (MessageBox.Show(this, "Delete built-in category \"" + GetCategoryDisplayName(item.Name) + "\" from the normal GUI? This hides it and clears its designer layout/label, but it can be shown again later.", "Delete Category", MessageBoxButtons.YesNo, MessageBoxIcon.Question) != DialogResult.Yes)
            {
                return;
            }

            _document.Metadata.CategoryLayouts.Remove(item.Name);
            _document.Metadata.CategoryLabels.Remove(item.Name);
            RemoveCategoryName(_document.Metadata.HiddenCategories, item.Name);
            _document.Metadata.HiddenCategories.Add(item.Name);
            _document.Metadata.Save();

            var fixedIndex = categoryList.SelectedIndex;
            categoryList.Items[fixedIndex] = new CategoryOrderItem(item.Name, hidden: true, GetCategoryDisplayName(item.Name));
            categoryList.SelectedIndex = fixedIndex;
            ReloadCategoriesPreservingSelection();
            SetStatus("Category hidden/deleted from normal GUI: " + item.Name);
            return;
        }

        if (MessageBox.Show(this, "Delete category \"" + item.Name + "\" from the designer layout?", "Delete Category", MessageBoxButtons.YesNo, MessageBoxIcon.Question) != DialogResult.Yes)
        {
            return;
        }

        _document.Metadata.CategoryLayouts.Remove(item.Name);
        RemoveCategoryName(_document.Metadata.CategoryOrder, item.Name);
        RemoveCategoryName(_document.Metadata.HiddenCategories, item.Name);
        foreach (var key in _document.Metadata.Entries.Keys.ToList())
        {
            var metadata = _document.Metadata.Entries[key];
            if (metadata.Category?.Equals(item.Name, StringComparison.OrdinalIgnoreCase) == true)
            {
                metadata.Category = null;
                _document.Metadata.RemoveIfEmpty(key);
            }
        }

        _document.Metadata.Save();
        var index = categoryList.SelectedIndex;
        categoryList.Items.RemoveAt(index);
        if (categoryList.Items.Count > 0)
        {
            categoryList.SelectedIndex = Math.Min(index, categoryList.Items.Count - 1);
        }

        ReloadCategoriesPreservingSelection();
        SetStatus("Category deleted: " + item.Name);
    }

    private static void ReplaceCategoryName(List<string> names, string oldName, string newName)
    {
        for (var i = 0; i < names.Count; i++)
        {
            if (names[i].Equals(oldName, StringComparison.OrdinalIgnoreCase))
            {
                names[i] = newName;
            }
        }
    }

    private static void RemoveCategoryName(List<string> names, string name)
    {
        names.RemoveAll(candidate => candidate.Equals(name, StringComparison.OrdinalIgnoreCase));
    }

    private void AddDesignerCategory(ComboBox categoryBox, ListBox itemList)
    {
        if (_document is null)
        {
            return;
        }

        if (HasChanges())
        {
            MessageBox.Show(this, "Save or reload pending config value changes before editing designer layout.", "Admin Designer", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

        var name = PromptForText("New Category", "Category name")?.Trim();
        if (string.IsNullOrWhiteSpace(name))
        {
            return;
        }

        if (IsReservedCategory(name))
        {
            MessageBox.Show(this, "That category name is reserved.", "New Category", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

        for (var i = 0; i < categoryBox.Items.Count; i++)
        {
            if (string.Equals(categoryBox.Items[i]?.ToString(), name, StringComparison.OrdinalIgnoreCase))
            {
                categoryBox.SelectedIndex = i;
                SetStatus("Category already exists. Add items to it, then Save Layout.");
                return;
            }
        }

        _document.Metadata.CategoryLayouts[name] = new GuiCategoryLayout();
        _document.Metadata.Save();
        _designerSelectedCategory = name;
        categoryBox.Items.Add(name);
        categoryBox.SelectedItem = name;
        itemList.Items.Clear();
        SetStatus("Category created. Add items to it, then Save Layout to show it in the left list.");
    }

    private static void MoveLayoutItem(ListBox list, int direction)
    {
        var index = list.SelectedIndex;
        if (index < 0)
        {
            return;
        }

        var target = direction switch
        {
            int.MinValue => 0,
            int.MaxValue => list.Items.Count - 1,
            _ => index + direction
        };
        target = Math.Max(0, Math.Min(list.Items.Count - 1, target));
        if (target == index)
        {
            return;
        }

        var item = list.Items[index];
        list.Items.RemoveAt(index);
        list.Items.Insert(target, item);
        list.SelectedIndex = target;
    }

    private void AddLayoutItem(string categoryName, ListBox itemList)
    {
        if (_document is null || string.IsNullOrWhiteSpace(categoryName))
        {
            return;
        }

        var existing = itemList.Items
            .OfType<DesignerItem>()
            .Select(item => item.Key)
            .ToHashSet(StringComparer.Ordinal);
        var candidates = GetLayoutCandidates(categoryName)
            .Where(item => !existing.Contains(item.Key))
            .OrderBy(item => item.Label, StringComparer.OrdinalIgnoreCase)
            .ToList();
        if (candidates.Count == 0)
        {
            MessageBox.Show(this, "No more items are available to add to this category.", "Layout", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

        var selected = PromptForLayoutItem(candidates);
        if (selected is null)
        {
            return;
        }

        itemList.Items.Add(selected);
        itemList.SelectedIndex = itemList.Items.Count - 1;
    }

    private static void RemoveLayoutItem(ListBox itemList)
    {
        var index = itemList.SelectedIndex;
        if (index < 0)
        {
            return;
        }

        itemList.Items.RemoveAt(index);
        if (itemList.Items.Count > 0)
        {
            itemList.SelectedIndex = Math.Min(index, itemList.Items.Count - 1);
        }
    }

    private void MoveLayoutItemToCategory(string sourceCategoryName, ListBox itemList)
    {
        if (_document is null || string.IsNullOrWhiteSpace(sourceCategoryName))
        {
            return;
        }

        var selectedItems = itemList.SelectedItems
            .OfType<DesignerItem>()
            .OrderBy(item => itemList.Items.IndexOf(item))
            .ToList();
        if (selectedItems.Count == 0)
        {
            return;
        }

        if (HasChanges())
        {
            MessageBox.Show(this, "Save or reload pending config value changes before editing designer layout.", "Admin Designer", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

        var targetCategoryName = PromptForCategoryName(
            "Move To Category",
            selectedItems.Count == 1
                ? "Move \"" + selectedItems[0].Label + "\" to category"
                : "Move " + selectedItems.Count.ToString(CultureInfo.InvariantCulture) + " selected items to category",
            GetDesignerCategoryNames()
                .Where(name => !name.Equals(sourceCategoryName, StringComparison.OrdinalIgnoreCase))
                .ToList());
        if (string.IsNullOrWhiteSpace(targetCategoryName))
        {
            return;
        }

        var selectedKeys = selectedItems
            .Select(item => item.Key)
            .ToHashSet(StringComparer.Ordinal);
        var sourceItems = itemList.Items
            .OfType<DesignerItem>()
            .Where(item => !selectedKeys.Contains(item.Key))
            .ToList();
        var targetItems = GetDesignerItems(targetCategoryName, includeTableRows: false, includeAdvanced: true)
            .Where(item => !selectedKeys.Contains(item.Key))
            .ToList();
        targetItems.AddRange(selectedItems.Select(item => CopyDesignerItemToCategory(item, targetCategoryName)));

        SaveCategoryLayoutItems(sourceCategoryName, sourceItems);
        SaveCategoryLayoutItems(targetCategoryName, targetItems);
        _document.Metadata.Save();
        _designerSelectedCategory = sourceCategoryName;
        var selectedIndex = itemList.SelectedIndex;
        itemList.BeginUpdate();
        try
        {
            itemList.Items.Clear();
            foreach (var item in sourceItems)
            {
                itemList.Items.Add(item);
            }

            if (itemList.Items.Count > 0)
            {
                itemList.SelectedIndex = Math.Min(selectedIndex, itemList.Items.Count - 1);
            }
        }
        finally
        {
            itemList.EndUpdate();
        }

        SetStatus("Moved " + selectedItems.Count.ToString(CultureInfo.InvariantCulture) + " item(s) to " + targetCategoryName + ". Preview or export to use the updated design.");
    }

    private static DesignerItem CopyDesignerItemToCategory(DesignerItem item, string categoryName)
    {
        return new DesignerItem(item.Key, item.Label, categoryName, item.IsGroup, item.Entries, item.StringListTable, item.StageTable);
    }

    private string? PromptForCategoryName(string title, string labelText, List<string> categoryNames)
    {
        if (categoryNames.Count == 0)
        {
            MessageBox.Show(this, "No target categories are available.", title, MessageBoxButtons.OK, MessageBoxIcon.Information);
            return null;
        }

        using var dialog = new Form
        {
            Text = title,
            StartPosition = FormStartPosition.CenterParent,
            FormBorderStyle = FormBorderStyle.FixedDialog,
            MinimizeBox = false,
            MaximizeBox = false,
            ClientSize = new Size(420, 122),
            Font = Font
        };

        dialog.Controls.Add(new Label
        {
            Text = labelText,
            AutoSize = true,
            Location = new Point(12, 14)
        });

        var comboBox = new WheelSafeComboBox
        {
            Location = new Point(12, 38),
            Width = 396,
            DropDownStyle = ComboBoxStyle.DropDownList
        };
        foreach (var categoryName in categoryNames)
        {
            comboBox.Items.Add(categoryName);
        }
        comboBox.SelectedIndex = 0;
        dialog.Controls.Add(comboBox);

        var okButton = new Button
        {
            Text = "Move",
            DialogResult = DialogResult.OK,
            Location = new Point(246, 78),
            Width = 76
        };
        var cancelButton = new Button
        {
            Text = "Cancel",
            DialogResult = DialogResult.Cancel,
            Location = new Point(332, 78),
            Width = 76
        };
        dialog.Controls.Add(okButton);
        dialog.Controls.Add(cancelButton);
        dialog.AcceptButton = okButton;
        dialog.CancelButton = cancelButton;
        return dialog.ShowDialog(this) == DialogResult.OK ? comboBox.Text : null;
    }

    private List<DesignerItem> GetLayoutCandidates(string targetCategory)
    {
        var items = new Dictionary<string, DesignerItem>(StringComparer.Ordinal);
        if (_document is null)
        {
            return new List<DesignerItem>();
        }

        foreach (var categoryName in GetDesignerCategoryNames())
        {
            foreach (var item in GetAutoDesignerItems(categoryName, includeTableRows: false, includeAdvanced: true))
            {
                items.TryAdd(item.Key, new DesignerItem(item.Key, item.Label, targetCategory, item.IsGroup, item.Entries));
            }
        }

        foreach (var entry in _document.Entries.Where(entry => string.IsNullOrWhiteSpace(entry.ParentKey)))
        {
            items.TryAdd(entry.DisplayKey, new DesignerItem(entry.DisplayKey, entry.DisplayName, targetCategory, isGroup: false, new List<ConfigEntry> { entry }));
        }

        foreach (var group in _document.Entries
                     .Where(entry => !string.IsNullOrWhiteSpace(entry.ParentKey))
                     .GroupBy(entry => entry.ParentKey))
        {
            var children = group.OrderBy(entry => entry.LineIndex).ThenBy(entry => entry.Key, StringComparer.OrdinalIgnoreCase).ToList();
            items.TryAdd(group.Key, new DesignerItem(group.Key, GetDesignerGroupLabel(group.Key, children), targetCategory, isGroup: true, children));
        }

        return items.Values.ToList();
    }

    private DesignerItem? PromptForLayoutItem(List<DesignerItem> candidates)
    {
        using var dialog = new Form
        {
            Text = "Add Layout Item",
            StartPosition = FormStartPosition.CenterParent,
            FormBorderStyle = FormBorderStyle.FixedDialog,
            MinimizeBox = false,
            MaximizeBox = false,
            ClientSize = new Size(520, 360),
            Font = Font
        };

        var label = new Label
        {
            Text = "Select an item to add to this category.",
            Dock = DockStyle.Top,
            Height = 34,
            TextAlign = ContentAlignment.MiddleLeft,
            Padding = new Padding(10, 8, 10, 0)
        };
        dialog.Controls.Add(label);

        var list = new ListBox
        {
            Dock = DockStyle.Top,
            Height = 260,
            IntegralHeight = false
        };
        foreach (var candidate in candidates)
        {
            list.Items.Add(candidate);
        }
        list.SelectedIndex = 0;
        dialog.Controls.Add(list);

        var buttons = new FlowLayoutPanel
        {
            Dock = DockStyle.Bottom,
            FlowDirection = FlowDirection.RightToLeft,
            Height = 48,
            Padding = new Padding(8)
        };
        var addButton = new Button
        {
            Text = "Add",
            DialogResult = DialogResult.OK,
            Width = 90
        };
        var cancelButton = new Button
        {
            Text = "Cancel",
            DialogResult = DialogResult.Cancel,
            Width = 90
        };
        buttons.Controls.Add(addButton);
        buttons.Controls.Add(cancelButton);
        dialog.Controls.Add(buttons);

        dialog.AcceptButton = addButton;
        dialog.CancelButton = cancelButton;
        list.DoubleClick += (_, _) => dialog.DialogResult = DialogResult.OK;
        return dialog.ShowDialog(this) == DialogResult.OK ? list.SelectedItem as DesignerItem : null;
    }

    private bool SaveDesignerLayout(string categoryName, ListBox itemList)
    {
        if (_document is null || string.IsNullOrWhiteSpace(categoryName))
        {
            return false;
        }

        if (HasChanges())
        {
            MessageBox.Show(this, "Save or reload pending config value changes before editing designer layout.", "Admin Designer", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return false;
        }

        SaveCategoryLayoutItems(categoryName, itemList.Items.OfType<DesignerItem>());
        _document.Metadata.Save();
        _designerSelectedCategory = categoryName;
        SetStatus("Designer layout saved: " + _document.Metadata.Path);
        return true;
    }

    private void SaveCategoryLayoutItems(string categoryName, IEnumerable<DesignerItem> items)
    {
        if (_document is null)
        {
            return;
        }

        var layout = new GuiCategoryLayout();
        foreach (var item in items)
        {
            layout.Items.Add(item.Key);
        }

        _document.Metadata.CategoryLayouts[categoryName] = layout;
    }

    private static Label MakeDesignerLabel(string text)
    {
        return new Label
        {
            Text = text,
            Dock = DockStyle.Top,
            AutoSize = true,
            Padding = new Padding(0, 10, 0, 3)
        };
    }

    private static TextBox MakeDesignerTextBox(bool singleLine)
    {
        return new TextBox
        {
            Dock = DockStyle.Top,
            Multiline = !singleLine,
            ScrollBars = singleLine ? ScrollBars.None : ScrollBars.Vertical
        };
    }

    private static Button MakeDesignerButton(string text, Action action, int width)
    {
        var button = new Button
        {
            Text = text,
            Width = width,
            Height = 30,
            MinimumSize = new Size(width, 30),
            AutoSize = true,
            AutoSizeMode = AutoSizeMode.GrowOnly,
            Margin = new Padding(0, 0, 8, 0),
            AutoEllipsis = true
        };
        StyleButton(button);
        button.Click += (_, _) => action();
        return button;
    }

    private Button MakeHelpButton(string title, string helpText, string? metadataKey = null)
    {
        var fullHelp = title + Environment.NewLine + Environment.NewLine + helpText;
        var buttonSize = Math.Max(Zoomed(22), Font.Height + Zoomed(4));
        var button = new Button
        {
            Text = "?",
            Width = buttonSize,
            Height = buttonSize,
            MinimumSize = new Size(buttonSize, buttonSize),
            Margin = new Padding(0, Zoomed(1), 0, 0),
            FlatStyle = FlatStyle.Flat,
            BackColor = ButtonBackground,
            ForeColor = PrimaryTextColor
        };
        button.FlatAppearance.BorderColor = BorderColor;
        _toolTip.SetToolTip(button, fullHelp);
        button.MouseEnter += (_, _) => _toolTip.Show(fullHelp, button, button.Width + 6, 0, 30000);
        button.MouseLeave += (_, _) => _toolTip.Hide(button);
        if (!string.IsNullOrWhiteSpace(metadataKey) && _adminUnlocked && !AppMode.IsExportedUserBuild)
        {
            button.Click += (_, _) =>
            {
                _toolTip.Hide(button);
                EditHelpMetadata(metadataKey, title, helpText);
            };
        }

        return button;
    }

    private List<string> GetKnownCategoryNames()
    {
        var names = _document is null
            ? _categories
                .Select(category => category.Name)
                .Where(name => name is not "Admin Designer" and not "Raw Values")
                .ToList()
            : GetConfigCategoryNamesInSourceOrder();

        return names.OrderBy(name => name, StringComparer.OrdinalIgnoreCase).ToList();
    }

    private List<string> GetDesignerCategoryNames()
    {
        var names = _document is null
            ? _categories
                .Where(category => category.Name is not "Admin Designer" and not "Raw Values")
                .Select(category => category.Name)
                .ToList()
            : GetConfigCategoryNamesInSourceOrder();

        return OrderCategoryNames(names);
    }

    private List<string> GetConfigCategoryNamesInSourceOrder()
    {
        var categories = new List<(int LineIndex, string Name)>();
        if (_document is null)
        {
            return new List<string>();
        }

        categories.AddRange(_document.Entries
            .Where(entry => !string.IsNullOrWhiteSpace(entry.EffectiveCategory))
            .Select(entry => (entry.LineIndex, entry.EffectiveCategory)));
        categories.AddRange(_document.StringListTables
            .Where(table => !string.IsNullOrWhiteSpace(table.Section))
            .Select(table => (table.StartLineIndex, table.Section)));
        categories.AddRange(_document.StageTables
            .Where(table => !string.IsNullOrWhiteSpace(table.Section))
            .Select(table => (table.StartLineIndex, table.Section)));

        var names = new List<string>();
        foreach (var category in categories
                     .OrderBy(category => category.LineIndex)
                     .ThenBy(category => category.Name, StringComparer.OrdinalIgnoreCase))
        {
            if (!names.Contains(category.Name, StringComparer.OrdinalIgnoreCase))
            {
                names.Add(category.Name);
            }
        }

        return names;
    }

    private bool HasConfigCategory(string categoryName)
    {
        if (_document is null || string.IsNullOrWhiteSpace(categoryName))
        {
            return false;
        }

        return _document.Entries.Any(entry => entry.EffectiveCategory.Equals(categoryName, StringComparison.OrdinalIgnoreCase)) ||
               _document.StringListTables.Any(table => table.Section.Equals(categoryName, StringComparison.OrdinalIgnoreCase)) ||
               _document.StageTables.Any(table => table.Section.Equals(categoryName, StringComparison.OrdinalIgnoreCase));
    }

    private List<DesignerItem> GetDesignerItems(string categoryName, bool includeTableRows, bool includeAdvanced = false)
    {
        if (HasConfigCategory(categoryName))
        {
            // Config-backed categories use Lua source order; designer metadata still controls labels and rendering.
            return GetConfigSourceDesignerItems(categoryName, includeTableRows, includeAdvanced);
        }

        if (_document is not null &&
            _document.Metadata.CategoryLayouts.TryGetValue(categoryName, out var layout))
        {
            return GetSavedLayoutDesignerItems(categoryName, layout, includeTableRows, includeAdvanced);
        }

        return GetAutoDesignerItems(categoryName, includeTableRows, includeAdvanced);
    }

    private List<DesignerItem> GetAutoDesignerItems(string categoryName, bool includeTableRows, bool includeAdvanced = false)
    {
        var items = new List<DesignerItem>();
        if (_document is null || string.IsNullOrWhiteSpace(categoryName))
        {
            return SortDesignerItems(items);
        }

        var rendered = new HashSet<string>(StringComparer.Ordinal);
        var category = HasConfigCategory(categoryName)
            ? null
            : _categories.FirstOrDefault(item => item.Name.Equals(categoryName, StringComparison.OrdinalIgnoreCase));
        if (category is not null)
        {
            var fixedKeys = GetFixedRenderedKeys();
            foreach (var key in category.Keys)
            {
                var direct = FindEntry(key);
                var children = FindGroupEntries(key);
                if (direct is not null)
                {
                    items.Add(new DesignerItem(direct.DisplayKey, direct.DisplayName, categoryName, isGroup: false, new List<ConfigEntry> { direct }));
                    rendered.Add(direct.DisplayKey);
                }
                else if (children.Count > 0)
                {
                    items.Add(new DesignerItem(key, GetDesignerGroupLabel(key, children), categoryName, isGroup: true, children));
                    foreach (var child in children)
                    {
                        rendered.Add(child.DisplayKey);
                    }

                    if (includeTableRows)
                    {
                        foreach (var child in children)
                        {
                            items.Add(new DesignerItem(child.DisplayKey, "  " + child.DisplayName, categoryName, isGroup: false, new List<ConfigEntry> { child }));
                        }
                    }
                }
                else if (FindStringListTable(key) is { } stringListTable)
                {
                    items.Add(new DesignerItem(key, stringListTable.GuiLabel ?? GetConfiguredGroupLabel(key), categoryName, isGroup: false, new List<ConfigEntry>(), stringListTable));
                    rendered.Add(key);
                }
                else if (FindStageTable(key) is { } stageTable)
                {
                    items.Add(new DesignerItem(key, stageTable.GuiLabel ?? GetConfiguredGroupLabel(key), categoryName, isGroup: true, new List<ConfigEntry>(), stageTable: stageTable));
                    rendered.Add(key);
                }
            }

            foreach (var entry in _document.Entries.Where(entry =>
                         entry.EffectiveCategory.Equals(categoryName, StringComparison.OrdinalIgnoreCase) &&
                         string.IsNullOrWhiteSpace(entry.ParentKey) &&
                         !fixedKeys.Contains(entry.DisplayKey) &&
                         !rendered.Contains(entry.DisplayKey)))
            {
                items.Add(new DesignerItem(entry.DisplayKey, entry.DisplayName, categoryName, isGroup: false, new List<ConfigEntry> { entry }));
                rendered.Add(entry.DisplayKey);
            }

            return SortDesignerItems(items);
        }

        foreach (var group in GetRenderableCategoryEntries(categoryName)
                     .Where(entry => includeAdvanced || ShouldIncludeAdvancedEntries() || !entry.IsAdvanced)
                     .GroupBy(entry => entry.ParentKey)
                     .OrderBy(group => string.IsNullOrWhiteSpace(group.Key) ? "!" : group.Key, StringComparer.OrdinalIgnoreCase))
        {
            if (string.IsNullOrWhiteSpace(group.Key))
            {
                foreach (var entry in group)
                {
                    items.Add(new DesignerItem(entry.DisplayKey, entry.DisplayName, categoryName, isGroup: false, new List<ConfigEntry> { entry }));
                }
                continue;
            }

            var children = group.OrderBy(entry => entry.LineIndex).ThenBy(entry => entry.Key, StringComparer.OrdinalIgnoreCase).ToList();
            items.Add(new DesignerItem(group.Key, GetDesignerGroupLabel(group.Key, children), categoryName, isGroup: true, children));
            if (!includeTableRows)
            {
                continue;
            }

            foreach (var child in children)
            {
                items.Add(new DesignerItem(child.DisplayKey, "  " + child.DisplayName, categoryName, isGroup: false, new List<ConfigEntry> { child }));
            }
        }

        return SortDesignerItems(items);
    }

    private List<DesignerItem> GetSavedLayoutDesignerItems(string categoryName, GuiCategoryLayout layout, bool includeTableRows, bool includeAdvanced)
    {
        var items = new List<DesignerItem>();
        if (_document is null)
        {
            return items;
        }

        var rendered = new HashSet<string>(StringComparer.Ordinal);
        foreach (var key in layout.Items)
        {
            var item = ResolveDesignerItem(key, categoryName);
            if (item is null)
            {
                continue;
            }

            items.Add(item);
            MarkDesignerItemRendered(item, rendered);
            if (includeTableRows && item.IsGroup)
            {
                foreach (var child in item.Entries)
                {
                    items.Add(new DesignerItem(child.DisplayKey, "  " + child.DisplayName, categoryName, isGroup: false, new List<ConfigEntry> { child }));
                }
            }
        }

        // Saved layouts anchor the preferred order, but config source order must still surface new keys.
        foreach (var item in GetUnlistedSourceDesignerItems(categoryName, rendered, includeAdvanced))
        {
            items.Add(item);
            if (includeTableRows && item.IsGroup)
            {
                foreach (var child in item.Entries)
                {
                    items.Add(new DesignerItem(child.DisplayKey, "  " + child.DisplayName, categoryName, isGroup: false, new List<ConfigEntry> { child }));
                }
            }
        }

        return items;
    }

    private List<DesignerItem> GetConfigSourceDesignerItems(string categoryName, bool includeTableRows, bool includeAdvanced)
    {
        var rendered = new HashSet<string>(StringComparer.Ordinal);
        var layoutVisibleKeys = GetCategoryLayoutRenderedKeys(categoryName);
        var sourceItems = GetUnlistedSourceDesignerItems(
            categoryName,
            rendered,
            includeAdvanced,
            excludeSavedLayoutPinned: false,
            alwaysVisibleKeys: layoutVisibleKeys);
        if (!includeTableRows)
        {
            return sourceItems;
        }

        var items = new List<DesignerItem>();
        foreach (var item in sourceItems)
        {
            items.Add(item);
            if (!item.IsGroup)
            {
                continue;
            }

            foreach (var child in item.Entries)
            {
                items.Add(new DesignerItem(child.DisplayKey, "  " + child.DisplayName, categoryName, isGroup: false, new List<ConfigEntry> { child }));
            }
        }

        return items;
    }

    private List<DesignerItem> GetUnlistedSourceDesignerItems(string categoryName, HashSet<string> rendered, bool includeAdvanced)
    {
        return GetUnlistedSourceDesignerItems(categoryName, rendered, includeAdvanced, excludeSavedLayoutPinned: true, alwaysVisibleKeys: null);
    }

    private List<DesignerItem> GetUnlistedSourceDesignerItems(
        string categoryName,
        HashSet<string> rendered,
        bool includeAdvanced,
        bool excludeSavedLayoutPinned,
        HashSet<string>? alwaysVisibleKeys)
    {
        var items = new List<(int LineIndex, DesignerItem Item)>();
        if (_document is null)
        {
            return new List<DesignerItem>();
        }

        var pinnedBySavedLayouts = excludeSavedLayoutPinned
            ? GetSavedLayoutRenderedKeys()
            : new HashSet<string>(StringComparer.Ordinal);
        var sourceEntries = _document.Entries
            .Where(entry => entry.EffectiveCategory.Equals(categoryName, StringComparison.OrdinalIgnoreCase))
            .Where(entry => includeAdvanced ||
                            ShouldIncludeAdvancedEntries() ||
                            !entry.IsAdvanced ||
                            IsAlwaysVisibleDesignerItem(entry, alwaysVisibleKeys))
            .Where(entry => !rendered.Contains(entry.DisplayKey))
            .Where(entry => !pinnedBySavedLayouts.Contains(entry.DisplayKey))
            .ToList();

        AddFlattenedCallsignOverridesItem(categoryName, sourceEntries, rendered, pinnedBySavedLayouts, items);

        foreach (var entry in sourceEntries.Where(entry => string.IsNullOrWhiteSpace(entry.ParentKey)))
        {
            items.Add((entry.LineIndex, new DesignerItem(entry.DisplayKey, entry.DisplayName, categoryName, isGroup: false, new List<ConfigEntry> { entry })));
            rendered.Add(entry.DisplayKey);
        }

        foreach (var group in sourceEntries
                     .Where(entry => !string.IsNullOrWhiteSpace(entry.ParentKey))
                     .GroupBy(entry => entry.ParentKey)
                     .OrderBy(group => group.Min(entry => entry.LineIndex)))
        {
            if (rendered.Contains(group.Key) || pinnedBySavedLayouts.Contains(group.Key))
            {
                continue;
            }

            var children = group.OrderBy(entry => entry.LineIndex).ThenBy(entry => entry.Key, StringComparer.OrdinalIgnoreCase).ToList();
            if (ShouldRenderRecordTableAsEntries(group.Key, children))
            {
                foreach (var child in children)
                {
                    items.Add((child.LineIndex, new DesignerItem(child.DisplayKey, child.DisplayName, categoryName, isGroup: false, new List<ConfigEntry> { child })));
                    rendered.Add(child.DisplayKey);
                }

                rendered.Add(group.Key);
                continue;
            }

            items.Add((children[0].LineIndex, new DesignerItem(group.Key, GetDesignerGroupLabel(group.Key, children), categoryName, isGroup: true, children)));
            rendered.Add(group.Key);
            foreach (var child in children)
            {
                rendered.Add(child.DisplayKey);
            }
        }

        foreach (var table in _document.StringListTables
                     .Where(table => table.Section.Equals(categoryName, StringComparison.OrdinalIgnoreCase))
                     .Where(table => !rendered.Contains(table.Key))
                     .Where(table => !pinnedBySavedLayouts.Contains(table.Key)))
        {
            items.Add((table.StartLineIndex, new DesignerItem(table.Key, table.GuiLabel ?? GetConfiguredGroupLabel(table.Key), categoryName, isGroup: false, new List<ConfigEntry>(), table)));
            rendered.Add(table.Key);
        }

        foreach (var table in _document.StageTables
                     .Where(table => table.Section.Equals(categoryName, StringComparison.OrdinalIgnoreCase))
                     .Where(table => !rendered.Contains(table.Key))
                     .Where(table => !pinnedBySavedLayouts.Contains(table.Key)))
        {
            items.Add((table.StartLineIndex, new DesignerItem(table.Key, table.GuiLabel ?? GetConfiguredGroupLabel(table.Key), categoryName, isGroup: true, new List<ConfigEntry>(), stageTable: table)));
            rendered.Add(table.Key);
        }

        return items
            .OrderBy(item => item.LineIndex)
            .Select(item => item.Item)
            .ToList();
    }

    private void AddFlattenedCallsignOverridesItem(
        string categoryName,
        List<ConfigEntry> sourceEntries,
        HashSet<string> rendered,
        HashSet<string> pinnedBySavedLayouts,
        List<(int LineIndex, DesignerItem Item)> items)
    {
        const string key = "CallsignOverrides";
        if (rendered.Contains(key) || pinnedBySavedLayouts.Contains(key))
        {
            return;
        }

        var entries = sourceEntries
            .Where(entry => entry.DisplayKey.StartsWith(key + ".", StringComparison.Ordinal) &&
                            entry.ParentKey.StartsWith(key + ".", StringComparison.Ordinal))
            .OrderBy(GetCallsignAircraft, StringComparer.OrdinalIgnoreCase)
            .ThenBy(entry => entry.Key, StringComparer.OrdinalIgnoreCase)
            .ToList();
        if (entries.Count == 0)
        {
            return;
        }

        items.Add((entries.Min(entry => entry.LineIndex), new DesignerItem(key, GetConfiguredGroupLabel(key), categoryName, isGroup: true, entries)));
        rendered.Add(key);
        foreach (var entry in entries)
        {
            rendered.Add(entry.ParentKey);
            rendered.Add(entry.DisplayKey);
        }
    }

    private static bool ShouldRenderRecordTableAsEntries(string groupKey, IReadOnlyList<ConfigEntry> children)
    {
        return !groupKey.Contains(".", StringComparison.Ordinal) &&
               children.Count > 0 &&
               children.All(child => child.ParentKey.Equals(groupKey, StringComparison.Ordinal)) &&
               children.Any(child => child.IsLongText ||
                                     string.Equals(child.ControlTypeOverride, "multiline", StringComparison.OrdinalIgnoreCase));
    }

    private HashSet<string> GetCategoryLayoutRenderedKeys(string categoryName)
    {
        var rendered = new HashSet<string>(StringComparer.Ordinal);
        if (_document is null ||
            !_document.Metadata.CategoryLayouts.TryGetValue(categoryName, out var layout))
        {
            return rendered;
        }

        foreach (var key in layout.Items)
        {
            rendered.Add(key);
            var item = ResolveDesignerItem(key, categoryName);
            if (item is not null)
            {
                MarkDesignerItemRendered(item, rendered);
            }
        }

        return rendered;
    }

    private static bool IsAlwaysVisibleDesignerItem(ConfigEntry entry, HashSet<string>? alwaysVisibleKeys)
    {
        return alwaysVisibleKeys is not null &&
               (alwaysVisibleKeys.Contains(entry.DisplayKey) ||
                (!string.IsNullOrWhiteSpace(entry.ParentKey) && alwaysVisibleKeys.Contains(entry.ParentKey)));
    }

    private HashSet<string> GetSavedLayoutRenderedKeys()
    {
        var rendered = new HashSet<string>(StringComparer.Ordinal);
        if (_document is null)
        {
            return rendered;
        }

        foreach (var layout in _document.Metadata.CategoryLayouts)
        {
            foreach (var key in layout.Value.Items)
            {
                rendered.Add(key);
                var item = ResolveDesignerItem(key, layout.Key);
                if (item is not null)
                {
                    MarkDesignerItemRendered(item, rendered);
                }
            }
        }

        return rendered;
    }

    private static void MarkDesignerItemRendered(DesignerItem item, HashSet<string> rendered)
    {
        rendered.Add(item.Key);
        if (item.StringListTable is not null)
        {
            rendered.Add(item.StringListTable.Key);
        }

        if (item.StageTable is not null)
        {
            rendered.Add(item.StageTable.Key);
        }

        foreach (var entry in item.Entries)
        {
            rendered.Add(entry.DisplayKey);
            if (!string.IsNullOrWhiteSpace(entry.ParentKey))
            {
                rendered.Add(entry.ParentKey);
            }
        }
    }

    private DesignerItem? ResolveDesignerItem(string key, string categoryName)
    {
        var direct = FindEntry(key);
        if (direct is not null)
        {
            return new DesignerItem(direct.DisplayKey, direct.DisplayName, categoryName, isGroup: false, new List<ConfigEntry> { direct });
        }

        var children = FindGroupEntries(key);
        if (children.Count > 0)
        {
            return new DesignerItem(key, GetDesignerGroupLabel(key, children), categoryName, isGroup: true, children);
        }

        if (FindStringListTable(key) is { } stringListTable)
        {
            return new DesignerItem(key, stringListTable.GuiLabel ?? GetConfiguredGroupLabel(key), categoryName, isGroup: false, new List<ConfigEntry>(), stringListTable);
        }

        if (FindStageTable(key) is { } stageTable)
        {
            return new DesignerItem(key, stageTable.GuiLabel ?? GetConfiguredGroupLabel(key), categoryName, isGroup: true, new List<ConfigEntry>(), stageTable: stageTable);
        }

        return null;
    }

    private List<DesignerItem> SortDesignerItems(List<DesignerItem> items)
    {
        return items
            .Select((item, index) => new { Item = item, Index = index, Order = GetDesignerOrder(item.Key) })
            .OrderBy(item => item.Order ?? int.MaxValue)
            .ThenBy(item => item.Index)
            .Select(item => item.Item)
            .ToList();
    }

    private int? GetDesignerOrder(string key)
    {
        return _document is not null &&
               _document.Metadata.Entries.TryGetValue(key, out var metadata)
            ? metadata.Order
            : null;
    }

    private string GetDesignerGroupLabel(string key, List<ConfigEntry> entries)
    {
        if (_document?.Metadata.Entries.TryGetValue(key, out var metadata) == true &&
            !string.IsNullOrWhiteSpace(metadata.Label))
        {
            return metadata.Label;
        }

        return GetConfiguredGroupLabel(key);
    }

    private string GetConfiguredGroupLabel(string key)
    {
        return _document?.GetGuiLabel(key) ?? GetDefaultGroupLabel(key);
    }

    private static string GetDefaultGroupLabel(string key)
    {
        if (key.Equals("CapLimitStages", StringComparison.Ordinal))
        {
            return "RED CAP Limit";
        }

        if (key.Equals("RedCasLimitStages", StringComparison.Ordinal))
        {
            return "RED CAS Limit";
        }

        if (key.Equals("RedSeadLimitStages", StringComparison.Ordinal))
        {
            return "RED SEAD Limit";
        }

        if (key.Equals("RedRunwayStrikeLimitStages", StringComparison.Ordinal))
        {
            return "RED Runway Strike Limit";
        }

        if (key.Equals("BlueCapSupportStages", StringComparison.Ordinal))
        {
            return "BLUE CAP Support";
        }

        if (key.Equals("BlueCasSupportStages", StringComparison.Ordinal))
        {
            return "BLUE CAS Support";
        }

        if (key.Equals("BlueSeadSupportStages", StringComparison.Ordinal))
        {
            return "BLUE SEAD Support";
        }

        if (key.Equals("AllowedCsar", StringComparison.Ordinal))
        {
            return "Allowed CSAR Aircraft";
        }

        if (key.Equals("CallsignOverrides", StringComparison.Ordinal))
        {
            return "Welcome Message Callsigns";
        }

        if (key.Equals("allowedPlanes", StringComparison.Ordinal))
        {
            return "Allowed Aircraft";
        }

        if (key.Equals("allowedPlanesRed", StringComparison.Ordinal))
        {
            return "Allowed RED Aircraft";
        }

        if (key.Equals("restockAircraft", StringComparison.Ordinal))
        {
            return "Warehouse Restock Aircraft";
        }

        if (key.Equals("restrictedWeapons", StringComparison.Ordinal))
        {
            return "Cold War Restricted Weapons";
        }

        if (key.Equals("ForbiddWeaponsInAllEra", StringComparison.Ordinal))
        {
            return "Forbidden Weapons All Eras";
        }

        return HumanizeCategoryKey(key);
    }

    private static string GetCallsignAircraft(ConfigEntry entry)
    {
        const string prefix = "CallsignOverrides.";
        if (!entry.ParentKey.StartsWith(prefix, StringComparison.Ordinal))
        {
            return "";
        }

        return entry.ParentKey[prefix.Length..];
    }

    private static string GetDesignerGroupHelp(DesignerItem item)
    {
        if (item.StageTable is not null)
        {
            return item.StageTable.Description;
        }

        return item.Entries.FirstOrDefault(entry => !string.IsNullOrWhiteSpace(entry.ParentDescription))?.ParentDescription ?? "";
    }

    private void LoadDesignerItem(
        DesignerItem item,
        TextBox labelBox,
        ComboBox controlTypeBox,
        ComboBox advancedBox,
        ComboBox tableHeightModeBox,
        NumericUpDown tableMaxVisibleRowsBox,
        TextBox choicesBox)
    {
        if (_document is null)
        {
            return;
        }

        _document.Metadata.Entries.TryGetValue(item.Key, out var metadata);
        labelBox.Text = metadata?.Label ?? item.Label;
        controlTypeBox.Text = item.IsGroup ? "table" : metadata?.ControlType ?? "";
        advancedBox.Text = metadata?.Advanced switch
        {
            true => "Advanced",
            false => "Basic",
            _ => "Use inferred"
        };
        tableHeightModeBox.Text = metadata?.TableHeightMode switch
        {
            "Auto" => "Auto",
            "Capped" => "Capped",
            _ => "Use default"
        };
        tableMaxVisibleRowsBox.Value = Math.Clamp(
            metadata?.TableMaxVisibleRows ?? 0,
            (int)tableMaxVisibleRowsBox.Minimum,
            (int)tableMaxVisibleRowsBox.Maximum);
        choicesBox.Text = item.IsGroup
            ? ""
            : FormatDesignerChoices(metadata?.Choices.Count > 0
                ? metadata.Choices
                : item.Entries[0].Choices.Select(choice => new GuiChoiceMetadata { Display = choice.Display, Literal = choice.Literal }).ToList());

        controlTypeBox.Enabled = !item.IsGroup;
        advancedBox.Enabled = !item.IsGroup;
        tableHeightModeBox.Enabled = item.IsGroup;
        tableMaxVisibleRowsBox.Enabled = item.IsGroup;
        choicesBox.Enabled = !item.IsGroup;
    }

    private void LoadDesignerEntry(
        string key,
        TextBox labelBox,
        ComboBox controlTypeBox,
        ComboBox advancedBox,
        TextBox helpBox,
        TextBox choicesBox)
    {
        var entry = FindEntry(key);
        if (entry is null || _document is null)
        {
            return;
        }

        _document.Metadata.Entries.TryGetValue(key, out var metadata);
        labelBox.Text = metadata?.Label ?? entry.DisplayName;
        controlTypeBox.Text = metadata?.ControlType ?? "";
        advancedBox.Text = metadata?.Advanced switch
        {
            true => "Advanced",
            false => "Basic",
            _ => "Use inferred"
        };
        helpBox.Text = metadata?.Help ?? entry.EffectiveDescription;
        choicesBox.Text = FormatDesignerChoices(metadata?.Choices.Count > 0
            ? metadata.Choices
            : entry.Choices.Select(choice => new GuiChoiceMetadata { Display = choice.Display, Literal = choice.Literal }).ToList());
    }

    private bool SaveDesignerMetadata(
        DesignerItem? item,
        TextBox labelBox,
        ComboBox controlTypeBox,
        ComboBox advancedBox,
        ComboBox tableHeightModeBox,
        NumericUpDown tableMaxVisibleRowsBox,
        TextBox choicesBox,
        CheckBox advancedToggleVisibleBox,
        CheckBox rawValuesVisibleBox,
        TextBox footerVersionBox,
        bool previewAfterSave)
    {
        if (_document is null)
        {
            return false;
        }

        if (HasChanges())
        {
            MessageBox.Show(this, "Save or reload pending config value changes before editing designer metadata.", "Admin Designer", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return false;
        }

        var categoryListMayChange =
            _document.Metadata.AdvancedToggleVisible != advancedToggleVisibleBox.Checked ||
            _document.Metadata.RawValuesVisible != rawValuesVisibleBox.Checked;
        _document.Metadata.AdvancedToggleVisible = advancedToggleVisibleBox.Checked;
        _document.Metadata.RawValuesVisible = rawValuesVisibleBox.Checked;
        _document.Metadata.FooterVersion = string.IsNullOrWhiteSpace(footerVersionBox.Text)
            ? null
            : footerVersionBox.Text.Trim();
        UpdateFooterLabels();

        if (item is null)
        {
            _document.Metadata.Save();
            ApplyAdvancedToggleVisibility();
            if (categoryListMayChange)
            {
                ReloadCategoriesPreservingSelection();
            }

            SetStatus("Designer metadata saved: " + _document.Metadata.Path);
            return true;
        }

        var entry = item.IsGroup ? null : item.Entries.FirstOrDefault();
        if (!item.IsGroup && entry is null)
        {
            return false;
        }

        var metadata = _document.Metadata.GetOrCreate(item.Key);
        metadata.Label = NullIfWhite(labelBox.Text);
        if (item.IsGroup)
        {
            metadata.Category = null;
            metadata.ControlType = null;
            metadata.Advanced = null;
            metadata.TableHeightMode = tableHeightModeBox.Text switch
            {
                "Auto" => "Auto",
                "Capped" => "Capped",
                _ => null
            };
            metadata.TableMaxVisibleRows = tableMaxVisibleRowsBox.Value > 0
                ? (int)tableMaxVisibleRowsBox.Value
                : null;
            metadata.Choices.Clear();
        }
        else
        {
            metadata.Category = null;
            metadata.ControlType = NullIfWhite(controlTypeBox.Text);
            metadata.Advanced = advancedBox.Text switch
            {
                "Basic" => false,
                "Advanced" => true,
                _ => null
            };
            metadata.TableHeightMode = null;
            metadata.TableMaxVisibleRows = null;
            metadata.Choices = ParseDesignerChoices(choicesBox.Text);
        }

        _document.Metadata.RemoveIfEmpty(item.Key);
        _document.Metadata.Save();
        _document.ApplyMetadata();
        ApplyAdvancedToggleVisibility();
        if (categoryListMayChange)
        {
            ReloadCategoriesPreservingSelection();
        }

        _designerSelectedKey = item.Key;
        _designerSelectedCategory = item.Category;

        var targetCategory = item.Category;
        if (previewAfterSave)
        {
            ReloadCategoriesPreservingSelection();
            SelectCategory(targetCategory);
        }

        SetStatus("Designer metadata saved: " + _document.Metadata.Path);
        return true;
    }

    private void ExportConfiguredExe(
        DesignerItem? item,
        TextBox labelBox,
        ComboBox controlTypeBox,
        ComboBox advancedBox,
        ComboBox tableHeightModeBox,
        NumericUpDown tableMaxVisibleRowsBox,
        TextBox choicesBox,
        CheckBox advancedToggleVisibleBox,
        CheckBox rawValuesVisibleBox,
        TextBox footerVersionBox,
        string buildMode)
    {
        if (_document is null)
        {
            return;
        }

        if (!SaveDesignerMetadata(item, labelBox, controlTypeBox, advancedBox, tableHeightModeBox, tableMaxVisibleRowsBox, choicesBox, advancedToggleVisibleBox, rawValuesVisibleBox, footerVersionBox, previewAfterSave: false))
        {
            return;
        }

        using var dialog = new SaveFileDialog
        {
            Title = buildMode.Equals("admin", StringComparison.OrdinalIgnoreCase)
                ? "Export admin Foothold Config Manager EXE"
                : "Export user Foothold Config Manager EXE",
            Filter = "EXE files (*.exe)|*.exe|All files (*.*)|*.*",
            FileName = buildMode.Equals("admin", StringComparison.OrdinalIgnoreCase)
                ? "Foothold Config Manager Admin.exe"
                : "Foothold Config Manager.exe",
            InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory),
            OverwritePrompt = true
        };

        if (dialog.ShowDialog(this) != DialogResult.OK)
        {
            return;
        }

        try
        {
            UseWaitCursor = true;
            SetStatus(buildMode.Equals("admin", StringComparison.OrdinalIgnoreCase)
                ? "Building smaller admin EXE..."
                : "Building smaller user EXE...");
            Application.DoEvents();

            var exportedPath = UserExeExporter.Export(_document, dialog.FileName, buildMode);
            SetStatus("Exported " + buildMode + " EXE: " + exportedPath);
            MessageBox.Show(
                this,
                "Exported " + buildMode + " EXE:" + Environment.NewLine + exportedPath + Environment.NewLine + Environment.NewLine +
                "This smaller EXE requires the .NET 8 Windows Desktop Runtime on the user's PC/server.",
                "Export complete",
                MessageBoxButtons.OK,
                MessageBoxIcon.Information);
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Export failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
            SetStatus("Export failed.");
        }
        finally
        {
            UseWaitCursor = false;
        }
    }

    private bool ClearDesignerMetadata(string key)
    {
        if (_document is null || string.IsNullOrWhiteSpace(key))
        {
            return false;
        }

        if (HasChanges())
        {
            MessageBox.Show(this, "Save or reload pending config value changes before editing designer metadata.", "Admin Designer", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return false;
        }

        _document.Metadata.Entries.Remove(key);
        _document.Metadata.Save();
        _document.ApplyMetadata();
        SetStatus("Designer override cleared.");
        return true;
    }

    private bool SelectCategory(string name, bool suppressRender = false)
    {
        for (var i = 0; i < _categoryList.Items.Count; i++)
        {
            if (string.Equals(GetCategoryItemName(_categoryList.Items[i]), name, StringComparison.OrdinalIgnoreCase) ||
                string.Equals(_categoryList.Items[i]?.ToString(), name, StringComparison.OrdinalIgnoreCase))
            {
                if (suppressRender)
                {
                    _loadingCategories = true;
                    try
                    {
                        _categoryList.SelectedIndex = i;
                    }
                    finally
                    {
                        _loadingCategories = false;
                    }
                }
                else
                {
                    _categoryList.SelectedIndex = i;
                }

                return true;
            }
        }

        return false;
    }

    private static string? NullIfWhite(string value)
    {
        return string.IsNullOrWhiteSpace(value) ? null : value.Trim();
    }

    private static string FormatDesignerChoices(List<GuiChoiceMetadata> choices)
    {
        return string.Join(Environment.NewLine, choices.Select(choice =>
            string.IsNullOrWhiteSpace(choice.Literal) ? choice.Display : choice.Display + "=" + choice.Literal));
    }

    private static List<GuiChoiceMetadata> ParseDesignerChoices(string text)
    {
        var choices = new List<GuiChoiceMetadata>();
        foreach (var rawLine in text.Split(new[] { "\r\n", "\n" }, StringSplitOptions.None))
        {
            var line = rawLine.Trim();
            if (string.IsNullOrWhiteSpace(line))
            {
                continue;
            }

            var split = line.Split('=', 2);
            var display = split[0].Trim();
            var literal = split.Length > 1 ? split[1].Trim() : display;
            if (display.Length == 0)
            {
                continue;
            }

            choices.Add(new GuiChoiceMetadata { Display = display, Literal = literal });
        }

        return choices;
    }

    private void SetHelp(Control control, ConfigEntry entry)
    {
        var help = EntryDescription(entry);
        if (!string.IsNullOrWhiteSpace(help))
        {
            _toolTip.SetToolTip(control, help);
        }
    }

    private void ConfigureEditableHelpControl(Control control, string metadataKey, string title, string currentHelpText)
    {
        if (!_adminUnlocked || AppMode.IsExportedUserBuild || string.IsNullOrWhiteSpace(metadataKey))
        {
            return;
        }

        control.Cursor = Cursors.Hand;
        control.Click += (_, _) => EditHelpMetadata(metadataKey, title, currentHelpText);
    }

    private void SetChangedStatus(bool invalidateRenderedCategory = false)
    {
        // Normal editors refresh their own live control/grid. Pass true only when
        // the cached category cannot be updated directly and must rebuild later.
        if (invalidateRenderedCategory)
        {
            MarkRenderedCategoryPanelDirty();
        }

        if (HasChanges())
        {
            SetStatus("Changes are pending. Use Save to write the config.");
            UpdateEditActionButtonStates();
            return;
        }

        UpdateEditActionButtonStates();
        SetStatus(_undoStack.Count > 0 ? "No pending changes. Undo is still available." : "No pending changes.");
    }

    private void SetUndoAction(string description, Action action)
    {
        SetUndoAction(description, action, null);
    }

    private void SetUndoAction(string description, Action action, Action? refreshAction)
    {
        if (_restoringUndo)
        {
            return;
        }

        _undoStack.Push(new UndoStep(description, action, refreshAction));
        UpdateEditActionButtonStates();
    }

    private void SetEntryValueUndoAction(ConfigEntry entry, string description, string oldValue, string newValue, Action? refreshAction)
    {
        if (_restoringUndo)
        {
            return;
        }

        var collapseKey = "entry:" + entry.DisplayKey;
        if (_undoStack.Count > 0)
        {
            var top = _undoStack.Peek();
            if (top.CollapseGeneration == _undoCollapseGeneration &&
                string.Equals(top.CollapseKey, collapseKey, StringComparison.Ordinal) &&
                string.Equals(top.BeforeValue, newValue, StringComparison.Ordinal) &&
                string.Equals(top.AfterValue, oldValue, StringComparison.Ordinal))
            {
                _undoStack.Pop();
                UpdateEditActionButtonStates();
                return;
            }

            if (top.CollapseGeneration == _undoCollapseGeneration &&
                string.Equals(top.CollapseKey, collapseKey, StringComparison.Ordinal) &&
                string.Equals(top.AfterValue, oldValue, StringComparison.Ordinal) &&
                top.BeforeValue is not null)
            {
                _undoStack.Pop();
                oldValue = top.BeforeValue;
            }
        }

        var undoValue = oldValue;
        _undoStack.Push(new UndoStep(
            description,
            () => entry.ValueText = undoValue,
            refreshAction,
            collapseKey,
            undoValue,
            newValue,
            _undoCollapseGeneration));
        UpdateEditActionButtonStates();
    }

    private void ClearUndo()
    {
        _undoStack.Clear();
        UpdateEditActionButtonStates();
    }

    private void UndoLastChange()
    {
        if (_undoStack.Count == 0)
        {
            SetStatus("No editor change to undo.");
            return;
        }

        var step = _undoStack.Pop();

        try
        {
            _restoringUndo = true;
            step.Action();
            // Undo actions refresh the specific cached control/grid they changed.
            // Broad cache invalidation belongs in RefreshCurrentView callers.
            step.RefreshAction?.Invoke();
            var hasChanges = HasChanges();
            SetStatus(hasChanges
                ? "Undid " + step.Description + ". Use Save to write the config."
                : _undoStack.Count > 0
                    ? "Undid " + step.Description + ". No pending changes. Undo is still available."
                    : "Undid " + step.Description + ". No pending changes.");
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Undo failed", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
        finally
        {
            _restoringUndo = false;
            UpdateEditActionButtonStates();
        }
    }

    private static string HumanizeCategoryKey(string key)
    {
        var text = Regex.Replace(key, @"[_\.]+", " ");
        text = Regex.Replace(text, @"(?<=[a-z0-9])(?=[A-Z])", " ");
        return CultureInfo.InvariantCulture.TextInfo.ToTitleCase(text.ToLowerInvariant())
            .Replace("Csar", "CSAR", StringComparison.Ordinal)
            .Replace("Ctld", "CTLD", StringComparison.Ordinal)
            .Replace("Ewrs", "EWRS", StringComparison.Ordinal)
            .Replace("Aien", "AIEN", StringComparison.Ordinal);
    }

    private void RefreshGrid()
    {
        if (_document is null || _grid.Columns.Count == 0)
        {
            return;
        }

        var selectedKey = _activeEntry?.DisplayKey;
        _grid.Rows.Clear();

        var search = IsRawCategorySelected() ? _rawSearchBox.Text.Trim() : _searchBox.Text.Trim();
        var section = _sectionFilter.SelectedItem?.ToString();
        var entries = _document.Entries.AsEnumerable();

        if (!string.IsNullOrWhiteSpace(section) && section != "All sections")
        {
            entries = entries.Where(entry => entry.Section == section);
        }

        if (_changedOnly.Checked)
        {
            entries = entries.Where(entry => entry.IsChanged);
        }

        if (!IsRawCategorySelected() && !ShouldIncludeAdvancedEntries())
        {
            entries = entries.Where(entry => !entry.IsAdvanced);
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            entries = entries.Where(entry =>
                entry.DisplayKey.Contains(search, StringComparison.OrdinalIgnoreCase) ||
                entry.DisplayName.Contains(search, StringComparison.OrdinalIgnoreCase) ||
                entry.Section.Contains(search, StringComparison.OrdinalIgnoreCase) ||
                entry.EffectiveCategory.Contains(search, StringComparison.OrdinalIgnoreCase) ||
                entry.ValueText.Contains(search, StringComparison.OrdinalIgnoreCase) ||
                entry.FriendlyValueText.Contains(search, StringComparison.OrdinalIgnoreCase) ||
                EntryDescription(entry).Contains(search, StringComparison.OrdinalIgnoreCase));
        }

        foreach (var entry in entries)
        {
            var rowIndex = _grid.Rows.Add(entry.EffectiveCategory, entry.DisplayName, entry.FriendlyValueText, entry.TypeLabel, FirstLine(EntryDescription(entry)));
            var row = _grid.Rows[rowIndex];
            row.Tag = entry;
            if (entry.IsChanged)
            {
                row.DefaultCellStyle.BackColor = Color.FromArgb(255, 248, 214);
            }

            if (entry.DisplayKey == selectedKey)
            {
                row.Selected = true;
            }
        }

        if (_grid.SelectedRows.Count == 0 && _grid.Rows.Count > 0)
        {
            _grid.Rows[0].Selected = true;
        }

        SelectGridEntry();
    }

    private static string FirstLine(string text)
    {
        if (string.IsNullOrWhiteSpace(text))
        {
            return "";
        }

        return text.Split(new[] { "\r\n", "\n" }, StringSplitOptions.None)[0];
    }

    private static string EntryDescription(ConfigEntry entry)
    {
        return entry.EffectiveDescription;
    }

    private void SelectGridEntry()
    {
        if (_grid.SelectedRows.Count == 0)
        {
            _activeEntry = null;
            return;
        }

        if (_grid.SelectedRows[0].Tag is not ConfigEntry entry)
        {
            return;
        }

        _activeEntry = entry;
        _loadingEntry = true;
        _keyBox.Text = entry.DisplayName;
        _sectionBox.Text = entry.Section;
        _descriptionBox.Text = EntryDescription(entry);
        _valueBox.Text = entry.ValueText;

        HideValueEditors();

        if (entry.IsSideMultiplier && entry.TryGetSideMultipliers(out var red, out var blue))
        {
            _redMultiplier.Value = ClampMultiplier(red);
            _blueMultiplier.Value = ClampMultiplier(blue);
            UpdateMultiplierText();
            _multiplierPanel.Visible = true;
            _loadingEntry = false;
            return;
        }

        if (entry.TupleFields.Count > 0)
        {
            BuildTupleEditor(entry);
            _tuplePanel.Visible = true;
            _loadingEntry = false;
            return;
        }

        _choiceBox.Visible = entry.Choices.Count > 0;
        _boolBox.Visible = entry.Choices.Count == 0 && entry.Kind == ConfigValueKind.Boolean;
        _valueBox.Visible = !_choiceBox.Visible && !_boolBox.Visible;

        if (_choiceBox.Visible)
        {
            _choiceBox.Items.Clear();
            foreach (var choice in entry.Choices)
            {
                _choiceBox.Items.Add(choice.Display);
            }

            _choiceBox.Text = entry.ValueText;
        }

        if (_boolBox.Visible)
        {
            _boolBox.Checked = entry.ValueText.Equals("true", StringComparison.OrdinalIgnoreCase);
        }

        _loadingEntry = false;
    }

    private void HideValueEditors()
    {
        _valueBox.Visible = false;
        _choiceBox.Visible = false;
        _boolBox.Visible = false;
        _multiplierPanel.Visible = false;
        _tuplePanel.Visible = false;
    }

    private static decimal ClampMultiplier(decimal value)
    {
        if (value < 0.1m)
        {
            return 0.1m;
        }

        if (value > 5m)
        {
            return 5m;
        }

        return value;
    }

    private void UpdateMultiplierText()
    {
        _redMultiplierText.Text = DescribeMultiplier(_redMultiplier.Value);
        _blueMultiplierText.Text = DescribeMultiplier(_blueMultiplier.Value);
    }

    private static string DescribeMultiplier(decimal value)
    {
        if (value == 1m)
        {
            return "Normal spawn timer";
        }

        if (value > 1m)
        {
            return $"{Math.Round((value - 1m) * 100m)}% slower spawns";
        }

        return $"{Math.Round((1m - value) * 100m)}% faster spawns";
    }

    private void BuildTupleEditor(ConfigEntry entry)
    {
        _tupleControls.Clear();
        _tuplePanel.Controls.Clear();
        _tuplePanel.RowStyles.Clear();
        _tuplePanel.RowCount = entry.TupleFields.Count;

        var values = entry.GetTupleValues();
        for (var i = 0; i < entry.TupleFields.Count; i++)
        {
            var field = entry.TupleFields[i];
            var value = i < values.Count ? values[i] : "";
            _tuplePanel.RowStyles.Add(new RowStyle(SizeType.Absolute, 32));
            _tuplePanel.Controls.Add(MakeLabel(field.Name), 0, i);

            var control = BuildTupleControl(field, value);
            _tuplePanel.Controls.Add(control, 1, i);
            _tupleControls.Add((field, control));
        }
    }

    private static Control BuildTupleControl(ConfigTupleField field, string value)
    {
        switch (field.Kind)
        {
            case ConfigTupleFieldKind.Boolean:
                var checkBox = new CheckBox
                {
                    Dock = DockStyle.Fill,
                    Checked = value.Equals("true", StringComparison.OrdinalIgnoreCase)
                };
                return checkBox;

            case ConfigTupleFieldKind.Choice:
            var comboBox = new WheelSafeComboBox
                {
                    Dock = DockStyle.Fill,
                    DropDownStyle = ComboBoxStyle.DropDownList
                };
                foreach (var choice in field.Choices)
                {
                    comboBox.Items.Add(choice.Display);
                }

                comboBox.Text = FindChoiceDisplay(field, value);
                return comboBox;

            case ConfigTupleFieldKind.Number:
                var numeric = new WheelSafeNumericUpDown
                {
                    Dock = DockStyle.Fill,
                    DecimalPlaces = value.Contains('.', StringComparison.Ordinal) ? 2 : 0,
                    Minimum = -100000,
                    Maximum = 100000,
                    Increment = 1
                };
                if (decimal.TryParse(value, NumberStyles.Float, CultureInfo.InvariantCulture, out var decimalValue))
                {
                    numeric.Value = Math.Max(numeric.Minimum, Math.Min(numeric.Maximum, decimalValue));
                }

                return numeric;

            default:
                return new TextBox
                {
                    Dock = DockStyle.Fill,
                    Text = value
                };
        }
    }

    private static string FindChoiceDisplay(ConfigTupleField field, string value)
    {
        var choice = field.Choices.FirstOrDefault(choice =>
            choice.Literal.Equals(value, StringComparison.OrdinalIgnoreCase) ||
            choice.Display.Equals(value, StringComparison.OrdinalIgnoreCase));
        return choice?.Display ?? value;
    }

    private void ApplyChoiceChange()
    {
        if (_loadingEntry || !_choiceBox.Visible)
        {
            return;
        }

        _valueBox.Text = _choiceBox.Text;
    }

    private void ApplyBoolChange()
    {
        if (_loadingEntry || !_boolBox.Visible)
        {
            return;
        }

        _valueBox.Text = _boolBox.Checked ? "true" : "false";
    }

    private void ApplyEntryValue()
    {
        if (_activeEntry is null)
        {
            return;
        }

        var oldValue = _activeEntry.ValueText;
        if (_multiplierPanel.Visible)
        {
            _activeEntry.SetSideMultipliers(_redMultiplier.Value, _blueMultiplier.Value);
        }
        else if (_tuplePanel.Visible)
        {
            _activeEntry.SetTupleValues(ReadTupleEditorValues());
        }
        else
        {
            var newValue = _choiceBox.Visible
                ? _choiceBox.Text
                : _boolBox.Visible
                    ? (_boolBox.Checked ? "true" : "false")
                    : _valueBox.Text;
            _activeEntry.ValueText = newValue;
        }

        var error = _activeEntry.Validate();
        if (error is not null)
        {
            _activeEntry.ValueText = oldValue;
            MessageBox.Show(this, error, "Invalid value", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return;
        }

        if (!StringComparer.Ordinal.Equals(_activeEntry.ValueText, oldValue))
        {
            var entry = _activeEntry;
            SetUndoAction("edit " + entry.DisplayName, () => entry.ValueText = oldValue, () => RefreshCurrentView());
            RefreshLinkedStageEditors(entry);
        }

        RefreshGrid();
        SetStatus("Value applied in the editor. Use Save to write the config.");
    }

    private List<string> ReadTupleEditorValues()
    {
        var values = new List<string>();
        foreach (var (field, control) in _tupleControls)
        {
            values.Add(ReadTupleControlValue(field, control));
        }

        return values;
    }

    private static string ReadTupleControlValue(ConfigTupleField field, Control control)
    {
        return control switch
        {
            CheckBox checkBox => checkBox.Checked ? "true" : "false",
            ComboBox comboBox => FindChoiceLiteral(field, comboBox.Text),
            NumericUpDown numeric => numeric.Value.ToString(numeric.DecimalPlaces == 0 ? "0" : "0.##", CultureInfo.InvariantCulture),
            TextBox textBox => textBox.Text,
            _ => ""
        };
    }

    private static string FindChoiceLiteral(ConfigTupleField field, string display)
    {
        var choice = field.Choices.FirstOrDefault(choice =>
            choice.Display.Equals(display, StringComparison.OrdinalIgnoreCase) ||
            choice.Literal.Equals(display, StringComparison.OrdinalIgnoreCase));
        return choice?.Literal ?? display;
    }

    private void ResetEntryValue()
    {
        if (_activeEntry is null)
        {
            return;
        }

        var entry = _activeEntry;
        var oldValue = entry.ValueText;
        _activeEntry.ValueText = _activeEntry.OriginalValueText;
        if (!StringComparer.Ordinal.Equals(entry.ValueText, oldValue))
        {
            SetUndoAction("reset " + entry.DisplayName, () => entry.ValueText = oldValue, () => RefreshCurrentView());
            RefreshLinkedStageEditors(entry);
        }

        SelectGridEntry();
        RefreshGrid();
    }

    private void ValidateConfig()
    {
        if (_document is null)
        {
            return;
        }

        if (IsRawCategorySelected())
        {
            ApplyEntryValue();
        }

        var validatingDiskFile = !HasChanges();
        var document = validatingDiskFile
            ? ConfigDocument.Load(_document.Path)
            : _document;
        var errors = document.Validate();
        if (TryRepairStringListValidationIssues(document, validatingDiskFile, errors))
        {
            return;
        }

        if (errors.Count == 0)
        {
            var message = validatingDiskFile
                ? "The config file on disk passed the built-in checks."
                : "All editable values passed the built-in checks.";
            MessageBox.Show(this, message, "Validate", MessageBoxButtons.OK, MessageBoxIcon.Information);
            SetStatus("Validation passed.");
            return;
        }

        ShowValidationIssues("Validation issues", errors);
    }

    private bool TryRepairStringListValidationIssues(ConfigDocument document, bool validatingDiskFile, List<string> errors)
    {
        if (!HasStringListRepairIssue(errors))
        {
            return false;
        }

        var target = validatingDiskFile ? "the config file on disk" : "the loaded config";
        if (MessageBox.Show(
                this,
                "One or more config tables have a safe format issue, such as a missing comma, missing quote, broken comment marker, or simple keyed-row typo." + Environment.NewLine +
                "Repair this in " + target + "?",
                "Repair table format",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question) != DialogResult.Yes)
        {
            return false;
        }

        var repaired = document.RepairStringListSeparators();
        var repairedErrors = document.Validate();
        if (repaired == 0 || repairedErrors.Count > 0)
        {
            ShowValidationIssues("Validation issues", repairedErrors.Count > 0 ? repairedErrors : errors);
            return true;
        }

        if (validatingDiskFile)
        {
            document.SaveTo(document.Path);
            LoadConfig(document.Path);
            MessageBox.Show(this, "Repaired " + repaired.ToString(CultureInfo.InvariantCulture) + " table-format issue(s).", "Validate", MessageBoxButtons.OK, MessageBoxIcon.Information);
            SetStatus("Repaired table format and reloaded config.");
            return true;
        }

        RefreshCurrentView();
        SetStatus("Repaired " + repaired.ToString(CultureInfo.InvariantCulture) + " table-format issue(s). Use Save to write the config.");
        MessageBox.Show(this, "Repaired " + repaired.ToString(CultureInfo.InvariantCulture) + " table-format issue(s). Use Save to write the config.", "Validate", MessageBoxButtons.OK, MessageBoxIcon.Information);
        return true;
    }

    private static bool HasStringListRepairIssue(IEnumerable<string> errors)
    {
        return errors.Any(error =>
            error.Contains("missing comma", StringComparison.OrdinalIgnoreCase) ||
            error.Contains("missing opening quote after list separator", StringComparison.OrdinalIgnoreCase) ||
            error.Contains("missing closing quote before list separator", StringComparison.OrdinalIgnoreCase) ||
            error.Contains("duplicate comma", StringComparison.OrdinalIgnoreCase) ||
            error.Contains("broken comment marker", StringComparison.OrdinalIgnoreCase) ||
            error.Contains("smart quote", StringComparison.OrdinalIgnoreCase) ||
            error.Contains("missing '=' in keyed table row", StringComparison.OrdinalIgnoreCase) ||
            error.Contains("missing comma between keyed table rows", StringComparison.OrdinalIgnoreCase));
    }

    private void ShowValidationIssues(string title, IReadOnlyCollection<string> errors)
    {
        MessageBox.Show(this, string.Join(Environment.NewLine, errors.Take(20)), title, MessageBoxButtons.OK, MessageBoxIcon.Warning);
    }

    private void InstallConfigFromMiz()
    {
        using var dialog = new OpenFileDialog
        {
            Title = "Select updated Foothold mission MIZ",
            Filter = "DCS mission (*.miz)|*.miz|All files (*.*)|*.*",
            FileName = "*.miz",
            InitialDirectory = _document is null
                ? RuntimeSettings.GetBestInitialDirectory()
                : Path.GetDirectoryName(_document.Path)
        };

        if (dialog.ShowDialog(this) == DialogResult.OK)
        {
            InstallConfigFromMiz(dialog.FileName);
        }
    }

    private void InstallConfigFromMiz(string mizPath)
    {
        if (_document is null)
        {
            MessageBox.Show(this, "Open the current server Foothold Config.lua first, then import the updated MIZ config.", "Import MIZ Config", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

        if (IsRawCategorySelected())
        {
            ApplyEntryValue();
        }

        if (HasChanges())
        {
            MessageBox.Show(this, "Save or reload pending changes before importing a config from MIZ.", "Import MIZ Config", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

        var tempDir = Path.Combine(Path.GetTempPath(), "FootholdConfigManager-" + Guid.NewGuid().ToString("N"));
        try
        {
            Directory.CreateDirectory(tempDir);
            var extractedConfig = ExtractFootholdConfigFromMiz(mizPath, tempDir, GetCurrentConfigFileName(_document));
            var currentDocument = _document;
            var targetPath = Path.GetFileName(currentDocument.Path).Equals(extractedConfig.ConfigFileName, StringComparison.OrdinalIgnoreCase)
                ? currentDocument.Path
                : GetSiblingConfigPath(currentDocument.Path, extractedConfig.ConfigFileName);
            if (!PathsEqual(targetPath, currentDocument.Path) && File.Exists(targetPath))
            {
                currentDocument = ConfigDocument.Load(targetPath);
            }

            var newDocument = ConfigDocument.Load(extractedConfig.Path);
            newDocument.RepairStringListSeparators();
            if (!ValidateInstallMizDocument(newDocument, "The " + extractedConfig.ConfigFileName + " inside this MIZ"))
            {
                return;
            }

            RefreshStringListCatalogFromDefaults(newDocument);
            if (!PathsEqual(targetPath, currentDocument.Path) && !File.Exists(targetPath))
            {
                if (!ConfirmInstallMissingMizConfigVariant(extractedConfig.ConfigFileName, targetPath, currentDocument.Path, mizPath))
                {
                    return;
                }

                var targetDirectory = Path.GetDirectoryName(targetPath);
                if (string.IsNullOrWhiteSpace(targetDirectory))
                {
                    throw new InvalidOperationException("The target config path is invalid.");
                }

                Directory.CreateDirectory(targetDirectory);
                var installedDefaults = StoreMizDefaults(mizPath, extractedConfig);
                newDocument.SaveTo(targetPath);
                UpdateSelectedInstanceConfigPath(targetPath);
                LoadConfig(targetPath);
                SetStatus("Installed " + extractedConfig.ConfigFileName + " from MIZ. Stored defaults from " + installedDefaults.MizName + ".");
                return;
            }

            var preview = MergeCurrentConfigIntoNewConfig(currentDocument, newDocument);
            if (!ValidateInstallMizDocument(newDocument, "The merged MIZ config"))
            {
                return;
            }

            var previewText = BuildMizInstallPreviewText(mizPath, currentDocument.Path, preview);
            var valueChoices = preview.KeptValues
                .Select(item => new SelectableValueChoice(item.Key, item.CurrentValue, item.NewDefault, item.Entry.EffectiveDescription))
                .ToList();
            var tableChoices = BuildKeptTableChoices(preview, "current table text", "new MIZ table text");
            var choices = valueChoices.Concat(tableChoices).ToList();
            if (!ConfirmSelectableValuePreview(
                    previewText,
                    "Import MIZ Config Preview",
                    "Tick rows to keep your current values. Untick rows to use the new MIZ defaults.",
                    "Import",
                    "Your current value",
                    "New MIZ default",
                    "Keep your current values",
                    "Use new config value",
                    choices,
                    BuildMizInstallInfoTabs(preview)))
            {
                return;
            }

            ApplyKeptTableChoices(newDocument, preview, tableChoices);
            ApplyKeptValueChoices(newDocument, preview, valueChoices);

            if (!ValidateInstallMizDocument(newDocument, "The final imported MIZ config"))
            {
                return;
            }

            var importedNewMarkers = CaptureImportedNewMarkers(preview);
            var storedDefaults = StoreMizDefaults(mizPath, extractedConfig);
            newDocument.SaveTo(targetPath);
            UpdateSelectedInstanceConfigPath(targetPath);
            LoadConfig(targetPath);
            ApplyImportedNewMarkers(importedNewMarkers);
            SetStatus("Imported merged config from MIZ. Stored defaults from " + storedDefaults.MizName + ".");
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Import MIZ Config failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
        finally
        {
            try
            {
                if (Directory.Exists(tempDir))
                {
                    Directory.Delete(tempDir, recursive: true);
                }
            }
            catch
            {
                // Temporary cleanup failure should not hide the install result.
            }
        }
    }

    private bool InstallInitialConfigFromMiz(string mizPath, FirstRunInstanceCandidate instance)
    {
        var tempDir = Path.Combine(Path.GetTempPath(), "FootholdConfigManager-" + Guid.NewGuid().ToString("N"));
        try
        {
            Directory.CreateDirectory(tempDir);
            var extractedConfig = ExtractFootholdConfigFromMiz(mizPath, tempDir, null);
            var targetPath = Path.GetFullPath(instance.ConfigPathFor(extractedConfig.ConfigFileName));
            if (File.Exists(targetPath))
            {
                AddOrUpdateInstanceProfile(instance.Name, targetPath);
                LoadConfig(targetPath);
                MessageBox.Show(this, "A " + extractedConfig.ConfigFileName + " already exists at the selected target. It was opened and no file was overwritten.", "Install Foothold Config", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return true;
            }

            var newDocument = ConfigDocument.Load(extractedConfig.Path);
            newDocument.RepairStringListSeparators();
            if (!ValidateMergeDocument(newDocument, "Install Foothold Config validation failed", "The " + extractedConfig.ConfigFileName + " inside this MIZ"))
            {
                return false;
            }

            RefreshStringListCatalogFromDefaults(newDocument);
            var targetDirectory = Path.GetDirectoryName(targetPath);
            if (string.IsNullOrWhiteSpace(targetDirectory))
            {
                throw new InvalidOperationException("The selected install target is invalid.");
            }

            Directory.CreateDirectory(targetDirectory);
            newDocument.SaveTo(targetPath);
            var storedDefaults = StoreMizDefaults(mizPath, extractedConfig);
            AddOrUpdateInstanceProfile(instance.Name, targetPath);
            LoadConfig(targetPath);
            SetStatus("Installed Foothold config from " + storedDefaults.MizName + " to " + instance.Name + ".");
            return true;
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Install Foothold Config failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return false;
        }
        finally
        {
            try
            {
                if (Directory.Exists(tempDir))
                {
                    Directory.Delete(tempDir, recursive: true);
                }
            }
            catch
            {
                // Temporary cleanup failure should not hide the install result.
            }
        }
    }

    private bool ConfirmInstallMissingMizConfigVariant(string configFileName, string targetPath, string currentPath, string mizPath)
    {
        var variantLabel = GetConfigVariantLabel(configFileName);
        var currentLabel = GetConfigVariantLabel(currentPath);
        var message =
            "This MIZ contains a " + variantLabel + " config, but this instance does not have one yet." +
            Environment.NewLine + Environment.NewLine +
            "Current instance config:" + Environment.NewLine +
            currentPath +
            Environment.NewLine + Environment.NewLine +
            "New config to create:" + Environment.NewLine +
            targetPath +
            Environment.NewLine + Environment.NewLine +
            "Install it from this MIZ and switch this instance from " + currentLabel + " to " + variantLabel + "?" +
            Environment.NewLine +
            Path.GetFileName(mizPath);

        return MessageBox.Show(this, message, "Install " + variantLabel + " Config", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes;
    }

    private bool ValidateInstallMizDocument(ConfigDocument document, string context)
    {
        return ValidateMergeDocument(document, "Import MIZ Config validation failed", context);
    }

    private bool ValidateMergeDocument(ConfigDocument document, string title, string context)
    {
        var errors = document.Validate();
        if (errors.Count == 0)
        {
            return true;
        }

        ShowValidationIssues(title, new[] { context + " has validation issues. No file was changed." }.Concat(errors.Take(20)).ToList());
        return false;
    }

    private ExtractedMizConfig ExtractFootholdConfigFromMiz(string mizPath, string tempDir, string? preferredConfigFileName)
    {
        using var archive = ZipFile.OpenRead(mizPath);
        var entries = archive.Entries
            .Where(item => IsSupportedConfigFileName(Path.GetFileName(item.FullName)))
            .OrderBy(item => item.FullName.Contains("l10n/DEFAULT", StringComparison.OrdinalIgnoreCase) ? 0 : 1)
            .ThenBy(item => item.FullName.Length)
            .ToList();
        var entry = SelectMizConfigEntry(mizPath, entries, preferredConfigFileName);
        if (entry is null)
        {
            throw new InvalidOperationException("Foothold Config.lua or Foothold Config WW2.lua was not found inside this MIZ.");
        }

        var configFileName = Path.GetFileName(entry.FullName);
        var targetPath = Path.Combine(tempDir, configFileName);
        using var input = entry.Open();
        using var output = File.Create(targetPath);
        input.CopyTo(output);
        return new ExtractedMizConfig(targetPath, configFileName);
    }

    private ZipArchiveEntry? SelectMizConfigEntry(string mizPath, List<ZipArchiveEntry> entries, string? preferredConfigFileName)
    {
        if (entries.Count == 0)
        {
            return null;
        }

        if (!string.IsNullOrWhiteSpace(preferredConfigFileName))
        {
            var preferred = entries.FirstOrDefault(item =>
                Path.GetFileName(item.FullName).Equals(preferredConfigFileName, StringComparison.OrdinalIgnoreCase));
            if (preferred is not null)
            {
                return preferred;
            }
        }

        var distinctNames = entries
            .Select(item => Path.GetFileName(item.FullName))
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();
        if (distinctNames.Count == 1)
        {
            return entries[0];
        }

        var selectedName = PromptForMizConfigFileName(mizPath, distinctNames);
        return string.IsNullOrWhiteSpace(selectedName)
            ? null
            : entries.FirstOrDefault(item => Path.GetFileName(item.FullName).Equals(selectedName, StringComparison.OrdinalIgnoreCase));
    }

    private string? PromptForMizConfigFileName(string mizPath, List<string> configFileNames)
    {
        using var dialog = new Form
        {
            Text = "Select MIZ Config",
            StartPosition = FormStartPosition.CenterParent,
            FormBorderStyle = FormBorderStyle.FixedDialog,
            MinimizeBox = false,
            MaximizeBox = false,
            ClientSize = new Size(620, 260),
            Font = Font,
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        };

        var panel = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            RowCount = 3,
            ColumnCount = 1,
            Padding = new Padding(16),
            BackColor = MainBackground
        };
        panel.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        panel.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 54));
        dialog.Controls.Add(panel);

        panel.Controls.Add(new Label
        {
            Dock = DockStyle.Top,
            AutoSize = true,
            MaximumSize = new Size(560, 0),
            Text = "This MIZ contains more than one Foothold config. Choose which one to use:" + Environment.NewLine +
                   Path.GetFileName(mizPath),
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        }, 0, 0);

        var list = new ListBox
        {
            Dock = DockStyle.Fill
        };
        foreach (var fileName in configFileNames)
        {
            list.Items.Add(GetConfigVariantLabel(fileName) + "  " + fileName);
        }
        list.SelectedIndex = 0;
        panel.Controls.Add(list, 0, 1);

        var buttons = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            FlowDirection = FlowDirection.RightToLeft,
            WrapContents = false,
            Padding = new Padding(0, 10, 0, 0),
            BackColor = MainBackground
        };
        var useButton = new Button { Text = "Use selected", DialogResult = DialogResult.OK };
        var cancelButton = new Button { Text = "Cancel", DialogResult = DialogResult.Cancel };
        SizeDialogButton(useButton);
        SizeDialogButton(cancelButton);
        buttons.Controls.Add(useButton);
        buttons.Controls.Add(cancelButton);
        panel.Controls.Add(buttons, 0, 2);

        dialog.AcceptButton = useButton;
        dialog.CancelButton = cancelButton;
        list.DoubleClick += (_, _) => dialog.DialogResult = DialogResult.OK;
        ApplyThemeToControl(dialog, restyleButtons: true);

        return dialog.ShowDialog(this) == DialogResult.OK && list.SelectedIndex >= 0
            ? configFileNames[list.SelectedIndex]
            : null;
    }

    private static StoredMizDefaultsInfo StoreMizDefaults(string mizPath, ExtractedMizConfig extractedConfig)
    {
        Directory.CreateDirectory(StoredDefaultsDirectory);
        var index = LoadStoredMizDefaultsIndex();
        var storedAt = DateTime.Now;
        var mizName = Path.GetFileName(mizPath);
        var fullMizPath = Path.GetFullPath(mizPath);
        var configFileName = IsSupportedConfigFileName(extractedConfig.ConfigFileName)
            ? extractedConfig.ConfigFileName
            : RuntimeSettings.DefaultConfigFileName;
        var id = storedAt.ToString("yyyyMMdd-HHmmss", CultureInfo.InvariantCulture) +
                 "-" + MakeSafeFileName(Path.GetFileNameWithoutExtension(mizName)) +
                 "-" + MakeSafeFileName(Path.GetFileNameWithoutExtension(configFileName));
        var configPath = Path.Combine(StoredDefaultsDirectory, id + ".lua");

        File.Copy(extractedConfig.Path, configPath, overwrite: true);
        var info = new StoredMizDefaultsInfo
        {
            Id = id,
            SourceKind = "miz",
            MizName = mizName,
            MizPath = fullMizPath,
            ConfigFileName = configFileName,
            ConfigPath = configPath,
            StoredAt = storedAt
        };

        var sourceKey = GetStoredDefaultsSourceKey(info);
        var replacedItems = index.Items
            .Where(item => GetStoredDefaultsSourceKey(item).Equals(sourceKey, StringComparison.OrdinalIgnoreCase))
            .ToList();
        foreach (var item in replacedItems)
        {
            if (!PathsEqual(item.ConfigPath, configPath))
            {
                TryDeleteOwnedStoredDefaultsConfig(item.ConfigPath);
            }
        }

        index.Items.RemoveAll(item => GetStoredDefaultsSourceKey(item).Equals(sourceKey, StringComparison.OrdinalIgnoreCase));
        index.Items.Insert(0, info);
        NormalizeStoredMizDefaultsIndex(index, deleteRemovedFiles: true);
        SaveStoredMizDefaultsIndex(index);
        return info;
    }

    private static StoredMizDefaultsInfo StoreConfigDefaults(string configPath)
    {
        Directory.CreateDirectory(StoredDefaultsDirectory);
        var index = LoadStoredMizDefaultsIndex();
        var fullConfigPath = Path.GetFullPath(configPath);
        var info = new StoredMizDefaultsInfo
        {
            Id = "config:" + fullConfigPath,
            SourceKind = "config",
            MizName = Path.GetFileName(fullConfigPath),
            MizPath = fullConfigPath,
            ConfigFileName = Path.GetFileName(fullConfigPath),
            ConfigPath = fullConfigPath,
            StoredAt = DateTime.Now
        };

        var sourceKey = GetStoredDefaultsSourceKey(info);
        index.Items.RemoveAll(item => GetStoredDefaultsSourceKey(item).Equals(sourceKey, StringComparison.OrdinalIgnoreCase));
        index.Items.Insert(0, info);
        NormalizeStoredMizDefaultsIndex(index, deleteRemovedFiles: true);
        SaveStoredMizDefaultsIndex(index);
        return info;
    }

    private static List<StoredMizDefaultsInfo> LoadStoredRestoreDefaultsSources()
    {
        var index = LoadStoredMizDefaultsIndex();
        if (NormalizeStoredMizDefaultsIndex(index, deleteRemovedFiles: true))
        {
            SaveStoredMizDefaultsIndex(index);
        }

        return index.Items.ToList();
    }

    private static bool NormalizeStoredMizDefaultsIndex(StoredMizDefaultsIndex index, bool deleteRemovedFiles)
    {
        var originalItems = index.Items.ToList();
        var keptItems = new List<StoredMizDefaultsInfo>();
        var removedItems = new List<StoredMizDefaultsInfo>();
        var seenKeys = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        foreach (var item in index.Items
                     .Where(item => !string.IsNullOrWhiteSpace(item.ConfigPath) && File.Exists(item.ConfigPath))
                     .OrderByDescending(item => item.StoredAt))
        {
            var key = GetStoredDefaultsSourceKey(item);
            if (string.IsNullOrWhiteSpace(key) || !seenKeys.Add(key))
            {
                removedItems.Add(item);
                continue;
            }

            if (keptItems.Count < 20)
            {
                keptItems.Add(item);
            }
            else
            {
                removedItems.Add(item);
            }
        }

        removedItems.AddRange(originalItems.Where(item => !keptItems.Contains(item) && !removedItems.Contains(item)));
        if (deleteRemovedFiles)
        {
            foreach (var item in removedItems)
            {
                TryDeleteOwnedStoredDefaultsConfig(item.ConfigPath);
            }
        }

        index.Items = keptItems;
        return originalItems.Count != keptItems.Count ||
               originalItems.Where((item, itemIndex) => itemIndex >= keptItems.Count || !ReferenceEquals(item, keptItems[itemIndex])).Any();
    }

    private static string GetStoredDefaultsSourceKey(StoredMizDefaultsInfo info)
    {
        var sourcePath = !string.IsNullOrWhiteSpace(info.MizPath)
            ? info.MizPath
            : info.ConfigPath;
        if (!string.IsNullOrWhiteSpace(sourcePath))
        {
            var configKey = info.SourceKind.Equals("miz", StringComparison.OrdinalIgnoreCase) &&
                            !string.IsNullOrWhiteSpace(info.ConfigFileName)
                ? "|config:" + info.ConfigFileName
                : "";
            try
            {
                return "path:" + Path.GetFullPath(sourcePath) + configKey;
            }
            catch
            {
                return "path:" + sourcePath + configKey;
            }
        }

        return "name:" + info.MizName;
    }

    private static bool PathsEqual(string left, string right)
    {
        if (string.IsNullOrWhiteSpace(left) || string.IsNullOrWhiteSpace(right))
        {
            return false;
        }

        try
        {
            return Path.GetFullPath(left).Equals(Path.GetFullPath(right), StringComparison.OrdinalIgnoreCase);
        }
        catch
        {
            return left.Equals(right, StringComparison.OrdinalIgnoreCase);
        }
    }

    private static void RemoveStoredMizDefaultsSource(StoredMizDefaultsInfo source)
    {
        var index = LoadStoredMizDefaultsIndex();
        var sourceKey = GetStoredDefaultsSourceKey(source);
        var removedItems = index.Items
            .Where(item =>
                item.Id.Equals(source.Id, StringComparison.OrdinalIgnoreCase) ||
                GetStoredDefaultsSourceKey(item).Equals(sourceKey, StringComparison.OrdinalIgnoreCase))
            .ToList();

        foreach (var item in removedItems)
        {
            TryDeleteOwnedStoredDefaultsConfig(item.ConfigPath);
        }

        index.Items.RemoveAll(item =>
            item.Id.Equals(source.Id, StringComparison.OrdinalIgnoreCase) ||
            GetStoredDefaultsSourceKey(item).Equals(sourceKey, StringComparison.OrdinalIgnoreCase));
        SaveStoredMizDefaultsIndex(index);
    }

    private static void TryDeleteOwnedStoredDefaultsConfig(string path)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(path) || !File.Exists(path))
            {
                return;
            }

            var storedRoot = Path.GetFullPath(StoredDefaultsDirectory)
                .TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar) + Path.DirectorySeparatorChar;
            var fullPath = Path.GetFullPath(path);
            if (fullPath.StartsWith(storedRoot, StringComparison.OrdinalIgnoreCase))
            {
                File.Delete(fullPath);
            }
        }
        catch
        {
            // Best-effort cleanup only; the original MIZ/config source is never deleted here.
        }
    }

    private static StoredMizDefaultsIndex LoadStoredMizDefaultsIndex()
    {
        if (!File.Exists(StoredDefaultsIndexPath))
        {
            return new StoredMizDefaultsIndex();
        }

        try
        {
            var index = JsonSerializer.Deserialize<StoredMizDefaultsIndex>(File.ReadAllText(StoredDefaultsIndexPath), StoredDefaultsJsonOptions)
                        ?? new StoredMizDefaultsIndex();
            index.Items ??= new List<StoredMizDefaultsInfo>();
            foreach (var item in index.Items.Where(item => string.IsNullOrWhiteSpace(item.SourceKind)))
            {
                item.SourceKind = "miz";
            }
            foreach (var item in index.Items.Where(item => string.IsNullOrWhiteSpace(item.ConfigFileName)))
            {
                item.ConfigFileName = IsSupportedConfigFileName(Path.GetFileName(item.ConfigPath))
                    ? Path.GetFileName(item.ConfigPath)
                    : RuntimeSettings.DefaultConfigFileName;
            }

            return index;
        }
        catch
        {
            return new StoredMizDefaultsIndex();
        }
    }

    private static void SaveStoredMizDefaultsIndex(StoredMizDefaultsIndex index)
    {
        Directory.CreateDirectory(StoredDefaultsDirectory);
        File.WriteAllText(StoredDefaultsIndexPath, JsonSerializer.Serialize(index, StoredDefaultsJsonOptions));
    }

    private static string MakeSafeFileName(string text)
    {
        var invalid = Path.GetInvalidFileNameChars().ToHashSet();
        var safe = new string(text.Select(ch => invalid.Contains(ch) ? '_' : ch).ToArray()).Trim();
        if (string.IsNullOrWhiteSpace(safe))
        {
            safe = "MIZ";
        }

        return safe.Length <= 80 ? safe : safe[..80];
    }

    private StoredMizDefaultsInfo? CreateRestoreDefaultsSourceFromFile(string path)
    {
        var fullPath = Path.GetFullPath(path);
        if (Path.GetExtension(fullPath).Equals(".miz", StringComparison.OrdinalIgnoreCase))
        {
            var tempDir = Path.Combine(Path.GetTempPath(), "FootholdConfigDefaults-" + Guid.NewGuid().ToString("N"));
            try
            {
                Directory.CreateDirectory(tempDir);
                var extractedConfig = ExtractFootholdConfigFromMiz(fullPath, tempDir, GetCurrentConfigFileName(_document));
                var defaultDocument = ConfigDocument.Load(extractedConfig.Path);
                defaultDocument.RepairStringListSeparators();
                if (!ValidateMergeDocument(defaultDocument, "Restore Defaults validation failed", "The selected MIZ defaults"))
                {
                    return null;
                }

                return StoreMizDefaults(fullPath, extractedConfig);
            }
            finally
            {
                try
                {
                    if (Directory.Exists(tempDir))
                    {
                        Directory.Delete(tempDir, recursive: true);
                    }
                }
                catch
                {
                    // Temporary cleanup failure should not hide the selected source result.
                }
            }
        }

        var configDocument = ConfigDocument.Load(fullPath);
        configDocument.RepairStringListSeparators();
        if (!ValidateMergeDocument(configDocument, "Restore Defaults validation failed", "The selected config defaults"))
        {
            return null;
        }

        return StoreConfigDefaults(fullPath);
    }

    private void RestoreConfigDefaults()
    {
        if (_document is null)
        {
            MessageBox.Show(this, "Open the current Foothold Config.lua first.", "Restore Defaults", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

        if (IsRawCategorySelected())
        {
            ApplyEntryValue();
        }

        if (HasChanges())
        {
            MessageBox.Show(this, "Save or reload pending changes before restoring config defaults.", "Restore Defaults", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

        var defaults = LoadStoredRestoreDefaultsSources();

        var selection = PromptForRestoreDefaultsSelection(defaults, _document);
        if (selection is null)
        {
            return;
        }

        try
        {
            ApplyRestoreDefaultsSelection(_document, selection);
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Restore Defaults failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private void ApplyRestoreDefaultsSelection(ConfigDocument currentDocument, RestoreDefaultsSelection selection)
    {
        var defaultDocument = ConfigDocument.Load(selection.Defaults.ConfigPath);
        defaultDocument.RepairStringListSeparators();
        if (!ValidateMergeDocument(defaultDocument, "Restore Defaults validation failed", "The selected defaults source"))
        {
            return;
        }

        RefreshStringListCatalogFromDefaults(defaultDocument);
        var outputDocument = ConfigDocument.Load(currentDocument.Path);
        foreach (var item in selection.SelectedItems)
        {
            ApplyDefaultRestoreItem(outputDocument, defaultDocument, item);
        }

        if (!ValidateMergeDocument(outputDocument, "Restore Defaults validation failed", "The final Restore Defaults config"))
        {
            return;
        }

        outputDocument.SaveTo(currentDocument.Path);
        LoadConfig(currentDocument.Path);
        SetStatus(
            "Restored " +
            selection.SelectedItems.Count.ToString(CultureInfo.InvariantCulture) +
            " default item(s) from " +
            FormatRestoreDefaultsSourceName(selection.Defaults) +
            ".");
    }

    private static void ApplyDefaultRestoreItem(ConfigDocument outputDocument, ConfigDocument defaultDocument, RestoreDefaultItem item)
    {
        if (item.Kind == CopyChangeKind.Entry)
        {
            var defaultEntry = defaultDocument.Entries.FirstOrDefault(entry => entry.DisplayKey.Equals(item.Key, StringComparison.Ordinal));
            var outputEntry = outputDocument.Entries.FirstOrDefault(entry => entry.DisplayKey.Equals(item.Key, StringComparison.Ordinal));
            if (defaultEntry is null)
            {
                return;
            }

            if (outputEntry is null)
            {
                throw new InvalidOperationException(item.Label + " is not in the current config. Use Import MIZ Config first if you need to add new config options.");
            }

            outputEntry.ValueText = defaultEntry.ValueText;
            return;
        }

        if (!outputDocument.ReplaceTableBlockFrom(defaultDocument, item.Key))
        {
            throw new InvalidOperationException(item.Label + " is not in the current config. Use Import MIZ Config first if you need to add new config tables.");
        }
    }

    private RestoreDefaultsSelection? PromptForRestoreDefaultsSelection(List<StoredMizDefaultsInfo> defaults, ConfigDocument currentDocument)
    {
        using var dialog = new Form
        {
            Text = "Restore Config Defaults",
            StartPosition = FormStartPosition.CenterParent,
            FormBorderStyle = FormBorderStyle.Sizable,
            MinimizeBox = false,
            MaximizeBox = true,
            ClientSize = new Size(Zoomed(900), Zoomed(620)),
            MinimumSize = new Size(Zoomed(760), Zoomed(500)),
            Font = Font,
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        };

        var panel = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            RowCount = 4,
            ColumnCount = 1,
            Padding = new Padding(Zoomed(12)),
            BackColor = MainBackground
        };
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(34)));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(38)));
        panel.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(58)));
        dialog.Controls.Add(panel);

        panel.Controls.Add(new Label
        {
            Text = "Select a defaults source, then choose the categories or entries to restore. Changed entries are selected by default.",
            Dock = DockStyle.Fill,
            TextAlign = ContentAlignment.MiddleLeft,
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        }, 0, 0);

        var sourceRow = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            RowCount = 1,
            ColumnCount = 4,
            BackColor = MainBackground,
            Margin = new Padding(0)
        };
        sourceRow.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, Zoomed(110)));
        sourceRow.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        sourceRow.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        sourceRow.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        sourceRow.Controls.Add(new Label
        {
            Text = "Default source",
            Dock = DockStyle.Fill,
            TextAlign = ContentAlignment.MiddleLeft,
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        }, 0, 0);
        var sourceBox = new ComboBox
        {
            Dock = DockStyle.Fill,
            DropDownStyle = ComboBoxStyle.DropDownList
        };
        StyleInput(sourceBox);
        sourceRow.Controls.Add(sourceBox, 1, 0);
        var browseSourceButton = new Button { Text = "Browse..." };
        var removeSourceButton = new Button { Text = "Remove", Enabled = false };
        SizeDialogButton(browseSourceButton, 90);
        SizeDialogButton(removeSourceButton, 90);
        sourceRow.Controls.Add(browseSourceButton, 2, 0);
        sourceRow.Controls.Add(removeSourceButton, 3, 0);
        panel.Controls.Add(sourceRow, 0, 1);

        var tree = new TreeView
        {
            Dock = DockStyle.Fill,
            CheckBoxes = true,
            HideSelection = false,
            BackColor = EditorBackground,
            ForeColor = PrimaryTextColor,
            BorderStyle = BorderStyle.FixedSingle
        };
        panel.Controls.Add(tree, 0, 2);

        var bottom = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            RowCount = 1,
            ColumnCount = 2,
            BackColor = MainBackground,
            Margin = new Padding(0),
            Padding = new Padding(0, Zoomed(8), 0, 0)
        };
        bottom.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        bottom.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        var status = new Label
        {
            Dock = DockStyle.Fill,
            TextAlign = ContentAlignment.MiddleLeft,
            BackColor = MainBackground,
            ForeColor = HelpTextColor
        };
        bottom.Controls.Add(status, 0, 0);
        var buttons = new FlowLayoutPanel
        {
            AutoSize = true,
            Dock = DockStyle.Fill,
            FlowDirection = FlowDirection.RightToLeft,
            WrapContents = false,
            BackColor = MainBackground
        };
        var restoreButton = new Button { Text = "Restore Selected", DialogResult = DialogResult.OK, Enabled = false };
        var cancelButton = new Button { Text = "Cancel", DialogResult = DialogResult.Cancel };
        var tickChangedButton = new Button { Text = "Tick changed only", Enabled = false };
        var untickAllButton = new Button { Text = "Untick all" };
        var tickAllButton = new Button { Text = "Tick all" };
        SizeDialogButton(restoreButton, 150);
        SizeDialogButton(cancelButton);
        SizeDialogButton(tickChangedButton, 150);
        SizeDialogButton(untickAllButton, 110);
        SizeDialogButton(tickAllButton, 96);
        buttons.Controls.Add(restoreButton);
        buttons.Controls.Add(cancelButton);
        buttons.Controls.Add(tickChangedButton);
        buttons.Controls.Add(untickAllButton);
        buttons.Controls.Add(tickAllButton);
        bottom.Controls.Add(buttons, 1, 0);
        panel.Controls.Add(bottom, 0, 3);

        var sources = defaults.ToList();
        var changingChecks = false;
        var refreshingSources = false;

        StoredMizDefaultsInfo? GetSelectedSource()
        {
            return sourceBox.SelectedIndex >= 0 && sourceBox.SelectedIndex < sources.Count
                ? sources[sourceBox.SelectedIndex]
                : null;
        }

        void RefreshSourceBox(string? selectedId = null)
        {
            refreshingSources = true;
            sourceBox.BeginUpdate();
            try
            {
                sourceBox.Items.Clear();
                foreach (var item in sources)
                {
                    sourceBox.Items.Add(FormatStoredMizDefaults(item));
                }

                sourceBox.DropDownWidth = GetComboBoxDropDownWidth(sourceBox);

                if (sources.Count == 0)
                {
                    sourceBox.SelectedIndex = -1;
                }
                else if (!string.IsNullOrWhiteSpace(selectedId))
                {
                    var selectedIndex = sources.FindIndex(item => item.Id.Equals(selectedId, StringComparison.OrdinalIgnoreCase));
                    sourceBox.SelectedIndex = selectedIndex >= 0 ? selectedIndex : 0;
                }
                else
                {
                    sourceBox.SelectedIndex = 0;
                }
            }
            finally
            {
                sourceBox.EndUpdate();
                refreshingSources = false;
            }

            removeSourceButton.Enabled = GetSelectedSource() is not null;
            LoadSelectedDefaults();
        }

        List<RestoreDefaultItem> GetSelectedItems()
        {
            return tree.Nodes
                .Cast<TreeNode>()
                .SelectMany(GetCheckedRestoreItems)
                .ToList();
        }

        void UpdateSelectionStatus()
        {
            var count = GetSelectedItems().Count;
            restoreButton.Enabled = count > 0;
            status.Text = count == 0
                ? "No defaults selected."
                : count.ToString(CultureInfo.InvariantCulture) + " default item(s) selected.";
        }

        void LoadSelectedDefaults()
        {
            tree.BeginUpdate();
            try
            {
                tree.Nodes.Clear();
                var selectedSource = GetSelectedSource();
                removeSourceButton.Enabled = selectedSource is not null;
                if (selectedSource is null)
                {
                    status.Text = "Choose a Foothold Config.lua or MIZ defaults source.";
                    restoreButton.Enabled = false;
                    tickChangedButton.Enabled = false;
                    return;
                }

                var defaultDocument = ConfigDocument.Load(selectedSource.ConfigPath);
                defaultDocument.RepairStringListSeparators();
                var errors = defaultDocument.Validate();
                if (errors.Count > 0)
                {
                    status.Text = "Defaults source failed validation: " + errors[0];
                    restoreButton.Enabled = false;
                    tickChangedButton.Enabled = false;
                    return;
                }

                var currentItems = BuildRestoreDefaultItems(currentDocument, defaultDocument);
                tickChangedButton.Enabled = currentItems.Any(item => item.IsChanged);
                changingChecks = true;
                try
                {
                    PopulateRestoreDefaultsTree(tree, currentItems);
                }
                finally
                {
                    changingChecks = false;
                }

                UpdateSelectionStatus();
            }
            catch (Exception ex)
            {
                tree.Nodes.Clear();
                status.Text = "Could not load defaults source: " + ex.Message;
                restoreButton.Enabled = false;
                tickChangedButton.Enabled = false;
            }
            finally
            {
                tree.EndUpdate();
            }
        }

        tree.AfterCheck += (_, args) =>
        {
            if (changingChecks || args.Node is null)
            {
                return;
            }

            changingChecks = true;
            try
            {
                if (args.Node.Tag is RestoreDefaultItem)
                {
                    UpdateRestoreCategoryCheck(args.Node.Parent);
                }
                else
                {
                    foreach (TreeNode child in args.Node.Nodes)
                    {
                        child.Checked = args.Node.Checked;
                    }
                }
            }
            finally
            {
                changingChecks = false;
            }

            UpdateSelectionStatus();
        };

        tickAllButton.Click += (_, _) =>
        {
            changingChecks = true;
            try
            {
                foreach (TreeNode node in tree.Nodes)
                {
                    SetRestoreNodeChecked(node, true);
                }
            }
            finally
            {
                changingChecks = false;
            }

            UpdateSelectionStatus();
        };

        untickAllButton.Click += (_, _) =>
        {
            changingChecks = true;
            try
            {
                foreach (TreeNode node in tree.Nodes)
                {
                    SetRestoreNodeChecked(node, false);
                }
            }
            finally
            {
                changingChecks = false;
            }

            UpdateSelectionStatus();
        };

        tickChangedButton.Click += (_, _) =>
        {
            changingChecks = true;
            try
            {
                foreach (TreeNode category in tree.Nodes)
                {
                    foreach (TreeNode child in category.Nodes)
                    {
                        child.Checked = child.Tag is RestoreDefaultItem item && item.IsChanged;
                    }

                    UpdateRestoreCategoryCheck(category);
                }
            }
            finally
            {
                changingChecks = false;
            }

            UpdateSelectionStatus();
        };

        browseSourceButton.Click += (_, _) =>
        {
            using var fileDialog = new OpenFileDialog
            {
                Title = "Select restore defaults source",
                Filter = "Foothold config or MIZ (*.lua;*.miz)|*.lua;*.miz|Lua config (*.lua)|*.lua|DCS mission (*.miz)|*.miz|All files (*.*)|*.*",
                FileName = GetCurrentConfigFileName(currentDocument),
                InitialDirectory = Path.GetDirectoryName(currentDocument.Path)
            };

            if (fileDialog.ShowDialog(dialog) != DialogResult.OK)
            {
                return;
            }

            try
            {
                var source = CreateRestoreDefaultsSourceFromFile(fileDialog.FileName);
                if (source is null)
                {
                    return;
                }

                sources = LoadStoredRestoreDefaultsSources();
                RefreshSourceBox(source.Id);
            }
            catch (Exception ex)
            {
                MessageBox.Show(dialog, ex.Message, "Select Defaults Source failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        };

        removeSourceButton.Click += (_, _) =>
        {
            var selectedSource = GetSelectedSource();
            if (selectedSource is null)
            {
                return;
            }

            if (MessageBox.Show(
                    dialog,
                    "Remove this defaults source from the list?" + Environment.NewLine +
                    "The original MIZ/config file will not be deleted.",
                    "Remove Defaults Source",
                    MessageBoxButtons.YesNo,
                    MessageBoxIcon.Question) != DialogResult.Yes)
            {
                return;
            }

            var selectedIndex = sourceBox.SelectedIndex;
            RemoveStoredMizDefaultsSource(selectedSource);
            sources = LoadStoredRestoreDefaultsSources();

            var nextSelectedId = selectedIndex >= 0 && selectedIndex < sources.Count
                ? sources[selectedIndex].Id
                : sources.LastOrDefault()?.Id;
            RefreshSourceBox(nextSelectedId);
        };

        sourceBox.SelectedIndexChanged += (_, _) =>
        {
            if (!refreshingSources)
            {
                LoadSelectedDefaults();
            }
        };
        RefreshSourceBox();

        ApplyDialogChrome(dialog);
        dialog.AcceptButton = restoreButton;
        dialog.CancelButton = cancelButton;
        if (dialog.ShowDialog(this) != DialogResult.OK)
        {
            return null;
        }

        var finalSource = GetSelectedSource();
        if (finalSource is null)
        {
            return null;
        }

        var selectedItems = GetSelectedItems();
        return selectedItems.Count == 0
            ? null
            : new RestoreDefaultsSelection(finalSource, selectedItems);
    }

    private List<RestoreDefaultItem> BuildRestoreDefaultItems(ConfigDocument currentDocument, ConfigDocument defaultDocument)
    {
        var items = new List<RestoreDefaultItem>();
        var tableKeys = new HashSet<string>(StringComparer.Ordinal);

        foreach (var table in defaultDocument.StringListTables)
        {
            AddRestoreTableItem(currentDocument, defaultDocument, table.Key, table.GuiLabel ?? defaultDocument.GetGuiLabel(table.Key) ?? GetDefaultGroupLabel(table.Key), table.Section, table.StartLineIndex, items);
            tableKeys.Add(table.Key);
        }

        foreach (var table in defaultDocument.StageTables)
        {
            AddRestoreTableItem(currentDocument, defaultDocument, table.Key, table.GuiLabel ?? defaultDocument.GetGuiLabel(table.Key) ?? GetDefaultGroupLabel(table.Key), table.Section, table.StartLineIndex, items);
            tableKeys.Add(table.Key);
        }

        foreach (var group in defaultDocument.Entries
                     .Where(entry => !string.IsNullOrWhiteSpace(entry.ParentKey))
                     .GroupBy(entry => GetCopyTableRootKey(entry.ParentKey), StringComparer.Ordinal))
        {
            if (tableKeys.Contains(group.Key))
            {
                continue;
            }

            var first = group.OrderBy(entry => entry.LineIndex).First();
            AddRestoreTableItem(currentDocument, defaultDocument, group.Key, defaultDocument.GetGuiLabel(group.Key) ?? GetDefaultGroupLabel(group.Key), first.EffectiveCategory, first.LineIndex, items);
            tableKeys.Add(group.Key);
        }

        foreach (var defaultEntry in defaultDocument.Entries
                     .Where(entry => string.IsNullOrWhiteSpace(entry.ParentKey)))
        {
            var currentEntry = currentDocument.Entries.FirstOrDefault(entry => entry.DisplayKey.Equals(defaultEntry.DisplayKey, StringComparison.Ordinal));
            var isChanged = currentEntry is null || !StringComparer.Ordinal.Equals(currentEntry.ValueText, defaultEntry.ValueText);
            var summary = currentEntry is null
                ? "not in current config"
                : isChanged
                    ? PreviewCopyValue(currentEntry.ValueText) + " -> " + PreviewCopyValue(defaultEntry.ValueText)
                    : "already matches";
            items.Add(new RestoreDefaultItem(
                CopyChangeKind.Entry,
                defaultEntry.DisplayKey,
                defaultEntry.DisplayName,
                defaultEntry.EffectiveCategory,
                summary,
                defaultEntry.LineIndex,
                isChanged));
        }

        return items
            .OrderBy(item => item.Order)
            .ThenBy(item => item.Label, StringComparer.OrdinalIgnoreCase)
            .ToList();
    }

    private static void AddRestoreTableItem(
        ConfigDocument currentDocument,
        ConfigDocument defaultDocument,
        string key,
        string label,
        string category,
        int order,
        List<RestoreDefaultItem> items)
    {
        if (!defaultDocument.TryGetTableBlockText(key, out var defaultText))
        {
            return;
        }

        var currentHasTable = currentDocument.TryGetTableBlockText(key, out var currentText);
        var isChanged = !currentHasTable || !NormalizeCopyText(defaultText).Equals(NormalizeCopyText(currentText), StringComparison.Ordinal);
        var summary = currentHasTable
            ? isChanged ? "table changed" : "already matches"
            : "not in current config";
        items.Add(new RestoreDefaultItem(CopyChangeKind.Table, key, label, category, summary, order, isChanged));
    }

    private void PopulateRestoreDefaultsTree(TreeView tree, IReadOnlyList<RestoreDefaultItem> items)
    {
        foreach (var group in items
                     .GroupBy(item => item.Category, StringComparer.OrdinalIgnoreCase)
                     .OrderBy(group => group.Min(item => item.Order)))
        {
            var categoryName = string.IsNullOrWhiteSpace(group.Key) ? "Uncategorized" : group.Key;
            var category = new TreeNode(GetCategoryDisplayName(categoryName));
            var hasChangedItems = false;
            foreach (var item in group.OrderBy(item => item.Order).ThenBy(item => item.Label, StringComparer.OrdinalIgnoreCase))
            {
                hasChangedItems |= item.IsChanged;
                var suffix = item.IsChanged ? "  -  " + item.Summary : "  -  already matches";
                category.Nodes.Add(new TreeNode(item.Label + suffix)
                {
                    Tag = item,
                    Checked = item.IsChanged
                });
            }

            UpdateRestoreCategoryCheck(category);
            tree.Nodes.Add(category);
            if (hasChangedItems)
            {
                category.Expand();
            }
        }
    }

    private static IEnumerable<RestoreDefaultItem> GetCheckedRestoreItems(TreeNode node)
    {
        foreach (TreeNode child in node.Nodes)
        {
            if (child.Tag is RestoreDefaultItem item && child.Checked)
            {
                yield return item;
            }

            foreach (var nested in GetCheckedRestoreItems(child))
            {
                yield return nested;
            }
        }
    }

    private static void SetRestoreNodeChecked(TreeNode node, bool isChecked)
    {
        node.Checked = isChecked;
        foreach (TreeNode child in node.Nodes)
        {
            SetRestoreNodeChecked(child, isChecked);
        }
    }

    private static void UpdateRestoreCategoryCheck(TreeNode? category)
    {
        if (category is null || category.Tag is RestoreDefaultItem)
        {
            return;
        }

        category.Checked = category.Nodes.Count > 0 && category.Nodes.Cast<TreeNode>().All(node => node.Checked);
    }

    private StoredMizDefaultsInfo? PromptForStoredMizDefaults(List<StoredMizDefaultsInfo> defaults)
    {
        using var dialog = new Form
        {
            Text = "Restore Config Defaults",
            StartPosition = FormStartPosition.CenterParent,
            FormBorderStyle = FormBorderStyle.FixedDialog,
            MinimizeBox = false,
            MaximizeBox = false,
            ClientSize = new Size(Zoomed(760), Zoomed(360)),
            Font = Font,
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        };

        var panel = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            RowCount = 3,
            ColumnCount = 1,
            Padding = new Padding(Zoomed(10)),
            BackColor = MainBackground
        };
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(42)));
        panel.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(54)));
        dialog.Controls.Add(panel);

        panel.Controls.Add(new Label
        {
            Text = "Select stored MIZ defaults to restore from.",
            Dock = DockStyle.Fill,
            TextAlign = ContentAlignment.MiddleLeft,
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        }, 0, 0);

        var list = new ListBox
        {
            Dock = DockStyle.Fill,
            HorizontalScrollbar = true
        };
        StyleInput(list);
        foreach (var item in defaults)
        {
            list.Items.Add(FormatStoredMizDefaults(item));
        }

        if (list.Items.Count > 0)
        {
            list.SelectedIndex = 0;
        }

        panel.Controls.Add(list, 0, 1);

        var buttons = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            FlowDirection = FlowDirection.RightToLeft,
            WrapContents = false,
            Padding = new Padding(0, Zoomed(8), 0, 0),
            BackColor = MainBackground
        };
        var restoreButton = new Button { Text = "Restore", DialogResult = DialogResult.OK };
        var cancelButton = new Button { Text = "Cancel", DialogResult = DialogResult.Cancel };
        SizeDialogButton(restoreButton);
        SizeDialogButton(cancelButton);
        buttons.Controls.Add(restoreButton);
        buttons.Controls.Add(cancelButton);
        panel.Controls.Add(buttons, 0, 2);

        ApplyDialogChrome(dialog);
        dialog.AcceptButton = restoreButton;
        dialog.CancelButton = cancelButton;
        list.DoubleClick += (_, _) => dialog.DialogResult = DialogResult.OK;
        if (dialog.ShowDialog(this) != DialogResult.OK || list.SelectedIndex < 0)
        {
            return null;
        }

        return defaults[list.SelectedIndex];
    }

    private static string FormatStoredMizDefaults(StoredMizDefaultsInfo info)
    {
        var configName = !string.IsNullOrWhiteSpace(info.ConfigFileName) && IsSupportedConfigFileName(info.ConfigFileName)
            ? " - " + GetConfigVariantLabel(info.ConfigFileName)
            : "";
        var suffix = info.SourceKind.Equals("config", StringComparison.OrdinalIgnoreCase)
            ? "  (config file" + configName + ")"
            : "  (MIZ" + configName + ")";
        return FormatRestoreDefaultsSourceName(info) + suffix;
    }

    private static string FormatRestoreDefaultsSourceName(StoredMizDefaultsInfo info)
    {
        var sourcePath = !string.IsNullOrWhiteSpace(info.MizPath)
            ? info.MizPath
            : info.ConfigPath;
        if (!string.IsNullOrWhiteSpace(sourcePath))
        {
            return sourcePath;
        }

        if (!string.IsNullOrWhiteSpace(info.MizName))
        {
            return info.MizName;
        }

        return "selected source";
    }

    private const string InstallPolicyKeepTable = "keepTable";
    private const string InstallPolicyMergeRows = "mergeRows";
    private const string InstallPolicyReplaceTable = "replaceTable";

    private MizMergePreview MergeCurrentConfigIntoNewConfig(ConfigDocument currentDocument, ConfigDocument newDocument)
    {
        var preview = new MizMergePreview();
        ApplyStringListInstallPolicies(currentDocument, newDocument, preview);

        var currentByKey = currentDocument.Entries
            .GroupBy(entry => entry.DisplayKey, StringComparer.Ordinal)
            .ToDictionary(group => group.Key, group => group.First(), StringComparer.Ordinal);
        var newKeys = newDocument.Entries
            .Select(entry => entry.DisplayKey)
            .ToHashSet(StringComparer.Ordinal);
        var newTopLevelByKey = newDocument.Entries
            .Where(entry => string.IsNullOrWhiteSpace(entry.ParentKey))
            .GroupBy(entry => entry.Key, StringComparer.Ordinal)
            .ToDictionary(group => group.Key, group => group.First(), StringComparer.Ordinal);

        foreach (var newEntry in newDocument.Entries)
        {
            if (!currentByKey.TryGetValue(newEntry.DisplayKey, out var currentEntry))
            {
                preview.NewEntries.Add(newEntry);
                continue;
            }

            if (string.Equals(newEntry.ValueText, currentEntry.ValueText, StringComparison.Ordinal))
            {
                preview.UnchangedCount++;
                continue;
            }

            preview.KeptValues.Add(new MizKeptValue(newEntry, currentEntry.ValueText, newEntry.ValueText));
            newEntry.ValueText = currentEntry.ValueText;
        }

        foreach (var currentEntry in currentDocument.Entries.Where(entry => !newKeys.Contains(entry.DisplayKey)))
        {
            if (TryMigrateMisplacedTopLevelValue(currentByKey, newTopLevelByKey, currentEntry, preview))
            {
                continue;
            }

            if (TryPreserveSimpleTableRow(newDocument, currentEntry, newTopLevelByKey))
            {
                preview.PreservedTableRows.Add((currentEntry.DisplayKey, currentEntry.ValueText));
                continue;
            }

            preview.SkippedOldValues.Add((currentEntry.DisplayKey, currentEntry.ValueText));
        }

        PreserveStringListItems(currentDocument, newDocument, preview);
        return preview;
    }

    private static void ApplyStringListInstallPolicies(
        ConfigDocument currentDocument,
        ConfigDocument newDocument,
        MizMergePreview preview)
    {
        foreach (var newTable in newDocument.StringListTables.ToList())
        {
            var currentTable = currentDocument.StringListTables.FirstOrDefault(table => table.Key.Equals(newTable.Key, StringComparison.Ordinal));
            if (currentTable is null)
            {
                continue;
            }

            var policy = ResolveInstallPolicy(newDocument, newTable.Key, InstallPolicyMergeRows);
            if (!policy.Equals(InstallPolicyKeepTable, StringComparison.OrdinalIgnoreCase))
            {
                continue;
            }

            if (currentDocument.TryGetTableBlockText(newTable.Key, out var currentBlock) &&
                newDocument.TryGetTableBlockText(newTable.Key, out var newDefaultBlock) &&
                !TableBlockTextEquals(currentBlock, newDefaultBlock))
            {
                preview.KeptTableBlocks.Add(new MizKeptTableBlock(
                    newTable.Key,
                    currentBlock,
                    newDefaultBlock,
                    currentTable.Items.Count,
                    newTable.Items.Count));
            }

            var keptTable = IsBucketStringListEditor(newTable)
                ? newDocument.RewriteBucketStringListBodyFrom(currentDocument, newTable.Key)
                : newDocument.ReplaceTableBodyFrom(currentDocument, newTable.Key);
            if (keptTable)
            {
                preview.KeptStringListTables.Add((newTable.Key, currentTable.Items.Count));
            }
        }
    }

    private static bool TryMigrateMisplacedTopLevelValue(
        Dictionary<string, ConfigEntry> currentByKey,
        IReadOnlyDictionary<string, ConfigEntry> newTopLevelByKey,
        ConfigEntry currentEntry,
        MizMergePreview preview)
    {
        if (string.IsNullOrWhiteSpace(currentEntry.ParentKey) ||
            currentEntry.ParentKey.Contains('.', StringComparison.Ordinal) ||
            !newTopLevelByKey.TryGetValue(currentEntry.Key, out var topLevelEntry) ||
            currentEntry.Kind != topLevelEntry.Kind)
        {
            return false;
        }

        if (currentByKey.ContainsKey(topLevelEntry.DisplayKey))
        {
            return true;
        }

        if (string.Equals(topLevelEntry.ValueText, currentEntry.ValueText, StringComparison.Ordinal))
        {
            preview.UnchangedCount++;
            return true;
        }

        preview.KeptValues.Add(new MizKeptValue(topLevelEntry, currentEntry.ValueText, topLevelEntry.ValueText));
        topLevelEntry.ValueText = currentEntry.ValueText;
        return true;
    }

    private static bool TryPreserveSimpleTableRow(
        ConfigDocument newDocument,
        ConfigEntry currentEntry,
        IReadOnlyDictionary<string, ConfigEntry> newTopLevelByKey)
    {
        if (string.IsNullOrWhiteSpace(currentEntry.ParentKey) ||
            currentEntry.ParentKey.Contains('.', StringComparison.Ordinal) ||
            newTopLevelByKey.ContainsKey(currentEntry.Key))
        {
            return false;
        }

        var template = newDocument.Entries.FirstOrDefault(entry => entry.ParentKey.Equals(currentEntry.ParentKey, StringComparison.Ordinal));
        if (template is null)
        {
            return false;
        }

        try
        {
            newDocument.AddTableEntry(currentEntry.ParentKey, currentEntry.Key, currentEntry.ValueText, template);
            return true;
        }
        catch
        {
            return false;
        }
    }

    private static void PreserveStringListItems(ConfigDocument currentDocument, ConfigDocument newDocument, MizMergePreview preview)
    {
        foreach (var newTable in newDocument.StringListTables)
        {
            var currentTable = currentDocument.StringListTables.FirstOrDefault(table => table.Key.Equals(newTable.Key, StringComparison.Ordinal));
            if (currentTable is null)
            {
                continue;
            }

            var policy = ResolveInstallPolicy(newDocument, newTable.Key, InstallPolicyMergeRows);
            if (policy.Equals(InstallPolicyKeepTable, StringComparison.OrdinalIgnoreCase) ||
                policy.Equals(InstallPolicyReplaceTable, StringComparison.OrdinalIgnoreCase))
            {
                continue;
            }

            var newValues = newTable.Items
                .Select(item => item.Value)
                .ToHashSet(StringComparer.Ordinal);
            foreach (var currentItem in currentTable.Items)
            {
                if (newValues.Contains(currentItem.Value))
                {
                    continue;
                }

                newDocument.AddStringListItem(newTable, currentItem.Value);
                newValues.Add(currentItem.Value);
                preview.PreservedListItems.Add((newTable.Key, currentItem.Value));
            }
        }
    }

    private static string ResolveInstallPolicy(ConfigDocument document, string key, string defaultPolicy)
    {
        var policy = document.GetInstallPolicy(key);
        if (policy is null)
        {
            return defaultPolicy;
        }

        if (policy.Equals(InstallPolicyKeepTable, StringComparison.OrdinalIgnoreCase))
        {
            return InstallPolicyKeepTable;
        }

        if (policy.Equals(InstallPolicyMergeRows, StringComparison.OrdinalIgnoreCase))
        {
            return InstallPolicyMergeRows;
        }

        if (policy.Equals(InstallPolicyReplaceTable, StringComparison.OrdinalIgnoreCase))
        {
            return InstallPolicyReplaceTable;
        }

        return defaultPolicy;
    }

    private static bool TableBlockTextEquals(string left, string right)
    {
        return string.Equals(NormalizeTableBlockText(left), NormalizeTableBlockText(right), StringComparison.Ordinal);
    }

    private static string NormalizeTableBlockText(string text)
    {
        return text.Replace("\r\n", "\n", StringComparison.Ordinal)
            .Replace('\r', '\n')
            .Trim();
    }

    private static List<SelectableValueChoice> BuildKeptTableChoices(
        MizMergePreview preview,
        string selectedTableLabel,
        string otherTableLabel)
    {
        return preview.KeptTableBlocks
            .Select(table => new SelectableValueChoice(
                table.Key + " (full table)",
                table.CurrentItemCount.ToString(CultureInfo.InvariantCulture) + " parsed item(s), " + selectedTableLabel,
                table.NewDefaultItemCount.ToString(CultureInfo.InvariantCulture) + " parsed item(s), " + otherTableLabel,
                "Raw table text differs, including commented-out rows."))
            .ToList();
    }

    private static void ApplyKeptTableChoices(
        ConfigDocument targetDocument,
        MizMergePreview preview,
        IReadOnlyList<SelectableValueChoice> tableChoices)
    {
        ConfigDocument? defaultDocument = null;
        for (var i = 0; i < tableChoices.Count; i++)
        {
            if (tableChoices[i].Selected)
            {
                continue;
            }

            defaultDocument ??= ConfigDocument.Load(targetDocument.Path);
            defaultDocument.RepairStringListSeparators();
            var table = preview.KeptTableBlocks[i];
            if (!targetDocument.ReplaceTableBodyFrom(defaultDocument, table.Key))
            {
                throw new InvalidOperationException("Could not restore the new table text for " + table.Key + ".");
            }
        }
    }

    private static void ApplyKeptValueChoices(
        ConfigDocument targetDocument,
        MizMergePreview preview,
        IReadOnlyList<SelectableValueChoice> valueChoices)
    {
        for (var i = 0; i < valueChoices.Count; i++)
        {
            if (valueChoices[i].Selected)
            {
                continue;
            }

            var keptValue = preview.KeptValues[i];
            var entry = targetDocument.Entries.FirstOrDefault(candidate => candidate.DisplayKey.Equals(keptValue.Key, StringComparison.Ordinal));
            if (entry is not null)
            {
                entry.ValueText = keptValue.NewDefault;
            }
        }
    }

    private void ImportValuesFromOldConfig()
    {
        if (_document is null)
        {
            return;
        }

        if (IsRawCategorySelected())
        {
            ApplyEntryValue();
        }

        if (HasChanges())
        {
            MessageBox.Show(this, "Save or reload pending changes before importing another config file.", "Import Config File", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

        using var dialog = new OpenFileDialog
        {
            Title = "Select Foothold Config.lua",
            Filter = "Lua config (*.lua)|*.lua|All files (*.*)|*.*",
            FileName = GetCurrentConfigFileName(_document),
            InitialDirectory = Path.GetDirectoryName(_document.Path)
        };

        if (dialog.ShowDialog(this) != DialogResult.OK)
        {
            return;
        }

        try
        {
            var currentPath = Path.GetFullPath(_document.Path);
            var sourcePath = Path.GetFullPath(dialog.FileName);
            if (string.Equals(currentPath, sourcePath, StringComparison.OrdinalIgnoreCase))
            {
                MessageBox.Show(this, "Select another config file, not the config that is already open.", "Import Config File", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }

            var currentDocument = _document;
            var sourceDocument = ConfigDocument.Load(sourcePath);
            sourceDocument.RepairStringListSeparators();
            if (!ValidateMergeDocument(sourceDocument, "Import Config File validation failed", "The selected config"))
            {
                return;
            }

            var outputDocument = ConfigDocument.Load(sourcePath);
            outputDocument.RepairStringListSeparators();
            var preview = MergeCurrentConfigIntoNewConfig(currentDocument, outputDocument);
            if (!ValidateMergeDocument(outputDocument, "Import Config File validation failed", "The merged Import Config File config"))
            {
                return;
            }

            if (preview.KeptValues.Count == 0 && preview.UnchangedCount == 0)
            {
                MessageBox.Show(this, "No matching config keys were found in the selected config.", "Import Config File", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }

            var previewText = BuildImportMergePreviewText(sourcePath, currentPath, preview);
            var valueChoices = preview.KeptValues
                .Select(item => new SelectableValueChoice(item.Key, item.CurrentValue, item.NewDefault, item.Entry.EffectiveDescription))
                .ToList();
            var tableChoices = BuildKeptTableChoices(preview, "current table text", "selected config table text");
            var choices = valueChoices.Concat(tableChoices).ToList();
            if (!ConfirmSelectableValuePreview(
                    previewText,
                    "Import Config File Preview",
                    "Tick rows to keep your current values. Untick rows to use the selected config defaults.",
                    "Import",
                    "Your current value",
                    "Selected config default",
                    "Keep your current values",
                    "Use selected config value",
                    choices,
                    BuildMizInstallInfoTabs(preview)))
            {
                return;
            }

            ApplyKeptTableChoices(outputDocument, preview, tableChoices);
            ApplyKeptValueChoices(outputDocument, preview, valueChoices);

            if (!ValidateMergeDocument(outputDocument, "Import Config File validation failed", "The final Import Config File config"))
            {
                return;
            }

            var importedNewMarkers = CaptureImportedNewMarkers(preview);
            var storedDefaults = StoreConfigDefaults(sourcePath);
            outputDocument.SaveTo(currentPath);
            LoadConfig(currentPath);
            ApplyImportedNewMarkers(importedNewMarkers);
            SetStatus("Imported merged config from " + FormatRestoreDefaultsSourceName(storedDefaults) + ".");
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Import Config File failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private bool ConfirmImportValues(
        string previewText,
        string title = "Import Values Preview",
        string message = "Review the values that will be imported before values are loaded into the editor.",
        string confirmText = "Import")
    {
        using var dialog = new Form
        {
            Text = title,
            StartPosition = FormStartPosition.CenterParent,
            FormBorderStyle = FormBorderStyle.Sizable,
            MinimizeBox = false,
            MaximizeBox = true,
            ClientSize = new Size(780, 540),
            Font = Font
        };

        var panel = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            RowCount = 3,
            ColumnCount = 1,
            Padding = new Padding(10)
        };
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 42));
        panel.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 48));
        dialog.Controls.Add(panel);

        panel.Controls.Add(new Label
        {
            Text = message,
            Dock = DockStyle.Fill,
            TextAlign = ContentAlignment.MiddleLeft
        }, 0, 0);

        var previewBox = new TextBox
        {
            Dock = DockStyle.Fill,
            Multiline = true,
            ReadOnly = true,
            ScrollBars = ScrollBars.Both,
            WordWrap = false,
            Text = previewText
        };
        panel.Controls.Add(previewBox, 0, 1);

        var buttons = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            FlowDirection = FlowDirection.RightToLeft
        };
        var importButton = new Button
        {
            Text = confirmText,
            DialogResult = DialogResult.OK,
            Width = 90
        };
        var cancelButton = new Button
        {
            Text = "Cancel",
            DialogResult = DialogResult.Cancel,
            Width = 90
        };
        buttons.Controls.Add(importButton);
        buttons.Controls.Add(cancelButton);
        panel.Controls.Add(buttons, 0, 2);

        dialog.AcceptButton = importButton;
        dialog.CancelButton = cancelButton;
        return dialog.ShowDialog(this) == DialogResult.OK;
    }

    private bool ConfirmSelectableValuePreview(
        string previewText,
        string title,
        string message,
        string confirmText,
        string selectedValueLabel,
        string otherValueLabel,
        string selectedActionLabel,
        string otherActionLabel,
        List<SelectableValueChoice> choices,
        IReadOnlyList<(string Title, IReadOnlyList<string> Rows)>? infoTabs = null)
    {
        using var dialog = new Form
        {
            Text = title,
            StartPosition = FormStartPosition.CenterParent,
            FormBorderStyle = FormBorderStyle.Sizable,
            MinimizeBox = false,
            MaximizeBox = true,
            ClientSize = new Size(Zoomed(980), Zoomed(700)),
            MinimumSize = new Size(Zoomed(780), Zoomed(560)),
            Font = Font,
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        };

        var panel = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            RowCount = 4,
            ColumnCount = 1,
            Padding = new Padding(Zoomed(10)),
            BackColor = MainBackground
        };
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(64)));
        panel.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        var detailsRowStyle = new RowStyle(SizeType.Absolute, 0);
        panel.RowStyles.Add(detailsRowStyle);
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(56)));
        dialog.Controls.Add(panel);

        string Plural(int count, string singular, string plural)
        {
            return count.ToString(CultureInfo.InvariantCulture) + " " + (count == 1 ? singular : plural);
        }

        string FormatNewImportRowLabel(string row)
        {
            var firstLine = row.Replace("\r\n", "\n", StringComparison.Ordinal)
                .Replace('\r', '\n')
                .Split('\n', StringSplitOptions.RemoveEmptyEntries)
                .FirstOrDefault()?.Trim() ?? row.Trim();
            if (firstLine.StartsWith("NEW  ", StringComparison.OrdinalIgnoreCase))
            {
                firstLine = firstLine[5..].Trim();
            }

            var assignmentIndex = firstLine.IndexOf(" = ", StringComparison.Ordinal);
            if (assignmentIndex > 0)
            {
                firstLine = firstLine[..assignmentIndex].Trim();
            }
            else
            {
                var colonIndex = firstLine.IndexOf(": ", StringComparison.Ordinal);
                if (colonIndex > 0)
                {
                    firstLine = firstLine[..colonIndex].Trim();
                }
            }

            return firstLine + " (NEW)";
        }

        var orderedChoices = choices.OrderBy(choice => choice.Key, StringComparer.OrdinalIgnoreCase).ToList();
        var newRows = new List<(string Label, string Summary)>();
        if (infoTabs is not null)
        {
            foreach (var tab in infoTabs.Where(tab =>
                         tab.Title.Equals("New", StringComparison.OrdinalIgnoreCase) ||
                         tab.Title.Equals("New Options", StringComparison.OrdinalIgnoreCase) ||
                         tab.Title.Equals("New Rows", StringComparison.OrdinalIgnoreCase)))
            {
                newRows.AddRange(tab.Rows.Select(row => (FormatNewImportRowLabel(row), "NEW")));
            }
        }

        string BuildCompactSummary()
        {
            var parts = new List<string>();
            if (orderedChoices.Count > 0)
            {
                parts.Add(Plural(orderedChoices.Count, "change", "changes"));
            }

            if (newRows.Count > 0)
            {
                parts.Add(Plural(newRows.Count, "new item", "new items"));
            }

            return parts.Count == 0
                ? "No changed values need a checkbox decision."
                : string.Join(", ", parts) + ".";
        }

        panel.Controls.Add(new Label
        {
            Text = BuildCompactSummary() + Environment.NewLine + message,
            Dock = DockStyle.Fill,
            TextAlign = ContentAlignment.MiddleLeft,
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        }, 0, 0);

        Control choiceControl;
        if (orderedChoices.Count == 0 && newRows.Count == 0)
        {
            choiceControl = new Label
            {
                Text = "No changed matching values need a checkbox decision.",
                Dock = DockStyle.Fill,
                TextAlign = ContentAlignment.MiddleLeft,
                BackColor = MainBackground,
                ForeColor = PrimaryTextColor
            };
        }
        else
        {
            var groupName = _instanceBox.SelectedItem is InstanceItem instanceItem
                ? instanceItem.Profile.Name
                : "Current config";
            var choicePanel = new TableLayoutPanel
            {
                Dock = DockStyle.Fill,
                RowCount = 2,
                ColumnCount = 1,
                Margin = new Padding(0),
                Padding = new Padding(0),
                BackColor = MainBackground
            };
            choicePanel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(38)));
            choicePanel.RowStyles.Add(new RowStyle(SizeType.Percent, 100));

            var actionBar = new FlowLayoutPanel
            {
                Dock = DockStyle.Fill,
                FlowDirection = FlowDirection.LeftToRight,
                Margin = new Padding(0),
                WrapContents = false,
                BackColor = MainBackground
            };
            var selectAllButton = new Button { Text = selectedActionLabel, Margin = new Padding(Zoomed(2)) };
            var clearAllButton = new Button { Text = otherActionLabel, Margin = new Padding(Zoomed(2)) };
            selectAllButton.Enabled = orderedChoices.Count > 0;
            clearAllButton.Enabled = orderedChoices.Count > 0;
            SizeDialogButton(selectAllButton, 190);
            SizeDialogButton(clearAllButton, 170);
            actionBar.Controls.Add(selectAllButton);
            actionBar.Controls.Add(clearAllButton);
            choicePanel.Controls.Add(actionBar, 0, 0);

            var scrollPanel = new Panel
            {
                Dock = DockStyle.Fill,
                AutoScroll = true,
                BackColor = MainBackground
            };
            var rows = new TableLayoutPanel
            {
                Dock = DockStyle.Top,
                AutoSize = true,
                ColumnCount = 1,
                BackColor = MainBackground,
                Padding = new Padding(0, Zoomed(4), 0, Zoomed(4))
            };
            rows.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            scrollPanel.Controls.Add(rows);

            var updatingSelectionUi = false;
            var childChecks = new List<CheckBox>();
            CheckBox? parentCheck = null;
            Label? parentSummaryLabel = null;

            string BuildChangeSummary(SelectableValueChoice choice)
            {
                return PreviewValue(choice.OtherValue) + " -> " + PreviewValue(choice.SelectedValue);
            }

            string BuildGroupSummary()
            {
                if (orderedChoices.Count == 0)
                {
                    return Plural(newRows.Count, "new item", "new items");
                }

                var selectedCount = orderedChoices.Count(choice => choice.Selected);
                if (selectedCount == 0)
                {
                    return "Not selected";
                }

                return selectedCount == orderedChoices.Count
                    ? orderedChoices.Count.ToString(CultureInfo.InvariantCulture) + " changes"
                    : selectedCount.ToString(CultureInfo.InvariantCulture) + " of " + orderedChoices.Count.ToString(CultureInfo.InvariantCulture) + " changes selected";
            }

            void RefreshSelectionUi()
            {
                updatingSelectionUi = true;
                try
                {
                    var selectedCount = orderedChoices.Count(choice => choice.Selected);
                    if (parentCheck is not null && parentCheck.Checked != (selectedCount > 0))
                    {
                        parentCheck.Checked = selectedCount > 0;
                    }

                    if (parentSummaryLabel is not null)
                    {
                        parentSummaryLabel.Text = BuildGroupSummary();
                    }

                    for (var i = 0; i < orderedChoices.Count && i < childChecks.Count; i++)
                    {
                        if (childChecks[i].Checked != orderedChoices[i].Selected)
                        {
                            childChecks[i].Checked = orderedChoices[i].Selected;
                        }
                    }
                }
                finally
                {
                    updatingSelectionUi = false;
                }
            }

            void AddRow(Control control)
            {
                rows.RowStyles.Add(new RowStyle(SizeType.AutoSize));
                rows.Controls.Add(control, 0, rows.RowCount);
                rows.RowCount++;
            }

            TableLayoutPanel MakeImportRow(int indent, CheckBox? checkBox, string label, string summary)
            {
                var row = new TableLayoutPanel
                {
                    AutoSize = true,
                    Dock = DockStyle.Top,
                    ColumnCount = 3,
                    Padding = new Padding(0, Zoomed(2), 0, Zoomed(2)),
                    BackColor = MainBackground
                };
                row.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, Zoomed(indent)));
                row.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, Zoomed(360)));
                row.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));

                if (checkBox is not null)
                {
                    checkBox.Dock = DockStyle.Fill;
                    checkBox.Margin = new Padding(0);
                    checkBox.BackColor = MainBackground;
                    checkBox.ForeColor = PrimaryTextColor;
                    row.Controls.Add(checkBox, 0, 0);
                }

                row.Controls.Add(new Label
                {
                    Text = label,
                    Dock = DockStyle.Fill,
                    TextAlign = ContentAlignment.MiddleLeft,
                    AutoEllipsis = true,
                    BackColor = MainBackground,
                    ForeColor = PrimaryTextColor
                }, 1, 0);

                row.Controls.Add(new Label
                {
                    Text = summary,
                    Dock = DockStyle.Fill,
                    TextAlign = ContentAlignment.MiddleLeft,
                    AutoEllipsis = true,
                    BackColor = MainBackground,
                    ForeColor = HelpTextColor
                }, 2, 0);

                return row;
            }

            parentCheck = new CheckBox
            {
                Checked = orderedChoices.Any(choice => choice.Selected),
                Enabled = orderedChoices.Count > 0
            };
            parentCheck.CheckedChanged += (_, _) =>
            {
                if (updatingSelectionUi)
                {
                    return;
                }

                foreach (var choice in orderedChoices)
                {
                    choice.Selected = parentCheck.Checked;
                }

                RefreshSelectionUi();
            };
            var parentRow = MakeImportRow(28, parentCheck, groupName, BuildGroupSummary());
            parentSummaryLabel = parentRow.Controls.OfType<Label>().LastOrDefault();
            AddRow(parentRow);

            foreach (var choice in orderedChoices)
            {
                var changeCheck = new CheckBox { Checked = choice.Selected };
                changeCheck.CheckedChanged += (_, _) =>
                {
                    if (updatingSelectionUi)
                    {
                        return;
                    }

                    choice.Selected = changeCheck.Checked;
                    RefreshSelectionUi();
                };
                childChecks.Add(changeCheck);
                AddRow(MakeImportRow(68, changeCheck, choice.Key, BuildChangeSummary(choice)));
            }

            foreach (var newRow in newRows.OrderBy(row => row.Label, StringComparer.OrdinalIgnoreCase))
            {
                AddRow(MakeImportRow(68, null, newRow.Label, newRow.Summary));
            }

            selectAllButton.Click += (_, _) =>
            {
                foreach (var choice in orderedChoices)
                {
                    choice.Selected = true;
                }

                RefreshSelectionUi();
            };
            clearAllButton.Click += (_, _) =>
            {
                foreach (var choice in orderedChoices)
                {
                    choice.Selected = false;
                }

                RefreshSelectionUi();
            };

            choicePanel.Controls.Add(scrollPanel, 0, 1);
            choiceControl = choicePanel;
        }

        panel.Controls.Add(choiceControl, 0, 1);

        var previewFrame = new Panel
        {
            Dock = DockStyle.Fill,
            BorderStyle = BorderStyle.FixedSingle,
            Padding = new Padding(Zoomed(6)),
            BackColor = EditorBackground,
            Visible = false
        };

        var previewPanel = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            RowCount = 2,
            ColumnCount = 1,
            BackColor = EditorBackground,
            Margin = new Padding(0),
            Padding = new Padding(0)
        };
        previewPanel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(36)));
        previewPanel.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        previewFrame.Controls.Add(previewPanel);

        var previewTabs = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            FlowDirection = FlowDirection.LeftToRight,
            WrapContents = false,
            BackColor = EditorBackground,
            Margin = new Padding(0),
            Padding = new Padding(0, 0, 0, Zoomed(6))
        };
        previewPanel.Controls.Add(previewTabs, 0, 0);

        var previewBox = new RichTextBox
        {
            Dock = DockStyle.Fill,
            ReadOnly = true,
            ScrollBars = RichTextBoxScrollBars.Both,
            WordWrap = false,
            DetectUrls = false,
            BorderStyle = BorderStyle.None,
            Text = previewText,
            BackColor = EditorBackground,
            ForeColor = PrimaryTextColor,
            Margin = new Padding(0)
        };
        previewPanel.Controls.Add(previewBox, 0, 1);

        var previewTabText = new Dictionary<Button, string>();

        Button AddPreviewTab(string tabTitle, string tabText)
        {
            var button = new Button
            {
                Text = tabTitle,
                Margin = new Padding(0, 0, Zoomed(6), 0)
            };
            SizeDialogButton(button, 90);
            previewTabText[button] = tabText;
            button.Click += (_, _) => SelectPreviewTab(button);
            previewTabs.Controls.Add(button);
            return button;
        }

        void RefreshPreviewChrome()
        {
            previewFrame.BackColor = EditorBackground;
            previewPanel.BackColor = EditorBackground;
            previewTabs.BackColor = EditorBackground;
            previewBox.BackColor = EditorBackground;
            previewBox.ForeColor = PrimaryTextColor;
        }

        void SelectPreviewTab(Button selectedButton)
        {
            RefreshPreviewChrome();
            previewBox.Text = previewTabText[selectedButton];
            foreach (var button in previewTabText.Keys)
            {
                StyleButton(button);
                if (button == selectedButton)
                {
                    button.BackColor = SelectionBackground;
                    button.ForeColor = SelectionText;
                    button.FlatAppearance.BorderColor = SelectionBackground;
                }
            }
        }

        var summaryButton = AddPreviewTab("Summary", previewText);

        if (infoTabs is not null)
        {
            foreach (var tab in infoTabs.Where(tab => tab.Rows.Count > 0))
            {
                AddPreviewTab(tab.Title, string.Join(Environment.NewLine, tab.Rows));
            }
        }

        panel.Controls.Add(previewFrame, 0, 2);

        var buttons = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            FlowDirection = FlowDirection.RightToLeft,
            WrapContents = false,
            Padding = new Padding(0, Zoomed(8), 0, 0),
            BackColor = MainBackground
        };
        var confirmButton = new Button
        {
            Text = confirmText,
            DialogResult = DialogResult.OK
        };
        var cancelButton = new Button
        {
            Text = "Cancel",
            DialogResult = DialogResult.Cancel
        };
        var detailsButton = new Button
        {
            Text = "Show details"
        };
        detailsButton.Click += (_, _) =>
        {
            previewFrame.Visible = !previewFrame.Visible;
            detailsRowStyle.Height = previewFrame.Visible ? Zoomed(220) : 0;
            detailsButton.Text = previewFrame.Visible ? "Hide details" : "Show details";
            panel.PerformLayout();
        };
        SizeDialogButton(confirmButton);
        SizeDialogButton(cancelButton);
        SizeDialogButton(detailsButton, 120);
        buttons.Controls.Add(confirmButton);
        buttons.Controls.Add(cancelButton);
        buttons.Controls.Add(detailsButton);
        panel.Controls.Add(buttons, 0, 3);

        ApplyDialogChrome(dialog);
        SelectPreviewTab(summaryButton);
        dialog.AcceptButton = confirmButton;
        dialog.CancelButton = cancelButton;
        if (dialog.ShowDialog(this) != DialogResult.OK)
        {
            return false;
        }

        if (TryFindChoiceList(choiceControl, out var listView))
        {
            foreach (ListViewItem item in listView.Items)
            {
                if (item.Tag is SelectableValueChoice choice)
                {
                    choice.Selected = item.Checked;
                }
            }
        }

        return true;
    }

    private static bool TryFindChoiceList(Control control, out ListView list)
    {
        if (control is ListView direct)
        {
            list = direct;
            return true;
        }

        foreach (Control child in control.Controls)
        {
            if (TryFindChoiceList(child, out list))
            {
                return true;
            }
        }

        list = null!;
        return false;
    }

    private static string BuildImportPreviewText(
        string oldPath,
        List<(ConfigEntry Entry, string OldValue, string CurrentValue)> changes,
        int unchangedCount,
        List<ConfigEntry> newDefaults,
        List<ConfigEntry> skippedOldEntries)
    {
        var lines = new List<string>
        {
            "Old config:",
            oldPath,
            "",
            "Values to import: " + changes.Count.ToString(CultureInfo.InvariantCulture),
            "Matching values already the same: " + unchangedCount.ToString(CultureInfo.InvariantCulture),
            "New defaults kept: " + newDefaults.Count.ToString(CultureInfo.InvariantCulture),
            "Old config values skipped: " + skippedOldEntries.Count.ToString(CultureInfo.InvariantCulture)
        };

        AddPreviewSection(
            lines,
            "Values to import",
            changes.OrderBy(change => change.Entry.DisplayKey, StringComparer.OrdinalIgnoreCase)
                .Select(change => change.Entry.DisplayKey + ": " + PreviewValue(change.CurrentValue) + " -> " + PreviewValue(change.OldValue)));
        AddPreviewSection(
            lines,
            "New defaults kept",
            newDefaults.OrderBy(entry => entry.DisplayKey, StringComparer.OrdinalIgnoreCase)
                .Select(entry => entry.DisplayKey + ": " + PreviewValue(entry.ValueText)));
        AddPreviewSection(
            lines,
            "Old config values skipped",
            skippedOldEntries.Select(entry => entry.DisplayKey + ": " + PreviewValue(entry.ValueText)));

        return string.Join(Environment.NewLine, lines);
    }

    private static string BuildImportMergePreviewText(string importedPath, string currentConfigPath, MizMergePreview preview)
    {
        var newOptions = GetNewOptionEntries(preview);
        var newRows = GetNewRowEntries(preview);
        var lines = new List<string>
        {
            "Selected config:",
            importedPath,
            "",
            "Current config to update:",
            currentConfigPath,
            "",
            "Matching values kept from current config: " + preview.KeptValues.Count.ToString(CultureInfo.InvariantCulture),
            "Matching values already the same: " + preview.UnchangedCount.ToString(CultureInfo.InvariantCulture),
            "New options from selected config kept: " + newOptions.Count.ToString(CultureInfo.InvariantCulture),
            "New rows from selected config kept: " + newRows.Count.ToString(CultureInfo.InvariantCulture),
            "Current full lists kept: " + preview.KeptStringListTables.Count.ToString(CultureInfo.InvariantCulture),
            "Current table rows preserved: " + preview.PreservedTableRows.Count.ToString(CultureInfo.InvariantCulture),
            "Current list items preserved: " + preview.PreservedListItems.Count.ToString(CultureInfo.InvariantCulture),
            "Current values skipped: " + preview.SkippedOldValues.Count.ToString(CultureInfo.InvariantCulture)
        };

        AddPreviewSection(
            lines,
            "Matching values kept from current config",
            preview.KeptValues
                .OrderBy(item => item.Key, StringComparer.OrdinalIgnoreCase)
                .Select(item => item.Key + ": " + PreviewValue(item.NewDefault) + " -> " + PreviewValue(item.CurrentValue)));
        AddPreviewSection(
            lines,
            "Current full lists kept",
            preview.KeptStringListTables
                .OrderBy(item => item.Table, StringComparer.OrdinalIgnoreCase)
                .Select(item => item.Table + ": " + item.ItemCount.ToString(CultureInfo.InvariantCulture) + " item(s)"));
        AddPreviewSection(
            lines,
            "Current table rows preserved",
            preview.PreservedTableRows
                .OrderBy(item => item.Key, StringComparer.OrdinalIgnoreCase)
                .Select(item => item.Key + ": " + PreviewValue(item.Value)));
        AddPreviewSection(
            lines,
            "Current list items preserved",
            preview.PreservedListItems
                .OrderBy(item => item.Table, StringComparer.OrdinalIgnoreCase)
                .ThenBy(item => item.Value, StringComparer.OrdinalIgnoreCase)
                .Select(item => item.Table + ": " + PreviewValue(item.Value)));
        AddPreviewSection(
            lines,
            "New options from selected config kept",
            newOptions
                .OrderBy(entry => entry.DisplayKey, StringComparer.OrdinalIgnoreCase)
                .Select(entry => FormatEntryAssignment(entry)));
        AddPreviewSection(
            lines,
            "Current values skipped",
            preview.SkippedOldValues
                .OrderBy(item => item.Key, StringComparer.OrdinalIgnoreCase)
                .Select(item => item.Key + ": " + PreviewValue(item.Value)));

        return string.Join(Environment.NewLine, lines);
    }

    private static string BuildRestoreDefaultsPreviewText(StoredMizDefaultsInfo defaults, string currentConfigPath, MizMergePreview preview)
    {
        var newOptions = GetNewOptionEntries(preview);
        var newRows = GetNewRowEntries(preview);
        var lines = new List<string>
        {
            "Defaults source:",
            FormatRestoreDefaultsSourceName(defaults),
            "Stored at: " + defaults.StoredAt.ToString("yyyy-MM-dd HH:mm", CultureInfo.InvariantCulture),
            "",
            "Current config to replace:",
            currentConfigPath,
            "",
            "Matching values kept from current config: " + preview.KeptValues.Count.ToString(CultureInfo.InvariantCulture),
            "Matching values already the same: " + preview.UnchangedCount.ToString(CultureInfo.InvariantCulture),
            "Default options restored: " + newOptions.Count.ToString(CultureInfo.InvariantCulture),
            "Default rows restored: " + newRows.Count.ToString(CultureInfo.InvariantCulture),
            "Current full lists kept: " + preview.KeptStringListTables.Count.ToString(CultureInfo.InvariantCulture),
            "Current table rows preserved: " + preview.PreservedTableRows.Count.ToString(CultureInfo.InvariantCulture),
            "Current list items preserved: " + preview.PreservedListItems.Count.ToString(CultureInfo.InvariantCulture),
            "Current values skipped: " + preview.SkippedOldValues.Count.ToString(CultureInfo.InvariantCulture)
        };

        AddPreviewSection(
            lines,
            "Matching values kept from current config",
            preview.KeptValues
                .OrderBy(item => item.Key, StringComparer.OrdinalIgnoreCase)
                .Select(item => item.Key + ": " + PreviewValue(item.NewDefault) + " -> " + PreviewValue(item.CurrentValue)));
        AddPreviewSection(
            lines,
            "Current full lists kept",
            preview.KeptStringListTables
                .OrderBy(item => item.Table, StringComparer.OrdinalIgnoreCase)
                .Select(item => item.Table + ": " + item.ItemCount.ToString(CultureInfo.InvariantCulture) + " item(s)"));
        AddPreviewSection(
            lines,
            "Current table rows preserved",
            preview.PreservedTableRows
                .OrderBy(item => item.Key, StringComparer.OrdinalIgnoreCase)
                .Select(item => item.Key + ": " + PreviewValue(item.Value)));
        AddPreviewSection(
            lines,
            "Current list items preserved",
            preview.PreservedListItems
                .OrderBy(item => item.Table, StringComparer.OrdinalIgnoreCase)
                .ThenBy(item => item.Value, StringComparer.OrdinalIgnoreCase)
                .Select(item => item.Table + ": " + PreviewValue(item.Value)));
        AddPreviewSection(
            lines,
            "Default options restored",
            newOptions
                .OrderBy(entry => entry.DisplayKey, StringComparer.OrdinalIgnoreCase)
                .Select(entry => FormatEntryAssignment(entry)));
        AddPreviewSection(
            lines,
            "Current values skipped",
            preview.SkippedOldValues
                .OrderBy(item => item.Key, StringComparer.OrdinalIgnoreCase)
                .Select(item => item.Key + ": " + PreviewValue(item.Value)));

        return string.Join(Environment.NewLine, lines);
    }

    private static string BuildMizInstallPreviewText(string mizPath, string currentConfigPath, MizMergePreview preview)
    {
        var newOptions = GetNewOptionEntries(preview);
        var newRows = GetNewRowEntries(preview);
        var lines = new List<string>
        {
            "MIZ:",
            mizPath,
            "",
            "Current config to replace:",
            currentConfigPath,
            "",
            "Matching values kept from current config: " + preview.KeptValues.Count.ToString(CultureInfo.InvariantCulture),
            "Matching values already the same: " + preview.UnchangedCount.ToString(CultureInfo.InvariantCulture),
            "New options from MIZ kept: " + newOptions.Count.ToString(CultureInfo.InvariantCulture),
            "New rows from MIZ kept: " + newRows.Count.ToString(CultureInfo.InvariantCulture),
            "Current full lists kept: " + preview.KeptStringListTables.Count.ToString(CultureInfo.InvariantCulture),
            "Current table rows preserved: " + preview.PreservedTableRows.Count.ToString(CultureInfo.InvariantCulture),
            "Current list items preserved: " + preview.PreservedListItems.Count.ToString(CultureInfo.InvariantCulture),
            "Old values skipped: " + preview.SkippedOldValues.Count.ToString(CultureInfo.InvariantCulture)
        };

        AddPreviewSection(
            lines,
            "Matching values kept from current config",
            preview.KeptValues
                .OrderBy(item => item.Key, StringComparer.OrdinalIgnoreCase)
                .Select(item => item.Key + ": " + PreviewValue(item.NewDefault) + " -> " + PreviewValue(item.CurrentValue)));
        AddPreviewSection(
            lines,
            "Current full lists kept",
            preview.KeptStringListTables
                .OrderBy(item => item.Table, StringComparer.OrdinalIgnoreCase)
                .Select(item => item.Table + ": " + item.ItemCount.ToString(CultureInfo.InvariantCulture) + " item(s)"));
        AddPreviewSection(
            lines,
            "Current table rows preserved",
            preview.PreservedTableRows
                .OrderBy(item => item.Key, StringComparer.OrdinalIgnoreCase)
                .Select(item => item.Key + ": " + PreviewValue(item.Value)));
        AddPreviewSection(
            lines,
            "Current list items preserved",
            preview.PreservedListItems
                .OrderBy(item => item.Table, StringComparer.OrdinalIgnoreCase)
                .ThenBy(item => item.Value, StringComparer.OrdinalIgnoreCase)
                .Select(item => item.Table + ": " + PreviewValue(item.Value)));
        AddPreviewSection(
            lines,
            "New options from MIZ kept",
            newOptions
                .OrderBy(entry => entry.DisplayKey, StringComparer.OrdinalIgnoreCase)
                .Select(entry => FormatEntryAssignment(entry)));
        AddPreviewSection(
            lines,
            "Old values skipped",
            preview.SkippedOldValues
                .OrderBy(item => item.Key, StringComparer.OrdinalIgnoreCase)
                .Select(item => item.Key + ": " + PreviewValue(item.Value)));

        return string.Join(Environment.NewLine, lines);
    }

    private static IReadOnlyList<(string Title, IReadOnlyList<string> Rows)> BuildMizInstallInfoTabs(MizMergePreview preview)
    {
        var newOptions = GetNewOptionEntries(preview);
        var newRows = GetNewRowEntries(preview);
        return new List<(string Title, IReadOnlyList<string> Rows)>
        {
            ("New Options", newOptions
                .OrderBy(entry => entry.DisplayKey, StringComparer.OrdinalIgnoreCase)
                .Select(FormatNewOptionDetail)
                .ToList()),
            ("New Rows", newRows
                .OrderBy(entry => entry.DisplayKey, StringComparer.OrdinalIgnoreCase)
                .Select(entry => FormatEntryAssignment(entry))
                .ToList()),
            ("Kept Lists", preview.KeptStringListTables
                .OrderBy(item => item.Table, StringComparer.OrdinalIgnoreCase)
                .Select(item => item.Table + ": " + item.ItemCount.ToString(CultureInfo.InvariantCulture) + " item(s)")
                .ToList()),
            ("Preserved Rows", preview.PreservedTableRows
                .OrderBy(item => item.Key, StringComparer.OrdinalIgnoreCase)
                .Select(item => item.Key + ": " + PreviewValue(item.Value))
                .ToList()),
            ("Preserved Lists", preview.PreservedListItems
                .OrderBy(item => item.Table, StringComparer.OrdinalIgnoreCase)
                .ThenBy(item => item.Value, StringComparer.OrdinalIgnoreCase)
                .Select(item => item.Table + ": " + PreviewValue(item.Value))
                .ToList()),
            ("Skipped", preview.SkippedOldValues
                .OrderBy(item => item.Key, StringComparer.OrdinalIgnoreCase)
                .Select(item => item.Key + ": " + PreviewValue(item.Value))
                .ToList())
        };
    }

    private static List<ConfigEntry> GetNewOptionEntries(MizMergePreview preview)
    {
        return preview.NewEntries
            .Where(entry => string.IsNullOrWhiteSpace(entry.ParentKey))
            .ToList();
    }

    private static List<ConfigEntry> GetNewRowEntries(MizMergePreview preview)
    {
        return preview.NewEntries
            .Where(entry => !string.IsNullOrWhiteSpace(entry.ParentKey))
            .ToList();
    }

    private static IReadOnlyList<(string Title, IReadOnlyList<string> Rows)> BuildImportInfoTabs(
        List<ConfigEntry> newDefaults,
        List<ConfigEntry> skippedOldEntries)
    {
        return new List<(string Title, IReadOnlyList<string> Rows)>
        {
            ("New", newDefaults
                .OrderBy(entry => entry.DisplayKey, StringComparer.OrdinalIgnoreCase)
                .Select(entry => entry.DisplayKey + ": " + PreviewValue(entry.ValueText))
                .ToList()),
            ("Skipped", skippedOldEntries
                .OrderBy(entry => entry.DisplayKey, StringComparer.OrdinalIgnoreCase)
                .Select(entry => entry.DisplayKey + ": " + PreviewValue(entry.ValueText))
                .ToList())
        };
    }

    private static string FormatEntryAssignment(ConfigEntry entry)
    {
        return entry.DisplayKey + " = " + PreviewValue(entry.ValueText);
    }

    private static string FormatNewOptionDetail(ConfigEntry entry)
    {
        var lines = new List<string>
        {
            "NEW  " + FormatEntryAssignment(entry)
        };
        var help = entry.EffectiveDescription.Trim();
        if (!string.IsNullOrWhiteSpace(help))
        {
            lines.AddRange(help
                .Split(new[] { "\r\n", "\n" }, StringSplitOptions.None)
                .Where(line => !string.IsNullOrWhiteSpace(line))
                .Select(line => "  " + line.Trim()));
        }

        return string.Join(Environment.NewLine, lines);
    }

    private static void AddPreviewSection(List<string> lines, string title, IEnumerable<string> rows)
    {
        const int limit = 80;
        var listedRows = rows.Take(limit + 1).ToList();
        if (listedRows.Count == 0)
        {
            return;
        }

        lines.Add("");
        lines.Add(title + ":");
        foreach (var row in listedRows.Take(limit))
        {
            lines.Add("  " + row);
        }

        if (listedRows.Count > limit)
        {
            lines.Add("  ...more not shown");
        }
    }

    private static string PreviewValue(string value)
    {
        var text = value
            .Replace("\r\n", "\\n", StringComparison.Ordinal)
            .Replace("\n", "\\n", StringComparison.Ordinal)
            .Replace("\r", "\\n", StringComparison.Ordinal)
            .Trim();
        return text.Length <= 90 ? text : text[..87] + "...";
    }

    private static string PreviewHelp(string value)
    {
        var text = value.Trim();
        return text.Length <= 180 ? text : text[..177] + "...";
    }

    private void SaveConfig()
    {
        if (_document is null)
        {
            return;
        }

        if (IsAdminDesignerSelected())
        {
            _designerSaveAction?.Invoke();
            return;
        }

        if (IsRawCategorySelected())
        {
            ApplyEntryValue();
        }

        if (!HasChanges())
        {
            UpdateEditActionButtonStates();
            SetStatus(_undoStack.Count > 0 ? "No changes to save. Undo is still available." : "No changes to save.");
            return;
        }

        try
        {
            _document.Save();
            _undoCollapseGeneration++;
            RefreshCurrentView(invalidateCachedPanels: false);
            UpdateEditActionButtonStates();
            SetStatus(_undoStack.Count > 0 ? "Saved config. Undo is still available." : "Saved config.");
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Save failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private void SavePreset()
    {
        if (_document is null)
        {
            return;
        }

        var name = _presetBox.Text.Trim();
        if (string.IsNullOrWhiteSpace(name))
        {
            MessageBox.Show(this, "Type a preset name first.", "Save preset", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

        if (IsRawCategorySelected())
        {
            ApplyEntryValue();
        }

        PresetStore.Save(name, _document.Entries);
        LoadPresets();
        _presetBox.Text = name;
        SetStatus("Preset saved.");
    }

    private void ApplyPreset()
    {
        if (_document is null)
        {
            return;
        }

        var name = _presetBox.Text.Trim();
        if (string.IsNullOrWhiteSpace(name))
        {
            return;
        }

        try
        {
            var preset = PresetStore.Load(name);
            var applied = 0;
            var undoValues = new List<(ConfigEntry Entry, string Value)>();
            foreach (var entry in _document.Entries)
            {
                if (!preset.TryGetValue(entry.DisplayKey, out var value))
                {
                    continue;
                }

                if (!StringComparer.Ordinal.Equals(entry.ValueText, value))
                {
                    undoValues.Add((entry, entry.ValueText));
                }

                entry.ValueText = value;
                applied++;
            }

            if (undoValues.Count > 0)
            {
                SetUndoAction("apply preset", () =>
                {
                    foreach (var item in undoValues)
                    {
                        item.Entry.ValueText = item.Value;
                    }
                }, () => RefreshCurrentView());
            }

            RefreshCurrentView();
            SetStatus($"Applied {applied.ToString(CultureInfo.InvariantCulture)} preset values. Use Save to write the config.");
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Apply preset failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private bool HasChanges()
    {
        if (_document is null)
        {
            return false;
        }

        try
        {
            return _document.HasUnsavedChanges;
        }
        catch (InvalidOperationException)
        {
            return true;
        }
    }

    private void RefreshCurrentView(bool invalidateCachedPanels = true)
    {
        if (invalidateCachedPanels)
        {
            MarkAllCategoryPanelsDirty();
        }

        if (IsRawCategorySelected())
        {
            RefreshGrid();
        }
        else
        {
            RenderSelectedCategory(force: invalidateCachedPanels);
        }
    }

    private bool IsRawCategorySelected()
    {
        return string.Equals(GetSelectedCategoryName(), "Raw Values", StringComparison.Ordinal);
    }

    private bool IsAdminDesignerSelected()
    {
        return string.Equals(GetSelectedCategoryName(), "Admin Designer", StringComparison.Ordinal);
    }

    private void SetStatus(string message)
    {
        _status.Text = message;
    }
}
