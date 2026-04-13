# Core Memory

All agents read on startup. Cross-cutting guidelines. Monitor maintains.

---

## Startup Protocol (all agents)

On spawn, order:
1. Read `core-memory.md` (this file)
2. Read `.claude/agents/memory/<your-name>.md`
3. Read `<project>/agent-memory.md` (project domain knowledge)
4. Check `taskboard.md` for assigned/pending work
5. `sdlc/<task-slug>/relay.md` exists → read upstream context; append your section when done

Agent defs assume this. Individual `## Startup` sections list extras only.

---

## Operating Modes

### Single-Agent Mode
- Skip `messages.md` I/O; announce role switches inline
- Adopt each role's mindset + constraints; thinking matters, ceremony doesn't
- Write memory at milestones only; update `taskboard.md` at session start/end
- Skeptic still adversarial. Roles still enforce boundaries.
- Infra work benefits disproportionately from full pipeline.

### Multi-Agent Mode (default)
- `messages.md` for inter-agent comms, `[PENDING]`/`[DONE]` tags
- `taskboard.md` tracks handoffs/assignments
- Full protocols including memory updates

---

## Guidelines

### Planning must not make architectural decisions
Tech choices, file structure, patterns → Architect. Planning saying "use X framework" or "single-file" overstepped.

### Joint submissions reduce circular dependencies
Architecture + planning intertwined → submit joint package to Skeptic. Each retains domain authority. Disagreements → user.

### Never skip the Skeptic
Catches real design gaps + scope omissions. Feels like overhead; prevents impl-stage issues.

### `messages.md` for inter-agent comms
Single unified log, `[PENDING]`/`[DONE]` tags. Standard channel.

### Explicit task tracking for all roles
Roles get bypassed without visible tracking. `taskboard.md` makes assignments explicit.

### Runtime verification mandatory
Code review misses runtime behavior. Developer verifies in running env. Tester blocks + escalates if no runtime.

### Architect researches tool capabilities first
Investigate what tool provides before designing custom solutions.

### Skeptic reviews test code too
Test code = same quality bar as production.

### Algorithmic changes still need self-review
UI tweaks can skip; logic changes (functions, not styling) cannot.

### Design docs update on every code change
Bug fixes + redesigns produce non-obvious decisions worth documenting.

### Tests run after every structural change
Structure changes → run suite → fix failures.

### Skeptic-only = minimum gate for fix-chains
New features: full pipeline. Fix-chains: Developer → Skeptic → Tester.

### Friction reports mandatory; plans optional for sub-feature work
Every impl session ends with friction report regardless of pipeline mode.

### User-reported metadata verified against source
Check actual source of truth (DB, config, data array). User-facing numbers may differ from internal repr.

### SDLC relay = structured handoff
`sdlc/<task-slug>/relay.md`. Each role reads → appends. Single-agent: append inline. Multi-agent: Orchestrator creates + passes path.

### Skeptic + Security Auditor run concurrently post-Developer
All modes with both: Orchestrator spawns parallel. Neither depends on other's output. Both blocking gates — Developer output must satisfy both before Tester proceeds.

### UX Designer mandatory for any UI change
Not optional. Pipeline mode determines when; when it runs: required gate, not suggestion.

### New routes reachable from nav
Added route → matching nav entry OR documented reason for nav-less.

### Data-only changes → Config/Data-only mode
Adding/modifying config array entry = Config/Data-only. Full pipeline only for genuine design ambiguity or new component layout.

### URL-accepting interfaces: spec security at design time
Must specify: (1) scheme allowlist, (2) hostname blocklist/allowlist w/ normalization, (3) exact comparison expression.