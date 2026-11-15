#!/bin/bash

# Set input and output paths
genefamilies_path=Path/
out_path=Path/

# Process all TSV files
for tsv in ${genefamilies_path}/*.tsv
do
    # Extract the filename without the path and extension
    fname=$(basename "$tsv" .tsv)

    # Set the output directory
    outdir=${out_path}/${fname}

    # Regroup gene families into KEGG orthologs
    humann_regroup_table \
        --input "$tsv" \
        --groups uniref90_ko \
        --output "${out_path}/${fname}_ko.tsv"
done