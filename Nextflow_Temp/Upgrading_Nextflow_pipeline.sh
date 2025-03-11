# Test pipeline
module load python
source activate java
sbatch -p sapphire -c 112 -t 3-00:00 --mem=990000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf --main --path_nextflow_dir /n/netscratch/hanage_lab/Lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline/Nextflow_pipeline_CDC_Netherlands --path_conda_envs /n/home02/lcavalli/.conda/envs"

sbatch -p sapphire -c 112 -t 3-00:00 --mem=990000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf -resume --main --path_nextflow_dir /n/netscratch/hanage_lab/Lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline/Nextflow_pipeline_CDC_Netherlands --path_conda_envs /n/home02/lcavalli/.conda/envs"


module load python
source activate java
sbatch -p sapphire -c 112 -t 3-00:00 --mem=990000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf -resume --main --sub1 --sub2 --sub3 --path_nextflow_dir /n/netscratch/hanage_lab/Lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline/Nextflow_pipeline_CDC --path_conda_envs /n/home02/lcavalli/.conda/envs"


module load python
source activate java
sbatch -p test -c 10 -t 0-06:00 --mem=100000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf --main --path_nextflow_dir /n/netscratch/hanage_lab/Lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline/Nextflow_pipeline_CDC_Netherlands --path_conda_envs /n/home02/lcavalli/.conda/envs"

module load python
source activate java
sbatch -p shared -c 10 -t 0-06:00 --mem=100000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf --main --path_nextflow_dir /n/netscratch/hanage_lab/Lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline/Nextflow_pipeline_QUAST_test --path_conda_envs /n/home02/lcavalli/.conda/envs"


sbatch -p test -c 1 -t 0-01:00 --mem=100000 --wrap="quast -o ERR1624738.quast.out /n/netscratch/hanage_lab/Lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline/Nextflow_pipeline_CDC_Netherlands/scripts/work/9b/327c08454c066ebe49784f0da716ea/ERR1624738.fasta"
sbatch -p sapphire -c 112 -t 3-00:00 --mem=990000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf --main --sub1 --sub2 --sub3 --path_nextflow_dir /n/netscratch/hanage_lab/Lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline/Nextflow_pipeline --path_conda_envs /n/home02/lcavalli/.conda/envs"


sbatch -p test -c 112 -t 0-12:00 --mem=100000 --wrap="nextflow -C nextflow.config run Test.nf -resume --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_18 --path_conda_envs /n/home02/lcavalli/.conda/envs"


sbatch -p intermediate -c 112 -t 14-00:00 --mem=990000 --wrap="nextflow -C nextflow.config run Test_Main_Analysis.nf --path_nextflow_dir /n/holyscratch01/hanage_lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE_Upgrade_500_TEST2 --path_conda_envs /n/home02/lcavalli/.conda/envs"

source activate poppunk
sbatch -p test -c 8 -t 0-01:00 --mem=50000 --wrap="poppunk --create-db --output GBS_GWAS_db --r-files qfile.txt --threads 8"
# 2. Run QC on the database
sbatch -p test -c 8 -t 0-01:00 --mem=50000 --wrap="poppunk --qc-db --ref-db GBS_GWAS_db --length-range 1500000 2500000  --max-zero-dist 1 --threads 8"
# 3. Fit a model, check cluster (core+accessory)
sbatch -p test -c 8 -t 0-01:00 --mem=50000 --wrap="poppunk --fit-model dbscan --ref-db GBS_GWAS_db --threads 8"
# 4. Fit a model, check cluster (core only)
sbatch -p test -c 8 -t 0-01:00 --mem=50000 --wrap="poppunk --fit-model refine --ref-db GBS_GWAS_db --threads 8 --indiv-refine core"

../scripts/work/conda/env-8ba28aee9bac5e0403e9d1764933556d/bin/poppunk

source activate java
sbatch -p test -c 8 -t 0-01:00 --mem=100000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_TEXT_POPPUNK.nf --path_nextflow_dir /n/netscratch/hanage_lab/Lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline/Nextflow_pipeline_100"

Nextflow_pipeline_TEXT_POPPUNK.nf

