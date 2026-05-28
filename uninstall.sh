#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.claude/sounds}"
SYMLINK_DIR="${SYMLINK_DIR:-/usr/local/bin}"
SETTINGS_FILE="${SETTINGS_FILE:-$HOME/.claude/settings.json}"
NO_PROMPT=false

for arg in "$@"; do
  case "$arg" in
    --test) ;;
    --no-prompt) NO_PROMPT=true ;;
  esac
done

echo "Uninstalling Claude Code Sounds..."

HOOK_CMD="bash $INSTALL_DIR/dispatcher.sh"

if [ -f "$SETTINGS_FILE" ]; then
  SETTINGS=$(cat "$SETTINGS_FILE")
  EVENTS=$(echo "$SETTINGS" | jq -r '.hooks | keys[]' 2>/dev/null || true)
  for event in $EVENTS; do
    SETTINGS=$(echo "$SETTINGS" | jq ".hooks.\"$event\" = [.hooks.\"$event\"[] | select(.hooks[0].command != \"$HOOK_CMD\")]")
    remaining=$(echo "$SETTINGS" | jq ".hooks.\"$event\" | length")
    if [ "$remaining" = "0" ]; then
      SETTINGS=$(echo "$SETTINGS" | jq "del(.hooks.\"$event\")")
    fi
  done
  echo "$SETTINGS" | jq '.' > "$SETTINGS_FILE"
  echo "  Removed hook entries from $SETTINGS_FILE"
fi

if [ -L "$SYMLINK_DIR/claude-sounds" ]; then
  rm "$SYMLINK_DIR/claude-sounds"
  echo "  Removed symlink from $SYMLINK_DIR/"
fi

if [ "$NO_PROMPT" = true ]; then
  echo "  Skipping directory cleanup (no-prompt mode)"
else
  echo ""
  read -rp "Remove $INSTALL_DIR? Your config and custom sounds will be deleted. [y/N] " answer
  if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
    rm -rf "$INSTALL_DIR"
    echo "  Removed $INSTALL_DIR"
  else
    echo "  Kept $INSTALL_DIR (your config and sounds are preserved)"
  fi
fi

echo ""
echo "Claude Code Sounds uninstalled."
