# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased](https://github.com/jordinbrouwer/AutomaticRoleCheck/compare/2.1.0...master)

## [2.1.0 (2024-12-02)](https://github.com/jordinbrouwer/AutomaticRoleCheck/compare/2.0.0...2.1.0)

### Added
- Added an option to disable the addon for the first role check upon changing role (@Pegoth).

### Changed
- Bumped version due to new patch.

## [2.0.0 (2024-08-05)](https://github.com/jordinbrouwer/AutomaticRoleCheck/compare/1.11.0...2.0.0)

### Fixed
- Check for the enabled state of the addon on acceptance of the role check.

### Added
- Added an option to disable the addon whilst being AFK.
- Added an icon to identify the addon in the Addons option screen.

### Changed
- Adapted the color of the commands to be corresponding with the logo color.

## [1.11.0 (2024-08-04)](https://github.com/jordinbrouwer/AutomaticRoleCheck/compare/1.10.0...1.11.0)

### Fixed
- Capability with new changes to the WoW Settings API.

### Added
- Added a feature to disable first role check upon each login.
- Added a command to open the options for the addon.

### Changed
- Restructured the command list with more fitting naming.
- Bumped version due to new patch.

## [1.10.0 (2024-06-10)](https://github.com/jordinbrouwer/AutomaticRoleCheck/compare/1.9.0...1.10.0)

### Fixed
- Issue with populating the options panel (@rodrigodias4).

### Changed
- Bumped version due to new patch.

## [1.9.0 (2024-02-13)](https://github.com/jordinbrouwer/AutomaticRoleCheck/compare/1.8.0...1.9.0)

### Changed
- Bumped version due to new patch.

## [1.8.0 (2023-12-18)](https://github.com/jordinbrouwer/AutomaticRoleCheck/compare/1.7.0...1.8.0)

### Changed
- Bumped version due to new patch.

## [1.7.0 (2023-08-08)](https://github.com/jordinbrouwer/AutomaticRoleCheck/compare/1.6.0...1.7.0)

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

## [1.6.0 (2023-05-22)](https://github.com/jordinbrouwer/AutomaticRoleCheck/compare/1.5.0...1.6.0)

### Changed
- Bumped version due to new patch.

## [1.5.0 (2023-01-10)](https://github.com/jordinbrouwer/AutomaticRoleCheck/compare/1.4.0...1.5.0)

### Changed
- Bumped version due to new patch.

## [1.4.0 (2022-06-13)](https://github.com/jordinbrouwer/AutomaticRoleCheck/compare/1.3.0...1.4.0)

### Changed
- Bumped version due to new patch.

## [1.3.0 (2022-02-28)](https://github.com/jordinbrouwer/AutomaticRoleCheck/compare/1.2.3...1.3.0)

### Changed
- Bumped version due to new patch.

## [1.2.4 (2021-12-15)](https://github.com/jordinbrouwer/AutomaticRoleCheck/compare/1.2.3...1.2.4)

### Added
- Added LICENSE for the project.

### Changed
- Updated `.editorconfig`, `.gitattributes` and `.gitignore`.

## [1.2.3 (2021-10-28)](https://github.com/jordinbrouwer/AutomaticRoleCheck/compare/1.2.2...1.2.3)

### Changed
- Bumped version due to new patch.

## [1.2.2 (2021-10-28)](https://github.com/jordinbrouwer/AutomaticRoleCheck/compare/1.2.1...1.2.2)

### Added
- Added `.gitattributes`, `.editorconfig` and `CHANGELOG.md`.

## [1.2.1 (2021-07-04)](https://github.com/jordinbrouwer/AutomaticRoleCheck/compare/1.2.0...1.2.1)

### Changed
- Bumped version due to new patch.

## [1.2.0 (2021-03-01)](https://github.com/jordinbrouwer/AutomaticRoleCheck/compare/1.1.0...1.2.0)

### Added
- Added support to disable the addon once.

### Changed
- Changed the general command to also display whether the addon is enabled or not.
- Changed the tooltips to be more precise.

## [1.1.0 (2021-02-22)](https://github.com/jordinbrouwer/AutomaticRoleCheck/compare/1.0.0...1.1.0)

### Added
- Added support to enable and disable the addon using commands.
- Added support to enable and disable the addon the interface options.

## 1.0.0 (2021-02-18)

Initial setup of the project which contains constants enumerating the HTTP Status Codes.