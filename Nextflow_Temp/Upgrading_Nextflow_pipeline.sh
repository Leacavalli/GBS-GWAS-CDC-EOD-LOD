# Test pipeline
module load python
source activate java

sbatch -p sapphire -c 112 -t 3-00:00 --mem=990000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf --main --sub1 --sub2 --path_nextflow_dir /n/netscratch/hanage_lab/Lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline/Nextflow_pipeline --path_conda_envs /n/home02/lcavalli/.conda/envs"


sbatch -p test -c 112 -t 0-12:00 --mem=100000 --wrap="nextflow -C nextflow.config run Test.nf -resume --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_18 --path_conda_envs /n/home02/lcavalli/.conda/envs"


sbatch -p intermediate -c 112 -t 14-00:00 --mem=990000 --wrap="nextflow -C nextflow.config run Test_Main_Analysis.nf --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_500_TEST2 --path_conda_envs /n/home02/lcavalli/.conda/envs"
