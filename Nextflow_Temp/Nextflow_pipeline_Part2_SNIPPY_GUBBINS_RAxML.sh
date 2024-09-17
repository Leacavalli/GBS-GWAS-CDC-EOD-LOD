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

process SNIPPY_MULTI {
  conda "snippy"

  publishDir "${params.path_nextflow_dir}/9.SNIPPY_MULTI", overwrite: true

  output:
  path "core.aln"
  path "core.full.aln"
  path "core.tab"
  path "core.vcf"
  path "core.txt"
  path "core.ref.fa"
  path "clean.full.aln"

  script:
  """
  snippy-core --ref ${params.path_nextflow_dir}/Files/AP018935.1.fa ${params.path_nextflow_dir}/6.SNIPPY/SRR*
  snippy-clean_full_aln core.full.aln > clean.full.aln
  """
}

process GUBBINS {
  conda "gubbins"

  publishDir "${params.path_nextflow_dir}/10.GUBBINS", overwrite: true

  input:
  val a
  val b
  val c
  val d
  val e
  val f
  val g

  output:
  path "GBS_GWAS.recombination_predictions.embl"
  path "GBS_GWAS.recombination_predictions.gff"
  path "GBS_GWAS.branch_base_reconstruction.embl"
  path "GBS_GWAS.summary_of_snp_distribution.vcf"
  path "GBS_GWAS.per_branch_statistics.csv"
  path "GBS_GWAS.filtered_polymorphic_sites.fasta"
  path "GBS_GWAS.filtered_polymorphic_sites.phylip"
  path "GBS_GWAS.final_tree.tre"
  path "GBS_GWAS.node_labelled.final_tree.tre"
  path "GBS_GWAS.log"

  script:
  """
  run_gubbins.py -p GBS_GWAS ${params.path_nextflow_dir}/9.SNIPPY_MULTI/clean.full.aln
  """
}

process RAxML {
  publishDir "${params.path_nextflow_dir}/11.RAxML", overwrite: true

  input:
  val a
  val b
  val c
  val d
  val e
  val f
  val g
  val h
  val i
  val j

  output:
  path "RAxML_bestTree.GBS_GWAS"
  path "RAxML_bipartitionsBranchLabels.GBS_GWAS"
  path "RAxML_bipartitions.GBS_GWAS"
  path "RAxML_bootstrap.GBS_GWAS"
  path "RAxML_info.GBS_GWAS"

  script:
  """
  # 1. Create a partition file with 1 partition of length of the Core SNP alignment (containing only variant sites)
  variant_sites=\$(head -2 ${params.path_nextflow_dir}/9.SNIPPY_MULTI/core.aln | tail -1 | wc -c)
  echo "[asc~\${params.path_nextflow_dir}/11.RAxML/p1_fel.txt], ASC_DNA, prt1 = 1-\$variant_sites" > ${params.path_nextflow_dir}/11.RAxML/part1.txt

  # 2. Create a Felsenstein correction input file displaying the number of invariant sites
  echo "2263191,\$variant_sites" | tr ',' '-' | bc > ${params.path_nextflow_dir}/11.RAxML/p1_fel.txt

  # 3. Run RAxML
  raxmlHPC-PTHREADS-SSE3 -s ${params.path_nextflow_dir}/10.GUBBINS/GBS_GWAS.filtered_polymorphic_sites.fasta -T 48 -m ASC_GTRGAMMA --asc-corr=felsenstein ­-q ${params.path_nextflow_dir}/11.RAxML/part1.txt -N 100 -p 1234 -f t -t ${params.path_nextflow_dir}/10.GUBBINS/GBS_GWAS.final_tree.tre -n GBS_GWAS
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
        SNIPPY_MULTI()
        | GUBBINS
        | RAxML
}

workflow {
  channel.fromFilePairs("${params.path_nextflow_dir}/0.RAW_READS/SRR*_{1,2}.fastq.gz")
         .map { it[0] }
         | flow1
         | collect
         | flow2
}
