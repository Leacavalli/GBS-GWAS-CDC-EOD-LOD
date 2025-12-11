#!/bin/bash
#SBATCH -p fasse
#SBATCH -t 0-2:00 
#SBATCH --mem=4G
#SBATCH -o /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_NL/14.UNITIGS/unitig_dist/output_log.out
#SBATCH -e /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_NL/14.UNITIGS/unitig_dist/error_log.err

module load R

# set R packages and rstudio server singularity image locations
my_packages="/n/home_fasse/lcavalli/apps/R"
rstudio_singularity_image="/n/singularity_images/informatics/ifxrstudio/ifxrstudio:RELEASE_3_16.sif"

# run myscript.R using RStudio Server signularity image
singularity exec --cleanenv --env R_LIBS_USER=${my_packages} ${rstudio_singularity_image} Rscript Get_jaccard_dist.R
