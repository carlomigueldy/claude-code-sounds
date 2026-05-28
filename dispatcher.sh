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

mkdir -p "$DEBOUNCE_DIR"
debounce_ms=$(echo "$event_cfg" | jq -r '.debounce_ms // empty')
if [ -z "$debounce_ms" ]; then
  debounce_ms=$(jq -r '.defaults.debounce_ms // 2000' "$CONFIG")
fi
debounce_file="$DEBOUNCE_DIR/$event_name"

now_ms=$(($(date +%s) * 1000))
if [ -f "$debounce_file" ]; then
  last_ms=$(cat "$debounce_file" 2>/dev/null || echo "0")
  elapsed=$((now_ms - last_ms))
  if [ "$elapsed" -lt "$debounce_ms" ]; then
    exit 0
  fi
fi
echo "$now_ms" > "$debounce_file"

sound_type=$(echo "$event_cfg" | jq -r '.type // empty')
event_vol=$(echo "$event_cfg" | jq -r '.volume // 0.5')
global_vol=$(jq -r '.defaults.global_volume // 1.0' "$CONFIG")
final_vol=$(echo "$event_vol * $global_vol" | bc 2>/dev/null || echo "$event_vol")

if [ "$sound_type" = "audio" ]; then
  sound_file="$SOUNDS_DIR/$(echo "$event_cfg" | jq -r '.sound // empty')"
  if [ -f "$sound_file" ]; then
    afplay -v "$final_vol" "$sound_file" &
    wait
  fi
elif [ "$sound_type" = "tts" ]; then
  message=$(echo "$event_cfg" | jq -r '.message // empty')
  if [ -n "$message" ]; then
    voice=$(jq -r '.defaults.tts_voice // "Samantha"' "$CONFIG")
    rate=$(jq -r '.defaults.tts_rate // 200' "$CONFIG")
    say -v "$voice" -r "$rate" --volume="$final_vol" "$message" &
    wait
  fi
fi

exit 0
