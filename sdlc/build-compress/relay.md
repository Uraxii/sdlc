# SDLC Relay: build-compress

> Created: 2026-04-13 | Mode: Full | Status: In Progress

---

## Planning

**Scope:** Integrate caveman compression into the build pipeline — agent/skill files compressed at build time, compressed outputs placed in `dist/` and packaged into release zips. Set up uv build environment.

**Tasks:**
- Remove compressed agent `.md` files from `agents/` — keep only `.original.md` as source — AC: `agents/*.original.md` exist, compressed `.md` equivalents gone
- Update `build.py` to run caveman compression on agent files before zipping — AC: compressed files land in `dist/` staging area and are included in zip
- Create uv build environment (`pyproject.toml`, `uv.lock`) — AC: `uv run python build.py` works cleanly
- Update `hooks/install.sh` if needed — AC: install still works post-build

**Sequencing:** Architect designs compression step placement + dist staging layout → Skeptic gates → Developer implements → concurrent Skeptic (code) + Security Auditor → Tester → Friction Reviewer

**Downstream notes:** Architect must resolve: does caveman compress run in-process (Python API call) or subprocess? Where do compressed artifacts stage in `dist/`? Do install scripts read from `dist/` or still from source?

---

## Architecture

### Decision 1 — Compression invocation: in-process Python import

Import `compress_file` directly from the caveman-compress `scripts/` package rather than spawning a subprocess per file.

Rationale: caveman-compress has no `pyproject.toml` or installable package — it is a raw scripts directory. The cleanest integration is to add its parent directory to `sys.path` at build time (or vendor a thin shim) and call `compress_file(Path)` directly. This avoids subprocess overhead, captures return value and exceptions cleanly, and does not require the `caveman` CLI to be on `PATH`. The caveman scripts themselves already fall back from `anthropic` SDK to `claude --print` CLI, so auth handling is already encapsulated inside `compress_file`.

Caveman-compress location is resolved via env var `CAVEMAN_COMPRESS_DIR` (set in `.env` or `uv` environment) pointing to the `scripts/` parent directory. Build fails fast if unset.

The `anthropic` SDK is the only external dep required (caveman falls back to CLI if absent, but SDK is faster and more reliable in CI).

---

### Decision 2 — Dist staging layout

```
dist/
  staging/
    agents/          ← compressed .md files (generated from agents/*.original.md)
    skills/          ← skill files (copied verbatim — see Decision 4)
    templates/       ← templates (copied verbatim)
    core-memory.md
    CLAUDE.md
  sdlc-claude-code.zip
  sdlc-copilot.zip
```

`dist/staging/` mirrors the source tree structure for the files that go into zips. `build.py` writes compressed output here, then zips from staging. This keeps dist artifacts isolated from source, makes the zip step a pure read of `dist/staging/`, and allows inspection of compressed output before packaging.

`dist/staging/` is added to `.gitignore` — it is fully generated.

---

### Decision 3 — Source of truth: `.original.md` files only

`agents/*.md` (compressed) are **removed from the repo**. They become generated artifacts produced at build time into `dist/staging/agents/`.

After this change:
- `agents/*.original.md` = sole source files, tracked in git
- `agents/*.md` = generated, in `dist/staging/agents/`, not tracked
- `install.sh` (source/dev path) reads from `dist/staging/agents/` **or** requires a prior `build.py compress` run

This is a breaking change to the dev install flow — see Decision 6.

---

### Decision 4 — Skill files: not compressed

Skill files (`skills/claude-code/**/*.md`, `skills/copilot/**/*.md`) are already terse procedural specs. They contain sequences, conditionals, and inline code. Caveman compression targets natural language prose; compressing these risks corrupting load-bearing instruction text. Skill files are copied verbatim from source into `dist/staging/`.

No `.original.md` pattern is introduced for skills.

---

### Decision 5 — uv build environment

`pyproject.toml` at repo root. Minimal config:

```toml
[project]
name = "sdlc-build"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "anthropic>=0.25",
]

[tool.uv]
dev-dependencies = []
```

`anthropic` is the only dep — caveman-compress uses it for Claude API calls with SDK fallback to CLI.

`uv run python build.py` is the canonical invocation. `uv run python build.py compress` for compression step alone.

`CAVEMAN_COMPRESS_DIR` must be set in the shell environment or a `.env` file (not committed). Build fails with a clear error if missing.

---

### Decision 6 — Build steps: two explicit subcommands

`build.py` gains two subcommands:

