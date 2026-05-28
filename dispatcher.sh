#!/bin/bash
SOUNDS_DIR="${CLAUDE_SOUNDS_DIR:-$HOME/.claude/sounds}"
CONFIG="$SOUNDS_DIR/sounds-config.json"
STATE="$SOUNDS_DIR/state.json"
DEBOUNCE_DIR="$SOUNDS_DIR/debounce"

payload=$(cat)
event_name=$(echo "$payload" | jq -r '.hook_event_name // empty')
if [ -z "$event_name" ]; then
  exit 0
fi

if [ ! -f "$CONFIG" ]; then exit 0; fi

if jq -e '.global_mute == true' "$STATE" >/dev/null 2>&1; then
  exit 0
fi

event_cfg=$(jq -r ".events.\"$event_name\" // empty" "$CONFIG")
if [ -z "$event_cfg" ] || [ "$event_cfg" = "null" ]; then
  exit 0
fi

enabled=$(echo "$event_cfg" | jq -r '.enabled // false')
if [ "$enabled" != "true" ]; then
  exit 0
fi

category=$(echo "$event_cfg" | jq -r '.category // empty')
if [ -n "$category" ]; then
  cat_enabled=$(jq -r ".categories.\"$category\".enabled // true" "$CONFIG")
  if [ "$cat_enabled" != "true" ]; then
    exit 0
  fi

  cat_muted=$(jq -r ".muted_categories.\"$category\" // false" "$STATE")
  if [ "$cat_muted" = "true" ]; then
    exit 0
  fi
fi

exit 0
