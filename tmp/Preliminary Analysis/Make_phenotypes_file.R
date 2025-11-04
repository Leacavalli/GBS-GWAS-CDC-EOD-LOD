# Clean environment
rm( list = ls() )

# load necessary libraries
library(xlsx)
library(tidyverse)

# load data
setwd("~/GitHub/GBS-GWAS-CDC-EOD-LOD/Preliminary Analysis")
CDC_metadata <- read.xlsx("CDC_metadata.xlsx", sheetName ="Sheet1")
SraAcclist <- read.delim("CDC_SraAccList.txt")

# Subset EOD/LOD isolates
CDC_EOD_LOD <- CDC_metadata |> 
  filter(Age.group %in% c("EOD", "LOD"))|> 
  select(Biosample.Accession, Age.group)|>
  rename("BioSample"="Biosample.Accession")

# join SRA Accession 
phenotypes <- left_join(CDC_EOD_LOD, SraAcclist) |>
  filter(! is.na(BioSample)) |>
  rename("samples"="SRA")|>
  mutate(binary= ifelse(Age.group =="EOD", 1, 0))|>
  mutate(continuous= sample(1:365, size = nrow(phenotypes), replace = TRUE))|>
  select(samples, continuous, binary)


# Write phenotypes file 
write.table(phenotypes, "phenotypes.txt", 
            row.names = F, 
            col.names = T, 
            quote = F, 
            sep = '\t')

# Write SraAccList file 
write.table(phenotypes |> select(SRA), "SraAccList.txt", 
            row.names = F, 
            col.names = F, 
            quote = F, 
            sep = '\t')

