#!/usr/bin/env bash
# Usage: ./check_cert.sh example.com 30
set -e
domain="$1"
days="$2"

if [[ -z "$domain" || -z "$days" ]]; then
  echo "Usage: $0 <domain> <days>"
  exit 2
fi

seconds=$((days*24*60*60))

if echo | openssl s_client -servername "$domain" -connect "$domain:443" 2>/dev/null \
   | openssl x509 -noout -checkend "$seconds" >/dev/null; then
  echo "valid > ${days}d"
  exit 0
else
  echo "valid < ${days}d"
  exit 1
fi
