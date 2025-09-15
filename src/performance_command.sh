#!/usr/bin/env bash
# Performance command for bamon

# Libraries are included via bashly custom_includes

# Initialize configuration
init_config

# get_enabled_scripts function is provided by the main library

# Parse command line arguments using bashly args array
VERBOSE="${args[--verbose]:-false}"
FORMAT="${args[--format]:-table}"

# Handle --json flag
if [[ "${args[--json]:-}" == "1" ]]; then
  FORMAT="json"
fi

# Handle case when args array is not available (direct function call)
if [[ -z "${args[--verbose]:-}" && -n "${1:-}" ]]; then
  # Fallback to manual parsing if args array is not available
  while [[ $# -gt 0 ]]; do
    case $1 in
      --verbose|-v)
        VERBOSE=true
        shift
        ;;
      --format|-f)
        FORMAT="$2"
        shift 2
        ;;
      --json)
        FORMAT="json"
        shift
        ;;
      --help|-h)
        echo "Usage: bamon performance [options]"
        echo ""
        echo "Options:"
        echo "  --verbose, -v     Show detailed performance information"
        echo "  --format, -f      Output format: table, json (default: table)"
        echo "  --json            Output in JSON format"
        echo "  --help, -h        Show this help message"
        echo ""
        echo "Examples:"
        echo "  bamon performance              # Show basic performance metrics"
        echo "  bamon performance --verbose    # Show detailed metrics"
        echo "  bamon performance --json       # Output in JSON format"
        exit 0
        ;;
      *)
        echo "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
    esac
  done
fi

# Check if daemon is running
if ! is_daemon_running; then
  echo "Error: Daemon is not running"
  echo "Start the daemon with: bamon start --daemon"
  exit 1
fi

# Generate performance report
if [[ "$FORMAT" == "json" ]]; then
  # Load performance data
  load_performance_data
  
  # JSON format output
  echo "{"
  echo "  \"timestamp\": \"$(date -Iseconds)\","
  echo "  \"daemon_status\": \"running\","
  echo "  \"system_metrics\": {"
  
  # System metrics
  local first=true
  while IFS=: read -r metric value; do
    if [[ -n "$metric" && -n "$value" ]]; then  # Skip empty lines
      if [[ "$first" == "true" ]]; then
        first=false
      else
        echo ","
      fi
      echo -n "    \"$metric\": $value"
    fi
  done < <(collect_performance_metrics)
  echo ""
  
  echo "  },"
  echo "  \"script_performance\": {"
  
  # Script performance
  local first=true
  local script_count=0
  for script_name in $(get_enabled_scripts); do
    if [[ -n "$script_name" ]]; then  # Skip empty lines
      if [[ "$first" == "true" ]]; then
        first=false
      else
        echo ","
      fi
      local avg_time=$(get_script_avg_execution_time "$script_name")
      local failures=$(get_script_failure_count "$script_name")
      echo -n "    \"$script_name\": {\"avg_time\": \"${avg_time}s\", \"failures\": $failures}"
      script_count=$((script_count + 1))
    fi
  done
  echo ""
  
  echo "  }"
  echo "}"
else
  # Table format output (default)
  generate_performance_report
  
  if [[ "$VERBOSE" == "true" ]]; then
    echo ""
    echo "=== Detailed System Information ==="
    echo "Performance Monitoring: $(is_performance_monitoring_enabled && echo "Enabled" || echo "Disabled")"
    echo "Load Threshold: $(get_load_threshold)"
    echo "Scheduling Optimization: $(is_scheduling_optimized && echo "Enabled" || echo "Disabled")"
  fi
fi
