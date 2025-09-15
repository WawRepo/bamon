#!/usr/bin/env bats
# test/daemon/test_daemon_logging.bats

load "../container/test_helpers.sh"

setup() {
  # Common setup
  install_bamon "user"
  
  # Add test script
  run run_bamon "user" add test_script --command "echo 'test output'" --interval 5
  [ "$status" -eq 0 ]
}

@test "Daemon creates log file" {
  # Start daemon
  run run_bamon "user" start --daemon
  [ "$status" -eq 0 ]
  
  # Wait for daemon to start
  wait_for_daemon
  [ "$?" -eq 0 ]
  
  # Get log file path from config
  local log_file="/tmp/bamon.log"
  if [ -f "$HOME/.config/bamon/config.yaml" ]; then
    local config_log_file=$(yq e '.daemon.log_file' "$HOME/.config/bamon/config.yaml" 2>/dev/null)
    if [ -n "$config_log_file" ] && [ "$config_log_file" != "null" ]; then
      log_file="$config_log_file"
    fi
  fi
  
  # Debug output on failure
  if [ ! -f "$log_file" ]; then
    echo "=== LOG FILE TEST FAILED ==="
    echo "Expected log file: $log_file"
    echo "BAMON_CONFIG_DIR: $BAMON_CONFIG_DIR"
    echo "Config file exists: $(test -f "$HOME/.config/bamon/config.yaml" && echo "yes" || echo "no")"
    if [ -f "$HOME/.config/bamon/config.yaml" ]; then
      echo "Config file contents:"
      cat "$HOME/.config/bamon/config.yaml"
    fi
    echo "Directory contents:"
    ls -la "$(dirname "$log_file")" || echo "Directory does not exist"
    echo "Daemon status:"
    run run_bamon "user" status
    echo "Status output: $output"
    echo "========================="
  fi
  
  # Check log file exists
  [ -f "$log_file" ]
}

@test "Daemon logs script execution" {
  # Start daemon
  run run_bamon "user" start --daemon
  [ "$status" -eq 0 ]
  
  # Wait for daemon to start
  wait_for_daemon
  [ "$?" -eq 0 ]
  
  # Wait for execution
  sleep 10
  
  # Get log file path from config
  local log_file="/tmp/bamon.log"
  if [ -f "$HOME/.config/bamon/config.yaml" ]; then
    local config_log_file=$(yq e '.daemon.log_file' "$HOME/.config/bamon/config.yaml" 2>/dev/null)
    if [ -n "$config_log_file" ] && [ "$config_log_file" != "null" ]; then
      log_file="$config_log_file"
    fi
  fi
  
  # Check log contains execution info
  run grep "test_script" "$log_file"
  
  # Debug output on failure
  if [ "$status" -ne 0 ] || [ -z "$output" ]; then
    echo "=== SCRIPT EXECUTION LOG TEST FAILED ==="
    echo "Exit code: $status"
    echo "Grep output: $output"
    echo "Log file: $log_file"
    echo "Log file exists: $(test -f "$log_file" && echo "yes" || echo "no")"
    if [ -f "$log_file" ]; then
      echo "Log file contents:"
      cat "$log_file"
    else
      echo "Log file does not exist"
    fi
    echo "Daemon status:"
    run run_bamon "user" status
    echo "Status output: $output"
    echo "========================="
  fi
  
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "Daemon logs errors appropriately" {
  # Add failing script
  run run_bamon "user" add failing_script --command "exit 1" --interval 5
  [ "$status" -eq 0 ]
  
  # Start daemon
  run run_bamon "user" start --daemon
  [ "$status" -eq 0 ]
  
  # Wait for daemon to start
  wait_for_daemon
  [ "$?" -eq 0 ]
  
  # Wait for execution
  sleep 10
  
  # Get log file path from config
  local log_file="/tmp/bamon.log"
  if [ -f "$HOME/.config/bamon/config.yaml" ]; then
    local config_log_file=$(yq e '.daemon.log_file' "$HOME/.config/bamon/config.yaml" 2>/dev/null)
    if [ -n "$config_log_file" ] && [ "$config_log_file" != "null" ]; then
      log_file="$config_log_file"
    fi
  fi
  
  # Check log contains error info
  run grep "failing_script" "$log_file"
  
  # Debug output on failure
  if [ "$status" -ne 0 ] || [ -z "$output" ]; then
    echo "=== ERROR LOG TEST FAILED ==="
    echo "Exit code: $status"
    echo "Grep output: $output"
    echo "Log file: $log_file"
    echo "Log file exists: $(test -f "$log_file" && echo "yes" || echo "no")"
    if [ -f "$log_file" ]; then
      echo "Log file contents:"
      cat "$log_file"
    else
      echo "Log file does not exist"
    fi
    echo "Daemon status:"
    run run_bamon "user" status
    echo "Status output: $output"
    echo "========================="
  fi
  
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}
