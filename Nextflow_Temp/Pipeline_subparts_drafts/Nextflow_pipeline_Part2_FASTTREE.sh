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


process FASTTREE {

  script:
  """
  mkdir -p ${params.path_nextflow_dir}/14.Phylogeny
  mkdir -p ${params.path_nextflow_dir}/14.Phylogeny/14.2.FastTree
  FastTree -gtr -nt ${params.path_nextflow_dir}/9.SNIPPY_MULTI/clean.full.aln > ${params.path_nextflow_dir}/14.Phylogeny/14.2.FastTree/GBS_GWAS_FastTree_phylo
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
        FASTTREE()
}

workflow {
  channel.fromFilePairs("${params.path_nextflow_dir}/0.RAW_READS/SRR*_{1,2}.fastq.gz")
         .map { it[0] }
         | flow1
         | collect
         | flow2
}
