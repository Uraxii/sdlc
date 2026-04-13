---
name: sdlc:poc
description: POC mode — build + test features fast and cheap. NOT shippable. Requires full pipeline before merge to main.
---

# SDLC: POC

Fast, cheap feature exploration. No production constraints — no Architect, no Security Auditor, no Friction Reviewer.

**Hard constraint:** POC output NEVER ships. Requires `sdlc:full-ui` or `sdlc:full-logic` before merge to main.

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

2. **Skeptic (concept)**: quick concept check only — no code exists yet.
   - Is the goal clear?
   - Any obvious fatal flaw (wrong layer, breaks invariant, already exists)?
   - Verdict: Proceed / Kill (with reason).

3. **Developer**: build fast. Shortcuts are fine.
   - Hardcoded values OK
   - Skip error handling for non-critical paths
   - Skip version bump
   - Document assumptions + shortcuts in relay

4. **Tester** (smoke only):
   - Does the core scenario work? Yes/No.
   - Any obvious regressions in adjacent paths?
   - List all coverage gaps — becomes input for full pipeline run.
   - Conclude relay with: `⚠️ POC complete — NOT SHIPPABLE. Promote via sdlc:full-[ui|logic] before shipping.`

> **To promote:** run `sdlc:full-ui` or `sdlc:full-logic`. Tester coverage gaps = starting test plan.
