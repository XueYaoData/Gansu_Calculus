#!/bin/bash

# Set your input and output paths
INPUT_DB=Path/
OUTPUT_INDX=Path/

# Set mapping database
MAPPING=Path/

# Build MALT index
Path/malt-build \
--input $INPUT_DB \
--sequenceType DNA \
--index $OUTPUT_INDX \
--threads $THREADS \
--mapDB $MAPPING

