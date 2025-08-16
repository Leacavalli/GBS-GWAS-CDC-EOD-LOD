

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







# Fix FastTree
## test with gtr+gamma
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="Files/FastTree -gtr -gamma -nt 11.SNIPPY_MULTI/clean.full.aln > Test_FastTree.tre"
sbatch -p fasse -t 3-00:00:00 --mem=180000 --wrap="Files/FastTree -nt -gtr -gamma 11.SNIPPY_MULTI/clean.full.aln > Test_FastTree.tre"
# slurm-5887974.out

## Try installing with -DUSE_DOUBLE
cd Files
curl -O http://www.microbesonline.org/fasttree/FastTree.c
gcc -DUSE_DOUBLE -O3 -finline-functions -funroll-loops -Wall -o FastTre_DUSE_DOUBLE FastTree.c -lm
chmod +x FastTre_DUSE_DOUBLE
./FastTre_DUSE_DOUBLE -h
cd ../
sbatch -p fasse_bigmem -t 3-00:00:00 --mem=400000 --wrap="Files/FastTre_DUSE_DOUBLE -nt -gtr -gamma 11.SNIPPY_MULTI/clean.full.aln > Test_FastTree_DUSE_DOUBLE.tre"
# slurm-5890238.out




# Run Main analysis for CDC_EOD_LOD with IQTREE population correction
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/TEST_IQTree
cp /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Iqtree_CDC_EOD_LOD/core_tree.treefile ./
module load python
source activate pyseer
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="python ../Files/pyseer/scripts/phylogeny_distance.py --lmm core_tree.treefile > IQTree_phylogeny_K.tsv"
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="pyseer --lmm --phenotypes ../Files/phenotypes_filtered.txt --kmers ../14.UNITIGS/unitigs.txt --uncompressed --similarity IQTree_phylogeny_K.tsv --output-patterns DBGWAS_RAxML_unitig_patterns.txt --cpu 8 > DBGWAS_IQtree_LMM.txt"
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --lmm --phenotypes ../Files/phenotypes_filtered.txt --pres ../13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --similarity IQTree_phylogeny_K.tsv --cpu 8 > PanGWAS_Panaroo_IQtree_LMM.txt"
sbatch -p fasse -c 1 -t 1-00:00:00 --mem=50000 --wrap="annotate_hits_pyseer DBGWAS_IQtree_LMM.txt ../../Files/DBGWAS_references.txt DBGWAS_IQtree_LMM_annotation.txt"
# DONE



# Run DBGWAS Main analysis for CDC_EOD_LOD with  --min-af 0.05 --max-af 0.95 options
module load python
source activate pyseer
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="pyseer --lmm --phenotypes Files/phenotypes_filtered.txt --kmers 14.UNITIGS/unitigs.txt --uncompressed --similarity 15.Pyseer/15.1.Main_analysis/FastTree_phylogeny_K.tsv --output-patterns 15.Pyseer/15.1.Main_analysis/DBGWAS_RAxML_unitig_patterns_5_95.txt --cpu 8 >  15.Pyseer/15.1.Main_analysis/DBGWAS_Fasttree_LMM_5_95.txt"
sbatch -p fasse -c 1 -t 1-00:00:00 --mem=50000 --wrap="annotate_hits_pyseer DBGWAS_Fasttree_LMM_5_95.txt ../../Files/DBGWAS_references.txt DBGWAS_Fasttree_LMM_5_95_annotation.txt"
# slurm-5869814.out
# DONE
# /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/15.Pyseer/15.1.Main_analysis/DBGWAS_Fasttree_LMM_5_95.txt



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
# slurm-5887985.out
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
# slurm-5887983.out
## RAxML_bootstrap
sbatch -p fasse -c 2 -t 3-00:00:00 --mem=100000 --wrap="raxml-ng --bootstrap --msa ../11.SNIPPY_MULTI/core.aln --model GTR+G+ASC_FELS{2230680} --threads 2  --seed 12345 --prefix core_T2"
# slurm-5887984.out
## RAxML_bipartition
sbatch -p fasse -c 2 -t 3-00:00:00 --mem=100000 --wrap="raxml-ng --support --tree T1.raxml.bestTree --bs-trees T2.raxml.bootstraps --threads auto{48} --prefix core_T3"



awk '(NR == 1) || (FNR > 1)' *__genes__GBS-SBG__results.txt | head >
cut -f1,2 ${params.path_nextflow_dir}/3.SEROTYPE_MLST/combined_results.txt | tail -n +2 | sed 's/\t/,/g' | sort -t',' -k2,2 | sed  's/\\*//g'  > ${params.path_nextflow_dir}/10.ASSIGN_CC/STs.txt
