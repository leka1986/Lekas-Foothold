using System.Security.Cryptography;

namespace FootholdConfigManager;

internal static class MissionVariantService
{
    private static readonly IReadOnlyDictionary<string, string> EmptyOutputNames = new Dictionary<string, string>();

    internal static IReadOnlyList<MissionVariantPlan> BuildPlan(IReadOnlyList<PreparedMissionTemplate> templates,
        IReadOnlyList<ProfileMissionSnapshot> profiles, bool applyCurrentMissionOptions, string missionDirectory,
        MissionCollisionPolicy collisionPolicy)
        => BuildPlanCore(templates, profiles, applyCurrentMissionOptions, missionDirectory, collisionPolicy, EmptyOutputNames);

    internal static IReadOnlyList<MissionVariantPlan> BuildNamedPlan(IReadOnlyList<PreparedMissionTemplate> templates,
        IReadOnlyList<ProfileMissionSnapshot> profiles, bool applyCurrentMissionOptions, string missionDirectory,
        MissionCollisionPolicy collisionPolicy, IReadOnlyDictionary<string, string> outputNames)
        => BuildPlanCore(templates, profiles, applyCurrentMissionOptions, missionDirectory, collisionPolicy, outputNames);

    private static IReadOnlyList<MissionVariantPlan> BuildPlanCore(IReadOnlyList<PreparedMissionTemplate> templates,
        IReadOnlyList<ProfileMissionSnapshot> profiles, bool applyCurrentMissionOptions, string missionDirectory,
        MissionCollisionPolicy collisionPolicy, IReadOnlyDictionary<string, string> outputNames)
    {
        if (templates.Count == 0 || profiles.Count > 5) throw new InvalidDataException("Choose missions and up to five saved profiles.");
        if (!Path.IsPathFullyQualified(missionDirectory)) throw new InvalidDataException("Choose a full Missions destination folder.");
        if (!Enum.IsDefined(collisionPolicy)) throw new InvalidDataException("Choose a supported file conflict action.");
        var directory = Path.GetFullPath(missionDirectory);
        var used = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var plans = new List<MissionVariantPlan>();
        foreach (var template in templates)
        {
            if (profiles.Count == 0)
                Add(template, null, applyCurrentMissionOptions ? MissionOutputMode.OptionsOnly : MissionOutputMode.Original);
            else
                foreach (var profile in profiles)
                {
                    if (string.IsNullOrWhiteSpace(profile.Name)) throw new InvalidDataException("Choose a named weather profile.");
                    profile.Settings.Validate();
                    Add(template, profile, MissionOutputMode.Profile);
                }
        }
        return Array.AsReadOnly(plans.ToArray());

        void Add(PreparedMissionTemplate template, ProfileMissionSnapshot? profile, MissionOutputMode mode)
        {
            var name = outputNames.TryGetValue(template.SourcePath, out var outputName) ? outputName : template.Name;
            if (profile is not null)
            {
                var tag = string.Concat(profile.Name.Trim().Select(c => Path.GetInvalidFileNameChars().Contains(c) || char.IsWhiteSpace(c) ? '_' : c)).Trim('_', '.');
                if (tag.Length == 0) throw new InvalidDataException("The profile needs a usable mission filename.");
                name = Path.GetFileNameWithoutExtension(name) + "_" + tag + ".miz";
            }
            name = WeatherExportNames.Normalize(name, template.SourcePath, directory, keepBoth: false);
            if (name.Length > 255) throw new InvalidDataException("The mission/profile filename is too long. Choose a shorter profile name.");
            var candidate = name;
            for (var number = 2; !used.Add(candidate); number++) candidate = WeatherExportNames.NumberedName(name, number);
            if (candidate.Length > 255) throw new InvalidDataException("The numbered mission filename is too long. Choose a shorter profile name.");
            plans.Add(new(template, Path.Combine(directory, candidate), mode, profile, collisionPolicy, applyCurrentMissionOptions));
        }
    }

    internal static string Install(MissionVariantPlan plan, MissionOptionsSettings? currentOptions,
        IReadOnlyDictionary<string, byte[]> configMembers, bool replaceExisting, CancellationToken token)
    {
        token.ThrowIfCancellationRequested();
        plan.WarehouseCopy?.SourceIdentity.RequireUnchanged();
        return InstallReviewed(plan, currentOptions, configMembers, replaceExisting, token);
    }

