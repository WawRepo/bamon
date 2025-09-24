# Examples

Real-world examples and use cases for BAMON monitoring scripts.

## Basic Monitoring Examples

### HTTP Health Checks

```bash
# Simple HTTP status check
bamon add api_health \
  --command "curl -s -o /dev/null -w '%{http_code}' https://api.example.com/health" \
  --interval 30 \
  --description "Check API health every 30 seconds"

# HTTP response time monitoring
bamon add response_time \
  --command "curl -s -o /dev/null -w '%{time_total}' https://api.example.com/health" \
  --interval 60 \
  --description "Monitor API response time"
```

### System Resource Monitoring

```bash
# Disk usage monitoring
bamon add disk_usage \
  --command "df -h / | awk 'NR==2 {print \$5}' | sed 's/%//' | awk '{if(\$1>90) exit 1; else exit 0}'" \
  --interval 300 \
  --description "Alert if disk usage exceeds 90%"

# Memory usage check
bamon add memory_check \
  --command "free -m | awk '/^Mem:/ {print \$3/\$2 * 100.0}' | awk '{if(\$1>85) exit 1; else exit 0}'" \
  --interval 120 \
  --description "Alert if memory usage exceeds 85%"

# CPU load monitoring
bamon add cpu_load \
  --command "uptime | awk '{print \$10}' | sed 's/,//' | awk '{if(\$1>2.0) exit 1; else exit 0}'" \
  --interval 60 \
  --description "Alert if CPU load exceeds 2.0"
```

### Service Status Monitoring

```bash
# Nginx status check
bamon add nginx_status \
  --command "systemctl is-active nginx" \
  --interval 30 \
  --description "Check if Nginx service is running"

# Database connection test
bamon add db_health \
  --command "mysql -u root -p'password' -e 'SELECT 1' > /dev/null 2>&1" \
  --interval 60 \
  --description "Test database connectivity"

# Docker container health
bamon add docker_health \
  --command "docker ps --filter 'status=running' | grep -q 'web-app'" \
  --interval 30 \
  --description "Check if web-app container is running"
```

## Advanced Monitoring Examples

### Log File Monitoring

```bash
# Check for error patterns in logs
bamon add error_log_check \
  --command "tail -n 100 /var/log/nginx/error.log | grep -c 'ERROR' | awk '{if(\$1>10) exit 1; else exit 0}'" \
  --interval 300 \
  --description "Alert if too many errors in Nginx logs"

# Application log monitoring
bamon add app_log_check \
  --command "tail -n 50 /var/log/app/application.log | grep -c 'CRITICAL' | awk '{if(\$1>0) exit 1; else exit 0}'" \
  --interval 120 \
  --description "Alert on critical application errors"
```

### Network Connectivity

```bash
# Internet connectivity test
bamon add internet_check \
  --command "ping -c 1 8.8.8.8 > /dev/null 2>&1" \
  --interval 60 \
  --description "Test internet connectivity"

# DNS resolution test
bamon add dns_check \
  --command "nslookup google.com > /dev/null 2>&1" \
  --interval 120 \
  --description "Test DNS resolution"

# Port availability check
bamon add port_check \
  --command "nc -z localhost 80 > /dev/null 2>&1" \
  --interval 30 \
  --description "Check if port 80 is open"
```

### File System Monitoring

```bash
# File existence check
bamon add config_file_check \
  --command "test -f /etc/nginx/nginx.conf" \
  --interval 300 \
  --description "Verify Nginx config file exists"

# Directory size monitoring
bamon add log_size_check \
  --command "du -sh /var/log | awk '{print \$1}' | sed 's/G//' | awk '{if(\$1>5) exit 1; else exit 0}'" \
  --interval 600 \
  --description "Alert if log directory exceeds 5GB"

# File modification time check
bamon add backup_check \
  --command "find /backups -name '*.tar.gz' -mtime -1 | wc -l | awk '{if(\$1>0) exit 0; else exit 1}'" \
  --interval 3600 \
  --description "Verify daily backups are created"
```

## Business Logic Examples

### E-commerce Monitoring

```bash
# Payment gateway health
bamon add payment_health \
  --command "curl -s https://api.stripe.com/v1/charges -H 'Authorization: Bearer sk_test_...' | grep -q 'object'" \
  --interval 60 \
  --description "Check payment gateway connectivity"

# Inventory check
bamon add inventory_check \
  --command "mysql -u root -p'password' -e 'SELECT COUNT(*) FROM products WHERE stock < 10' | awk 'NR==2' | awk '{if(\$1>0) exit 1; else exit 0}'" \
  --interval 300 \
  --description "Alert if any products are low in stock"
```

