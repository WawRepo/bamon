#!/usr/bin/env bash
# Performance command for bamon

# Libraries are included via bashly custom_includes

# Initialize configuration
init_config

# get_enabled_scripts function is provided by the main library

# Parse command line arguments
VERBOSE=false
FORMAT="table"

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

# Check if daemon is running
if ! is_daemon_running; then
  echo "Error: Daemon is not running"
  echo "Start the daemon with: bamon start --daemon"
  exit 1
fi

# Generate performance report
if [[ "$FORMAT" == "json" ]]; then
  # JSON format output
  echo "{"
  echo "  \"timestamp\": \"$(date -Iseconds)\","
  echo "  \"daemon_status\": \"running\","
  echo "  \"system_metrics\": {"
  
  # System metrics
  metrics=()
  while IFS=: read -r metric value; do
    metrics+=("    \"$metric\": $value")
  done < <(collect_performance_metrics)
  
  # Join metrics with commas
  metrics_json=$(printf '%s,\n' "${metrics[@]}")
  metrics_json="${metrics_json%,}"  # Remove trailing comma
  echo "$metrics_json"
  
  echo "  },"
  echo "  \"script_performance\": {"
  
  # Script performance
  script_metrics=()
  for script_name in $(get_enabled_scripts); do
    avg_time=$(get_script_avg_execution_time "$script_name")
    failures=$(get_script_failure_count "$script_name")
    script_metrics+=("    \"$script_name\": {\"avg_time\": $avg_time, \"failures\": $failures}")
  done
  
  # Join script metrics with commas
  script_json=$(printf '%s,\n' "${script_metrics[@]}")
  script_json="${script_json%,}"  # Remove trailing comma
  echo "$script_json"
  
  echo "  },"
  echo "  \"cache_status\": {"
  echo "    \"ttl\": $CACHE_TTL,"
  echo "    \"cached_items\": ${#PERFORMANCE_CACHE_KEYS[@]}"
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
    echo "Cache TTL: $(get_cache_ttl) seconds"
    echo "Scheduling Optimization: $(is_scheduling_optimized && echo "Enabled" || echo "Disabled")"
    echo ""
    
    echo "=== Cache Contents ==="
    if [[ ${#PERFORMANCE_CACHE_KEYS[@]} -eq 0 ]]; then
      echo "No cached items"
    else
      for i in "${!PERFORMANCE_CACHE_KEYS[@]}"; do
        local key="${PERFORMANCE_CACHE_KEYS[$i]}"
        local value="${PERFORMANCE_CACHE_VALUES[$i]}"
        local cached_time="${PERFORMANCE_CACHE_TIMES[$i]}"
        local current_time=$(date +%s)
        local age=$((current_time - cached_time))
        echo "  $key: $value (age: ${age}s)"
      done
    fi
  fi
fi
