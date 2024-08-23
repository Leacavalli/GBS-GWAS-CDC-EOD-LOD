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
  val base
  val filtered_read1
  val filtered_read2

  script:
  """
  fastqc ${filtered_read1} --extract -o ${params.path_nextflow_dir}/2.FASTQC
  fastqc ${filtered_read2} --extract -o ${params.path_nextflow_dir}/2.FASTQC
  """
}


process Serotype_MLST {
  conda "srst2"

  publishDir "${params.path_nextflow_dir}/3.SEROTYPE_MLST", overwrite: true

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
  srst2 --input_pe ${params.path_nextflow_dir}/0.RAW_READS/${base}_{1,2}.fastq.gz --output ${base} --log --gene_db ${params.path_nextflow_dir}/Files/GBS-SBG.fasta --mlst_db ${params.path_nextflow_dir}/Files/Streptococcus_agalactiae.fasta --mlst_definitions ${params.path_nextflow_dir}/Files/profiles_csv --mlst_delimiter '_'
  """
}

process SNIPPY {
  conda "snippy"

  input:
  val base
  val filtered_read1
  val filtered_read2
  val serotypes_out
  val mlst_out

  output:
  val base
  val filtered_read1
  val filtered_read2

  script:
  """
  snippy --outdir ${params.path_nextflow_dir}/4.SNIPPY/${base} --R1 ${filtered_read1} --R2 ${filtered_read2} --ref ${params.path_nextflow_dir}/Files/AP018935.1.fa --cpus 16
  """
}

process ASSEMBLY {
  conda "unicycler"

  publishDir "${params.path_nextflow_dir}/5.ASSEMBLIES", overwrite: true

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
  mv ${base}.unicycler.out/base.fasta ${base}.fasta
  rm -r ${base}.unicycler.out
  """
}


process ANNOTATION {
  conda "prokka"

  publishDir "${params.path_nextflow_dir}/6.ANNOTATION", overwrite: true

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

process FastANI {
  conda "fastani"

  publishDir "${params.path_nextflow_dir}/7.FastANI", overwrite: true

  input:
  val base
  val fasta_file
  val gff_file

  output:
  val base
  val fasta_file
  path "${base}.fastani.out"

  script:
  """
  fastANI -q ${fasta_file} -r ${params.path_nextflow_dir}/Files/AP018935.1.fa -o ${base}.fastani.out
  """
}

process QUAST {
  conda "quast"

  publishDir "${params.path_nextflow_dir}/8.QUAST", overwrite: true

  input:
  val base
  val fasta_file
  val fastani_file

  output:
  val base
  path "${base}.quast.out"

  script:
  """
  quast -o ${base}.quast.out ${fasta_file}
  """
}


process Filter_out_QC {
  input:
  val base
  val quast_file

  output:
  val base

  script:
  """
  # Create necessary directories if they don't already exist
    mkdir -p ${params.path_nextflow_dir}/4.SNIPPY/Filter_out_QC
    mkdir -p ${params.path_nextflow_dir}/5.ASSEMBLIES/Filter_out_QC
    mkdir -p ${params.path_nextflow_dir}/6.ANNOTATION/Filter_out_QC

  # Extract information from the QUAST report
    n50=\$(grep -w "N50" ${quast_file}/report.txt | awk '{print \$2}')
    gc=\$(grep -w "GC (%)" ${quast_file}/report.txt | awk '{print \$3}')
    total_length=\$(grep -w "Total length" ${quast_file}/report.txt | grep -v "(>= " | awk '{print \$3}')
    contigs=\$(grep "^# contigs " ${quast_file}/report.txt | tail -1 | awk '{print \$3}')
    ANI=\$(cat ${params.path_nextflow_dir}/7.FastANI/\${base}.fastani.out | awk '{print \$3}')
    Adapter_content_1=\$(grep "Adapter Content" ${params.path_nextflow_dir}/2.FASTQC/${base}_trimmed_1_fastqc/summary.txt | awk '{print \$1}')
    Adapter_content_2=\$(grep "Adapter Content" ${params.path_nextflow_dir}/2.FASTQC/${base}_trimmed_2_fastqc/summary.txt | awk '{print \$1}')

  # Check the conditions and move files if necessary
    if (( \$(echo "\$ANI < 95" | bc -l) )) || [ "\$n50" -lt 30000 ] || [ "\$contigs" -gt 250 ] || (( \$(echo "\$gc <= 30" | bc -l) )) || (( \$(echo "\$gc >= 40" | bc -l) )) || [ "\$total_length" -lt 1700000 ] || [ "\$total_length" -gt 2400000 ] || [[ "\$Adapter_content_1" == "FAIL" || "\$Adapter_content_2" == "FAIL" ]]; then
      mv ${params.path_nextflow_dir}/4.SNIPPY/${base} ${params.path_nextflow_dir}/4.SNIPPY/Filter_out_QC
      mv ${params.path_nextflow_dir}/5.ASSEMBLIES/${base}.fasta ${params.path_nextflow_dir}/5.ASSEMBLIES/Filter_out_QC
      mv ${params.path_nextflow_dir}/6.ANNOTATION/${base}.gff ${params.path_nextflow_dir}/6.ANNOTATION/Filter_out_QC
    fi
  """
}



workflow {
channel.fromFilePairs("${params.path_nextflow_dir}/0.RAW_READS/SRR*_{1,2}.fastq.gz")
       .map { it[0] }
    | Trimmomatic
    | FastQC
    | Serotype_MLST
    | SNIPPY
    | ASSEMBLY
    | ANNOTATION
    | FastANI
    | QUAST
    | Filter_out_QC
}
