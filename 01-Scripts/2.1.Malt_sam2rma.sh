
#!/bin/bash

unset DISPLAY

# Set input and output paths

# MALT parameters
MODE=BlastN
THREADS=40

# SAM2RMA parameters
LCACoveragePercent=80
LCAAlgorithm=weighted

# Run MALT
cd ${MALT_PATH}

./malt-run \
--inFile ${INPUT_FASTQ}* \
--mode ${MODE} \
--index ${INDEX} \
--alignments ${OUTPUT_SAM} \
--format SAM \
--gzipAlignments false \
--memoryMode load \
--minBitScore 40.0 \
--numThreads ${THREADS} \
--verbose

wait

# Convert SAM files to RMA format
cd ${SAM2RMA_PATH}

./sam2rma \
-r ${INPUT_FASTQ}* \
-i ${Input_SAM}* \
-o ${Output_RMA_PATH} \
--mapDB ${MapDB_DNA} \
-lcp ${LCACoveragePercent} \
-alg ${LCAAlgorithm} \
--threads 32 \
--verbose