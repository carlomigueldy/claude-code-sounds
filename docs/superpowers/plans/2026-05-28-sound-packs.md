# Sound Packs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add installable, switchable sound packs to claude-code-sounds, shipping the Peon (Warcraft III) pack as the first built-in pack.

**Architecture:** Each pack is a directory under `packs/<name>/` containing a `pack.json` manifest (metadata + event-to-sound mappings) and an `audio/` directory with sound files. The CLI gains a `pack` subcommand (list/install/active) that validates packs, generates configs from manifests, and tracks the active pack in `state.json`. The installer copies built-in packs to the installed location.

**Tech Stack:** Bash, jq, afplay (macOS)

---

## File Structure

| File | Responsibility |
|------|---------------|
| `packs/peon/pack.json` | Peon pack manifest — metadata + all 29 event mappings with relative sound paths |
| `packs/peon/audio/*.mp3` | 26 Peon MP3 audio files |
| `claude-sounds` | CLI script — gains `pack list`, `pack install`, `pack active` subcommands + updated `reset` |
| `install.sh` | Installer — gains packs directory copy step |
| `uninstall.sh` | Uninstaller — gains packs cleanup |
| `tests/test-packs.sh` | Pack management test suite |
| `Makefile` | Quality gates — gains pack.json validation |
| `README.md` | User docs — gains sound packs section |
| `docs/CUSTOMIZING.md` | Customization docs — gains pack usage section |

---

### Task 1: Create Peon Pack Bundle

**Files:**
- Create: `packs/peon/pack.json`
- Create: `packs/peon/audio/*.mp3` (26 files, copied from `~/.claude/sounds/audio/peon/`)

- [ ] **Step 1: Create the pack directory and copy audio files**

```bash
mkdir -p packs/peon/audio
cp ~/.claude/sounds/audio/peon/*.mp3 packs/peon/audio/
```

- [ ] **Step 2: Create pack.json**

Create `packs/peon/pack.json` with this exact content:

