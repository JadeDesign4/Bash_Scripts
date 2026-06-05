#!/bin/bash

# Exit on any error
set -e

# Safety check: Ensure script is run with sudo/root privileges
if [ "$EUID" -ne 0 ]; then
  echo "❌ Error: Please run this script with sudo or as root."
  exit 1
fi

# Detect Linux Distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "❌ Error: Could not detect the operating system version."
    exit 1
fi

echo "🚀 Detected OS: $OS"

case "$OS" in
    ubuntu|debian)
        echo "📦 Installing tools via apt (Debian/Ubuntu)..."
        apt-get update
        apt-get install -y grim slurp swappy wf-recorder wl-clipboard ffmpeg pipewire notify-osd
        ;;

    arch)
        echo "📦 Installing tools via pacman (Arch Linux)..."
        # Using --overwrite "*" to bypass any manual filesystem file conflicts
        pacman -Syu --noconfirm --overwrite "*" grim slurp swappy wf-recorder wl-clipboard ffmpeg pipewire
        ;;

    *)
        echo "❌ Error: Unsupported Linux distribution for this specific script: $OS"
        exit 1
        ;;
esac

# --- CONFIGURATION LAYER ---
# Find the actual human user who invoked sudo
HUMAN_USER=${SUDO_USER:-$USER}
HUMAN_HOME=$(eval echo ~$HUMAN_USER)

echo "⚙️ Setting up Swappy configuration for user: $HUMAN_USER"

# Create Swappy config directory cleanly under the user's home
mkdir -p "$HUMAN_HOME/.config/swappy"

# Generate the config file
cat << EOF > "$HUMAN_HOME/.config/swappy/config"
[config]
save_dir=$HUMAN_HOME/Pictures/Screenshots
save_filename_format=Screenshot_%Y%m%d_%H%M%S.png
show_panel=true
line_size=5
text_size=20
EOF

# Ensure the human user owns their config files and directories
chown -R "$HUMAN_USER:$HUMAN_USER" "$HUMAN_HOME/.config/swappy"
mkdir -p "$HUMAN_HOME/Pictures/Screenshots" "$HUMAN_HOME/Videos"
chown -R "$HUMAN_USER:$HUMAN_USER" "$HUMAN_HOME/Pictures" "$HUMAN_HOME/Videos"

echo "------------------------------------------------------------"
echo "✅ Backend tools and configurations successfully installed!"
echo "------------------------------------------------------------"
echo "👉 FINAL STEP: To make your keys work, paste the shortcut keys"
echo "   into your window manager config file."
echo ""
echo "   If using Hyprland, paste these into your config file:"
echo "   bind = CTRL ALT, P, exec, grim -g \"\$(slurp)\" - | swappy -f -"
echo "   bind = CTRL ALT, O, exec, grim - | wl-copy"
echo "   bind = CTRL ALT, R, exec, notify-send \"Screen Recorder\" \"Select zone...\" && wf-recorder -g \"\$(slurp)\" -f ~/Videos/Recording_\$(date +%Y%m%d_%H%M%S).mp4"
echo "   bind = CTRL ALT, X, exec, killall -s SIGINT wf-recorder && notify-send \"Screen Recorder\" \"Saved!\""
echo "------------------------------------------------------------"
