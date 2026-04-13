---
name: sdlc:full-ui
description: Full-UI mode — new feature with UI. Architect → UX Designer → Skeptic → Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer.
---

# SDLC: Full-UI

New feature with UI changes (layout, components, tokens, visual behavior).

## Sequence
```
Architect → UX Designer → Skeptic (design) → Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer
```
`[X ∥ Y]` = Orchestrator spawns concurrently; both blocking gates.

## Steps

1. Create `sdlc/<slug>/relay.md`:
   ```
   # SDLC Relay: <slug>
   > Created: <date> | Mode: Full-UI | Status: In Progress
   ---
   ```

2. Append Planning section (scope, tasks+AC, sequencing, downstream notes).

3. **Architect**: system design, component boundaries, ADRs. No code. → Skeptic.

4. **UX Designer**: read Architect relay. Token-exact specs, layout, interaction states, rationale. → Skeptic.

5. **Skeptic (design)**: review Architect + UX jointly.
   Security checklist: auth/authz stated? data exposure defined? external inputs identified?
   Verdict: Approved / Revise / Rejected.

6. **Developer**: implement per design + UX spec. No deviation w/o change request. Bump version.

7. **Orchestrator** spawns concurrently:
   - **Skeptic (code)**: correctness, patterns, test quality, UX spec vs impl
   - **Security Auditor**: OWASP, auth/authz, data exposure, injection
   Both approve required before Tester.

8. **Tester**: test against AC. Visual regression if UX ran. Fix stale tests.

9. **Friction Reviewer**: process review, write to memory.