---
name: sdlc-full
description: Full mode — new feature. Planner -> Architect -> [UX Designer] -> Skeptic -> Developer -> [Skeptic + Security Auditor] -> Tester -> Friction Reviewer. UX Designer runs when task includes UI changes.
---

# SDLC: Full

New feature. UI or logic changes.

## Sequence
```
Planner -> Architect -> [UX Designer]* -> Skeptic (design) -> Developer -> [Skeptic + Security Auditor] -> Tester -> Friction Reviewer
```
`*` UX Designer runs when task includes UI changes (layout, components, tokens, visual behavior).

## Steps

Invoke the `sdlc-orchestrator` agent with the user's task and instruct it to use **full** mode.

1. **Planner**: scope, task breakdown, dependencies, sequencing. Decides if UX Designer needed.
2. **Architect**: system design, component boundaries, data flow, API contracts. Reads Planner output.
3. *(If UI)* **UX Designer**: token-exact specs, layout, interaction states.
4. **Skeptic** (design review): Verdict: Approved / Revise / Rejected. On reject -> loop to Architect.
5. **Developer**: implement per approved design (+ UX spec if UI). Bump version.
6. **Skeptic** (code) + **Security Auditor**: both must approve. On reject -> loop to Developer.
7. **Tester**: test against acceptance criteria. Visual regression if UX ran.
8. **Friction Reviewer**: process review, write to memory.
