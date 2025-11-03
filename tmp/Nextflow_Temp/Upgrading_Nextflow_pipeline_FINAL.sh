

# FIXING SNPGWAS
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/11.SNIPPY_MULTI

## Filter and format VCFS
### decompose complex variants (mnps), Filter AF>95%, keep only SNPs
module load python
# conda create -n bcftools
source activate bcftools
# conda install bioconda::bcftools

for i in ../4.SNIPPY/SRR*; do
  sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="bcftools norm -a --atom-overlaps . $i/snps.vcf.gz | bcftools view --min-af 0.95 --types snps -o $i/snps_norm_filter.vcf.gz"
done

for i in ../4.SNIPPY/SRR*; do
  sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="tabix -p vcf $i/snps_norm_filter.vcf.gz"
done

# Merge VCFS
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="bcftools merge -m none -0 -O z ../4.SNIPPY/SRR*/snps_norm_filter.vcf.gz > merged.vcf.gz"
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="tabix -p vcf merged.vcf.gz"

## Find the position that have <5% missingness
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="bash -c 'awk '\''/^>/ {if (seq) print name \"\n\" seq; name=\$0; seq=\"\"; next} {seq=seq \$0} END{if (seq) print name \"\n\" seq}'\'' clean.full.aln | grep -v '\''^>'\'' | tail -n +2 | sed '\''s/./&\t/g; s/\t$//'\'' | awk '\''{for(i=1;i<=NF;i++) if(\$i==\"-\" || \$i==\"N\") col[i]++;n++}END {for(i=1;i<=NF;i++) printf \"%d %.5f\n\", i, (col[i]?col[i]:0)/n}'\'' > Missingness_Prop.txt'"
awk '$2 < 0.05 {print "AP018935.1\t" $1}' Missingness_Prop.txt > Keep_Pos_max5missing.txt
awk '$2 == 0 {print "AP018935.1\t" $1}' Missingness_Prop.txt > Keep_Pos_0missing.txt

# Filter only positions with <5% missingness
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="bcftools view -R Keep_Pos_max5missing.txt merged.vcf.gz > merged_max5missing.vcf"
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="bcftools view -R Keep_Pos_0missing.txt merged.vcf.gz > merged_0missing.vcf"

## Run Pyseer
module load python
source activate pyseer
# 0. Test positive control
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="pyseer --lmm --phenotypes ../Files/phenotypes_filtered.txt --vcf merged_0missing.vcf --similarity ../15.Pyseer/15.1.Main_analysis/FastTree_phylogeny_K.tsv --cpu 8 > SNPGWAS_Fasttree_LMM_0missing.txt"
# 1. Main-Analysis
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="pyseer --lmm --phenotypes ../Files/phenotypes_filtered.txt --vcf merged_max5missing.vcf --similarity ../15.Pyseer/15.1.Main_analysis/FastTree_phylogeny_K.tsv --cpu 8 > SNPGWAS_Fasttree_LMM_max5missing.txt"
# 2. SubAnalysis 1
## 2.1. FastTree FEM
sbatch -p fasse -c 8 -t 0-12:00 --mem=100000 --wrap="pyseer --phenotypes ../Files/phenotypes_filtered.txt --vcf merged_max5missing.vcf --distances ../15.Pyseer/15.2.Subanalysis_1/15.2.1.Fasttree_FEM/FastTree_phylogeny_distances.tsv --cpu 8 > ../15.Pyseer/15.2.Subanalysis_1/15.2.1.Fasttree_FEM/SNPGWAS_Fasttree_FEM_max5missing.txt"
## 2.2. Mash
sbatch -p fasse -c 8 -t 0-12:00 --mem=100000 --wrap="pyseer --phenotypes ../Files/phenotypes_filtered.txt --vcf merged_max5missing.vcf --distances ../15.Pyseer/15.2.Subanalysis_1/15.2.3.Mash/mash.tsv --cpu 8 > ../15.Pyseer/15.2.Subanalysis_1/15.2.3.Mash/SNPGWAS_mash_max5missing.txt"
## 2.3. SC
sbatch -p fasse -c 8 -t 0-12:00 --mem=100000 --wrap="pyseer --phenotypes ../Files/phenotypes_filtered_SC.txt --vcf merged_max5missing.vcf --covariates ../15.Pyseer/15.2.Subanalysis_1/15.2.4.SC/SC_clusters.txt --use-covariates 2 --no-distances --cpu 8 > ../15.Pyseer/15.2.Subanalysis_1/15.2.4.SC/SNPGWAS_SC_max5missing.txt"
# 3. SubAnalysis 3 - Continuous outcome
sbatch -p fasse -c 8 -t 0-12:00 --mem=100000 --wrap="pyseer --lmm --phenotypes ../Files/phenotypes_filtered.txt --continuous --phenotype-column continuous --vcf merged_max5missing.vcf --similarity ../15.Pyseer/15.1.Main_analysis/FastTree_phylogeny_K.tsv --cpu 8 > ../15.Pyseer/15.4.Subanalysis_3/SNPGWAS_continuous_Fasttree_max5missing.txt"


