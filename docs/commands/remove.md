# remove Command

Remove a script from monitoring.

## Syntax

```bash
bamon remove <name> [options]
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `name` | Yes | Script name/ID to remove |

## Options

| Option | Short | Description |
|--------|-------|-------------|
| `--force` | `-f` | Remove without confirmation |

## Examples

### Basic Removal

```bash
# Remove a script
bamon remove health_check
```

**Output:**
```
Script 'health_check' removed successfully
```

### Force Removal

```bash
# Remove without confirmation
bamon remove old_script --force
```

**Output:**
```
Script 'old_script' removed successfully
```

## Related Commands

- **[add](add.md)** - Add a new script to monitor
- **[list](list.md)** - List all configured scripts
- **[status](status.md)** - Check script execution status
