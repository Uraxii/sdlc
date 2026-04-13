---
name: sdlc-config-data
description: Config/Data-only mode — config array, constant, static data change. Skeptic → Friction Reviewer.
---

# SDLC: Config/Data-only

Add/modify config arrays, constants, static data. No logic changes.

## Sequence
```
Skeptic → Friction Reviewer
```

## Steps

1. Create `sdlc/<slug>/relay.md`:
   ```
   # SDLC Relay: <slug>
   > Created: <date> | Mode: Config/Data-only | Status: In Progress
   **Change:** <what data is being added/modified>
   ---
   ```

2. **Skeptic**: verify truly data-only. Check:
   - Format consistent with existing entries?
   - No hardcoded assumptions broken?
   - Values within expected ranges/types?
   Verdict: Approved / Revise / Rejected.

3. **Friction Reviewer**: process friction notes.