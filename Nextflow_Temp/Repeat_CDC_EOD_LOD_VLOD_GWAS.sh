
# Nextflow_pipeline_EOD_LOD_VLOD_CDC
module load python
source activate pyseer

# MAIN ANALYSIS
# pop structure correction: fastree double precission on full aln (LMM)
# Phenotype: binary
# Pangenome tool: panaroo
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/12.Phylogeny/12.1.FastTree_DP/
# population structure distances
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="python ../Files/pyseer/scripts/phylogeny_distance.py --lmm EOD_LOD_VLOD_CDC_FastTree_DP.tre > EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv"
## SNPGWAS
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="pyseer --lmm --phenotypes ../Files/phenotypes_filtered.txt --phenotype-column binary --vcf ../11.SNIPPY_MULTI/merged_max5missing.vcf --similarity EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv > SNPGWAS_FastTree_DP_LMM.txt"
## DBGWAS
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --lmm --phenotypes ../Files/phenotypes_filtered.txt  --phenotype-column binary --kmers ../14.UNITIGS/unitigs.txt --uncompressed --similarity EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv > DBGWAS_FastTree_DP_LMM.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="annotate_hits_pyseer DBGWAS_FastTree_DP_LMM.txt ../Files/DBGWAS_references.txt DBGWAS_FastTree_DP_LMM_annotation.txt"
## PanGWAS
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --lmm --phenotypes ../Files/phenotypes_filtered.txt --phenotype-column binary --pres ../13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --similarity EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv > PanGWAS_FastTree_DP_LMM.txt"

# SUBANALYSIS 1: POPULATION STRUCTURE CORRECTION
# pop structure correction: fastree double precission on full aln (FEM)
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/12.Phylogeny/12.1.FastTree_DP/15.2.Subanalysis_1/15.2.1.Fasttree_FEM
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="python /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/pyseer/scripts/phylogeny_distance.py /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/12.Phylogeny/12.1.FastTree_DP/EOD_LOD_VLOD_CDC_FastTree_DP.tre > FastTree_DP_phylogeny_distances.tsv"
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --phenotypes /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes_filtered.txt --phenotype-column binary --vcf /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/11.SNIPPY_MULTI/merged_max5missing.vcf --distances FastTree_DP_phylogeny_distances.tsv > SNPGWAS_Fasttree_DP_FEM.txt"
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --phenotypes /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes_filtered.txt --phenotype-column binary --kmers /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/14.UNITIGS/unitigs.txt --uncompressed --distances FastTree_DP_phylogeny_distances.tsv > DBGWAS_Fasttree_DP_FEM.txt"
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --phenotypes /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes_filtered.txt --phenotype-column binary --pres /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --distances FastTree_DP_phylogeny_distances.tsv > PanGWAS_Fasttree_DP_FEM.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="annotate_hits_pyseer DBGWAS_Fasttree_DP_FEM.txt ../../../../Files/DBGWAS_references.txt DBGWAS_Fasttree_DP_FEM_annotation.txt"

# pop structure correction: fastree single precission on full aln
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/12.Phylogeny/12.1.FastTree_DP/15.2.Subanalysis_1/15.2.2.Fasttree_SP_LMM
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="python /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/pyseer/scripts/phylogeny_distance.py --lmm /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/12.Phylogeny/12.2.FastTree_SP/GBS_GWAS_FastTree_phylo.tre > EOD_LOD_VLOD_CDC_FastTree_SP_K.tsv"
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --lmm --phenotypes /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes_filtered.txt --phenotype-column binary --vcf /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/11.SNIPPY_MULTI/merged_max5missing.vcf --similarity EOD_LOD_VLOD_CDC_FastTree_SP_K.tsv > SNPGWAS_Fasttree_SP_LMM.txt"
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --lmm --phenotypes /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes_filtered.txt --phenotype-column binary --kmers /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/14.UNITIGS/unitigs.txt --uncompressed --similarity EOD_LOD_VLOD_CDC_FastTree_SP_K.tsv > DBGWAS_Fasttree_SP_LMM.txt"
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --lmm --phenotypes /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes_filtered.txt --phenotype-column binary --pres /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --similarity EOD_LOD_VLOD_CDC_FastTree_SP_K.tsv > PanGWAS_Fasttree_SP_LMM.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="annotate_hits_pyseer DBGWAS_Fasttree_SP_LMM.txt ../../../../Files/DBGWAS_references.txt DBGWAS_Fasttree_SP_LMM_annotation.txt"

