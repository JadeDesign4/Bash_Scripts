#!/usr/bin/env bash

# ==============================================================================
# 📝 SCRIPT DESCRIPTION
# ==============================================================================
# NAME:        monitor-backend-perf.sh
# TARGET:      Backend Developers, Sysadmins, & Power Users
# DESCRIPTION: Monitors the real-time CPU and Memory usage of a specified 
#              backend runtime engine process (e.g., node, python, go, java).
# PROBLEM:     Backend apps can suffer from silent memory leaks or CPU spikes 
#              during heavy local testing, which are hard to track without bloated GUI tools.
# USAGE:       ./monitor-backend-perf.sh [process_name] (e.g., ./monitor-backend-perf.sh node)
# ==============================================================================

# Default to "node" if no process engine name is provided
PROCESS_NAME="${1:-node}"

echo "📊 Initiating Backend Performance Watchdog..."
echo "🔍 Searching for runtime engine: '$PROCESS_NAME'"
echo "==============================================================="
echo -e "PID\t\tCPU %\t\tMEM %\t\tCOMMAND"
echo "---------------------------------------------------------------"

# Get process stats using 'ps' command
# 'pgrep' finds PIDs matching the process name, 'ps' formats the resource consumption
STATS=$(ps -eo pid,pcpu,pmem,comm | grep -i "$PROCESS_NAME" | grep -v "monitor-backend-perf")

if [ -z "$STATS" ]; then
    echo -e "❌ \e[31mNo active processes found matching '$PROCESS_NAME'.\e[0m"
    echo "💡 Tip: Make sure your local backend server is actually running!"
    exit 1
fi

# Print out process resources row by row
while read -r pid cpu mem comm; do
    # Simple warning flag if CPU usage is unusually high (> 80%)
    if (( $(echo "$cpu > 80.0" | bc -l 2>/dev/null || [ "${cpu%.*}" -gt 80 ] 2>/dev/null) )); then
        printf "%s\t\t%s%%\t\t%s%%\t\t%s \e[31m[🔥 HIGH CPU!]\e[0m\n" "$pid" "$cpu" "$mem" "$(basename "$comm")"
    else
        printf "%s\t\t%s%%\t\t%s%%\t\t%s\n" "$pid" "$cpu" "$mem" "$(basename "$comm")"
    fi
done <<< "$STATS"

echo "==============================================================="
echo "💡 Tip: Keep refreshing this script to monitor local load spikes during API tests."
