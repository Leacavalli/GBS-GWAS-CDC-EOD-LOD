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
  fastqc ${filtered_read1} -o ${params.path_nextflow_dir}/2.FASTQC
  fastqc ${filtered_read2} -o ${params.path_nextflow_dir}/2.FASTQC
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
  mv ${base}.unicycler.out/assembly.fasta ${base}.fasta
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
  mkdir ${params.path_nextflow_dir}/4.SNIPPY/Filter_out_QC
  mkdir ${params.path_nextflow_dir}/5.ASSEMBLIES/Filter_out_QC
  mkdir ${params.path_nextflow_dir}/6.ANNOTATION/Filter_out_QC


  for i in ${params.path_nextflow_dir}/8.QUAST/*.quast.out;
  do
    assembly=$(grep "Assembly" $i/report.txt | awk '{print $2}')
    n50=$(grep -w "N50" $i/report.txt | awk '{print $2}')
    gc=$(grep -w "GC (%)" $i/report.txt | awk '{print $3}')
    total_length=$(grep -w "Total length" $i/report.txt | grep -v "(>= " | awk '{print $3}')
    contigs=$(grep "^# contigs " $i/report.txt | tail -1 | awk '{print $3}')
    ANI=$(cat ${params.path_nextflow_dir}/7.FastANI/$assembly\.fastani.out| awk '{print $3}')

    # Check the conditions
    if (( $(echo "$ANI < 95" | bc -l) )) ||[ "$n50" -lt  30000 ] || [ "$contigs" -gt 250 ]  || (( $(echo "$gc <= 30" | bc -l) )) || (( $(echo "$gc >= 40" | bc -l) )) || [ "$total_length" -lt 1700000 ] || [ "$total_length" -gt 2400000 ] ; then
      mv ${params.path_nextflow_dir}/4.SNIPPY/$assembly ${params.path_nextflow_dir}/4.SNIPPY/Filter_out_QC
      mv ${params.path_nextflow_dir}/5.ASSEMBLIES/$assembly\.fasta ${params.path_nextflow_dir}/5.ASSEMBLIES/Filter_out_QC
      mv ${params.path_nextflow_dir}/6.ANNOTATION/$assembly\.gff ${params.path_nextflow_dir}/6.ANNOTATION/Filter_out_QC
    fi
  done
  """
}


process SNIPPY2 {
  conda "snippy"

  publishDir "${params.path_nextflow_dir}/4.SNIPPY", overwrite: true

  script:
  """
  ref = $(ls ${params.path_nextflow_dir}/4.SNIPPY | head -1)
  snippy-core --ref $ref/ref.fa ${params.path_nextflow_dir}/4.SNIPPY/SRR*
  snippy-clean_full_aln core.full.aln > SNIPPY_whole_genome_alignment.aln
  """
}


# Gubbins
# Note: Are files directly written to publishDIR, although not included in ouput ?

process GUBBINS {
  conda "gubbins"

  publishDir "${params.path_nextflow_dir}/9.GUBBINS", overwrite: true

  script:
  """
  run_gubbins.py -p gubbins ${params.path_nextflow_dir}/4.SNIPPY/SNIPPY_whole_genome_alignment.aln
  """
}


# Panaroo
process Pangenome_panaroo {
  conda "panaroo"

  script:
  """
  panaroo -i ${params.path_nextflow_dir}/6.ANNOTATION/*.gff -o ${params.path_nextflow_dir}/10.Pangenome_analysis/10.1.Panaroo --clean-mode strict --alignment pan --aligner mafft
  """
}

# Roary
process Pangenome_Roary {
  conda "roary"

  publishDir "${params.path_nextflow_dir}/10.Pangenome_analysis/10.2.Roary", overwrite: true

  script:
  """
  roary -e --mafft -p 8 ${params.path_nextflow_dir}/6.ANNOTATION/*.gff
  """
}

# CLARC

# unitig-counter
# Note: check output name + path 
process Unitigs {
  conda "unitig-counter"

  publishDir "${params.path_nextflow_dir}/11.Unitigs", overwrite: true

  script:
  """
  for i in ${params.path_nextflow_dir}/5.ASSEMBLIES/*.fasta
  do
    base=$(echo "$i" | cut -d '.' -f1)
    echo -e "$base\t$i"
  done >> strain_list.txt
  unitig-counter -strains strain_list.txt -output output -nb-cores 8
  cdbg-ops extend --graph graph --unitigs unitigs.txt > extended.txt
  """
}


workflow flow1 {
    take: data
    main:
        Trimmomatic(data)
        | FastQC
        | Serotype_MLST
        | SNIPPY
        | ASSEMBLY
        | ANNOTATION
        | FastANI
        | QUAST
        | Filter_out_QC
    emit: Filter_out_QC.out

}

workflow flow2 {
    take: data
    main:
        SNIPPY2()
}

workflow {
  channel.fromFilePairs("${params.path_nextflow_dir}/0.RAW_READS/SRR*_{1,2}.fastq.gz")
         .map { it[0] }
         | flow1
         | collect
         | flow2
}
