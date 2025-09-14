#!/usr/bin/env bats
# test/daemon/test_daemon_execution.bats

load "../container/test_helpers.sh"

setup() {
  # Common setup
  install_bamon "user"
  
  # Add test script
  run run_bamon "user" add test_script --command "echo 'executed' > /tmp/test_execution" --interval 5
  [ "$status" -eq 0 ]
}

@test "Daemon starts successfully" {
  run run_bamon "user" start --daemon
  [ "$status" -eq 0 ]
  
  # Wait for daemon to start
  wait_for_daemon
  [ "$?" -eq 0 ]
}

@test "Daemon executes scripts at specified intervals" {
  # Start daemon
  run run_bamon "user" start --daemon
  [ "$status" -eq 0 ]
  
  # Wait for daemon to start
  wait_for_daemon
  [ "$?" -eq 0 ]
  
  # Wait for execution
  sleep 10
  
  # Check if script was executed
  [ -f "/tmp/test_execution" ]
  run cat "/tmp/test_execution"
  [ "$output" = "executed" ]
}

@test "Daemon stops successfully" {
  # Start daemon
  run run_bamon "user" start --daemon
  [ "$status" -eq 0 ]
  
  # Wait for daemon to start
  wait_for_daemon
  [ "$?" -eq 0 ]
  
  # Stop daemon
  run run_bamon "user" stop
  [ "$status" -eq 0 ]
  
  # Wait a bit for cleanup
  sleep 2
  
  # Verify daemon is stopped
  if [[ -f "$BAMON_CONFIG_DIR/bamon.pid" ]]; then
    local pid=$(cat "$BAMON_CONFIG_DIR/bamon.pid")
    ! kill -0 "$pid" 2>/dev/null
  fi
}

@test "Daemon restart works" {
  # Start daemon
  run run_bamon "user" start --daemon
  [ "$status" -eq 0 ]
  
  # Wait for daemon to start
  wait_for_daemon
  [ "$?" -eq 0 ]
  
  # Restart daemon
  run run_bamon "user" restart
  [ "$status" -eq 0 ]
  
  # Wait for daemon to restart
  wait_for_daemon
  [ "$?" -eq 0 ]
}
