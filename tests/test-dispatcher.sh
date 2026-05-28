#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/test-helper.sh"
DISPATCHER="$PROJECT_DIR/dispatcher.sh"

send_event() {
  echo "{\"hook_event_name\": \"$1\"}" | bash "$DISPATCHER"
}

test_global_mute_skips() {
  echo '{"global_mute":true,"muted_categories":{}}' > "$SANDBOX/state.json"
  send_event "Stop"
  assert_mock_not_called "no sound when globally muted"
}

test_unknown_event_skips() {
  send_event "NonExistentEvent"
  assert_mock_not_called "no sound for unknown event"
}

test_disabled_event_skips() {
  jq '.events.Stop.enabled = false' "$SANDBOX/sounds-config.json" > "$SANDBOX/tmp.json" \
    && mv "$SANDBOX/tmp.json" "$SANDBOX/sounds-config.json"
  send_event "Stop"
  assert_mock_not_called "no sound for disabled event"
}

test_disabled_category_skips() {
  jq '.categories.completion.enabled = false' "$SANDBOX/sounds-config.json" > "$SANDBOX/tmp.json" \
    && mv "$SANDBOX/tmp.json" "$SANDBOX/sounds-config.json"
  send_event "Stop"
  assert_mock_not_called "no sound when category disabled"
}

test_muted_category_skips() {
  echo '{"global_mute":false,"muted_categories":{"completion":true}}' > "$SANDBOX/state.json"
  send_event "Stop"
  assert_mock_not_called "no sound when category muted in state"
}

test_debounce_allows_first_call() {
  send_event "TaskCompleted"
  assert_mock_called "first call plays sound" "say"
}

test_debounce_blocks_rapid_repeat() {
  send_event "TaskCompleted"
  > "$SANDBOX/mock-calls.log"
  send_event "TaskCompleted"
  assert_mock_not_called "rapid repeat blocked by debounce"
}

test_debounce_allows_after_window() {
  send_event "TaskCompleted"
  > "$SANDBOX/mock-calls.log"
  echo "0" > "$SANDBOX/debounce/TaskCompleted"
  send_event "TaskCompleted"
  assert_mock_called "plays after debounce window" "say"
}

echo "=== Dispatcher: mute checks and event lookup ==="
run_test "global mute skips" test_global_mute_skips
run_test "unknown event skips" test_unknown_event_skips
run_test "disabled event skips" test_disabled_event_skips
run_test "disabled category skips" test_disabled_category_skips
run_test "muted category skips" test_muted_category_skips
run_test "debounce allows first call" test_debounce_allows_first_call
run_test "debounce blocks rapid repeat" test_debounce_blocks_rapid_repeat
run_test "debounce allows after window" test_debounce_allows_after_window
report
