#!/bin/bash

# PDF Calendar Build Script
# Usage: ./build.sh <config-file.json> [output-name]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Typst is installed
if ! command -v typst &> /dev/null; then
    echo -e "${RED}Error: Typst is not installed.${NC}"
    echo "Please install Typst from: https://github.com/typst/typst"
    echo "Or use: brew install typst (on macOS)"
    exit 1
fi

# Check arguments
if [ $# -lt 1 ]; then
    echo -e "${YELLOW}Usage: ./build.sh <config-file.json> [output-name]${NC}"
    echo ""
    echo "Examples:"
    echo "  ./build.sh examples/full-calendar.json"
    echo "  ./build.sh my-config.json my-calendar"
    echo ""
    exit 1
fi

CONFIG_FILE="$1"
OUTPUT_NAME="${2:-calendar}"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Error: Configuration file not found: $CONFIG_FILE${NC}"
    exit 1
fi

# Extract year from config for output filename
YEAR=$(grep -o '"year"[[:space:]]*:[[:space:]]*[0-9]*' "$CONFIG_FILE" | grep -o '[0-9]*')
if [ -z "$YEAR" ]; then
    YEAR="unknown"
fi

OUTPUT_FILE="output/${OUTPUT_NAME}-${YEAR}.pdf"

echo -e "${GREEN}PDF Calendar Generator${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Config: $CONFIG_FILE"
echo "Output: $OUTPUT_FILE"
echo ""

# Create output directory if it doesn't exist
mkdir -p output

# Copy config to templates directory temporarily
TEMP_CONFIG="templates/temp-config.json"
cp "$CONFIG_FILE" "$TEMP_CONFIG"

# Create temporary main.typ with correct config path
TEMP_MAIN="templates/main_temp.typ"
cat templates/main.typ | sed 's|"../examples/full-calendar.json"|"temp-config.json"|g' > "$TEMP_MAIN"

echo -e "${YELLOW}Generating PDF...${NC}"

# Compile with Typst from templates directory
if (cd templates && typst compile main_temp.typ "../$OUTPUT_FILE" 2>&1); then
    # Clean up temp files
    rm "$TEMP_MAIN"
    rm "$TEMP_CONFIG"
    
    echo ""
    echo -e "${GREEN}✓ Success!${NC}"
    echo "PDF generated: $OUTPUT_FILE"
    echo ""
    echo "Next steps:"
    echo "  1. Open the PDF to verify"
    echo "  2. Import to GoodNotes/Notability/Remarkable"
    echo "  3. Test hyperlink navigation"
    echo ""
else
    # Clean up temp files on error
    rm -f "$TEMP_MAIN"
    rm -f "$TEMP_CONFIG"
    
    echo ""
    echo -e "${RED}✗ Build failed${NC}"
    echo "Please check the error messages above."
    exit 1
fi
