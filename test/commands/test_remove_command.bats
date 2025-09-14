#!/usr/bin/env bats
# test/commands/test_remove_command.bats

load "../container/test_helpers.sh"

setup() {
  # Common setup
  install_bamon "user"
}

@test "Remove command removes existing script" {
  # Add a script first
  run run_bamon "user" add test_script --command "echo 'test'" --interval 60
  [ "$status" -eq 0 ]
  
  # Verify it exists
  run yq e '.scripts[] | select(.name == "test_script")' "$HOME/.config/bamon/config.yaml"
  [ "$status" -eq 0 ]
  [ -n "$output" ]
  
  # Remove it
  run run_bamon "user" remove test_script
  [ "$status" -eq 0 ]
  
  # Verify it's gone
  run yq e '.scripts[] | select(.name == "test_script")' "$HOME/.config/bamon/config.yaml"
  [ "$status" -ne 0 ]
}

@test "Remove command fails for non-existent script" {
  run run_bamon "user" remove non_existent_script
  [ "$status" -ne 0 ]
}

@test "Remove command preserves other scripts" {
  # Add two scripts
  run run_bamon "user" add test_script1 --command "echo 'test1'" --interval 60
  [ "$status" -eq 0 ]
  run run_bamon "user" add test_script2 --command "echo 'test2'" --interval 60
  [ "$status" -eq 0 ]
  
  # Remove one
  run run_bamon "user" remove test_script1
  [ "$status" -eq 0 ]
  
  # Verify the other still exists
  run yq e '.scripts[] | select(.name == "test_script2")' "$HOME/.config/bamon/config.yaml"
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}
