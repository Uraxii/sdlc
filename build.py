#!/usr/bin/env python3
"""Build SDLC release zip assets."""

import argparse
import glob
import os
import zipfile

ROOT = os.path.dirname(os.path.abspath(__file__))
DIST = os.path.join(ROOT, "dist")

# Each entry is (archive_path, source_glob_or_path)
# Globs are relative to ROOT. Literal paths (no wildcards) are included as-is.
ZIPS = {
    "sdlc-claude-code": [
        ("agents/",          "agents/*.md"),
        ("skills/",          "skills/sdlc/**/*.md"),
        ("templates/",       "templates/*.md"),
        ("",                 "core-memory.md"),
        ("",                 "CLAUDE.md"),
        ("hooks/",           "hooks/install.sh"),
        ("hooks/",           "hooks/install.ps1"),
        ("hooks/",           "hooks/session-start.js"),
        (".claude-plugin/",  ".claude-plugin/plugin.json"),
    ],
    "sdlc-copilot": [
        ("",                 ".github/copilot-instructions.md"),
        ("",                 ".github/copilot/sdlc.prompt.md"),
        ("",                 "hooks/copilot/install.sh"),
        ("",                 "hooks/copilot/install.ps1"),
    ],
    "sdlc-cursor": [
        ("",                 ".cursor/rules/sdlc.mdc"),
        ("",                 ".cursor/skills/sdlc/SKILL.md"),
        ("",                 "hooks/cursor/install.sh"),
        ("",                 "hooks/cursor/install.ps1"),
    ],
    "sdlc-windsurf": [
        ("",                 ".windsurf/rules/sdlc.md"),
        ("",                 ".windsurf/skills/sdlc/SKILL.md"),
        ("",                 "hooks/windsurf/install.sh"),
        ("",                 "hooks/windsurf/install.ps1"),
    ],
    "sdlc-cline": [
        ("",                 ".clinerules/sdlc.md"),
        ("",                 "hooks/cline/install.sh"),
        ("",                 "hooks/cline/install.ps1"),
    ],
    "sdlc-codex": [
        ("",                 "AGENTS.md"),
        ("",                 "hooks/codex/install.sh"),
        ("",                 "hooks/codex/install.ps1"),
    ],
}


def is_original(path):
    return path.endswith(".original.md")


def resolve(pattern):
    """Expand a glob pattern relative to ROOT. Return sorted list of abs paths."""
    if any(c in pattern for c in ("*", "?")):
        return sorted(
            p for p in glob.glob(os.path.join(ROOT, pattern), recursive=True)
            if os.path.isfile(p) and not is_original(p)
        )
    path = os.path.join(ROOT, pattern)
    if os.path.isfile(path) and not is_original(path):
        return [path]
    return []


def arcname(prefix, abs_path, pattern):
    """Derive the in-zip path for a file."""
    if prefix:
        # Keep directory structure relative to the prefix anchor
        rel = os.path.relpath(abs_path, os.path.join(ROOT, prefix.rstrip("/")))
        return os.path.join(prefix.rstrip("/"), rel)
    # No prefix: use the path relative to ROOT
    return os.path.relpath(abs_path, ROOT)


def build(names=None):
    os.makedirs(DIST, exist_ok=True)
    targets = {k: v for k, v in ZIPS.items() if not names or k in names}

    for name, entries in targets.items():
        out = os.path.join(DIST, f"{name}.zip")
        with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zf:
            for prefix, pattern in entries:
                for abs_path in resolve(pattern):
                    arc = arcname(prefix, abs_path, pattern)
                    zf.write(abs_path, arc)
                    print(f"  {arc}")
        size = os.path.getsize(out)
        print(f"{name}.zip  ({size // 1024}K)")

    print(f"\nBuilt {len(targets)} zip(s) → {DIST}/")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Build SDLC release zips")
    parser.add_argument("zips", nargs="*", help="Zip names to build (default: all)")
    args = parser.parse_args()
    build(args.zips or None)
