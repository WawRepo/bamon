#!/usr/bin/env bash
# Log Command for BAMON
# View and manage daemon log files with filtering, searching, and real-time following

# Libraries are included via bashly custom_includes

# Default values
DEFAULT_LINES=50
DEFAULT_FORMAT="text"
DEFAULT_COLOR=true

# Initialize variables
LINES="${args[--lines]:-$DEFAULT_LINES}"
FOLLOW="${args[--follow]:-}"
LEVEL="${args[--level]:-}"
SINCE="${args[--since]:-}"
UNTIL="${args[--until]:-}"
SEARCH="${args[--search]:-}"
REGEX="${args[--regex]:-}"
BEFORE="${args[--before]:-}"
AFTER="${args[--after]:-}"
INFO="${args[--info]:-}"
FORMAT="${args[--format]:-$DEFAULT_FORMAT}"
NO_COLOR="${args[--no-color]:-}"

# Main log command function
function log_command() {
  # Handle case when args array is not available (direct function call)
  if [[ -z "${args[--lines]:-}" && -n "${1:-}" ]]; then
    # Parse arguments manually if called directly
    parse_arguments "$@"
  fi
  
  # Load configuration
  if ! load_config; then
    log_error "Failed to load configuration"
    return 1
  fi
  
  # Show help only if explicitly requested
  if [[ -n "${args[--help]:-}" || -n "${args[-h]:-}" ]]; then
    show_log_help
    return 0
  fi
  
  # Handle info flag
  if [[ -n "$INFO" ]]; then
    show_log_info
    return 0
  fi
  
  # Determine log file path
  local log_file=$(get_log_file_path)
  if [[ -z "$log_file" ]]; then
    log_error "No log file found"
    return 1
  fi
  
  # Check if log file exists
  if [[ ! -f "$log_file" ]]; then
    log_error "Log file not found: $log_file"
    return 1
  fi
  
  # Handle follow mode
  if [[ -n "$FOLLOW" ]]; then
    follow_logs "$log_file"
    return 0
  fi
  
  # Display logs with filters
  display_logs "$log_file"
}

# Parse command line arguments manually
function parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      --lines|-n)
        LINES="$2"
        shift 2
        ;;
      --follow|-f)
        FOLLOW="1"
        shift
        ;;
      --level|-l)
        LEVEL="$2"
        shift 2
        ;;
      --since|-s)
        SINCE="$2"
        shift 2
        ;;
      --until|-u)
        UNTIL="$2"
        shift 2
        ;;
      --search|-g)
        SEARCH="$2"
        shift 2
        ;;
      --regex|-r)
        REGEX="1"
        shift
        ;;
      --before|-b)
        BEFORE="$2"
        shift 2
        ;;
      --after|-a)
        AFTER="$2"
        shift 2
        ;;
      --info|-i)
        INFO="1"
        shift
        ;;
      --format|-o)
        FORMAT="$2"
        shift 2
        ;;
      --no-color)
        NO_COLOR="1"
        shift
        ;;
      --help|-h)
        show_log_help
        exit 0
        ;;
      *)
        log_error "Unknown option: $1"
        show_log_help
        return 1
        ;;
    esac
  done
}

# Show help information
function show_log_help() {
  cat << EOF
BAMON Log Command

View and manage daemon log files with filtering, searching, and real-time following.

USAGE:
    bamon log [OPTIONS]

OPTIONS:
    -n, --lines <number>      Number of lines to display (default: 50)
    -f, --follow              Follow log output in real-time (like tail -f)
    -l, --level <levels>      Filter by log level (ERROR, WARN, INFO, DEBUG) - comma separated
    -s, --since <time>        Show logs since time (e.g., '1h', '2d', '2023-01-01')
    -u, --until <time>        Show logs until time (e.g., '1h', '2d', '2023-01-01')
    -g, --search <pattern>    Search for keyword or pattern in logs
    -r, --regex               Treat search pattern as regular expression
    -b, --before <lines>      Show N lines before each match
    -a, --after <lines>       Show N lines after each match
    -i, --info               Show log file information (location, size, etc.)
    -o, --format <format>     Output format: text, json (default: text)
        --no-color           Disable color output
    -h, --help               Show this help message

EXAMPLES:
    bamon log                           # Show last 50 log entries
    bamon log --lines 100               # Show last 100 log entries
    bamon log --follow                  # Follow logs in real-time
    bamon log --level ERROR,WARN       # Show only ERROR and WARN logs
    bamon log --search 'timeout'        # Search for 'timeout' in logs
    bamon log --since '1h' --level ERROR # Show ERROR logs from last hour
    bamon log --info                    # Show log file information

EOF
}

