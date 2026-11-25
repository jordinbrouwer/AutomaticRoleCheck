# Contributing

Contributions are welcome.

## How to contribute

1. Fork the repository and create a branch from `master`.
2. Make one feature or fix per pull request, and follow the existing code style.
3. Run the checks (see below).
4. Open a pull request against `master`. The checks run on it automatically.

## Guidelines

- Write commits as [Conventional Commits](https://www.conventionalcommits.org/): `feat: ...`, `fix: ...`, `docs: ...`. Write the description for players, because it becomes the changelog line.
- Don't change `CHANGELOG.md` or version numbers; that happens automatically when a release is made.
- Everything that ships with the addon lives in `src/`. Keep the `.toc` file list in load order.
- To test in game, link `src/` into your AddOns folder as `AutomaticRoleCheck`.

## Code layout

Everything is in `src/`; the load order is in `src/AutomaticRoleCheck.toc`.

- `src/Locale/enUS.lua`: all texts the player sees (`L("key")`; a missing key shows the key itself).
- `src/Core/`: the addon itself.
  - `Core.lua`: the shared table, picture paths, messages (as toasts) and `ARC.On("EVENT", fn)` for game events.
  - `Options.lua`: defaults, `ARC.SetOption`, and tidying the saved settings (`DB_VERSION`).
  - `Sound.lua`: muting the game's ready-check sound and playing the chosen sounds.
  - `Roles.lua`: your specialization and the roles you queue as.
  - `Accept.lua`: accepting the popups, also in combat (waiting for combat to end).
  - `Minimap.lua`: the minimap button.
  - `Command.lua`: the `/arc` commands.
- `src/UI/`: the options window; every file takes its tools from the `UI` table.
  - `Base.lua` (colours, sizes, shared state), `Widgets.lua`, `Tooltip.lua`, `Toast.lua` (messages), `Data.lua` (choices of the settings), `Controls.lua`, `RoleButtons.lua`, `Layout.lua` (which settings show, flow layout), `Scroll.lua`, `Groups.lua`, `TableBox.lua` ("When it is accepted"), `MinimapBox.lua` ("Minimap button"), `TopStrip.lua` ("Enabled" and "My role"), `Canvas.lua` (puts the boxes together), `Window.lua` (header, close, resize grip) and `SettingsPage.lua` (the page in the game's settings).
- `src/Media/`: the addon's own `.tga` pictures (`ARC.Media.*` gives the paths).

Rules of thumb:

- Colours and sizes live in `src/UI/Base.lua`, texts in `src/Locale/enUS.lua`, picture paths in `src/Core/Core.lua`.
- A setting is added in `src/Core/Options.lua` (default), `src/UI/Canvas.lua` (where it shows) and the locale.
- Renamed or removed settings go in `OBSOLETE_KEYS` in `src/Core/Options.lua`, and raise `DB_VERSION`.

## Checks

The checks live in [wow-addon-ci](https://github.com/jordinbrouwer/wow-addon-ci). Clone it next to this repository; it needs Python 3 and `luacheck`. From this repository's root:

- `python3 ../wow-addon-ci/scripts/checks/run.py quick`: fast structural checks.
- `python3 ../wow-addon-ci/scripts/checks/run.py`: everything CI runs.

Checks for this addon only live in `.github/checks/`: `commands` (slash command registration and help) and `readme` (every command is in the README). CI runs them next to the shared checks.

## Releases (maintainers)

A `feat`, `fix` or breaking commit in `src/` on `master` releases automatically: the pipeline writes the changelog, tags the version and publishes it to GitHub and CurseForge. **Actions > Pipeline > Run workflow** on `master` can force a `patch`, `minor` or `major` release.

Descriptions, website and images on GitHub and CurseForge can only be changed on their websites. The pipeline compares them with the code and, when they differ, shows a warning and a summary with what to paste.

Repository setup:

- Secrets `CF_API_TOKEN` and `CF_PROJECT_ID` for the CurseForge upload.
- `github-actions` must be allowed to push to `master` (for the release commit and the README release block).
