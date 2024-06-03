# Pipeline Description:

# Pipeline Architecture:

NEXTFLOW_PIPELINE__
  | scripts__
      |--- nextflow.config__
      |--- Nextflow_pipeline.nf
  | 0.RAW_READS
      |--- *r1.fq.gz
      |--- *r2.fq.gz
  | 1.TRIMMED_READS
      | *_trimmed_1.fq.gz
      | *_trimmed_2.fq.gz
  | 2.KRAKEN
      | *_kraken.out
      | *_report.txt
  | 3.FILTERED_READS
      | *_filtered_1.fq.gz
      | *_filtered_2.fq.gz
  | 4.ASSEMBLIES
      | *.fasta
  | 5.ANNOTATION
      | *.gff3
  | 6.SEROTYPES
      | *_sero.tab
  | 7.MLST
      | *_mlst.tab

# Steps to run the Pipeline:

## 1. Create ARCHITECTURE
mkdir NEXTFLOW_PIPELINE
cd NEXTFLOW_PIPELINE
  mkdir 0.RAW_READS
  mkdir 1.TRIMMED_READS
  mkdir 2.KRAKEN
  mkdir 3.FILTERED_READS
  mkdir 4.ASSEMBLIES
  mkdir 5.ANNOTATION
  mkdir 6.SEROTYPES
  mkdir 7.MLST
  mkdir scripts

## 2. Download Raw reads from NCBI
# SraAccList.txt contains the list of accessions you want
cd 0.RAW_READS
sbatch -p shared -t 1-00:00 --mem=100000 --wrap="prefetch --option-file SraAccList.txt"
for i in *RR*
do
 sbatch -p shared  -t 0-00:10 --mem=10000 --wrap="fasterq-dump --split-files $i/*sra"
done


# 3. Install Java 11
 # Installation
 module load python
 # conda create -n java  # Only run once to set up; All following times, skip this
 conda activate java
 # conda install openjdk=11  # Only run once to set up; All following times, skip this
 java -version


# 4. Install Nextflow
# Download the executable package
wget -qO- https://get.nextflow.io | bash
# Make the binary executable on your system by running
chmod +x nextflow
# Remember the full path to nextflow
cd /home/leacavalli
cd /n/holylfs05/LABS/hanage_lab/Lab/holyscratch01/lcavalli/Software
# Add executable to $PATH
nano  ~/.bashrc
# add line at the end of file: export PATH="/home/leacavalli:$PATH"
# add line at the end of file: export PATH="/n/holylfs05/LABS/hanage_lab/Lab/holyscratch01/lcavalli/Software:$PATH"
# exist file with ctlX and Y
source ~/.bashrc


# 5. Run Nextflow
cd NEXTFLOW_PIPELINE/scripts/

for i in ../0.RAW_READS/*_1.fastq
do
 base=$(echo $i | cut -d '/' -f3-3 | cut -d '_' -f1-1)
 sbatch -p shared -t 0-03:00 --mem=100000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline.nf --base $base"
done


for i in ../0.RAW_READS/*_1.fastq
do
 base=$(echo $i | cut -d '/' -f3-3 | cut -d '_' -f1-1)
 sbatch -p shared -t 0-03:00 --mem=100000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline_V1.nf --base $base"
done
