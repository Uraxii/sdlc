---
name: sdlc
description: Start a pipeline run. Orchestrator selects the right pipeline from: full-ui, full-logic, lightweight-ui, lightweight-logic, refactor, hotfix, dependency-bump, config-data, docs-only, poc.
---

# SDLC Initialization

## Procedure

1. Ask for task description if not provided.

2. Invoke the Orchestrator agent to select the pipeline mode.

   Prompt:
   ```
   You are the Orchestrator. Given this task, select the correct pipeline mode.

   Task: <task description>

   Modes:
   - full-ui            New feature + UI changes
   - full-logic         New feature, no UI
   - lightweight-ui     Bug fix or small change + UI
   - lightweight-logic  Bug fix or small change, no UI
   - refactor           Behavior-preserving restructure only
   - hotfix             Production incident — time-critical
   - dependency-bump    Library version update only
   - config-data        Config, constant, or static data change only
   - docs-only          Docs or comments only
   - poc                Fast proof-of-concept — NOT shippable

   Respond with:
   - Selected mode and one sentence explaining why
   - Any assumptions made
   ```

   Present the Orchestrator's selection to the user and confirm before proceeding. If the user disagrees, re-run with their correction.

3. Create task slug — lowercase, hyphenated, short.

4. Add taskboard row to `taskboard.md`:
   ```
   | **[<slug>]** <description> | In Progress | <first role> | — | Relay: sdlc/<slug>/relay.md. <Mode>. |
   ```

5. Invoke the matching sub-skill and follow its relay creation and role sequence.