
Main analysis: RAxML
1.1 SNPGWAS + RAxML
1.2 DBGWAS + RAxML
1.3 PANGWAS + RAxML + Panaroo

Subanalysis analysis: Other population structure correction techniques
2.1.1 SNPGWAS + Fasttree
2.1.2 DBGWAS + Fasttree
2.1.3 PANGWAS + Fasttree + Panaroo
2.2.1 SNPGWAS + Mash
2.2.2 DBGWAS + Mash
2.2.3 PANGWAS + Mash + Panaroo
2.3.1 SNPGWAS + SCs
2.3.2 DBGWAS + SCs
2.3.3 PANGWAS + SCs + Panaroo

Subanalysis analysis: Other pangenome tools
3.1.1 PANGWAS + RAxML + Roary
3.1.2 PANGWAS + RAxML + Panaroo + CLARC
3.1.3 PANGWAS + RAxML + Roary + CLARC


module load python
source activate pyseer
path_nextflow_dir="/n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_test"

# Make fake phenotype file
for i in ${params.path_nextflow_dir}/*.ASSEMBLIES/*.fasta
do
  base=$(echo "$i" | cut -d '/' -f9-9 | cut -d '.' -f1)
  pheno=$((RANDOM % 2))
  echo -e "$base\t$pheno"
done > ${params.path_nextflow_dir}/Files/phenotypes.txt

# 1     Main analysis:
mkdir ${params.path_nextflow_dir}/16.Pyseer
mkdir ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis
# 1.0 Make distance matrix from phylo - RAxML
sbatch -p test -t 0-01:00 --mem=40000 --wrap="python ${params.path_nextflow_dir}/Files/pyseer/scripts/phylogeny_distance.py --lmm ${params.path_nextflow_dir}/13.Phylogeny/13.1.RAxML/RAxML_bestTree.GBS_GWAS > ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/RAxML_phylogeny_K.tsv"
# 1.1   SNPGWAS + Population structure correction with RAxML phylo
sbatch -p test -t 0-02:00 --mem=50000 --wrap="pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --vcf ${params.path_nextflow_dir}/11.SNIPPY_MULTI/core.vcf --similarity ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/RAxML_phylogeny_K.tsv --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/SNPGWAS_RAxML.txt"
# 1.2   DBGWAS + Population structure correction with RAxML phylo
sbatch -p test -t 0-02:00 --mem=50000 --wrap="pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --kmers ${params.path_nextflow_dir}/15.UNITIGS/unitigs.txt --uncompressed --similarity ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/RAxML_phylogeny_K.tsv --output-patterns ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/DBGWAS_RAxML_unitig_patterns.txt --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/DBGWAS_RAxML.txt"
# 1.3   PANGWAS + Population structure correction with RAxML phylo
sbatch -p test -t 0-02:00 --mem=50000 --wrap="pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --pres ${params.path_nextflow_dir}/14.Pangenome_analysis/14.1.Panaroo/gene_presence_absence.Rtab --similarity ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/RAxML_phylogeny_K.tsv --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/PanGWAS_Panaroo_RAxML.txt"

# 2     Subanalysis analysis: Other population structure correction techniques
mkdir ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1
# 2.1   Population structure correction with phylo (FASTTREE)
mkdir ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.1.Fasttree
# 2.1.0 Make distance matrix from phylo - fasttree
sbatch -p test -t 0-01:00 --mem=40000 --wrap="python ${params.path_nextflow_dir}/Files/pyseer/scripts/phylogeny_distance.py --lmm ${params.path_nextflow_dir}/13.Phylogeny/13.2.FastTree/GBS_GWAS_FastTree_phylo.tre > ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.1.Fasttree/FastTree_phylogeny_K.tsv"
# 2.1.1 SNPGWAS
sbatch -p test -t 0-02:00 --mem=50000 --wrap="pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --vcf ${params.path_nextflow_dir}/11.SNIPPY_MULTI/core.vcf --similarity ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.1.Fasttree/FastTree_phylogeny_K.tsv --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.1.Fasttree/SNPGWAS_Fasttree.txt"
# 2.1.2 DBGWAS
sbatch -p test -t 0-02:00 --mem=50000 --wrap="pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --kmers ${params.path_nextflow_dir}/15.UNITIGS/unitigs.txt --uncompressed --similarity ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.1.Fasttree/FastTree_phylogeny_K.tsv --output-patterns ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.1.Fasttree/DBGWAS_Fasttree_unitig_patterns.txt --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.1.Fasttree/DBGWAS_Fasttree.txt"
# 2.1.3 PANGWAS (PANAROO)
sbatch -p test -t 0-02:00 --mem=50000 --wrap="pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --pres ${params.path_nextflow_dir}/14.Pangenome_analysis/14.1.Panaroo/gene_presence_absence.Rtab --similarity ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.1.Fasttree/FastTree_phylogeny_K.tsv --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.1.Fasttree/PanGWAS_Panaroo_phylo_Fasttree.txt"

# 2.2.  Population structure correction with mash distances
mkdir ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.2.Mash
# 2.2.0 Create mash sketches + Calculate pairwise distance
sbatch -p test -t 0-01:00 --mem=40000 --wrap="mash sketch -s 10000 -o ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.2.Mash/mash_sketch ${params.path_nextflow_dir}/5.ASSEMBLIES/*.fasta"
sbatch -p test -t 0-01:00 --mem=40000 --wrap="mash dist ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.2.Mash/mash_sketch.msh ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.2.Mash/mash_sketch.msh  | square_mash > ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.2.Mash/mash.tsv"
# 2.2.1 SNPGWAS
sbatch -p test -t 0-02:00 --mem=50000 --wrap="pyseer --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --vcf ${params.path_nextflow_dir}/11.SNIPPY_MULTI/core.vcf --distances ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.2.Mash/mash.tsv --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.2.Mash/SNPGWAS_mash.txt"
# 2.2.2 DBGWAS
sbatch -p test -t 0-02:00 --mem=50000 --wrap="pyseer --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --kmers ${params.path_nextflow_dir}/15.UNITIGS/unitigs.txt --uncompressed --output-patterns ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.2.Mash/DBGWAS_mash_unitig_patterns.txt --distances ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.2.Mash/mash.tsv --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.2.Mash/DBGWAS_mash.txt"
# 2.2.3 PANGWAS (PANAROO)
sbatch -p test -t 0-02:00 --mem=50000 --wrap="pyseer --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --pres ${params.path_nextflow_dir}/14.Pangenome_analysis/14.1.Panaroo/gene_presence_absence.Rtab --distances ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.2.Mash/mash.tsv --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.2.Mash/PanGWAS_Panaroo_mash.txt"

# 2.3   Population structure correction with SC classification
mkdir ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.3.SC
# 2.3.0 Create covariate input file
sbatch -p test -t 0-01:00 --mem=40000 --wrap="sed 's/,/\t/g' ${params.path_nextflow_dir}/9.POPPUNK/GBS_GWAS_db/GBS_GWAS_db_clusters.csv > ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.3.SC/SC_clusters.txt"
# 2.3.1 SNPGWAS
sbatch -p test -t 0-02:00 --mem=50000 --wrap="pyseer --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --vcf ${params.path_nextflow_dir}/11.SNIPPY_MULTI/core.vcf --covariates ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.3.SC/SC_clusters.txt --use-covariates 2 --no-distances --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.3.SC/SNPGWAS_SC.txt"
# 2.3.2 DBGWAS
sbatch -p test -t 0-02:00 --mem=50000 --wrap="pyseer --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --kmers ${params.path_nextflow_dir}/15.UNITIGS/unitigs.txt --uncompressed --output-patterns ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.3.SC/DBGWAS_SC_unitig_patterns.txt --covariates ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.3.SC/SC_clusters.txt --use-covariates 2 --no-distances --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.3.SC/DBGWAS_SC.txt"
# 2.3.3 PANGWAS (PANAROO)
sbatch -p test -t 0-02:00 --mem=50000 --wrap="pyseer --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --pres ${params.path_nextflow_dir}/14.Pangenome_analysis/14.1.Panaroo/gene_presence_absence.Rtab --covariates ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.3.SC/SC_clusters.txt --use-covariates 2 --no-distances --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.3.SC/PanGWAS_Panaroo_SC.txt"

# 3. Subanalysis analysis: Other pangenome tools
mkdir ${params.path_nextflow_dir}/16.Pyseer/16.3.Subanalysis_2
# 3.1. PANGWAS w/ roary
mkdir ${params.path_nextflow_dir}/16.Pyseer/16.3.Subanalysis_2/16.3.1.Roary
sbatch -p test -t 0-02:00 --mem=50000 --wrap="pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --pres ${params.path_nextflow_dir}/14.Pangenome_analysis/14.2.ROARY/gene_presence_absence.Rtab --similarity ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/RAxML_phylogeny_K.tsv --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.3.Subanalysis_2/16.3.1.Roary/PanGWAS_Roary_RAxML.txt"
# 3.2. PANGWAS w/ Panaroo + CLARC
mkdir ${params.path_nextflow_dir}/16.Pyseer/16.3.Subanalysis_2/16.3.2.Panaroo_CLARC
awk 'BEGIN {FS=OFS=","} NR==1 {$1="Gene" $1} 1' ${params.path_nextflow_dir}/14.Pangenome_analysis/14.3.Panaroo_CLARC/Output/clarc_results/clarc_condensed_presence_absence.csv | awk '
{
    for (i=1; i<=NF; i++)  {
        a[NR,i] = $i
    }
}
NF>p { p = NF }
END {
    for (i=1; i<=p; i++) {
        for (j=1; j<=NR; j++) {
            printf "%s%s", a[j,i], (j==NR ? "\n" : "\t")
        }
    }
}
' FS=',' OFS='\t' > ${params.path_nextflow_dir}/14.Pangenome_analysis/14.3.Panaroo_CLARC/Output/clarc_results/clarc_condensed_presence_absence.Rtab

sbatch -p test -t 0-02:00 --mem=50000 --wrap="pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --pres ${params.path_nextflow_dir}/14.Pangenome_analysis/14.3.Panaroo_CLARC/Output/clarc_results/clarc_condensed_presence_absence.Rtab --similarity ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/RAxML_phylogeny_K.tsv --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.3.Subanalysis_2/16.3.2.Panaroo_CLARC/PanGWAS_Panaroo_CLARC_RAxML.txt"
# 3.3. PANGWAS w/ roary + CLARC
mkdir ${params.path_nextflow_dir}/16.Pyseer/16.3.Subanalysis_2/16.3.3.Roary_CLARC
awk 'BEGIN {FS=OFS=","} NR==1 {$1="Gene" $1} 1'  ${params.path_nextflow_dir}/14.Pangenome_analysis/14.4.ROARY_CLARC/Output/clarc_results/clarc_condensed_presence_absence.csv | awk '
{
    for (i=1; i<=NF; i++)  {
        a[NR,i] = $i
    }
}
NF>p { p = NF }
END {
    for (i=1; i<=p; i++) {
        for (j=1; j<=NR; j++) {
            printf "%s%s", a[j,i], (j==NR ? "\n" : "\t")
        }
    }
}
' FS=',' OFS='\t' > ${params.path_nextflow_dir}/14.Pangenome_analysis/14.4.ROARY_CLARC/Output/clarc_results/clarc_condensed_presence_absence.Rtab

awk 'BEGIN {FS=OFS=","} NR==1 {\$1="Gene" \$1} 1' ${params.path_nextflow_dir}/14.Pangenome_analysis/14.4.ROARY_CLARC/Output/clarc_results/clarc_condensed_presence_absence.csv | awk '
    {
        for (i=1; i<=NF; i++)  {
            a[NR,i] = \$i
        }
    }
    NF>p { p = NF }
    END {
        for (i=1; i<=p; i++) {
            for (j=1; j<=NR; j++) {
                printf "%s%s", a[j,i], (j==NR ? "\\n" : "\\t")
            }
        }
    }
    ' FS=',' OFS='\\t' > ${params.path_nextflow_dir}/14.Pangenome_analysis/14.4.ROARY_CLARC/Output/clarc_results/clarc_condensed_presence_absence.Rtab

sbatch -p test -t 0-02:00 --mem=50000 --wrap="pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --pres ${params.path_nextflow_dir}/14.Pangenome_analysis/14.4.ROARY_CLARC/Output/clarc_results/clarc_condensed_presence_absence.Rtab --similarity ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/RAxML_phylogeny_K.tsv --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.3.Subanalysis_2/16.3.3.Roary_CLARC/PanGWAS_Roary_CLARC_RAxML.txt"




# 1     Main analysis:
mkdir ${params.path_nextflow_dir}/16.Pyseer
mkdir ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis
# 1.0 Make distance matrix from phylo - RAxML
sbatch -p test -t 0-01:00 --mem=40000 --wrap="python ${params.path_nextflow_dir}/Files/pyseer/scripts/phylogeny_distance.py --lmm ${params.path_nextflow_dir}/13.Phylogeny/13.1.RAxML/RAxML_bestTree.GBS_GWAS > ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/RAxML_phylogeny_K.tsv"
# 1.1   SNPGWAS + Population structure correction with RAxML phylo
sbatch -p test -t 0-02:00 --mem=50000 --wrap="pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --vcf ${params.path_nextflow_dir}/11.SNIPPY_MULTI/core.vcf --similarity ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/RAxML_phylogeny_K.tsv --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/SNPGWAS_RAxML.txt"
# 1.2   DBGWAS + Population structure correction with RAxML phylo
sbatch -p test -t 0-02:00 --mem=50000 --wrap="pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --kmers ${params.path_nextflow_dir}/15.UNITIGS/unitigs.txt --uncompressed --similarity ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/RAxML_phylogeny_K.tsv --output-patterns ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/DBGWAS_RAxML_unitig_patterns.txt --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/DBGWAS_RAxML.txt"
# 1.3   PANGWAS + Population structure correction with RAxML phylo
sbatch -p test -t 0-02:00 --mem=50000 --wrap="pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --pres ${params.path_nextflow_dir}/14.Pangenome_analysis/14.1.Panaroo/gene_presence_absence.Rtab --similarity ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/RAxML_phylogeny_K.tsv --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/PanGWAS_Panaroo_RAxML.txt"

process RAxML_dist {
  conda "pyseer"

  input:
  val base


  script:
  """
  # create output folders
  mkdir -p ${params.path_nextflow_dir}/16.GWAS
  mkdir -p ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis

  # create phylogeny tsv file
  python ${params.path_nextflow_dir}/Files/pyseer/scripts/phylogeny_distance.py --lmm ${params.path_nextflow_dir}/13.Phylogeny/13.1.RAxML/RAxML_bestTree.GBS_GWAS > ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/RAxML_phylogeny_K.tsv
  """
}

process SNPGWAS_RAxML {
  conda "pyseer"

  input:
  val base


  script:
  """
  pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --vcf ${params.path_nextflow_dir}/11.SNIPPY_MULTI/core.vcf --similarity ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/RAxML_phylogeny_K.tsv --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/SNPGWAS_RAxML.txt
  """
}

process SNPGWAS_RAxML {
  conda "pyseer"

  input:
  val base


  script:
  """
  pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --kmers ${params.path_nextflow_dir}/15.UNITIGS/unitigs.txt --uncompressed --similarity ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/RAxML_phylogeny_K.tsv --output-patterns ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/DBGWAS_RAxML_unitig_patterns.txt --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/DBGWAS_RAxML.txt
  """
}

process PanGWAS_Panaroo_RAxML {
  conda "pyseer"

  input:
  val base


  script:
  """
  pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --pres ${params.path_nextflow_dir}/14.Pangenome_analysis/14.1.Panaroo/gene_presence_absence.Rtab --similarity ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/RAxML_phylogeny_K.tsv --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/PanGWAS_Panaroo_RAxML.txt
  """
}






process FASTTREE_dist {
  conda "pyseer pandas"

  input:
  val base


  script:
  """
  # create output folders
  mkdir -p ${params.path_nextflow_dir}/16.GWAS

  # create phylogeny tsv file
  python ${params.path_nextflow_dir}/Files/pyseer/scripts/phylogeny_distance.py --lmm ${params.path_nextflow_dir}/13.Phylogeny/13.2.FastTree/GBS_GWAS_FastTree_phylo.tre > ${params.path_nextflow_dir}/16.GWAS/FastTree_phylo_K.tsv
  """
}


process mash_dist {
  conda "pyseer"

  input:
  val base

  script:
  """
  # create output folders
  mkdir -p ${params.path_nextflow_dir}/16.GWAS

  #Create mash sketches
  mash sketch -s 10000 -o ${params.path_nextflow_dir}/16.GWAS/mash_sketch ${params.path_nextflow_dir}/5.ASSEMBLIES/*.fasta

  #Calculate pairwise distance
  mash dist ${params.path_nextflow_dir}/16.GWAS/mash_sketch.msh ${params.path_nextflow_dir}/16.GWAS/mash_sketch.msh| square_mash > ${params.path_nextflow_dir}/16.GWAS/mash.tsv

"""
}

process SNPGWAS_fasttree {
  conda "pyseer"

  input:
  val base


  script:
  """
  # create output folders
  mkdir -p ${params.path_nextflow_dir}/16.GWAS/16.1.SNPGWAS

  # snp based pyseer
  pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --vcf ${params.path_nextflow_dir}/11.SNIPPY_MULTI/core.vcf --similarity ${params.path_nextflow_dir}/16.GWAS/FastTree_phylo_K.tsv > ${params.path_nextflow_dir}/16.GWAS/16.1.SNPGWAS/SNPGWAS_fasttree.txt
  """
}

process DBGWAS_fasttree {
  conda "pyseer"

  input:
  val base


  script:
  """
  # create output folders
  mkdir -p ${params.path_nextflow_dir}/16.GWAS/16.2.DBGWAS

  # snp based pyseer
  pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --kmers ${params.path_nextflow_dir}/15.UNITIGS/unitigs.txt --uncompressed --similarity ${params.path_nextflow_dir}/16.GWAS/FastTree_phylo_K.tsv --output-patterns ${params.path_nextflow_dir}/16.GWAS/16.2.DBGWAS/DBGWAS_fasttree_unitig_patterns.txt > ${params.path_nextflow_dir}/16.GWAS/16.2.DBGWAS/DBGWAS_fasttree.txt
  """
}

process PANGWAS_panaroo_fasttree {
  conda "pyseer"

  input:
  val base


  script:
  """
  # create output folders
  mkdir -p ${params.path_nextflow_dir}/16.GWAS/16.3.PANGWAS

  # snp based pyseer
  pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --pres ${params.path_nextflow_dir}/14.Pangenome_analysis/14.1.Panaroo/gene_presence_absence.Rtab --similarity ${params.path_nextflow_dir}/16.GWAS/FastTree_phylo_K.tsv > ${params.path_nextflow_dir}/16.GWAS/16.3.PANGWAS/PANGWAS_panaroo_fasttree.txt
  """
}

process PANGWAS_roary_fasttree {
  conda "pyseer"

  input:
  val base


  script:
  """
  # create output folders
  mkdir -p ${params.path_nextflow_dir}/16.GWAS/16.3.PANGWAS

  # snp based pyseer
  pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --pres ${params.path_nextflow_dir}/14.Pangenome_analysis/14.2.ROARY/gene_presence_absence.Rtab --similarity ${params.path_nextflow_dir}/16.GWAS/FastTree_phylo_K.tsv > ${params.path_nextflow_dir}/16.GWAS/16.3.PANGWAS/PANGWAS_roary_fasttree.txt
  """
}
