using System.Globalization;
using System.Text.RegularExpressions;
using Loretta.CodeAnalysis.Lua;
using Loretta.CodeAnalysis.Lua.Syntax;
namespace FootholdConfigManager;

// Required metadata alone interprets selectors; ordinary visibility/value matching keeps its grammar.
internal sealed record RequiredConditionSelector(string SourceKey, string BaseKey, int? Index, bool Negated, bool Invalid, IReadOnlyList<string> Values)
{
    internal static RequiredConditionSelector Read((string SourceKey, List<string> Values) condition)
    {
        var key = condition.SourceKey;
        var negated = key.EndsWith("!", StringComparison.Ordinal);
        var candidate = negated ? key[..^1] : key;
        var match = Regex.Match(candidate, @"^(?<base>.+)\[(?<index>[0-9]+)\]$");
        if (match.Success)
        {
            var valid = int.TryParse(match.Groups["index"].Value, NumberStyles.None, CultureInfo.InvariantCulture, out var index) && index > 0;
            return new(key, match.Groups["base"].Value, valid ? index : null, negated, !valid, condition.Values);
        }
        return new(key, candidate, null, negated, string.IsNullOrWhiteSpace(candidate) || candidate.Contains('[') || candidate.Contains(']'), condition.Values);
    }
}

internal sealed partial class RequiredValueSources
{
    private static readonly LuaParseOptions RequiredParseOptions = new(LuaSyntaxOptions.Lua51);
    private readonly Dictionary<ConfigEntry, RequiredTupleSnapshot> _requiredTuples = new();
    private readonly Dictionary<string, RequiredLiteral> _requiredLiterals = new(StringComparer.Ordinal);
    private enum RequiredLiteralKind { Nil, Boolean, Number, String, Unsupported }
    private readonly record struct RequiredLiteral(RequiredLiteralKind Kind, object? Value, string? Error = null);
    private sealed class RequiredTupleSnapshot(TableConstructorExpressionSyntax? table, string? error)
    {
        internal TableConstructorExpressionSyntax? Table { get; } = table;
        internal string? Error { get; } = error;
        internal Dictionary<int, RequiredLiteral> SelectedValues { get; } = new();
    }

    internal bool MatchRequiredCondition(RequiredConditionSelector condition, out string? error)
    {
        error = null;
        // Literal whole keys win even when their spelling resembles [index] or a terminal !.
        if (Find(condition.SourceKey) is { } exact)
            return ConfigConditions.ValueMatches(exact.ValueText, condition.Values);
        if (condition.Invalid)
        {
            error = "Invalid requiredWhen selector: " + condition.SourceKey;
            return false;
        }
        if (condition.Index is not { } index)
        {
            error = condition.Negated ? "NOT-IN requires an indexed requiredWhen selector: " + condition.SourceKey :
                "Unresolved requiredWhen source: " + condition.SourceKey;
            return false;
        }
        var source = Find(condition.BaseKey);
        if (source is null)
        {
            error = "Unresolved requiredWhen source: " + condition.BaseKey;
            return false;
        }

        if (!_requiredTuples.TryGetValue(source, out var tuple))
        {
            var expression = source.Kind == ConfigValueKind.Raw ? SyntaxFactory.ParseExpression(source.ValueText, 0, RequiredParseOptions, consumeFullText: true) : null;
            var table = expression as TableConstructorExpressionSyntax;
            var invalidShape = expression is null || expression.ContainsDiagnostics || table is null || table.Fields.Any(field => field is not UnkeyedTableFieldSyntax);
            tuple = new(invalidShape ? null : table, invalidShape ? "Indexed requiredWhen source must be a positional Lua tuple: " + source.DisplayKey : null);
            _requiredTuples[source] = tuple;
        }
        if (tuple.Error is not null) { error = tuple.Error; return false; }
        if (!tuple.SelectedValues.TryGetValue(index, out var actual))
        {
            var fields = tuple.Table!.Fields;
            if (index <= fields.Count) actual = ReadRequiredLiteral(((UnkeyedTableFieldSyntax)fields[index - 1]).Value);
            else if (fields.Count > 0 && ((UnkeyedTableFieldSyntax)fields[^1]).Value is FunctionCallExpressionSyntax or MethodCallExpressionSyntax or VarArgExpressionSyntax)
                actual = new(RequiredLiteralKind.Unsupported, null, "A final call or vararg can expand missing tuple positions.");
            else actual = new(RequiredLiteralKind.Nil, null);
            tuple.SelectedValues[index] = actual;
        }
        if (actual.Error is not null)
        {
            error = "Unsupported requiredWhen tuple value at " + condition.SourceKey + ": " + actual.Error;
            return false;
        }
        var matched = false;
        foreach (var text in condition.Values)
        {
            if (!_requiredLiterals.TryGetValue(text, out var expected))
            {
                expected = ReadRequiredLiteral(SyntaxFactory.ParseExpression(text, 0, RequiredParseOptions, consumeFullText: true));
                _requiredLiterals[text] = expected;
            }
            if (expected.Error is not null)
            {
                error = "Unsupported requiredWhen literal: " + text;
                return false;
            }
            if (actual.Kind == expected.Kind && Equals(actual.Value, expected.Value)) matched = true;
        }
        return condition.Negated ? !matched : matched;
    }

    // Syntax only: parentheses and unary minus on numeric literals are safe; no Lua is executed.
    private static RequiredLiteral ReadRequiredLiteral(ExpressionSyntax expression)
    {
        if (expression.ContainsDiagnostics) return new(RequiredLiteralKind.Unsupported, null, "Malformed Lua literal.");
        if (expression is ParenthesizedExpressionSyntax parenthesized) return ReadRequiredLiteral(parenthesized.Expression);
        if (expression is UnaryExpressionSyntax unary && unary.OperatorToken.Text == "-")
        {
            var operand = ReadRequiredLiteral(unary.Operand);
            return operand.Kind == RequiredLiteralKind.Number ? new(RequiredLiteralKind.Number, -(double)operand.Value!) :
                new(RequiredLiteralKind.Unsupported, null, "Unary minus needs a numeric literal.");
        }
        if (expression is not LiteralExpressionSyntax literal) return new(RequiredLiteralKind.Unsupported, null, "Expected a literal, not an expression.");
        return literal.Token.Value switch
        {
            null => new(RequiredLiteralKind.Nil, null),
            bool boolean => new(RequiredLiteralKind.Boolean, boolean),
            string text => new(RequiredLiteralKind.String, text),
            double number => new(RequiredLiteralKind.Number, number),
            long integer => new(RequiredLiteralKind.Number, (double)integer),
            _ => new(RequiredLiteralKind.Unsupported, null, "Unsupported Lua literal kind.")
        };
    }
}
