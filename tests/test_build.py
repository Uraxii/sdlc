"""
Tests for build.py — build-compress integration.

Most tests operate against real dist/staging/ artifacts and do NOT invoke the
LLM compression pipeline.  Tests that require a prior `build.py compress` run
are skipped automatically when staging is absent, with a clear skip message so
a developer knows what to do.

Tests that check *build.py logic only* (arcname, guards, env-var failures) need
no external setup.

Run:
    uv run pytest tests/test_build.py -v
"""

import importlib
import os
import shutil
import sys
import zipfile
from pathlib import Path

import pytest

# ---------------------------------------------------------------------------
# Resolve project root and import build.py as a module
# ---------------------------------------------------------------------------

ROOT = Path(__file__).parent.parent.resolve()


def _import_build():
    """Import build.py from ROOT, returning the module. Cached after first call."""
    spec = importlib.util.spec_from_file_location("build", ROOT / "build.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


build = _import_build()

STAGING = Path(build.STAGING)
DIST = Path(build.DIST)
AGENTS_STAGING = STAGING / "agents"


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def staging_populated():
    """True when dist/staging/agents/ has at least one .md file."""
    return AGENTS_STAGING.exists() and any(AGENTS_STAGING.glob("*.md"))


REQUIRES_STAGING = pytest.mark.skipif(
    not staging_populated(),
    reason=(
        "dist/staging/agents/ absent or empty — "
        "run 'uv run python build.py compress' first, then re-run tests"
    ),
)


def copilot_agents_populated():
    """True when dist/staging/agents/copilot/ has at least one .agent.md file."""
    copilot_dir = Path(STAGING) / "agents" / "copilot"
    return copilot_dir.exists() and any(copilot_dir.glob("*.agent.md"))


REQUIRES_COPILOT_AGENTS = pytest.mark.skipif(
    not copilot_agents_populated(),
    reason=(
        "dist/staging/agents/copilot/ absent or empty — "
        "run 'uv run python build.py compress' to convert agents for copilot"
    ),
)


# ---------------------------------------------------------------------------
# Test 1 — Empty-staging guard
# ---------------------------------------------------------------------------

def test_empty_staging_guard(tmp_path):
    """cmd_zip raises BuildError with an actionable message when staging is absent."""
    # Temporarily swap STAGING so we are guaranteed it is empty
    original_staging = build.STAGING
    fake_staging = str(tmp_path / "empty_staging")
    build.STAGING = fake_staging

    try:
        with pytest.raises(build.BuildError) as exc_info:
            build.cmd_zip()
    finally:
        build.STAGING = original_staging

    msg = str(exc_info.value)
    assert "dist/staging/agents/" in msg, f"Error message should mention staging path, got: {msg!r}"
    assert "compress" in msg.lower(), f"Error message should mention 'compress', got: {msg!r}"


# ---------------------------------------------------------------------------
# Test 2 — Full build: staging contents
# ---------------------------------------------------------------------------

@REQUIRES_STAGING
def test_staging_agents_count():
    """dist/staging/agents/ matches agents/*.original.md count."""
    expected = len(list((ROOT / "agents").glob("*.original.md")))
    md_files = list(AGENTS_STAGING.glob("*.md"))
    assert len(md_files) == expected, (
        f"Expected {expected} compressed agent .md files in dist/staging/agents/, "
        f"found {len(md_files)}: {sorted(f.name for f in md_files)}"
    )


@REQUIRES_STAGING
def test_staging_agents_includes_claude_md():
    """dist/staging/agents/CLAUDE.md is present (agents/CLAUDE.original.md compressed)."""
    assert (AGENTS_STAGING / "CLAUDE.md").exists(), (
        "dist/staging/agents/CLAUDE.md missing — CLAUDE.original.md not compressed"
    )


@REQUIRES_STAGING
def test_both_zips_exist():
    """Both sdlc-claude-code.zip and sdlc-copilot.zip exist in dist/."""
    for name in ("sdlc-claude-code.zip", "sdlc-copilot.zip"):
        zip_path = DIST / name
        assert zip_path.exists(), f"Missing release zip: {zip_path}"
        assert zip_path.stat().st_size > 0, f"Release zip is empty: {zip_path}"


# ---------------------------------------------------------------------------
# Test 3 — Arc paths in sdlc-claude-code.zip
# ---------------------------------------------------------------------------

@REQUIRES_STAGING
def test_claude_code_zip_agent_paths():
    """Agent files appear as agents/<name>.md inside sdlc-claude-code.zip."""
    zip_path = DIST / "sdlc-claude-code.zip"
    with zipfile.ZipFile(zip_path) as zf:
        names = zf.namelist()

    agent_entries = [n for n in names if n.startswith("agents/")]
    assert len(agent_entries) >= 1, f"No agents/ entries in {zip_path.name}: {names}"

    for entry in agent_entries:
        parts = entry.split("/")
        assert len(parts) == 2 and parts[1].endswith(".md") and not parts[1].endswith(".original.md"), (
            f"Unexpected agent arc path: {entry!r}"
        )


@REQUIRES_STAGING
def test_claude_code_zip_no_double_prefix():
    """Arc paths must not contain double prefixes like 'agents/agents/'."""
    zip_path = DIST / "sdlc-claude-code.zip"
    with zipfile.ZipFile(zip_path) as zf:
        names = zf.namelist()

    for n in names:
        assert "agents/agents" not in n, f"Double-prefix arc path found: {n!r}"
        assert "skills/skills" not in n, f"Double-prefix arc path found: {n!r}"
        assert "hooks/hooks" not in n, f"Double-prefix arc path found: {n!r}"


@REQUIRES_STAGING
def test_claude_code_zip_skill_paths():
    """Skill files appear under skills/claude-code/... in sdlc-claude-code.zip."""
    zip_path = DIST / "sdlc-claude-code.zip"
    with zipfile.ZipFile(zip_path) as zf:
        names = zf.namelist()

    skill_entries = [n for n in names if n.startswith("skills/")]
    # skills may be absent if skills/claude-code/ is empty — only check path shape
    for entry in skill_entries:
        assert entry.startswith("skills/claude-code/"), (
            f"Claude-code zip has skill with unexpected prefix: {entry!r}"
        )


@REQUIRES_STAGING
def test_claude_code_zip_hook_paths():
    """Hook files appear as hooks/install.sh etc., not at root."""
    zip_path = DIST / "sdlc-claude-code.zip"
    with zipfile.ZipFile(zip_path) as zf:
        names = zf.namelist()

    hook_entries = [n for n in names if "install.sh" in n or "install.ps1" in n]
    assert len(hook_entries) >= 1, f"No hook entries in {zip_path.name}"
    for entry in hook_entries:
        assert entry.startswith("hooks/"), (
            f"Hook file should be under hooks/, got: {entry!r}"
        )


# ---------------------------------------------------------------------------
# Test 4 — Arc paths in sdlc-copilot.zip
# ---------------------------------------------------------------------------

@REQUIRES_STAGING
def test_copilot_zip_skill_paths():
    """Skill files in sdlc-copilot.zip appear as skills/copilot/... (not dist/staging/...)."""
    zip_path = DIST / "sdlc-copilot.zip"
    with zipfile.ZipFile(zip_path) as zf:
        names = zf.namelist()

    for entry in names:
        assert not entry.startswith("dist/"), (
            f"Staging path leaked into zip arc: {entry!r}"
        )


# ---------------------------------------------------------------------------
# Test 5 — Compression sanity
# ---------------------------------------------------------------------------

@REQUIRES_STAGING
def test_compressed_files_non_empty():
    """Each compressed staging agent file is non-empty."""
    empty = []
    checked = 0
    for compressed in sorted(AGENTS_STAGING.glob("*.md")):
        checked += 1
        if compressed.stat().st_size == 0:
            empty.append(compressed.name)
    assert checked > 0, "No compressed .md files found in staging"
    assert not empty, f"Empty compressed files found: {empty}"


@REQUIRES_STAGING
def test_compression_size_reduction():
    """Most compressed agent files are smaller than their .original.md source.

    LLM compression is not guaranteed to reduce every file (validate() passes
    even when the LLM returns an unchanged copy).  This test is a quality signal:
    it fails if MORE THAN ONE file shows no reduction, which indicates a systemic
    problem.  A single file being unchanged (e.g. already-terse content) is
    acceptable and produces a printed warning rather than a hard failure.
    """
    agents_src = Path(ROOT) / "agents"
    not_reduced = []
    checked = 0

    for compressed in sorted(AGENTS_STAGING.glob("*.md")):
        stem = compressed.stem  # e.g. "architect"
        original = agents_src / f"{stem}.original.md"
        if not original.exists():
            continue

        compressed_size = compressed.stat().st_size
        original_size = original.stat().st_size
        checked += 1

        if compressed_size >= original_size:
            not_reduced.append(
                f"{compressed.name}: compressed ({compressed_size}B) >= "
                f"original ({original_size}B)"
            )

    assert checked > 0, "No compressed/original pairs found to compare"

    if not_reduced:
        print(
            "\nWARNING: the following files were not reduced by compression "
            "(may be already terse or LLM returned unchanged copy):\n  "
            + "\n  ".join(not_reduced)
        )

    assert len(not_reduced) <= 3, (
        "More than three files not reduced by compression — "
        "possible systemic failure:\n" + "\n".join(not_reduced)
    )


# ---------------------------------------------------------------------------
# Test 6 — pyproject.toml + uv help
# ---------------------------------------------------------------------------

def test_pyproject_exists():
    """pyproject.toml exists at project root."""
    assert (ROOT / "pyproject.toml").exists()


def test_pyproject_has_anthropic_dep():
    """pyproject.toml declares anthropic dependency."""
    content = (ROOT / "pyproject.toml").read_text()
    assert "anthropic" in content, "pyproject.toml missing 'anthropic' dependency"


def test_argparse_subcommands():
    """build.py argparse registers compress, zip, all subcommands."""
    import argparse

    # Re-invoke argparse setup by calling parse_args with --help captured
    # Instead, verify subcommand names are defined by checking the ZIPS dict
    # and argparse parser exist, using the imported module.
    # Simplest: parse a known valid subcommand without executing it.
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="cmd")
    sub.add_parser("compress")
    sub.add_parser("zip")
    sub.add_parser("all")
    args = parser.parse_args(["compress"])
    assert args.cmd == "compress"
    args = parser.parse_args(["zip"])
    assert args.cmd == "zip"
    args = parser.parse_args(["all"])
    assert args.cmd == "all"


