data = channel.fromFilePairs("${params.path_to_reads}/0.RAW_READS/SRR*_{1,2}.fastq")
       .map { it[0] }

process foo {
publishDir '/n/holylfs05/LABS/hanage_lab/Lab/hsphfs1/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE/X.foo_out', overwrite: true

input:
  val x

  output:
  path "${x}_file.txt"

  script:
  """
  echo $x > ${x}_file.txt
  """
}


process bar {
publishDir '/n/holylfs05/LABS/hanage_lab/Lab/hsphfs1/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE/X.bar_out', overwrite: true

input:
  path foo_out_files

  output:
  path "Mega_out_file.txt"

  script:
  """
  cat ${foo_out_files}/* > Mega_out_file.txt
  """
}

workflow flow1 {
    take: data
    main:
        foo(data)
    emit: "/n/holylfs05/LABS/hanage_lab/Lab/hsphfs1/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE/X.foo_out"
}

workflow flow2 {
    take: foo_out_path
    main:
        bar(foo_out_path)
}

workflow {
    take: data
    main:
        flow1(data)
        flow2(flow1.out)
}









process foo {
publishDir "${params.path_to_reads}/X.foo_out", overwrite: true

input:
  val x

  output:
  path "${x}_file.txt"

  script:
  """
  echo $x > ${x}_file.txt
  """
}


process bar {
publishDir "${params.path_to_reads}/X.bar_out", overwrite: true

input:
  file x

  output:
  path "Mega_out_file.txt"

  script:
  """
  cat ${params.path_to_reads}/X.foo_out/* > Mega_out_file.txt
  """
}

workflow flow1 {
    take: data
    main:
        foo(data)
    emit: foo.out
}

workflow flow2 {
    take: foo_out_path
    main:
        bar(foo_out_path)
}

workflow {
  channel.fromFilePairs("${params.path_to_reads}/0.RAW_READS/SRR*_{1,2}.fastq")
         .map { it[0] }
         | flow1
         | collect
         | flow2
}




nextflow run Test1.nf --path_to_reads '/n/holylfs05/LABS/hanage_lab/Lab/hsphfs1/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE/0.RAW_READS/SRR*_{1,2}.fastq'
nextflow run Test3.nf --path_to_reads '/n/holylfs05/LABS/hanage_lab/Lab/hsphfs1/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE/0.RAW_READS/SRR*_{1,2}.fastq'

nextflow run Test3.nf --path_to_reads /n/holylfs05/LABS/hanage_lab/Lab/hsphfs1/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE
nextflow run Test5.nf --path_to_reads /n/holylfs05/LABS/hanage_lab/Lab/hsphfs1/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE
nextflow run Test7.nf --path_to_reads /n/holylfs05/LABS/hanage_lab/Lab/hsphfs1/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE


sbatch -p shared -t 0-03:00 --mem=100000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_Test.nf --path_to_reads '/n/holylfs05/LABS/hanage_lab/Lab/hsphfs1/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE/0.RAW_READS/SRR*_{1,2}.fastq'"
sbatch -p shared -t 0-03:00 --mem=100000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_Test2.nf --path_to_reads /n/holylfs05/LABS/hanage_lab/Lab/hsphfs1/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE"
sbatch -p shared -t 0-03:00 --mem=100000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_Test3.nf --path_to_reads /n/holylfs05/LABS/hanage_lab/Lab/hsphfs1/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE"
sbatch -p shared -t 0-03:00 --mem=100000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_Test4.nf --path_to_reads /n/holylfs05/LABS/hanage_lab/Lab/hsphfs1/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE"

sbatch -p shared -t 0-03:00 --mem=100000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_Test4.nf --path_to_reads /n/holylfs05/LABS/hanage_lab/Lab/hsphfs1/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE"
sbatch -p shared -c 10 -t 0-03:00 --mem=100000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_Test4.nf --path_to_reads /n/holylfs05/LABS/hanage_lab/Lab/hsphfs1/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE"


sbatch -p shared -t 0-10:00 --mem=100000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline.nf --path_to_reads /n/holylfs05/LABS/hanage_lab/Lab/hsphfs1/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_RUN"

sbatch -p bigmem -c 6 -t 0-10:00 --mem=1000000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline.nf --path_to_reads /n/holylfs05/LABS/hanage_lab/Lab/hsphfs1/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_RUN"


step 1. Run pipeline for several inputs - DONE
step 2. Run simple pipeline for one file from list of files - DONE
step 3. Run simple pipeline from list of files inside script - DONE
step 3. Run simple pipeline from list of files indicated by path in pipeline parameter - DONE
step 4. Run simple pipeline from list of files indicated by path in pipeline parameter - DONE
step 5. Run simple pipeline with two workflows - DONE
step 6. Input the path to PIPELINE folder as parameter  - DONE
step 7. Run 'augmented' pipeline with two workflows
step 8. Test panaroo one liner on pipeline output
step 9. Integrate panaroo to pipeline (run on 5 samples)