process POPPUNK {
  cpus 8

  conda "poppunk=2.7.2"

  publishDir "${params.path_nextflow_dir}/9.POPPUNK", overwrite: true


  script:
  """
  # Prepare input file
  mkdir -p ${params.path_nextflow_dir}/9.POPPUNK
  for i in ${params.path_nextflow_dir}/5.ASSEMBLIES/*fasta
  do
  sample=\$(basename \$i | cut -d '.' -f1-1)
  echo -e "\$sample\t\$i"
  done > ${params.path_nextflow_dir}/9.POPPUNK/qfile.txt

  # Run
  # 1. Create sketch database
  poppunk --create-db --output ${params.path_nextflow_dir}/9.POPPUNK/GBS_GWAS_db --r-files ${params.path_nextflow_dir}/9.POPPUNK/qfile.txt --threads 8
  # 2. Run QC on the database
  poppunk --qc-db --ref-db ${params.path_nextflow_dir}/9.POPPUNK/GBS_GWAS_db --length-range 1500000 2500000  --max-zero-dist 1 --threads 8
  # 3. Fit a model, check cluster (core+accessory)
  poppunk --fit-model dbscan --ref-db ${params.path_nextflow_dir}/9.POPPUNK/GBS_GWAS_db --threads 8
  # 4. Fit a model, check cluster (core only)
  poppunk --fit-model refine --ref-db ${params.path_nextflow_dir}/9.POPPUNK/GBS_GWAS_db --threads 8 --indiv-refine core
  # Keep only the samples with classified SC for pyseer
  tail -n +2 ${params.path_nextflow_dir}/9.POPPUNK/GBS_GWAS_db/GBS_GWAS_db_core_clusters.csv | cut -d ',' -f1 | sort > sorted_file1.csv
  cut -f1 ${params.path_nextflow_dir}/Files/phenotypes.txt | sort > sorted_file2.csv
  comm -3 sorted_file1.csv  sorted_file2.csv | sed 's/\t//g' > removed_samples.txt
  grep -v -F -f removed_samples.txt ${params.path_nextflow_dir}/Files/phenotypes_filtered.txt > ${params.path_nextflow_dir}/Files/phenotypes_filtered_SC.txt
  """
}


workflow {
 POPPUNK()
}

# Test pipeline
module load python
source activate java
sbatch -p sapphire -c 100 -t 1-00:00 --mem=990000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_FINAL.nf --main --sub1 --sub2 --path_nextflow_dir /n/netscratch/hanage_lab/Lab/lcavalli/GBS-GWAS-CDC-EOD-LOD/GBS-GWAS-pipeline/Nextflow_pipeline_10 --path_conda_envs /n/home02/lcavalli/.conda/envs"


sbatch -p test -c 1 -t 0-12:00 --mem=100000 --wrap="panaroo -t 8 -i 6.ANNOTATION/*.gff -o 13.Pangenome_analysis/13.1.Panaroo --clean-mode strict --alignment pan --aligner mafft"
mkdir -p 9.POPPUNK
for i in 5.ASSEMBLIES/*fasta
do
sample=$(basename $i | cut -d '.' -f1-1)
echo -e "$sample\t$i"
done > 9.POPPUNK/qfile.txt

sbatch -p test -c 1 -t 0-12:00 --mem=100000 --wrap="poppunk --create-db --output 9.POPPUNK/GBS_GWAS_db --r-files 9.POPPUNK/qfile.txt --threads 8"


# Extract the paired end reads
for i in */*.aligned.fa
do
  base=$(echo $i | cut -d '/' -f1-1)
  mv $base DONE
done

for i in ../1.TRIMMED_READS/*_trimmed_1.fq.gz
do
  base=$(echo $i | cut -d '/' -f3-3 | cut -d '_' -f1-1)
 sbatch -p shared -c 1 -t 0-00:15 --mem=10000 --wrap="snippy --outdir ../4.SNIPPY/$base --R1 ../1.TRIMMED_READS/$base\_trimmed_1.fq.gz --R2 ../1.TRIMMED_READS/$base\_trimmed_2.fq.gz --ref ../Files/AP018935.1.fa"
done


mkdir 10.SNIPPY_MULTI
cd 10.SNIPPY_MULTI
sbatch -p shared -c 1 -t 0-00:10 --mem=10000 --wrap="snippy-core --ref ../Files/AP018935.1.fa --prefix core_outgroup ../4.SNIPPY/*"
sbatch -p shared -c 1 -t 0-00:10 --mem=10000 --wrap="snippy-clean_full_aln core_outgroup.full.aln > clean_outgroup.full.aln"


mkdir 4.Phylogeny
cd 4.Phylogeny
sbatch -p test -t 0-12:00 --mem=100000 --wrap="../Files/FastTree -gtr -nt ../10.SNIPPY_MULTI/clean_outgroup.full.aln > BCH_GBS_FastTree.tre"


sbatch -p test -t 0-12:00 --mem=100000 --wrap="../Files/FastTree -gtr -nt ../10.SNIPPY_MULTI/clean_outgroup.full.aln > BCH_GBS_FastTree.tre"

source activate raxml-ng
sbatch -p sapphire -t 0-12:00 -c 112 -t 3-00:00 --mem=990000 --wrap="raxml-ng --msa ../10.SNIPPY_MULTI/clean_outgroup.full.aln --model GTR+G --threads 112 --seed 12345 --prefix T1"
