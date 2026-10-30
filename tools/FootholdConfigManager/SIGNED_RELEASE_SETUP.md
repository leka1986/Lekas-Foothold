# Signed Manager releases: one-time setup

The admin Manager can prepare a player release, request signing, and download the verified result. Publishing the download is a separate **Publish download** action. Ordinary **Export User EXE** continues to create a local unsigned EXE.

Signing is unavailable until the project has been accepted and configured with SignPath. This guide and the included workflow do not establish acceptance or sponsorship.

## 1. Obtain project approval

Apply through [SignPath Foundation](https://signpath.org/apply). Enable two-factor authentication on the GitHub and SignPath accounts used for this project. Identify the maintainers, reviewers and signing approvers. Every release requires a trusted approver's approval.

Review the project's open-source licensing and all bundled material, including the three splash photographs, icon and third-party notices. Confirm that their licenses or your permissions allow public source distribution and inclusion in signed releases. Resolve any missing artwork rights before uploading source.

Prepare a code signing policy and accurate privacy statement describing the Manager's actual network behavior, including update checks and explicitly requested admin release operations. Link the policy from the project homepage and download page. Add the Foundation's required attribution only after acceptance and according to its instructions. The current requirements are in the [Foundation terms](https://signpath.org/terms).

## 2. Install the workflow on the default branch

Put these reviewed files in the public repository:

- `.github/workflows/foothold-manager-signed.yml`
- `tools/FootholdConfigManager/BuildSignedRelease.ps1`
- `tools/FootholdConfigManager/SIGNED_RELEASE_SETUP.md` (this guide)

The project remains flat: `tools/FootholdConfigManager/FootholdConfigManager.csproj`. The two existing sample configs stay in `tools/test-configs/`.

Commit the workflow to the repository's **default branch** before using **Build signed release**. GitHub requires that installation for manual dispatch; placing it only on a release branch is insufficient. Use GitHub's web editor or an owner credential allowed to update workflows. If GitHub CLI reports missing workflow authorization during this one-time installation, update the owner's authorization deliberately; do not put credentials in project files. See [GitHub manual workflow requirements](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow).

## 3. Configure SignPath and GitHub

Install the [SignPath GitHub App](https://github.com/apps/signpath) for this repository. In the accepted SignPath project, link the GitHub.com trusted build system and configure the release signing policy. Require GitHub-hosted runners and manual signing approval. Permit the intended release branches, `foothold-manager/releases/*`, and this workflow; keep any additional restrictions required by the accepted project.

Configure the default artifact configuration as a ZIP containing exactly `Foothold Config Manager <version>.exe` at the root, with that executable signed using the accepted Foundation certificate. Enforce the project's product metadata and consistent release version. The unsigned upload uses GitHub's ZIP artifact format. Follow the official [GitHub integration guide](https://docs.signpath.io/trusted-build-systems/github) when configuring the project and policy.

In GitHub, open **Settings → Secrets and variables → Actions** and add:

| Kind | Name | Value |
| --- | --- | --- |
| Variable | `SIGNPATH_ORGANIZATION_ID` | Organization ID supplied by SignPath |
| Variable | `SIGNPATH_PROJECT_SLUG` | Accepted project's slug |
| Variable | `SIGNPATH_SIGNING_POLICY_SLUG` | Release signing policy slug |
| Secret | `SIGNPATH_API_TOKEN` | SignPath API token with permission to submit to that policy |

Keep `SIGNPATH_API_TOKEN` only in the repository's encrypted secret store. Do not paste it into the Manager, source, screenshots, workflow text or release artifacts.

On the admin computer, install GitHub CLI and sign in as the repository owner using `gh auth login`. The existing login must be permitted to create release branches, dispatch/read Actions runs and download artifacts. The separate publishing action also needs permission to create a commit in the download folder. No GitHub or SignPath token is included in player builds.

## 4. Make a release

1. In the admin Manager, select a numeric Designer version above the currently published version and open **Build signed release**.
2. Choose the output folder, use **Check setup**, then **Build signed release**.
3. Use **Open build** to follow the run. When it reaches **Request SignPath signing**, use **Approve in SignPath** and approve the exact release commit in SignPath.
4. Wait for the verified signed EXE to become ready. **Open folder** shows the result.
5. Review the result, then use **Publish download** when you intend to make that new version available to players.

**Stop watching** stops local monitoring; the remote build continues. Use **Resume** to reconnect. If the run expires while awaiting approval, inspect its status and start a new build request as needed. No failed, unsigned or unverified artifact is published automatically.

## What the workflow verifies

Each request uses a unique `foothold-manager/releases/<version>-<id>` branch. The workflow checks out its exact `GITHUB_SHA`; `release-result.json` records that commit rather than a branch name. The source snapshot includes no live Lua config values or normal Manager settings.

`release-inputs/` contains `EmbeddedGuiMetadata.json`, `EmbeddedBuildMode.txt` set to `user`, `ManagerVersion.txt`, and `source-manifest.json`. The manifest lists the exact source/resource/fixture paths and their SHA-256 hashes. Only these verified files enter the temporary builds, so older files inherited from the branch's base cannot enter the compilation. Source and embedded versions must match the requested version.

The helper builds an admin copy and runs the existing merge and stability self-tests with a private application data directory. It then publishes the actual player copy as a framework-dependent Windows x64 single-file EXE targeting .NET 8 Desktop, matching ordinary export packaging. A verification harness checks exact embedded metadata, user mode, release version and admin-code exclusion before signing.

The workflow submits the unsigned GitHub artifact through the official [SignPath action](https://github.com/SignPath/github-action-submit-signing-request/blob/f6d04783b4569d051e0c80105fe66e82819d0092/action.yml), pinned to v3.0's immutable commit. After signing, it requires exactly the expected EXE, a Windows-trusted valid Authenticode signature with publisher `SignPath Foundation`, and the expected file version. Only then does it create the hash manifest and upload `foothold-manager-signed-<version>`, containing the EXE and `release-result.json`.

The workflow has read-only repository permissions and does not publish downloads, install the EXE, execute mission archives, cache signed binaries or place an unsigned EXE in a signed artifact.

## Local unsigned verification

Use a prepared source snapshot with its generated `release-inputs/` and sample configs. In PowerShell 7 on Windows, run the following with empty private output directories and the snapshot's actual commit and version:

```powershell
./BuildSignedRelease.ps1 -Mode Build `
  -ProjectDirectory 'C:/release-snapshot/tools/FootholdConfigManager' `
  -ReleaseInputsDirectory 'C:/release-snapshot/tools/FootholdConfigManager/release-inputs' `
  -Version '2.1.6' -SourceCommit '<40-character source commit>' `
  -WorkDirectory "$env:TEMP/foothold-release-check-work" `
  -ArtifactDirectory "$env:TEMP/foothold-release-check-unsigned"
```

This checks compilation and player identity and produces an **unsigned** candidate. It does not request SignPath signing or prove that the remote signing policy is configured. A real signing run remains dependent on external approval and setup.
