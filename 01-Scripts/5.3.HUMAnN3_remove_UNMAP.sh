#!/bin/bash

# This script clean the Gene family (UniRef90) tables by removing unmapped and species-level annotations

# Set input and output directories
input_dir="Path/"
output_dir="Path/"

# Create the output directory if it does not exist
mkdir -p "$output_dir"

# Process each TSV file
for file in "$input_dir"/*.tsv; do
    # Extract the filename
    filename=$(basename "$file")

    # Set the output file path with the _clean suffix
    output_file="$output_dir/${filename%.tsv}_clean.tsv"

    # Remove lines containing UNMAPPED or |
    grep -v -E "UNMAPPED" "$file" > "$output_file"
done