cd /n/hanage_gbs_gwas_l3/Lab

# Summarise the age categories
cut -d',' -f$(head -1 HARVARD_GBS_2015_2023_metadata.csv | tr ',' '\n' | grep -xn ONSET | cut -d: -f1) \
  HARVARD_GBS_2015_2023_metadata.csv | tail -n +2 | sort | uniq -c | sort -nr

# Subset metadata to only EOD/LOD
awk -F, 'NR==1 || $2=="0" || $2=="1"' phenotypes_CDC_EOD_LOD_VLOD.txt > phenotypes_CDC_EOD_LOD.txt


# 0. Run Nextflow pipeline test only 50 samples subset
## Subset 50 EOD and LOD samples
head -51 phenotypes_CDC_EOD_LOD.txt > phenotypes_CDC_EOD_LOD_subset50.txt
cp phenotypes_CDC_EOD_LOD_subset50.txt /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_TEST50/Files/phenotypes.txt
cp phenotypes_CDC_EOD_LOD_subset50.txt /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_TEST50/Files/phenotypes_filtered.txt
## Move those samples to the test pipeline directory
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_TEST50/
mkdir 0.RAW_READS
awk -F',' 'NR>1{print $1}' Files/phenotypes.txt > samples.txt
while read sample; do
  cp ../Nextflow_pipeline/0.RAW_READS_CDC/"$sample"*.fastq.gz 0.RAW_READS/
done < samples.txt
## Run pipeline
cd scripts
module load python
source activate java
java -version
sbatch -p fasse -c 48 -t 0-12:00 --mem=100000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf --main --sub1 --sub2 --path_nextflow_dir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_TEST50 --path_conda_envs /n/home_fasse/lcavalli/.conda/envs"

sbatch -p fasse -c 48 -t 0-12:00 --mem=100000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf -resume --main --sub1 --sub2 --path_nextflow_dir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_TEST50 --path_conda_envs /n/home_fasse/lcavalli/.conda/envs"

# 1. Run Nextflow pipeline for EOD vs LOD - CDC samples only
## Make a Nextflow Pipeline directory
cd /n/hanage_gbs_gwas_l3/Lab
## Make phenotypes files
cp phenotypes_CDC_EOD_LOD.txt /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/Files/phenotypes.txt
cp phenotypes_CDC_EOD_LOD.txt /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/Files/phenotypes_filtered.txt
## Move those samples to the test pipeline directory
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/
mkdir 0.RAW_READS
awk -F',' 'NR>1{print $1}' Files/phenotypes.txt > samples.txt
while read sample; do
  cp /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline/0.RAW_READS_CDC/"$sample"*.fastq.gz 0.RAW_READS/
done < samples.txt
## Run pipeline



# 2. Run Nextflow pipeline for EOD vs (LOD, VLOD) - CDC samples only
## Make a Nextflow Pipeline directory
cd /n/hanage_gbs_gwas_l3/Lab
## Make phenotypes files
awk -F, 'BEGIN{OFS=","} NR==1{print; next} $2 == 2 { $2 = 1 } { print }' phenotypes_CDC_EOD_LOD_VLOD.txt > /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes.txt
awk -F, 'BEGIN{OFS=","} NR==1{print; next} $2 == 2 { $2 = 1 } { print }' phenotypes_CDC_EOD_LOD_VLOD.txt > /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes_filtered.txt
## Move those samples to the test pipeline directory
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/
mkdir 0.RAW_READS
awk -F',' 'NR>1{print $1}' Files/phenotypes.txt > samples.txt
while read sample; do
  cp /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline/0.RAW_READS_CDC/"$sample"*.fastq.gz 0.RAW_READS/
done < samples.txt
## Run pipeline



# 3. Run Nextflow pipeline for EOD vs (LOD, VLOD) - CDC and NL samples
## Make a Nextflow Pipeline directory
cd /n/hanage_gbs_gwas_l3/Lab
## Make phenotypes files
ls /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes.txt

## Move those samples to the test pipeline directory
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/
mkdir 0.RAW_READS
awk -F',' 'NR>1{print $1}' Files/phenotypes.txt > samples.txt
while read sample; do
  cp /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline/0.RAW_READS_CDC/"$sample"*.fastq.gz 0.RAW_READS/
done < samples.txt
## Run pipeline
