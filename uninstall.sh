#!/bin/bash

# ⚠️ If you see "permission denied", run:
# chmod +x uninstall.sh

echo "🧹 Starting AVNightwatch uninstallation..."

# === Uninstall Ableton Live Project ===

LIVE_PROJECT_NAME="RDN_Liveset"
MUSIC_ROOT="$HOME/Music/Ableton"
PRIMARY_PROJECT_PATH="$MUSIC_ROOT/$LIVE_PROJECT_NAME"
FALLBACK_PROJECT_PATH="$MUSIC_ROOT/Projects Folder/$LIVE_PROJECT_NAME"

if [ -d "$PRIMARY_PROJECT_PATH" ]; then
    EXISTING_LIVE_PROJECT="$PRIMARY_PROJECT_PATH"
elif [ -d "$FALLBACK_PROJECT_PATH" ]; then
    EXISTING_LIVE_PROJECT="$FALLBACK_PROJECT_PATH"
else
    EXISTING_LIVE_PROJECT=""
fi

if [ -n "$EXISTING_LIVE_PROJECT" ]; then
    echo "⚠️ Ableton Live project '$LIVE_PROJECT_NAME' found at:"
    echo "   $EXISTING_LIVE_PROJECT"
    echo "❓ Do you want to delete it?"
    echo "  [y] Yes"
    echo "  [n] No"
    read -rp "Enter your choice (y/n): " DELETE_LIVE

    case "$DELETE_LIVE" in
        y|Y)
            rm -rf "$EXISTING_LIVE_PROJECT"
            echo "✅ Deleted Ableton Live project."
            ;;
        *)
            echo "⏭️ Skipped deleting Ableton Live project."
            ;;
    esac
else
    echo "ℹ️ Ableton Live project not found in expected locations."
fi

echo "🧼 AVNightwatch uninstallation complete."
