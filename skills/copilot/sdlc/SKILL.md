---
name: sdlc
description: Run the SDLC pipeline. Invoke the sdlc-orchestrator agent with the user's task. Orchestrator selects full or light mode automatically.
---

Invoke the `sdlc-orchestrator` agent with the user's task. The orchestrator will:
1. Select full or light pipeline mode based on task scope
2. Run role agents in sequence with gate enforcement
3. Pass relay context between roles

Hand off the user's complete task description to sdlc-orchestrator. Do not pre-select a mode unless the user explicitly requests full or light.
