
#!/bin/bash

# Set reference sequence path
ref_path="Path/reference.fasta"

# Set FASTQ file path
fastq_path="Path/"

# Set output path
output_path="Path/"

# Get sample names
samples=("${fastq_path}"*.fastq)

# Write summary header
echo -e "Sample \t Mapped reads \t Q37 mapped reads \t Unique Q37 mapped reads \t Average length of mapped reads \t Mean coverage \t Std dev of mean coverage \t % reference covered >= 1X \t % reference covered >= 3X \t % reference covered >= 5X \t GC percentage" >> bam_summary_Anaerolineaceae_MRZ-bro_NOUDG.txt

# Process each sample
for sample in "${samples[@]}"; do
    # Extract sample name
    sample_name=$(basename "${sample}" .fastq)

    # 1. Index the reference sequence
    bwa index "${ref_path}"

    # 2. BWA alignment
    bwa aln \
        -t 10 \
        "${ref_path}" \
        "${sample}" \
        -n 0.1 \
        -l 1024 \
        -f "${output_path}${sample_name}.sai"

    # 3. Convert to SAM format
    bwa samse -f "${output_path}${sample_name}.sam" \
        "${ref_path}" \
        "${output_path}${sample_name}.sai" \
        "${sample}"

    # 4. Filter unmapped and low-quality reads
    samtools view -@ 10 -bS \
        "${output_path}${sample_name}.sam" > \
        "${output_path}${sample_name}.1.bam"

    samtools view -@ 10 -b \
        -F4 \
        "${output_path}${sample_name}.1.bam" > \
        "${output_path}${sample_name}.2.bam"

    samtools view -@ 10 -b \
        -q 37 \
        "${output_path}${sample_name}.2.bam" > \
        "${output_path}${sample_name}.3.bam"

    # 5. Sort alignments
    samtools sort -@ 10 \
        -o "${output_path}${sample_name}_sorted.bam" \
        "${output_path}${sample_name}.3.bam"

    samtools index -@ 10 \
        "${output_path}${sample_name}_sorted.bam"

    # 6. Add read group information
    picard AddOrReplaceReadGroups \
        I="${output_path}${sample_name}_sorted.bam" \
        O="${output_path}${sample_name}_sorted_rg.bam" \
        RGID=merged_sample \
        RGLB=merged_library \
        RGPL=illumina \
        RGPU=merged_run \
        RGSM=$(echo "$sample_name" | cut -d'_' -f1)

    # 7. Remove PCR duplicates
    picard MarkDuplicates -Xmx64g I="${output_path}${sample_name}_sorted_rg.bam" \
        O="${output_path}${sample_name}_sorted_rg_rmdup.bam" \
        M="${output_path}${sample_name}_sorted_rg_rmdup.txt" \
        REMOVE_DUPLICATES=true

    # 8. Index alignments and generate statistics
    samtools index "${output_path}${sample_name}_sorted_rg_rmdup.bam"

    # 9. Calculate alignment statistics
    Sample=${sample_name}
    Mapped_reads=$(samtools view -c "${output_path}${sample_name}.2.bam")
    Q37_reads=$(samtools view -c "${output_path}${sample_name}.3.bam")
    Unique_reads=$(samtools view -c "${output_path}${sample_name}_sorted_rg_rmdup.bam")
    Average_length=$(samtools view "${output_path}${sample_name}_sorted_rg_rmdup.bam" | awk '{SUM+=length($10);DIV++}END{print SUM/DIV}')
    Cluster_factor=`echo "scale=4;$Mapped_reads/$Unique_reads" | bc`

    # 10. Remove temporary files
    rm -r \
        "${output_path}${sample_name}.sai" \
        "${output_path}${sample_name}.sam" \
        "${output_path}${sample_name}.1.bam" \
        "${output_path}${sample_name}.2.bam" \
        "${output_path}${sample_name}.3.bam" \
        "${output_path}${sample_name}_sorted.bam" \
        "${output_path}${sample_name}_sorted.bam.bai" \
        "${output_path}${sample_name}_sorted_rg.bam" \
        "${output_path}${sample_name}_sorted_rg_rmdup.txt" \

    # 11. Run Qualimap for statistics
    qualimap bamqc \
        -bam "${output_path}${sample_name}_sorted_rg_rmdup.bam" \
        -outdir "${output_path}${sample_name}/" \
        -outformat pdf

    Mean_cov=`grep "mean coverageData" "${output_path}${sample_name}/genome_results.txt" | cut -d "=" -f2`
    sd_cov=`grep "std coverageData" "${output_path}${sample_name}/genome_results.txt" | cut -d "=" -f2`
    cov1=`grep "reference with a coverageData >= 1X" "${output_path}${sample_name}/genome_results.txt" | awk '{print $4}'`
    cov3=`grep "reference with a coverageData >= 3X" "${output_path}${sample_name}/genome_results.txt" | awk '{print $4}'`
    cov5=`grep "reference with a coverageData >= 5X" "${output_path}${sample_name}/genome_results.txt" | awk '{print $4}'`
    GC=`grep "GC percentage" "${output_path}${sample_name}/genome_results.txt" | cut -d "=" -f2`

    # 12. Remove temporary files
    rm -rf \
        "${output_path}${sample_name}/"


    echo -e "$Sample \t $Mapped_reads \t $Q37_reads \t $Unique_reads \t $Average_length \t $Mean_cov \t $sd_cov \t $cov1 \t $cov3 \t $cov5 \t $GC" >> bam_summary_Anaerolineaceae_MRZ-bro_NOUDG.txt

done