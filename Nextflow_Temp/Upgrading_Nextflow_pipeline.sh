# Test pipeline
module load python
source activate java

sbatch -p test -c 50 -t 0-06:00 --mem=100000 --wrap="nextflow -C nextflow.config run Test.nf -resume --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_18 --path_conda_envs /n/home02/lcavalli/.conda/envs"

sbatch -p test -c 48 -t 0-12:00 --mem=990000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_1 --path_conda_envs /n/home02/lcavalli/.conda/envs"

# Generate 100 ML trees on distinct starting trees and output the best likelihood tree
sbatch -p test -c 50 -t 0-06:00 --mem=100000 --wrap="/n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_56/Files/standard-RAxML-master/raxmlHPC-PTHREADS-SSE3 -T 50 -m GTRGAMMA -p 12345 -# 100 -s /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_56/11.SNIPPY_MULTI/clean.full.aln -w /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_56/12.Phylogeny/12.3.RAxML -n T1"
  # Generate 250 bootstrap tree to infer statistical support of the branches.
sbatch -p test -c 50 -t 0-06:00 --mem=100000 --wrap="/n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_56/Files/standard-RAxML-master/raxmlHPC-PTHREADS-SSE3 -T 50 -m GTRGAMMA -p 12345 -b 12345 -# 250 -s /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_56/11.SNIPPY_MULTI/clean.full.aln -w /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_56/12.Phylogeny/12.3.RAxML -n T2"
  # Draw bipartitions on the best ML tree
  /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_56/Files/standard-RAxML-master/raxmlHPC-PTHREADS-SSE3 -T 50 -m GTRCAT -p 12345 -f b -t /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_56/12.Phylogeny/12.1.RAxML/RAxML_bestTree.T1 -z /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_56/12.Phylogeny/12.1.RAxML/RAxML_bootstrap.T2 -w /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_56/12.Phylogeny/12.1.RAxML -n T3


module load python
source activate java
sbatch -p test -c 112 -t 0-12:00 --mem=990000 --wrap="nextflow -C nextflow.config run Test.nf --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_56 --path_conda_envs /n/home02/lcavalli/.conda/envs"

module load python
source activate java
sbatch -p intermediate -c 112 -t 14-00:00 --mem=990000 --wrap="nextflow -C nextflow.config run Test_Main_Analysis.nf --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_500_TEST2 --path_conda_envs /n/home02/lcavalli/.conda/envs"

module load python
source activate java
sbatch -p test -c 112 -t 0-12:00 --mem=990000 --wrap="nextflow -C nextflow.config run Test.nf --main --sub1 --sub2 --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_500 --path_conda_envs /n/home02/lcavalli/.conda/envs"
sbatch -p test -c 112 -t 0-12:00 --mem=990000 --wrap="nextflow -C nextflow.config run Test2.nf --main --Fasttree --sub2 --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_500 --path_conda_envs /n/home02/lcavalli/.conda/envs"
module load python
source activate java
sbatch -p sapphire -c 112 -t 3-00:00 --mem=990000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf --main --sub1 --sub2 --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_500_TEST2 --path_conda_envs /n/home02/lcavalli/.conda/envs"
sbatch -p intermediate -c 112 -t 6-00:00 --mem=990000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf --main  --sub1 --sub2 --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_500_TEST2 --path_conda_envs /n/home02/lcavalli/.conda/envs"


sbatch -p sapphire -c 112 -t 3-00:00 --mem=990000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf -resume --main --sub1 --sub2 --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_500_TEST2 --path_conda_envs /n/home02/lcavalli/.conda/envs"

module load python
source activate java
sbatch -p test -c 112 -t 0-12:00 --mem=990000 --wrap="nextflow -C nextflow.config run Test.nf --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_test --path_conda_envs /n/home02/lcavalli/.conda/envs"

sbatch -p sapphire -c 112 -t 3-00:00 --mem=990000 --wrap="nextflow -C nextflow.config run Test.nf --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_56 --path_conda_envs /n/home02/lcavalli/.conda/envs"


