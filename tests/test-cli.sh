#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/test-helper.sh"
CLI="$PROJECT_DIR/claude-sounds"

test_off_sets_global_mute() {
  bash "$CLI" off
  local muted
  muted=$(jq -r '.global_mute' "$SANDBOX/state.json")
  assert_eq "global_mute set to true" "true" "$muted"
}

test_on_clears_global_mute() {
  echo '{"global_mute":true,"muted_categories":{}}' > "$SANDBOX/state.json"
  bash "$CLI" on
  local muted
  muted=$(jq -r '.global_mute' "$SANDBOX/state.json")
  assert_eq "global_mute set to false" "false" "$muted"
}

test_status_shows_on() {
  local output
  output=$(bash "$CLI" status)
  assert_contains "shows ON" "$output" "ON"
}

test_status_shows_off() {
  echo '{"global_mute":true,"muted_categories":{}}' > "$SANDBOX/state.json"
  local output
  output=$(bash "$CLI" status)
  assert_contains "shows OFF" "$output" "OFF"
}

test_status_shows_categories() {
  local output
  output=$(bash "$CLI" status)
  assert_contains "shows completion" "$output" "completion"
  assert_contains "shows attention" "$output" "attention"
  assert_contains "shows lifecycle" "$output" "lifecycle"
  assert_contains "shows progress" "$output" "progress"
  assert_contains "shows input" "$output" "input"
  assert_contains "shows context" "$output" "context"
}

test_mute_category() {
  bash "$CLI" mute completion
  local muted
  muted=$(jq -r '.muted_categories.completion // false' "$SANDBOX/state.json")
  assert_eq "completion is muted" "true" "$muted"
}

test_unmute_category() {
  echo '{"global_mute":false,"muted_categories":{"completion":true}}' > "$SANDBOX/state.json"
  bash "$CLI" unmute completion
  local muted
  muted=$(jq -r '.muted_categories.completion // false' "$SANDBOX/state.json")
  assert_eq "completion is unmuted" "false" "$muted"
}

test_mute_invalid_category() {
  local output exit_code
  output=$(bash "$CLI" mute foobar 2>&1) || exit_code=$?
  assert_contains "shows error for invalid category" "$output" "Unknown category"
}

test_status_reflects_muted_category() {
  bash "$CLI" mute attention
  local output
  output=$(bash "$CLI" status)
  assert_contains "attention shows off" "$output" "attention"
}

test_test_event_plays_sound() {
  bash "$CLI" test SessionStart
  assert_mock_called "say called for test" "say"
  assert_mock_called "correct message" "Session started"
}

test_test_unknown_event() {
  local output
  output=$(bash "$CLI" test FakeEvent 2>&1) || true
  assert_contains "shows error for unknown event" "$output" "Unknown event"
}

test_list_all() {
  local output
  output=$(bash "$CLI" list)
  assert_contains "shows Stop" "$output" "Stop"
  assert_contains "shows SessionStart" "$output" "SessionStart"
  assert_contains "shows PermissionRequest" "$output" "PermissionRequest"
}

test_list_by_category() {
  local output
  output=$(bash "$CLI" list --category attention)
  assert_contains "shows PermissionRequest" "$output" "PermissionRequest"
  assert_contains "shows StopFailure" "$output" "StopFailure"
}

test_reset_backs_up_and_restores() {
  jq '.defaults.global_volume = 0.1' "$SANDBOX/sounds-config.json" > "$SANDBOX/tmp.json" \
    && mv "$SANDBOX/tmp.json" "$SANDBOX/sounds-config.json"
  cp "$PROJECT_DIR/sounds-config.default.json" "$SANDBOX/sounds-config.default.json"
  bash "$CLI" reset
  assert_file_exists "backup created" "$SANDBOX/sounds-config.json.bak"
  local vol
  vol=$(jq -r '.defaults.global_volume' "$SANDBOX/sounds-config.json")
  assert_eq "config restored to default" "1" "$vol"
}

echo "=== CLI: on/off/status ==="
run_test "off sets global mute" test_off_sets_global_mute
run_test "on clears global mute" test_on_clears_global_mute
run_test "status shows ON" test_status_shows_on
run_test "status shows OFF" test_status_shows_off
run_test "status shows categories" test_status_shows_categories
run_test "mute category" test_mute_category
run_test "unmute category" test_unmute_category
run_test "mute invalid category" test_mute_invalid_category
run_test "status reflects muted category" test_status_reflects_muted_category
run_test "test event plays sound" test_test_event_plays_sound
run_test "test unknown event" test_test_unknown_event
run_test "list all events" test_list_all
run_test "list by category" test_list_by_category
run_test "reset backs up and restores" test_reset_backs_up_and_restores
report
