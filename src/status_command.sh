#!/usr/bin/env bash
# Status command implementation

# Source the library functions

# Parse command line arguments
VERBOSE=false
FAILED_ONLY=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --verbose|-v)
      VERBOSE=true
      shift
      ;;
    --failed-only|-f)
      FAILED_ONLY=true
      shift
      ;;
    --help|-h)
      # Help is handled by the main script
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Initialize configuration
init_config
load_config

# Validate configuration
if ! validate_config; then
  echo "Error: Invalid configuration file" >&2
  exit 1
fi

# Function to display a script
function display_script() {
  if [[ -z "$script_name" ]]; then
    return
  fi
  
  # Determine status
  local status="UNKNOWN"
  local status_color=""
  
  if [[ "$script_enabled" != "true" ]]; then
    status="DISABLED"
    status_color="\033[0;33m"  # Yellow
  else
    # For now, we'll show as ENABLED since we don't have execution history
    # In a real implementation, you'd check last execution results
    status="ENABLED"
    status_color="\033[0;32m"  # Green
  fi
  
  # Skip if only showing failed scripts and this one isn't failed
  if [[ "$FAILED_ONLY" == "true" && "$status" != "FAILED" ]]; then
    return
  fi
  
  # Display script info
  echo -e "${status_color}${script_name}${status_color}\033[0m: ${status}"
  
  if [[ -n "$script_description" && "$script_description" != '""' ]]; then
    echo "  Description: $script_description"
  fi
  
  echo "  Command: $script_command"
  echo "  Interval: ${script_interval}s"
  echo "  Enabled: $script_enabled"
  
  if [[ "$VERBOSE" == "true" ]]; then
    echo "  Last execution: Not implemented yet"
    echo "  Next execution: Not implemented yet"
  fi
  
  echo ""
}

# Get all scripts
scripts_yaml=$(yq eval '.scripts[]' "${CONFIG_FILE}" 2>/dev/null)

if [[ -z "$scripts_yaml" ]]; then
  echo "No scripts configured"
  exit 0
fi

# Parse scripts and display status
echo "Script Status:"
echo "=============="

# Parse each script
local current_script=""
local script_name=""
local script_command=""
local script_interval=""
local script_enabled=""
local script_description=""

while IFS= read -r line; do
  if [[ "$line" =~ ^name:\ (.+)$ ]]; then
    # If we have a previous script, display it
    if [[ -n "$script_name" ]]; then
      display_script
    fi
    # Start new script
    script_name="${BASH_REMATCH[1]}"
    script_command=""
    script_interval=""
    script_enabled=""
    script_description=""
  elif [[ "$line" =~ ^command:\ (.+)$ ]]; then
    script_command="${BASH_REMATCH[1]}"
  elif [[ "$line" =~ ^interval:\ (.+)$ ]]; then
    script_interval="${BASH_REMATCH[1]}"
  elif [[ "$line" =~ ^enabled:\ (.+)$ ]]; then
    script_enabled="${BASH_REMATCH[1]}"
  elif [[ "$line" =~ ^description:\ (.+)$ ]]; then
    script_description="${BASH_REMATCH[1]}"
  fi
done <<< "$scripts_yaml"

# Display the last script
if [[ -n "$script_name" ]]; then
  display_script
fi

echo ""
echo "Total scripts: $(yq eval '.scripts | length' "${CONFIG_FILE}" 2>/dev/null || echo "0")"