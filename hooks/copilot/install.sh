#!/usr/bin/env bash
# Install SDLC Copilot files into the current project.
# Run from your project root: bash /path/to/install.sh

set -e

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
PROJECT_ROOT="$(pwd)"

echo "SDLC (Copilot) install: $PLUGIN_ROOT → $PROJECT_ROOT"

# Create directories
mkdir -p \
  "$PROJECT_ROOT/.github/extensions/sdlc" \
  "$PROJECT_ROOT/sdlc" \
  "$PROJECT_ROOT/templates"

# Copy copilot-instructions.md (skip if present)
dest="$PROJECT_ROOT/.github/copilot-instructions.md"
if [ -f "$dest" ]; then
  echo "  skip (exists): .github/copilot-instructions.md"
else
  cp "$PLUGIN_ROOT/.github/copilot-instructions.md" "$dest"
  echo "  copied: .github/copilot-instructions.md"
fi

# Copy extension (always overwrite — plugin-managed)
cp "$PLUGIN_ROOT/extensions/sdlc/extension.mjs" \
   "$PROJECT_ROOT/.github/extensions/sdlc/extension.mjs"
echo "  updated: .github/extensions/sdlc/extension.mjs"

# Copy core-memory.md (skip if present)
if [ ! -f "$PROJECT_ROOT/core-memory.md" ]; then
  cp "$PLUGIN_ROOT/core-memory.md" "$PROJECT_ROOT/core-memory.md"
  echo "  copied: core-memory.md"
else
  echo "  skip (exists): core-memory.md"
fi

# Copy relay template
if [ -f "$PLUGIN_ROOT/templates/relay-template.md" ]; then
  cp "$PLUGIN_ROOT/templates/relay-template.md" "$PROJECT_ROOT/templates/relay-template.md"
  echo "  copied: templates/relay-template.md"
fi

# Create taskboard.md (skip if present)
if [ ! -f "$PROJECT_ROOT/taskboard.md" ]; then
  printf '# Task Board\n| Task | Status | Owner | Blocked By | Notes |\n|------|--------|-------|-----------|-------|\n' \
    > "$PROJECT_ROOT/taskboard.md"
  echo "  created: taskboard.md"
else
  echo "  skip (exists): taskboard.md"
fi

echo ""
echo "Done."
echo "  gh copilot CLI:    /sdlc slash command via .github/extensions/sdlc/extension.mjs"
echo "  Copilot Chat:      .github/copilot-instructions.md loaded as repo context"
