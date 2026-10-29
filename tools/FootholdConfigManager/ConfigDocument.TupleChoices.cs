namespace FootholdConfigManager;

internal sealed record TupleChoiceSpec(int Index, string Source, string[] ActiveLists, string Label,
    IReadOnlyList<(string SourceKey, List<string> Values)> VisibleWhen);
internal sealed record TupleChoiceState(TupleChoiceSpec Spec, List<ConfigChoice> Choices, string? Default,
    HashSet<string>? Active, bool Visible)
{
    internal bool Admits(string key) => Visible && Choices.Count > 0 && (Active is null || Active.Contains(key));
    internal ConfigChoice? Find(string value) => Choices.FirstOrDefault(choice =>
        StringComparer.Ordinal.Equals(ConfigEntry.UnquoteLuaString(choice.Literal), ConfigEntry.UnquoteLuaString(value)));
}
internal sealed record TupleChoiceSnapshot(Dictionary<int, TupleChoiceState> Fields)
{
    internal bool Admits(string key) => Fields.Values.Any(field => field.Admits(key));
}
internal sealed record TupleChoiceChange(ConfigEntry Entry, string Before, string After);

internal sealed partial class ConfigDocument
{
    private readonly Dictionary<string, List<TupleChoiceSpec>> _tupleChoiceSpecs = new(StringComparer.Ordinal);
    private readonly Dictionary<string, IReadOnlyList<(string SourceKey, List<string> Values)>> _tupleChoiceDefaults = new(StringComparer.Ordinal);