### API Rate Limiting

```bash
# API rate limit monitoring
bamon add rate_limit_check \
  --command "curl -s -I https://api.example.com/endpoint | grep 'X-RateLimit-Remaining' | awk '{print \$2}' | awk '{if(\$1<100) exit 1; else exit 0}'" \
  --interval 120 \
  --description "Alert if API rate limit is low"
```

### Security Monitoring

```bash
# Failed login attempts
bamon add failed_logins \
  --command "grep 'Failed password' /var/log/auth.log | tail -n 10 | wc -l | awk '{if(\$1>5) exit 1; else exit 0}'" \
  --interval 300 \
  --description "Alert on multiple failed login attempts"

# SSL certificate expiry
bamon add ssl_expiry \
  --command "echo | openssl s_client -servername example.com -connect example.com:443 2>/dev/null | openssl x509 -noout -dates | grep 'notAfter' | cut -d= -f2 | xargs -I {} date -d {} +%s | awk '{if(\$1-$(date +%s)<604800) exit 1; else exit 0}'" \
  --interval 86400 \
  --description "Alert if SSL certificate expires within 7 days"
```

## Performance Monitoring

### Application Performance

```bash
# Response time monitoring
bamon add response_time \
  --command "curl -s -o /dev/null -w '%{time_total}' https://app.example.com/api/health | awk '{if(\$1>2.0) exit 1; else exit 0}'" \
  --interval 30 \
  --description "Alert if API response time exceeds 2 seconds"

# Database query performance
bamon add db_performance \
  --command "mysql -u root -p'password' -e 'SHOW PROCESSLIST' | grep -c 'Query' | awk '{if(\$1>50) exit 1; else exit 0}'" \
  --interval 60 \
  --description "Alert if too many database queries are running"
```

### System Performance

```bash
# Load average monitoring
bamon add load_average \
  --command "uptime | awk '{print \$10}' | sed 's/,//' | awk '{if(\$1>4.0) exit 1; else exit 0}'" \
  --interval 60 \
  --description "Alert if system load exceeds 4.0"

# Disk I/O monitoring
bamon add disk_io \
  --command "iostat -x 1 1 | grep 'sda' | awk '{print \$10}' | awk '{if(\$1>80) exit 1; else exit 0}'" \
  --interval 120 \
  --description "Alert if disk I/O wait exceeds 80%"
```

## Integration Examples

### Slack Notifications

```bash
# Send Slack notification on failure
bamon add slack_alert \
  --command "curl -X POST -H 'Content-type: application/json' --data '{\"text\":\"System alert: Service is down\"}' https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK" \
  --interval 300 \
  --description "Send Slack alert every 5 minutes if triggered"
```

### Email Alerts

```bash
# Send email notification
bamon add email_alert \
  --command "echo 'System alert: Service is down' | mail -s 'BAMON Alert' admin@example.com" \
  --interval 600 \
  --description "Send email alert every 10 minutes if triggered"
```

### Webhook Integration

```bash
# Send webhook notification
bamon add webhook_alert \
  --command "curl -X POST -H 'Content-Type: application/json' -d '{\"status\":\"down\",\"service\":\"api\"}' https://monitoring.example.com/webhook" \
  --interval 300 \
  --description "Send webhook alert on service failure"
```

## Best Practices

### Script Design

1. **Use descriptive names**: `api_health_check` instead of `check1`
2. **Include meaningful descriptions**: Help others understand the script's purpose
3. **Test commands manually**: Verify they work before adding to BAMON
4. **Use appropriate intervals**: Balance monitoring frequency with system load
5. **Handle errors gracefully**: Scripts should exit with appropriate codes

### Error Handling

```bash
# Good: Explicit error handling
bamon add good_script \
  --command "curl -s https://api.example.com/health || exit 1" \
  --interval 30

# Bad: No error handling
bamon add bad_script \
  --command "curl -s https://api.example.com/health" \
  --interval 30
```

### Resource Management

```bash
# Use timeouts for long-running commands
bamon add timeout_script \
  --command "timeout 30 curl -s https://slow-api.example.com/health" \
  --interval 60

# Limit resource usage
bamon add resource_script \
  --command "nice -n 19 curl -s https://api.example.com/health" \
  --interval 30
```