---
name: sdlc
description: Start a pipeline run. Shows available pipeline modes — full-ui, full-logic, lightweight-ui, lightweight-logic, refactor, hotfix, dependency-bump, config-data, docs-only, poc.
---

# SDLC Initialization

## Procedure

1. Present the pipeline menu:

   ```
   Select a pipeline:

     1. full-ui            New feature + UI
     2. full-logic         New feature, no UI
     3. lightweight-ui     Bug fix + UI
     4. lightweight-logic  Bug fix, no UI
     5. refactor           Behavior-preserving restructure
     6. hotfix             Production incident
     7. dependency-bump    Library version update only
     8. config-data        Config, constant, or static data change
     9. docs-only          Docs or comments only
    10. poc                Fast proof-of-concept — NOT shippable
   ```

   If the user already provided a mode (e.g. `/sdlc:hotfix`), skip this step.

2. Ask for task description if not provided.

3. Create task slug — lowercase, hyphenated, short.

4. Add taskboard row to `taskboard.md`:
   ```
   | **[<slug>]** <description> | In Progress | <first role> | — | Relay: sdlc/<slug>/relay.md. <Mode>. |
   ```

5. Invoke the matching sub-skill and follow its relay creation and role sequence.