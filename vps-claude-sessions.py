#!/usr/bin/env python3
"""List / resolve resumable Claude Code conversations on this machine.

Runs on the VPS (piped over ssh by the `qkvps` CLI). Reads the on-disk
transcripts under ~/.claude/projects/<encoded-cwd>/<uuid>.jsonl, which persist
across reboots/crashes.

Usage:
  vps-claude-sessions.py                 human table, newest first
  vps-claude-sessions.py --json          same data as a JSON array
  vps-claude-sessions.py --resolve <id>  print "<full-uuid>\\t<cwd>" for the id
                                         (accepts a short id prefix); used by
                                         `qkvps --resume`. Exit 3=none, 4=ambiguous.
"""
import glob
import json
import os
import sys
from datetime import datetime, timezone

root = os.path.expanduser("~/.claude/projects")
rows = []  # (mtime, full_id, cwd, label)
for f in glob.glob(os.path.join(root, "*", "*.jsonl")):  # top-level only; skips */subagents/*
    try:
        mtime = os.path.getmtime(f)
    except OSError:
        continue
    sid = os.path.basename(f)[:-6]
    cwd, label, first_user = None, None, None
    try:
        with open(f, "r", errors="replace") as fh:
            for line in fh:
                line = line.strip()
                if not line:
                    continue
                try:
                    o = json.loads(line)
                except ValueError:
                    continue
                if cwd is None and isinstance(o.get("cwd"), str):
                    cwd = o["cwd"]
                if o.get("type") == "summary" and o.get("summary"):
                    label = o["summary"]  # last summary wins
                if first_user is None and o.get("type") == "user":
                    c = o.get("message", {}).get("content")
                    txt = c if isinstance(c, str) else ""
                    if isinstance(c, list):
                        txt = "".join(
                            b.get("text", "") for b in c
                            if isinstance(b, dict) and b.get("type") == "text"
                        )
                    txt = " ".join(txt.split())
                    if txt and not txt.startswith("<") and "tool_result" not in txt:
                        first_user = txt[:90]
    except OSError:
        continue
    rows.append((mtime, sid, cwd or "", label or first_user or "(no label)"))

rows.sort(reverse=True)
args = sys.argv[1:]

if args and args[0] == "--resolve":
    if len(args) < 2:
        sys.stderr.write("resolve: need an id\n"); sys.exit(2)
    want = args[1]
    matches = [(sid, cwd) for (_, sid, cwd, _) in rows if sid.startswith(want) or sid == want]
    if len(matches) == 1:
        sys.stdout.write("%s\t%s\n" % matches[0]); sys.exit(0)
    if not matches:
        sys.stderr.write("no Claude conversation matches id '%s'\n" % want); sys.exit(3)
    sys.stderr.write("id '%s' is ambiguous: %s\n" % (want, ", ".join(m[0][:8] for m in matches)))
    sys.exit(4)

if "--json" in args:
    out = [
        {
            "id": sid,
            "cwd": cwd,
            "last_active_utc": datetime.fromtimestamp(mtime, timezone.utc).isoformat(timespec="seconds"),
            "label": label,
        }
        for mtime, sid, cwd, label in rows
    ]
    print(json.dumps(out, indent=2))
    sys.exit(0)

home = os.path.expanduser("~")
print("%-14s  %-8s  %-36s  %s" % ("last active", "id", "project cwd", "what it was about"))
print("-" * 100)
for mtime, sid, cwd, label in rows[:20]:
    ts = datetime.fromtimestamp(mtime, timezone.utc).strftime("%m-%d %H:%M")
    disp = cwd.replace(home, "~", 1) if cwd else "?"
    print("%-14s  %-8s  %-36s  %s" % (ts, sid[:8], disp, label[:66]))
if rows:
    print("\nResume one:  qkvps --resume <id>   (times are UTC)")
