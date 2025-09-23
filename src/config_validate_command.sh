# Libraries are included via bashly custom_includes

# Config validate command implementation
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

