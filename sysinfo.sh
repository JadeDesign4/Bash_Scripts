#!/bin/bash

# Ensure the script is run as root for full information
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo) to fetch all hardware details."
  exit 1
fi

echo "=================================================="
echo "               SYSTEM INFORMATION                 "
echo "=================================================="

echo -e "\n--- [ System & OS Details ] ---"
echo "Hostname:      $(hostname)"
echo "OS Name:       $(grep -w "PRETTY_NAME" /etc/os-release | cut -d= -f2 | tr -d '"')"
echo "Kernel:        $(uname -r)"
echo "Architecture:  $(uname -m)"
echo "Uptime:        $(uptime -p)"

echo -e "\n--- [ CPU Information ] ---"
echo "Model:         $(lscpu | grep 'Model name:' | sed 's/Model name:[ \t]*//')"
echo "Architecture:  $(lscpu | grep 'Architecture:' | sed 's/Architecture:[ \t]*//')"
echo "Total Cores:   $(nproc)"
echo "CPU Usage:     $(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4"%"}')"

echo -e "\n--- [ Memory (RAM) ] ---"
free -h | awk 'NR==1{print "Type\t\tTotal\tUsed\tFree"} NR==2{print "RAM:\t\t"$2"\t"$3"\t"$4} NR==3{print "Swap:\t\t"$2"\t"$3"\t"$4}'

echo -e "\n--- [ Disk Usage ] ---"
df -h --total | grep -E 'Filesystem|total' | awk '{print "Total Disk:\tSize: "$2" | Used: "$3" | Available: "$4" ("$5")"}'

echo -e "\n--- [ Network Information ] ---"
echo "IP Address:    $(hostname -I | awk '{print $1}')"
echo "Gateway:       $(ip route | grep default | awk '{print $3}')"
echo "DNS Server:    $(grep nameserver /etc/resolv.conf | awk '{print $2}' | paste -sd, -)"

echo -e "\n--- [ Logged In Users ] ---"
who

echo "=================================================="
