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
ls
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

sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=450000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf -resume --main --sub1 --sub2 --path_nextflow_dir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL --path_conda_envs /n/home_fasse/lcavalli/.conda/envs"


fasse
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
mkdir 0.RAW_READS
ln -s /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline/0.RAW_READS_Netherlands/*.fastq.gz 0.RAW_READS/
ln -s /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline/0.RAW_READS_CDC/*.fastq.gz 0.RAW_READS/
ln -s /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline/0.RAW_READS_TW/*.fastq.gz 0.RAW_READS/

## Run pipeline
cd scripts
module load python
source activate java
java -version
sbatch -p fasse -c 48 -t 7-00:00:00 --mem=180000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf --main --sub1 --sub2 --path_nextflow_dir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL_TW --path_conda_envs /n/home_fasse/lcavalli/.conda/envs"
sbatch -p fasse -c 48 -t 7-00:00:00 --mem=180000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf -resume --main --sub1 --sub2 --path_nextflow_dir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL_TW --path_conda_envs /n/home_fasse/lcavalli/.conda/envs"

sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=450000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf -resume --main --sub1 --sub2 --path_nextflow_dir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL_TW --path_conda_envs /n/home_fasse/lcavalli/.conda/envs"



# 5. Run Nextflow pipeline for EOD vs LOD - NL samples only
## Make a Nextflow Pipeline directory
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline
mkdir Nextflow_pipeline_EOD_LOD_NL
cd Nextflow_pipeline_EOD_LOD_NL
## Make phenotypes files
mkdir Files
cd Files
cp ../../../phenotypes_NL_EOD_LOD.txt phenotypes.txt
cp ../../../phenotypes_NL_EOD_LOD.txt phenotypes_filtered.txt
## Move those samples to the test pipeline directory
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_NL/
mkdir 0.RAW_READS
awk -F'\t' 'NR>1{print $1}' Files/phenotypes.txt > samples.txt
ln -s /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline/0.RAW_READS_Netherlands/*.fastq.gz 0.RAW_READS/
## Run pipeline
mkdir scripts
cd scripts
cp ../../Nextflow_pipeline_EOD_LOD_CDC/scripts/nextflow.config ./
cp ../../Nextflow_pipeline_EOD_LOD_CDC/scripts/Nextflow_pipeline_FINAL.nf ./
module load python
source activate java
java -version
sbatch -p fasse -c 48 -t 7-00:00:00 --mem=180000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf --main --sub1 --sub2 --path_nextflow_dir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_NL --path_conda_envs /n/home_fasse/lcavalli/.conda/envs"
sbatch -p fasse -c 48 -t 7-00:00:00 --mem=180000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf -resume --main --sub1 --sub2 --path_nextflow_dir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_NL --path_conda_envs /n/home_fasse/lcavalli/.conda/envs"




# Run Pyseer
mkdir 15.Pyseer/15.4.Subanalysis_3
sbatch -p fasse -t 0-10:00:00 --mem=100000 --wrap="pyseer --lmm --phenotypes Files/phenotypes_filtered.txt --continuous --phenotype-column continuous --vcf 11.SNIPPY_MULTI/core.vcf --similarity 15.Pyseer/15.1.Main_analysis/FastTree_phylogeny_K.tsv --cpu 8 > 15.Pyseer/15.4.Subanalysis_3/SNPGWAS_continuous_Fasttree.txt"
sbatch -p fasse -t 0-10:00:00 --mem=100000 --wrap="pyseer --lmm --phenotypes Files/phenotypes_filtered.txt --continuous --phenotype-column continuous --kmers 14.UNITIGS/unitigs.txt --uncompressed --similarity 15.Pyseer/15.1.Main_analysis/FastTree_phylogeny_K.tsv --output-patterns 15.Pyseer/15.4.Subanalysis_3/DBGWAS_Fasttree_LMM_unitig_patterns.txt --cpu 8 > 15.Pyseer/15.4.Subanalysis_3/DBGWAS_continuous_Fasttree.txt"
sbatch -p fasse -t 0-10:00:00 --mem=100000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --lmm --phenotypes Files/phenotypes_filtered.txt --continuous --phenotype-column continuous --pres 13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --similarity 15.Pyseer/15.1.Main_analysis/FastTree_phylogeny_K.tsv --cpu 8 > 15.Pyseer/15.4.Subanalysis_3/PanGWAS_continuous_Fasttree.txt"




module load python
source activate pyseer


cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/15.Pyseer/15.1.Main_analysis
sbatch -p fasse -c 1 -t 1-00:00:00 --mem=50000 --wrap="annotate_hits_pyseer DBGWAS_Fasttree_LMM.txt ../../Files/DBGWAS_references_v2.txt DBGWAS_Fasttree_LMM_annotation.txt"
python summarise_annotations.py DBGWAS_Fasttree_LMM_annotation.txt > gene_hits.txt

cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/15.Pyseer/15.2.Subanalysis_1/15.2.1.Fasttree_FEM
sbatch -p fasse -c 1 -t 1-00:00:00 --mem=50000 --wrap="annotate_hits_pyseer DBGWAS_Fasttree_FEM.txt ../../../Files/DBGWAS_references.txt DBGWAS_Fasttree_FEM_annotation.txt"

cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/15.Pyseer/15.2.Subanalysis_1/15.2.3.Mash
sbatch -p fasse -c 1 -t 1-00:00:00 --mem=50000 --wrap="annotate_hits_pyseer DBGWAS_mash.txt ../../../Files/DBGWAS_references.txt DBGWAS_mash_annotation.txt"

cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/15.Pyseer/15.2.Subanalysis_1/15.2.4.SC
sbatch -p fasse -c 1 -t 1-00:00:00 --mem=50000 --wrap="annotate_hits_pyseer DBGWAS_SC.txt ../../../Files/DBGWAS_references.txt DBGWAS_SC_annotation.txt"

cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/15.Pyseer/15.4.Subanalysis_3
sbatch -p fasse -c 1 -t 1-00:00:00 --mem=50000 --wrap="annotate_hits_pyseer DBGWAS_continuous_Fasttree.txt ../../Files/DBGWAS_references.txt DBGWAS_continuous_Fasttree_annotation.txt"



cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL/15.Pyseer/15.1.Main_analysis
sbatch -p fasse -c 1 -t 1-00:00:00 --mem=50000 --wrap="annotate_hits_pyseer DBGWAS_Fasttree_LMM.txt ../../Files/DBGWAS_references.txt DBGWAS_Fasttree_LMM_annotation.txt"





cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files
## First list the reference annotation ("ref genome")
echo -e '/n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/AP018935.1.fa\t/n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/AP018935.1.gff3\tref' > DBGWAS_references.txt
## Then, add study samples rows ("draft genomes")
for fasta in ../5.ASSEMBLIES/*.fasta
do
    sample=$(basename "$fasta" .fasta)
    echo -e "/n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/5.ASSEMBLIES/$sample.fasta\t/n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/6.ANNOTATION/$sample.gff\tdraft"
done >> DBGWAS_references.txt

cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/15.Pyseer/15.1.Main_analysis
sbatch -p fasse -c 1 -t 1-00:00:00 --mem=50000 --wrap="annotate_hits_pyseer DBGWAS_Fasttree_LMM.txt ../../Files/DBGWAS_references.txt DBGWAS_Fasttree_LMM_annotation.txt"

cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/15.Pyseer/15.2.Subanalysis_1/15.2.1.Fasttree_FEM
sbatch -p fasse -c 1 -t 1-00:00:00 --mem=50000 --wrap="annotate_hits_pyseer DBGWAS_Fasttree_FEM.txt ../../../Files/DBGWAS_references.txt DBGWAS_Fasttree_FEM_annotation.txt"

cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/15.Pyseer/15.2.Subanalysis_1/15.2.3.Mash
sbatch -p fasse -c 1 -t 1-00:00:00 --mem=50000 --wrap="annotate_hits_pyseer DBGWAS_mash.txt ../../../Files/DBGWAS_references.txt DBGWAS_mash_annotation.txt"

cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/15.Pyseer/15.2.Subanalysis_1/15.2.4.SC
sbatch -p fasse -c 1 -t 1-00:00:00 --mem=50000 --wrap="annotate_hits_pyseer DBGWAS_SC.txt ../../../Files/DBGWAS_references.txt DBGWAS_SC_annotation.txt"

cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/15.Pyseer/15.4.Subanalysis_3
sbatch -p fasse -c 1 -t 1-00:00:00 --mem=50000 --wrap="annotate_hits_pyseer DBGWAS_continuous_Fasttree.txt ../../Files/DBGWAS_references.txt DBGWAS_continuous_Fasttree_annotation.txt"



# Install eggnog-mapper
module load python
conda create -n eggnog
source activate eggnog
conda install -c bioconda -c conda-forge eggnog-mapper
emapper.py -h
mkdir /n/home_fasse/lcavalli/.conda/envs/eggnog/lib/python3.11/site-packages/data
download_eggnog_data.py --data_dir /n/home_fasse/lcavalli/.conda/envs/eggnog/lib/python3.11/site-packages/data
# Run eggnog-mapper
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/15.Pyseer/15.1.Main_analysis
sbatch -p fasse -c 8 -t 1-00:00:00 --mem=50000 --wrap="emapper.py -m diamond --itype CDS -i /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/13.Pangenome_analysis/13.1.Panaroo/pan_genome_reference.fa -o panaroo_annotation --cpu 8"
