# Claude Code Sounds

Configurable sound notifications for Claude Code via hooks. macOS only (afplay, say, jq, bc).

## Architecture

Single dispatcher shell script (`dispatcher.sh`) called by all Claude Code hooks. Reads `sounds-config.json` for event→sound mappings. Companion CLI (`claude-sounds`) controls muting. Install/uninstall scripts handle setup non-destructively.

## File Ownership

| File | Responsibility |
|------|---------------|
| `dispatcher.sh` | Hook entry point — mute checks, debounce, afplay/say playback |
| `claude-sounds` | CLI — on/off/status/mute/unmute/test/list/config/reset |
| `sounds-config.default.json` | Default config with all 29 events |
| `install.sh` | One-line installer, non-destructive hook merging |
| `uninstall.sh` | Clean removal with hook cleanup |
| `tests/test-helper.sh` | Test framework — sandbox, mocks, assertions |
| `tests/test-dispatcher.sh` | Dispatcher tests (12 tests) |
| `tests/test-cli.sh` | CLI tests (14 tests) |
| `tests/test-install.sh` | Install/uninstall tests (7 tests) |
| `tests/run-all.sh` | Runs all test suites |

## Conventions

- **Shell style:** POSIX-compatible bash. All scripts start with `#!/bin/bash`.
- **Testability:** Scripts read `CLAUDE_SOUNDS_DIR` env var (defaults to `~/.claude/sounds`). Tests override this to a temporary sandbox.
- **Error handling:** Dispatcher always exits 0 — never blocks Claude Code. CLI exits 1 on user errors with helpful messages.
- **Config:** JSON parsed with `jq`. Volume math with `bc`. Both pre-installed on macOS.

## Git

- Conventional commits: `type(scope): description`
- No AI attribution in commits or code
- Branch off `main`, PR for non-trivial changes

## Quality Gates

Before claiming work is done, run:

```bash
make check
```

This runs: tests + shellcheck + JSON validation. All three must pass.

Individual gates:
- `make test` — run all test suites
- `make lint` — shellcheck on all .sh files
- `make validate` — jq validation on JSON config files
