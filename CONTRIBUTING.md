# Contributing

Contributions are welcome and appreciated.

## Development guidelines

- Create feature branches. Do not work directly on `master`.
- Keep each change focused on one feature or fix.
- Keep commits meaningful and history clean.
- Follow the existing code style in this repository.
- Keep changes simple and avoid unnecessary complexity.
- Document intentional behavior changes in `README.md`, `CHANGELOG.md`, or this file.

## Run checks locally

Use these before opening a PR:

- Fast structural pass:
  - `bash ./scripts/check.sh quick`
- Full check suite:
  - `bash ./scripts/check.sh all`
- Individual modes:
  - `bash ./scripts/check.sh --help`
