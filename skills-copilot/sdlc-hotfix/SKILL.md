---
name: sdlc-hotfix
description: >
  Run the hotfix pipeline: production incident, time-critical.
  Sequence: Developer → Skeptic (code) + Security Auditor → Tester → Friction Reviewer.
  Minimal fix only — no scope expansion.
---

# SDLC: Hotfix

Production incident. Time-critical. Minimal fix only — no scope expand.

## Sequence
```
Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer
```

## Steps

1. **Developer**: smallest possible fix for the incident. No refactoring, no opportunistic improvements.
2. Concurrently:
   - **Skeptic (code)**: correctness, no regressions, scope check
   - **Security Auditor**: no new vulnerabilities introduced
   Both must approve before Tester.
3. **Tester**: targeted tests for the fix and likely regressions.
4. **Friction Reviewer**: post-incident process review.

Prefix each response `**[RoleName]**`.
