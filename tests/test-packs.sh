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
  setup_pack_sandbox
  create_test_pack "test-pack" "A test pack"
  local output
  output=$(bash "$CLI" pack list)
  assert_contains "shows pack name" "$output" "test-pack"
  assert_contains "shows description" "$output" "A test pack"
  assert_contains "shows version" "$output" "1.0.0"
}

test_pack_list_empty() {
  setup_pack_sandbox
  mkdir -p "$PACKS_DIR"
  local output
  output=$(bash "$CLI" pack list)
  assert_contains "shows no packs message" "$output" "No packs"
}

test_pack_install_copies_audio() {
  setup_pack_sandbox
  create_test_pack
  bash "$CLI" pack install test-pack
  assert_file_exists "audio copied" "$SANDBOX/audio/test-pack/beep.mp3"
}

test_pack_install_generates_config() {
  setup_pack_sandbox
  create_test_pack
  bash "$CLI" pack install test-pack
  local sound_path
  sound_path=$(jq -r '.events.Stop.sound' "$SANDBOX/sounds-config.json")
  assert_eq "sound path rewritten" "audio/test-pack/beep.mp3" "$sound_path"
}

test_pack_install_preserves_default_events() {
  setup_pack_sandbox
  create_test_pack
  bash "$CLI" pack install test-pack
  local session_start_type
  session_start_type=$(jq -r '.events.SessionStart.type' "$SANDBOX/sounds-config.json")
  assert_eq "default event preserved" "tts" "$session_start_type"
}

test_pack_install_uses_pack_categories() {
  setup_pack_sandbox
  create_test_pack
  jq '.categories = {"completion":{"enabled":true},"attention":{"enabled":true},"lifecycle":{"enabled":true},"progress":{"enabled":true},"input":{"enabled":true},"context":{"enabled":true}}' \
    "$PACKS_DIR/test-pack/pack.json" > "$PACKS_DIR/test-pack/pack.json.tmp" \
    && mv "$PACKS_DIR/test-pack/pack.json.tmp" "$PACKS_DIR/test-pack/pack.json"
  bash "$CLI" pack install test-pack
  local progress_enabled
  progress_enabled=$(jq -r '.categories.progress.enabled' "$SANDBOX/sounds-config.json")
  assert_eq "pack category overrides default" "true" "$progress_enabled"
}

test_pack_install_saves_previous_config() {
  setup_pack_sandbox
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
  setup_pack_sandbox
  create_test_pack "pack-a" "Pack A"
  create_test_pack "pack-b" "Pack B"
  bash "$CLI" pack install pack-a
  bash "$CLI" pack install pack-b
  assert_file_exists "pack-a config saved" "$SANDBOX/sounds-config.pack-a.json"
}

test_pack_install_updates_state() {
  setup_pack_sandbox
  create_test_pack
  bash "$CLI" pack install test-pack
  local active
  active=$(jq -r '.active_pack' "$SANDBOX/state.json")
  assert_eq "active pack set" "test-pack" "$active"
}

test_pack_install_default_restores() {
  setup_pack_sandbox
  create_test_pack
  bash "$CLI" pack install test-pack
  bash "$CLI" pack install default
  local vol
  vol=$(jq -r '.defaults.global_volume' "$SANDBOX/sounds-config.json")
  assert_eq "default config restored" "1" "$vol"
}

test_pack_install_default_clears_state() {
  setup_pack_sandbox
  create_test_pack
  bash "$CLI" pack install test-pack
  bash "$CLI" pack install default
  local active
  active=$(jq -r '.active_pack // "none"' "$SANDBOX/state.json")
  assert_eq "active pack cleared" "none" "$active"
}

test_pack_install_default_saves_pack_config() {
  setup_pack_sandbox
  create_test_pack
  bash "$CLI" pack install test-pack
  bash "$CLI" pack install default
  assert_file_exists "pack config saved before restoring default" "$SANDBOX/sounds-config.test-pack.json"
}

test_pack_switch_restores_saved_config() {
  setup_pack_sandbox
  create_test_pack "pack-a" "Pack A"
  bash "$CLI" pack install pack-a
  jq '.defaults.global_volume = 0.77' "$SANDBOX/sounds-config.json" > "$SANDBOX/tmp.json" \
    && mv "$SANDBOX/tmp.json" "$SANDBOX/sounds-config.json"
  bash "$CLI" pack install default
  bash "$CLI" pack install pack-a
  local vol
  vol=$(jq -r '.defaults.global_volume' "$SANDBOX/sounds-config.json")
  assert_eq "restored saved config with customization" "0.77" "$vol"
}

echo "=== Pack management ==="
run_test "pack list shows packs" test_pack_list_shows_packs
run_test "pack list empty" test_pack_list_empty
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
report
