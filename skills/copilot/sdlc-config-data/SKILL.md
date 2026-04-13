---
name: sdlc-config-data
description: >
  Run the config-data pipeline: config, constant, or static data change only.
  Sequence: Skeptic → Friction Reviewer.
---

# SDLC: Config-Data

Config array, constant, or static data change only. No logic changes.

## Sequence
```
Skeptic → Friction Reviewer
```

## Steps

1. **Skeptic**: verify the change is data-only (no logic), format is consistent, no assumptions broken by the new values.
2. **Friction Reviewer**: process review.

Prefix each response `**[RoleName]**`.
