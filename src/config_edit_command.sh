# Load required libraries
source "$(dirname "${BASH_SOURCE[0]}")/lib/config.sh"

# Config edit command implementation
local editor="${args[--editor]:-${EDITOR:-vi}}"
local config_file

# Get config file path
config_file=$(get_config_file)

if [[ ! -f "$config_file" ]]; then
  echo "Error: Configuration file not found at $config_file"
  echo "Please create a configuration file or run 'bamon start' to initialize one."
  exit 1
fi

# Check if editor exists
if ! command -v "$editor" >/dev/null 2>&1; then
  echo "Error: Editor '$editor' not found"
  echo "Please install the editor or use --editor to specify a different one"
  exit 1
fi

echo "Opening configuration file in $editor..."
echo "File: $config_file"

# Open editor
"$editor" "$config_file"

# Validate after editing
echo ""
echo "Validating configuration after edit..."
if validate_config_file "$config_file"; then
  echo "✅ Configuration is valid"
else
  echo "❌ Configuration has errors. Please fix them before using BAMON."
  exit 1
fi

