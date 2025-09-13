#!/usr/bin/env bash
# Stop command implementation

# Source the library functions

# Parse command line arguments
FORCE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --force|-f)
      FORCE=true
      shift
      ;;
    --help|-h)
      # Help is handled by the main script
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Initialize configuration
init_config
load_config

# Stop the daemon
stop_daemon "$FORCE"