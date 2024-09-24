
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
  mkdir -p ${params.path_nextflow_dir}/13.Phylogeny
  mkdir -p ${params.path_nextflow_dir}/13.Phylogeny/13.1.RAxML
  # Generate 100 ML trees on distinct starting trees and output the best likelihood tree
  ${params.path_nextflow_dir}/Files/standard-RAxML-master/raxmlHPC-PTHREADS-SSE3 -T 50 -m GTRGAMMA -p 12345 -# 100 -s ${params.path_nextflow_dir}/11.SNIPPY_MULTI/clean.full.aln -w ${params.path_nextflow_dir}/13.Phylogeny/13.1.RAxML -n GBS_GWAS
  # Generate 100 bootstrap tree to infer statistical support of the branches.
  ${params.path_nextflow_dir}/Files/standard-RAxML-master/raxmlHPC-PTHREADS-SSE3 -T 50 -m GTRGAMMA -p 12345 -b 12345 -# 250 -s ${params.path_nextflow_dir}/11.SNIPPY_MULTI/clean.full.aln -w ${params.path_nextflow_dir}/13.Phylogeny/13.1.RAxML -n GBS_GWAS
  # Draw bipartitions on the best ML tree
  ${params.path_nextflow_dir}/Files/standard-RAxML-master/raxmlHPC-PTHREADS-SSE3 -T 50 -m GTRCAT -p 12345 -f b -t RAxML_bestTree.GBS_GWAS -z RAxML_bootstrap.GBS_GWAS -w ${params.path_nextflow_dir}/13.Phylogeny/13.1.RAxML -n GBS_GWAS
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
    RAxML()
}

workflow {
  channel.fromFilePairs("${params.path_nextflow_dir}/0.RAW_READS/SRR*_{1,2}.fastq.gz")
         .map { it[0] }
         | flow1
         | collect
         | flow2
}
