---
name: sdlc:lightweight-ui
description: Lightweight-UI mode — bug fix with UI. UX Designer → Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer.
---

# SDLC: Lightweight-UI

Bug fix or clear-scope change touching UI.

## Sequence
```
UX Designer → Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer
```
No Architect. No Skeptic design review.

## Steps

1. Create `sdlc/<slug>/relay.md`:
   ```
   # SDLC Relay: <slug>
   > Created: <date> | Mode: Lightweight-UI | Status: In Progress
   ---
   ```

2. Append Planning section.

3. **UX Designer**: audit tokens, produce exact specs for fix. Verify no design drift. Document rationale.

4. **Developer**: implement per spec. Bump version.

5. **Orchestrator** spawns concurrently:
   - **Skeptic (code)**: correctness, token usage matches spec, no drift
   - **Security Auditor**: new input surface or data exposure?
   Both approve before Tester.

6. **Tester**: verify fix + adjacent UI regression. Fix stale tests.

7. **Friction Reviewer**: process review, write to memory.