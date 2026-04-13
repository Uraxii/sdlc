# Architect Memory

## Downstream notes must be implementer-ready, not design-complete

Design docs that are correct at the architecture level still cause Skeptic blockers when they omit
implementation-level specifics. Two recurring gap types:

**File operation specifics:** When files are moved AND renamed, state the exact rename transformation
explicitly in the Developer notes — not just the target layout. "Move `full/` → `sdlc-full/`" must
appear as a concrete instruction, not be derivable by diffing the before/after tree.

**Script surgery specifics:** When a script has a block that must be removed AND a loop that must be
extended, call out both operations explicitly. "The loop now covers root skill" is insufficient;
state "remove lines N–N (the standalone root-skill copy block) and change the loop glob to X."

Pattern: after writing the design, re-read the Developer notes asking "could someone implement this
without reading the rest of the Architecture section?" If no, add the missing step.

## File-move refactors: annotate pre-post names in the moves table

When source dir names differ from destination dir names, put both in the moves table:
`skills/sdlc/full/SKILL.md → skills/claude-code/sdlc-full/SKILL.md`
not just the layout diagram. The layout shows the result; the table drives the work.
