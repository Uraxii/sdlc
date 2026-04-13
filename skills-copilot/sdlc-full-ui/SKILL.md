---
name: sdlc-full-ui
description: >
  Run the full-ui pipeline: new feature with UI changes.
  Sequence: Architect → UX Designer → Skeptic (design) → Developer → Skeptic (code) + Security Auditor → Tester → Friction Reviewer.
---

# SDLC: Full-UI

New feature with UI changes (layout, components, tokens, visual behavior).

## Sequence
```
Architect → UX Designer → Skeptic (design) → Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer
```

## Steps

1. Create `sdlc/<slug>/relay.md`.
2. **Architect**: system design, data flow, API contracts, ADRs. No code.
3. **UX Designer**: exact visual specs, token values, component behavior, rationale. No code. Mandatory — not skippable.
4. **Skeptic (design)**: review Architect + UX output. Security checklist. Verdict: Approved / Revise / Rejected. Blocks next step.
5. **Developer**: implement per Architect + UX spec.
6. Concurrently:
   - **Skeptic (code)**: correctness, patterns, test quality
   - **Security Auditor**: OWASP, auth/authz, data exposure, injection
   Both must approve before Tester.
7. **Tester**: test against acceptance criteria.
8. **Friction Reviewer**: process review.

Prefix each response `**[RoleName]**`.
