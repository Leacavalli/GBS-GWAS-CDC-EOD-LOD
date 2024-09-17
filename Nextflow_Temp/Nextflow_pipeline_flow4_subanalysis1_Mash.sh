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


workflow flow1 {
    take: data
    main:
        TEST(data)
    emit: TEST.out
}

workflow flow4 {
    take: data
    main:
    Mash_dist(data)
    SNPGWAS_Mash(Mash_dist.out[0])
    DBGWAS_Mash(Mash_dist.out[0])
    PanGWAS_Panaroo_Mash(Mash_dist.out[0])
}

workflow {
  channel.fromFilePairs("${params.path_nextflow_dir}/0.RAW_READS/SRR*_{1,2}.fastq.gz")
         .map { it[0] }
         | flow1
         | collect
         | flow4
}
