---
name: sdlc-full
description: Full mode — new feature. Architect → [UX Designer] → Skeptic → Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer. UX Designer runs when task includes UI changes.
---

# SDLC: Full

New feature. UI or logic changes.

## Sequence
```
Architect → [UX Designer]* → Skeptic (design) → Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer
```
`*` UX Designer runs when task includes UI changes (layout, components, tokens, visual behavior).
`[X ∥ Y]` = Orchestrator spawns concurrently; both blocking gates.

## Steps

1. Create `sdlc/<slug>/relay.md`:
   ```
   # SDLC Relay: <slug>
   > Created: <date> | Mode: Full | Status: In Progress
   ---
   ```

2. Append Planning section (scope, tasks+AC, sequencing, downstream notes).

3. **Architect**: system design, component boundaries, data flow, API contracts, ADRs. No code. → next step.

4. *(If UI)* **UX Designer**: read Architect relay. Token-exact specs, layout, interaction states, rationale. → Skeptic.

5. **Skeptic (design)**: review Architect output (and UX spec if present) jointly.
   Security checklist: auth/authz stated? data exposure defined? external inputs identified?
   Verdict: Approved / Revise / Rejected.

6. **Developer**: implement per design (and UX spec if UI). No deviation w/o change request. Bump version.

7. **Orchestrator** spawns concurrently:
   - **Skeptic (code)**: correctness, patterns, test quality (+ UX spec vs impl if UI ran)
   - **Security Auditor**: OWASP, auth/authz, data exposure, injection
   Both approve before Tester.

8. **Tester**: test against AC. Visual regression if UX ran. Fix stale tests.

9. **Friction Reviewer**: process review, write to memory.
