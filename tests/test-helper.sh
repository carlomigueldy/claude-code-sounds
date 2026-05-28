#!/bin/bash
set -euo pipefail

TESTS_PASSED=0
TESTS_FAILED=0
TESTS_RUN=0
CURRENT_TEST=""
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

setup_sandbox() {
  SANDBOX=$(mktemp -d)
  export CLAUDE_SOUNDS_DIR="$SANDBOX"
  mkdir -p "$SANDBOX/audio" "$SANDBOX/debounce"
  cp "$PROJECT_DIR/sounds-config.default.json" "$SANDBOX/sounds-config.json"
  cp "$PROJECT_DIR/dispatcher.sh" "$SANDBOX/dispatcher.sh"
  chmod +x "$SANDBOX/dispatcher.sh"
  echo '{"global_mute":false,"muted_categories":{}}' > "$SANDBOX/state.json"

  mkdir -p "$SANDBOX/bin"
  cat > "$SANDBOX/bin/afplay" << 'MOCK'
#!/bin/bash
echo "afplay $*" >> "$CLAUDE_SOUNDS_DIR/mock-calls.log"
MOCK
  cat > "$SANDBOX/bin/say" << 'MOCK'
#!/bin/bash
echo "say $*" >> "$CLAUDE_SOUNDS_DIR/mock-calls.log"
MOCK
  chmod +x "$SANDBOX/bin/afplay" "$SANDBOX/bin/say"
  export PATH="$SANDBOX/bin:$PATH"
  > "$SANDBOX/mock-calls.log"
}

teardown_sandbox() {
  if [ -n "${SANDBOX:-}" ] && [ -d "$SANDBOX" ]; then
    rm -rf "$SANDBOX"
  fi
}

run_test() {
  local name="$1"
  shift
  CURRENT_TEST="$name"
  TESTS_RUN=$((TESTS_RUN + 1))
  setup_sandbox
  if "$@" 2>/dev/null; then
    teardown_sandbox
  else
    echo "  FAIL: $name (function errored)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    teardown_sandbox
  fi
}

assert_eq() {
  local desc="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    echo "  PASS: $CURRENT_TEST — $desc"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo "  FAIL: $CURRENT_TEST — $desc"
    echo "    expected: '$expected'"
    echo "    actual:   '$actual'"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

assert_contains() {
  local desc="$1" haystack="$2" needle="$3"
  if echo "$haystack" | grep -qF "$needle"; then
    echo "  PASS: $CURRENT_TEST — $desc"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo "  FAIL: $CURRENT_TEST — $desc"
    echo "    expected to contain: '$needle'"
    echo "    actual: '$haystack'"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

assert_file_exists() {
  local desc="$1" path="$2"
  if [ -f "$path" ]; then
    echo "  PASS: $CURRENT_TEST — $desc"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo "  FAIL: $CURRENT_TEST — $desc (file not found: $path)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

assert_file_not_exists() {
  local desc="$1" path="$2"
  if [ ! -f "$path" ]; then
    echo "  PASS: $CURRENT_TEST — $desc"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo "  FAIL: $CURRENT_TEST — $desc (file exists: $path)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

assert_mock_called() {
  local desc="$1" pattern="$2"
  if grep -q "$pattern" "$SANDBOX/mock-calls.log" 2>/dev/null; then
    echo "  PASS: $CURRENT_TEST — $desc"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo "  FAIL: $CURRENT_TEST — $desc"
    echo "    expected mock call matching: '$pattern'"
    echo "    actual calls: $(cat "$SANDBOX/mock-calls.log" 2>/dev/null || echo '(none)')"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

assert_mock_not_called() {
  local desc="$1"
  local call_count
  call_count=$(wc -l < "$SANDBOX/mock-calls.log" 2>/dev/null || echo "0")
  call_count=$(echo "$call_count" | tr -d ' ')
  if [ "$call_count" = "0" ]; then
    echo "  PASS: $CURRENT_TEST — $desc"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo "  FAIL: $CURRENT_TEST — $desc"
    echo "    expected no mock calls, got: $(cat "$SANDBOX/mock-calls.log")"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

report() {
  echo ""
  echo "================================"
  echo "Tests run: $TESTS_RUN"
  echo "Assertions passed: $TESTS_PASSED"
  echo "Assertions failed: $TESTS_FAILED"
  echo "================================"
  if [ "$TESTS_FAILED" -gt 0 ]; then
    exit 1
  fi
}
