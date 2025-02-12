#Powerbac GWAS Test

# Install

cd /n/netscratch/hanage_lab/Lab/rbalasubramanian 

module load python
source activate java
git clone https://github.com/francesccoll/powerbacgwas/
cd powerbacgwas/
git clone https://github.com/evolbioinfo/pastml
git clone https://github.com/mgalardini/pyseer
cd nextflow 
nextflow run main.nf --help

salloc -p hsph -c 48 -t 00-09:00 --mem=200000
source activate java

#Pre processing

#COPY VCF Files Pangenome files and Tree Files to Nextflow folder 

cp /n/netscratch/hanage_lab/Lab/rbalasubramanian/GBS-GWAS-pipeline/Nextflow_pipeline/11.SNIPPY_MULTI/core.vcf ./

cp /n/netscratch/hanage_lab/Lab/rbalasubramanian/GBS-GWAS-pipeline/Nextflow_pipeline/12.Phylogeny/12.2.FastTree/GBS_FastTree_phylo.tre ./

cp /n/netscratch/hanage_lab/Lab/rbalasubramanian/GBS-GWAS-pipeline/Nextflow_pipeline/13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab ./

#SNP GWAS (Done)
nextflow run main.nf --vcf core.vcf --outprefix GBS_test.var --run_prepare_vcf -profile farm  --num_cores 8

#Pan GWAS (Done)
nextflow run main.nf --pangenome gene_presence_absence.Rtab --outprefix GBS_test.pg --run_prepare_pangenome -profile farm --num_cores 8

#Ancestral state reconsruction 

#SNP GWAS (Done)
nextflow run main.nf --outprefix GBS_test.var --tree GBS_FastTree_phylo.tre --run_vcf_ast -profile farm --num_cores 8

#PanGWAS (Done)
nextflow run main.nf --outprefix GBS_test.pg --tree GBS_FastTree_phylo.tre --run_pangenome_ast -profile farm --num_cores 8



#? --run_vcf_regions_ast, to be run after --run_prepare_vcf and --run_vcf_ast what is the prefix for genes??
#? I beleive fasttree output should be in newick format but want to confirm 
#double check name for pangenome and vcf outputs 

#Phenotype simulation approach: # do we specify new vcf files and new tree file? 

#SNP GWAS 
nextflow run main.nf --outprefix GBS_test.var --tree GBS_FastTree_phylo.tre --vcf core.vcf --parameters GBS_parameters.txt --run_phensim_vcf -profile farm --num_cores 8 --gwas_tmp_dir tmp/gwas_tmp_GBS_SNPGWAS_test/

#PanGWAS

nextflow run main.nf --outprefix GBS_test.pg --tree  GBS_FastTree_phylo.tre --pangenome gene_presence_absence.Rtab --parameters GBS_parameters.txt --run_phensim_pangenome --num_cores 8 --gwas_tmp_dir tmp/gwas_tmp_GBS_PanGWAS_test/