```json
{
  "name": "peon",
  "description": "Warcraft III Peon voice lines",
  "version": "1.0.0",
  "categories": {
    "completion": { "enabled": true },
    "attention": { "enabled": true },
    "lifecycle": { "enabled": true },
    "progress": { "enabled": true },
    "input": { "enabled": true },
    "context": { "enabled": true }
  },
  "events": {
    "Stop": {
      "enabled": true,
      "category": "completion",
      "type": "audio",
      "sound": "zug-zug.mp3",
      "volume": 0.7,
      "debounce_ms": 2000
    },
    "TaskCompleted": {
      "enabled": true,
      "category": "completion",
      "type": "audio",
      "sound": "be-happy-to.mp3",
      "volume": 0.7,
      "debounce_ms": 2000
    },
    "SubagentStop": {
      "enabled": true,
      "category": "completion",
      "type": "audio",
      "sound": "i-can-do-that.mp3",
      "volume": 0.7,
      "debounce_ms": 2000
    },
    "SessionEnd": {
      "enabled": true,
      "category": "completion",
      "type": "audio",
      "sound": "ok.mp3",
      "volume": 0.7,
      "debounce_ms": 2000
    },
    "PermissionRequest": {
      "enabled": true,
      "category": "attention",
      "type": "audio",
      "sound": "what-do-you-want.mp3",
      "volume": 0.9,
      "debounce_ms": 2000
    },
    "StopFailure": {
      "enabled": true,
      "category": "attention",
      "type": "audio",
      "sound": "ugh-splat.mp3",
      "volume": 0.9,
      "debounce_ms": 2000
    },
    "PostToolUseFailure": {
      "enabled": true,
      "category": "attention",
      "type": "audio",
      "sound": "my-tummy-feels-funny.mp3",
      "volume": 0.9,
      "debounce_ms": 2000
    },
    "PermissionDenied": {
      "enabled": true,
      "category": "attention",
      "type": "audio",
      "sound": "me-not-that-kind-of-orc.mp3",
      "volume": 0.9,
      "debounce_ms": 2000
    },
    "TeammateIdle": {
      "enabled": true,
      "category": "attention",
      "type": "audio",
      "sound": "no-time-for-play.mp3",
      "volume": 0.9,
      "debounce_ms": 2000
    },
    "SessionStart": {
      "enabled": true,
      "category": "lifecycle",
      "type": "audio",
      "sound": "ready-to-work.mp3",
      "volume": 0.5,
      "debounce_ms": 2000
    },
    "Setup": {
      "enabled": true,
      "category": "lifecycle",
      "type": "audio",
      "sound": "something-need-doing.mp3",
      "volume": 0.5,
      "debounce_ms": 2000
    },
    "SubagentStart": {
      "enabled": true,
      "category": "lifecycle",
      "type": "audio",
      "sound": "ill-try.mp3",
      "volume": 0.5,
      "debounce_ms": 2000
    },
    "WorktreeCreate": {
      "enabled": true,
      "category": "lifecycle",
      "type": "audio",
      "sound": "we-need-more-gold.mp3",
      "volume": 0.5,
      "debounce_ms": 2000
    },
    "WorktreeRemove": {
      "enabled": true,
      "category": "lifecycle",
      "type": "audio",
      "sound": "kill-them.mp3",
      "volume": 0.5,
      "debounce_ms": 2000
    },
    "InstructionsLoaded": {
      "enabled": true,
      "category": "lifecycle",
      "type": "audio",
      "sound": "yes.mp3",
      "volume": 0.5,
      "debounce_ms": 2000
    },
    "PostToolUse": {
      "enabled": true,
      "category": "progress",
      "type": "audio",
      "sound": "work-work.mp3",
      "volume": 0.3,
      "debounce_ms": 3000
    },
    "PostToolBatch": {
      "enabled": true,
      "category": "progress",
      "type": "audio",
      "sound": "okie-dokey.mp3",
      "volume": 0.3,
      "debounce_ms": 3000
    },
    "PreCompact": {
      "enabled": true,
      "category": "progress",
      "type": "audio",
      "sound": "me-busy.mp3",
      "volume": 0.3,
      "debounce_ms": 3000
    },
    "PostCompact": {
      "enabled": true,
      "category": "progress",
      "type": "audio",
      "sound": "why-not.mp3",
      "volume": 0.3,
      "debounce_ms": 3000
    },
    "UserPromptSubmit": {
      "enabled": true,
      "category": "input",
      "type": "audio",
      "sound": "hmm.mp3",
      "volume": 0.5,
      "debounce_ms": 2000
    },
    "UserPromptExpansion": {
      "enabled": true,
      "category": "input",
      "type": "audio",
      "sound": "look.mp3",
      "volume": 0.5,
      "debounce_ms": 2000
    },
    "Notification": {
      "enabled": true,
      "category": "input",
      "type": "audio",
      "sound": "what.mp3",
      "volume": 0.5,
      "debounce_ms": 2000
    },
    "Elicitation": {
      "enabled": true,
      "category": "input",
      "type": "audio",
      "sound": "what-do-you-want.mp3",
      "volume": 0.5,
      "debounce_ms": 2000
    },
    "ElicitationResult": {
      "enabled": true,
      "category": "input",
      "type": "audio",
      "sound": "ohh.mp3",
      "volume": 0.5,
      "debounce_ms": 2000
    },
    "MessageDisplay": {
      "enabled": true,
      "category": "input",
      "type": "audio",
      "sound": "double.mp3",
      "volume": 0.5,
      "debounce_ms": 2000
    },
    "CwdChanged": {
      "enabled": true,
      "category": "context",
      "type": "audio",
      "sound": "look.mp3",
      "volume": 0.3,
      "debounce_ms": 3000
    },
    "FileChanged": {
      "enabled": true,
      "category": "context",
      "type": "audio",
      "sound": "hmm.mp3",
      "volume": 0.3,
      "debounce_ms": 3000
    },
    "ConfigChange": {
      "enabled": true,
      "category": "context",
      "type": "audio",
      "sound": "swobu.mp3",
      "volume": 0.3,
      "debounce_ms": 3000
    },
    "PreToolUse": {
      "enabled": true,
      "category": "context",
      "type": "audio",
      "sound": "leave-me-alone.mp3",
      "volume": 0.3,
      "debounce_ms": 3000
    }
  }
}
```

- [ ] **Step 3: Validate the pack.json**

Run: `jq empty packs/peon/pack.json`

Expected: exit 0, no output (valid JSON)

- [ ] **Step 4: Verify audio file count**

Run: `ls packs/peon/audio/*.mp3 | wc -l`

