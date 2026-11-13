using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace FootholdConfigManager;

internal sealed class DcsWebGuiClient : IDisposable
{
    private const int MaximumResponseBytes = 16 * 1024 * 1024;
    private static readonly Dictionary<string, (long Length, DateTime Write, byte[] Key)> ProtocolKeys = new(StringComparer.OrdinalIgnoreCase);
    private readonly HttpClient _client;
    private readonly byte[] _key;

    internal DcsWebGuiClient(Uri endpoint, string installationDirectory, HttpMessageHandler? handler = null)
    {
        if (!endpoint.IsAbsoluteUri || endpoint.Scheme != "http" || !IPAddress.TryParse(endpoint.Host, out var ip)
            || !IPAddress.IsLoopback(ip) || endpoint.AbsolutePath != "/" || endpoint.Query.Length != 0
            || endpoint.UserInfo.Length != 0 || endpoint.Fragment.Length != 0)
            throw new ArgumentException("Only a local dedicated-server control endpoint is supported.", nameof(endpoint));
        _key = ReadProtocolKey(installationDirectory);
        _client = new HttpClient(handler ?? new SocketsHttpHandler { UseProxy = false, AllowAutoRedirect = false })
        { BaseAddress = endpoint, Timeout = Timeout.InfiniteTimeSpan };
    }

    private static byte[] ReadProtocolKey(string installation)
    {
        var path = Path.GetFullPath(Path.Combine(installation, "WebGUI", "js", "app.js"));
        var info = new FileInfo(path);
        lock (ProtocolKeys)
        {
            if (ProtocolKeys.TryGetValue(path, out var previous) && previous.Length == info.Length
                && previous.Write == info.LastWriteTimeUtc) return previous.Key;
            if (info.Length > MaximumResponseBytes) throw new InvalidDataException("Unsupported DCS local control protocol.");
            var text = File.ReadAllText(path);
            var matches = Regex.Matches(text, "webKey:\"([^\"]+)\"", RegexOptions.CultureInvariant, TimeSpan.FromSeconds(2));
            if (matches.Count != 1) throw new InvalidDataException("The installed DCS local control protocol could not be identified.");
            var key = SHA256.HashData(Encoding.UTF8.GetBytes(matches[0].Groups[1].Value));
            ProtocolKeys[path] = (info.Length, info.LastWriteTimeUtc, key);
            return key;
        }
    }

    internal async Task<string> GetDefaultMissionsDirectoryAsync(CancellationToken token)
    {
        var reply = await SendAsync(new { uri = "getFileList", fileType = "mission" }, false, token).ConfigureAwait(false);
        return reply.GetProperty("root").GetString() ?? throw new InvalidDataException("DCS did not identify its Missions folder.");
    }

    internal async Task<DcsNativeMissionList> GetMissionListAsync(CancellationToken token)
    {
        var reply = await SendAsync(new { uri = "getMissionList" }, false, token).ConfigureAwait(false);
        var paths = reply.GetProperty("missionList");
        string[] list;
        if (paths.ValueKind == JsonValueKind.Array)
            list = paths.EnumerateArray().Select(p => p.GetString() ?? throw new InvalidDataException("Invalid mission list entry.")).ToArray();
        else if (paths.ValueKind == JsonValueKind.Object && !paths.EnumerateObject().Any()) list = [];
        else throw new InvalidDataException("DCS returned an unsupported mission list.");
        return new(list, reply.GetProperty("listStartIndex").GetInt32(),
            reply.GetProperty("listLoop").GetBoolean(), reply.GetProperty("listShuffle").GetBoolean());
    }

    internal async Task<DcsNativeMissionState> GetMissionStateAsync(CancellationToken token)
    {
        var mode = await SendAsync(new { uri = "getSimulatorMode" }, false, token).ConfigureAwait(false);
        var mission = await SendAsync(new { uri = "getMissionInfo" }, false, token).ConfigureAwait(false);
        return new(mode.GetInt32(), mission.TryGetProperty("mission_filename", out var path) ? path.GetString() : null);
    }

    internal async Task<bool> AddMissionsAsync(IReadOnlyList<string> paths, CancellationToken token)
    {
        var reply = await SendAsync(new { uri = "addMissions", missions = paths }, true, token).ConfigureAwait(false);
        return reply.ValueKind == JsonValueKind.True;
    }

    private async Task<JsonElement> SendAsync(object request, bool mutation, CancellationToken token)
    {
        using var timeout = CancellationTokenSource.CreateLinkedTokenSource(token);
        timeout.CancelAfter(TimeSpan.FromSeconds(mutation ? 10 : 3));
        using var aes = Aes.Create();
        aes.Key = _key; aes.Mode = CipherMode.CBC; aes.Padding = PaddingMode.PKCS7; aes.GenerateIV();
        var plain = JsonSerializer.SerializeToUtf8Bytes(request);
        using var encryptor = aes.CreateEncryptor();
        var envelope = new { iv = Convert.ToBase64String(aes.IV),
            ct = Convert.ToBase64String(encryptor.TransformFinalBlock(plain, 0, plain.Length)) };
        using var content = new StringContent(JsonSerializer.Serialize(envelope), Encoding.UTF8, "application/json");
        using var message = new HttpRequestMessage(HttpMethod.Post, "encryptedRequest") { Content = content };
        using var response = await _client.SendAsync(message, HttpCompletionOption.ResponseHeadersRead, timeout.Token).ConfigureAwait(false);
        response.EnsureSuccessStatusCode();
        if (response.Content.Headers.ContentLength > MaximumResponseBytes)
            throw new InvalidDataException("DCS local control response exceeded the supported size.");
        await using var stream = await response.Content.ReadAsStreamAsync(timeout.Token).ConfigureAwait(false);
        using var buffer = new MemoryStream();
        var chunk = new byte[8192];
        while (true)
        {
            var count = await stream.ReadAsync(chunk, timeout.Token).ConfigureAwait(false);
            if (count == 0) break;
            if (buffer.Length + count > MaximumResponseBytes) throw new InvalidDataException("DCS local control response exceeded the supported size.");
            buffer.Write(chunk, 0, count);
        }
        try
        {
            using var encoded = JsonDocument.Parse(buffer.ToArray());
            aes.IV = Convert.FromBase64String(encoded.RootElement.GetProperty("iv").GetString()!);
            var cipher = Convert.FromBase64String(encoded.RootElement.GetProperty("ct").GetString()!);
            using var decryptor = aes.CreateDecryptor();
            using var decoded = JsonDocument.Parse(decryptor.TransformFinalBlock(cipher, 0, cipher.Length));
            return decoded.RootElement.Clone();
        }
        catch (Exception error) when (error is JsonException or KeyNotFoundException or FormatException
            or CryptographicException or ArgumentException or InvalidOperationException)
        { throw new InvalidDataException("DCS returned an invalid local control response.", error); }
    }

    public void Dispose() => _client.Dispose();
}
