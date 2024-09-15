#!/usr/bin/env bash

# Check if the directory path is provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory_path>"
    exit 1
fi

# Directory containing images
IMAGE_DIR="$1"

# Path to the rofi theme file
ROFI_THEME="$HOME/.config/rofi/wallpaper-chooser.rasi"

# Check if the rofi theme file exists
if [ ! -f "$ROFI_THEME" ]; then
    echo "Error: Rofi theme file '$ROFI_THEME' does not exist."
    exit 1
fi

# Create an associative array to map filenames to their full paths
declare -A file_map

# Populate the associative array with image files
while IFS= read -r -d '' file; do
    filename=$(basename "$file")
    file_map["$filename"]="$file"
done < <(find "$IMAGE_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.tiff" -o -iname "*.gif" \) -print0)

# Generate the list of filenames, each on a new line
filenames=$(printf "%s\n" "${!file_map[@]}")

# Display the filenames in `rofi` and capture the selected filename
selected_filename=$(echo "$filenames" | rofi -dmenu -p "Select an image:" -theme "$ROFI_THEME")

# Exit if no selection was made
if [ -z "$selected_filename" ]; then
    echo "No image selected. Exiting."
    exit 1
fi

# Get the full path of the selected filename from the map
selected_image_path="${file_map[$selected_filename]}"

# Check if the image path is found
if [ -z "$selected_image_path" ]; then
    echo "Error: Selected image '$selected_filename' does not exist."
    exit 1
fi

# Execute the wallpaper setter script with the full path of the selected image
plasmaWallpaperSetter.sh "$selected_image_path"