Expected: `26`

- [ ] **Step 5: Commit**

```bash
git add packs/peon/pack.json packs/peon/audio/
git commit -m "feat(packs): add Peon sound pack bundle"
```

---

### Task 2: CLI `pack list` Command (TDD)

**Files:**
- Create: `tests/test-packs.sh`
- Modify: `claude-sounds`

- [ ] **Step 1: Create test file with pack sandbox helper and failing `pack list` test**

Create `tests/test-packs.sh`:

```bash
#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/test-helper.sh"
CLI="$PROJECT_DIR/claude-sounds"
PACKS_DIR=""

setup_pack_sandbox() {
  setup_sandbox
  PACKS_DIR="$SANDBOX/packs"
  cp "$PROJECT_DIR/sounds-config.default.json" "$SANDBOX/sounds-config.default.json"
}

create_test_pack() {
  local name="${1:-test-pack}"
  local desc="${2:-A test pack}"
  mkdir -p "$PACKS_DIR/$name/audio"
  echo "fake audio" > "$PACKS_DIR/$name/audio/beep.mp3"
  cat > "$PACKS_DIR/$name/pack.json" << PACK
{
  "name": "$name",
  "description": "$desc",
  "version": "1.0.0",
  "events": {
    "Stop": {
      "enabled": true,
      "category": "completion",
      "type": "audio",
      "sound": "beep.mp3",
      "volume": 0.7,
      "debounce_ms": 2000
    }
  }
}
PACK
}

test_pack_list_shows_packs() {
  create_test_pack "test-pack" "A test pack"
  local output
  output=$(bash "$CLI" pack list)
  assert_contains "shows pack name" "$output" "test-pack"
  assert_contains "shows description" "$output" "A test pack"
  assert_contains "shows version" "$output" "1.0.0"
}

test_pack_list_empty() {
  mkdir -p "$PACKS_DIR"
  local output
  output=$(bash "$CLI" pack list)
  assert_contains "shows no packs message" "$output" "No packs"
}

echo "=== Pack management ==="
run_test "pack list shows packs" test_pack_list_shows_packs
run_test "pack list empty" test_pack_list_empty
report
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bash tests/test-packs.sh`

Expected: FAIL — `pack` is not a recognized command yet.

- [ ] **Step 3: Add `pack list` to the CLI**

In `claude-sounds`, add the `PACKS_DIR` variable near the top (after `DISPATCHER`), the `cmd_pack_list` function, the `cmd_pack` dispatcher, and the `pack)` case:

Add after line 8 (`DISPATCHER="$SOUNDS_DIR/dispatcher.sh"`):

```bash
PACKS_DIR="$SOUNDS_DIR/packs"
```

Add the `cmd_pack_list` function before the `case` statement:

```bash
cmd_pack_list() {
  if [ ! -d "$PACKS_DIR" ] || [ -z "$(ls -A "$PACKS_DIR" 2>/dev/null)" ]; then
    echo "No packs available."
    return
  fi
  echo "Available packs:"
  for pack_dir in "$PACKS_DIR"/*/; do
    [ -d "$pack_dir" ] || continue
    local pack_json="$pack_dir/pack.json"
    [ -f "$pack_json" ] || continue
    local name desc version
    name=$(jq -r '.name' "$pack_json")
    desc=$(jq -r '.description' "$pack_json")
    version=$(jq -r '.version' "$pack_json")
    printf "  %-12s %s (v%s)\n" "$name" "$desc" "$version"
  done
}

cmd_pack() {
  local subcmd="${1:-}"
  case "$subcmd" in
    list) cmd_pack_list ;;
    *)
      echo "Usage: claude-sounds pack <list|install|active>"
      echo ""
      echo "Commands:"
      echo "  list                  List available sound packs"
      echo "  install <name>        Install a sound pack"
      echo "  install default       Restore default config"
      echo "  active                Show currently active pack"
      exit 1
      ;;
  esac
}
```

Add to the `case` statement (before the `*` catch-all):

```bash
  pack) cmd_pack "${2:-}" "${3:-}" ;;
```

Update the help text in the `*` catch-all to include the `pack` command:

