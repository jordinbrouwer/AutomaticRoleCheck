# Changelog
Written by the release pipeline from the commits; see `CONTRIBUTING.md`.

## [Unreleased](https://github.com/jordinbrouwer/AutomaticRoleCheck/compare/2.6.0...master)

### Added
- Added a new options window of its own, opened with `/arc`: a header with the logo, a thin scroll bar, its own tooltips and a hint about `/arc help` at the bottom. The game's settings page now has a button that opens it.
- Added resizing of the options window: drag the grip in the bottom right corner to change its width and height, right-click the grip to go back to the default size. The size is remembered.
- Added accepting in combat: the popup waits and is accepted right after combat ends, and the minimap button shows that something is waiting.
- Added the "When it is accepted" table with In combat and Out of combat columns: accept for me, hide the popup, play a sound, choose the sound, and wait before accepting (out of combat only). With "Linked" the Out of combat column follows the In combat column.
- Added "What to accept" (role checks, role polls, group invites, group sign-ups) and "Only when" (when I play a tank, healer or damage, and where: everywhere, group or instance, or instance only).
- Added the "My role" box: switch Tank, Healer and Damage on or off for the Group Finder, "Follow spec" to set the role from your specialization, and "Set in group" to also set your role in your group.
- Added a "Minimap button" box: show the button, colour the check mark by status, lock the button in place, and choose what Left-click, Right-click, Shift + Left-click and Shift + Right-click do.
- Added a "Reset" link to most option boxes that puts the settings of that box back to their defaults (click it twice).
- Added `/arc help`, which shows the commands as keys in a message that stays until you click it.
- Added a new logo, used for the addon icon, the options window, the messages and the minimap button.

### Changed
- Changed `/arc` to open the options window instead of listing the commands.
- Changed all messages to show as toasts at the top of the screen instead of lines in chat.
- Changed the minimap button: the check mark of the logo is green when the addon is on, red when it is off and amber while something waits for combat to end, and its tooltip lists the clicks as you set them.
- Changed what happens by default out of combat: the game's popup is hidden while it is accepted, and the Ready check sound plays when it has been accepted.
- Changed sounds: while the addon is on, the game's own ready-check sound is muted (also for normal ready checks), so only the sound you chose plays.
- Changed the code layout into separate folders for core, window, texts and pictures.

### Removed
- Removed `/arc options`; use `/arc` to open the options window.

## [2.6.0 (2026-10-07)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/2.6.0)

### Added
- Added auto-accept support for the role poll popup.
- Added WoW Forever compatibility via interface version `16001`.

### Changed
- Updated specialization role detection to use `C_SpecializationInfo` on newer clients.
- Updated release and CurseForge publish scripts to handle multiple TOC files.

## [2.5.0 (2026-07-28)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/2.5.0)

### Added
- Added CurseForge publish step to CD so tagged releases upload automatically.

### Changed
- Updated the default name of the release.
- Bumped version due to new patch.

## [2.4.0 (2026-05-06)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/2.4.0)

### Added
- Added minimap button support to enable/disable the addon quickly.
- Added `/arc status` command to show current addon version and status.
- Added support for `/arc enable once` and `/arc disable once`.
- Added missing options to the panel and updated visual.
- Added `CONTRIBUTING.md` with local development and check guidance.
- Added localization for user-facing strings, with English as the default and optional per-locale overrides.

### Changed
- Bumped version due to new patch.
- Changed `/arc` to list available commands.
- Changed slash command handling to use shared helpers and cleaner option updates.
- Changed release packaging to use `.tmp` artifacts with stricter output validation.
- Changed CI check execution to use simpler, script-based single-mode jobs.

### Removed
- Removed `/arc help` command (help is now shown automatically with `/arc`).
- Removed legacy `/arc enableonce` and `/arc disableonce` command forms.

## [2.3.1 (2026-03-16)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/2.3.1)

### Changed
- Bumped version due to new patch.

## [2.3.0 (2026-01-05)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/2.3.0)

### Added
- Added feature to skip once by holding shift during a role check.

## [2.2.3 (2025-10-09)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/2.2.3)

