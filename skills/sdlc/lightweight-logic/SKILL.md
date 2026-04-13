---
name: sdlc:lightweight-logic
description: Lightweight-Logic mode — bug fix, no UI. Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer.
---

# SDLC: Lightweight-Logic

Bug fix or clear-scope change, no UI.

## Sequence
```
Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer
```

## Steps

1. Create `sdlc/<slug>/relay.md`:
   ```
   # SDLC Relay: <slug>
   > Created: <date> | Mode: Lightweight-Logic | Status: In Progress
   ---
   ```

2. Append Planning section.

3. **Developer**: implement fix. No scope expansion. Bump version.

4. **Orchestrator** spawns concurrently:
   - **Skeptic (code)**: correctness, side effects, project patterns
   - **Security Auditor**: new attack surface?
   Both approve before Tester.

5. **Tester**: verify fix + regression check. Fix stale tests.

6. **Friction Reviewer**: process review, write to memory.