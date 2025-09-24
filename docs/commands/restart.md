# restart Command

Restart the BAMON daemon process.

## Syntax

```bash
bamon restart [options]
```

## Options

| Option | Short | Description |
|--------|-------|-------------|
| `--daemon` | `-d` | Run in background (daemon mode) |
| `--config` | `-c` | Specify custom config file path |

## Examples

### Restart Daemon

```bash
# Restart daemon in background
bamon restart --daemon
```

**Output:**
```
BAMON daemon restarted successfully
PID: 12346
Log file: ~/.local/share/bamon/logs/bamon.log
```

### Restart with Custom Config

```bash
# Restart with custom configuration
bamon restart --daemon --config /path/to/config.yaml
```

**Output:**
```
BAMON daemon restarted successfully
Configuration: /path/to/config.yaml
PID: 12346
Log file: ~/.local/share/bamon/logs/bamon.log
```

## Related Commands

- **[start](start.md)** - Start the daemon process
- **[stop](stop.md)** - Stop the daemon process
- **[status](status.md)** - Check daemon status
