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


workflow flow1 {
    take: data
    main:
        TEST(data)
    emit: TEST.out
}

workflow flow4 {
    take: data
    main:
    SC_dist(data)
    SNPGWAS_SC(SC_dist.out[0])
    DBGWAS_SC(SC_dist.out[0])
    PanGWAS_Panaroo_SC(SC_dist.out[0])
}

workflow {
  channel.fromFilePairs("${params.path_nextflow_dir}/0.RAW_READS/SRR*_{1,2}.fastq.gz")
         .map { it[0] }
         | flow1
         | collect
         | flow4
}
