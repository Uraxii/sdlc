---
name: sdlc-light
description: Light mode — bug fix or clear-scope change. [UX Designer] → Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer. UX Designer runs when task includes UI changes.
---
Respond in caveman — terse, no filler, fragments OK.

# SDLC: Light

Bug fix or clear-scope change. UI or logic changes.

## Sequence
```
[UX Designer]* → Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer
```
`*` UX Designer runs when task includes UI changes (layout, components, tokens, visual behavior).
No Planner. No Architect. No Skeptic design review.
`[X ∥ Y]` = spawn concurrently in a single message; both are blocking gates.

## Steps

Create a task for each step. Spawn each role agent. Mark tasks done as they complete.

1. *(If UI)* **UX Designer** (subagent_type: ux-designer): audit tokens, produce exact specs for fix. Verify no design drift.

2. **Developer** (subagent_type: developer): implement fix (per UX spec if UI). No scope expansion. Bump version.

3. **Skeptic + Security Auditor** (spawn both in one message, concurrently):
   - Skeptic (subagent_type: skeptic): correctness, side effects, project patterns
   - Security Auditor (subagent_type: security-auditor): new attack surface or data exposure?
   Both must approve before proceeding. On reject → loop to Developer.

4. **Tester** (subagent_type: tester): verify fix + regression check. Fix stale tests.

5. **Friction Reviewer** (subagent_type: friction-reviewer): process review, write to memory.
