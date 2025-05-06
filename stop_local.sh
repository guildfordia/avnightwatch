#!/bin/bash

# ⚠️ If you see "permission denied", run:
# chmod +x stop_local.sh

# Function to cleanup Docker resources
cleanup_docker() {
    echo "🧹 Cleaning up Docker resources..."
    
    # List of containers to stop and remove
    CONTAINERS=("sentiment-bot" "thelounge" "nginx" "ngircd" "sentiment-api")
    
    # First, stop all running containers
    echo "🛑 Stopping all running containers..."
    docker stop $(docker ps -q) 2>/dev/null || true
    
    # Then remove specific containers
    for container in "${CONTAINERS[@]}"; do
        if docker ps -a | grep -q "$container"; then
            echo "🗑️ Removing $container..."
            docker rm -f "$container" 2>/dev/null || true
        fi
    done

    # Remove network if it exists
    if docker network ls | grep -q "irc-net"; then
        echo "🗑️ Removing Docker network irc-net..."
        docker network rm irc-net 2>/dev/null || true
    fi

    # Wait a moment to ensure ports are freed
    sleep 2
}

# Main script
echo "🛑 Stopping AVNightwatch local services..."

# Check if Docker is installed and running
if ! command -v docker &> /dev/null; then
    echo "⚠️ Docker is not installed. Nothing to clean up."
    exit 0
fi

if ! docker info &>/dev/null; then
    echo "⚠️ Docker is not running. Nothing to clean up."
    exit 0
fi

# Clean up Docker resources
cleanup_docker

echo "✅ AVNightwatch local services stopped and cleaned up."
