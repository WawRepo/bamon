#!/usr/bin/env bash
# Status Check Command for BAMON
# Displays the current status of all configured scripts without running them

# Libraries are included via bashly custom_includes

# Main status check function
function status_command() {
  local name="${args[--name]:-}"
  local json_output="${args[--json]:-}"
  local failed_only="${args[--failed-only]:-}"
  local verbose="${args[--verbose]:-}"
  
  # Handle case when args array is not available (direct function call)
  if [[ -z "${args[--name]:-}" && -n "${1:-}" ]]; then
    name="$1"
  fi
  
  # Load configuration
  if ! load_config; then
    log_error "Failed to load configuration"
    return 1
  fi
  
  # Get all scripts or specific script
  local scripts=""
  if [[ -n "$name" ]]; then
    if ! script_exists "$name"; then
      echo "Error: Script '$name' does not exist"
      return 1
    fi
    scripts="$name"
  else
    scripts=$(get_all_scripts)
    if [[ -z "$scripts" ]]; then
      echo "No scripts configured. Use 'bamon add' to add scripts."
      return 0
    fi
  fi
  
  # Print header if not JSON output
  if [[ "$json_output" != "1" ]]; then
    printf "%-20s %-10s %-20s %-10s %-15s %-20s %-20s %s\n" \
      "NAME" "STATUS" "LAST EXECUTION" "EXIT CODE" "DURATION" "TIME SINCE" "NEXT EXECUTION" "ERROR"
    printf "%s\n" "$(printf '=%.0s' {1..140})"
  else
    echo "{"
    echo "  \"scripts\": ["
  fi
  
  local first=true
  for script in $scripts; do
    # Get script details
    local enabled=$(is_script_enabled "$script")
    local last_run=$(get_script_last_execution_time "$script")
    local last_status=$(get_script_last_status "$script")
    local last_duration=$(get_script_last_duration "$script")
    local last_error=$(get_script_last_error "$script")
    local interval=$(get_script_interval "$script")
    
    # Skip if failed_only is set and script didn't fail
    if [[ "$failed_only" == "true" && "$last_status" != "FAILED" ]]; then
      continue
    fi
    
    # Calculate time since last execution
    local time_since="Never"
    if [[ -n "$last_run" && "$last_run" != "0" ]]; then
      time_since=$(calculate_time_since "$last_run")
    fi
    
    # Calculate next execution time
    local next_execution="Not scheduled"
    if [[ "$enabled" == "true" && -n "$last_run" && "$last_run" != "0" && -n "$interval" ]]; then
      next_execution=$(calculate_next_execution "$last_run" "$interval")
    elif [[ "$enabled" != "true" ]]; then
      next_execution="Disabled"
    fi
    
    # Format result
    local result="Unknown"
    if [[ -n "$last_status" ]]; then
      if [[ "$last_status" == "SUCCESS" ]]; then
        result="Success"
      else
        result="Failed"
      fi
    fi
    
    # Format duration
    local duration="N/A"
    if [[ -n "$last_duration" && "$last_duration" != "0" ]]; then
      duration=$(format_duration "$last_duration")
    fi
    
    # Format exit code
    local exit_code="N/A"
    if [[ -n "$last_status" && "$last_status" != "UNKNOWN" ]]; then
      exit_code=$(get_script_exit_code "$script")
    fi
    
    # Truncate error message if too long
    local error_msg=""
    if [[ -n "$last_error" && "$last_error" != "null" ]]; then
      if [[ ${#last_error} -gt 30 ]]; then
        error_msg="${last_error:0:27}..."
      else
        error_msg="$last_error"
      fi
    fi
    
    # Format last execution time
    local last_execution_display="Never"
    if [[ -n "$last_run" && "$last_run" != "0" ]]; then
      last_execution_display=$(format_timestamp "$last_run")
    fi
    
    # Output in requested format
    if [[ "$json_output" == "1" ]]; then
      if [[ "$first" != "true" ]]; then
        echo "    ,"
      fi
      first=false
      
      echo "    {"
      echo "      \"name\": \"$script\","
      echo "      \"enabled\": $enabled,"
      echo "      \"lastExecution\": \"$last_execution_display\","
      echo "      \"result\": \"$result\","
      echo "      \"exitCode\": \"$exit_code\","
      echo "      \"duration\": \"$duration\","
      echo "      \"timeSince\": \"$time_since\","
      echo "      \"nextExecution\": \"$next_execution\","
      echo "      \"error\": \"${last_error:-null}\""
      echo -n "    }"
    else
      printf "%-20s %-10s %-20s %-10s %-15s %-20s %-20s %s\n" \
        "$script" \
        "$result" \
        "$last_execution_display" \
        "$exit_code" \
        "$duration" \
        "$time_since" \
        "$next_execution" \
        "$error_msg"
    fi
  done
  
    if [[ "$json_output" == "1" ]]; then
    echo ""
    echo "  ]"
    echo "}"
  fi
  
  return 0
}

# Check if a script exists
function script_exists() {
  local script_name="$1"
  yq eval ".scripts[] | select(.name == \"$script_name\")" ~/.config/bamon/config.yaml >/dev/null 2>&1
}

# Get all enabled scripts
function get_all_scripts() {
  yq eval '.scripts[] | select(.enabled == true) | .name' ~/.config/bamon/config.yaml 2>/dev/null
}

# Check if a script is enabled
function is_script_enabled() {
  local script_name="$1"
  local enabled=$(yq eval ".scripts[] | select(.name == \"$script_name\") | .enabled" ~/.config/bamon/config.yaml 2>/dev/null)
  if [[ "$enabled" == "true" ]]; then
    echo "true"
  else
    echo "false"
  fi
}

# Get script last execution time (timestamp)
function get_script_last_execution_time() {
  local script_name="$1"
  local tracking_file="$HOME/.config/bamon/script_execution_times.json"
  
  if [[ -f "$tracking_file" ]]; then
    jq -r ".\"$script_name\" // 0" "$tracking_file" 2>/dev/null || echo "0"
  else
    echo "0"
  fi
}

# Get script last status
function get_script_last_status() {
  local script_name="$1"
  local data_file="$HOME/.config/bamon/performance_data.json"
  
  if [[ -f "$data_file" ]]; then
    local last_status=$(jq -r ".last_status.\"$script_name\" // \"UNKNOWN\"" "$data_file" 2>/dev/null)
    if [[ "$last_status" == "true" ]]; then
      echo "SUCCESS"
    elif [[ "$last_status" == "false" ]]; then
      echo "FAILED"
    else
      echo "UNKNOWN"
    fi
  else
    echo "UNKNOWN"
  fi
}

# Get script last duration
function get_script_last_duration() {
  local script_name="$1"
  local data_file="$HOME/.config/bamon/performance_data.json"
  
  if [[ -f "$data_file" ]]; then
    jq -r ".execution_times.\"$script_name\" // 0" "$data_file" 2>/dev/null || echo "0"
  else
    echo "0"
  fi
}

# Get script last error (placeholder - would need to be implemented)
function get_script_last_error() {
  local script_name="$1"
  local data_file="$HOME/.config/bamon/performance_data.json"
  
  if [[ -f "$data_file" ]]; then
    jq -r ".last_errors.\"$script_name\" // \"\"" "$data_file" 2>/dev/null || echo ""
  else
    echo ""
  fi
}

# Get script exit code
function get_script_exit_code() {
  local script_name="$1"
  local data_file="$HOME/.config/bamon/performance_data.json"
  
  if [[ -f "$data_file" ]]; then
    local exit_code=$(jq -r ".last_exit_codes.\"$script_name\" // \"N/A\"" "$data_file" 2>/dev/null)
    if [[ "$exit_code" == "null" || "$exit_code" == "" ]]; then
      echo "N/A"
    else
      echo "$exit_code"
    fi
  else
    echo "N/A"
  fi
}

# Calculate time since last execution
function calculate_time_since() {
  local last_run_timestamp="$1"
  local current_time=$(date +%s)
  local time_diff=$((current_time - last_run_timestamp))
  
  if [[ $time_diff -lt 60 ]]; then
    echo "${time_diff}s ago"
  elif [[ $time_diff -lt 3600 ]]; then
    echo "$((time_diff / 60))m ago"
  elif [[ $time_diff -lt 86400 ]]; then
    echo "$((time_diff / 3600))h ago"
  else
    echo "$((time_diff / 86400))d ago"
  fi
}

# Calculate next execution time
function calculate_next_execution() {
  local last_run_timestamp="$1"
  local interval="$2"
  local current_time=$(date +%s)
  
  # Parse interval (assume it's in seconds for now)
  local next_run_time=$((last_run_timestamp + interval))
  
  if [[ $next_run_time -lt $current_time ]]; then
    echo "Overdue"
  else
    local time_until=$((next_run_time - current_time))
    if [[ $time_until -lt 60 ]]; then
      echo "In ${time_until}s"
    elif [[ $time_until -lt 3600 ]]; then
      echo "In $((time_until / 60))m"
    elif [[ $time_until -lt 86400 ]]; then
      echo "In $((time_until / 3600))h"
    else
      echo "In $((time_until / 86400))d"
    fi
  fi
}

# Format duration in human-readable format
function format_duration() {
  local duration="$1"
  
  if [[ $duration -lt 1 ]]; then
    echo "<1s"
  elif [[ $duration -lt 60 ]]; then
    echo "${duration}s"
  elif [[ $duration -lt 3600 ]]; then
    echo "$((duration / 60))m $((duration % 60))s"
  else
    echo "$((duration / 3600))h $((duration / 60 % 60))m"
  fi
}

# Format timestamp in human-readable format
function format_timestamp() {
  local timestamp="$1"
  
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    date -r "$timestamp" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "Invalid timestamp"
  else
    # Linux
    date -d "@$timestamp" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "Invalid timestamp"
  fi
}

# Call the main function when this file is executed
status_command