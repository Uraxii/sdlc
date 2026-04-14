#!/usr/bin/env python3
"""Build SDLC release zip assets."""

import argparse
import glob
import hashlib
import json
import os
import shutil
import subprocess
import sys
import zipfile
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path


class BuildError(Exception):
    """Fatal build error — halts the pipeline."""


ROOT = os.path.dirname(os.path.abspath(__file__))
DIST = os.path.join(ROOT, "dist")
STAGING = os.path.join(ROOT, "dist", "staging")

# Each entry is (prefix, source_glob, arc_base).
# source_glob is relative to ROOT. arc_base is the filesystem root to strip
# when computing in-zip paths.
ZIPS = {
    "sdlc-claude-code": [
        ("agents/",          "dist/staging/agents/*.md",                STAGING),
        ("skills/",          "dist/staging/skills/claude-code/**/*.md", STAGING),
        ("templates/",       "dist/staging/templates/*.md",             STAGING),
        ("",                 "dist/staging/core-memory.md",             STAGING),
        ("",                 "dist/staging/CLAUDE.md",                  STAGING),
        ("hooks/",           "hooks/install.sh",                        ROOT),
        ("hooks/",           "hooks/install.ps1",                       ROOT),
        ("hooks/",           "hooks/session-start.js",                  ROOT),
        (".claude-plugin/",  ".claude-plugin/plugin.json",              ROOT),
    ],
    "sdlc-copilot": [
        ("",  ".github/copilot-instructions.md",              ROOT),
        ("",  "dist/staging/skills/copilot/**/*.md",          STAGING),
        ("",  "dist/staging/extensions/sdlc/extension.mjs",   STAGING),
        ("",  "hooks/copilot/install.sh",                     ROOT),
        ("",  "hooks/copilot/install.ps1",                    ROOT),
    ],
}


# ---------- Helpers ----------


def is_original(path):
    return path.endswith(".original.md")


def resolve(pattern, arc_base):
    """Expand a glob pattern relative to ROOT. Return sorted list of abs paths."""
    if any(c in pattern for c in ("*", "?")):
        full = os.path.join(ROOT, pattern)
        return sorted(
            p for p in glob.glob(full, recursive=True)
            if os.path.isfile(p) and not is_original(p)
        )
    path = os.path.join(ROOT, pattern)
    if os.path.isfile(path) and not is_original(path):
        return [path]
    return []


def arcname(prefix, abs_path, arc_base):
    """Derive the in-zip path for a file."""
    if prefix:
        # Anchor: arc_base + prefix dir. Strip that, then prepend prefix.
        anchor = os.path.join(arc_base, prefix.rstrip("/"))
        rel = os.path.relpath(abs_path, anchor)
        return os.path.join(prefix.rstrip("/"), rel)
    # No prefix: path relative to arc_base is the full arc path.
    return os.path.relpath(abs_path, arc_base)


CACHE_FILE = os.path.join(DIST, ".compress-cache.json")


