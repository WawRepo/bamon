#!/usr/bin/env bash
source src/lib/sandbox.sh
# Test the sandbox function with debug
temp_dir=$(mktemp -d)
temp_script="${temp_dir}/script.sh"
cat > "$temp_script" << EOF
#!/usr/bin/env bash
set -e
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/homebrew/bin:\$PATH"
bash -c "echo hello"
EOF
chmod +x "$temp_script"
echo "Script content:"
cat "$temp_script"
echo "---"
# Test with timeout
output=$(timeout 10s "$temp_script" 2>&1)
exit_code=$?
echo "Exit code: $exit_code"
echo "Output: $output"
rm -rf "$temp_dir"
