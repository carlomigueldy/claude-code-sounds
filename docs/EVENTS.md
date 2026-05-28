# Event Reference

All 29 events supported by Claude Code Sounds, organized by category.

Default values come from `sounds-config.default.json`. Per-event config in `~/.claude/sounds/sounds-config.json` overrides these.

---

## completion

Events in this category are **enabled by default**.

### Stop

| Field | Value |
|-------|-------|
| Category | completion |
| Description | Claude Code finishes a response |
| Type | audio |
| Sound | `audio/stop.aiff` |
| Volume | 0.8 |
| Debounce | 2000 ms |
| Enabled | yes |

### TaskCompleted

| Field | Value |
|-------|-------|
| Category | completion |
| Description | A tracked task is marked complete |
| Type | tts |
| Message | "Task complete" |
| Volume | 0.6 |
| Debounce | 2000 ms |
| Enabled | yes |

### SubagentStop

| Field | Value |
|-------|-------|
| Category | completion |
| Description | A dispatched subagent finishes its work |
| Type | tts |
| Message | "Agent finished" |
| Volume | 0.5 |
| Debounce | 2000 ms |
| Enabled | yes |

### SessionEnd

| Field | Value |
|-------|-------|
| Category | completion |
| Description | Claude Code session ends |
| Type | tts |
| Message | "Session ended" |
| Volume | 0.4 |
| Debounce | 2000 ms |
| Enabled | yes |

---

## attention

Events in this category are **enabled by default**.

### PermissionRequest

| Field | Value |
|-------|-------|
| Category | attention |
| Description | Claude Code needs permission to run a tool |
| Type | audio |
| Sound | `audio/permission.aiff` |
| Volume | 0.9 |
| Debounce | 3000 ms |
| Enabled | yes |

### StopFailure

| Field | Value |
|-------|-------|
| Category | attention |
| Description | API error (rate limit, auth failure, server error) |
| Type | audio |
| Sound | `audio/error.aiff` |
| Volume | 1.0 |
| Debounce | 2000 ms |
| Enabled | yes |

### PostToolUseFailure

| Field | Value |
|-------|-------|
| Category | attention |
| Description | A tool call fails |
| Type | audio |
| Sound | `audio/tool-error.aiff` |
| Volume | 0.8 |
| Debounce | 2000 ms |
| Enabled | yes |

### PermissionDenied

| Field | Value |
|-------|-------|
| Category | attention |
| Description | Auto-mode classifier rejects a tool call |
| Type | tts |
| Message | "Permission denied" |
| Volume | 0.7 |
| Debounce | 2000 ms |
| Enabled | yes |

### TeammateIdle

| Field | Value |
|-------|-------|
| Category | attention |
| Description | A teammate agent is waiting for work |
| Type | tts |
| Message | "Teammate idle" |
| Volume | 0.5 |
| Debounce | 5000 ms |
| Enabled | yes |

---

## lifecycle

Events in this category are **enabled by default** (individual events may still be disabled).

### SessionStart

| Field | Value |
|-------|-------|
| Category | lifecycle |
| Description | New Claude Code session begins |
| Type | tts |
| Message | "Session started" |
| Volume | 0.4 |
| Debounce | 2000 ms |
| Enabled | yes |

### Setup

| Field | Value |
|-------|-------|
| Category | lifecycle |
| Description | Initial session setup completes |
| Type | tts |
| Message | "Setup complete" |
| Volume | 0.3 |
| Debounce | 2000 ms |
| Enabled | no |

### SubagentStart

| Field | Value |
|-------|-------|
| Category | lifecycle |
| Description | A subagent is dispatched |
| Type | tts |
| Message | "Agent started" |
| Volume | 0.4 |
| Debounce | 2000 ms |
| Enabled | yes |

### WorktreeCreate

| Field | Value |
|-------|-------|
| Category | lifecycle |
| Description | A git worktree is created |
| Type | tts |
| Message | "Worktree created" |
| Volume | 0.4 |
| Debounce | 2000 ms |
| Enabled | no |

### WorktreeRemove

| Field | Value |
|-------|-------|
| Category | lifecycle |
| Description | A git worktree is removed |
| Type | tts |
| Message | "Worktree removed" |
| Volume | 0.4 |
| Debounce | 2000 ms |
| Enabled | no |

