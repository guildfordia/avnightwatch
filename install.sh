#!/bin/bash

# ⚠️ If you see "permission denied", run:
# chmod +x install.sh

echo "📦 Starting AVNightwatch installation..."

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script only works on macOS."
    exit 1
fi

# Check for Ableton Live 11
LIVE_PATH="/Applications/Ableton Live 11 Suite.app"
if [ -d "$LIVE_PATH" ]; then
    echo "✅ Ableton Live 11 found."
else
    echo "❌ Ableton Live 11 not found at /Applications."
    exit 1
fi

# Check for Max 8 (standalone or bundled)
MAX_STANDALONE="/Applications/Max.app"
MAX_BUNDLED="$LIVE_PATH/Contents/App-Resources/Max"
MAX_FOUND=false

if [ -d "$MAX_STANDALONE" ]; then
    MAX_VERSION=$("$MAX_STANDALONE/Contents/MacOS/Max" -v | grep -o 'Version.*')
    if echo "$MAX_VERSION" | grep -q "Version 8"; then
        echo "✅ Max 8 (standalone) found."
        MAX_FOUND=true
    fi
fi

if [ -d "$MAX_BUNDLED" ]; then
    echo "✅ Max bundled with Ableton Live found."
    MAX_FOUND=true
fi

if [ "$MAX_FOUND" = false ]; then
    echo "❌ Max 8 not found (neither standalone nor bundled)."
    exit 1
fi

# Assume Max for Live is available if Live 11 and Max are found
echo "✅ Ableton Live and Max found — assuming Max for Live is available."

# Locate Max 8 user folder or prompt
DEFAULT_MAX_USER_FOLDER="$HOME/Documents/Max 8"
if [ -d "$DEFAULT_MAX_USER_FOLDER" ]; then
    MAX_USER_FOLDER="$DEFAULT_MAX_USER_FOLDER"
    echo "📁 Max 8 user folder found: $MAX_USER_FOLDER"
else
    echo "⚠️ Max 8 folder not found at: $DEFAULT_MAX_USER_FOLDER"
    echo "👉 Enter your Max 8 user folder path manually:"
    read -r MAX_USER_FOLDER
    if [ ! -d "$MAX_USER_FOLDER" ]; then
        echo "❌ Invalid path. Aborting."
        exit 1
    fi
fi

# Define source and destination paths
PROJECT_NAME="RDN_Orchestrator_2.1 Project"
SOURCE_PROJECT_PATH="$(cd "$(dirname "$0")/$PROJECT_NAME" && pwd)"
M4L_DEVICES_PATH="$MAX_USER_FOLDER/Max For Live Devices"
DEST_PROJECT_PATH="$M4L_DEVICES_PATH/$PROJECT_NAME"

# Ensure destination folder exists
mkdir -p "$M4L_DEVICES_PATH"

# Confirm source folder exists
if [ ! -d "$SOURCE_PROJECT_PATH" ]; then
    echo "❌ Project folder not found: $SOURCE_PROJECT_PATH"
    exit 1
fi

# Check if the destination folder already exists
if [ -d "$DEST_PROJECT_PATH" ]; then
    echo "⚠️ The folder '$DEST_PROJECT_PATH' already exists."
    echo "❓ What would you like to do?"
    echo "  [o] Overwrite it"
    echo "  [s] Skip copying"
    echo "  [c] Cancel installation"
    read -rp "Enter your choice (o/s/c): " USER_CHOICE

    case "$USER_CHOICE" in
        o|O)
            echo "🗑️ Removing existing folder..."
            rm -rf "$DEST_PROJECT_PATH"
            echo "📦 Copying project..."
            cp -R "$SOURCE_PROJECT_PATH" "$DEST_PROJECT_PATH"
            echo "✅ Overwritten and installed."
            ;;
        s|S)
            echo "⏭️ Skipping copy step."
            ;;
        c|C)
            echo "❌ Installation canceled by user."
            exit 1
            ;;
        *)
            echo "❌ Invalid choice. Aborting."
            exit 1
            ;;
    esac
