#!/usr/bin/env bash
# Links this repo's Claude Code setup into the workspace folder (this repo's parent).
# Safe to run again: existing links are updated, real files are left alone.
set -euo pipefail
cd "$(dirname "$0")"
repo="$(basename "$PWD")"
cd ..

link() { # link <target> <name>
  if [ -e "$2" ] && [ ! -L "$2" ]; then
    echo "skip: $2 is a real file or folder, move it away and rerun" >&2
    return 0
  fi
  ln -sfn "$1" "$2"
  echo "ok:   $2 -> $1"
}

mkdir -p .claude
link "$repo/AGENTS.md"            AGENTS.md
link "$repo/CLAUDE.md"            CLAUDE.md
link "../$repo/skills"            .claude/skills
link "../$repo/agents"            .claude/agents
link "../$repo/settings.json"     .claude/settings.json

echo "Done. Start Claude Code in $(pwd) and check /agents, / and /permissions."
