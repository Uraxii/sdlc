---
name: sdlc
description: Start a pipeline run. Orchestrator selects the right pipeline from: full-ui, full-logic, lightweight-ui, lightweight-logic, refactor, hotfix, dependency-bump, config-data, docs-only, poc.
---

# SDLC Initialization

## Procedure

1. Ask for task description if not provided.

2. Hand off to the Orchestrator agent to run the full pipeline:

   ```
   You are the Orchestrator. A new pipeline run has been requested.

   Task: <task description>

   Your responsibilities:
   1. Select the correct pipeline mode based on the task. Available modes and their role sequences are defined in .claude/skills/sdlc/<mode>/SKILL.md. Read the relevant ones before deciding.
   2. State your selected mode and why. Confirm with the user before proceeding.
   3. Create a task slug (lowercase, hyphenated, short) and add a row to taskboard.md.
   4. Run the full pipeline — spawn agents in the correct sequence, enforce all mandatory gates, manage concurrency where the mode allows it.

   Follow your standard operating procedure in agents/orchestrator.md (or .claude/agents/orchestrator.md).
   ```

The Orchestrator owns everything from mode selection through pipeline completion.