# pop structure correction: RAxML on core aln with ASC_FELS
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/12.Phylogeny/12.1.FastTree_DP/15.2.Subanalysis_1/15.2.6.RAxML
module load python
source activate raxml-ng
sbatch -p fasse -t 0-10:00:00 --mem=50000 --wrap="raxml-ng --parse --msa ../../../../11.SNIPPY_MULTI/clean.full.aln --model GTR+G"
sbatch -p fasse -t 0-10:00:00 --mem=50000 --wrap="raxml-ng --parse --msa ../../../../11.SNIPPY_MULTI/core.aln --model GTR+G"
## Get number of invariant sites for Felsenstein correction:
awk '/^>/ {if(s){print length(s); exit} } {if(!/^>/) s=s $0} END{if(s) print length(s)}' ../../../../11.SNIPPY_MULTI/core.full.aln # 2231314
awk '/^>/ {if(s){print length(s); exit} } {if(!/^>/) s=s $0} END{if(s) print length(s)}' ../../../../11.SNIPPY_MULTI/core.aln # 586
# 2231314 - 586 = 2230728
## RAxML_MLsearch
sbatch -p fasse -c 2 -t 3-00:00:00 --mem=100000 --wrap="raxml-ng --msa ../../../../11.SNIPPY_MULTI/core.aln --model GTR+G+ASC_FELS{2230728} --threads 2 --seed 12345 --prefix core_ascfel"
## GWAS
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="python ../../../../Files/pyseer/scripts/phylogeny_distance.py --lmm core_ascfel.raxml.bestTree > EOD_LOD_VLOD_CDC_RAxML_K.tsv"
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="pyseer --lmm --phenotypes ../../../../Files/phenotypes_filtered.txt --phenotype-column binary --vcf ../../../../11.SNIPPY_MULTI/merged_max5missing.vcf --similarity EOD_LOD_VLOD_CDC_RAxML_K.tsv > SNPGWAS_RAxML.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --lmm --phenotypes ../../../../Files/phenotypes_filtered.txt  --phenotype-column binary --kmers ../../../../14.UNITIGS/unitigs.txt --uncompressed --similarity EOD_LOD_VLOD_CDC_RAxML_K.tsv > DBGWAS_RAxML.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --lmm --phenotypes ../../../../Files/phenotypes_filtered.txt --phenotype-column binary --pres ../../../../13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --similarity EOD_LOD_VLOD_CDC_RAxML_K.tsv > PanGWAS_RAxML.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="annotate_hits_pyseer DBGWAS_RAxML.txt ../../../../Files/DBGWAS_references.txt DBGWAS_RAxML_annotation.txt"

# pop structure correction: IQtree on core aln with ASC_FELS
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/12.Phylogeny/12.1.FastTree_DP/15.2.Subanalysis_1/15.2.7.IQtree
conda create -n iqtree2 -c bioconda -c conda-forge iqtree
source activate iqtree2
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="iqtree -s ../../../../11.SNIPPY_MULTI/core.aln -m GTR+G+ASC -B 1000 -alrt 1000 -T AUTO --prefix gbs_gwas_core --seed 12345"
## GWAS
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="python /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/pyseer/scripts/phylogeny_distance.py --lmm gbs_gwas_core.treefile > EOD_LOD_VLOD_CDC_IQtree_K.tsv"
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="pyseer --lmm --phenotypes /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes_filtered.txt --phenotype-column binary --vcf /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/11.SNIPPY_MULTI/merged_max5missing.vcf --similarity EOD_LOD_VLOD_CDC_IQtree_K.tsv > SNPGWAS_IQtree.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --lmm --phenotypes /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes_filtered.txt  --phenotype-column binary --kmers /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/14.UNITIGS/unitigs.txt --uncompressed --similarity EOD_LOD_VLOD_CDC_IQtree_K.tsv > DBGWAS_IQtree.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --lmm --phenotypes /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes_filtered.txt --phenotype-column binary --pres /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --similarity EOD_LOD_VLOD_CDC_IQtree_K.tsv > PanGWAS_IQtree.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="annotate_hits_pyseer DBGWAS_IQtree.txt ../../../../Files/DBGWAS_references.txt DBGWAS_IQtree_annotation.txt"

