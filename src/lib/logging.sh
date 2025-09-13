#!/usr/bin/env bash
# Logging functions for bamon

# Libraries are included via bashly custom_includes

# Log levels
LOG_LEVEL_ERROR=0
LOG_LEVEL_WARN=1
LOG_LEVEL_INFO=2
LOG_LEVEL_DEBUG=3

# Default log level
DEFAULT_LOG_LEVEL=$LOG_LEVEL_INFO

# Get current log level
function get_log_level() {
  local level=$(get_config_value "daemon.log_level" "$DEFAULT_LOG_LEVEL")
  echo "${level:-$DEFAULT_LOG_LEVEL}"
}

# Check if we should log at this level
function should_log() {
  local level="$1"
  local current_level=$(get_log_level)
  
  # Default to INFO level if log level is not set
  if [[ -z "$current_level" || "$current_level" == "null" ]]; then
    current_level=$LOG_LEVEL_INFO
  fi
  
  if [[ $level -le $current_level ]]; then
    return 0
  else
    return 1
  fi
}

# Format log message
function format_log_message() {
  local level="$1"
  local message="$2"
  local script_name="$3"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  
  local level_name
  case $level in
    $LOG_LEVEL_ERROR) level_name="ERROR" ;;
    $LOG_LEVEL_WARN)  level_name="WARN"  ;;
    $LOG_LEVEL_INFO)  level_name="INFO"  ;;
    $LOG_LEVEL_DEBUG) level_name="DEBUG" ;;
    *)                level_name="INFO"  ;;
  esac
  
  if [[ -n "$script_name" ]]; then
    echo "[$timestamp] [$level_name] [$script_name] $message"
  else
    echo "[$timestamp] [$level_name] [bamon] $message"
  fi
}

# Write to log file
function write_to_log() {
  local message="$1"
  local log_file=$(get_log_file)
  
  # Ensure log directory exists
  local log_dir=$(dirname "$log_file")
  mkdir -p "$log_dir" 2>/dev/null
  
  # Write to log file
  echo "$message" >> "$log_file"
}

# Log error message
function log_error() {
  local message="$1"
  local script_name="$2"
  
  if should_log $LOG_LEVEL_ERROR; then
    local formatted_message=$(format_log_message $LOG_LEVEL_ERROR "$message" "$script_name")
    echo "$formatted_message" >&2
    write_to_log "$formatted_message"
  fi
}

# Log warning message
function log_warn() {
  local message="$1"
  local script_name="$2"
  
  if should_log $LOG_LEVEL_WARN; then
    local formatted_message=$(format_log_message $LOG_LEVEL_WARN "$message" "$script_name")
    echo "$formatted_message" >&2
    write_to_log "$formatted_message"
  fi
}

# Log info message
function log_info() {
  local message="$1"
  local script_name="$2"
  
  if should_log $LOG_LEVEL_INFO; then
    local formatted_message=$(format_log_message $LOG_LEVEL_INFO "$message" "$script_name")
    echo "$formatted_message"
    write_to_log "$formatted_message"
  fi
}

# Log debug message
function log_debug() {
  local message="$1"
  local script_name="$2"
  
  if should_log $LOG_LEVEL_DEBUG; then
    local formatted_message=$(format_log_message $LOG_LEVEL_DEBUG "$message" "$script_name")
    echo "$formatted_message" >&2
    write_to_log "$formatted_message"
  fi
}

# Log script execution result
function log_script_result() {
  local script_name="$1"
  local exit_code="$2"
  local output="$3"
  local duration="$4"
  
  if [[ $exit_code -eq 0 ]]; then
    log_info "Script '$script_name' completed successfully in ${duration}s" "$script_name"
  else
    log_error "Script '$script_name' failed with exit code $exit_code in ${duration}s" "$script_name"
  fi
  
  # Log output if it's not empty and not just whitespace
  if [[ -n "$output" && "$output" =~ [^[:space:]] ]]; then
    log_info "Script '$script_name' output: $output" "$script_name"
  fi
}

# Rotate log file if needed
function rotate_log_if_needed() {
  local log_file=$(get_log_file)
  local max_size=$(get_config_value "daemon.max_log_size" "10485760")  # 10MB default
  
  if [[ -f "$log_file" ]]; then
    local file_size=$(stat -f%z "$log_file" 2>/dev/null || echo "0")
    if [[ $file_size -gt $max_size ]]; then
      # Rotate log file
      local backup_file="${log_file}.1"
      if [[ -f "$backup_file" ]]; then
        rm -f "$backup_file"
      fi
      mv "$log_file" "$backup_file"
      log_info "Log file rotated due to size limit"
    fi
  fi
}