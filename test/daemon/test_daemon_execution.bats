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
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== START COMMAND FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "Config file exists: $(test -f "$HOME/.config/bamon/config.yaml" && echo "yes" || echo "no")"
    if [ -f "$HOME/.config/bamon/config.yaml" ]; then
      echo "Config file contents:"
      cat "$HOME/.config/bamon/config.yaml"
    fi
    echo "============================"
  fi
  
  [ "$status" -eq 0 ]
  
  # Wait for daemon to start
  wait_for_daemon
  
  # Debug output on failure
  if [ "$?" -ne 0 ]; then
    echo "=== WAIT FOR DAEMON FAILED ==="
    echo "PID file location: $(yq e '.daemon.pid_file' "$HOME/.config/bamon/config.yaml" 2>/dev/null || echo "not found")"
    echo "PID file exists: $(test -f "$(yq e '.daemon.pid_file' "$HOME/.config/bamon/config.yaml" 2>/dev/null)" && echo "yes" || echo "no")"
    if [ -f "$(yq e '.daemon.pid_file' "$HOME/.config/bamon/config.yaml" 2>/dev/null)" ]; then
      echo "PID file contents:"
      cat "$(yq e '.daemon.pid_file' "$HOME/.config/bamon/config.yaml" 2>/dev/null)"
    fi
    echo "============================="
  fi
  
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
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== STOP COMMAND FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "Config file exists: $(test -f "$HOME/.config/bamon/config.yaml" && echo "yes" || echo "no")"
    if [ -f "$HOME/.config/bamon/config.yaml" ]; then
      echo "Config file contents:"
      cat "$HOME/.config/bamon/config.yaml"
    fi
    echo "PID file location: $(yq e '.daemon.pid_file' "$HOME/.config/bamon/config.yaml" 2>/dev/null || echo "not found")"
    echo "PID file exists: $(test -f "$(yq e '.daemon.pid_file' "$HOME/.config/bamon/config.yaml" 2>/dev/null)" && echo "yes" || echo "no")"
    if [ -f "$(yq e '.daemon.pid_file' "$HOME/.config/bamon/config.yaml" 2>/dev/null)" ]; then
      echo "PID file contents:"
      cat "$(yq e '.daemon.pid_file' "$HOME/.config/bamon/config.yaml" 2>/dev/null)"
    fi
    echo "========================="
  fi
  
  [ "$status" -eq 0 ]
  
  # Wait a bit for cleanup
  sleep 2
  
  # Verify daemon is stopped
  local pid_file="/tmp/bamon.pid"
  if [[ -f "$HOME/.config/bamon/config.yaml" ]]; then
    local config_pid_file=$(yq e '.daemon.pid_file' "$HOME/.config/bamon/config.yaml" 2>/dev/null)
    if [[ -n "$config_pid_file" && "$config_pid_file" != "null" ]]; then
      pid_file="$config_pid_file"
    fi
  fi
  
  if [[ -f "$pid_file" ]]; then
    local pid=$(cat "$pid_file")
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
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== RESTART COMMAND FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "Config file exists: $(test -f "$HOME/.config/bamon/config.yaml" && echo "yes" || echo "no")"
    if [ -f "$HOME/.config/bamon/config.yaml" ]; then
      echo "Config file contents:"
      cat "$HOME/.config/bamon/config.yaml"
    fi
    echo "PID file location: $(yq e '.daemon.pid_file' "$HOME/.config/bamon/config.yaml" 2>/dev/null || echo "not found")"
    echo "PID file exists: $(test -f "$(yq e '.daemon.pid_file' "$HOME/.config/bamon/config.yaml" 2>/dev/null)" && echo "yes" || echo "no")"
    if [ -f "$(yq e '.daemon.pid_file' "$HOME/.config/bamon/config.yaml" 2>/dev/null)" ]; then
      echo "PID file contents:"
      cat "$(yq e '.daemon.pid_file' "$HOME/.config/bamon/config.yaml" 2>/dev/null)"
    fi
    echo "============================="
  fi
  
  [ "$status" -eq 0 ]
  
  # Wait for daemon to restart
  wait_for_daemon
  [ "$?" -eq 0 ]
}