# Run DBGWAS Main analysis for CDC_EOD_LOD with  --min-af 0.05 --max-af 0.95 options
module load python
source activate pyseer
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/TEST_Fasttree
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="pyseer --lmm --phenotypes Files/phenotypes_filtered.txt --kmers 14.UNITIGS/unitigs.txt --uncompressed --similarity 15.Pyseer/15.1.Main_analysis/FastTree_phylogeny_K.tsv --output-patterns 15.Pyseer/15.1.Main_analysis/DBGWAS_RAxML_unitig_patterns_5_95.txt --cpu 8 >  15.Pyseer/15.1.Main_analysis/DBGWAS_Fasttree_LMM_5_95.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="annotate_hits_pyseer DBGWAS_Fasttree_LMM_5_95.txt ../../Files/DBGWAS_references.txt DBGWAS_Fasttree_LMM_5_95_annotation.txt"
# slurm-5869814.out
# DONE
# /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/15.Pyseer/15.1.Main_analysis/DBGWAS_Fasttree_LMM_5_95.txt


# Fix FastTree
## test with gtr+gamma
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/TEST_Fasttree/FastTree_GTR_GAMMA_SP
sbatch -p fasse -t 3-00:00:00 --mem=180000 --wrap="../Files/FastTree -nt -gtr -gamma ../11.SNIPPY_MULTI/clean.full.aln > Test_FastTree.tre"
# slurm-5887974.out - DONE
# Pyseer
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="python ../../Files/pyseer/scripts/phylogeny_distance.py --lmm Test_FastTree.tre > FastTree_GAMMA_K.tsv"
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="pyseer --lmm --phenotypes ../../Files/phenotypes_filtered.txt --phenotype-column binary --vcf ../../11.SNIPPY_MULTI/merged_max5missing.vcf --similarity FastTree_GAMMA_K.tsv --cpu 8 > SNPGWAS_FastTree_GAMMA_LMM_max5missing.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --lmm --phenotypes ../../Files/phenotypes_filtered.txt  --phenotype-column binary --kmers ../../14.UNITIGS/unitigs.txt --uncompressed --similarity FastTree_GAMMA_K.tsv > DBGWAS_FastTree_GAMMA_LMM_max5missing.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="annotate_hits_pyseer DBGWAS_FastTree_GAMMA_LMM_max5missing.txt ../../Files/DBGWAS_references.txt DBGWAS_FastTree_GAMMA_LMM_max5missing_annotation.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --lmm --phenotypes ../../Files/phenotypes_filtered.txt --phenotype-column binary --pres ../../13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --similarity FastTree_GAMMA_K.tsv > PanGWAS_FastTree_GAMMA_LMM_max5missing.txt"

