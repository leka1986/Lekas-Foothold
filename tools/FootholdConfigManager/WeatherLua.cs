using System.Globalization;
using System.Text;
using Loretta.CodeAnalysis;
using Loretta.CodeAnalysis.Lua;
using Loretta.CodeAnalysis.Lua.Syntax;

namespace FootholdConfigManager;

internal sealed class LuaDataTable
{
    private readonly List<KeyValuePair<object, object?>> _entries = new();
    public IReadOnlyList<KeyValuePair<object, object?>> Entries => _entries;
    public object? Get(object key)
    {
        if (_entries.Count == 0) return null;
        key = NormalizeKey(key);
        return _entries.FirstOrDefault(pair => Equals(pair.Key, key)).Value;
    }
    public bool Contains(object key)
    {
        if (_entries.Count == 0) return false;
        key = NormalizeKey(key);
        return _entries.Any(pair => Equals(pair.Key, key));
    }
    public void Set(object key, object? value)
    {
        key = NormalizeKey(key);
        var index = _entries.FindIndex(pair => Equals(pair.Key, key));
        var entry = new KeyValuePair<object, object?>(key, value);
        if (index >= 0) _entries[index] = entry;
        else _entries.Add(entry);
    }
    public void Remove(object key)
    {
        if (_entries.Count == 0) return;
        key = NormalizeKey(key);
        _entries.RemoveAll(pair => Equals(pair.Key, key));
    }
    public LuaDataTable Table(string key)
    {
        var value = Get(key);
        if (value is LuaDataTable existing) return existing;
        if (value is not null)
            throw new InvalidDataException("Weather field '" + key + "' is not a table.");
        var table = new LuaDataTable();
        Set(key, table);
        return table;
    }
    private static object NormalizeKey(object key) => key is string or bool
        ? key : Convert.ToDouble(key, CultureInfo.InvariantCulture);
}

internal static class WeatherLua
{
    private static readonly LuaParseOptions Options = new(LuaSyntaxOptions.Lua51);

    public static CompilationUnitSyntax Parse(string text, string displayPath = "mission")
    {
        var tree = LuaSyntaxTree.ParseText(text, Options, displayPath);
        var errors = tree.GetDiagnostics().Where(d => d.Severity == DiagnosticSeverity.Error).Take(5).ToArray();
        if (errors.Length != 0)
            throw new InvalidDataException("Invalid Lua: " + string.Join(Environment.NewLine, errors.Select(d => d.ToString())));
        return (CompilationUnitSyntax)tree.GetRoot();
    }

    public static object? Read(ExpressionSyntax expression) => Read(expression, false);

    private static object? Read(ExpressionSyntax expression, bool rejectDuplicates)
    {
        return expression switch
        {
            LiteralExpressionSyntax literal => ReadLiteral(literal),
            UnaryExpressionSyntax unary when unary.OperatorToken.Text == "-" && Read(unary.Operand, rejectDuplicates) is double number => -number,
            ParenthesizedExpressionSyntax parenthesized => Read(parenthesized.Expression, rejectDuplicates),
            TableConstructorExpressionSyntax table => ReadTable(table, rejectDuplicates),
            _ => throw new InvalidDataException("Weather contains an unsupported expression: " + expression.Kind()
                + ". No mission code is executed and the MIZ has not been changed.")
        };
    }

    private static object? ReadLiteral(LiteralExpressionSyntax literal)
    {
        var value = literal.Token.Value;
        if (value is null or string or bool) return value;
        if (value is IConvertible)
        {
            var number = Convert.ToDouble(value, CultureInfo.InvariantCulture);
            if (double.IsFinite(number)) return number;
        }
        throw new InvalidDataException("Unsupported or non-finite Lua literal.");
    }

    public static LuaDataTable ReadTable(TableConstructorExpressionSyntax syntax) => ReadTable(syntax, false);

    internal static LuaDataTable ReadTable(TableConstructorExpressionSyntax syntax, bool rejectDuplicates)
    {
        var result = new LuaDataTable();
        var nextIndex = 1d;
        foreach (var field in syntax.Fields)
        {
            object key;
            ExpressionSyntax expression;
            switch (field)
            {
                case IdentifierKeyedTableFieldSyntax named:
                    key = named.Identifier.Text;
                    expression = named.Value;
                    break;
                case ExpressionKeyedTableFieldSyntax keyed:
                    key = Read(keyed.Key, rejectDuplicates) ?? throw new InvalidDataException("A Lua table key cannot be nil.");
                    if (key is LuaDataTable) throw new InvalidDataException("Table-valued keys are unsupported.");
                    expression = keyed.Value;
                    break;
                case UnkeyedTableFieldSyntax unkeyed:
                    key = nextIndex++;
                    expression = unkeyed.Value;
                    break;
                default:
                    throw new InvalidDataException("Unsupported Lua table field.");
            }
            if (rejectDuplicates && result.Contains(key)) throw new InvalidDataException("Duplicate Lua table key: " + key);
            result.Set(key, Read(expression, rejectDuplicates));
        }
        return result;
    }

    public static string Serialize(object? value, int depth = 1, string newLine = "\n")
    {
        var output = new StringBuilder();
        Write(output, value, depth, newLine);
        return output.ToString();
    }

    private static void Write(StringBuilder output, object? value, int depth, string newLine)
    {
        switch (value)
        {
            case null: output.Append("nil"); break;
            case bool boolean: output.Append(boolean ? "true" : "false"); break;
            case string text: WriteString(output, text); break;
            case LuaDataTable table:
                if (table.Entries.Count == 0) { output.Append("{}"); break; }
                output.Append('{').Append(newLine);
                foreach (var pair in table.Entries)
                {
                    output.Append('\t', depth + 1).Append('[');
                    Write(output, pair.Key, depth + 1, newLine);
                    output.Append("] = ");
                    Write(output, pair.Value, depth + 1, newLine);
                    output.Append(',').Append(newLine);
                }
                output.Append('\t', depth).Append('}');
                break;
            case IConvertible number:
                var numeric = number.ToDouble(CultureInfo.InvariantCulture);
                if (!double.IsFinite(numeric)) throw new InvalidDataException("Weather numbers must be finite.");
                output.Append(numeric.ToString("R", CultureInfo.InvariantCulture));
                break;
            default: throw new InvalidDataException("Unsupported weather value type.");
        }
    }

    private static void WriteString(StringBuilder output, string text)
    {
        output.Append('"');
        foreach (var ch in text)
        {
            switch (ch)
            {
                case '\\': output.Append(@"\\"); break;
                case '"': output.Append("\\\""); break;
                case '\r': output.Append(@"\r"); break;
                case '\n': output.Append(@"\n"); break;
                case '\t': output.Append(@"\t"); break;
                default:
                    if (ch < 32 || ch == 127)
                        output.Append('\\').Append(((int)ch).ToString("D3", CultureInfo.InvariantCulture));
                    else output.Append(ch);
                    break;
            }
        }
        output.Append('"');
    }
}