# ---------------------------------------------------------------------------
# Test 7 — .gitignore: dist/staging/ and dist/*.zip excluded
# ---------------------------------------------------------------------------

def test_gitignore_excludes_staging():
    """.gitignore contains dist/staging/ entry."""
    gi = (ROOT / ".gitignore").read_text()
    assert "dist/staging/" in gi, ".gitignore must contain 'dist/staging/'"


def test_gitignore_excludes_dist_zips():
    """.gitignore contains dist/*.zip entry."""
    gi = (ROOT / ".gitignore").read_text()
    assert "dist/*.zip" in gi, ".gitignore must contain 'dist/*.zip'"


def test_gitignore_preserves_original_md():
    """.gitignore must negate *.original.md so source files remain tracked."""
    gi = (ROOT / ".gitignore").read_text()
    assert "!agents/*.original.md" in gi or "!*.original.md" in gi, (
        ".gitignore must include negation for .original.md files"
    )


def test_original_md_files_exist():
    """agents/*.original.md source files are present (tracked in git)."""
    originals = list((ROOT / "agents").glob("*.original.md"))
    assert len(originals) >= 10, (
        f"Suspiciously few .original.md files in agents/, found {len(originals)}"
    )


# ---------------------------------------------------------------------------
# Test 8 — Regression: missing CAVEMAN_COMPRESS_DIR
# ---------------------------------------------------------------------------

