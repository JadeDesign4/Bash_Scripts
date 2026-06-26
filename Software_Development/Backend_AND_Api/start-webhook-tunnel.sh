#!/usr/bin/env bash

# ==============================================================================
# 📝 SCRIPT DESCRIPTION
# ==============================================================================
# NAME:        start-webhook-tunnel.sh
# TARGET:      Backend Developers, API Engineers, & Integration Testers
# DESCRIPTION: Automates launching an external public tunnel (via ngrok) to expose
#              a local backend API port for testing external live webhooks.
# PROBLEM:     External APIs (Stripe, GitHub) cannot route payloads directly to 
#              localhost:3000, requiring tedious manual proxy setups.
# USAGE:       ./start-webhook-tunnel.sh [port]
# ==============================================================================

LOCAL_PORT="${1:-3000}"

echo "🌐 Initiating Backend Webhook Tunnel Proxy Automator..."
echo "==============================================================="

# Verify that ngrok is installed and available in the current PATH
if ! command -v ngrok &>/dev/null; then
    echo "❌ Error: 'ngrok' CLI utility was not found on this machine."
    echo "💡 Instruction: Please install ngrok (https://ngrok.com) or adjust your PATH."
    exit 1
fi

echo "🚀 Launching secure proxy tunnel pointing to localhost:$LOCAL_PORT..."
echo "---------------------------------------------------------------"

# Launch ngrok in the background and discard raw tracking output
ngrok http "$LOCAL_PORT" > /dev/null 2>&1 &
NGROK_PID=$!

# Allow the background process a brief moment to negotiate the connection handshake
sleep 3

# Query ngrok's local agent API endpoint to extract the newly assigned public URL
PUBLIC_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -o '"public_url":"[^"]*' | head -n1 | cut -d'"' -f4)

if [ -z "$PUBLIC_URL" ]; then
    echo "❌ Error: Failed to extract a public routing URL."
    echo "💡 Tip: Make sure your ngrok authentication token is configured ('ngrok config add-authtoken <token>')."
    kill $NGROK_PID 2>/dev/null
    exit 1
fi

echo -e "🎉 \e[32mTUNNEL ESTABLISHED SUCCESSFULLY!\e[0m"
echo -e "🔗 Public Entrypoint: \e[36m$PUBLIC_URL\e[0m"
echo "👉 Target Endpoint:   http://localhost:$LOCAL_PORT"
echo "---------------------------------------------------------------"
echo "🛑 Press [CTRL+C] to tear down the tunnel and close proxy lines safely."
echo "==============================================================="

# Hold the process forward-facing to maintain active lines until execution interruption
trap "echo -e '\n🛑 Tearing down proxy processes...'; kill $NGROK_PID 2>/dev/null; exit 0" SIGINT SIGTERM
while kill -0 $NGROK_PID 2>/dev/null; do sleep 1; done
