
library(ggplot2)
library(ggpubr)

rm(list=ls()) # Clear global environment

# Read data
df <- read.csv("Path/Species.csv",
               header = TRUE,
               sep = ",",
               stringsAsFactors = FALSE,
               na.strings = c("", "NA", "NULL"),
               encoding = "UTF-8")

# Set the group order for plotting
df$Group <- factor(df$Group, levels = c("Oceania",
                                        "Europe",
                                        "North_America",
                                        "Asia",
                                        "Gansu",
                                        "Africa"))

# Create a boxplot with jittered points (without statistical testing)
ggplot(df, aes(Group, Value)) +
  geom_boxplot(aes(fill = Group), width = 0.7, outlier.shape = NA) +
  geom_jitter(aes(color = Group), width = 0.2, alpha = 0.6, size = 1) +
  scale_fill_brewer(palette = "Set2") +
  scale_color_brewer(palette = "Set2") +
  theme_classic()