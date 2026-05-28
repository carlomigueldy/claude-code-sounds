#!/bin/bash
set -euo pipefail

INSTALL_DIR="${INSTALL_DIR:-$HOME/.claude/sounds}"
SYMLINK_DIR="${SYMLINK_DIR:-/usr/local/bin}"
SETTINGS_FILE="${SETTINGS_FILE:-$HOME/.claude/settings.json}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_MODE=false

if [ "${1:-}" = "--test" ]; then
  TEST_MODE=true
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not installed."
  echo "Install with: brew install jq"
  exit 1
fi

echo "Installing Claude Code Sounds..."

mkdir -p "$INSTALL_DIR/audio" "$INSTALL_DIR/debounce"

cp "$SCRIPT_DIR/dispatcher.sh" "$INSTALL_DIR/dispatcher.sh"
cp "$SCRIPT_DIR/claude-sounds" "$INSTALL_DIR/claude-sounds"
cp "$SCRIPT_DIR/uninstall.sh" "$INSTALL_DIR/uninstall.sh"
cp "$SCRIPT_DIR/sounds-config.default.json" "$INSTALL_DIR/sounds-config.default.json"
chmod +x "$INSTALL_DIR/dispatcher.sh" "$INSTALL_DIR/claude-sounds" "$INSTALL_DIR/uninstall.sh"

if [ ! -f "$INSTALL_DIR/sounds-config.json" ]; then
  cp "$SCRIPT_DIR/sounds-config.default.json" "$INSTALL_DIR/sounds-config.json"
  echo "  Created sounds-config.json"
else
  echo "  Existing sounds-config.json preserved"
fi

if [ ! -f "$INSTALL_DIR/state.json" ]; then
  echo '{"global_mute":false,"muted_categories":{}}' > "$INSTALL_DIR/state.json"
fi

ln -sf "$INSTALL_DIR/claude-sounds" "$SYMLINK_DIR/claude-sounds"
echo "  Symlinked claude-sounds to $SYMLINK_DIR/"

HOOK_EVENTS=(
  "Stop" "StopFailure" "SessionStart" "SessionEnd" "Setup"
  "UserPromptSubmit" "UserPromptExpansion"
  "PreToolUse" "PostToolUse" "PostToolUseFailure" "PostToolBatch"
  "PermissionRequest" "PermissionDenied"
  "SubagentStart" "SubagentStop" "TeammateIdle"
  "TaskCompleted"
  "PreCompact" "PostCompact"
  "CwdChanged" "FileChanged" "ConfigChange" "InstructionsLoaded"
  "WorktreeCreate" "WorktreeRemove"
  "Notification" "Elicitation" "ElicitationResult" "MessageDisplay"
)

HOOK_CMD="bash $INSTALL_DIR/dispatcher.sh"

if [ ! -f "$SETTINGS_FILE" ]; then
  echo '{}' > "$SETTINGS_FILE"
fi

SETTINGS=$(cat "$SETTINGS_FILE")

if ! echo "$SETTINGS" | jq -e '.hooks' >/dev/null 2>&1; then
  SETTINGS=$(echo "$SETTINGS" | jq '.hooks = {}')
fi

SOUNDS_HOOK_ENTRY=$(cat <<ENTRY
{
  "hooks": [{"type": "command", "command": "$HOOK_CMD"}]
}
ENTRY
)

for event in "${HOOK_EVENTS[@]}"; do
  has_sounds_hook=$(echo "$SETTINGS" | jq -r ".hooks.\"$event\" // [] | map(select(.hooks[0].command == \"$HOOK_CMD\")) | length")
  if [ "$has_sounds_hook" = "0" ]; then
    SETTINGS=$(echo "$SETTINGS" | jq ".hooks.\"$event\" = (.hooks.\"$event\" // []) + [$SOUNDS_HOOK_ENTRY]")
  fi
done

echo "$SETTINGS" | jq '.' > "$SETTINGS_FILE"
echo "  Hook entries merged into $SETTINGS_FILE"

echo ""
echo "Claude Code Sounds installed successfully!"
echo ""

if [ "$TEST_MODE" = false ]; then
  CLAUDE_SOUNDS_DIR="$INSTALL_DIR" bash "$INSTALL_DIR/claude-sounds" status
fi
