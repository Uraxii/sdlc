#!/usr/bin/env bash
# Install SDLC agents and pipeline files into the current project.
# Run from your project root: bash "$CLAUDE_PLUGIN_ROOT/hooks/install.sh"

set -e

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
PROJECT_ROOT="$(pwd)"

echo "SDLC install: $PLUGIN_ROOT → $PROJECT_ROOT"

# Create directories
mkdir -p \
  "$PROJECT_ROOT/.claude/agents/memory" \
  "$PROJECT_ROOT/templates" \
  "$PROJECT_ROOT/sdlc"

# Copy agent files (always overwrite — plugin-managed definitions)
for f in "$PLUGIN_ROOT/agents/"*.md; do
  dest="$PROJECT_ROOT/.claude/agents/$(basename "$f")"
  cp "$f" "$dest"
  echo "  updated: .claude/agents/$(basename "$f")"
done

# Create empty memory files (skip if present)
for agent in architect developer skeptic tester security-auditor ux-designer \
             friction-reviewer orchestrator progenitor monitor; do
  mem="$PROJECT_ROOT/.claude/agents/memory/$agent.md"
  if [ ! -f "$mem" ]; then
    touch "$mem"
    echo "  created: .claude/agents/memory/$agent.md"
  fi
done

# Copy skills (always overwrite — plugin-managed)
mkdir -p "$PROJECT_ROOT/.claude/skills"
if [ -d "$PLUGIN_ROOT/skills/sdlc" ]; then
  rm -rf "$PROJECT_ROOT/.claude/skills/sdlc"
  cp -r "$PLUGIN_ROOT/skills/sdlc" "$PROJECT_ROOT/.claude/skills/sdlc"
  echo "  updated: .claude/skills/sdlc"
fi

# Copy templates
cp "$PLUGIN_ROOT/templates/relay-template.md" "$PROJECT_ROOT/templates/relay-template.md"
echo "  copied: templates/relay-template.md"

# Copy core-memory.md (skip if present)
if [ ! -f "$PROJECT_ROOT/core-memory.md" ]; then
  cp "$PLUGIN_ROOT/core-memory.md" "$PROJECT_ROOT/core-memory.md"
  echo "  copied: core-memory.md"
else
  echo "  skip (exists): core-memory.md"
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
echo "Done. Next steps:"
echo "  1. Edit .claude/agents/ux-designer.md — fill in design token table"
echo "  2. Edit .claude/agents/CLAUDE.md — update <project>/agent-memory.md path"
echo "  3. Edit .claude/agents/developer.md — update version file reference"
echo "  4. Create <project>/agent-memory.md with project domain knowledge"
echo "  5. Use /sdlc to start a pipeline run"
