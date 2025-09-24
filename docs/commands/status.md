# status Command

Display current status of all configured scripts with execution details.

## Syntax

```bash
bamon status [options]
```

## Options

| Option | Short | Argument | Description |
|--------|-------|----------|-------------|
| `--verbose` | `-v` | | Show detailed information including full output |
| `--failed-only` | `-f` | | Show only failed scripts |
| `--json` | `-j` | | Output in JSON format |
| `--name` | `-n` | script_name | Check status of a specific script |

## Examples

### Basic Status Check

```bash
# Show status of all scripts
bamon status
```

**Output:**
```
Script Status Report
===================

Name            Status    Last Run           Next Run            Interval
health_check    success   2024-01-15 10:30   2024-01-15 11:00   30s
disk_usage      success   2024-01-15 10:25   2024-01-15 15:25   300s
github_status   failed    2024-01-15 10:20   2024-01-15 10:50   30s
```

### Verbose Output

```bash
# Show detailed status with full output
bamon status --verbose
```

**Output:**
```
Script Status Report
===================

Name: health_check
Status: success
Last Run: 2024-01-15 10:30:15
Next Run: 2024-01-15 11:00:15
Interval: 30s
Command: curl -s https://httpbin.org/status/200
Output:
200

Name: disk_usage
Status: success
Last Run: 2024-01-15 10:25:10
Next Run: 2024-01-15 15:25:10
Interval: 300s
Command: df -h / | awk 'NR==2 {print $5}' | sed 's/%//'
Output:
45
```

### Failed Scripts Only

```bash
# Show only failed scripts
bamon status --failed-only
```

**Output:**
```
Failed Scripts
=============

Name: github_status
Status: failed
Last Run: 2024-01-15 10:20:05
Error: Connection timeout
Command: curl -s https://www.githubstatus.com/api/v2/status.json
```

### Specific Script Status

```bash
# Check status of a specific script
bamon status --name health_check
```

**Output:**
```
Script: health_check
Status: success
Last Run: 2024-01-15 10:30:15
Next Run: 2024-01-15 11:00:15
Interval: 30s
Command: curl -s https://httpbin.org/status/200
```

### JSON Output

```bash
# Get status in JSON format
bamon status --json
```

**Output:**
```json
{
  "scripts": [
    {
      "name": "health_check",
      "status": "success",
      "last_run": "2024-01-15T10:30:15Z",
      "next_run": "2024-01-15T11:00:15Z",
      "interval": 30,
      "command": "curl -s https://httpbin.org/status/200",
      "output": "200"
    },
    {
      "name": "disk_usage",
      "status": "success",
      "last_run": "2024-01-15T10:25:10Z",
      "next_run": "2024-01-15T15:25:10Z",
      "interval": 300,
      "command": "df -h / | awk 'NR==2 {print $5}' | sed 's/%//'",
      "output": "45"
    }
  ]
}
```

## Status Values

| Status | Description |
|--------|-------------|
| `success` | Script executed successfully |
| `failed` | Script execution failed |
| `running` | Script is currently executing |
| `disabled` | Script is disabled |
| `never` | Script has never been executed |

## Use Cases

### Monitoring Dashboard

```bash
# Create a simple monitoring dashboard
bamon status --json | jq -r '.scripts[] | "\(.name): \(.status)"'
```

### Health Check Script

```bash
# Check if any scripts are failing
if bamon status --failed-only --json | jq -e '.scripts | length > 0'; then
    echo "Some monitoring scripts are failing!"
    exit 1
fi
```

### Performance Monitoring

```bash
# Check script execution times
bamon status --verbose | grep -E "(Name|Last Run|Status)"
```

## Related Commands

- **[list](list.md)** - List all configured scripts
- **[now](now.md)** - Execute all scripts immediately
- **[performance](performance.md)** - Show system performance metrics
- **[config](config.md)** - Manage configuration

## Troubleshooting

### No Scripts Found

If `bamon status` shows no scripts:

1. Check if scripts are configured: `bamon list`
2. Verify configuration: `bamon config validate`
3. Check if daemon is running: `bamon start --daemon`

### Status Not Updating

If status information seems outdated:

1. Check daemon status: `bamon status`
2. Restart daemon: `bamon restart`
3. Check logs: `tail -f ~/.local/share/bamon/logs/bamon.log`
