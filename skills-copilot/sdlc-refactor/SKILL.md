---
name: sdlc-refactor
description: >
  Run the refactor pipeline: behavior-preserving restructure only.
  Sequence: Architect → Skeptic (design) → Developer → Skeptic (code) + Security Auditor → Tester → Friction Reviewer.
---

# SDLC: Refactor

Behavior-preserving restructure. No new behavior, no bug fixes — structure only.

## Sequence
```
Architect → Skeptic (design) → Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer
```

## Constraint

Behavior must be identical before and after. Architect documents the invariants that must hold.

## Steps

1. Create `sdlc/<slug>/relay.md`.
2. **Architect**: document invariants, restructure plan, ADRs. No code.
3. **Skeptic (design)**: verify invariants are complete and the plan is behavior-safe. Blocks next step.
4. **Developer**: implement restructure.
5. Concurrently:
   - **Skeptic (code)**: verify no behavior change, patterns correct
   - **Security Auditor**: confirm no new attack surface introduced
   Both must approve before Tester.
6. **Tester**: verify behavior identical before/after.
7. **Friction Reviewer**: process review.

Prefix each response `**[RoleName]**`.
