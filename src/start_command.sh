#!/usr/bin/env bash
# Start command implementation

# Source the library functions

# Get parsed arguments from bashly
DAEMON_MODE=false
CONFIG_FILE=""

# Check for daemon mode flag
if [[ -n "${args['--daemon']:-}" ]]; then
  DAEMON_MODE=true
fi

# Get config file if provided
CONFIG_FILE="${args['--config']:-}"

# Set custom config file if provided
if [[ -n "$CONFIG_FILE" ]]; then
  export BAMON_CONFIG_FILE="$CONFIG_FILE"
fi

# Initialize configuration
init_config
load_config

# Validate configuration
if ! validate_config; then
  echo "Error: Invalid configuration file" >&2
  exit 1
fi

# Check if yq is available
if ! command -v yq >/dev/null 2>&1; then
  echo "Error: yq is required for daemon operation but not found" >&2
  echo "Please install yq: brew install yq" >&2
  exit 1
fi

# Start the daemon
start_daemon "$DAEMON_MODE"