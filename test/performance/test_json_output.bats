#!/usr/bin/env bats
# test/performance/test_json_output.bats

load "../container/test_helpers.sh"

setup() {
  # Common setup
  install_bamon "user"
}

@test "Status command JSON output is valid" {
  run run_bamon "user" status --json
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== STATUS JSON TEST FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "STDERR: $stderr"
    echo "========================="
  fi
  
  [ "$status" -eq 0 ]
  
  # Verify JSON is valid
  echo "$output" | jq . >/dev/null
  
  # Debug output on JSON validation failure
  if [ "$status" -ne 0 ]; then
    echo "=== JSON VALIDATION FAILED ==="
    echo "JSON output: $output"
    echo "jq exit code: $status"
    echo "========================="
  fi
  
  [ "$status" -eq 0 ]
  
  # Check JSON structure
  local json_output="$output"
  local scripts_type=$(echo "$json_output" | jq '.scripts | type')
  local jq_exit_code=$?
  
  # Debug output on structure check failure
  if [ "$jq_exit_code" -ne 0 ] || [ "$scripts_type" != '"array"' ]; then
    echo "=== JSON STRUCTURE CHECK FAILED ==="
    echo "jq exit code: $jq_exit_code"
    echo "Expected: \"array\""
    echo "Got: $scripts_type"
    echo "Full JSON output:"
    echo "$json_output" | jq .
    echo "========================="
  fi
  
  [ "$jq_exit_code" -eq 0 ]
  [ "$scripts_type" = '"array"' ]
}

@test "Performance command JSON output is valid" {
  # Start daemon first
  run run_bamon "user" start --daemon
  [ "$status" -eq 0 ]
  
  # Wait for daemon to start
  wait_for_daemon
  [ "$?" -eq 0 ]
  
  run run_bamon "user" performance --json
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== PERFORMANCE JSON TEST FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "STDERR: $stderr"
    echo "========================="
  fi
  
  [ "$status" -eq 0 ]
  
  # Verify JSON is valid
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
  
  # Check JSON structure
  local json_output="$output"
  local system_metrics_type=$(echo "$json_output" | jq '.system_metrics | type')
  local jq_exit_code2=$?
  
  # Debug output on structure check failure
  if [ "$jq_exit_code2" -ne 0 ] || [ "$system_metrics_type" != '"object"' ]; then
    echo "=== JSON STRUCTURE CHECK FAILED ==="
    echo "jq exit code: $jq_exit_code2"
    echo "Expected: \"object\""
    echo "Got: $system_metrics_type"
    echo "Full output:"
    echo "$json_output" 
    echo "Full JSON output:"
    echo "$json_output" | jq .
    echo "========================="
  fi
  
  [ "$jq_exit_code2" -eq 0 ]
  [ "$system_metrics_type" = '"object"' ]
}

@test "JSON output contains expected fields" {
  run run_bamon "user" status --json
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== STATUS JSON FIELDS TEST FAILED ==="
    echo "Exit code: $status"
    echo "STDOUT: $output"
    echo "STDERR: $stderr"
    echo "========================="
  fi
  
  [ "$status" -eq 0 ]
  
  # Check for expected fields
  local json_output="$output"
  local has_name=$(echo "$json_output" | jq '.scripts[0] | has("name")')
  local jq_exit_code1=$?
  
  # Debug output on field check failure
  if [ "$jq_exit_code1" -ne 0 ] || [ "$has_name" != "true" ]; then
    echo "=== NAME FIELD CHECK FAILED ==="
    echo "jq exit code: $jq_exit_code1"
    echo "Expected: true"
    echo "Got: $has_name"
    echo "Scripts array:"
    echo "$json_output" | jq '.scripts'
    echo "First script:"
    echo "$json_output" | jq '.scripts[0]'
    echo "========================="
  fi
  
  [ "$jq_exit_code1" -eq 0 ]
  [ "$has_name" = "true" ]
  
  local has_result=$(echo "$json_output" | jq '.scripts[0] | has("result")')
  local jq_exit_code2=$?
  
  # Debug output on field check failure
  if [ "$jq_exit_code2" -ne 0 ] || [ "$has_result" != "true" ]; then
    echo "=== RESULT FIELD CHECK FAILED ==="
    echo "jq exit code: $jq_exit_code2"
    echo "Expected: true"
    echo "Got: $has_result"
    echo "Scripts array:"
    echo "$json_output" | jq '.scripts'
    echo "First script:"
    echo "$json_output" | jq '.scripts[0]'
    echo "========================="
  fi
  
  [ "$jq_exit_code2" -eq 0 ]
  [ "$has_result" = "true" ]
}