### Changed
- Bumped version due to new patch and early Midnight support.

## [2.2.2 (2025-07-15)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/2.2.2)

### Fixed
- Issue where enabling the addon once would cause it to remain permanently active.

## [2.2.1 (2025-07-14)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/2.2.1)

### Fixed
- Issue with the incorrect packaging of the latest release.

### Changed
- Removed unused file from `.gitattributes`.

## [2.2.0 (2025-07-11)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/2.2.0)

### Added
- Added an option to enable the addon once for the next upcoming role check.

### Changed
- Bumped version due to new patch.

## [2.1.2 (2025-02-19)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/2.1.2)

### Changed
- Bumped version due to new patch.

## [2.1.1 (2024-12-30)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/2.1.1)

### Changed
- Bumped version due to new patch.

## [2.1.0 (2024-12-02)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/2.1.0)

### Added
- Added an option to disable the addon for the first role check upon changing role (@Pegoth).

### Changed
- Bumped version due to new patch.

## [2.0.0 (2024-08-05)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/2.0.0)

### Fixed
- Check for the enabled state of the addon on acceptance of the role check.

### Added
- Added an option to disable the addon whilst being AFK.
- Added an icon to identify the addon in the Addons option screen.

### Changed
- Adapted the color of the commands to be corresponding with the logo color.

## [1.11.0 (2024-08-04)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/1.11.0)

### Fixed
- Capability with new changes to the WoW Settings API.

### Added
- Added a feature to disable first role check upon each login.
- Added a command to open the options for the addon.

### Changed
- Restructured the command list with more fitting naming.
- Bumped version due to new patch.

## [1.10.0 (2024-06-10)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/1.10.0)

### Fixed
- Issue with populating the options panel (@rodrigodias4).

### Changed
- Bumped version due to new patch.

## [1.9.0 (2024-02-13)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/1.9.0)

### Changed
- Bumped version due to new patch.

## [1.8.0 (2023-12-18)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/1.8.0)

### Changed
- Bumped version due to new patch.

## [1.7.0 (2023-08-08)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/1.7.0)

### Added
- Added fallback for invalid commands.
- Added in-game docs for the addon.

### Changed
- Bumped version due to new patch.
- Fixed position of settings panel checkbox.
- Simplified code execution for the hook events on the buttons by removing unnecessary code.
- Changed the final newline rule to be false.
- Fixed uppercase mismatch on words of the docs and panels.

### Removed
- The option for automatic acceptance of dungeon queues upon receiving an invite has been disabled due to hardware protection since patch `10.1.5`.

## [1.6.0 (2023-05-22)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/1.6.0)

### Changed
- Bumped version due to new patch.

## [1.5.0 (2023-01-10)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/1.5.0)

### Changed
- Bumped version due to new patch.

## [1.4.0 (2022-06-13)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/1.4.0)

### Changed
- Bumped version due to new patch.

## [1.3.0 (2022-02-28)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/1.3.0)

### Changed
- Bumped version due to new patch.

## [1.2.4 (2021-12-15)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/1.2.4)

### Added
- Added LICENSE for the project.

### Changed
- Updated `.editorconfig`, `.gitattributes` and `.gitignore`.

## [1.2.3 (2021-10-28)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/1.2.3)

### Changed
- Bumped version due to new patch.

## [1.2.2 (2021-10-28)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/1.2.2)

### Added
- Added `.gitattributes`, `.editorconfig` and `CHANGELOG.md`.

## [1.2.1 (2021-07-04)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/1.2.1)

### Changed
- Bumped version due to new patch.

## [1.2.0 (2021-03-01)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/1.2.0)

### Added
- Added support to disable the addon once.

### Changed
- Changed the general command to also display whether the addon is enabled or not.
- Changed the tooltips to be more precise.

## [1.1.0 (2021-02-22)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/1.1.0)

### Added
- Added support to enable and disable the addon using commands.
- Added support to enable and disable the addon the interface options.

## [1.0.0 (2021-02-18)](https://github.com/jordinbrouwer/AutomaticRoleCheck/releases/tag/1.0.0)

First release.
