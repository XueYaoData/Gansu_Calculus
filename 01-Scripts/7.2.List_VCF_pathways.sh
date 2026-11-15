#!/bin/bash

# Set input and output paths
path=Path/
outputdir=Path/

# The input directory should contain only VCF folders
# Create the VCF pathway list; remove the first line ("List of VCF pathways") before downstream analysis
echo "List of VCF pathways" > $outputdir/VCF_pathway_list_prinseq14.txt

for a in $path/*; do

    ID=$(basename $a)
    for vcf in $a/*.vcf; do
        Name=$(basename $vcf)
        PWD="${path}"/"${ID}"/"${Name}"
        echo $PWD >> $outputdir/VCF_pathway_list_prinseq14.txt
    done
done
