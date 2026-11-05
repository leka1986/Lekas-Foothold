using System.Collections.Frozen;
using System.Globalization;
using System.Text;
using Loretta.CodeAnalysis.Lua.Syntax;

namespace FootholdConfigManager;

// Pure per-inspection facts. Results retain no Lua tables, syntax trees or member payloads.
internal static class MissionScriptReferenceFacts
{
    internal sealed record Binding(string Key, string MemberPath, string CompiledPath, string EditorPath);
    private sealed record CompiledBodyFacts(IReadOnlyList<(int Start, int Length, string Key)> ScriptLookups,
        FrozenSet<string> AllDecodedStrings, FrozenSet<string> OtherDecodedStrings, bool UnresolvedLookup);
    internal sealed record Result(FrozenDictionary<string, Binding> Bindings,
        FrozenDictionary<string, Binding> BindingsByMember, FrozenDictionary<string, string> PathOverrides,
        FrozenSet<string> UnsafeKeys, (int Actions, int Other, int Reused) BodyParses, string? Error);

    internal sealed record TaskExecutable(string Kind, string BodySha256, int ByteLength, string Wrapper, bool Enabled, bool Auto, int Count);
    internal sealed record TaskFacts(IReadOnlyList<TaskExecutable> Executables, int Occurrences, int BodyHashes, int BodyReuses, string? Error);
    private const int MaximumTaskOccurrences = 4096, MaximumTaskBodyBytes = 16 * 1024 * 1024;

