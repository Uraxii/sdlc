# SDLC Plugin

Structured multi-role pipeline for AI-assisted development. Replaces ad-hoc AI sessions with disciplined workflows: role-based agents, 2 pipeline modes, parallel review gates, and persistent memory across sessions.

Supports: **Claude Code** · **GitHub Copilot CLI**

---

## Installation

Run from your project root.

**Linux / macOS:**

```bash
curl -fsSL https://github.com/Uraxii/sdlc/releases/latest/download/install.sh | bash
```

**Windows:**

```powershell
irm https://github.com/Uraxii/sdlc/releases/latest/download/install.ps1 -OutFile install.ps1; .\install.ps1
```

The installer prompts you to pick your tool. Pass a flag to skip the prompt:

| Flag | Effect |
|------|--------|
| `--claude-code` | Install for Claude Code |
| `--copilot` | Install for GitHub Copilot CLI |

```bash
curl -fsSL https://github.com/Uraxii/sdlc/releases/latest/download/install.sh | bash -s -- --copilot
```

```powershell
irm https://github.com/Uraxii/sdlc/releases/latest/download/install.ps1 -OutFile install.ps1; .\install.ps1 --copilot
```

---

## Usage

```
/sdlc                    # Start a pipeline run — infers mode from task
/sdlc:full               # New feature (UX Designer runs if UI changes)
/sdlc:light              # Bug fix or small change (UX Designer runs if UI changes)
```

`/sdlc` infers the mode from the task description. Only prompts if the request is ambiguous.

---

## Pipeline Modes

| Mode | Pipeline |
|------|----------|
| `full` | Planner → Architect → [UX Designer]* → Skeptic → Developer → Skeptic ∥ SecAudit → Tester → Friction |
| `light` | [UX Designer]* → Developer → Skeptic ∥ SecAudit → Tester → Friction |

`*` UX Designer runs when task includes UI changes.
Skeptic + Security Auditor always run concurrently (∥) after implementation. Neither is bypassable.

---

## Roles

| Role | Responsibility |
|------|----------------|
| Planner | Scope, task breakdown, dependencies, priorities — picks pipeline mode |
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

## License

GPLv2 — see LICENSE.
