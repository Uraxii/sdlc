#!/usr/bin/env bash
# Install SDLC Codex/OpenAI agent instructions into the current project.
# Run from your project root: bash /path/to/install.sh

set -e

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
PROJECT_ROOT="$(pwd)"

echo "SDLC (Codex) install: $PLUGIN_ROOT → $PROJECT_ROOT"

dest="$PROJECT_ROOT/AGENTS.md"
if [ -f "$dest" ]; then
  echo "  skip (exists): AGENTS.md"
else
  cp "$PLUGIN_ROOT/AGENTS.md" "$dest"
  echo "  copied: AGENTS.md"
fi

echo ""
echo "Done. Codex/OpenAI will pick up AGENTS.md automatically."
