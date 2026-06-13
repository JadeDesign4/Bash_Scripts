#!/usr/bin/env bash

# ==============================================================================
# 📝 SCRIPT DESCRIPTION
# ==============================================================================
# NAME:        clear-backend-logs.sh
# TARGET:      Backend Developers, Sysadmins, & Power Users
# DESCRIPTION: Scans the target directory for '.log' files and safely truncates 
#              them to 0 bytes without deleting the files or breaking system handles.
# PROBLEM:     Backend application logs balloon over time, consuming local disk 
#              space and making debugging fresh errors incredibly tedious.
# USAGE:       ./clear-backend-logs.sh [optional/path/to/search]
# ==============================================================================

# Default to current directory if no argument is passed
TARGET_DIR="${1:-.}"

if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ Error: Directory '$TARGET_DIR' does not exist."
    exit 1
fi

echo "🔍 Scanning for log files in: $(realpath "$TARGET_DIR")"
echo "--------------------------------------------------"

TOTAL_SAVED=0
LOG_FILES=$(find "$TARGET_DIR" -type f -name "*.log")

if [ -z "$LOG_FILES" ]; then
    echo "🎉 No .log files found. Your workspace is perfectly clean!"
    exit 0
fi

# Loop through found log files
while IFS= read -r file; do
    # Get file size in bytes
    file_size=$(wc -c < "$file")
    TOTAL_SAVED=$((TOTAL_SAVED + file_size))
    
    # Safely truncate the file to 0 bytes without deleting it
    : > "$file"
    
    # Convert size to human-readable format (KB or MB) for output
    if [ "$file_size" -ge 1048576 ]; then
        readable_size="$((file_size / 1048576)) MB"
    elif [ "$file_size" -ge 1024 ]; then
        readable_size="$((file_size / 1024)) KB"
    else
        readable_size="$file_size Bytes"
    fi

    echo "🧹 Cleared: $(basename "$file") ($readable_size cleared)"
done <<< "$LOG_FILES"

echo "--------------------------------------------------"
# Convert total saved bytes to MB for final report
TOTAL_MB=$((TOTAL_SAVED / 1048576))
if [ "$TOTAL_MB" -gt 0 ]; then
    echo "✅ Success! Safely reclaimed approx. $TOTAL_MB MB of disk space."
else
    echo "✅ Success! All log files have been reset to 0 bytes."
fi
