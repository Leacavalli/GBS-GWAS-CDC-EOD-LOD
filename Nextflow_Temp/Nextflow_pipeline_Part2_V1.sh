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

process SNIPPY_MULTI {
  conda "snippy"

  publishDir "${params.path_nextflow_dir}/9.SNIPPY_MULTI", overwrite: true

  script:
  """
  snippy-core --ref ${params.path_nextflow_dir}/Files/AP018935.1.fa ${params.path_nextflow_dir}/4.SNIPPY/SRR*
  snippy-clean_full_aln core.full.aln > clean.full.aln
  """
}

process GUBBINS {
  conda "gubbins"

  publishDir "${params.path_nextflow_dir}/10.GUBBINS", overwrite: true

  script:
  """
  run_gubbins.py -p GBS_GWAS ${params.path_nextflow_dir}/9.SNIPPY_MULTI/clean.full.aln
  """
}

workflow flow1 {
    take: data
    main:
        TEST(data)
    emit: TEST.out
}

workflow flow2 {
    take: data
    main:
        SNIPPY_MULTI()
        GUBBINS()
}

workflow {
  channel.fromFilePairs("${params.path_nextflow_dir}/0.RAW_READS/SRR*_{1,2}.fastq.gz")
         .map { it[0] }
         | flow1
         | collect
         | flow2
}
