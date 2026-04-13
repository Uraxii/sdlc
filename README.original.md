# SDLC Plugin

A project-agnostic software development lifecycle plugin. Provides a structured multi-role pipeline with 9 mode variants, parallel review gates, and a relay-based handoff system.

Supports: **Claude Code** · **GitHub Copilot** · **Cursor** · **Windsurf** · **Cline** · **Codex**

## What It Does

Replaces ad-hoc AI coding sessions with a disciplined pipeline:
- **Role system**: Architect, Developer, UX Designer, Skeptic, Security Auditor, Tester, Friction Reviewer, Orchestrator, and more
- **9 pipeline modes**: Right-sized process for every change type (new feature, bug fix, refactor, hotfix, etc.)
- **Parallel gates**: Skeptic + Security Auditor run concurrently post-implementation
- **Relay files**: Structured handoff docs so every role reads upstream context before starting
- **Memory system**: Roles accumulate project-specific lessons across sessions (Claude Code)

## Installation

### Claude Code (plugin manager)

```bash
claude plugin install github.com/Uraxii/sdlc
```

Then run the project setup hook from your project root:

```bash
bash "$CLAUDE_PLUGIN_ROOT/hooks/install.sh"
```

### Other IDEs

| IDE | File |
|-----|------|
| GitHub Copilot | Copy `.github/copilot-instructions.md` to your project's `.github/` |
| Cursor | Copy `.cursor/rules/sdlc.mdc` to your project's `.cursor/rules/` |
| Windsurf | Copy `.windsurf/rules/sdlc.md` to your project's `.windsurf/rules/` |
| Cline | Copy `.clinerules/sdlc.md` to your project root as `.clinerules` |
| Codex / OpenAI | Reference `AGENTS.md` |

## Usage

### Claude Code

```
/sdlc                    # Start a pipeline run — selects mode interactively
/sdlc:full-ui            # New feature with UI changes
/sdlc:full-logic         # New feature, no UI
/sdlc:lightweight-ui     # Bug fix with UI
/sdlc:lightweight-logic  # Bug fix, no UI
/sdlc:refactor           # Behavior-preserving restructure
/sdlc:hotfix             # Production incident
/sdlc:dependency-bump    # Library update
/sdlc:config-data        # Config/static data change
/sdlc:docs-only          # Docs or comments only
/sdlc:poc                # Fast proof-of-concept (NOT shippable)
```

### Other IDEs

Reference modes by name in chat:

```
Use sdlc:full-ui for this task.
Use sdlc:hotfix — production is down.
```

## Pipeline Modes

| Mode | Pipeline |
|------|----------|
| `full-ui` | Architect → UX → Skeptic → Developer → Skeptic + SecAudit → Tester → Friction |
| `full-logic` | Architect → Skeptic → Developer → Skeptic + SecAudit → Tester → Friction |
| `lightweight-ui` | UX → Developer → Skeptic + SecAudit → Tester → Friction |
| `lightweight-logic` | Developer → Skeptic + SecAudit → Tester → Friction |
| `refactor` | Architect → Skeptic → Developer → Skeptic + SecAudit → Tester → Friction |
| `hotfix` | Developer → Skeptic + SecAudit → Tester → Friction |
| `dependency-bump` | SecAudit → Tester |
| `config-data` | Skeptic → Friction |
| `docs-only` | Skeptic |
| `poc` | Skeptic (concept) → Developer → Tester (smoke) — NOT shippable |

## License

GPLv2 — see LICENSE.
