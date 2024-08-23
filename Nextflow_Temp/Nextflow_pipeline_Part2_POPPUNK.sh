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

process POPPUNK {
  conda "poppunk"

  publishDir "${params.path_nextflow_dir}/9.POPPUNK", overwrite: true

  script:
  """
  # Prepare input file
  mkdir -p ${params.path_nextflow_dir}/9.POPPUNK
  for i in ${params.path_nextflow_dir}/7.ASSEMBLIES/*fasta
  do
  sample=\$(echo \$i | cut -d '/' -f12-12 | cut -d '.' -f1-1)
  echo -e "\$sample\t\$i"
  done > ${params.path_nextflow_dir}/9.POPPUNK/qfile.txt

  # Run
  # 1. Create sketch database
  poppunk --create-db --output ${params.path_nextflow_dir}/9.POPPUNK/GBS_GWAS_db --r-files ${params.path_nextflow_dir}/9.POPPUNK/qfile.txt --threads 8
  # 2. Run QC on the database
  poppunk --qc-db --ref-db ${params.path_nextflow_dir}/9.POPPUNK/GBS_GWAS_db --length-range 1500000 2500000 --threads 8
  # 3. Fit a model, check cluster (core+accessory)
  poppunk --fit-model dbscan --ref-db ${params.path_nextflow_dir}/9.POPPUNK/GBS_GWAS_db --threads 8
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
        POPPUNK()
}

workflow {
  channel.fromFilePairs("${params.path_nextflow_dir}/0.RAW_READS/SRR*_{1,2}.fastq.gz")
         .map { it[0] }
         | flow1
         | collect
         | flow2
}