    // Exact code inventory, not execution-context equality. Indices/names/coordinates are PLAYER data.
    internal static TaskFacts ProduceTasks(LuaDataTable mission)
    {
        var memo = new Dictionary<string, (string Hash, int Bytes)>(StringComparer.Ordinal);
        var inventory = new Dictionary<string, TaskExecutable>(StringComparer.Ordinal);
        var containers = new HashSet<LuaDataTable>();
        var keys = new List<object>(); var tables = new List<LuaDataTable> { mission };
        int occurrences = 0, reused = 0;
        string? error = null;
        try
        {
            if (mission.Contains("taskProofVersion") || mission.Contains("taskExecutables"))
                throw new InvalidDataException("PLAYER/author mission contains reserved task-proof metadata.");
            Walk(mission);
        }
        catch (Exception ex) when (ex is InvalidDataException or ArgumentException) { error = ex.Message; }
        return new(Array.AsReadOnly(inventory.OrderBy(p => p.Key, StringComparer.Ordinal).Select(p => p.Value).ToArray()), occurrences, memo.Count, reused, error);

        void Walk(LuaDataTable table)
        {
            if (table.Get("stopCondition") is LuaDataTable stop && stop.Contains("condition") && stop.Get("condition") is not (null or ""))
                throw new InvalidDataException("Unsupported executable task stop condition.");
            if (table.Get("id") is "ControlledTask" && table.Get("params") is LuaDataTable controlled
                && controlled.Get("condition") is LuaDataTable start && start.Contains("condition") && start.Get("condition") is not (null or ""))
                throw new InvalidDataException("Unsupported executable task start condition.");
            if (table.Get("id") is "ScriptFile") throw new InvalidDataException("Unsupported ScriptFile task.");
            if (table.Get("id") is "Script")
            {
                // Observed route actions, including Iraq's flag-controlled convoy message.
                var controlledAction = keys.Count == 18;
                if (keys.Count is not (16 or 18) || !Equals(keys[0], "coalition") || keys[1] is not ("blue" or "red" or "neutrals")
                    || !Equals(keys[2], "country") || !TaskIndex(keys[3]) || keys[4] is not ("plane" or "helicopter" or "vehicle" or "ship")
                    || !Equals(keys[5], "group") || !TaskIndex(keys[6]) || !Equals(keys[7], "route") || !Equals(keys[8], "points")
                    || !TaskIndex(keys[9]) || !Equals(keys[10], "task") || !Equals(keys[11], "params") || !Equals(keys[12], "tasks")
                    || !TaskIndex(keys[13]) || !Equals(keys[14], "params")
                    || (controlledAction ? !Equals(keys[15], "task") || !Equals(keys[16], "params") || !Equals(keys[17], "action") : !Equals(keys[15], "action")))
                    throw new InvalidDataException("Unsupported executable task wrapper/context shape.");
                var combo = tables[11]; var wrapper = tables[14];
                TaskShape(combo, "id", "params"); TaskShape(tables[12], "tasks");
                // DCS nameEditBox writes this optional display label; it is not an activation/code field.
                if (wrapper.Contains("name") && wrapper.Get("name") is not string) throw new InvalidDataException("Nonliteral task editor label.");
                TaskShape(wrapper, wrapper.Contains("name") ? ["id", "params", "enabled", "auto", "number", "name"] : ["id", "params", "enabled", "auto", "number"]);
                if (controlledAction)
                {
                    TaskShape(tables[15], "condition", "task");
                    if (tables[15].Get("condition") is not LuaDataTable condition || condition.Get("userFlag") is not string flag || string.IsNullOrWhiteSpace(flag))
                        throw new InvalidDataException("Unsupported controlled Script condition.");
                    TaskShape(condition, "userFlag");
                    TaskShape(tables[16], "id", "params");
                    if (tables[16].Get("id") is not "WrappedAction") throw new InvalidDataException("Unsupported controlled Script action.");
                    // Literal flag conditions are PLAYER context, not additional executable code.
                }
                TaskShape(tables[controlledAction ? 17 : 15], "action");
                TaskShape(table, "id", "params");
                if (combo.Get("id") is not "ComboTask" || !Equals(wrapper.Get("id"), controlledAction ? "ControlledTask" : "WrappedAction")
                    || wrapper.Get("enabled") is not bool enabled || wrapper.Get("auto") is not bool auto || !TaskIndex(wrapper.Get("number")))
                    throw new InvalidDataException("Unsupported executable task activation/wrapper semantics.");
                if (!containers.Add(combo)) throw new InvalidDataException("Multiple executable actions in one container are unsupported.");
                if (table.Get("params") is not LuaDataTable parameters) throw new InvalidDataException("Missing Script parameters.");
                TaskShape(parameters, "command");
                if (parameters.Get("command") is not string command) throw new InvalidDataException("Nonliteral Script command.");
                if (++occurrences > MaximumTaskOccurrences) throw new InvalidDataException("Too many executable tasks.");
                if (!memo.TryGetValue(command, out var body))
                {
                    var bytes = new UTF8Encoding(false, true).GetBytes(command);
                    if (bytes.Length > MaximumTaskBodyBytes) throw new InvalidDataException("Executable task body exceeds limit.");
                    body = (Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(bytes)).ToLowerInvariant(), bytes.Length);
                    memo.Add(command, body);
                }
                else reused++;
                var fact = new TaskExecutable("Script", body.Hash, body.Bytes, "route.ComboTask.WrappedAction", enabled, auto, 1);
                var key = TaskKey(fact);
                inventory[key] = inventory.TryGetValue(key, out var existing) ? existing with { Count = existing.Count + 1 } : fact;
            }
            foreach (var pair in table.Entries)
            {
                if (keys.Count == 0 && pair.Key is "trig" or "trigrules") continue;
                if (pair.Value is not LuaDataTable child) continue;
                keys.Add(pair.Key); tables.Add(child); Walk(child); tables.RemoveAt(tables.Count - 1); keys.RemoveAt(keys.Count - 1);
            }
        }
    }

    internal static void WriteTaskProof(LuaDataTable proof, TaskFacts facts)
    {
        if (facts.Error is not null) throw new InvalidDataException(facts.Error);
        proof.Set("taskProofVersion", 1d); proof.Set("taskExecutables", TaskTable(facts));
    }
    internal static string TaskSignature(TaskFacts facts) => WeatherLua.Serialize(TaskTable(facts));
    private static LuaDataTable TaskTable(TaskFacts facts)
    {
        var list = new LuaDataTable();
        foreach (var fact in facts.Executables)
        {
            var row = new LuaDataTable();
            row.Set("kind", fact.Kind); row.Set("bodySha256", fact.BodySha256); row.Set("byteLength", (double)fact.ByteLength);
            row.Set("wrapper", fact.Wrapper); row.Set("enabled", fact.Enabled); row.Set("auto", fact.Auto); row.Set("count", (double)fact.Count);
            list.Set((double)list.Entries.Count + 1, row);
        }
        return list;
    }
    // Called only for authenticated payload proof, never to derive expected facts from a PLAYER root.
    internal static TaskFacts ReadTaskProof(LuaDataTable proof)
    {
        TaskShape(proof, "theatre", "trig", "trigrules", "taskProofVersion", "taskExecutables");
        if (proof.Get("taskProofVersion") is not double version || version != 1 || proof.Get("taskExecutables") is not LuaDataTable list)
            throw new InvalidDataException("Missing or unsupported task proof version/metadata.");
        var facts = new List<TaskExecutable>(); string? previous = null; var total = 0;
        foreach (var entry in list.Entries)
        {
            if (!Equals(entry.Key, (double)facts.Count + 1) || entry.Value is not LuaDataTable row) throw new InvalidDataException("Noncanonical task proof list.");
            TaskShape(row, "kind", "bodySha256", "byteLength", "wrapper", "enabled", "auto", "count");
            if (row.Get("kind") is not "Script" || row.Get("wrapper") is not "route.ComboTask.WrappedAction"
                || row.Get("bodySha256") is not string hash || hash.Length != 64 || hash.Any(c => c is not (>= '0' and <= '9') and not (>= 'a' and <= 'f'))
                || row.Get("byteLength") is not double length || !double.IsFinite(length) || length < 0 || length > MaximumTaskBodyBytes || length != Math.Truncate(length)
                || row.Get("count") is not double count || !TaskIndex(count) || count > MaximumTaskOccurrences
                || row.Get("enabled") is not bool enabled || row.Get("auto") is not bool auto)
                throw new InvalidDataException("Malformed task proof fact.");
            var fact = new TaskExecutable("Script", hash, (int)length, "route.ComboTask.WrappedAction", enabled, auto, (int)count);
            var key = TaskKey(fact);
            if (previous is not null && string.CompareOrdinal(previous, key) >= 0 || (total += fact.Count) > MaximumTaskOccurrences)
                throw new InvalidDataException("Duplicate, unordered or oversized task proof inventory.");
            facts.Add(fact); previous = key;
        }
        return new(facts.AsReadOnly(), total, 0, 0, null);
    }
    private static string TaskKey(TaskExecutable fact) => fact.BodySha256 + ":" + fact.ByteLength.ToString("D8", CultureInfo.InvariantCulture) + ":" + (fact.Enabled ? "1" : "0") + (fact.Auto ? "1" : "0");
    private static bool TaskIndex(object? key) => key is double n && double.IsFinite(n) && n > 0 && n == Math.Truncate(n);
    private static void TaskShape(LuaDataTable table, params string[] fields)
    {
        if (table.Entries.Count != fields.Length || fields.Any(field => !table.Contains(field)))
            throw new InvalidDataException("Unsupported task/proof fields.");
    }

    internal static Result Produce(LuaDataTable mission, LuaDataTable map, IReadOnlySet<string> members)
    {
        var bindings = new Dictionary<string, Binding>(StringComparer.Ordinal);
        var unsafeKeys = new HashSet<string>(StringComparer.Ordinal);
        var overrides = new Dictionary<string, string>(StringComparer.Ordinal);
        (int Actions, int Other, int Reused) bodyParses = default;
        string? error = null;
        try { overrides = NormalizeBindings(mission, map, members, bindings, unsafeKeys, out bodyParses); }
        catch (Exception ex) when (ex is InvalidDataException or ArgumentException) { error = ex.Message; }
        // Preserve partial bindings/counts on Unknown exactly as the Publisher inspection did.
        return new(bindings.ToFrozenDictionary(StringComparer.Ordinal), bindings.Values.ToFrozenDictionary(b => b.MemberPath, StringComparer.Ordinal),
            overrides.ToFrozenDictionary(StringComparer.Ordinal), unsafeKeys.ToFrozenSet(StringComparer.Ordinal), bodyParses, error);
    }

    internal static FrozenDictionary<string, string> ProjectOwnedReferences(IReadOnlyDictionary<string, string> facts, IEnumerable<Binding> bindings)
    {
        // Cohort discrimination uses owned execution facts only, never author geometry or editor comments.
        var referencePaths = new HashSet<string>(StringComparer.Ordinal) { "mission[\"theatre\"]" };
        foreach (var binding in bindings)
        {
            var index = binding.CompiledPath["mission[\"trig\"][\"actions\"]".Length..];
            foreach (var field in new[] { "actions", "conditions", "func", "funcStartup", "flag" }) referencePaths.Add("mission[\"trig\"][\"" + field + "\"]" + index);
            foreach (var field in new[] { "actions", "rules", "predicate", "eventlist" }) referencePaths.Add("mission[\"trigrules\"]" + index + "[\"" + field + "\"]");
        }
        var referenceFacts = new Dictionary<string, string>(StringComparer.Ordinal);
        foreach (var prefix in referencePaths)
        {
            referenceFacts[prefix] = facts.GetValueOrDefault(prefix, "missing");
            foreach (var pair in facts.Where(p => p.Key.StartsWith(prefix + "[", StringComparison.Ordinal))) referenceFacts[pair.Key] = pair.Value;
        }
        return referenceFacts.ToFrozenDictionary(StringComparer.Ordinal);
    }

    internal static string KeyPath(string path, object key) => path + "[" + WeatherLua.Serialize(key) + "]";
    internal static void SafePath(string path)
    {
        if (string.IsNullOrWhiteSpace(path) || path.StartsWith('/') || path.Contains('\\') || path.Contains(':')
            || path.Split('/').Any(part => part is "" or "." or ".." || part.EndsWith('.') || part.EndsWith(' ') || part.Any(ch => ch < 32)))
            throw new InvalidDataException("Unsafe member path: " + path);
    }
    internal static bool IsLua(string path) => path.EndsWith(".lua", StringComparison.OrdinalIgnoreCase);
    internal static void Flatten(object? value, string path, Dictionary<string, string> facts, IReadOnlyDictionary<string, string>? overrides = null)
    {
        if (overrides is not null && overrides.TryGetValue(path, out var replacement)) { facts.Add(path, "s:" + replacement); return; }
        if (value is LuaDataTable table)
        {
            facts.Add(path, "table");
            foreach (var pair in table.Entries) Flatten(pair.Value, KeyPath(path, pair.Key), facts, overrides);
        }
        else facts.Add(path, value switch
        {
            null => "nil", string s => "s:" + s, bool b => b ? "true" : "false",
            double n when double.IsFinite(n) => "n:" + n.ToString("R", CultureInfo.InvariantCulture),
            _ => throw new InvalidDataException("Unsupported typed value at " + path)
        });
    }

    private static Dictionary<string, string> NormalizeBindings(LuaDataTable mission, LuaDataTable map,
        IReadOnlySet<string> members, Dictionary<string, Binding> bindings, HashSet<string> unsafeKeys,
        out (int Actions, int Other, int Reused) bodyParses)
    {
        var overrides = new Dictionary<string, string>(StringComparer.Ordinal);
        var recognizedUses = new Dictionary<string, int>(StringComparer.Ordinal);
        var decodedOtherUses = new HashSet<string>(StringComparer.Ordinal);
        var unresolvedLookup = false;
        bodyParses = default;
        var bodyFacts = new Dictionary<string, CompiledBodyFacts>(StringComparer.Ordinal);
        var trig = mission.Get("trig") as LuaDataTable ?? throw new InvalidDataException("Missing compiled triggers.");
        var actions = trig.Get("actions") as LuaDataTable ?? throw new InvalidDataException("Missing compiled trigger actions.");
        var rules = mission.Get("trigrules") as LuaDataTable ?? throw new InvalidDataException("Missing editor trigger rules.");
        var programs = new List<(string Field, LuaDataTable Table)> { ("actions", actions) };
        foreach (var field in new[] { "conditions", "func", "funcStartup" })
        {
            if (!trig.Contains(field)) continue;
            if (trig.Get(field) is not LuaDataTable table) throw new InvalidDataException("Non-table compiled trigger field: " + field);
            programs.Add((field, table));
        }
        foreach (var program in programs)
        foreach (var action in program.Table.Entries)
        {
            if (action.Value is not string code) throw new InvalidDataException("Nonliteral compiled program.");
            var compiledPath = KeyPath("mission[\"trig\"][\"" + program.Field + "\"]", action.Key);
            if (!bodyFacts.TryGetValue(code, out var body))
            {
                if (program.Field == "actions") bodyParses.Actions++; else bodyParses.Other++;
                var syntax = WeatherLua.Parse(code, compiledPath);
                var nodes = syntax.DescendantNodes().ToArray();
                var recognized = new List<(int Start, int Length, string Key)>();
                var directLookupNames = new HashSet<int>();
                // Renames require a closed, static generated program. Do not infer the identity of
                // aliases, computed globals, member calls or evaluated code from identifier spelling.
                var dispatchNodes = new HashSet<(int Start, int Length)>();
                foreach (var access in nodes.OfType<ElementAccessExpressionSyntax>())
                {
                    if (access.Expression is not MemberAccessExpressionSyntax { Expression: MemberAccessExpressionSyntax
                        { Expression: IdentifierNameSyntax root, MemberName: var trigName }, MemberName: var field }
                        || root.Identifier.Text != "mission" || trigName.Text != "trig"
                        || access.KeyExpression is not LiteralExpressionSyntax { Token.Value: double index }
                        || index <= 0 || index != Math.Truncate(index)) continue;
                    var dispatch = access.Parent is FunctionCallExpressionSyntax invocation && invocation.Expression == access
                        && field.Text is "conditions" or "actions"
                        && invocation.Argument is ExpressionListFunctionArgumentSyntax arguments && arguments.Expressions.Count == 0;
                    var disable = access.Parent is AssignmentStatementSyntax assignment && field.Text == "func"
                        && assignment.Variables.Count == 1 && assignment.Variables[0] == access
                        && assignment.EqualsValues.Values.Count == 1
                        && assignment.EqualsValues.Values[0] is LiteralExpressionSyntax nil && nil.Token.Text == "nil";
                    if (!dispatch && !disable) continue;
                    foreach (var part in access.DescendantNodes().Append(access)) dispatchNodes.Add((part.Span.Start, part.Span.Length));
                    if (disable) dispatchNodes.Add((access.Parent!.Span.Start, access.Parent.Span.Length));
                }
                var unresolved = nodes.Any(node => node is StatementSyntax && node is not (ExpressionStatementSyntax
                        or IfStatementSyntax or ReturnStatementSyntax or AssignmentStatementSyntax or EmptyStatementSyntax)
                    || node is ExpressionSyntax && node is not (LiteralExpressionSyntax or IdentifierNameSyntax
                        or UnaryExpressionSyntax or BinaryExpressionSyntax or ParenthesizedExpressionSyntax or FunctionCallExpressionSyntax)
                        && !dispatchNodes.Contains((node.Span.Start, node.Span.Length))
                    || node is AssignmentStatementSyntax && !dispatchNodes.Contains((node.Span.Start, node.Span.Length))
                    || node is IdentifierNameSyntax name && !dispatchNodes.Contains((node.Span.Start, node.Span.Length))
                        && (name.Parent is not FunctionCallExpressionSyntax namedCall || namedCall.Expression != name));
                foreach (var call in nodes.OfType<FunctionCallExpressionSyntax>())
                {
                    if (call.Expression is not IdentifierNameSyntax id)
                    {
                        if (!dispatchNodes.Contains((call.Expression.Span.Start, call.Expression.Span.Length))) unresolved = true;
                        continue;
                    }
                    // Only these established generated callbacks are proven here. Unknown callbacks
                    // remain usable with stable keys, but cannot certify a resource-key rename.
                    if (id.Identifier.Text is not ("a_do_script_file" or "a_out_sound_s" or "a_end_mission"
                        or "c_time_after" or "c_flag_is_true" or "getValueDictByKey" or "getValueResourceByKey")) unresolved = true;
                    if (id.Identifier.Text == "getValueResourceByKey")
                    {
                        directLookupNames.Add(id.Identifier.Span.Start);
                        if (call.Argument is not ExpressionListFunctionArgumentSyntax lookupArguments || lookupArguments.Expressions.Count != 1
                            || lookupArguments.Expressions[0] is not LiteralExpressionSyntax { Token.Value: string }) unresolved = true;
                        continue;
                    }
                    if (id.Identifier.Text != "a_do_script_file") continue;
                    if (call.Argument is not ExpressionListFunctionArgumentSyntax args || args.Expressions.Count != 1
                        || args.Expressions[0] is not FunctionCallExpressionSyntax lookup
                        || lookup.Expression is not IdentifierNameSyntax lookupId || lookupId.Identifier.Text != "getValueResourceByKey"
                        || lookup.Argument is not ExpressionListFunctionArgumentSyntax lookupArgs || lookupArgs.Expressions.Count != 1
                        || lookupArgs.Expressions[0] is not LiteralExpressionSyntax literal || literal.Token.Value is not string key)
                        throw new InvalidDataException("Unsupported script-file action at " + compiledPath);
                    recognized.Add((literal.Span.Start, literal.Span.Length, key));
                }
                // Decode once per distinct body; only approved action positions may omit their key literals.
                var ownedPositions = recognized.Select(r => r.Start).ToHashSet();
                var allStrings = new HashSet<string>(StringComparer.Ordinal);
                var otherStrings = new HashSet<string>(StringComparer.Ordinal);
                foreach (var literal in nodes.OfType<LiteralExpressionSyntax>())
                    if (literal.Token.Value is string value)
                    {
                        allStrings.Add(value);
                        if (!ownedPositions.Contains(literal.Span.Start)) otherStrings.Add(value);
                    }
                foreach (var token in syntax.DescendantTokens())
                    if ((token.Text == "getValueResourceByKey" || token.Value is string value && value.Contains("getValueResourceByKey", StringComparison.Ordinal))
                        && !directLookupNames.Contains(token.Span.Start)) unresolved = true;
                body = new(recognized.AsReadOnly(), allStrings.ToFrozenSet(StringComparer.Ordinal), otherStrings.ToFrozenSet(StringComparer.Ordinal), unresolved);
                bodyFacts.Add(code, body);
            }
            else bodyParses.Reused++;
            unresolvedLookup |= body.UnresolvedLookup;
            decodedOtherUses.UnionWith(program.Field == "actions" ? body.OtherDecodedStrings : body.AllDecodedStrings);
            if (program.Field != "actions") continue;
            var editor = (rules.Get(action.Key) as LuaDataTable)?.Get("actions") as LuaDataTable
                ?? throw new InvalidDataException("Compiled action has no corresponding editor rule.");
            var editorFiles = editor.Entries.Where(p => p.Value is LuaDataTable t && Equals(t.Get("predicate"), "a_do_script_file")).ToArray();
            if (editorFiles.Length != body.ScriptLookups.Count) throw new InvalidDataException("Compiled/editor script action counts disagree.");
            var edits = new List<(int Start, int Length, string Text)>();
            for (var i = 0; i < body.ScriptLookups.Count; i++)
            {
                var (start, length, key) = body.ScriptLookups[i];
                var editorAction = (LuaDataTable)editorFiles[i].Value!;
                if (!Equals(editorAction.Get("file"), key)) throw new InvalidDataException("Compiled/editor script order or key disagrees.");
                if (map.Get(key) is not string filename) throw new InvalidDataException("Unresolved script key: " + key);
                var member = "l10n/DEFAULT/" + filename;
                SafePath(member);
                if (!members.Contains(member) || !IsLua(member)) throw new InvalidDataException("Script key does not resolve to an existing Lua member: " + key);
                if (map.Entries.Count(p => Equals(p.Value, filename)) != 1) throw new InvalidDataException("Aliased script resource: " + filename);
                var editorPath = KeyPath(KeyPath("mission[\"trigrules\"]", action.Key) + "[\"actions\"]", editorFiles[i].Key) + "[\"file\"]";
                if (!bindings.TryAdd(key, new(key, member, compiledPath, editorPath))) throw new InvalidDataException("Duplicated owned script reference: " + key);
                overrides.Add(editorPath, "@script:" + member);
                edits.Add((start, length, WeatherLua.Serialize("@script:" + member)));
                recognizedUses[key] = 2;
            }
            var normalized = new StringBuilder(code);
            foreach (var edit in edits.OrderByDescending(e => e.Start)) normalized.Remove(edit.Start, edit.Length).Insert(edit.Start, edit.Text);
            overrides.Add(compiledPath, normalized.ToString());
        }
        // Check all mission string leaves for unaccounted uses before allowing a key rename.
        var raw = new Dictionary<string, string>(StringComparer.Ordinal);
        Flatten(mission, "mission", raw);
        foreach (var key in bindings.Keys)
        {
            var uses = 0;
            foreach (var text in raw.Values.Where(v => v.StartsWith("s:", StringComparison.Ordinal)))
                for (var start = 0; (start = text.IndexOf(key, start, StringComparison.Ordinal)) >= 0; start += key.Length) uses++;
            if (unresolvedLookup || decodedOtherUses.Contains(key) || uses != recognizedUses[key]) unsafeKeys.Add(key);
        }
        return overrides;
    }
}
