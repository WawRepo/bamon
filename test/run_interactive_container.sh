#!/usr/bin/env bash

# Interactive BAMON testing container
# This script starts a container with BAMON pre-installed and configured
# for interactive testing and PRD validation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONTAINER_NAME="bamon-interactive"
IMAGE_NAME="container-bamon-test"
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$TEST_DIR")"

echo -e "${BLUE}🚀 Starting Interactive BAMON Testing Container${NC}"
echo "=================================================="

# Check if BAMON binary exists
if [[ ! -f "$PROJECT_ROOT/bamon" ]]; then
    echo -e "${RED}❌ BAMON binary not found at $PROJECT_ROOT/bamon${NC}"
    echo "Please run 'bashly generate' first to build the BAMON binary"
    exit 1
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running${NC}"
    echo "Please start Docker and try again"
    exit 1
fi

# Build the container if it doesn't exist
echo -e "${YELLOW}📦 Building BAMON test container...${NC}"
cd "$TEST_DIR/container"
docker-compose build --no-cache
# docker-compose build 

# Stop and remove existing container if it exists
echo -e "${YELLOW}🧹 Cleaning up existing container...${NC}"
docker stop "$CONTAINER_NAME" 2>/dev/null || true
docker rm "$CONTAINER_NAME" 2>/dev/null || true

# Start the interactive container with automatic setup
echo -e "${GREEN}🎯 Starting interactive container with automatic setup...${NC}"
docker run -it --rm \
    --name "$CONTAINER_NAME" \
    -v "$PROJECT_ROOT:/app" \
    -w /app \
    "$IMAGE_NAME" \
    bash -c "/app/test/container/setup_interactive.sh && exec /bin/bash"

echo -e "${BLUE}👋 Interactive session ended${NC}"