#requires -Version 7.2
<#
.SYNOPSIS
Build an unsigned player candidate, or verify a SignPath result. This script never signs or publishes.
.DESCRIPTION
Build uses private copies under WorkDirectory. VerifySigned accepts exactly the expected EXE and
writes release-result.json only after Windows validates its SignPath Foundation signature.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('Build', 'VerifySigned')][string]$Mode,
    [Parameter(Mandatory)][string]$Version,
    [Parameter(Mandatory)][ValidatePattern('^[a-fA-F0-9]{40}$')][string]$SourceCommit,
    [Parameter(Mandatory)][string]$ArtifactDirectory,
    [string]$ProjectDirectory = $PSScriptRoot,
    [string]$ReleaseInputsDirectory = (Join-Path $PSScriptRoot 'release-inputs'),
    [string]$WorkDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$utf8 = [System.Text.UTF8Encoding]::new($false)

function Get-ReleaseVersion([string]$Text) {
    if ($Text -notmatch '^\d+\.\d+\.\d+(?:\.\d+)?$') {
        throw 'Use a numeric release version such as 2.1.6 or 2.1.6.1.'
    }
    $parsed = [version]::Parse($Text)
    if ($parsed.Major -gt 65535 -or $parsed.Minor -gt 65535 -or $parsed.Build -gt 65535 -or $parsed.Revision -gt 65535) {
        throw 'Release version components must be between 0 and 65535.'
    }
    return [version]::new($parsed.Major, $parsed.Minor, $parsed.Build, [Math]::Max(0, $parsed.Revision))
}

function Assert-EmptyDirectory([string]$Path) {
    if (Test-Path -LiteralPath $Path) {
        if (-not (Test-Path -LiteralPath $Path -PathType Container) -or @(Get-ChildItem -LiteralPath $Path -Force).Count -ne 0) {
            throw "An empty output directory is required: $Path"
        }
    }
    else { [void][System.IO.Directory]::CreateDirectory($Path) }
}

function Invoke-Dotnet([string[]]$Arguments) {
    & dotnet @Arguments
    if ($LASTEXITCODE -ne 0) { throw "dotnet failed with exit code $LASTEXITCODE ($($Arguments[0]))." }
}

$releaseVersion = Get-ReleaseVersion $Version
$fileName = "Foothold Config Manager $Version.exe"
$ArtifactDirectory = [System.IO.Path]::GetFullPath($ArtifactDirectory)

if ($Mode -eq 'VerifySigned') {
    $entries = @(Get-ChildItem -LiteralPath $ArtifactDirectory -Force)
    if ($entries.Count -ne 1 -or $entries[0].PSIsContainer -or $entries[0].Name -cne $fileName -or
        ($entries[0].Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
        throw "The signed artifact must contain only $fileName at its root."
    }
    $exePath = $entries[0].FullName
    $signature = Get-AuthenticodeSignature -LiteralPath $exePath
    if ($signature.Status -ne [System.Management.Automation.SignatureStatus]::Valid -or
        $null -eq $signature.SignerCertificate -or
        $signature.SignerCertificate.GetNameInfo([System.Security.Cryptography.X509Certificates.X509NameType]::SimpleName, $false) -cne 'SignPath Foundation') {
        throw "The release needs a trusted, valid SignPath Foundation Authenticode signature (status: $($signature.Status))."
    }
    $actualVersion = Get-ReleaseVersion ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($exePath).FileVersion)
    if ($actualVersion -ne $releaseVersion) { throw 'The signed EXE file version does not match the requested release.' }
    $result = [ordered]@{
        version = $Version
        sourceCommit = $SourceCommit.ToLowerInvariant()
        fileName = $fileName
        sha256 = (Get-FileHash -LiteralPath $exePath -Algorithm SHA256).Hash.ToLowerInvariant()
        buildMode = 'user'
    }
    [System.IO.File]::WriteAllText((Join-Path $ArtifactDirectory 'release-result.json'), ($result | ConvertTo-Json), $utf8)
    Write-Host "Verified signed release: $fileName"
    return
}

