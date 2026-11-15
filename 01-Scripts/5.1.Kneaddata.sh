#!/bin/bash

# Set input and output paths
fastq_path="Path/"
out_path="Path/"

# Set the KneadData database path
db_path="Path/"

# Set the number of threads
threads=20

# Process all .fastq files in the input directory
for fastq_file in "$fastq_path"/*.fastq; do
    # Extract the sample name without the path and file extension
    sample_name=$(basename "$fastq_file" .fastq)

    # Create the output directory
    output_dir="$out_path/$sample_name"
    mkdir -p "$output_dir"

    # Run KneadData
    kneaddata \
        -un "$fastq_file" \
        -db "$db_path" \
        --bowtie2-options "--very-sensitive -p $threads" \
        --bypass-trim \
        --bypass-trf \
        -o "$output_dir"
done