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

process RAxML {
  cpus 50

  publishDir "${params.path_nextflow_dir}/11.RAxML", overwrite: true

  input:
  val snippy_out

  output:
  val snippy_out

  script:
  """
  mkdir -p ${params.path_nextflow_dir}/13.Phylogeny_Test
  mkdir -p ${params.path_nextflow_dir}/13.Phylogeny_Test/13.1.RAxML
  # Generate 100 ML trees on distinct starting trees and output the best likelihood tree
  ${params.path_nextflow_dir}/Files/standard-RAxML-master/raxmlHPC-PTHREADS-SSE3 -T 50 -m GTRGAMMA -p 12345 -# 100 -s ${params.path_nextflow_dir}/11.SNIPPY_MULTI/clean.full.aln -w ${params.path_nextflow_dir}/13.Phylogeny_Test/13.1.RAxML -n T1 -o Reference
  # Generate 250 bootstrap tree to infer statistical support of the branches.
  ${params.path_nextflow_dir}/Files/standard-RAxML-master/raxmlHPC-PTHREADS-SSE3 -T 50 -m GTRGAMMA -p 12345 -b 12345 -# 250 -s ${params.path_nextflow_dir}/11.SNIPPY_MULTI/clean.full.aln -w ${params.path_nextflow_dir}/13.Phylogeny_Test/13.1.RAxML -n T2 -o Reference
  # Draw bipartitions on the best ML tree
  ${params.path_nextflow_dir}/Files/standard-RAxML-master/raxmlHPC-PTHREADS-SSE3 -T 50 -m GTRCAT -p 12345 -f b -t ${params.path_nextflow_dir}/13.Phylogeny_Test/13.1.RAxML/RAxML_bestTree.T1 -z ${params.path_nextflow_dir}/13.Phylogeny_Test/13.1.RAxML/RAxML_bootstrap.T2 -w ${params.path_nextflow_dir}/13.Phylogeny_Test/13.1.RAxML -n T3
  """
}


workflow flow1 {
  take: data
  main:
    TEST(data)
  emit:
    TEST.out
}

workflow flow2 {
  take: data
  main:
    RAxML(data)
}

workflow {
  channel.fromFilePairs("${params.path_nextflow_dir}/0.RAW_READS/SRR*_{1,2}.fastq.gz")
         .map { it[0] }
         | flow1
         | collect
         | flow2
}
