#!/bin/bash

# Set input and output paths
fastq_path=Path/
out_path=Path/

# Process all FASTQ files
for fq in ${fastq_path}/*.fastq
do
    # Extract the filename without the path and extension
    fname=$(basename "$fq" .fastq)

    # Set the output directory
    outdir=${out_path}/${fname}

    # Run HUMAnN
    humann \
        --input "$fq" \
        --output "$outdir" \
        --threads 10 \
        --metaphlan-options="--bowtie2db Path/ --index mpa_vJun23_CHOCOPhlAnSGB_202307"
done