#!/usr/bin/env bash
# SDLC installer
#
# Interactive:
#   bash <(curl -fsSL https://github.com/Uraxii/sdlc/releases/latest/download/install.sh)
#
# Skip prompt with a flag:
#   bash <(curl -fsSL https://...install.sh) --cursor
#
# Flags: --claude-code  --copilot  --cursor  --windsurf  --cline  --codex

set -e

REPO="Uraxii/sdlc"
BASE_URL="https://github.com/$REPO/releases/latest/download"
IDES=(claude-code copilot cursor windsurf cline codex)

IDE=""
for arg in "$@"; do
  case "$arg" in
    --claude-code) IDE="claude-code" ;;
    --copilot)     IDE="copilot"     ;;
    --cursor)      IDE="cursor"      ;;
    --windsurf)    IDE="windsurf"    ;;
    --cline)       IDE="cline"       ;;
    --codex)       IDE="codex"       ;;
    *) echo "Unknown flag: $arg"; echo "Flags: --claude-code --copilot --cursor --windsurf --cline --codex"; exit 1 ;;
  esac
done

if [ -z "$IDE" ]; then
  echo "Select your IDE:"
  i=1
  for ide in "${IDES[@]}"; do
    echo "  $i) $ide"
    ((i++))
  done
  while true; do
    printf "> "
    read -r choice </dev/tty
    if [[ "$choice" =~ ^[1-6]$ ]]; then
      IDE="${IDES[$((choice-1))]}"
      break
    fi
    echo "Enter a number 1–6."
  done
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

ZIP="sdlc-${IDE}.zip"
echo "Downloading $ZIP..."
curl -fsSL "$BASE_URL/$ZIP" -o "$TMP/$ZIP"

echo "Extracting..."
if command -v unzip >/dev/null 2>&1; then
  unzip -q "$TMP/$ZIP" -d "$TMP/sdlc"
elif command -v python3 >/dev/null 2>&1; then
  python3 -c "import zipfile,sys; zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])" "$TMP/$ZIP" "$TMP/sdlc"
else
  echo "ERROR: neither 'unzip' nor 'python3' found. Install one and re-run."
  exit 1
fi

echo "Installing ($IDE)..."
if [ "$IDE" = "claude-code" ]; then
  bash "$TMP/sdlc/hooks/install.sh"
else
  bash "$TMP/sdlc/install.sh"
fi
