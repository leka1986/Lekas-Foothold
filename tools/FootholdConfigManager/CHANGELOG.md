# Foothold Config Manager changes

Source changes are listed below. Existing versioned executables are separate artifacts.

**2026-11-05 — Changes since the version included with Foothold v5.4.4**

**Added**

- Added mission downloads directly in the Manager, with map selection and installation to your chosen instance.
- Added files-only updates for compatible missions, keeping everything the same except the updated script files.
- Added compatibility checks across your instances, with options to add other mission folders, select individual MIZ files and rescan.
- Added selection of multiple mission variants, so day, night and other customised copies can be updated together.
- Added support for updating missions from DCSServerBot backups.
- Added an optional Custom Folder for downloads and updated missions. Your folder is remembered, and you can choose each new mission's filename before saving.
- Added warehouse transfer during full mission downloads, including modded items.
- Added options to apply saved weather and time profiles to downloaded missions, and update the selected instances' Configs while keeping their settings.
- Added an adjustable editor width, shared across categories and remembered between sessions.
- Added remembered widths for manually resized grid columns, with an option to restore their default widths.

**Changed**

- Changed the main editor with clearer setting groups, rounded sections, larger text and collapsible tables.
- Changed the editor layout to adapt to the window size while keeping comfortable spacing around the content.
- Changed tables, scrollbars and text editors for a more consistent appearance in dark and light mode.
- Changed grid sizing to keep column headings readable and give long dropdown options more room.
- Changed the Aircraft / Weapons lists with wider grids, buttons above the lists and a fully visible Status column.
- Changed Warehouse Weapon Caps and other simple lists to place Add item and Remove selected above the grid, leaving more room for the list.
- Changed the Updates page to clearly separate files-only updates from full mission downloads and explain what each option preserves.

**Fixed**

- Fixed list transfers losing Config comments. Moving an item back or using Undo now restores its original text and clears the Save highlight when no other changes remain.

**2026-10-25 — Escort template choices**

- Added a NEW category indicator when an older Escort table gains template-based controls; opening the category acknowledges it.

- Fixed older Config updates failing validation before numeric escort choices were migrated.

- Added escort selections from checked CAP templates, including separate Red choices when PvP escorts are enabled.
- Changed Era updates to retain valid escort selections or choose an enabled era default, with CHANGED highlighting and one-step Undo.
- Changed inactive player-aircraft rows to remain visible and greyed out while preserving their escort preferences.
- Added migration of old numeric escort selections when updating Configs, preserving availability and follow altitude and adding Red choices.
- Fixed Vietnam escort requirements forcing modern aircraft that were not selected for CAP.
- Changed empty CAP lists to disable escort choices; manually removing a selected template clearly requests a replacement.

Requires the matching updated Config and mission escort script. Existing released executables remain separate artifacts.

**2026-10-25 — Aircraft lists and AI-use review**

- Changed AI-only aircraft handling so these types no longer appear as player-selectable aircraft; legacy entries are cleaned up when saving or updating older Configs.
- Fixed AI-only aircraft requirements preventing older Configs from saving, including Cold War lists.
- Added automatic activation of flyable aircraft required by enabled AI when changing Era or AI settings, with CHANGED category indicators and highlighted aircraft rows.
- Added a Save review listing automatic aircraft changes that have not been viewed, with Review aircraft, Save these changes and Cancel choices.
- Added one-step Undo for the triggering setting and its automatic aircraft additions; aircraft still required by another enabled AI use remain active.
- Replaced the silent disabled aircraft move arrow with a clickable action that explains which aircraft is required and how to change its AI uses.
- Added Review all uses and category links that open the relevant AI settings, scroll to the first matching source and highlight every matching row or setting on that page.
- Changed AI-use highlights to update after edits and Undo, clear when leaving the category or changing Configs, and keep hidden/testing sources out of the displayed details.

**Other improvements included in this source update**

- Added combined editable grids for related availability, price, rank and saved-unit limits, where supported by Config metadata, while retaining their original saved settings.
- Added labelled command text fields with live examples, including suffix-only examples for blank fields; only the entered command word is saved.
- Added reusable aircraft requirement sets and conditional source rules for Config authors, with actual AI-use reasons and navigation links.
- Added conditional visibility for individual table rows and alternative-source conditions for related options.
- Added locked-value display overrides and whole-table/stage-editor locks without overwriting saved preferences.
- Added separate, session-only visibility for testing settings.
- Added CHANGED category indicators and in-page change rails for settings affected elsewhere; viewed categories clear their indicators, and no global Options changed banner is required.
- Added an option to update matching Config variants across instances, with each instance's own value choices, backup and results.
- Added separate remembered folders for MIZ and Config-file imports.
- Changed Config-file updates to use the incoming comments and metadata while preserving the selected current settings.
- Changed aircraft requirement conflicts during Config/MIZ updates into reported warnings; malformed metadata, syntax and unrelated validation errors remain blocking.
- Fixed rows removed from source tables being restored during updates when those tables use the replacement policy; matching retained values can still be preserved.
- Fixed NEW category indicators remaining after their visible items had been reviewed, including conditionally visible aircraft lists.
- Fixed numeric and text grid editing ending after each keystroke; editing now commits on normal completion while checkboxes and choices retain immediate updates.
- Fixed clipped Presets buttons, table headings and constrained header/footer layouts.
- Changed zoom scaling for denser high-resolution layouts, with an 80–130% range and improved high-DPI handling.
- Changed category hover, grid layout and scrollbar presentation for smoother navigation and less redraw flicker.
- Added a Comments view for the selected category and the Manager version in the window title.
- Changed category switching, Config parsing, validation and unchanged-table updates to reuse existing results and avoid repeated work.
- Changed user exports to build in a temporary workspace and omit development-only diagnostics and unused sample resources, reducing unnecessary executable content.

**Build and compatibility**

- Added the complete current core source, required build resources and instructions so this checkout can be built directly.
- Changed the source only; existing downloadable executables are separate artifacts.
- Changed AI-only aircraft handling to rely on the corresponding mission-side warehouse support; updating the Manager alone does not change an older mission's runtime stock handling.

Controls driven by Config metadata appear only when the Config supplies the corresponding annotations. These notes do not describe changes to mission scripts or embedded MIZ files in this source synchronization.
