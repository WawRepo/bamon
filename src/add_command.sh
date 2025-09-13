#!/usr/bin/env bash
# Add command implementation

# Source the library functions

# Get parsed arguments from bashly
SCRIPT_NAME="${args['name']:-}"
SCRIPT_COMMAND="${args['--command']:-}"
SCRIPT_INTERVAL="${args['--interval']:-60}"
SCRIPT_DESCRIPTION="${args['--description']:-}"
SCRIPT_ENABLED="true"

# Check for disabled flag
if [[ -n "${args['--disabled']:-}" ]]; then
  SCRIPT_ENABLED="false"
fi

# Validate required arguments
if [[ -z "$SCRIPT_NAME" ]]; then
  echo "Error: Script name is required" >&2
  echo "Usage: bamon add <name> --command <command> [options]" >&2
  exit 1
fi

if [[ -z "$SCRIPT_COMMAND" ]]; then
  echo "Error: Script command is required" >&2
  echo "Usage: bamon add <name> --command <command> [options]" >&2
  exit 1
fi

# Validate script name (alphanumeric, hyphens, underscores only)
if [[ ! "$SCRIPT_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo "Error: Script name must contain only alphanumeric characters, hyphens, and underscores" >&2
  exit 1
fi

# Validate interval (must be a positive integer)
if [[ ! "$SCRIPT_INTERVAL" =~ ^[0-9]+$ ]] || [[ "$SCRIPT_INTERVAL" -le 0 ]]; then
  echo "Error: Interval must be a positive integer" >&2
  exit 1
fi

# Initialize configuration
init_config
load_config

# Validate configuration
if ! validate_config; then
  echo "Error: Invalid configuration file" >&2
  exit 1
fi

# Check if script already exists
if script_exists "$SCRIPT_NAME"; then
  echo "Error: Script '$SCRIPT_NAME' already exists" >&2
  exit 1
fi

# Add the script
if add_script "$SCRIPT_NAME" "$SCRIPT_COMMAND" "$SCRIPT_INTERVAL" "$SCRIPT_DESCRIPTION" "$SCRIPT_ENABLED"; then
  echo "Successfully added script '$SCRIPT_NAME'"
  echo "  Command: $SCRIPT_COMMAND"
  echo "  Interval: ${SCRIPT_INTERVAL}s"
  echo "  Description: ${SCRIPT_DESCRIPTION:-'No description'}"
  echo "  Enabled: $SCRIPT_ENABLED"
else
  echo "Error: Failed to add script '$SCRIPT_NAME'" >&2
  exit 1
fi