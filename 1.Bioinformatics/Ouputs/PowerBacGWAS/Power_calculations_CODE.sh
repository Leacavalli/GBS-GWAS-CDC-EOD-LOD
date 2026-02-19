PowerBacGWAS: Power calculations for Bacterial GWAS

https://github.com/francesccoll/powerbacgwas/wiki#usage

# Install
module load python
source activate java
git clone https://github.com/francesccoll/powerbacgwas/
cd powerbacgwas/nextflow
nextflow run main.nf --help

cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Power_Calc/

## CDC
### SNPGWAS
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Power_Calc/powerbacgwas_SNPGWAS_CDC/nextflow
sbatch -p fasse -c 48 -t 00-09:00 --mem=100000 --wrap="nextflow run main.nf --outprefix CDC_Samp20_Sim100.var --vcf /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/11.SNIPPY_MULTI/merged_max5missing.vcf --run_prepare_vcf -profile farm --num_cores 48"
sbatch -p fasse -c 48 -t 00-09:00 --mem=100000 --wrap="nextflow run main.nf --outprefix CDC_Samp20_Sim100.var --tree /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/12.Phylogeny/12.1.FastTree_DP/EOD_LOD_VLOD_CDC_FastTree_DP.tre --run_vcf_ast -profile farm --num_cores 48"
sbatch -p fasse -c 48 -t 7-00:00:00 --mem=100000 --wrap="nextflow run main.nf --outprefix CDC_Samp20_Sim100.var --tree /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/12.Phylogeny/12.1.FastTree_DP/EOD_LOD_VLOD_CDC_FastTree_DP.tre --vcf /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/11.SNIPPY_MULTI/merged_max5missing.vcf --parameters GBS_parameters_Samp20_Sim100.txt --run_phensim_vcf -profile farm --num_cores 48 --gwas_tmp_dir tmp/CDC_SNPGWAS_Samp20_Sim100/"
# slurm-6412602.out

sbatch -p fasse -c 48 -t 7-00:00:00 --mem=100000 --wrap="nextflow run main.nf --outprefix CDC_Samp20_Sim100.var --tree /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/12.Phylogeny/12.1.FastTree_DP/EOD_LOD_VLOD_CDC_FastTree_DP.tre --vcf /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/11.SNIPPY_MULTI/merged_max5missing.vcf --parameters GBS_parameters_Samp20_Sim100.txt --run_phensim_vcf -profile farm --num_cores 48 --gwas_tmp_dir tmp/CDC_SNPGWAS_Samp20_Sim100/ -resume d179ffff-d355-42a0-8eff-ad2376db4c7b"


### PanGWAS
sbatch -p fasse -c 48 -t 00-09:00 --mem=100000 --wrap="nextflow run main.nf --outprefix CDC_Samp20_Sim100.pg --pangenome /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --run_prepare_pangenome -profile farm --num_cores 48"
sbatch -p fasse -c 48 -t 00-09:00 --mem=100000 --wrap="nextflow run main.nf --outprefix CDC_Samp20_Sim100.pg --tree /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/12.Phylogeny/12.1.FastTree_DP/EOD_LOD_VLOD_CDC_FastTree_DP.tre --run_pangenome_ast -profile farm --num_cores 48"
sbatch -p fasse -c 48 -t 00-09:00 --mem=100000 --wrap="nextflow run main.nf --outprefix CDC_Samp20_Sim100.pg --tree /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/12.Phylogeny/12.1.FastTree_DP/EOD_LOD_VLOD_CDC_FastTree_DP.tre --pangenome /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --parameters GBS_parameters_Samp20_Sim100.txt --run_phensim_pangenome -profile farm --num_cores 48 --gwas_tmp_dir tmp/CDC_PanGWAS_Samp20_Sim100/"
# Done !

