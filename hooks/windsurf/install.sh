#!/usr/bin/env bash
# Install SDLC Windsurf rules and skills into the current project.
# Run from your project root: bash /path/to/install.sh

set -e

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
PROJECT_ROOT="$(pwd)"

echo "SDLC (Windsurf) install: $PLUGIN_ROOT → $PROJECT_ROOT"

mkdir -p "$PROJECT_ROOT/.windsurf/rules" "$PROJECT_ROOT/.windsurf/skills/sdlc"

dest="$PROJECT_ROOT/.windsurf/rules/sdlc.md"
if [ -f "$dest" ]; then
  echo "  skip (exists): .windsurf/rules/sdlc.md"
else
  cp "$PLUGIN_ROOT/.windsurf/rules/sdlc.md" "$dest"
  echo "  copied: .windsurf/rules/sdlc.md"
fi

dest="$PROJECT_ROOT/.windsurf/skills/sdlc/SKILL.md"
if [ -f "$dest" ]; then
  echo "  skip (exists): .windsurf/skills/sdlc/SKILL.md"
else
  cp "$PLUGIN_ROOT/.windsurf/skills/sdlc/SKILL.md" "$dest"
  echo "  copied: .windsurf/skills/sdlc/SKILL.md"
fi

echo ""
echo "Done. Windsurf will pick up .windsurf/rules/sdlc.md automatically."
