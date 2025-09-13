#!/usr/bin/env bash
# List command implementation

# Source the library functions

# Get parsed arguments from bashly
ENABLED_ONLY=false
DISABLED_ONLY=false

# Check for filter flags
if [[ -n "${args['--enabled-only']:-}" ]]; then
  ENABLED_ONLY=true
fi

if [[ -n "${args['--disabled-only']:-}" ]]; then
  DISABLED_ONLY=true
fi

# Initialize configuration
init_config
load_config

# Validate configuration
if ! validate_config; then
  echo "Error: Invalid configuration file" >&2
  exit 1
fi

# Get all scripts
scripts_yaml=$(yq eval '.scripts[]' "${CONFIG_FILE}" 2>/dev/null)

if [[ -z "$scripts_yaml" ]]; then
  echo "No scripts configured"
  exit 0
fi

# Function to display a script
function display_script() {
  if [[ -z "$script_name" ]]; then
    return
  fi
  
  # Apply filters
  if [[ "$ENABLED_ONLY" == "true" && "$script_enabled" != "true" ]]; then
    return
  fi
  
  if [[ "$DISABLED_ONLY" == "true" && "$script_enabled" == "true" ]]; then
    return
  fi
  
  # Display script info
  local status_color=""
  if [[ "$script_enabled" == "true" ]]; then
    status_color="\033[0;32m"  # Green
  else
    status_color="\033[0;33m"  # Yellow
  fi
  
  echo -e "${status_color}${script_name}${status_color}\033[0m"
  
  if [[ -n "$script_description" && "$script_description" != '""' ]]; then
    echo "  Description: $script_description"
  fi
  
  echo "  Command: $script_command"
  echo "  Interval: ${script_interval}s"
  echo "  Enabled: $script_enabled"
  echo ""
}

# Display scripts
echo "Configured Scripts:"
echo "=================="

# Parse each script
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

# Show summary
local total_count=$(yq eval '.scripts | length' "${CONFIG_FILE}" 2>/dev/null || echo "0")
local enabled_count=$(yq eval '[.scripts[] | select(.enabled == true)] | length' "${CONFIG_FILE}" 2>/dev/null || echo "0")
local disabled_count=$(yq eval '[.scripts[] | select(.enabled == false)] | length' "${CONFIG_FILE}" 2>/dev/null || echo "0")

echo "Summary:"
echo "  Total scripts: $total_count"
echo "  Enabled: $enabled_count"
echo "  Disabled: $disabled_count"