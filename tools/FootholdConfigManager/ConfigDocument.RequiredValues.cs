using System.Text.RegularExpressions;
namespace FootholdConfigManager;

internal sealed record RequiredValueRule(string? Values, string? From, string? When, string? Reason, string? Source,
    IReadOnlyList<(string SourceKey, List<string> Values)> Conditions, bool MalformedCondition, string MetadataLine, string? Sets = null, string? Each = null)
{
    internal IReadOnlyList<RequiredConditionSelector> ParsedConditions { get; } = Conditions.Select(RequiredConditionSelector.Read).ToArray();
    internal string[] ExactValues { get; } = Values?.Split('|', StringSplitOptions.TrimEntries | StringSplitOptions.RemoveEmptyEntries) ?? Array.Empty<string>();
    internal string[] SourceKeys { get; } = From?.Split('|', StringSplitOptions.TrimEntries | StringSplitOptions.RemoveEmptyEntries) ?? Array.Empty<string>();
    internal string[] SetKeys { get; } = Sets?.Split('|', StringSplitOptions.TrimEntries | StringSplitOptions.RemoveEmptyEntries) ?? Array.Empty<string>();
}
internal sealed record RequiredValueReason(string Text, ConfigEntry? Source, IReadOnlyList<ConfigEntry> SourceEntries);
internal sealed class RequiredValueResolution
{
    internal static readonly RequiredValueResolution Empty = new();
    internal Dictionary<string, List<RequiredValueReason>> Values { get; } = new(StringComparer.Ordinal);
    internal List<string> Errors { get; } = new();
    public IReadOnlyList<RequiredValueReason> ReasonsFor(string value) => Values.TryGetValue(value, out var reasons) ? reasons : Array.Empty<RequiredValueReason>();
    public bool IsRequired(string value) => Values.ContainsKey(value);
    public string RemovalMessage(string value) => value + " is used by AI. Disable its requiring options first.";
}
internal sealed partial class RequiredValueSources
{
    internal Dictionary<string, RequiredValueResolution> RequiredSetResults { get; } = new(StringComparer.Ordinal);
    internal HashSet<string> ResolvingRequiredSets { get; } = new(StringComparer.Ordinal);
    internal Dictionary<string, ConfigEntry> ByDisplay { get; } = new(StringComparer.Ordinal);
    internal Dictionary<string, ConfigEntry> ByKey { get; } = new(StringComparer.Ordinal);
    internal Dictionary<string, List<ConfigEntry>> ByParent { get; } = new(StringComparer.Ordinal);
    internal RequiredValueSources(IEnumerable<ConfigEntry> entries)
    {
        foreach (var entry in entries)
        {
            ByDisplay.TryAdd(entry.DisplayKey, entry); ByKey.TryAdd(entry.Key, entry);
            if (string.IsNullOrEmpty(entry.ParentKey)) continue;
            if (!ByParent.TryGetValue(entry.ParentKey, out var rows)) ByParent[entry.ParentKey] = rows = new();
            rows.Add(entry);
        }
    }
    internal ConfigEntry? Find(string key) => ByDisplay.GetValueOrDefault(key) ?? ByKey.GetValueOrDefault(key);
}
internal sealed partial class ConfigDocument
{
    private readonly Dictionary<string, List<RequiredValueRule>> _requiredValueSets = new(StringComparer.Ordinal);

    private bool ReadRequiredValueSetDefinition(string comment)
    {
        if (!comment.Contains("requiredSet", StringComparison.OrdinalIgnoreCase)) return false;
        var definition = GuiAttributeRegex.Matches(comment).Cast<Match>().FirstOrDefault(m => m.Groups["name"].Value.Equals("requiredSet", StringComparison.OrdinalIgnoreCase));
        if (definition is null) return false;
        var name = ReadGuiAttributeValue(definition, literal: true) ?? "";
        if (!_requiredValueSets.TryGetValue(name, out var rules)) _requiredValueSets[name] = rules = new();
        rules.AddRange(ReadRequiredValueRules(new[] { CleanComment(comment) }));
        return true;
    }
    private static IReadOnlyList<RequiredValueRule> ReadRequiredValueRules(IEnumerable<string> comments)
    {
        List<RequiredValueRule>? rules = null;
        foreach (var comment in comments)
        {
            var line = comment.Trim();
            if (!line.StartsWith("@gui", StringComparison.OrdinalIgnoreCase) || !line.Contains("required", StringComparison.OrdinalIgnoreCase)) continue;
            var attrs = new Dictionary<string, string?>(StringComparer.OrdinalIgnoreCase);
            foreach (Match match in ReadGuiMatches(comments, line)) attrs[match.Groups["name"].Value] = ReadGuiAttributeValue(match, literal: true);
            if (!new[] { "requiredValues", "requiredValuesFrom", "requiredWhen", "requiredReason", "requiredSource", "requiredSets", "requiredEach" }.Any(attrs.ContainsKey)) continue;
            string? Read(string key) => attrs.GetValueOrDefault(key);
            var when = Read("requiredWhen");
            var conditions = ConfigConditions.Parse(when ?? "", out var malformed);
            malformed &= when is not null;
            (rules ??= new()).Add(new(Read("requiredValues"), Read("requiredValuesFrom"), when, Read("requiredReason"), Read("requiredSource"), conditions, malformed, "-- " + line, Read("requiredSets"), Read("requiredEach")));
        }
        return rules ?? (IReadOnlyList<RequiredValueRule>)Array.Empty<RequiredValueRule>();
    }