    // The batch caller has checked every reviewed identity once before any commit.
    internal static string InstallReviewed(MissionVariantPlan plan, MissionOptionsSettings? currentOptions,
        IReadOnlyDictionary<string, byte[]> configMembers, bool replaceExisting, CancellationToken token, PreparedMissionInput? preparedInput = null)
    {
        if (plan.Mode == MissionOutputMode.Original && plan.WarehouseCopy is null) return CopyOriginal(plan.Template, plan.OutputPath, replaceExisting, token, plan.ReviewedIdentity);
        if (plan.ApplyCurrentMissionOptions && currentOptions is null) throw new InvalidDataException("The reviewed Mission options snapshot is missing.");
        if (plan.Mode == MissionOutputMode.Profile && plan.Profile is null) throw new InvalidDataException("The reviewed weather profile is missing.");
        var stampedConfigs = new Dictionary<string, byte[]>(configMembers, StringComparer.Ordinal);
        foreach (var member in plan.Template.ConfigMembers)
            if (stampedConfigs.TryGetValue(member.Name, out var bytes) && MissionVersionStamp.Read(member.Bytes) is { } identity)
                stampedConfigs[member.Name] = MissionVersionStamp.Write(bytes, identity.Version, identity.Map);
        return WeatherMizService.ApplyPreparedWarehouse(plan.Template, plan.Profile?.Settings,
            plan.ApplyCurrentMissionOptions ? currentOptions : null, stampedConfigs, plan.OutputPath, replaceExisting, token, plan.ReviewedIdentity, plan.WarehouseCopy, preparedInput);
    }

    private static string CopyOriginal(PreparedMissionTemplate template, string outputPath, bool replaceExisting, CancellationToken token, MissionPathIdentity? reviewedIdentity)
    {
        token.ThrowIfCancellationRequested();
        if (!Path.IsPathFullyQualified(outputPath) || !Directory.Exists(Path.GetDirectoryName(outputPath)))
            throw new DirectoryNotFoundException("The reviewed mission destination folder is unavailable.");
        var target = Path.GetFullPath(outputPath);
        WeatherExportNames.Normalize(Path.GetFileName(target), template.SourcePath, Path.GetDirectoryName(target)!, false);
        return CopyVerifiedFile(template.SourcePath, template.Sha256, target, replaceExisting, token, reviewedIdentity);
    }

    internal static string CopyVerifiedFile(string sourcePath, string expectedSha256, string outputPath, bool replaceExisting,
        CancellationToken token, MissionPathIdentity? reviewedIdentity)
    {
        token.ThrowIfCancellationRequested();
        if (!Path.IsPathFullyQualified(outputPath) || !Directory.Exists(Path.GetDirectoryName(outputPath)))
            throw new DirectoryNotFoundException("The reviewed download destination folder is unavailable.");
        var target = Path.GetFullPath(outputPath);
        if (target.Equals(Path.GetFullPath(sourcePath), StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException("Choose an output path different from the prepared source.");
        using var source = new FileStream(sourcePath, FileMode.Open, FileAccess.Read, FileShare.Read);
        reviewedIdentity?.RequireUnchanged();
        using var reservation = replaceExisting ? null : new FileStream(target, FileMode.CreateNew, FileAccess.ReadWrite, FileShare.Read | FileShare.Delete);
        var publicationIdentity = reviewedIdentity is { Exists: false } && reservation is not null
            ? MissionPathIdentity.Capture(target, []) : reviewedIdentity;
        var committed = false;
        try
        {
            AtomicFile.WriteStaged(target, temporary =>
            {
                using (var output = new FileStream(temporary, FileMode.CreateNew, FileAccess.Write)) source.CopyTo(output);
                using (var check = File.OpenRead(temporary))
                    if (!Convert.ToHexString(SHA256.HashData(check)).Equals(expectedSha256, StringComparison.OrdinalIgnoreCase))
                        throw new InvalidDataException("The prepared download changed after inspection.");
                token.ThrowIfCancellationRequested();
                publicationIdentity?.RequireUnchanged(reservation);
                if (replaceExisting && File.Exists(target))
                    AtomicFile.Copy(target, Path.Combine(Path.GetDirectoryName(target)!, Path.GetFileNameWithoutExtension(target)
                        + ".mission-backup-" + Guid.NewGuid().ToString("N") + Path.GetExtension(target)));
                token.ThrowIfCancellationRequested();
            });
            committed = true;
            return target;
        }
        finally { if (!committed && reservation is not null && File.Exists(target) && new FileInfo(target).Length == 0) File.Delete(target); }
    }
}