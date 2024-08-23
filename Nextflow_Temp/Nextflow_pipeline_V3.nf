
process SNIPPY_MULTI {
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
        SNIPPY_MULTI()
}

workflow {
  channel.fromFilePairs("${params.path_nextflow_dir}/0.RAW_READS/SRR*_{1,2}.fastq.gz")
         .map { it[0] }
         | flow1
         | collect
         | flow2
}
