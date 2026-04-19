# claude-sessions

A CLI wrapper around Claude Code that serializes every conversation to markdown on exit.

Sessions are stored as `.jsonl` files under `~/.claude/projects/`. This tool surfaces them with timestamps and opening prompts, runs new or resumed sessions, and exports the full conversation to `~/.claude/exports/` when you're done.

## Install

```bash
git clone https://github.com/cantux/claude-sessions
cd claude-sessions
./install.sh
```

That's it. The installer checks for Python 3.6+, the `claude` binary, creates the symlink, and sets up the exports directory.

**Requires**: [Claude Code CLI](https://claude.ai/install.sh) installed separately.

## Usage

```bash
# Start a new session — conversation saved to ~/.claude/exports/ on exit
claude-sessions run

# Pass flags through to claude
claude-sessions run -- --model claude-opus-4-7

# Interactive session picker, then resume + export
claude-sessions resume

# Resume a specific session and export it
claude-sessions resume bb105ece

# Export an existing session without launching claude
claude-sessions export bb105ece

# Export to a specific file
claude-sessions export bb105ece ~/notes/session.md

# List all sessions
claude-sessions

# Filter by project name
claude-sessions vcln
```

## Output

Each exported session is a markdown file in `~/.claude/exports/`:

```
~/.claude/exports/
  bb105ece_how_can_I_find_the_previous_list.md
  3f166569_how_can_I_use_claude_code_with_vs_code.md
```

The file name is `<session-id>_<opening-prompt>.md`. Contents include every user and assistant turn, with tool calls shown as fenced JSON blocks.

## Session storage

| Path | Contents |
|------|----------|
| `~/.claude/projects/<project>/*.jsonl` | Raw session files (Claude's format) |
| `~/.claude/exports/` | Exported markdown conversations |

Sessions persist indefinitely on disk. Anthropic's server-side retention is 30 days on most plans; local files are unaffected.

## Requirements

- Python 3.6+
- Claude Code CLI
