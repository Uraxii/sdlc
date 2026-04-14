#!/usr/bin/env bash
# Install SDLC Copilot files into the current project.
# Run from your project root: bash /path/to/install.sh

set -e

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
PROJECT_ROOT="$(pwd)"

echo "SDLC (Copilot) install: $PLUGIN_ROOT → $PROJECT_ROOT"

mkdir -p "$PROJECT_ROOT/.github"

dest="$PROJECT_ROOT/.github/copilot-instructions.md"
if [ -f "$dest" ]; then
  echo "  skip (exists): .github/copilot-instructions.md"
else
  cp "$PLUGIN_ROOT/.github/copilot-instructions.md" "$dest"
  echo "  copied: .github/copilot-instructions.md"
fi

mkdir -p "$PROJECT_ROOT/.github/extensions/sdlc"
dest="$PROJECT_ROOT/.github/extensions/sdlc/extension.mjs"
if [ -f "$dest" ]; then
  echo "  skip (exists): .github/extensions/sdlc/extension.mjs"
else
  cp "$PLUGIN_ROOT/extensions/sdlc/extension.mjs" "$dest"
  echo "  copied: .github/extensions/sdlc/extension.mjs"
fi

echo ""
echo "Done."
echo "  gh copilot CLI:    extension at .github/extensions/sdlc/extension.mjs"
echo "  Copilot Chat:      .github/copilot-instructions.md loaded as repo context"
