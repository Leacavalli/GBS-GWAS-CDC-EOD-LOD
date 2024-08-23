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


process ROARY {
  conda "roary"

  script:
  """
  mkdir -p ${params.path_nextflow_dir}/10.Pangenome_analysis
  roary -e --mafft -p 8 ${params.path_nextflow_dir}/8.ANNOTATION/*.gff -f ${params.path_nextflow_dir}/10.Pangenome_analysis/10.2.Roary
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
        ROARY()
}

workflow {
  channel.fromFilePairs("${params.path_nextflow_dir}/0.RAW_READS/SRR*_{1,2}.fastq.gz")
         .map { it[0] }
         | flow1
         | collect
         | flow2
}
