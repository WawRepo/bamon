#!/usr/bin/env bats
# test/performance/test_performance_monitoring.bats

load "../container/test_helpers.sh"

setup() {
  # Common setup
  install_bamon "user"
}

@test "Performance command shows system metrics" {
  # Start daemon first
  run run_bamon "user" start --daemon
  [ "$status" -eq 0 ]
  
  # Wait for daemon to start
  wait_for_daemon
  [ "$?" -eq 0 ]
  
  run run_bamon "user" performance
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== PERFORMANCE COMMAND TEST FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "STDERR: $stderr"
    echo "========================="
  fi
  
  [ "$status" -eq 0 ]
  
  # Debug output on content check failure
  if [[ "$output" != *"Performance Report"* ]]; then
    echo "=== PERFORMANCE REPORT CHECK FAILED ==="
    echo "Expected: *Performance Report*"
    echo "Got: $output"
    echo "========================="
  fi
  
  [[ "$output" == *"Performance Report"* ]]
  
  if [[ "$output" != *"System Metrics"* ]]; then
    echo "=== SYSTEM METRICS CHECK FAILED ==="
    echo "Expected: *System Metrics*"
    echo "Got: $output"
    echo "========================="
  fi
  
  [[ "$output" == *"System Metrics"* ]]
}

@test "Performance command shows JSON output" {
  # Start daemon first
  run run_bamon "user" start --daemon
  [ "$status" -eq 0 ]
  
  # Wait for daemon to start
  wait_for_daemon
  [ "$?" -eq 0 ]
  
  run run_bamon "user" performance --json
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== PERFORMANCE JSON COMMAND TEST FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "STDERR: $stderr"
    echo "========================="
  fi
  
  [ "$status" -eq 0 ]
  
  # Verify JSON output
  local json_validation=$(echo "$output" | jq . 2>&1)
  local jq_exit_code=$?
  
  # Debug output on JSON validation failure
  if [ "$jq_exit_code" -ne 0 ]; then
    echo "=== JSON VALIDATION FAILED ==="
    echo "JSON output: $output"
    echo "jq exit code: $jq_exit_code"
    echo "jq error: $json_validation"
    echo "Raw output (first 500 chars):"
    echo "$output" | head -c 500
    echo ""
    echo "========================="
  fi
  
  [ "$jq_exit_code" -eq 0 ]
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
  
  # Get the performance data file location
  # The performance data file is stored at $HOME/.config/bamon/performance_data.json
  local performance_file="$HOME/.config/bamon/performance_data.json"
  
  # Check performance data
  if [ ! -f "$performance_file" ]; then
    echo "=== PERFORMANCE DATA FILE MISSING ==="
    echo "Expected file: $performance_file"
    echo "BAMON_CONFIG_DIR: $BAMON_CONFIG_DIR"
    echo "HOME: $HOME"
    echo "Directory contents:"
    ls -la "$HOME/.config/bamon/" || echo "Directory does not exist"
    echo "Daemon status:"
    run run_bamon "user" status
    echo "Status output: $output"
    echo "========================="
  fi
  
  [ -f "$performance_file" ]
  
  # Verify performance data contains script info
  run jq '.execution_times | has("test_script")' "$performance_file"
  
  # Debug output on script tracking failure
  if [ "$status" -ne 0 ] || [ "$output" != "true" ]; then
    echo "=== SCRIPT TRACKING CHECK FAILED ==="
    echo "Exit code: $status"
    echo "Expected: true"
    echo "Got: $output"
    echo "Performance data file exists: $(test -f "$performance_file" && echo "yes" || echo "no")"
    if [ -f "$performance_file" ]; then
      echo "Performance data contents:"
      cat "$performance_file"
    fi
    echo "========================="
  fi
  
  [ "$status" -eq 0 ]
  [ "$output" = "true" ]
}
