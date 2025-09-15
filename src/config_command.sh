#!/usr/bin/env bash
# src/config_command.sh

# Load required libraries
source "$(dirname "${BASH_SOURCE[0]}")/lib/config.sh"

# Config edit command
config_edit() {
  local editor="${args[--editor]:-${EDITOR:-vi}}"
  local config_file
  
  # Get config file path
  config_file=$(get_config_file)
  
  if [[ ! -f "$config_file" ]]; then
    echo "Error: Configuration file not found at $config_file"
    echo "Please create a configuration file or run 'bamon start' to initialize one."
    exit 1
  fi
  
  # Check if editor exists
  if ! command -v "$editor" >/dev/null 2>&1; then
    echo "Error: Editor '$editor' not found"
    echo "Please install the editor or use --editor to specify a different one"
    exit 1
  fi
  
  echo "Opening configuration file in $editor..."
  echo "File: $config_file"
  
  # Open editor
  "$editor" "$config_file"
  
  # Validate after editing
  echo ""
  echo "Validating configuration after edit..."
  if validate_config_file "$config_file"; then
    echo "✅ Configuration is valid"
  else
    echo "❌ Configuration has errors. Please fix them before using BAMON."
    exit 1
  fi
}

# Config show command
config_show() {
  local config_file
  local pretty="${args[--pretty]:-0}"
  
  # Get config file path
  config_file=$(get_config_file)
  
  if [[ ! -f "$config_file" ]]; then
    echo "Error: Configuration file not found at $config_file"
    echo "Please create a configuration file or run 'bamon start' to initialize one."
    exit 1
  fi
  
  if [[ "$pretty" == "1" ]]; then
    # Pretty print with yq
    if command -v yq >/dev/null 2>&1; then
      yq eval '.' "$config_file"
    else
      cat "$config_file"
    fi
  else
    cat "$config_file"
  fi
}

# Config validate command
config_validate() {
  local config_file
  local verbose="${args[--verbose]:-0}"
  
  # Get config file path
  config_file=$(get_config_file)
  
  if [[ ! -f "$config_file" ]]; then
    echo "❌ Configuration file not found at $config_file"
    exit 1
  fi
  
  echo "Validating configuration file: $config_file"
  echo ""
  
  if validate_config_file "$config_file"; then
    echo "✅ Configuration is valid"
    
    if [[ "$verbose" == "1" ]]; then
      echo ""
      echo "Configuration details:"
      echo "====================="
      
      # Show basic config info
      local default_interval
      local log_file
      local pid_file
      local max_concurrent
      local script_count
      
      default_interval=$(get_config_value "daemon.default_interval" "$config_file")
      log_file=$(get_config_value "daemon.log_file" "$config_file")
      pid_file=$(get_config_value "daemon.pid_file" "$config_file")
      max_concurrent=$(get_config_value "daemon.max_concurrent" "$config_file")
      script_count=$(yq eval '.scripts | length' "$config_file" 2>/dev/null || echo "0")
      
      echo "  Default interval: ${default_interval}s"
      echo "  Log file: $log_file"
      echo "  PID file: $pid_file"
      echo "  Max concurrent: $max_concurrent"
      echo "  Scripts configured: $script_count"
      
      if [[ "$script_count" -gt 0 ]]; then
        echo ""
        echo "Configured scripts:"
        yq eval '.scripts[] | "  - \(.name): \(.command)"' "$config_file" 2>/dev/null || true
      fi
    fi
    
    exit 0
  else
    echo "❌ Configuration has errors"
    exit 1
  fi
}


# Validate configuration file
validate_config_file() {
  local config_file="$1"
  local errors=0
  
  # Check if file exists
  if [[ ! -f "$config_file" ]]; then
    echo "Error: Configuration file not found: $config_file"
    return 1
  fi
  
  # Check if yq is available for validation
  if ! command -v yq >/dev/null 2>&1; then
    echo "Warning: yq not found, skipping YAML validation"
    return 0
  fi
  
  # Validate YAML syntax
  if ! yq eval '.' "$config_file" >/dev/null 2>&1; then
    echo "Error: Invalid YAML syntax in configuration file"
    return 1
  fi
  
  # Validate required sections
  local required_sections=("daemon" "sandbox" "performance" "scripts")
  for section in "${required_sections[@]}"; do
    if ! yq eval "has(\"$section\")" "$config_file" | grep -q "true"; then
      echo "Error: Missing required section: $section"
      ((errors++))
    fi
  done
  
  # Validate daemon section
  local daemon_required=("default_interval" "log_file" "pid_file" "max_concurrent")
  for field in "${daemon_required[@]}"; do
    if ! yq eval ".daemon.$field" "$config_file" | grep -q -v "null"; then
      echo "Error: Missing required daemon field: $field"
      ((errors++))
    fi
  done
  
  # Validate scripts section
  local script_count
  script_count=$(yq eval '.scripts | length' "$config_file" 2>/dev/null || echo "0")
  
  if [[ "$script_count" -gt 0 ]]; then
    # Validate each script
    local i=0
    while [[ $i -lt $script_count ]]; do
      local script_name
      local script_command
      local script_interval
      local script_enabled
      
      script_name=$(yq eval ".scripts[$i].name" "$config_file" 2>/dev/null)
      script_command=$(yq eval ".scripts[$i].command" "$config_file" 2>/dev/null)
      script_interval=$(yq eval ".scripts[$i].interval" "$config_file" 2>/dev/null)
      script_enabled=$(yq eval ".scripts[$i].enabled" "$config_file" 2>/dev/null)
      
      if [[ "$script_name" == "null" || -z "$script_name" ]]; then
        echo "Error: Script $i missing name"
        ((errors++))
      fi
      
      if [[ "$script_command" == "null" || -z "$script_command" ]]; then
        echo "Error: Script '$script_name' missing command"
        ((errors++))
      fi
      
      if [[ "$script_interval" == "null" || -z "$script_interval" ]]; then
        echo "Error: Script '$script_name' missing interval"
        ((errors++))
      elif ! [[ "$script_interval" =~ ^[0-9]+$ ]]; then
        echo "Error: Script '$script_name' interval must be a number"
        ((errors++))
      fi
      
      if [[ "$script_enabled" == "null" ]]; then
        echo "Error: Script '$script_name' missing enabled status"
        ((errors++))
      fi
      
      ((i++))
    done
  fi
  
  return $errors
}
