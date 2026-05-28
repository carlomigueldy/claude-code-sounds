#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/test-helper.sh"
INSTALLER="$PROJECT_DIR/install.sh"

setup_install_sandbox() {
  setup_sandbox
  export INSTALL_DIR="$SANDBOX/install"
  export SYMLINK_DIR="$SANDBOX/bin"
  export SETTINGS_FILE="$SANDBOX/settings.json"
  mkdir -p "$INSTALL_DIR" "$SYMLINK_DIR"
  echo '{"permissions":{"allow":[]},"hooks":{}}' > "$SETTINGS_FILE"
}

test_install_creates_directory_structure() {
  setup_install_sandbox
  bash "$INSTALLER" --test
  assert_file_exists "dispatcher exists" "$INSTALL_DIR/dispatcher.sh"
  assert_file_exists "cli exists" "$INSTALL_DIR/claude-sounds"
  assert_file_exists "config exists" "$INSTALL_DIR/sounds-config.json"
  assert_file_exists "state exists" "$INSTALL_DIR/state.json"
  assert_file_exists "default config exists" "$INSTALL_DIR/sounds-config.default.json"
  teardown_sandbox
}

test_install_preserves_existing_config() {
  setup_install_sandbox
  mkdir -p "$INSTALL_DIR"
  echo '{"version":1,"custom":true}' > "$INSTALL_DIR/sounds-config.json"
  bash "$INSTALLER" --test
  local custom
  custom=$(jq -r '.custom // false' "$INSTALL_DIR/sounds-config.json")
  assert_eq "existing config preserved" "true" "$custom"
  teardown_sandbox
}

test_install_creates_symlink() {
  setup_install_sandbox
  bash "$INSTALLER" --test
  assert_file_exists "symlink created" "$SYMLINK_DIR/claude-sounds"
  teardown_sandbox
}

test_install_merges_hooks() {
  setup_install_sandbox
  bash "$INSTALLER" --test
  local stop_hooks
  stop_hooks=$(jq '.hooks.Stop // empty' "$SETTINGS_FILE")
  assert_contains "Stop hook added" "$stop_hooks" "dispatcher.sh"
  teardown_sandbox
}

test_install_preserves_existing_hooks() {
  setup_install_sandbox
  echo '{"permissions":{"allow":[]},"hooks":{"Stop":[{"hooks":[{"type":"command","command":"echo existing"}]}]}}' > "$SETTINGS_FILE"
  bash "$INSTALLER" --test
  local existing
  existing=$(jq -r '.hooks.Stop[0].hooks[0].command' "$SETTINGS_FILE")
  assert_eq "existing hook preserved" "echo existing" "$existing"
  teardown_sandbox
}

test_uninstall_removes_hooks() {
  setup_install_sandbox
  bash "$INSTALLER" --test
  bash "$INSTALL_DIR/uninstall.sh" --test --no-prompt
  local stop_hooks
  stop_hooks=$(jq -r '.hooks.Stop // "[]"' "$SETTINGS_FILE")
  if echo "$stop_hooks" | grep -q "dispatcher.sh"; then
    echo "  FAIL: uninstall removes hooks — dispatcher.sh still in hooks"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  else
    echo "  PASS: uninstall removes hooks"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  fi
  teardown_sandbox
}

test_uninstall_removes_symlink() {
  setup_install_sandbox
  bash "$INSTALLER" --test
  bash "$INSTALL_DIR/uninstall.sh" --test --no-prompt
  assert_file_not_exists "symlink removed" "$SYMLINK_DIR/claude-sounds"
  teardown_sandbox
}

test_install_copies_packs() {
  setup_install_sandbox
  mkdir -p "$PROJECT_DIR/packs/test-pack/audio"
  echo '{"name":"test-pack","description":"Test","version":"1.0.0","events":{}}' > "$PROJECT_DIR/packs/test-pack/pack.json"
  echo "fake" > "$PROJECT_DIR/packs/test-pack/audio/beep.mp3"
  bash "$INSTALLER" --test
  assert_file_exists "pack.json copied" "$INSTALL_DIR/packs/test-pack/pack.json"
  assert_file_exists "audio copied" "$INSTALL_DIR/packs/test-pack/audio/beep.mp3"
  rm -rf "$PROJECT_DIR/packs/test-pack"
  teardown_sandbox
}

echo "=== Install script ==="
run_test "creates directory structure" test_install_creates_directory_structure
run_test "preserves existing config" test_install_preserves_existing_config
run_test "creates symlink" test_install_creates_symlink
run_test "merges hooks" test_install_merges_hooks
run_test "preserves existing hooks" test_install_preserves_existing_hooks
run_test "uninstall removes hooks" test_uninstall_removes_hooks
run_test "uninstall removes symlink" test_uninstall_removes_symlink
run_test "install copies packs" test_install_copies_packs
report
