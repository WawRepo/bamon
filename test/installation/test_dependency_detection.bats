#!/usr/bin/env bats
# test/installation/test_dependency_detection.bats

load "../container/test_helpers.sh"

@test "Installation succeeds with all dependencies present" {
  # Test that installation works when all dependencies are available
  run install_bamon "user"
  [ "$status" -eq 0 ]
  
  # Verify installation was successful
  verify_installation "user"
}

@test "Installation creates proper directory structure" {
  install_bamon "user"
  
  # Check that all required directories exist
  [ -d "$HOME/.local/bin" ]
  [ -d "$HOME/.config/bamon" ]
  [ -d "$HOME/.config/bamon/samples" ]
}

@test "Installation creates executable binary" {
  install_bamon "user"
  
  # Check that binary is executable
  [ -x "$HOME/.local/bin/bamon" ]
  
  # Check that binary runs
  run "$HOME/.local/bin/bamon" --help
  [ "$status" -eq 0 ]
}
