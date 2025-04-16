#!/bin/bash

# ⚠️ If you see "permission denied", run:
# chmod +x start.sh

ENV_FILE=".env"
ENV_TEMPLATE=".env.example"

echo "🔧 Choose WebSocket connection mode:"
echo "  [1] Local mode (connect to localhost)"
echo "  [2] Mesh mode (connect to Raspberry Pi over Ethernet)"
read -rp "Enter choice (1 or 2): " MODE

# Step 1: Ensure .env exists
if [ ! -f "$ENV_FILE" ]; then
    if [ -f "$ENV_TEMPLATE" ]; then
        cp "$ENV_TEMPLATE" "$ENV_FILE"
        echo "📄 Created .env from .env.example"
    else
        echo "❌ No .env or .env.example file found. Aborting."
        exit 1
    fi
fi

# Step 2: Set WEBSOCKET_URL based on user choice
if [ "$MODE" == "1" ]; then
    echo "🌐 Using LOCAL mode"
    sed -i '' 's|^WEBSOCKET_URL=.*|WEBSOCKET_URL=http://localhost:5000|' "$ENV_FILE"

        # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker is not installed or not in your PATH."
        echo "👉 Please install Docker Desktop for macOS:"
        echo "   https://www.docker.com/products/docker-desktop/"
        exit 1
    else
        echo "🐳 Docker is installed."
    fi

    if [ ! -d "ircnightwatch" ]; then
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

        # The folder will be named ircnightwatch-main; rename it
        mv ircnightwatch-main ircnightwatch
        echo "✅ Repo downloaded and extracted to ./ircnightwatch"
    else
        echo "✅ IRCNightwatch folder already exists. Skipping download."
    fi

    # Build the IRC component
    echo "🔨 Building IRC project..."
    cd ircnightwatch/irc || {
        echo "❌ Could not enter ircnightwatch/irc"
        exit 1
    }
    make || {
        echo "❌ IRC make failed"
        exit 1
    }

    # Build the Sentiment component
    echo "🔨 Building Sentiment project..."
    cd ../Sentiment || {
        echo "❌ Could not enter ircnightwatch/Sentiment"
        exit 1
    }
    make || {
        echo "❌ Sentiment make failed"
        exit 1
    }

    # === Check for Ethernet connection to GL-MT300N ===
    echo "🌐 Checking Ethernet interface for GL-MT300N router..."

    # Check if local IP is 192.168.8.132
    LOCAL_ETH_IP=$(ipconfig getifaddr en0 2>/dev/null)

    if [ "$LOCAL_ETH_IP" = "192.168.8.132" ]; then
        echo "✅ Ethernet interface has IP 192.168.8.132"
    else
        echo "❌ Expected Ethernet IP 192.168.8.132 not found."
        echo "👉 Make sure you're connected to the GL-MT300N via Ethernet."
        exit 1
    fi

    # Check if the GL-MT300N router is reachable at 192.168.8.1
    ping -c 1 192.168.8.1 >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ GL-MT300N router is reachable at 192.168.8.1"
    else
        echo "❌ Cannot reach GL-MT300N router at 192.168.8.1"
        echo "👉 Check that it's powered on and connected via Ethernet."
        exit 1
    fi

    cd ../../  # Return to AVNightwatch root

    # === Open QR Code ===
    QR_PATH="$(cd "$(dirname "$0")" && pwd)/img/QRCode.png"

    if [ -f "$QR_PATH" ]; then
        echo "🖼️ Opening QR code..."
        open "$QR_PATH"
    else
        echo "⚠️ QR code image not found at: $QR_PATH"
    fi


elif [ "$MODE" == "2" ]; then
    echo "🌐 Using MESH mode - connecting to Raspberry Pi at raspi.local..."

    PI_HOSTNAME="raspi.local"

    echo "🧪 Testing connection to $PI_HOSTNAME via SSH..."

    if ssh -o ConnectTimeout=3 rpi@"$PI_HOSTNAME" "echo ok" >/dev/null 2>&1; then
        echo "✅ Raspberry Pi is reachable at $PI_HOSTNAME"
    else
        echo "❌ Could not reach Raspberry Pi at '$PI_HOSTNAME' via SSH"
        echo "👉 Make sure it's powered on and connected via Ethernet."
        exit 1
    fi

    # Update .env with the hostname (not IP)
    sed -i '' "s|^WEBSOCKET_URL=.*|WEBSOCKET_URL=http://$PI_HOSTNAME:5000|" "$ENV_FILE"
    echo "🌐 Set WEBSOCKET_URL=http://$PI_HOSTNAME:5000 in $ENV_FILE"

    # Offer to open SSH in a new terminal window
    echo "❓ Do you want to SSH into the Raspberry Pi in a new Terminal window? [y/n]"
    read -r ANSWER
    if [[ "$ANSWER" =~ ^[Yy]$ ]]; then
        echo "🔐 Opening SSH session to rpi@$PI_HOSTNAME..."
        osascript -e "tell application \"Terminal\" to do script \"ssh rpi@$PI_HOSTNAME\""
        sleep 1
    else
        echo "⏭️ Skipping SSH login."
    fi

else
    echo "❌ Invalid option. Please enter 1 or 2."
    exit 1
fi

# Step 3: Launch the Live project
echo "🚀 Launching Ableton project..."
LIVE_PROJECT_NAME="RDN_Liveset"
PRIMARY_PATH="$HOME/Music/Ableton/$LIVE_PROJECT_NAME"
FALLBACK_PATH="$HOME/Music/Ableton/Projects Folder/$LIVE_PROJECT_NAME"

if [ -d "$PRIMARY_PATH" ]; then
    PROJECT_PATH="$PRIMARY_PATH"
elif [ -d "$FALLBACK_PATH" ]; then
    PROJECT_PATH="$FALLBACK_PATH"
else
    echo "❌ Could not find the RDN_Liveset project."
    exit 1
fi

ALS_FILE=$(find "$PROJECT_PATH" -maxdepth 1 -type f -name "*.als" | head -n 1)

if [ -z "$ALS_FILE" ]; then
    echo "❌ No .als file found in: $PROJECT_PATH"
    exit 1
fi

echo "📂 Opening Live Set: $ALS_FILE"
/usr/bin/open -a "Ableton Live 11 Suite" "$ALS_FILE"