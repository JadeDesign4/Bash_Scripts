#!/usr/bin/env bash

# ==============================================================================
# 📝 SCRIPT DESCRIPTION
# ==============================================================================
# NAME:        scan-secrets.sh
# TARGET:      Backend Developers, Sysadmins, & Power Users
# DESCRIPTION: Scans code and configuration files in the current workspace for 
#              hardcoded secrets, API tokens, and private keys using regex patterns.
# PROBLEM:     Accidentally committing credentials (like AWS keys or DB passwords) 
#              to Git repositories leads to massive security breaches.
# USAGE:       ./scan-secrets.sh
# ==============================================================================

echo "🔒 Initiating Local Secret & Token Scanner..."
echo "=================================================="

# Define high-risk regex patterns
# 1. Generic secrets/passwords, 2. AWS Keys, 3. Generic Bearer/API tokens, 4. Private Keys
PATTERNS=(
    "(password|passwd|secret|db_password|pwd)\s*=\s*['\"][^'\"]+['\"]"
    "([^A-Z0-9])[A-Z0-9]{20}([^A-Z0-9])" # Basic AWS Access Key ID pattern
    "(amzn\.mws\.[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}|A3T[A-Z0-9]{14})"
    "bearer\s+[a-zA-Z0-9_\-\.]+"
    "-----BEGIN [A-Z]+ PRIVATE KEY-----"
)

LEAKS_FOUND=0

# Use find to locate text files, avoiding the .git directory and the script itself
while IFS= read -r file; do
    # Skip this script file to avoid false positives on the patterns array
    if [[ "$file" == *"scan-secrets.sh" ]]; then continue; fi

    LINE_NUM=0
    while IFS= read -r line; do
        ((LINE_NUM++))
        
        for pattern in "${PATTERNS[@]}"; do
            if echo "$line" | grep -Eiq "$pattern"; then
                # Highlight the file name and leaked line (red output)
                echo -e "⚠️  \e[31mPOSSIBLE LEAK DETECTED\e[0m in \e[33m$file\e[0m on line $LINE_NUM"
                echo -e "   👉 Line: \e[90m$(echo "$line" | xargs)\e[0m"
                echo "--------------------------------------------------"
                ((LEAKS_FOUND++))
                break # Move to next line if a leak is found to avoid double counting
            fi
        done
    done < "$file"
done < <(find . -type f -not -path '*/.**' -not -name "*.log" -not -name "*.md" 2>/dev/null)

# Final Status Dashboard
echo "=================================================="
if [ "$LEAKS_FOUND" -eq 0 ]; then
    echo -e "🎉 \e[32mScan clean! No obvious hardcoded secrets or tokens found.\e[0m"
    exit 0
else
    echo -e "❌ \e[31mScan complete. Found $LEAKS_FOUND potential secret leak(s)!\e[0m"
    echo "💡 Recommendation: Remove these secrets or move them safely into a .env file immediately."
    exit 1
fi