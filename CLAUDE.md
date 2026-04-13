# SDLC Plugin — Claude Code

Role system and pipeline protocol defined in `agents/CLAUDE.md` (plugin source) and `.claude/agents/CLAUDE.md` (installed in project).

## Install

```
claude plugin install github.com/Uraxii/sdlc
```

Then in your project root:

```bash
bash "$CLAUDE_PLUGIN_ROOT/hooks/install.sh"
```

## Project Setup

After install, add project context here:
- Tech stack
- Project structure
- Project-specific agent constraints