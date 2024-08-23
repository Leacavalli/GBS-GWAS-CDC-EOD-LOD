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

process PANAROO {
  conda "/n/home02/lcavalli/.conda/envs/Panaroo"

  script:
  """
  mkdir -p ${params.path_nextflow_dir}/10.Pangenome_analysis
  mkdir -p ${params.path_nextflow_dir}/10.Pangenome_analysis/10.1.Panaroo
  panaroo -i ${params.path_nextflow_dir}/8.ANNOTATION/*.gff -o ${params.path_nextflow_dir}/10.Pangenome_analysis/10.1.Panaroo --clean-mode strict --alignment pan --aligner mafft

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
        PANAROO()
}

workflow {
  channel.fromFilePairs("${params.path_nextflow_dir}/0.RAW_READS/SRR*_{1,2}.fastq.gz")
         .map { it[0] }
         | flow1
         | collect
         | flow2
}
