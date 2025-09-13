#!/usr/bin/env bash

# Debug daemon detection
source src/lib/config.sh
source src/lib/execution.sh

echo "Testing daemon detection step by step..."

echo "1. Checking PID file:"
pid_file=$(get_pid_file)
echo "   PID file: $pid_file"
echo "   Exists: $([[ -f "$pid_file" ]] && echo "yes" || echo "no")"

if [[ -f "$pid_file" ]]; then
  pid=$(cat "$pid_file" 2>/dev/null)
  echo "   PID: $pid"
  echo "   Process running: $(kill -0 "$pid" 2>/dev/null && echo "yes" || echo "no")"
fi

echo "2. Testing is_daemon_running function:"
if is_daemon_running; then
  echo "   Result: Daemon is running"
else
  echo "   Result: Daemon is not running"
fi

echo "3. Checking PID file after detection:"
echo "   Exists: $([[ -f "$pid_file" ]] && echo "yes" || echo "no")"
if [[ -f "$pid_file" ]]; then
  pid=$(cat "$pid_file" 2>/dev/null)
  echo "   PID: $pid"
  echo "   Process running: $(kill -0 "$pid" 2>/dev/null && echo "yes" || echo "no")"
fi