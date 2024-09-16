#!/usr/bin/env bash

# Colors
RED='\033[31m'
GREEN='\033[32m'
BLUE='\033[34m'
RESET='\033[0m'

# Check for required parameters
if [ $# -lt 2 ]; then
    echo "Usage: $0 <days_to_keep> <pattern>"
    echo "Example: $0 30 'plasma-wallpaper_*.log'"
    exit 1
fi

# Parameters
DAYS_TO_KEEP="$1"
PATTERN="$2"

# Current working directory
PWD_DIR=$(pwd)

# Check if the script is running in the root of the filesystem or home directory
if [ "$PWD_DIR" = "/" ] || [ "$PWD_DIR" = "$HOME" ]; then
    echo -e "${RED}Error: This script cannot be run in the root of the filesystem or the user's home directory.${RESET}"
    exit 1
fi

# Check for write permissions
if [ ! -w "$PWD_DIR" ]; then
    echo -e "${RED}Error: No write permissions for directory $PWD_DIR.${RESET}"
    exit 1
fi

# Sanity check for days_to_keep
if ! [[ "$DAYS_TO_KEEP" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Error: '$DAYS_TO_KEEP' is not a valid number of days.${RESET}"
    exit 1
fi

# Sanity check for pattern
if [ -z "$PATTERN" ]; then
    echo -e "${RED}Error: Pattern cannot be empty.${RESET}"
    exit 1
fi

# Find files to be deleted
FILES_TO_DELETE=$(find "$PWD_DIR" -type f -name "$PATTERN" -mtime +"$DAYS_TO_KEEP")

# Count the files and check if the output is empty
if [ -z "$FILES_TO_DELETE" ]; then
    echo "No files to delete."
    exit 0
fi

# Print the number of files to be deleted with colors
FILE_COUNT=$(echo "$FILES_TO_DELETE" | wc -l)
echo -e "Found ${RED}$FILE_COUNT${RESET} file(s) older than ${GREEN}$DAYS_TO_KEEP${RESET} days matching pattern ${BLUE}'$PATTERN'${RESET}."

# Ask if user wants to see the file paths
read -t 30 -p "Do you want to see the list of file paths? (y/N): " SHOW_FILES
if [[ "$SHOW_FILES" =~ ^[Yy]$ ]]; then
    echo "Files to be deleted:"
    echo "$FILES_TO_DELETE"
fi

# First confirmation prompt
read -t 30 -p "Do you really want to delete these files? (y/N): " CONFIRM_FIRST
if ! [[ "$CONFIRM_FIRST" =~ ^[Yy]$ ]]; then
    echo "No files were deleted."
    exit 0
fi

# Final confirmation prompt in red
echo -e "${RED}Are you absolutely sure you want to delete these files?${RESET}"
read -t 30 -p "(y/N): " CONFIRM_FINAL
if [[ "$CONFIRM_FINAL" =~ ^[Yy]$ ]]; then
    echo "$FILES_TO_DELETE" | xargs -r rm
    echo -e "${RED}Deleted $FILE_COUNT file(s).${RESET}"
else
    echo "No files were deleted."
    exit 0
fi

