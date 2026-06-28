#!/usr/bin/env bash

# ==============================================================================
# 📝 SCRIPT DESCRIPTION
# ==============================================================================
# NAME:        lint-dockerfile.sh
# TARGET:      DevOps Engineers, Cloud Architects, & Security Engineers
# DESCRIPTION: Scans a local Dockerfile for security and stability anti-patterns
#              (e.g., root execution, unpinned base tags, missing healthchecks).
# PROBLEM:     Misconfigured container builds leak credentials, increase attack 
#              surfaces, and introduce unpredictable breakages in cloud pipelines.
# USAGE:       ./lint-dockerfile.sh [path/to/Dockerfile]
# ==============================================================================

DOCKERFILE="${1:-Dockerfile}"
FAILED_RULES=0

echo "🛡️  Initiating Pre-Flight Container Security & Linting Guard..."
echo "==============================================================="

if [ ! -f "$DOCKERFILE" ] && [ ! -s "$DOCKERFILE" ]; then
    echo "💡 Target '$DOCKERFILE' not found. Creating a sample Dockerfile with common anti-patterns for review..."
    cat << 'EOF' > "$DOCKERFILE"
FROM node:latest
WORKDIR /app
COPY . .
RUN npm install
EXPOSE 3000
CMD ["node", "server.js"]
EOF
fi

echo "🔍 Analyzing build manifest instructions: '$DOCKERFILE'"
echo "---------------------------------------------------------------"

# --- Rule 1: Check for unstable base image configurations (:latest tag) ---
if grep -E "^FROM[[:space:]]+[^[:space:]]+:latest" "$DOCKERFILE" &>/dev/null || ! grep -E "^FROM[[:space:]]+[^[:space:]]+:[a-zA-Z0-9._-]+" "$DOCKERFILE" &>/dev/null; then
    echo -e "⚠️  [\e[33mSTABILITY\e[0m] Unpinned or ':latest' base image detected."
    echo "   👉 Fix: Pin your base layer to a specific version digest (e.g., node:20-alpine)."
    ((FAILED_RULES++))
fi

# --- Rule 2: Check for missing explicit non-root service execution profile ---
if ! grep -E "^USER[[:space:]]+" "$DOCKERFILE" &>/dev/null; then
    echo -e "🚨 [\e[31mSECURITY\e[0m ] Missing non-root 'USER' designation instruction."
    echo "   👉 Fix: Add 'USER node' or 'USER 10001' to prevent containers running with root host privileges."
    ((FAILED_RULES++))
fi

# --- Rule 3: Check for suspicious environment variables or credentials ---
if grep -E "ENV.*(PASSWORD|SECRET|TOKEN|KEY)=" "$DOCKERFILE" &>/dev/null; then
    echo -e "🚨 [\e[31mSECURITY\e[0m ] Hardcoded sensitive credential placeholders detected inside ENV blocks."
    echo "   👉 Fix: Inject operational variables via runtime parameter mapping or secrets managers."
    ((FAILED_RULES++))
fi

# --- Rule 4: Check for missing operational availability polling ---
if ! grep -E "^HEALTHCHECK" "$DOCKERFILE" &>/dev/null; then
    echo -e "⚠️  [\e[33mTELEMETRY\e[0m] Missing native container 'HEALTHCHECK' definition."
    echo "   👉 Fix: Configure a HEALTHCHECK instruction to allow orchestrators (K8s/ECS) to track readiness."
    ((FAILED_RULES++))
fi

echo "---------------------------------------------------------------"
if [ "$FAILED_RULES" -eq 0 ]; then
    echo -e "🎉 \e[32mPASSED!\e[0m Manifest meets baseline security and structural compliance criteria."
else
    echo -e "❌ \e[31mREJECTED!\e[0m Found $FAILED_RULES container validation variance issues listed above."
fi
echo "==============================================================="

[ "$FAILED_RULES" -eq 0 ] && exit 0 || exit 1
