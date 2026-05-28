# Sound Packs for claude-code-sounds

Installable, switchable sound packs that bundle audio files + event mappings. Ships with the Peon (Warcraft III) pack as the first built-in pack.

## Pack Format

Each pack lives in `packs/<name>/` in the repo:

```
packs/<name>/
  pack.json        # manifest: metadata + event-to-sound mappings
  audio/
    sound-one.mp3
    sound-two.mp3
    ...
```

### pack.json Schema

```json
{
  "name": "peon",
  "description": "Warcraft III Peon voice lines",
  "version": "1.0.0",
  "categories": {
    "completion": { "enabled": true },
    "attention": { "enabled": true },
    "lifecycle": { "enabled": true },
    "progress": { "enabled": true },
    "input": { "enabled": true },
    "context": { "enabled": true }
  },
  "events": {
    "Stop": {
      "enabled": true,
      "category": "completion",
      "type": "audio",
      "sound": "zug-zug.mp3",
      "volume": 0.7,
      "debounce_ms": 2000
    }
  }
}
```

**Required fields:** `name`, `description`, `version`, `events`

**Optional fields:** `author` (string), `categories` (defaults to current `sounds-config.default.json` categories if omitted)

**Sound paths:** Relative to the pack's own `audio/` directory (filename only). The CLI rewrites them to `audio/<pack-name>/<filename>` when generating the installed config.

**Event coverage:** A pack should define all 29 events. Events not defined in the pack fall back to `sounds-config.default.json`.

## Distribution

### Built-in Packs

Stored in the repo under `packs/`. The main `install.sh` copies `packs/` to `~/.claude/sounds/packs/` alongside the existing install steps. Audio files (MP3s) are committed directly to git. Reinstalling updates built-in packs without removing user-added custom packs.

### Custom Packs

Users can add packs by dropping a directory into `~/.claude/sounds/packs/<name>/` following the same format. The CLI discovers all packs from this directory.

## Installation Flow

### `claude-sounds pack install <name>`

1. Validate pack: check `pack.json` exists, required fields present, all referenced audio files exist in `audio/`
2. Save current config: copy `sounds-config.json` to `sounds-config.<active-pack>.json` (or `sounds-config.custom.json` if no pack is active)
3. Copy audio: copy `packs/<name>/audio/*` to `audio/<name>/`
4. Generate config: build `sounds-config.json` from `sounds-config.default.json` defaults + pack's event mappings + pack's category overrides. Sound paths rewritten to `audio/<name>/<file>`.
5. Update state: set `"active_pack": "<name>"` in `state.json`

### `claude-sounds pack install default`

1. Save current config as `sounds-config.<active-pack>.json`
2. Copy `sounds-config.default.json` to `sounds-config.json`
3. Remove `active_pack` from `state.json`

### Switching Back to a Previously Installed Pack

If `sounds-config.<name>.json` exists from a previous install, restore it instead of regenerating from the pack manifest. This preserves user customizations made after the pack was installed.

If no saved config exists, generate fresh from the pack manifest.

## CLI Commands

All new commands live under `claude-sounds pack`:

| Command | Purpose |
|---------|---------|
| `pack list` | List available packs from `~/.claude/sounds/packs/` |
| `pack install <name>` | Install or switch to a pack |
| `pack install default` | Restore default config |
| `pack active` | Show currently active pack |

### Output Examples

```
$ claude-sounds pack list
Available packs:
  peon    Warcraft III Peon voice lines (v1.0.0)

$ claude-sounds pack install peon
Installed pack 'peon' (26 sounds). Previous config saved.

$ claude-sounds pack active
Active pack: peon (v1.0.0)

$ claude-sounds pack install default
Restored default config. Previous config saved as peon.

$ claude-sounds pack active
No pack active (using default config)
```

### Error Cases

```
$ claude-sounds pack install nonexistent
Error: pack 'nonexistent' not found. Run 'claude-sounds pack list' to see available packs.

$ claude-sounds pack install broken-pack
Error: pack 'broken-pack' is invalid: missing audio file 'sound.mp3' referenced in pack.json
```

### Interaction with Existing Commands

