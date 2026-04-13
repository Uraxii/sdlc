---
name: sdlc-lightweight
description: Lightweight mode — bug fix or clear-scope change. [UX Designer] → Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer. UX Designer runs when task includes UI changes.
---

# SDLC: Lightweight

Bug fix or clear-scope change. UI or logic changes.

## Sequence
```
[UX Designer]* → Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer
```
`*` UX Designer runs when task includes UI changes (layout, components, tokens, visual behavior).
No Architect. No Skeptic design review.
`[X ∥ Y]` = Orchestrator spawns concurrently; both blocking gates.

## Steps

1. Create `sdlc/<slug>/relay.md`:
   ```
   # SDLC Relay: <slug>
   > Created: <date> | Mode: Lightweight | Status: In Progress
   ---
   ```

2. Append Planning section.

3. *(If UI)* **UX Designer**: audit tokens, produce exact specs for fix. Verify no design drift. Document rationale.

4. **Developer**: implement fix (per UX spec if UI). No scope expansion. Bump version.

5. **Orchestrator** spawns concurrently:
   - **Skeptic (code)**: correctness, side effects, project patterns (+ token usage matches spec if UI ran)
   - **Security Auditor**: new attack surface or data exposure?
   Both approve before Tester.

6. **Tester**: verify fix + regression check (+ adjacent UI regression if UI ran). Fix stale tests.

7. **Friction Reviewer**: process review, write to memory.
