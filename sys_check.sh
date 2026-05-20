#!/bin/bash

echo "=================================================="
echo "          SYSTEM HEALTH DIAGNOSTIC REPORT         "
echo "=================================================="

# 1. Check Disk Space Metrics (Day 1)
echo -e "\n[1/3] SCANNING DISK STORAGE..."
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')
echo "Root Partition Usage: $DISK_USAGE"

# 2. Check Process Counts (Day 3)
echo -e "\n[2/3] SCANNING ACTIVE PROCESSES..."
TOTAL_PROCS=$(ps aux | wc -l)
echo "Total Active Processes Running: $TOTAL_PROCS"

# 3. Security Audit (Day 4)
echo -e "\n[3/3] AUDITING SECURITY PERMISSIONS..."
FILE="$HOME/local_project/database.env"

if [ -f "$FILE" ]; then
    # Grab the 10-character permission string
    PERMS=$(ls -l "$FILE" | awk '{print $1}')
    echo "Current Permission Switches for database.env: $PERMS"
    
    # Check if the last 3 switches (Others) contain 'r' (Read)
    if [[ "$PERMS" == *r ]]; then
        echo "⚠️  WARNING: Security Breach! Others can read this file."
    else
        echo "✅ SUCCESS: Security Gate is holding. Others are blocked."
    fi
else
    echo "❌ ERROR: database.env file not found for audit."
fi

echo -e "\n=================================================="
echo "             DIAGNOSTIC SCAN COMPLETE             "
echo "=================================================="
