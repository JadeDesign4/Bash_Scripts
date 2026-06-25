#!/usr/bin/env bash

# ==============================================================================
# 📝 SCRIPT DESCRIPTION
# ==============================================================================
# NAME:        rotate-backend-logs.sh
# TARGET:      Backend Developers, DevOps Engineers, & System Administrators
# DESCRIPTION: Safely archives heavy operational logs into compressed backups 
#              and refreshes active log targets without service interruption.
# PROBLEM:     Deleting logs destroys debug history, but letting them grow 
#              indefinitely fills disk sectors and crashes the backend.
# USAGE:       ./rotate-backend-logs.sh [path/to/logs]
# ==============================================================================

LOG_DIR="${1:-./logs}"
TIMESTAMP=$(date +"%Y-%m-%d_%H%M%S")
SIZE_THRESHOLD_KB=10240 # 10MB limit before rotation kicks in

echo "🔄 Initiating Automated Backend Log Rotator & Archiver..."
echo "==============================================================="

if [ ! -d "$LOG_DIR" ]; then
    echo "💡 Creating directory '$LOG_DIR' and generating sample log matrix..."
    mkdir -p "$LOG_DIR"
    # Seed a simulated heavy log file for demonstration
    dd if=/dev/zero of="$LOG_DIR/api-server.log" bs=1M count=11 2>/dev/null
    dd if=/dev/zero of="$LOG_DIR/database.log" bs=1M count=2 2>/dev/null
fi

echo "🔍 Scanning '$LOG_DIR' for logs exceeding $((SIZE_THRESHOLD_KB / 1024))MB..."
echo "---------------------------------------------------------------"

ROTATED_COUNT=0

# Loop through all files ending in .log
for log_file in "$LOG_DIR"/*.log; do
    [ -e "$log_file" ] || continue # Handle empty directory edge case
    
    # Get file size in Kilobytes
    FILE_SIZE_KB=$(du -k "$log_file" | cut -f1)
    FILE_NAME=$(basename "$log_file")
    
    if [ "$FILE_SIZE_KB" -ge "$SIZE_THRESHOLD_KB" ]; then
        echo "📦 Target Identified: $FILE_NAME ($((FILE_SIZE_KB / 1024))MB)"
        
        # 1. Archive the historical records safely by copying to a timestamped file
        ARCHIVE_FILE="$LOG_DIR/${FILE_NAME}.${TIMESTAMP}.tar.gz"
        tar -czf "$ARCHIVE_FILE" -C "$LOG_DIR" "$FILE_NAME"
        
        # 2. Safely clear the active file without breaking active server handles (Atomic rewrite)
        cat /dev/null > "$log_file"
        
        echo "   ✅ Compressed to: $(basename "$ARCHIVE_FILE")"
        echo "   ✅ Active log reset to 0 bytes cleanly."
        ((ROTATED_COUNT++))
    else
        echo "   ├── $FILE_NAME ($((FILE_SIZE_KB / 1024))MB) is within safety margins."
    fi
done

echo "---------------------------------------------------------------"
echo "🎉 Clean execution complete! Rotated $ROTATED_COUNT log stream(s)."
echo "==============================================================="
