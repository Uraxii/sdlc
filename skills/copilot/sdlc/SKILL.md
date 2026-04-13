---
name: sdlc
description: >
  Start a structured development pipeline run. Use when the user says /sdlc,
  "start a pipeline", "new pipeline", or describes a feature, bug fix, refactor,
  hotfix, or other code change and wants a disciplined workflow.
---

# SDLC Pipeline

Structured multi-role pipeline for AI-assisted development. Replaces ad-hoc sessions with disciplined workflows: role-based agents, 8 pipeline modes, parallel review gates.

## Starting a pipeline

1. Ask for task description if not provided.
2. Select mode — two questions:
   - New feature or fix/refactor?
   - Does this touch UI? (layout, components, visual behavior) — UX Designer runs if yes.

3. State: `**[Orchestrator]** Mode: sdlc:<mode> — <one sentence why>.` then proceed.

| Mode | When |
|------|------|
| `full` | New feature (UX Designer runs if UI changes) |
| `lightweight` | Bug fix or small change (UX Designer runs if UI changes) |
| `refactor` | Behavior-preserving restructure only |
| `hotfix` | Production incident — time-critical |
| `dependency-bump` | Library version update only |
| `config-data` | Config, constant, or static data change only |
| `docs-only` | Docs or comments only |
| `poc` | Fast proof-of-concept — NOT shippable |

To invoke a mode directly: `Use sdlc:<mode> for this task.`

---

## Roles

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
Architect → [UX Designer]* → Skeptic (design) → Developer → Skeptic (code) + Security Auditor → Tester → Friction Reviewer
```
`*` UX Designer mandatory when task touches UI.

### `lightweight`
```
[UX Designer]* → Developer → Skeptic (code) + Security Auditor → Tester → Friction Reviewer
```
`*` UX Designer mandatory when task touches UI. No Architect. No Skeptic design review.

### `refactor`
```
Architect → Skeptic (design) → Developer → Skeptic (code) + Security Auditor → Tester → Friction Reviewer
```
Constraint: behavior identical before/after.

### `hotfix`
```
Developer → Skeptic + Security Auditor → Tester → Friction Reviewer
```
Minimal fix only. No scope expand.

### `dependency-bump`
```
Security Auditor → Tester
```

### `config-data`
```
Skeptic → Friction Reviewer
```

### `docs-only`
```
Skeptic
```

### `poc`
```
Skeptic (concept) → Developer → Tester (smoke)
```
**NOT SHIPPABLE.** Needs `full` before merge to main.

---

## Gates

**Skeptic** blocks all modes. Must approve before next role.
**Security Auditor** blocks post-Developer in all code-change modes.
**UX Designer** mandatory any UI change — not skippable.
**Friction Reviewer** mandatory except docs-only.

---

## Skeptic security checklist (design review)

1. Auth/authz model stated explicit?
2. Data exposure surface defined?
3. External inputs identified + validation specified?
