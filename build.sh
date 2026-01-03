#!/bin/bash
# PaperMaker V2 Build Script
# Usage: ./build.sh <config-file.json> [output-name]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Ensure common binary paths are included (needed for Node.js/macOS execution)
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Check if Typst is installed
if ! command -v typst &> /dev/null; then
    echo -e "${RED}Error: Typst is not installed.${NC}"
    exit 1
fi

# Check arguments
if [ $# -lt 1 ]; then
    echo -e "${YELLOW}Usage: ./build.sh <config-file.json> [output-name]${NC}"
    exit 1
fi

CONFIG_FILE="$1"
OUTPUT_NAME="${2:-calendar}"

echo "Debug: CONFIG_FILE=$CONFIG_FILE"
echo "Debug: OUTPUT_NAME=$OUTPUT_NAME"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Error: Configuration file not found: $CONFIG_FILE${NC}"
    exit 1
fi

# Create output directory
mkdir -p output

# Extract year from config for output filename
# Using a simpler grep pattern
YEAR=$(grep -o '"startYear": [0-9]*' "$CONFIG_FILE" | grep -o '[0-9]*' | head -n 1 || echo "2025")
echo "Debug: Extracted YEAR=$YEAR"

OUTPUT_FILE="output/${OUTPUT_NAME}-${YEAR}.pdf"
echo "Debug: OUTPUT_FILE=$OUTPUT_FILE"

echo -e "${GREEN}PaperMaker V2 - Constructing PDF...${NC}"
echo "----------------------------------------"

# Compile with Typst from the root
# We point to the main template and pass the config path relative to the template
echo "Running: typst compile templates/main.typ \"$OUTPUT_FILE\" --input config=\"../$(basename "$CONFIG_FILE")\" --root . --font-path ./fonts"

if typst compile templates/main.typ "$OUTPUT_FILE" --input config="../$(basename "$CONFIG_FILE")" --root . --font-path ./fonts 2>&1; then
    echo -e "${GREEN}✓ Success! PDF generated: $OUTPUT_FILE${NC}"
else
    echo -e "${RED}Refined Build Diagnostic:${NC}"
    echo "1. Working Directory: $(pwd)"
    echo "2. Typst Path: $(which typst)"
    echo "3. Config Basename: $(basename "$CONFIG_FILE")"
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi
