#!/bin/bash

# Detect the package manager
if command -v pacman &> /dev/null; then
    echo "=== Arch Linux Detected ==="
    echo "Fetching apps and summaries..."
    echo "----------------------------------------"
    # List explicit packages and format output to show Name - Description
    pacman -Qei | awk '/^Name/ {name=$3} /^Description/ {$1=""; print name " -" $0}'

elif command -v apt-get &> /dev/null; then
    echo "=== Debian/Ubuntu Detected ==="
    echo "Fetching apps and summaries..."
    echo "----------------------------------------"
    # List installed packages and pull their short descriptions
    dpkg-query -W -f='${Package} - ${Description}\n' | awk -F' - ' '{print $1 " - " $2}'

else
    echo "Error: This script only supports Arch or Debian-based distributions."
    exit 1
fi
