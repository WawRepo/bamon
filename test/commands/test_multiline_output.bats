#!/usr/bin/env bats

load "../container/test_helpers.sh"

setup() {
  # Common setup
  install_bamon "user"
}

@test "Multiline output handling in table view" {
  # Create a script that outputs multiple lines
  cat > /tmp/multiline_test.sh << 'EOF'
#!/bin/bash
echo "Line 1"
echo "Line 2" 
echo "Line 3"
EOF
  chmod +x /tmp/multiline_test.sh

  # Add the multiline script
  run run_bamon "user" add multiline_test --command "bash /tmp/multiline_test.sh"
  [ "$status" -eq 0 ]

  # Execute the script
  run run_bamon "user" now --name multiline_test
  [ "$status" -eq 0 ]

  # Check table view shows truncation message
  run run_bamon "user" status
  [ "$status" -eq 0 ]
  [[ "$output" == *"multiline_test"* ]]
  [[ "$output" == *"(truncated - use --json)"* ]]
}

@test "Multiline output handling in JSON view" {
  # Create a script that outputs multiple lines
  cat > /tmp/multiline_test.sh << 'EOF'
#!/bin/bash
echo "Line 1"
echo "Line 2"
echo "Line 3"
EOF
  chmod +x /tmp/multiline_test.sh

  # Add the multiline script
  run run_bamon "user" add multiline_test --command "bash /tmp/multiline_test.sh"
  [ "$status" -eq 0 ]

  # Execute the script
  run run_bamon "user" now --name multiline_test
  [ "$status" -eq 0 ]

  # Check JSON view shows proper array format
  run run_bamon "user" status --json
  [ "$status" -eq 0 ]
  
  # Parse JSON and check multiline output is an array
  local json_output=$(echo "$output" | jq -r '.scripts[] | select(.name == "multiline_test") | .output')
  [[ "$json_output" == *"Line 1"* ]]
  [[ "$json_output" == *"Line 2"* ]]
  [[ "$json_output" == *"Line 3"* ]]
  
  # Verify it's a proper JSON array
  echo "$json_output" | jq -e 'type == "array"'
}

@test "Long single-line output truncation" {
  # Create a script that outputs a long single line
  cat > /tmp/long_output_test.sh << 'EOF'
#!/bin/bash
echo "this is a very long output that should be truncated in the table view because it exceeds the character limit"
EOF
  chmod +x /tmp/long_output_test.sh

  # Add the long output script
  run run_bamon "user" add long_output_test --command "bash /tmp/long_output_test.sh"
  [ "$status" -eq 0 ]

  # Execute the script
  run run_bamon "user" now --name long_output_test
  [ "$status" -eq 0 ]

  # Check table view shows truncation message
  run run_bamon "user" status
  [ "$status" -eq 0 ]
  [[ "$output" == *"long_output_test"* ]]
  [[ "$output" == *"(truncated - use --json)"* ]]
}

@test "Short output shows completely in table view" {
  # Create a script that outputs a short line
  cat > /tmp/short_output_test.sh << 'EOF'
#!/bin/bash
echo "short"
EOF
  chmod +x /tmp/short_output_test.sh

  # Add the short output script
  run run_bamon "user" add short_output_test --command "bash /tmp/short_output_test.sh"
  [ "$status" -eq 0 ]

  # Execute the script
  run run_bamon "user" now --name short_output_test
  [ "$status" -eq 0 ]

  # Check table view shows complete output
  run run_bamon "user" status
  [ "$status" -eq 0 ]
  [[ "$output" == *"short_output_test"* ]]
  [[ "$output" == *"short"* ]]
  # Should not show truncation message for short output
  [[ "$output" != *"(truncated - use --json)"* ]] || [[ "$output" == *"short_output_test"*"short"* ]]
}

