---
name: sdlc
description: >
  Start a pipeline run. Select mode (full or light) based on task, then orchestrate
  the role sequence directly — visible tasks, visible agent spawns.
---

# SDLC Pipeline

## Procedure

1. If the task description is ambiguous or missing, ask for clarification. Otherwise proceed immediately.

2. Select mode based on task:
   - **full** — new feature, ambiguous scope, architectural decisions needed
   - **light** — bug fix, clear-scope change, no design phase needed

3. State: `**[Orchestrator]** Mode: sdlc:<mode> — <one sentence why>.`

4. Read the mode's skill for the role sequence:
   - full: `.claude/skills/sdlc-full/SKILL.md`
   - light: `.claude/skills/sdlc-light/SKILL.md`

5. Orchestrate the pipeline directly in this conversation:
   - Create a task for each role in the sequence (TaskCreate)
   - Spawn each role agent individually (Agent tool with the role's subagent_type)
   - Mark tasks complete as each role finishes (TaskUpdate)
   - For concurrent steps (Skeptic ∥ Security Auditor), spawn both agents in a single message
   - On gate rejection, loop back to the appropriate role
   - Pass relay context between roles via agent prompts

6. Every agent prompt must include:
   - Role identity and responsibilities
   - Task description with acceptance criteria
   - All upstream relay context (accumulated output from prior roles)
   - Specific files to read/modify
   - Scope boundaries (what NOT to do)

7. After pipeline completes, summarize results to the user.

Do NOT delegate to a single Orchestrator subagent. Run the pipeline here so the user sees progress.
