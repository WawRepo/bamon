# API Reference

Technical details and API reference for BAMON developers.

## Configuration API

### Configuration Structure

```yaml
# BAMON Configuration Schema
daemon:
  default_interval: integer          # Default execution interval in seconds
  log_file: string                   # Log file path (supports ~ expansion)
  pid_file: string                   # PID file path (supports ~ expansion)
  max_concurrent: integer            # Maximum concurrent script executions

sandbox:
  timeout: integer                   # Script execution timeout in seconds
  max_cpu_time: integer              # Maximum CPU time in seconds
  max_file_size: integer              # Maximum file size in KB
  max_virtual_memory: integer        # Maximum virtual memory in KB

performance:
  enable_monitoring: boolean         # Enable performance monitoring
  load_threshold: float              # System load threshold for optimization
  optimize_scheduling: boolean       # Enable intelligent scheduling

scripts:
  - name: string                     # Unique script identifier
    command: string                  # Bash command to execute
    interval: integer                # Execution interval in seconds
    enabled: boolean                 # Whether script is enabled
    description: string              # Human-readable description
```

### Configuration Validation

```bash
# Validate configuration syntax
bamon config validate

# Validate with verbose output
bamon config validate --verbose
```

## CLI API

### Command Structure

```bash
bamon <command> [options] [arguments]
```

### Global Options

| Option | Type | Description |
|--------|------|-------------|
| `--help` | flag | Show help message for the command |
| `--version` | flag | Show version information |
| `--config` | string | Specify custom configuration file path |

### Status Command API

```bash
bamon status [options]
```

**Options:**
- `--verbose` (`-v`): Show detailed information including full output
- `--failed-only` (`-f`): Show only failed scripts
- `--json` (`-j`): Output in JSON format
- `--name` (`-n`): Check status of a specific script

**JSON Output Format:**
```json
{
  "scripts": [
    {
      "name": "string",
      "status": "success|failed|running|disabled|never",
      "last_run": "ISO8601_timestamp",
      "next_run": "ISO8601_timestamp",
      "interval": "integer",
      "command": "string",
      "output": "string",
      "error": "string"
    }
  ]
}
```

### Add Command API

```bash
bamon add <name> [options]
```

**Required Arguments:**
- `name`: Script name/ID (must be unique)

**Options:**
- `--command` (`-c`): Bash command/code to execute (required)
- `--interval` (`-i`): Execution interval in seconds (default: 60)
- `--description` (`-d`): Description of what the script does
- `--enabled`: Set script as enabled (default)
- `--disabled`: Set script as disabled

### Remove Command API

```bash
bamon remove <name> [options]
```

**Required Arguments:**
- `name`: Script name/ID to remove

**Options:**
- `--force` (`-f`): Remove without confirmation

### List Command API

```bash
bamon list [options]
```

**Options:**
- `--enabled-only` (`-e`): Show only enabled scripts
- `--disabled-only` (`-d`): Show only disabled scripts
- `--json`: Output in JSON format

### Now Command API

```bash
bamon now [options]
```

**Options:**
- `--name` (`-n`): Execute only specific script by name

### Daemon Commands API

#### Start Command
```bash
bamon start [options]
```

**Options:**
- `--daemon` (`-d`): Run in background (daemon mode)
- `--config` (`-c`): Specify custom config file path

#### Stop Command
```bash
bamon stop [options]
```

**Options:**
- `--force` (`-f`): Force kill the daemon

#### Restart Command
```bash
bamon restart [options]
```

**Options:**
- `--daemon` (`-d`): Run in background (daemon mode)
- `--config` (`-c`): Specify custom config file path

### Performance Command API

```bash
bamon performance [options]
```

**Options:**
- `--verbose` (`-v`): Show detailed performance information
- `--format` (`-f`): Output format (table, json)
- `--json`: Output in JSON format

**JSON Output Format:**
```json
{
  "system": {
    "load_average": "float",
    "memory_usage": "float",
    "disk_usage": "float",
    "cpu_usage": "float"
  },
  "bamon": {
    "active_scripts": "integer",
    "total_executions": "integer",
    "failed_executions": "integer",
    "average_execution_time": "float"
  }
}
```

### Config Command API

#### Config Show
```bash
bamon config show [options]
```

**Options:**
- `--pretty` (`-p`): Pretty print the YAML output

#### Config Edit
```bash
bamon config edit [options]
```

**Options:**
- `--editor` (`-e`): Specify editor to use (default: EDITOR env var or vi)

#### Config Validate
```bash
bamon config validate [options]
```

**Options:**
- `--verbose` (`-v`): Show detailed validation information

#### Config Reset
```bash
bamon config reset [options]
```

**Options:**
- `--force` (`-f`): Reset without confirmation prompt

## Environment Variables

### Configuration Override

| Variable | Type | Description |
|----------|------|-------------|
| `BAMON_CONFIG_FILE` | string | Override default configuration file path |
| `BAMON_VERBOSE` | boolean | Enable verbose logging (true/false) |
| `BAMON_LOG_FILE` | string | Override default log file path |

