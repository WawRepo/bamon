#!/usr/bin/env bash
# Sandboxing functions for script execution

# Libraries are included via bashly custom_includes

# Default sandbox configuration
DEFAULT_TIMEOUT=30
DEFAULT_MAX_CPU_TIME=60
DEFAULT_MAX_FILE_SIZE=10240
DEFAULT_MAX_VIRTUAL_MEMORY=102400

# Execute script in a sandboxed environment
function execute_sandboxed() {
  local script_name="$1"
  local command="$2"
  local timeout="${3:-$DEFAULT_TIMEOUT}"
  
  if [[ -z "$script_name" || -z "$command" ]]; then
    log_error "execute_sandboxed: script_name and command are required"
    return 1
  fi
  
  log_info "Executing '$script_name' in sandbox with ${timeout}s timeout"
  
  # Create temporary directory for script
  local temp_dir
  temp_dir=$(mktemp -d)
  if [[ $? -ne 0 ]]; then
    log_error "Failed to create temporary directory for script '$script_name'"
    return 1
  fi
  
  local temp_script="${temp_dir}/script.sh"
  
  # Write command to temporary script
  cat > "$temp_script" << EOF
#!/usr/bin/env bash
set -e
# Preserve environment variables
export PATH="\$PATH"
# Use full path to common commands
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/homebrew/bin:\$PATH"
# Execute the command using bash directly
$command
EOF
  
  chmod +x "$temp_script"
  
  # Execute with resource limits
  local output
  local exit_code
  
  # Use timeout and ulimit to restrict resources
  # Note: ulimit settings are inherited by child processes
  output=$(
    (
      ulimit -t "$DEFAULT_MAX_CPU_TIME"  # CPU time limit
      ulimit -f "$DEFAULT_MAX_FILE_SIZE"  # File size limit
      # Skip virtual memory limit on macOS as it's not supported
      if [[ "$OSTYPE" != "darwin"* ]]; then
        ulimit -v "$DEFAULT_MAX_VIRTUAL_MEMORY"  # Virtual memory limit
      fi
      # Use gtimeout on macOS (from GNU coreutils), timeout on Linux
      if [[ "$OSTYPE" == "darwin"* ]]; then
        gtimeout "${timeout}s" "$temp_script" 2>&1
      else
        timeout "${timeout}s" "$temp_script" 2>&1
      fi
    )
  )
  exit_code=$?
  
  # Clean up temporary files
  rm -rf "$temp_dir"
  
  # Handle timeout specifically
  if [[ $exit_code -eq 124 ]]; then
    log_error "Script '$script_name' timed out after ${timeout}s"
    output="ERROR: Script execution timed out after ${timeout} seconds"
    exit_code=124
  elif [[ $exit_code -eq 125 ]]; then
    log_error "Script '$script_name' timeout command failed"
    output="ERROR: Timeout command failed"
    exit_code=125
  elif [[ $exit_code -eq 126 ]]; then
    log_error "Script '$script_name' command not executable"
    output="ERROR: Command not executable"
    exit_code=126
  elif [[ $exit_code -eq 127 ]]; then
    log_error "Script '$script_name' command not found"
    output="ERROR: Command not found"
    exit_code=127
  elif [[ $exit_code -eq 137 ]]; then
    log_error "Script '$script_name' killed (SIGKILL)"
    output="ERROR: Script killed due to resource limits"
    exit_code=137
  elif [[ $exit_code -gt 128 ]]; then
    log_error "Script '$script_name' terminated with signal $((exit_code - 128))"
    output="ERROR: Script terminated with signal $((exit_code - 128))"
  fi
  
  # Return results
  echo "$exit_code:$output"
}

# Execute script with custom resource limits
function execute_sandboxed_with_limits() {
  local script_name="$1"
  local command="$2"
  local timeout="${3:-$DEFAULT_TIMEOUT}"
  local max_cpu_time="${4:-$DEFAULT_MAX_CPU_TIME}"
  local max_file_size="${5:-$DEFAULT_MAX_FILE_SIZE}"
  local max_virtual_memory="${6:-$DEFAULT_MAX_VIRTUAL_MEMORY}"
  
  if [[ -z "$script_name" || -z "$command" ]]; then
    log_error "execute_sandboxed_with_limits: script_name and command are required"
    return 1
  fi
  
  log_info "Executing '$script_name' in sandbox with custom limits: timeout=${timeout}s, cpu=${max_cpu_time}s, file=${max_file_size}KB, mem=${max_virtual_memory}KB"
  
  # Create temporary directory for script
  local temp_dir
  temp_dir=$(mktemp -d)
  if [[ $? -ne 0 ]]; then
    log_error "Failed to create temporary directory for script '$script_name'"
    return 1
  fi
  
  local temp_script="${temp_dir}/script.sh"
  
  # Write command to temporary script
  cat > "$temp_script" << EOF
#!/usr/bin/env bash
set -e
# Preserve environment variables
export PATH="\$PATH"
# Use full path to common commands
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/homebrew/bin:\$PATH"
# Execute the command using bash directly
$command
EOF
  
  chmod +x "$temp_script"
  
  # Execute with custom resource limits
  local output
  local exit_code
  
  output=$(
    (
      ulimit -t "$max_cpu_time"
      ulimit -f "$max_file_size"
      # Skip virtual memory limit on macOS as it's not supported
      if [[ "$OSTYPE" != "darwin"* ]]; then
        ulimit -v "$max_virtual_memory"
      fi
      # Use gtimeout on macOS (from GNU coreutils), timeout on Linux
      if [[ "$OSTYPE" == "darwin"* ]]; then
        gtimeout "${timeout}s" "$temp_script" 2>&1
      else
        timeout "${timeout}s" "$temp_script" 2>&1
      fi
    )
  )
  exit_code=$?
  
  # Clean up temporary files
  rm -rf "$temp_dir"
  
  # Handle various exit codes
  case $exit_code in
    124)
      log_error "Script '$script_name' timed out after ${timeout}s"
      output="ERROR: Script execution timed out after ${timeout} seconds"
      ;;
    125)
      log_error "Script '$script_name' timeout command failed"
      output="ERROR: Timeout command failed"
      ;;
    126)
      log_error "Script '$script_name' command not executable"
      output="ERROR: Command not executable"
      ;;
    127)
      log_error "Script '$script_name' command not found"
      output="ERROR: Command not found"
      ;;
    137)
      log_error "Script '$script_name' killed (SIGKILL) - likely due to resource limits"
      output="ERROR: Script killed due to resource limits"
      ;;
    [1-9][0-9][0-9])
      log_error "Script '$script_name' terminated with signal $((exit_code - 128))"
      output="ERROR: Script terminated with signal $((exit_code - 128))"
      ;;
  esac
  
  # Return results
  echo "$exit_code:$output"
}

