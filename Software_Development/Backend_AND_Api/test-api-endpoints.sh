#!/usr/bin/env bash

# ==============================================================================
# 📝 SCRIPT DESCRIPTION
# ==============================================================================
# NAME:        test-api-endpoints.sh
# TARGET:      Backend Developers, API Engineers, & QA Testers
# DESCRIPTION: Concurrently pings a list of target local or remote API endpoints, 
#              validates HTTP response status codes, and measures latency.
# PROBLEM:     Manually testing multiple backend routes using Postman or singular 
#              curl commands slows down rapid development and integration loops.
# USAGE:       ./test-api-endpoints.sh
# ==============================================================================

# Define your backend routes to test (Modify this array to fit your local/dev setup)
ENDPOINTS=(
    "https://httpbin.org/status/200"
    "https://httpbin.org/status/404"
    "https://httpbin.org/delay/1"
)

echo "🚀 Initiating Local API Health & Response Validator..."
echo "======================================================================="
printf "%-40s | %-12s | %-10s\n" "ENDPOINT URL" "HTTP STATUS" "LATENCY"
echo "-----------------------------------------------------------------------"

for url in "${ENDPOINTS[@]}"; do
    # Capture metrics natively using curl formatting tokens
    # time_total outputs seconds, so we convert it to milliseconds using awk
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code},%{time_total}" "$url")
    
    STATUS=$(echo "$RESPONSE" | cut -d',' -f1)
    DURATION=$(echo "$RESPONSE" | cut -d',' -f2)
    LATENCY=$(awk -v t="$DURATION" 'BEGIN {print int(t*1000)}')
    
    # Truncate long URLs gracefully for dashboard alignment
    DISPLAY_URL="${url:0:38}"
    if [ ${#url} -gt 38 ]; then DISPLAY_URL="${url:0:35}..."; fi

    # Color code output based on standard HTTP response expectations
    if [ "$STATUS" -ge 200 ] && [ "$STATUS" -lt 300 ]; then
        # Green for healthy responses
        printf "%-40s | \e[32m%-12s\e[0m | %-s ms\n" "$DISPLAY_URL" "$STATUS OK" "$LATENCY"
    else
        # Red for failed/error status codes
        printf "%-40s | \e[31m%-12s\e[0m | %-s ms\n" "$DISPLAY_URL" "$STATUS ERR" "$LATENCY"
    fi
done

echo "======================================================================="
echo "🎉 API endpoint screening complete!"
