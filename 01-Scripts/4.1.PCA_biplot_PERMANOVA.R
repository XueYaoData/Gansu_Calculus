## Script to:
## (1) Create PCA plots based on malt relative abundance data
## (2) Color PCA plots based on geographical group or sample type
## (3) Perform PERMANOVA and PERMDISP testing
## (4) Create a PCA biplot
## Script originally developed by R. Fleskes (2024), based on scripts provided by Velsko et al. (2022)
## Modified in the present study
## https://github.com/ivelsko/smoking_calculus

## Load libraries
library(vegan)
library(phyloseq)
library(mixOmics)
library(RColorBrewer)
library(tidyverse)
library(ggrepel)
library(pander)

rm(list=ls()) # Clear global environment

## Set file paths
otu_table_path <- "Path/OTU.txt"
metadata_path <- "Path/metadata.txt"
all_permanova_results_path <- "Path/all_permanova_testing.csv"
BiPlot_result_path <- "Path/BiPlot.pdf"
positive_loadings_path <- "Path/pc1_positive_loadings.txt"
negative_loading_path <- "Path/pc1_negative_loadings.txt"

## Read species-level table and sample metadata
OTUIN<-otu_table(read.table(otu_table_path,header=TRUE,row.names=1, sep = "\t"),taxa_are_rows = TRUE)
SAMPDATA<-sample_data(read.table(metadata_path,header=TRUE,row.names=1,sep="\t"))


## Create PCA plot
psobject<-phyloseq(OTUIN,SAMPDATA)
PRobject<-t(otu_table(psobject))+1
pca.result<-pca(PRobject,logratio='CLR')
percentVar <- pca.result$prop_expl_var
coords_pca<-as.data.frame(pca.result$variates)
loadings_pca<-as.data.frame(pca.result$loadings)
FinalTable<-merge(coords_pca,as.data.frame(SAMPDATA),by="row.names")

## Format pathology variables
FinalTable$date_region <- factor(FinalTable$date_region)

## Create base PCA plot
plot1<-ggplot(data=FinalTable,aes(X.PC1,X.PC2))+geom_point(alpha=0.0001)+theme_bw()+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

plot1<-plot1+
  geom_point(data=FinalTable, shape=17, colour="black", size=2) +
  theme_bw()+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  labs(x = paste("PC1: ", round(percentVar$X[1]*100, 2), "% expl. var", sep=""), 
       y = paste("PC2: ", round(percentVar$X[2]*100, 2), "% expl. var", sep=""))
plot1

## Create PCA plots colored by variable
date_region_code_colors <- colorRampPalette(brewer.pal(12, "Paired"))(40)
DateRegionVariablePlot <- plot1 +
  geom_point(
    data = FinalTable,
    aes(color = factor(date_region)), shape = 17, size = 2) +
  scale_color_manual(values = date_region_code_colors, name="")+
  theme(legend.position = "bottom",
        legend.text = element_text(size = 6),
        legend.title = element_text(size = 6),
        plot.title = element_text(hjust = 0.5, size = 12, face = "bold"),
        plot.title.position = "plot",
        text = element_text(size = 12))
DateRegionVariablePlot



## Create Euclidean distance matrix using vegan
diss_matrix <- vegdist(pca.result$X, method = "euclidean", na.rm = F)

## Create variables based on metadata
date_region <- FinalTable$date_region

## Run PERMANOVA using adonis2
perm_result_date_region <- adonis2(diss_matrix ~ date_region, FinalTable, permutations = 999, by = "margin")

## Filter and export PERMANOVA results
all_permanova_results <- bind_rows(perm_result_date_region) %>% rownames_to_column("ID")

all_permanova_results_filtered <- all_permanova_results %>%
  as_tibble() %>%
  drop_na(`F`) %>%
  arrange(desc(`F`)) %>%
  arrange(desc(R2))

write.csv(all_permanova_results_filtered, file = all_permanova_results_path, quote =  F)

## Test homogeneity of multivariate dispersion
dispersion_date_region <- betadisper(diss_matrix, date_region)

