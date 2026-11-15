#!/bin/bash

# This script performs adapter trimming, quality filtering, and read collapsing of paired-end FASTQ files using AdapterRemoval.

# Set input directory
input_folder=Path/01_fastq/pair

# Set output directory
output_folder=Path/02_process-fastq/01_pair

# Iterate through all files in the input directory
for file1 in ${input_folder}/*_1.fastq; do
    # Extract the sample name (without extension)
    base=$(basename "$file1" _1.fastq)
    #filename_no_ext="${filename%.*}"
    file2=${input_folder}/${base}_2.fastq

    # Define the output file path
    output_file=${output_folder}/${base}

    # Run AdapterRemoval
    AdapterRemoval --file1 ${file1} --file2 ${file2} --trimns --trimqualities --minlength 30 --minquality 30 --collapse --basename ${output_file} --threads 100
done