Nextflow_pipeline_FINAL.nf

grep -v "^SRR9083146\s" /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_test/Files/phenotypes_filtered.txt > /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_test/Files/phenotypes_filtered.tmp

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
mkdir -p /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline_old/Nextflow_pipeline_old1/9.POPPUNK_CORE
for i in /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline_old/Nextflow_pipeline_old1/5.ASSEMBLIES/*fasta
do
sample=$(basename $i | cut -d '.' -f1-1)
echo -e "$sample\t$i"
done > /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline_old/Nextflow_pipeline_old1/9.POPPUNK_CORE/qfile.txt

# Run
# 1. Create sketch database
sbatch -p test -c 8 -t 0-01:00 --mem=10000 --wrap="poppunk --create-db --output Test --r-files /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline_old/Nextflow_pipeline_old1/9.POPPUNK_CORE/qfile.txt --threads 8"
# 2. Run QC on the database
sbatch -p test -c 8 -t 0-01:00 --mem=10000 --wrap="poppunk --qc-db --ref-db /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline_old/Nextflow_pipeline_old1/9.POPPUNK/GBS_GWAS_db --length-range 1500000 2500000 --max-zero-dist 0.1 --threads 8"
# 3. Fit a model, check cluster (core+accessory)
sbatch -p test -c 8 -t 0-01:00 --mem=10000 --wrap="poppunk --fit-model dbscan --ref-db /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline_old/Nextflow_pipeline_old1/9.POPPUNK_CORE/GBS_GWAS_db --threads 8"
# 3. Fit a model, check cluster (core+accessory)

sbatch -p test -c 8 -t 0-01:00 --mem=10000 --wrap="poppunk --fit-model refine --ref-db /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline_old/Nextflow_pipeline_old1/9.POPPUNK/GBS_GWAS_db --indiv-refine core"
sbatch -p test -c 8 -t 0-01:00 --mem=10000 --wrap="poppunk --fit-model refine --ref-db /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline_old/Nextflow_pipeline_old1/9.POPPUNK_TEST/GBS_GWAS_db --indiv-refine core"

find /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline_old/Nextflow_pipeline_old1/4.SNIPPY -maxdepth 1 -type d ! -name "Outgroup"

SNIPPY_DIRS=\$(find /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_56/4.SNIPPY -maxdepth 1 -type d ! -name "Outgroup")
snippy-core --ref /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_56/Files/AP018935.1.fa $SNIPPY_DIRS

# Run RAxML Unrooted
## Make directory
mkdir RAxML_Unrooted
cd RAxML_Unrooted
# Make whole genome allignment
module load python
source activate snippy
sbatch -p shared -c 1 -t 0-01:00 --mem=10000 --wrap="snippy-core --ref /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_500/Files/AP018935.1.fa /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/Test_RAxML_outgroup/4.SNIPPY/SRR*"
sbatch -p shared -c 1 -t 0-01:00 --mem=10000 --wrap="snippy-clean_full_aln core.full.aln > clean.full.aln"
# Run RAxML
sbatch -p shared -c 48 -t 3-00:00 --mem=100000 --wrap="/n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_500/Files/standard-RAxML-master/raxmlHPC-PTHREADS-SSE3 -T 48 -m GTRGAMMA -p 12345 -# 100 -s clean.full.aln -n T1"
sbatch -p shared -c 48 -t 3-00:00 --mem=100000 --wrap="/n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_500/Files/standard-RAxML-master/raxmlHPC-PTHREADS-SSE3 -T 48 -m GTRGAMMA -p 12345 -b 12345 -# 250 -s clean.full.aln -n T2"
sbatch -p test -c 50 -t 0-01:00 --mem=10000 --wrap="/n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_500/Files/standard-RAxML-master/raxmlHPC-PTHREADS-SSE3 -T 50 -m GTRCAT -p 12345 -f b -t RAxML_bestTree.T1 -z RAxML_bootstrap.T2 -n T3"

# Run RAxML Spneumo Rooted
## Make directory
mkdir RAxML_Spneumo_Rooted
cd RAxML_Spneumo_Rooted
# Make whole genome allignment
module load python
source activate snippy
sbatch -p shared -c 1 -t 0-01:00 --mem=10000 --wrap="snippy-core --ref /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_500/Files/AP018935.1.fa /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/Test_RAxML_outgroup/4.SNIPPY/SRR* /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/Test_RAxML_outgroup/4.SNIPPY/Spneumo_Outgroup"
sbatch -p shared -c 1 -t 0-01:00 --mem=10000 --wrap="snippy-clean_full_aln core.full.aln > clean.full.aln"
# Run RAxML
sbatch -p test -c 50 -t 0-01:00 --mem=100000 --wrap="/n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_500/Files/standard-RAxML-master/raxmlHPC-PTHREADS-SSE3 -T 50 -m GTRGAMMA -p 12345 -# 100 -s clean.full.aln -n T1"

# Run RAxML GAS Rooted
## Make directory
mkdir RAxML_GAS_Rooted
cd RAxML_GAS_Rooted
## Make whole genome allignment
module load python
source activate snippy
sbatch -p shared -c 1 -t 0-01:00 --mem=10000 --wrap="snippy-core --ref /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_500/Files/AP018935.1.fa /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/Test_RAxML_outgroup/4.SNIPPY/SRR* /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/Test_RAxML_outgroup/4.SNIPPY/GAS_Outgroup"
sbatch -p shared -c 1 -t 0-01:00 --mem=10000 --wrap="snippy-clean_full_aln core.full.aln > clean.full.aln"
## Run RAxML
sbatch -p test -c 50 -t 0-01:00 --mem=100000 --wrap="/n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_500/Files/standard-RAxML-master/raxmlHPC-PTHREADS-SSE3 -T 50 -m GTRGAMMA -p 12345 -# 100 -s clean.full.aln -n T1"


# Generate 100 ML trees on distinct starting trees and output the best likelihood tree
sbatch -p shared -c 50 -t 0-01:00 --mem=10000 --wrap="/n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_500/Files/standard-RAxML-master/raxmlHPC-PTHREADS-SSE3 -T 50 -m GTRGAMMA -p 12345 -# 100 -s clean.full.aln -n T1"
# Generate 250 bootstrap tree to infer statistical support of the branches.
sbatch -p shared -c 50 -t 0-01:00 --mem=10000 --wrap="/n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_500/Files/standard-RAxML-master/raxmlHPC-PTHREADS-SSE3 -T 50 -m GTRGAMMA -p 12345 -b 12345 -# 250 -s clean.full.aln -n T2"
# Draw bipartitions on the best ML tree
sbatch -p shared -c 50 -t 0-01:00 --mem=10000 --wrap="/n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_500/Files/standard-RAxML-master/raxmlHPC-PTHREADS-SSE3 -T 50 -m GTRCAT -p 12345 -f b -t RAxML_bestTree.T1 -z RAxML_bootstrap.T2 -n T3"


SNIPPY_DIRS=$(find /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_56/4.SNIPPY -maxdepth 1 -type d ! -name "Outgroup")
sbatch -p shared -c 1 -t 0-01:00 --mem=10000 --wrap="snippy-core --ref /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_56/Files/AP018935.1.fa $SNIPPY_DIRS"

for i in 5.ASSEMBLY/*bam
do
sample=$(echo $i | cut -d '/' -f2-2 | cut -d '.' -f1-1)
mv 0.RAW_READS/$sample\-r{1,2}.fq.gz 0.RAW_READS/DONE/
done

for i in *_coverage.txt
do
sample=$(echo $i | cut -d '_' -f1-1)
mv ../5.ASSEMBLY/$sample*bam ../5.ASSEMBLY/DONE
done


for i in *.fa.gz
do
sbatch -p shared -t 0-05:00 --mem=100000 --wrap="gunzip $i"
done

for i in *.fa
do
  base=$(echo $i | cut -d '.' -f1-1)
  sed -i "s/NC_045512.2/$base/g" $i
  mv $i DONE
done



for i in *fa.gz
do

done
