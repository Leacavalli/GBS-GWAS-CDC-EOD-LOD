# Clean environment
rm( list = ls() )

# load necessary libraries
library(xlsx)
library(tidyverse)

# load data
setwd("~/GitHub/GBS-GWAS-CDC-EOD-LOD/0.Raw_data")
NL_metadata <- read.xlsx("Netherlands_Sanger_metadata.xlsx", sheetName ="Isolate characteristics")

# Subset EOD/LOD isolates
head(NL_metadata)
table(NL_metadata$Disease.onset.classification)
phenotypes <- NL_metadata |> 
  select(ENA.lane.accession, Disease.onset.classification)|>
  rename("samples"="ENA.lane.accession")|>
  mutate(binary= ifelse(Disease.onset.classification =="EOD", 1, 0))|>
  select(samples, binary)

# Write phenotypes file 
write.table(phenotypes, "phenotypes_NL_EOD_LOD.txt", 
            row.names = F, 
            col.names = T, 
            quote = F, 
            sep = '\t')


