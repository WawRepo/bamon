#!/usr/bin/env bats
# test/performance/test_json_output.bats

load "../container/test_helpers.sh"

setup() {
  # Common setup
  install_bamon "user"
}

@test "Status command JSON output is valid" {
  run run_bamon "user" status --json
  [ "$status" -eq 0 ]
  
  # Verify JSON is valid
  echo "$output" | jq . >/dev/null
  [ "$status" -eq 0 ]
  
  # Check JSON structure
  run echo "$output" | jq '.scripts | type'
  [ "$status" -eq 0 ]
  [ "$output" = '"array"' ]
}

@test "Performance command JSON output is valid" {
  run run_bamon "user" performance --json
  [ "$status" -eq 0 ]
  
  # Verify JSON is valid
  echo "$output" | jq . >/dev/null
  [ "$status" -eq 0 ]
  
  # Check JSON structure
  run echo "$output" | jq '.system_metrics | type'
  [ "$status" -eq 0 ]
  [ "$output" = '"object"' ]
}

@test "JSON output contains expected fields" {
  run run_bamon "user" status --json
  [ "$status" -eq 0 ]
  
  # Check for expected fields
  run echo "$output" | jq '.scripts[0] | has("name")'
  [ "$status" -eq 0 ]
  [ "$output" = "true" ]
  
  run echo "$output" | jq '.scripts[0] | has("status")'
  [ "$status" -eq 0 ]
  [ "$output" = "true" ]
}
