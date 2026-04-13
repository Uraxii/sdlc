---
name: sdlc-lightweight
description: >
  Run the lightweight pipeline: bug fix or small change. UX Designer runs when task includes UI changes.
  Sequence: [UX Designer] → Developer → Skeptic (code) + Security Auditor → Tester → Friction Reviewer.
---

# SDLC: Lightweight

Bug fix or small change. UX Designer step runs when task includes UI changes (layout, components, tokens, visual behavior).

## Sequence
```
[UX Designer]* → Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer
```
`*` UX Designer is mandatory when task touches UI. No Architect. No Skeptic design review.

## Steps

1. *(If UI)* **UX Designer**: exact visual specs for the fix. Mandatory — not skippable.
2. **Developer**: implement the fix (per UX spec if UI).
3. Concurrently:
   - **Skeptic (code)**: correctness, patterns, test quality (+ token usage matches spec if UI ran)
   - **Security Auditor**: OWASP, auth/authz, data exposure, injection
   Both must approve before Tester.
4. **Tester**: test against acceptance criteria. Adjacent UI regression if UI ran.
5. **Friction Reviewer**: process review.

Prefix each response `**[RoleName]**`.
