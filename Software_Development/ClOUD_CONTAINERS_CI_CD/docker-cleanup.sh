#!/usr/bin/env bash

# ==============================================================================
# 📝 SCRIPT DESCRIPTION
# ==============================================================================
# NAME:        docker-cleanup.sh
# TARGET:      Developers using Docker, DevOps Engineers, & Cloud Architects
# DESCRIPTION: Calculates Docker storage footprints, selectively purges dangling 
#              or orphaned container resources, and reports reclaimed space.
# PROBLEM:     Unused container layers, stopped instances, and build caches silently 
#              hoard tens of gigabytes of storage over prolonged dev cycles.
# USAGE:       ./docker-cleanup.sh
# ==============================================================================

echo "🐳 Initiating Smart Docker Hygiene & Space Optimizer..."
echo "==============================================================="

# Verify if the Docker daemon is installed and actively running
if ! command -v docker &>/dev/null; then
    echo "❌ Error: 'docker' CLI utility was not found on this system."
    exit 1
fi

if ! docker info &>/dev/null; then
    echo "❌ Error: Cannot connect to the Docker daemon."
    echo "💡 Instruction: Please ensure Docker Desktop or the Docker daemon service is running."
    exit 1
fi

echo "📊 Step 1: Evaluating current Docker storage footprint..."
echo "---------------------------------------------------------------"
docker system df

echo "---------------------------------------------------------------"
echo "🧹 Step 2: Commencing safe, targeted resource extraction..."
echo "---------------------------------------------------------------"

# 1. Clear stopped containers
echo "🔹 Removing stopped containers..."
docker container prune -f

# 2. Clear dangling images (orphaned layers with no tag tags)
echo "🔹 Purging dangling images..."
docker image prune -f

# 3. Clear unused networks
echo "🔹 Clearing empty custom networks..."
docker network prune -f

# 4. Clear build cache layers (highly effective for reclaiming space)
echo "🔹 Compacting BuildKit developer cache matrices..."
docker builder prune -f

echo "---------------------------------------------------------------"
echo "📊 Step 3: Optimization complete! Post-cleanup status:"
echo "---------------------------------------------------------------"
docker system df

echo "==============================================================="
echo "🎉 Docker development storage environment successfully optimized!"