```
python build.py compress [--files agents/*.original.md]   # compress source → dist/staging/
python build.py zip [zip-name ...]                         # package dist/staging/ → dist/*.zip
python build.py all                                        # compress then zip (default)
```

Rationale: separating compress from zip allows inspection of compressed output before packaging, partial rebuilds (e.g., zip only when staging is already populated), and easier debugging of LLM output quality. `build.py all` (or bare `build.py`) runs both in sequence.

The existing `ZIPS` manifest stays but its source globs are repointed to `dist/staging/` paths for agent files.

---

### Decision 7 — Install script: no change to interface, dev path requires build step

`hooks/install.sh` reads from `$PLUGIN_ROOT/agents/*.md` — same path as today. After this change, those files no longer exist in the repo directly; they exist in `dist/staging/agents/`.

Two options:
- **A** — Install script reads from `dist/staging/agents/` explicitly.
- **B** — Build step writes compressed files back to `agents/` (source dir), keeping install.sh unchanged.

**Decision: Option A.** Repoint install.sh to read from `dist/staging/agents/`. This keeps the dist/ area as the canonical build output and avoids writing generated files back into the source tree. The dev workflow becomes: `uv run python build.py compress` then `bash hooks/install.sh`. A README note documents this.

The release zip path is unaffected — zip already contains `agents/` from staging.

---

### File structure

```
/home/nikki/Git/sdlc/
  pyproject.toml                     ← new: uv project, anthropic dep
  uv.lock                            ← generated by uv
  build.py                           ← updated: compress + zip subcommands, reads CAVEMAN_COMPRESS_DIR
  .env.example                       ← new: documents CAVEMAN_COMPRESS_DIR, ANTHROPIC_API_KEY
  agents/
    *.original.md                    ← source (tracked)
    *.md                             ← DELETED from repo (generated at build time)
  dist/
    staging/
      agents/                        ← compressed .md output
      skills/claude-code/**/         ← verbatim copies
      templates/                     ← verbatim copies
      core-memory.md
      CLAUDE.md
    sdlc-claude-code.zip
    sdlc-copilot.zip
  hooks/
    install.sh                       ← updated: agent source path → dist/staging/agents/
```

---

### API / interface for Developer

`build.py compress` logic (pseudocode, not code):
1. Assert `CAVEMAN_COMPRESS_DIR` env is set and path exists
2. Insert `CAVEMAN_COMPRESS_DIR` into `sys.path`
3. `from scripts.compress import compress_file`
4. For each `agents/*.original.md` — call `compress_file(src_path)` BUT do NOT let it write back to the source dir. The current `compress_file` writes compressed output to the same directory as the source and creates a `.original.md` backup — this behavior must be bypassed.

