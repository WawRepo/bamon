# status Command

Display current status of all configured scripts with execution details.

## Syntax

```bash
bamon status [options]
```

## Options

| Option | Short | Argument | Description |
|--------|-------|----------|-------------|
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
NAME                 STATUS     EXIT CODE  OUTPUT                         DURATION TIME SINCE      NEXT EXECUTION      
=============================================================================================================================
health_check         Success    0          301                            1s       1d ago          Overdue             
disk_check           Success    0          1                              N/A      1d ago          Overdue             
simple_test          Success    0          hello                          N/A      1d ago          Overdue   
```

### Failed Scripts Only

```bash
# Show only failed scripts
bamon status --failed-only
```

**Output:**
```
NAME                 STATUS     EXIT CODE  OUTPUT                         DURATION TIME SINCE      NEXT EXECUTION      
=============================================================================================================================
github_status        Failed     1          Connection timeout             2s       5m ago          In 25s             
```

### Specific Script Status

```bash
# Check status of a specific script
bamon status --name health_check
```

**Output:**
```
NAME                 STATUS     EXIT CODE  OUTPUT                         DURATION TIME SINCE      NEXT EXECUTION      
=============================================================================================================================
health_check         Success    0          301                            1s       1d ago          Overdue             
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
      "enabled": true,
      "lastExecution": "2024-01-15 10:30:15",
      "result": "Success",
      "exitCode": "0",
      "duration": "1s",
      "timeSince": "1d ago",
      "nextExecution": "Overdue",
      "output": "301",
      "error": null
    }
  ]
}
```

## Status Values

| Status | Description |
|--------|-------------|
| `Success` | Script executed successfully |
| `Failed` | Script execution failed |
| `Unknown` | Script status is unknown |

## Use Cases

### Monitoring Dashboard

```bash
# Create a simple monitoring dashboard
bamon status --json | jq -r '.scripts[] | "\(.name): \(.result)"'
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
bamon status | grep -E "(NAME|Success|Failed)"
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
