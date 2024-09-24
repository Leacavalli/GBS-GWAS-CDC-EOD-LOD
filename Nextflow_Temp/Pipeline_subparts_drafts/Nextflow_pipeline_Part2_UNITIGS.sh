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


process UNITIG {
  conda "unitig-counter"

  script:
  """
  unitig-counter -strains ${params.path_nextflow_dir}/9.POPPUNK/qfile.txt -output ${params.path_nextflow_dir}/11.Unitigs -nb-cores 8
  cdbg-ops extend --graph ${params.path_nextflow_dir}/11.Unitigs/graph --unitigs ${params.path_nextflow_dir}/11.Unitigs/unitigs.txt > ${params.path_nextflow_dir}/11.Unitigs/extended.txt
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
        UNITIG()
}

workflow {
  channel.fromFilePairs("${params.path_nextflow_dir}/0.RAW_READS/SRR*_{1,2}.fastq.gz")
         .map { it[0] }
         | flow1
         | collect
         | flow2
}
