#!/usr/bin/env bats
# test/commands/test_status_command.bats

load "../container/test_helpers.sh"

setup() {
  # Common setup
  install_bamon "user"
}

@test "Status command shows help" {
  run run_bamon "user" status --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"status"* ]]
}

@test "Status command shows default scripts" {
  run run_bamon "user" status
  [ "$status" -eq 0 ]
  [[ "$output" == *"health_check"* ]]
  [[ "$output" == *"disk_usage"* ]]
  [[ "$output" == *"github_status"* ]]
}

@test "Status command shows JSON output" {
  run run_bamon "user" status --json
  [ "$status" -eq 0 ]
  
  # Verify JSON output
  echo "$output" | jq . >/dev/null
  [ "$status" -eq 0 ]
}

@test "Status command shows failed-only filter" {
  run run_bamon "user" status --failed-only
  [ "$status" -eq 0 ]
  # Should show empty or no failed scripts initially
}

@test "Status command shows specific script" {
  run run_bamon "user" status --name health_check
  [ "$status" -eq 0 ]
  [[ "$output" == *"health_check"* ]]
}
