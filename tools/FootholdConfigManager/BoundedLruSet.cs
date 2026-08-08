namespace FootholdConfigManager;

internal sealed class BoundedLruSet<TKey> where TKey : notnull
{
    private readonly int _capacity;
    private readonly LinkedList<TKey> _recency = new();
    private readonly Dictionary<TKey, LinkedListNode<TKey>> _nodes;

    public BoundedLruSet(int capacity, IEqualityComparer<TKey>? comparer = null)
    {
        if (capacity < 1)
        {
            throw new ArgumentOutOfRangeException(nameof(capacity));
        }

        _capacity = capacity;
        _nodes = new Dictionary<TKey, LinkedListNode<TKey>>(comparer);
    }

    public int Count => _nodes.Count;

    public bool Contains(TKey key) => _nodes.ContainsKey(key);

    public TKey? Touch(TKey key)
    {
        if (_nodes.TryGetValue(key, out var existingNode))
        {
            _recency.Remove(existingNode);
            _recency.AddFirst(existingNode);
            return default;
        }

        var newNode = _recency.AddFirst(key);
        _nodes.Add(key, newNode);
        if (_nodes.Count <= _capacity)
        {
            return default;
        }

        var leastRecentNode = _recency.Last!;
        _recency.RemoveLast();
        _nodes.Remove(leastRecentNode.Value);
        return leastRecentNode.Value;
    }

    public bool Remove(TKey key)
    {
        if (!_nodes.Remove(key, out var node))
        {
            return false;
        }

        _recency.Remove(node);
        return true;
    }

    public void Clear()
    {
        _nodes.Clear();
        _recency.Clear();
    }
}
