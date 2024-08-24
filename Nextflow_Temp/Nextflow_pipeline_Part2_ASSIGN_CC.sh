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


process ASSIGN_CC {
  conda "${params.path_conda_envs}/clarc_env"

  script:
  """
  # Load R module
  module load R/4.3.1-fasrc01
  export R_LIBS_USER=$HOME/apps/R_4.3.1/:$R_LIBS_USER

  # Run the R script
  R CMD BATCH --quiet --no-restore --no-save Calculate_Pair_shared_iSNV.R
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
        ASSIGN_CC()
}

workflow {
  channel.fromFilePairs("${params.path_nextflow_dir}/0.RAW_READS/SRR*_{1,2}.fastq.gz")
         .map { it[0] }
         | flow1
         | collect
         | flow2
}
