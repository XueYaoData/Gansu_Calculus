library(variancePartition)
library(corrplot)

# Read data containing PC1-PC3 coordinates and metadata
info <- read.table("Path/CC.txt", header=TRUE, row.names=1)

# Specify variables for analysis
form <- ~ PC1 + PC2 + PC3 + Porphyromonas_gingivalis + Prevotella_conceptionensis + Prevotella_intermedia + Prevotella_maculosa + Prevotella_saccharolytica + Prevotella_sp__HMSC073D09 + Prevotella_sp__oral_taxon_317 + Fusobacterium_nucleatum + Fusobacterium_sp__oral_taxon_203 + Leptotrichia_buccalis + Leptotrichia_trevisanii + Desulfomicrobium_orale + Campylobacter_gracilis + Campylobacter_rectus + Treponema_denticola + Treponema_lecithinolyticum + Treponema_maltophilum + Treponema_parvum + Treponema_socranskii + Treponema_sp__Marseille_Q4132 + Actinomyces_naeslundii + Actinomyces_sp__oral_taxon_849 + Filifactor_alocis + Selenomonas_noxia + Selenomonas_sp__oral_taxon_920

# Perform canonical correlation analysis
cor_matrix <- canCorPairs(form, info)

# Perform statistical tests on the correlation matrix
testRes = cor.mtest(cor_matrix, conf.level = 0.95)

# Generate the correlation plot
plot <- corrplot(
  cor_matrix, # Correlation coefficient matrix
  p.mat = testRes$p, # Display P-values
  sig.level = 0.01, # Significance threshold
  insig = 'label_sig', # Mark significant correlations with asterisks
  method = 'circle', # Display correlations as circles
  col.lim = c(0, 1), # Set the display range
  col = COL2('RdBu', 100), # Set the color palette
  type = 'lower' # Display only the lower triangle
  )

plot