#!/usr/bin/env bash
# Remove command implementation

# Source the library functions

# Get parsed arguments from bashly
SCRIPT_NAME="${args['name']:-}"
FORCE=false

# Check for force flag
if [[ -n "${args['--force']:-}" ]]; then
  FORCE=true
fi

# Validate required arguments
if [[ -z "$SCRIPT_NAME" ]]; then
  echo "Error: Script name is required" >&2
  echo "Usage: bamon remove <name> [options]" >&2
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

# Check if script exists
if ! script_exists "$SCRIPT_NAME"; then
  echo "Error: Script '$SCRIPT_NAME' not found" >&2
  exit 1
fi

# Get script details for confirmation
script_info=$(get_script "$SCRIPT_NAME")
if [[ -n "$script_info" && "$script_info" != "{}" ]]; then
  local description=$(echo "$script_info" | yq eval '.description' - 2>/dev/null)
  local command=$(echo "$script_info" | yq eval '.command' - 2>/dev/null)
  
  echo "Script to be removed:"
  echo "  Name: $SCRIPT_NAME"
  echo "  Description: ${description:-'No description'}"
  echo "  Command: $command"
  echo ""
  
  if [[ "$FORCE" != "true" ]]; then
    read -p "Are you sure you want to remove this script? (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
      echo "Operation cancelled"
      exit 0
    fi
  fi
fi

# Remove the script
if remove_script "$SCRIPT_NAME"; then
  echo "Successfully removed script '$SCRIPT_NAME'"
else
  echo "Error: Failed to remove script '$SCRIPT_NAME'" >&2
  exit 1
fi