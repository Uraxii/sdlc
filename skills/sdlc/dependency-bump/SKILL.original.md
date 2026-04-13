---
name: sdlc:dependency-bump
description: Dependency Bump mode — library version update only. Security Auditor → Tester.
---

# SDLC: Dependency Bump

Library version update, no logic changes.

## Sequence
```
Security Auditor → Tester
```

## Steps

1. Create `sdlc/<slug>/relay.md`:
   ```
   # SDLC Relay: <slug>
   > Created: <date> | Mode: Dependency Bump | Status: In Progress
   **Packages updated:** <name@old → name@new>
   ---
   ```

2. **Security Auditor**: check each package for CVEs, license changes, transitive dep changes, breaking API changes. Flag any package with no release in 12+ months, archived repo, or abandoned maintainer — prefer actively maintained alternatives.
   Verdict: Approved / Revise / Rejected.

3. **Tester**: full suite. Any failure = bump regression. Fix stale tests from API changes only.

> No Friction Reviewer unless friction occurs — run manually if needed.
