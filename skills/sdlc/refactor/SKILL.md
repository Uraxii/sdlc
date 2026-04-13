---
name: sdlc-refactor
description: Refactor mode — behavior-preserving restructure. Architect → Skeptic → Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer.
---

# SDLC: Refactor

Behavior-preserving restructure — no new features, no bug fixes, no UI changes.

## Sequence
```
Architect → Skeptic (design) → Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer
```

## Steps

1. Create `sdlc/<slug>/relay.md`:
   ```
   # SDLC Relay: <slug>
   > Created: <date> | Mode: Refactor | Status: In Progress
   ---
   ```

2. Append Planning section. Document invariants: must hold before/after.

3. **Architect**: target structure, file boundaries, extraction strategy. Constraint: behavior identical before/after.

4. **Skeptic (design)**: verify scope truly behavior-preserving. Flag feature creep.
   Verdict: Approved / Revise / Rejected.

5. **Developer**: restructure per plan. No logic changes. Bump version.

6. **Orchestrator** spawns concurrent:
   - **Skeptic (code)**: behavior preserved, no accidental logic changes, circular dep check
   - **Security Auditor**: new attack surface from restructure?
   Both approve before Tester.

7. **Tester**: full suite. Any failure = regression. Fix stale tests from restructure only.

8. **Friction Reviewer**: process review, write to memory.