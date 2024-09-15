#!/usr/bin/env bash

# Log directory and file
LOG_DIR="$HOME/.local/share/plasma-wallpaper-logs"
mkdir -p "$LOG_DIR"  # Create directory if it does not exist
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/plasma-wallpaper_$TIMESTAMP.log"

# Write output to log file
exec > >(tee -a "$LOG_FILE") 2>&1

# Check if the file path is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <file_path>"
    exit 1
fi

# Check if the provided path is a file
if [ ! -f "$1" ]; then
    echo "Error: '$1' is not a file or does not exist."
    exit 1
fi

# Use the provided file path
wallpaper_file="$1"

# Ensure qdbus is available
if ! command -v qdbus &> /dev/null; then
    echo "Error: qdbus command not found. Please install it to set the wallpaper."
    exit 1
fi

# Set the wallpaper for all desktops using qdbus
if ! qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
var allDesktops = desktops();
for (i=0;i<allDesktops.length;i++) {
    d = allDesktops[i];
    d.wallpaperPlugin = 'org.kde.image';
    d.currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
    d.writeConfig('Image', 'file://$wallpaper_file')
}" ; then
    echo "Error: Failed to set wallpaper using qdbus."
    exit 1
fi

echo "Wallpaper set to: $wallpaper_file"