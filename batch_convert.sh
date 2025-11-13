#!/bin/bash

# Batch convert multiple TEI files to branded HTML
# Usage: ./batch_convert.sh <input_directory> <output_directory> [site_title] [brand_name]

INPUT_DIR="$1"
OUTPUT_DIR="$2"
SITE_TITLE="${3:-TEI Document Viewer}"
BRAND_NAME="${4:-UCPEC}"

if [ -z "$INPUT_DIR" ] || [ -z "$OUTPUT_DIR" ]; then
    echo "Usage: $0 <input_directory> <output_directory> [site_title] [brand_name]"
    echo "Example: $0 data/ output/ 'My Library' 'UC Berkeley'"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Copy CSS file to output directory (for uploading)
if [ -f "templates/styles.css" ]; then
    cp templates/styles.css "$OUTPUT_DIR/styles.css"
fi

count=0
total=$(find "$INPUT_DIR" -name "*.xml" | wc -l)

echo "Converting $total TEI files from $INPUT_DIR to $OUTPUT_DIR"
echo "Site Title: $SITE_TITLE"
echo "Brand Name: $BRAND_NAME\n" 

# Process each XML file
find "$INPUT_DIR" -name "*.xml" | while read -r tei_file; do
    count=$((count + 1))
    
    # Get filename without path and extension
    filename=$(basename "$tei_file" .xml)
    
    output_file="$OUTPUT_DIR/${filename}.html"
    
    echo "Converting: $(basename "$tei_file") -> $(basename "$output_file")"
    
    # Convert using templating script
    ./create_branded_html.sh "$tei_file" "$SITE_TITLE" "$BRAND_NAME" > "$output_file"
    
    if [ $? -eq 0 ]; then
        echo "Success: $output_file"
    else
        echo "Failed: $tei_file"
    fi
done

echo "\nDONE! Output files saved to: $OUTPUT_DIR"
