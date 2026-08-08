namespace FootholdConfigManager;

internal static class StabilityRegressionSelfTest
{
    internal static int Run()
    {
        var tempDirectory = Path.Combine(
            Path.GetTempPath(),
            "FootholdConfigManager-StabilitySelfTest-" + Guid.NewGuid().ToString("N"));
        try
        {
            Directory.CreateDirectory(tempDirectory);
            VerifyAtomicWritePreservesExistingFile(tempDirectory);
            VerifyAtomicCopyCreatesAndPreservesFiles(tempDirectory);
            VerifyAtomicStagedWritePreservesExistingFile(tempDirectory);
            VerifyFailedConfigSaveKeepsScalarDirty(tempDirectory);
            VerifyFailedConfigSaveKeepsStageRowDirty(tempDirectory);
            VerifyFailedConfigSaveKeepsStructuralEditDirty(tempDirectory);
            VerifySnapshotSavePreservesDocumentState(tempDirectory);
            VerifyMultilineExpansionKeepsLaterEntryAligned(tempDirectory);
            VerifyMultilineShrinkKeepsCommentedListItemAligned(tempDirectory);
            VerifyRuntimeSettingsSaveIsAtomic(tempDirectory);
            VerifyGuiMetadataSaveIsAtomic(tempDirectory);
            VerifyStringListCatalogRetriesFailedSave(tempDirectory);
            VerifyLegacyPresetSaveIsAtomic(tempDirectory);
            VerifyStoredPresetConfigSaveIsAtomic(tempDirectory);
            VerifyStoredPresetMetadataSaveIsAtomic(tempDirectory);
            VerifyStoredMizDefaultsUseUniqueIds(tempDirectory);
            VerifyStoredMizDefaultsPreservePriorCommitOnIndexFailure(tempDirectory);
            VerifyStoredMizDefaultsRemovalCommitsIndexFirst(tempDirectory);
            VerifyStoredMizDefaultsNormalizationDefersCleanup(tempDirectory);
            VerifyConfigLoadCandidateFallback(tempDirectory);
            VerifyRememberedConfigCandidateOrder(tempDirectory);
            VerifyBoundedCategoryLruPolicy();
            VerifyThirdPartyNoticesResource();
            VerifyMalformedQuotedScalarRemainsInvalid(tempDirectory);
            VerifyEscapedQuoteScalarRemainsValid(tempDirectory);
            LuaSyntaxValidatorRegressionSelfTest.Run(tempDirectory);
            VerifyControlTreeDisposerClearsToolTips();
            VerifyUiViewGenerationRejectsStaleCallbacks();
            VerifyConfigSearchIndexSemantics();
            VerifyDebouncedSearchQueryKeepsOnlyLatestInput();
            Console.WriteLine("Stability regression self-test passed.");
            return 0;
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine("Stability regression self-test failed: " + ex.Message);
            return 1;
        }
        finally
        {
            try
            {
                if (Directory.Exists(tempDirectory))
                {
                    Directory.Delete(tempDirectory, recursive: true);
                }
            }
            catch
            {
                // Best-effort test cleanup only.
            }
        }
    }