- `claude-sounds reset` restores `sounds-config.default.json` and clears `active_pack` from state (same as `pack install default`)
- `claude-sounds test --all` works as before, playing whatever config is active
- `claude-sounds config` edits the active config (which may be a pack-generated config)

## Config Generation

When generating `sounds-config.json` from a pack:

```
{
  "version": <from sounds-config.default.json>,
  "defaults": <from sounds-config.default.json>,
  "categories": <from pack.json if present, else sounds-config.default.json>,
  "events": {
    For each of the 29 events:
      If defined in pack.json:
        Use pack's mapping with sound path rewritten to "audio/<pack-name>/<file>"
      Else:
        Use sounds-config.default.json mapping
  }
}
```

## File Changes

### Modify

| File | Change |
|------|--------|
| `claude-sounds` | Add `pack` subcommand (list, install, active) |
| `install.sh` | Copy `packs/` directory to installed location |
| `uninstall.sh` | Include `packs/` in cleanup |

### Create

| File | Purpose |
|------|---------|
| `packs/peon/pack.json` | Peon pack manifest |
| `packs/peon/audio/*.mp3` | 26 Peon MP3 files |
| `tests/test-packs.sh` | Pack management test suite |

### Documentation Updates

| File | Change |
|------|--------|
| `README.md` | Add sound packs section |
| `docs/CUSTOMIZING.md` | Add pack usage instructions |

## Peon Pack Contents

26 MP3 audio files (~1.9 MB total), sourced from the already-installed instance at `~/.claude/sounds/audio/peon/`.

Event mappings (all 29 events):

### Completion (volume: 0.7, debounce: 2000ms)

| Event | Sound |
|-------|-------|
| Stop | zug-zug.mp3 |
| TaskCompleted | be-happy-to.mp3 |
| SubagentStop | i-can-do-that.mp3 |
| SessionEnd | ok.mp3 |

### Attention (volume: 0.9, debounce: 2000ms)

| Event | Sound |
|-------|-------|
| PermissionRequest | what-do-you-want.mp3 |
| StopFailure | ugh-splat.mp3 |
| PostToolUseFailure | my-tummy-feels-funny.mp3 |
| PermissionDenied | me-not-that-kind-of-orc.mp3 |
| TeammateIdle | no-time-for-play.mp3 |

### Lifecycle (volume: 0.5, debounce: 2000ms)

| Event | Sound |
|-------|-------|
| SessionStart | ready-to-work.mp3 |
| Setup | something-need-doing.mp3 |
| SubagentStart | ill-try.mp3 |
| WorktreeCreate | we-need-more-gold.mp3 |
| WorktreeRemove | kill-them.mp3 |
| InstructionsLoaded | yes.mp3 |

### Progress (volume: 0.3, debounce: 3000ms)

| Event | Sound |
|-------|-------|
| PostToolUse | work-work.mp3 |
| PostToolBatch | okie-dokey.mp3 |
| PreCompact | me-busy.mp3 |
| PostCompact | why-not.mp3 |

### Input (volume: 0.5, debounce: 2000ms)

| Event | Sound |
|-------|-------|
| UserPromptSubmit | hmm.mp3 |
| UserPromptExpansion | look.mp3 |
| Notification | what.mp3 |
| Elicitation | what-do-you-want.mp3 |
| ElicitationResult | ohh.mp3 |
| MessageDisplay | double.mp3 |

### Context (volume: 0.3, debounce: 3000ms)

| Event | Sound |
|-------|-------|
| CwdChanged | look.mp3 |
| FileChanged | hmm.mp3 |
| ConfigChange | swobu.mp3 |
| PreToolUse | leave-me-alone.mp3 |

## Testing

New test suite `tests/test-packs.sh`:

- `pack list` shows available packs
- `pack list` shows nothing when no packs exist
- `pack install` copies audio files
- `pack install` generates correct config with rewritten sound paths
- `pack install` saves previous config
- `pack install` updates state with active pack
- `pack install default` restores default config
- `pack install default` clears active pack from state
- Switching packs preserves per-pack saved configs
- Invalid pack name shows error
- Missing audio file in pack detected during validation
- Missing pack.json detected during validation

## Rollback

- `claude-sounds pack install default` restores factory defaults
- `claude-sounds reset` also works (existing behavior)
- Saved per-pack configs enable switching back without data loss
