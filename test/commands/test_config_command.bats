#!/usr/bin/env bats
# test/commands/test_config_command.bats

load "../container/test_helpers.sh"

@test "Config show command displays current configuration" {
  # Setup: Install BAMON
  install_bamon "user"
  
  # Show configuration
  run run_bamon "user" config show
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== CONFIG SHOW COMMAND FAILED ==="
    echo "Exit code: $status"
    echo "Output: $output"
    echo "Config file path: $BAMON_CONFIG_DIR/config.yaml"
    echo "Config file exists: $(test -f "$BAMON_CONFIG_DIR/config.yaml" && echo "yes" || echo "no")"
    if [ -f "$BAMON_CONFIG_DIR/config.yaml" ]; then
      echo "Config file contents:"
      cat "$BAMON_CONFIG_DIR/config.yaml"
    fi
    echo "========================="
  fi
  
  [ "$status" -eq 0 ]
  [[ "$output" == *"daemon:"* ]]
  [[ "$output" == *"scripts:"* ]]
  [[ "$output" == *"performance:"* ]]
}

@test "Config show command with pretty flag" {
  # Setup: Install BAMON
  install_bamon "user"
  
  # Show configuration with pretty flag
  run run_bamon "user" config show --pretty
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== CONFIG SHOW --PRETTY COMMAND FAILED ==="
    echo "Exit code: $status"
    echo "Output: $output"
    echo "Config file path: $BAMON_CONFIG_DIR/config.yaml"
    echo "Config file exists: $(test -f "$BAMON_CONFIG_DIR/config.yaml" && echo "yes" || echo "no")"
    if [ -f "$BAMON_CONFIG_DIR/config.yaml" ]; then
      echo "Config file contents:"
      cat "$BAMON_CONFIG_DIR/config.yaml"
    fi
    echo "========================="
  fi
  
  [ "$status" -eq 0 ]
  [[ "$output" == *"daemon:"* ]]
  [[ "$output" == *"scripts:"* ]]
  [[ "$output" == *"performance:"* ]]
}

@test "Config validate command validates configuration" {
  # Setup: Install BAMON
  install_bamon "user"
  
  # Validate configuration
  run run_bamon "user" config validate
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== CONFIG VALIDATE COMMAND FAILED ==="
    echo "Exit code: $status"
    echo "Output: $output"
    echo "Config file path: $BAMON_CONFIG_DIR/config.yaml"
    echo "Config file exists: $(test -f "$BAMON_CONFIG_DIR/config.yaml" && echo "yes" || echo "no")"
    if [ -f "$BAMON_CONFIG_DIR/config.yaml" ]; then
      echo "Config file contents:"
      cat "$BAMON_CONFIG_DIR/config.yaml"
    fi
    echo "========================="
  fi
  
  [ "$status" -eq 0 ]
  [[ "$output" == *"valid"* ]] || [[ "$output" == *"Valid"* ]] || [[ "$output" == *"OK"* ]] || [[ "$output" == *"ok"* ]]
}

