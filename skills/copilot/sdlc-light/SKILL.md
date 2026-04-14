---
name: sdlc-light
description: Light mode — bug fix or clear-scope change. [UX Designer] -> Developer -> [Skeptic + Security Auditor] -> Tester -> Friction Reviewer. UX Designer runs when task includes UI changes.
---

# SDLC: Light

Bug fix or clear-scope change.

## Sequence
```
[UX Designer]* -> Developer -> [Skeptic + Security Auditor] -> Tester -> Friction Reviewer
```
`*` UX Designer runs when task includes UI changes.
No Planner. No Architect. No Skeptic design review.

## Steps

Invoke the `sdlc-orchestrator` agent with the user's task and instruct it to use **light** mode.

1. *(If UI)* **UX Designer**: audit tokens, produce specs for fix.
2. **Developer**: implement fix (per UX spec if UI). No scope expansion. Bump version.
3. **Skeptic** (code) + **Security Auditor**: both must approve. On reject -> loop to Developer.
4. **Tester**: verify fix + regression check.
5. **Friction Reviewer**: process review, write to memory.
