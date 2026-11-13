using System.Text.Json;
using System.Text.Json.Serialization;

namespace FootholdConfigManager;

internal sealed record ReleaseWeaponCatalog(
    [property: JsonPropertyName("schema")] int Schema,
    [property: JsonPropertyName("releaseTag")] string ReleaseTag,
    [property: JsonPropertyName("weaponIds")] string[] WeaponIds)
{
    internal const string AssetName = "foothold-weapon-catalog.json";
    internal const string CacheName = "weapon-catalog-cache.json";
    internal const int MaximumBytes = 256 * 1024;

    internal static ReleaseWeaponCatalog Parse(ReadOnlyMemory<byte> bytes, string? expectedTag = null)
    {
        if (bytes.Length is <= 0 or > MaximumBytes)
            throw new InvalidDataException("The weapon catalog has an invalid size.");
        var catalog = JsonSerializer.Deserialize<ReleaseWeaponCatalog>(bytes.Span, new JsonSerializerOptions { MaxDepth = 4 });
        if (catalog is null || catalog.Schema != 1 || catalog.ReleaseTag is not { Length: > 1 and <= 32 } tag
            || tag[0] != 'v' || !Version.TryParse(tag[1..], out var version) || version.Build < 0
            || expectedTag is not null && tag != expectedTag
            || catalog.WeaponIds is not { Length: > 0 and <= 5000 }
            || !catalog.WeaponIds.All(IsWeaponId)
            || catalog.WeaponIds.Distinct(StringComparer.Ordinal).Count() != catalog.WeaponIds.Length)
            throw new InvalidDataException("The weapon catalog is invalid or belongs to a different release.");
        return catalog;
    }

    internal static bool IsWeaponId(string? id)
    {
        if (id is not { Length: > 10 and <= 250 } || id != id.Trim() ||
            !id.StartsWith("weapons.", StringComparison.Ordinal) || id.Any(char.IsControl)) return false;
        var categoryEnd = id.IndexOf('.', 8);
        return categoryEnd > 8 && categoryEnd < id.Length - 1 &&
            id.AsSpan(8, categoryEnd - 8).IndexOfAnyExceptInRange('a', 'z') < 0;
    }
}
