#!/usr/bin/env bash
# Configuration management functions for bamon

# Default configuration file location
CONFIG_FILE="${BAMON_CONFIG_FILE:-${HOME}/.config/bamon/config.yaml}"
LOG_DIR="${HOME}/.local/share/bamon/logs"
PID_DIR="${HOME}/.local/share/bamon"

# Create default configuration
function init_config() {
  # Ensure CONFIG_FILE is set
  CONFIG_FILE="${CONFIG_FILE:-${BAMON_CONFIG_FILE:-${HOME}/.config/bamon/config.yaml}}"
  local config_dir="$(dirname "${CONFIG_FILE}")"
  
  # Create directories if they don't exist
  if [[ ! -d "$config_dir" ]]; then
    mkdir -p "$config_dir"
  fi
  
  if [[ ! -d "$LOG_DIR" ]]; then
    mkdir -p "$LOG_DIR"
  fi
  
  if [[ ! -d "$PID_DIR" ]]; then
    mkdir -p "$PID_DIR"
  fi
  
  # Create default config if it doesn't exist
  if [[ ! -f "${CONFIG_FILE}" ]]; then
    cat > "${CONFIG_FILE}" << EOF
daemon:
  default_interval: 60
  log_file: "${LOG_DIR}/bamon.log"
  pid_file: "${PID_DIR}/bamon.pid"
  max_concurrent: 10

sandbox:
  timeout: 30
  max_cpu_time: 60
  max_file_size: 10240
  max_virtual_memory: 102400

performance:
  enable_monitoring: true
  load_threshold: 0.8
  cache_ttl: 30
  optimize_scheduling: true

scripts: []
EOF
    echo "Created default configuration at ${CONFIG_FILE}"
  fi
}

# Load configuration from file
function load_config() {
  if [[ ! -f "${CONFIG_FILE}" ]]; then
    init_config
  fi
  
  # Check if yq is available for YAML parsing
  if command -v yq >/dev/null 2>&1; then
    return 0
  else
    echo "Warning: yq not found. YAML parsing will be limited." >&2
    return 1
  fi
}

# Get a configuration value using yq
function get_config_value() {
  local key="$1"
  local default_value="${2:-}"
  
  if command -v yq >/dev/null 2>&1; then
    yq eval ".${key}" "${CONFIG_FILE}" 2>/dev/null || echo "$default_value"
  else
    echo "$default_value"
  fi
}

# Set a configuration value using yq
function set_config_value() {
  local key="$1"
  local value="$2"
  
  if command -v yq >/dev/null 2>&1; then
    yq eval ".${key} = \"${value}\"" -i "${CONFIG_FILE}"
  else
    echo "Error: yq not available for configuration updates" >&2
    return 1
  fi
}

# Add a script to configuration
function add_script() {
  local name="$1"
  local command="$2"
  local interval="${3:-60}"
  local description="${4:-}"
  local enabled="${5:-true}"
  
  # Check if script already exists
  if script_exists "$name"; then
    echo "Error: Script '$name' already exists" >&2
    return 1
  fi
  
  if command -v yq >/dev/null 2>&1; then
    # Add script to the scripts array
    yq eval ".scripts += [{\"name\": \"${name}\", \"command\": \"${command}\", \"interval\": ${interval}, \"description\": \"${description}\", \"enabled\": ${enabled}}]" -i "${CONFIG_FILE}"
    echo "Added script '$name' to configuration"
  else
    echo "Error: yq not available for adding scripts" >&2
    return 1
  fi
}

# Remove a script from configuration
function remove_script() {
  local name="$1"
  
  if command -v yq >/dev/null 2>&1; then
    # Remove script from the scripts array
    yq eval "del(.scripts[] | select(.name == \"${name}\"))" -i "${CONFIG_FILE}"
    echo "Removed script '$name' from configuration"
  else
    echo "Error: yq not available for removing scripts" >&2
    return 1
  fi
}

