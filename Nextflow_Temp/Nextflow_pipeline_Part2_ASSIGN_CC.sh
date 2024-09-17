
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


process ASSIGN_CC {
  script:
  """
  # Create Output Directory
  mkdir -p ${params.path_nextflow_dir}/11.ASSIGN_CC

  # Append all results from mlst to a single file
  awk '(NR == 1) || (FNR > 1)' ${params.path_nextflow_dir}/5.SEROTYPE_MLST/*__mlst__Streptococcus_agalactiae__results.txt > ${params.path_nextflow_dir}/5.SEROTYPE_MLST/combined_results.txt
  cut -f1,2 ${params.path_nextflow_dir}/5.SEROTYPE_MLST/combined_results.txt  | tail -n +2  | sed 's/\t/,/g' | sort -t',' -k2,2  > ${params.path_nextflow_dir}/11.ASSIGN_CC/STs.txt

  # Define the file paths
  cut -d',' -f1,9 ${params.path_nextflow_dir}/Files/GBS_CC_BIGSdb_2798265_4857213195_63187.csv | tail -n +2  | sort -t',' -k1,1 > ${params.path_nextflow_dir}/11.ASSIGN_CC/GBS_ST_CC_ref.txt

  # Process the files and join them based on the 'ST' column
  echo "ST,Sample,clonal_complex" > ${params.path_nextflow_dir}/11.ASSIGN_CC/combined_results_with_cc.txt
  join -t',' -1 2 -2 1 -a 1 -e 'NA' -o 1.2,1.1,2.2 ${params.path_nextflow_dir}/11.ASSIGN_CC/STs.txt ${params.path_nextflow_dir}/11.ASSIGN_CC/GBS_ST_CC_ref.txt -a1  >> ${params.path_nextflow_dir}/11.ASSIGN_CC/combined_results_with_cc.txt
  """
}


workflow flow1 {
  take: data
  main:
    TEST(data)
  emit:
    TEST.out
}

workflow flow2 {
  take: data
  main:
    ASSIGN_CC()
}

workflow {
  channel.fromFilePairs("${params.path_nextflow_dir}/0.RAW_READS/SRR*_{1,2}.fastq.gz")
         .map { it[0] }
         | flow1
         | collect
         | flow2
}
