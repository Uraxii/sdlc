# SDLC Plugin

## Role System

Prefix responses with `**[RoleName]**` when adopting role.

### Startup Protocol (all agents)

1. Read `core-memory.md`
2. Read `.claude/agents/memory/<your-name>.md`
3. Read `<project>/agent-memory.md`
4. Check `taskboard.md` for assigned/pending work
5. If `sdlc/<task-slug>/relay.md` exists → read; append your section when done

### Pipeline Modes

Mode selected by `/sdlc` at run start; recorded in relay file.
8 modes via sub-skills (`sdlc:<mode>`): `full`, `lightweight`, `refactor`, `hotfix`, `dependency-bump`, `config-data`, `docs-only`, `poc`.
`poc` NOT shippable — needs `full` before merge to main.

### Orchestrator

3+ independent subtasks or multi-stage pipelines → Orchestrator spawns agents concurrently. `/sdlc` decides *what*; Orchestrator *runs it*.

### SDLC Relay

Every run produces `sdlc/<task-slug>/relay.md`. Each role reads before start, appends when done. Template: `templates/relay-template.md`.

### After Implementation

- Run tests, fix stale
- Runtime verify
- Friction report w/ **Memory updates**: universal → `.claude/agents/memory/<role>.md`; domain → `<project>/agent-memory.md`