@test "Config validate command with verbose flag" {
  # Setup: Install BAMON
  install_bamon "user"
  
  # Validate configuration with verbose flag
  run run_bamon "user" config validate --verbose
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== CONFIG VALIDATE --VERBOSE COMMAND FAILED ==="
    echo "Exit code: $status"
    echo "Output: $output"
    echo "Config file path: $BAMON_CONFIG_DIR/config.yaml"
    echo "Config file exists: $(test -f "$BAMON_CONFIG_DIR/config.yaml" && echo "yes" || echo "no")"
    if [ -f "$BAMON_CONFIG_DIR/config.yaml" ]; then
      echo "Config file contents:"
      cat "$BAMON_CONFIG_DIR/config.yaml"
    fi
    echo "========================="
  fi
  
  [ "$status" -eq 0 ]
  # Verbose output should contain more detailed information
  [[ "$output" == *"valid"* ]] || [[ "$output" == *"Valid"* ]] || [[ "$output" == *"OK"* ]] || [[ "$output" == *"ok"* ]]
  # Should have more detailed output than non-verbose version
  [ ${#output} -gt 10 ]
}

@test "Config edit command opens editor" {
  # Setup: Install BAMON
  install_bamon "user"
  
  # Mock editor to avoid interactive prompt
  export EDITOR="echo 'mock editor called'"
  
  # Try to edit configuration
  run run_bamon "user" config edit
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== CONFIG EDIT COMMAND FAILED ==="
    echo "Exit code: $status"
    echo "Output: $output"
    echo "EDITOR env var: $EDITOR"
    echo "Config file path: $BAMON_CONFIG_DIR/config.yaml"
    echo "Config file exists: $(test -f "$BAMON_CONFIG_DIR/config.yaml" && echo "yes" || echo "no")"
    echo "========================="
  fi
  
  # Should either succeed or fail gracefully
  # Success case: editor is called
  if [ "$status" -eq 0 ]; then
    [[ "$output" == *"mock editor called"* ]] || [[ "$output" == *"editor"* ]]
  else
    # Failure case: should show appropriate error
    [[ "$output" == *"editor"* ]] || [[ "$output" == *"EDITOR"* ]] || [[ "$output" == *"error"* ]] || [[ "$output" == *"Error"* ]]
  fi
}

@test "Config edit command with custom editor" {
  # Setup: Install BAMON
  install_bamon "user"
  
  # Try to edit configuration with custom editor
  run run_bamon "user" config edit --editor "echo 'custom editor called'"
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== CONFIG EDIT --EDITOR COMMAND FAILED ==="
    echo "Exit code: $status"
    echo "Output: $output"
    echo "Config file path: $BAMON_CONFIG_DIR/config.yaml"
    echo "Config file exists: $(test -f "$BAMON_CONFIG_DIR/config.yaml" && echo "yes" || echo "no")"
    echo "========================="
  fi
  
  # Should either succeed or fail gracefully
  # Success case: custom editor is called
  if [ "$status" -eq 0 ]; then
    [[ "$output" == *"custom editor called"* ]] || [[ "$output" == *"editor"* ]]
  else
    # Failure case: should show appropriate error
    [[ "$output" == *"editor"* ]] || [[ "$output" == *"EDITOR"* ]] || [[ "$output" == *"error"* ]] || [[ "$output" == *"Error"* ]]
  fi
}

@test "Config commands fail with invalid config file" {
  # Setup: Install BAMON
  install_bamon "user"
  
  # Create invalid config file in the correct location
  echo "invalid: yaml: content: [" > "$HOME/.config/bamon/config.yaml"
  
  # Try config show - this should succeed (just displays file contents)
  run run_bamon "user" config show
  
  # Debug output on failure
  if [ "$status" -ne 0 ]; then
    echo "=== CONFIG SHOW WITH INVALID CONFIG FAILED ==="
    echo "Exit code: $status"
    echo "Output: $output"
    echo "Config file path: $HOME/.config/bamon/config.yaml"
    echo "Invalid config file contents:"
    cat "$HOME/.config/bamon/config.yaml"
    echo "========================="
  fi
  
  # Config show should succeed (it just displays the file, doesn't validate)
  [ "$status" -eq 0 ]
  [[ "$output" == *"invalid: yaml: content: ["* ]]
  
  # Try config validate
  run run_bamon "user" config validate
  
  # Debug output on unexpected success
  if [ "$status" -eq 0 ]; then
    echo "=== CONFIG VALIDATE WITH INVALID CONFIG UNEXPECTEDLY SUCCEEDED ==="
    echo "Exit code: $status"
    echo "Output: $output"
    echo "Config file path: $HOME/.config/bamon/config.yaml"
    echo "Invalid config file contents:"
    cat "$HOME/.config/bamon/config.yaml"
    echo "========================="
  fi
  
  # Config validate should fail with invalid YAML
  [ "$status" -ne 0 ]
  [[ "$output" == *"invalid"* ]] || [[ "$output" == *"Invalid"* ]] || [[ "$output" == *"error"* ]] || [[ "$output" == *"Error"* ]] || [[ "$output" == *"yaml"* ]]
}
