---
name: sdlc-lightweight-logic
description: >
  Run the lightweight-logic pipeline: bug fix or small change, no UI.
  Sequence: Developer → Skeptic (code) + Security Auditor → Tester → Friction Reviewer.
---

# SDLC: Lightweight-Logic

Bug fix or small change, no UI.

## Sequence
```
Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer
```

## Steps

1. **Developer**: implement the fix.
2. Concurrently:
   - **Skeptic (code)**: correctness, patterns, test quality
   - **Security Auditor**: OWASP, auth/authz, data exposure, injection
   Both must approve before Tester.
3. **Tester**: test against acceptance criteria.
4. **Friction Reviewer**: process review.

Prefix each response `**[RoleName]**`.