# Get log file path from configuration
function get_log_file_path() {
  local config_file="$HOME/.config/bamon/config.yaml"
  
  # Check if config file exists
  if [[ ! -f "$config_file" ]]; then
    log_warn "Configuration file not found: $config_file"
    echo "$HOME/.local/share/bamon/logs/bamon.log"
    return 0
  fi
  
  # Check if yq is available
  if ! command -v yq >/dev/null 2>&1; then
    log_warn "yq not found, using default log file location"
    echo "$HOME/.local/share/bamon/logs/bamon.log"
    return 0
  fi
  
  # Try to get log file from config
  local log_file=$(yq eval '.daemon.log_file' "$config_file" 2>/dev/null)
  if [[ -n "$log_file" && "$log_file" != "null" ]]; then
    # Expand tilde in path
    echo "${log_file/#\~/$HOME}"
  else
    # Default log file location
    echo "$HOME/.local/share/bamon/logs/bamon.log"
  fi
}

# Show log file information
function show_log_info() {
  local log_file=$(get_log_file_path)
  
  echo "Log File Information"
  echo "==================="
  echo "Location: $log_file"
  
  if [[ -f "$log_file" ]]; then
    local file_size=$(du -h "$log_file" | cut -f1)
    local file_date=$(stat -c %y "$log_file" 2>/dev/null || stat -f %Sm "$log_file" 2>/dev/null)
    local line_count=$(wc -l < "$log_file" 2>/dev/null || echo "0")
    
    echo "Size: $file_size"
    echo "Last Modified: $file_date"
    echo "Lines: $line_count"
    
    # Check for log rotation
    local log_dir=$(dirname "$log_file")
    local rotated_logs=$(find "$log_dir" -name "*.log.*" -o -name "*.log.[0-9]*" 2>/dev/null | wc -l)
    if [[ $rotated_logs -gt 0 ]]; then
      echo "Rotated Logs: $rotated_logs files"
    fi
    
    # Disk usage
    local disk_usage=$(du -sh "$log_dir" 2>/dev/null | cut -f1)
    echo "Directory Size: $disk_usage"
  else
    echo "Status: File not found"
  fi
}

# Follow logs in real-time
function follow_logs() {
  local log_file="$1"
  
  if [[ ! -f "$log_file" ]]; then
    log_error "Log file not found: $log_file"
    return 1
  fi
  
  echo "Following log file: $log_file"
  echo "Press Ctrl+C to stop"
  echo "========================"
  
  # Build the follow command with filters
  local cmd="tail -f \"$log_file\""
  
  # Apply level filter
  if [[ -n "$LEVEL" ]]; then
    local level_pattern=$(echo "$LEVEL" | tr ',' '|')
    cmd="$cmd | grep -E \"\\[($level_pattern)\\]\""
  fi
  
  # Apply search filter
  if [[ -n "$SEARCH" ]]; then
    if [[ -n "$REGEX" ]]; then
      cmd="$cmd | grep -E \"$SEARCH\""
    else
      cmd="$cmd | grep \"$SEARCH\""
    fi
  fi
  
  # Set up signal handler for graceful exit
  trap 'echo -e "\nStopping log follow..."; exit 0' INT
  
  # Execute the follow command
  eval "$cmd"
}

