#!/usr/bin/env bats
# test/performance/test_performance_monitoring.bats

load "../container/test_helpers.sh"

setup() {
  # Common setup
  install_bamon "user"
}

@test "Performance command shows system metrics" {
  run run_bamon "user" performance
  [ "$status" -eq 0 ]
  [[ "$output" == *"Performance Report"* ]]
  [[ "$output" == *"System Metrics"* ]]
}

@test "Performance command shows JSON output" {
  run run_bamon "user" performance --json
  [ "$status" -eq 0 ]
  
  # Verify JSON output
  echo "$output" | jq . >/dev/null
  [ "$status" -eq 0 ]
}

@test "Performance monitoring tracks script execution" {
  # Add a script
  run run_bamon "user" add test_script --command "echo 'test'" --interval 5
  [ "$status" -eq 0 ]
  
  # Start daemon
  run run_bamon "user" start --daemon
  [ "$status" -eq 0 ]
  
  # Wait for daemon to start
  wait_for_daemon
  [ "$?" -eq 0 ]
  
  # Wait for execution
  sleep 10
  
  # Check performance data
  [ -f "$BAMON_CONFIG_DIR/performance_data.json" ]
  
  # Verify performance data contains script info
  run jq '.script_execution_times | has("test_script")' "$BAMON_CONFIG_DIR/performance_data.json"
  [ "$status" -eq 0 ]
  [ "$output" = "true" ]
}
