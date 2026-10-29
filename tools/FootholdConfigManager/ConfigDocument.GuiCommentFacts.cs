using System.Collections;
using System.Text.RegularExpressions;

namespace FootholdConfigManager;

internal sealed partial class ConfigDocument
{
    // Immutable comments and lazily observed regex matches
    // belong to one assignment only; no evaluated conditions survive the operation.
    private sealed class GuiCommentFacts : IEnumerable<string>
    {
        private readonly string[] _comments;
        private Dictionary<string, Match[]>? _matches;
        internal GuiCommentFacts(IEnumerable<string> comments) => _comments = comments.ToArray();
        internal IReadOnlyList<Match> Matches(string line)
        {
            _matches ??= new(StringComparer.Ordinal);
            if (!_matches.TryGetValue(line, out var matches))
                _matches[line] = matches = GuiAttributeRegex.Matches(line).Cast<Match>().ToArray();
            return matches;
        }
        public IEnumerator<string> GetEnumerator() => ((IEnumerable<string>)_comments).GetEnumerator();
        IEnumerator IEnumerable.GetEnumerator() => GetEnumerator();
    }
    private static IEnumerable<Match> ReadGuiMatches(IEnumerable<string> comments, string line)
        => comments is GuiCommentFacts facts ? facts.Matches(line) : GuiAttributeRegex.Matches(line).Cast<Match>();
}
