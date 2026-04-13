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

for skill_dir in "$PLUGIN_ROOT/skills-copilot/"/*/; do
  [ -f "${skill_dir}SKILL.md" ] || continue
  name=$(basename "$skill_dir")
  dest_dir="$PROJECT_ROOT/.github/skills/$name"
  mkdir -p "$dest_dir"
  dest="$dest_dir/SKILL.md"
  if [ -f "$dest" ]; then
    echo "  skip (exists): .github/skills/$name/SKILL.md"
  else
    cp "${skill_dir}SKILL.md" "$dest"
    echo "  copied: .github/skills/$name/SKILL.md"
  fi
done

echo ""
echo "Done."
echo "  gh copilot CLI:    skills available under .github/skills/"
echo "  Copilot Chat:      .github/copilot-instructions.md loaded as repo context"
