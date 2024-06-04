process Trimmomatic {
  conda 'openjdk=11'

  publishDir '${params.path_to_reads}/1.TRIMMED_READS' , overwrite: true

  input:
  val base

  output:
  val base
  path "${base}_trimmed_1.fq.gz"
  path "${base}_trimmed_2.fq.gz"

  """
  java -jar /n/holylfs05/LABS/hanage_lab/Lab/holyscratch01/lcavalli/Software/Trimmomatic-0.39/trimmomatic-0.39.jar PE -phred33 -trimlog ${base}_1.log ${params.path_to_reads}/0.RAW_READS/${base}_1.fastq.gz ${params.path_to_reads}/0.RAW_READS/${base}_2.fastq.gz ${base}_trimmed_1.fq.gz ${base}_unpaired_1.fq.gz ${base}_trimmed_2.fq.gz ${base}_unpaired_2.fq.gz LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 > ${base}_trim.out
  rm ${base}_1.log ${base}_unpaired_1.fq.gz ${base}_unpaired_2.fq.gz ${base}_trim.out
  """
}


process Kraken {
  publishDir '${params.path_to_reads}/2.KRAKEN' , overwrite: true

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

  publishDir '${params.path_to_reads}/3.FILTERED_READS', overwrite: true

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


process ASSEMBLY {
  conda 'unicycler'

  publishDir '${params.path_to_reads}/4.ASSEMBLIES', overwrite: true

  input:
  val base
  val filtered_read1
  val filtered_read2

  output:
  val base
  path "${base}.fasta"

  script:
  """
  unicycler -1 ${filtered_read1}  -2 ${filtered_read2} -o ${base}.unicycler.out
  mv ${base}.unicycler.out/assembly.fasta ${base}.fasta
  rm -r ${base}.unicycler.out
  """
}


process ANNOTATION {
  conda 'prokka'

  publishDir '${params.path_to_reads}/5.ANNOTATION', overwrite: true

  input:
  val base
  val fasta_file

  output:
  val base
  val fasta_file
  path "${base}.gff"

  script:
  """
  prokka ${fasta_file} --outdir ${base}_prokka  --prefix ${base}
  mv ${base}_prokka/*.gff .
  rm -r ${base}_prokka
  """
}

process Serotyping {
  conda 'perl blast'

  publishDir '${params.path_to_reads}/6.SEROTYPES', overwrite: true

  input:
  val base
  val fasta_file
  val gff3_file


  output:
  val base
  val fasta_file
  path "${base}_sero.tab"

  script:
  """
  perl /n/holylfs05/LABS/hanage_lab/Lab/holyscratch01/lcavalli/Software/GBS-SBG/GBS-SBG.pl ${fasta_file} | tail -1 > ${base}_sero.tab
  """
}

process MLST {
  conda 'mlst'

  publishDir '${params.path_to_reads}/7.MLST', overwrite: true

  input:
  val base
  val fasta_file
  val sero_tab_file

  output:
  val base
  val fasta_file
  path "${base}_mlst.tab"

  script:
  """
  mlst --scheme sagalactiae ${fasta_file} > ${base}_mlst.tab
  """
}

workflow {
  Channel.of(params.base)
    | Trimmomatic
    | Kraken
    | Kraken_tools
    | ASSEMBLY
    | ANNOTATION
    | Serotyping
    | MLST
}
