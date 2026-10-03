# Licensing and third-party notices

## Foothold license scope

Copyright (c) 2026 Leka (leka1986), for Leka's original contributions.

Leka's original source code and modifications in this repository are licensed
under the GNU General Public License, version 3 only (SPDX: `GPL-3.0-only`).
The full license is in [LICENSE](LICENSE).

This grant covers only material for which Leka holds the necessary rights.
It does not replace third-party copyrights, license notices or permissions.
Upstream material retains the terms described below; those terms must also be
preserved when distributing Foothold versions containing that material.
Other contributors' work is covered only where their applicable license or
permission allows it. Material with unverified permissions is identified below.

## ZoneCommander and the original Foothold

- Original author: Dzsek / dzsekeb.
- Upstream: [Dzsek/zoneCommander](https://github.com/Dzsek/zoneCommander).
- Upstream license: [Apache License 2.0](LICENSES/Apache-2.0.txt).
- Foothold files: `Common Scripts/zoneCommanderv2.lua`

These Foothold variants contain modifications maintained by Leka. The original
upstream portions retain Apache-2.0 notices and permissions; Leka's modifications
are offered under GPL-3.0-only. The last recorded public revisions of these files
are dated 2026-10-02, 2026-09-25 and 2026-09-25, respectively. Revision history
records the published changes; these dates do not assert initial authorship.

## MOOSE, including its CTLD framework

- Authors: the MOOSE project contributors, including Leka (leka1986).
  CTLD credits include Applevangelist
  and Ciribob for the original CTLD work.
- Upstream: [FlightControl-Master/MOOSE](https://github.com/FlightControl-Master/MOOSE).
- License: GNU GPL version 3; see [LICENSE](LICENSE).
- Foothold file: `Common Scripts/Moose_2026-08-13.lua`.
- Its build header identifies upstream commit
  `8b69c197cbe69ee18af9a4ff02f4c60eaa00f2d9`.
- [License at that commit](https://github.com/FlightControl-Master/MOOSE/blob/8b69c197cbe69ee18af9a4ff02f4c60eaa00f2d9/LICENSE).
- Foothold contains customizations, with its last recorded public file revision
  dated 2026-09-25. Modular upstream source is available in the MOOSE repository.

`Foothold CTLD.lua` and `Foothold_CTLD_Red.lua` are Foothold integration scripts;
they use the bundled MOOSE CTLD framework. Existing upstream terms continue to
apply to any upstream code included in those integrations.

## AIEN

- Author: Chromium18 and contributors.
- Upstream: [Chromium18/AIEN](https://github.com/Chromium18/AIEN).
- License: GNU GPL version 3; see [LICENSE](LICENSE) and the
  [upstream license](https://github.com/Chromium18/AIEN/blob/stable/LICENSE).
- Foothold file: `Common Scripts/AIEN.lua`.
- Foothold contains customizations, with its last recorded public file revision
  dated 2026-10-02.

## Splash Damage

- Upstream: [stephenpostlethwaite/DCSSplashDamageScript](https://github.com/stephenpostlethwaite/DCSSplashDamageScript).
- Maintainer credited by the bundled script: stevey9062 / Stevey666
  (stephenpostlethwaite).
- Upstream license: [MIT](LICENSES/Splash-Damage-MIT.txt), including the original
  copyright notice for wheelyjoe (2021).
- Foothold file: `Common Scripts/Splash_Damage_3.4.1_leka.lua`.
- Foothold contains customizations, with its last recorded public file revision
  dated 2026-09-11.

## Early Warning Radar Script (EWRS)

- Original author: Bob7heBuilder / Steggles.
- Upstream: [Bob7heBuilder/EWRS](https://github.com/Bob7heBuilder/EWRS).
- Upstream license: [MIT](LICENSES/EWRS-MIT.txt), copyright Bob7heBuilder (2016).
- Foothold file: `Common Scripts/EWRS.lua`.
- The bundled header also credits Apple and Leka for later updates.
- The Foothold version uses MOOSE and contains modifications; its last recorded
  public file revision is dated 2026-10-02.

## Normandy

- Mission creator credited by this repository: sevenfifty777.
- Upstream: [sevenfifty777/DCS-foothold-Normandy](https://github.com/sevenfifty777/DCS-foothold-Normandy).
- Upstream license: [MIT](LICENSES/Normandy-MIT.txt), retaining its stated
  copyright holder, Apex (2025).
- Related Foothold material: `Setup files/Normandy_Zone_Setup.lua` and the
  Normandy mission archive under `Missions/`.

The Normandy author's original contributions retain that MIT license.
Third-party scripts and media packaged in a Normandy mission retain their own
terms; the upstream MIT file does not establish ownership of every bundled asset.

## Foothold Config Manager and .NET dependencies

Config Manager source is under `tools/FootholdConfigManager/`.
Its dependency notices already appear in
[ThirdPartyNotices.txt](tools/FootholdConfigManager/ThirdPartyNotices.txt)
and are embedded by the project in the executable. They include:

- Loretta.CodeAnalysis.Lua and Loretta.CodeAnalysis.Common 0.2.13: MIT,
  copyright GGG KILLER (2021); [Loretta](https://github.com/GGG-KILLER/Loretta).
- Tsu 2.2.2: MIT, copyright GGG KILLER (2020);
  [Tsu](https://github.com/GGG-KILLER/Tsu).

The .NET runtime retains its own
[MIT license](LICENSES/DotNet-MIT.txt) and
[third-party notices](LICENSES/DotNet-ThirdPartyNotices.txt).
These copies come from the [.NET 8.0.28 source release](https://github.com/dotnet/runtime/tree/v8.0.28).
Runtime and dependency notices must accompany distributions that include those
components; the Foothold license does not replace them.

## Mission archives, media and unresolved provenance

Scripts embedded in `.miz` archives retain the applicable script licenses above.
Archive packaging does not change those licenses. This update does not modify
mission archives or add notices inside them. Standalone mission downloads must
also be accompanied by the applicable licenses, notices and corresponding source
when required by those licenses.

This license addition does not grant new rights over third-party audio, images,
DCS assets, trademarks or mission contributions without established permission.
The following provenance or permissions were not established by this check:

- Afghanistan contributions credited to Santaowns.
- Upstream portions, if any, of `Common Scripts/Zeus.lua` and the distinct
  `zeus_Full_v2.1.lua` embedded in the Normandy mission.
- Audio and images embedded in mission archives.
- The authorship, dependency notices and corresponding source of
  `tools/MizBatchUpdater.exe` and `tools/MizFileReplacer.exe`.
- Permissions for later third-party script modifications not covered by the
  verified upstream licenses or Leka's own copyright.

These items require their existing permissions to be preserved or confirmed.
A missing or unverified notice is not a grant of permission. This record documents
verified upstream licenses as of 2026-10-03; it is not a certification that every
packaged asset or binary has complete redistribution documentation.
