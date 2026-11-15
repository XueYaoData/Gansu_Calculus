# Load required libraries
library(dplyr)
library(tidyr)

# Read CSV data
df <- read.csv("Path/Species.csv",
               header = TRUE,
               stringsAsFactors = FALSE)

# Get all group names
groups <- unique(df$Group)

# Initialize the results data frame
results <- data.frame(Group1 = character(),
                      Group2 = character(),
                      W_statistic = numeric(),
                      p_value = numeric(),
                      stringsAsFactors = FALSE)

# Perform pairwise Wilcoxon rank-sum tests
for (i in 1:(length(groups)-1)) {
  for (j in (i+1):length(groups)) {
    g1 <- groups[i]
    g2 <- groups[j]

    x <- df$Value[df$Group == g1]
    y <- df$Value[df$Group == g2]

    test <- wilcox.test(x, y, exact = FALSE)  # Set exact = FALSE to avoid warnings caused by ties

    results <- rbind(results, data.frame(
      Group1 = g1,
      Group2 = g2,
      W_statistic = test$statistic,
      p_value = test$p.value
    ))
  }
}

# View results
print(results)

# Adjust p-values for multiple testing using the BH method
results$FDR <- p.adjust(
  results$p_value,
  method = "BH"
)

# Determine statistical significance
results$Significant <- results$FDR < 0.05

# View results
print(results)

# Save results
write.csv(
  results,
  "Path/Species_wilcox_results_FDR.csv",
  row.names = FALSE
)