---
name: sdlc-poc
description: >
  Run the poc pipeline: fast proof-of-concept. NOT shippable — requires full pipeline before merge to main.
  Sequence: Skeptic (concept) → Developer → Tester (smoke).
---

# SDLC: PoC

Fast proof-of-concept. **NOT SHIPPABLE.**

Requires `sdlc-full` before merge to main. Tester gaps become the starting plan for the full run.

## Sequence
```
Skeptic (concept) → Developer → Tester (smoke)
```

## Constraints

- No version bump
- No Security Auditor
- No Friction Reviewer
- Tester runs smoke only — documents gaps, does not block

## Steps

1. **Skeptic (concept)**: is the concept worth pursuing? Any fatal flaws? Approves or rejects before any code.
2. **Developer**: fast implementation. Cut corners deliberately — this is exploratory.
3. **Tester (smoke)**: basic smoke tests only. Document what's untested — this list feeds the full pipeline run.

Prefix each response `**[RoleName]**`.
