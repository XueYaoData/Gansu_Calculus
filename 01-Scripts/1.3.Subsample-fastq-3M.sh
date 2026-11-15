#!/bin/bash

# This script performs random subsampling of FASTQ files using seqtk.

# Set input directory
input_folder=Path/fastq

# Set output directory
output_folder=Path/fastq_subsample-3M

# Change to the input directory
cd ${input_folder}

# Iterate through all FASTQ files in the input directory
for file in *.fastq; do
    # Extract the filename (without extension)
    base=$(basename "$file" .fastq)

    # Define input file path
    input_file=${input_folder}/${file}

    # Define output file path
    output_file=${output_folder}/${base}_subsampled.fastq

    # Perform random subsampling (3 million reads per file)
    seqtk sample -s 11 ${input_file} 3000000 > ${output_file}
done
