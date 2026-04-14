# SDLC Relay: {task-slug}

> Created: {date} | Mode: {full|light} | Status: {In Progress|Complete}

**Conventions:**
- Each role appends when done. Skip sections not in your mode.
- On revision: overwrite your section, no duplicates.
- Skeptic + Security Auditor run concurrent post-Developer. Each appends independent.

---

## Planning

**Scope:** {one-sentence description}

**Tasks:**
- {task 1 — acceptance criteria}

**Sequencing:** {dep order, parallelizable work}

**Downstream notes:** {what Architect/Developer needs}

---

## Architect

**Design decisions:**
- {decision — choice + why}

**File structure:**
- {path → purpose}

**API contracts:** {interfaces}

**Downstream notes:** {what Developer needs}

---

## Skeptic (design)

**Verdict:** {Approved | Revise | Rejected}

**Conditions:** {approval conditions}

**Objections:** {raised + resolved}

---

## UX Designer

**Specs:** {token-exact layout, component hierarchy, interaction states}

**Rationale:** {why this, not alternatives}

**Downstream notes:** {exact values Developer needs}

---

## Developer

**Files changed:**
- {path — what + why}

**Decisions:** {divergences from design + why}

**Known issues:** {what Tester should target}

---

## Skeptic (code review)

**Verdict:** {Approved | Changes requested}

**Issues found:**
- {blocking|suggestion|nit}: {description}

---

## Security Auditor

**Verdict:** {Approved | Changes requested}

**Issues found:**
- {blocking|suggestion|nit}: {description}

---

## Tester

**Test results:** {X/X passed}

**Failures:** {description, repro steps}

**Coverage gaps:** {untested areas}

---

## Friction Report

**Friction points:** {what hard/slow/wrong}

**Token efficiency:**
- {role — cost — waste type — suggested saving}

**Memory updates:**
- {role memory: what written where}