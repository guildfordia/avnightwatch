#!/bin/bash

# ⚠️ If you see "permission denied", run:
# chmod +x start.sh

# Function to check Docker installation
check_docker() {
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker is not installed or not in your PATH."
        echo "👉 Please install Docker Desktop for macOS:"
        echo "   https://www.docker.com/products/docker-desktop/"
        exit 1
    else
        echo "🐳 Docker is installed."
    fi

    # Check if Docker daemon is running
    if ! docker info &>/dev/null; then
        echo "❌ Docker is installed but not running."
        echo "👉 Please start Docker Desktop and wait for it to be ready."
        exit 1
    else
        echo "✅ Docker is running."
    fi
}

# Function to check version and update if needed
check_and_update_version() {
    local local_version="0"
    local github_version="0"
    
    # Get local version if version file exists
    if [ -f "ircnightwatch/version" ]; then
        local_version=$(cat ircnightwatch/version)
    fi
    
    # Get GitHub version
    github_version=$(curl -s https://raw.githubusercontent.com/guildfordia/ircnightwatch/main/version)
    
    if [ -z "$github_version" ]; then
        echo "⚠️ Could not fetch version from GitHub. Using local version."
        return 0
    fi
    
    # Compare versions (handle non-numeric versions)
    if [[ "$github_version" =~ ^[0-9]+$ ]] && [[ "$local_version" =~ ^[0-9]+$ ]]; then
        if [ "$github_version" -gt "$local_version" ]; then
            echo "📥 New version available: $github_version (current: $local_version)"
            echo "🔄 Updating IRCNightwatch..."
            rm -rf ircnightwatch
            return 1
        else
            echo "✅ IRCNightwatch is up to date (version $local_version)"
            return 0
        fi
    else
        echo "⚠️ Version format not recognized. Skipping version check."
        return 0
    fi
}

# Function to setup IRCNightwatch
setup_ircnightwatch() {
    # Create Docker network if it doesn't exist
    if ! docker network ls | grep -q "irc-net"; then
        echo "🌐 Creating Docker network irc-net..."
        docker network create irc-net || {
            echo "❌ Failed to create Docker network irc-net"
            exit 1
        }
    else
        echo "✅ Docker network irc-net already exists"
    fi

    if [ ! -d "ircnightwatch" ] || ! check_and_update_version; then
        echo "📥 Downloading IRCNightwatch project from GitHub using curl..."
        ZIP_URL="https://github.com/guildfordia/ircnightwatch/archive/refs/heads/main.zip"
        ZIP_FILE="ircnightwatch.zip"

        curl -L "$ZIP_URL" -o "$ZIP_FILE" || {
            echo "❌ Failed to download repo zip. Aborting."
            exit 1
        }

        unzip "$ZIP_FILE" || {
            echo "❌ Failed to unzip archive."
            rm -f "$ZIP_FILE"
            exit 1
        }

        rm "$ZIP_FILE"
        mv ircnightwatch-main ircnightwatch
        echo "✅ Repo downloaded and extracted to ./ircnightwatch"
    else
        echo "✅ IRCNightwatch folder already exists and is up to date."
    fi

    # Build components
    cd ircnightwatch || {
        echo "❌ Could not enter ircnightwatch directory"
        exit 1
    }
    
    # Check if Makefile exists
    if [ -f "Makefile" ]; then
        make || {
            echo "❌ Make failed"
            exit 1
        }
    else
        echo "⚠️ No Makefile found in ircnightwatch directory"
    fi
    
    cd ..
}

# Function to check GL-MT300N connection
check_gl_mt300n() {
    echo "🌐 Checking Ethernet interface for GL-MT300N router..."
    
    # Check IP
    LOCAL_ETH_IP=$(ipconfig getifaddr en0 2>/dev/null)
    if [ "$LOCAL_ETH_IP" != "192.168.8.132" ]; then
        echo "❌ Expected Ethernet IP 192.168.8.132 not found."
        echo "👉 Make sure you're connected to the GL-MT300N via Ethernet."
        exit 1
    fi
    echo "✅ Ethernet interface has IP 192.168.8.132"

    # Check router reachability
    if ! ping -c 1 192.168.8.1 >/dev/null 2>&1; then
        echo "❌ Cannot reach GL-MT300N router at 192.168.8.1"
        echo "👉 Check that it's powered on and connected via Ethernet."
        exit 1
    fi
    echo "✅ GL-MT300N router is reachable at 192.168.8.1"
}

# Function to open QR code
open_qr_code() {
    QR_PATH="$(cd "$(dirname "$0")" && pwd)/img/QRCode.png"
    if [ -f "$QR_PATH" ]; then
        echo "🖼️ Opening QR code..."
        open "$QR_PATH"
    else
        echo "⚠️ QR code image not found at: $QR_PATH"
    fi
}

# Function to launch Live project
launch_live_project() {
    echo "🚀 Launching Ableton project..."
    LIVE_PROJECT_NAME="RDN_Liveset"
    
    # Load paths from .env file
    if [ -f ".env" ]; then
        echo "📄 Reading .env file..."
        # Read .env file line by line
        while IFS='=' read -r key value; do
            # Skip empty lines and comments
            [[ -z "$key" || "$key" =~ ^# ]] && continue
            # Remove any quotes and trim whitespace
            value=$(echo "$value" | tr -d '"'"'" | xargs)
            key=$(echo "$key" | xargs)
            # Export the variable
            export "$key"="$value"
            echo "   Loaded: $key=$value"
        done < .env
    else
        echo "❌ .env file not found. Please run install.sh first."
        exit 1
    fi
    
    # Check if ABLETON_PROJECTS_DIR is set
    if [ -z "$ABLETON_PROJECTS_DIR" ]; then
        echo "❌ ABLETON_PROJECTS_DIR not set in .env file. Please run install.sh first."
        echo "   Current .env contents:"
        cat .env
        exit 1
    fi
    
    # Check if RDN_Liveset directory exists
    PROJECT_PATH="$ABLETON_PROJECTS_DIR/$LIVE_PROJECT_NAME"
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "❌ RDN_Liveset project not found at: $PROJECT_PATH"
        echo "   Please run install.sh first."
        exit 1
    fi
    
    # Find the most recent .als file
    echo "🔍 Looking for .als files in: $PROJECT_PATH"
    ALS_FILE=$(find "$PROJECT_PATH" -maxdepth 1 -type f -name "*.als" | sort -r | head -n 1)
    
    if [ -z "$ALS_FILE" ]; then
        echo "❌ No .als files found in: $PROJECT_PATH"
        exit 1
    fi
    
    echo "📂 Found most recent Live Set: $ALS_FILE"

    # Check for Ableton Live versions
    LIVE_12_PATH="/Applications/Ableton Live 12 Suite.app"
    LIVE_11_PATH="/Applications/Ableton Live 11 Suite.app"
    LIVE_APP=""

    if [ -d "$LIVE_12_PATH" ]; then
        LIVE_APP="$LIVE_12_PATH"
        echo "✅ Using Ableton Live 12 Suite"
    elif [ -d "$LIVE_11_PATH" ]; then
        # Check Live 11 version
        LIVE_VERSION=$(defaults read "$LIVE_11_PATH/Contents/Info.plist" CFBundleShortVersionString)
        echo "📊 Checking Ableton Live version: $LIVE_VERSION"
        
        # Compare versions
        if [ "$(printf '%s\n' "11.3.42" "$LIVE_VERSION" | sort -V | head -n1)" != "11.3.42" ]; then
            echo "❌ Ableton Live version $LIVE_VERSION is too old. Please update to version 11.3.42 or newer."
            exit 1
        else
            LIVE_APP="$LIVE_11_PATH"
            echo "✅ Using Ableton Live 11 Suite version $LIVE_VERSION"
        fi
    else
        echo "❌ Neither Ableton Live 11 nor 12 found at /Applications."
        exit 1
    fi

    echo "📂 Opening Live Set: $ALS_FILE"
    /usr/bin/open -a "$LIVE_APP" "$ALS_FILE"
}

# Function to cleanup Docker resources
cleanup_docker() {
    echo "🧹 Cleaning up Docker resources..."
    
    # Stop and remove containers
    if docker ps -a | grep -q "ircnightwatch"; then
        echo "🛑 Stopping IRCNightwatch containers..."
        docker-compose -f ircnightwatch/irc/docker-compose.yml down
        docker-compose -f ircnightwatch/Sentiment/docker-compose.yml down
    fi

    # Remove network if it exists
    if docker network ls | grep -q "irc-net"; then
        echo "🗑️ Removing Docker network irc-net..."
        docker network rm irc-net
    fi
}

# Main script
ENV_FILE=".env"
ENV_TEMPLATE=".env.example"

echo "🔧 Choose WebSocket connection mode:"
echo "  [0] Local mode (connect via localhost)"
echo "  [1] Demo mode (connect directly to router)"
echo "  [2] Mesh mode (connect to Raspberry Pi over Ethernet)"
read -rp "Enter choice (0/1/2): " MODE

# Ensure .env exists
if [ ! -f "$ENV_FILE" ]; then
    if [ -f "$ENV_TEMPLATE" ]; then
        #cp "$ENV_TEMPLATE" "$ENV_FILE"
        #echo "📄 Created .env from .env.example"
    else
        echo "❌ No .env or .env.example file found. Aborting."
        exit 1
    fi
fi

# Handle different modes
case "$MODE" in
    0|1)
        # Common setup for Local and Demo modes
        sed -i '' 's|^WEBSOCKET_URL=.*|WEBSOCKET_URL=http://127.0.0.1:6000|' "$ENV_FILE"
        echo "🌐 Set WEBSOCKET_URL=http://127.0.0.1:6000 in $ENV_FILE"
        
        check_docker
        setup_ircnightwatch

        # Demo mode specific checks
        if [ "$MODE" == "1" ]; then
            check_gl_mt300n
            open_qr_code
        fi
        ;;
    2)
        # Mesh mode
        echo "🌐 Using MESH mode - connecting to Raspberry Pi at raspi.local..."
        PI_HOSTNAME="raspi.local"

        if ! ssh -o ConnectTimeout=3 rpi@"$PI_HOSTNAME" "echo ok" >/dev/null 2>&1; then
            echo "❌ Could not reach Raspberry Pi at '$PI_HOSTNAME' via SSH"
            echo "👉 Make sure it's powered on and connected via Ethernet."
            exit 1
        fi

        sed -i '' "s|^WEBSOCKET_URL=.*|WEBSOCKET_URL=http://$PI_HOSTNAME:6000|" "$ENV_FILE"
        echo "🌐 Set WEBSOCKET_URL=http://$PI_HOSTNAME:6000 in $ENV_FILE"

        read -rp "❓ Do you want to SSH into the Raspberry Pi in a new Terminal window? [y/n] " ANSWER
        if [[ "$ANSWER" =~ ^[Yy]$ ]]; then
            echo "🔐 Opening SSH session to rpi@$PI_HOSTNAME..."
            osascript -e "tell application \"Terminal\" to do script \"ssh rpi@$PI_HOSTNAME\""
            sleep 1
        fi
        ;;
    *)
        echo "❌ Invalid option. Please enter 0, 1, or 2."
        exit 1
        ;;
esac

# Launch Live project
launch_live_project
docker logs sentiment-api -f