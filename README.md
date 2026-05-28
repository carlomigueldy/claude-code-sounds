# Claude Code Sounds

Configurable sound notifications for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Every hook event can trigger a distinct sound — custom audio files or text-to-speech — with per-event volume, debounce, and category-based muting.

## Quick Start

**Install:**

```bash
curl -fsSL https://raw.githubusercontent.com/carlomigueldy/claude-code-sounds/main/install.sh | bash
```

**Test it:**

```bash
claude-sounds test SessionStart   # Should say "Session started"
claude-sounds status              # Show what's enabled
```

**That's it.** Claude Code will now play sounds on hook events. All TTS events work immediately — custom audio events are silent until you add sound files.

## Requirements

- macOS (uses `afplay` and `say`)
- [jq](https://jqlang.github.io/jq/) (`brew install jq`)
- Claude Code with hooks support

## Commands

| Command | Description |
|---------|-------------|
| `claude-sounds on` | Unmute all sounds |
| `claude-sounds off` | Mute all sounds |
| `claude-sounds status` | Show current mute state |
| `claude-sounds mute <category>` | Mute a category |
| `claude-sounds unmute <category>` | Unmute a category |
| `claude-sounds test <event>` | Play a specific event's sound |
| `claude-sounds test --all` | Play all enabled sounds |
| `claude-sounds list` | List all events |
| `claude-sounds list --category <c>` | Filter by category |
| `claude-sounds config` | Edit config in $EDITOR |
| `claude-sounds reset` | Reset to defaults (backs up first) |
| `claude-sounds pack list` | List available sound packs |
| `claude-sounds pack install <name>` | Install a sound pack |
| `claude-sounds pack install default` | Restore default sounds |
| `claude-sounds pack active` | Show currently active pack |

## Categories

Events are grouped into 6 categories. Mute entire categories to control noise level.

| Category | Events | Default |
|----------|--------|---------|
| completion | Stop, TaskCompleted, SubagentStop, SessionEnd | on |
| attention | PermissionRequest, StopFailure, PostToolUseFailure, PermissionDenied, TeammateIdle | on |
| lifecycle | SessionStart, Setup, SubagentStart, WorktreeCreate, WorktreeRemove, InstructionsLoaded | on |
| progress | PostToolUse, PostToolBatch, PreCompact, PostCompact | off |
| input | UserPromptSubmit, Notification, Elicitation, and others | on |
| context | CwdChanged, FileChanged, ConfigChange, PreToolUse | off |

See [docs/EVENTS.md](docs/EVENTS.md) for the full event reference.

## Configuration

Edit `~/.claude/sounds/sounds-config.json` (or run `claude-sounds config`).

See [docs/CUSTOMIZING.md](docs/CUSTOMIZING.md) for the customization guide.

## Custom Sounds

Place audio files in `~/.claude/sounds/audio/` and reference them in your config:

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

Supported formats: `.aiff`, `.mp3`, `.wav`, `.m4a` (anything `afplay` supports).

## Sound Packs

Sound packs bundle audio files with event mappings for one-command installation.

**List available packs:**

```bash
claude-sounds pack list
```

**Install a pack:**

```bash
claude-sounds pack install peon
```

**See what's active:**

```bash
claude-sounds pack active
```

**Switch back to defaults:**

```bash
claude-sounds pack install default
```

Switching packs saves your current config, so you can switch back without losing customizations.

### Built-in Packs

| Pack | Description |
|------|-------------|
| peon | Warcraft III Peon voice lines — 26 sounds across all 29 events |

### Custom Packs

Create your own pack by adding a directory to `~/.claude/sounds/packs/<name>/`:

```
packs/my-pack/
  pack.json        # manifest with event mappings
  audio/
    sound1.mp3
    sound2.mp3
```

See [docs/CUSTOMIZING.md](docs/CUSTOMIZING.md) for the pack manifest format.

## Uninstall

```bash
~/.claude/sounds/uninstall.sh
```

Removes hooks and symlink. Optionally removes config and sounds.

## License

MIT
