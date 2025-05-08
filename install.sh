#!/bin/bash

# ⚠️ If you see "permission denied", run:
# chmod +x install.sh

echo "📦 Starting AVNightwatch installation..."

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script only works on macOS."
    exit 1
fi

# Function to validate and prompt for directory
validate_and_prompt_dir() {
    local default_path="$1"
    local prompt_message="$2"
    local env_var_name="$3"
    local dir_path

    if [ -d "$default_path" ]; then
        dir_path="$default_path"
        echo "✅ Found directory: $dir_path" >&2  # Redirect to stderr
    else
        echo "⚠️ Directory not found at: $default_path" >&2
        echo "👉 $prompt_message" >&2
        read -r dir_path
        while [ ! -d "$dir_path" ]; do
            echo "❌ Invalid directory. Please enter a valid path:" >&2
            read -r dir_path
        done
    fi

    # For ABLETON_PROJECTS_DIR, ensure we use the correct path
    if [ "$env_var_name" = "ABLETON_PROJECTS_DIR" ]; then
        # If the path ends with RDN_Liveset, remove it
        if [[ "$dir_path" == */RDN_Liveset ]]; then
            dir_path="${dir_path%/RDN_Liveset}"
        fi
        echo "📁 Using Ableton projects directory: $dir_path" >&2
    fi

    # Add to .env file
    if [ ! -f ".env" ]; then
        echo "# AVNightwatch Environment Variables" > .env
        echo "# Created by install.sh" >> .env
        echo "" >> .env
        # Add default WEBSOCKET_URL
        echo "WEBSOCKET_URL=http://127.0.0.1:6000" >> .env
        echo "" >> .env
    fi
    
    # Remove any existing line with this variable
    sed -i '' "/^$env_var_name=/d" .env
    
    # Add the new variable
    echo "$env_var_name=\"$dir_path\"" >> .env
    
    echo "✅ Saved path to .env file" >&2
    
    # Return just the path, no messages
    echo "$dir_path"
}

# Validate and get Ableton Live project directory
ABLETON_PROJECT_DIR=$(validate_and_prompt_dir \
    "$HOME/Music/Ableton" \
    "Enter your Ableton Live projects directory path:" \
    "ABLETON_PROJECTS_DIR")

# Validate and get Max for Live devices directory
MAX_DEVICES_DIR=$(validate_and_prompt_dir \
    "$HOME/Music/Max 8/Max For Live Devices" \
    "Enter your Max for Live devices directory path:" \
    "MAX_DEVICES_DIR")

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
DEST_PROJECT_PATH="$MAX_DEVICES_DIR/$PROJECT_NAME"

# Ensure destination folder exists
mkdir -p "$MAX_DEVICES_DIR"

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
DEST_PROJECT_PATH="$ABLETON_PROJECT_DIR/$LIVE_PROJECT_NAME"
SOURCE_PROJECT_PATH="$(cd "$(dirname "$0")" && pwd)/$LIVE_PROJECT_NAME"

echo "📦 Installing Ableton Live project..."
echo "   From: $SOURCE_PROJECT_PATH"
echo "   To: $DEST_PROJECT_PATH"

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
            exit 0
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
    echo "📦 Copying '$LIVE_PROJECT_NAME' to: $DEST_PROJECT_PATH"
    cp -R "$SOURCE_PROJECT_PATH" "$DEST_PROJECT_PATH"
    COPY_STATUS=$?
    if [ $COPY_STATUS -eq 0 ]; then
        echo "✅ Live project installed at: $DEST_PROJECT_PATH"
    else
        echo "❌ Failed to copy project (error code: $COPY_STATUS)"
        echo "   Source: $SOURCE_PROJECT_PATH"
        echo "   Destination: $DEST_PROJECT_PATH"
        echo "   Please check:"
        echo "   - Source directory exists and is readable"
        echo "   - Destination directory exists and is writable"
        echo "   - You have enough disk space"
        exit 1
    fi
else
    echo "❌ Source Live project folder not found at: $SOURCE_PROJECT_PATH"
    exit 1
fi

echo "🎉 AVNightwatch installation complete."
