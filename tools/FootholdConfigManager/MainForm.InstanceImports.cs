namespace FootholdConfigManager;

internal sealed partial class MainForm
{
    private sealed class InstanceImportPlan
    {
        public string Name { get; }
        public ConfigDocument Current { get; }
        public ConfigDocument Output { get; }
        public ConfigDocument? PreviousDefaults { get; }
        public MizMergePreview Preview { get; }
        public List<SelectableValueChoice> ValueChoices { get; }
        public List<SelectableValueChoice> TableChoices { get; }
        public List<SelectableValueChoice> Choices { get; }
        public InstanceImportPlan(string name, ConfigDocument current, ConfigDocument output,
            ConfigDocument? previousDefaults, MizMergePreview preview,
            List<SelectableValueChoice> valueChoices, List<SelectableValueChoice> tableChoices)
        {
            Name = name; Current = current; Output = output; PreviousDefaults = previousDefaults;
            Preview = preview; ValueChoices = valueChoices; TableChoices = tableChoices;
            Choices = valueChoices.Concat(tableChoices).ToList();
            foreach (var choice in Choices) choice.ImportPlan = this;
        }
    }

    private static InstanceImportPlan PrepareInstanceImport(ConfigDocument current, ConfigDocument incoming,
        ConfigDocument? previousDefaults, string name)
    {
        var preview = MergeCurrentConfigIntoNewConfig(current, incoming, previousDefaults);
        var values = preview.KeptValues.Select(item => new SelectableValueChoice(
            item.Key, item.CurrentValue, item.NewDefault, item.Entry.EffectiveDescription)).ToList();
        var tables = BuildKeptTableChoices(preview, "current table text", "new source table text");
        return new InstanceImportPlan(name, current, incoming, previousDefaults, preview, values, tables);
    }

    private static void ApplyInstanceImportChoices(InstanceImportPlan plan)
    {
        ApplyKeptTableChoices(plan.Output, plan.Preview, plan.TableChoices);
        ApplyKeptValueChoices(plan.Output, plan.Preview, plan.ValueChoices);
    }
    private sealed class InstanceImportScope
    {
        public InstanceImportPlan Current { get; }
        public bool AllInstances { get; set; }
        public int TargetCount { get; }
        public List<string> Skipped { get; } = new();
        private readonly ConfigDocument _cleanSource;
        public ConfigDocument CleanSource => _cleanSource;
        private readonly List<(string Name, string Path)> _targets;
        private List<InstanceImportPlan>? _allPlans;
        public InstanceImportScope(MainForm owner, InstanceImportPlan current, ConfigDocument cleanSource)
        {
            Current = current; _cleanSource = cleanSource;
            var fileName = System.IO.Path.GetFileName(current.Current.Path);
            _targets = owner._settings.ServerProfiles.Select(profile =>
                (Name: profile.Name, Path: ResolveMatchingCopyTargetPath(profile.ConfigPath, fileName)))
                .Where(target => !PathsEqual(target.Path, current.Current.Path))
                .DistinctBy(target => target.Path, StringComparer.OrdinalIgnoreCase).ToList();
            TargetCount = 1 + _targets.Count(target => File.Exists(target.Path));
        }
        public List<InstanceImportPlan> Plans
        {
            get
            {
                if (!AllInstances) return new List<InstanceImportPlan> { Current };
                if (_allPlans is not null) return _allPlans;
                _allPlans = new List<InstanceImportPlan> { Current };
                foreach (var target in _targets)
                {
                    try
                    {
                        if (!File.Exists(target.Path))
                        {
                            Skipped.Add(target.Name + ": matching config is missing.");
                            continue;
                        }
                        var current = ConfigDocument.Load(target.Path);
                        var currentErrors = current.ValidateForImport(new List<string>());
                        if (currentErrors.Count > 0) throw new InvalidOperationException(string.Join(Environment.NewLine, currentErrors.Take(8)));
                        var plan = PrepareInstanceImport(current, _cleanSource.CreateWorkingCopy(),
                            TryLoadStoredMizDefaultsForConfig(target.Path), target.Name);
                        var errors = plan.Output.ValidateForImport(plan.Preview.ImportWarnings);
                        if (errors.Count > 0) throw new InvalidOperationException(string.Join(Environment.NewLine, errors.Take(8)));
                        _allPlans.Add(plan);
                    }
                    catch (Exception ex) { Skipped.Add(target.Name + ": " + ex.Message); }
                }
                return _allPlans;
            }
        }
    }

