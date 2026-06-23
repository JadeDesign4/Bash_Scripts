#!/usr/bin/env bash

# ==============================================================================
# 📝 SCRIPT DESCRIPTION
# ==============================================================================
# NAME:        check-dependencies.sh
# TARGET:      Frontend Developers, Project Maintainers, & Security Engineers
# DESCRIPTION: Audits package.json dependencies for security vulnerabilities 
#              and outdated versions before pushing code to production.
# PROBLEM:     Outdated or vulnerable third-party packages silently compromise 
#              frontend application security and performance.
# USAGE:       ./check-dependencies.sh
# ==============================================================================

echo "🛡️  Initiating Frontend Dependency Health & Security Guard..."
echo "==============================================================="

# Verify package.json exists in the current working directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: 'package.json' not found in this directory."
    echo "💡 Tip: Run this script from the root folder of your frontend project."
    exit 1
fi

# Check if npm CLI is available on the machine
if ! command -v npm &>/dev/null; then
    echo "❌ Error: 'npm' is not installed or accessible in the current PATH."
    exit 1
fi

echo "🔍 Step 1: Checking for outdated packages..."
echo "---------------------------------------------------------------"
# npm outdated returns an exit code of 1 if outdated packages exist, so we append || true
npm outdated || true

echo "---------------------------------------------------------------"
echo "🔐 Step 2: Auditing open-source dependencies for vulnerabilities..."
echo "---------------------------------------------------------------"
# Runs a lightweight security audit against the npm registry
npm audit

echo "==============================================================="
echo "🎉 Dependency health screening complete!"