```
    echo "  pack <subcommand>     Manage sound packs"
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `bash tests/test-packs.sh`

Expected: 2 tests, all PASS

- [ ] **Step 5: Run all existing tests to check for regressions**

Run: `make check`

Expected: All tests pass, shellcheck clean, JSON valid.

- [ ] **Step 6: Commit**

```bash
git add tests/test-packs.sh claude-sounds
git commit -m "feat(cli): add pack list command"
```

---

### Task 3: CLI `pack install` Command (TDD)

**Files:**
- Modify: `tests/test-packs.sh`
- Modify: `claude-sounds`

- [ ] **Step 1: Add failing tests for `pack install`**

Append these test functions and run_test calls to `tests/test-packs.sh` (before the `report` line):

```bash
test_pack_install_copies_audio() {
  create_test_pack
  bash "$CLI" pack install test-pack
  assert_file_exists "audio copied" "$SANDBOX/audio/test-pack/beep.mp3"
}

test_pack_install_generates_config() {
  create_test_pack
  bash "$CLI" pack install test-pack
  local sound_path
  sound_path=$(jq -r '.events.Stop.sound' "$SANDBOX/sounds-config.json")
  assert_eq "sound path rewritten" "audio/test-pack/beep.mp3" "$sound_path"
}

test_pack_install_preserves_default_events() {
  create_test_pack
  bash "$CLI" pack install test-pack
  local session_start_type
  session_start_type=$(jq -r '.events.SessionStart.type' "$SANDBOX/sounds-config.json")
  assert_eq "default event preserved" "tts" "$session_start_type"
}

test_pack_install_uses_pack_categories() {
  create_test_pack
  # Add categories to the pack
  jq '.categories = {"completion":{"enabled":true},"attention":{"enabled":true},"lifecycle":{"enabled":true},"progress":{"enabled":true},"input":{"enabled":true},"context":{"enabled":true}}' \
    "$PACKS_DIR/test-pack/pack.json" > "$PACKS_DIR/test-pack/pack.json.tmp" \
    && mv "$PACKS_DIR/test-pack/pack.json.tmp" "$PACKS_DIR/test-pack/pack.json"
  bash "$CLI" pack install test-pack
  local progress_enabled
  progress_enabled=$(jq -r '.categories.progress.enabled' "$SANDBOX/sounds-config.json")
  assert_eq "pack category overrides default" "true" "$progress_enabled"
}

test_pack_install_saves_previous_config() {
  create_test_pack
  jq '.defaults.global_volume = 0.42' "$SANDBOX/sounds-config.json" > "$SANDBOX/tmp.json" \
    && mv "$SANDBOX/tmp.json" "$SANDBOX/sounds-config.json"
  bash "$CLI" pack install test-pack
  assert_file_exists "previous config saved" "$SANDBOX/sounds-config.custom.json"
  local saved_vol
  saved_vol=$(jq -r '.defaults.global_volume' "$SANDBOX/sounds-config.custom.json")
  assert_eq "saved config has original volume" "0.42" "$saved_vol"
}

test_pack_install_saves_as_pack_name_when_active() {
  create_test_pack "pack-a" "Pack A"
  create_test_pack "pack-b" "Pack B"
  bash "$CLI" pack install pack-a
  bash "$CLI" pack install pack-b
  assert_file_exists "pack-a config saved" "$SANDBOX/sounds-config.pack-a.json"
}

test_pack_install_updates_state() {
  create_test_pack
  bash "$CLI" pack install test-pack
  local active
  active=$(jq -r '.active_pack' "$SANDBOX/state.json")
  assert_eq "active pack set" "test-pack" "$active"
}

test_pack_install_default_restores() {
  create_test_pack
  bash "$CLI" pack install test-pack
  bash "$CLI" pack install default
  local vol
  vol=$(jq -r '.defaults.global_volume' "$SANDBOX/sounds-config.json")
  assert_eq "default config restored" "1" "$vol"
}

test_pack_install_default_clears_state() {
  create_test_pack
  bash "$CLI" pack install test-pack
  bash "$CLI" pack install default
  local active
  active=$(jq -r '.active_pack // "none"' "$SANDBOX/state.json")
  assert_eq "active pack cleared" "none" "$active"
}

test_pack_install_default_saves_pack_config() {
  create_test_pack
  bash "$CLI" pack install test-pack
  bash "$CLI" pack install default
  assert_file_exists "pack config saved before restoring default" "$SANDBOX/sounds-config.test-pack.json"
}

