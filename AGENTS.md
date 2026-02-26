# AGENTS: homebrew-made

Public tap formulas for pkgx ecosystem tools.

## Core Commands

- `brew install --build-from-source ./pkgm.rb`
- `brew test pkgm`
- `brew audit pkgm`
- `brew install --build-from-source ./pkgx.rb`
- `brew test pkgx`
- `brew audit pkgx`

## Always Do

- Keep formula versions/checksums consistent with upstream releases.
- Validate formula install and test behavior in CI-compatible flow.

## Ask First

- Tap policy changes.
- Formula naming or ownership changes.

## Never Do

- Never merge formula updates without verification for affected formula.
- Never include internal-only release notes in formula commit messages.
