#!/bin/bash

# Set strict mode
set -euo pipefail

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

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
if [ -d "results" ]; then
    RESULTS_DIR="results"
else
    RESULTS_DIR="markdown"
fi
COMFY_OUTPUT_DIR="/Users/danielzirpoli/ComfyUI/custom_nodes/ComfyUI-Inspire-Pack/prompts/example"

# Step 1: Extract image descriptions
extract_images() {
    local input_file="$1"
    local output_file="${input_file%.*}_images.txt"
    
    echo -e "${BLUE}Extracting image tags from $input_file${NC}" >&2
    
    # Create a temporary file for processing
    > "$output_file"
    
    # Process the file line by line to extract image tags
    while IFS= read -r line; do
        if [[ $line =~ \[Pic[0-9]+:.*\] ]]; then
            # Extract just the [PicX: description] part
            tag="${BASH_REMATCH[0]}"
            echo -e "${YELLOW}Found image tag: $tag${NC}" >&2
            echo "$tag" >> "$output_file"
        fi
    done < "$input_file"
    
    # Return only the output file path
    echo "$output_file"
}

# Step 2: Process each extracted line and write to output as it's processed
process_and_convert_lines() {
    local input_file="$1"
    local output_file="$2"

    echo -e "${BLUE}Processing lines from $input_file and saving to $output_file${NC}"

    if [ ! -f "$input_file" ]; then
        echo -e "${RED}Error: $input_file does not exist.${NC}"
        return 1
    fi

    # Clear or create the output file
    > "$output_file"

    while IFS= read -r line
    do
        echo -e "\n${YELLOW}Original image tag: $line${NC}"
        
        # Process each line with fabric and store the result
        if command_exists fabric; then
            echo -e "${BLUE}Processing with fabric...${NC}"
            processed_line=$(echo "$line" | fabric -p flux -s)
            if [ $? -ne 0 ]; then
                echo -e "${RED}Error: 'fabric' command failed.${NC}"
                continue
            fi
        else
            echo -e "${RED}Error: 'fabric' command not found. Please install it to process lines.${NC}"
            return 1
        fi

        # Remove all instances of "FLUX.1" and related headers
        processed_line=$(echo "$processed_line" | sed 's/FLUX\.1//g' | sed 's/### Image Generation Prompt for //g' | sed 's/### Prompt for //g' | sed 's/\*\*Prompt for \*\*//g')

        # Convert the processed line to a single line
        processed_line=$(echo "$processed_line" | tr '\n' ' ' | sed 's/  */ /g')

        echo -e "${GREEN}Processed result: $processed_line${NC}"

        # Format the processed line into the correct format with positive/negative sections
        formatted_content="positive: $processed_line\n\nnegative: none\n----\n\n"

        # Append the formatted content to the output file
        echo -e "$formatted_content" >> "$output_file"
        
        echo -e "${GREEN}Successfully processed and saved to output file${NC}"
    done < "$input_file"
    
    echo -e "${GREEN}All lines processed and saved to $output_file${NC}"
}

# Main function to coordinate steps
main() {
    echo -e "${YELLOW}Starting image prompt processing${NC}"

    # Allow the user to select the input file
    echo "Please select an input file from the '$RESULTS_DIR' folder:"
    select md_file in "$RESULTS_DIR"/*.md; do
        if [ -f "$md_file" ]; then
            echo "You selected $md_file"
            break
        else
            echo -e "${RED}Invalid selection. Please try again.${NC}"
        fi
    done

    # Generate a unique output file name based on the input file
    timestamp=$(date +"%Y%m%d_%H%M%S")
    output_file_name=$(basename "${md_file%.*}")
    
    # Check if COMFY_OUTPUT_DIR exists, if not create it
    if [ ! -d "$COMFY_OUTPUT_DIR" ]; then
        echo -e "${YELLOW}Creating directory: $COMFY_OUTPUT_DIR${NC}"
        mkdir -p "$COMFY_OUTPUT_DIR"
    fi
    
    # Set the output file path
    OUTPUT_FILE="${COMFY_OUTPUT_DIR}/comfy_${output_file_name}_${timestamp}.txt"

    # Step 1: Extract images
    image_file=$(extract_images "$md_file")
    
    # Check if the file exists and has content
    if [ -f "$image_file" ] && [ -s "$image_file" ]; then
        echo -e "${GREEN}Image file exists and contains content: $image_file${NC}"
        
        # Step 2: Process and convert each line, saving immediately to output
        echo "Running process_and_convert_lines..."
        if ! process_and_convert_lines "$image_file" "$OUTPUT_FILE"; then
            echo -e "${RED}Error occurred during processing. Exiting.${NC}"
            rm -f "$image_file"  # Clean up the temporary file in case of error
            return 1
        fi

        # Step 3: Delete the temporary _images.txt file
        rm -f "$image_file"
        echo -e "${GREEN}Temporary file $image_file has been deleted.${NC}"
    else
        echo -e "${RED}No image file found or file is empty after extraction.${NC}"
        return 1
    fi

    echo -e "${GREEN}Image prompt processing completed successfully!${NC}"
    echo -e "${GREEN}Output saved to: $OUTPUT_FILE${NC}"
}

# Execute the main function
main
