# BAMON Examples

This document provides comprehensive examples of how to use BAMON for various monitoring scenarios.

## Table of Contents

- [HTTP Health Checks](#http-health-checks)
- [System Resource Monitoring](#system-resource-monitoring)
- [Process Monitoring](#process-monitoring)
- [Database Monitoring](#database-monitoring)
- [File System Monitoring](#file-system-monitoring)
- [Network Monitoring](#network-monitoring)
- [Custom Scripts](#custom-scripts)
- [Advanced Configuration](#advanced-configuration)

## HTTP Health Checks

### Basic Website Check

```bash
# Check if a website is accessible
bamon add "website_check" \
  --command "curl -s -o /dev/null -w '%{http_code}' https://example.com" \
  --interval 60 \
  --description "Check if example.com is accessible"
```

### API Health Check

```bash
# Check API endpoint with JSON response
bamon add "api_health" \
  --command "curl -s -H 'Accept: application/json' https://api.example.com/health | jq -e '.status == \"ok\"'" \
  --interval 30 \
  --description "Check API health endpoint"
```

### HTTP Status Code Validation

```bash
# Ensure specific HTTP status code
bamon add "status_check" \
  --command "curl -s -o /dev/null -w '%{http_code}' https://httpbin.org/status/200 | grep -q '200' || exit 1" \
  --interval 30 \
  --description "Verify HTTP 200 response"
```

### SSL Certificate Check

```bash
# Check SSL certificate expiration (cross-platform compatible)
bamon add "ssl_check" \
  --command "echo | openssl s_client -servername example.com -connect example.com:443 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2 | if [[ \"\$OSTYPE\" == \"darwin\"* ]]; then gdate -d \"\$1\" +%s 2>/dev/null || date -j -f \"%b %d %H:%M:%S %Y %Z\" \"\$1\" +%s; else date -d \"\$1\" +%s; fi | awk -v threshold=\$(if [[ \"\$OSTYPE\" == \"darwin\"* ]]; then gdate -d \"+30 days\" +%s 2>/dev/null || date -v +30d +%s; else date -d \"+30 days\" +%s; fi) '{if(\$1 < threshold) exit 1; else exit 0}'" \
  --interval 3600 \
  --description "Check SSL certificate expiration (30 days warning)"
```

**Simplified version (recommended):**
```bash
# Simpler SSL certificate check using openssl directly
bamon add "ssl_check" \
  --command "echo | openssl s_client -servername example.com -connect example.com:443 2>/dev/null | openssl x509 -noout -checkend 2592000 || exit 1" \
  --interval 3600 \
  --description "Check SSL certificate expiration (30 days warning)"
```

**With expiration date output (yyyy-mm-dd format):**
```bash
# SSL certificate check with readable expiration date
bamon add "ssl_check_with_date" \
  --command "expiry=\$(echo | openssl s_client -servername example.com -connect example.com:443 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2); if [[ \$OSTYPE == darwin* ]]; then formatted_date=\$(date -j -f '%b %d %H:%M:%S %Y %Z' \"\$expiry\" +%Y-%m-%d 2>/dev/null); else formatted_date=\$(date -d \"\$expiry\" +%Y-%m-%d 2>/dev/null); fi; echo \"Certificate expires: \$formatted_date\"; echo | openssl s_client -servername example.com -connect example.com:443 2>/dev/null | openssl x509 -noout -checkend 2592000 || exit 1" \
  --interval 3600 \
  --description "Check SSL certificate expiration with date output (30 days warning)"
```

**Even simpler version (recommended):**
```bash
# SSL certificate check with date output - simplified
bamon add "ssl_check_simple" \
  --command "expiry=\$(echo | openssl s_client -servername example.com -connect example.com:443 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2); echo \"Certificate expires: \$expiry\"; echo | openssl s_client -servername example.com -connect example.com:443 2>/dev/null | openssl x509 -noout -checkend 2592000 || exit 1" \
  --interval 3600 \
  --description "Check SSL certificate expiration with date output (30 days warning)"
```

## System Resource Monitoring

### Disk Usage Monitoring

```bash
# Monitor root partition disk usage
bamon add "disk_root" \
  --command "df -h / | awk 'NR==2 {print \$5}' | sed 's/%//' | awk '{if(\$1>80) exit 1; else exit 0}'" \
  --interval 300 \
  --description "Alert if root partition usage exceeds 80%"

# Monitor specific directory
bamon add "disk_home" \
  --command "df -h /home | awk 'NR==2 {print \$5}' | sed 's/%//' | awk '{if(\$1>90) exit 1; else exit 0}'" \
  --interval 300 \
  --description "Alert if /home partition usage exceeds 90%"
```

### Memory Usage Monitoring

```bash
# Monitor system memory usage
bamon add "memory_check" \
  --command "free -m | awk '/^Mem:/ {print \$3/\$2 * 100.0}' | awk '{if(\$1>85) exit 1; else exit 0}'" \
  --interval 300 \
  --description "Alert if memory usage exceeds 85%"

# Monitor swap usage
bamon add "swap_check" \
  --command "free -m | awk '/^Swap:/ {if(\$2>0) print \$3/\$2 * 100.0; else print 0}' | awk '{if(\$1>50) exit 1; else exit 0}'" \
  --interval 300 \
  --description "Alert if swap usage exceeds 50%"
```

### CPU Load Monitoring

```bash
# Monitor 1-minute load average
bamon add "cpu_load" \
  --command "uptime | awk '{print \$10}' | sed 's/,//' | awk '{if(\$1>2.0) exit 1; else exit 0}'" \
  --interval 60 \
  --description "Alert if 1-minute load average exceeds 2.0"

# Monitor CPU usage percentage
bamon add "cpu_usage" \
  --command "top -bn1 | grep 'Cpu(s)' | awk '{print \$2}' | sed 's/%us,//' | awk '{if(\$1>80) exit 1; else exit 0}'" \
  --interval 60 \
  --description "Alert if CPU usage exceeds 80%"
```

## Process Monitoring

### Service Process Checks

```bash
# Check if Nginx is running
bamon add "nginx_check" \
  --command "pgrep nginx > /dev/null || exit 1" \
  --interval 60 \
  --description "Check if Nginx is running"

# Check if MySQL is running
bamon add "mysql_check" \
  --command "pgrep mysqld > /dev/null || exit 1" \
  --interval 60 \
  --description "Check if MySQL is running"

# Check if Docker daemon is running
bamon add "docker_check" \
  --command "pgrep dockerd > /dev/null || exit 1" \
  --interval 60 \
  --description "Check if Docker daemon is running"
```

### Process Count Monitoring

```bash
# Monitor number of Apache processes
bamon add "apache_processes" \
  --command "pgrep -c apache2 | awk '{if(\$1<2) exit 1; else exit 0}'" \
  --interval 60 \
  --description "Ensure at least 2 Apache processes are running"

# Monitor zombie processes
bamon add "zombie_check" \
  --command "ps aux | awk '\$8 ~ /^Z/ {count++} END {if(count>0) exit 1; else exit 0}'" \
  --interval 300 \
  --description "Alert if zombie processes are found"
```

## Database Monitoring

### MySQL Connection Check

```bash
# Check MySQL database connection
bamon add "mysql_connect" \
  --command "mysql -u root -e 'SELECT 1' > /dev/null 2>&1 || exit 1" \
  --interval 120 \
  --description "Check MySQL database connection"

# Check MySQL replication status
bamon add "mysql_replication" \
  --command "mysql -u root -e 'SHOW SLAVE STATUS\\G' | grep 'Slave_IO_Running: Yes' && mysql -u root -e 'SHOW SLAVE STATUS\\G' | grep 'Slave_SQL_Running: Yes'" \
  --interval 300 \
  --description "Check MySQL replication status"
```

### PostgreSQL Connection Check

```bash
# Check PostgreSQL connection
bamon add "postgres_connect" \
  --command "psql -U postgres -c 'SELECT 1' > /dev/null 2>&1 || exit 1" \
  --interval 120 \
  --description "Check PostgreSQL database connection"
```

### Redis Connection Check

```bash
# Check Redis connection
bamon add "redis_connect" \
  --command "redis-cli ping | grep -q PONG || exit 1" \
  --interval 60 \
  --description "Check Redis connection"
```

## File System Monitoring

### Log File Size Monitoring

```bash
# Monitor Apache error log size
bamon add "apache_error_log" \
  --command "find /var/log/apache2 -name 'error.log' -size +100M | wc -l | awk '{if(\$1>0) exit 1; else exit 0}'" \
  --interval 300 \
  --description "Alert if Apache error log exceeds 100MB"

# Monitor system log size
bamon add "syslog_size" \
  --command "find /var/log -name 'syslog*' -size +500M | wc -l | awk '{if(\$1>0) exit 1; else exit 0}'" \
  --interval 300 \
  --description "Alert if system log exceeds 500MB"
```

### File Existence Checks

```bash
# Check if critical files exist
bamon add "critical_files" \
  --command "test -f /etc/passwd && test -f /etc/shadow && test -f /etc/group || exit 1" \
  --interval 300 \
  --description "Check if critical system files exist"

# Check if backup files are recent
bamon add "backup_check" \
  --command "find /backup -name '*.tar.gz' -mtime -1 | wc -l | awk '{if(\$1==0) exit 1; else exit 0}'" \
  --interval 3600 \
  --description "Check if daily backups exist"
```

## Network Monitoring

### Port Availability Checks

```bash
# Check if SSH port is open
bamon add "ssh_port" \
  --command "nc -z localhost 22 || exit 1" \
  --interval 60 \
  --description "Check if SSH port 22 is open"

# Check if web server port is open
bamon add "web_port" \
  --command "nc -z localhost 80 && nc -z localhost 443 || exit 1" \
  --interval 60 \
  --description "Check if web server ports 80 and 443 are open"
```

### Network Connectivity Checks

```bash
# Check internet connectivity
bamon add "internet_check" \
  --command "ping -c 1 8.8.8.8 > /dev/null 2>&1 || exit 1" \
  --interval 60 \
  --description "Check internet connectivity"

# Check DNS resolution
bamon add "dns_check" \
  --command "nslookup google.com > /dev/null 2>&1 || exit 1" \
  --interval 60 \
  --description "Check DNS resolution"
```

## Custom Scripts

### Complex Health Check Script

Create a custom script file:

```bash
# Create custom health check script
cat > ~/.config/bamon/samples/custom_health.sh << 'SCRIPT_EOF'
#!/bin/bash

# Custom health check script
# This script performs multiple checks and returns appropriate exit codes

# Check 1: Disk space
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 80 ]; then
    echo "ERROR: Disk usage is ${DISK_USAGE}%"
    exit 1
fi

# Check 2: Memory usage
MEMORY_USAGE=$(free | awk '/^Mem:/ {printf "%.0f", $3/$2 * 100}')
if [ "$MEMORY_USAGE" -gt 85 ]; then
    echo "ERROR: Memory usage is ${MEMORY_USAGE}%"
    exit 1
fi

# Check 3: Load average
LOAD_AVG=$(uptime | awk '{print $10}' | sed 's/,//')
if (( $(echo "$LOAD_AVG > 2.0" | bc -l) )); then
    echo "ERROR: Load average is $LOAD_AVG"
    exit 1
fi

echo "OK: All checks passed (Disk: ${DISK_USAGE}%, Memory: ${MEMORY_USAGE}%, Load: $LOAD_AVG)"
exit 0
SCRIPT_EOF

chmod +x ~/.config/bamon/samples/custom_health.sh

# Add the custom script to BAMON
bamon add "custom_health" \
  --command "~/.config/bamon/samples/custom_health.sh" \
  --interval 300 \
  --description "Custom comprehensive health check"
```

### Database Backup Verification

```bash
# Create database backup verification script
cat > ~/.config/bamon/samples/db_backup_check.sh << 'SCRIPT_EOF'
#!/bin/bash

# Database backup verification script
BACKUP_DIR="/backup/database"
DB_NAME="myapp"

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo "ERROR: Backup directory $BACKUP_DIR does not exist"
    exit 1
fi

# Check if today's backup exists
TODAY=$(date +%Y-%m-%d)
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${TODAY}.sql.gz"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "ERROR: Today's backup file $BACKUP_FILE does not exist"
    exit 1
fi

# Check if backup file is not empty
if [ ! -s "$BACKUP_FILE" ]; then
    echo "ERROR: Backup file $BACKUP_FILE is empty"
    exit 1
fi

# Check if backup is recent (within last 25 hours)
if [ $(find "$BACKUP_FILE" -mtime -1 | wc -l) -eq 0 ]; then
    echo "ERROR: Backup file $BACKUP_FILE is older than 24 hours"
    exit 1
fi

echo "OK: Database backup verified - $BACKUP_FILE"
exit 0
SCRIPT_EOF

chmod +x ~/.config/bamon/samples/db_backup_check.sh

# Add the backup check to BAMON
bamon add "db_backup_check" \
  --command "~/.config/bamon/samples/db_backup_check.sh" \
  --interval 3600 \
  --description "Verify daily database backup"
```

## Advanced Configuration

### Environment-Specific Monitoring

```yaml
# Production environment configuration
daemon:
  default_interval: 30
  log_file: "/var/log/bamon/bamon.log"
  pid_file: "/var/run/bamon.pid"
  max_concurrent: 20

sandbox:
  timeout: 60
  max_cpu_time: 120
  max_file_size: 20480
  max_virtual_memory: 204800

performance:
  enable_monitoring: true
  load_threshold: 0.7
  optimize_scheduling: true

scripts:
  # Critical system checks (every 30 seconds)
  - name: "system_critical"
    command: "~/.config/bamon/samples/critical_system_check.sh"
    interval: 30
    enabled: true
    description: "Critical system health check"
  
  # Application health checks (every 60 seconds)
  - name: "app_health"
    command: "curl -s -o /dev/null -w '%{http_code}' https://myapp.com/health"
    interval: 60
    enabled: true
    description: "Application health check"
  
  # Resource monitoring (every 5 minutes)
  - name: "resource_monitor"
    command: "~/.config/bamon/samples/resource_monitor.sh"
    interval: 300
    enabled: true
    description: "System resource monitoring"
  
  # Backup verification (every hour)
  - name: "backup_verify"
    command: "~/.config/bamon/samples/backup_verification.sh"
    interval: 3600
    enabled: true
    description: "Backup verification"
```

### Conditional Monitoring

```bash
# Only run during business hours (9 AM - 5 PM)
bamon add "business_hours_check" \
  --command "curl -s -o /dev/null -w '%{http_code}' https://business-app.com/status" \
  --interval 300 \
  --description "Business hours application check"

# Create a wrapper script for conditional execution
cat > ~/.config/bamon/samples/business_hours_wrapper.sh << 'SCRIPT_EOF'
#!/bin/bash

# Check if current time is within business hours (9 AM - 5 PM)
CURRENT_HOUR=$(date +%H)
if [ "$CURRENT_HOUR" -ge 9 ] && [ "$CURRENT_HOUR" -lt 17 ]; then
    # Run the actual check
    curl -s -o /dev/null -w '%{http_code}' https://business-app.com/status
else
    echo "Outside business hours - skipping check"
    exit 0
fi
SCRIPT_EOF

chmod +x ~/.config/bamon/samples/business_hours_wrapper.sh

# Update the script to use the wrapper
bamon remove business_hours_check
bamon add "business_hours_check" \
  --command "~/.config/bamon/samples/business_hours_wrapper.sh" \
  --interval 300 \
  --description "Business hours application check"
```

## Best Practices

### 1. Script Design
- Keep scripts simple and focused
- Use descriptive names and descriptions
- Include proper error handling
- Test scripts manually before adding to BAMON

### 2. Interval Selection
- Use shorter intervals (30-60 seconds) for critical checks
- Use longer intervals (5-15 minutes) for resource monitoring
- Consider system load when setting intervals

### 3. Error Handling
- Always return appropriate exit codes (0 for success, 1 for failure)
- Provide meaningful error messages
- Log important information to stdout

### 4. Resource Management
- Monitor BAMON's own resource usage
- Use appropriate sandbox limits
- Consider system load when running multiple scripts

### 5. Maintenance
- Regularly review and update monitoring scripts
- Clean up old log files
- Update configurations as needed
- Test scripts after system updates

## Troubleshooting Examples

### Debug Script Execution

```bash
# Test a script manually
bash -c "your_script_command"

# Run BAMON with debug logging
BAMON_LOG_LEVEL=DEBUG bamon start

# Check specific script execution
bamon now --name script_name
```

### Common Issues and Solutions

1. **Script not executing**: Check if script is enabled and has correct permissions
2. **Permission denied**: Ensure script has execute permissions
3. **Command not found**: Verify all commands in script are available in PATH
4. **Timeout errors**: Adjust sandbox timeout settings or optimize script performance
5. **Resource limits**: Check sandbox resource limits and system resources

## About BAMON's CLI Framework

BAMON is built using [Bashly](https://github.com/DannyBen/bashly), a powerful bash CLI framework that helps create beautiful command-line tools with minimal effort. Bashly generates a complete CLI structure from YAML configuration files, making it easy to maintain and extend the command-line interface.

- **Bashly Repository**: https://github.com/DannyBen/bashly
- **Bashly Documentation**: https://bashly.dannyb.co/
- **Bashly Features**: Auto-generated help, argument parsing, subcommands, and more

This comprehensive examples guide should help you get started with BAMON and implement effective monitoring solutions for your systems.
