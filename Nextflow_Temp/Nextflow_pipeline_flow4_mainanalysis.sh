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


workflow flow1 {
    take: data
    main:
        TEST(data)
    emit: TEST.out
}

workflow flow4 {
    take: data
    main:
    RAxML_dist(data)
    SNPGWAS_RAxML(RAxML_dist.out[0])
    DBGWAS_RAxML(RAxML_dist.out[0])
    PanGWAS_Panaroo_RAxML(RAxML_dist.out[0])
}

workflow {
  channel.fromFilePairs("${params.path_nextflow_dir}/0.RAW_READS/SRR*_{1,2}.fastq.gz")
         .map { it[0] }
         | flow1
         | collect
         | flow4
}
