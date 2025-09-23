# Libraries are included via bashly custom_includes

# Config show command implementation
local config_file
local pretty="${args[--pretty]:-0}"

# Get config file path
config_file=$(get_config_file)

if [[ ! -f "$config_file" ]]; then
  echo "Error: Configuration file not found at $config_file"
  echo "Please create a configuration file or run 'bamon start' to initialize one."
  exit 1
fi

if [[ "$pretty" == "1" ]]; then
  # Pretty print with yq
  if command -v yq >/dev/null 2>&1; then
    yq eval '.' "$config_file"
  else
    cat "$config_file"
  fi
else
  cat "$config_file"
fi
