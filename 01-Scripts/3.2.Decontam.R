library(decontam)

# Load the OTU table
otu_table <- read.table("Path/decontam_OTU.txt",
                        header = TRUE,
                        row.names = 1,
                        sep = "\t")

# Extract the numeric matrix
otu_matrix <- as.matrix(otu_table)

# Define sample information
sample_names <- rownames(otu_table)
stone_samples <- sample_names[1:16]  # First 16 samples are dental calculus metagenomic samples
control_samples <- sample_names[17:length(sample_names)]  # Remaining samples are negative controls

# Identify negative control samples
neg_control_status <- ifelse(sample_names %in% control_samples, TRUE, FALSE)

# Identify potential contaminants using the prevalence method
result <- isContaminant(
  seqtab = otu_matrix,
  neg = neg_control_status,
  method = "prevalence",
  threshold = 0.8  # Adjust the threshold according to the actual data
)

# Save the results
write.table(result,
            file = "Path/decontam_result_0.8.txt",
            sep = "\t",
            quote = FALSE)

# Print the results
print(result)