#!/bin/bash

# Set software and input paths
MultiVCFAnalyzer=Path/MultiVCFAnalyzer_0-85-1.jar
vcf_list=Path/VCF_pathway_list.txt
ref=Path/reference.fasta
output_path=Path/
exclude=Path/reference_exclude.gff
java=Path/java

# Run MultiVCFAnalyzer
# Remove the first line of the VCF pathway list before analysis
$java -Xmx1024G -jar $MultiVCFAnalyzer \
    NA \
    $ref \
    NA \
    $output_path \
    F \
    30 \
    3 \
    0.9 \
    0.9 \
    $exclude \
    $(cat $vcf_list)