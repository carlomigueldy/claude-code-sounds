# Customizing Claude Code Sounds

All customization is done by editing `~/.claude/sounds/sounds-config.json`.

Open it with:

```bash
claude-sounds config
```

Or edit it directly. The file is plain JSON — changes take effect immediately on the next hook event.

---

## Config File Location

```
~/.claude/sounds/sounds-config.json
```

To reset to defaults (creates a backup first):

```bash
claude-sounds reset
```

---

## Resolution Order

The dispatcher resolves settings in this order, from most to least specific:

1. **Per-event config** — fields on the event object in `events`
2. **Category config** — the category's `enabled` flag in `categories`
3. **Global defaults** — the `defaults` block

An event must pass all three layers to play: it must be enabled, its category must be enabled (or not muted), and global mute must be off.

---

## Changing Sounds

To switch an event from TTS to audio, set `type` to `"audio"` and add a `sound` path:

```json
{
  "events": {
    "Stop": {
      "type": "audio",
      "sound": "audio/my-chime.aiff"
    }
  }
}
```

To switch from audio to TTS, set `type` to `"tts"` and add a `message`:

```json
{
  "events": {
    "Stop": {
      "type": "tts",
      "message": "Claude is done"
    }
  }
}
```

You only need to include the fields you want to change. All other event settings (volume, debounce, enabled) remain as-is.

---

## Adding Custom Audio Files

1. Place audio files in `~/.claude/sounds/audio/`
2. Reference them by path relative to `~/.claude/sounds/`

```json
{
  "events": {
    "Stop": {
      "type": "audio",
      "sound": "audio/my-completion-chime.aiff"
    }
  }
}
```

Supported formats: `.aiff`, `.mp3`, `.wav`, `.m4a` — anything `afplay` accepts.

Test the sound immediately:

```bash
claude-sounds test Stop
```

---

## Adjusting Volume

Volume is a float from `0.0` (silent) to `1.0` (full).

**Per-event volume** — set on the event:

```json
{
  "events": {
    "Stop": {
      "volume": 0.5
    }
  }
}
```

**Global volume multiplier** — scales all events proportionally:

```json
{
  "defaults": {
    "global_volume": 0.7
  }
}
```

**Final volume** is computed as: `event_volume * global_volume`. For example, an event with `volume: 0.8` and `global_volume: 0.5` plays at effective volume `0.4`.

---

## Changing TTS Voice and Rate

List all available voices on your system:

```bash
say -v '?'
```

Set the voice and rate in the `defaults` block:

```json
{
  "defaults": {
    "tts_voice": "Alex",
    "tts_rate": 250
  }
}
```

`tts_rate` is words per minute. The default is `200`. Higher values speak faster.

Voice and rate apply to all TTS events. There is no per-event voice override.

---

## Adjusting Debounce Timing

Debounce prevents a sound from firing again too soon after the previous firing of the same event.

**Per-event override** — set `debounce_ms` on the event:

```json
{
  "events": {
    "TeammateIdle": {
      "debounce_ms": 10000
    }
  }
}
```

**Global default** — applies when an event does not specify its own:

```json
{
  "defaults": {
    "debounce_ms": 3000
  }
}
```

**When to increase debounce:** Events that fire rapidly during normal work (PostToolUse, UserPromptSubmit) benefit from longer debounce to avoid audio spam. TeammateIdle defaults to 5000 ms for this reason.

**When to decrease debounce:** Attention events like PermissionRequest are important to hear every time — lower debounce (or 0) ensures none are missed.

---

## Enabling and Disabling Events

**Per-event toggle:**

```json
{
  "events": {
    "Setup": {
      "enabled": true
    },
    "WorktreeCreate": {
      "enabled": false
    }
  }
}
```

**Per-category toggle** — disabling a category silences all events in it regardless of per-event settings:

```json
{
  "categories": {
    "progress": {
      "enabled": true
    }
  }
}
```

---

## Quick Muting with the CLI

The CLI provides runtime mute control without editing the config file.

**Mute/unmute all sounds:**

```bash
claude-sounds off
claude-sounds on
```

**Mute/unmute a category:**

```bash
claude-sounds mute progress
claude-sounds unmute progress
```

**Check current state:**

```bash
claude-sounds status
```

CLI mute state is stored separately in `~/.claude/sounds/state.json` and does not modify `sounds-config.json`.

---

## Full Config Example

```json
{
  "version": 1,
  "defaults": {
    "debounce_ms": 2000,
    "tts_voice": "Alex",
    "tts_rate": 220,
    "global_volume": 0.8
  },
  "categories": {
    "completion": { "enabled": true },
    "attention": { "enabled": true },
    "lifecycle": { "enabled": true },
    "progress": { "enabled": true },
    "input": { "enabled": true },
    "context": { "enabled": false }
  },
  "events": {
    "Stop": {
      "type": "audio",
      "sound": "audio/my-chime.aiff",
      "volume": 1.0
    },
    "PermissionRequest": {
      "volume": 1.0,
      "debounce_ms": 0
    },
    "PostToolUse": {
      "enabled": true,
      "debounce_ms": 500
    }
  }
}
```

---

## Sound Packs

Sound packs provide pre-configured sound sets that replace all events at once.

### Using Packs

```bash
# List available packs
claude-sounds pack list

# Install a pack
claude-sounds pack install peon

# See what's active
claude-sounds pack active

# Switch back to defaults
claude-sounds pack install default
```

Installing a pack saves your current config. When you switch back later, your customizations are restored.

### Creating a Pack

A pack is a directory with a `pack.json` manifest and an `audio/` directory:

```
~/.claude/sounds/packs/my-pack/
  pack.json
  audio/
    chime.mp3
    alert.mp3
```

### pack.json Format

```json
{
  "name": "my-pack",
  "description": "My custom sound pack",
  "version": "1.0.0",
  "categories": {
    "completion": { "enabled": true },
    "attention": { "enabled": true },
    "lifecycle": { "enabled": true },
    "progress": { "enabled": false },
    "input": { "enabled": true },
    "context": { "enabled": false }
  },
  "events": {
    "Stop": {
      "enabled": true,
      "category": "completion",
      "type": "audio",
      "sound": "chime.mp3",
      "volume": 0.8,
      "debounce_ms": 2000
    }
  }
}
```

**Required fields:** `name`, `description`, `version`, `events`

**Optional fields:** `author`, `categories`

**Sound paths** are relative to the pack's `audio/` directory — use just the filename (e.g., `"chime.mp3"`, not `"audio/my-pack/chime.mp3"`). The CLI rewrites paths automatically during installation.

**Events not defined** in the pack fall back to the defaults from `sounds-config.default.json`.

**Categories** override the default category settings when present. Omit to keep defaults.