# Display logs with filters
function display_logs() {
  local log_file="$1"
  
  if [[ ! -f "$log_file" ]]; then
    log_error "Log file not found: $log_file"
    return 1
  fi
  
  # Build the command to display logs
  local cmd="tail -n $LINES \"$log_file\""
  
  # Apply level filter
  if [[ -n "$LEVEL" ]]; then
    # Convert comma-separated levels to grep pattern
    local level_pattern=$(echo "$LEVEL" | tr ',' '|')
    cmd="$cmd | grep -E \"\\[($level_pattern)\\]\""
  fi
  
  # Apply time filters
  if [[ -n "$SINCE" || -n "$UNTIL" ]]; then
    cmd=$(apply_time_filters "$cmd" "$log_file")
  fi
  
  # Apply search filter (must be before context filters)
  if [[ -n "$SEARCH" ]]; then
    if [[ -n "$REGEX" ]]; then
      cmd="$cmd | grep -E \"$SEARCH\""
    else
      cmd="$cmd | grep \"$SEARCH\""
    fi
  fi
  
  # Apply context filters (before/after) - must be after search and only if search is provided
  if [[ -n "$SEARCH" && ( -n "$BEFORE" || -n "$AFTER" ) ]]; then
    cmd=$(apply_context_filters "$cmd")
  fi
  
  # Apply output formatting
  if [[ "$FORMAT" == "json" ]]; then
    cmd=$(format_as_json "$cmd")
  elif [[ -z "$NO_COLOR" ]]; then
    cmd=$(add_color_coding "$cmd")
  fi
  
  # Execute the command
  eval "$cmd"
}

# Apply time-based filters
function apply_time_filters() {
  local cmd="$1"
  local log_file="$2"
  
  # For now, return the original command
  # Time filtering would require more complex date parsing
  echo "$cmd"
}

# Apply context filters (before/after lines)
function apply_context_filters() {
  local cmd="$1"
  
  # Only apply context filters if search is provided
  if [[ -n "$SEARCH" ]]; then
    # Add context lines if specified
    if [[ -n "$BEFORE" && -n "$AFTER" ]]; then
      cmd="$cmd | grep -A $AFTER -B $BEFORE \"$SEARCH\""
    elif [[ -n "$BEFORE" ]]; then
      cmd="$cmd | grep -B $BEFORE \"$SEARCH\""
    elif [[ -n "$AFTER" ]]; then
      cmd="$cmd | grep -A $AFTER \"$SEARCH\""
    fi
  fi
  
  echo "$cmd"
}

# Add color coding to log output
function add_color_coding() {
  local cmd="$1"
  
  # Add sed commands for color coding
  cmd="$cmd | sed -E 's/\\[ERROR\\]/\\[\\033[31mERROR\\033[0m\\]/g'"
  cmd="$cmd | sed -E 's/\\[WARN\\]/\\[\\033[33mWARN\\033[0m\\]/g'"
  cmd="$cmd | sed -E 's/\\[INFO\\]/\\[\\033[32mINFO\\033[0m\\]/g'"
  cmd="$cmd | sed -E 's/\\[DEBUG\\]/\\[\\033[36mDEBUG\\033[0m\\]/g'"
  
  echo "$cmd"
}

# Format output as JSON
function format_as_json() {
  local cmd="$1"
  
  # Convert the command to output JSON format
  cmd="$cmd | while IFS= read -r line; do
    if [[ -n \"\$line\" ]]; then
      # Extract timestamp, level, and message
      timestamp=\$(echo \"\$line\" | grep -o '\\[.*\\]' | head -1)
      level=\$(echo \"\$line\" | grep -o '\\[ERROR\\]\\|\\[WARN\\]\\|\\[INFO\\]\\|\\[DEBUG\\]' | head -1)
      message=\$(echo \"\$line\" | sed 's/^\\[.*\\]\\s*//')
      
      echo \"{\\\"timestamp\\\": \\\"\$timestamp\\\", \\\"level\\\": \\\"\$level\\\", \\\"message\\\": \\\"\$message\\\"}\"
    fi
  done"
  
  echo "$cmd"
}

# Call the main function when this file is executed
log_command