else
    echo "📦 Copying '$PROJECT_NAME' to: $DEST_PROJECT_PATH"
    cp -R "$SOURCE_PROJECT_PATH" "$DEST_PROJECT_PATH"
    echo "✅ Project copied."
fi

# === Install Ableton Live Project ===

LIVE_PROJECT_NAME="RDN_Liveset"
MUSIC_ROOT="$HOME/Music/Ableton"
PRIMARY_PROJECT_PATH="$MUSIC_ROOT/$LIVE_PROJECT_NAME"
FALLBACK_PROJECTS_FOLDER="$MUSIC_ROOT/Projects Folder"
FALLBACK_PROJECT_PATH="$FALLBACK_PROJECTS_FOLDER/$LIVE_PROJECT_NAME"
SOURCE_PROJECT_PATH="$(cd "$(dirname "$0")/$LIVE_PROJECT_NAME" && pwd)"

# Determine where the project currently exists (if anywhere)
if [ -d "$PRIMARY_PROJECT_PATH" ]; then
    EXISTING_PROJECT_PATH="$PRIMARY_PROJECT_PATH"
elif [ -d "$FALLBACK_PROJECT_PATH" ]; then
    EXISTING_PROJECT_PATH="$FALLBACK_PROJECT_PATH"
else
    EXISTING_PROJECT_PATH=""
fi

# If it already exists, prompt before overwriting
if [ -n "$EXISTING_PROJECT_PATH" ]; then
    echo "⚠️ Ableton Live project '$LIVE_PROJECT_NAME' already exists at:"
    echo "   $EXISTING_PROJECT_PATH"
    echo "❓ What would you like to do?"
    echo "  [o] Overwrite it"
    echo "  [s] Skip copying"
    echo "  [c] Cancel installation"
    read -rp "Enter your choice (o/s/c): " USER_CHOICE

    case "$USER_CHOICE" in
        o|O)
            echo "🗑️ Removing existing project folder..."
            rm -rf "$EXISTING_PROJECT_PATH"
            ;;
        s|S)
            echo "⏭️ Skipping project copy step."
            ;;
        c|C)
            echo "❌ Installation canceled by user."
            exit 1
            ;;
        *)
            echo "❌ Invalid choice. Aborting."
            exit 1
            ;;
    esac
fi

# If 'Projects Folder' doesn't exist, create it
if [ ! -d "$FALLBACK_PROJECTS_FOLDER" ]; then
    echo "📂 Creating 'Projects Folder' at: $FALLBACK_PROJECTS_FOLDER"
    mkdir -p "$FALLBACK_PROJECTS_FOLDER"
fi

# Copy the project
if [ -d "$SOURCE_PROJECT_PATH" ]; then
    echo "📦 Copying '$LIVE_PROJECT_NAME' to: $FALLBACK_PROJECTS_FOLDER"
    # Handle possible nested RDN_Liveset folder
    NESTED_PATH="$SOURCE_PROJECT_PATH/$LIVE_PROJECT_NAME"

    if [ -d "$NESTED_PATH" ]; then
        echo "📦 Detected nested RDN_Liveset. Copying inner folder instead..."
        cp -R "$NESTED_PATH" "$FALLBACK_PROJECT_PATH"
    else
        echo "📦 Copying '$LIVE_PROJECT_NAME' to: $FALLBACK_PROJECTS_FOLDER"
        cp -R "$SOURCE_PROJECT_PATH" "$FALLBACK_PROJECT_PATH"
    fi
    echo "✅ Live project installed at: $FALLBACK_PROJECT_PATH"
else
    echo "❌ Source Live project folder not found at: $SOURCE_PROJECT_PATH"
    exit 1
fi

echo "🎉 AVNightwatch installation complete."