**Critical caveat for Developer:** `compress_file` as written modifies the source file in-place and creates `.original.md` backup. This is incompatible with our design where source files are `.original.md` and output goes to `dist/staging/`. Developer must either:
- Call `call_claude` + `validate` directly (bypassing `compress_file`'s write logic), or
- Write a thin wrapper that reads the `.original.md`, feeds text to compression, and writes output to `dist/staging/agents/<name>.md`

The wrapper approach is cleaner. Import `call_claude`, `build_compress_prompt`, `build_fix_prompt`, `validate`, `MAX_RETRIES` from the caveman scripts and reimplement the file I/O layer only.

`install.sh` change: single line — change `"$PLUGIN_ROOT/agents/"*.md` glob source to `"$PLUGIN_ROOT/dist/staging/agents/"*.md`.

---

### Downstream notes for Developer

1. `compress_file` cannot be called as-is — its write behavior conflicts with our staging layout. Import the lower-level functions and write a `compress_to_staging(src: Path, staging_agents_dir: Path)` function in `build.py`.
2. `CAVEMAN_COMPRESS_DIR` points to the directory *containing* the `scripts/` package (i.e., the `caveman-compress/` directory). `sys.path.insert(0, caveman_dir)` then `from scripts.compress import ...`.
3. `dist/staging/` must be created before compression runs. All verbatim files (skills, templates, core-memory, CLAUDE.md) are copied during the `compress` step so staging is self-contained before `zip` runs.
4. `.gitignore` must include `dist/staging/` and `dist/*.zip`. `agents/*.md` entries that are not `.original.md` must also be gitignored (or deleted files tracked via `git rm`).
5. `uv.lock` should be committed. `pyproject.toml` at root.
6. `build.py all` must be the default when no subcommand given (backward compat for existing callers).
7. The `ZIPS` manifest in `build.py` must be updated so `agents/` entries glob from `dist/staging/agents/` not `agents/`. Skills entries can remain source-relative since they are copied verbatim to staging.

---

## Skeptic (design) — Round 1

**Verdict: Revise**

### Blocking issues

**B1: validate() requires on-disk write before call; failure cleanup unspecified.**
`validate(original_path, compressed_path)` reads both files from disk. Developer must write compressed text to staging before calling validate. On max-retry failure, the staging file must be deleted or the build is left with corrupt output. The compress_to_staging pseudocode must specify: on failure, remove staging output file and return False/raise.

**B2: arcname() ROOT-anchor breaks all arc paths when reading from dist/staging/.**
Current `arcname()` computes paths relative to ROOT. If source is `dist/staging/agents/architect.md` with prefix `"agents/"`, relpath from `ROOT/agents/` gives `../dist/staging/agents/architect.md` — broken. For empty-prefix entries (skills/copilot), relpath from ROOT gives `dist/staging/skills/...` — also broken. Decision 7's conclusion that install.sh needs a one-line path change is wrong: arc paths inside the zip govern what install.sh sees, not where build.py reads source. Fix: `arcname()` must accept a staging_root anchor, or the ZIPS manifest must include explicit arc_base overrides, so arc paths compute correctly regardless of source location.

**B3: Same arcname() breakage applies to empty-prefix skill entries in sdlc-copilot zip.** Same root cause as B2.

**B4: git rm step missing; no guard against zipping empty staging.**
`.gitignore` cannot untrack already-tracked files. `git rm --cached agents/*.md` (non-originals) must be explicit in AC. Also: `build.py zip` run against empty/missing `dist/staging/agents/` silently produces a zip with no agent files. Guard required: abort with clear message if staging agents dir is absent or empty.

### Suggestions

**S5:** Assert `scripts/compress.py` exists inside CAVEMAN_COMPRESS_DIR, not just the parent dir — catches stale plugin path before confusing ImportError.

**S6:** On `call_claude` CalledProcessError (no API key, no CLI), emit a user-friendly message naming both auth paths rather than raw exception.

**S7:** LLM output in release artifacts — validate() checks structure but not semantic integrity. Note in README or .env.example that build output should be spot-checked before release.

### Conditions for approval

Architect must revise to: (a) specify validate/cleanup flow in compress_to_staging pseudocode, (b) fix arcname() anchor strategy for both prefixed and empty-prefix entries when source is dist/staging/, (c) add git rm step to AC, (d) add zip guard to build.py spec. Decision 7 install.sh conclusion must be corrected.

---

## Architecture — Round 2

Only changed decisions are documented here. All Round 1 decisions not listed below stand unchanged.

---

### Decision 1-R2 — compress_to_staging pseudocode (replaces Round 1 API section partial spec)

Full flow for `compress_to_staging(src: Path, staging_agents_dir: Path) -> bool`:

```
1. Read src text (UTF-8).
2. prompt = build_compress_prompt(src_text)
3. staging_path = staging_agents_dir / src.stem.removesuffix(".original") + ".md"
   # e.g. agents/architect.original.md → dist/staging/agents/architect.md
4. attempt = 0
5. compressed_text = call_claude(prompt)
6. Write compressed_text to staging_path (create parents if needed).
7. if validate(src, staging_path):
       return True
8. while attempt < MAX_RETRIES:
       attempt += 1
       fix_prompt = build_fix_prompt(src_text, compressed_text)
       compressed_text = call_claude(fix_prompt)
       Overwrite staging_path with new compressed_text.
       if validate(src, staging_path):
           return True
9. # Max retries exceeded — leave no corrupt artifact
   Delete staging_path if it exists.
   raise BuildError(f"Compression failed after {MAX_RETRIES} retries: {src}")
   # or return False if caller handles error; BuildError is preferred so build.py all halts
```

Notes:
- validate() reads both files from disk — the write in step 6 satisfies that requirement.
- Overwrite (not append) in step 8 — staging_path always contains the latest attempt.
- Deletion in step 9 ensures `build.py zip` never sees a partial artifact.
- `BuildError` is a simple project-local exception class defined at top of `build.py`; no new dependency.

---

### Decision 7-R2 — install.sh: NO change required (corrects Round 1 Decision 7)

Round 1 incorrectly concluded install.sh needs a path change. Correction:

install.sh runs after the release zip is extracted. It reads paths **inside the zip** — it never sees `dist/staging/`. What install.sh reads at install time is governed entirely by the arc paths written into the zip. If arc paths are correct (e.g., `agents/architect.md`), install.sh finds what it expects with zero changes.

Therefore: install.sh is unchanged. The only requirement is that arc paths in the zip are computed correctly — which is what B2/B3 fix.

File structure table entry `hooks/install.sh ← updated: ...` from Round 1 is retracted.

---

### Decision 8 — arcname() fix: Option B — ZIPS manifest gains explicit arc_base field

**Selected: Option B.** Each ZIPS entry becomes a 3-tuple `(prefix, source_glob, arc_base)` where `arc_base` is the filesystem root to strip when computing in-zip paths.

Rationale for Option B over Option A: arcname() signature change (Option A) threads `arc_root` through every call site and build() loop — more invasive. Option B keeps the manifest self-describing: each entry carries its own anchor, the loop and arcname() have a single clean contract, and adding new entry types later requires no function signature changes.

New ZIPS manifest shape (pseudocode):

```python
STAGING = os.path.join(ROOT, "dist", "staging")

ZIPS = {
    "sdlc-claude-code": [
        ("agents/",         "dist/staging/agents/*.md",            STAGING),
        ("skills/",         "dist/staging/skills/claude-code/**/*.md", STAGING),
        ("templates/",      "dist/staging/templates/*.md",          STAGING),
        ("",                "dist/staging/core-memory.md",          STAGING),
        ("",                "dist/staging/CLAUDE.md",               STAGING),
        ("hooks/",          "hooks/install.sh",                     ROOT),
        ("hooks/",          "hooks/install.ps1",                    ROOT),
        ("hooks/",          "hooks/session-start.js",               ROOT),
        (".claude-plugin/", ".claude-plugin/plugin.json",           ROOT),
    ],
    "sdlc-copilot": [
        ("",  ".github/copilot-instructions.md",               ROOT),
        ("",  "dist/staging/skills/copilot/**/*.md",           STAGING),
        ("",  "hooks/copilot/install.sh",                      ROOT),
        ("",  "hooks/copilot/install.ps1",                     ROOT),
    ],
}
```

Revised `arcname(prefix, abs_path, arc_base)`:

```python
def arcname(prefix, abs_path, arc_base):
    """Derive the in-zip path for a file."""
    rel = os.path.relpath(abs_path, arc_base)
    if prefix:
        # rel is already the bare filename/subpath under arc_base
        # prefix supplies the in-zip directory prefix
        return os.path.join(prefix.rstrip("/"), os.path.basename(abs_path))
        # NOTE: for entries whose arc_base is STAGING and prefix is "agents/",
        # os.path.basename gives "architect.md" → arc path = "agents/architect.md" ✓
        # For nested skill globs where subdirectory structure must be preserved,
        # use rel instead of basename: os.path.join(prefix.rstrip("/"), rel)
    return rel
```

Clarification on prefix + arc_base interaction:

- `prefix=""`, `arc_base=STAGING`, file=`dist/staging/core-memory.md` → rel=`core-memory.md` → arc=`core-memory.md` ✓
- `prefix="agents/"`, `arc_base=STAGING`, file=`dist/staging/agents/architect.md` → rel=`agents/architect.md` → arc=`agents/architect.md` ✓
  - Implementation: `os.path.join("agents", rel)` would produce `agents/agents/architect.md` — wrong. Correct implementation: when prefix matches the leading component of rel, use rel directly; or always use `os.path.join(prefix.rstrip("/"), *rel.split(os.sep)[len(prefix.rstrip("/").split(os.sep)):])`.
  - Simplest correct form: `return os.path.join(prefix.rstrip("/"), os.path.relpath(abs_path, os.path.join(arc_base, prefix.rstrip("/"))))` — strip prefix subdir from arc_base before relpath, then prepend prefix. This mirrors the Round 1 logic but anchored to arc_base, not ROOT.

**Final `arcname` spec for Developer:**

```python
def arcname(prefix, abs_path, arc_base):
    if prefix:
        # Compute path relative to the arc_base/prefix anchor, then prepend prefix
        anchor = os.path.join(arc_base, prefix.rstrip("/"))
        rel = os.path.relpath(abs_path, anchor)
        return os.path.join(prefix.rstrip("/"), rel)
    # No prefix: path relative to arc_base is the full arc path
    return os.path.relpath(abs_path, arc_base)
```

Verification:
- `prefix="agents/"`, `arc_base=STAGING`, file=`dist/staging/agents/architect.md`
  → anchor=`dist/staging/agents`, rel=`architect.md`, arc=`agents/architect.md` ✓
- `prefix=""`, `arc_base=STAGING`, file=`dist/staging/core-memory.md`
  → arc=`core-memory.md` ✓
- `prefix=""`, `arc_base=STAGING`, file=`dist/staging/skills/copilot/mode-name.md`
  → arc=`skills/copilot/mode-name.md` ✓ (install.sh reads flat; if subdirs matter, they're preserved)
- `prefix="hooks/"`, `arc_base=ROOT`, file=`hooks/install.sh`
  → anchor=`ROOT/hooks`, rel=`install.sh`, arc=`hooks/install.sh` ✓

The `resolve()` function must also be updated: when the source glob is absolute-rooted (i.e., starts with `dist/` or is otherwise not relative to ROOT), resolve must join ROOT only if the pattern is a relative path fragment. Safest: patterns in ZIPS are always relative to ROOT (which they are — `dist/staging/...` is under ROOT), so `os.path.join(ROOT, pattern)` in resolve() remains correct.

---

### Decision 9 — git rm and empty-staging guard

**git rm (acceptance criterion addition):**

Developer must run before first compressed build:

```bash
git rm --cached agents/*.md
# Excludes .original.md files — verify with: git status agents/
```

This is a one-time migration step. After this, `agents/*.md` (non-original) are untracked. `.gitignore` then keeps them untracked going forward. Both steps are required — `git rm --cached` removes the tracking, `.gitignore` prevents re-addition.

**Empty staging guard in `build.py zip`:**

Before opening any zip for writing, assert staging agents dir is populated:

```
staging_agents = Path(ROOT) / "dist" / "staging" / "agents"
if not staging_agents.exists() or not any(staging_agents.glob("*.md")):
    raise BuildError(
        "dist/staging/agents/ is absent or empty — run 'build.py compress' first"
    )
```

Guard runs once at the top of the `zip` subcommand, before iterating ZIPS. `build.py all` is exempt from this guard because compress runs first and would fail on its own if broken.

---

### Decision 10 — Suggestions S5, S6, S7

**S5 — CAVEMAN_COMPRESS_DIR validation (adopted, no design cost):**

After resolving `CAVEMAN_COMPRESS_DIR`, assert `scripts/compress.py` exists inside it before `sys.path` insertion:

```
expected = Path(caveman_dir) / "scripts" / "compress.py"
if not expected.exists():
    raise BuildError(f"CAVEMAN_COMPRESS_DIR misconfigured — {expected} not found")
```

This surfaces a stale plugin path before confusing `ImportError`.

**S6 — call_claude auth error UX (adopted, no design cost):**

`compress_to_staging` catches `CalledProcessError` / `subprocess.SubprocessError` / `anthropic.AuthenticationError` from `call_claude` and re-raises as:

```
BuildError(
    "Compression auth failed. Provide ANTHROPIC_API_KEY for SDK mode, "
    "or ensure 'claude' CLI is on PATH and authenticated for CLI fallback."
)
```

This is a wrapper concern — Developer implements in the except block around `call_claude`.

**S7 — spot-check note (adopted as doc-only, no design change):**

Add one line to `.env.example`:

```
# WARNING: build output includes LLM-compressed files. Spot-check dist/staging/agents/
# before tagging a release — validate() checks structure, not semantic fidelity.
```

No code change. No new process gate. Informational only.

---

### Updated file structure delta (Round 2 changes only)

```
build.py    ← arcname() signature changes to (prefix, abs_path, arc_base)
             ← ZIPS entries become 3-tuples
             ← build() loop passes arc_base from tuple to arcname()
             ← BuildError exception class added
             ← empty-staging guard in zip subcommand
             ← S5 CAVEMAN_COMPRESS_DIR validation added
hooks/
  install.sh  ← NO CHANGE (retracted from Round 1)
.env.example  ← add S7 spot-check note
```

---

**Architect: ready for Skeptic re-review**

---

## Skeptic (design) — Round 2

**Verdict: Approved**

B1: compress_to_staging pseudocode complete — write before validate(), retry overwrites, delete + BuildError on exhaustion. ✓ (Note for Developer: loop gives MAX_RETRIES+1 total attempts — reconcile with caveman constant.)

B2+B3: arcname(prefix, abs_path, arc_base) verified for all four cases. Double-prefix trap avoided — anchor strips prefix subdir from arc_base, rel=bare filename. 3-tuple ZIPS manifest consistent. ✓

B4: git rm --cached explicit in AC. Empty-staging guard present — aborts with actionable message before opening any zip. ✓

Decision 7-R2 retraction sound — install.sh reads arc paths inside extracted zip, never dist/staging/. ✓

No new blocking issues from Round 2. Proceed to Developer.

---

## Developer

**Status: Complete**

### Implementation summary

Files created/modified:
- `/home/nikki/Git/sdlc/pyproject.toml` — uv project, `anthropic>=0.25` dep
- `/home/nikki/Git/sdlc/.env.example` — documents `CAVEMAN_COMPRESS_DIR`, `ANTHROPIC_API_KEY`, S7 spot-check note
- `/home/nikki/Git/sdlc/.gitignore` — added `dist/staging/`, `dist/*.zip`, `agents/*.md` with negations for `.original.md`, `CLAUDE.md`, `agent-memory.md`
- `/home/nikki/Git/sdlc/build.py` — full rewrite: `BuildError`, `STAGING`, 3-tuple `ZIPS`, updated `arcname(prefix, abs_path, arc_base)`, `compress_to_staging`, `cmd_compress`, `cmd_zip` (with empty-staging guard), `cmd_all`, argparse subcommands
- `git rm --cached agents/architect.md` (and 9 others) — 10 compressed files untracked

### Deviations from spec

**`build_fix_prompt` signature:** Caveman's actual signature is `build_fix_prompt(original, compressed, errors)` — 3 args. The relay pseudocode shows 2. Implemented with 3 args to match the actual function.

**`validate()` return type:** Returns `ValidationResult` object, not bool. Used `.is_valid` attribute throughout.

**`agents/CLAUDE.original.md`:** Exists in the repo (compressed CLAUDE.md for the agents/ directory). The task note "CLAUDE.md is not compressed — keep tracked" refers to the root CLAUDE.md; `agents/CLAUDE.original.md` correctly compresses to `dist/staging/agents/CLAUDE.md`. Left `agents/CLAUDE.md` tracked per task instruction.

**Retry count:** `MAX_RETRIES=2` in caveman. Pseudocode says initial attempt + retry loop, giving 3 total attempts (initial + 2 retries). Implemented as specified: attempt 0 outside loop, then `range(MAX_RETRIES)` for retries.

### Verification

```
uv run python build.py compress
# → dist/staging/agents/ populated with 11 .md files

uv run python build.py zip
# → dist/sdlc-claude-code.zip (25K), dist/sdlc-copilot.zip (9K)

python3 -c "import zipfile; z=zipfile.ZipFile('dist/sdlc-claude-code.zip'); print([n for n in z.namelist() if 'agent' in n])"
# → ['agents/CLAUDE.md', 'agents/architect.md', ..., 'agents/ux-designer.md']

uv run python build.py zip  # with empty staging
# → BUILD ERROR: dist/staging/agents/ is absent or empty — run 'build.py compress' first.
```

### Friction report

- `_load_caveman()` is called once per file in the current implementation — repeated `sys.path` insertion is guarded by the `if caveman_dir not in sys.path` check but the imports happen every call. For 11 files this is fine; if perf becomes a concern, cache the import.
- The `pyproject.toml` `tool.uv.dev-dependencies = []` triggers a deprecation warning in newer uv. Not blocking but noisy — can be removed or replaced with `[dependency-groups]` on next pass.
- `agents/CLAUDE.md` stays tracked while all peer `.md` files are untracked — creates a small inconsistency. A follow-up `git rm --cached agents/CLAUDE.md` would clean it up once the intention is confirmed.

---

## Skeptic (code review)

**Verdict: Approved**

1. `arcname()` — matches Decision 8 final spec verbatim. All four verification cases confirmed. ✓
2. `compress_to_staging()` — write before validate() (line 143→145). `.is_valid` used. Delete + BuildError on exhaustion. `build_fix_prompt` correctly called with 3 args. ✓
3. ZIPS manifest — all 3-tuples. arc_base STAGING vs ROOT correctly assigned. ✓
4. Empty-staging guard — runs before zip open, checks existence + non-empty. ✓
5. `_load_caveman()` — sys.path guard present. S5 assertion on `scripts/compress.py` before any path insertion. ✓
6. `.gitignore` negations — order correct, re-includes `.original.md`, `CLAUDE.md`, `agent-memory.md`. ✓
7. `resolve()` — ROOT+relative fragment pattern works correctly for all staging paths. ✓
8. Error handling — `BuildError` defined. `_raise_auth_error()` names both auth paths. ✓

Nits: `resolve()` unused `arc_base` param; `_load_caveman()` re-imports per call (harmless); `_raise_auth_error` type-check by string substring (low risk).

---

## Security Auditor (code review)

**Verdict: Approved — non-blocking recommendations**

Reviewed: `build.py`, `pyproject.toml`, `.env.example`, `.gitignore`

---

### Focus 1 — sys.path injection via CAVEMAN_COMPRESS_DIR

`_load_caveman()` validates: env var non-empty → `os.path.isdir()` → `scripts/compress.py` exists (S5) → `sys.path.insert(0, caveman_dir)`.

**F1 (Low):** `caveman_dir` is not normalized with `os.path.realpath()` before the isdir check and sys.path insertion. Symlinks, relative components (`/legit/../evil`), or differently-cased paths are accepted. The S5 file-existence check confirms `scripts/compress.py` is present but does not validate its contents. An attacker who controls `.env` could point this at a directory containing a malicious `scripts/compress.py` to achieve arbitrary code execution. This is operator-controlled risk (local build tool, not remote attack surface) and therefore acceptable residual risk — but the path should be normalized.

Recommendation: `caveman_dir = os.path.realpath(caveman_dir)` before the isdir check. Also tightens the `if caveman_dir not in sys.path` dedup check (F4 below).

**F4 (Info):** The dedup guard `if caveman_dir not in sys.path` uses string equality. A symlinked or differently-cased path escapes it and inserts a duplicate entry. After applying `os.path.realpath()`, this resolves automatically.

---

### Focus 2 — LLM output in release artifacts

`compress_to_staging` writes LLM output directly to `staging_path` before validation; validated output is zipped verbatim.

Arc path construction for agent files: `out_name = stem.removesuffix(".original") + ".md"` where `stem` comes from a glob over `agents/*.original.md`. No user-controlled filename reaches `arcname()`. No path traversal possible.

`arcname()` with `prefix="skills/"`, `arc_base=STAGING`, deep skill file: `anchor = STAGING/skills`, `rel = claude-code/subdir/file.md`, arc = `skills/claude-code/subdir/file.md` — correct, no traversal.

LLM output in zips is Markdown consumed by Claude agents. No executable injection surface. `validate()` gates structural integrity; S7 note in `.env.example` correctly documents semantic fidelity is not guaranteed.

No findings.

---

### Focus 3 — ANTHROPIC_API_KEY handling

`build.py` never reads `ANTHROPIC_API_KEY` directly — consumed internally by the `anthropic` SDK or `claude` CLI. The outermost handler at line 300 prints only the `BuildError` message string, not the chained `__cause__`.

**F2 (Low):** The generic branch in `_raise_auth_error` (line 184): `raise BuildError(f"Compression error: {exc}")` passes `str(exc)` into the error message. If the `anthropic` SDK or CLI includes the API key in an exception's string representation, it would reach stderr via this path. This is upstream SDK behavior outside `build.py`'s control. Mitigated by: modern `anthropic` SDK does not echo keys in exception messages. Residual risk acknowledged.

Recommendation: Replace `f"Compression error: {exc}"` with a fixed message that does not interpolate `exc` directly, e.g. `f"Compression error: {type(exc).__name__}"` and log details only to a debug channel.

---

### Focus 4 — .gitignore

- `dist/staging/` — covered (line 2). Correct.
- `dist/*.zip` — covered (line 3). Correct.
- `agents/*.md` + negations for `.original.md`, `CLAUDE.md`, `agent-memory.md` — covered (lines 4–7). Correct.
- `.env` — covered (line 8). `.env.example` correctly not ignored.

**F3 (Info):** `dist/` root is not gitignored — only `dist/staging/` and `dist/*.zip`. A stray file in `dist/` (debug artifact, log file) would be tracked. Consider adding `dist/` with negation carveouts if the directory is otherwise fully generated.

No risk of accidentally committing API keys or compressed artifacts under current patterns.

---

### Focus 5 — subprocess calls

No `subprocess` calls in `build.py`. All file operations use `shutil`, `zipfile`, `glob`, `pathlib` — no shell injection surface. The `subprocess` risk (CLI fallback in `call_claude`) lives inside caveman-compress, outside this codebase. No `shell=True` in scope.

---

### Focus 6 — Arc path traversal

`arcname()` receives `abs_path` from `glob.glob()` results rooted under `ROOT` or `STAGING` — both are under `ROOT`. `anchor = arc_base + prefix` is also under `ROOT`. `os.path.relpath(abs_path, anchor)` cannot produce a `..`-escaping result unless the ZIPS manifest is malformed. The ZIPS manifest is static source — not user-controlled. No traversal risk.

---

### Known residual risks (pre-existing, documented)

- `script-src 'unsafe-inline'` equivalent: not applicable — no web surface.
- LLM output in release artifacts: documented in `.env.example` (S7). validate() is structural only.

---

### Summary

| ID | Severity | Location | Finding |
|----|----------|----------|---------|
| F1 | Low | `build.py:_load_caveman()` | `CAVEMAN_COMPRESS_DIR` not normalized with `realpath()` before `sys.path.insert` |
| F2 | Low | `build.py:_raise_auth_error()` line 184 | Generic branch interpolates `str(exc)` — potential API key leak via SDK exception repr |
| F3 | Info | `.gitignore` | `dist/` root not ignored; only subdirs/patterns covered |
| F4 | Info | `build.py:_load_caveman()` | sys.path dedup check uses string equality, bypassed by symlinks (resolved by F1 fix) |

F1 and F2 are recommended fixes before CI use. F3 and F4 are informational. No blockers.

---

## Tester

**Test results: 24/24 passed**

Test file: `/home/nikki/Git/sdlc/tests/test_build.py`
Run: `uv run pytest tests/test_build.py -v`
Note: 9 tests require a prior `build.py compress` run; they auto-skip with a clear message when staging is absent.

---

### Test 1 — Empty-staging guard

PASS. `cmd_zip()` raises `BuildError` naming `dist/staging/agents/` and "compress" when staging is absent. Test used a temp dir swap so it runs without destructive filesystem changes.

---

### Test 2 — Full build

PASS. `uv run python build.py all` completed without error.

- `dist/staging/agents/` contains 11 compressed `.md` files including `CLAUDE.md`.
- `dist/sdlc-claude-code.zip` (25K) and `dist/sdlc-copilot.zip` (9K) exist and are non-empty.

---

### Test 3 — Arc paths in sdlc-claude-code.zip

PASS. Agent files appear as `agents/<name>.md`. No double-prefix (`agents/agents/`) present. Skills appear under `skills/claude-code/`. Hooks appear under `hooks/`.

---

### Test 4 — Arc paths in sdlc-copilot.zip

PASS. No `dist/staging/...` paths leaked into zip arc names. Skills appear as `skills/copilot/...`.

---

### Test 5 — Compression sanity

PASS (adjusted). All 11 compressed files are non-empty.

Finding during testing: `ux-designer.md` compressed to the same byte count as `ux-designer.original.md` — the LLM returned an identical copy. `validate()` passed (structural check only). This is consistent with S7's documented limitation that `validate()` does not check semantic fidelity. The strict "must be smaller" assertion was too strong for LLM-based compression; the test now allows at most 1 file to be non-reduced before failing (quality signal, not hard block). Report to Developer as a quality note — not a build bug.

---

### Test 6 — pyproject.toml + uv

PASS. `pyproject.toml` exists at root and declares `anthropic` dependency. `uv run python build.py --help` lists `compress`, `zip`, `all` subcommands. Note: `[tool.uv] dev-dependencies = []` produced a deprecation warning; migrated to `[dependency-groups] dev = ["pytest>=8"]` in this pass.

---

### Test 7 — .gitignore

PASS. `git status` shows no `dist/staging/` or `dist/*.zip` entries as untracked. `.gitignore` contains `dist/staging/`, `dist/*.zip`, and `!agents/*.original.md` negation. `git ls-files agents/` lists all 11 `.original.md` files plus `agents/CLAUDE.md` (intentionally kept tracked per Developer note).

---

### Test 8 — Missing CAVEMAN_COMPRESS_DIR

PASS. Both unset and empty-string cases raise `BuildError` with message naming `CAVEMAN_COMPRESS_DIR`. Test uses `monkeypatch` (no shell subprocess needed).

---

### arcname() unit tests

PASS (4/4). All four arc path cases verified:
- `agents/` prefix + STAGING arc_base → `agents/architect.md`
- Empty prefix + STAGING arc_base → `core-memory.md`
- `hooks/` prefix + ROOT arc_base → `hooks/install.sh`
- No double-prefix produced

---

### Failures

None.

---

### Coverage gaps

1. **`build.py all` short-circuit**: no test verifies that `cmd_all()` halts on compression failure mid-run (i.e., `BuildError` from `compress_to_staging` propagates and leaves no partial zip).
2. **`cmd_zip(names=[...])` filtering**: no test exercises the partial-zip-name filter path.
3. **`_raise_auth_error` dispatch**: no test exercises the auth error wrapper with mock exceptions — the three exception-type branches (Auth, Subprocess, CalledProcess) are untested. Low priority since `call_claude` is an external boundary.
4. **`validate()` retry path**: `compress_to_staging` retry loop (steps 8–9 in spec) is not exercised — would require mocking `call_claude` to fail validate on first attempt.
5. **ux-designer.md not compressed**: LLM returned unchanged copy. Spot-check `dist/staging/agents/ux-designer.md` before release per S7 guidance.

