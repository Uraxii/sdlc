#!/usr/bin/env bash
# SDLC universal installer
# Usage (from your project root):
#   bash -s -- <ide> < <(curl -fsSL https://github.com/Uraxii/sdlc/releases/latest/download/install.sh)
#
# <ide>: claude-code | copilot | cursor | windsurf | cline | codex

set -e

REPO="Uraxii/sdlc"
BASE_URL="https://github.com/$REPO/releases/latest/download"
VALID_IDES=(claude-code copilot cursor windsurf cline codex)

usage() {
  echo "Usage: bash install.sh <ide>"
  echo "IDEs:  ${VALID_IDES[*]}"
  exit 1
}

IDE="${1:-}"
[ -z "$IDE" ] && { echo "Error: IDE argument required."; usage; }

valid=false
for i in "${VALID_IDES[@]}"; do [ "$i" = "$IDE" ] && valid=true && break; done
$valid || { echo "Unknown IDE: $IDE"; usage; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

ZIP="sdlc-${IDE}.zip"
echo "Downloading $ZIP..."
curl -fsSL "$BASE_URL/$ZIP" -o "$TMP/$ZIP"

echo "Extracting..."
unzip -q "$TMP/$ZIP" -d "$TMP/sdlc"

echo "Installing..."
if [ "$IDE" = "claude-code" ]; then
  bash "$TMP/sdlc/hooks/install.sh"
else
  bash "$TMP/sdlc/install.sh"
fi
