#!/bin/bash

# Set input directory
input_folder=Path/fastq

# Set output directory
output_folder=Path/fastq-cut5

# Set directory for fastp HTML and JSON reports
fastp_cut5_html=Path/fastp-cut5-html

# Iterate through all FASTQ files in the input directory
for file in ${input_folder}/*.fastq; do
    # Extract the filename (without extension)
    base=$(basename "$file" .fastq)

    # Define output file path
    output_file=${output_folder}/${base}

    # Run fastp for quality trimming
    fastp -i ${file} --trim_front1 5 --trim_tail1 5 -o "${output_file}-cut5.fastq" --json ${fastp_cut5_html}/${base} --html ${fastp_cut5_html}/${base}
done