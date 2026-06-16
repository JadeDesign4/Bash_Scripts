#!/bin/bash

# If it throws errors at the "CPU" section install the bc command utility

# Color codes for visual feedback
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "=================================================="
echo "          LINUX SYSTEM HEALTH REPORT              "
echo "=================================================="

# 1. BATTERY CHECK
# 1. BATTERY CHECK
echo -e "\n[+] Checking Battery Status..."

# Find all paths matching /sys/class/power_supply/BAT*
battery_paths=(/sys/class/power_supply/BAT*)

# Check if the wildcard actually found real directories
if [ -d "${battery_paths[0]}" ]; then
    # Loop through every battery found on the system
    for bat in "${battery_paths[@]}"; do
        bat_name=$(basename "$bat")
        capacity=$(cat "$bat/capacity")
        status=$(cat "$bat/status")
        
        echo "[$bat_name] Current Charge: $capacity%"
        echo "[$bat_name] Status: $status"
        
        if [ "$capacity" -le 15 ] && [ "$status" != "Charging" ]; then
            echo -e "Result ($bat_name): ${RED}CRITICAL (Battery Low & Not Charging)${NC}"
        elif [ "$capacity" -le 30 ] && [ "$status" != "Charging" ]; then
            echo -e "Result ($bat_name): ${YELLOW}WARNING (Battery getting low)${NC}"
        else
            echo -e "Result ($bat_name): ${GREEN}GOOD${NC}"
        fi
    done
else
    echo "No battery found (Desktop PC or Virtual Machine)."
fi

sleep 1

# 2. STORAGE CHECK
echo -e "\n[+] Checking Storage / Root Partition..."
# Gets the percentage usage of the root '/' partition
storage_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

echo "Root Partition Usage: $storage_usage%"

if [ "$storage_usage" -ge 90 ]; then
    echo -e "Result: ${RED}CRITICAL (Storage almost full! Run out of space soon)${NC}"
elif [ "$storage_usage" -ge 75 ]; then
    echo -e "Result: ${YELLOW}WARNING (Storage filling up)${NC}"
else
    echo -e "Result: ${GREEN}GOOD${NC}"
fi

sleep 2

# 3. RAM/MEMORY CHECK
echo -e "\n[+] Checking RAM Utilization..."
# Calculates free memory percentage
ram_data=$(free | grep Mem)
total_ram=$(echo "$ram_data" | awk '{print $2}')
used_ram=$(echo "$ram_data" | awk '{print $3}')
ram_usage_pct=$(( 100 * used_ram / total_ram ))

echo "RAM Usage: $ram_usage_pct%"

if [ "$ram_usage_pct" -ge 90 ]; then
    echo -e "Result: ${RED}CRITICAL (System is choking on RAM)${NC}"
elif [ "$ram_usage_pct" -ge 75 ]; then
    echo -e "Result: ${YELLOW}WARNING (High memory usage)${NC}"
else
    echo -e "Result: ${GREEN}GOOD${NC}"
fi

sleep 1

# 4. CPU LOAD CHECK
echo -e "\n[+] Checking CPU Load..."
# Gets 1-minute load average
load_avg=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | xargs)
# Gets number of CPU cores to calculate real threshold
cpu_cores=$(nproc)

echo "1-Minute Load Average: $load_avg (Total Cores: $cpu_cores)"

# Simple check: If load average is higher than your core count, the CPU is bottlenecked
if (( $(echo "$load_avg >= $cpu_cores" | bc -l) )); then
    echo -e "Result: ${RED}CRITICAL (CPU is overloaded)${NC}"
elif (( $(echo "$load_avg >= ($cpu_cores * 0.7)" | bc -l) )); then
    echo -e "Result: ${YELLOW}WARNING (CPU load is heavy)${NC}"
else
    echo -e "Result: ${GREEN}GOOD${NC}"
fi

echo -e "\n=================================================="