    // One operation snapshot; no retained evaluated flags or catalog/native discovery.
    internal RequiredValueResolution ResolveRequiredValues(ConfigStringListTable table) => ResolveRequiredValues(table, null);
    internal RequiredValueResolution ResolveRequiredValues(ConfigStringListTable table, RequiredValueSources? sources)
    {
        if (table.RequiredValueRules.Count == 0) return RequiredValueResolution.Empty;
        return ResolveRequiredValueRules(table.RequiredValueRules, table.Key, sources ?? new RequiredValueSources(Entries));
    }

    private RequiredValueResolution ResolveRequiredValueRules(IReadOnlyList<RequiredValueRule> rules, string owner, RequiredValueSources sources)
    {
        var result = new RequiredValueResolution();
        ConfigEntry? Source(string key) => sources.Find(key);
        void Error(string text) => result.Errors.Add(owner + ": " + text);
        bool Applies(RequiredValueRule rule, ConfigEntry? each = null)
        {
            var valid = !rule.MalformedCondition;
            if (!valid) Error("Malformed requiredWhen: " + rule.When);
            var matches = true;
            foreach (var condition in rule.ParsedConditions)
            {
                var resolved = each is not null && condition.BaseKey == "$" ? condition with { SourceKey = each.DisplayKey + condition.SourceKey[1..], BaseKey = each.DisplayKey } : condition;
                var matched = sources.MatchRequiredCondition(resolved, out var error);
                if (error is not null) { Error(error); valid = false; }
                else if (!matched) matches = false;
            }
            return valid && matches;
        }
        void Add(RequiredValueRule rule, ConfigEntry? actual, bool enabled, bool each = false)
        {
            var applies = Applies(rule, each ? actual : null);
            var navigation = actual;
            if (rule.Source is not null)
            {
                navigation = Source(rule.Source);
                if (navigation is null) { Error("Unresolved requiredSource: " + rule.Source); return; }
            }
            if (string.IsNullOrWhiteSpace(rule.Values)) { Error("requiredValues must contain an exact value."); return; }
            var values = rule.ExactValues;
            if (values.Length == 0) { Error("requiredValues must contain an exact value."); return; }
            if (!enabled || !applies) return;
            IReadOnlyList<ConfigEntry> sourceEntries = navigation is null ? Array.Empty<ConfigEntry>() : sources.ByParent.TryGetValue(navigation.ParentKey, out var peers) ? peers : new[] { navigation };
            foreach (var value in values)
            {
                if (!result.Values.TryGetValue(value, out var reasons)) result.Values[value] = reasons = new();
                var text = rule.Reason ?? actual?.DisplayName ?? "AI service";
                if (each) text = text.Replace("{key}", actual!.Key, StringComparison.Ordinal);
                var reason = new RequiredValueReason(text, navigation, sourceEntries);
                if (!reasons.Any(existing => StringComparer.Ordinal.Equals(existing.Text, reason.Text) && ReferenceEquals(existing.Source, reason.Source))) reasons.Add(reason);
            }
        }
        foreach (var target in rules)
        {
            if (target.Sets is not null)
            {
                var applies = Applies(target);
                if (target.SetKeys.Length == 0) Error("requiredSets must contain an actual set.");
                foreach (var key in target.SetKeys)
                {
                    if (!_requiredValueSets.TryGetValue(key, out var setRules)) { Error("Unresolved requiredSets: " + key); continue; }
                    if (setRules.Count == 0) { Error("Empty requiredSet: " + key); continue; }
                    if (!sources.RequiredSetResults.TryGetValue(key, out var setFacts))
                    {
                        if (!sources.ResolvingRequiredSets.Add(key)) { Error("Cyclic requiredSets: " + key); continue; }
                        setFacts = ResolveRequiredValueRules(setRules, "requiredSet " + key, sources);
                        sources.ResolvingRequiredSets.Remove(key);
                        sources.RequiredSetResults[key] = setFacts;
                    }
                    result.Errors.AddRange(setFacts.Errors);
                    if (!applies) continue;
                    foreach (var pair in setFacts.Values)
                    {
                        if (!result.Values.TryGetValue(pair.Key, out var reasons)) result.Values[pair.Key] = reasons = new();
                        foreach (var reason in pair.Value)
                            if (!reasons.Any(r => r.Text == reason.Text && ReferenceEquals(r.Source, reason.Source))) reasons.Add(reason);
                    }
                }
            }
            if (target.Each is not null)
            {
                if (!sources.ByParent.TryGetValue(target.Each, out var rows)) Error("Unresolved requiredEach: " + target.Each);
                else foreach (var row in rows) Add(target, row, true, each: true);
            }
            if (target.From is not null)
            {
                var applies = Applies(target);
                var keys = target.SourceKeys;
                if (keys.Length == 0) Error("requiredValuesFrom must contain an actual source.");
                foreach (var key in keys)
                {
                    var contributing = sources.ByParent.TryGetValue(key, out var rows) ? rows : Source(key) is { } scalar ? new List<ConfigEntry> { scalar } : null;
                    if (contributing is null) { Error("Unresolved requiredValuesFrom: " + key); continue; }
                    foreach (var source in contributing)
                    {
                        if (source.Kind != ConfigValueKind.Boolean) { Error("Required source must be Boolean: " + source.DisplayKey); continue; }
                        foreach (var rule in source.RequiredValueRules) Add(rule, source, applies && ConfigConditions.ValueMatches(source.ValueText, new[] { "true" }));
                    }
                }
            }
            if (target.Values is not null && target.Each is null) Add(target, null, true);
            if (target.From is null && target.Values is null && target.Sets is null) Error("Requirement contribution needs requiredValues, requiredValuesFrom or requiredSets.");
        }
        return result;
    }