# Get sandbox configuration from config file
function get_sandbox_config() {
  # Initialize config if not already done
  init_config
  
  local timeout=$(get_config_value "sandbox.timeout" "$DEFAULT_TIMEOUT")
  local max_cpu_time=$(get_config_value "sandbox.max_cpu_time" "$DEFAULT_MAX_CPU_TIME")
  local max_file_size=$(get_config_value "sandbox.max_file_size" "$DEFAULT_MAX_FILE_SIZE")
  local max_virtual_memory=$(get_config_value "sandbox.max_virtual_memory" "$DEFAULT_MAX_VIRTUAL_MEMORY")
  
  # Ensure we have valid values
  timeout="${timeout:-$DEFAULT_TIMEOUT}"
  max_cpu_time="${max_cpu_time:-$DEFAULT_MAX_CPU_TIME}"
  max_file_size="${max_file_size:-$DEFAULT_MAX_FILE_SIZE}"
  max_virtual_memory="${max_virtual_memory:-$DEFAULT_MAX_VIRTUAL_MEMORY}"
  
  echo "$timeout:$max_cpu_time:$max_file_size:$max_virtual_memory"
}

# Execute script with configuration-based sandbox settings
function execute_sandboxed_from_config() {
  local script_name="$1"
  local command="$2"
  
  if [[ -z "$script_name" || -z "$command" ]]; then
    log_error "execute_sandboxed_from_config: script_name and command are required"
    echo "1:ERROR: script_name and command are required"
    return 1
  fi
  
  # Get sandbox configuration from config file
  local config
  config=$(get_sandbox_config)
  IFS=':' read -r timeout max_cpu_time max_file_size max_virtual_memory <<< "$config"
  
  # Use configured timeout and return the result
  execute_sandboxed "$script_name" "$command" "$timeout"
}

# Validate sandbox configuration
function validate_sandbox_config() {
  local config
  config=$(get_sandbox_config)
  IFS=':' read -r timeout max_cpu_time max_file_size max_virtual_memory <<< "$config"
  
  local errors=()
  
  # Validate timeout
  if ! [[ "$timeout" =~ ^[0-9]+$ ]] || [[ $timeout -lt 1 ]] || [[ $timeout -gt 3600 ]]; then
    errors+=("Invalid timeout value: $timeout (must be 1-3600 seconds)")
  fi
  
  # Validate CPU time limit
  if ! [[ "$max_cpu_time" =~ ^[0-9]+$ ]] || [[ $max_cpu_time -lt 1 ]] || [[ $max_cpu_time -gt 7200 ]]; then
    errors+=("Invalid max_cpu_time value: $max_cpu_time (must be 1-7200 seconds)")
  fi
  
  # Validate file size limit
  if ! [[ "$max_file_size" =~ ^[0-9]+$ ]] || [[ $max_file_size -lt 1 ]] || [[ $max_file_size -gt 1048576 ]]; then
    errors+=("Invalid max_file_size value: $max_file_size (must be 1-1048576 KB)")
  fi
  
  # Validate virtual memory limit
  if ! [[ "$max_virtual_memory" =~ ^[0-9]+$ ]] || [[ $max_virtual_memory -lt 1 ]] || [[ $max_virtual_memory -gt 1048576 ]]; then
    errors+=("Invalid max_virtual_memory value: $max_virtual_memory (must be 1-1048576 KB)")
  fi
  
  if [[ ${#errors[@]} -gt 0 ]]; then
    log_error "Sandbox configuration validation failed:"
    for error in "${errors[@]}"; do
      log_error "  - $error"
    done
    return 1
  fi
  
  log_info "Sandbox configuration validation passed"
  return 0
}