## Try installing with -DUSE_DOUBLE
cd Files
curl -O http://www.microbesonline.org/fasttree/FastTree.c
gcc -DUSE_DOUBLE -O3 -finline-functions -funroll-loops -Wall -o FastTre_DUSE_DOUBLE FastTree.c -lm
chmod +x FastTre_DUSE_DOUBLE
./FastTre_DUSE_DOUBLE -h
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/TEST_Fasttree/FastTree_GTR_GAMMA_DP
sbatch -p fasse_bigmem -t 3-00:00:00 --mem=400000 --wrap="../Files/FastTre_DUSE_DOUBLE -nt -gtr -gamma ../11.SNIPPY_MULTI/clean.full.aln > Test_FastTree_DUSE_DOUBLE.tre"
# slurm-5890238.out - DONE
# Pyseer
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="python ../../Files/pyseer/scripts/phylogeny_distance.py --lmm Test_FastTree_DUSE_DOUBLE.tre > FastTree_DUSE_DOUBLE_K.tsv"
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="pyseer --lmm --phenotypes ../../Files/phenotypes_filtered.txt --phenotype-column binary --vcf ../../11.SNIPPY_MULTI/merged_max5missing.vcf --similarity FastTree_DUSE_DOUBLE_K.tsv --cpu 8 > SNPGWAS_FastTree_DUSE_DOUBLE_LMM_max5missing.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --lmm --phenotypes ../../Files/phenotypes_filtered.txt  --phenotype-column binary --kmers ../../14.UNITIGS/unitigs.txt --uncompressed --similarity FastTree_DUSE_DOUBLE_K.tsv > DBGWAS_FastTree_DUSE_DOUBLE_LMM_max5missing.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="annotate_hits_pyseer DBGWAS_FastTree_DUSE_DOUBLE_LMM_max5missing.txt ../../Files/DBGWAS_references.txt DBGWAS_FastTree_DUSE_DOUBLE_LMM_max5missing_annotation.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --lmm --phenotypes ../../Files/phenotypes_filtered.txt --phenotype-column binary --pres ../../13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --similarity FastTree_DUSE_DOUBLE_K.tsv > PanGWAS_FastTree_DUSE_DOUBLE_LMM_max5missing.txt"

# MAke FastTree Double Precision for EOD vs (LOD+VLOD)
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/TEST_Fasttree
curl -O http://www.microbesonline.org/fasttree/FastTree.c
gcc -DUSE_DOUBLE -O3 -finline-functions -funroll-loops -Wall -o FastTre_DUSE_DOUBLE FastTree.c -lm
chmod +x FastTre_DUSE_DOUBLE
./FastTre_DUSE_DOUBLE -h
sbatch -p fasse_bigmem -t 3-00:00:00 --mem=400000 --wrap="./FastTre_DUSE_DOUBLE -nt -gtr -gamma ../11.SNIPPY_MULTI/clean.full.aln > EOD_LOD_VLOD_CDC_FastTree_DP.tre"
# slurm-5915339.out
# generate SNP Files
module load python
source activate bcftools
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/11.SNIPPY_MULTI
for i in ../4.SNIPPY/SRR*; do
  sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="bcftools norm -a --atom-overlaps . $i/snps.vcf.gz | bcftools view --min-af 0.95 --types snps -o $i/snps_norm_filter.vcf.gz"
done
for i in ../4.SNIPPY/SRR*; do
  sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="tabix -p vcf $i/snps_norm_filter.vcf.gz"
done
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="bcftools merge -m none -0 -O z ../4.SNIPPY/SRR*/snps_norm_filter.vcf.gz > merged.vcf.gz"
## Find the position that have <5% missingness
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="bash -c 'awk '\''/^>/ {if (seq) print name \"\n\" seq; name=\$0; seq=\"\"; next} {seq=seq \$0} END{if (seq) print name \"\n\" seq}'\'' clean.full.aln | grep -v '\''^>'\'' | tail -n +2 | sed '\''s/./&\t/g; s/\t$//'\'' | awk '\''{for(i=1;i<=NF;i++) if(\$i==\"-\" || \$i==\"N\") col[i]++;n++}END {for(i=1;i<=NF;i++) printf \"%d %.5f\n\", i, (col[i]?col[i]:0)/n}'\'' > Missingness_Prop.txt'"
awk '$2 < 0.05 {print "AP018935.1\t" $1}' Missingness_Prop.txt > Keep_Pos_max5missing.txt
# Filter only positions with <5% missingness
zcat merged.vcf.gz | awk 'BEGIN { while ((getline < "Keep_Pos_max5missing.txt") > 0) s[$1":"$2]=1 } /^#/ {print; next} (s[$1":"$2])' > merged_max5missing.vcf
# Pyseer
# MAIN ANALYSIS
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/TEST_Fasttree
module load python
source activate pyseer
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="python ../Files/pyseer/scripts/phylogeny_distance.py --lmm EOD_LOD_VLOD_CDC_FastTree_DP.tre > EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv"
## GWAS
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="pyseer --lmm --phenotypes ../Files/phenotypes_filtered.txt --phenotype-column binary --vcf ../11.SNIPPY_MULTI/merged_max5missing.vcf --similarity EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv > SNPGWAS_FastTree_DP_LMM.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --lmm --phenotypes ../Files/phenotypes_filtered.txt  --phenotype-column binary --kmers ../14.UNITIGS/unitigs.txt --uncompressed --similarity EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv > DBGWAS_FastTree_DP_LMM.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="annotate_hits_pyseer DBGWAS_FastTree_DP_LMM.txt ../Files/DBGWAS_references.txt DBGWAS_FastTree_DP_LMM_annotation.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --lmm --phenotypes ../Files/phenotypes_filtered.txt --phenotype-column binary --pres ../13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --similarity EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv > PanGWAS_FastTree_DP_LMM.txt"