# pop structure correction: Mash distances
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/12.Phylogeny/12.1.FastTree_DP/15.2.Subanalysis_1/15.2.3.Mash
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="mash sketch -s 10000 -o mash_sketch /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/5.ASSEMBLIES/*.fasta"
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="mash dist mash_sketch.msh mash_sketch.msh | square_mash > mash.tsv"
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --phenotypes /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes_filtered.txt --phenotype-column binary --vcf /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/11.SNIPPY_MULTI/merged_max5missing.vcf --distances mash.tsv > SNPGWAS_mash.txt"
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --phenotypes /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes_filtered.txt --phenotype-column binary --kmers /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/14.UNITIGS/unitigs.txt --uncompressed --output-patterns DBGWAS_mash_unitig_patterns.txt --distances mash.tsv > DBGWAS_mash.txt"
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --phenotypes /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes_filtered.txt --phenotype-column binary --pres /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --distances mash.tsv > PanGWAS_mash.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="annotate_hits_pyseer DBGWAS_mash.txt ../../../../Files/DBGWAS_references.txt DBGWAS_mash_annotation.txt"

# pop structure correction: SC
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/12.Phylogeny/12.1.FastTree_DP/15.2.Subanalysis_1/15.2.4.SC
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="sed 's/,/\t/g' /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/9.POPPUNK/GBS_GWAS_db/GBS_GWAS_db_core_clusters.csv > SC_clusters.txt"
head -1 ../../../../Files/phenotypes_filtered.txt > phenotypes_filtered_SC.txt
cat phenotypes_filtered_SC.txt >> phenotypes_filtered_SC.txt
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --phenotypes phenotypes_filtered_SC.txt --phenotype-column binary --vcf /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/11.SNIPPY_MULTI/merged_max5missing.vcf --covariates SC_clusters.txt --use-covariates 2 --no-distances > SNPGWAS_SC.txt"
sbatch -p fasse -t 7-00:00:00 --mem=50000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --phenotypes phenotypes_filtered_SC.txt --phenotype-column binary --kmers /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/14.UNITIGS/unitigs.txt --uncompressed --output-patterns DBGWAS_SC_unitig_patterns.txt --covariates SC_clusters.txt --use-covariates 2 --no-distances > DBGWAS_SC.txt"
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --phenotypes phenotypes_filtered_SC.txt --phenotype-column binary --pres /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --covariates SC_clusters.txt --use-covariates 2 --no-distances > PanGWAS_SC.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="annotate_hits_pyseer DBGWAS_SC.txt ../../../../Files/DBGWAS_references.txt DBGWAS_SC_annotation.txt"

# pop structure correction: CC
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/12.Phylogeny/12.1.FastTree_DP/15.2.Subanalysis_1/15.2.5.CC

awk 'NR>1{s[$1]=1} END{for(k in s)print k}' ../../../../Files/phenotypes_filtered.txt > IDs.txt
echo -e "Sample\tclonal_complex" > CC_clusters.txt
awk -F',' 'NR==1{next} {sub(/^cc/,"",$3); if($3!="NA") print $2 "\t" $3}' ../../../../10.ASSIGN_CC/combined_results_with_cc.txt | awk 'NR==FNR{s[$1]=1;next}($1 in s)' IDs.txt - >> CC_clusters.txt
awk 'NR>1{s[$1]=1} END{for(k in s)print k}' CC_clusters.txt > IDs2.txt
head -1 ../../../../Files/phenotypes_filtered.txt > phenotypes_filtered_CC.txt
awk 'NR==FNR{s[$1]=1;next}NR>1&&($1 in s)' IDs2.txt ../../../../Files/phenotypes_filtered.txt >> phenotypes_filtered_CC.txt

sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --phenotypes  phenotypes_filtered_CC.txt --phenotype-column binary --vcf /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/11.SNIPPY_MULTI/merged_max5missing.vcf --covariates CC_clusters.txt --use-covariates 2 --no-distances > SNPGWAS_CC.txt"
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --phenotypes  phenotypes_filtered_CC.txt --phenotype-column binary --kmers /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/14.UNITIGS/unitigs.txt --uncompressed --output-patterns DBGWAS_CC_unitig_patterns.txt --covariates CC_clusters.txt --use-covariates 2 --no-distances > DBGWAS_CC.txt"
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --phenotypes  phenotypes_filtered_CC.txt --phenotype-column binary --pres /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --covariates CC_clusters.txt --use-covariates 2 --no-distances > PanGWAS_CC.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="annotate_hits_pyseer DBGWAS_CC.txt ../../../../Files/DBGWAS_references.txt DBGWAS_CC_annotation.txt"


# SUBANALYSIS 2: PANGENOME TOOLS
## PanGWAS - Panaroo + CLARC
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --lmm --phenotypes /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes_filtered.txt --phenotype-column binary --pres /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/13.Pangenome_analysis/13.3.Panaroo_CLARC/Output/clarc_results/clarc_condensed_presence_absence.Rtab --similarity EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv > PanGWAS_PANAROO_CLARC.txt"
## PanGWAS - ROARY
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --lmm --phenotypes /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes_filtered.txt --phenotype-column binary --pres /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/13.Pangenome_analysis/13.2.ROARY/gene_presence_absence.Rtab --similarity EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv > PanGWAS_ROARY.txt"
## PanGWAS - ROARY + CLARC
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --lmm --phenotypes /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes_filtered.txt --phenotype-column binary --pres /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/13.Pangenome_analysis/13.4.ROARY_CLARC/Output/clarc_results/clarc_condensed_presence_absence.Rtab --similarity EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv > PanGWAS_ROARY_CLARC.txt"

# SUBANALYSIS 3: Continuous Phenotype
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/12.Phylogeny/12.1.FastTree_DP/15.4.Subanalysis_3
## SNPGWAS
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="pyseer --lmm --phenotypes /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes_filtered.txt --phenotype-column continuous --vcf /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/11.SNIPPY_MULTI/merged_max5missing.vcf --similarity EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv > SNPGWAS_FastTree_DP_LMM.txt"
## DBGWAS
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --lmm --phenotypes /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes_filtered.txt  --phenotype-column continuous --kmers /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/14.UNITIGS/unitigs.txt --uncompressed --similarity EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv > DBGWAS_FastTree_DP_LMM.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="annotate_hits_pyseer DBGWAS_FastTree_DP_LMM.txt ../../../Files/DBGWAS_references.txt DBGWAS_FastTree_DP_LMM_annotation.txt"
## PanGWAS
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --lmm --phenotypes /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes_filtered.txt --phenotype-column continuous --pres /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --similarity EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv > PanGWAS_FastTree_DP_LMM.txt"

# SUBANALYSIS 4: Transformed Continuous Phenotype
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/15.Pyseer/15.4.Subanalysis_transformed_cont_age
## SNPGWAS
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="pyseer --lmm --phenotypes /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes_filtered.txt --phenotype-column continuous --vcf /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/11.SNIPPY_MULTI/merged_max5missing.vcf --similarity EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv > SNPGWAS_FastTree_DP_LMM.txt"
## DBGWAS
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --lmm --phenotypes /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes_filtered.txt  --phenotype-column continuous --kmers /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/14.UNITIGS/unitigs.txt --uncompressed --similarity EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv > DBGWAS_FastTree_DP_LMM.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="annotate_hits_pyseer DBGWAS_FastTree_DP_LMM.txt ../../../Files/DBGWAS_references.txt DBGWAS_FastTree_DP_LMM_annotation.txt"
## PanGWAS
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --lmm --phenotypes /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/Files/phenotypes_filtered.txt --phenotype-column continuous --pres /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --similarity EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv > PanGWAS_FastTree_DP_LMM.txt"



sbatch -p fasse -c 8 -t 0-10:00 --mem=100000 --wrap="roary -e --mafft -p 8 ../6.ANNOTATION/*.gff -f ../13.Pangenome_analysis/13.2.ROARY"