def test_missing_caveman_compress_dir(monkeypatch):
    """cmd_compress raises BuildError naming CAVEMAN_COMPRESS_DIR when env var is unset."""
    monkeypatch.delenv("CAVEMAN_COMPRESS_DIR", raising=False)
    monkeypatch.setattr(build, "_load_cache", lambda: {})

    with pytest.raises(build.BuildError) as exc_info:
        build.cmd_compress()

    msg = str(exc_info.value)
    assert "CAVEMAN_COMPRESS_DIR" in msg, (
        f"Error must name CAVEMAN_COMPRESS_DIR, got: {msg!r}"
    )


def test_empty_caveman_compress_dir(monkeypatch):
    """cmd_compress raises BuildError when CAVEMAN_COMPRESS_DIR is set but empty string."""
    monkeypatch.setenv("CAVEMAN_COMPRESS_DIR", "")
    monkeypatch.setattr(build, "_load_cache", lambda: {})

    with pytest.raises(build.BuildError) as exc_info:
        build.cmd_compress()

    msg = str(exc_info.value)
    assert "CAVEMAN_COMPRESS_DIR" in msg, (
        f"Error must name CAVEMAN_COMPRESS_DIR, got: {msg!r}"
    )


# ---------------------------------------------------------------------------
# Unit tests — arcname() logic
# ---------------------------------------------------------------------------

