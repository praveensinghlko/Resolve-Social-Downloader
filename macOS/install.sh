#!/bin/bash

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     📥 Social Downloader - macOS Installer                  ║"
echo "║     💻 Developed by Praveen Singh                           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE="$SCRIPT_DIR/Resolve-Social-Downloader.lua"
DEST="$HOME/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/Utility"

# Check if source exists
if [ ! -f "$SOURCE" ]; then
    echo "❌ ERROR: Resolve-Social-Downloader.lua not found!"
    echo "   Make sure install.sh is in the same folder as the .lua file"
    echo ""
    exit 1
fi

# Check if DaVinci Resolve folder exists
if [ ! -d "$HOME/Library/Application Support/Blackmagic Design/DaVinci Resolve" ]; then
    echo "❌ ERROR: DaVinci Resolve not found!"
    echo "   Please install DaVinci Resolve first."
    echo ""
    exit 1
fi

# Create destination folder if needed
mkdir -p "$DEST"

# Copy script
cp "$SOURCE" "$DEST/"

if [ $? -eq 0 ]; then
    echo "✅ Script installed successfully!"
    echo ""
    echo "📁 Installed to:"
    echo "   $DEST/"
    echo ""
    echo "🚀 How to run:"
    echo "   1. Open DaVinci Resolve"
    echo "   2. Go to: Workspace → Scripts → Utility"
    echo "   3. Click: Resolve-Social-Downloader"
    echo ""

    # Check dependencies
    echo "🔍 Checking dependencies..."
    echo ""

    if command -v yt-dlp &> /dev/null; then
        echo "   ✅ yt-dlp: $(yt-dlp --version)"
    else
        echo "   ❌ yt-dlp: NOT FOUND"
        echo "      Install: brew install yt-dlp"
    fi

    if command -v ffmpeg &> /dev/null; then
        echo "   ✅ ffmpeg: installed"
    else
        echo "   ❌ ffmpeg: NOT FOUND"
        echo "      Install: brew install ffmpeg"
    fi

    echo ""

    # Ask to install dependencies
    if ! command -v yt-dlp &> /dev/null || ! command -v ffmpeg &> /dev/null; then
        echo "📦 Do you want to install missing dependencies? (y/n)"
        read -r answer
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
            # Check Homebrew
            if ! command -v brew &> /dev/null; then
                echo "🍺 Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            echo "📦 Installing yt-dlp..."
            brew install yt-dlp
            echo "📦 Installing ffmpeg..."
            brew install ffmpeg
            echo ""
            echo "✅ All dependencies installed!"
        fi
    fi

    echo ""
    echo "🎬 Done! Open DaVinci Resolve and enjoy!"
    echo ""
else
    echo "❌ Installation failed!"
    echo "   Try running with sudo:"
    echo "   sudo bash install.sh"
    echo ""
    exit 1
fi