### Usage Examples

```bash
# Use custom configuration file
export BAMON_CONFIG_FILE="/path/to/custom/config.yaml"
bamon status

# Enable verbose logging
export BAMON_VERBOSE=true
bamon start --daemon

# Custom log file
export BAMON_LOG_FILE="/var/log/bamon/custom.log"
bamon start --daemon
```

## Exit Codes

### Standard Exit Codes

| Code | Description |
|------|-------------|
| 0 | Success |
| 1 | General error |
| 2 | Configuration error |
| 3 | Script execution error |
| 4 | Daemon already running |
| 5 | Daemon not running |

### Script Exit Codes

Scripts should follow standard Unix exit codes:

| Code | Description |
|------|-------------|
| 0 | Success |
| 1 | General error |
| 2 | Misuse of shell builtins |
| 126 | Command invoked cannot execute |
| 127 | Command not found |
| 128 | Invalid exit argument |
| 130 | Script terminated by Ctrl+C |

## File System API

### Default File Locations

#### User Installation
- **Binary**: `~/.local/bin/bamon`
- **Configuration**: `~/.config/bamon/config.yaml`
- **Logs**: `~/.local/share/bamon/logs/bamon.log`
- **PID**: `~/.local/share/bamon/bamon.pid`
- **History**: `~/.config/bamon/execution_history.json`

#### System Installation
- **Binary**: `/usr/local/bin/bamon`
- **Configuration**: `/etc/bamon/config.yaml`
- **Logs**: `/var/log/bamon/bamon.log`
- **PID**: `/var/run/bamon.pid`
- **History**: `/var/lib/bamon/execution_history.json`

### File Permissions

```bash
# Binary permissions
chmod 755 /usr/local/bin/bamon

# Configuration permissions
chmod 644 /etc/bamon/config.yaml

# Log directory permissions
chmod 755 /var/log/bamon/
chmod 644 /var/log/bamon/bamon.log

# PID file permissions
chmod 644 /var/run/bamon.pid
```

## Logging API

### Log Format

```
[timestamp] [script_name] message
```

**Example:**
```
[2024-01-15 10:30:15] [health_check] Script executed successfully
[2024-01-15 10:30:15] [health_check] Output: 200
[2024-01-15 10:30:15] [disk_usage] Script execution failed: exit code 1
```

### Log Levels

- **INFO**: General information
- **WARN**: Warning messages
- **ERROR**: Error messages
- **DEBUG**: Debug information (when verbose enabled)

### Log Rotation

```bash
# Manual log rotation
mv ~/.local/share/bamon/logs/bamon.log ~/.local/share/bamon/logs/bamon.log.old
touch ~/.local/share/bamon/logs/bamon.log
bamon restart
```

## Integration API

### Webhook Integration

```bash
# Send webhook on script failure
bamon add webhook_alert \
  --command "curl -X POST -H 'Content-Type: application/json' -d '{\"status\":\"down\",\"service\":\"api\"}' https://monitoring.example.com/webhook" \
  --interval 300
```

### Slack Integration

```bash
# Send Slack notification
bamon add slack_alert \
  --command "curl -X POST -H 'Content-type: application/json' --data '{\"text\":\"System alert: Service is down\"}' https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK" \
  --interval 300
```

### Email Integration

```bash
# Send email notification
bamon add email_alert \
  --command "echo 'System alert: Service is down' | mail -s 'BAMON Alert' admin@example.com" \
  --interval 600
```

## Performance API

### System Metrics

```bash
# Get system performance metrics
bamon performance --json | jq '.system'
```

### BAMON Metrics

```bash
# Get BAMON performance metrics
bamon performance --json | jq '.bamon'
```

### Custom Metrics

```bash
# Add custom performance monitoring
bamon add custom_metrics \
  --command "echo 'custom_metric_value' | curl -X POST -d @- https://metrics.example.com/api/metrics" \
  --interval 60
```

## Security API

### Sandbox Configuration

```yaml
sandbox:
  timeout: 30                    # Script execution timeout
  max_cpu_time: 60               # Maximum CPU time
  max_file_size: 10240           # Maximum file size (KB)
  max_virtual_memory: 102400     # Maximum virtual memory (KB)
```

### Resource Limits

```bash
# Check current resource usage
bamon performance --verbose

# Monitor resource usage over time
watch -n 1 'bamon performance --json | jq ".system"'
```

## Development API

### Testing Scripts

```bash
# Test script execution
bamon now --name script_name

# Test with custom configuration
bamon --config test-config.yaml now --name script_name
```

### Debug Mode

```bash
# Enable debug mode
export BAMON_VERBOSE=true
bamon start --daemon

# Check debug logs
tail -f ~/.local/share/bamon/logs/bamon.log
```

### Configuration Management

```bash
# Backup configuration
cp ~/.config/bamon/config.yaml ~/.config/bamon/config.yaml.backup

# Restore configuration
cp ~/.config/bamon/config.yaml.backup ~/.config/bamon/config.yaml
bamon restart
```
