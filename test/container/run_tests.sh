#!/usr/bin/env bash
# test/container/run_tests.sh

set -e

echo "Starting BAMON test suite..."

# Source common test functions
source "$(dirname "$0")/test_helpers.sh"

# Load test configuration
CONFIG_FILE="$(dirname "$0")/../config.yaml"
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: Test configuration file not found: $CONFIG_FILE"
  exit 1
fi

# Run installation tests
echo "=== Running Installation Tests ==="
if [[ -d "$(dirname "$0")/../installation" ]]; then
  bats "$(dirname "$0")/../installation/"*.bats
else
  echo "No installation tests found"
fi

# Run command tests
echo "=== Running Command Tests ==="
if [[ -d "$(dirname "$0")/../commands" ]]; then
  bats "$(dirname "$0")/../commands/"*.bats
else
  echo "No command tests found"
fi

# Run daemon tests
echo "=== Running Daemon Tests ==="
if [[ -d "$(dirname "$0")/../daemon" ]]; then
  bats "$(dirname "$0")/../daemon/"*.bats
else
  echo "No daemon tests found"
fi

# Run performance tests
echo "=== Running Performance Tests ==="
if [[ -d "$(dirname "$0")/../performance" ]]; then
  bats "$(dirname "$0")/../performance/"*.bats
else
  echo "No performance tests found"
fi

echo "All tests completed successfully!"
