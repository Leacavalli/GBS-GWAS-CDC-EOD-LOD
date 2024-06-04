process Trimmomatic {
  conda 'openjdk=11'

  publishDir '/n/holylfs05/LABS/hanage_lab/Lab/hsphfs1/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE/1.TRIMMED_READS' , overwrite: true

  input:
  val base

  output:
  val base
  path "${base}_trimmed_1.fq.gz"
  path "${base}_trimmed_2.fq.gz"

  """
  java -jar /n/holylfs05/LABS/hanage_lab/Lab/holyscratch01/lcavalli/Software/Trimmomatic-0.39/trimmomatic-0.39.jar PE -phred33 -trimlog ${base}_1.log /n/holylfs05/LABS/hanage_lab/Lab/hsphfs1/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE/0.RAW_READS/${base}_1.fastq.gz /n/holylfs05/LABS/hanage_lab/Lab/hsphfs1/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE/0.RAW_READS/${base}_2.fastq.gz ${base}_trimmed_1.fq.gz ${base}_unpaired_1.fq.gz ${base}_trimmed_2.fq.gz ${base}_unpaired_2.fq.gz LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 > ${base}_trim.out
  rm ${base}_1.log ${base}_unpaired_1.fq.gz ${base}_unpaired_2.fq.gz ${base}_trim.out
  """
}


process Kraken {
  publishDir '/n/holylfs05/LABS/hanage_lab/Lab/hsphfs1/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE/2.KRAKEN' , overwrite: true

  input:
  val base
  val trimmed_read1
  val trimmed_read2

  output:
  val base
  val trimmed_read1
  val trimmed_read2
  path "${base}_kraken.out"
  path "${base}_report.txt.gz"

  script:
  """
  kraken2 --db /n/holylfs05/LABS/hanage_lab/Lab/holyscratch01/lcavalli/Software/kraken2/standard_db --report ${base}_report.txt --paired ${trimmed_read1} ${trimmed_read2} > ${base}_kraken.out
  gzip ${base}_report.txt
  """
}

process Kraken_tools {
  conda 'biopython'

  publishDir '/n/holylfs05/LABS/hanage_lab/Lab/hsphfs1/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE/3.FILTERED_READS', overwrite: true

  input:
  val base
  val trimmed_read1
  val trimmed_read2
  val kraken_output
  val kraken_report

  output:
  val base
  path "${base}_filtered_1.fq.gz"
  path "${base}_filtered_2.fq.gz"

  script:
  """
  extract_kraken_reads.py -k ${kraken_output} -s1 ${trimmed_read1} -s2 ${trimmed_read2} -o ${base}_filtered_1.fq -o2 ${base}_filtered_2.fq --fastq-output --taxid 1301
  gzip ${base}_filtered_1.fq
  gzip ${base}_filtered_2.fq
  """
}

process Serotype_MLST {
  conda 'srst2'

  publishDir '/n/holylfs05/LABS/hanage_lab/Lab/hsphfs1/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE/6.SRST2', overwrite: true

  input:
  val base
  val filtered_read1
  val filtered_read2

  output:
  val base
  val filtered_read1
  val filtered_read2
  path "${base}__genes__GBS-SBG__results.txt"
  path "${base}__mlst__Streptococcus_agalactiae__results.txt"

  script:
  """
  srst2 --input_pe /n/holylfs05/LABS/hanage_lab/Lab/hsphfs1/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE/0.RAW_READS/${base}_{1,2}.fastq.gz --output ${base} --log --gene_db /n/holylfs05/LABS/hanage_lab/Lab/holyscratch01/lcavalli/Software/GBS-SBG/GBS-SBG.fasta --mlst_db /n/holylfs05/LABS/hanage_lab/Lab/holyscratch01/lcavalli/Software/srst2/Streptococcus_agalactiae.fasta --mlst_definitions /n/holylfs05/LABS/hanage_lab/Lab/holyscratch01/lcavalli/Software/srst2/profiles_csv --mlst_delimiter '_'
  """
}


workflow {
  Channel.of(params.base)
    | Trimmomatic
    | Kraken
    | Kraken_tools
    | Serotype_MLST
}
