# now Command

Execute all enabled scripts immediately (manual trigger).

## Syntax

```bash
bamon now [options]
```

## Options

| Option | Short | Argument | Description |
|--------|-------|----------|-------------|
| `--name` | `-n` | script_name | Execute only specific script by name |

## Examples

### Execute All Scripts

```bash
# Execute all enabled scripts immediately
bamon now
```

**Output:**
```
Executing all enabled scripts
=============================

Executing script: health_check
===============================
200
Script execution completed successfully

Executing script: disk_usage
=============================
45
Script execution completed successfully

All scripts executed successfully
```

### Execute Specific Script

```bash
# Execute only the health_check script
bamon now --name health_check
```

**Output:**
```
Executing script: health_check
===============================
200
Script execution completed successfully
```

### Script Execution Failure

```bash
# When a script fails
bamon now --name failing_script
```

**Output:**
```
Executing script: failing_script
===============================
Script execution failed
```

## Use Cases

### Manual Testing

```bash
# Test a script before enabling it
bamon add test_script --command "echo 'Hello World'" --disabled
bamon now --name test_script
bamon remove test_script
```

### Emergency Execution

```bash
# Run critical scripts immediately
bamon now --name backup_script
bamon now --name health_check
```

### Debugging

```bash
# Test script execution for debugging
bamon now --name problematic_script
# Check the output and fix issues
```

## Execution Environment

Scripts executed with `bamon now` run in the same environment as scheduled execution:

- **Sandboxed execution** with resource limits
- **Timeout protection** (configurable per script)
- **Resource monitoring** and logging
- **Error handling** and status reporting

## Related Commands

- **[status](status.md)** - Check script execution status
- **[start](start.md)** - Start daemon for scheduled execution
- **[add](add.md)** - Add scripts to monitor
- **[list](list.md)** - List all configured scripts

## Troubleshooting

### Script Not Found

```bash
# Check if script exists
bamon list --name script_name

# List all scripts
bamon list
```

### Execution Failures

```bash
# Check script status
bamon status --name script_name

# View detailed status
bamon status --verbose --name script_name
```

### Permission Issues

```bash
# Check if daemon is running
bamon status

# Start daemon if needed
bamon start --daemon
```
