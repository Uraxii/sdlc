---
mode: 'agent'
description: 'Start a pipeline run — select mode, create relay, update taskboard. Use when the user says /sdlc, "start a pipeline", "new pipeline", etc.'
---

# SDLC Initialization

## Procedure

1. Ask for task description if not provided.

2. Select mode — two questions:
   - UI touched? (layout, components, tokens, visual behavior)
   - Change type?

   | Mode | When |
   |------|------|
   | `sdlc:full-ui` | New feature + UI |
   | `sdlc:full-logic` | New feature, no UI |
   | `sdlc:lightweight-ui` | Bug fix + UI |
   | `sdlc:lightweight-logic` | Bug fix, no UI |
   | `sdlc:refactor` | Behavior-preserving restructure |
   | `sdlc:hotfix` | Production incident |
   | `sdlc:dependency-bump` | Library version update only |
   | `sdlc:config-data` | Config array, constant, static data |
   | `sdlc:docs-only` | Docs or comments only |

   Confirm mode. Invoke sub-skill.

3. Create task slug — lowercase, hyphenated, short.

4. Add taskboard row to `taskboard.md`:
   ```
   | **[<slug>]** <description> | In Progress | <first role> | — | Relay: sdlc/<slug>/relay.md. <Mode>. |
   ```

5. Follow sub-skill for relay creation, planning, role sequence.
