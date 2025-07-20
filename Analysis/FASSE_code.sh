cd /n/hanage_gbs_gwas_l3/Lab

# Summarise the age categories
cut -d',' -f$(head -1 HARVARD_GBS_2015_2023_metadata.csv | tr ',' '\n' | grep -xn ONSET | cut -d: -f1) \
  HARVARD_GBS_2015_2023_metadata.csv | tail -n +2 | sort | uniq -c | sort -nr

# Prepare phenotypes file for CDC data
sed 's/,/\t/g' output_samples_disease.txt | sed '1s/disease/binary/' | sort > output_samples_disease_temp.txt
sed 's/,/\t/g' output_samples_comtinuous.txt  | sed '1s/agedys/continuous/' | sort > output_samples_comtinuous_temp.txt
join -t $'\t' output_samples_disease_temp.txt output_samples_comtinuous_temp.txt > phenotypes_CDC_EOD_LOD_VLOD.txt
rm output_samples_disease_temp.txt output_samples_comtinuous_temp.txt

# Subset CDC metadata to only EOD/LOD
awk -F'\t' 'NR==1 || $2=="0" || $2=="1"' phenotypes_CDC_EOD_LOD_VLOD.txt > phenotypes_CDC_EOD_LOD.txt

# Join NL and

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
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline
mkdir Nextflow_pipeline_EOD_LOD_CDC
cd Nextflow_pipeline_EOD_LOD_CDC
## Make phenotypes files
mkdir Files
cp phenotypes_CDC_EOD_LOD.txt /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/Files/phenotypes.txt
cp phenotypes_CDC_EOD_LOD.txt /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/Files/phenotypes_filtered.txt
## Move those samples to the test pipeline directory
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/
mkdir 0.RAW_READS
awk -F'\t' 'NR>1{print $1}' Files/phenotypes.txt > samples.txt
while read sample; do
  cp /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline/0.RAW_READS_CDC/"$sample"*.fastq.gz 0.RAW_READS/
done < samples.txt
## Run pipeline
cd scripts
module load python
source activate java
java -version
sbatch -p fasse -c 48 -t 7-00:00:00 --mem=180000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf --main --sub1 --sub2 --path_nextflow_dir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC --path_conda_envs /n/home_fasse/lcavalli/.conda/envs"
sbatch -p fasse -c 48 -t 7-00:00:00 --mem=180000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf -resume --main --sub1 --sub2 --path_nextflow_dir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC --path_conda_envs /n/home_fasse/lcavalli/.conda/envs"


# 2. Run Nextflow pipeline for EOD vs (LOD, VLOD) - CDC samples only
## Make a Nextflow Pipeline directory
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline
mkdir Nextflow_pipeline_EOD_LOD_VLOD_CDC
cd Nextflow_pipeline_EOD_LOD_VLOD_CDC
## Make phenotypes files
mkdir Files
awk -F'\t' 'BEGIN{OFS="\t"} NR==1{print; next} $2 == 2 { $2 = 1 } { print }' phenotypes_CDC_EOD_LOD_VLOD.txt > /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes.txt
awk -F'\t' 'BEGIN{OFS="\t"} NR==1{print; next} $2 == 2 { $2 = 1 } { print }' phenotypes_CDC_EOD_LOD_VLOD.txt > /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes_filtered.txt
## Move those samples to the test pipeline directory
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/
mkdir 0.RAW_READS
awk -F'\t' 'NR>1{print $1}' Files/phenotypes.txt > samples.txt
while read sample; do
  cp /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline/0.RAW_READS_CDC/"$sample"*.fastq.gz 0.RAW_READS/
done < samples.txt
## Run pipeline
cd scripts
module load python
source activate java
java -version
sbatch -p fasse -c 48 -t 7-00:00:00 --mem=180000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf --main --sub1 --sub2 --path_nextflow_dir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC --path_conda_envs /n/home_fasse/lcavalli/.conda/envs"
sbatch -p fasse -c 48 -t 7-00:00:00 --mem=180000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf -resume --main --sub1 --sub2 --path_nextflow_dir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC --path_conda_envs /n/home_fasse/lcavalli/.conda/envs"



