#!/usr/bin/env bash
# Logging functions for bamon

# Libraries are included via bashly custom_includes

# Simple logging - no debug levels needed
# All important information is logged

# Format log message
function format_log_message() {
  local message="$1"
  local script_name="$2"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  
  if [[ -n "$script_name" ]]; then
    echo "[$timestamp] [$script_name] $message"
  else
    echo "[$timestamp] [bamon] $message"
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
  
  local formatted_message=$(format_log_message "$message" "$script_name")
  echo "$formatted_message" >&2
  write_to_log "$formatted_message"
}

# Log warning message
function log_warn() {
  local message="$1"
  local script_name="$2"
  
  local formatted_message=$(format_log_message "$message" "$script_name")
  echo "$formatted_message" >&2
  write_to_log "$formatted_message"
}

# Log info message
function log_info() {
  local message="$1"
  local script_name="$2"
  
  local formatted_message=$(format_log_message "$message" "$script_name")
  echo "$formatted_message" >&2
  write_to_log "$formatted_message"
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