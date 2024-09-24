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


workflow flow1 {
    take: data
    main:
        TEST(data)
    emit: TEST.out
}

workflow flow4 {
    take: data
    main:
    Fasttree_dist(data)
    SNPGWAS_Fasttree(Fasttree_dist.out[0])
    DBGWAS_Fasttree(Fasttree_dist.out[0])
    PanGWAS_Panaroo_Fasttree(Fasttree_dist.out[0])
}

workflow {
  channel.fromFilePairs("${params.path_nextflow_dir}/0.RAW_READS/SRR*_{1,2}.fastq.gz")
         .map { it[0] }
         | flow1
         | collect
         | flow4
}
