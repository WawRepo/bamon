# start Command

Start the BAMON daemon process.

## Syntax

```bash
bamon start [options]
```

## Options

| Option | Short | Description |
|--------|-------|-------------|
| `--daemon` | `-d` | Run in background (daemon mode) |
| `--config` | `-c` | Specify custom config file path |

## Examples

### Start Daemon

```bash
# Start daemon in background
bamon start --daemon
```

**Output:**
```
BAMON daemon started successfully
PID: 12345
Log file: ~/.local/share/bamon/logs/bamon.log
```

### Start with Custom Config

```bash
# Start with custom configuration
bamon start --daemon --config /path/to/config.yaml
```

**Output:**
```
BAMON daemon started successfully
Configuration: /path/to/config.yaml
PID: 12345
Log file: ~/.local/share/bamon/logs/bamon.log
```

## Related Commands

- **[stop](stop.md)** - Stop the daemon process
- **[restart](restart.md)** - Restart the daemon process
- **[status](status.md)** - Check daemon status
