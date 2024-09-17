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

process PanGWAS_Roary_RAxML {
  conda "pyseer"

  input:
  val base


  script:
  """
  # create output folders
  mkdir -p ${params.path_nextflow_dir}/16.Pyseer
  mkdir -p ${params.path_nextflow_dir}/16.Pyseer/16.3.Subanalysis_2

  # Run Pyseer
  pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --pres ${params.path_nextflow_dir}/14.Pangenome_analysis/14.2.ROARY/gene_presence_absence.Rtab --similarity ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/RAxML_phylogeny_K.tsv --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.3.Subanalysis_2/PanGWAS_Roary_RAxML.txt
  """
}

process PanGWAS_Panaroo_CLARC_RAxML {
  conda "pyseer"

  input:
  val base


  script:
  """
  # create output folders
  mkdir -p ${params.path_nextflow_dir}/16.Pyseer
  mkdir -p ${params.path_nextflow_dir}/16.Pyseer/16.3.Subanalysis_2

  # Make gene presence/absence input (convert CLARC .csv output to Rtab)
  awk 'BEGIN {FS=OFS=","} NR==1 {\$1="Gene" \$1} 1' ${params.path_nextflow_dir}/14.Pangenome_analysis/14.3.Panaroo_CLARC/Output/clarc_results/clarc_condensed_presence_absence.csv | awk '
   {
       for (i=1; i<=NF; i++)  {
           a[NR,i] = \$i
       }
   }
   NF>p { p = NF }
   END {
       for (i=1; i<=p; i++) {
           for (j=1; j<=NR; j++) {
               printf "%s%s", a[j,i], (j==NR ? "\\n" : "\\t")
           }
       }
   }
   ' FS=',' OFS='\\t' > ${params.path_nextflow_dir}/14.Pangenome_analysis/14.3.Panaroo_CLARC/Output/clarc_results/clarc_condensed_presence_absence.Rtab


  # Run Pyseer
  pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --pres ${params.path_nextflow_dir}/14.Pangenome_analysis/14.3.Panaroo_CLARC/Output/clarc_results/clarc_condensed_presence_absence.Rtab --similarity ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/RAxML_phylogeny_K.tsv --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.3.Subanalysis_2/PanGWAS_Panaroo_CLARC_RAxML.txt
  """
}

process PanGWAS_Roary_CLARC_RAxML {
  conda "pyseer"

  input:
  val base


  script:
  """
  # create output folders
  mkdir -p ${params.path_nextflow_dir}/16.Pyseer
  mkdir -p ${params.path_nextflow_dir}/16.Pyseer/16.3.Subanalysis_2

  # Make gene presence/absence input (convert CLARC .csv output to Rtab)
  awk 'BEGIN {FS=OFS=","} NR==1 {\$1="Gene" \$1} 1' ${params.path_nextflow_dir}/14.Pangenome_analysis/14.4.ROARY_CLARC/Output/clarc_results/clarc_condensed_presence_absence.csv | awk '
   {
       for (i=1; i<=NF; i++)  {
           a[NR,i] = \$i
       }
   }
   NF>p { p = NF }
   END {
       for (i=1; i<=p; i++) {
           for (j=1; j<=NR; j++) {
               printf "%s%s", a[j,i], (j==NR ? "\\n" : "\\t")
           }
       }
   }
   ' FS=',' OFS='\\t' > ${params.path_nextflow_dir}/14.Pangenome_analysis/14.4.ROARY_CLARC/Output/clarc_results/clarc_condensed_presence_absence.Rtab

  # Run Pyseer
  pyseer --lmm --phenotypes ${params.path_nextflow_dir}/Files/phenotypes.txt --pres ${params.path_nextflow_dir}/14.Pangenome_analysis/14.4.ROARY_CLARC/Output/clarc_results/clarc_condensed_presence_absence.Rtab --similarity ${params.path_nextflow_dir}/16.Pyseer/16.1.Main_analysis/RAxML_phylogeny_K.tsv --cpu 8 > ${params.path_nextflow_dir}/16.Pyseer/16.3.Subanalysis_2/PanGWAS_Roary_CLARC_RAxML.txt
  """
}


workflow flow1 {
    take: data
    main:
        TEST(data)
    emit: TEST.out
}

workflow flow4 {
    take: data
    main:
    PanGWAS_Roary_RAxML(data)
    PanGWAS_Panaroo_CLARC_RAxML(data)
    PanGWAS_Roary_CLARC_RAxML(data)
}

workflow {
  channel.fromFilePairs("${params.path_nextflow_dir}/0.RAW_READS/SRR*_{1,2}.fastq.gz")
         .map { it[0] }
         | flow1
  flow4(flow1.out.collect)
}
