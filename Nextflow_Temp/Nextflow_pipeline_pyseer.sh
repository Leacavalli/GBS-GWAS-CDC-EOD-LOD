process TEST {
  input:
  val base

  output:
  val base

  script:
  """
  echo "test" >> ${params.path_nextflow_dir}/test.txt
  """
}

process RAxML_dist {
  conda "pyseer"

  input:
  val base

  output:
  val base

  script:
  """
  # create output folders
  mkdir -p ${params.path_nextflow_dir}/16.Pyseer
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

process DBGWAS_RAxML {
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


process Fasttree_dist {
  conda "pyseer"

  input:
  val base

  output:
  val base

  script:
  """
  # create output folders
  mkdir -p ${params.path_nextflow_dir}/16.Pyseer
  mkdir -p ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1
  mkdir -p ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.1.Fasttree

  # create phylogeny tsv file
  python ${params.path_nextflow_dir}/Files/pyseer/scripts/phylogeny_distance.py --lmm ${params.path_nextflow_dir}/13.Phylogeny/13.2.FastTree/GBS_GWAS_FastTree_phylo.tre > ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.1.Fasttree/FastTree_phylogeny_K.tsv
  """
}

process SNPGWAS_Fasttree {
  conda "pyseer"

  input:
  val base


  script:
  """
  pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --vcf ${params.path_nextflow_dir}/11.SNIPPY_MULTI/core.vcf --similarity ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.1.Fasttree/FastTree_phylogeny_K.tsv --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.1.Fasttree/SNPGWAS_Fasttree.txt
  """
}

process DBGWAS_Fasttree {
  conda "pyseer"

  input:
  val base


  script:
  """
  pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --kmers ${params.path_nextflow_dir}/15.UNITIGS/unitigs.txt --uncompressed --similarity ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.1.Fasttree/FastTree_phylogeny_K.tsv --output-patterns ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.1.Fasttree/DBGWAS_Fasttree_unitig_patterns.txt --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.1.Fasttree/DBGWAS_Fasttree.txt
  """
}

process PanGWAS_Panaroo_Fasttree {
  conda "pyseer"

  input:
  val base


  script:
  """
  pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --pres ${params.path_nextflow_dir}/14.Pangenome_analysis/14.1.Panaroo/gene_presence_absence.Rtab --similarity ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.1.Fasttree/FastTree_phylogeny_K.tsv --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.1.Fasttree/PanGWAS_Panaroo_phylo_Fasttree.txt
  """
}

process Mash_dist {
  conda "pyseer"

  input:
  val base

  output:
  val base

  script:
  """
  # create output folders
  mkdir -p ${params.path_nextflow_dir}/16.Pyseer
  mkdir -p ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1
  mkdir -p ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.2.Mash

  # create distance file
  mash sketch -s 10000 -o ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.2.Mash/mash_sketch ${params.path_nextflow_dir}/5.ASSEMBLIES/*.fasta
  mash dist ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.2.Mash/mash_sketch.msh ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.2.Mash/mash_sketch.msh  | square_mash > ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.2.Mash/mash.tsv
  """
}

process SNPGWAS_Mash {
  conda "pyseer"

  input:
  val base


  script:
  """
  pyseer --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --vcf ${params.path_nextflow_dir}/11.SNIPPY_MULTI/core.vcf --distances ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.2.Mash/mash.tsv --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.2.Mash/SNPGWAS_mash.txt
  """
}

process DBGWAS_Mash {
  conda "pyseer"

  input:
  val base


  script:
  """
  pyseer --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --kmers ${params.path_nextflow_dir}/15.UNITIGS/unitigs.txt --uncompressed --output-patterns ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.2.Mash/DBGWAS_mash_unitig_patterns.txt --distances ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.2.Mash/mash.tsv --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.2.Mash/DBGWAS_mash.txt
  """
}

process PanGWAS_Panaroo_Mash {
  conda "pyseer"

  input:
  val base


  script:
  """
  pyseer --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --pres ${params.path_nextflow_dir}/14.Pangenome_analysis/14.1.Panaroo/gene_presence_absence.Rtab --distances ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.2.Mash/mash.tsv --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.2.Mash/PanGWAS_Panaroo_mash.txt
  """
}

process SC_dist {
  conda "pyseer"

  input:
  val base

  output:
  val base

  script:
  """
  # create output folders
  mkdir -p ${params.path_nextflow_dir}/16.Pyseer
  mkdir -p ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1
  mkdir -p ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.3.SC

  # create distances file
  sed 's/,/\t/g' ${params.path_nextflow_dir}/9.POPPUNK/GBS_GWAS_db/GBS_GWAS_db_clusters.csv > ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.3.SC/SC_clusters.txt
  """
}

process SNPGWAS_SC {
  conda "pyseer"

  input:
  val base


  script:
  """
  pyseer --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --vcf ${params.path_nextflow_dir}/11.SNIPPY_MULTI/core.vcf --covariates ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.3.SC/SC_clusters.txt --use-covariates 2 --no-distances --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.3.SC/SNPGWAS_SC.txt
  """
}

process DBGWAS_SC {
  conda "pyseer"

  input:
  val base


  script:
  """
  pyseer --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --kmers ${params.path_nextflow_dir}/15.UNITIGS/unitigs.txt --uncompressed --output-patterns ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.3.SC/DBGWAS_SC_unitig_patterns.txt --covariates ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.3.SC/SC_clusters.txt --use-covariates 2 --no-distances --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.3.SC/DBGWAS_SC.txt
  """
}

process PanGWAS_Panaroo_SC {
  conda "pyseer"

  input:
  val base


  script:
  """
  pyseer --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --pres ${params.path_nextflow_dir}/14.Pangenome_analysis/14.1.Panaroo/gene_presence_absence.Rtab --covariates ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.3.SC/SC_clusters.txt --use-covariates 2 --no-distances --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.2.Subanalysis_1/16.2.3.SC/PanGWAS_Panaroo_SC.txt
  """
}

process PanGWAS_Roary_RAxML {
  conda "pyseer"

  input:
  val base


  script:
  """
  # create output folders
  mkdir -p ${params.path_nextflow_dir}/16.Pyseer
  mkdir -p ${params.path_nextflow_dir}/16.Pyseer/16.3.Subanalysis_2

  # Run Pyseer
  pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --pres ${params.path_nextflow_dir}/14.Pangenome_analysis/14.2.ROARY/gene_presence_absence.Rtab --similarity ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/RAxML_phylogeny_K.tsv --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.3.Subanalysis_2/PanGWAS_Roary_RAxML.txt
  """
}

process PanGWAS_Panaroo_CLARC_RAxML {
  conda "pyseer"

  input:
  val base


  script:
  """
  # create output folders
  mkdir -p ${params.path_nextflow_dir}/16.Pyseer
  mkdir -p ${params.path_nextflow_dir}/16.Pyseer/16.3.Subanalysis_2

  # Make gene presence/absence input (convert CLARC .csv output to Rtab)
  awk 'BEGIN {FS=OFS=","} NR==1 {\$1="Gene" \$1} 1' ${params.path_nextflow_dir}/14.Pangenome_analysis/14.3.Panaroo_CLARC/Output/clarc_results/clarc_condensed_presence_absence.csv | awk '
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
   ' FS=',' OFS='\\t' > ${params.path_nextflow_dir}/14.Pangenome_analysis/14.3.Panaroo_CLARC/Output/clarc_results/clarc_condensed_presence_absence.Rtab


  # Run Pyseer
  pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --pres ${params.path_nextflow_dir}/14.Pangenome_analysis/14.3.Panaroo_CLARC/Output/clarc_results/clarc_condensed_presence_absence.Rtab --similarity ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/RAxML_phylogeny_K.tsv --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.3.Subanalysis_2/PanGWAS_Panaroo_CLARC_RAxML.txt
  """
}

process PanGWAS_Roary_CLARC_RAxML {
  conda "pyseer"

  input:
  val base


  script:
  """
  # create output folders
  mkdir -p ${params.path_nextflow_dir}/16.Pyseer
  mkdir -p ${params.path_nextflow_dir}/16.Pyseer/16.3.Subanalysis_2

  # Make gene presence/absence input (convert CLARC .csv output to Rtab)
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

  # Run Pyseer
  pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --pres ${params.path_nextflow_dir}/14.Pangenome_analysis/14.4.ROARY_CLARC/Output/clarc_results/clarc_condensed_presence_absence.Rtab --similarity ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/RAxML_phylogeny_K.tsv --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.3.Subanalysis_2/PanGWAS_Roary_CLARC_RAxML.txt
  """
}


workflow flow1 {
    take: data
    main:
        TEST(data)
    emit: TEST.out
}

workflow flow_main {
    take: data
    main:
    RAxML_dist(data)
    SNPGWAS_RAxML(RAxML_dist.out[0])
    DBGWAS_RAxML(RAxML_dist.out[0])
    PanGWAS_Panaroo_RAxML(RAxML_dist.out[0])
}

workflow flow_sub1_Fasttree {
    take: data
    main:
    Fasttree_dist(data)
    SNPGWAS_Fasttree(Fasttree_dist.out[0])
    DBGWAS_Fasttree(Fasttree_dist.out[0])
    PanGWAS_Panaroo_Fasttree(Fasttree_dist.out[0])
}

workflow flow_sub1_Mash {
    take: data
    main:
    Mash_dist(data)
    SNPGWAS_Mash(Mash_dist.out[0])
    DBGWAS_Mash(Mash_dist.out[0])
    PanGWAS_Panaroo_Mash(Mash_dist.out[0])
}

workflow flow_sub1_SC {
    take: data
    main:
    SC_dist(data)
    SNPGWAS_SC(SC_dist.out[0])
    DBGWAS_SC(SC_dist.out[0])
    PanGWAS_Panaroo_SC(SC_dist.out[0])
}

workflow flow_sub2 {
    take: data
    main:
    RAxML_dist(data)
    PanGWAS_Roary_RAxML(RAxML_dist.out[0])
    PanGWAS_Panaroo_CLARC_RAxML(RAxML_dist.out[0])
    PanGWAS_Roary_CLARC_RAxML(RAxML_dist.out[0])
}


workflow {
  channel.fromFilePairs("${params.path_nextflow_dir}/0.RAW_READS/SRR*_{1,2}.fastq.gz")
         .map { it[0] }
         | flow1
  flow_main(flow1.out.collect())
  flow_sub1_Fasttree(flow1.out.collect())
  flow_sub1_Mash(flow1.out.collect())
  flow_sub1_SC(flow1.out.collect())
  flow_sub2(flow1.out.collect())
}
