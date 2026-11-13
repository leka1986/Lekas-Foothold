using System.Security.Cryptography;
using System.Text;

namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private sealed record MissionImportGroup(MissionConfigSource Source, ConfigDocument CleanSource,
        string ConfigSourcePath, IReadOnlyList<InstanceImportPlan> Plans);

    private sealed class ReviewedMissionDownload
    {
        public required MissionDownloadSelection Selection { get; init; }
        public required IReadOnlyList<MissionVariantPlan> Outputs { get; set; }
        public required IReadOnlyList<MissionImportGroup> Imports { get; init; }
        public required IReadOnlyDictionary<string, MissionPathIdentity> Identities { get; set; }
        public required IReadOnlyDictionary<string, string> DestinationConfigPaths { get; init; }
        public required IReadOnlyDictionary<string, byte[]> DestinationConfigBytes { get; init; }
        public required IReadOnlyDictionary<string, string> ZipOutputs { get; init; }
        public bool CreationApproved { get; set; }
        public bool ReplacementApproved { get; set; }
        public IReadOnlyDictionary<long, string?>? RevisedWarehouseSources { get; set; }
        public IReadOnlyList<string> Creations => Imports.SelectMany(group => group.Plans).Where(plan => plan.CreateMissing)
            .Select(plan => plan.Current.Path).ToArray();
        public IReadOnlyList<string> Replacements => Outputs.Where(plan => plan.CollisionPolicy == MissionCollisionPolicy.AskReplace
            && plan.ReviewedIdentity?.Exists == true).Select(plan => plan.OutputPath)
            .Concat(ZipOutputs.Values.Where(path => Selection.CollisionPolicy == MissionCollisionPolicy.AskReplace && Identities[path].Exists)).ToArray();
    }

    private async Task<MissionDownloadResult> ExecuteMissionDownloadAsync(ReviewedMissionDownload reviewed,
        IProgress<LoadingProgress> progress, CancellationToken token)
    {
        token.ThrowIfCancellationRequested();
        if (reviewed.Selection.Prepared.IsDisposed) throw new InvalidDataException("Prepare the release again before installing.");
        if (reviewed.Creations.Count > 0 && !reviewed.CreationApproved)
            throw new InvalidDataException("Approve the listed new Config files before installing.");
        if (reviewed.Replacements.Count > 0 && !reviewed.ReplacementApproved)
            throw new InvalidDataException("Approve the listed file replacements before installing.");
        await Task.Run(() =>
        {
            foreach (var identity in reviewed.Identities.Values)
            {
                token.ThrowIfCancellationRequested();
                try { identity.RequireUnchanged(); }
                catch (Exception error) when (error is InvalidDataException or FileNotFoundException or DirectoryNotFoundException)
                {
                    foreach (var source in reviewed.Imports)
                    {
                        if (!PathsEqual(source.ConfigSourcePath, identity.Path)) continue;
                        var member = source.Source.Member;
                        var stage = Path.TrimEndingDirectorySeparator(Path.GetFullPath(reviewed.Selection.Prepared.StageDirectory))
                            + Path.DirectorySeparatorChar;
                        var expected = Path.GetFullPath(Path.Combine(stage, "config-sources", member.Sha256, member.Variant));
                        if (expected.StartsWith(stage, StringComparison.OrdinalIgnoreCase) && PathsEqual(source.ConfigSourcePath, expected))
                        {
                            token.ThrowIfCancellationRequested();
                            // This reviewed scratch source already owns its staged-byte reservation.
                            Directory.CreateDirectory(Path.GetDirectoryName(expected)!);
                            File.WriteAllBytes(expected, member.Bytes);
                        }
                        break;
                    }
                    reviewed.Selection.Prepared.InvalidateConsumedPath(identity.Path);
                    throw;
                }
            }
        }, token);
        var result = new MissionDownloadResult();
        var mapUpdates = new List<MissionMapUpdate>();
        var updated = new List<InstanceImportPlan>();
        var failedConfigs = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var activePath = _document?.Path;
        try
        {
            foreach (var group in reviewed.Imports)
            {
                token.ThrowIfCancellationRequested();
                try
                {
                    var committed = await CommitInstanceImportPlans(group.Plans, group.CleanSource,
                        group.ConfigSourcePath, null, progress, token, recordRelease: false);
                    updated.AddRange(committed.Updated);
                    result.UpdatedConfigs.AddRange(committed.Updated.Select(plan => plan.Current.Path));
                    result.Warnings.AddRange(committed.Warnings);
                    result.FailedConfigs.AddRange(committed.Failed);
                    foreach (var plan in group.Plans.Except(committed.Updated)) failedConfigs.Add(plan.Current.Path);
                    if (committed.Cancelled) { result.Cancelled = true; break; }
                }
                catch (OperationCanceledException) when (token.IsCancellationRequested) { throw; }
                catch (Exception error)
                {
                    foreach (var plan in group.Plans)
                    {
                        failedConfigs.Add(plan.Current.Path);
                        result.FailedConfigs.Add(plan.Name + ": " + error.Message);
                    }
                }
            }
            token.ThrowIfCancellationRequested();
            var destinationBytes = new Dictionary<string, byte[]>(reviewed.DestinationConfigBytes, StringComparer.OrdinalIgnoreCase);
            foreach (var destination in reviewed.DestinationConfigPaths)
            {
                if (failedConfigs.Contains(destination.Value)) { destinationBytes.Remove(destination.Key); continue; }
                if (result.UpdatedConfigs.Contains(destination.Value, StringComparer.OrdinalIgnoreCase))
                    destinationBytes[destination.Key] = await Task.Run(() => File.ReadAllBytes(destination.Value), token);
                else reviewed.Identities[destination.Value].RequireUnchanged();
            }
            var missionInputs = reviewed.Selection.Profiles.Count > 1
                ? new Dictionary<PreparedMissionTemplate, PreparedMissionInput>() : null;
            PreparedMissionTemplate? missionInputOwner = null;
            foreach (var output in reviewed.Outputs)
            {
                token.ThrowIfCancellationRequested();
                if (output.CollisionPolicy == MissionCollisionPolicy.Skip && output.ReviewedIdentity?.Exists == true)
                { result.Skipped.Add(output.OutputPath); continue; }
                progress.Report(new LoadingProgress("Installing " + Path.GetFileName(output.OutputPath) + "…"));
                try
                {
                    var members = new Dictionary<string, byte[]>(StringComparer.Ordinal);
                    if (output.Mode != MissionOutputMode.Original)
                        foreach (var member in output.Template.ConfigMembers)
                            members[member.Name] = destinationBytes.TryGetValue(member.Variant, out var bytes) ? bytes
                                : throw new InvalidDataException("The destination Config was not updated: " + member.Variant);
                    var installed = await Task.Run(() =>
                    {
                        PreparedMissionInput? input = null;
                        if (output.Mode != MissionOutputMode.Original && missionInputs is not null)
                        {
                            if (!ReferenceEquals(missionInputOwner, output.Template))
                            {
                                missionInputs.Clear();
                                missionInputOwner = output.Template;
                            }
                            input = WeatherMizService.GetPreparedMissionInput(output.Template, missionInputs);
                        }
                        return MissionVariantService.InstallReviewed(output, reviewed.Selection.CurrentMissionOptions, members,
                            output.CollisionPolicy == MissionCollisionPolicy.AskReplace && output.ReviewedIdentity?.Exists == true, token, input);
                    }, token);
                    result.Installed.Add(installed);
                    if (MissionUpdateProgress.FullMission(reviewed.Selection.Destination.Id, reviewed.Selection.Release.Tag,
                        output.Template.Asset, reviewed.Selection.ZipOnly) is { } update) mapUpdates.Add(update);
                }
                catch (OperationCanceledException) when (token.IsCancellationRequested) { throw; }
                catch (Exception error) { result.Failed.Add(output.OutputPath + ": " + error.Message); }
            }
            foreach (var zip in reviewed.ZipOutputs)
            {
                token.ThrowIfCancellationRequested();
                var identity = reviewed.Identities[zip.Value];
                if (reviewed.Selection.CollisionPolicy == MissionCollisionPolicy.Skip && identity.Exists)
                { result.Skipped.Add(zip.Value); continue; }
                progress.Report(new LoadingProgress("Saving " + Path.GetFileName(zip.Value) + "…"));
                try
                {
                    result.SavedZips.Add(await Task.Run(() => MissionVariantService.CopyVerifiedFile(zip.Key,
                        reviewed.Identities[zip.Key].Sha256!, zip.Value,
                        reviewed.Selection.CollisionPolicy == MissionCollisionPolicy.AskReplace && identity.Exists,
                        token, identity), token));
                }
                catch (OperationCanceledException) when (token.IsCancellationRequested) { throw; }
                catch (Exception error) { result.Failed.Add(zip.Value + ": " + error.Message); }
            }
        }
        catch (OperationCanceledException) when (token.IsCancellationRequested) { result.Cancelled = true; }
        catch (Exception error) { result.Warnings.Add("Stopped before the remaining files: " + error.Message); }
        finally
        {
            if (RememberMissionMapUpdates(mapUpdates) is { } progressWarning) result.Warnings.Add(progressWarning);
            var active = activePath is null ? null : updated.FirstOrDefault(plan => PathsEqual(plan.Current.Path, activePath));
            if (active is not null && !IsDisposed && !Disposing)
            {
                try
                {
                    LoadConfig(active.Current.Path);
                    ApplyImportedNewMarkers(CaptureImportedNewMarkers(active.Preview));
                }
                catch (Exception error) { result.Warnings.Add("The active Config was updated, but its view could not be reloaded: " + error.Message); }
            }
            if (!reviewed.Selection.ZipOnly && (result.Installed.Count > 0 || result.UpdatedConfigs.Count > 0))
            {
                _updateChecker ??= new GitHubUpdateChecker(ManagerBuildInfo.ReleaseVersion);
                try
                {
                    var state = await _updateChecker.RecordImportedFootholdAsync(reviewed.Selection.Release.Tag, CancellationToken.None);
                    PresentUpdateResult(state);
                    if (state.PersistenceError is not null) result.Warnings.Add(state.PersistenceError);
                }
                catch (Exception error) { result.Warnings.Add("The release was installed, but its history could not be saved: " + error.Message); }
            }
        }
        return result;
    }

    private static bool IsMissionDownloadWarehouseSource(ReviewedMissionDownload reviewed, string path) =>
        reviewed.Outputs.Any(plan => plan.WarehouseCopy is { } copy && PathsEqual(copy.SourceIdentity.Path, path));

    private bool ResolveMissionDownloadCollisions(ReviewedMissionDownload reviewed,
        Func<MissionVariantPlan, (string OutputPath, MissionCollisionPolicy Policy, MissionPathIdentity Identity)?> choose)
    {
        var outputs = reviewed.Outputs.ToArray();
        var identities = new Dictionary<string, MissionPathIdentity>(reviewed.Identities, StringComparer.OrdinalIgnoreCase);
        var reserved = outputs.Select(plan => plan.OutputPath).Concat(reviewed.ZipOutputs.Values).ToHashSet(StringComparer.OrdinalIgnoreCase);
        var consumed = outputs.Select(plan => plan.Template.SourcePath)
            .Concat(outputs.Where(plan => plan.WarehouseCopy is not null).Select(plan => plan.WarehouseCopy!.SourceIdentity.Path))
            .Concat(reviewed.Imports.Select(group => group.ConfigSourcePath))
            .Concat(reviewed.Imports.SelectMany(group => group.Plans).Select(plan => plan.Current.Path))
            .Concat(reviewed.DestinationConfigPaths.Values).Concat(reviewed.ZipOutputs.Keys).Concat(reviewed.ZipOutputs.Values)
            .ToHashSet(StringComparer.OrdinalIgnoreCase);
        for (var index = 0; index < outputs.Length; index++)
        {
            var output = outputs[index];
            var decision = choose(output);
            if (decision is null) return false;
            var choice = decision.Value;
            var directory = Path.GetDirectoryName(output.OutputPath)!;
            var original = choice.OutputPath.EndsWith(".miz.orig", StringComparison.OrdinalIgnoreCase);
            if (original && !WeatherMizService.BotOriginalsAvailable(output.OutputPath, null))
                throw new InvalidDataException("DCSServerBot originals were not detected for the selected output folder.");
            var name = WeatherExportNames.Normalize(Path.GetFileName(choice.OutputPath), output.Template.SourcePath, directory, keepBoth: false, original: original);
            var path = Path.GetFullPath(Path.Combine(directory, name));
            if (name.Length > 255 || !PathsEqual(path, choice.OutputPath) || !PathsEqual(path, choice.Identity.Path))
                throw new InvalidDataException("Choose a valid mission filename in the selected mission folder.");
            if (Directory.Exists(path) || reserved.Contains(path) && !PathsEqual(path, output.OutputPath))
                throw new InvalidDataException("Another selected output or folder already uses this filename. Choose another name.");
            if (choice.Policy is not (MissionCollisionPolicy.KeepBoth or MissionCollisionPolicy.AskReplace))
                throw new InvalidDataException("Choose a filename, Overwrite, or Cancel.");
            var identity = identities.TryGetValue(path, out var captured) ? captured : choice.Identity;
            identity.RequireUnchanged();
            if (identity.Exists && choice.Policy != MissionCollisionPolicy.AskReplace)
                throw new InvalidDataException("This filename exists. Explicitly choose Overwrite or another name.");
            if (IsMissionDownloadWarehouseSource(reviewed, path))
                throw new InvalidDataException("An output would replace an older warehouse source. Choose another name.");
            reserved.Remove(output.OutputPath);
            reserved.Add(path);
            if (!PathsEqual(output.OutputPath, path) && !consumed.Contains(output.OutputPath)) identities.Remove(output.OutputPath);
            identities[path] = identity;
            outputs[index] = output with { OutputPath = path, CollisionPolicy = choice.Policy, ReviewedIdentity = identity };
        }
        reviewed.Outputs = Array.AsReadOnly(outputs);
        reviewed.Identities = identities;
        return true;
    }

    private Task<ReviewedMissionDownload> PrepareReviewedMissionDownloadAsync(MissionDownloadSelection selection,
        IProgress<LoadingProgress> progress, CancellationToken token)
    {
        var cloudNames = selection.CheckMissionCollisions
            ? selection.Profiles.Select(profile => _weatherWindow?.CachedCloudPresetName(profile.Settings.CloudPreset)).ToArray()
            : Array.Empty<string?>();
        // These containers are detached from the retained controls before the worker reads them.
        var frozen = selection with
        {
            Assets = Array.AsReadOnly(selection.Assets.ToArray()),
            Templates = Array.AsReadOnly(selection.Templates.ToArray()),
            ConfigTargets = Array.AsReadOnly(selection.ConfigTargets.ToArray()),
            ConfigSources = new Dictionary<string, MissionConfigSource>(selection.ConfigSources, StringComparer.OrdinalIgnoreCase),
            Profiles = Array.AsReadOnly(selection.Profiles.ToArray()),
            WarehouseSources = new Dictionary<long, string?>(selection.WarehouseSources),
            Destination = new ServerProfileSettings { Id = selection.Destination.Id, Name = selection.Destination.Name,
                ConfigPath = selection.Destination.ConfigPath, MissionDirectory = selection.Destination.MissionDirectory }
        };
        return Task.Run(() => Prepare(), token);

        ReviewedMissionDownload Prepare()
        {
            token.ThrowIfCancellationRequested();
            if (frozen.Prepared.IsDisposed) throw new InvalidDataException("The prepared downloads are no longer available.");
            if (frozen.Assets.Count == 0 || frozen.Templates.Count == 0
                || frozen.Assets.Any(asset => !GitHubUpdateChecker.IsValidReleaseAsset(asset, frozen.Release.Tag)
                    || !frozen.Release.Assets.Contains(asset)
                    || !frozen.Prepared.Packages.TryGetValue(asset.Id, out var package) || package.Asset != asset)
                || frozen.Templates.Any(template => !frozen.Assets.Contains(template.Asset)
                    || !frozen.Prepared.Packages[template.Asset.Id].Templates.Contains(template)))
                throw new InvalidDataException("The selected missions must belong to the prepared release ZIPs.");
            if (!frozen.ZipOnly && (!Path.IsPathFullyQualified(frozen.MissionDirectory) || !Directory.Exists(frozen.MissionDirectory)))
                throw new DirectoryNotFoundException("Choose an available mission destination folder.");
            if ((frozen.KeepZip || frozen.ZipOnly) && (!Path.IsPathFullyQualified(frozen.ZipDirectory) || !Directory.Exists(frozen.ZipDirectory)))
                throw new DirectoryNotFoundException("Choose an available folder for the selected ZIPs.");
            if (!frozen.ZipOnly) RequireOutsideStage(frozen.MissionDirectory);
            if (frozen.KeepZip || frozen.ZipOnly) RequireOutsideStage(frozen.ZipDirectory);
            if (frozen.ApplyCurrentMissionOptions && !frozen.ZipOnly && frozen.CurrentMissionOptions is null)
                throw new InvalidDataException("The reviewed Mission options snapshot is missing.");
            frozen.CurrentMissionOptions?.Validate();

            var identities = new Dictionary<string, MissionPathIdentity>(StringComparer.OrdinalIgnoreCase);
            var loaded = new Dictionary<string, (ConfigDocument Document, byte[] Bytes)>(StringComparer.OrdinalIgnoreCase);
            if (frozen.KeepZip || frozen.ZipOnly)
                foreach (var asset in frozen.Assets)
                {
                    var package = frozen.Prepared.Packages[asset.Id];
                    identities[package.ZipPath] = new(package.ZipPath, true, asset.Size, package.Sha256);
                }
            if (!frozen.ZipOnly)
                foreach (var template in frozen.Templates)
                {
                    try { identities[template.SourcePath] = new(template.SourcePath, true, new FileInfo(template.SourcePath).Length, template.Sha256); }
                    catch (Exception error) when (error is FileNotFoundException or DirectoryNotFoundException)
                    {
                        frozen.Prepared.InvalidateConsumedPath(template.SourcePath);
                        throw;
                    }
                }

            var imports = new List<MissionImportGroup>();
            if (frozen.UpdateConfig && !frozen.ZipOnly)
            {
                var targets = frozen.ConfigTargets.Select(target => target with { Path = Path.GetFullPath(target.Path) })
                    .DistinctBy(target => target.Path, StringComparer.OrdinalIgnoreCase).ToArray();
                if (targets.Length == 0) throw new InvalidDataException("Select the Config paths to update.");
                var previousSources = LoadStoredRestoreDefaultsSources();
                var previousDocuments = new Dictionary<string, ConfigDocument>(StringComparer.OrdinalIgnoreCase);
                foreach (var variantTargets in targets.GroupBy(target => Path.GetFileName(target.Path), StringComparer.OrdinalIgnoreCase))
                {
                    token.ThrowIfCancellationRequested();
                    var variant = RuntimeSettings.SupportedConfigFileNames.FirstOrDefault(name => name.Equals(variantTargets.Key, StringComparison.OrdinalIgnoreCase))
                        ?? throw new InvalidDataException("Choose a supported Config variant.");
                    if (!frozen.ConfigSources.TryGetValue(variant, out var source)
                        || !source.Member.Variant.Equals(variant, StringComparison.OrdinalIgnoreCase)
                        || !frozen.Templates.Contains(source.Template) || !source.Template.ConfigMembers.Contains(source.Member))
                        throw new InvalidDataException("Choose the " + variant + " source from a selected mission.");
                    var sourceHash = Convert.ToHexString(SHA256.HashData(source.Member.Bytes));
                    if (!sourceHash.Equals(source.Member.Sha256, StringComparison.OrdinalIgnoreCase))
                        throw new InvalidDataException("The prepared Config source changed.");
                    var sourceDirectory = Path.Combine(frozen.Prepared.StageDirectory, "config-sources", sourceHash);
                    Directory.CreateDirectory(sourceDirectory);
                    var sourcePath = Path.Combine(sourceDirectory, variant);
                    if (!File.Exists(sourcePath))
                    {
                        frozen.Prepared.ReserveStagedBytes(source.Member.Bytes.LongLength);
                        File.WriteAllBytes(sourcePath, source.Member.Bytes);
                    }
                    identities[sourcePath] = MissionPathIdentity.Capture(sourcePath, source.Member.Bytes);
                    var genericBytes = MissionVersionStamp.Remove(source.Member.Bytes);
                    var clean = ConfigDocument.LoadText(sourcePath, Decode(genericBytes));
                    clean.RepairStringListSeparators();
                    clean.PrepareTupleChoiceMigration();
                    RequireValid(clean, variant, new List<string>());
                    var plans = new List<InstanceImportPlan>();
                    foreach (var target in variantTargets)
                    {
                        token.ThrowIfCancellationRequested();
                        RequireOutsideStage(target.Path);
                        if (!Directory.Exists(Path.GetDirectoryName(target.Path)))
                            throw new DirectoryNotFoundException("The selected Config folder is unavailable: " + target.Path);
                        progress.Report(new LoadingProgress("Preparing " + target.Name + " · " + variant + "…"));
                        ConfigDocument current;
                        var missing = !File.Exists(target.Path);
                        if (missing)
                        {
                            identities[target.Path] = MissionPathIdentity.Capture(target.Path);
                            current = ConfigDocument.LoadText(target.Path, Decode(genericBytes));
                        }
                        else current = LoadCurrent(target.Path).Document;
                        ConfigDocument? previous = null;
                        var previousInfo = SelectStoredMizDefaultsForConfig(previousSources, target.Path);
                        if (previousInfo is not null)
                        {
                            var key = Path.GetFullPath(previousInfo.ConfigPath);
                            if (!previousDocuments.TryGetValue(key, out previous))
                            {
                                previous = TryLoadStoredMizDefaults(previousInfo);
                                if (previous is not null) previousDocuments[key] = previous;
                            }
                        }
                        var plan = PrepareInstanceImport(current, clean.CreateWorkingCopy(), previous, target.Name);
                        plan.CreateMissing = missing;
                        plan.ReviewedIdentity = identities[target.Path];
                        ApplyInstanceImportChoices(plan);
                        RequireValid(plan.Output, target.Name, plan.Preview.ImportWarnings);
                        plans.Add(plan);
                    }
                    imports.Add(new(source, clean, sourcePath, Array.AsReadOnly(plans.ToArray())));
                }
            }
            var warehouseCopies = new Dictionary<PreparedMissionTemplate, MissionWarehouseCopy>();
            if (frozen.CopyWarehouses && !frozen.ZipOnly)
            {
                var captured = new Dictionary<string, MissionWarehouseCopy>(StringComparer.OrdinalIgnoreCase);
                var sourceSnapshots = new Dictionary<string, MissionWarehouseService.SourceSnapshot>(StringComparer.OrdinalIgnoreCase);
                var remainingWarehouseBytes = frozen.Prepared.AvailableCapturedBytes;
                foreach (var template in frozen.Templates)
                {
                    token.ThrowIfCancellationRequested();
                    if (!frozen.WarehouseSources.TryGetValue(template.Asset.Id, out var source))
                        throw new InvalidDataException("Choose a warehouse source, or explicitly use the new warehouses for " + template.Name + ".");
                    if (source is null) continue;
                    if (!Path.IsPathFullyQualified(source))
                        throw new InvalidDataException("Choose a full warehouse source path.");
                    source = Path.GetFullPath(source);
                    if (RuntimeSettings.ResolveMissionsDirectory(frozen.Destination) is not { } sourceDirectory
                        || !Directory.Exists(sourceDirectory) || !PathsEqual(Path.GetDirectoryName(source)!, sourceDirectory))
                        throw new InvalidDataException("The warehouse source must be in the selected instance's Missions folder.");
                    RequireOutsideStage(source);
                    var key = template.Sha256 + "\n" + source;
                    if (!captured.TryGetValue(key, out var copy))
                    {
                        progress.Report(new LoadingProgress("Checking warehouses · " + Path.GetFileName(source) + "…"));
                        if (!sourceSnapshots.TryGetValue(source, out var snapshot))
                        {
                            snapshot = MissionWarehouseService.CaptureSource(template, source, token);
                            if (snapshot.Bytes.LongLength > remainingWarehouseBytes)
                                throw new InvalidDataException("The selected warehouses exceed the preparation memory limit. Select fewer maps.");
                            remainingWarehouseBytes -= snapshot.Bytes.LongLength;
                            sourceSnapshots.Add(source, snapshot);
                        }
                        try { copy = MissionWarehouseService.PrepareFromSource(template, snapshot, token); }
                        catch (Exception error) when (error is InvalidDataException or IOException or UnauthorizedAccessException)
                        {
                            try { identities[template.SourcePath].RequireUnchanged(); }
                            catch (Exception stale) when (stale is InvalidDataException or FileNotFoundException or DirectoryNotFoundException)
                            {
                                frozen.Prepared.InvalidateConsumedPath(template.SourcePath);
                                throw;
                            }
                            throw;
                        }
                        captured.Add(key, copy);
                    }
                    else MissionWarehouseService.ValidateSourceSelection(template, source);
                    warehouseCopies[template] = copy;
                    if (identities.TryGetValue(source, out var previousIdentity)
                        && previousIdentity != copy.SourceIdentity)
                        throw new InvalidDataException("A warehouse source changed while preparing. Prepare and review again: " + source);
                    identities[source] = copy.SourceIdentity;
                }
            }

            var outputNames = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            if (!frozen.ZipOnly && !string.IsNullOrWhiteSpace(frozen.Destination.ConfigPath))
                foreach (var template in frozen.Templates)
                {
                    var variants = template.ConfigMembers.Select(member => member.Variant).Distinct(StringComparer.OrdinalIgnoreCase).ToArray();
                    var variant = variants.Length == 1 ? variants[0]
                        : (MissionWarehouseService.GetMapVariant(template.Name) ?? MissionWarehouseService.GetMapVariant(template.Asset.Name)) == "Normandy WWII"
                            ? RuntimeSettings.Ww2ConfigFileName : RuntimeSettings.DefaultConfigFileName;
                    var path = ResolveMatchingCopyTargetPath(frozen.Destination.ConfigPath, variant);
                    var imported = imports.SelectMany(group => group.Plans).FirstOrDefault(plan => PathsEqual(plan.Current.Path, path));
                    var document = imported?.Output ?? (File.Exists(path) ? LoadCurrent(path).Document : null);
                    if (document is null) continue;
                    var value = document.Entries.FirstOrDefault(entry => entry.DisplayKey == "Era")?.ValueText;
                    var era = value is not null ? ConfigEntry.UnquoteLuaString(value)
                        : variant.Equals(RuntimeSettings.Ww2ConfigFileName, StringComparison.OrdinalIgnoreCase) ? "WW2" : null;
                    if (!string.IsNullOrWhiteSpace(era)) outputNames[template.SourcePath] = WeatherExportNames.SuggestOptions(template.Name, era);
                }
            var namingProfiles = frozen.Profiles;
            var originals = new Dictionary<ProfileMissionSnapshot, ProfileMissionSnapshot>(ReferenceEqualityComparer.Instance);
            if (frozen.CheckMissionCollisions)
                namingProfiles = frozen.Profiles.Select((profile, index) =>
                {
                    var naming = profile with { Name = WeatherExportNames.DownloadProfileSuffix(cloudNames[index], profile.Settings) };
                    originals.Add(naming, profile);
                    return naming;
                }).ToArray();
            var rawPlans = frozen.ZipOnly ? Array.Empty<MissionVariantPlan>()
                : MissionVariantService.BuildNamedPlan(frozen.Templates, namingProfiles, frozen.ApplyCurrentMissionOptions,
                    frozen.MissionDirectory, frozen.CheckMissionCollisions ? MissionCollisionPolicy.AskReplace : frozen.CollisionPolicy, outputNames)
                    .Select(plan => frozen.CheckMissionCollisions && plan.Profile is { } profile ? plan with { Profile = originals[profile] } : plan).ToArray();
            var used = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            var outputs = rawPlans.Select(plan =>
            {
                var path = ReviewOutput(plan.OutputPath, plan.CollisionPolicy, used);
                if (!frozen.CheckMissionCollisions && warehouseCopies.Values.Any(copy => PathsEqual(copy.SourceIdentity.Path, path)))
                    throw new InvalidDataException("An output would replace an older warehouse source. Choose Keep both or another mission folder.");
                return plan with { OutputPath = path, ReviewedIdentity = identities[path],
                    WarehouseCopy = warehouseCopies.GetValueOrDefault(plan.Template) };
            }).ToArray();
            var destinationPaths = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            var destinationBytes = new Dictionary<string, byte[]>(StringComparer.OrdinalIgnoreCase);
            foreach (var variant in outputs.Where(plan => plan.Mode != MissionOutputMode.Original)
                .SelectMany(plan => plan.Template.ConfigMembers).Select(member => member.Variant).Distinct(StringComparer.OrdinalIgnoreCase))
            {
                var path = ResolveMatchingCopyTargetPath(frozen.Destination.ConfigPath, variant);
                RequireOutsideStage(path);
                destinationPaths[variant] = path;
                if (File.Exists(path)) destinationBytes[variant] = LoadCurrent(path).Bytes;
                else if (!imports.SelectMany(group => group.Plans).Any(plan => plan.CreateMissing && PathsEqual(plan.Current.Path, path)))
                    throw new InvalidDataException("The destination is missing " + variant + ". Select its Config update and creation, or install the original mission unchanged.");
            }
            var zipOutputs = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            if (frozen.KeepZip || frozen.ZipOnly)
                foreach (var asset in frozen.Assets)
                {
                    // Reuse the established Windows filename checks; the saved payload remains a ZIP.
                    WeatherExportNames.Normalize(Path.ChangeExtension(asset.Name, ".miz"), frozen.Prepared.Packages[asset.Id].ZipPath,
                        frozen.ZipDirectory, false);
                    zipOutputs[frozen.Prepared.Packages[asset.Id].ZipPath] =
                        ReviewOutput(Path.Combine(frozen.ZipDirectory, asset.Name), frozen.CollisionPolicy, used);
                }
            token.ThrowIfCancellationRequested();
            return new ReviewedMissionDownload { Selection = frozen, Outputs = Array.AsReadOnly(outputs),
                Imports = Array.AsReadOnly(imports.ToArray()), Identities = identities,
                DestinationConfigPaths = destinationPaths, DestinationConfigBytes = destinationBytes, ZipOutputs = zipOutputs };

            (ConfigDocument Document, byte[] Bytes) LoadCurrent(string path)
            {
                path = Path.GetFullPath(path);
                if (loaded.TryGetValue(path, out var cached)) return cached;
                token.ThrowIfCancellationRequested();
                var bytes = File.ReadAllBytes(path);
                var document = ConfigDocument.LoadText(path, Decode(bytes));
                document.RepairStringListSeparators();
                if (frozen.UpdateConfig || frozen.ApplyCurrentMissionOptions || frozen.Profiles.Count > 0)
                    RequireValid(document, Path.GetFileName(path), new List<string>());
                identities[path] = MissionPathIdentity.Capture(path, bytes);
                loaded[path] = (document, bytes);
                return (document, bytes);
            }

            string ReviewOutput(string proposed, MissionCollisionPolicy policy, HashSet<string> reserved)
            {
                RequireOutsideStage(proposed);
                var path = Path.GetFullPath(proposed);
                if (policy == MissionCollisionPolicy.KeepBoth)
                {
                    var directory = Path.GetDirectoryName(path)!;
                    var fileName = Path.GetFileName(path);
                    for (var number = 1; File.Exists(path) || Directory.Exists(path) || reserved.Contains(path); number++)
                        path = Path.Combine(directory, WeatherExportNames.NumberedName(fileName, number + 1));
                    if (Path.GetFileName(path).Length > 255) throw new InvalidDataException("The numbered output filename is too long.");
                }
                if (!reserved.Add(path)) throw new InvalidDataException("Two reviewed outputs have the same path.");
                if (frozen.CheckMissionCollisions && identities.TryGetValue(path, out var captured)) captured.RequireUnchanged();
                else identities[path] = MissionPathIdentity.Capture(path);
                return path;
            }

            void RequireOutsideStage(string path)
            {
                var full = Path.GetFullPath(path);
                var stage = Path.TrimEndingDirectorySeparator(Path.GetFullPath(frozen.Prepared.StageDirectory));
                if (full.Equals(stage, StringComparison.OrdinalIgnoreCase) || full.StartsWith(stage + Path.DirectorySeparatorChar, StringComparison.OrdinalIgnoreCase))
                    throw new InvalidDataException("Choose a destination outside the private download staging folder.");
            }
        }

        static string Decode(byte[] bytes)
        {
            var bom = bytes.AsSpan().StartsWith(new byte[] { 0xef, 0xbb, 0xbf }) ? 3 : 0;
            return new UTF8Encoding(false, true).GetString(bytes, bom, bytes.Length - bom);
        }
        static void RequireValid(ConfigDocument document, string name, List<string> warnings)
        {
            var errors = document.ValidateForImport(warnings);
            if (errors.Count > 0) throw new InvalidDataException(name + ": " + string.Join(Environment.NewLine, errors.Take(8)));
        }
    }
}