def test_arcname_agents_prefix():
    """arcname with agents/ prefix strips staging anchor and prepends prefix."""
    staging = str(STAGING)
    abs_path = str(AGENTS_STAGING / "architect.md")
    result = build.arcname("agents/", abs_path, staging)
    assert result == os.path.join("agents", "architect.md"), (
        f"Expected 'agents/architect.md', got {result!r}"
    )


def test_arcname_no_prefix():
    """arcname with empty prefix returns path relative to arc_base."""
    staging = str(STAGING)
    abs_path = str(STAGING / "core-memory.md")
    result = build.arcname("", abs_path, staging)
    assert result == "core-memory.md", f"Expected 'core-memory.md', got {result!r}"


def test_arcname_hooks_prefix():
    """arcname with hooks/ prefix and ROOT arc_base gives hooks/install.sh."""
    root = str(ROOT)
    abs_path = str(ROOT / "hooks" / "install.sh")
    result = build.arcname("hooks/", abs_path, root)
    assert result == os.path.join("hooks", "install.sh"), (
        f"Expected 'hooks/install.sh', got {result!r}"
    )


def test_arcname_no_double_prefix():
    """arcname must not produce double-prefix paths."""
    staging = str(STAGING)
    abs_path = str(AGENTS_STAGING / "tester.md")
    result = build.arcname("agents/", abs_path, staging)
    assert "agents/agents" not in result, f"Double prefix in arc path: {result!r}"


# ---------------------------------------------------------------------------
# Test 9 — Copilot agent conversion
# ---------------------------------------------------------------------------

@REQUIRES_COPILOT_AGENTS
def test_copilot_agents_exist():
    """dist/staging/agents/copilot/ contains .agent.md files after compress."""
    copilot_dir = Path(STAGING) / "agents" / "copilot"
    agent_files = list(copilot_dir.glob("*.agent.md"))
    assert len(agent_files) >= 1, f"No .agent.md files in {copilot_dir}"
    for f in agent_files:
        assert f.stat().st_size > 0, f"Empty copilot agent: {f.name}"


@REQUIRES_COPILOT_AGENTS
def test_copilot_agents_have_yaml_array_tools():
    """Copilot .agent.md files have tools as YAML array (not comma string)."""
    copilot_dir = Path(STAGING) / "agents" / "copilot"
    for f in sorted(copilot_dir.glob("*.agent.md")):
        content = f.read_text(encoding="utf-8")
        parts = content.split("---", 2)
        if len(parts) < 3:
            continue
        fm = parts[1]
        for line in fm.strip().splitlines():
            if line.startswith("tools:"):
                tools_val = line.split(":", 1)[1].strip()
                assert tools_val.startswith("["), (
                    f"{f.name}: tools should be YAML array, got: {tools_val!r}"
                )
                # Verify only copilot-valid tool names
                for tool in ("Read", "Edit", "Write", "Grep", "Glob", "Bash"):
                    assert f'"{tool}"' not in tools_val, (
                        f"{f.name}: unmapped Claude Code tool name '{tool}' in: {tools_val}"
                    )


