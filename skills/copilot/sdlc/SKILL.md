---
name: sdlc
description: >
  Start a structured development pipeline run. Use when the user says /sdlc,
  "start a pipeline", "new pipeline", or describes a feature, bug fix,
  or other code change and wants a disciplined workflow.
---

# SDLC Pipeline

Structured multi-role pipeline for AI-assisted development. Replaces ad-hoc sessions with disciplined workflows: role-based agents, 4 pipeline modes, parallel review gates.

## Starting a pipeline

1. If the task description is ambiguous or missing, ask for clarification. Otherwise infer mode from context and proceed.
2. State: `**[Orchestrator]** Mode: sdlc:<mode> — <one sentence why>.` then proceed.

| Mode | When |
|------|------|
| `full` | New feature (UX Designer runs if UI changes) |
| `light` | Bug fix or small change (UX Designer runs if UI changes) |

To invoke a mode directly: `Use sdlc:<mode> for this task.`

---

## Roles

**Planner**: scope, task breakdown, dependencies, priorities. Picks pipeline mode. No technical decisions.
**Architect**: system design, ADRs, API contracts. No code.
**UX Designer**: exact visual specs, token values, rationale. No code. Mandatory on UI changes.
**Skeptic**: adversarial reviewer. Design (pre-impl) + code (post-impl). Blocking gate.
**Security Auditor**: OWASP, auth/authz, data exposure, injection. Blocking gate post-impl.
**Developer**: implement per Architect + UX spec. Unit tests. Bump version every change.
**Tester**: adversarial test strategy. Edge cases. No bug fixes — report to Developer.
**Friction Reviewer**: reviews process, not code. What was hard/slow/wrong.

Prefix each response `**[RoleName]**`.

---

## Pipeline sequences

### `full`
```
Planner → Architect → [UX Designer]* → Skeptic (design) → Developer → Skeptic (code) + Security Auditor → Tester → Friction Reviewer
```
`*` UX Designer mandatory when task touches UI.

### `light`
```
[UX Designer]* → Developer → Skeptic (code) + Security Auditor → Tester → Friction Reviewer
```
`*` UX Designer mandatory when task touches UI. No Planner. No Architect. No Skeptic design review.

---

## Gates

**Skeptic** blocks all modes. Must approve before next role.
**Security Auditor** blocks post-Developer in all code-change modes.
**UX Designer** mandatory any UI change — not skippable.
**Friction Reviewer** mandatory in all modes.

---

## Skeptic security checklist (design review)

1. Auth/authz model stated explicit?
2. Data exposure surface defined?
3. External inputs identified + validation specified?
