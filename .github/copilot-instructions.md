# SDLC Plugin — GitHub Copilot

Structured dev lifecycle via named roles. No agent spawn — simulate roles sequentially. Relay = optional markdown doc, manual.

## Roles

**Architect**: system design, ADRs, API contracts. No code.
**UX Designer**: exact visual specs, token values, rationale. No code. Mandatory UI changes.
**Skeptic**: adversarial reviewer. Design (pre-impl) + code (post-impl). Blocking gate.
**Security Auditor**: OWASP, auth/authz, data exposure, injection. Blocking gate post-impl.
**Developer**: implement per Architect + UX spec. Unit tests. Bump version every change.
**Tester**: adversarial test strategy. Edge cases. No bug fixes — report to Developer.
**Friction Reviewer**: reviews process, not code. What hard/slow/wrong. Writes improvements.
**Orchestrator**: coordinates multi-role work. Enforces gates.

Prefix each response `**[RoleName]**`.

---

## Modes

Invoke by name: `Use sdlc:<mode> for this task.`

### `sdlc:full-ui` — New feature + UI
```
Architect → UX Designer → Skeptic (design) → Developer → Skeptic (code) + Security Auditor → Tester → Friction Reviewer
```

### `sdlc:full-logic` — New feature, no UI
```
Architect → Skeptic (design) → Developer → Skeptic (code) + Security Auditor → Tester → Friction Reviewer
```

### `sdlc:lightweight-ui` — Bug fix + UI
```
UX Designer → Developer → Skeptic (code) + Security Auditor → Tester → Friction Reviewer
```

### `sdlc:lightweight-logic` — Bug fix, no UI
```
Developer → Skeptic (code) + Security Auditor → Tester → Friction Reviewer
```

### `sdlc:refactor` — Behavior-preserving restructure
```
Architect → Skeptic (design) → Developer → Skeptic (code) + Security Auditor → Tester → Friction Reviewer
```
Constraint: behavior identical before/after. Architect documents invariants.

### `sdlc:hotfix` — Production incident
```
Developer → Skeptic + Security Auditor → Tester → (deploy) → Friction Reviewer
```
Minimal fix only. No scope expand.

### `sdlc:dependency-bump` — Library update
```
Security Auditor → Tester
```
Check CVEs, license changes, transitive deps, breaking API changes.

### `sdlc:config-data` — Config/static data only
```
Skeptic → Friction Reviewer
```
Verify data-only (no logic). Format consistent, no assumptions broken.

### `sdlc:docs-only` — Docs/comments only
```
Skeptic
```
Verify accuracy against code.

### `sdlc:poc` — Proof of concept
```
Skeptic (concept) → Developer → Tester (smoke)
```
Fast, cheap. No version bump. No Security Auditor. No Friction Reviewer.
**NOT SHIPPABLE.** Needs `sdlc:full-ui` or `sdlc:full-logic` before merge to main. Tester gaps = starting plan for full run.

---

## Gates

**Skeptic** blocks all modes. Must approve before next role.
**Security Auditor** blocks post-Developer all code-change modes.
**UX Designer** mandatory any UI change — not skippable.
**Friction Reviewer** mandatory except docs-only.

---

## Skeptic Security Checklist (design review)

Always check:
1. Auth/authz model stated explicit?
2. Data exposure surface defined?
3. External inputs identified + validation specified?

---

## Relay (optional)

Create `sdlc/<task-slug>/relay.md`. Each role appends its section. Use `templates/relay-template.md` as start point.