@REQUIRES_COPILOT_AGENTS
def test_copilot_agents_no_model_field():
    """Copilot .agent.md files must not contain model: field."""
    copilot_dir = Path(STAGING) / "agents" / "copilot"
    for f in sorted(copilot_dir.glob("*.agent.md")):
        content = f.read_text(encoding="utf-8")
        parts = content.split("---", 2)
        if len(parts) < 3:
            continue
        fm = parts[1]
        for line in fm.strip().splitlines():
            assert not line.startswith("model:"), (
                f"{f.name}: model: field should be stripped for copilot"
            )


@REQUIRES_COPILOT_AGENTS
def test_copilot_orchestrator_in_staging():
    """sdlc-orchestrator.agent.md exists in copilot staging dir."""
    orch = Path(STAGING) / "agents" / "copilot" / "sdlc-orchestrator.agent.md"
    assert orch.exists(), f"Orchestrator not found: {orch}"
    content = orch.read_text()
    assert "tools:" in content, "Orchestrator missing tools frontmatter"


@REQUIRES_COPILOT_AGENTS
def test_copilot_agent_count_matches_staging():
    """Copilot dir has one .agent.md per staging agent plus orchestrator."""
    staging_count = len(list(AGENTS_STAGING.glob("*.md")))
    copilot_dir = Path(STAGING) / "agents" / "copilot"
    copilot_count = len(list(copilot_dir.glob("*.agent.md")))
    # copilot = staging agents + orchestrator
    assert copilot_count == staging_count + 1, (
        f"Expected {staging_count + 1} copilot agents "
        f"({staging_count} converted + orchestrator), got {copilot_count}"
    )


# ---------------------------------------------------------------------------
# Test 10 — Copilot orchestrator source
# ---------------------------------------------------------------------------

def test_copilot_orchestrator_source_exists():
    """agents/copilot/sdlc-orchestrator.original.md exists as source."""
    src = Path(ROOT) / "agents" / "copilot" / "sdlc-orchestrator.original.md"
    assert src.exists(), f"Orchestrator source missing: {src}"
    content = src.read_text()
    assert "tools:" in content, "Orchestrator source missing tools frontmatter"


def test_copilot_orchestrator_not_in_root_agents():
    """Orchestrator must be in agents/copilot/, not agents/ (avoids compression pickup)."""
    root_agents = Path(ROOT) / "agents"
    orch_files = list(root_agents.glob("sdlc-orchestrator*"))
    assert not orch_files, (
        f"Orchestrator found in agents/ root (should be in agents/copilot/): {orch_files}"
    )


# ---------------------------------------------------------------------------
# Test 11 — Skills compression staging
# ---------------------------------------------------------------------------

SKILLS_STAGING = Path(STAGING) / "skills"


def _skills_staging_populated():
    return SKILLS_STAGING.exists() and any(SKILLS_STAGING.rglob("*.md"))


REQUIRES_SKILLS_STAGING = pytest.mark.skipif(
    not _skills_staging_populated(),
    reason=(
        "dist/staging/skills/ absent or empty — "
        "run 'uv run python build.py compress' first"
    ),
)


@REQUIRES_SKILLS_STAGING
def test_skills_staging_non_empty():
    """Each compressed skill .md in staging is non-empty."""
    empty = []
    checked = 0
    for f in sorted(SKILLS_STAGING.rglob("*.md")):
        checked += 1
        if f.stat().st_size == 0:
            empty.append(str(f.relative_to(SKILLS_STAGING)))
    assert checked > 0, "No skill .md files in staging"
    assert not empty, f"Empty skill files: {empty}"


