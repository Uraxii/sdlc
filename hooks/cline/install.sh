#!/usr/bin/env bash
# Install SDLC Cline rules into the current project.
# Run from your project root: bash /path/to/install.sh

set -e

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
PROJECT_ROOT="$(pwd)"

echo "SDLC (Cline) install: $PLUGIN_ROOT → $PROJECT_ROOT"

mkdir -p "$PROJECT_ROOT/.clinerules"

dest="$PROJECT_ROOT/.clinerules/sdlc.md"
if [ -f "$dest" ]; then
  echo "  skip (exists): .clinerules/sdlc.md"
else
  cp "$PLUGIN_ROOT/.clinerules/sdlc.md" "$dest"
  echo "  copied: .clinerules/sdlc.md"
fi

echo ""
echo "Done. Cline will pick up .clinerules/sdlc.md automatically."
