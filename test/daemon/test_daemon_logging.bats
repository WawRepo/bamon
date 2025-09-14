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
  
  # Check log file exists
  [ -f "$BAMON_CONFIG_DIR/bamon.log" ]
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
  
  # Check log contains execution info
  run grep "test_script" "$BAMON_CONFIG_DIR/bamon.log"
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
  
  # Check log contains error info
  run grep "failing_script" "$BAMON_CONFIG_DIR/bamon.log"
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}
