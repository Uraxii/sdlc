# SDLC Plugin — Agent Memory

Domain knowledge for agents working on the SDLC plugin repo itself.

---

## Skills architecture

### Platform-variant content (not content-identical)

Claude Code skills: detailed/procedural, numbered Steps, relay creation step, code fences, explicit
Orchestrator spawn note, concurrent gate description. ~40–50 lines.

Copilot skills: concise prose, condensed step list, no relay creation step, ends with
`Prefix each response **[RoleName]**.` reminder. ~30–35 lines.

Single merged file is not viable — content diverges structurally, not just in wording.

### Directory layout (post centralize-skills refactor, 2026-04-13)

```
skills/
  claude-code/
    sdlc/SKILL.md              ← root skill
    sdlc-<mode>/SKILL.md       ← 8 modes
  copilot/
    sdlc/SKILL.md
    sdlc-<mode>/SKILL.md
```

Modes: `full`, `lightweight`, `refactor`, `hotfix`, `poc`, `docs-only`, `config-data`, `dependency-bump`

Old trees `skills/sdlc/` and `skills-copilot/` are gone.

### Install destinations

| Platform | Source | Destination |
|----------|--------|-------------|
| Claude Code | `skills/claude-code/*/` | `.claude/skills/<dirname>/SKILL.md` |
| Copilot | `skills/copilot/*/` | `.github/skills/<dirname>/SKILL.md` |

Dir names in source equal destination dir names — no name transformation at copy time.
Root skill `sdlc/` is a peer dir alongside `sdlc-<mode>/` dirs; covered by the same loop.

### Build (build.py)

Two zips:
- `sdlc-claude-code.zip`: glob `skills/claude-code/**/*.md`, prefix `"skills/"` → arc paths `skills/claude-code/<mode>/SKILL.md`
- `sdlc-copilot.zip`: glob `skills/copilot/**/*.md`, no prefix → arc paths `skills/copilot/<mode>/SKILL.md`

`arcname()` uses prefix to compute in-zip paths. Verify arc paths match what install scripts reference
after extraction.

### `.original.md` files

Present in old `skills/sdlc/` tree. Excluded from zips via `is_original()` filter. Discarded on move — do not carry forward.