if ([string]::IsNullOrWhiteSpace($WorkDirectory)) { throw 'Build requires a private, empty WorkDirectory.' }
$ProjectDirectory = [System.IO.Path]::GetFullPath($ProjectDirectory)
$ReleaseInputsDirectory = [System.IO.Path]::GetFullPath($ReleaseInputsDirectory)
$WorkDirectory = [System.IO.Path]::GetFullPath($WorkDirectory)
foreach ($outputPath in @($WorkDirectory, $ArtifactDirectory)) {
    foreach ($inputPath in @($ProjectDirectory, $ReleaseInputsDirectory)) {
        if ($outputPath.Equals($inputPath, [System.StringComparison]::OrdinalIgnoreCase) -or
            $outputPath.StartsWith($inputPath.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw 'Build output must be outside the checked-out project and release inputs.'
        }
    }
}
$expectedInputs = @('EmbeddedGuiMetadata.json', 'EmbeddedBuildMode.txt', 'ManagerVersion.txt')
$releaseInputNames = @($expectedInputs) + 'source-manifest.json'
$inputEntries = @(Get-ChildItem -LiteralPath $ReleaseInputsDirectory -Force)
if ($inputEntries.Count -ne $releaseInputNames.Count -or @($inputEntries | Where-Object {
    $_.PSIsContainer -or $_.Name -cnotin $releaseInputNames -or ($_.Attributes -band [System.IO.FileAttributes]::ReparsePoint)
}).Count -ne 0) { throw 'release-inputs must contain exactly EmbeddedGuiMetadata.json, EmbeddedBuildMode.txt, ManagerVersion.txt and source-manifest.json.' }
if ([System.IO.File]::ReadAllText((Join-Path $ReleaseInputsDirectory 'EmbeddedBuildMode.txt')).Trim() -cne 'user') {
    throw 'The requested embedded build mode must be user.'
}
foreach ($versionPath in @((Join-Path $ProjectDirectory 'ManagerVersion.txt'), (Join-Path $ReleaseInputsDirectory 'ManagerVersion.txt'))) {
    if ((Get-ReleaseVersion ([System.IO.File]::ReadAllText($versionPath).Trim())) -ne $releaseVersion) {
        throw "ManagerVersion.txt does not match the requested release: $versionPath"
    }
}
$metadataPath = Join-Path $ReleaseInputsDirectory 'EmbeddedGuiMetadata.json'
$metadata = [System.IO.File]::ReadAllText($metadataPath) | ConvertFrom-Json
if ((Get-ReleaseVersion $metadata.FooterVersion) -ne $releaseVersion) { throw 'The embedded metadata FooterVersion does not match the requested release.' }
# The branch can inherit older files from its base. Only hash-bound manifest inputs enter a build.
$manifest = @([System.IO.File]::ReadAllText((Join-Path $ReleaseInputsDirectory 'source-manifest.json')) | ConvertFrom-Json)
$seenPaths = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$extensions = @('.cs', '.csproj', '.resx', '.ico', '.png', '.jpg', '.jpeg', '.json', '.txt', '.ps1')
$verifiedInputs = foreach ($entry in $manifest) {
    $inputName = [string]$entry.path
    if (-not $seenPaths.Add($inputName)) { throw "Duplicate source manifest path: $inputName" }
    if ([string]$entry.sha256 -notmatch '^[A-Fa-f0-9]{64}$') { throw "Invalid source manifest hash: $inputName" }
    $projectPrefix = 'tools/FootholdConfigManager/'
    $releasePrefix = $projectPrefix + 'release-inputs/'
    if ($inputName.StartsWith($releasePrefix, [StringComparison]::Ordinal)) {
        $leafName = $inputName.Substring($releasePrefix.Length)
        if ($leafName -cnotin $expectedInputs) { throw "Unexpected release input in source manifest: $inputName" }
        $inputPath = Join-Path $ReleaseInputsDirectory $leafName
        $relativeOutput = $null
    }
    elseif ($inputName.StartsWith($projectPrefix, [StringComparison]::Ordinal)) {
        $leafName = $inputName.Substring($projectPrefix.Length)
        if ($leafName.Contains('/') -or $leafName.Contains('\') -or
            [System.IO.Path]::GetExtension($leafName) -notin $extensions -or
            ([System.IO.Path]::GetExtension($leafName) -eq '.ps1' -and $leafName -cne 'BuildSignedRelease.ps1')) {
            throw "Unexpected project input in source manifest: $inputName"
        }
        $inputPath = Join-Path $ProjectDirectory $leafName
        $relativeOutput = 'source/' + $leafName
    }
    elseif ($inputName -cin @('tools/test-configs/Foothold Config.lua', 'tools/test-configs/Foothold Config WW2.lua')) {
        $leafName = $inputName.Substring('tools/test-configs/'.Length)
        $inputPath = Join-Path (Split-Path -Parent $ProjectDirectory) ('test-configs/' + $leafName)
        $relativeOutput = 'test-configs/' + $leafName
    }
    else { throw "Unexpected path in source manifest: $inputName" }
    $inputFile = Get-Item -LiteralPath $inputPath
    if ($inputFile.PSIsContainer -or ($inputFile.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
        throw "Source manifest input is not a regular file: $inputName"
    }
    if ((Get-FileHash -LiteralPath $inputPath -Algorithm SHA256).Hash -cne ([string]$entry.sha256).ToUpperInvariant()) {
        throw "Source manifest hash mismatch: $inputName"
    }
    [pscustomobject]@{ Path = $inputPath; RelativeOutput = $relativeOutput }
}
foreach ($requiredPath in @('tools/FootholdConfigManager/FootholdConfigManager.csproj', 'tools/FootholdConfigManager/BuildSignedRelease.ps1',
    'tools/test-configs/Foothold Config.lua', 'tools/test-configs/Foothold Config WW2.lua') + @($expectedInputs | ForEach-Object {
        'tools/FootholdConfigManager/' + $_; 'tools/FootholdConfigManager/release-inputs/' + $_
    })) {
    if (-not $seenPaths.Contains($requiredPath)) { throw "Source manifest is missing: $requiredPath" }
}
foreach ($inputName in $expectedInputs) {
    if ((Get-FileHash -LiteralPath (Join-Path $ProjectDirectory $inputName) -Algorithm SHA256).Hash -cne
        (Get-FileHash -LiteralPath (Join-Path $ReleaseInputsDirectory $inputName) -Algorithm SHA256).Hash) {
        throw "The source and release-inputs copies differ: $inputName"
    }
}
Assert-EmptyDirectory $WorkDirectory
Assert-EmptyDirectory $ArtifactDirectory
$adminProject = Join-Path $WorkDirectory 'admin/source'
$playerProject = Join-Path $WorkDirectory 'player/source'
foreach ($stage in @('admin', 'player')) {
    foreach ($inputFile in $verifiedInputs | Where-Object { $null -ne $_.RelativeOutput }) {
        $destination = Join-Path (Join-Path $WorkDirectory $stage) $inputFile.RelativeOutput
        [void][System.IO.Directory]::CreateDirectory((Split-Path -Parent $destination))
        Copy-Item -LiteralPath $inputFile.Path -Destination $destination
    }
}
# Only the private admin copy changes mode; the player consumes the exact submitted bytes.
[System.IO.File]::WriteAllText((Join-Path $adminProject 'EmbeddedBuildMode.txt'), 'admin', $utf8)
foreach ($inputName in $expectedInputs) {
    Copy-Item -LiteralPath (Join-Path $ReleaseInputsDirectory $inputName) -Destination (Join-Path $playerProject $inputName) -Force
}

$harnessDirectory = Join-Path $WorkDirectory 'verification-harness'
[void][System.IO.Directory]::CreateDirectory($harnessDirectory)
$harnessProject = @"
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net8.0-windows</TargetFramework>
    <UseWindowsForms>true</UseWindowsForms>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>
</Project>
"@
[System.IO.File]::WriteAllText((Join-Path $harnessDirectory 'ReleaseVerification.csproj'), $harnessProject, $utf8)
$harnessSource = @"
using System.Reflection;
using System.Runtime.Loader;

internal static class ReleaseVerification
{
    [STAThread]
    private static int Main(string[] args)
    {
        try
        {
            var assemblyPath = Path.GetFullPath(args[1]);
            AssemblyLoadContext.Default.Resolving += (_, name) =>
            {
                var dependency = Path.Combine(Path.GetDirectoryName(assemblyPath)!, name.Name + ".dll");
                return File.Exists(dependency) ? AssemblyLoadContext.Default.LoadFromAssemblyPath(dependency) : null;
            };
            if (args[0] == "self-test")
            {
                Directory.CreateDirectory(args[2]);
                AppContext.SetData("FootholdManager3.DataDirectory", Path.GetFullPath(args[2]));
                var admin = AssemblyLoadContext.Default.LoadFromAssemblyPath(assemblyPath);
                return (int)admin.EntryPoint!.Invoke(null, new object[] { new[] { args[3] } })!;
            }
            if (args[0] != "inspect-player") throw new InvalidOperationException("Unknown verification command.");
            var player = AssemblyLoadContext.Default.LoadFromAssemblyPath(assemblyPath);
            byte[] Resource(string suffix)
            {
                using var stream = player.GetManifestResourceStream("FootholdConfigManager." + suffix)
                    ?? throw new InvalidOperationException("Missing embedded resource: " + suffix);
                using var buffer = new MemoryStream();
                stream.CopyTo(buffer);
                return buffer.ToArray();
            }
            var inputDirectory = args[2];
            foreach (var input in new[] { "EmbeddedGuiMetadata.json", "EmbeddedBuildMode.txt", "ManagerVersion.txt" })
                if (!Resource(input).AsSpan().SequenceEqual(File.ReadAllBytes(Path.Combine(inputDirectory, input))))
                    throw new InvalidOperationException("Player resource differs from submitted release input: " + input);
            if (System.Text.Encoding.UTF8.GetString(Resource("EmbeddedBuildMode.txt")).Trim() != "user")
                throw new InvalidOperationException("Player is not in user mode.");
            var expected = Version.Parse(args[3]);
            if (player.GetName().Version != expected) throw new InvalidOperationException("Player assembly version differs from release.");
            foreach (var adminType in new[] { "SignedReleaseService", "SignedReleaseDialog", "SignedReleaseJob", "ISignedReleaseService", "StabilityRegressionSelfTest" })
                if (player.GetType("FootholdConfigManager." + adminType, throwOnError: false) is not null)
                    throw new InvalidOperationException("Admin-only type found in player assembly: " + adminType);
            if (player.GetManifestResourceNames().Any(name => name.StartsWith("FootholdConfigManager.Preview.", StringComparison.Ordinal)))
                throw new InvalidOperationException("Admin preview samples are embedded in the player assembly.");
            Console.WriteLine("Player version, user mode, metadata bytes and admin exclusions verified.");
            return 0;
        }
        catch (Exception error)
        {
            Console.Error.WriteLine(error.InnerException ?? error);
            return 1;
        }
    }
}
"@
[System.IO.File]::WriteAllText((Join-Path $harnessDirectory 'Program.cs'), $harnessSource, $utf8)

$originalDirectory = (Get-Location).Path
try {
    # Restore and build use isolated copies; checked-out bin/obj directories stay untouched.
    Set-Location -LiteralPath $WorkDirectory
    $harnessOutput = Join-Path $harnessDirectory 'out'
    Invoke-Dotnet @('build', (Join-Path $harnessDirectory 'ReleaseVerification.csproj'), '-c', 'Release', '-o', $harnessOutput, '--nologo')
    $harnessDll = Join-Path $harnessOutput 'ReleaseVerification.dll'
    $adminOutput = Join-Path $WorkDirectory 'admin-build'
    Invoke-Dotnet @('build', (Join-Path $adminProject 'FootholdConfigManager.csproj'), '-c', 'Release', '-r', 'win-x64', '-p:SelfContained=false', '-o', $adminOutput, '--nologo')
    $adminDll = Join-Path $adminOutput 'FootholdConfigManager.dll'
    foreach ($test in @('--self-test-merge', '--self-test-stability')) {
        $privateData = Join-Path $WorkDirectory ($test.TrimStart('-') + '-data')
        Invoke-Dotnet @($harnessDll, 'self-test', $adminDll, $privateData, $test)
    }
    $publishDirectory = Join-Path $WorkDirectory 'player-publish'
    Invoke-Dotnet @('publish', (Join-Path $playerProject 'FootholdConfigManager.csproj'), '-c', 'Release', '-r', 'win-x64', '-p:PublishSingleFile=true', '-p:SelfContained=false', '-p:PublishReadyToRun=false', '-p:DebugType=None', '-p:DebugSymbols=false', '-o', $publishDirectory, '--nologo')
    $playerDll = Join-Path $playerProject 'bin/Release/net8.0-windows/win-x64/FootholdConfigManager.dll'
    Invoke-Dotnet @($harnessDll, 'inspect-player', $playerDll, $ReleaseInputsDirectory, $releaseVersion.ToString(4))
    $builtExe = Join-Path $publishDirectory 'FootholdConfigManager.exe'
    if ((Get-ReleaseVersion ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($builtExe).FileVersion)) -ne $releaseVersion) {
        throw 'The published EXE file version does not match the requested release.'
    }
    if (@(Get-ChildItem -LiteralPath $publishDirectory -File | Where-Object { $_.Extension -in @('.exe', '.dll') }).Count -ne 1) {
        throw 'The player publish did not produce the expected single-file executable.'
    }
    Copy-Item -LiteralPath $builtExe -Destination (Join-Path $ArtifactDirectory $fileName)
    Write-Host "Unsigned player candidate ready for SignPath: $fileName (source $SourceCommit)"
}
finally { Set-Location -LiteralPath $originalDirectory }
