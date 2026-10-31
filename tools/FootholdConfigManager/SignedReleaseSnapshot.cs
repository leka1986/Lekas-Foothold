#if !FOOTHOLD_USER_BUILD
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

namespace FootholdConfigManager;

internal sealed partial class SignedReleaseService
{
    // Exact product input names: new files do not silently become release inputs.
    private static readonly string[] SourceInputs = """
        AppMode.cs AtomicFile.cs BoundedLruSet.cs ConfigConditions.cs ConfigDocument.cs
        ConfigDocument.GuiCommentFacts.cs ConfigDocument.ManagedLists.cs ConfigDocument.RequiredConditions.cs
        ConfigDocument.RequiredValues.cs ConfigDocument.TupleChoices.cs ConfigLoadCandidateSelector.cs
        ConfigSearchIndex.cs ControlTreeDisposer.cs DcsWeatherCatalog.cs DebouncedSearchQuery.cs
        DuplicateTableRepair.cs ExperimentBootstrap.cs GitHubUpdateChecker.cs GuiMetadata.cs LoadingScreenController.cs
        LoadingScreenForm.cs LuaSyntaxValidator.cs LuaSyntaxValidatorRegressionSelfTest.cs MainForm.CategoryNavigation.cs
        MainForm.cs MainForm.DropdownTypography.cs MainForm.IncrementalRefresh.cs MainForm.InputChrome.cs MainForm.InstanceImports.cs
        MainForm.LinkedTable.cs MainForm.LoadingOperations.cs MainForm.ManagedLists.cs MainForm.NewVisibility.cs
        MainForm.OptionsChanged.cs MainForm.PerformanceProbe.cs MainForm.PopupScrollbars.cs MainForm.PreviewAppearance.cs
        MainForm.PreviewStartup.cs MainForm.RequiredAircraft.cs MainForm.RequiredValues.cs MainForm.Scrollbars.cs
        MainForm.SignedRelease.cs MainForm.ResponsiveLayout.cs MainForm.StartupPreparation.cs MainForm.TableSizing.cs MainForm.TemplateWorkspace.cs
        MainForm.TupleChoices.cs MainForm.Updates.cs MainForm.Weather.cs ManagerBuildInfo.cs ManagerSelfUpdater.cs
        ManagerStartupContext.cs MissionDateTimeSettings.cs MissionOptions.cs MissionWeather.cs PendingNewItemStore.cs
        PresetStore.cs Program.cs RadarLoadingForm.cs RuntimeSettings.cs SingleInstanceCoordinator.cs SplashPictureSequence.cs
        StabilityRegressionSelfTest.cs StringListCatalogStore.cs UiViewGeneration.cs UpdateNotificationStore.cs UserExeExporter.cs
        WeatherArtwork.cs WeatherAssemblyInfo.cs WeatherDateTimeInput.Chrome.cs WeatherDateTimeInput.TextEntry.cs
        WeatherExportNames.cs WeatherLua.cs WeatherMizService.cs WeatherPreviewControls.cs WeatherProfileStore.cs
        WeatherScrollHost.cs WeatherSettings.cs WeatherWindCoupling.cs WeatherWindDial.cs WeatherWindow.Bindings.cs
        WeatherWindow.Clouds.cs WeatherWindow.Controls.cs WeatherWindow.cs WeatherWindow.Export.cs WeatherWindow.Focus.cs
        WeatherWindow.Import.cs WeatherWindow.MissionOptions.cs WeatherWindow.Options.cs WeatherWindow.Time.cs WeatherWindow.Visuals.cs
        WeatherWindow.Zoom.cs WheelSafeControls.cs
        SignedReleaseContracts.cs SignedReleaseCommands.cs SignedReleaseService.cs SignedReleaseSnapshot.cs SignedReleaseMonitor.cs SignedReleaseDialog.cs
        FootholdConfigManager.csproj packages.lock.json MainForm.resx WheelSafeControls.resx ThirdPartyNotices.txt
        FootholdConfigManager.ico foothold-manager-icon.png FootholdConfigManager-icon.png apache-sunset-source.jpg
        apache-action-source.png carrier-launch-source.jpg BuildSignedRelease.ps1
        """.Split((char[]?)null, StringSplitOptions.RemoveEmptyEntries);

    internal static IReadOnlyDictionary<string, byte[]> Snapshot(SignedReleaseRequest request, Version version, string directory)
    {
        var metadata = JsonSerializer.Deserialize<GuiMetadataStore>(request.MetadataJson)
            ?? throw new InvalidDataException("Designer metadata is empty.");
        metadata.FooterVersion = VersionText(version);
        var source = Path.Combine(directory, "source");
        var selectedSource = Path.Combine(directory, "input", "source");
        var selectedConfigs = Path.Combine(directory, "input", "test-configs");
        Directory.CreateDirectory(selectedSource);
        Directory.CreateDirectory(selectedConfigs);
        var files = new Dictionary<string, byte[]>(StringComparer.Ordinal);
        foreach (var name in SourceInputs)
        {
            var path = Path.Combine(request.ProjectDirectory, name);
            // Some approved partials are optional in earlier local admin snapshots.
            if (!File.Exists(path)) continue;
            AddInput(files, ManagerPath + name, path);
            File.WriteAllBytes(Path.Combine(selectedSource, name), files[ManagerPath + name]);
        }
        foreach (var name in RuntimeSettings.SupportedConfigFileNames)
        {
            var key = "tools/test-configs/" + name;
            AddInput(files, key, Path.Combine(request.ProjectDirectory, "..", "test-configs", name));
            File.WriteAllBytes(Path.Combine(selectedConfigs, name), files[key]);
        }
        UserExeExporter.PrepareBuildSource(selectedSource, source, metadata.ToJson(), "user", version);
        foreach (var name in new[] { "FootholdConfigManager.csproj", "BuildSignedRelease.ps1", "packages.lock.json" })
            if (!files.ContainsKey(ManagerPath + name)) throw new InvalidDataException("Required Manager release input is missing: " + name);

        foreach (var name in new[] { "EmbeddedGuiMetadata.json", "EmbeddedBuildMode.txt", "ManagerVersion.txt" })
        {
            AddInput(files, ManagerPath + name, Path.Combine(source, name));
            files.Add(ManagerPath + "release-inputs/" + name, (byte[])files[ManagerPath + name].Clone());
        }
        var manifest = files.Select(file => new { path = file.Key, sha256 = Convert.ToHexString(SHA256.HashData(file.Value)) }).ToArray();
        files.Add(ManagerPath + "release-inputs/source-manifest.json", Encoding.UTF8.GetBytes(JsonSerializer.Serialize(manifest)));
        return files;
    }

    private static void AddInput(Dictionary<string, byte[]> files, string name, string path)
    {
        var info = new FileInfo(path);
        if ((info.Attributes & FileAttributes.ReparsePoint) != 0 || info.Length > 16 * 1024 * 1024)
            throw new InvalidDataException("Release inputs must be regular, bounded source/resource files: " + name);
        files.Add(name, File.ReadAllBytes(path));
    }
}
#endif
