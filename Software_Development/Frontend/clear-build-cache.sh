#!/usr/bin/env bash

# ==============================================================================
# 📝 SCRIPT DESCRIPTION
# ==============================================================================
# NAME:        clear-build-cache.sh
# TARGET:      Frontend Developers, Jamstack/Static Site Engineers, & Build Ops
# DESCRIPTION: Locates and purges temporary frontend build artifacts and local 
#              framework cache folders (.next, dist, .turbo, etc.) to fix caching bugs.
# PROBLEM:     Stale local compilation caches cause weird visual bugs, build
#              regressions, and consume massive amounts of hidden storage.
# USAGE:       ./clear-build-cache.sh
# ==============================================================================

echo "🧹 Initiating Smart Frontend Build Cache Cleaner..."
echo "==============================================================="

# Array of standard framework build artifact and cache folder names
CACHE_TARGETS=(".next" "dist" "build" ".turbo" ".cache" "out" ".astro" ".svelte-kit")
FOUND_COUNT=0

echo "🔍 Scanning current workspace for stale artifacts..."
echo "---------------------------------------------------------------"

for target in "${CACHE_TARGETS[@]}"; do
    # Search recursively for matching directory names while ignoring git configurations
    find . -type d -name "$target" -not -path '*/.*git*' 2>/dev/null | while read -r found_dir; do
        if [ -d "$found_dir" ]; then
            echo "🔥 Purging build cache: $found_dir"
            rm -rf "$found_dir"
            ((FOUND_COUNT++))
        fi
    done
done

echo "---------------------------------------------------------------"
if [ "$FOUND_COUNT" -eq 0 ]; then
    echo "🎉 Workspace is already completely pristine! No stale caches found."
else
    echo "✨ Clean sweep successful! Purged $FOUND_COUNT build/cache location(s)."
    echo "💡 Next Step: Run 'npm run dev' or 'npm run build' for a completely fresh compilation."
fi
echo "==============================================================="
