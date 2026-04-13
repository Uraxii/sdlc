#!/usr/bin/env bash
# Install SDLC Copilot instructions into the current project.
# Run from your project root: bash /path/to/install.sh

set -e

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
PROJECT_ROOT="$(pwd)"

echo "SDLC (Copilot) install: $PLUGIN_ROOT → $PROJECT_ROOT"

mkdir -p "$PROJECT_ROOT/.github" "$PROJECT_ROOT/.github/copilot"

dest="$PROJECT_ROOT/.github/copilot-instructions.md"
if [ -f "$dest" ]; then
  echo "  skip (exists): .github/copilot-instructions.md"
else
  cp "$PLUGIN_ROOT/.github/copilot-instructions.md" "$dest"
  echo "  copied: .github/copilot-instructions.md"
fi

dest="$PROJECT_ROOT/.github/copilot/sdlc.prompt.md"
if [ -f "$dest" ]; then
  echo "  skip (exists): .github/copilot/sdlc.prompt.md"
else
  cp "$PLUGIN_ROOT/.github/copilot/sdlc.prompt.md" "$dest"
  echo "  copied: .github/copilot/sdlc.prompt.md"
fi

echo ""
echo "Done. Copilot will pick up .github/copilot-instructions.md and .github/copilot/sdlc.prompt.md automatically."
