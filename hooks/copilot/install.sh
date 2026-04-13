#!/usr/bin/env bash
# Install SDLC Copilot files into the current project.
# Run from your project root: bash /path/to/install.sh

set -e

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
PROJECT_ROOT="$(pwd)"

echo "SDLC (Copilot) install: $PLUGIN_ROOT → $PROJECT_ROOT"

mkdir -p "$PROJECT_ROOT/.github" "$PROJECT_ROOT/.github/skills/sdlc"

dest="$PROJECT_ROOT/.github/copilot-instructions.md"
if [ -f "$dest" ]; then
  echo "  skip (exists): .github/copilot-instructions.md"
else
  cp "$PLUGIN_ROOT/.github/copilot-instructions.md" "$dest"
  echo "  copied: .github/copilot-instructions.md"
fi

dest="$PROJECT_ROOT/.github/skills/sdlc/SKILL.md"
if [ -f "$dest" ]; then
  echo "  skip (exists): .github/skills/sdlc/SKILL.md"
else
  cp "$PLUGIN_ROOT/skills-copilot/sdlc/SKILL.md" "$dest"
  echo "  copied: .github/skills/sdlc/SKILL.md"
fi

echo ""
echo "Done."
echo "  gh copilot CLI:    skill 'sdlc' available at .github/skills/sdlc/SKILL.md"
echo "  Copilot Chat:      .github/copilot-instructions.md loaded as repo context"
