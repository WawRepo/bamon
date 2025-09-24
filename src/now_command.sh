#!/usr/bin/env bash
# Now command implementation

# Source the library functions

# Get parsed arguments from bashly
SCRIPT_NAME="${args['--name']:-}"

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
  echo "Error: yq is required for script execution but not found" >&2
  echo "Please install yq: brew install yq" >&2
  exit 1
fi

# Execute specific script or all scripts
if [[ -n "$SCRIPT_NAME" ]]; then
  # Execute specific script
  if ! script_exists "$SCRIPT_NAME"; then
    echo "Error: Script '$SCRIPT_NAME' not found" >&2
    exit 1
  fi
  
  echo "Executing script: $SCRIPT_NAME"
  echo "================================"
  
  if execute_scripts "$SCRIPT_NAME"; then
    echo "Script execution completed successfully"
  else
    echo "Script execution failed"
    exit 1
  fi
else
  # Execute all enabled scripts
  echo "Executing all enabled scripts"
  echo "============================="
  
  if execute_all_scripts; then
    echo "All scripts executed successfully"
  else
    echo "Some scripts failed"
    exit 1
  fi
fi