## NL
### SNPGWAS
sbatch -p fasse -c 48 -t 00-09:00 --mem=100000 --wrap="nextflow run main.nf --outprefix NL_Samp20_Sim100.var --vcf /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_NL/11.SNIPPY_MULTI/merged_max5missing.vcf --run_prepare_vcf -profile farm --num_cores 48"
sbatch -p fasse -c 48 -t 00-09:00 --mem=100000 --wrap="nextflow run main.nf --outprefix NL_Samp20_Sim100.var --tree /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_NL/12.Phylogeny/12.2.FastTree/GBS_GWAS_FastTree_phylo.tre --run_vcf_ast -profile farm --num_cores 48"
sbatch -p fasse -c 48 -t 7-00:00:00 --mem=100000 --wrap="nextflow run main.nf --outprefix NL_Samp20_Sim100.var --tree /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_NL/12.Phylogeny/12.2.FastTree/GBS_GWAS_FastTree_phylo.tre --vcf /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_NL/11.SNIPPY_MULTI/merged_max5missing.vcf --parameters GBS_parameters_Samp20_Sim100.txt --run_phensim_vcf -profile farm --num_cores 48 --gwas_tmp_dir tmp/NL_SNPGWAS_Samp20_Sim100/"
# Done !

### PanGWAS
sbatch -p fasse -c 48 -t 00-09:00 --mem=100000 --wrap="nextflow run main.nf --outprefix NL_Samp20_Sim100.pg --pangenome /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_NL/13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --run_prepare_pangenome -profile farm --num_cores 48"
sbatch -p fasse -c 48 -t 00-09:00 --mem=100000 --wrap="nextflow run main.nf --outprefix NL_Samp20_Sim100.pg --tree /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_NL/12.Phylogeny/12.2.FastTree/GBS_GWAS_FastTree_phylo.tre --run_pangenome_ast -profile farm --num_cores 48"
sbatch -p fasse -c 48 -t 7-00:00:00 --mem=100000 --wrap="nextflow run main.nf --outprefix NL_Samp20_Sim100.pg --tree /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_NL/12.Phylogeny/12.2.FastTree/GBS_GWAS_FastTree_phylo.tre --pangenome /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_NL/13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --parameters GBS_parameters_Samp20_Sim100.txt --run_phensim_pangenome -profile farm --num_cores 48 --gwas_tmp_dir tmp/NL_PanGWAS_Samp20_Sim100/"
# Done !


## CDC_NL_TW
### SNPGWAS
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Power_Calc/powerbacgwas_SNPGWAS_CDC_NL_TW/nextflow
sbatch -p fasse -c 48 -t 00-09:00 --mem=100000 --wrap="nextflow run main.nf --outprefix CDC_NL_TW_Samp20_Sim100.var --vcf /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL_TW/11.SNIPPY_MULTI/merged_max5missing.vcf --run_prepare_vcf -profile farm --num_cores 48"
sbatch -p fasse -c 48 -t 00-09:00 --mem=180000 --wrap="nextflow run main.nf --outprefix CDC_NL_TW_Samp20_Sim100.var --tree /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL_TW/12.Phylogeny/12.2.FastTree/GBS_GWAS_FastTree_phylo.tre --run_vcf_ast -profile farm --num_cores 48"
sbatch -p fasse -c 48 -t 7-00:00:00 --mem=100000 --wrap="nextflow run main.nf --outprefix CDC_NL_TW_Samp20_Sim100.var --tree /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL_TW/12.Phylogeny/12.2.FastTree/GBS_GWAS_FastTree_phylo.tre --vcf /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL_TW/11.SNIPPY_MULTI/merged_max5missing.vcf --parameters GBS_parameters_Samp20_Sim100.txt --run_phensim_vcf -profile farm --num_cores 48 --gwas_tmp_dir tmp/CDC_NL_TW_SNPGWAS_Samp20_Sim100/"
#


