#!/usr/bin/env bash
# Performance Optimization Library for BAMON
# Provides system load monitoring, resource management, and execution optimization
# Requires Bash 4.0+ for associative array support

# Libraries are included via bashly custom_includes

# Performance monitoring variables using associative arrays (Bash 4.0+ feature)
declare -A SCRIPT_EXECUTION_TIMES
declare -A SCRIPT_FAILURE_COUNTS
declare -A SCRIPT_LAST_STATUS
declare -A SCRIPT_LAST_ERROR
declare -A SCRIPT_LAST_OUTPUT
declare -A SCRIPT_LAST_EXIT_CODE
declare -A SYSTEM_LOAD_VALUES

# Persistent storage file for execution data
PERFORMANCE_DATA_FILE="$HOME/.config/bamon/performance_data.json"

# Performance configuration functions
function get_performance_config() {
  local key="$1"
  local default="$2"
  get_config_value "performance.$key" "$default"
}

# Get enabled scripts function (needed for performance reporting)
function get_enabled_scripts() {
  local scripts_json=$(get_all_scripts)
  local script_names=()
  
  # Extract script names from YAML
  while IFS= read -r line; do
    if [[ "$line" =~ ^name:\ (.+)$ ]]; then
      script_names+=("${BASH_REMATCH[1]}")
    fi
  done <<< "$scripts_json"
  
  printf '%s\n' "${script_names[@]}"
}

function is_performance_monitoring_enabled() {
  get_performance_config "enable_monitoring" "true"
}

function get_load_threshold() {
  get_performance_config "load_threshold" "0.8"
}


function is_scheduling_optimized() {
  local result=$(get_performance_config "optimize_scheduling" "true")
  [[ "$result" == "true" ]]
}

# System load monitoring
function get_system_load() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS: use sysctl - extract first number from { 1.91 2.12 2.01 }
    sysctl -n vm.loadavg | sed 's/{ //' | awk '{print $1}'
  else
    # Linux: use /proc/loadavg
    cat /proc/loadavg | cut -d' ' -f1
  fi
}

function get_cpu_cores() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sysctl -n hw.ncpu
  else
    nproc
  fi
}

function is_system_overloaded() {
  if ! is_performance_monitoring_enabled; then
    return 1
  fi
  
  local load=$(get_system_load)
  local cores=$(get_cpu_cores)
  local threshold=$(get_load_threshold)
  local max_load=$(echo "$cores * $threshold" | bc -l)
  
  if (( $(echo "$load > $max_load" | bc -l) )); then
    log_warn "System load is high: $load (threshold: $max_load)"
    return 0  # true, system is overloaded
  fi
  return 1  # false, system is not overloaded
}

# Resource monitoring
function get_memory_usage() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS: use vm_stat
    vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//'
  else
    # Linux: use /proc/meminfo
    free | grep Mem | awk '{print $3/$2 * 100.0}'
  fi
}

function get_disk_usage() {
  df -h / | awk 'NR==2 {print $5}' | sed 's/%//'
}

# Concurrent execution management
function count_running_scripts() {
  local count=0
  local pid_file=$(get_pid_file)
  
  if [[ -f "$pid_file" ]]; then
    local daemon_pid=$(cat "$pid_file")
    if kill -0 "$daemon_pid" 2>/dev/null; then
      count=$(pgrep -P "$daemon_pid" | wc -l)
    fi
  fi
  
  echo "$count"
}

function can_run_more_scripts() {
  local max_concurrent=$(get_max_concurrent)
  local running=$(count_running_scripts)
  
  if [[ $running -ge $max_concurrent ]]; then
    log_debug "At max concurrent capacity: $running/$max_concurrent"
    return 1  # false, at max capacity
  fi
  
  # Check system load
  if is_system_overloaded; then
    return 1  # false, system is overloaded
  fi
  
  return 0  # true, can run more scripts
}


