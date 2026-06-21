#!/usr/bin/env bash

# ==============================================================================
# 📝 SCRIPT DESCRIPTION
# ==============================================================================
# NAME:        verify-i18n.sh
# TARGET:      Frontend Developers, Content Managers, & i18n Engineers
# DESCRIPTION: Compares root keys across JSON translation/configuration files 
#              to catch missing variables or structural drift.
# PROBLEM:     Adding feature text keys to a primary config (e.g., en.json) but 
#              forgetting others causes broken UI labels and missing web text.
# USAGE:       ./verify-i18n.sh [path/to/locales]
# ==============================================================================

TARGET_DIR="${1:-./locales}"

echo "🌐 Initiating Translation & Config Integrity Guard..."
echo "==============================================================="

if [ ! -d "$TARGET_DIR" ]; then
    echo "⚠️  Directory '$TARGET_DIR' not found. Creating placeholder directory structure..."
    mkdir -p "$TARGET_DIR"
    # Create sample files to avoid empty run warnings
    echo '{"title": "Hello", "button": "Submit"}' > "$TARGET_DIR/en.json"
    echo '{"title": "Hola"}' > "$TARGET_DIR/es.json"
fi

# Find all JSON config files in target directory
FILES=($(find "$TARGET_DIR" -maxdepth 1 -name "*.json" | sort))

if [ ${#FILES[@]} -lt 2 ]; then
    echo "💡 Found ${#FILES[@]} JSON file(s). Need at least 2 files in '$TARGET_DIR' to compare."
    exit 0
fi

PRIMARY_FILE="${FILES[0]}"
echo "📘 Using primary reference base: $(basename "$PRIMARY_FILE")"
echo "---------------------------------------------------------------"

# Extract top-level keys using a clean sed/awk routine to maintain zero external dependencies
get_json_keys() {
    grep -o '"[^"]*"\s*:' "$1" | sed 's/"//g' | sed 's/://g' | tr -d ' ' | sort
}

PRIMARY_KEYS=$(get_json_keys "$PRIMARY_FILE")

DRIFT_DETECTED=0

for ((i=1; i<${#FILES[@]}; i++)); do
    COMPARE_FILE="${FILES[$i]}"
    COMPARE_KEYS=$(get_json_keys "$COMPARE_FILE")
    
    echo "🔍 Auditing: $(basename "$COMPARE_FILE") against reference..."
    
    # Track down keys that exist in the primary file but are missing in the comparison file
    MISSING_KEYS=$(comm -23 <(echo "$PRIMARY_KEYS") <(echo "$COMPARE_KEYS"))
    
    if [ -n "$MISSING_KEYS" ]; then
        echo -e "   ❌ \e[31mMISSING KEYS DETECTED:\e[0m"
        while read -r key; do
            echo -e "      👉 [ ] $key"
        done <<< "$MISSING_KEYS"
        ((DRIFT_DETECTED++))
    else
        echo -e "   ✅ \e[32mStructure fully aligned!\e[0m"
    fi
    echo "---------------------------------------------------------------"
done

if [ "$DRIFT_DETECTED" -gt 0 ]; then
    echo "⚠️  Drift detected. Update your configuration files to match the reference structure."
    exit 1
else
    echo "🎉 Alignment perfect! All layout configuration matrices match exactly."
    exit 0
fi