test_pack_switch_restores_saved_config() {
  create_test_pack "pack-a" "Pack A"
  bash "$CLI" pack install pack-a
  # Customize config while pack-a is active
  jq '.defaults.global_volume = 0.77' "$SANDBOX/sounds-config.json" > "$SANDBOX/tmp.json" \
    && mv "$SANDBOX/tmp.json" "$SANDBOX/sounds-config.json"
  bash "$CLI" pack install default
  # Switch back to pack-a — should restore the customized config
  bash "$CLI" pack install pack-a
  local vol
  vol=$(jq -r '.defaults.global_volume' "$SANDBOX/sounds-config.json")
  assert_eq "restored saved config with customization" "0.77" "$vol"
}
```

Add these run_test calls before `report`:

```bash
run_test "pack install copies audio" test_pack_install_copies_audio
run_test "pack install generates config" test_pack_install_generates_config
run_test "pack install preserves default events" test_pack_install_preserves_default_events
run_test "pack install uses pack categories" test_pack_install_uses_pack_categories
run_test "pack install saves previous config" test_pack_install_saves_previous_config
run_test "pack install saves as pack name when active" test_pack_install_saves_as_pack_name_when_active
run_test "pack install updates state" test_pack_install_updates_state
run_test "pack install default restores" test_pack_install_default_restores
run_test "pack install default clears state" test_pack_install_default_clears_state
run_test "pack install default saves pack config" test_pack_install_default_saves_pack_config
run_test "pack switch restores saved config" test_pack_switch_restores_saved_config
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `bash tests/test-packs.sh`

Expected: `pack list` tests pass, all `pack install` tests FAIL.

- [ ] **Step 3: Implement `pack install` in the CLI**

Add these functions to `claude-sounds` (after `cmd_pack_list`, before `cmd_pack`):

```bash
cmd_pack_install() {
  local pack_name="${1:-}"
  if [ -z "$pack_name" ]; then
    echo "Usage: claude-sounds pack install <name|default>"
    exit 1
  fi

  ensure_state

  if [ "$pack_name" = "default" ]; then
    cmd_pack_install_default
    return
  fi

  local pack_dir="$PACKS_DIR/$pack_name"
  local pack_json="$pack_dir/pack.json"

  if [ ! -d "$pack_dir" ]; then
    echo "Error: pack '$pack_name' not found. Run 'claude-sounds pack list' to see available packs."
    exit 1
  fi
  if [ ! -f "$pack_json" ]; then
    echo "Error: pack '$pack_name' is invalid: missing pack.json"
    exit 1
  fi

  # Validate all referenced audio files exist
  local missing_files=()
  while IFS= read -r sound_file; do
    if [ ! -f "$pack_dir/audio/$sound_file" ]; then
      missing_files+=("$sound_file")
    fi
  done < <(jq -r '.events[].sound // empty' "$pack_json")

  if [ ${#missing_files[@]} -gt 0 ]; then
    echo "Error: pack '$pack_name' is invalid: missing audio file '${missing_files[0]}' referenced in pack.json"
    exit 1
  fi

  # Save current config
  local current_pack
  current_pack=$(jq -r '.active_pack // empty' "$STATE")
  if [ -n "$current_pack" ]; then
    cp "$CONFIG" "$SOUNDS_DIR/sounds-config.$current_pack.json"
  else
    cp "$CONFIG" "$SOUNDS_DIR/sounds-config.custom.json"
  fi

  # Check for previously saved config for this pack
  local saved_config="$SOUNDS_DIR/sounds-config.$pack_name.json"
  if [ -f "$saved_config" ]; then
    cp "$saved_config" "$CONFIG"
  else
    # Generate config from pack manifest + defaults
    local new_config
    new_config=$(jq --arg pack "$pack_name" --slurpfile pd "$pack_json" '
      # Use pack categories if present, otherwise keep defaults
      (if $pd[0].categories then $pd[0].categories else .categories end) as $cats |
      # Rewrite pack event sound paths
      ($pd[0].events | to_entries | map(.value.sound = "audio/\($pack)/\(.value.sound)") | from_entries) as $pack_events |
      {
        version: .version,
        defaults: .defaults,
        categories: $cats,
        events: (.events + $pack_events)
      }
    ' "$DEFAULT_CONFIG")
    echo "$new_config" > "$CONFIG"
  fi

  # Copy audio files
  mkdir -p "$SOUNDS_DIR/audio/$pack_name"
  cp "$pack_dir/audio/"* "$SOUNDS_DIR/audio/$pack_name/" 2>/dev/null || true

  # Update state
  jq --arg p "$pack_name" '.active_pack = $p' "$STATE" > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"

  local sound_count
  sound_count=$(ls "$pack_dir/audio/" 2>/dev/null | wc -l | tr -d ' ')
  echo "Installed pack '$pack_name' ($sound_count sounds). Previous config saved."
}

cmd_pack_install_default() {
  if [ ! -f "$DEFAULT_CONFIG" ]; then
    echo "Default config not found at $DEFAULT_CONFIG"
    exit 1
  fi

  ensure_state

  # Save current config under active pack name
  local current_pack
  current_pack=$(jq -r '.active_pack // empty' "$STATE")
  if [ -n "$current_pack" ] && [ -f "$CONFIG" ]; then
    cp "$CONFIG" "$SOUNDS_DIR/sounds-config.$current_pack.json"
  fi

  cp "$DEFAULT_CONFIG" "$CONFIG"
  jq 'del(.active_pack)' "$STATE" > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"

  local saved_as=""
  if [ -n "$current_pack" ]; then
    saved_as=" Previous config saved as $current_pack."
  fi
  echo "Restored default config.$saved_as"
}
```

