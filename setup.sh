#!/usr/bin/env bash
# Links this repo's Claude Code setup into the workspace folder (this repo's parent).
set -euo pipefail
cd "$(dirname "$0")"
repo="$(basename "$PWD")"
cd ..

mkdir -p .claude
ln -s "$repo/AGENTS.md" AGENTS.md
ln -s "$repo/CLAUDE.md" CLAUDE.md
ln -s "../$repo/skills" .claude/skills
ln -s "../$repo/agents" .claude/agents
ln -s "../$repo/settings.json" .claude/settings.json

echo "Done. Start Claude Code in $(pwd) and check /agents, / and /permissions."
