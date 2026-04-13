# SDLC Plugin

Structured multi-role pipeline for AI-assisted development. Replaces ad-hoc AI sessions with disciplined workflows: role-based agents, 10 pipeline modes, parallel review gates, and persistent memory across sessions.

Supports: **Claude Code** · **GitHub Copilot** · **Cursor** · **Windsurf** · **Cline** · **Codex**

---

## Installation

Run from your project root.

**Linux / macOS:**

```bash
bash <(curl -fsSL https://github.com/Uraxii/sdlc/releases/latest/download/install.sh)
```

**Windows:**

```powershell
iex "& { $(irm https://github.com/Uraxii/sdlc/releases/latest/download/install.ps1) }"
```

The installer prompts you to select your IDE. Pass a flag to skip the prompt:

| IDE | Flag |
|-----|------|
| Claude Code | `--claude-code` / `-ClaudeCode` |
| GitHub Copilot | `--copilot` / `-Copilot` |
| Cursor | `--cursor` / `-Cursor` |
| Windsurf | `--windsurf` / `-Windsurf` |
| Cline | `--cline` / `-Cline` |
| Codex / OpenAI | `--codex` / `-Codex` |

```bash
bash <(curl -fsSL https://github.com/Uraxii/sdlc/releases/latest/download/install.sh) --cursor
```

**Claude Code via plugin manager** (alternative):

```bash
claude plugin install github.com/Uraxii/sdlc && bash "$CLAUDE_PLUGIN_ROOT/hooks/install.sh"
```

---

## Project Setup (Claude Code)

After install, configure the agents for your project:

1. **`.claude/agents/ux-designer.md`** — fill in the design token table
2. **`.claude/agents/CLAUDE.md`** — update the `<project>/agent-memory.md` path
3. **`.claude/agents/developer.md`** — update the version file reference
4. Create `agent-memory.md` in your project root — add domain knowledge: tech stack, key concepts, known quirks

---

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
/sdlc:config-data        # Config or static data change
/sdlc:docs-only          # Docs or comments only
/sdlc:poc                # Fast proof-of-concept — NOT shippable
```

`/sdlc` asks two questions to pick the right mode: does this touch UI, and is it new work or a fix?

### Other IDEs

Reference modes by name in chat:

```
Use sdlc:full-ui for this task.
Use sdlc:hotfix — production is down.
```

---

## Pipeline Modes

| Mode | Pipeline |
|------|----------|
| `full-ui` | Architect → UX → Skeptic → Developer → Skeptic ∥ SecAudit → Tester → Friction |
| `full-logic` | Architect → Skeptic → Developer → Skeptic ∥ SecAudit → Tester → Friction |
| `lightweight-ui` | UX → Developer → Skeptic ∥ SecAudit → Tester → Friction |
| `lightweight-logic` | Developer → Skeptic ∥ SecAudit → Tester → Friction |
| `refactor` | Architect → Skeptic → Developer → Skeptic ∥ SecAudit → Tester → Friction |
| `hotfix` | Developer → Skeptic ∥ SecAudit → Tester → Friction (async) |
| `dependency-bump` | SecAudit → Tester |
| `config-data` | Skeptic → Friction |
| `docs-only` | Skeptic |
| `poc` | Skeptic (concept) → Developer → Tester (smoke) — NOT shippable |

Skeptic + Security Auditor always run concurrently (∥) after implementation. Neither is bypassable.

---

## Roles

| Role | Responsibility |
|------|----------------|
| Architect | System design, patterns, ADRs, API contracts — no code |
| Developer | Implements Architect output — bumps version on every change |
| UX Designer | Visual identity, design tokens, style spec — mandatory on UI changes |
| Skeptic | Blocking review gate — runs pre- and post-implementation |
| Security Auditor | CVE scanning, threat modeling, auth/authz, data exposure |
| Tester | Test strategy, edge cases, Playwright, adversarial testing |
| Friction Reviewer | Reviews the process, not the code — updates memory with improvements |
| Orchestrator | Runs pipelines, spawns parallel agents, manages failures |
| Monitor | Consolidates cross-cutting patterns into `core-memory.md` |
| Progenitor | Creates, modifies, and retires agent role definitions |

---

## How It Works

Each pipeline run creates a relay file at `sdlc/<task-slug>/relay.md`. Every role reads upstream context before adding its section — no context loss between roles.

Roles accumulate lessons in `.claude/agents/memory/<role>.md` across sessions. The Monitor agent consolidates cross-cutting patterns into `core-memory.md`.

---

## License

GPLv2 — see LICENSE.
