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
