#!/usr/bin/env bash
# SDLC installer
#
# Interactive:
#   bash <(curl -fsSL https://github.com/Uraxii/sdlc/releases/latest/download/install.sh)
#
# Skip prompt with a flag:
#   bash <(curl -fsSL https://...install.sh) --copilot
#
# Flags: --claude-code  --copilot

set -e

REPO="Uraxii/sdlc"
BASE_URL="https://github.com/$REPO/releases/latest/download"
IDES=(claude-code copilot)

IDE=""
for arg in "$@"; do
  case "$arg" in
    --claude-code) IDE="claude-code" ;;
    --copilot)     IDE="copilot"     ;;
    *) echo "Unknown flag: $arg"; echo "Flags: --claude-code --copilot"; exit 1 ;;
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
    if [[ "$choice" =~ ^[1-2]$ ]]; then
      IDE="${IDES[$((choice-1))]}"
      break
    fi
    echo "Enter a number 1–2."
  done
fi

STAGING=".sdlc-install"
trap 'rm -rf "$STAGING"' EXIT

ZIP="sdlc-${IDE}.zip"
echo "Downloading $ZIP..."
curl -fsSL "$BASE_URL/$ZIP" -o "$ZIP"

echo "Extracting..."
if command -v unzip >/dev/null 2>&1; then
  unzip -q "$ZIP" -d "$STAGING"
elif command -v python3 >/dev/null 2>&1; then
  python3 -c "import zipfile,sys; zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])" "$ZIP" "$STAGING"
else
  echo "ERROR: neither 'unzip' nor 'python3' found. Install one and re-run."
  exit 1
fi
rm "$ZIP"

echo "Installing ($IDE)..."
if [ "$IDE" = "claude-code" ]; then
  bash "$STAGING/hooks/install.sh"
else
  bash "$STAGING/hooks/$IDE/install.sh"
fi

SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
if [ -f "$SCRIPT_PATH" ] && [[ "$SCRIPT_PATH" != /dev/* ]]; then
  printf "Delete install script (%s)? [y/N] " "$SCRIPT_PATH"
  read -r ans </dev/tty
  case "$ans" in
    [yY]*) rm "$SCRIPT_PATH"; echo "Deleted." ;;
    *)     echo "Kept." ;;
  esac
fi
