# Foothold Config Manager source

Build this project on Windows with the .NET 8 SDK and its Windows desktop support. Download or clone the repository with both `tools/FootholdConfigManager` and `tools/test-configs` present. The two sample Configs in the sibling folder are build resources; they are not installed into a DCS instance by building this project.

From the repository root:

```powershell
dotnet build tools/FootholdConfigManager/FootholdConfigManager.csproj -c Release
dotnet run --project tools/FootholdConfigManager/FootholdConfigManager.csproj -c Release
```

For a single-file, framework-dependent Windows build:

```powershell
dotnet publish tools/FootholdConfigManager/FootholdConfigManager.csproj -c Release -r win-x64 --self-contained false -p:PublishSingleFile=true -p:PublishReadyToRun=false -p:DebugType=None -p:DebugSymbols=false -o manager-publish
```

The published executable requires the .NET 8 Windows Desktop Runtime. Normal source builds include the administrative tools. To create a player distribution with selected GUI settings, use Export User EXE in the Manager's designer. Exports compile from a temporary copy of this source tree and do not overwrite the source build's metadata.

Validation commands:

```powershell
dotnet run --project tools/FootholdConfigManager/FootholdConfigManager.csproj -c Release -- --self-test-stability
dotnet run --project tools/FootholdConfigManager/FootholdConfigManager.csproj -c Release -- --self-test-merge
dotnet run --project tools/FootholdConfigManager/FootholdConfigManager.csproj -c Release -- --check "path/to/Foothold Config.lua"
dotnet run --project tools/FootholdConfigManager/FootholdConfigManager.csproj -c Release -- --audit "path/to/Foothold Config.lua" "manager-audit.log"
```

The optional external Lua syntax oracle is used only when `FOOTHOLD_CONFIG_MANAGER_LUAC_ORACLE` is configured. The regular parser and validation remain available without it.

Saved preferences, instances and presets belong to `Saved Games/Foothold Config Manager`. They are not source files and should not be copied into this directory. Existing versioned executables are independent of a new source build.

See CHANGELOG.md for the source update's user-facing changes. New metadata-driven controls need a Config containing their annotations. AI-only aircraft warehouse handling also needs the corresponding mission update.
