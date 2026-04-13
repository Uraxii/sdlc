---
name: sdlc-dependency-bump
description: Dependency Bump mode — library version update only. Security Auditor → Tester.
---

# SDLC: Dependency Bump

Lib version update. No logic changes.

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

2. **Security Auditor**: check each pkg — CVEs, license changes, transitive deps, breaking API. Flag: no release 12+ months, archived repo, abandoned maintainer. Prefer active alternatives.
   Verdict: Approved / Revise / Rejected.

3. **Tester**: full suite. Failure = bump regression. Fix stale tests from API changes only.

> No Friction Reviewer unless friction — run manually if needed.