### InstructionsLoaded

| Field | Value |
|-------|-------|
| Category | lifecycle |
| Description | CLAUDE.md or similar instructions are loaded |
| Type | tts |
| Message | "Instructions loaded" |
| Volume | 0.3 |
| Debounce | 2000 ms |
| Enabled | no |

---

## progress

Events in this category are **disabled by default** (the category itself is off).

### PostToolUse

| Field | Value |
|-------|-------|
| Category | progress |
| Description | A tool call completes successfully |
| Type | audio |
| Sound | `audio/tool-done.aiff` |
| Volume | 0.3 |
| Debounce | 2000 ms |
| Enabled | no |

### PostToolBatch

| Field | Value |
|-------|-------|
| Category | progress |
| Description | A batch of tool calls completes |
| Type | tts |
| Message | "Batch complete" |
| Volume | 0.3 |
| Debounce | 2000 ms |
| Enabled | no |

### PreCompact

| Field | Value |
|-------|-------|
| Category | progress |
| Description | Context window compaction begins |
| Type | tts |
| Message | "Compacting context" |
| Volume | 0.5 |
| Debounce | 2000 ms |
| Enabled | yes |

### PostCompact

| Field | Value |
|-------|-------|
| Category | progress |
| Description | Context window compaction finishes |
| Type | tts |
| Message | "Context compacted" |
| Volume | 0.5 |
| Debounce | 2000 ms |
| Enabled | yes |

---

## input

Events in this category are **enabled by default** (individual events may still be disabled).

### UserPromptSubmit

| Field | Value |
|-------|-------|
| Category | input |
| Description | User submits a prompt |
| Type | — |
| Sound/Message | — |
| Volume | — |
| Debounce | — |
| Enabled | no |

### UserPromptExpansion

| Field | Value |
|-------|-------|
| Category | input |
| Description | User prompt is expanded |
| Type | — |
| Sound/Message | — |
| Volume | — |
| Debounce | — |
| Enabled | no |

### Notification

| Field | Value |
|-------|-------|
| Category | input |
| Description | System notification event |
| Type | audio |
| Sound | `audio/notification.aiff` |
| Volume | 0.6 |
| Debounce | 2000 ms |
| Enabled | yes |

### Elicitation

| Field | Value |
|-------|-------|
| Category | input |
| Description | MCP server requests user input |
| Type | tts |
| Message | "Input needed" |
| Volume | 0.6 |
| Debounce | 2000 ms |
| Enabled | yes |

### ElicitationResult

| Field | Value |
|-------|-------|
| Category | input |
| Description | MCP input form submitted/dismissed |
| Type | — |
| Sound/Message | — |
| Volume | — |
| Debounce | — |
| Enabled | no |

### MessageDisplay

| Field | Value |
|-------|-------|
| Category | input |
| Description | A message is displayed |
| Type | — |
| Sound/Message | — |
| Volume | — |
| Debounce | — |
| Enabled | no |

---

## context

Events in this category are **disabled by default** (the category itself is off).

### CwdChanged

| Field | Value |
|-------|-------|
| Category | context |
| Description | Working directory changes |
| Type | tts |
| Message | "Directory changed" |
| Volume | 0.3 |
| Debounce | 2000 ms |
| Enabled | no |

### FileChanged

| Field | Value |
|-------|-------|
| Category | context |
| Description | A watched file changes |
| Type | — |
| Sound/Message | — |
| Volume | — |
| Debounce | — |
| Enabled | no |

### ConfigChange

| Field | Value |
|-------|-------|
| Category | context |
| Description | Settings configuration changes |
| Type | tts |
| Message | "Config changed" |
| Volume | 0.4 |
| Debounce | 2000 ms |
| Enabled | no |

### PreToolUse

| Field | Value |
|-------|-------|
| Category | context |
| Description | A tool call is about to execute |
| Type | — |
| Sound/Message | — |
| Volume | — |
| Debounce | — |
| Enabled | no |

---

## Global Defaults

These values apply when an event does not specify its own:

| Setting | Default |
|---------|---------|
| debounce_ms | 2000 |
| tts_voice | Samantha |
| tts_rate | 200 |
| global_volume | 1 |

See [CUSTOMIZING.md](CUSTOMIZING.md) for how to change these.
