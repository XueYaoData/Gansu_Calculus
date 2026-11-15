#!/bin/bash

# Set input and output paths
input_path="Path/"
output_path="Path/"

# Process each BAM file
for bam_file in ${input_path}*.bam; do
    # Extract filename without extension
    bam_name=$(basename "$bam_file" .bam)

    # Set output file path
    output_bam="${output_path}${bam_name}_trim.bam"

    # Run trimBam
    bam trimBam "${bam_file}" "${output_bam}" 2
done