    private void ReadTupleChoiceSpecs(string key, IEnumerable<string> comments)
    {
        var text = ReadGuiAttribute(comments, "tupleChoices");
        if (text is null) return;
        var labels = (ReadGuiAttribute(comments, "tupleChoiceLabels") ?? "").Split('|')
            .Select(part => part.Split(':', 2)).Where(part => part.Length == 2).ToDictionary(part => part[0], part => part[1]);
        var visibility = (ReadGuiAttribute(comments, "tupleChoiceVisibleWhen") ?? "").Split('|')
            .Select(part => part.Split(':', 2)).Where(part => part.Length == 2).ToDictionary(part => part[0], part => part[1]);
        var specs = new List<TupleChoiceSpec>();
        foreach (var part in text.Split('|'))
        {
            var pieces = part.Split(':', 3);
            if (pieces.Length < 2 || !int.TryParse(pieces[0], out var index) || index < 1 || index > 32)
                throw new InvalidOperationException(key + ": invalid tupleChoices field.");
            var when = visibility.GetValueOrDefault(pieces[0]);
            specs.Add(new(index - 1, pieces[1], pieces.Length == 3 ? pieces[2].Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries) : Array.Empty<string>(),
                labels.GetValueOrDefault(pieces[0]) ?? "Selection", when is null ? Array.Empty<(string, List<string>)>() : ConfigConditions.Parse(when)));
        }
        _tupleChoiceSpecs[key] = specs;
    }

    internal bool HasTupleChoices(string key) => _tupleChoiceSpecs.ContainsKey(key);
    internal IEnumerable<string> TupleChoiceTargets => _tupleChoiceSpecs.Keys;

    internal TupleChoiceSnapshot? ResolveTupleChoices(string key, RequiredValueSources? sources = null)
    {
        if (!_tupleChoiceSpecs.TryGetValue(key, out var specs)) return null;
        sources ??= new RequiredValueSources(Entries);
        bool Matches(IReadOnlyList<(string SourceKey, List<string> Values)> rules) => rules.All(rule =>
            sources.Find(rule.SourceKey) is { } entry && ConfigConditions.ValueMatches(entry.ValueText, rule.Values));
        var fields = new Dictionary<int, TupleChoiceState>();
        foreach (var spec in specs)
        {
            var choices = new List<ConfigChoice>();
            string? defaultValue = null;
            if (!sources.ByParent.TryGetValue(spec.Source, out var rows))
            {
                if (!TryGetTableBlockText(spec.Source, out _))
                    throw new InvalidOperationException(key + ": unresolved tupleChoices source " + spec.Source);
                rows = new();
            }
            foreach (var row in rows)
            {
                if (row.Kind != ConfigValueKind.Boolean || !row.ValueText.Equals("true", StringComparison.OrdinalIgnoreCase)) continue;
                var literal = "\"" + EscapeLuaKey(row.Key) + "\"";
                var label = row.InlineComment.Trim();
                var eraEnd = label.IndexOf(';');
                if (label.StartsWith("eras=", StringComparison.OrdinalIgnoreCase) && eraEnd >= 0) label = label[(eraEnd + 1)..].Trim();
                choices.Add(new(string.IsNullOrWhiteSpace(label) ? row.DisplayName : label, literal));
                if (defaultValue is null && _tupleChoiceDefaults.TryGetValue(row.DisplayKey, out var rules) && Matches(rules)) defaultValue = literal;
            }
            // Duplicate friendly labels must still identify their exact, different payloads.
            foreach (var group in choices.GroupBy(choice => choice.Display).Where(group => group.Count() > 1).ToArray())
                foreach (var choice in group.ToArray()) choices[choices.IndexOf(choice)] = new(choice.Display + " — " + ConfigEntry.UnquoteLuaString(choice.Literal), choice.Literal);
            HashSet<string>? active = null;
            foreach (var listKey in spec.ActiveLists)
            {
                var table = StringListTables.FirstOrDefault(table => table.Key == listKey)
                    ?? throw new InvalidOperationException(key + ": unresolved tupleChoices aircraft list " + listKey);
                if (!string.IsNullOrWhiteSpace(table.GuiVisibleWhen) && !Matches(ConfigConditions.Parse(table.GuiVisibleWhen))) continue;
                active ??= new(StringComparer.Ordinal);
                active.UnionWith(table.Items.Select(item => item.Value));
            }
            fields[spec.Index] = new(spec, choices, defaultValue ?? choices.FirstOrDefault()?.Literal, active, Matches(spec.VisibleWhen));
        }
        return new(fields);
    }

    internal void ConfigureTupleChoiceFields(ConfigEntry entry, TupleChoiceSnapshot snapshot)
    {
        foreach (var state in snapshot.Fields.Values)
        {
            while (entry.TupleFields.Count <= state.Spec.Index) entry.TupleFields.Add(new(state.Spec.Label, ConfigTupleFieldKind.Choice));
            entry.TupleFields[state.Spec.Index].Choices = state.Choices;
        }
    }

    internal List<TupleChoiceChange> PlanTupleChoiceChanges(string key, TupleChoiceSnapshot snapshot, bool legacyOnly = false)
    {
        var changes = new List<TupleChoiceChange>();
        foreach (var entry in Entries.Where(entry => entry.ParentKey == key))
        {
            var values = entry.GetTupleValues();
            var changed = false;
            foreach (var state in snapshot.Fields.Values)
            {
                if (state.Default is null || (legacyOnly ? state.Choices.Count == 0 : !state.Admits(entry.Key))) continue;
                var previous = values.ElementAtOrDefault(state.Spec.Index);
                if (legacyOnly && previous is not null && previous != "nil" && !int.TryParse(previous, out _)) continue;
                while (values.Count <= state.Spec.Index) values.Add("nil");
                if (state.Find(values[state.Spec.Index]) is not null) continue;
                values[state.Spec.Index] = state.Default;
                changed = true;
            }
            if (changed) changes.Add(new(entry, entry.ValueText, "{ " + string.Join(", ", values) + " }"));
        }
        return changes;
    }

    internal void PrepareTupleChoiceMigration()
    {
        if (_tupleChoiceSpecs.Count == 0) return;
        var sources = new RequiredValueSources(Entries);
        foreach (var key in _tupleChoiceSpecs.Keys)
            foreach (var change in PlanTupleChoiceChanges(key, ResolveTupleChoices(key, sources)!, legacyOnly: true))
                change.Entry.ValueText = change.After;
    }

    private List<string> ValidateTupleChoices()
    {
        var errors = new List<string>();
        if (_tupleChoiceSpecs.Count == 0) return errors;
        var sources = new RequiredValueSources(Entries);
        foreach (var key in _tupleChoiceSpecs.Keys)
        {
            TupleChoiceSnapshot snapshot;
            try { snapshot = ResolveTupleChoices(key, sources)!; }
            catch (InvalidOperationException error) { errors.Add(error.Message); continue; }
            if (_guiTableDisabledWhen.TryGetValue(key, out var disabled) && ConfigConditions.Parse(disabled).All(rule =>
                sources.Find(rule.SourceKey) is { } source && ConfigConditions.ValueMatches(source.ValueText, rule.Values))) continue;
            foreach (var entry in sources.ByParent.GetValueOrDefault(key) ?? new())
            {
                var values = entry.GetTupleValues();
                if (values.Count == 0 || !values[0].Equals("true", StringComparison.OrdinalIgnoreCase)) continue;
                foreach (var field in snapshot.Fields.Values)
                    if (field.Admits(entry.Key) && field.Find(values.ElementAtOrDefault(field.Spec.Index) ?? "nil") is null)
                        errors.Add(entry.DisplayName + ": select an enabled " + field.Spec.Label + " template, or turn this row off.");
            }
        }
        return errors;
    }

    internal bool TupleChoicesDependOn(string key, ConfigEntry changed) => _tupleChoiceSpecs.TryGetValue(key, out var specs) &&
        specs.Any(spec => spec.Source == changed.ParentKey || spec.Source == changed.Key || spec.ActiveLists.Contains(changed.Key) ||
            spec.VisibleWhen.Any(rule => rule.SourceKey == changed.Key) ||
            _tupleChoiceDefaults.Any(pair => pair.Key.StartsWith(spec.Source + ".", StringComparison.Ordinal) && pair.Value.Any(rule => rule.SourceKey == changed.Key)) ||
            spec.ActiveLists.Any(listKey => StringListTables.FirstOrDefault(table => table.Key == listKey) is { } table &&
                ConfigConditions.Parse(table.GuiVisibleWhen ?? "").Any(rule => rule.SourceKey == changed.Key)));
}
