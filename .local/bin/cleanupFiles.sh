#!/usr/bin/env bash

# Colors
RED='\033[31m'
GREEN='\033[32m'
BLUE='\033[34m'
RESET='\033[0m'

# Default values
INTERACTIVE_MODE=false

# Parse command-line arguments
while getopts ":i" opt; do
    case ${opt} in
        i )
            INTERACTIVE_MODE=true
            ;;
        \? )
            echo -e "${RED}Invalid option: -$OPTARG${RESET}" >&2
            echo "Usage: $0 [-i] <days_to_keep> <pattern>"
            exit 1
            ;;
        : )
            echo -e "${RED}Invalid option: -$OPTARG requires an argument${RESET}" >&2
            echo "Usage: $0 [-i] <days_to_keep> <pattern>"
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

# Check for required parameters
if [ $# -lt 2 ]; then
    echo "Usage: $0 [-i] <days_to_keep> <pattern>"
    echo "Example: $0 -i 30 'plasma-wallpaper_*.log'"
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

# Find files to be deleted and count them
FILES_TO_DELETE=$(find "$PWD_DIR" -type f -name "$PATTERN" -mtime +$DAYS_TO_KEEP)
FILE_COUNT=$(echo "$FILES_TO_DELETE" | wc -l)

# Print the number of files to be deleted with colors
echo -e "Found ${RED}$FILE_COUNT${RESET} file(s) older than ${GREEN}$DAYS_TO_KEEP${RESET} days matching pattern ${BLUE}'$PATTERN'${RESET}."

if [ "$FILE_COUNT" -eq 0 ]; then
    echo "No files to delete."
    exit 0
fi

# Interactive view mode
if $INTERACTIVE_MODE; then
    echo "Interactive mode enabled."
    echo "Files to be deleted:"
    PS3='Please select a file to delete (or type 0 to exit): '
    select FILE in $FILES_TO_DELETE; do
        if [ "$REPLY" -eq 0 ]; then
            echo "Exiting interactive mode."
            break
        elif [ -n "$FILE" ]; then
            echo -e "Do you want to delete ${RED}$FILE${RESET}? (y/N): "
            read -r CONFIRM_FILE
            if [[ "$CONFIRM_FILE" =~ ^[Yy]$ ]]; then
                rm "$FILE"
                echo -e "${RED}$FILE deleted.${RESET}"
            else
                echo -e "${RED}$FILE not deleted.${RESET}"
            fi
        else
            echo "Invalid selection. Please try again."
        fi
    done
    exit 0
fi

# Ask if user wants to see the file paths
read -t 30 -p "Do you want to see the list of file paths? (y/N): " SHOW_FILES
if [[ "$SHOW_FILES" =~ ^[Yy]$ ]]; then
    echo "Files to be deleted:"
    echo "$FILES_TO_DELETE"
fi

# Backup option
read -t 30 -p "Do you want to create a backup of these files before deleting? (y/N): " BACKUP
if [[ "$BACKUP" =~ ^[Yy]$ ]]; then
    BACKUP_DIR="$PWD_DIR/backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    echo "$FILES_TO_DELETE" | xargs -I{} cp {} "$BACKUP_DIR/"
    echo "Backup created in $BACKUP_DIR."
fi

# First confirmation prompt
read -t 30 -p "Do you really want to delete these files? (y/N): " CONFIRM_FIRST
if ! [[ "$CONFIRM_FIRST" =~ ^[Yy]$ ]]; then
    echo "No files were deleted."
    exit 0
fi

# Optional second confirmation prompt
read -t 30 -p "This is your last chance to review the list. Do you want to see the file paths again? (y/N): " SHOW_FILES_AGAIN
if [[ "$SHOW_FILES_AGAIN" =~ ^[Yy]$ ]]; then
    echo "Files to be deleted:"
    echo "$FILES_TO_DELETE"
fi

# Final confirmation prompt in red
echo -e "${RED}Are you absolutely sure you want to delete these files?${RESET}"
read -t 30 -p "(y/N): " CONFIRM_FINAL
if [[ "$CONFIRM_FINAL" =~ ^[Yy]$ ]]; then
    echo "$FILES_TO_DELETE" | xargs rm
    echo -e "${RED}Deleted $FILE_COUNT file(s).${RESET}"
else
    echo "No files were deleted."
    exit 0
fi