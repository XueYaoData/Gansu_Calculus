## This script filters KO abundance values based on a relative abundance threshold.

# Load required packages
library(data.table)

# Set input and output file paths
input_file <- "Path/KO_abundance.txt"
output_file <- "Path/KO_abundance_Filter.tsv"

# Read data
# The first column contains KO IDs, and the first row contains sample names
data <- fread(input_file, header = TRUE, sep = "\t", data.table = FALSE)

# Extract the KO ID column
ko_col <- data[,1]

# Extract the numeric matrix by removing the KO ID column
mat <- data[,-1]

# Calculate relative abundance for each sample
rel_abundance <- sweep(mat, 2, colSums(mat), FUN = "/")

# Create a logical matrix indicating values below the threshold
threshold <- 0.00005
mask <- rel_abundance < threshold

# Set corresponding values in the original CPM matrix to zero
mat_filtered <- mat
mat_filtered[mask] <- 0

# Remove rows containing only zeros
keep_rows <- rowSums(mat_filtered != 0) > 0
mat_filtered <- mat_filtered[keep_rows,]
ko_filtered <- ko_col[keep_rows]

# Combine KO IDs with the filtered abundance matrix
final_data <- cbind(KO = ko_filtered, mat_filtered)

# Write the filtered data to a TSV file
write.table(final_data,
            file = output_file,
            sep = "\t",
            row.names = FALSE,
            quote = FALSE)