# Test RAxML outside of Pipeline
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/TEST_RAxML
module load python
source activate raxml-ng
## Determine optimal number of threads
sbatch -p fasse -t 0-10:00:00 --mem=50000 --wrap="raxml-ng --parse --msa ../11.SNIPPY_MULTI/clean.full.aln --model GTR+G"
# slurm-5887981.out
# oof it sais 189
## Check how many were needed in the preliminary analysis
sbatch -p hsph -t 0-10:00:00 --mem=50000 --wrap="raxml-ng --parse --msa clean.full.aln --model GTR+G"

## RAxML_MLsearch
sbatch -p fasse_bigmem -c 64 -t 7-00:00:00 --mem=400000 --wrap="raxml-ng --msa ../11.SNIPPY_MULTI/clean.full.aln --model GTR+G --threads 64 --seed 12345 --prefix fullaln_T1"
# slurm-5920004.out - RUNNING
## RAxML_bootstrap
sbatch -p fasse -t 3-00:00:00 --mem=100000 --wrap="raxml-ng --bootstrap --msa ../11.SNIPPY_MULTI/clean.full.aln --model GTR+G --threads 64 --seed 12345 --prefix fullaln_T2"
## RAxML_bipartition
sbatch -p fasse -t 3-00:00:00 --mem=100000 --wrap="raxml-ng --support --tree T1.raxml.bestTree --bs-trees T2.raxml.bootstraps --threads 64 --prefix fullaln_T3"


## Determine optimal number of threads
sbatch -p fasse -t 0-10:00:00 --mem=50000 --wrap="raxml-ng --parse --msa ../11.SNIPPY_MULTI/core.aln --model GTR+G"
# slurm-5887982.out
## Get number of invariant sites for Felsenstein correction:
awk '/^>/ {if(s){print length(s); exit} } {if(!/^>/) s=s $0} END{if(s) print length(s)}' core.full.aln
# 2231314
awk '/^>/ {if(s){print length(s); exit} } {if(!/^>/) s=s $0} END{if(s) print length(s)}' core.aln
# 634
# 2231314 - 634 = 2230680
## RAxML_MLsearch
sbatch -p fasse -c 2 -t 3-00:00:00 --mem=100000 --wrap="raxml-ng --msa ../11.SNIPPY_MULTI/core.aln --model GTR+G+ASC_FELS{2230680} --threads 2 --seed 12345 --prefix core_T1"
# slurm-5887983.out - DONE
## RAxML_bootstrap
sbatch -p fasse -c 2 -t 3-00:00:00 --mem=100000 --wrap="raxml-ng --bootstrap --msa ../11.SNIPPY_MULTI/core.aln --model GTR+G+ASC_FELS{2230680} --threads 2  --seed 12345 --prefix core_T2"
# slurm-5887984.out - DONE
## RAxML_bipartition
sbatch -p fasse -c 2 -t 3-00:00:00 --mem=100000 --wrap="raxml-ng --support --tree T1.raxml.bestTree --bs-trees T2.raxml.bootstraps --threads auto{48} --prefix core_T3"
# Pyseer
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="python ../Files/pyseer/scripts/phylogeny_distance.py --lmm core_T1.raxml.bestTree > core_raxml_K.tsv"
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="pyseer --lmm --phenotypes ../Files/phenotypes_filtered.txt --phenotype-column binary --vcf ../11.SNIPPY_MULTI/merged_max5missing.vcf --similarity core_raxml_K.tsv > SNPGWAS_core_raxml_LMM_max5missing.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --lmm --phenotypes ../Files/phenotypes_filtered.txt  --phenotype-column binary --kmers ../14.UNITIGS/unitigs.txt --uncompressed --similarity core_raxml_K.tsv > DBGWAS_core_raxml_LMM_max5missing.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="annotate_hits_pyseer DBGWAS_core_raxml_LMM_max5missing.txt ../Files/DBGWAS_references.txt DBGWAS_core_raxml_LMM_max5missing_annotation.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --lmm --phenotypes ../Files/phenotypes_filtered.txt --phenotype-column binary --pres ../13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --similarity core_raxml_K.tsv > PanGWAS_core_raxml_LMM_max5missing.txt"


