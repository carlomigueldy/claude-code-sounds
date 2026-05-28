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

echo "=== Pack management ==="
run_test "pack list shows packs" test_pack_list_shows_packs
run_test "pack list empty" test_pack_list_empty
report
