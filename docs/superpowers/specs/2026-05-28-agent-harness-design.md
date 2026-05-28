# Agent Harness — Design Spec

**Date:** 2026-05-28
**Status:** Approved
**Scope:** Minimal viable harness for solo Claude Code sessions

## Overview

A bare-essentials agent harness for the `claude-code-sounds` project. Three files: `CLAUDE.md` + `AGENTS.md` (byte-identical) for project context, `.claude/settings.json` for permissions, and a `Makefile` for quality gates.

## Goals

- Give Claude Code agents full project context without reading every file
- Pre-approve common commands to reduce permission prompts
- Single `make check` command that runs tests + shellcheck + JSON validation
- No agents, teams, commands, or skills — just config that earns its place

## Files

### CLAUDE.md + AGENTS.md (byte-identical)

Root-level project documentation covering:
- Project overview (one sentence)
- Architecture (dispatcher + CLI + config pattern)
- File ownership table (10 files, one row each)
- Conventions (shell style, testability via CLAUDE_SOUNDS_DIR, error handling, config tooling)
- Git rules (conventional commits, no AI attribution)
- Quality gates (`make check` with individual `make test`, `make lint`, `make validate`)

### .claude/settings.json

Project-scoped permissions:

```json
{
  "permissions": {
    "allow": [
      "Bash(bash tests/*)",
      "Bash(bash tests/run-all.sh)",
      "Bash(shellcheck *)",
      "Bash(jq *)",
      "Bash(make *)",
      "Bash(git status*)",
      "Bash(git log*)",
      "Bash(git diff*)"
    ]
  }
}
```

### Makefile

```makefile
.PHONY: test lint validate check

test:
	bash tests/run-all.sh

lint:
	shellcheck dispatcher.sh claude-sounds install.sh uninstall.sh

validate:
	jq empty sounds-config.default.json

check: validate lint test
```

Execution order: validate (instant) → lint (fast) → test (slowest). Fails fast on cheapest check.

## What's Explicitly Not Included

- No agent definitions (`.claude/agents/`)
- No team blueprints (`.claude/teams/`)
- No custom commands (`.claude/commands/`)
- No custom skills (`.claude/skills/`)
- No harness directory with evals/graders
- No SessionStart hooks
- No memory system
- No scoped CLAUDE.md in subdirectories

These can be added later if the project grows. For a shell-script CLI tool with 3 main files and 33 tests, this harness is sufficient.