# Check if a script exists
function script_exists() {
  local name="$1"
  
  if command -v yq >/dev/null 2>&1; then
    local count=$(yq eval ".scripts[] | select(.name == \"${name}\") | length" "${CONFIG_FILE}" 2>/dev/null)
    [[ "$count" -gt 0 ]]
  else
    return 1
  fi
}

# Get all scripts
function get_all_scripts() {
  if command -v yq >/dev/null 2>&1; then
    yq eval '.scripts[]' "${CONFIG_FILE}" 2>/dev/null
  else
    echo "[]"
  fi
}

# Get script by name
function get_script() {
  local name="$1"
  
  if command -v yq >/dev/null 2>&1; then
    yq eval ".scripts[] | select(.name == \"${name}\")" "${CONFIG_FILE}" 2>/dev/null
  else
    echo "{}"
  fi
}

# Update script property
function update_script_property() {
  local name="$1"
  local property="$2"
  local value="$3"
  
  if command -v yq >/dev/null 2>&1; then
    yq eval "(.scripts[] | select(.name == \"${name}\") | .${property}) = \"${value}\"" -i "${CONFIG_FILE}"
  else
    echo "Error: yq not available for updating scripts" >&2
    return 1
  fi
}

# Validate configuration file
function validate_config() {
  if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "Error: Configuration file not found: ${CONFIG_FILE}" >&2
    return 1
  fi
  
  if command -v yq >/dev/null 2>&1; then
    # Check if it's valid YAML
    if ! yq eval '.' "${CONFIG_FILE}" >/dev/null 2>&1; then
      echo "Error: Invalid YAML in configuration file" >&2
      return 1
    fi
    
    # Check required fields
    local daemon_config=$(yq eval '.daemon' "${CONFIG_FILE}" 2>/dev/null)
    if [[ -z "$daemon_config" || "$daemon_config" == "null" ]]; then
      echo "Error: Missing daemon configuration" >&2
      return 1
    fi
    
    local scripts_config=$(yq eval '.scripts' "${CONFIG_FILE}" 2>/dev/null)
    if [[ -z "$scripts_config" || "$scripts_config" == "null" ]]; then
      echo "Error: Missing scripts configuration" >&2
      return 1
    fi
    
    echo "Configuration file is valid"
    return 0
  else
    echo "Warning: Cannot validate YAML without yq" >&2
    return 1
  fi
}

# Get daemon configuration
function get_daemon_config() {
  if command -v yq >/dev/null 2>&1; then
    yq eval '.daemon' "${CONFIG_FILE}" 2>/dev/null
  else
    echo "{}"
  fi
}

# Get log file path
function get_log_file() {
  get_config_value "daemon.log_file" "${LOG_DIR}/bamon.log"
}

# Get PID file path
function get_pid_file() {
  get_config_value "daemon.pid_file" "${PID_DIR}/bamon.pid"
}

# Get default interval
function get_default_interval() {
  get_config_value "daemon.default_interval" "60"
}

# Get max concurrent executions
function get_max_concurrent() {
  get_config_value "daemon.max_concurrent" "10"
}

# Get sandbox timeout
function get_sandbox_timeout() {
  get_config_value "sandbox.timeout" "30"
}

# Get sandbox max CPU time
function get_sandbox_max_cpu_time() {
  get_config_value "sandbox.max_cpu_time" "60"
}

# Get sandbox max file size
function get_sandbox_max_file_size() {
  get_config_value "sandbox.max_file_size" "10240"
}

# Get sandbox max virtual memory
function get_sandbox_max_virtual_memory() {
  get_config_value "sandbox.max_virtual_memory" "102400"
}

# Performance configuration functions
function get_performance_config() {
  local key="$1"
  local default="$2"
  get_config_value "performance.$key" "$default"
}

function is_performance_monitoring_enabled() {
  get_performance_config "enable_monitoring" "true"
}

function get_performance_load_threshold() {
  get_performance_config "load_threshold" "0.8"
}

function get_performance_cache_ttl() {
  get_performance_config "cache_ttl" "30"
}

function is_performance_scheduling_optimized() {
  get_performance_config "optimize_scheduling" "true"
}
