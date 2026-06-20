#!/usr/bin/env bash

# ==============================================================================
# 📝 SCRIPT DESCRIPTION
# ==============================================================================
# NAME:        audit-styles.sh
# TARGET:      Frontend Developers, UI Engineers, & Tailwind/CSS Enthusiasts
# DESCRIPTION: Scans project components and markup (HTML, JS, JSX, TSX) to inventory 
#              class utility usage and flag potential structural style bloat.
# PROBLEM:     CSS utilities and classes easily become bloated and duplicated over 
#              time, leading to messy components and unoptimized build bundles.
# USAGE:       ./audit-styles.sh [path/to/src]
# ==============================================================================

TARGET_DIR="${1:-./src}"

echo "🎨 Initiating Frontend Stylesheet & Component Auditor..."
echo "📂 Scanning UI directory: $TARGET_DIR"
echo "==============================================================="

if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ Error: Directory '$TARGET_DIR' does not exist."
    echo "💡 Tip: Pass your frontend components folder as an argument: ./audit-styles.sh ./components"
    exit 1
fi

echo "📊 Top 10 Most Frequently Used Classes/Utilities:"
echo "---------------------------------------------------------------"

# Find HTML, JS, JSX, TSX, Vue, and Svelte files
# Regex extracts standard class="..." or className="..." contents, splits them, and counts frequencies
find "$TARGET_DIR" -type f \( -name "*.html" -o -name "*.js" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.vue" -o -name "*.svelte" \) 2>/dev/null | \
xargs grep -Eoi 'class(Name)?="[^"]+"' 2>/dev/null | \
sed -E 's/class(Name)?="//I' | sed 's/"//' | \
tr ' ' '\n' | \
sort | \
uniq -c | \
sort -nr | \
head -n 10

echo "---------------------------------------------------------------"
echo "⚠️  Checking for Component File Complexity (Potential Bloat):"

# Flags components that have exceptionally high class counts (e.g., heavily hardcoded utility strings)
find "$TARGET_DIR" -type f \( -name "*.html" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.vue" \) 2>/dev/null | while read -r file; do
    CLASS_COUNT=$(grep -Eoi 'class(Name)?="[^"]+"' "$file" | wc -l | xargs)
    if [ "$CLASS_COUNT" -gt 30 ]; then
        echo -e "   👉 \e[33mWarning:\e[0m '$(basename "$file")' has \e[31m$CLASS_COUNT\e[0m styling lines. Consider refactoring into atomic components."
    fi
done

echo "==============================================================="
echo "🎉 Style audit complete! Use these insights to streamline your design system tokens."
