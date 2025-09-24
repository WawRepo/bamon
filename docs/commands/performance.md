# performance Command

Show system performance metrics and BAMON optimization status.

## Syntax

```bash
bamon performance [options]
```

## Options

| Option | Short | Description |
|--------|-------|-------------|
| `--verbose` | `-v` | Show detailed performance information |
| `--format` | `-f` | Output format (table, json) |
| `--json` | `-j` | Output in JSON format |

## Examples

### Basic Performance

```bash
# Show performance metrics
bamon performance
```

**Output:**
```
System Performance
=================

Load Average: 0.45, 0.52, 0.48
Memory Usage: 45.2%
Disk Usage: 67.8%
CPU Usage: 12.3%

BAMON Performance
=================

Active Scripts: 3
Total Executions: 1,247
Failed Executions: 12
Average Execution Time: 0.8s
```

### Verbose Output

```bash
# Show detailed performance information
bamon performance --verbose
```

**Output:**
```
System Performance
=================

Load Average: 0.45, 0.52, 0.48
Memory Usage: 45.2% (3.6GB / 8.0GB)
Disk Usage: 67.8% (340GB / 500GB)
CPU Usage: 12.3%

BAMON Performance
=================

Active Scripts: 3
Total Executions: 1,247
Failed Executions: 12
Average Execution Time: 0.8s
Last Execution: 2024-01-15 10:30:15
Next Execution: 2024-01-15 10:31:15

Script Performance
==================

health_check: 0.2s avg, 98% success rate
disk_usage: 0.1s avg, 100% success rate
api_health: 1.2s avg, 95% success rate
```

### JSON Output

```bash
# Get performance data in JSON format
bamon performance --json
```

**Output:**
```json
{
  "system": {
    "load_average": [0.45, 0.52, 0.48],
    "memory_usage": 45.2,
    "disk_usage": 67.8,
    "cpu_usage": 12.3
  },
  "bamon": {
    "active_scripts": 3,
    "total_executions": 1247,
    "failed_executions": 12,
    "average_execution_time": 0.8,
    "last_execution": "2024-01-15T10:30:15Z",
    "next_execution": "2024-01-15T10:31:15Z"
  },
  "scripts": [
    {
      "name": "health_check",
      "average_time": 0.2,
      "success_rate": 98,
      "total_executions": 1247,
      "failed_executions": 25
    }
  ]
}
```

## Related Commands

- **[status](status.md)** - Check script execution status
- **[start](start.md)** - Start the daemon process
- **[config](config.md)** - Manage configuration