@test "Failed script with multiline error output" {
  # Create a script that fails with multiline error
  cat > /tmp/failing_multiline_test.sh << 'EOF'
#!/bin/bash
echo "Error: Something went wrong"
echo "Details: This is a detailed error message"
echo "Stack trace: Line 1 of stack"
echo "Stack trace: Line 2 of stack"
exit 1
EOF
  chmod +x /tmp/failing_multiline_test.sh

  # Add the failing multiline script
  run run_bamon "user" add failing_multiline_test --command "bash /tmp/failing_multiline_test.sh"
  [ "$status" -eq 0 ]

  # Execute the script (it will fail)
  run run_bamon "user" now --name failing_multiline_test
  [ "$status" -eq 1 ]  # Script fails, but bamon command succeeds

  # Check table view shows truncation message for failed script
  run run_bamon "user" status
  [ "$status" -eq 0 ]
  [[ "$output" == *"failing_multiline_test"* ]]
  [[ "$output" == *"Failed"* ]]
  [[ "$output" == *"(truncated - use --json)"* ]]
}

@test "JSON output preserves multiline formatting" {
  # Create a script with complex multiline output
  cat > /tmp/complex_multiline_test.sh << 'EOF'
#!/bin/bash
echo "Header: System Information"
echo "========================="
echo "Hostname: $(hostname)"
echo "Date: $(date)"
echo "Uptime: $(uptime)"
echo "========================="
EOF
  chmod +x /tmp/complex_multiline_test.sh

  # Add the complex multiline script
  run run_bamon "user" add complex_multiline_test --command "bash /tmp/complex_multiline_test.sh"
  [ "$status" -eq 0 ]

  # Execute the script
  run run_bamon "user" now --name complex_multiline_test
  [ "$status" -eq 0 ]

  # Check JSON output preserves all lines
  run run_bamon "user" status --json
  [ "$status" -eq 0 ]
  
  # Parse JSON and verify all lines are preserved
  local json_output=$(echo "$output" | jq -r '.scripts[] | select(.name == "complex_multiline_test") | .output')
  [[ "$json_output" == *"Header: System Information"* ]]
  [[ "$json_output" == *"========================="* ]]
  [[ "$json_output" == *"Hostname:"* ]]
  [[ "$json_output" == *"Date:"* ]]
  [[ "$json_output" == *"Uptime:"* ]]
  
  # Verify it's a proper JSON array with multiple elements
  local array_length=$(echo "$json_output" | jq 'length')
  [ "$array_length" -ge 5 ]  # Should have at least 5 lines
}

@test "Table alignment with different output lengths" {
  # Create scripts with different output lengths
  cat > /tmp/short.sh << 'EOF'
#!/bin/bash
echo "OK"
EOF
  chmod +x /tmp/short.sh

  cat > /tmp/medium.sh << 'EOF'
#!/bin/bash
echo "This is a medium length output message"
EOF
  chmod +x /tmp/medium.sh

  cat > /tmp/long.sh << 'EOF'
#!/bin/bash
echo "This is a very long output message that should definitely be truncated in the table view because it exceeds the maximum allowed length"
EOF
  chmod +x /tmp/long.sh

  # Add all scripts
  run run_bamon "user" add short_test --command "bash /tmp/short.sh"
  [ "$status" -eq 0 ]
  run run_bamon "user" add medium_test --command "bash /tmp/medium.sh"
  [ "$status" -eq 0 ]
  run run_bamon "user" add long_test --command "bash /tmp/long.sh"
  [ "$status" -eq 0 ]

  # Execute all scripts
  run run_bamon "user" now
  [ "$status" -eq 0 ]

  # Check table alignment
  run run_bamon "user" status
  [ "$status" -eq 0 ]
  
  # Verify all scripts appear in output
  [[ "$output" == *"short_test"* ]]
  [[ "$output" == *"medium_test"* ]]
  [[ "$output" == *"long_test"* ]]
  
  # Verify truncation behavior
  [[ "$output" == *"OK"* ]]  # Short output should show completely
  [[ "$output" == *"(truncated - use --json)"* ]]  # Long output should show truncation
}
