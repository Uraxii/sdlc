# Orchestrator Memory

## Skeptic Revise verdict: loop back, do not patch inline

When Skeptic issues a Revise verdict with blocking issues, the correct flow is:
1. Return to the role that produced the flawed output (Architect, Planner, etc.)
2. That role corrects its section
3. Skeptic re-reviews the corrected section

Patching Developer notes inline and self-approving on the Skeptic's behalf bypasses the gate.
The Skeptic's value is independent review of the corrected work, not acknowledgment that a patch
was applied. Inline correction is acceptable only for trivial wording clarifications where the
Skeptic explicitly delegates approval authority in their verdict.

## Concurrent gate sequencing in single-agent mode

Skeptic (code review) and Security Auditor run concurrently in spec. In single-agent mode they
run sequentially, but the relay should note this explicitly so the ordering doesn't imply a
dependency. Add "(sequential in single-agent mode; concurrent in multi-agent)" to the Planning
sequencing line when relevant.
