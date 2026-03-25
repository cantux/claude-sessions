---
name: claude-sessions
description: List all local Claude Code sessions with timestamps, sizes, and opening prompt summaries. Use when user asks to see previous sessions, browse session history, or find a past conversation. Invokes `/claude-sessions` to show the session list.
tools: Bash
disable-model-invocation: false
---

# Claude Sessions

List all locally stored Claude Code sessions with timestamps, sizes, and opening prompt summaries.

## What to do

Run the session listing script and display the output. If the script is installed in PATH, use it directly. Otherwise inline the logic.

```bash
# Try installed script first, fall back to inline
if command -v claude-sessions &>/dev/null; then
  claude-sessions "$@"
else
  python3 -c "
import json, sys
from pathlib import Path
from datetime import datetime

SESSIONS_DIR = Path.home() / '.claude' / 'projects'
SKIP = ('<local-command-caveat>', '<command-name>', '<command-message>')

def first_msg(path):
    try:
        with open(path) as f:
            for line in f:
                try:
                    obj = json.loads(line)
                    if obj.get('type') != 'user':
                        continue
                    c = obj.get('message', {}).get('content', '')
                    if isinstance(c, list):
                        c = next((x['text'] for x in c if isinstance(x,dict) and x.get('type')=='text'), '')
                    if isinstance(c, str):
                        t = c.strip().replace('\n', ' ')
                        if t and not any(t.startswith(p) for p in SKIP):
                            return t
                except: pass
    except: pass
    return '(no user message)'

sessions = []
for d in SESSIONS_DIR.iterdir():
    if not d.is_dir(): continue
    for f in d.glob('*.jsonl'):
        sessions.append((f.stat().st_mtime, f, d.name, f.stat().st_size // 1024))
sessions.sort()

print(f\"{'DATE':<18} {'SIZE':>6}  {'PROJECT':<18} {'ID':>10}  SUMMARY\")
print('-' * 100)
for mtime, f, proj, kb in sessions:
    dt = datetime.fromtimestamp(mtime).strftime('%Y-%m-%d %H:%M')
    print(f\"{dt:<18} {kb:>5}K  {proj[:18]:<18} {f.stem[:8]}  {first_msg(f)[:55]}\")
print(f'\nTotal: {len(sessions)} session(s)')
print('Resume: claude --resume <session-id>  |  Browse: claude --resume')
"
fi
```

After displaying the output, offer to resume any session the user points to by name or ID prefix.

## Installation tip

To install the `claude-sessions` CLI globally:
```bash
ln -s ~/Projects/claude-sessions/bin/claude-sessions ~/.local/bin/claude-sessions
chmod +x ~/Projects/claude-sessions/bin/claude-sessions
```
