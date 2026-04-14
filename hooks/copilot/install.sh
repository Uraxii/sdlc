#!/usr/bin/env bash
# Install SDLC Copilot files into the current project.
# Run from your project root: bash /path/to/install.sh

set -e

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
PROJECT_ROOT="$(pwd)"

echo "SDLC (Copilot) install: $PLUGIN_ROOT -> $PROJECT_ROOT"

# Create directories
mkdir -p \
  "$PROJECT_ROOT/.github/agents" \
  "$PROJECT_ROOT/.github/skills" \
  "$PROJECT_ROOT/sdlc" \
  "$PROJECT_ROOT/templates"

# Copy agents (always overwrite — plugin-managed)
for agent in "$PLUGIN_ROOT"/agents/copilot/*.agent.md; do
  [ -f "$agent" ] || continue
  name=$(basename "$agent")
  cp "$agent" "$PROJECT_ROOT/.github/agents/$name"
  echo "  updated: .github/agents/$name"
done

# Copy skills (always overwrite — plugin-managed)
for skill_dir in "$PLUGIN_ROOT"/skills/copilot/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")
  mkdir -p "$PROJECT_ROOT/.github/skills/$skill_name"
  for md in "$skill_dir"*.md; do
    [ -f "$md" ] || continue
    cp "$md" "$PROJECT_ROOT/.github/skills/$skill_name/$(basename "$md")"
    echo "  updated: .github/skills/$skill_name/$(basename "$md")"
  done
done

# Copy copilot-instructions.md (skip if present)
dest="$PROJECT_ROOT/.github/copilot-instructions.md"
if [ -f "$dest" ]; then
  echo "  skip (exists): .github/copilot-instructions.md"
else
  cp "$PLUGIN_ROOT/.github/copilot-instructions.md" "$dest"
  echo "  copied: .github/copilot-instructions.md"
fi

# Copy core-memory.md (skip if present)
if [ ! -f "$PROJECT_ROOT/core-memory.md" ]; then
  cp "$PLUGIN_ROOT/core-memory.md" "$PROJECT_ROOT/core-memory.md"
  echo "  copied: core-memory.md"
else
  echo "  skip (exists): core-memory.md"
fi

# Copy relay template (always overwrite)
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
echo "  Copilot agents:  .github/agents/*.agent.md"
echo "  Copilot skills:  .github/skills/*/SKILL.md"
echo "  Copilot Chat:    .github/copilot-instructions.md loaded as repo context"