# 3. Run Nextflow pipeline for EOD vs (LOD, VLOD) - CDC and NL samples
## Make a Nextflow Pipeline directory
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline
mkdir Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL
cd Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL
## Make phenotypes files
mkdir Files
cut -f1,2 /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes.txt > /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL/Files/phenotypes.txt
awk 'NR>1' phenotypes_NL_EOD_LOD.txt >> /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL/Files/phenotypes.txt
cp /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL/Files/phenotypes.txt /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL/Files/phenotypes_filtered.txt
## Move those samples to the test pipeline directory
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL/
awk -F'\t' 'NR>1{print $1}' Files/phenotypes.txt > samples.txt
mkdir 0.RAW_READS
while read sample; do
  cp /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline/0.RAW_READS_CDC/"$sample"*.fastq.gz 0.RAW_READS/
done < samples.txt
while read sample; do
  cp /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline/0.RAW_READS_Netherlands/"$sample"*.fastq.gz 0.RAW_READS/
done < samples.txt
## Run pipeline
cd scripts
module load python
source activate java
java -version
sbatch -p fasse -c 48 -t 7-00:00:00 --mem=180000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf --main --sub1 --sub2 --path_nextflow_dir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL --path_conda_envs /n/home_fasse/lcavalli/.conda/envs"
sbatch -p fasse -c 48 -t 7-00:00:00 --mem=180000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf -resume --main --sub1 --sub2 --path_nextflow_dir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL --path_conda_envs /n/home_fasse/lcavalli/.conda/envs"


# 4. Run Nextflow pipeline for EOD vs (LOD, VLOD) - CDC + NL + Taiwan samples
## Make a Nextflow Pipeline directory
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline
mkdir Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL_TW
cd Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL_TW
## Make phenotypes files
cd Files
cp /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL/Files/phenotypes.txt ./
cat /n/hanage_gbs_gwas_l3/Lab/phenotypes_tw.txt >> phenotypes.txt
cp phenotypes.txt phenotypes_filtered.txt
## Move those samples to the test pipeline directory
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL_TW/
awk -F'\t' 'NR>1{print $1}' /n/hanage_gbs_gwas_l3/Lab/phenotypes_tw.txt > samples.txt
mkdir 0.RAW_READS
ln -s /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL/0.RAW_READS/* 0.RAW_READS
while read sample; do
  ln -s /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline/0.RAW_READS_TW/"$sample"*.fastq.gz 0.RAW_READS/
done < samples.txt
## Run pipeline
cd scripts
module load python
source activate java
java -version
sbatch -p fasse -c 48 -t 7-00:00:00 --mem=180000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf --main --sub1 --sub2 --path_nextflow_dir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL_TW --path_conda_envs /n/home_fasse/lcavalli/.conda/envs"



# Run Pyseer
mkdir 15.Pyseer/15.4.Subanalysis_3
sbatch -p fasse -t 0-10:00:00 --mem=100000 --wrap="pyseer --lmm --phenotypes Files/phenotypes_filtered.txt --continuous --phenotype-column continuous --vcf 11.SNIPPY_MULTI/core.vcf --similarity 15.Pyseer/15.1.Main_analysis/FastTree_phylogeny_K.tsv --cpu 8 > 15.Pyseer/15.4.Subanalysis_3/SNPGWAS_continuous_Fasttree.txt"
sbatch -p fasse -t 0-10:00:00 --mem=100000 --wrap="pyseer --lmm --phenotypes Files/phenotypes_filtered.txt --continuous --phenotype-column continuous --kmers 14.UNITIGS/unitigs.txt --uncompressed --similarity 15.Pyseer/15.1.Main_analysis/FastTree_phylogeny_K.tsv --output-patterns 15.Pyseer/15.4.Subanalysis_3/DBGWAS_Fasttree_LMM_unitig_patterns.txt --cpu 8 > 15.Pyseer/15.4.Subanalysis_3/DBGWAS_continuous_Fasttree.txt"
sbatch -p fasse -t 0-10:00:00 --mem=100000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --lmm --phenotypes Files/phenotypes_filtered.txt --continuous --phenotype-column continuous --pres 13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --similarity 15.Pyseer/15.1.Main_analysis/FastTree_phylogeny_K.tsv --cpu 8 > 15.Pyseer/15.4.Subanalysis_3/PanGWAS_continuous_Fasttree.txt"
