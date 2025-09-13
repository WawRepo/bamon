#!/usr/bin/env bash

# Test the memory_check command exactly as it would be executed in sandbox
command="ps aux | awk '{sum+=\$6} END {print int(sum/1024)}'"

echo "Testing command: $command"

# Create temporary directory
temp_dir=$(mktemp -d)
echo "Temp dir: $temp_dir"

# Create temporary script
temp_script="${temp_dir}/script.sh"

cat > "$temp_script" << EOF
#!/usr/bin/env bash
set -e
# Preserve environment variables
export PATH="\$PATH"
# Use full path to common commands
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/homebrew/bin:\$PATH"
# Execute the command using bash directly
bash -c "$command"
EOF

chmod +x "$temp_script"

echo "Script content:"
cat "$temp_script"
echo ""

# Test the script directly
echo "Testing script directly:"
bash "$temp_script"
echo "Exit code: $?"

echo ""

# Test with gtimeout
echo "Testing with gtimeout:"
gtimeout 3s "$temp_script"
echo "Exit code: $?"

echo ""

# Test with ulimit
echo "Testing with ulimit:"
ulimit -t 60
ulimit -f 10240
gtimeout 3s "$temp_script"
echo "Exit code: $?"

# Clean up
rm -rf "$temp_dir"