Add `install` to `cmd_pack`'s case statement:

```bash
    install) cmd_pack_install "${2:-}" ;;
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `bash tests/test-packs.sh`

Expected: All 13 tests PASS.

- [ ] **Step 5: Run all tests for regressions**

Run: `make check`

Expected: All pass.

- [ ] **Step 6: Commit**

```bash
git add tests/test-packs.sh claude-sounds
git commit -m "feat(cli): add pack install command with config switching"
```

---

### Task 4: CLI `pack active` and Error Handling (TDD)

**Files:**
- Modify: `tests/test-packs.sh`
- Modify: `claude-sounds`

- [ ] **Step 1: Add failing tests for `pack active` and error cases**

Append these test functions to `tests/test-packs.sh` (before `report`):

```bash
test_pack_active_shows_pack() {
  create_test_pack
  bash "$CLI" pack install test-pack
  local output
  output=$(bash "$CLI" pack active)
  assert_contains "shows pack name" "$output" "test-pack"
  assert_contains "shows version" "$output" "1.0.0"
}

test_pack_active_no_pack() {
  local output
  output=$(bash "$CLI" pack active)
  assert_contains "shows no pack" "$output" "No pack active"
}

test_pack_install_invalid_name() {
  local output exit_code=0
  output=$(bash "$CLI" pack install nonexistent 2>&1) || exit_code=$?
  assert_contains "shows error" "$output" "not found"
}

test_pack_install_missing_audio() {
  create_test_pack "broken"
  # Reference a file that doesn't exist
  jq '.events.Stop.sound = "missing.mp3"' "$PACKS_DIR/broken/pack.json" > "$PACKS_DIR/broken/pack.json.tmp" \
    && mv "$PACKS_DIR/broken/pack.json.tmp" "$PACKS_DIR/broken/pack.json"
  local output exit_code=0
  output=$(bash "$CLI" pack install broken 2>&1) || exit_code=$?
  assert_contains "shows missing audio error" "$output" "missing audio file"
}

