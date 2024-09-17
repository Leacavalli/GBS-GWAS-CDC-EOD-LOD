
module load python
source activate java
sbatch -p test -c 60 -t 0-12:00 --mem=100000 --wrap="nextflow -C nextflow.config run test.nf --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade5 --path_conda_envs /n/home02/lcavalli/.conda/envs"
sbatch -p test -c 60 -t 0-12:00 --mem=100000 --wrap="nextflow -C nextflow.config run test_RAxML.nf --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade5 --path_conda_envs /n/home02/lcavalli/.conda/envs"


module load python
source activate java
sbatch -p test -c 4 -t 0-12:00 --mem=100000 --wrap="nextflow -C nextflow.config run test_flow4_main.nf --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_test --path_conda_envs /n/home02/lcavalli/.conda/envs"

module load python
source activate java
sbatch -p test -c 4 -t 0-12:00 --mem=100000 --wrap="nextflow -C nextflow.config run test_flow4_subanalysis_Fasttree.nf --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_test --path_conda_envs /n/home02/lcavalli/.conda/envs"
sbatch -p test -c 4 -t 0-12:00 --mem=100000 --wrap="nextflow -C nextflow.config run test_flow4_subanalysis_Mash.nf --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_test --path_conda_envs /n/home02/lcavalli/.conda/envs"
sbatch -p test -c 4 -t 0-12:00 --mem=100000 --wrap="nextflow -C nextflow.config run test_flow4_subanalysis_SC.nf --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_test --path_conda_envs /n/home02/lcavalli/.conda/envs"
sbatch -p test -c 4 -t 0-12:00 --mem=100000 --wrap="nextflow -C nextflow.config run test_flow4_All_options.nf --main --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_test --path_conda_envs /n/home02/lcavalli/.conda/envs"

sbatch -p test -c 4 -t 0-12:00 --mem=100000 --wrap="nextflow -C nextflow.config run test_flow4_All_options.nf --main --sub1 --sub2 --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_test --path_conda_envs /n/home02/lcavalli/.conda/envs"

sbatch -p test -c 4 -t 0-12:00 --mem=100000 --wrap="nextflow -C nextflow.config run test_flow4_All_options.nf --main --Fasttree --sub2 --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_test --path_conda_envs /n/home02/lcavalli/.conda/envs"

module load python
source activate poppunk
sbatch -p test -t 0-02:00 --mem=50000 --wrap="poppunk --create-db --output $path_nextflow_dir/9.POPPUNK/GBS_GWAS_db --r-files $path_nextflow_dir/9.POPPUNK/qfile.txt --threads 8"
sbatch -p test -t 0-02:00 --mem=50000 --wrap="poppunk --qc-db --ref-db $path_nextflow_dir/9.POPPUNK/GBS_GWAS_db --length-range 1700000 2400000 --max-zero-dist 20 --threads 8"
sbatch -p test -t 0-02:00 --mem=50000 --wrap="poppunk --fit-model dbscan --ref-db $path_nextflow_dir/9.POPPUNK/GBS_GWAS_db --threads 8"



mkdir $path_nextflow_dir/13.Phylogeny/13.1.RAxML
sbatch -p test -c 50 -t 0-05:00 --mem=100000 --wrap="/n/holylfs05/LABS/hanage_lab/Lab/holyscratch01/lcavalli/Software/standard-RAxML/raxmlHPC-PTHREADS-SSE3 -s $path_nextflow_dir/11.SNIPPY_MULTI/clean.full.aln -T 50 -m GTRGAMMA -p 1234 -b 12345 -N 100 -w $path_nextflow_dir/13.Phylogeny/13.1.RAxML -n GBS_GWAS"


-s $path_nextflow_dir/11.SNIPPY_MULTI/clean.full.aln -T 50 -m GTRGAMMA -p 1234 -b 12345 -N 100 -w $path_nextflow_dir/13.Phylogeny/13.1.RAxML -n GBS_GWAS
sbatch -p test -c 50 -t 0-05:00 --mem=100000 --wrap="/n/holylfs05/LABS/hanage_lab/Lab/holyscratch01/lcavalli/Software/standard-RAxML/raxmlHPC-PTHREADS-SSE3 -T 50 -f a -m GTRGAMMA -p 12345 -x 12345 -N 100 -s $path_nextflow_dir/11.SNIPPY_MULTI/clean.full.aln -w $path_nextflow_dir/13.Phylogeny/13.1.RAxML -n GBS_GWAS"
raxmlHPC-PTHREADS-SSE3 -s $path_nextflow_dir/11.SNIPPY_MULTI/core.vcf -T 48 -m ASC_GTRGAMMA --asc-corr=felsenstein ­-q ${params.path_nextflow_dir}/11.RAxML/part1.txt -N 100 -p 1234 -f t -t ${params.path_nextflow_dir}/10.GUBBINS/GBS_GWAS.final_tree.tre -n GBS_GWAS

$path_nextflow_dir/Files/standard-RAxML/raxmlHPC-PTHREADS-SSE3
  # 1. Create a partition file with 1 partition of length of the Core SNP alignment (containing only variant sites)
  variant_sites=$(head -2 $path_nextflow_dir/11.SNIPPY_MULTI/core.aln | tail -1 | wc -c)
  echo "[asc~$path_nextflow_dir/test_RAxML/p1_fel.txt], ASC_DNA, prt1 = 1-$variant_sites" > part1.txt
  cat part1.txt

  # 2. Create a Felsenstein correction input file displaying the number of invariant sites
  echo "2231314,$variant_sites" | tr ',' '-' | bc > p1_fel.txt
  cat p1_fel.txt

  # 3. Run RAxML
  sbatch -p test -c 10 -t 0-12:00 --mem=100000 --wrap="/n/holylfs05/LABS/hanage_lab/Lab/holyscratch01/lcavalli/Software/standard-RAxML/raxmlHPC-PTHREADS-SSE3 -s $path_nextflow_dir/12.GUBBINS/GBS_GWAS.filtered_polymorphic_sites.fasta -T 10 -m ASC_GTRGAMMA --asc-corr=felsenstein -q $path_nextflow_dir/test_RAxML/part1.txt -t $path_nextflow_dir/12.GUBBINS/GBS_GWAS.final_tree.tre -n GBS_GWAS_ASC"
