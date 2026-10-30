#if !FOOTHOLD_USER_BUILD
namespace FootholdConfigManager;

internal sealed record SignedReleaseRequest(string ProjectDirectory, string MetadataJson, string Version, string OutputDirectory);
internal sealed record SignedReleaseProgress(string Stage, string Message, string? RunUrl = null);
internal sealed record SignedReleaseSetup(bool Ready, string Message, Version? LatestVersion = null);
internal sealed record SignedReleaseJob(string Version, string Branch, string CommitSha, string OutputDirectory,
    long RunId = 0, string? SignedExePath = null, string? SignedSha256 = null);

internal interface ISignedReleaseService
{
    Task<SignedReleaseSetup> CheckSetupAsync(CancellationToken cancellationToken);
    Task<SignedReleaseJob> BuildAsync(SignedReleaseRequest request, IProgress<SignedReleaseProgress> progress, CancellationToken cancellationToken);
    Task<SignedReleaseJob> ResumeAsync(SignedReleaseJob job, IProgress<SignedReleaseProgress> progress, CancellationToken cancellationToken);
    Task PublishAsync(SignedReleaseJob job, IProgress<SignedReleaseProgress> progress, CancellationToken cancellationToken);
}
#endif
