#!/usr/bin/env bash

# ==============================================================================
# 📝 SCRIPT DESCRIPTION
# ==============================================================================
# NAME:        purge-node-modules.sh
# TARGET:      Frontend Developers, UI/UX Engineers, & Power Users
# DESCRIPTION: Deeply scans a target folder for 'node_modules' directories and 
#              safely purges them after user verification to reclaim space.
# PROBLEM:     Frontend projects accumulate hidden 'node_modules' folders that 
#              hoard gigabytes of disk space and slow down system file tracking.
# USAGE:       ./purge-node-modules.sh [optional/path/to/scan]
# ==============================================================================

# Default to current directory if no path is passed
TARGET_DIR="${1:-.}"

if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ Error: Directory '$TARGET_DIR' does not exist."
    exit 1
fi

echo "🔍 Scanning for 'node_modules' in: $(realpath "$TARGET_DIR")"
echo "⏳ This might take a moment depending on your storage speed..."
echo "----------------------------------------------------------------"

# Find all node_modules directories, ignoring standard hidden git folders
MODULE_PATHS=$(find "$TARGET_DIR" -type d -name "node_modules" -not -path '*/.*' 2>/dev/null)

if [ -z "$MODULE_PATHS" ]; then
    echo "🎉 Clean sweep! No 'node_modules' folders found in this directory tree."
    exit 0
fi

# List out what we found
echo "⚠️  Found the following 'node_modules' folders:"
echo "$MODULE_PATHS"
echo "----------------------------------------------------------------"

# Interactive safety prompt
read -p "🚨 Are you absolutely sure you want to PURGE these folders? (y/N): " CONFIRM
echo "----------------------------------------------------------------"

if [[ "$CONFIRM" =~ ^[Yy]$ || "$CONFIRM" =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "🧹 Purge authorized. Deleting folders... please wait."
    
    # Loop and delete safely using rm -rf
    while IFS= read -r dir; do
        if [ -d "$dir" ]; then
            rm -rf "$dir"
            echo "✅ Removed: $dir"
        fi
    done <<< "$MODULE_PATHS"
    
    echo "----------------------------------------------------------------"
    echo "✨ Done! All target 'node_modules' folders have been successfully purged."
else
    echo "❌ Operation cancelled. No files were altered."
fi
