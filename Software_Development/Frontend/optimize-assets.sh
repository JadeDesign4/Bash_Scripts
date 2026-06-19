#!/usr/bin/env bash

# ==============================================================================
# 📝 SCRIPT DESCRIPTION
# ==============================================================================
# NAME:        optimize-assets.sh
# TARGET:      Frontend Developers, Web Designers, & Content Creators
# DESCRIPTION: Detects the OS and optimizes local project images (.png, .jpg)
#              to reduce web bundle sizes and boost load speeds.
# PROBLEM:     Uncompressed assets bloat modern frontend deployments and hurt
#              SEO/Lighthouse performance scores.
# USAGE:       ./optimize-assets.sh [path/to/images]
# ==============================================================================

TARGET_DIR="${1:-./assets}"

echo "🖼️  Initiating Smart Frontend Asset Optimizer..."
echo "=================================================="

# Check if target folder exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "⚠️  Directory '$TARGET_DIR' not found. Creating it for placeholder use..."
    mkdir -p "$TARGET_DIR"
fi

# 1. Detect Operating System & Choose Processing Engine
OS_TYPE="$(uname -s)"
echo "🖥️  Detected OS: $OS_TYPE"

optimize_mac() {
    echo "⚙️  Using macOS Native 'sips' Engine..."
    echo "--------------------------------------------------"
    find "$TARGET_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | while read -r img; do
        echo "⚡ Optimizing: $(basename "$img")"
        # sips utilities are built-in natively to macOS
        sips -Z 1200 "$img" &>/dev/null # Rescales max width/height to 1200px while maintaining aspect ratio
        echo "   ✅ Done!"
    done
}

optimize_linux() {
    # Check for ImageMagick on Linux systems
    if command -v convert &>/dev/null; then
        echo "⚙️  Using Linux 'ImageMagick' Engine..."
        echo "--------------------------------------------------"
        find "$TARGET_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | while read -r img; do
            echo "⚡ Compressing: $(basename "$img")"
            convert "$img" -resize 1200x1200\> -quality 85 "$img"
            echo "   ✅ Done!"
        done
    else
        echo -e "\n❌ \e[31mError: No native image optimization CLI tools found on this Linux environment.\e[0m"
        echo "💡 To activate compression features, please run: sudo apt install imagemagick"
        exit 1
    fi
}

# Run the appropriate engine
if [ "$OS_TYPE" = "Darwin" ]; then
    optimize_mac
elif [ "$OS_TYPE" = "Linux" ]; then
    optimize_linux
else
    echo "❌ Unsupported OS type: $OS_TYPE"
    exit 1
fi

echo "=================================================="
echo "🎉 Asset optimization routine completed for '$TARGET_DIR'!"
