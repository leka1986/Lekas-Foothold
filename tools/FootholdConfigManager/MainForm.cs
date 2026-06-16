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
    private const int TableActionColumnWidth = 168;
    private const int TableActionButtonWidth = 148;
    private const float BaseFontSize = 9F;
    private const string ToolbarSeparatorTag = "ToolbarSeparator";
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
    private static Color BrandColor = Color.FromArgb(30, 136, 183);

    private sealed record UndoStep(string Description, Action Action, Action? RefreshAction);

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
            var fillColor = Enabled
                ? darkPalette
                    ? (_pressed ? SelectionBackground : _hover ? HeaderBackground : NormalBackColor)
                    : (_pressed ? SelectionBackground : _hover ? HeaderBackground : NormalBackColor)
                : ButtonBackground;
            var textColor = Enabled ? PrimaryTextColor : HelpTextColor;

            e.Graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
            e.Graphics.TextRenderingHint = System.Drawing.Text.TextRenderingHint.ClearTypeGridFit;

            using var fill = new SolidBrush(fillColor);
            e.Graphics.FillRectangle(fill, bounds);
            if (darkPalette)
            {
                var borderColor = Enabled && (_hover || _pressed)
                    ? BrandColor
                    : BorderColor;
                using var border = new Pen(borderColor, _pressed ? 2 : 1);
                e.Graphics.DrawRectangle(border, bounds.X, bounds.Y, bounds.Width - 1, bounds.Height - 1);
            }
            else
            {
                using var border = new Pen(BorderColor);
                e.Graphics.DrawRectangle(border, bounds.X, bounds.Y, bounds.Width - 1, bounds.Height - 1);
            }

            var iconSize = Math.Min(17, Math.Max(13, bounds.Height - 16));
            var iconX = bounds.X + 6;
            var iconY = bounds.Y + Math.Max(0, (bounds.Height - iconSize) / 2);
            var iconBounds = new Rectangle(iconX, iconY, iconSize, iconSize);
            DrawToolbarIcon(e.Graphics, IconKind, iconBounds, textColor);

            var textBounds = new RectangleF(
                iconX + iconSize + 5,
                bounds.Y,
                Math.Max(0, bounds.Width - iconSize - 14),
                bounds.Height);
            using var textBrush = new SolidBrush(textColor);
            using var textFormat = new StringFormat
            {
                Alignment = StringAlignment.Near,
                LineAlignment = StringAlignment.Center,
                Trimming = StringTrimming.EllipsisCharacter,
                FormatFlags = StringFormatFlags.NoWrap
            };
            e.Graphics.DrawString(Text, Font, textBrush, textBounds, textFormat);
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
        public CopyChange(CopyChangeKind kind, string key, string label, string summary)
        {
            Kind = kind;
            Key = key;
            Label = label;
            Summary = summary;
            Id = kind.ToString() + ":" + key;
        }

        public CopyChangeKind Kind { get; }
        public string Key { get; }
        public string Label { get; }
        public string Summary { get; }
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
        public CopyTargetPlan(ServerProfileSettings profile, List<CopyChange> changes, string? loadError = null, bool contentMatches = true)
        {
            Profile = profile;
            Changes = changes;
            LoadError = loadError;
            ContentMatches = contentMatches;
            SelectedChangeIds = changes.Select(change => change.Id).ToHashSet(StringComparer.Ordinal);
            IsTargetSelected = loadError is null;
        }

        public ServerProfileSettings Profile { get; }
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
        public string MizName { get; set; } = "";
        public string MizPath { get; set; } = "";
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
    private Button? _undoButton;
    private readonly List<Control> _topToolbarButtons = new();
    private TableLayoutPanel? _rootLayout;
    private TableLayoutPanel? _topAreaLayout;
    private TableLayoutPanel? _toolbarLayout;
    private TableLayoutPanel? _instanceLayout;
    private TableLayoutPanel? _zoomLayout;
    private SplitContainer? _mainSplit;
    private Panel? _statusPanel;
    private Control? _zoomControl;

    private ConfigDocument? _document;
    private ConfigEntry? _activeEntry;
    private readonly RuntimeSettings _settings = RuntimeSettings.Load();
    private readonly bool _requestAdminOnLoad;
    private bool _adminUnlocked;
    private bool _loadingEntry;
    private bool _loadingForm;
    private bool _loadingInstances;
    private bool _loadingCategories;
    private bool _gridConfigured;
    private bool _rawSearchBound;
    private bool _advancedToggleBound;
    private string? _renderedCategoryName;
    private Control? _rawEditorRoot;
    private readonly Dictionary<string, Control> _categoryPanelCache = new(StringComparer.OrdinalIgnoreCase);
    private readonly HashSet<string> _dirtyCategoryPanels = new(StringComparer.OrdinalIgnoreCase);
    private readonly Dictionary<string, Point> _categoryScrollPositions = new(StringComparer.OrdinalIgnoreCase);
    private readonly Dictionary<string, string> _viewedStageDifficulties = new(StringComparer.Ordinal);
    private readonly List<(ConfigTupleField Field, Control Control)> _tupleControls = new();
    private Action? _designerSaveAction;
    private string? _designerSelectedKey;
    private string? _designerSelectedCategory;
    private string? _hoverStatusRestore;
    private int _brandClickCount;
    private DateTime _lastBrandClickUtc = DateTime.MinValue;
    private readonly Stack<UndoStep> _undoStack = new();
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
        EnableMizDragDrop();
        FormClosing += (_, _) => SaveWindowSize();
        Load += (_, _) =>
        {
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
        UpdateFooterLabels();
        UpdateThemeButtonState();
        UpdateUndoButtonState();
        LayoutStatusBar();
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

            case Label label:
                label.BackColor = MainBackground;
                label.ForeColor = PrimaryTextColor;
                break;

            case SplitContainer split:
                split.BackColor = BorderColor;
                split.Panel1.BackColor = MainBackground;
                split.Panel2.BackColor = MainBackground;
                break;

            default:
                if (control is Panel or TableLayoutPanel or FlowLayoutPanel or TabControl or TabPage)
                {
                    control.BackColor = MainBackground;
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
        if (_themeButton is null)
        {
            return;
        }

        _themeButton.BackColor = MainBackground;
        _themeButton.ForeColor = PrimaryTextColor;
        _themeButton.SetDarkMode(_darkMode);
        _toolTip.SetToolTip(_themeButton, _darkMode ? "Switch to light mode." : "Switch to dark mode.");
    }

    private void UpdateUndoButtonState()
    {
        if (_undoButton is null)
        {
            return;
        }

        _undoButton.Enabled = _undoStack.Count > 0;
        StyleButton(_undoButton);
        if (_undoButton.Enabled)
        {
            _undoButton.BackColor = UndoBackground;
            _undoButton.ForeColor = PrimaryTextColor;
        }
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
        actions.Controls.Add(MakeToolbarButton("Import Config File", ImportValuesFromOldConfig, "Import config values from another Foothold Config.lua file.", ToolbarIconKind.Import));
        actions.Controls.Add(MakeToolbarButton("Import MIZ Config", InstallConfigFromMiz, "Import Foothold Config.lua from a .miz file.", ToolbarIconKind.Install));
        actions.Controls.Add(MakeToolbarButton("Restore Defaults", RestoreConfigDefaults, "Restore from a default Foothold Config.lua previously stored during Import MIZ Config.", ToolbarIconKind.Restore));
        actions.Controls.Add(MakeToolbarSeparator());
        _undoButton = MakeToolbarButton("Undo", UndoLastChange, "Revert the last unsaved edit, add, or remove action.");
        UpdateUndoButtonState();
        SizeTopToolbarButton(_undoButton, 100);
        _topToolbarButtons.Add(_undoButton);
        actions.Controls.Add(_undoButton);
        actions.Controls.Add(MakeToolbarButton("Save", SaveConfig, "Write pending changes to the current config.", ToolbarIconKind.Save));
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
        button.Margin = new Padding(1, Zoomed(2), 1, 0);
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
            "Undo" => 60,
            "Save" => 60,
            _ => 60
        };
    }

    private void ApplyToolbarSeparatorSizing(Control control)
    {
        if (Equals(control.Tag, ToolbarSeparatorTag))
        {
            control.Width = Zoomed(1);
            control.Height = Math.Max(Zoomed(24), Font.Height + Zoomed(6));
            control.Margin = new Padding(Zoomed(5), Zoomed(5), Zoomed(5), 0);
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
        var panel = new TableLayoutPanel { Dock = DockStyle.Fill, ColumnCount = 7, BackColor = MainBackground };
        _instanceLayout = panel;
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, LabelColumnWidth("Instance", 70)));
        panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
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
        _showAdvanced.Text = "Advanced";
        _showAdvanced.Dock = DockStyle.Fill;
        BindAdvancedToggle();
        panel.Controls.Add(_showAdvanced, 2, 0);
        panel.Controls.Add(MakeInstanceToolbarButton("Open File Location", OpenCurrentConfigLocation, "Open Explorer with the current Foothold config selected."), 3, 0);
        panel.Controls.Add(MakeInstanceToolbarButton("Add", AddInstance, "Add another Foothold config instance."), 4, 0);
        panel.Controls.Add(MakeInstanceToolbarButton("Remove", RemoveInstance, "Remove the selected instance from this list. The config file is not deleted."), 5, 0);
        panel.Controls.Add(MakeInstanceToolbarButton("Copy To...", CopyCurrentConfigToInstances, "Replace selected instance configs with the currently open saved config. No backup is created."), 6, 0);
        RefreshInstanceList();
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
        // 6 left + 17 icon + 5 gap + text + 6 right = text + 34
        return Math.Max(Zoomed(minimum), TextRenderer.MeasureText(text, font).Width + Zoomed(34));
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
            SetColumnWidth(_instanceLayout, 2, ShouldShowAdvancedToggle() ? ToolbarButtonWidth("Advanced", 105) : 0);
            SetColumnWidth(_instanceLayout, 3, ToolbarButtonWidth("Open File Location", 150));
            SetColumnWidth(_instanceLayout, 4, ToolbarButtonWidth("Add", 90));
            SetColumnWidth(_instanceLayout, 5, ToolbarButtonWidth("Remove", 100));
            SetColumnWidth(_instanceLayout, 6, ToolbarButtonWidth("Copy To...", 110));
        }

        if (_mainSplit is not null)
        {
            var desiredWidth = Zoomed(250);
            var maxWidth = Math.Max(Zoomed(210), ClientSize.Width / 3);
            _mainSplit.SplitterDistance = Math.Min(desiredWidth, maxWidth);
        }

        if (_zoomLayout is not null)
        {
            _zoomLayout.Width = Zoomed(252);
            _zoomLayout.Height = Zoomed(32);
            SetColumnWidth(_zoomLayout, 1, ToolbarButtonWidth("A-", 42));
            SetColumnWidth(_zoomLayout, 2, Math.Max(Zoomed(62), TextRenderer.MeasureText("150%", Font).Width + Zoomed(16)));
            SetColumnWidth(_zoomLayout, 3, ToolbarButtonWidth("A+", 42));
            SetColumnWidth(_zoomLayout, 4, Zoomed(10));
            SetColumnWidth(_zoomLayout, 5, Zoomed(36));
        }

        LayoutFooterLinks();
        LayoutStatusBar();
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

        var zoomControl = BuildZoomStatusControl();
        _zoomControl = zoomControl;
        panel.Controls.Add(zoomControl);

        _footerLinks.Dock = DockStyle.Right;
        _footerLinks.FlowDirection = FlowDirection.LeftToRight;
        _footerLinks.WrapContents = false;
        _footerLinks.AutoSize = false;
        _footerLinks.Height = Zoomed(32);
        _footerLinks.Padding = new Padding(0);
        _footerLinks.Margin = new Padding(0);
        _footerLinks.BackColor = MainBackground;

        _brandLabel.Text = "By Leka";
        _brandLabel.AutoSize = true;
        _brandLabel.TextAlign = ContentAlignment.MiddleLeft;
        _brandLabel.ForeColor = BrandColor;
        _brandLabel.Cursor = Cursors.Hand;
        _brandLabel.Margin = new Padding(0, Zoomed(7), Zoomed(10), 0);
        _brandLabel.Click += (_, _) => HandleBrandClick();
        _toolTip.SetToolTip(_brandLabel, "Triple-click to open the admin password prompt.");
        _footerLinks.Controls.Add(_brandLabel);

        _footerVersionLabel.AutoSize = true;
        _footerVersionLabel.TextAlign = ContentAlignment.MiddleLeft;
        _footerVersionLabel.ForeColor = PrimaryTextColor;
        _footerVersionLabel.Margin = new Padding(0, Zoomed(7), Zoomed(10), 0);
        _footerLinks.Controls.Add(_footerVersionLabel);

        _discordLabel.Text = "Discord";
        _discordLabel.AutoSize = true;
        _discordLabel.TextAlign = ContentAlignment.MiddleLeft;
        _discordLabel.ForeColor = BrandColor;
        _discordLabel.Cursor = Cursors.Hand;
        _discordLabel.Margin = new Padding(0, Zoomed(7), 0, 0);
        _discordLabel.Click += (_, _) => OpenDiscordInvite();
        _toolTip.SetToolTip(_discordLabel, "Open Foothold Discord.");
        _footerLinks.Controls.Add(_discordLabel);
        UpdateFooterLabels();
        panel.Controls.Add(_footerLinks);

        panel.Resize += (_, _) => LayoutStatusBar();
        panel.HandleCreated += (_, _) => LayoutStatusBar();
        _footerLinks.BringToFront();
        zoomControl.BringToFront();

        return panel;
    }

    private void LayoutStatusBar()
    {
        if (_statusPanel is null || _zoomControl is null)
        {
            return;
        }

        _zoomControl.Left = Math.Max(0, (_statusPanel.ClientSize.Width - _zoomControl.Width) / 2);
        _zoomControl.Top = Math.Max(0, (_statusPanel.ClientSize.Height - _zoomControl.Height) / 2);
    }

    private void UpdateFooterLabels()
    {
        _footerLinks.BackColor = MainBackground;
        _brandLabel.BackColor = MainBackground;
        _brandLabel.ForeColor = BrandColor;
        _footerVersionLabel.BackColor = MainBackground;
        _footerVersionLabel.ForeColor = PrimaryTextColor;
        _discordLabel.BackColor = MainBackground;
        _discordLabel.ForeColor = BrandColor;

        var version = _document?.Metadata.FooterVersion?.Trim() ?? "";
        _footerVersionLabel.Text = version;
        _footerVersionLabel.Visible = !string.IsNullOrWhiteSpace(version);
        LayoutFooterLinks();
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
        button.AutoEllipsis = true;
        button.Click += (_, _) => action();
        SetToolbarHelp(button, helpText);
        return button;
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
                    Point(7.0F, 5.0F),
                    Point(3.5F, 8.5F),
                    Point(7.0F, 12.0F)
                });
                graphics.DrawArc(pen, Rect(5.0F, 5.0F, 10.0F, 8.0F), 185, 235);
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
                RenderSelectedCategory();
            }
        };
        split.Panel1.BackColor = MainBackground;
        split.Panel1.Controls.Add(_categoryList);

        _formHost.Dock = DockStyle.Fill;
        _formHost.AutoScroll = true;
        _formHost.BackColor = MainBackground;
        _formHost.MouseDown += HandleBackgroundMouseDown;
        split.Panel2.BackColor = MainBackground;
        split.Panel2.Controls.Add(_formHost);
        return split;
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

        var textBounds = new Rectangle(
            args.Bounds.X + Zoomed(8),
            args.Bounds.Y,
            Math.Max(0, args.Bounds.Width - Zoomed(12)),
            args.Bounds.Height);
        TextRenderer.DrawText(
            args.Graphics,
            list.Items[args.Index]?.ToString() ?? "",
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
                var added = AddDetectedInstances(savedGamesConfigs);
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
            SetStatus("Foothold Config.lua was not found. Place it in a Saved Games DCS Missions\\Saves folder, or use Open.");
            return;
        }

        LoadConfig(path);
    }

    private void OpenConfig()
    {
        using var dialog = new OpenFileDialog
        {
            Filter = "Lua config (*.lua)|*.lua|All files (*.*)|*.*",
            FileName = "Foothold Config.lua",
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
            ClearCategoryPanelCache();
            _viewedStageDifficulties.Clear();
            _document = ConfigDocument.Load(path);
            _pathBox.Text = path;
            LoadSections();
            LoadPresets();
            ApplyAdvancedToggleVisibility();
            UpdateFooterLabels();
            LoadCategories();
            _settings.RememberConfig(path);
            RefreshInstanceList();
            ClearUndo();
            SetStatus($"Loaded {_document.Entries.Count.ToString(CultureInfo.InvariantCulture)} editable values.");
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Load failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
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
            MessageBox.Show(this, "That instance config was not found:" + Environment.NewLine + targetPath, "Switch Instance", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            RefreshInstanceList();
            return;
        }

        LoadConfig(targetPath);
    }

    private void AddInstance()
    {
        using var dialog = new OpenFileDialog
        {
            Title = "Select Foothold Config.lua for this instance",
            Filter = "Lua config (*.lua)|*.lua|All files (*.*)|*.*",
            FileName = "Foothold Config.lua",
            InitialDirectory = _document is null
                ? RuntimeSettings.GetBestInitialDirectory()
                : Path.GetDirectoryName(_document.Path)
        };

        if (dialog.ShowDialog(this) != DialogResult.OK)
        {
            return;
        }

        var path = Path.GetFullPath(dialog.FileName);
        var existing = _settings.ServerProfiles.FirstOrDefault(profile => Path.GetFullPath(profile.ConfigPath).Equals(path, StringComparison.OrdinalIgnoreCase));
        var name = PromptForText("Add Instance", "Instance name", existing?.Name ?? GuessInstanceName(path))?.Trim();
        if (string.IsNullOrWhiteSpace(name))
        {
            return;
        }

        if (_settings.ServerProfiles.Any(profile =>
                !Path.GetFullPath(profile.ConfigPath).Equals(path, StringComparison.OrdinalIgnoreCase) &&
                profile.Name.Equals(name, StringComparison.OrdinalIgnoreCase)))
        {
            MessageBox.Show(this, "An instance with that name already exists.", "Add Instance", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return;
        }

        if (existing is not null)
        {
            existing.Name = name;
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

    private int AddDetectedInstances(List<string> paths)
    {
        var existingNames = _settings.ServerProfiles
            .Select(profile => profile.Name)
            .ToHashSet(StringComparer.OrdinalIgnoreCase);
        var added = 0;
        foreach (var path in paths.Select(Path.GetFullPath).Distinct(StringComparer.OrdinalIgnoreCase))
        {
            if (_settings.ServerProfiles.Any(profile => Path.GetFullPath(profile.ConfigPath).Equals(path, StringComparison.OrdinalIgnoreCase)))
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
        var targets = _settings.ServerProfiles
            .Where(profile => !Path.GetFullPath(profile.ConfigPath).Equals(sourcePath, StringComparison.OrdinalIgnoreCase))
            .OrderBy(profile => profile.Name, StringComparer.OrdinalIgnoreCase)
            .ToList();
        if (targets.Count == 0)
        {
            MessageBox.Show(this, "Add at least one other instance first.", "Copy To Instances", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

        var plans = targets.Select(target => BuildCopyTargetPlan(_document, target)).ToList();
        var selectedPlans = PromptForCopyTargets(plans);
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

    private CopyTargetPlan BuildCopyTargetPlan(ConfigDocument sourceDocument, ServerProfileSettings target)
    {
        try
        {
            if (!File.Exists(target.ConfigPath))
            {
                return new CopyTargetPlan(target, new List<CopyChange>(), "Config file was not found.");
            }

            var targetDocument = ConfigDocument.Load(target.ConfigPath);
            var contentMatches = NormalizeCopyText(File.ReadAllText(sourceDocument.Path)).Equals(
                NormalizeCopyText(File.ReadAllText(target.ConfigPath)),
                StringComparison.Ordinal);
            return new CopyTargetPlan(target, BuildCopyChanges(sourceDocument, targetDocument), contentMatches: contentMatches);
        }
        catch (Exception ex)
        {
            return new CopyTargetPlan(target, new List<CopyChange>(), ex.Message);
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
            changes.Add((sourceEntry.LineIndex, new CopyChange(CopyChangeKind.Entry, sourceEntry.DisplayKey, sourceEntry.DisplayName, summary)));
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

        changes.Add((order, new CopyChange(CopyChangeKind.Table, key, label, targetHasTable ? "table changed" : "table added")));
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

    private void ApplyCopyPlan(string sourcePath, CopyTargetPlan plan)
    {
        var selectedChanges = plan.Changes.Where(change => plan.SelectedChangeIds.Contains(change.Id)).ToList();
        if (plan.Changes.Count == 0)
        {
            File.Copy(sourcePath, plan.Profile.ConfigPath, overwrite: true);
            return;
        }

        if (selectedChanges.Count == 0)
        {
            return;
        }

        if (selectedChanges.Count == plan.Changes.Count)
        {
            File.Copy(sourcePath, plan.Profile.ConfigPath, overwrite: true);
            return;
        }

        var originalTarget = ConfigDocument.Load(plan.Profile.ConfigPath);
        File.Copy(sourcePath, plan.Profile.ConfigPath, overwrite: true);
        var output = ConfigDocument.Load(plan.Profile.ConfigPath);
        foreach (var change in plan.Changes.Where(change => !plan.SelectedChangeIds.Contains(change.Id)))
        {
            if (change.Kind == CopyChangeKind.Entry)
            {
                var oldEntry = originalTarget.Entries.FirstOrDefault(entry => entry.DisplayKey.Equals(change.Key, StringComparison.Ordinal));
                var outputEntry = output.Entries.FirstOrDefault(entry => entry.DisplayKey.Equals(change.Key, StringComparison.Ordinal));
                if (outputEntry is null)
                {
                    continue;
                }

                if (oldEntry is null)
                {
                    output.RemoveEntry(outputEntry);
                    continue;
                }

                outputEntry.ValueText = oldEntry.ValueText;
                continue;
            }

            if (!output.ReplaceTableBlockFrom(originalTarget, change.Key))
            {
                output.RemoveTableBlock(change.Key);
            }
        }

        output.Save();
    }

    private List<CopyTargetPlan>? PromptForCopyTargets(List<CopyTargetPlan> plans)
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
            Text = "Select instances to replace with the currently open config. No backup will be created.",
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
                return "Cannot read config";
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

        void RebuildRows()
        {
            rows.SuspendLayout();
            try
            {
                rows.Controls.Clear();
                rows.RowStyles.Clear();
                rows.RowCount = 0;

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
                        plan.IsTargetSelected = targetCheck.Checked;
                        RebuildRows();
                    };
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

                    targetRow.Controls.Add(new Label
                    {
                        Text = TargetSummary(plan),
                        Dock = DockStyle.Fill,
                        TextAlign = ContentAlignment.MiddleLeft,
                        AutoEllipsis = true,
                        BackColor = MainBackground,
                        ForeColor = plan.LoadError is null ? HelpTextColor : Color.Firebrick
                    }, 2, 0);

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
                        ColumnCount = 3,
                        Padding = new Padding(Zoomed(32), 0, 0, Zoomed(8)),
                        BackColor = MainBackground
                    };
                    detailPanel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, Zoomed(28)));
                    detailPanel.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, Zoomed(300)));
                    detailPanel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));

                    if (plan.LoadError is not null)
                    {
                        detailPanel.Controls.Add(new Label
                        {
                            Text = plan.LoadError,
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
                                Enabled = plan.IsTargetSelected,
                                Dock = DockStyle.Fill,
                                Margin = new Padding(0),
                                BackColor = MainBackground,
                                ForeColor = PrimaryTextColor
                            };
                            changeCheck.CheckedChanged += (_, _) =>
                            {
                                if (changeCheck.Checked)
                                {
                                    plan.SelectedChangeIds.Add(change.Id);
                                }
                                else
                                {
                                    plan.SelectedChangeIds.Remove(change.Id);
                                }

                                RebuildRows();
                            };
                            detailPanel.Controls.Add(changeCheck, 0, detailRow);
                            detailPanel.Controls.Add(new Label
                            {
                                Text = change.Label,
                                Dock = DockStyle.Fill,
                                AutoEllipsis = true,
                                TextAlign = ContentAlignment.MiddleLeft,
                                BackColor = MainBackground,
                                ForeColor = PrimaryTextColor
                            }, 1, detailRow);
                            detailPanel.Controls.Add(new Label
                            {
                                Text = change.Summary,
                                Dock = DockStyle.Fill,
                                AutoEllipsis = true,
                                TextAlign = ContentAlignment.MiddleLeft,
                                BackColor = MainBackground,
                                ForeColor = HelpTextColor
                            }, 2, detailRow);
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

            copyButton.Enabled = plans.Any(plan => plan.IsTargetSelected && plan.LoadError is null && (plan.Changes.Count == 0 || plan.SelectedChangeCount > 0));
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
            .Where(plan => plan.IsTargetSelected && plan.LoadError is null && (plan.Changes.Count == 0 || plan.SelectedChangeCount > 0))
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

        return IsFixedCategory(categoryName) || ShouldShowDynamicCategory(categoryName);
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
            Dock = DockStyle.Top,
            AutoSize = true,
            FlowDirection = FlowDirection.LeftToRight,
            WrapContents = false,
            Padding = GetTableHeaderPadding()
        };

        var label = new Label
        {
            Text = entry.DisplayName,
            AutoSize = true,
            TextAlign = ContentAlignment.MiddleLeft,
            Margin = GetTableHeaderLabelMargin(),
            ForeColor = PrimaryTextColor,
            BackColor = MainBackground
        };
        SetHelp(label, entry);
        header.Controls.Add(label);

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
            Padding = new Padding(0, 4, 0, 0)
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
        if (!StringComparer.Ordinal.Equals(entry.ValueText, oldValue))
        {
            SetUndoAction(description, () => entry.ValueText = oldValue, refreshAction);
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

    private Control BuildStringListEditor(ConfigStringListTable table)
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
            MakeDesignerButton("Add item", () => AddStringListItemRow(table, grid), TableActionButtonWidth),
            MakeDesignerButton("Remove selected", () => RemoveStringListItemRow(table, grid), TableActionButtonWidth)), 1, 1);

        grid.SuspendLayout();
        try
        {
            foreach (var item in GetStringListItemsInSourceOrder(table))
            {
                var rowIndex = grid.Rows.Add(item.Value);
                grid.Rows[rowIndex].Tag = item;
            }
        }
        finally
        {
            grid.ResumeLayout();
        }

        ApplyCompactTableLayout(group, grid, 220, 640, GetTableHeightPadding(76));
        return group;
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

    private void AddStringListItemRow(ConfigStringListTable table, DataGridView? grid)
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
            RefreshStringListGrid(grid, table);
            SelectGridRowByTag(grid, item);
            SetUndoAction("add " + value.Trim(), () =>
            {
                _document.RemoveStringListItem(table, item);
                RefreshStringListGrid(grid, table);
            });
            SetChangedStatus();
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Add item failed", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
    }

    private void RemoveStringListItemRow(ConfigStringListTable table, DataGridView? grid)
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
            RefreshStringListGrid(grid, table);
            SelectGridRowByIndex(grid, selectedIndex);
            SetUndoAction("remove " + removedValue, () =>
            {
                var restored = _document.AddStringListItem(table, removedValue);
                RefreshStringListGrid(grid, table);
                SelectGridRowByTag(grid, restored);
            });
            SetChangedStatus();
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
                SetUndoAction("edit " + entry.DisplayName, () => entry.ValueText = oldValue, () => RefreshTableGrid(grid, entries));
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

    private void RefreshStringListGrid(DataGridView grid, ConfigStringListTable table)
    {
        var items = GetStringListItemsInSourceOrder(table);
        SyncGridRows(grid, items, AddStringListGridRow, UpdateStringListGridRow);

        if (grid.Parent is TableLayoutPanel group)
        {
            ApplyCompactTableLayout(group, grid, 220, 640, GetTableHeightPadding(76));
        }
    }

    private static List<ConfigStringListItem> GetStringListItemsInSourceOrder(ConfigStringListTable table)
    {
        return table.Items
            .OrderBy(item => item.LineIndex)
            .ThenBy(item => item.StartIndex)
            .ToList();
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
        grid.Columns["callsign"].ReadOnly = true;
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
        grid.CellValueChanged += (_, args) =>
        {
            if (_loadingForm || args.RowIndex < 0 || grid.Rows[args.RowIndex].Tag is not ConfigEntry entry)
            {
                return;
            }

            var oldValue = entry.ValueText;
            ApplyCallsignOverrideRow(grid.Rows[args.RowIndex], entry);
            if (!StringComparer.Ordinal.Equals(entry.ValueText, oldValue))
            {
                SetUndoAction("edit " + entry.DisplayName, () => entry.ValueText = oldValue, () => RefreshCallsignGrid(grid, entries));
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

    private static void AddCallsignGridRow(DataGridView grid, ConfigEntry entry)
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
    }

    private static void UpdateCallsignGridRow(DataGridViewRow row, ConfigEntry entry)
    {
        var values = entry.GetTupleValues();
        row.Cells["aircraft"].Value = GetCallsignAircraft(entry);
        row.Cells["callsign"].Value = entry.Key;
        row.Cells["iff1"].Value = values.Count > 0 ? values[0] : "";
        row.Cells["iff2"].Value = values.Count > 1 ? values[1] : "";
        row.Cells["iff3"].Value = values.Count > 2 ? values[2] : "";
        row.Cells["iff4"].Value = values.Count > 3 ? values[3] : "";
        row.Tag = entry;
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

    private static void AddTableRow(DataGridView grid, ConfigEntry entry)
    {
        if (IsPriceRankEntry(entry) && TryReadPriceRank(entry.ValueText, out var price, out var rank))
        {
            var priceRankIndex = grid.Rows.Add(entry.Key, price, rank);
            grid.Rows[priceRankIndex].Tag = entry;
            ApplyTableRowTooltip(grid.Rows[priceRankIndex], entry);
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
            return;
        }

        var rowIndex = grid.Rows.Add(entry.Key, "");
        var row = grid.Rows[rowIndex];
        ApplyTableValueCell(row, entry);
        row.Tag = entry;
        ApplyTableRowTooltip(row, entry);
    }

    private static void UpdateTableGridRow(DataGridViewRow row, ConfigEntry entry)
    {
        if (IsPriceRankEntry(entry) && TryReadPriceRank(entry.ValueText, out var price, out var rank))
        {
            row.Cells["name"].Value = entry.Key;
            row.Cells["price"].Value = price;
            row.Cells["rank"].Value = rank;
            row.Tag = entry;
            ApplyTableRowTooltip(row, entry);
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
            return;
        }

        ApplyTableValueCell(row, entry);
        row.Tag = entry;
        ApplyTableRowTooltip(row, entry);
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

        if (_document is not null)
        {
            foreach (var name in _document.Metadata.CategoryOrder)
            {
                if (!string.IsNullOrWhiteSpace(name) && !names.Contains(name, StringComparer.OrdinalIgnoreCase))
                {
                    names.Add(name);
                }
            }
        }

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

        if (_document is not null)
        {
            foreach (var name in _document.Metadata.CategoryOrder)
            {
                if (!string.IsNullOrWhiteSpace(name) && !names.Contains(name, StringComparer.OrdinalIgnoreCase))
                {
                    names.Add(name);
                }
            }

            foreach (var name in _document.Metadata.HiddenCategories)
            {
                if (!string.IsNullOrWhiteSpace(name) && !names.Contains(name, StringComparer.OrdinalIgnoreCase))
                {
                    names.Add(name);
                }
            }

            foreach (var name in _document.Metadata.CategoryLayouts.Keys)
            {
                if (!string.IsNullOrWhiteSpace(name) && !names.Contains(name, StringComparer.OrdinalIgnoreCase))
                {
                    names.Add(name);
                }
            }

            foreach (var name in GetConfigCategoryNamesInSourceOrder())
            {
                if (!names.Contains(name, StringComparer.OrdinalIgnoreCase))
                {
                    names.Add(name);
                }
            }
        }

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
            UpdateUndoButtonState();
            return;
        }

        ClearUndo();
        SetStatus("No pending changes.");
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
        UpdateUndoButtonState();
    }

    private void ClearUndo()
    {
        _undoStack.Clear();
        UpdateUndoButtonState();
    }

    private void UndoLastChange()
    {
        if (_undoStack.Count == 0)
        {
            SetStatus("No editor change to undo.");
            return;
        }

        var step = _undoStack.Pop();
        UpdateUndoButtonState();

        try
        {
            _restoringUndo = true;
            step.Action();
            // Undo actions refresh the specific cached control/grid they changed.
            // Broad cache invalidation belongs in RefreshCurrentView callers.
            step.RefreshAction?.Invoke();
            SetStatus(HasChanges()
                ? "Undid " + step.Description + ". Use Save to write the config."
                : "Undid " + step.Description + ". No pending changes.");
            if (!HasChanges())
            {
                ClearUndo();
            }
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Undo failed", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
        finally
        {
            _restoringUndo = false;
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
            var extractedConfigPath = ExtractFootholdConfigFromMiz(mizPath, tempDir);
            var currentDocument = _document;
            var newDocument = ConfigDocument.Load(extractedConfigPath);
            newDocument.RepairStringListSeparators();
            if (!ValidateInstallMizDocument(newDocument, "The Foothold Config.lua inside this MIZ"))
            {
                return;
            }

            var preview = MergeCurrentConfigIntoNewConfig(currentDocument, newDocument);
            if (!ValidateInstallMizDocument(newDocument, "The merged MIZ config"))
            {
                return;
            }

            var previewText = BuildMizInstallPreviewText(mizPath, currentDocument.Path, preview);
            var choices = preview.KeptValues
                .Select(item => new SelectableValueChoice(item.Key, item.CurrentValue, item.NewDefault, item.Entry.EffectiveDescription))
                .ToList();
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

            for (var i = 0; i < choices.Count; i++)
            {
                if (!choices[i].Selected)
                {
                    preview.KeptValues[i].Entry.ValueText = preview.KeptValues[i].NewDefault;
                }
            }

            if (!ValidateInstallMizDocument(newDocument, "The final imported MIZ config"))
            {
                return;
            }

            var storedDefaults = StoreMizDefaults(mizPath, extractedConfigPath);
            newDocument.SaveTo(currentDocument.Path);
            LoadConfig(currentDocument.Path);
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

    private static string ExtractFootholdConfigFromMiz(string mizPath, string tempDir)
    {
        using var archive = ZipFile.OpenRead(mizPath);
        var entry = archive.Entries
            .Where(item => Path.GetFileName(item.FullName).Equals("Foothold Config.lua", StringComparison.OrdinalIgnoreCase))
            .OrderBy(item => item.FullName.Contains("l10n/DEFAULT", StringComparison.OrdinalIgnoreCase) ? 0 : 1)
            .ThenBy(item => item.FullName.Length)
            .FirstOrDefault();
        if (entry is null)
        {
            throw new InvalidOperationException("Foothold Config.lua was not found inside this MIZ.");
        }

        var targetPath = Path.Combine(tempDir, "Foothold Config.lua");
        using var input = entry.Open();
        using var output = File.Create(targetPath);
        input.CopyTo(output);
        return targetPath;
    }

    private static StoredMizDefaultsInfo StoreMizDefaults(string mizPath, string extractedConfigPath)
    {
        Directory.CreateDirectory(StoredDefaultsDirectory);
        var index = LoadStoredMizDefaultsIndex();
        var storedAt = DateTime.Now;
        var mizName = Path.GetFileName(mizPath);
        var id = storedAt.ToString("yyyyMMdd-HHmmss", CultureInfo.InvariantCulture) + "-" + MakeSafeFileName(Path.GetFileNameWithoutExtension(mizName));
        var configPath = Path.Combine(StoredDefaultsDirectory, id + ".lua");

        File.Copy(extractedConfigPath, configPath, overwrite: true);
        var info = new StoredMizDefaultsInfo
        {
            Id = id,
            MizName = mizName,
            MizPath = Path.GetFullPath(mizPath),
            ConfigPath = configPath,
            StoredAt = storedAt
        };

        index.Items.RemoveAll(item => item.Id.Equals(info.Id, StringComparison.OrdinalIgnoreCase));
        index.Items.Insert(0, info);
        index.Items = index.Items
            .Where(item => !string.IsNullOrWhiteSpace(item.ConfigPath) && File.Exists(item.ConfigPath))
            .OrderByDescending(item => item.StoredAt)
            .Take(20)
            .ToList();
        SaveStoredMizDefaultsIndex(index);
        return info;
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

        var defaults = LoadStoredMizDefaultsIndex().Items
            .Where(item => !string.IsNullOrWhiteSpace(item.ConfigPath) && File.Exists(item.ConfigPath))
            .OrderByDescending(item => item.StoredAt)
            .ToList();
        if (defaults.Count == 0)
        {
            MessageBox.Show(this, "No stored MIZ defaults were found. Use Import MIZ Config once to store defaults first.", "Restore Defaults", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

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
        if (!ValidateMergeDocument(defaultDocument, "Restore Defaults validation failed", "The stored MIZ defaults"))
        {
            return;
        }

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
            selection.Defaults.MizName +
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
            Text = "Select stored defaults, then choose the categories or entries to restore. Changed entries are selected by default.",
            Dock = DockStyle.Fill,
            TextAlign = ContentAlignment.MiddleLeft,
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        }, 0, 0);

        var sourceRow = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            RowCount = 1,
            ColumnCount = 2,
            BackColor = MainBackground,
            Margin = new Padding(0)
        };
        sourceRow.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, Zoomed(110)));
        sourceRow.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
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
        foreach (var item in defaults)
        {
            sourceBox.Items.Add(FormatStoredMizDefaults(item));
        }

        if (sourceBox.Items.Count > 0)
        {
            sourceBox.SelectedIndex = 0;
        }

        sourceRow.Controls.Add(sourceBox, 1, 0);
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

        var changingChecks = false;

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
                if (sourceBox.SelectedIndex < 0)
                {
                    status.Text = "No stored defaults selected.";
                    restoreButton.Enabled = false;
                    return;
                }

                var defaultDocument = ConfigDocument.Load(defaults[sourceBox.SelectedIndex].ConfigPath);
                defaultDocument.RepairStringListSeparators();
                var errors = defaultDocument.Validate();
                if (errors.Count > 0)
                {
                    status.Text = "Stored defaults failed validation: " + errors[0];
                    restoreButton.Enabled = false;
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
                status.Text = "Could not load stored defaults: " + ex.Message;
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

        sourceBox.SelectedIndexChanged += (_, _) => LoadSelectedDefaults();
        LoadSelectedDefaults();

        ApplyDialogChrome(dialog);
        dialog.AcceptButton = restoreButton;
        dialog.CancelButton = cancelButton;
        if (dialog.ShowDialog(this) != DialogResult.OK || sourceBox.SelectedIndex < 0)
        {
            return null;
        }

        var selectedItems = GetSelectedItems();
        return selectedItems.Count == 0
            ? null
            : new RestoreDefaultsSelection(defaults[sourceBox.SelectedIndex], selectedItems);
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
        return info.StoredAt.ToString("yyyy-MM-dd HH:mm", CultureInfo.InvariantCulture) + "  " + info.MizName;
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

            if (newDocument.ReplaceTableBodyFrom(currentDocument, newTable.Key))
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
            MessageBox.Show(this, "Save or reload pending changes before importing values from another config.", "Import Values", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return;
        }

        using var dialog = new OpenFileDialog
        {
            Title = "Select old Foothold Config.lua",
            Filter = "Lua config (*.lua)|*.lua|All files (*.*)|*.*",
            FileName = "Foothold Config.lua",
            InitialDirectory = Path.GetDirectoryName(_document.Path)
        };

        if (dialog.ShowDialog(this) != DialogResult.OK)
        {
            return;
        }

        try
        {
            var currentPath = Path.GetFullPath(_document.Path);
            var oldPath = Path.GetFullPath(dialog.FileName);
            if (string.Equals(currentPath, oldPath, StringComparison.OrdinalIgnoreCase))
            {
                MessageBox.Show(this, "Select the old config file, not the config that is already open.", "Import Values", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }

            var originalDocument = _document;
            var importedDocument = ConfigDocument.Load(oldPath);
            importedDocument.RepairStringListSeparators();
            if (!ValidateMergeDocument(importedDocument, "Import Values validation failed", "The selected config"))
            {
                return;
            }

            var mergedDocument = ConfigDocument.Load(currentPath);
            var preview = MergeCurrentConfigIntoNewConfig(importedDocument, mergedDocument);
            if (!ValidateMergeDocument(mergedDocument, "Import Values validation failed", "The merged Import Values config"))
            {
                return;
            }

            if (preview.KeptValues.Count == 0 &&
                preview.UnchangedCount == 0 &&
                preview.KeptStringListTables.Count == 0 &&
                preview.PreservedTableRows.Count == 0 &&
                preview.PreservedListItems.Count == 0)
            {
                MessageBox.Show(this, "No matching config keys were found in the old config.", "Import Values", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }

            var previewText = BuildImportMergePreviewText(oldPath, currentPath, preview);
            var choices = preview.KeptValues
                .Select(item => new SelectableValueChoice(item.Key, item.CurrentValue, item.NewDefault, item.Entry.EffectiveDescription))
                .ToList();
            if (!ConfirmSelectableValuePreview(
                    previewText,
                    "Import Values Preview",
                    "Tick rows to import values from the selected config. Untick rows to keep current values.",
                    "Import",
                    "Imported value",
                    "Current value",
                    "Import selected values",
                    "Keep current values",
                    choices,
                    BuildMizInstallInfoTabs(preview)))
            {
                return;
            }

            for (var i = 0; i < choices.Count; i++)
            {
                if (!choices[i].Selected)
                {
                    preview.KeptValues[i].Entry.ValueText = preview.KeptValues[i].NewDefault;
                }
            }

            if (!ValidateMergeDocument(mergedDocument, "Import Values validation failed", "The final Import Values config"))
            {
                return;
            }

            _document = mergedDocument;
            ClearCategoryPanelCache();
            LoadSections();
            ApplyAdvancedToggleVisibility();
            LoadCategories();
            SetUndoAction("import values", () =>
            {
                _document = originalDocument;
                ClearCategoryPanelCache();
                LoadSections();
                ApplyAdvancedToggleVisibility();
                LoadCategories();
            }, () => RefreshCurrentView());

            RefreshCurrentView();
            SetStatus("Imported merged values from selected config. Use Save to write the config.");
        }
        catch (Exception ex)
        {
            MessageBox.Show(this, ex.Message, "Import Values failed", MessageBoxButtons.OK, MessageBoxIcon.Error);
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
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(48)));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, choices.Count == 0 ? Zoomed(44) : Zoomed(250)));
        panel.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        panel.RowStyles.Add(new RowStyle(SizeType.Absolute, Zoomed(56)));
        dialog.Controls.Add(panel);

        panel.Controls.Add(new Label
        {
            Text = message,
            Dock = DockStyle.Fill,
            TextAlign = ContentAlignment.MiddleLeft,
            BackColor = MainBackground,
            ForeColor = PrimaryTextColor
        }, 0, 0);

        Control choiceControl;
        if (choices.Count == 0)
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
            actionBar.Controls.Add(new Label
            {
                Text = "Tick = " + selectedActionLabel + ". Untick = " + otherActionLabel + ".",
                AutoSize = true,
                TextAlign = ContentAlignment.MiddleLeft,
                Padding = new Padding(0, Zoomed(7), Zoomed(12), 0),
                BackColor = MainBackground,
                ForeColor = PrimaryTextColor
            });
            var selectAllButton = new Button { Text = selectedActionLabel, Margin = new Padding(Zoomed(2)) };
            var clearAllButton = new Button { Text = otherActionLabel, Margin = new Padding(Zoomed(2)) };
            SizeDialogButton(selectAllButton, 190);
            SizeDialogButton(clearAllButton, 170);
            actionBar.Controls.Add(selectAllButton);
            actionBar.Controls.Add(clearAllButton);
            choicePanel.Controls.Add(actionBar, 0, 0);

            var list = new ListView
            {
                Dock = DockStyle.Fill,
                View = View.Details,
                CheckBoxes = true,
                FullRowSelect = true,
                GridLines = true,
                BackColor = EditorBackground,
                ForeColor = PrimaryTextColor
            };
            list.Columns.Add("Use", Zoomed(48));
            list.Columns.Add("Setting", Zoomed(250));
            list.Columns.Add(selectedValueLabel, Zoomed(210));
            list.Columns.Add(otherValueLabel, Zoomed(210));
            list.Columns.Add("Comment", Zoomed(280));
            foreach (var choice in choices.OrderBy(choice => choice.Key, StringComparer.OrdinalIgnoreCase))
            {
                var item = new ListViewItem("");
                item.Checked = choice.Selected;
                item.Tag = choice;
                item.SubItems.Add(choice.Key);
                item.SubItems.Add(PreviewValue(choice.SelectedValue));
                item.SubItems.Add(PreviewValue(choice.OtherValue));
                item.SubItems.Add(PreviewHelp(choice.HelpText));
                list.Items.Add(item);
            }

            selectAllButton.Click += (_, _) =>
            {
                foreach (ListViewItem item in list.Items)
                {
                    item.Checked = true;
                }
            };
            clearAllButton.Click += (_, _) =>
            {
                foreach (ListViewItem item in list.Items)
                {
                    item.Checked = false;
                }
            };

            choicePanel.Controls.Add(list, 0, 1);
            choiceControl = choicePanel;
        }

        panel.Controls.Add(choiceControl, 0, 1);

        var previewFrame = new Panel
        {
            Dock = DockStyle.Fill,
            BorderStyle = BorderStyle.FixedSingle,
            Padding = new Padding(Zoomed(6)),
            BackColor = EditorBackground
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
        SizeDialogButton(confirmButton);
        SizeDialogButton(cancelButton);
        buttons.Controls.Add(confirmButton);
        buttons.Controls.Add(cancelButton);
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
            "Matching values imported from selected config: " + preview.KeptValues.Count.ToString(CultureInfo.InvariantCulture),
            "Matching values already the same: " + preview.UnchangedCount.ToString(CultureInfo.InvariantCulture),
            "Current options kept: " + newOptions.Count.ToString(CultureInfo.InvariantCulture),
            "Current rows kept: " + newRows.Count.ToString(CultureInfo.InvariantCulture),
            "Imported full lists kept: " + preview.KeptStringListTables.Count.ToString(CultureInfo.InvariantCulture),
            "Imported table rows preserved: " + preview.PreservedTableRows.Count.ToString(CultureInfo.InvariantCulture),
            "Imported list items preserved: " + preview.PreservedListItems.Count.ToString(CultureInfo.InvariantCulture),
            "Imported values skipped: " + preview.SkippedOldValues.Count.ToString(CultureInfo.InvariantCulture)
        };

        AddPreviewSection(
            lines,
            "Matching values imported from selected config",
            preview.KeptValues
                .OrderBy(item => item.Key, StringComparer.OrdinalIgnoreCase)
                .Select(item => item.Key + ": " + PreviewValue(item.NewDefault) + " -> " + PreviewValue(item.CurrentValue)));
        AddPreviewSection(
            lines,
            "Imported full lists kept",
            preview.KeptStringListTables
                .OrderBy(item => item.Table, StringComparer.OrdinalIgnoreCase)
                .Select(item => item.Table + ": " + item.ItemCount.ToString(CultureInfo.InvariantCulture) + " item(s)"));
        AddPreviewSection(
            lines,
            "Imported table rows preserved",
            preview.PreservedTableRows
                .OrderBy(item => item.Key, StringComparer.OrdinalIgnoreCase)
                .Select(item => item.Key + ": " + PreviewValue(item.Value)));
        AddPreviewSection(
            lines,
            "Imported list items preserved",
            preview.PreservedListItems
                .OrderBy(item => item.Table, StringComparer.OrdinalIgnoreCase)
                .ThenBy(item => item.Value, StringComparer.OrdinalIgnoreCase)
                .Select(item => item.Table + ": " + PreviewValue(item.Value)));
        AddPreviewSection(
            lines,
            "Current options kept",
            newOptions
                .OrderBy(entry => entry.DisplayKey, StringComparer.OrdinalIgnoreCase)
                .Select(entry => FormatEntryAssignment(entry)));
        AddPreviewSection(
            lines,
            "Imported values skipped",
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
            "Stored defaults:",
            defaults.MizName,
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
            SetStatus("No changes to save.");
            return;
        }

        try
        {
            _document.Save();
            ClearUndo();
            RefreshCurrentView(invalidateCachedPanels: false);
            SetStatus("Saved config.");
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