    private sealed class InstanceImportResult
    {
        public List<InstanceImportPlan> Updated { get; } = new();
        public List<string> Warnings { get; } = new();
        public List<string> Failed { get; } = new();
    }

    private InstanceImportResult CommitInstanceImports(InstanceImportScope scope, string sourcePath,
        ExtractedMizConfig? extracted)
    {
        var plans = scope.Plans;
        var result = new InstanceImportResult();
        foreach (var plan in plans)
        {
            ApplyInstanceImportChoices(plan);
            var errors = plan.Output.ValidateForImport(plan.Preview.ImportWarnings);
            if (errors.Count > 0)
                throw new InvalidOperationException(plan.Name + ": " + string.Join(Environment.NewLine, errors.Take(8)));
        }

        foreach (var plan in plans)
        {
            try
            {
                StoreConfigBackup(plan.Current.Path, sourcePath, _settings.ServerProfiles,
                    ConfigBackupsDirectory, ConfigBackupsIndexPath, extracted is null ? "config" : "miz");
                plan.Output.SaveImportedTo(plan.Current.Path, plan.Preview.ImportWarnings);
            }
            catch (Exception ex)
            {
                result.Failed.Add(plan.Name + ": " + ex.Message);
                continue;
            }
            result.Updated.Add(plan);
            result.Warnings.AddRange(plan.Preview.ImportWarnings.Select(warning => plan.Name + ": " + warning));
            try
            {
                var markerWarning = PersistImportedBucketNewItems(plan.Current.Path, plan.Preview);
                if (markerWarning is not null) result.Warnings.Add(plan.Name + ": " + markerWarning);
                if (!TrySyncActivePresetFromLive(plan.Current.Path, out var presetName, out var presetError))
                    result.Warnings.Add(plan.Name + ": active preset " + presetName + " could not be updated: " + presetError);
            }
            catch (Exception ex)
            {
                result.Warnings.Add(plan.Name + ": config updated, but its review markers or preset could not be synchronized: " + ex.Message);
            }
            if (plan.Preview.DefaultedPlayerValues.Count > 0)
                result.Warnings.Add(plan.Name + ": unsupported current values use source defaults: " +
                    string.Join(", ", plan.Preview.DefaultedPlayerValues.Select(item => item.Key)));
        }

        if (result.Updated.Count > 0)
        {
            try
            {
                var targets = result.Updated.Select(plan => plan.Current.Path).ToList();
                if (extracted is not null)
                    StoreMizDefaults(sourcePath, extracted, targetConfigPaths: targets);
                else
                    StoreConfigDefaults(sourcePath, targets, scope.CleanSource);
            }
            catch (Exception ex)
            {
                result.Warnings.Add("Configs were updated, but clean source defaults could not be stored: " + ex.Message);
            }
        }
        return result;
    }

    private void CompleteInstanceImports(InstanceImportScope scope, string sourcePath, ExtractedMizConfig? extracted)
    {
        var result = CommitInstanceImports(scope, sourcePath, extracted);
        if (result.Updated.Contains(scope.Current))
        {
            UpdateSelectedInstanceConfigPath(scope.Current.Current.Path);
            LoadConfig(scope.Current.Current.Path);
            ApplyImportedNewMarkers(CaptureImportedNewMarkers(scope.Current.Preview));
        }
        var lines = new List<string>
        {
            "Updated " + result.Updated.Count + " instance(s): " + string.Join(", ", result.Updated.Select(plan => plan.Name)),
            "Each updated instance kept its own selected settings and has its own pre-update backup."
        };
        if (scope.Skipped.Count > 0) lines.Add("Skipped:" + Environment.NewLine + string.Join(Environment.NewLine, scope.Skipped));
        if (result.Failed.Count > 0) lines.Add("Not updated:" + Environment.NewLine + string.Join(Environment.NewLine, result.Failed));
        if (result.Warnings.Count > 0) lines.Add("Warnings:" + Environment.NewLine + string.Join(Environment.NewLine, result.Warnings));
        SetStatus("Updated " + result.Updated.Count + " instances from " + Path.GetFileName(sourcePath) + ".");
        MessageBox.Show(this, string.Join(Environment.NewLine + Environment.NewLine, lines),
            "Instance update results", MessageBoxButtons.OK,
            result.Failed.Count + result.Warnings.Count > 0 ? MessageBoxIcon.Warning : MessageBoxIcon.Information);
    }
}
