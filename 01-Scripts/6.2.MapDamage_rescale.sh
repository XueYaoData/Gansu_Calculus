#!/bin/bash

# Set input BAM directory and reference sequence
bam_input="Path/"
ref="Path/reference.fasta"

# Process all BAM files
for bam in "$bam_input"*.bam; do
    bam_name=$(basename "$bam" .bam)
    mapDamage --rescale -i "$bam" -r "$ref" -d "$bam_name"
done