# Log Command

The `bamon log` command allows you to view and manage daemon log files with advanced filtering, searching, and real-time following capabilities.

## Usage

```bash
bamon log [OPTIONS]
```

## Options

| Option | Short | Description |
|--------|-------|-------------|
| `--lines <number>` | `-n` | Number of lines to display (default: 50) |
| `--follow` | `-f` | Follow log output in real-time (like tail -f) |
| `--level <levels>` | `-l` | Filter by log level (ERROR, WARN, INFO, DEBUG) - comma separated |
| `--since <time>` | `-s` | Show logs since time (e.g., '1h', '2d', '2023-01-01') |
| `--until <time>` | `-u` | Show logs until time (e.g., '1h', '2d', '2023-01-01') |
| `--search <pattern>` | `-g` | Search for keyword or pattern in logs |
| `--regex` | `-r` | Treat search pattern as regular expression |
| `--before <lines>` | `-b` | Show N lines before each match |
| `--after <lines>` | `-a` | Show N lines after each match |
| `--info` | `-i` | Show log file information (location, size, etc.) |
| `--format <format>` | `-o` | Output format: text, json (default: text) |
| `--no-color` | | Disable color output |

## Examples

### Basic Usage

```bash
# Show recent log entries
bamon log

# Show last 100 lines
bamon log --lines 100

# Follow logs in real-time
bamon log --follow
```

### Filtering by Log Level

```bash
# Show only ERROR level logs
bamon log --level ERROR

# Show ERROR and WARN level logs
bamon log --level ERROR,WARN

# Show INFO level logs with last 20 lines
bamon log --level INFO --lines 20
```

### Searching Logs

```bash
# Search for specific keyword
bamon log --search "github"

# Search with regex pattern
bamon log --search ".*failed.*" --regex

# Search with context lines
bamon log --search "error" --before 2 --after 2
```

### Output Formatting

```bash
# JSON output format
bamon log --format json --lines 10

# Disable color output
bamon log --no-color

# Show log file information
bamon log --info
```

### Advanced Filtering

```bash
# Combine multiple filters
bamon log --level ERROR --search "timeout" --lines 50

# Search with context and JSON output
bamon log --search "github" --before 1 --after 1 --format json

# Follow logs with level filtering
bamon log --follow --level ERROR,WARN
```

## Log File Information

When using `--info`, the command displays:

- **Location**: Full path to the log file
- **Size**: Current file size in human-readable format
- **Last Modified**: Timestamp of last modification
- **Lines**: Total number of lines in the file
- **Rotated Logs**: Number of rotated log files
- **Directory Size**: Total size of the log directory

## Output Formats

### Text Format (Default)
- Color-coded log levels (ERROR in red, WARN in yellow, INFO in green, DEBUG in cyan)
- Human-readable timestamps and messages
- Standard terminal output

### JSON Format
- Structured JSON output with separate fields for timestamp, level, and message
- Suitable for programmatic processing
- Each log entry is a separate JSON object

## Real-time Following

The `--follow` option works like `tail -f`, continuously displaying new log entries as they are written. This is useful for monitoring daemon activity in real-time.

**Note**: Press `Ctrl+C` to stop following logs.

## Error Handling

The command handles various error conditions gracefully:

- **Missing log file**: Shows appropriate error message
- **Permission issues**: Displays access denied messages
- **Invalid arguments**: Shows usage help
- **Configuration issues**: Falls back to default log location

## Examples in Practice

### Monitoring System Health
```bash
# Monitor for errors in real-time
bamon log --follow --level ERROR

# Check recent system activity
bamon log --lines 50 --level INFO
```

### Debugging Issues
```bash
# Find all timeout-related errors
bamon log --search "timeout" --level ERROR

# Get context around specific errors
bamon log --search "failed" --before 3 --after 3
```

### Log Analysis
```bash
# Export logs in JSON format for analysis
bamon log --format json --lines 1000 > logs.json

# Get log file statistics
bamon log --info
```

## Integration with Other Commands

The log command works seamlessly with other BAMON commands:

```bash
# Check daemon status and then view logs
bamon status && bamon log --lines 20

# View logs after starting daemon
bamon start && bamon log --follow
```

## Tips and Best Practices

1. **Use appropriate line counts**: Start with `--lines 50` for recent activity, increase for historical analysis
2. **Combine filters effectively**: Use level filtering with search for targeted results
3. **Monitor in real-time**: Use `--follow` for active monitoring during troubleshooting
4. **Export for analysis**: Use JSON format for programmatic log analysis
5. **Check log file info**: Use `--info` to understand log file size and rotation status
