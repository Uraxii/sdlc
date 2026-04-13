---
name: sdlc-lightweight-ui
description: >
  Run the lightweight-ui pipeline: bug fix or small change with UI changes.
  Sequence: UX Designer → Developer → Skeptic (code) + Security Auditor → Tester → Friction Reviewer.
---

# SDLC: Lightweight-UI

Bug fix or small change with UI changes.

## Sequence
```
UX Designer → Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer
```

## Steps

1. **UX Designer**: exact visual specs for the fix. Mandatory — not skippable.
2. **Developer**: implement per UX spec.
3. Concurrently:
   - **Skeptic (code)**: correctness, patterns, test quality
   - **Security Auditor**: OWASP, auth/authz, data exposure, injection
   Both must approve before Tester.
4. **Tester**: test against acceptance criteria.
5. **Friction Reviewer**: process review.

Prefix each response `**[RoleName]**`.
