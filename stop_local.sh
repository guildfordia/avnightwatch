#!/bin/bash

# ⚠️ If you see "permission denied", run:
# chmod +x restart.sh

echo "🔄 Restarting AVNightwatch setup..."

# Step 1: Stop all Docker containers
echo "🛑 Stopping all running Docker containers..."
docker ps -q | xargs -r docker stop

# Step 2: Remove all stopped containers (optional, but clean)
echo "🧹 Removing stopped containers..."
docker container prune -f

# Step 3: Remove the ircnightwatch folder
if [ -d "ircnightwatch" ]; then
    echo "🗑️ Deleting existing 'ircnightwatch' folder..."
    rm -rf ircnightwatch
else
    echo "ℹ️ 'ircnightwatch' folder does not exist. Skipping deletion."
fi