### PanGWAS
sbatch -p fasse -c 48 -t 00-09:00 --mem=100000 --wrap="nextflow run main.nf --outprefix CDC_NL_TW_Samp20_Sim100.pg --pangenome /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL_TW/13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --run_prepare_pangenome -profile farm --num_cores 48"
sbatch -p fasse -c 48 -t 00-09:00 --mem=100000 --wrap="nextflow run main.nf --outprefix CDC_NL_TW_Samp20_Sim100.pg --tree /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL_TW/12.Phylogeny/12.2.FastTree/GBS_GWAS_FastTree_phylo.tre --run_pangenome_ast -profile farm --num_cores 48"
sbatch -p fasse -c 48 -t 7-00:00:00 --mem=100000 --wrap="nextflow run main.nf --outprefix CDC_NL_TW_Samp20_Sim100.pg --tree /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL_TW/12.Phylogeny/12.2.FastTree/GBS_GWAS_FastTree_phylo.tre --pangenome /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL_TW/13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --parameters GBS_parameters_Samp20_Sim100.txt --run_phensim_pangenome -profile farm --num_cores 48 --gwas_tmp_dir tmp/CDC_NL_TW_PanGWAS_Samp20_Sim100/"
# Done !

sbatch -p fasse -c 48 -t 7-00:00:00 --mem=100000 --wrap="nextflow run main.nf -resume --outprefix CDC_NL_TW_Samp20_Sim100.pg --tree /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL_TW/12.Phylogeny/12.2.FastTree/GBS_GWAS_FastTree_phylo.tre --pangenome /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL_TW/13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --parameters GBS_parameters_Samp20_Sim100.txt --run_phensim_pangenome -profile farm --num_cores 48 --gwas_tmp_dir tmp/CDC_NL_TW_PanGWAS_Samp20_Sim100/"
# DONE !




cd /n/netscratch/hanage_lab/Lab/lcavalli/

## CDC
### SNPGWAS
cd /n/netscratch/hanage_lab/Lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/Power_Calculations/powerbacgwas_CDC_SNP/nextflow
sbatch -p hsph -c 48 -t 00-01:00 --mem=50000 --wrap="nextflow run main.nf --outprefix CDC_Samp20_Sim100.var --vcf CDC_merged_max5missing.vcf --run_prepare_vcf -profile farm --num_cores 48"
sbatch -p hsph -c 48 -t 00-01:00 --mem=100000 --wrap="nextflow run main.nf --outprefix CDC_Samp20_Sim100.var --tree CDC_FastTree.tre --run_vcf_ast -profile farm --num_cores 48"
sbatch -p intermediate -c 48 -t 14-00:00:00 --mem=100000 --wrap="nextflow run main.nf --outprefix CDC_Samp20_Sim100.var --tree CDC_FastTree.tre --vcf CDC_merged_max5missing.vcf --parameters GBS_parameters_Samp20_Sim100.txt --run_phensim_vcf -profile farm --num_cores 48 --gwas_tmp_dir tmp/CDC_SNPGWAS_Samp20_Sim100/"

## Global
### SNPGWAS
cd /n/netscratch/hanage_lab/Lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/Power_Calculations/powerbacgwas_CDC_NL_TW_SNP/nextflow
sbatch -p hsph -c 48 -t 00-01:00 --mem=10000 --wrap="nextflow run main.nf --outprefix CDC_NL_TW_Samp20_Sim100.var --vcf CDC_NL_TW_merged_max5missing.vcf --run_prepare_vcf -profile farm --num_cores 48"
sbatch -p hsph -c 48 -t 00-01:00 --mem=150000 --wrap="nextflow run main.nf --outprefix CDC_NL_TW_Samp20_Sim100.var --tree CDC_NL_TW_FastTree.tre --run_vcf_ast -profile farm --num_cores 48"
sbatch -p hsph -c 48 -t 7-00:00:00 --mem=100000 --wrap="nextflow run main.nf --outprefix CDC_Samp20_Sim100.var --tree CDC_FastTree.tre --vcf CDC_merged_max5missing.vcf --parameters GBS_parameters_Samp20_Sim100.txt --run_phensim_vcf -profile farm --num_cores 48 --gwas_tmp_dir tmp/CDC_SNPGWAS_Samp20_Sim100/"
