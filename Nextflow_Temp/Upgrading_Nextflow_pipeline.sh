# Test pipeline
module load python
source activate java
sbatch -p test -c 112 -t 0-12:00 --mem=990000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf --main --sub1 --sub2 --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline/Nextflow_pipeline --path_conda_envs /n/home02/lcavalli/.conda/envs"


sbatch -p test -c 1 -t 0-12:00 --mem=990000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_1 --path_conda_envs /n/home02/lcavalli/.conda/envs"

# Test RAxML
module load python
source activate java
sbatch -p test -c 50 -t 0-12:00 --mem=100000 --wrap="nextflow -C nextflow.config run test_RAxML.nf --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_18 --path_conda_envs /n/home02/lcavalli/.conda/envs"

# Test Unicycler
module load python
source activate java
sbatch -p test -c 112 -t 0-12:00 --mem=990000 --wrap="nextflow -C nextflow.config run test.nf --main --sub1 --sub2 --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_56_test_unicycler --path_conda_envs /n/home02/lcavalli/.conda/envs"


# Test RAxML
module load python
source activate java
sbatch -p test -c 50 -t 0-12:00 --mem=100000 --wrap="nextflow -C nextflow.config run test_RAxML.nf --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_18 --path_conda_envs /n/home02/lcavalli/.conda/envs"


TO DO
- solve quast issue - DONE (/n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_1/scripts)
- Poppunk QC Fail report -DONE
- RUN with filtering phenotype.txt file -IP (/n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline/Nextflow_pipeline/scripts)



# Prepare input file
mkdir -p /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline_old/Nextflow_pipeline_old1/9.POPPUNK_CORE_CORE
for i in /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline_old/Nextflow_pipeline_old1/5.ASSEMBLIES/*fasta
do
sample=$(basename $i | cut -d '.' -f1-1)
echo -e "$sample\t$i"
done > /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline_old/Nextflow_pipeline_old1/9.POPPUNK_CORE/qfile.txt

# Run
# 1. Create sketch database
poppunk --create-db --output /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline_old/Nextflow_pipeline_old1/9.POPPUNK_CORE/GBS_GWAS_db --r-files /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline_old/Nextflow_pipeline_old1/9.POPPUNK_CORE/qfile.txt --threads 8
# 2. Run QC on the database
poppunk --qc-db --ref-db /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline_old/Nextflow_pipeline_old1/9.POPPUNK_CORE/GBS_GWAS_db --length-range 1500000 2500000  --max-zero-dist 0.1 --threads 8
# 3. Fit a model, check cluster (core+accessory)
poppunk --fit-model dbscan --ref-db /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline_old/Nextflow_pipeline_old1/9.POPPUNK_CORE/GBS_GWAS_db --threads 8




module load python
source activate java
sbatch -p test -c 112 -t 0-12:00 --mem=990000 --wrap="nextflow -C nextflow.config run BCH_GBS_Nextflow_pipeline.nf --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/BCH_GBS/NEXTFLOW_PIPELINE --path_conda_envs /n/home02/lcavalli/.conda/envs"
