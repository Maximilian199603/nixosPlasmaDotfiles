#!/usr/bin/env bash

# Set the fallback image path
FALLBACK_IMAGE="$HOME/Pictures/Wallpapers/.fallback.jpg"

# Log directory and file
LOG_DIR="$HOME/.local/share/plasma-wallpaper-logs"
mkdir -p "$LOG_DIR"  # Create directory if it does not exist
TIMESTAMP=$(date +"%d%m%Y_%H%M%S")
LOG_FILE="$LOG_DIR/plasma-random-wallpaper-picker_$TIMESTAMP.log"

# Write output to log file
exec > >(tee -a "$LOG_FILE") 2>&1

# Check if the fallback image exists
if [ ! -f "$FALLBACK_IMAGE" ]; then
    echo "Error: Fallback image '$FALLBACK_IMAGE' does not exist."
    exit 1
fi

# Check if the directory path is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <directory_path>"
    exit 1
fi

# Check if the provided path is a directory
if [ ! -d "$1" ]; then
    echo "Error: '$1' is not a directory. Using fallback wallpaper."
    random_file=$FALLBACK_IMAGE
else
    # Get the list of files in the directory
    files=($(find "$1" -maxdepth 1 -type f ! -name ".*"))

    # Check if there are any files in the directory
    if [ ${#files[@]} -eq 0 ]; then
        echo "Error: No files found in the directory. Using fallback wallpaper."
        random_file=$FALLBACK_IMAGE
    else
        # Choose a random file from the directory
        random_file=${files[RANDOM % ${#files[@]}]}
    fi
fi

# Check if the random_file exists, otherwise use the fallback image
if [ ! -f "$random_file" ]; then
    echo "Error: Selected wallpaper '$random_file' does not exist. Using fallback wallpaper."
    random_file=$FALLBACK_IMAGE
fi

$HOME/.local/bin/plasmaWallpaperSetter.sh "$random_file"