    private static void VerifyAtomicWritePreservesExistingFile(string tempDirectory)
    {
        var destinationPath = Path.Combine(tempDirectory, "atomic-existing.txt");
        File.WriteAllText(destinationPath, "old");

        var failedAsExpected = false;
        using (File.Open(destinationPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
        {
            try
            {
                AtomicFile.WriteUtf8Text(destinationPath, "new");
            }
            catch (Exception ex) when (ex is IOException or UnauthorizedAccessException)
            {
                failedAsExpected = true;
            }
        }

        RequireStability(failedAsExpected, "Atomic write unexpectedly replaced a locked destination.");
        RequireStability(File.ReadAllText(destinationPath) == "old",
            "Atomic write changed the destination after a failed commit.");
        RequireStability(!Directory.EnumerateFiles(tempDirectory, "*.tmp-*").Any(),
            "Atomic write left a staged file after a failed commit.");
    }

    private static void VerifyAtomicCopyCreatesAndPreservesFiles(string tempDirectory)
    {
        var sourcePath = Path.Combine(tempDirectory, "atomic-copy-source.txt");
        var destinationPath = Path.Combine(tempDirectory, "atomic-copy-destination.txt");
        File.WriteAllText(sourcePath, "first");

        AtomicFile.Copy(sourcePath, destinationPath);
        RequireStability(File.ReadAllText(destinationPath) == "first",
            "Atomic copy did not create the destination.");

        File.WriteAllText(sourcePath, "second");
        var failedAsExpected = false;
        using (File.Open(destinationPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
        {
            try
            {
                AtomicFile.Copy(sourcePath, destinationPath);
            }
            catch (Exception ex) when (ex is IOException or UnauthorizedAccessException)
            {
                failedAsExpected = true;
            }
        }

        RequireStability(failedAsExpected, "Atomic copy unexpectedly replaced a locked destination.");
        RequireStability(File.ReadAllText(destinationPath) == "first",
            "Atomic copy changed the destination after a failed commit.");
        RequireStability(!Directory.EnumerateFiles(tempDirectory, "*.tmp-*").Any(),
            "Atomic copy left a staged file after a failed commit.");
    }

    private static void VerifyAtomicStagedWritePreservesExistingFile(string tempDirectory)
    {
        var destinationPath = Path.Combine(tempDirectory, "atomic-staged.txt");
        File.WriteAllText(destinationPath, "old");

        var failedAsExpected = false;
        using (File.Open(destinationPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
        {
            try
            {
                AtomicFile.WriteStaged(
                    destinationPath,
                    temporaryPath => File.WriteAllText(temporaryPath, "new"));
            }
            catch (Exception ex) when (ex is IOException or UnauthorizedAccessException)
            {
                failedAsExpected = true;
            }
        }

        RequireStability(failedAsExpected, "Staged write unexpectedly replaced a locked destination.");
        RequireStability(File.ReadAllText(destinationPath) == "old",
            "Staged write changed the destination after a failed commit.");
        RequireStability(!Directory.EnumerateFiles(tempDirectory, "*.tmp-*").Any(),
            "Staged write left a temporary file after a failed commit.");

        AtomicFile.WriteStaged(
            destinationPath,
            temporaryPath => File.WriteAllText(temporaryPath, "new"));
        RequireStability(File.ReadAllText(destinationPath) == "new",
            "Staged write retry did not replace the destination.");
    }

    private static void VerifyFailedConfigSaveKeepsScalarDirty(string tempDirectory)
    {
        var configPath = Path.Combine(tempDirectory, "locked-scalar.lua");
        const string originalText = "-- Test\nScalarValue = 1\n";
        File.WriteAllText(configPath, originalText, new System.Text.UTF8Encoding(false));
        var document = ConfigDocument.Load(configPath);
        var entry = document.Entries.Single(candidate => candidate.DisplayKey == "ScalarValue");
        entry.ValueText = "2";

        var failedAsExpected = false;
        using (File.Open(configPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
        {
            try
            {
                document.Save();
            }
            catch (Exception ex) when (ex is IOException or UnauthorizedAccessException)
            {
                failedAsExpected = true;
            }
        }

        RequireStability(failedAsExpected, "Config save unexpectedly replaced a locked destination.");
        RequireStability(File.ReadAllText(configPath) == originalText,
            "Failed config save changed the destination.");
        RequireStability(entry.IsChanged && document.HasUnsavedChanges,
            "Failed config save accepted the scalar edit instead of keeping it dirty.");

        document.Save();
        RequireStability(File.ReadAllText(configPath).Contains("ScalarValue = 2", StringComparison.Ordinal),
            "Retry after a failed config save did not write the scalar edit.");
        RequireStability(!document.HasUnsavedChanges,
            "Successful retry did not clear the saved scalar edit.");
    }

    private static void VerifyFailedConfigSaveKeepsStageRowDirty(string tempDirectory)
    {
        var configPath = Path.Combine(tempDirectory, "locked-stage.lua");
        const string originalText = """
            -- Test
            RewardStages = {
                easy = {
                    { player = 1, amount = 2 },
                },
            }
            """;
        File.WriteAllText(configPath, originalText, new System.Text.UTF8Encoding(false));
        var document = ConfigDocument.Load(configPath);
        var row = document.StageTables.Single(candidate => candidate.Key == "RewardStages").Rows.Single();
        row.Amount = 3;

        var failedAsExpected = false;
        using (File.Open(configPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
        {
            try
            {
                document.Save();
            }
            catch (Exception ex) when (ex is IOException or UnauthorizedAccessException)
            {
                failedAsExpected = true;
            }
        }

        RequireStability(failedAsExpected, "Stage save unexpectedly replaced a locked destination.");
        RequireStability(File.ReadAllText(configPath) == originalText,
            "Failed stage save changed the destination.");
        RequireStability(row.IsChanged && document.HasUnsavedChanges,
            "Failed stage save accepted the row edit instead of keeping it dirty.");

        document.Save();
        RequireStability(ReferenceEquals(row,
                document.StageTables.Single(candidate => candidate.Key == "RewardStages").Rows.Single()),
            "Successful stage save replaced the parsed row object.");
        RequireStability(!row.IsChanged && !document.HasUnsavedChanges,
            "Successful stage retry did not accept the saved row value.");
    }

    private static void VerifyFailedConfigSaveKeepsStructuralEditDirty(string tempDirectory)
    {
        var configPath = Path.Combine(tempDirectory, "locked-structural.lua");
        const string originalText = """
            -- Test
            allowedPlanes = {
                "Active",
            }
            """;
        File.WriteAllText(configPath, originalText, new System.Text.UTF8Encoding(false));
        var document = ConfigDocument.Load(configPath);
        var table = document.StringListTables.Single(candidate => candidate.Key == "allowedPlanes");
        document.AddStringListItem(table, "Added");

        var failedAsExpected = false;
        using (File.Open(configPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
        {
            try
            {
                document.Save();
            }
            catch (Exception ex) when (ex is IOException or UnauthorizedAccessException)
            {
                failedAsExpected = true;
            }
        }

        RequireStability(failedAsExpected, "Structural save unexpectedly replaced a locked destination.");
        RequireStability(File.ReadAllText(configPath) == originalText,
            "Failed structural save changed the destination.");
        RequireStability(document.HasUnsavedChanges,
            "Failed structural save cleared the structural dirty state.");

        document.Save();
        RequireStability(File.ReadAllText(configPath).Contains("\"Added\"", StringComparison.Ordinal),
            "Retry after a failed structural save did not write the added value.");
    }

    private static void VerifySnapshotSavePreservesDocumentState(string tempDirectory)
    {
        var configPath = Path.Combine(tempDirectory, "snapshot-source.lua");
        var snapshotPath = Path.Combine(tempDirectory, "snapshot-target.lua");
        File.WriteAllText(configPath, "ScalarValue = 1\n", new System.Text.UTF8Encoding(false));
        File.WriteAllText(snapshotPath, "old snapshot", new System.Text.UTF8Encoding(false));
        var document = ConfigDocument.Load(configPath);
        document.Entries.Single(candidate => candidate.DisplayKey == "ScalarValue").ValueText = "2";

        var failedAsExpected = false;
        using (File.Open(snapshotPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
        {
            try
            {
                document.SaveSnapshotTo(snapshotPath);
            }
            catch (Exception ex) when (ex is IOException or UnauthorizedAccessException)
            {
                failedAsExpected = true;
            }
        }

        RequireStability(failedAsExpected, "Snapshot save unexpectedly replaced a locked destination.");
        RequireStability(File.ReadAllText(snapshotPath) == "old snapshot",
            "Failed snapshot save changed the destination.");
        RequireStability(document.HasUnsavedChanges,
            "Snapshot save changed the active document's dirty state.");

        document.SaveSnapshotTo(snapshotPath);
        RequireStability(File.ReadAllText(snapshotPath).Contains("ScalarValue = 2", StringComparison.Ordinal),
            "Snapshot save did not write the rendered edit.");
        RequireStability(document.HasUnsavedChanges,
            "Successful snapshot save accepted the active document edit.");
    }

    private static void VerifyMultilineExpansionKeepsLaterEntryAligned(string tempDirectory)
    {
        var configPath = Path.Combine(tempDirectory, "multiline-expand.lua");
        File.WriteAllText(configPath, """
            -- Test
            LongValue =
            [[first
            second]]
            LaterValue = 1
            """, new System.Text.UTF8Encoding(false));
        var document = ConfigDocument.Load(configPath);
        var longEntry = document.Entries.Single(candidate => candidate.DisplayKey == "LongValue");
        var laterEntry = document.Entries.Single(candidate => candidate.DisplayKey == "LaterValue");
        var originalLaterLine = laterEntry.LineIndex;

        longEntry.ValueText = "first\nmiddle\nmore\nsecond";
        document.Save();

        RequireStability(ReferenceEquals(longEntry,
                document.Entries.Single(candidate => candidate.DisplayKey == "LongValue")),
            "Multiline save replaced the parsed entry object.");
        RequireStability(laterEntry.LineIndex > originalLaterLine,
            "Multiline expansion did not shift the later entry index.");

        laterEntry.ValueText = "2";
        document.Save();
        var savedText = File.ReadAllText(configPath);
        RequireStability(savedText.Contains("LaterValue = 2", StringComparison.Ordinal),
            "A scalar edit after multiline expansion did not reach the later setting.");
        RequireStability(ConfigDocument.Load(configPath).Validate().Count == 0,
            "A scalar edit after multiline expansion produced invalid Lua.");
    }

    private static void VerifyMultilineShrinkKeepsCommentedListItemAligned(string tempDirectory)
    {
        var configPath = Path.Combine(tempDirectory, "multiline-shrink.lua");
        File.WriteAllText(configPath, """
            -- Test
            LongValue =
            [[one
            two
            three
            four]]
            allowedPlanes = {
                "Active",
                --"Inactive",
            }
            """, new System.Text.UTF8Encoding(false));
        var document = ConfigDocument.Load(configPath);
        var longEntry = document.Entries.Single(candidate => candidate.DisplayKey == "LongValue");
        var table = document.StringListTables.Single(candidate => candidate.Key == "allowedPlanes");
        var commentedItem = table.CommentedItems.Single(candidate => candidate.Value == "Inactive");

        longEntry.ValueText = "one";
        document.Save();

        var savedLines = File.ReadAllLines(configPath);
        var actualCommentedLine = Array.FindIndex(
            savedLines,
            line => line.Contains("Inactive", StringComparison.Ordinal));
        RequireStability(commentedItem.LineIndex == actualCommentedLine,
            "Multiline shrink did not shift the commented string-list item index.");
        RequireStability(ReferenceEquals(commentedItem,
                table.CommentedItems.Single(candidate => candidate.Value == "Inactive")),
            "Multiline save replaced the commented string-list item object.");

        document.ActivateStringListValue(table, "Inactive");
        document.Save();
        RequireStability(File.ReadAllText(configPath).Contains("\"Inactive\"", StringComparison.Ordinal) &&
                         !File.ReadAllText(configPath).Contains("--\"Inactive\"", StringComparison.Ordinal),
            "The commented string-list value could not be activated after multiline shrink.");
    }

    private static void VerifyRuntimeSettingsSaveIsAtomic(string tempDirectory)
    {
        var settingsPath = Path.Combine(tempDirectory, "settings.json");
        File.WriteAllText(settingsPath, "old settings", new System.Text.UTF8Encoding(false));
        var settings = new RuntimeSettings { UiZoomPercent = 125 };

        var failedAsExpected = false;
        using (File.Open(settingsPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
        {
            try
            {
                settings.SaveTo(settingsPath);
            }
            catch (Exception ex) when (ex is IOException or UnauthorizedAccessException)
            {
                failedAsExpected = true;
            }
        }

        RequireStability(failedAsExpected, "Runtime settings unexpectedly replaced a locked destination.");
        RequireStability(File.ReadAllText(settingsPath) == "old settings",
            "Failed runtime-settings save changed the destination.");

        settings.SaveTo(settingsPath);
        RequireStability(File.ReadAllText(settingsPath).Contains("\"UiZoomPercent\": 125", StringComparison.Ordinal),
            "Runtime settings retry did not save the current values.");
    }

    private static void VerifyGuiMetadataSaveIsAtomic(string tempDirectory)
    {
        var metadataPath = Path.Combine(tempDirectory, "metadata.json");
        File.WriteAllText(metadataPath, "old metadata", new System.Text.UTF8Encoding(false));
        var metadata = new GuiMetadataStore { FooterVersion = "test-version" };

        var failedAsExpected = false;
        using (File.Open(metadataPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
        {
            try
            {
                metadata.SaveTo(metadataPath);
            }
            catch (Exception ex) when (ex is IOException or UnauthorizedAccessException)
            {
                failedAsExpected = true;
            }
        }

        RequireStability(failedAsExpected, "GUI metadata unexpectedly replaced a locked destination.");
        RequireStability(File.ReadAllText(metadataPath) == "old metadata",
            "Failed GUI-metadata save changed the destination.");

        metadata.SaveTo(metadataPath);
        RequireStability(File.ReadAllText(metadataPath).Contains("test-version", StringComparison.Ordinal),
            "GUI metadata retry did not save the current values.");
    }

    private static void VerifyStringListCatalogRetriesFailedSave(string tempDirectory)
    {
        var configPath = Path.Combine(tempDirectory, RuntimeSettings.DefaultConfigFileName);
        var catalogPath = Path.Combine(tempDirectory, "catalog.json");
        File.WriteAllText(configPath, """
            allowedPlanes = {
                "A-10C_2",
            }
            """, new System.Text.UTF8Encoding(false));
        File.WriteAllText(catalogPath, "old catalog", new System.Text.UTF8Encoding(false));
        var document = ConfigDocument.Load(configPath);
        var catalog = new StringListCatalogStore();
        RequireStability(catalog.RefreshFrom(document),
            "New string-list catalog did not detect the config values.");

        var failedAsExpected = false;
        using (File.Open(catalogPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
        {
            try
            {
                catalog.SaveTo(catalogPath);
            }
            catch (Exception ex) when (ex is IOException or UnauthorizedAccessException)
            {
                failedAsExpected = true;
            }
        }

        RequireStability(failedAsExpected, "String-list catalog unexpectedly replaced a locked destination.");
        RequireStability(File.ReadAllText(catalogPath) == "old catalog",
            "Failed string-list catalog save changed the destination.");
        RequireStability(catalog.RefreshFrom(document),
            "Failed string-list catalog save was not marked for retry.");

        catalog.SaveTo(catalogPath);
        RequireStability(File.ReadAllText(catalogPath).Contains("A-10C_2", StringComparison.Ordinal),
            "String-list catalog retry did not save the current values.");
        RequireStability(!catalog.RefreshFrom(document),
            "Successful string-list catalog retry remained marked for save.");
    }

    private static void VerifyLegacyPresetSaveIsAtomic(string tempDirectory)
    {
        var presetPath = Path.Combine(tempDirectory, "legacy-preset.json");
        File.WriteAllText(presetPath, "old preset", new System.Text.UTF8Encoding(false));
        var values = new Dictionary<string, string>(StringComparer.Ordinal)
        {
            ["ScalarValue"] = "2"
        };

        var failedAsExpected = false;
        using (File.Open(presetPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
        {
            try
            {
                PresetStore.SaveLegacyValuesTo(presetPath, values);
            }
            catch (Exception ex) when (ex is IOException or UnauthorizedAccessException)
            {
                failedAsExpected = true;
            }
        }

        RequireStability(failedAsExpected, "Legacy preset unexpectedly replaced a locked destination.");
        RequireStability(File.ReadAllText(presetPath) == "old preset",
            "Failed legacy-preset save changed the destination.");

        PresetStore.SaveLegacyValuesTo(presetPath, values);
        RequireStability(File.ReadAllText(presetPath).Contains("ScalarValue", StringComparison.Ordinal),
            "Legacy preset retry did not save the current values.");
    }

    private static void VerifyStoredPresetConfigSaveIsAtomic(string tempDirectory)
    {
        var presetDirectory = Path.Combine(tempDirectory, "stored-preset");
        Directory.CreateDirectory(presetDirectory);
        var configPath = Path.Combine(presetDirectory, RuntimeSettings.DefaultConfigFileName);
        File.WriteAllText(configPath, "old config", new System.Text.UTF8Encoding(false));
        var originalUpdatedAt = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Local);
        var preset = new StoredConfigPreset
        {
            Id = "test-preset",
            Name = "Test",
            ConfigFileName = RuntimeSettings.DefaultConfigFileName,
            DirectoryPath = presetDirectory,
            ConfigPath = configPath,
            MetadataPath = Path.Combine(presetDirectory, "preset.json"),
            CreatedAt = originalUpdatedAt,
            UpdatedAt = originalUpdatedAt
        };

        var failedAsExpected = false;
        using (File.Open(configPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
        {
            try
            {
                PresetStore.WriteConfig(
                    preset,
                    temporaryPath => File.WriteAllText(temporaryPath, "new config"),
                    updateTimestamp: true);
            }
            catch (Exception ex) when (ex is IOException or UnauthorizedAccessException)
            {
                failedAsExpected = true;
            }
        }

        RequireStability(failedAsExpected, "Stored preset config unexpectedly replaced a locked destination.");
        RequireStability(File.ReadAllText(configPath) == "old config",
            "Failed stored-preset config save changed the destination.");
        RequireStability(preset.UpdatedAt == originalUpdatedAt,
            "Failed stored-preset config save changed its timestamp.");
        RequireStability(!Directory.EnumerateFiles(presetDirectory, "*.tmp-*").Any(),
            "Failed stored-preset config save left a temporary file.");

        PresetStore.WriteConfig(
            preset,
            temporaryPath => File.WriteAllText(temporaryPath, "new config"),
            updateTimestamp: true);
        RequireStability(File.ReadAllText(configPath) == "new config",
            "Stored-preset config retry did not replace the destination.");
        RequireStability(preset.UpdatedAt > originalUpdatedAt,
            "Successful stored-preset config retry did not update its timestamp.");
    }

    private static void VerifyStoredPresetMetadataSaveIsAtomic(string tempDirectory)
    {
        var presetDirectory = Path.Combine(tempDirectory, "stored-preset-metadata");
        Directory.CreateDirectory(presetDirectory);
        var metadataPath = Path.Combine(presetDirectory, "preset.json");
        File.WriteAllText(metadataPath, "old metadata", new System.Text.UTF8Encoding(false));
        var preset = new StoredConfigPreset
        {
            Id = "metadata-test",
            Name = "Metadata Test",
            ConfigFileName = RuntimeSettings.DefaultConfigFileName,
            DirectoryPath = presetDirectory,
            ConfigPath = Path.Combine(presetDirectory, RuntimeSettings.DefaultConfigFileName),
            MetadataPath = metadataPath,
            CreatedAt = DateTime.Now,
            UpdatedAt = DateTime.Now
        };

        var failedAsExpected = false;
        using (File.Open(metadataPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
        {
            try
            {
                PresetStore.SaveMetadata(preset);
            }
            catch (Exception ex) when (ex is IOException or UnauthorizedAccessException)
            {
                failedAsExpected = true;
            }
        }

        RequireStability(failedAsExpected, "Stored preset metadata unexpectedly replaced a locked destination.");
        RequireStability(File.ReadAllText(metadataPath) == "old metadata",
            "Failed stored-preset metadata save changed the destination.");
        RequireStability(!Directory.EnumerateFiles(presetDirectory, "*.tmp-*").Any(),
            "Failed stored-preset metadata save left a temporary file.");

        PresetStore.SaveMetadata(preset);
        RequireStability(File.ReadAllText(metadataPath).Contains("Metadata Test", StringComparison.Ordinal),
            "Stored-preset metadata retry did not replace the destination.");
    }

    private static void VerifyStoredMizDefaultsUseUniqueIds(string tempDirectory)
    {
        var storageDirectory = Path.Combine(tempDirectory, "miz-defaults-unique");
        var extractedPath = Path.Combine(tempDirectory, "extracted-defaults.lua");
        var mizPath = Path.Combine(tempDirectory, "Mission.miz");
        var storedAt = new DateTime(2026, 8, 3, 12, 0, 0, 123, DateTimeKind.Local);
        File.WriteAllText(extractedPath, "Value = 1\n", new System.Text.UTF8Encoding(false));
        var extracted = new MainForm.ExtractedMizConfig(extractedPath, RuntimeSettings.DefaultConfigFileName);

        var first = MainForm.StoreMizDefaults(
            mizPath,
            extracted,
            storedDefaultsDirectory: storageDirectory,
            storedAtOverride: storedAt);
        File.WriteAllText(extractedPath, "Value = 2\n", new System.Text.UTF8Encoding(false));
        var second = MainForm.StoreMizDefaults(
            mizPath,
            extracted,
            storedDefaultsDirectory: storageDirectory,
            storedAtOverride: storedAt);

        RequireStability(!first.Id.Equals(second.Id, StringComparison.OrdinalIgnoreCase),
            "Stored MIZ defaults reused an ID at the same timestamp.");
        RequireStability(File.Exists(second.ConfigPath) &&
                         File.ReadAllText(second.ConfigPath).Contains("Value = 2", StringComparison.Ordinal),
            "The second stored MIZ defaults did not retain its own config file.");
        RequireStability(!Directory.EnumerateFiles(storageDirectory, "*.tmp-*").Any(),
            "Stored MIZ defaults left a temporary file after successful replacement.");
    }

    private static void VerifyStoredMizDefaultsPreservePriorCommitOnIndexFailure(string tempDirectory)
    {
        var storageDirectory = Path.Combine(tempDirectory, "miz-defaults-index-failure");
        var extractedPath = Path.Combine(tempDirectory, "extracted-index-failure.lua");
        var mizPath = Path.Combine(tempDirectory, "Index Failure Mission.miz");
        File.WriteAllText(extractedPath, "Value = 1\n", new System.Text.UTF8Encoding(false));
        var extracted = new MainForm.ExtractedMizConfig(extractedPath, RuntimeSettings.DefaultConfigFileName);
        var first = MainForm.StoreMizDefaults(
            mizPath,
            extracted,
            storedDefaultsDirectory: storageDirectory,
            storedAtOverride: new DateTime(2026, 8, 3, 12, 0, 0, 100, DateTimeKind.Local));
        var indexPath = Path.Combine(storageDirectory, "index.json");
        var committedIndexText = File.ReadAllText(indexPath);
        File.WriteAllText(extractedPath, "Value = 2\n", new System.Text.UTF8Encoding(false));

        var failedAsExpected = false;
        using (File.Open(indexPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
        {
            try
            {
                MainForm.StoreMizDefaults(
                    mizPath,
                    extracted,
                    storedDefaultsDirectory: storageDirectory,
                    storedAtOverride: new DateTime(2026, 8, 3, 12, 0, 0, 200, DateTimeKind.Local));
            }
            catch (Exception ex) when (ex is IOException or UnauthorizedAccessException)
            {
                failedAsExpected = true;
            }
        }

        RequireStability(failedAsExpected, "Stored-default index unexpectedly committed while locked.");
        RequireStability(File.ReadAllText(indexPath) == committedIndexText,
            "Failed stored-default index commit changed the prior index.");
        RequireStability(File.Exists(first.ConfigPath) &&
                         File.ReadAllText(first.ConfigPath).Contains("Value = 1", StringComparison.Ordinal),
            "Failed stored-default index commit deleted the prior config.");
        RequireStability(Directory.EnumerateFiles(storageDirectory, "*.lua").Count() == 1,
            "Failed stored-default index commit left an unindexed config file.");
        RequireStability(!Directory.EnumerateFiles(storageDirectory, "*.tmp-*").Any(),
            "Failed stored-default index commit left a temporary file.");
    }

    private static void VerifyStoredMizDefaultsRemovalCommitsIndexFirst(string tempDirectory)
    {
        var storageDirectory = Path.Combine(tempDirectory, "miz-defaults-remove");
        var extractedPath = Path.Combine(tempDirectory, "extracted-remove.lua");
        var mizPath = Path.Combine(tempDirectory, "Remove Mission.miz");
        File.WriteAllText(extractedPath, "Value = 1\n", new System.Text.UTF8Encoding(false));
        var source = MainForm.StoreMizDefaults(
            mizPath,
            new MainForm.ExtractedMizConfig(extractedPath, RuntimeSettings.DefaultConfigFileName),
            storedDefaultsDirectory: storageDirectory);
        var indexPath = Path.Combine(storageDirectory, "index.json");
        var committedIndexText = File.ReadAllText(indexPath);

        var failedAsExpected = false;
        using (File.Open(indexPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
        {
            try
            {
                MainForm.RemoveStoredMizDefaultsSource(source, storageDirectory);
            }
            catch (Exception ex) when (ex is IOException or UnauthorizedAccessException)
            {
                failedAsExpected = true;
            }
        }

        RequireStability(failedAsExpected, "Stored-default removal unexpectedly committed while the index was locked.");
        RequireStability(File.ReadAllText(indexPath) == committedIndexText && File.Exists(source.ConfigPath),
            "Failed stored-default removal deleted data before its index committed.");

        MainForm.RemoveStoredMizDefaultsSource(source, storageDirectory);
        RequireStability(!File.Exists(source.ConfigPath),
            "Successful stored-default removal did not clean up its owned config.");
        RequireStability(!File.ReadAllText(indexPath).Contains(source.Id, StringComparison.Ordinal),
            "Successful stored-default removal left the source in the index.");
    }

    private static void VerifyStoredMizDefaultsNormalizationDefersCleanup(string tempDirectory)
    {
        var storageDirectory = Path.Combine(tempDirectory, "miz-defaults-normalize");
        Directory.CreateDirectory(storageDirectory);
        var index = new MainForm.StoredMizDefaultsIndex();
        for (var itemIndex = 0; itemIndex < 21; itemIndex++)
        {
            var configPath = Path.Combine(storageDirectory, "stored-" + itemIndex + ".lua");
            File.WriteAllText(configPath, "Value = " + itemIndex + "\n", new System.Text.UTF8Encoding(false));
            index.Items.Add(new MainForm.StoredMizDefaultsInfo
            {
                Id = "stored-" + itemIndex,
                SourceKind = "miz",
                MizName = "Mission " + itemIndex + ".miz",
                MizPath = Path.Combine(tempDirectory, "Mission " + itemIndex + ".miz"),
                ConfigFileName = RuntimeSettings.DefaultConfigFileName,
                ConfigPath = configPath,
                StoredAt = new DateTime(2026, 8, 3, 0, 0, 0, DateTimeKind.Local).AddMinutes(itemIndex)
            });
        }

        var changed = MainForm.NormalizeStoredMizDefaultsIndex(index, out var removedItems);
        RequireStability(changed && index.Items.Count == 20 && removedItems.Count == 1,
            "Stored-default normalization did not return the retention cleanup set.");
        RequireStability(File.Exists(removedItems[0].ConfigPath),
            "Stored-default normalization deleted a file before its caller committed the index.");
    }

    private static void VerifyConfigLoadCandidateFallback(string tempDirectory)
    {
        var invalidPath = Path.Combine(tempDirectory, "invalid-remembered.lua");
        var validPath = Path.Combine(tempDirectory, "valid-recent.lua");
        File.WriteAllBytes(invalidPath, new byte[] { 0xC3, 0x28 });
        File.WriteAllText(validPath, "Value = 1\n", new System.Text.UTF8Encoding(false));

        var selection = ConfigLoadCandidateSelector.Select(new[]
        {
            invalidPath,
            invalidPath,
            validPath
        });

        RequireStability(selection.Document is not null &&
                         Path.GetFullPath(selection.Path!).Equals(
                             Path.GetFullPath(validPath),
                             StringComparison.OrdinalIgnoreCase),
            "Config candidate fallback did not select the valid recent config.");
        RequireStability(selection.Failures.Count == 1 &&
                         Path.GetFullPath(selection.Failures[0].Path).Equals(
                             Path.GetFullPath(invalidPath),
                             StringComparison.OrdinalIgnoreCase),
            "Config candidate fallback did not deduplicate and retain the rejected-path error.");

        var allInvalid = ConfigLoadCandidateSelector.Select(new[] { invalidPath });
        RequireStability(allInvalid.Document is null && allInvalid.Failures.Count == 1,
            "All-invalid config candidates did not return their combined failure details.");
    }

    private static void VerifyRememberedConfigCandidateOrder(string tempDirectory)
    {
        var firstPath = Path.Combine(tempDirectory, "first.lua");
        var secondPath = Path.Combine(tempDirectory, "second.lua");
        var settings = new RuntimeSettings
        {
            LastConfigPath = firstPath,
            RecentConfigPaths = new List<string>
            {
                firstPath,
                secondPath,
                firstPath
            }
        };

        var candidates = settings.GetRememberedConfigCandidates();
        RequireStability(candidates.Count == 2 &&
                         candidates[0].Equals(Path.GetFullPath(firstPath), StringComparison.OrdinalIgnoreCase) &&
                         candidates[1].Equals(Path.GetFullPath(secondPath), StringComparison.OrdinalIgnoreCase),
            "Remembered config candidates did not preserve last/recent order with deduplication.");
    }

    private static void VerifyBoundedCategoryLruPolicy()
    {
        var lru = new BoundedLruSet<string>(18, StringComparer.OrdinalIgnoreCase);
        for (var categoryIndex = 1; categoryIndex <= 18; categoryIndex++)
        {
            RequireStability(lru.Touch("Category " + categoryIndex) is null,
                "Built-in category capacity evicted a panel before reaching 18 entries.");
        }

        RequireStability(lru.Count == 18, "Category LRU did not retain all 18 built-in entries.");
        RequireStability(lru.Touch("category 1") is null,
            "Revisiting a cached category unexpectedly evicted another entry.");
        var evicted = lru.Touch("Custom 19");
        RequireStability(evicted == "Category 2",
            "The nineteenth category did not evict the least-recently-used inactive entry.");
        RequireStability(lru.Count == 18 && lru.Contains("Category 1") &&
                         lru.Contains("Custom 19") && !lru.Contains("Category 2"),
            "Category LRU membership was incorrect after eviction.");

        lru.Remove("Category 1");
        RequireStability(!lru.Contains("Category 1") && lru.Count == 17,
            "Category LRU removal left stale membership.");
        lru.Clear();
        RequireStability(lru.Count == 0, "Category LRU clear left stale membership.");
    }

    private static void VerifyThirdPartyNoticesResource()
    {
        using var stream = typeof(MainForm).Assembly.GetManifestResourceStream(
            "FootholdConfigManager.ThirdPartyNotices.txt");
        RequireStability(stream is not null,
            "The embedded third-party notices resource is missing.");
        if (stream is null)
        {
            return;
        }

        using var reader = new StreamReader(stream, new System.Text.UTF8Encoding(false));
        var notices = reader.ReadToEnd()
            .Replace("\r\n", "\n", StringComparison.Ordinal)
            .Replace('\r', '\n');
        RequireStability(notices.Contains("Loretta.CodeAnalysis.Lua 0.2.13", StringComparison.Ordinal),
            "Third-party notices omitted Loretta.CodeAnalysis.Lua 0.2.13.");
        RequireStability(notices.Contains("Loretta.CodeAnalysis.Common 0.2.13", StringComparison.Ordinal),
            "Third-party notices omitted Loretta.CodeAnalysis.Common 0.2.13.");
        RequireStability(notices.Contains("Tsu 2.2.2", StringComparison.Ordinal),
            "Third-party notices omitted Tsu 2.2.2.");
        const string mitPermissionParagraph = "Permission is hereby granted, free of charge, to any person obtaining a copy\n" +
            "of this software and associated documentation files (the \"Software\"), to deal\n" +
            "in the Software without restriction, including without limitation the rights\n" +
            "to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n" +
            "copies of the Software, and to permit persons to whom the Software is\n" +
            "furnished to do so, subject to the following conditions:";
        const string mitWarrantyParagraph = "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n" +
            "IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n" +
            "FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n" +
            "AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n" +
            "LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n" +
            "OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\n" +
            "SOFTWARE.";
        RequireStability(notices.Contains(mitPermissionParagraph, StringComparison.Ordinal),
            "Third-party notices omitted the MIT permission paragraph.");
        RequireStability(notices.Contains(mitWarrantyParagraph, StringComparison.Ordinal),
            "Third-party notices omitted the MIT warranty paragraph.");
    }

    private static void VerifyMalformedQuotedScalarRemainsInvalid(string tempDirectory)
    {
        var configPath = Path.Combine(tempDirectory, "malformed-quoted-scalar.lua");
        File.WriteAllText(configPath, "Era = \"Modern\"\"\n", new System.Text.UTF8Encoding(false));

        var errors = ConfigDocument.Load(configPath).Validate();

        RequireStability(errors.Any(error => error.StartsWith("Lua syntax:", StringComparison.Ordinal)),
            "Config validation normalized an extra scalar quote instead of rejecting the malformed Lua.");
    }

    private static void VerifyEscapedQuoteScalarRemainsValid(string tempDirectory)
    {
        var configPath = Path.Combine(tempDirectory, "escaped-quote-scalar.lua");
        File.WriteAllText(configPath, "Era = \"Modern\\\"Test\"\n", new System.Text.UTF8Encoding(false));

        var document = ConfigDocument.Load(configPath);
        var errors = document.Validate();

        RequireStability(errors.Count == 0,
            "Config validation rejected a valid escaped quote in a scalar string.");
        RequireStability(document.Entries.Single().Kind == ConfigValueKind.String,
            "A valid escaped-quote scalar was no longer classified as an editable string.");
    }

    private static void VerifyControlTreeDisposerClearsToolTips()
    {
        using var toolTip = new ToolTip();
        var references = CreateDisposedControlReferences(toolTip);

        GC.Collect();
        GC.WaitForPendingFinalizers();
        GC.Collect();

        RequireStability(!references.Root.IsAlive && !references.Child.IsAlive,
            "Disposed category controls remained rooted by tooltip associations.");
    }

    private static (WeakReference Root, WeakReference Child) CreateDisposedControlReferences(ToolTip toolTip)
    {
        using var host = new Panel();
        var root = new Panel();
        var child = new Button();
        root.Controls.Add(child);
        host.Controls.Add(root);
        toolTip.SetToolTip(root, "Root tooltip");
        toolTip.SetToolTip(child, "Child tooltip");

        var rootReference = new WeakReference(root);
        var childReference = new WeakReference(child);
        ControlTreeDisposer.Dispose(root, toolTip);

        RequireStability(root.Parent is null && root.IsDisposed && child.IsDisposed,
            "Control tree disposal did not detach and dispose the complete panel tree.");
        RequireStability(string.IsNullOrEmpty(toolTip.GetToolTip(root)) &&
                         string.IsNullOrEmpty(toolTip.GetToolTip(child)),
            "Control tree disposal left tooltip associations registered.");
        return (rootReference, childReference);
    }

    private static void VerifyUiViewGenerationRejectsStaleCallbacks()
    {
        var generation = new UiViewGeneration();
        var firstView = generation.Next();
        RequireStability(generation.IsCurrent(firstView),
            "A newly activated UI view was immediately treated as stale.");

        var secondView = generation.Next();
        RequireStability(!generation.IsCurrent(firstView) && generation.IsCurrent(secondView),
            "A callback from the previous UI view was not rejected.");
    }

    private static void VerifyConfigSearchIndexSemantics()
    {
        var items = new List<ConfigSearchIndexItem>
        {
            new("MAX_AT_SPAWN", "MAX_AT_SPAWN.Engineer soldier", "Engineer soldier", "CTLD", "CTLD",
                "Units restored after the last session.", 0),
            new("missionEra", null, "Era", "Mission Rules", "Mission Rules",
                "Choose Modern, Coldwar, Gulfwar, or Vietnam.", 1),
            new("connectionDisplay", null, "Connection Display", "F10 Map", "F10 Map",
                "Controls how supply connections are drawn.\nRestore the normal map lines.", 2),
            new("sharedFirst", null, "Shared option", "Mission options", "Mission options",
                "Shared wording.", 3),
            new("sharedSecond", null, "Shared option", "Mission options", "Mission options",
                "Shared wording.", 4)
        };

        var rowMatches = ConfigSearchIndex.Search(items, "Engineer soldier");
        RequireStability(rowMatches.Count == 1 &&
                         rowMatches[0].Item.TargetKey == "MAX_AT_SPAWN" &&
                         rowMatches[0].Item.RowKey == "MAX_AT_SPAWN.Engineer soldier" &&
                         rowMatches[0].Score == 0,
            "Cached config search changed exact group-row matching.");

        var commentMatches = ConfigSearchIndex.Search(items, "normal map");
        RequireStability(commentMatches.Count == 1 &&
                         commentMatches[0].Item.TargetKey == "connectionDisplay" &&
                         commentMatches[0].Excerpt == "Restore the normal map lines.",
            "Cached config search changed comment matching or excerpt selection.");

        var categoryMatches = ConfigSearchIndex.Search(items, "Mission Rules");
        RequireStability(categoryMatches.Count == 1 &&
                         categoryMatches[0].Item.TargetKey == "missionEra" &&
                         categoryMatches[0].Score == 4,
            "Cached config search changed category matching.");

        var stableMatches = ConfigSearchIndex.Search(items, "Shared option");
        RequireStability(stableMatches.Select(match => match.Item.TargetKey)
                .SequenceEqual(new[] { "sharedFirst", "sharedSecond" }),
            "Cached config search changed stable source ordering.");
        RequireStability(ConfigSearchIndex.Search(items, "not present").Count == 0,
            "Cached config search returned a result for an unmatched query.");

        var cappedItems = Enumerable.Range(0, 300)
            .Select(index => new ConfigSearchIndexItem(
                "key" + index,
                null,
                "Common match " + index,
                "Category",
                "Category",
                "",
                index))
            .ToList();
        var cappedMatches = ConfigSearchIndex.Search(cappedItems, "Common match");
        RequireStability(cappedMatches.Count == 250 && cappedMatches[^1].Item.Order == 249,
            "Cached config search changed the 250-result limit or source ordering.");
    }

    private static void VerifyDebouncedSearchQueryKeepsOnlyLatestInput()
    {
        var pending = new DebouncedSearchQuery();
        pending.Schedule("eng");
        pending.Schedule("engineer");
        RequireStability(pending.TryTake(out var query) && query == "engineer",
            "Debounced config search did not retain the latest pending query.");
        RequireStability(!pending.TryTake(out _),
            "Debounced config search ran the same pending query more than once.");

        pending.Schedule("cancelled");
        pending.Clear();
        RequireStability(!pending.TryTake(out _),
            "Clearing config search did not cancel its pending query.");
    }

    private static void RequireStability(bool condition, string message)
    {
        if (!condition)
        {
            throw new InvalidOperationException(message);
        }
    }
}
