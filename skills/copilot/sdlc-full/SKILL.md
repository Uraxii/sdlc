---
name: sdlc-full
description: >
  Run the full pipeline: new feature. UX Designer runs when task includes UI changes.
  Sequence: Architect → [UX Designer] → Skeptic (design) → Developer → Skeptic (code) + Security Auditor → Tester → Friction Reviewer.
---

# SDLC: Full

New feature. UX Designer step runs when task includes UI changes (layout, components, tokens, visual behavior).

## Sequence
```
Architect → [UX Designer]* → Skeptic (design) → Developer → [Skeptic ∥ Security Auditor] → Tester → Friction Reviewer
```
`*` UX Designer is mandatory when task touches UI.

## Steps

1. Create `sdlc/<slug>/relay.md`.
2. **Architect**: system design, data flow, API contracts, ADRs. No code.
3. *(If UI)* **UX Designer**: exact visual specs, token values, component behavior, rationale. No code. Mandatory — not skippable.
4. **Skeptic (design)**: review Architect output (and UX spec if present). Security checklist: auth/authz stated? data exposure defined? external inputs identified? Verdict: Approved / Revise / Rejected. Blocks next step.
5. **Developer**: implement per design (and UX spec if UI).
6. Concurrently:
   - **Skeptic (code)**: correctness, patterns, test quality (+ UX spec vs impl if UI ran)
   - **Security Auditor**: OWASP, auth/authz, data exposure, injection
   Both must approve before Tester.
7. **Tester**: test against acceptance criteria. Visual regression if UX ran.
8. **Friction Reviewer**: process review.

Prefix each response `**[RoleName]**`.
