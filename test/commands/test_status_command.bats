#!/usr/bin/env bats
# test/commands/test_status_command.bats

load "../container/test_helpers.sh"

setup() {
  # Common setup
  install_bamon "user"
}

@test "Status command shows help" {
  run run_bamon "user" status --help
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== STATUS HELP COMMAND FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "Config file exists: $(test -f "$HOME/.config/bamon/config.yaml" && echo "yes" || echo "no")"
    echo "=================================="
  fi
  
  [ "$status" -eq 0 ]
  [[ "$output" == *"status"* ]]
}

@test "Status command shows default scripts" {
  run run_bamon "user" status
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== STATUS COMMAND FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "Config file exists: $(test -f "$HOME/.config/bamon/config.yaml" && echo "yes" || echo "no")"
    if [ -f "$HOME/.config/bamon/config.yaml" ]; then
      echo "Config file contents:"
      cat "$HOME/.config/bamon/config.yaml"
    fi
    echo "============================="
  fi
  
  [ "$status" -eq 0 ]
  [[ "$output" == *"health_check"* ]]
  [[ "$output" == *"disk_usage"* ]]
  [[ "$output" == *"github_status"* ]]
}

@test "Status command shows JSON output" {
  run run_bamon "user" status --json
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== STATUS JSON COMMAND FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "Config file exists: $(test -f "$HOME/.config/bamon/config.yaml" && echo "yes" || echo "no")"
    echo "=================================="
  fi
  
  [ "$status" -eq 0 ]
  
  # Verify JSON output
  echo "$output" | jq . >/dev/null
  
  # Debug output on JSON validation failure
  if [ "$status" -ne 0 ]; then
    echo "=== JSON VALIDATION FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "Expected valid JSON but got invalid JSON"
    echo "======================================="
  fi
  
  [ "$status" -eq 0 ]
}

@test "Status command shows failed-only filter" {
  run run_bamon "user" status --failed-only
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== STATUS FAILED-ONLY COMMAND FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "Config file exists: $(test -f "$HOME/.config/bamon/config.yaml" && echo "yes" || echo "no")"
    echo "========================================="
  fi
  
  [ "$status" -eq 0 ]
  # Should show empty or no failed scripts initially
}

@test "Status command shows specific script" {
  run run_bamon "user" status --name health_check
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== STATUS SPECIFIC SCRIPT COMMAND FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "Config file exists: $(test -f "$HOME/.config/bamon/config.yaml" && echo "yes" || echo "no")"
    if [ -f "$HOME/.config/bamon/config.yaml" ]; then
      echo "Config file contents:"
      cat "$HOME/.config/bamon/config.yaml"
    fi
    echo "============================================="
  fi
  
  [ "$status" -eq 0 ]
  [[ "$output" == *"health_check"* ]]
}
