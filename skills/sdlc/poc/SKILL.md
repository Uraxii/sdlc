---
name: sdlc:poc
description: POC mode — build + test features fast and cheap. NOT shippable. Requires full pipeline before merge to main.
---

# SDLC: POC

Fast, cheap feature exploration. No prod constraints — no Architect, no Security Auditor, no Friction Reviewer.

**Hard constraint:** POC never ships. Needs `sdlc:full-ui` or `sdlc:full-logic` before merge to main.

## Sequence
```
Skeptic (concept) → Developer → Tester (smoke)
```

## Steps

1. Create `sdlc/<slug>/relay.md`:
   ```
   # SDLC Relay: <slug>
   > Created: <date> | Mode: POC | Status: In Progress
   > ⚠️ POC — NOT SHIPPABLE. Requires full pipeline before merge to main.
   **Goal:** <what are we proving/disproving>
   ---
   ```

2. **Skeptic (concept)**: quick concept check only — no code yet.
   - Goal clear?
   - Obvious fatal flaw (wrong layer, breaks invariant, already exists)?
   - Verdict: Proceed / Kill (with reason).

3. **Developer**: build fast. Shortcuts fine.
   - Hardcoded values OK
   - Skip error handling for non-critical paths
   - Skip version bump
   - Document assumptions + shortcuts in relay

4. **Tester** (smoke only):
   - Core scenario work? Yes/No.
   - Obvious regressions in adjacent paths?
   - List coverage gaps — input for full pipeline.
   - Conclude relay: `⚠️ POC complete — NOT SHIPPABLE. Promote via sdlc:full-[ui|logic] before shipping.`

> **To promote:** run `sdlc:full-ui` or `sdlc:full-logic`. Tester coverage gaps = starting test plan.