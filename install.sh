#!/bin/bash

# ⚠️ If you see "permission denied", run:
# chmod +x install.sh

echo "📦 Starting AVNightwatch installation..."

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script only works on macOS."
    exit 1
fi

# Check for Ableton Live 11 or 12
LIVE_11_PATH="/Applications/Ableton Live 11 Suite.app"
LIVE_12_PATH="/Applications/Ableton Live 12 Suite.app"
LIVE_PATH=""

if [ -d "$LIVE_12_PATH" ]; then
    LIVE_PATH="$LIVE_12_PATH"
    echo "✅ Ableton Live 12 found."
elif [ -d "$LIVE_11_PATH" ]; then
    LIVE_PATH="$LIVE_11_PATH"
    echo "✅ Ableton Live 11 found."
    
    # Check Live 11 version
    LIVE_VERSION=$(defaults read "$LIVE_PATH/Contents/Info.plist" CFBundleShortVersionString)
    echo "📊 Checking Ableton Live version: $LIVE_VERSION"
    
    # Compare versions
    if [ "$(printf '%s\n' "11.3.41" "$LIVE_VERSION" | sort -V | head -n1)" != "11.3.41" ]; then
        echo "❌ Ableton Live version $LIVE_VERSION is too old. Please update to version 11.3.41 or newer."
        exit 1
    else
        echo "✅ Ableton Live version $LIVE_VERSION is compatible."
    fi
else
    echo "❌ Neither Ableton Live 11 nor 12 found at /Applications."
    exit 1
fi

# Check for Max 8 (standalone or bundled)
MAX_STANDALONE="/Applications/Max.app"
MAX_BUNDLED="$LIVE_PATH/Contents/App-Resources/Max"
MAX_FOUND=false

if [ -d "$MAX_STANDALONE" ]; then
    MAX_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$MAX_STANDALONE/Contents/Info.plist")
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
DEFAULT_MAX_USER_FOLDER="$HOME/Music/Max 8"
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

# Check for npm and Node.js
echo "🔍 Checking for npm and Node.js..."
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed or not in your PATH."
    echo "👉 Please install Node.js (which includes npm) from:"
    echo "   https://nodejs.org/"
    exit 1
fi

if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed or not in your PATH."
    echo "👉 Please install Node.js from:"
    echo "   https://nodejs.org/"
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v)
if [[ "$NODE_VERSION" =~ ^v([0-9]+)\. ]]; then
    MAJOR_VERSION=${BASH_REMATCH[1]}
    if [ "$MAJOR_VERSION" -lt 14 ]; then
        echo "❌ Node.js version $NODE_VERSION is too old. Please update to version 14 or newer."
        exit 1
    fi
    echo "✅ Node.js version $NODE_VERSION is compatible."
else
    echo "❌ Could not determine Node.js version."
    exit 1
fi

# Save the original directory
ORIGINAL_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$DEST_PROJECT_PATH"/node_content/ && npm install socket.io-client

# Return to original directory
cd "$ORIGINAL_DIR"

# === Install Ableton Live Project ===

LIVE_PROJECT_NAME="RDN_Liveset"
MUSIC_ROOT="$HOME/Music/Ableton"
DEST_PROJECT_PATH="$MUSIC_ROOT/$LIVE_PROJECT_NAME"
SOURCE_PROJECT_PATH="$ORIGINAL_DIR/$LIVE_PROJECT_NAME"

# If it already exists, prompt before overwriting
if [ -d "$DEST_PROJECT_PATH" ]; then
    echo "⚠️ Ableton Live project '$LIVE_PROJECT_NAME' already exists at:"
    echo "   $DEST_PROJECT_PATH"
    echo "❓ What would you like to do?"
    echo "  [o] Overwrite it"
    echo "  [s] Skip copying"
    echo "  [c] Cancel installation"
    read -rp "Enter your choice (o/s/c): " USER_CHOICE

    case "$USER_CHOICE" in
        o|O)
            echo "🗑️ Removing existing project folder..."
            rm -rf "$DEST_PROJECT_PATH"
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

# Copy the project
if [ -d "$SOURCE_PROJECT_PATH" ]; then
    echo "📦 Copying '$LIVE_PROJECT_NAME' to: $MUSIC_ROOT"
    # Handle possible nested RDN_Liveset folder
    NESTED_PATH="$SOURCE_PROJECT_PATH/$LIVE_PROJECT_NAME"

    if [ -d "$NESTED_PATH" ]; then
        echo "📦 Detected nested RDN_Liveset. Copying inner folder instead..."
        cp -R "$NESTED_PATH" "$DEST_PROJECT_PATH"
    else
        echo "📦 Copying '$LIVE_PROJECT_NAME' to: $MUSIC_ROOT"
        cp -R "$SOURCE_PROJECT_PATH" "$DEST_PROJECT_PATH"
    fi
    echo "✅ Live project installed at: $DEST_PROJECT_PATH"
else
    echo "❌ Source Live project folder not found at: $SOURCE_PROJECT_PATH"
    exit 1
fi

echo "🎉 AVNightwatch installation complete."