test_pack_install_missing_pack_json() {
  mkdir -p "$PACKS_DIR/no-manifest/audio"
  echo "fake" > "$PACKS_DIR/no-manifest/audio/beep.mp3"
  local output exit_code=0
  output=$(bash "$CLI" pack install no-manifest 2>&1) || exit_code=$?
  assert_contains "shows missing pack.json error" "$output" "missing pack.json"
}
```

Add these run_test calls before `report`:

```bash
run_test "pack active shows pack" test_pack_active_shows_pack
run_test "pack active no pack" test_pack_active_no_pack
run_test "pack install invalid name" test_pack_install_invalid_name
run_test "pack install missing audio" test_pack_install_missing_audio
run_test "pack install missing pack.json" test_pack_install_missing_pack_json
```

- [ ] **Step 2: Run tests to verify new tests fail**

Run: `bash tests/test-packs.sh`

Expected: `pack active` tests fail (not implemented yet). Error case tests may pass since validation was added in Task 3.

- [ ] **Step 3: Implement `pack active` in the CLI**

Add this function to `claude-sounds` (after `cmd_pack_install_default`, before `cmd_pack`):

```bash
cmd_pack_active() {
  ensure_state
  local active
  active=$(jq -r '.active_pack // empty' "$STATE")
  if [ -z "$active" ]; then
    echo "No pack active (using default config)"
    return
  fi
  local pack_json="$PACKS_DIR/$active/pack.json"
  if [ -f "$pack_json" ]; then
    local version
    version=$(jq -r '.version' "$pack_json")
    echo "Active pack: $active (v$version)"
  else
    echo "Active pack: $active"
  fi
}
```

Add `active` to `cmd_pack`'s case statement:

```bash
    active) cmd_pack_active ;;
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `bash tests/test-packs.sh`

Expected: All 18 tests PASS.

- [ ] **Step 5: Run all tests for regressions**

Run: `make check`

Expected: All pass.

- [ ] **Step 6: Commit**

```bash
git add tests/test-packs.sh claude-sounds
git commit -m "feat(cli): add pack active command and install validation"
```

---

### Task 5: Update Installer and Uninstaller

**Files:**
- Modify: `install.sh`
- Modify: `uninstall.sh`
- Modify: `tests/test-install.sh`

- [ ] **Step 1: Add failing test for packs directory installation**

Append this test function and run_test call to `tests/test-install.sh` (before `report`):

```bash
test_install_copies_packs() {
  setup_install_sandbox
  # Create a test pack in the source repo
  mkdir -p "$PROJECT_DIR/packs/test-pack/audio"
  echo '{"name":"test-pack","description":"Test","version":"1.0.0","events":{}}' > "$PROJECT_DIR/packs/test-pack/pack.json"
  echo "fake" > "$PROJECT_DIR/packs/test-pack/audio/beep.mp3"
  bash "$INSTALLER" --test
  assert_file_exists "pack.json copied" "$INSTALL_DIR/packs/test-pack/pack.json"
  assert_file_exists "audio copied" "$INSTALL_DIR/packs/test-pack/audio/beep.mp3"
  # Cleanup test pack from source
  rm -rf "$PROJECT_DIR/packs/test-pack"
  teardown_sandbox
}
```

Add before `report`:

```bash
run_test "install copies packs" test_install_copies_packs
```

- [ ] **Step 2: Run tests to verify the new test fails**

Run: `bash tests/test-install.sh`

Expected: FAIL — packs directory not copied.

- [ ] **Step 3: Update install.sh to copy packs directory**

Add after line 28 (`chmod +x ...`):

```bash
# Copy built-in packs (non-destructive: update existing, don't remove custom packs)
if [ -d "$SCRIPT_DIR/packs" ]; then
  for pack_dir in "$SCRIPT_DIR/packs"/*/; do
    [ -d "$pack_dir" ] || continue
    local_pack_name=$(basename "$pack_dir")
    mkdir -p "$INSTALL_DIR/packs/$local_pack_name"
    cp -R "$pack_dir"* "$INSTALL_DIR/packs/$local_pack_name/"
  done
  echo "  Copied built-in sound packs"
fi
```

- [ ] **Step 4: Update uninstall.sh**

The existing uninstall already offers to `rm -rf "$INSTALL_DIR"` which includes packs. No change needed — packs are inside the install dir and get cleaned up with everything else.

- [ ] **Step 5: Run tests to verify they pass**

Run: `bash tests/test-install.sh`

Expected: All 8 tests PASS.

- [ ] **Step 6: Run all tests for regressions**

Run: `make check`

Expected: All pass.

- [ ] **Step 7: Commit**

```bash
git add install.sh tests/test-install.sh
git commit -m "feat(install): copy built-in packs on install"
```

---

### Task 6: Update Reset, Makefile, and Help Text

**Files:**
- Modify: `claude-sounds`
- Modify: `Makefile`

- [ ] **Step 1: Update `cmd_reset` to clear active pack**

In `claude-sounds`, modify `cmd_reset` to add active pack cleanup. Add after the line `cp "$DEFAULT_CONFIG" "$CONFIG"`:

```bash
  ensure_state
  jq 'del(.active_pack)' "$STATE" > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"
```

- [ ] **Step 2: Update help text in the catch-all case**

Update the usage output in the `*` catch-all to include the `pack` command. Add this line after the `reset` help line:

```bash
    echo "  pack <subcommand>     Manage sound packs"
```

- [ ] **Step 3: Update Makefile to validate pack.json files**

Replace the `validate` target:

```makefile
validate:
	jq empty sounds-config.default.json
	@find packs -name pack.json -exec jq empty {} +
```

- [ ] **Step 4: Run all tests and quality gates**

Run: `make check`

Expected: All pass, including pack.json validation.

- [ ] **Step 5: Commit**

```bash
git add claude-sounds Makefile
git commit -m "fix(cli): clear active pack on reset, validate pack manifests"
```

---

### Task 7: Documentation

**Files:**
- Modify: `README.md`
- Modify: `docs/CUSTOMIZING.md`

- [ ] **Step 1: Add sound packs section to README.md**

Add after the "Custom Sounds" section (before "## Uninstall"):

```markdown
## Sound Packs

Sound packs bundle audio files with event mappings for one-command installation.

**List available packs:**

```bash
claude-sounds pack list
```

**Install a pack:**

```bash
claude-sounds pack install peon
```

**See what's active:**

```bash
claude-sounds pack active
```

**Switch back to defaults:**

```bash
claude-sounds pack install default
```

Switching packs saves your current config, so you can switch back without losing customizations.

### Built-in Packs

| Pack | Description |
|------|-------------|
| peon | Warcraft III Peon voice lines — 26 sounds across all 29 events |

### Custom Packs

Create your own pack by adding a directory to `~/.claude/sounds/packs/<name>/`:

```
packs/my-pack/
  pack.json        # manifest with event mappings
  audio/
    sound1.mp3
    sound2.mp3
```

See [docs/CUSTOMIZING.md](docs/CUSTOMIZING.md) for the pack manifest format.
```

Also update the Commands table to include:

```markdown
| `claude-sounds pack list` | List available sound packs |
| `claude-sounds pack install <name>` | Install a sound pack |
| `claude-sounds pack install default` | Restore default sounds |
| `claude-sounds pack active` | Show currently active pack |
```

- [ ] **Step 2: Add pack format section to docs/CUSTOMIZING.md**

Add at the end of the file:

```markdown
---

## Sound Packs

Sound packs provide pre-configured sound sets that replace all events at once.

### Using Packs

```bash
# List available packs
claude-sounds pack list

# Install a pack
claude-sounds pack install peon

# See what's active
claude-sounds pack active

# Switch back to defaults
claude-sounds pack install default
```

Installing a pack saves your current config. When you switch back later, your customizations are restored.

### Creating a Pack

A pack is a directory with a `pack.json` manifest and an `audio/` directory:

```
~/.claude/sounds/packs/my-pack/
  pack.json
  audio/
    chime.mp3
    alert.mp3
```

### pack.json Format

```json
{
  "name": "my-pack",
  "description": "My custom sound pack",
  "version": "1.0.0",
  "categories": {
    "completion": { "enabled": true },
    "attention": { "enabled": true },
    "lifecycle": { "enabled": true },
    "progress": { "enabled": false },
    "input": { "enabled": true },
    "context": { "enabled": false }
  },
  "events": {
    "Stop": {
      "enabled": true,
      "category": "completion",
      "type": "audio",
      "sound": "chime.mp3",
      "volume": 0.8,
      "debounce_ms": 2000
    }
  }
}
```

**Required fields:** `name`, `description`, `version`, `events`

**Optional fields:** `author`, `categories`

**Sound paths** are relative to the pack's `audio/` directory — use just the filename (e.g., `"chime.mp3"`, not `"audio/my-pack/chime.mp3"`). The CLI rewrites paths automatically during installation.

**Events not defined** in the pack fall back to the defaults from `sounds-config.default.json`.

**Categories** override the default category settings when present. Omit to keep defaults.
```

- [ ] **Step 3: Commit**

```bash
git add README.md docs/CUSTOMIZING.md
git commit -m "docs: add sound packs usage and pack creation guide"
```

- [ ] **Step 4: Run final quality gate**

Run: `make check`

Expected: All tests pass, shellcheck clean, all JSON valid.