# Run Main analysis for CDC_EOD_LOD with IQTREE population correction
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/TEST_IQTree
cp /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Iqtree_CDC_EOD_LOD/core_tree.treefile ./
module load python
source activate pyseer
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="python ../Files/pyseer/scripts/phylogeny_distance.py --lmm core_tree.treefile > IQTree_phylogeny_K.tsv"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --lmm --phenotypes ../Files/phenotypes_filtered.txt --phenotype-column binary --vcf ../11.SNIPPY_MULTI/merged_max5missing.vcf --uncompressed --similarity IQTree_phylogeny_K.tsv --output-patterns DBGWAS_RAxML_unitig_patterns.txt > SNPGWAS_IQtree_core_LMM.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --lmm --phenotypes ../Files/phenotypes_filtered.txt --phenotype-column binary --kmers ../14.UNITIGS/unitigs.txt --uncompressed --similarity IQTree_phylogeny_K.tsv --output-patterns DBGWAS_IQTree_unitig_patterns.txt > DBGWAS_IQtree_core_LMM.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --lmm --phenotypes ../Files/phenotypes_filtered.txt --phenotype-column binary --pres ../13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --similarity IQTree_phylogeny_K.tsv > PanGWAS_Panaroo_IQtree_core_LMM.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="annotate_hits_pyseer DBGWAS_IQtree_core_LMM.txt ../../Files/DBGWAS_references.txt DBGWAS_IQtree_core_LMM_annotation.txt"
# DONE



# CC population structure-correction
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/TEST_CC_pop_correction
awk -F',' 'NR==1 {print "Taxon\tclonal_complex"; next} {sub(/^cc/, "", $3); if ($3 != "NA") print $2 "\t" $3 }' ../10.ASSIGN_CC/combined_results_with_cc.txt > CC_clusters.txt
head -1 ../Files/phenotypes_filtered.txt > phenotypes_filtered_CC.txt
awk 'NR==FNR { if (NR>1) s[$1]=1; next } NR==1 || $1 in s' CC_clusters.txt ../Files/phenotypes_filtered.txt >> phenotypes_filtered_CC.txt
awk 'NR==FNR { if (NR>1) s[$1]=1; next } NR==1 || $1 in s' ../Files/phenotypes_filtered.txt CC_clusters.txt > CC_clusters_filtered.txt
module load python
source activate pyseer
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --phenotypes phenotypes_filtered_CC.txt --phenotype-column binary --vcf ../11.SNIPPY_MULTI/merged_max5missing.vcf --covariates CC_clusters_filtered.txt --use-covariates 2 --no-distances > SNPGWAS_CC_max5missing.txt"

# 1. Filter CCs by phenotype
awk 'NR>1{s[$1]=1} END{for(k in s)print k}' ../Files/phenotypes_filtered.txt > IDs.txt
echo -e "Sample\tclonal_complex" > CC_clusters.txt
awk -F',' 'NR==1{next} {sub(/^cc/,"",$3); if($3!="NA") print $2 "\t" $3}' ../10.ASSIGN_CC/combined_results_with_cc.txt | awk 'NR==FNR{s[$1]=1;next}($1 in s)' IDs.txt - >> CC_clusters.txt

# 2. Now, filter phenos by new CC_clusters
awk 'NR>1{s[$1]=1} END{for(k in s)print k}' CC_clusters.txt > IDs2.txt
head -1 ../Files/phenotypes_filtered.txt > phenotypes_filtered_CC.txt
awk 'NR==FNR{s[$1]=1;next}NR>1&&($1 in s)' IDs2.txt ../Files/phenotypes_filtered.txt >> phenotypes_filtered_CC.txt
module load python
source activate pyseer
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --phenotypes phenotypes_filtered_CC.txt --phenotype-column binary --vcf ../11.SNIPPY_MULTI/merged_max5missing.vcf --covariates CC_clusters.txt --use-covariates 2 --no-distances > SNPGWAS_CC_max5missing.txt"

sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --phenotypes phenotypes_filtered_SC.txt --phenotype-column binary --vcf ../11.SNIPPY_MULTI/merged_max5missing.vcf --covariates ../15.Pyseer/15.2.Subanalysis_1/15.2.4.SC/SC_clusters.txt --use-covariates 2 --no-distances > SNPGWAS_SC_max5missing.txt"


head -1 ../Files/phenotypes_filtered.txt > phenotypes_filtered_SC.txt
cat ../Files/phenotypes_filtered_SC.txt >> phenotypes_filtered_SC.txt


# Run SnpEff
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/TEST_SnpEff
module load python
# conda create -n snpeff
source activate snpeff
# conda install bioconda::snpeff
snpEff -h

sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="snpEff -nodownload -c ../Files/snpEff.config -v AP018935.1 ../4.SNIPPY/SRR29475941/snps.vcf | gzip -c > test2.ann.vcf.gz"
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="snpEff -nodownload -c ../Files/snpEff.config -v AP018935.1 ../4.SNIPPY/SRR29475941/snps_norm_filter.vcf.gz | gzip -c > test3.ann.vcf.gz"




# Run pipeline with NL-opnly data
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_NL/scripts
module load python
source activate java
sbatch -p fasse -c 48 -t 7-00:00:00 --mem=180000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline.nf --main --sub1 --sub2 --path_nextflow_dir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_NL --path_conda_envs /n/home_fasse/lcavalli/.conda/envs"
sbatch -p fasse -c 48 -t 7-00:00:00 --mem=180000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline.nf -resume --main --sub1 --sub2 --path_nextflow_dir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_NL --path_conda_envs /n/home_fasse/lcavalli/.conda/envs"

module load python
source activate roary
sbatch -p fasse -c 16 -t 7-00:00:00 --mem=100000 --wrap="roary -e --mafft -p 16 ../6.ANNOTATION/*.gff -f ../13.Pangenome_analysis/13.2.ROARY"


# Run pipeline with CDC-only data
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/scripts
module load python
source activate java
sbatch -p fasse -c 48 -t 7-00:00:00 --mem=180000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline.nf --main --sub1 --sub2 --path_nextflow_dir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC --path_conda_envs /n/home_fasse/lcavalli/.conda/envs"

# Run with different EOD/LOD thresholds
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/15.Pyseer/15.5.EOD_LOD_Threshold
module load python
source activate pyseer
## phenotypes_EOD_lt14
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="pyseer --lmm --phenotypes phenotypes_EOD_lt14.txt --phenotype-column binary --vcf ../../11.SNIPPY_MULTI/merged_max5missing.vcf --similarity ../../12.Phylogeny/12.1.FastTree_DP/EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv > SNPGWAS_FastTree_DP_LMM_lt14.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --lmm --phenotypes phenotypes_EOD_lt14.txt  --phenotype-column binary --kmers ../../14.UNITIGS/unitigs.txt --uncompressed --similarity ../../12.Phylogeny/12.1.FastTree_DP/EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv > DBGWAS_FastTree_DP_LMM_lt14.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --lmm --phenotypes phenotypes_EOD_lt14.txt --phenotype-column binary --pres ../../13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --similarity ../../12.Phylogeny/12.1.FastTree_DP/EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv > PanGWAS_FastTree_DP_LMM_lt14.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="annotate_hits_pyseer DBGWAS_FastTree_DP_LMM_lt14.txt ../../Files/DBGWAS_references.txt DBGWAS_FastTree_DP_LMM_annotation_lt14.txt"
## phenotypes_EOD_lt30
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="pyseer --lmm --phenotypes phenotypes_EOD_lt30.txt --phenotype-column binary --vcf ../../11.SNIPPY_MULTI/merged_max5missing.vcf --similarity ../../12.Phylogeny/12.1.FastTree_DP/EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv > SNPGWAS_FastTree_DP_LMM_lt30.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --lmm --phenotypes phenotypes_EOD_lt30.txt  --phenotype-column binary --kmers ../../14.UNITIGS/unitigs.txt --uncompressed --similarity ../../12.Phylogeny/12.1.FastTree_DP/EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv > DBGWAS_FastTree_DP_LMM_lt30.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --lmm --phenotypes phenotypes_EOD_lt30.txt --phenotype-column binary --pres ../../13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --similarity ../../12.Phylogeny/12.1.FastTree_DP/EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv > PanGWAS_FastTree_DP_LMM_lt30.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="annotate_hits_pyseer DBGWAS_FastTree_DP_LMM_lt30.txt ../../Files/DBGWAS_references.txt DBGWAS_FastTree_DP_LMM_annotation_lt30.txt"
## phenotypes_EOD_lt60
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="pyseer --lmm --phenotypes phenotypes_EOD_lt60.txt --phenotype-column binary --vcf ../../11.SNIPPY_MULTI/merged_max5missing.vcf --similarity ../../12.Phylogeny/12.1.FastTree_DP/EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv > SNPGWAS_FastTree_DP_LMM_lt60.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --lmm --phenotypes phenotypes_EOD_lt60.txt  --phenotype-column binary --kmers ../../14.UNITIGS/unitigs.txt --uncompressed --similarity ../../12.Phylogeny/12.1.FastTree_DP/EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv > DBGWAS_FastTree_DP_LMM_lt60.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --lmm --phenotypes phenotypes_EOD_lt60.txt --phenotype-column binary --pres ../../13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --similarity ../../12.Phylogeny/12.1.FastTree_DP/EOD_LOD_VLOD_CDC_FastTree_DP_K.tsv > PanGWAS_FastTree_DP_LMM_lt60.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="annotate_hits_pyseer DBGWAS_FastTree_DP_LMM_lt60.txt ../../Files/DBGWAS_references.txt DBGWAS_FastTree_DP_LMM_annotation_lt60.txt"



