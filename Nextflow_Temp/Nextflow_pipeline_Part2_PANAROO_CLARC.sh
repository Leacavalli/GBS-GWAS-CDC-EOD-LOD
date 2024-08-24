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


process CLARC {
  conda "${params.path_conda_envs}/clarc_env"

  script:
  """
  mkdir -p ${params.path_nextflow_dir}/10.Pangenome_analysis/10.3.Panaroo_CLARC
  mkdir -p ${params.path_nextflow_dir}/10.Pangenome_analysis/10.3.Panaroo_CLARC/data
  mkdir -p ${params.path_nextflow_dir}/10.Pangenome_analysis/10.3.Panaroo_CLARC/Output
  # Prepare input Files
  cp ${params.path_nextflow_dir}/10.Pangenome_analysis/10.1.Panaroo/gene_presence_absence.csv ${params.path_nextflow_dir}/10.Pangenome_analysis/10.3.Panaroo_CLARC/data
  cp ${params.path_nextflow_dir}/10.Pangenome_analysis/10.1.Panaroo/pan_genome_reference.fa ${params.path_nextflow_dir}/10.Pangenome_analysis/10.3.Panaroo_CLARC/data
  for i in ${params.path_nextflow_dir}/7.ASSEMBLIES/*fasta
  do
  sample=\$(echo \$i | cut -d '/' -f12-12 | cut -d '.' -f1-1)
  echo "\$sample"
  done > ${params.path_nextflow_dir}/10.Pangenome_analysis/10.3.Panaroo_CLARC/data/needed_sample_names.txt

  # Run CLARC
  clarc --input_dir ${params.path_nextflow_dir}/10.Pangenome_analysis/10.3.Panaroo_CLARC/data --output_dir ${params.path_nextflow_dir}/10.Pangenome_analysis/10.3.Panaroo_CLARC/Output
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
        CLARC()
}

workflow {
  channel.fromFilePairs("${params.path_nextflow_dir}/0.RAW_READS/SRR*_{1,2}.fastq.gz")
         .map { it[0] }
         | flow1
         | collect
         | flow2
}
