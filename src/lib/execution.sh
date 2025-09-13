#!/usr/bin/env bash
# Script execution functions for bamon

# Libraries are included via bashly custom_includes

# Default timeout for script execution (seconds)
DEFAULT_TIMEOUT=30

# Execute a script with sandboxed environment
function execute_script() {
  local script_name="$1"
  local script_command="$2"
  local timeout="${3:-$DEFAULT_TIMEOUT}"
  local max_memory_mb="${4:-100}"
  
  local start_time=$(date +%s)
  local output=""
  local exit_code=0
  
  log_info "Executing script '${script_name}': ${script_command}" "$script_name"
  
  # Check if we can run more scripts (performance optimization)
  if ! can_run_more_scripts; then
    log_warn "Skipping script '$script_name' due to system load or capacity limits"
    return 1
  fi
  
  # Use sandboxed execution
  local result
  result=$(execute_sandboxed_from_config "$script_name" "$script_command")
  
  # Parse result (format: "exit_code:output")
  if [[ "$result" =~ ^([0-9]+):(.*)$ ]]; then
    exit_code="${BASH_REMATCH[1]}"
    output="${BASH_REMATCH[2]}"
  else
    log_error "Failed to parse sandbox execution result for '$script_name'"
    exit_code=1
    output="ERROR: Failed to parse execution result"
  fi
  
  local end_time=$(date +%s)
  local duration=$((end_time - start_time))
  
  # Track performance metrics
  local success="true"
  if [[ $exit_code -ne 0 ]]; then
    success="false"
  fi
  track_script_execution "$script_name" "$duration" "$success"
  
  # Log the result
  log_script_result "$script_name" "$exit_code" "$output" "$duration"
  
  # Return exit code
  return $exit_code
}

