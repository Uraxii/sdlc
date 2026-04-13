---
name: sdlc-full-logic
description: Full-Logic mode — new feature, no UI. Architect → Skeptic → Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer.
---

# SDLC: Full-Logic

New feature, no UI changes.

## Sequence
```
Architect → Skeptic (design) → Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer
```

## Steps

1. Create `sdlc/<slug>/relay.md`:
   ```
   # SDLC Relay: <slug>
   > Created: <date> | Mode: Full-Logic | Status: In Progress
   ---
   ```

2. Append Planning section (scope, tasks+AC, sequencing, downstream notes).

3. **Architect**: system design, data flow, API contracts, ADRs. No code. → Skeptic.

4. **Skeptic (design)**: review Architect output.
   Security checklist: auth/authz stated? data exposure defined? external inputs identified?
   Verdict: Approved / Revise / Rejected.

5. **Developer**: implement per design. Bump version.

6. **Orchestrator** spawns concurrently:
   - **Skeptic (code)**: correctness, patterns, test quality
   - **Security Auditor**: OWASP, auth/authz, data exposure, injection
   Both approve before Tester.

7. **Tester**: test against AC. Fix stale tests.

8. **Friction Reviewer**: process review, write to memory.