# Run pipeline with CDC-only data
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL_TW/scripts
module load python
source activate java
sbatch -p fasse -c 48 -t 7-00:00:00 --mem=180000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline.nf --main --path_nextflow_dir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL_TW --path_conda_envs /n/home_fasse/lcavalli/.conda/envs"
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline.nf -resume --main --path_nextflow_dir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL_TW --path_conda_envs /n/home_fasse/lcavalli/.conda/envs"
#6217858
sbatch -p fasse_bigmem -t 7-00:00:00 --mem=490000 --wrap=" /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL_TW/Files/FastTree_DUSE_DOUBLE -gtr -gamma -nt /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL_TW/11.SNIPPY_MULTI/clean.full.aln > /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC_NL_TW/12.Phylogeny/12.2.FastTree/FastTree_phylo.tre"
# 6217856



# Remove recombination
module load python
# conda create -n gubbins
source activate gubbins
#conda config --add channels r
#conda config --add channels defaults
#conda config --add channels conda-forge
#conda config --add channels bioconda
#conda install gubbins
gubbins -h

cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/11.SNIPPY_MULTI
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix gubbins_out --threads 48 --starting-tree ../12.Phylogeny/12.1.FastTree_DP/EOD_LOD_VLOD_CDC_FastTree_DP.tre --model GTRGAMMA clean.full.aln"
# slurm-6217863.out

# Full alignment
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/Fulltree_Gubbins
../seqtk/seqtk subseq ../../11.SNIPPY_MULTI/clean.full.aln Full_samples.txt > Full.fasta
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/Fulltree_Gubbins/gubbins_fulltree_out --threads 48 --starting-tree /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/12.Phylogeny/12.1.FastTree_DP/EOD_LOD_VLOD_CDC_FastTree_DP.tre --model GTRGAMMA Full.fasta"

# Need to subset to each major SC ?
## SC1
cd
../seqtk/seqtk subseq ../../11.SNIPPY_MULTI/clean.full.aln SC1_Samples.txt > SC1.fasta
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC1_Gubbins/gubbins_SC1_out --threads 48 --model GTRGAMMA /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/11.SNIPPY_MULTI/clean.full.aln"

Ok also, I have regenarate the plots for the branchwater and pushed to github. They are in . But I am missing the strainGST results for one sample : SRR17284135. I also could not find it in /n/holylabs/LABS/hanage_lab/Lab/rbalasubramanian/GI_Vaginal/Sourmash_Strainge. Although I do have its relative abundance so we presumably did run metaphlan on it, bur perhaps not strainGE ?... I believe this may be a sample we had previously excluded but are now including after your recategorization of body site of isolation... Could you let me know if you find strainGST
