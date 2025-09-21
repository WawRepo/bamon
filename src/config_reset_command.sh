# Load required libraries
source "$(dirname "${BASH_SOURCE[0]}")/lib/config.sh"

# Config reset command
config_reset() {
  local config_file
  local force="${args[--force]:-0}"

  # Get config file path
  config_file=$(get_config_file)

  # Check if config file exists
  if [[ ! -f "$config_file" ]]; then
    echo "No configuration file found at: $config_file"
    echo "Creating new default configuration..."
  else
    # Always create backup if config file exists
    local backup_file="${config_file}.backup.$(date +%Y%m%d_%H%M%S)"
    if cp "$config_file" "$backup_file"; then
      echo "Configuration backed up to: $backup_file"
    else
      echo "Warning: Failed to create backup file"
    fi
  fi

  # Confirm reset unless force flag is used
  if [[ "$force" != "1" ]]; then
    echo "This will reset your configuration to default values."
    echo "Current config file: $config_file"
    echo ""
    read -p "Are you sure you want to continue? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Reset cancelled."
      return 0
    fi
  fi

  # Create default configuration
  create_default_config "$config_file"

  if [[ $? -eq 0 ]]; then
    echo "Configuration reset to default values."
    echo "New config file: $config_file"
    echo ""
    echo "You can now:"
    echo "  - Edit the configuration: bamon config edit"
    echo "  - View the configuration: bamon config show"
    echo "  - Add scripts: bamon add <name> --command '<command>' --interval <seconds>"
  else
    echo "Error: Failed to reset configuration."
    return 1
  fi
}

# Execute the function
config_reset