def _file_hash(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _load_cache() -> dict:
    try:
        return json.loads(Path(CACHE_FILE).read_text())
    except (FileNotFoundError, json.JSONDecodeError):
        return {}


def _save_cache(cache: dict):
    Path(CACHE_FILE).parent.mkdir(parents=True, exist_ok=True)
    Path(CACHE_FILE).write_text(json.dumps(cache, indent=2))


# ---------- Compression ----------


def _caveman_dir() -> str:
    d = os.environ.get("CAVEMAN_COMPRESS_DIR", "").strip()
    if not d:
        raise BuildError(
            "CAVEMAN_COMPRESS_DIR not set. "
            "Point it at the caveman-compress/ directory (contains scripts/)."
        )
    if not os.path.isdir(d):
        raise BuildError(f"CAVEMAN_COMPRESS_DIR not found: {d!r}")
    if not os.path.isfile(os.path.join(d, "scripts", "compress.py")):
        raise BuildError(f"CAVEMAN_COMPRESS_DIR misconfigured — scripts/compress.py missing in {d!r}")
    return d


def compress_to_staging(src: Path, dst: Path) -> None:
    """Compress src → dst via subprocess.

    Copies src to dst, runs caveman compress on it
    (isolated subprocess, no shared context), removes the backup caveman creates.
    """
    staging_path = dst
    dst.parent.mkdir(parents=True, exist_ok=True)

    # Copy source → staging as target filename so caveman writes the right name
    shutil.copy2(src, staging_path)

    print(f"  Compressing {src.name} → {staging_path.relative_to(ROOT)}")

    result = subprocess.run(
        ["python3", "-m", "scripts", str(staging_path)],
        cwd=_caveman_dir(),
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        staging_path.unlink(missing_ok=True)
        raise BuildError(f"Compression failed for {src.name}:\n{result.stderr.strip()}")

    # Remove the .original.md backup caveman creates alongside the compressed file
    backup = staging_path.with_name(staging_path.stem + ".original.md")
    if backup.exists():
        backup.unlink()


def _compress_skills(cache: dict):
    """Compress skills/**/*.md → dist/staging/skills/<relative-path>."""
    skills_src = Path(ROOT, "skills")
    staging_skills = Path(STAGING, "skills")
    if not skills_src.exists():
        return
    to_compress = []
    for src in sorted(skills_src.rglob("*.md")):
        h = _file_hash(src)
        rel = src.relative_to(skills_src)
        dst = staging_skills / rel
        if cache.get(str(src)) == h and dst.exists():
            print(f"  Cached   skills/{rel} (unchanged)")
        else:
            to_compress.append((src, dst, h))
    if not to_compress:
        print("All skill files up to date (cache hit).")
    else:
        print(f"Compressing {len(to_compress)} skill file(s)...")
        errors = []
        with ThreadPoolExecutor(max_workers=min(8, max(1, len(to_compress)))) as pool:
            futures = {
                pool.submit(compress_to_staging, src, dst): (src, dst, h)
                for src, dst, h in to_compress
            }
            for future in as_completed(futures):
                src, dst, h = futures[future]
                try:
                    future.result()
                    cache[str(src)] = h
                except BuildError as exc:
                    errors.append(str(exc))
        if errors:
            raise BuildError("\n".join(errors))


# ---------- Subcommands ----------


def cmd_compress():
    """Compress agents/*.original.md + skills/**/*.md → dist/staging/.
    Also copies verbatim files (templates, core-memory.md, CLAUDE.md) to staging.
    """
    staging_agents = Path(STAGING) / "agents"
    staging_agents.mkdir(parents=True, exist_ok=True)

    originals = sorted(Path(ROOT, "agents").glob("*.original.md"))
    if not originals:
        raise BuildError("No agents/*.original.md files found.")

    cache = _load_cache()
    to_compress = []
    for src in originals:
        h = _file_hash(src)
        dst = staging_agents / (src.stem.removesuffix(".original") + ".md")
        if cache.get(str(src)) == h and dst.exists():
            print(f"  Cached   {src.name} (unchanged)")
        else:
            to_compress.append((src, dst, h))

    if not to_compress:
        print("All agent files up to date (cache hit).")
    else:
        print(f"Compressing {len(to_compress)} agent file(s) in parallel...")
        errors = []
        with ThreadPoolExecutor(max_workers=len(to_compress)) as pool:
            futures = {
                pool.submit(compress_to_staging, src, dst): (src, dst, h)
                for src, dst, h in to_compress
            }
            for future in as_completed(futures):
                src, dst, h = futures[future]
                try:
                    future.result()
                    cache[str(src)] = h
                except BuildError as exc:
                    errors.append(str(exc))
        if errors:
            raise BuildError("\n".join(errors))

    # Compress skills
    _compress_skills(cache)

    _save_cache(cache)

    # Copy verbatim: templates, core-memory.md, CLAUDE.md
    _copy_verbatim(
        Path(ROOT, "templates"),
        Path(STAGING, "templates"),
    )
    for name in ("core-memory.md", "CLAUDE.md"):
        src = Path(ROOT, name)
        if src.exists():
            dst = Path(STAGING, name)
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)
            print(f"  Copied {name} → dist/staging/{name}")

    _embed_agents_in_extension()

    print(f"\nStaging complete → {STAGING}/")


def _embed_agents_in_extension():
    """Read compressed agents from staging, embed into extension.mjs via placeholder replacement."""
    staging_agents = Path(STAGING) / "agents"
    agent_files = sorted(staging_agents.glob("*.md"))
    if not agent_files:
        raise BuildError("No agent .md files in dist/staging/agents/ -- run compress first.")

    agent_dict = {}
    for f in agent_files:
        agent_dict[f.stem] = f.read_text(encoding="utf-8")

    src = Path(ROOT, "hooks", "copilot", "extensions", "sdlc", "extension.mjs")
    if not src.exists():
        raise BuildError(f"Extension source not found: {src}")

    content = src.read_text(encoding="utf-8")
    replacement = json.dumps(agent_dict)
    content = content.replace('"__AGENTS_PLACEHOLDER__"', replacement)

    out_dir = Path(STAGING, "extensions", "sdlc")
    out_dir.mkdir(parents=True, exist_ok=True)
    out = out_dir / "extension.mjs"
    out.write_text(content, encoding="utf-8")
    print(f"  Embedded {len(agent_dict)} agents into {out.relative_to(ROOT)}")


def _copy_verbatim(src_dir: Path, dst_dir: Path):
    """Recursively copy src_dir into dst_dir (verbatim, no compression).
    Skips .original.md files — those are source-only artifacts.
    """
    if not src_dir.exists():
        return
    dst_dir.mkdir(parents=True, exist_ok=True)
    for item in src_dir.rglob("*"):
        if item.is_file() and not item.name.endswith(".original.md"):
            rel = item.relative_to(src_dir)
            dst = dst_dir / rel
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(item, dst)
            print(f"  Copied {item.relative_to(Path(ROOT))} → {dst.relative_to(Path(ROOT))}")


def cmd_zip(names=None):
    """Package dist/staging/ → dist/*.zip."""
    staging_agents = Path(STAGING) / "agents"
    if not staging_agents.exists() or not any(staging_agents.glob("*.md")):
        raise BuildError(
            "dist/staging/agents/ is absent or empty — run 'build.py compress' first."
        )

    os.makedirs(DIST, exist_ok=True)
    targets = {k: v for k, v in ZIPS.items() if not names or k in names}

    for name, entries in targets.items():
        out = os.path.join(DIST, f"{name}.zip")
        with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zf:
            for prefix, pattern, arc_base in entries:
                for abs_path in resolve(pattern, arc_base):
                    arc = arcname(prefix, abs_path, arc_base)
                    zf.write(abs_path, arc)
                    print(f"  {arc}")
        size = os.path.getsize(out)
        print(f"{name}.zip  ({size // 1024}K)")

    print(f"\nBuilt {len(targets)} zip(s) → {DIST}/")


def cmd_all():
    """Run compress then zip."""
    cmd_compress()
    print()
    cmd_zip()


# ---------- Entry point ----------


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Build SDLC release zips")
    sub = parser.add_subparsers(dest="cmd")

    sub.add_parser("compress", help="Compress agent files → dist/staging/")

    zip_p = sub.add_parser("zip", help="Package dist/staging/ → dist/*.zip")
    zip_p.add_argument("zips", nargs="*", help="Zip names to build (default: all)")

    sub.add_parser("all", help="compress then zip (default)")

    args = parser.parse_args()

    try:
        if args.cmd == "compress":
            cmd_compress()
        elif args.cmd == "zip":
            cmd_zip(args.zips or None)
        elif args.cmd == "all" or args.cmd is None:
            cmd_all()
        else:
            parser.print_help()
            sys.exit(1)
    except BuildError as e:
        print(f"\nBUILD ERROR: {e}", file=sys.stderr)
        sys.exit(1)
