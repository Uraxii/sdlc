---
name: sdlc-dependency-bump
description: >
  Run the dependency-bump pipeline: library version update only.
  Sequence: Security Auditor → Tester.
  Check CVEs, license changes, breaking API changes.
---

# SDLC: Dependency Bump

Library version update only.

## Sequence
```
Security Auditor → Tester
```

## Steps

1. **Security Auditor**: check CVEs in new version, license changes, transitive dependency changes, breaking API changes.
2. **Tester**: run full test suite, verify no breakage.

Prefix each response `**[RoleName]**`.
