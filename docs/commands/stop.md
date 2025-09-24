# stop Command

Stop the BAMON daemon process.

## Syntax

```bash
bamon stop [options]
```

## Options

| Option | Short | Description |
|--------|-------|-------------|
| `--force` | `-f` | Force kill the daemon |

## Examples

### Stop Daemon

```bash
# Stop the daemon gracefully
bamon stop
```

**Output:**
```
BAMON daemon stopped successfully
```

### Force Stop

```bash
# Force kill the daemon
bamon stop --force
```

**Output:**
```
BAMON daemon force stopped
```

## Related Commands

- **[start](start.md)** - Start the daemon process
- **[restart](restart.md)** - Restart the daemon process
- **[status](status.md)** - Check daemon status
