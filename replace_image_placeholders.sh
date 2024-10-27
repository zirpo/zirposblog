#!/bin/bash

# Set strict mode
set -euo pipefail

# Function to check if the terminal supports colors
supports_color() {
    if [ -t 1 ]; then
        ncolors=$(tput colors)
        if [ -n "$ncolors" ] && [ $ncolors -ge 8 ]; then
            return 0
        fi
    fi
    return 1
}

# Define color codes
if supports_color; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'  # No Color (reset)
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# Define directories
MARKDOWN_DIR="markdown"
IMAGES_DIR="images"

# Function to select a post
select_post() {
    echo -e "${BLUE}Please select a post to modify:${NC}" >&2
    select post in "$MARKDOWN_DIR"/*.md; do
        if [ -f "$post" ]; then
            echo -e "${GREEN}You selected: $post${NC}" >&2
            echo "$post"
            return
        else
            echo -e "${RED}Invalid selection. Please try again.${NC}" >&2
        fi
    done
}

# Function to get the corresponding image folder
get_image_folder() {
    local post_file="$1"
    local post_name=$(basename "$post_file" .md)
    local image_folder="$IMAGES_DIR/$post_name"
    
    if [ -d "$image_folder" ]; then
        echo "$image_folder"
    else
        echo -e "${RED}Error: Image folder not found for $post_name${NC}" >&2
        return 1
    fi
}

# Function to replace placeholders with images
replace_placeholders() {
    local post_file="$1"
    local image_folder="$2"
    local temp_file=$(mktemp)

    echo -e "${YELLOW}Replacing placeholders in $post_file${NC}"

    while IFS= read -r line; do
        if [[ $line =~ \[Pic([0-9]+):\ (.+)\] ]]; then
            pic_num=${BASH_REMATCH[1]}
            description=${BASH_REMATCH[2]}
            padded_num=$(printf "%05d" $pic_num)
            image_file=$(find "$image_folder" -name "*_${padded_num}_*.png" -print -quit)
            
            if [ -f "$image_file" ]; then
                image_name=$(basename "$image_file")
                replacement="![${description}](${image_folder}/${image_name})"
                echo -e "${GREEN}Replacing [Pic${pic_num}: ${description}] with ${replacement}${NC}"
                echo "${line/\[Pic${pic_num}: ${description}\]/$replacement}" >> "$temp_file"
            else
                echo -e "${RED}Warning: Image file not found for Pic${pic_num}${NC}" >&2
                echo "$line" >> "$temp_file"
            fi
        else
            echo "$line" >> "$temp_file"
        fi
    done < "$post_file"

    mv "$temp_file" "$post_file"
    echo -e "${GREEN}Placeholders replaced successfully in $post_file${NC}"
}

# Main function
main() {
    echo -e "${BLUE}Starting image placeholder replacement process${NC}"

    post_file=$(select_post)
    echo -e "${YELLOW}Debug: Selected file path: $post_file${NC}"

    if [ ! -f "$post_file" ]; then
        echo -e "${RED}Error: Selected file does not exist.${NC}"
        echo -e "${YELLOW}Debug: Current working directory: $(pwd)${NC}"
        echo -e "${YELLOW}Debug: List of files in $MARKDOWN_DIR:${NC}"
        ls -l "$MARKDOWN_DIR"
        exit 1
    fi

    image_folder=$(get_image_folder "$post_file")
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to find image folder. Exiting.${NC}"
        exit 1
    fi

    replace_placeholders "$post_file" "$image_folder"

    echo -e "${GREEN}Image placeholder replacement completed successfully!${NC}"
}

# Execute the main function
main
