# add Command

Add a new script to monitor with specified command and interval.

## Syntax

```bash
bamon add <name> [options]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `name` | Yes | Script name/ID (must be unique) |

## Options

| Option | Short | Argument | Required | Description |
|--------|-------|----------|----------|-------------|
| `--command` | `-c` | command | Yes | Bash command/code to execute |
| `--interval` | `-i` | seconds | No | Execution interval in seconds (default: 60) |
| `--description` | `-d` | text | No | Description of what the script does |
| `--enabled` | | | No | Set script as enabled (default) |
| `--disabled` | | | No | Set script as disabled |

## Examples

### Basic Script Addition

```bash
# Add a simple health check script
bamon add health_check --command "curl -s -o /dev/null -w '%{http_code}' https://httpbin.org/status/200"
```

**Output:**
```
Script 'health_check' added successfully
Command: curl -s -o /dev/null -w '%{http_code}' https://httpbin.org/status/200
Interval: 60s (default)
Status: enabled
```

### Custom Interval

```bash
# Add a disk usage monitor with custom interval
bamon add disk_check \
  --command "df -h / | awk 'NR==2 {print \$5}' | sed 's/%//'" \
  --interval 300 \
  --description "Check disk usage every 5 minutes"
```

**Output:**
```
Script 'disk_check' added successfully
Command: df -h / | awk 'NR==2 {print $5}' | sed 's/%//'
Interval: 300s
Description: Check disk usage every 5 minutes
Status: enabled
```

### Disabled Script

```bash
# Add a script that's initially disabled
bamon add maintenance_script \
  --command "systemctl restart nginx" \
  --interval 3600 \
  --description "Restart Nginx hourly" \
  --disabled
```

**Output:**
```
Script 'maintenance_script' added successfully
Command: systemctl restart nginx
Interval: 3600s
Description: Restart Nginx hourly
Status: disabled
```

### Complex Command

```bash
# Add a script with complex command
bamon add memory_check \
  --command "free -m | awk '/^Mem:/ {print \$3/\$2 * 100.0}' | awk '{if(\$1>85) exit 1; else exit 0}'" \
  --interval 120 \
  --description "Alert if memory usage exceeds 85%"
```

## Command Validation

BAMON validates commands before adding them:

```bash
# Invalid command (missing required option)
bamon add test_script
# Error: --command is required

# Duplicate name
bamon add existing_script --command "echo test"
# Error: Script 'existing_script' already exists
```

## Script Naming

### Valid Names

- Alphanumeric characters: `health_check`, `disk_usage`, `api_monitor`
- Underscores: `system_health`, `user_count`
- Numbers: `check_1`, `monitor_v2`

### Invalid Names

- Spaces: `health check` (use underscores instead)
- Special characters: `health-check!` (use underscores instead)
- Reserved words: `status`, `add`, `remove` (BAMON command names)

## Best Practices

### Script Design

1. **Use descriptive names**: `health_check` instead of `hc`
2. **Include descriptions**: Help others understand the script's purpose
3. **Test commands manually**: Verify they work before adding
4. **Use appropriate intervals**: Balance monitoring frequency with system load
5. **Handle errors gracefully**: Scripts should exit with appropriate codes

### Example Scripts

```bash
# HTTP health check
bamon add api_health \
  --command "curl -s -o /dev/null -w '%{http_code}' https://api.example.com/health" \
  --interval 30 \
  --description "Check API health every 30 seconds"

# Disk space monitoring
bamon add disk_space \
  --command "df -h / | awk 'NR==2 {print \$5}' | sed 's/%//' | awk '{if(\$1>90) exit 1; else exit 0}'" \
  --interval 300 \
  --description "Alert if disk usage exceeds 90%"

# Service status check
bamon add nginx_status \
  --command "systemctl is-active nginx" \
  --interval 60 \
  --description "Check if Nginx service is running"
```

## Related Commands

- **[list](list.md)** - List all configured scripts
- **[remove](remove.md)** - Remove a script from monitoring
- **[status](status.md)** - Check script execution status
- **[config](config.md)** - Manage configuration

## Troubleshooting

### Common Issues

**Script not executing**: Check if script is enabled
```bash
bamon list --enabled-only
```

**Command syntax errors**: Test command manually first
```bash
# Test the command
curl -s -o /dev/null -w '%{http_code}' https://httpbin.org/status/200

# Then add it
bamon add test --command "curl -s -o /dev/null -w '%{http_code}' https://httpbin.org/status/200"
```

**Duplicate name error**: Use a different name or remove existing script
```bash
# Check existing scripts
bamon list

# Remove if needed
bamon remove old_script
```