# Script execution tracking using associative arrays (Bash 4.0+)
function track_script_execution() {
  local script_name="$1"
  local execution_time="$2"
  local success="$3"
  local exit_code="${4:-0}"
  local output="${5:-}"
  local error_msg="${6:-}"
  
  # Load existing performance data first
  load_performance_data
  
  # Update execution time
  SCRIPT_EXECUTION_TIMES[$script_name]="$execution_time"
  
  # Update last execution status
  SCRIPT_LAST_STATUS[$script_name]="$success"
  
  # Update last execution details
  SCRIPT_LAST_EXIT_CODE[$script_name]="$exit_code"
  SCRIPT_LAST_OUTPUT[$script_name]="$output"
  SCRIPT_LAST_ERROR[$script_name]="$error_msg"
  
  # Update failure count if script failed
  if [[ "$success" == "false" ]]; then
    local failures="${SCRIPT_FAILURE_COUNTS[$script_name]:-0}"
    SCRIPT_FAILURE_COUNTS[$script_name]=$((failures + 1))
  fi
  
  # Save to persistent storage
  save_performance_data
}

# Save performance data to persistent storage
function save_performance_data() {
  local data_file="$PERFORMANCE_DATA_FILE"
  
  # Create directory if it doesn't exist
  mkdir -p "$(dirname "$data_file")"
  
  # Create JSON data
  local json_data="{"
  json_data+="\"execution_times\":{"
  local first=true
  for key in "${!SCRIPT_EXECUTION_TIMES[@]}"; do
    if [[ "$first" == "true" ]]; then
      first=false
    else
      json_data+=","
    fi
    json_data+="\"$key\":${SCRIPT_EXECUTION_TIMES[$key]}"
  done
  json_data+="},"
  
  json_data+="\"failure_counts\":{"
  first=true
  for key in "${!SCRIPT_FAILURE_COUNTS[@]}"; do
    if [[ "$first" == "true" ]]; then
      first=false
    else
      json_data+=","
    fi
    json_data+="\"$key\":${SCRIPT_FAILURE_COUNTS[$key]}"
  done
  json_data+="},"
  
  json_data+="\"last_status\":{"
  first=true
  for key in "${!SCRIPT_LAST_STATUS[@]}"; do
    if [[ "$first" == "true" ]]; then
      first=false
    else
      json_data+=","
    fi
    json_data+="\"$key\":\"${SCRIPT_LAST_STATUS[$key]}\""
  done
  json_data+="},"
  
  json_data+="\"last_exit_codes\":{"
  first=true
  for key in "${!SCRIPT_LAST_EXIT_CODE[@]}"; do
    if [[ "$first" == "true" ]]; then
      first=false
    else
      json_data+=","
    fi
    json_data+="\"$key\":${SCRIPT_LAST_EXIT_CODE[$key]}"
  done
  json_data+="},"
  
  json_data+="\"last_outputs\":{"
  first=true
  for key in "${!SCRIPT_LAST_OUTPUT[@]}"; do
    if [[ "$first" == "true" ]]; then
      first=false
    else
      json_data+=","
    fi
    # Escape quotes in output
    local escaped_output="${SCRIPT_LAST_OUTPUT[$key]//\"/\\\"}"
    json_data+="\"$key\":\"$escaped_output\""
  done
  json_data+="},"
  
  json_data+="\"last_errors\":{"
  first=true
  for key in "${!SCRIPT_LAST_ERROR[@]}"; do
    if [[ "$first" == "true" ]]; then
      first=false
    else
      json_data+=","
    fi
    # Escape quotes in error message
    local escaped_error="${SCRIPT_LAST_ERROR[$key]//\"/\\\"}"
    json_data+="\"$key\":\"$escaped_error\""
  done
  json_data+="}"
  json_data+="}"
  
  # Save to file
  echo "$json_data" > "$data_file"
}

