# Clean environment
rm( list = ls() )

# load necessary libraries
library(xlsx)
library(tidyverse)

# load data
setwd("~/GitHub/GBS-GWAS-CDC-EOD-LOD/Analysis")
NL_metadata <- read.xlsx("Netherlands_Sanger_metadata.xlsx", sheetName ="Isolate characteristics")

# Subset EOD/LOD isolates
head(NL_metadata)
table(NL_metadata$Disease.onset.classification)
phenotypes <- NL_metadata |> 
  select(ENA.lane.accession, Disease.onset.classification)|>
  rename("samples"="ENA.lane.accession")|>
  mutate(disease= ifelse(Disease.onset.classification =="EOD", 1, 0))|>
  select(samples, disease)

# Write phenotypes file 
write.table(phenotypes, "NL_phenotypes.txt", 
            row.names = F, 
            col.names = T, 
            quote = F, 
            sep = '\t')


