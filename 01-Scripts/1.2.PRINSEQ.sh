#!/bin/bash

# This script removes duplicate sequences from truncated FASTQ files using PRINSEQ.

# Set input directory
input_folder=Path

# Iterate through all truncated files in the input directory
for file in ${input_folder}/*.truncated; do
    # Run PRINSEQ to remove duplicate sequences
    perl Path/prinseq-lite.pl -fastq ${file} -derep 14
done
