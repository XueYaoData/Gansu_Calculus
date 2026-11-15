
#!/bin/bash

# Set software and input paths
gatk=Path/GenomeAnalysisTK.jar
java=Path/java

file=Path/*.bam
ref=Path/reference.fasta
output_path=Path/

# Set working directory
cd ${output_path}

# Process each BAM file
for BAM in $file; do
    samtools index $BAM
    i=$(basename $BAM .bam)
    mkdir $i

    # Call SNPs using GATK UnifiedGenotyper
    $java -jar $gatk -T UnifiedGenotyper \
        -R $ref \
        -I $BAM \
        -o $i/${i}.vcf \
        --output_mode EMIT_ALL_SITES

done