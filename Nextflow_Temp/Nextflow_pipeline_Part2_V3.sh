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
  def assembliesDir = new File("${params.path_nextflow_dir}/7.ASSEMBLIES")
  def fastaFiles = assembliesDir.listFiles().findAll { it.name.endsWith('.fasta') }
  fastaFiles.each { file ->
      def sample = file.name.split(/\./)[0]  // Extracts the part before the first dot
      println "${sample} ${file.path}"
  } > ${params.path_nextflow_dir}/9.POPPUNK/qfile.txt
  # sed -i 's/\ /\t/g' ${params.path_nextflow_dir}/9.POPPUNK/qfile.txt

  # Run
  # 1. Create sketch database
  #sbatch -p shared -c 8 -t 2-00:00 --mem=10000 --wrap="poppunk --create-db --output GBS_Global_NFDS_db --r-files qfile.txt --threads 8"
  # 2. Run QC on the database
  #sbatch -p shared -c 8 -t 0-05:00 --mem=10000 --wrap="poppunk --qc-db --ref-db GBS_Global_NFDS_db --length-range 1500000 2500000 --threads 8"
  # 3. Fit a model, check cluster (core+accessory)
  #sbatch -p shared -c 8 -t 0-08:00 --mem=10000 --wrap="poppunk --fit-model dbscan --ref-db GBS_Global_NFDS_db  --threads 8"
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
