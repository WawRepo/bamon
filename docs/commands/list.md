# list Command

List all configured scripts with their status and details.

## Syntax

```bash
bamon list [options]
```

## Options

| Option | Short | Description |
|--------|-------|-------------|
| `--enabled-only` | `-e` | Show only enabled scripts |
| `--disabled-only` | `-d` | Show only disabled scripts |
| `--json` | `-j` | Output in JSON format |

## Examples

### List All Scripts

```bash
# Show all configured scripts
bamon list
```

**Output:**
```
Configured Scripts
=================

Name            Status    Interval    Description
health_check    enabled   30s         HTTP health check
disk_usage      enabled   300s        Monitor disk usage
maintenance     disabled  3600s       Hourly maintenance
```

### Enabled Scripts Only

```bash
# Show only enabled scripts
bamon list --enabled-only
```

**Output:**
```
Enabled Scripts
===============

Name            Interval    Description
health_check    30s         HTTP health check
disk_usage      300s        Monitor disk usage
```

### JSON Output

```bash
# Get list in JSON format
bamon list --json
```

**Output:**
```json
{
  "scripts": [
    {
      "name": "health_check",
      "command": "curl -s https://httpbin.org/status/200",
      "interval": 30,
      "enabled": true,
      "description": "HTTP health check"
    },
    {
      "name": "disk_usage",
      "command": "df -h / | awk 'NR==2 {print $5}' | sed 's/%//'",
      "interval": 300,
      "enabled": true,
      "description": "Monitor disk usage"
    }
  ]
}
```

## Related Commands

- **[add](add.md)** - Add a new script to monitor
- **[remove](remove.md)** - Remove a script from monitoring
- **[status](status.md)** - Check script execution status
