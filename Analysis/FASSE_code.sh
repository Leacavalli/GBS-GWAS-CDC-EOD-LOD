cd /n/hanage_gbs_gwas_l3/Lab

# Summarise the age categories
cut -d',' -f$(head -1 HARVARD_GBS_2015_2023_metadata.csv | tr ',' '\n' | grep -xn ONSET | cut -d: -f1) \
  HARVARD_GBS_2015_2023_metadata.csv | tail -n +2 | sort | uniq -c | sort -nr

# Subset metadata to only EOD/LOD
awk -F, 'NR==1 || $2=="0" || $2=="1"' phenotypes_CDC_EOD_LOD_VLOD.txt > phenotypes_CDC_EOD_LOD.txt

# Subset only 50 samples
head -51 phenotypes_CDC_EOD_LOD.txt > phenotypes_CDC_EOD_LOD_subset50.txt
