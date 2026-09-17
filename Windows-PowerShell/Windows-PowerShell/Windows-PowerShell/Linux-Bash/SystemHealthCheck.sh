#!/bin/bash
# Description: Checks system disk usage and alerts if threshold is exceeded

THRESHOLD=80
CURRENT_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

echo "[INFO] Current disk usage on / is ${CURRENT_USAGE}%"

if [ "$CURRENT_USAGE" -gt "$THRESHOLD" ]; then
    echo "[WARNING] Disk space has exceeded ${THRESHOLD}% threshold!"
else
    echo "[OK] Disk space is within normal limits."
fi
