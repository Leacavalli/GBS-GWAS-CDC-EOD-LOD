
process Trimmomatic {
  conda "openjdk=11"

  publishDir "${params.path_nextflow_dir}/1.TRIMMED_READS" , overwrite: true

  input:
  val base

  output:
  val base
  path "${base}_trimmed_1.fq.gz"
  path "${base}_trimmed_2.fq.gz"

  """
  java -jar /n/holylfs05/LABS/hanage_lab/Lab/holyscratch01/lcavalli/Software/Trimmomatic-0.39/trimmomatic-0.39.jar PE -phred33 -trimlog ${base}_1.log ${params.path_nextflow_dir}/0.RAW_READS/${base}_1.fastq.gz ${params.path_nextflow_dir}/0.RAW_READS/${base}_2.fastq.gz ${base}_trimmed_1.fq.gz ${base}_unpaired_1.fq.gz ${base}_trimmed_2.fq.gz ${base}_unpaired_2.fq.gz LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 > ${base}_trim.out
  rm ${base}_1.log ${base}_unpaired_1.fq.gz ${base}_unpaired_2.fq.gz ${base}_trim.out
  """
}

process FastQC {
  conda "fastqc"

  input:
  val base
  val filtered_read1
  val filtered_read2

  output:
  val base , emit: base
  val filtered_read1
  val filtered_read2

  script:
  """
  fastqc ${filtered_read1} -o ${params.path_nextflow_dir}/4.FASTQC
  fastqc ${filtered_read2} -o ${params.path_nextflow_dir}/4.FASTQC
  """
}

process MultiQC {
  conda "multiqc"

  input:
  val base

  script:
  """
  multiqc -n MultiQC_report --outdir ${params.path_nextflow_dir}/9.MultiQC/ ${params.path_nextflow_dir}/4.FASTQC
  """
}


workflow flow1 {
    take: data
    main:
        Trimmomatic(data)
        | FastQC
    emit: FastQC.out.base

}

workflow flow2 {
    take: data
    main:
        MultiQC(data)
}

workflow {
  channel.fromFilePairs("${params.path_nextflow_dir}/0.RAW_READS/SRR*_{1,2}.fastq.gz")
         .map { it[0] }
         | flow1
         | collect
         | flow2
}



sbatch -p shared -c 3 -t 0-01:00 --mem=40000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_V06.nf --path_nextflow_dir /n/holylfs05/LABS/hanage_lab/Lab/hsphfs1/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade"
