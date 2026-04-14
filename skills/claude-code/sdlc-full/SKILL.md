---
name: sdlc-full
description: Full mode — new feature. Planner → Architect → [UX Designer] → Skeptic → Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer. UX Designer runs when task includes UI changes.
---

# SDLC: Full

New feature. UI or logic changes.

## Sequence
```
Planner → Architect → [UX Designer]* → Skeptic (design) → Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer
```
`*` UX Designer runs when task includes UI changes (layout, components, tokens, visual behavior).
`[X ∥ Y]` = spawn concurrently in a single message; both are blocking gates.

## Steps

Create a task for each step. Spawn each role agent. Mark tasks done as they complete.

1. **Planner** (subagent_type: planner): scope, task breakdown, dependencies, sequencing. Decides if UX Designer needed. No technical decisions.

2. **Architect** (subagent_type: architect): system design, component boundaries, data flow, API contracts, ADRs. No code. Read Planner output for scope + tasks.

3. *(If UI)* **UX Designer** (subagent_type: ux-designer): read Architect output. Token-exact specs, layout, interaction states, rationale.

4. **Skeptic** (subagent_type: skeptic): review Architect output (and UX spec if present).
   Security checklist: auth/authz stated? data exposure defined? external inputs identified?
   Verdict: Approved / Revise / Rejected. On reject → loop to Architect.

5. **Developer** (subagent_type: developer): implement per design (and UX spec if UI). Bump version.

6. **Skeptic + Security Auditor** (spawn both in one message, concurrently):
   - Skeptic (subagent_type: skeptic): correctness, patterns, test quality
   - Security Auditor (subagent_type: security-auditor): OWASP, auth/authz, data exposure, injection
   Both must approve before proceeding. On reject → loop to Developer.

7. **Tester** (subagent_type: tester): test against AC. Visual regression if UX ran. Fix stale tests.

8. **Friction Reviewer** (subagent_type: friction-reviewer): process review, write to memory.