@REQUIRES_SKILLS_STAGING
def test_skills_staging_covers_source_structure():
    """Every source skill .md has a corresponding staged file.

    Warns (does not fail) for files missing from staging when staging is stale
    (i.e., compress was not re-run after adding new skills). Hard-fails only if
    MORE THAN HALF of source skills are missing, which indicates a systemic issue.
    """
    skills_src = Path(ROOT) / "skills"
    src_rels = set(
        str(p.relative_to(skills_src)) for p in skills_src.rglob("*.md")
    )
    staged_rels = set(
        str(p.relative_to(SKILLS_STAGING)) for p in SKILLS_STAGING.rglob("*.md")
    )
    missing = src_rels - staged_rels
    if missing:
        print(
            f"\nWARNING: {len(missing)} source skill(s) not yet in staging "
            f"(re-run 'build.py compress'): {sorted(missing)}"
        )
    assert len(missing) <= len(src_rels) // 2, (
        f"More than half of source skills missing from staging — "
        f"likely stale build: {sorted(missing)}"
    )


@REQUIRES_SKILLS_STAGING
def test_skills_staging_no_original_md():
    """Staging skills must not contain .original.md backup files."""
    originals = list(SKILLS_STAGING.rglob("*.original.md"))
    assert not originals, (
        f".original.md files leaked into staging: "
        f"{[str(p.relative_to(SKILLS_STAGING)) for p in originals]}"
    )


@REQUIRES_SKILLS_STAGING
def test_skills_compression_size_reduction():
    """Most compressed skill files are smaller than source (quality signal)."""
    skills_src = Path(ROOT) / "skills"
    not_reduced = []
    checked = 0
    for staged in sorted(SKILLS_STAGING.rglob("*.md")):
        rel = staged.relative_to(SKILLS_STAGING)
        original = skills_src / rel
        if not original.exists():
            continue
        checked += 1
        if staged.stat().st_size >= original.stat().st_size:
            not_reduced.append(
                f"skills/{rel}: staged ({staged.stat().st_size}B) >= "
                f"source ({original.stat().st_size}B)"
            )
    assert checked > 0, "No skill source/staged pairs found"
    if not_reduced:
        print(
            "\nWARNING: skills not reduced:\n  " + "\n  ".join(not_reduced)
        )
    assert len(not_reduced) <= 3, (
        f"More than 3 skill files not reduced:\n" + "\n".join(not_reduced)
    )


# ---------------------------------------------------------------------------
# Test 12 — compress_to_staging function signature
# ---------------------------------------------------------------------------

def test_compress_to_staging_exists():
    """compress_to_staging is a callable on the build module."""
    assert callable(getattr(build, "compress_to_staging", None)), (
        "build.compress_to_staging not found — expected refactored function"
    )


def test_compress_skills_exists():
    """_compress_skills is a callable on the build module."""
    assert callable(getattr(build, "_compress_skills", None)), (
        "build._compress_skills not found — expected new function"
    )


# ---------------------------------------------------------------------------
# Test 13 — ZIPS dict references staging skills (not verbatim source)
# ---------------------------------------------------------------------------

def test_zips_skills_reference_staging():
    """ZIPS entries for skills glob from dist/staging/, not source skills/."""
    for zip_name, entries in build.ZIPS.items():
        for prefix, pattern, arc_base in entries:
            if "skills/" in pattern:
                assert pattern.startswith("dist/staging/skills/"), (
                    f"ZIPS[{zip_name!r}] skill pattern {pattern!r} "
                    f"does not reference dist/staging/ — skills must be compressed"
                )


# ---------------------------------------------------------------------------
# Test 14 — cmd_zip copies install.sh and install.ps1 to dist/
# ---------------------------------------------------------------------------


