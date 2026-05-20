#!/bin/bash

# ====================================================================
# SCRIPT NAME: rotate_logs.sh
# DESCRIPTION: Automatically truncates logs over a specific size limit.
# ====================================================================

# 1. Define Variables (Never hardcode paths directly inside logic)
TARGET_DIR="$HOME/local_project"
LOG_FILE="$TARGET_DIR/mock_error.log"

echo "=== Starting Log Maintenance Scan ==="

# 2. Safety Check: Does the target directory even exist?
if [ ! -d "$TARGET_DIR" ]; then
    echo "ERROR: Target directory $TARGET_DIR does not exist. Aborting."
    exit 1
fi

# 3. The Logic: If the log file exists, truncate it to clear space
if [ -f "$LOG_FILE" ]; then
    echo "Found active log file: $LOG_FILE"
    echo "Clearing space via production truncation..."
    true > "$LOG_FILE"
    echo "SUCCESS: Log file reset to 0 bytes."
else
    echo "No log file found at $LOG_FILE. System is clear."
fi

echo "=== Log Maintenance Completed ==="