## Perform permutation test for multivariate dispersion
dispersion_test_date_region <- permutest(
  dispersion_date_region,
  permutations = 999
)

dispersion_test_date_region

capture.output(
  dispersion_test_date_region,
  file = "Path/dispersion_test_date_region.txt"
)



## Extract explained variance
pca_expl_vars <- paste0(round(pca.result$variance * 100, 2), "%")

## Extract loadings (eigenvectors) from PCA
pca_loadings_df <- as.data.frame(pca.result$loadings$X) %>%
  rownames_to_column(var = "Species")

## Identify the 10 species with the highest positive and negative loadings in PC1 and PC2
pc1_pws <- pca_loadings_df %>%
  top_n(10, PC1) %>%
  arrange(desc(PC1)) %>%
  mutate(Species_Order = 1:10)

pc1_neg <- pca_loadings_df %>%
  top_n(-10, PC1) %>%
  arrange(PC1) %>%
  mutate(Species_Order = -1:-10)

pc2_pws <- pca_loadings_df %>%
  top_n(10, PC2)%>%
  arrange(desc(PC2)) %>%
  mutate(Species_Order = 1:10)

pc2_neg <- pca_loadings_df %>%
  top_n(-10, PC2) %>%
  arrange(PC2) %>%
  mutate(Species_Order = -1:-10)

## Calculate correction factor from ggfortify::autoplot
corr_lam <- pca.result$sdev[c("PC1", "PC2")] * sqrt(nrow(FinalTable))

## Create biplot
plot_bi <- FinalTable %>%
  mutate(PC1 = X.PC1 / corr_lam[1],
         pc2_residuals = X.PC2 / corr_lam[2]) %>%
  ggplot(.,
         aes(x = PC1, y = pc2_residuals)) +
  geom_point(size = 2, aes(shape = factor(FinalTable$shape), color = factor(FinalTable$color))) +

  scale_shape_manual(values = c(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10))+

  geom_segment(data = pc1_pws,
               aes(xend = PC1, yend = PC2),
               x = 0, y = 0, colour = "black", size = 0.5,
               arrow = arrow(length = unit(0.03, "npc"))) +
  geom_label_repel(data = pc1_pws,
                   aes(x = PC1, y = PC2, label = Species_Order),
                   size = 2.5, colour = "black", label.padding = 0.2, max.overlaps=50) +
  geom_segment(data = pc1_neg,
               aes(xend = PC1, yend = PC2),
               x = 0, y = 0, colour = "grey50", size = 0.5,
               arrow = arrow(length = unit(0.03, "npc"))) +
  geom_label_repel(data = pc1_neg,
                   aes(x = PC1, y = PC2, label = Species_Order),
                   size = 2.5, colour = "black", label.padding = 0.2, max.overlaps=50) +
  labs(x = paste("PC1: ", round(percentVar$X[1]*100, 2), "% expl. var", sep=""), 
       y = paste("PC2: ", round(percentVar$X[2]*100, 2), "% expl. var", sep="")) +
  theme_light() +
  theme(text = element_text(size = 14), legend.position = "right")
plot_bi
ggsave(BiPlot_result_path, plot = plot_bi, width = 12, height =4.5, dpi = 400)

## Create species loading tables
sink(positive_loadings_path)
pandoc.table(pc1_pws %>% arrange(desc(PC1)),
             digits = 5,
             keep.trailing.zeros = T,
             split.tables = Inf,
             caption = "PC1 positive loadings")
sink()

sink(negative_loading_path)
pandoc.table(pc1_neg %>% arrange(PC1),
             digits = 5,
             keep.trailing.zeros = T,
             split.tables = Inf,
             caption = "PC1 negative loadings")
sink()

## Export sample PCA coordinates (PC1, PC2, and PC3)
pca_coordinates <- as.data.frame(pca.result$variates[, 1:3])

write.csv(
  pca_coordinates,
  file = "Path/PCA_coordinates_PC123.csv",
  row.names = TRUE
)