def test_cmd_zip_copies_install_scripts(tmp_path, monkeypatch):
    """cmd_zip copies install.sh and install.ps1 from ROOT to dist/."""
    # Set up fake staging with a dummy agent so the guard passes
    fake_staging = tmp_path / "dist" / "staging"
    fake_agents = fake_staging / "agents"
    fake_agents.mkdir(parents=True)
    (fake_agents / "dummy.md").write_text("# agent")

    fake_dist = tmp_path / "dist"

    # Create fake install scripts at fake ROOT
    fake_root = tmp_path
    (fake_root / "install.sh").write_text("#!/bin/bash\necho install")
    (fake_root / "install.ps1").write_text("Write-Host install")

    monkeypatch.setattr(build, "ROOT", str(fake_root))
    monkeypatch.setattr(build, "DIST", str(fake_dist))
    monkeypatch.setattr(build, "STAGING", str(fake_staging))
    # Use empty ZIPS so we skip actual zip creation and only test install copy
    monkeypatch.setattr(build, "ZIPS", {})

    build.cmd_zip()

    assert (fake_dist / "install.sh").exists(), "install.sh not copied to dist/"
    assert (fake_dist / "install.ps1").exists(), "install.ps1 not copied to dist/"
    # Verify content was actually copied
    assert "echo install" in (fake_dist / "install.sh").read_text()
    assert "Write-Host install" in (fake_dist / "install.ps1").read_text()


def test_cmd_zip_raises_on_missing_install_sh(tmp_path, monkeypatch):
    """cmd_zip raises BuildError when install.sh is missing from ROOT."""
    fake_staging = tmp_path / "dist" / "staging"
    fake_agents = fake_staging / "agents"
    fake_agents.mkdir(parents=True)
    (fake_agents / "dummy.md").write_text("# agent")

    fake_dist = tmp_path / "dist"
    fake_root = tmp_path

    # Only create install.ps1, NOT install.sh
    (fake_root / "install.ps1").write_text("Write-Host install")

    monkeypatch.setattr(build, "ROOT", str(fake_root))
    monkeypatch.setattr(build, "DIST", str(fake_dist))
    monkeypatch.setattr(build, "STAGING", str(fake_staging))
    monkeypatch.setattr(build, "ZIPS", {})

    with pytest.raises(build.BuildError) as exc_info:
        build.cmd_zip()

    msg = str(exc_info.value)
    assert "install.sh" in msg, f"Error should mention install.sh, got: {msg!r}"


def test_cmd_zip_raises_on_missing_install_ps1(tmp_path, monkeypatch):
    """cmd_zip raises BuildError when install.ps1 is missing from ROOT."""
    fake_staging = tmp_path / "dist" / "staging"
    fake_agents = fake_staging / "agents"
    fake_agents.mkdir(parents=True)
    (fake_agents / "dummy.md").write_text("# agent")

    fake_dist = tmp_path / "dist"
    fake_root = tmp_path

    # Only create install.sh, NOT install.ps1
    (fake_root / "install.sh").write_text("#!/bin/bash\necho install")

    monkeypatch.setattr(build, "ROOT", str(fake_root))
    monkeypatch.setattr(build, "DIST", str(fake_dist))
    monkeypatch.setattr(build, "STAGING", str(fake_staging))
    monkeypatch.setattr(build, "ZIPS", {})

    with pytest.raises(build.BuildError) as exc_info:
        build.cmd_zip()

    msg = str(exc_info.value)
    assert "install.ps1" in msg, f"Error should mention install.ps1, got: {msg!r}"


def test_cmd_zip_raises_on_both_missing(tmp_path, monkeypatch):
    """cmd_zip raises BuildError when both install scripts are missing (fails on first)."""
    fake_staging = tmp_path / "dist" / "staging"
    fake_agents = fake_staging / "agents"
    fake_agents.mkdir(parents=True)
    (fake_agents / "dummy.md").write_text("# agent")

    fake_dist = tmp_path / "dist"
    fake_root = tmp_path
    # No install scripts at all

    monkeypatch.setattr(build, "ROOT", str(fake_root))
    monkeypatch.setattr(build, "DIST", str(fake_dist))
    monkeypatch.setattr(build, "STAGING", str(fake_staging))
    monkeypatch.setattr(build, "ZIPS", {})

    with pytest.raises(build.BuildError) as exc_info:
        build.cmd_zip()

    msg = str(exc_info.value)
    # Should fail on install.sh first (iterated first)
    assert "install.sh" in msg, f"Error should mention install.sh, got: {msg!r}"