    internal bool RequiredValuesDependOn(ConfigStringListTable table, ConfigEntry changed, Func<ConfigEntry, bool>? presentationDepends = null, Func<RequiredValueSources>? getSources = null)
    {
        if (table.RequiredValueRules.Count == 0) return false;
        RequiredValueSources? sources = null;
        RequiredValueSources Sources() => getSources?.Invoke() ?? (sources ??= new RequiredValueSources(Entries));
        bool Depends(RequiredValueRule r) => r.ParsedConditions.Any(c =>
            c.SourceKey == changed.DisplayKey || c.SourceKey == changed.Key ||
            c.Index is not null && !c.Invalid && (c.BaseKey == changed.DisplayKey || c.BaseKey == changed.Key) && Sources().Find(c.SourceKey) is null) ||
            r.Source == changed.DisplayKey || r.Source == changed.Key;
        var seenSets = new HashSet<string>(StringComparer.Ordinal);
        bool RulesDepend(IReadOnlyList<RequiredValueRule> rules)
        {
            foreach (var rule in rules)
            {
                if (rule.Each is not null && (rule.Each == changed.ParentKey || rule.Each == changed.DisplayKey || rule.Each == changed.Key)) return true;
                if (Depends(rule)) return true;
                if (rule.Source is not null && presentationDepends is not null && Sources().Find(rule.Source) is { } linkedSource && presentationDepends(linkedSource)) return true;
                foreach (var key in rule.SetKeys)
                    if (seenSets.Add(key) && _requiredValueSets.TryGetValue(key, out var setRules) && RulesDepend(setRules)) return true;
                if (rule.From is null) continue;
                foreach (var key in rule.SourceKeys)
                {
                    if (key == changed.DisplayKey || key == changed.Key || key == changed.ParentKey) return true;
                    if (Entries.Any(e => (e.ParentKey == key || e.DisplayKey == key || e.Key == key) && (e.RequiredValueRules.Any(Depends) || e.RequiredValueRules.Count > 0 && presentationDepends?.Invoke(e) == true))) return true;
                }
            }
            return false;
        }
        return RulesDepend(table.RequiredValueRules);
    }

    internal List<string> ValidateRequiredValues()
        => ValidateRequiredValuesCore(null);

    private List<string> ValidateRequiredValuesCore(List<string>? importWarnings)
    {
        var errors = new List<string>();
        RequiredValueSources? sources = null;
        foreach (var table in StringListTables)
        {
            if (table.RequiredValueRules.Count == 0) continue;
            var managed = GetManagedStringListValues(table);
            if (table.ManagedSource is not null && managed is null) continue;
            sources ??= new RequiredValueSources(Entries);
            var facts = ResolveRequiredValues(table, sources); errors.AddRange(facts.Errors);
            if (facts.Values.Count == 0) continue;
            var active = table.Items.Select(i => i.Value).ToHashSet(StringComparer.Ordinal);
            foreach (var value in facts.Values.Keys)
                if (!active.Contains(value) && managed?.Contains(value) != true)
                {
                    if (importWarnings is null) errors.Add(table.Key + ": " + value + " is used by AI and must be active.");
                    else importWarnings.Add(table.Key + ": " + value + " is used by AI but is not active. Review its aircraft list or AI settings.");
                }
        }
        return errors.Distinct(StringComparer.Ordinal).ToList();
    }

    // The retained old row owns these annotations; an arbitrary Add template never does.
    internal void PreserveRequiredValueMetadata(ConfigEntry added, ConfigEntry original)
    {
        if (original.RequiredValueRules.Count == 0) return;
        added.RequiredValueRules = original.RequiredValueRules;
        var lines = original.RequiredValueRules.Select(r => GetEntryIndent(added) + r.MetadataLine).ToList();
        var at = added.LineIndex; ShiftLineIndexes(at, lines.Count); _lines.InsertRange(at, lines);
        _hasStructuralChanges = true;
    }
}