# Execute multiple scripts
function execute_scripts() {
  local script_names=("$@")
  local results=()
  local failed_scripts=()
  
  for script_name in "${script_names[@]}"; do
    local script_info=$(get_script "$script_name")
    if [[ -z "$script_info" || "$script_info" == "{}" ]]; then
      log_error "Script '$script_name' not found in configuration" "$script_name"
      continue
    fi
    
    # Extract script details using yq
    local script_command=$(echo "$script_info" | yq eval '.command' - 2>/dev/null)
    local script_interval=$(echo "$script_info" | yq eval '.interval' - 2>/dev/null)
    local script_enabled=$(echo "$script_info" | yq eval '.enabled' - 2>/dev/null)
    
    if [[ "$script_enabled" != "true" ]]; then
      log_info "Skipping disabled script '$script_name'" "$script_name"
      continue
    fi
    
    if [[ -z "$script_command" ]]; then
      log_error "No command defined for script '$script_name'" "$script_name"
      continue
    fi
    
    # Execute the script
    if execute_script "$script_name" "$script_command" "$script_interval"; then
      results+=("$script_name:SUCCESS")
    else
      results+=("$script_name:FAILED")
      failed_scripts+=("$script_name")
    fi
  done
  
  # Print summary
  echo "Execution Summary:"
  for result in "${results[@]}"; do
    echo "  $result"
  done
  
  # Return number of failed scripts
  return ${#failed_scripts[@]}
}

# Execute all enabled scripts
function execute_all_scripts() {
  # Cleanup old cache entries
  cleanup_cache
  
  # Use optimized scheduling if enabled
  local script_names=()
  if is_scheduling_optimized; then
    while IFS= read -r script_name; do
      script_names+=("$script_name")
    done < <(optimize_schedule)
  else
    # Fallback to original method
    local scripts_json=$(get_all_scripts)
    
    # Extract script names from YAML
    while IFS= read -r line; do
      if [[ "$line" =~ ^name:\ (.+)$ ]]; then
        script_names+=("${BASH_REMATCH[1]}")
      fi
    done <<< "$scripts_json"
  fi
  
  if [[ ${#script_names[@]} -eq 0 ]]; then
    echo "No scripts configured"
    return 0
  fi
  
  execute_scripts "${script_names[@]}"
}

# Check if daemon is running
function is_daemon_running() {
  local pid_file=$(get_pid_file)
  
  # First check PID file
  if [[ -f "$pid_file" ]]; then
    local pid=$(cat "$pid_file" 2>/dev/null)
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
      return 0
    else
      # Clean up stale PID file
      rm -f "$pid_file"
    fi
  fi

  # Fallback: check for running bamon daemon processes (exclude current process)
  local current_pid=$$
  local daemon_pids=$(ps aux | grep -E "bamon start --daemon|daemon_loop" | grep -v grep | awk -v current="$current_pid" '$2 != current {print $2}')
  if [[ -n "$daemon_pids" ]]; then
    # Check if any of the found PIDs are actually running
    for pid in $daemon_pids; do
      if kill -0 "$pid" 2>/dev/null; then
        # Update PID file with the first running daemon PID
        echo "$pid" > "$pid_file"
        return 0
      fi
    done
  fi
  
  return 1
}

# Start daemon
function start_daemon() {
  local daemon_mode="${1:-false}"
  
  # Check if daemon is running and get PID before any cleanup
  local pid_file=$(get_pid_file)
  local existing_pid=""
  if [[ -f "$pid_file" ]]; then
    existing_pid=$(cat "$pid_file" 2>/dev/null)
  fi


  if is_daemon_running; then
    echo "Daemon is already running (PID: $existing_pid)"
    return 0
  fi
  
  log_info "Starting bamon daemon"
  
  if [[ "$daemon_mode" == "true" ]]; then
    # Start in background with output redirected to single log file
    local log_file=$(get_log_file)
    
    # Create log directory if it doesn't exist
    mkdir -p "$(dirname "$log_file")"
    
    # Debug: Write to debug file before starting daemon
    echo "DEBUG: Starting daemon in background mode" > /tmp/bamon_debug.log
    
    # Start daemon in background with both stdout and stderr redirected to single log file

    daemon_loop > "$log_file" 2>&1 &
    local daemon_pid=$!
    echo "$daemon_pid" > "$(get_pid_file)"
    echo "Daemon started in background (PID: $daemon_pid)"
    echo "Logs: $log_file"
    
    # Debug: Write PID to debug file
    echo "DEBUG: Daemon PID: $daemon_pid" >> /tmp/bamon_debug.log
  else
    # Start in foreground
    daemon_loop
  fi
}

# Stop daemon
function stop_daemon() {
  local force="${1:-false}"
  local pid_file=$(get_pid_file)
  
  if ! is_daemon_running; then
    echo "Daemon is not running"
    return 0
  fi
  
  local pid=$(cat "$pid_file")
  log_info "Stopping daemon (PID: $pid)"
  
  if [[ "$force" == "true" ]]; then
    kill -9 "$pid" 2>/dev/null
  else
    kill -TERM "$pid" 2>/dev/null
  fi
  
  # Wait for process to stop
  local count=0
  while kill -0 "$pid" 2>/dev/null && [[ $count -lt 10 ]]; do
    sleep 1
    ((count++))
  done
  
  if kill -0 "$pid" 2>/dev/null; then
    echo "Warning: Daemon did not stop gracefully, forcing..."
    kill -9 "$pid" 2>/dev/null
  fi
  
  rm -f "$pid_file"
  echo "Daemon stopped"
}

# Initialize script execution tracking
function init_script_execution_tracking() {
  local tracking_file="$HOME/.config/bamon/script_execution_times.json"
  
  # Create directory if it doesn't exist
  mkdir -p "$(dirname "$tracking_file")"
  
  # Initialize empty tracking file if it doesn't exist
  if [[ ! -f "$tracking_file" ]]; then
    echo '{}' > "$tracking_file"
  fi
}

# Execute scripts based on their intervals
function execute_scheduled_scripts() {
  local current_time=$(date +%s)
  local scripts_json=$(get_all_scripts)
  local script_names=()
  
  # Extract script names and intervals from YAML
  while IFS= read -r line; do
    if [[ "$line" =~ ^name:\ (.+)$ ]]; then
      script_names+=("${BASH_REMATCH[1]}")
    fi
  done <<< "$scripts_json"
  
  # Check each script's interval
  for script_name in "${script_names[@]}"; do
    if should_execute_script "$script_name" "$current_time"; then
      log_info "Executing scheduled script: $script_name"
      
      # Get script command from YAML array
      local script_command=$(yq eval ".scripts[] | select(.name == \"$script_name\") | .command" ~/.config/bamon/config.yaml 2>/dev/null)
      if [[ -n "$script_command" ]]; then
        execute_script "$script_name" "$script_command"
        update_script_execution_time "$script_name" "$current_time"
      else
        log_error "No command found for script '$script_name'"
      fi
    fi
  done
}

# Check if a script should be executed based on its interval
function should_execute_script() {
  local script_name="$1"
  local current_time="$2"
  local tracking_file="$HOME/.config/bamon/script_execution_times.json"
  
  # Get script interval from config
  local interval=$(get_script_interval "$script_name")
  if [[ -z "$interval" || "$interval" -le 0 ]]; then
    return 1
  fi
  
  # Get last execution time
  local last_execution=$(cat "$tracking_file" 2>/dev/null | jq -r ".\"$script_name\" // 0" 2>/dev/null)
  if [[ "$last_execution" == "null" || -z "$last_execution" ]]; then
    last_execution=0
  fi
  
  # Check if enough time has passed
  local time_since_last=$((current_time - last_execution))
  if [[ $time_since_last -ge $interval ]]; then
    return 0
  else
    return 1
  fi
}

# Update script execution time
function update_script_execution_time() {
  local script_name="$1"
  local execution_time="$2"
  local tracking_file="$HOME/.config/bamon/script_execution_times.json"
  
  # Update the tracking file
  local temp_file=$(mktemp)
  cat "$tracking_file" | jq ".\"$script_name\" = $execution_time" > "$temp_file" 2>/dev/null
  mv "$temp_file" "$tracking_file"
}

# Get script interval from config
function get_script_interval() {
  local script_name="$1"
  local scripts_json=$(get_all_scripts)
  local in_script=false
  local current_script=""
  
  while IFS= read -r line; do
    if [[ "$line" =~ ^name:\ (.+)$ ]]; then
      current_script="${BASH_REMATCH[1]}"
      in_script=true
    elif [[ "$line" =~ ^interval:\ (.+)$ ]] && [[ "$in_script" == "true" ]] && [[ "$current_script" == "$script_name" ]]; then
      echo "${BASH_REMATCH[1]}"
      return 0
    elif [[ "$line" =~ ^name:  ]] && [[ "$in_script" == "true" ]]; then
      in_script=false
    fi
  done <<< "$scripts_json"
  
  echo "60"  # Default interval
}

# Main daemon loop
function daemon_loop() {
  # Set daemon mode for logging
  export BAMON_DAEMON_MODE=true
  
  # Debug: Write to a debug file to see if daemon loop starts
  echo "DEBUG: Daemon loop started (PID: $$)" > /tmp/bamon_debug.log
  
  # Initialize performance monitoring
  init_performance_monitoring
  
  # Initialize script execution tracking
  init_script_execution_tracking
  
  log_info "Daemon loop started (PID: $$)"
  
  # Trap signals for graceful shutdown
  trap 'log_info "Received SIGTERM, shutting down gracefully"; exit 0' TERM
  trap 'log_info "Received SIGINT, shutting down gracefully"; exit 0' INT
  
  while true; do
    # Disable exit on error for daemon loop
    set +e
    
    # Rotate log if needed
    rotate_log_if_needed
    
    # Execute scripts based on their intervals
    execute_scheduled_scripts
    
    # Re-enable exit on error
    set -e
    
    # Sleep for a short interval before next check
    sleep 5
  done
}
