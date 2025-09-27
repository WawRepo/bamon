#!/usr/bin/env bats
# test/commands/test_log_command.bats

load "../container/test_helpers.sh"

setup() {
  # Common setup
  install_bamon "user"
  
  # Create a test log file with sample entries
  # Use the log file path from the test configuration
  local log_file="/tmp/bamon.log"
  mkdir -p "$(dirname "$log_file")"
  
  # Create sample log entries with different levels and timestamps
  cat > "$log_file" << 'EOF'
[ERROR] [2025-09-28 01:00:00] [test_script] Test error message
[WARN] [2025-09-28 01:00:01] [test_script] Test warning message
[INFO] [2025-09-28 01:00:02] [test_script] Test info message
[DEBUG] [2025-09-28 01:00:03] [test_script] Test debug message
[INFO] [2025-09-28 01:00:04] [github_check] Script 'github_check' completed successfully in 1s
[ERROR] [2025-09-28 01:00:05] [disk_check] Script 'disk_check' failed with exit code 1
[INFO] [2025-09-28 01:00:06] [bamon] Daemon started successfully
[WARN] [2025-09-28 01:00:07] [bamon] High system load detected
EOF
}

@test "Log command shows help" {
  run run_bamon "user" log --help
  
  [ "$status" -eq 0 ]
  [[ "$output" == *"log"* ]]
  [[ "$output" == *"--lines"* ]]
  [[ "$output" == *"--follow"* ]]
  [[ "$output" == *"--level"* ]]
  [[ "$output" == *"--search"* ]]
  [[ "$output" == *"--info"* ]]
}

@test "Log command displays recent entries by default" {
  run run_bamon "user" log --lines 3
  
  [ "$status" -eq 0 ]
  [[ "$output" == *"failed with exit code"* ]]
  [[ "$output" == *"Daemon started successfully"* ]]
  [[ "$output" == *"High system load detected"* ]]
}

@test "Log command filters by single level" {
  run run_bamon "user" log --level ERROR --lines 5
  
  [ "$status" -eq 0 ]
  [[ "$output" == *"failed with exit code"* ]]
  # Should not contain other levels
  [[ "$output" != *"Test warning message"* ]]
  [[ "$output" != *"Test info message"* ]]
}

@test "Log command filters by multiple levels" {
  run run_bamon "user" log --level ERROR,WARN --lines 5
  
  [ "$status" -eq 0 ]
  [[ "$output" == *"failed with exit code"* ]]
  [[ "$output" == *"High system load detected"* ]]
  # Should not contain other levels
  [[ "$output" != *"Test info message"* ]]
}

@test "Log command searches for keywords" {
  run run_bamon "user" log --search "github" --lines 5
  
  [ "$status" -eq 0 ]
  [[ "$output" == *"github_check"* ]]
  [[ "$output" == *"completed successfully"* ]]
}

@test "Log command searches with regex" {
  run run_bamon "user" log --search ".*failed.*" --regex --lines 5
  
  [ "$status" -eq 0 ]
  [[ "$output" == *"failed with exit code"* ]]
}

@test "Log command shows log file information" {
  run run_bamon "user" log --info
  
  [ "$status" -eq 0 ]
  [[ "$output" == *"Log File Information"* ]]
  [[ "$output" == *"Location:"* ]]
  [[ "$output" == *"Size:"* ]]
  [[ "$output" == *"Lines:"* ]]
}

@test "Log command outputs JSON format" {
  run run_bamon "user" log --format json --lines 2
  
  [ "$status" -eq 0 ]
  [[ "$output" == *"{"* ]]
  [[ "$output" == *"timestamp"* ]]
  [[ "$output" == *"level"* ]]
  [[ "$output" == *"message"* ]]
}

@test "Log command disables color output" {
  run run_bamon "user" log --no-color --lines 2
  
  [ "$status" -eq 0 ]
  # Should not contain ANSI color codes
  [[ "$output" != *"033"* ]]
  [[ "$output" != *"\\033"* ]]
}

@test "Log command handles missing log file gracefully" {
  # Remove the log file
  rm -f "/tmp/bamon.log"
  
  run run_bamon "user" log --lines 5
  
  [ "$status" -eq 1 ]
  [[ "$output" == *"Log file not found"* ]]
}

@test "Log command handles empty log file" {
  # Create empty log file
  echo "" > "/tmp/bamon.log"
  
  run run_bamon "user" log --lines 5
  
  [ "$status" -eq 0 ]
  # Should not fail, just return empty output
}

@test "Log command with context lines" {
  run run_bamon "user" log --search "github" --before 1 --after 1 --lines 5
  
  [ "$status" -eq 0 ]
  [[ "$output" == *"completed successfully"* ]]
}

@test "Log command with invalid arguments" {
  run run_bamon "user" log --invalid-flag
  
  [ "$status" -ne 0 ]
}

@test "Log command with zero lines" {
  run run_bamon "user" log --lines 0
  
  [ "$status" -eq 0 ]
  # Should return empty output
  [ -z "$output" ]
}

@test "Log command with large line count" {
  run run_bamon "user" log --lines 100
  
  [ "$status" -eq 0 ]
  # Should return all available lines (8 in our test file)
  [[ "$output" == *"Test error message"* ]]
  [[ "$output" == *"High system load detected"* ]]
}

@test "Log command level filtering with invalid level" {
  run run_bamon "user" log --level INVALID --lines 5
  
  [ "$status" -eq 0 ]
  # Should return empty output since no logs match INVALID level
  [ -z "$output" ]
}

@test "Log command search with no matches" {
  run run_bamon "user" log --search "nonexistent" --lines 5
  
  [ "$status" -eq 0 ]
  # Should return empty output since no logs match
  [ -z "$output" ]
}

@test "Log command combines multiple filters" {
  run run_bamon "user" log --level INFO --search "github" --lines 5
  
  [ "$status" -eq 0 ]
  [[ "$output" == *"github_check"* ]]
  [[ "$output" == *"completed successfully"* ]]
}

@test "Log command handles special characters in search" {
  # Add a log entry with special characters
  echo "[INFO] [2025-09-28 01:00:08] [test_script] Test with special chars: \$@#%^&*()" >> "/tmp/bamon.log"
  
  run run_bamon "user" log --search "special chars" --lines 5
  
  [ "$status" -eq 0 ]
  [[ "$output" == *"special chars"* ]]
}

@test "Log command handles multiline log entries" {
  # Add a multiline log entry
  cat >> "/tmp/bamon.log" << 'EOF'
[INFO] [2025-09-28 01:00:09] [test_script] Multiline log entry:
Line 1
Line 2
Line 3
EOF
  
  run run_bamon "user" log --search "Multiline" --lines 5
  
  [ "$status" -eq 0 ]
  [[ "$output" == *"Multiline log entry"* ]]
}
