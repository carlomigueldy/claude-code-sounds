# Peon Sound Pack for claude-code-sounds

Full Peon Mode: replace all TTS and placeholder audio events with Warcraft III Peon voice lines downloaded from 101soundboards.com.

## Source

Soundboard: `https://www.101soundboards.com/boards/10069-peon-sounds-warcraft-iii-reign-of-chaos`

26 sounds available. All events (29) get mapped; 3 sounds are reused where thematically appropriate.

## Audio Files

Download all 26 MP3s via Playwright browser automation (session already past Cloudflare).

Target directory: `~/.claude/sounds/audio/peon/`

| # | Soundboard Label | Filename | Sound ID |
|---|-----------------|----------|----------|
| 1 | Be happy to | `be-happy-to.mp3` | 9471 |
| 2 | Double | `double.mp3` | 9466 |
| 3 | Okie dokey | `okie-dokey.mp3` | 9487 |
| 4 | Hmm | `hmm.mp3` | 9472 |
| 5 | I can do that | `i-can-do-that.mp3` | 9465 |
| 6 | I'll try | `ill-try.mp3` | 9479 |
| 7 | Kill them | `kill-them.mp3` | 9473 |
| 8 | Leave me alone | `leave-me-alone.mp3` | 9463 |
| 9 | Look | `look.mp3` | 9474 |
| 10 | Me busy | `me-busy.mp3` | 9464 |
| 11 | Me not that kind of orc | `me-not-that-kind-of-orc.mp3` | 9475 |
| 12 | My tummy feels funny | `my-tummy-feels-funny.mp3` | 9480 |
| 13 | No time for play | `no-time-for-play.mp3` | 9476 |
| 14 | Ohh | `ohh.mp3` | 9470 |
| 15 | OK | `ok.mp3` | 9488 |
| 16 | Ready to work | `ready-to-work.mp3` | 9477 |
| 17 | Something need doing | `something-need-doing.mp3` | 9468 |
| 18 | Swobu/Dabu | `swobu.mp3` | 9478 |
| 19 | Ugh Splat | `ugh-splat.mp3` | 9467 |
| 20 | We need more gold | `we-need-more-gold.mp3` | 9469 |
| 21 | What do you want | `what-do-you-want.mp3` | 9481 |
| 22 | What | `what.mp3` | 9482 |
| 23 | Why not | `why-not.mp3` | 9483 |
| 24 | Work work | `work-work.mp3` | 9484 |
| 25 | Yes | `yes.mp3` | 9485 |
| 26 | Zug zug | `zug-zug.mp3` | 9486 |

## Event-to-Sound Mapping

All events use `type: "audio"`. All categories enabled.

### Completion (volume: 0.7, debounce: 2000ms)

| Event | Sound File | Rationale |
|-------|-----------|-----------|
| Stop | `zug-zug.mp3` | Classic acknowledgment -- work done |
| TaskCompleted | `be-happy-to.mp3` | Enthusiastic task completion |
| SubagentStop | `i-can-do-that.mp3` | Agent reporting it handled the job |
| SessionEnd | `ok.mp3` | Simple sign-off |

### Attention (volume: 0.9, debounce: 2000ms)

| Event | Sound File | Rationale |
|-------|-----------|-----------|
| PermissionRequest | `what-do-you-want.mp3` | Peon awaiting orders |
| StopFailure | `ugh-splat.mp3` | Something went wrong |
| PostToolUseFailure | `my-tummy-feels-funny.mp3` | Tool didn't feel right |
| PermissionDenied | `me-not-that-kind-of-orc.mp3` | Refused to do it |
| TeammateIdle | `no-time-for-play.mp3` | Teammate stopped working |

### Lifecycle (volume: 0.5, debounce: 2000ms)

| Event | Sound File | Rationale |
|-------|-----------|-----------|
| SessionStart | `ready-to-work.mp3` | Peon reporting for duty |
| Setup | `something-need-doing.mp3` | Asking what to set up |
| SubagentStart | `ill-try.mp3` | Agent spawned, giving it a shot |
| WorktreeCreate | `we-need-more-gold.mp3` | Creating new workspace |
| WorktreeRemove | `kill-them.mp3` | Destroying workspace |
| InstructionsLoaded | `yes.mp3` | Acknowledged instructions |

### Progress (volume: 0.3, debounce: 3000ms)

| Event | Sound File | Rationale |
|-------|-----------|-----------|
| PostToolUse | `work-work.mp3` | Just did some work |
| PostToolBatch | `okie-dokey.mp3` | Batch of work done |
| PreCompact | `me-busy.mp3` | Working on compaction |
| PostCompact | `why-not.mp3` | Compaction done |

### Input (volume: 0.5, debounce: 2000ms)

| Event | Sound File | Rationale |
|-------|-----------|-----------|
| UserPromptSubmit | `hmm.mp3` | Pondering input |
| UserPromptExpansion | `look.mp3` | Expanding what was said |
| Notification | `what.mp3` | Alert |
| Elicitation | `what-do-you-want.mp3` | Asking for input (reuse) |
| ElicitationResult | `ohh.mp3` | Got the answer |
| MessageDisplay | `double.mp3` | Message shown |

### Context (volume: 0.3, debounce: 3000ms)

| Event | Sound File | Rationale |
|-------|-----------|-----------|
| CwdChanged | `look.mp3` | Looking at new directory (reuse) |
| FileChanged | `hmm.mp3` | Noticing file change (reuse) |
| ConfigChange | `swobu.mp3` | Config acknowledged |
| PreToolUse | `leave-me-alone.mp3` | About to use a tool |

## Config Changes

### Categories

All categories set to `enabled: true` (progress and context were previously disabled).

### Defaults

| Setting | Value |
|---------|-------|
| `debounce_ms` | 2000 |
| `tts_voice` | "Samantha" (unused, kept for fallback) |
| `tts_rate` | 200 (unused, kept for fallback) |
| `global_volume` | 1.0 |

### Sound Paths

All sounds referenced as `audio/peon/<filename>.mp3` relative to `SOUNDS_DIR`.

## Implementation Steps

1. Create `~/.claude/sounds/audio/peon/` directory
2. On the main board page (already loaded in Playwright), click each sound's "Download this sound" button (26 total, all visible on the listing page)
3. If the download button triggers a file download, capture the MP3; if it navigates to a download page, follow through
4. Save downloaded MP3s with kebab-case filenames matching the table above
5. Generate new `sounds-config.json` with the mapping above
6. Back up existing config as `sounds-config.json.bak`
7. Copy new config into both the project repo and `~/.claude/sounds/`
8. Update `sounds-config.default.json` in the project repo
9. Run `claude-sounds test --all` to verify all sounds play
10. Run `make check` to verify tests + lint + validation pass

## Rollback

`claude-sounds reset` restores from `sounds-config.default.json`. The original default config should be preserved before overwriting.

## Verification

- `claude-sounds test --all` plays every enabled sound
- `claude-sounds status` shows all categories enabled
- `make check` passes (tests, shellcheck, JSON validation)
