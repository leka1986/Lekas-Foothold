namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private const string WarehouseWeaponCategory = "Aircraft / Weapons";
    private const string WarehouseWeaponEditorName = "WarehouseWeaponLocations";
    private const int EquipmentDefaultRows = 12;
    private const int AircraftWeaponsDefaultRows = 20;
    private const int EquipmentPaneHalfGap = 32;
    private event Action<ConfigDocument, string, Dictionary<string, string[]>?>? WarehouseRulesRestored;
    private static readonly (string Label, string? Prefix)[] WarehouseWeaponTypes =
    [
        ("All types", null),
        ("Bombs", "weapons.bombs."),
        ("Containers", "weapons.containers."),
        ("Missiles", "weapons.missiles."),
        ("Fuel tanks", "weapons.droptanks."),
        ("Rockets", "weapons.nurs."),
        ("Adapters", "weapons.adapters."),
        ("Gun mounts", "weapons.gunmounts."),
        ("Shells", "weapons.shells."),
        ("Torpedoes", "weapons.torpedoes.")
    ];
    private sealed record EquipmentSearchEntry(string Label, string SearchId, string SearchNames = "");
    private static readonly Lazy<Dictionary<string, EquipmentSearchEntry>> WarehouseWeaponCatalog = new(() =>
    {
        using var stream = typeof(MainForm).Assembly.GetManifestResourceStream("FootholdConfigManager.WarehouseWeaponIds")
            ?? throw new InvalidOperationException("The warehouse weapon picker catalog is missing.");
        using var reader = new StreamReader(stream);
        using var aircraftStream = typeof(MainForm).Assembly.GetManifestResourceStream("FootholdConfigManager.WarehouseWeaponAircraft")
            ?? throw new InvalidOperationException("The warehouse aircraft search data is missing.");
        using var aircraftReader = new StreamReader(aircraftStream);
        var aircraftByWeapon = aircraftReader.ReadToEnd()
            .Split('\n', StringSplitOptions.TrimEntries | StringSplitOptions.RemoveEmptyEntries)
            .Select(line => line.Split('\t'))
            .ToDictionary(fields => fields[0], fields => fields.Skip(1).SelectMany(AircraftSearchTerms), StringComparer.Ordinal);
        var entries = reader.ReadToEnd().Split('\n', StringSplitOptions.TrimEntries | StringSplitOptions.RemoveEmptyEntries)
            .Select(line => line.Split('\t', StringSplitOptions.TrimEntries))
            .Where(fields => fields[0] is not ("weapons.adapters." or "weapons.containers."))
            .DistinctBy(fields => fields[0], StringComparer.Ordinal)
            .ToDictionary(fields => fields[0], fields =>
            {
                // Each line contains the exact DCS ID, then an optional loadout name and search aliases.
                var label = fields.Length > 1 ? fields[1] : WarehouseWeaponName(fields[0]);
                var names = string.Join("|", new[] { label }.Concat(fields.Skip(2))
                    .Concat(aircraftByWeapon.GetValueOrDefault(fields[0]) ?? [])
                    .Select(NormalizeEquipmentSearch).Distinct(StringComparer.Ordinal));
                return new EquipmentSearchEntry(label, NormalizeEquipmentSearch(fields[0]), "|" + names + "|");
            }, StringComparer.Ordinal);
        try
        {
            var cache = new FileInfo(Path.Combine(RuntimeSettings.SettingsDirectory, ReleaseWeaponCatalog.CacheName));
            if (cache.Exists && cache.Length <= ReleaseWeaponCatalog.MaximumBytes)
            {
                foreach (var id in ReleaseWeaponCatalog.Parse(File.ReadAllBytes(cache.FullName)).WeaponIds)
                    entries.TryAdd(id, new EquipmentSearchEntry(WarehouseWeaponName(id), NormalizeEquipmentSearch(id)));
            }
        }
        catch (Exception exception) when (exception is IOException or InvalidDataException or UnauthorizedAccessException or System.Text.Json.JsonException)
        {
            System.Diagnostics.Trace.TraceWarning("Could not read the cached Foothold weapon catalog: " + exception.Message);
        }
        return entries;
    });

    private static readonly Lazy<string[]> SharedWeaponIds = new(() => WarehouseWeaponCatalog.Value.Keys
        .OrderBy(WeaponLabel, StringComparer.OrdinalIgnoreCase).ThenBy(id => id, StringComparer.Ordinal).ToArray());

    private static IEnumerable<string> EquipmentWeaponIds(IEnumerable<string> additionalIds) =>
        SharedWeaponIds.Value.Concat(additionalIds).Distinct(StringComparer.Ordinal);

    private Control? BuildWarehouseWeaponLocationsEditor()
    {
        using var probe = WarehouseLayoutProbe.Enter("build warehouse picker");
        var document = _document;
        if (document is null) return null;

        WarehouseWeaponLocations? settings;
        try
        {
            if (!document.TryReadWarehouseWeaponLocations(out settings) || settings is null ||
                settings.Catalog.Count == 0) return null;
        }
        catch (InvalidDataException ex)
        {
            return new Label { AutoSize = true, Text = "Warehouse Weapon Locations: " + ex.Message };
        }

        var root = new WarehouseCard(Zoomed(5)) { Name = WarehouseWeaponEditorName };
        root.Padding = new Padding(Zoomed(16));
        root.Margin = new Padding(0, 0, 0, Zoomed(15));
        root.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        var body = Column();
        body.Name = "WarehouseWeaponLocationsBody";
        var heading = new TableLayoutPanel
        {
            AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink, Dock = DockStyle.Top, ColumnCount = 3
        };
        heading.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        heading.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        heading.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        var intro = Column();
        var title = Title("Warehouse Weapon Locations");
        title.Font = GetConfigValueFont(5f, FontStyle.Bold);
        intro.Anchor = AnchorStyles.Left | AnchorStyles.Right;
        if (_activeImportedNewEntryKeys.Contains(WarehouseWeaponEditorName))
        {
            var titleRow = Row();
            titleRow.Controls.Add(title);
            titleRow.Controls.Add(MakeNewBadgeLabel());
            intro.Controls.Add(titleRow);
        }
        else intro.Controls.Add(title);
        intro.Controls.Add(new Label { AutoSize = true, Text = "Choose which warehouses can stock each weapon in PvE." });
        heading.Controls.Add(intro, 1, 0);

        var missionField = Column();
        missionField.Controls.Add(new Label { AutoSize = true, Text = "Mission" });
        var mission = new WheelSafeComboBox
        {
            Name = "WarehouseLocationMission", Width = Zoomed(222),
            DropDownStyle = ComboBoxStyle.DropDownList, AccessibleName = "Mission"
        };
        StyleConfigDropdown(mission);
        mission.Items.AddRange(settings.Catalog.Keys.Cast<object>().ToArray());
        missionField.Controls.Add(mission);
        heading.Controls.Add(missionField, 2, 0);
        heading.Margin = new Padding(0, 0, 0, Zoomed(12));
        var hasRules = settings.Rules.Values.Any(rules => rules.Values.Any(names => names.Length > 0));
        heading.Controls.Add(Disclosure("Warehouse Weapon Locations", "ToggleWarehouseWeaponLocations", body, expanded =>
        {
            missionField.Visible = expanded;
            heading.Margin = expanded ? new Padding(0, 0, 0, Zoomed(12)) : Padding.Empty;
            root.Invalidate();
        }, initiallyExpanded: hasRules), 0, 0);
        root.SectionHeading = heading;
        root.Controls.Add(heading);
        root.Controls.Add(body);

        var columns = new TableLayoutPanel
        {
            Dock = DockStyle.Top, AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink, ColumnCount = 2
        };
        columns.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50));
        columns.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50));
        columns.Margin = new Padding(0, 0, 0, Zoomed(8));
        var left = PickerCard("Choose weapons");
        var right = PickerCard("Allowed warehouses");
        left.Margin = new Padding(0, 0, Zoomed(EquipmentPaneHalfGap), 0);
        right.Margin = new Padding(Zoomed(EquipmentPaneHalfGap), 0, 0, 0);
        columns.Controls.Add(left, 0, 0);
        columns.Controls.Add(right, 1, 0);
        columns.SizeChanged += (_, _) =>
        {
            WarehouseLayoutProbe.Count(WarehouseLayoutProbe.Counter.PickerSize);
            var stacked = columns.ClientSize.Width < Zoomed(690);
            var span = stacked ? 2 : 1;
            if (columns.GetColumnSpan(left) == span) return;
            using var trace = WarehouseLayoutProbe.Enabled
                ? WarehouseLayoutProbe.Enter("change warehouse columns", $"width={columns.ClientSize.Width} stacked={stacked}") : null;
            columns.SuspendLayout();
            columns.SetCellPosition(right, new TableLayoutPanelCellPosition(stacked ? 0 : 1, stacked ? 1 : 0));
            columns.SetColumnSpan(left, span);
            columns.SetColumnSpan(right, span);
            left.Margin = stacked ? new Padding(0, 0, 0, Zoomed(8)) : new Padding(0, 0, Zoomed(EquipmentPaneHalfGap), 0);
            right.Margin = stacked ? Padding.Empty : new Padding(Zoomed(EquipmentPaneHalfGap), 0, 0, 0);
            columns.ResumeLayout(true);
        };
        body.Controls.Add(columns);

        var search = new TextBox
        {
            Name = "WarehouseWeaponSearch", AccessibleName = "Search weapons",
            PlaceholderText = "Search by weapon, aircraft, or DCS ID"
        };
        var selectedWeapons = new HashSet<string>(StringComparer.Ordinal);
        var weapons = MakeEquipmentChoiceGrid("WarehouseWeaponChoices", "Weapons",
            virtualMode: true,
            dcsId: (grid, row) => grid.Tag is string[] ids && (uint)row < (uint)ids.Length ? ids[row] : null);
        weapons.Tag = Array.Empty<string>();
        weapons.CellValueNeeded += (_, e) =>
        {
            var ids = (string[])weapons.Tag!;
            if ((uint)e.RowIndex >= (uint)ids.Length) return;
            var id = ids[e.RowIndex];
            e.Value = e.ColumnIndex == 0 ? selectedWeapons.Contains(id) : WeaponLabel(id);
        };
        var locations = MakeEquipmentChoiceGrid("WarehouseLocationChoices", "Airbases", virtualMode: true);
        var airbaseLabel = Subheading("Airbases");
        var carriers = MakeEquipmentChoiceGrid("WarehouseCarrierChoices", "Carriers", virtualMode: true);
        var carrierLabel = Subheading("Carriers");
        carrierLabel.Margin = new Padding(0, Zoomed(16), 0, Zoomed(2));
        var selectedLocations = new HashSet<string>(StringComparer.Ordinal);
        var locationsByMission = new Dictionary<string, (string[] Airbases, string[] Ships)>(StringComparer.Ordinal);
        foreach (var name in settings.Catalog.Keys)
            locationsByMission.Add(name, BuildLocationRows(name));
        foreach (var list in new[] { locations, carriers })
        {
            list.Tag = Array.Empty<string>();
            list.CellValueNeeded += (_, e) =>
            {
                var names = (string[])list.Tag;
                if ((uint)e.RowIndex >= (uint)names.Length) return;
                var name = names[e.RowIndex];
                e.Value = e.ColumnIndex == 0 ? selectedLocations.Contains(name) : name;
            };
        }
        // The weapon picker is shared across missions. Only warehouse choices and rules depend on the map.
        var extraWeapons = settings.Rules.Values.SelectMany(rules => rules.Keys)
            .Where(id => !WarehouseWeaponCatalog.Value.ContainsKey(id)).ToHashSet(StringComparer.Ordinal);
        string[] matches = [];
        EquipmentSearch<string>? weaponIndex = null;
        var selectedOnly = false;

        var typeFilter = MakeEquipmentWeaponTypeFilter("WarehouseWeaponType");
        var searchRow = MakeEquipmentSearchRow(search, typeFilter);
        left.Controls.Add(searchRow);
        var controls = Row();
        controls.AutoSize = false;
        controls.Dock = DockStyle.Fill;
        var matchToolbar = new TableLayoutPanel
        {
            Dock = DockStyle.Top, Height = Zoomed(33), ColumnCount = 2, Margin = Padding.Empty
        };
        matchToolbar.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        matchToolbar.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        matchToolbar.Controls.Add(controls, 0, 0);
        left.Controls.Add(matchToolbar);
        left.Controls.Add(weapons);

        right.Controls.Add(airbaseLabel);
        right.Controls.Add(locations);
        right.Controls.Add(carrierLabel);
        right.Controls.Add(carriers);
        var pickerGrip = MakeEquipmentListResizeGrip(weapons, locations, columns, AircraftWeaponsDefaultRows,
            AirbaseHeightFor, minimumRows: 4);
        pickerGrip.Margin = new Padding(0, 0, 0, Zoomed(6));
        columns.Margin = Padding.Empty;
        body.Controls.Add(pickerGrip);

        var custom = Row();
        var customId = new TextBox
        {
            Name = "WarehouseCustomWeaponId", AccessibleName = "Custom DCS weapon ID",
            PlaceholderText = "Exact DCS weapon ID"
        };
        var customFrame = new ConfigSearchSurface(customId, isSearch: false)
        {
            Width = Zoomed(230), Height = Zoomed(34), Margin = new Padding(0, 0, Zoomed(5), 0)
        };
        ApplyConfigInputMetrics(customFrame);
        customFrame.ApplyPalette(InputBackground, ControlBorderColor, BrandColor, HelpTextColor, HeaderBackground);
        custom.Controls.Add(customFrame);
        var addCustom = ActionButton("Add");
        addCustom.MinimumSize = new Size(addCustom.MinimumSize.Width, customFrame.Height);
        custom.Controls.Add(addCustom);
        var showCustom = ActionButton("+ Add custom weapon", () =>
        {
            custom.Visible = !custom.Visible;
            if (custom.Visible) customId.Focus();
        });
        showCustom.Anchor = AnchorStyles.Left;
        showCustom.Margin = new Padding(0, Zoomed(6), 0, 0);
        left.Controls.Add(showCustom);
        left.Controls.Add(custom);
        custom.Visible = false;

        var summaryRow = new WarehouseCard(Zoomed(5), outlined: false)
        {
            ColumnCount = 2, Padding = new Padding(Zoomed(10)), Margin = new Padding(0, 0, 0, Zoomed(10))
        };
        summaryRow.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        summaryRow.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        var summaryText = Column();
        var summary = Title("");
        var detail = new Label { AutoSize = true, Name = "WarehouseRuleSummaryDetail" };
        summaryText.SizeChanged += (_, _) => detail.MaximumSize = new Size(Math.Max(1, summaryText.Width - Zoomed(6)), 0);
        summaryText.Controls.Add(summary);
        summaryText.Controls.Add(detail);
        summaryRow.Controls.Add(summaryText, 0, 0);
        var apply = ActionButton("Apply rules");
        apply.Anchor = AnchorStyles.Right;
        apply.Name = "ApplyWarehouseWeaponRules";
        summaryRow.Controls.Add(apply, 1, 0);
        body.Controls.Add(summaryRow);
        var savedHeader = new TableLayoutPanel
        {
            Dock = DockStyle.Top, AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink,
            ColumnCount = 2, Margin = new Padding(0, 0, 0, Zoomed(4))
        };
        savedHeader.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        savedHeader.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        var savedRows = Column();
        savedRows.Name = "WarehouseSavedRuleRows";
        var savedViews = new Dictionary<string, TableLayoutPanel>(StringComparer.Ordinal);
        TableLayoutPanel? activeSavedView = null;
        var hasFirstMissionRules = settings.Rules.TryGetValue(settings.Catalog.Keys.First(), out var firstRules) &&
            firstRules.Values.Any(names => names.Length > 0);
        savedHeader.Controls.Add(Disclosure("saved rules", "ToggleWarehouseSavedRules", savedRows,
            layoutOwner: body, initiallyExpanded: hasFirstMissionRules), 0, 0);
        var savedTitle = Title("Saved rules");
        savedTitle.Anchor = AnchorStyles.Left;
        savedTitle.Margin = Padding.Empty;
        savedHeader.Controls.Add(savedTitle, 1, 0);
        body.Controls.Add(savedHeader);
        body.Controls.Add(savedRows);

        var matchCount = new Label
        {
            AutoSize = false, Width = Zoomed(88), Height = Zoomed(22), TextAlign = ContentAlignment.TopRight,
            Margin = new Padding(Zoomed(4), Zoomed(7), 0, 0)
        };
        var selectMatches = ActionButton("Select all 0000 matches");
        var showSelected = ActionButton("Show selected (0000)");
        foreach (var button in new[] { selectMatches, showSelected })
        {
            button.Size = button.GetPreferredSize(Size.Empty);
            button.AutoSize = false;
        }
        apply.Click += (_, _) => ApplySelection();
        addCustom.Click += (_, _) =>
        {
            var id = customId.Text.Trim();
            if (id.Length == 0) return;
            if (!WarehouseWeaponCatalog.Value.ContainsKey(id) && extraWeapons.Add(id)) weaponIndex = null;
            selectedWeapons.Add(id);
            customId.Clear();
            custom.Visible = false;
            selectedOnly = true;
            RefreshWeapons();
            RefreshSummary();
        };
        selectMatches.Click += (_, _) =>
        {
            selectedWeapons.UnionWith(matches);
            RefreshWeapons();
            RefreshSummary();
        };
        showSelected.Click += (_, _) =>
        {
            selectedOnly = !selectedOnly;
            RefreshWeapons();
        };
        controls.Controls.Add(selectMatches);
        controls.Controls.Add(showSelected);
        var clear = new LinkLabel
        {
            AutoSize = true, Text = "Clear selection", LinkBehavior = LinkBehavior.HoverUnderline,
            Margin = new Padding(Zoomed(4), Zoomed(6), 0, 0)
        };
        clear.LinkClicked += (_, _) =>
        {
            selectedWeapons.Clear();
            selectedOnly = false;
            RefreshWeapons();
            RefreshSummary();
        };
        controls.Controls.Add(clear);
        matchToolbar.Controls.Add(matchCount, 1, 0);
        controls.SizeChanged += (_, _) => ResizeMatchToolbar();
        selectMatches.SizeChanged += (_, _) => ResizeMatchToolbar();
        showSelected.SizeChanged += (_, _) => ResizeMatchToolbar();

        search.TextChanged += (_, _) =>
        {
            selectedOnly = false;
            RefreshWeapons();
        };
        typeFilter.SelectedIndexChanged += (_, _) =>
        {
            selectedOnly = false;
            RefreshWeapons();
        };
        WireChoices(weapons, selectedWeapons, () =>
        {
            RefreshSummary();
            if (selectedOnly) RefreshWeapons();
        });
        WireChoices(locations, selectedLocations, RefreshSummary);
        WireChoices(carriers, selectedLocations, RefreshSummary);
        mission.SelectedIndexChanged += (_, _) =>
        {
            var clearedLocations = selectedLocations.Count > 0;
            selectedLocations.Clear();
            RefreshMapDetails(clearedLocations);
        };
        WarehouseRulesRestored += RestoreRules;
        root.Disposed += (_, _) => WarehouseRulesRestored -= RestoreRules;
        RefreshWeapons();
        mission.SelectedIndex = 0;
        return root;

        Dictionary<string, string[]>? MissionRules() => mission.SelectedItem is string name &&
            settings.Rules.TryGetValue(name, out var rules) ? rules : null;

        void ResizeMatchToolbar()
        {
            WarehouseLayoutProbe.Count(WarehouseLayoutProbe.Counter.MatchToolbar);
            if (controls.Width == 0) return;
            var content = controls.GetPreferredSize(new Size(controls.Width, 0));
            var height = Math.Max(Zoomed(33), content.Height);
            if (matchToolbar.Height == height) return;
            matchToolbar.Height = height;
            ResizeAirbaseViewport();
        }

        int AirbaseHeightFor(int weaponHeight)
        {
            // Both cards have the same title and padding. Account for the controls below
            // each title so the last warehouse row ends level with the weapons list.
            var weaponHeader = searchRow.Height + searchRow.Margin.Vertical +
                matchToolbar.Height + matchToolbar.Margin.Vertical;
            var warehouseHeader = airbaseLabel.PreferredHeight + airbaseLabel.Margin.Vertical;
            var carrierSection = carriers.RowCount == 0 ? 0 :
                carrierLabel.PreferredHeight + carrierLabel.Margin.Vertical + carriers.Height;
            return Math.Max(locations.RowTemplate.Height, weaponHeight + weaponHeader - warehouseHeader - carrierSection);
        }

        void ResizeAirbaseViewport()
        {
            var height = AirbaseHeightFor(weapons.Height);
            if (locations.Height != height) locations.Height = height;
        }

        void RefreshWeapons()
        {
            using var trace = WarehouseLayoutProbe.Enter("refresh weapon results");
            var query = new EquipmentSearchQuery(search.Text, WarehouseWeaponTypes[typeFilter.SelectedIndex].Prefix);
            weaponIndex ??= new EquipmentSearch<string>(EquipmentWeaponIds(extraWeapons), id => id, weapons: true);
            matches = weaponIndex.Filter(query);
            var visible = selectedOnly ? selectedWeapons.Order(StringComparer.Ordinal).ToArray() : matches;
            if (!((string[])weapons.Tag!).AsSpan().SequenceEqual(visible))
            {
                weapons.Tag = visible;
                if (weapons.RowCount != visible.Length) weapons.RowCount = visible.Length;
                if (visible.Length > 0 && weapons.FirstDisplayedScrollingRowIndex > 0)
                    weapons.FirstDisplayedScrollingRowIndex = 0;
                weapons.ClearSelection();
            }
            weapons.Invalidate();
            selectMatches.Enabled = !selectedOnly && matches.Length > 0;
            selectMatches.Text = $"Select all {matches.Length} matches";
            matchCount.Text = $"{matches.Length} {(matches.Length == 1 ? "match" : "matches")}";
            showSelected.Text = selectedOnly ? "Show matches" : $"Show selected ({selectedWeapons.Count})";
        }

        void RefreshMapDetails(bool locationChecksChanged = false, string? changedRulesFor = null)
        {
            body.SuspendLayout();
            right.SuspendLayout();
            savedRows.SuspendLayout();
            try
            {
                if (changedRulesFor is not null) InvalidateSavedView(changedRulesFor);
                RefreshLocations(locationChecksChanged);
                RefreshSavedRules();
                RefreshSummary();
            }
            finally
            {
                savedRows.ResumeLayout(true);
                right.ResumeLayout(true);
                EditorSection.RunLayoutPass(() => body.ResumeLayout(true));
            }
        }

        void RefreshChangedRules(string name)
        {
            RefreshLocationCache(name);
            if (Equals(mission.SelectedItem, name)) RefreshMapDetails(changedRulesFor: name);
            else InvalidateSavedView(name);
        }

        void RestoreRules(ConfigDocument changedDocument, string name, Dictionary<string, string[]>? previousRules)
        {
            if (!ReferenceEquals(changedDocument, document)) return;
            if (previousRules is null) settings.Rules.Remove(name);
            else
            {
                settings.Rules[name] = new(previousRules, StringComparer.Ordinal);
                var addedWeapon = false;
                foreach (var id in previousRules.Keys)
                    if (!WarehouseWeaponCatalog.Value.ContainsKey(id)) addedWeapon |= extraWeapons.Add(id);
                if (addedWeapon)
                {
                    weaponIndex = null;
                    RefreshWeapons();
                }
            }
            RefreshChangedRules(name);
        }

        (string[] Airbases, string[] Ships) BuildLocationRows(string name)
        {
            var savedNames = settings.Rules.TryGetValue(name, out var rules)
                ? rules.Values.SelectMany(names => names)
                : Enumerable.Empty<string>();
            var names = settings.Catalog[name].Concat(savedNames).Distinct(StringComparer.Ordinal)
                .ToLookup(value => value.StartsWith("CVN-", StringComparison.Ordinal) || value == "Tarawa");
            return (names[false].ToArray(), names[true].ToArray());
        }

        void RefreshLocationCache(string name)
        {
            var previous = locationsByMission[name];
            var updated = BuildLocationRows(name);
            locationsByMission[name] =
                (previous.Airbases.AsSpan().SequenceEqual(updated.Airbases) ? previous.Airbases : updated.Airbases,
                 previous.Ships.AsSpan().SequenceEqual(updated.Ships) ? previous.Ships : updated.Ships);
        }

        void RefreshLocations(bool checksChanged = false)
        {
            using var trace = WarehouseLayoutProbe.Enter("refresh warehouse results");
            var (airbases, ships) = locationsByMission[(string)mission.SelectedItem!];
            if (selectedLocations.Count > 0)
                checksChanged |= selectedLocations.RemoveWhere(value => !airbases.Contains(value, StringComparer.Ordinal) &&
                    !ships.Contains(value, StringComparer.Ordinal)) > 0;
            ShowLocationRows(locations, airbases, checksChanged);
            ShowLocationRows(carriers, ships, checksChanged);
            var carrierHeight = carriers.RowTemplate.Height * Math.Clamp(ships.Length, 1, 3);
            if (carriers.Height != carrierHeight) carriers.Height = carrierHeight;
            var hasCarriers = ships.Length > 0;
            carrierLabel.Visible = carriers.Visible = hasCarriers;
            ResizeAirbaseViewport();
        }

        void WireChoices(SmoothDataGridView list, HashSet<string> selected, Action changed)
        {
            void Toggle(int index)
            {
                if ((uint)index >= (uint)list.RowCount) return;
                var id = ((string[])list.Tag!)[index];
                if (!selected.Remove(id)) selected.Add(id);
                list.InvalidateRow(index);
                changed();
            }

            WireEquipmentChoiceToggle(list, Toggle);
        }

        void ShowLocationRows(DataGridView list, string[] values, bool checksChanged)
        {
            var current = (string[])list.Tag!;
            list.Tag = values;
            if (!ReferenceEquals(current, values) && !current.AsSpan().SequenceEqual(values))
            {
                if (list.RowCount != values.Length) list.RowCount = values.Length;
                if (values.Length > 0 && list.FirstDisplayedScrollingRowIndex > 0)
                    list.FirstDisplayedScrollingRowIndex = 0;
                list.ClearSelection();
                list.Invalidate();
            }
            else if (checksChanged) list.Invalidate();
        }

        void RefreshSummary()
        {
            var rules = MissionRules();
            var add = 0;
            var update = 0;
            if (selectedLocations.Count > 0)
            {
                foreach (var id in selectedWeapons)
                {
                    if (rules is null || !rules.TryGetValue(id, out var current) || current.Length == 0) add++;
                    else if (!selectedLocations.SetEquals(current)) update++;
                }
            }

            var changes = new List<string>();
            if (add > 0) changes.Add($"Add {add} {(add == 1 ? "rule" : "rules")}");
            if (update > 0) changes.Add($"Update {update} {(update == 1 ? "rule" : "rules")}");
            summary.Text = changes.Count > 0 ? string.Join(" · ", changes) : "No rule changes";
            detail.Text = $"{selectedWeapons.Count} selected · {selectedLocations.Count} warehouses allowed"
                + (update > 0 ? ". Updating replaces the existing warehouse list." : "");
            detail.Tag = update > 0;
            detail.ForeColor = update > 0 ? UndoMutedText : HelpTextColor;
            apply.Enabled = add + update > 0;
            if (!selectedOnly) showSelected.Text = $"Show selected ({selectedWeapons.Count})";
        }

        void ApplySelection()
        {
            if (!apply.Enabled || mission.SelectedItem is not string name) return;
            CommitRules(rules =>
            {
                var warehouseNames = selectedLocations.Order(StringComparer.Ordinal).ToArray();
                foreach (var id in selectedWeapons)
                {
                    if (!rules.TryGetValue(id, out var current) || !selectedLocations.SetEquals(current))
                        rules[id] = warehouseNames;
                }
            });
        }

        void RefreshSavedRules()
        {
            var rules = MissionRules();
            var empty = rules is null || rules.Values.All(names => names.Length == 0);
            var key = empty ? "" : (string)mission.SelectedItem!;
            if (savedViews.TryGetValue(key, out var cached))
            {
                ShowSavedView(cached);
                return;
            }

            var view = Column();
            view.Visible = false;
            if (empty)
            {
                view.Controls.Add(new Label { AutoSize = true, Text = "No custom rules. Standard warehouse settings apply." });
            }
            else
            {
                foreach (var (id, names) in rules!.OrderBy(rule => rule.Key, StringComparer.Ordinal))
                {
                    if (names.Length == 0) continue;
                    var ruleRow = new TableLayoutPanel
                    {
                        Dock = DockStyle.Top, AutoSize = true, ColumnCount = 3,
                        Padding = new Padding(0, Zoomed(5), 0, Zoomed(5)), Margin = Padding.Empty
                    };
                    ruleRow.Paint += (_, e) =>
                    {
                        using var border = new Pen(BorderColor);
                        e.Graphics.DrawLine(border, 0, 0, ruleRow.Width, 0);
                    };
                    ruleRow.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
                    ruleRow.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
                    ruleRow.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
                    var text = Column();
                    text.Controls.Add(Title(WeaponLabel(id)));
                    var warehouseNames = new Label { AutoSize = true, Text = string.Join(", ", names) };
                    text.Controls.Add(warehouseNames);
                    text.SizeChanged += (_, _) => warehouseNames.MaximumSize = new Size(Math.Max(1, text.Width - Zoomed(8)), 0);
                    ruleRow.Controls.Add(text, 0, 0);
                    ruleRow.Controls.Add(ActionButton("Edit", () =>
                    {
                        selectedWeapons.Clear();
                        selectedWeapons.Add(id);
                        selectedLocations.Clear();
                        selectedLocations.UnionWith(names);
                        selectedOnly = true;
                        RefreshWeapons();
                        RefreshLocations(checksChanged: true);
                        RefreshSummary();
                    }), 1, 0);
                    ruleRow.Controls.Add(ActionButton("Remove", () =>
                    {
                        if (!CommitRules(edited => edited.Remove(id))) return;
                        selectedWeapons.Remove(id);
                        RefreshWeapons();
                        RefreshSummary();
                    }), 2, 0);
                    view.Controls.Add(ruleRow);
                }
            }
            ApplyThemeToControl(view, restyleButtons: false);
            savedViews.Add(key, view);
            savedRows.Controls.Add(view);
            ShowSavedView(view);
        }

        void ShowSavedView(TableLayoutPanel view)
        {
            if (ReferenceEquals(view, activeSavedView)) return;
            if (activeSavedView is not null) activeSavedView.Visible = false;
            view.Visible = true;
            activeSavedView = view;
        }

        void InvalidateSavedView(string name)
        {
            if (!savedViews.Remove(name, out var view)) return;
            if (ReferenceEquals(view, activeSavedView)) activeSavedView = null;
            view.Dispose();
        }

        bool CommitRules(Action<Dictionary<string, string[]>> edit)
        {
            if (!ReferenceEquals(document, _document) ||
                mission.SelectedItem is not string name ||
                !document.TryGetTableBlockText(WarehouseWeaponLocations.RulesKey, out var previous)) return false;

            settings.Rules.TryGetValue(name, out var previousRules);
            var edited = previousRules is null
                ? new Dictionary<string, string[]>(StringComparer.Ordinal)
                : new Dictionary<string, string[]>(previousRules, StringComparer.Ordinal);
            edit(edited);
            settings.Rules[name] = edited;
            if (!document.SetWarehouseWeaponRulesText(settings.RenderMissionRules(previous, name)))
            {
                if (previousRules is null) settings.Rules.Remove(name);
                else settings.Rules[name] = previousRules;
                return false;
            }

            SetUndoAction("warehouse weapon locations", () =>
            {
                if (document.SetWarehouseWeaponRulesText(previous))
                    WarehouseRulesRestored?.Invoke(document, name, previousRules);
            });
            SetChangedStatus();
            RefreshChangedRules(name);
            return true;
        }

        TableLayoutPanel Column()
        {
            var panel = new EditorLayoutPanel
            {
                Dock = DockStyle.Top, AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink,
                ColumnCount = 1, Margin = Padding.Empty
            };
            panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            return panel;
        }

        FlowLayoutPanel Row() => new()
        {
            Dock = DockStyle.Top, AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink,
            WrapContents = true, Margin = Padding.Empty
        };
        WarehouseCard PickerCard(string title)
        {
            var card = new WarehouseCard(Zoomed(5), shaded: true)
            {
                Dock = DockStyle.Fill, Padding = new Padding(Zoomed(10))
            };
            card.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            var label = Title(title);
            label.Margin = new Padding(0, 0, 0, Zoomed(7));
            card.Controls.Add(label);
            return card;
        }
        Label Title(string text) => new() { AutoSize = true, Text = text, Font = GetConfigValueFont(1.2f, FontStyle.Bold) };
        Label Subheading(string text) => new()
        {
            AutoSize = true, Name = "WarehousePickerSubheading", Text = text, Font = GetConfigValueFont(-.4f, FontStyle.Bold),
            Margin = new Padding(0, 0, 0, Zoomed(2))
        };

        PreviewButton Disclosure(string label, string name, Control content, Action<bool>? update = null,
            Control? layoutOwner = null, bool initiallyExpanded = true)
        {
            var expanded = initiallyExpanded;
            var toggle = ActionButton(expanded ? "▾" : "▸");
            toggle.Name = name;
            toggle.AccessibleName = (expanded ? "Collapse " : "Expand ") + label;
            content.Visible = expanded;
            update?.Invoke(expanded);
            toggle.Font = GetConfigValueFont(2.85f, FontStyle.Bold);
            toggle.Anchor = AnchorStyles.Left;
            toggle.Padding = Padding.Empty;
            toggle.FlatAppearance.BorderSize = 0;
            toggle.MinimumSize = new Size(Zoomed(24), Zoomed(25));
            if (layoutOwner is not null)
            {
                toggle.Size = toggle.GetPreferredSize(Size.Empty);
                toggle.AutoSize = false;
            }
            toggle.Click += (_, _) =>
            {
                expanded = !expanded;
                EditorSection.RunLayoutPass(() =>
                {
                    layoutOwner?.SuspendLayout();
                    try
                    {
                        toggle.Text = expanded ? "▾" : "▸";
                        toggle.AccessibleName = (expanded ? "Collapse " : "Expand ") + label;
                        content.Visible = expanded;
                        update?.Invoke(expanded);
                    }
                    finally
                    {
                        layoutOwner?.ResumeLayout(true);
                    }
                });
            };
            return toggle;
        }

        PreviewButton ActionButton(string label, Action? action = null) => MakeWarehouseActionButton(label, action);
    }

    private SmoothDataGridView MakeEquipmentChoiceGrid(string name, string label,
        Func<DataGridView, int, string?>? statusText = null, bool virtualMode = false,
        Func<DataGridView, int, string?>? dcsId = null, Func<DataGridView, int, string?>? pendingStatus = null)
    {
        var rowFont = GetConfigValueFont(.6f);
        var badgeFont = pendingStatus is null ? rowFont : GetConfigValueFont(-1f, FontStyle.Bold);
        var annotationGap = Zoomed(6);
        var badgePadding = Zoomed(4);
        var rowHeight = Math.Max(Zoomed(30), rowFont.Height + Zoomed(7));
        var list = new SmoothDataGridView
        {
            EquipmentRowId = dcsId ?? statusText,
            EquipmentRowChange = pendingStatus,
            Name = name, AccessibleName = label, Dock = DockStyle.Top, Margin = Padding.Empty,
            AllowUserToAddRows = false, AllowUserToDeleteRows = false, AllowUserToResizeColumns = false,
            AllowUserToResizeRows = false, ReadOnly = true, VirtualMode = virtualMode, MultiSelect = false, StandardTab = true, RowHeadersVisible = false,
            ColumnHeadersVisible = false, ScrollBars = ScrollBars.Vertical, BorderStyle = BorderStyle.None,
            RowTemplate = { Height = rowHeight }, CellBorderStyle = DataGridViewCellBorderStyle.None,
            SelectionMode = DataGridViewSelectionMode.FullRowSelect
        };
        list.Columns.Add(new DataGridViewCheckBoxColumn
        {
            HeaderText = "Selected", Width = Zoomed(24), MinimumWidth = Zoomed(24), FlatStyle = FlatStyle.Flat
        });
        list.Columns.Add(new DataGridViewTextBoxColumn
        {
            HeaderText = label, AutoSizeMode = DataGridViewAutoSizeColumnMode.Fill,
            SortMode = DataGridViewColumnSortMode.NotSortable
        });
        if (dcsId is not null)
        {
            list.CellToolTipTextNeeded += (_, e) =>
            {
                if (e.RowIndex >= 0 && e.ColumnIndex >= 0)
                    e.ToolTipText = dcsId(list, e.RowIndex) ?? "";
            };
        }
        list.CellPainting += (_, e) =>
        {
            if (e.RowIndex < 0 || e.ColumnIndex < 0 || e.Graphics is not { } graphics) return;
            var isChecked = e.ColumnIndex == 0
                ? e.Value is true
                : list.Rows[e.RowIndex].Cells[0].Value is true;
            var bounds = e.CellBounds;
            var background = isChecked ? ConfigSearchSurface.ColorBlend(EditorBackground, SelectionBackground, .45f) : EditorBackground;
            using var fill = new SolidBrush(background);
            graphics.FillRectangle(fill, bounds);
            using var border = new Pen(BorderColor);
            graphics.DrawLine(border, bounds.Left, bounds.Bottom - 1, bounds.Right, bounds.Bottom - 1);
            if (e.ColumnIndex == 0)
            {
                var size = Zoomed(13);
                var check = new Rectangle(bounds.X + (bounds.Width - size) / 2,
                    bounds.Y + (bounds.Height - size) / 2, size, size);
                using var checkFill = new SolidBrush(isChecked ? ConfigSearchSurface.ColorBlend(BrandColor, Color.White, .32f) : InputBackground);
                graphics.FillRectangle(checkFill, check);
                graphics.DrawRectangle(border, check);
                if (isChecked)
                {
                    using var mark = new Pen(Color.FromArgb(20, 40, 60), Math.Max(1, Zoomed(2)));
                    var start = new Point(check.X + size / 5, check.Y + size / 2);
                    var middle = new Point(check.X + size * 2 / 5, check.Y + size * 3 / 4);
                    var end = new Point(check.X + size * 4 / 5, check.Y + size / 4);
                    graphics.DrawLine(mark, start, middle);
                    graphics.DrawLine(mark, middle, end);
                }
            }
            else
            {
                var flags = TextFormatFlags.SingleLine | TextFormatFlags.EndEllipsis |
                    TextFormatFlags.VerticalCenter | TextFormatFlags.NoPadding | TextFormatFlags.NoPrefix;
                var textBounds = Rectangle.Inflate(bounds, -Zoomed(2), 0);
                var label = e.FormattedValue as string ?? "";
                if (textBounds.Width > 0)
                {
                    var status = statusText?.Invoke(list, e.RowIndex);
                    var pending = pendingStatus?.Invoke(list, e.RowIndex);
                    var trailingSpace = textBounds.Width / 2;
                    var badgeSize = pending is null ? Size.Empty : TextRenderer.MeasureText(graphics, pending, badgeFont, textBounds.Size, flags);
                    var badgeWidth = pending is null ? 0 : badgeSize.Width + badgePadding * 2;
                    if (badgeWidth + annotationGap > trailingSpace) badgeWidth = 0;
                    if (badgeWidth > 0) trailingSpace -= badgeWidth + annotationGap;
                    var annotation = status is null ? "" : "· " + status;
                    var annotationWidth = status is null ? 0 : Math.Min(Math.Max(0, trailingSpace - annotationGap),
                        TextRenderer.MeasureText(graphics, annotation, rowFont, textBounds.Size, flags).Width);
                    if (annotationWidth > 0) trailingSpace -= annotationWidth + annotationGap;
                    var labelBounds = textBounds;
                    labelBounds.Width -= textBounds.Width / 2 - trailingSpace;
                    TextRenderer.DrawText(graphics, label, rowFont, labelBounds, PrimaryTextColor, flags);
                    if (badgeWidth > 0 || annotationWidth > 0)
                    {
                        var x = labelBounds.X + Math.Min(labelBounds.Width,
                            TextRenderer.MeasureText(graphics, label, rowFont, labelBounds.Size, flags).Width) + annotationGap;
                        if (badgeWidth > 0)
                        {
                            var height = Math.Min(badgeSize.Height + Zoomed(2), textBounds.Height);
                            var badgeBounds = new Rectangle(x, textBounds.Y + (textBounds.Height - height) / 2, badgeWidth, height);
                            var dark = IsDarkPalette();
                            var (badgeBackground, badgeForeground) = pending == "ADDED"
                                ? dark ? (Color.FromArgb(35, 61, 53), Color.FromArgb(160, 230, 191))
                                       : (Color.FromArgb(212, 240, 225), Color.FromArgb(11, 87, 56))
                                : dark ? (Color.FromArgb(69, 53, 34), Color.FromArgb(255, 207, 135))
                                       : (Color.FromArgb(250, 233, 201), Color.FromArgb(120, 67, 0));
                            using var badgeFill = new SolidBrush(badgeBackground);
                            using var badgeShape = ConfigSearchSurface.RoundedRectangle(badgeBounds, Zoomed(3));
                            graphics.FillPath(badgeFill, badgeShape);
                            TextRenderer.DrawText(graphics, pending!, badgeFont, badgeBounds, badgeForeground,
                                flags | TextFormatFlags.HorizontalCenter);
                            x += badgeWidth + annotationGap;
                        }
                        if (annotationWidth > 0)
                        {
                            var annotationBounds = new Rectangle(x, textBounds.Y, annotationWidth, textBounds.Height);
                            var annotationColor = status is "Used by AI" or "Activated for AI" ? BrandColor : HelpTextColor;
                            TextRenderer.DrawText(graphics, annotation, rowFont, annotationBounds, annotationColor, flags);
                        }
                    }
                }
                if (list.Focused && list.CurrentCell?.RowIndex == e.RowIndex && InputChrome.KeyboardInputActive)
                    ControlPaint.DrawFocusRectangle(graphics, Rectangle.Inflate(bounds, -1, -1), PrimaryTextColor, background);
            }
            e.Handled = true;
        };
        return list;
    }

    private Control MakeEquipmentListResizeGrip(DataGridView grid, DataGridView pairedGrid, Control layout,
        int defaultRows, Func<int, int>? pairedHeightFor = null, int minimumRows = 3, string? preferenceKey = null)
    {
        const int maximumRows = 30;
        var grip = new EquipmentListResizeGrip
        {
            Name = "EquipmentResize:" + grid.Name,
            AccessibleName = "Resize " + grid.AccessibleName + " and " + pairedGrid.AccessibleName,
            AccessibleDescription = "Drag vertically or use the Up and Down arrow keys to resize both lists.",
            Dock = DockStyle.Top,
            Height = Zoomed(14),
            Margin = Padding.Empty,
            Cursor = Cursors.SizeNS
        };
        _toolTip.SetToolTip(grip, "Drag up or down to resize both lists.");
        var rowHeight = grid.RowTemplate.Height;
        var heightKey = preferenceKey ?? grid.Name;
        var preferredHeight = Math.Clamp(_settings.EquipmentListRows.GetValueOrDefault(heightKey, defaultRows),
            minimumRows, maximumRows) * rowHeight;
        int? dragStart = null;
        var dragPointer = Point.Empty;
        var dragRows = 0;
        var dragScrollStart = 0;
        var canScrollEditor = false;
        var dragUpdate = new System.Windows.Forms.Timer { Interval = 32 };

        void ApplyHeight()
        {
            var pairedHeight = pairedHeightFor?.Invoke(preferredHeight) ?? preferredHeight;
            if (grid.Height == preferredHeight && pairedGrid.Height == pairedHeight) return;
            using var trace = WarehouseLayoutProbe.Enabled
                ? WarehouseLayoutProbe.Enter("set equipment list height", $"grid={grid.Name} old={grid.Height} new={preferredHeight} count={grid.RowCount}")
                : null;
            var firstPane = grid.Parent;
            var secondPane = pairedGrid.Parent;
            layout.SuspendLayout();
            firstPane?.SuspendLayout();
            secondPane?.SuspendLayout();
            try
            {
                grid.Height = preferredHeight;
                pairedGrid.Height = pairedHeight;
            }
            finally
            {
                firstPane?.ResumeLayout(true);
                secondPane?.ResumeLayout(true);
                EditorSection.RunLayoutPass(() => layout.ResumeLayout(true));
            }
        }

        void Resize(int rows)
        {
            var resizedRows = Math.Clamp(rows, minimumRows, maximumRows);
            if (resizedRows * rowHeight == grid.Height) return;
            preferredHeight = resizedRows * rowHeight;
            ApplyHeight();
        }

        void SaveHeight(int previousRows)
        {
            var rows = preferredHeight / rowHeight;
            if (rows == previousRows) return;
            _settings.EquipmentListRows[heightKey] = rows;
            SaveEditorLayoutPreferences();
        }

        void FinishDrag()
        {
            if (dragStart is null) return;
            dragStart = null;
            dragUpdate.Stop();
            grip.Capture = false;
            SaveHeight(dragRows);
        }

        grip.MouseDown += (_, e) =>
        {
            if (e.Button != MouseButtons.Left) return;
            dragPointer = grip.PointToScreen(e.Location);
            dragStart = dragPointer.Y;
            dragRows = grid.Height / rowHeight;
            canScrollEditor = _formHost.AutoScroll && _formHost.Contains(grip);
            dragScrollStart = _formHost.AutoScrollPosition.Y;
            if (WarehouseLayoutProbe.Enabled) WarehouseLayoutProbe.Note($"DRAG START grid={grid.Name} height={grid.Height}");
            grip.Capture = true;
        };
        int RowsAt(Point screenPoint, int start)
        {
            // The same screen position moves down through the list as the editor scrolls.
            var scrolled = canScrollEditor ? dragScrollStart - _formHost.AutoScrollPosition.Y : 0;
            var offset = (screenPoint.Y - start + scrolled) / (double)rowHeight;
            return Math.Clamp(dragRows + (int)Math.Round(offset, MidpointRounding.AwayFromZero),
                minimumRows, maximumRows);
        }

        bool AtEditorBottom(int start)
        {
            if (!canScrollEditor || dragPointer.Y <= start) return false;
            var pointer = _formHost.PointToClient(dragPointer);
            return pointer.X >= 0 && pointer.X < _formHost.ClientSize.Width &&
                pointer.Y >= _formHost.ClientSize.Height - Zoomed(30);
        }

        int GripOverflow()
        {
            var bottom = _formHost.PointToClient(grip.PointToScreen(new Point(0, grip.Height))).Y;
            return Math.Max(0, bottom - _formHost.ClientSize.Height + Zoomed(4));
        }

        bool ScrollEditorDown(int amount)
        {
            if (amount == 0) return false;
            var before = _formHost.AutoScrollPosition;
            _formHost.AutoScrollPosition = new Point(-before.X, -before.Y + amount);
            if (_formHost.AutoScrollPosition == before) return false;
            WeatherScrollHost.SynchronizeParent(_formHost);
            return true;
        }

        dragUpdate.Tick += (_, _) =>
        {
            dragUpdate.Stop();
            if (dragStart is not int start) return;
            Resize(RowsAt(dragPointer, start));
            if (!AtEditorBottom(start)) return;

            var reveal = GripOverflow();
            var step = grid.Height < maximumRows * rowHeight ? Math.Max(Zoomed(14), reveal) : reveal;
            if (!ScrollEditorDown(step)) return;
            Resize(RowsAt(dragPointer, start));
            dragUpdate.Start();
        };
        grip.MouseMove += (_, e) =>
        {
            if (dragStart is not int start) return;
            dragPointer = grip.PointToScreen(e.Location);
            if (RowsAt(dragPointer, start) * rowHeight != grid.Height || AtEditorBottom(start)) dragUpdate.Start();
        };
        grip.MouseUp += (_, e) =>
        {
            if (e.Button != MouseButtons.Left || dragStart is not int start) return;
            dragPointer = grip.PointToScreen(e.Location);
            var rows = RowsAt(dragPointer, start);
            using var trace = WarehouseLayoutProbe.Enabled
                ? WarehouseLayoutProbe.Enter("release equipment grip", $"grid={grid.Name} rows={rows}") : null;
            Resize(rows);
            if (AtEditorBottom(start)) ScrollEditorDown(GripOverflow());
            FinishDrag();
        };
        grip.MouseCaptureChanged += (_, _) =>
        {
            if (!grip.Capture) FinishDrag();
        };
        grip.Disposed += (_, _) => dragUpdate.Dispose();
        grip.PreviewKeyDown += (_, e) => e.IsInputKey = e.KeyCode is Keys.Up or Keys.Down;
        grip.KeyDown += (_, e) =>
        {
            if (e.KeyCode is not (Keys.Up or Keys.Down)) return;
            var previousRows = preferredHeight / rowHeight;
            Resize(previousRows + (e.KeyCode == Keys.Down ? 1 : -1));
            SaveHeight(previousRows);
            e.Handled = true;
        };
        ApplyHeight();
        return grip;
    }

    private sealed class EquipmentListResizeGrip : Control
    {
        internal EquipmentListResizeGrip()
        {
            AccessibleRole = AccessibleRole.Grip;
            TabStop = true;
            SetStyle(ControlStyles.UserPaint | ControlStyles.AllPaintingInWmPaint |
                ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw | ControlStyles.Selectable, true);
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            e.Graphics.Clear(Parent?.BackColor ?? EditorBackground);
            var middle = ClientSize.Height / 2;
            var halfWidth = Math.Min(ClientSize.Width / 2, ClientSize.Height);
            var left = ClientSize.Width / 2 - halfWidth;
            var right = ClientSize.Width / 2 + halfWidth;
            using var pen = new Pen(SystemInformation.HighContrast ? SystemColors.ControlText : HelpTextColor);
            e.Graphics.DrawLine(pen, left, middle - 2, right, middle - 2);
            e.Graphics.DrawLine(pen, left, middle + 2, right, middle + 2);
            if (Focused && InputChrome.KeyboardInputActive)
                ControlPaint.DrawFocusRectangle(e.Graphics, Rectangle.Inflate(ClientRectangle, -1, -1));
        }

        protected override void OnGotFocus(EventArgs e) { base.OnGotFocus(e); Invalidate(); }
        protected override void OnLostFocus(EventArgs e) { base.OnLostFocus(e); Invalidate(); }
    }

    private PreviewButton MakeWarehouseActionButton(string label, Action? action = null)
    {
        var button = new PreviewButton
        {
            Text = label, AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink,
            Padding = new Padding(Zoomed(7), 0, Zoomed(7), 0), Margin = new Padding(0, 0, Zoomed(5), Zoomed(3)),
            MinimumSize = new Size(0, Zoomed(28))
        };
        StyleButton(button);
        if (action is not null) button.Click += (_, _) => action();
        return button;
    }

    private Control MakeEquipmentSearchRow(TextBox search, WheelSafeComboBox? typeFilter)
    {
        var searchFrame = new ConfigSearchSurface(search)
        {
            Dock = DockStyle.Fill, Height = Zoomed(34), Margin = new Padding(0, 0, Zoomed(6), 0)
        };
        ApplyConfigInputMetrics(searchFrame);
        searchFrame.ApplyPalette(InputBackground, BorderColor, BrandColor, HelpTextColor, HeaderBackground);
        if (typeFilter is null)
        {
            searchFrame.Dock = DockStyle.Top;
            searchFrame.Margin = new Padding(0, 0, 0, Zoomed(4));
            return searchFrame;
        }

        typeFilter.Anchor = AnchorStyles.Left | AnchorStyles.Right;
        var searchRow = new TableLayoutPanel
        {
            Dock = DockStyle.Top, ColumnCount = 2, Height = Math.Max(searchFrame.Height, typeFilter.Height),
            Margin = new Padding(0, 0, 0, Zoomed(4))
        };
        searchRow.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        searchRow.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, typeFilter.Width));
        searchRow.Controls.Add(searchFrame, 0, 0);
        searchRow.Controls.Add(typeFilter, 1, 0);
        return searchRow;
    }

    private static void WireEquipmentChoiceToggle(SmoothDataGridView list, Action<int> toggle, bool checkboxOnly = false)
    {
        list.ToggleEquipmentRow = toggle;
        list.CellClick += (_, e) =>
        {
            if (!checkboxOnly || e.ColumnIndex == 0) toggle(e.RowIndex);
        };
        list.KeyDown += (_, e) =>
        {
            if (e.KeyCode != Keys.Space || list.CurrentCell is null) return;
            e.Handled = e.SuppressKeyPress = true;
            toggle(list.CurrentCell.RowIndex);
        };
    }

    private sealed class WarehouseCard : TableLayoutPanel
    {
        private readonly int _radius;
        private readonly bool _outlined;
        internal bool Shaded { get; }
        internal Control? SectionHeading { get; set; }

        internal WarehouseCard(int radius, bool outlined = true, bool shaded = false)
        {
            _radius = radius;
            _outlined = outlined;
            Shaded = shaded || !outlined;
            Dock = DockStyle.Top;
            AutoSize = true;
            AutoSizeMode = AutoSizeMode.GrowAndShrink;
            ColumnCount = 1;
            Margin = Padding.Empty;
            SetStyle(ControlStyles.OptimizedDoubleBuffer | ControlStyles.ResizeRedraw, true);
        }

        internal void ApplyWarehousePalette()
        {
            var surface = Shaded ? EditorBackground : MainBackground;
            BackColor = surface;
            SetSurface(this, surface);
            Invalidate();

            void SetSurface(Control parent, Color surface)
            {
                foreach (Control child in parent.Controls)
                {
                    switch (child)
                    {
                        case WarehouseCard or ConfigSearchSurface:
                        case Label badge when Equals(badge.Tag, ImportedNewBadgeTag):
                            break;
                        case DataGridView grid:
                            grid.BorderStyle = BorderStyle.None;
                            grid.BackgroundColor = surface;
                            break;
                        case PreviewButton { Name: "ToggleWarehouseSavedRules" or "ToggleWarehouseWeaponLocations" } toggle:
                            toggle.BackColor = surface;
                            break;
                        case LinkLabel link:
                            link.BackColor = surface;
                            link.LinkColor = link.ActiveLinkColor = link.VisitedLinkColor = IsDarkPalette()
                                ? Color.FromArgb(139, 196, 255) : Color.FromArgb(7, 90, 169);
                            break;
                        case Label label when label.Name is "WarehouseRuleSummaryDetail" or "WarehousePickerSubheading":
                            label.BackColor = surface;
                            label.ForeColor = label.Tag is true ? UndoMutedText : HelpTextColor;
                            break;
                        case Label or Panel:
                            var childSurface = ReferenceEquals(child, SectionHeading) ? EditorBackground : surface;
                            child.BackColor = childSurface;
                            SetSurface(child, childSurface);
                            break;
                    }
                }
            }
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            base.OnPaint(e);
            if (!_outlined || ClientSize.Width < 2 * _radius || ClientSize.Height < 2 * _radius) return;
            using var outline = ConfigSearchSurface.RoundedRectangle(new RectangleF(.5f, .5f, Width - 1, Height - 1), _radius);
            using var pen = new Pen(BorderColor);
            if (SectionHeading is { } heading)
            {
                // Keep the existing content insets while extending the header fill to the rounded outline.
                var expanded = heading.Margin.Bottom > 0;
                var bottom = expanded ? Math.Min(Height, heading.Bottom + heading.Margin.Bottom / 2) : Height;
                var state = e.Graphics.Save();
                e.Graphics.SetClip(outline, System.Drawing.Drawing2D.CombineMode.Intersect);
                using var fill = new SolidBrush(EditorBackground);
                e.Graphics.FillRectangle(fill, 0, 0, Width, bottom);
                if (expanded) e.Graphics.DrawLine(pen, 1, bottom, Width - 2, bottom);
                e.Graphics.Restore(state);
            }
            e.Graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
            e.Graphics.DrawPath(pen, outline);
        }
    }

    private static string WeaponLabel(string id) =>
        WarehouseWeaponCatalog.Value.TryGetValue(id, out var entry) ? entry.Label : WarehouseWeaponName(id);

    private static string WarehouseWeaponName(string id) => id switch
    {
        "weapons.missiles.AIM_54" => "AIM-54 Phoenix",
        "weapons.missiles.AIM_54A_Mk47" => "AIM-54A Mk 47",
        "weapons.missiles.AIM_54A_Mk60" => "AIM-54A Mk 60",
        "weapons.missiles.AIM_54C_Mk47" => "AIM-54C Mk 47",
        "weapons.missiles.AIM_54C_Mk60" => "AIM-54C Mk 60",
        _ when id.StartsWith("weapons.", StringComparison.Ordinal) =>
            id[(id.IndexOf('.', "weapons.".Length) + 1)..].Replace('_', ' '),
        _ => id
    };

    private static readonly System.Runtime.CompilerServices.ConditionalWeakTable<DataGridView, EquipmentChecklist>
        EquipmentChecklists = new();

    private static bool IsWeaponList(string key) =>
        key is "ForbiddWeaponsInAllEra" or "restrictedWeapons" or "restrictedWeaponsVietnam" or "WarehouseWeaponCaps";

    private static bool IsEquipmentList(string key) =>
        IsWeaponList(key) || key.StartsWith("allowedPlanes", StringComparison.Ordinal) || key == "restockAircraft";

    private Control BuildEquipmentChecklist(ConfigStringListTable table, string categoryName)
    {
        GuiMetadataEntry? metadata = null;
        _document?.Metadata.Entries.TryGetValue(table.Key, out metadata);
        var title = metadata?.Label ?? table.GuiLabel ?? GetConfiguredGroupLabel(table.Key);
        var helpText = !string.IsNullOrWhiteSpace(metadata?.Help) ? metadata.Help : table.Description;
        var weapons = IsWeaponList(table.Key);
        var itemName = weapons ? "weapon" : "aircraft";
        var itemsName = weapons ? "weapons" : "aircraft";
        var group = new WarehouseCard(Zoomed(5), outlined: false);
        group.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        void AddRow(Control control)
        {
            var row = group.RowCount++;
            group.RowStyles.Add(new RowStyle(SizeType.AutoSize));
            group.Controls.Add(control, 0, row);
        }

        var header = new FlowLayoutPanel
        {
            Dock = DockStyle.Top, AutoSize = true, Margin = Padding.Empty, Padding = GetTableHeaderPadding()
        };
        header.Controls.Add(new Label { Text = title, AutoSize = true, Margin = GetTableHeaderLabelMargin() });
        if (!string.IsNullOrWhiteSpace(helpText)) header.Controls.Add(MakeHelpButton(title, helpText, table.Key));
        AddRow(header);
        ConfigureTableHeaderSizing(group, header);

        StringListRequirementBinding? binding = null;
        var activeLabel = weapons ? "Saved rules" : "Active aircraft";
        var availableLabel = weapons ? "Available weapons" : "Available aircraft";
        var activeCount = MakeCount("EquipmentActiveCount:");
        var count = MakeCount("EquipmentMatchCount:");
        Func<DataGridView, int, string?>? weaponId = weapons ? (list, row) => GetBucketItem(list, row)?.Value : null;
        var active = MakeEquipmentChoiceGrid("EquipmentActive:" + table.Key, activeLabel, StatusText,
            virtualMode: true, dcsId: weaponId, pendingStatus: PendingStatus);
        var grid = MakeEquipmentChoiceGrid("EquipmentChoices:" + table.Key, availableLabel, StatusText,
            virtualMode: true, dcsId: weaponId, pendingStatus: PendingStatus);
        var checklist = new EquipmentChecklist(active, grid, weapons, activeCount, count);
        EquipmentChecklists.Add(active, checklist);
        EquipmentChecklists.Add(grid, checklist);
        grid.RowPostPaint += PaintOptionsRowMarker;

        var searchInput = new TextBox
        {
            Name = "EquipmentSearch:" + table.Key, AccessibleName = "Search " + itemsName,
            PlaceholderText = weapons ? "Search by weapon, aircraft, or DCS ID" : "Search by aircraft name or DCS ID"
        };
        var typeFilter = weapons ? MakeEquipmentWeaponTypeFilter("EquipmentType:" + table.Key) : null;
        var searchRow = MakeEquipmentSearchRow(searchInput, typeFilter);
        searchRow.Margin = new Padding(0, Zoomed(6), 0, Zoomed(8));

        var customId = new TextBox
        {
            Name = "EquipmentCustomId:" + table.Key, AccessibleName = "Custom DCS " + itemName + " ID",
            PlaceholderText = "Exact DCS " + itemName + " ID"
        };
        var customFrame = new ConfigSearchSurface(customId, isSearch: false)
        {
            Width = Zoomed(230), Height = Zoomed(34), Margin = new Padding(0, 0, Zoomed(5), 0)
        };
        ApplyConfigInputMetrics(customFrame);
        var custom = new FlowLayoutPanel { Dock = DockStyle.Top, AutoSize = true, Margin = Padding.Empty };
        var addCustom = MakeWarehouseActionButton("+ Add custom " + itemName, () =>
        {
            custom.Visible = !custom.Visible;
            if (custom.Visible) customId.Focus();
        });
        var add = MakeWarehouseActionButton("Add", AddCustom);
        add.MinimumSize = new Size(add.MinimumSize.Width, customFrame.Height);
        custom.Controls.Add(customFrame);
        custom.Controls.Add(add);
        DataGridView selectedGrid = grid;
        var remove = MakeWarehouseActionButton("Remove entry…", () => RemoveStringListItemRow(table, active, grid, selectedGrid));
        remove.Enabled = false;
        AddRow(new FlowLayoutPanel
        {
            Name = "EquipmentActions:" + table.Key, Dock = DockStyle.Top, AutoSize = true, Margin = Padding.Empty,
            Controls = { addCustom, remove }
        });
        AddRow(custom);
        custom.Visible = false;
        AddRow(searchRow);

        var lists = new TableLayoutPanel
        {
            Dock = DockStyle.Top, AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink,
            ColumnCount = 2, RowCount = 1, Margin = Padding.Empty
        };
        var inAircraftWeapons = categoryName.Equals(WarehouseWeaponCategory, StringComparison.OrdinalIgnoreCase);
        var availableShare = inAircraftWeapons ? 50 : 54;
        lists.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, availableShare));
        lists.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100 - availableShare));
        lists.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        var availablePane = MakeListPane(availableLabel, count, grid);
        var activePane = MakeListPane(activeLabel, activeCount, active);
        availablePane.Margin = new Padding(0, 0, Zoomed(EquipmentPaneHalfGap), 0);
        activePane.Margin = new Padding(Zoomed(EquipmentPaneHalfGap), 0, 0, 0);
        lists.Controls.Add(availablePane, 0, 0);
        lists.Controls.Add(activePane, 1, 0);
        lists.Paint += (_, e) =>
        {
            var gapWidth = activePane.Left - availablePane.Right;
            if (gapWidth <= 0) return;
            using var fill = new SolidBrush(MainBackground);
            e.Graphics.FillRectangle(fill, availablePane.Right, 0, gapWidth, lists.ClientSize.Height);
        };
        AddRow(lists);
        var defaultRows = inAircraftWeapons ? AircraftWeaponsDefaultRows : EquipmentDefaultRows;
        // Caps moved from Logistics / Warehouse and starts with the new category's default height.
        var preferenceKey = inAircraftWeapons && table.Key == "WarehouseWeaponCaps"
            ? WarehouseWeaponCategory + ":" + grid.Name
            : null;
        AddRow(MakeEquipmentListResizeGrip(grid, active, lists, defaultRows, preferenceKey: preferenceKey));

        if (table.RequiredValueRules.Count > 0)
        {
            var reasons = new FlowLayoutPanel
            {
                Name = "RequiredValueReasons:" + table.Key, Dock = DockStyle.Top, AutoSize = true,
                FlowDirection = FlowDirection.TopDown, WrapContents = false, Margin = new Padding(0, Zoomed(6), 0, 0)
            };
            binding = new StringListRequirementBinding(table, active, grid, null, remove, reasons);
            group.Tag = availablePane.Tag = activePane.Tag = binding;
            AddRow(reasons);
        }

        foreach (var choiceGrid in new[] { active, grid })
        {
            choiceGrid.Enter += (_, _) =>
            {
                selectedGrid = choiceGrid;
                UpdateSelection();
            };
            choiceGrid.CurrentCellChanged += (_, _) =>
            {
                if (ReferenceEquals(selectedGrid, choiceGrid)) UpdateSelection();
            };
        }

        searchInput.TextChanged += (_, _) => Filter();
        if (typeFilter is not null) typeFilter.SelectedIndexChanged += (_, _) => Filter();
        customId.KeyDown += (_, e) =>
        {
            if (e.KeyCode != Keys.Enter) return;
            e.Handled = e.SuppressKeyPress = true;
            AddCustom();
        };
        WireEquipmentChoiceToggle(active, row =>
        {
            if (checklist.ItemAt(active, row) is null) return;
            active.CurrentCell = active.Rows[row].Cells[0];
            DeactivateStringListItemRow(table, active, grid);
        }, checkboxOnly: true);
        WireEquipmentChoiceToggle(grid, row =>
        {
            if (checklist.ItemAt(grid, row) is null) return;
            grid.CurrentCell = grid.Rows[row].Cells[0];
            ActivateStringListItemRow(table, active, grid);
        }, checkboxOnly: true);

        BindManagedStringListRefresh(table, group, values => RefreshStringListGrids(active, grid, table, values));
        RefreshStringListGrids(active, grid, table);
        return group;

        Label MakeCount(string name) => new()
        {
            Name = name + table.Key, AutoSize = true, Anchor = AnchorStyles.Right, Margin = Padding.Empty
        };

        WarehouseCard MakeListPane(string label, Label itemCount, DataGridView choices)
        {
            var pane = new WarehouseCard(Zoomed(4), shaded: true)
            {
                Dock = DockStyle.Fill, Padding = new Padding(1), RowCount = 2
            };
            pane.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            for (var row = 0; row < pane.RowCount; row++) pane.RowStyles.Add(new RowStyle(SizeType.AutoSize));

            var caption = new TableLayoutPanel
            {
                Dock = DockStyle.Top, AutoSize = true, AutoSizeMode = AutoSizeMode.GrowAndShrink,
                ColumnCount = 2, RowCount = 1, Margin = Padding.Empty,
                Padding = new Padding(Zoomed(7), Zoomed(4), Zoomed(7), Zoomed(4))
            };
            caption.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            caption.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
            caption.Controls.Add(new Label
            {
                Text = label, AutoSize = true, Anchor = AnchorStyles.Left,
                Font = GetConfigValueFont(.6f, FontStyle.Bold), Margin = new Padding(0, 0, Zoomed(5), 0)
            }, 0, 0);
            caption.Controls.Add(itemCount, 1, 0);
            pane.Controls.Add(caption, 0, 0);
            pane.Controls.Add(choices, 0, 1);
            return pane;
        }

        void UpdateSelection()
        {
            if (binding is not null) ShowRequiredValueReasons(binding, selectedGrid);
            else if (GetBucketItem(selectedGrid, selectedGrid.CurrentCellAddress.Y) is { } item)
                remove.Enabled = item.Item is not null || !weapons || !WarehouseWeaponCatalog.Value.ContainsKey(item.Value);
            else remove.Enabled = false;
        }

        void Filter()
        {
            var prefix = typeFilter is null ? null : WarehouseWeaponTypes[typeFilter.SelectedIndex].Prefix;
            checklist.Filter(new EquipmentSearchQuery(searchInput.Text, prefix));
        }

        void AddCustom()
        {
            var value = customId.Text.Trim();
            if (value.Length == 0) return;
            if (!table.Items.Any(item => item.Value.Equals(value, StringComparison.Ordinal)))
                AddStringListItemRow(table, active, grid, value);
            if (!table.Items.Any(item => item.Value.Equals(value, StringComparison.Ordinal))) return;

            SelectBucketRowByValue(active, value);
            customId.Clear();
            custom.Visible = false;
            addCustom.Focus();
        }

        string? StatusText(DataGridView choiceGrid, int row)
        {
            if (GetBucketItem(choiceGrid, row) is not { } item) return null;
            return binding?.Facts.IsRequired(item.Value) == true
                ? AutomaticAircraftHighlights(table)?.ContainsKey(item.Value) == true ? "Activated for AI" : "Used by AI"
                : item.IsNew ? "New" : null;
        }

        string? PendingStatus(DataGridView choiceGrid, int row)
        {
            if (GetBucketItem(choiceGrid, row) is not { } item ||
                _document?.WasStringListValueActive(table.Key, item.Value) is not bool wasActive || wasActive == item.IsActive)
                return null;
            return item.IsActive ? "ADDED" : "REMOVED";
        }
    }

    private WheelSafeComboBox MakeEquipmentWeaponTypeFilter(string name)
    {
        var type = new WheelSafeComboBox
        {
            Name = name, AccessibleName = "Weapon type",
            Width = Zoomed(150), Margin = Padding.Empty, DropDownStyle = ComboBoxStyle.DropDownList
        };
        StyleConfigDropdown(type);
        type.Items.AddRange(WarehouseWeaponTypes.Select(item => (object)item.Label).ToArray());
        type.SelectedIndex = 0;
        return type;
    }

    private static StringListBucketItem? GetBucketItem(DataGridView grid, int index)
    {
        if ((uint)index >= (uint)grid.RowCount) return null;
        return EquipmentChecklists.TryGetValue(grid, out var checklist)
            ? checklist.ItemAt(grid, index)
            : grid.Rows[index].Tag as StringListBucketItem;
    }

    private sealed class EquipmentChecklist
    {
        private readonly DataGridView _active;
        private readonly DataGridView _grid;
        private readonly bool _weapons;
        private readonly Label _activeCount;
        private readonly Label _count;
        private EquipmentSearch<StringListBucketItem>? _index;
        private StringListBucketItem[] _visible = [];
        private EquipmentSearchQuery _query = new("", null);
        private StringListBucketItem[] _selected = [];

        internal EquipmentChecklist(DataGridView active, DataGridView grid, bool weapons, Label activeCount,
            Label count)
        {
            _active = active;
            _grid = grid;
            _weapons = weapons;
            _activeCount = activeCount;
            _count = count;
            active.CellValueNeeded += SupplyCellValue;
            grid.CellValueNeeded += SupplyCellValue;
        }

        private void SupplyCellValue(object? sender, DataGridViewCellValueEventArgs e)
        {
            if (ItemAt((DataGridView)sender!, e.RowIndex) is { } item)
                e.Value = e.ColumnIndex == 0 ? item.IsActive : _weapons ? WeaponLabel(item.Value) : item.Value;
        }

        internal StringListBucketItem? ItemAt(DataGridView grid, int index)
        {
            var rows = ReferenceEquals(grid, _active) ? _selected : _visible;
            return (uint)index < (uint)rows.Length ? rows[index] : null;
        }

        internal void SetItems(IEnumerable<StringListBucketItem> items)
        {
            var configured = new Dictionary<string, StringListBucketItem>(StringComparer.Ordinal);
            foreach (var item in items) configured.TryAdd(item.Value, item);
            var ids = configured.Keys.OrderBy(id => _weapons ? WeaponLabel(id) : id, StringComparer.OrdinalIgnoreCase)
                .ThenBy(id => id, StringComparer.Ordinal);
            var selected = ids.Select(id => configured[id]).Where(item => item.IsActive).ToArray();
            var rows = (_weapons ? EquipmentWeaponIds(ids) : ids).Select(id => configured.GetValueOrDefault(id)
                ?? new StringListBucketItem(id, null, IsActive: false, CatalogOnly: true, IsNew: false));
            _index = new EquipmentSearch<StringListBucketItem>(rows.Where(item => !item.IsActive), item => item.Value, _weapons);
            _activeCount.Text = selected.Length.ToString();
            UpdateGrid(_active, ref _selected, selected);
            RefreshRows();
        }

        internal void Filter(EquipmentSearchQuery query)
        {
            _query = query;
            RefreshRows();
        }

        private void RefreshRows()
        {
            if (_index is null) return;
            var visible = _index.Filter(_query);
            UpdateGrid(_grid, ref _visible, visible);
            _count.Text = visible.Length == 0 ? "No matches" :
                $"{visible.Length} {(visible.Length == 1 ? "match" : "matches")}";
        }

        private static void UpdateGrid(DataGridView grid, ref StringListBucketItem[] current, StringListBucketItem[] rows)
        {
            if (current.AsSpan().SequenceEqual(rows)) return;
            var index = grid.CurrentCellAddress.Y;
            var selected = (uint)index < (uint)current.Length ? current[index].Value : null;
            grid.CurrentCell = null;
            current = rows;
            if (grid.RowCount != rows.Length) grid.RowCount = rows.Length;
            grid.CurrentCell = null;
            if (selected is not null) SelectBucketRowByValue(grid, selected);
            grid.Invalidate();
        }
    }

    private readonly record struct EquipmentSearchQuery
    {
        internal EquipmentSearchQuery(string text, string? prefix)
        {
            Term = text.Trim();
            Normalized = NormalizeEquipmentSearch(Term);
            Prefix = prefix;
        }

        internal string Term { get; }
        internal string Normalized { get; }
        internal string? Prefix { get; }
        internal bool IsEmpty => Term.Length == 0 && Prefix is null;
    }

    private sealed class EquipmentSearch<T>
    {
        private readonly record struct IndexedItem(T Item, string Id, EquipmentSearchEntry Entry);

        private readonly T[] _items;
        private readonly IndexedItem[] _index;
        private readonly bool _weapons;
        private EquipmentSearchQuery? _lastQuery;
        private T[]? _lastResult;

        internal EquipmentSearch(IEnumerable<T> items, Func<T, string> getId, bool weapons)
        {
            _items = items.ToArray();
            _index = new IndexedItem[_items.Length];
            _weapons = weapons;
            var catalog = weapons ? WarehouseWeaponCatalog.Value : null;
            for (var i = 0; i < _items.Length; i++)
            {
                var id = getId(_items[i]);
                var entry = catalog?.GetValueOrDefault(id)
                    ?? new EquipmentSearchEntry(weapons ? WarehouseWeaponName(id) : id, NormalizeEquipmentSearch(id),
                        weapons ? "" : string.Join("|", AircraftSearchTerms(id).Select(NormalizeEquipmentSearch)));
                _index[i] = new IndexedItem(_items[i], id, entry);
            }
        }

        internal T[] Filter(EquipmentSearchQuery query)
        {
            if (query.IsEmpty) return _items;
            if (_lastQuery == query) return _lastResult!;

            var roleAlias = !_weapons ? null : query.Normalized switch
            {
                "ASM" or "ANTISHIP" or "ANTISHIPMISSILE" or "ANTISHIPMISSILES" => "|ASM|",
                "ARM" or "ANTIRADIATION" or "ANTIRADIATIONMISSILE" or "ANTIRADIATIONMISSILES"
                    or "ANTIRADAR" => "|ARM|",
                _ => null
            };
            var result = new List<T>();
            foreach (var item in _index)
            {
                if (query.Prefix is not null && !item.Id.StartsWith(query.Prefix, StringComparison.OrdinalIgnoreCase)) continue;
                if (roleAlias is not null)
                {
                    if (item.Entry.SearchNames.Contains(roleAlias, StringComparison.Ordinal))
                        result.Add(item.Item);
                    continue;
                }

                if (item.Id.Contains(query.Term, StringComparison.OrdinalIgnoreCase) ||
                    item.Entry.Label.Contains(query.Term, StringComparison.OrdinalIgnoreCase) ||
                    query.Normalized.Length > 0 &&
                    (item.Entry.SearchId.Contains(query.Normalized, StringComparison.Ordinal) ||
                     item.Entry.SearchNames.Contains(query.Normalized, StringComparison.Ordinal)))
                {
                    result.Add(item.Item);
                }
            }

            _lastQuery = query;
            return _lastResult = result.ToArray();
        }
    }

    private static IEnumerable<string> AircraftSearchTerms(string id)
    {
        yield return id;
        var name = id.ToUpperInvariant();
        var aliases = name switch
        {
            "FA-18C_HORNET" or "F/A-18C" => "Hornet|F/A-18",
            "FA-18E" or "FA-18F" or "F/A-18E" or "F/A-18F" => "Super Hornet|F/A-18",
            "HERCULES" or "C-130" or "C-130J-30" => "Hercules|C-130",
            "A-10A" or "A-10C" or "A-10C_2" => "Warthog|Thunderbolt II",
            "AV8BNA" => "Harrier|AV-8B",
            "KA-50" or "KA-50_3" => "Black Shark",
            "UH-1H" => "Huey",
            "OH58D" or "OH-58D" => "Kiowa|OH-58",
            "M-2000C" => "Mirage 2000",
            "AJS37" => "Viggen",
            "JF-17" => "Thunder",
            _ when name.StartsWith("AH-64", StringComparison.Ordinal) => "Apache",
            _ when name.StartsWith("CH-47", StringComparison.Ordinal) => "Chinook",
            _ when name.StartsWith("F-14", StringComparison.Ordinal) => "Tomcat",
            _ when name.StartsWith("F-15", StringComparison.Ordinal) => "Eagle",
            _ when name.StartsWith("F-16", StringComparison.Ordinal) => "Viper|Fighting Falcon",
            _ when name.StartsWith("F-4E", StringComparison.Ordinal) => "Phantom II",
            _ when name.StartsWith("MIG-21", StringComparison.Ordinal) => "Fishbed",
            _ when name.StartsWith("MIG-29", StringComparison.Ordinal) => "Fulcrum",
            _ when name.StartsWith("MI-24", StringComparison.Ordinal) => "Hind",
            _ when name.StartsWith("MI-8", StringComparison.Ordinal) => "Hip",
            _ when name.StartsWith("SA342", StringComparison.Ordinal) => "Gazelle",
            _ => ""
        };
        foreach (var alias in aliases.Split('|', StringSplitOptions.RemoveEmptyEntries))
            yield return alias;
    }

    private static string NormalizeEquipmentSearch(string input) =>
        string.Concat(input.Where(char.IsLetterOrDigit)).ToUpperInvariant();
}
