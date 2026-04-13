---
name: sdlc:hotfix
description: Hotfix mode — production incident, time-critical. Developer → [Skeptic ∥ Security Auditor] → Tester → deploy → Friction Reviewer async.
---

# SDLC: Hotfix

Production incident. Fast turnaround. No planning, no Architect.

## Sequence
```
Developer → [Skeptic ∥ Security Auditor] → Tester → (deploy) → Friction Reviewer (async)
```

## Steps

1. Create `sdlc/<slug>/relay.md`:
   ```
   # SDLC Relay: <slug>
   > Created: <date> | Mode: Hotfix | Status: In Progress
   **Incident:** <what is broken in production>
   ---
   ```

2. **Developer**: minimal fix — smallest change resolves incident. No scope expansion. Bump version.

3. **Orchestrator** spawns concurrently:
   - **Skeptic**: correctness, no side effects, fix sufficient
   - **Security Auditor**: fix introduces no new vuln
   Both approve before Tester.

4. **Tester**: verify fix resolves incident. Smoke adjacent paths. Note coverage gaps in relay.

5. Deploy.

6. **Friction Reviewer** (async, post-deploy): full process review. Note test gaps as follow-up.