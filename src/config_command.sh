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
    echo "Run 'bamon config reset' to create a default configuration."
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
    echo "Run 'bamon config reset' to create a default configuration."
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

# Config reset command
config_reset() {
  local force="${args[--force]:-0}"
  local backup="${args[--backup]:-0}"
  local config_file
  local config_dir
  local backup_file
  
  # Get config file path
  config_file=$(get_config_file)
  config_dir=$(dirname "$config_file")
  
  # Create backup if requested
  if [[ "$backup" == "1" && -f "$config_file" ]]; then
    backup_file="${config_file}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "Creating backup: $backup_file"
    cp "$config_file" "$backup_file"
    echo "✅ Backup created: $backup_file"
  fi
  
  # Confirm reset unless forced
  if [[ "$force" != "1" ]]; then
    echo "This will reset your configuration to default values."
    echo "Current config file: $config_file"
    
    if [[ -f "$config_file" ]]; then
      echo ""
      echo "Current configuration will be lost!"
      if [[ "$backup" == "1" ]]; then
        echo "A backup will be created before reset."
      fi
    fi
    
    echo ""
    read -p "Are you sure you want to continue? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Reset cancelled."
      exit 0
    fi
  fi
  
  # Create config directory if it doesn't exist
  mkdir -p "$config_dir"
  
  # Generate default configuration
  echo "Generating default configuration..."
  generate_default_config "$config_file"
  
  if [[ -f "$config_file" ]]; then
    echo "✅ Configuration reset successfully"
    echo "File: $config_file"
    
    if [[ "$backup" == "1" && -n "$backup_file" ]]; then
      echo "Backup: $backup_file"
    fi
    
    echo ""
    echo "You can now:"
    echo "  - Edit the config: bamon config edit"
    echo "  - View the config: bamon config show"
    echo "  - Validate the config: bamon config validate"
  else
    echo "❌ Failed to create configuration file"
    exit 1
  fi
}

# Generate default configuration
generate_default_config() {
  local config_file="$1"
  
  cat > "$config_file" << 'EOF'
daemon:
  default_interval: 300
  log_file: "~/.config/bamon/daemon.log"
  pid_file: "~/.config/bamon/bamon.pid"
  max_concurrent: 3

sandbox:
  timeout: 30
  max_cpu_time: 60
  max_file_size: 10240
  max_virtual_memory: 102400

performance:
  enable_monitoring: true
  load_threshold: 0.8
  optimize_scheduling: true

scripts:
  - name: "health_check"
    command: "curl -s -o /dev/null -w \"%{http_code}\" https://httpbin.org/status/200"
    interval: 300
    enabled: true
    description: "Check if HTTP service is responding"
  
  - name: "disk_usage"
    command: "df -h / | awk 'NR==2 {print $5}' | sed 's/%//' | awk '{if($1>80) exit 1; else exit 0}'"
    interval: 300
    enabled: true
    description: "Check if disk usage is under 80%"
  
  - name: "github_status"
    command: "curl -s https://www.githubstatus.com/api/v2/status.json | jq -r '.status.indicator' | grep -q 'operational' || exit 1"
    interval: 300
    enabled: true
    description: "Check GitHub service status"
EOF
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
