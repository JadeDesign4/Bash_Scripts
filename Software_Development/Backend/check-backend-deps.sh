#!/usr/bin/env bash

# ==============================================================================
# 📝 SCRIPT DESCRIPTION
# ==============================================================================
# NAME:        check-backend-deps.sh
# TARGET:      Backend Developers, Sysadmins, & Power Users
# DESCRIPTION: Probes a predefined list of local or remote service ports using 
#              lightweight network sockets to verify dependency availability.
# PROBLEM:     Backend apps crash on startup with cryptic connection errors when 
#              dependencies (databases, caches, third-party APIs) are offline.
# USAGE:       ./check-backend-deps.sh
# ==============================================================================

# Define your dependencies here format: "NAME:HOST:PORT"
DEPENDENCIES=(
    "Local-PostgreSQL:127.0.0.1:5432"
    "Local-Redis:127.0.0.1:6379"
    "Local-MongoDB:127.0.0.1:27017"
    "GitHub-API:api.github.com:443"
)

# Timeout in seconds for each check
TIMEOUT=2

echo "🔍 Starting Backend Dependency Health Check..."
echo "=================================================="
echo -e "  STATUS  |  SERVICE NAME       |  ADDRESS:PORT"
echo "--------------------------------------------------"

for dep in "${DEPENDENCIES[@]}"; do
    # Parse the dependency string
    IFS=":" read -r name host port <<< "$dep"
    
    # Use bash built-in /dev/tcp to check connection quickly without needing netcat/telnet
    if (timeout "$TIMEOUT" bash -c "</dev/tcp/$host/$port" 2>/dev/null); then
        printf "  \e[32m[ UP ]\e[0m  |  %-18s |  %s:%s\n" "$name" "$host" "$port"
    else
        printf "  \e[31m[DOWN]\e[0m  |  %-18s |  %s:%s\n" "$name" "$host" "$port"
    fi
done

echo "=================================================="
echo "💡 Tip: If a dependency is [DOWN], ensure its service/docker container is running."