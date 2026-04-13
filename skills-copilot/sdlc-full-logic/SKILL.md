---
name: sdlc-full-logic
description: >
  Run the full-logic pipeline: new feature with no UI changes.
  Sequence: Architect → Skeptic (design) → Developer → Skeptic (code) + Security Auditor → Tester → Friction Reviewer.
---

# SDLC: Full-Logic

New feature, no UI changes.

## Sequence
```
Architect → Skeptic (design) → Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer
```

## Steps

1. Create `sdlc/<slug>/relay.md`.
2. **Architect**: system design, data flow, API contracts, ADRs. No code.
3. **Skeptic (design)**: adversarial review. Security checklist: auth/authz stated? data exposure defined? external inputs identified? Verdict: Approved / Revise / Rejected. Blocks next step.
4. **Developer**: implement per design.
5. Concurrently:
   - **Skeptic (code)**: correctness, patterns, test quality
   - **Security Auditor**: OWASP, auth/authz, data exposure, injection
   Both must approve before Tester.
6. **Tester**: test against acceptance criteria.
7. **Friction Reviewer**: process review.

Prefix each response `**[RoleName]**`.
