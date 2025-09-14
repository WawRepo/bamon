#!/usr/bin/env bash
# test/run_container_tests.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/container"

echo "Building BAMON test container..."
docker-compose build

echo "Running BAMON test suite in container..."
docker-compose run --rm bamon-test

echo "Container tests completed successfully!"
