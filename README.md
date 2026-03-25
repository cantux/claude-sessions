# claude-sessions

A Claude Code plugin that lets you browse and resume local session history.

Claude Code stores all conversations as `.jsonl` files under `~/.claude/projects/`. This plugin surfaces them with timestamps, file sizes, and the opening prompt of each session — so you can find and resume past conversations without guessing UUIDs.

## What it provides

| Component | Path | Purpose |
|-----------|------|---------|
| Skill | `skills/claude-sessions/SKILL.md` | `/claude-sessions` command inside Claude Code |
| CLI script | `bin/claude-sessions` | Standalone terminal command |

## Usage

### Inside Claude Code

After installing the plugin, type `/claude-sessions` in any Claude Code session:

```
DATE               SIZE    PROJECT              ID        SUMMARY
----------------------------------------------------------------------------------------------------
2026-03-23 22:40   136K  -home-ctuk           1b90f758  how can I find the previous list of sessions...
2026-03-24 02:58  1100K  -home-ctuk           bb105ece  I wan to make openclaw work with claude cli...
2026-03-25 03:42  1600K  -home-ctuk           3f166569  how can I use claude code with vs code?

Total: 3 session(s)
Resume: claude --resume <session-id>  |  Browse: claude --resume
```

Claude will then offer to resume any session you point to.

### From the terminal

```bash
# List all sessions across all projects
claude-sessions

# Filter by project name substring
claude-sessions home-ctuk
```

## Installation

### Plugin (recommended)

```bash
/plugin install cantux/claude-sessions
```

Or add manually to `~/.claude/settings.json`:

```json
{
  "plugins": ["cantux/claude-sessions"]
}
```

### CLI script only

```bash
ln -s ~/Projects/claude-sessions/bin/claude-sessions ~/.local/bin/claude-sessions
chmod +x ~/Projects/claude-sessions/bin/claude-sessions
```

## Session storage

Sessions are plain files — they do not expire. Anthropic's server-side retention is 30 days for most plans, but your local files persist indefinitely unless deleted.

| Path | Contents |
|------|----------|
| `~/.claude/projects/<project>/*.jsonl` | Session conversation files |
| `~/.claude/projects/<project>/memory/` | Auto-memory for that project |

## Resuming sessions

```bash
# Interactive picker (keyboard nav, search, preview)
claude --resume

# Resume by session ID prefix
claude --resume bb105ece

# Resume most recent session
claude --continue
```

## Requirements

- Python 3.6+
- Claude Code CLI
