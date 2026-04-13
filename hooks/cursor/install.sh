#!/usr/bin/env bash
# Install SDLC Cursor rules and skills into the current project.
# Run from your project root: bash /path/to/install.sh

set -e

PLUGIN_ROOT="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(pwd)"

echo "SDLC (Cursor) install: $PLUGIN_ROOT → $PROJECT_ROOT"

mkdir -p "$PROJECT_ROOT/.cursor/rules" "$PROJECT_ROOT/.cursor/skills/sdlc"

dest="$PROJECT_ROOT/.cursor/rules/sdlc.mdc"
if [ -f "$dest" ]; then
  echo "  skip (exists): .cursor/rules/sdlc.mdc"
else
  cp "$PLUGIN_ROOT/.cursor/rules/sdlc.mdc" "$dest"
  echo "  copied: .cursor/rules/sdlc.mdc"
fi

dest="$PROJECT_ROOT/.cursor/skills/sdlc/SKILL.md"
if [ -f "$dest" ]; then
  echo "  skip (exists): .cursor/skills/sdlc/SKILL.md"
else
  cp "$PLUGIN_ROOT/.cursor/skills/sdlc/SKILL.md" "$dest"
  echo "  copied: .cursor/skills/sdlc/SKILL.md"
fi

echo ""
echo "Done. Cursor will pick up .cursor/rules/sdlc.mdc automatically."
