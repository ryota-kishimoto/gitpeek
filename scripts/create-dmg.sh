#!/bin/bash
# Create a polished DMG installer for GitPeek
# Usage: ./scripts/create-dmg.sh <app_path> <output_dmg_name>

set -e

APP_PATH="${1:-GitPeek.app}"
DMG_NAME="${2:-GitPeek.dmg}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

BG_IMAGE="$PROJECT_DIR/Resources/dmg-background.png"

if [ ! -d "$APP_PATH" ]; then
    echo "Error: $APP_PATH not found"
    exit 1
fi

echo "Creating DMG: $DMG_NAME"
rm -f "$DMG_NAME"

set +e
create-dmg \
    --volname "GitPeek" \
    --window-pos 200 120 \
    --window-size 600 400 \
    --icon-size 100 \
    --icon "GitPeek.app" 175 190 \
    --hide-extension "GitPeek.app" \
    --app-drop-link 425 190 \
    --background "$BG_IMAGE" \
    --text-size 12 \
    --no-internet-enable \
    "$DMG_NAME" \
    "$APP_PATH"
EXIT_CODE=$?
set -e

# create-dmg exits with 2 when DMG is created but codesigning fails (expected without cert)
if [ $EXIT_CODE -ne 0 ] && [ $EXIT_CODE -ne 2 ]; then
    echo "create-dmg failed with exit code $EXIT_CODE"
    exit 1
fi

echo "DMG created: $DMG_NAME"