# Load performance data from persistent storage
function load_performance_data() {
  local data_file="$PERFORMANCE_DATA_FILE"
  
  if [[ -f "$data_file" ]]; then
    # Load execution times
    local execution_times=$(cat "$data_file" | jq -r '.execution_times | to_entries[] | "\(.key)=\(.value)"' 2>/dev/null)
    if [[ -n "$execution_times" ]]; then
      while IFS='=' read -r key value; do
        SCRIPT_EXECUTION_TIMES["$key"]="$value"
      done <<< "$execution_times"
    fi
    
    # Load failure counts
    local failure_counts=$(cat "$data_file" | jq -r '.failure_counts | to_entries[] | "\(.key)=\(.value)"' 2>/dev/null)
    if [[ -n "$failure_counts" ]]; then
      while IFS='=' read -r key value; do
        SCRIPT_FAILURE_COUNTS["$key"]="$value"
      done <<< "$failure_counts"
    fi
    
    # Load last status
    local last_status=$(cat "$data_file" | jq -r '.last_status | to_entries[] | "\(.key)=\(.value)"' 2>/dev/null)
    if [[ -n "$last_status" ]]; then
      while IFS='=' read -r key value; do
        SCRIPT_LAST_STATUS["$key"]="$value"
      done <<< "$last_status"
    fi
    
    # Load last exit codes
    local last_exit_codes=$(cat "$data_file" | jq -r '.last_exit_codes | to_entries[] | "\(.key)=\(.value)"' 2>/dev/null)
    if [[ -n "$last_exit_codes" ]]; then
      while IFS='=' read -r key value; do
        SCRIPT_LAST_EXIT_CODE["$key"]="$value"
      done <<< "$last_exit_codes"
    fi
    
    # Load last outputs
    local last_outputs=$(cat "$data_file" | jq -r '.last_outputs | to_entries[] | "\(.key)=\(.value)"' 2>/dev/null)
    if [[ -n "$last_outputs" ]]; then
      while IFS='=' read -r key value; do
        SCRIPT_LAST_OUTPUT["$key"]="$value"
      done <<< "$last_outputs"
    fi
    
    # Load last errors
    local last_errors=$(cat "$data_file" | jq -r '.last_errors | to_entries[] | "\(.key)=\(.value)"' 2>/dev/null)
    if [[ -n "$last_errors" ]]; then
      while IFS='=' read -r key value; do
        SCRIPT_LAST_ERROR["$key"]="$value"
      done <<< "$last_errors"
    fi
  fi
}

function get_script_avg_execution_time() {
  local script_name="$1"
  echo "${SCRIPT_EXECUTION_TIMES[$script_name]:-0}"
}

function get_script_failure_count() {
  local script_name="$1"
  echo "${SCRIPT_FAILURE_COUNTS[$script_name]:-0}"
}

function get_script_interval() {
  local script_name="$1"
  local script_info=$(get_script "$script_name")
  
  if [[ -z "$script_info" || "$script_info" == "{}" ]]; then
    echo "60"  # default interval
    return
  fi
  
  echo "$script_info" | yq eval '.interval' - 2>/dev/null || echo "60"
}

# Optimized script scheduling
function optimize_schedule() {
  if ! is_scheduling_optimized; then
    get_enabled_scripts
    return
  fi
  
  # Get all enabled scripts with their intervals and execution times
  local scripts_info=()
  
  while IFS= read -r script_name; do
    local interval=$(get_script_interval "$script_name")
    local avg_time=$(get_script_avg_execution_time "$script_name")
    local failures=$(get_script_failure_count "$script_name")
    
    # Calculate priority score (lower is better)
    # Prioritize: shorter intervals, faster execution, fewer failures
    local priority_score=$(echo "$interval + $avg_time - ($failures * 10)" | bc -l)
    
    
    scripts_info+=("$priority_score:$script_name")
  done < <(get_enabled_scripts)
  
  # Sort by priority score and return script names
  printf '%s\n' "${scripts_info[@]}" | sort -n | cut -d: -f2
}

# Performance metrics collection
function collect_performance_metrics() {
  local metrics=()
  
  metrics+=("load:$(get_system_load)")
  metrics+=("memory:$(get_memory_usage)")
  metrics+=("disk:$(get_disk_usage)")
  metrics+=("running_scripts:$(count_running_scripts)")
  metrics+=("max_concurrent:$(get_max_concurrent)")
  
  printf '%s\n' "${metrics[@]}"
}

# Performance report
function generate_performance_report() {
  # Load persistent performance data
  load_performance_data
  
  echo "=== BAMON Performance Report ==="
  echo "Timestamp: $(date)"
  echo ""
  
  echo "System Metrics:"
  collect_performance_metrics | while IFS=: read -r metric value; do
    echo "  $metric: $value"
  done
  echo ""
  
  echo "Script Performance:"
  for script_name in $(get_enabled_scripts); do
    local avg_time=$(get_script_avg_execution_time "$script_name")
    local failures=$(get_script_failure_count "$script_name")
    echo "  $script_name: avg_time=${avg_time}s, failures=$failures"
  done
  echo ""
  
}


# Initialize performance monitoring
function init_performance_monitoring() {
  if is_performance_monitoring_enabled; then
    log_info "Performance monitoring enabled"
  else
    log_info "Performance monitoring disabled"
  fi
}
