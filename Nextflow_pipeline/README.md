
# Pipeline Description

This Nextflow pipeline was built to intregate the following steps:
<br>   

| Steps  | Description  | Tool |
| ------------- | ------------- | ------------- |
| 1 | Trim sequencing primers  | [Trimmomatic](https://github.com/timflutre/trimmomatic)  |
| 2 | Identify contaminating reads  | [Kraken2](https://github.com/DerrickWood/kraken2) |
| 3 | Remove contaminating reads  | [KrakenTools](https://github.com/jenniferlu717/KrakenTools) |
| 4 | Assemble reads  | [Unicycler](https://github.com/rrwick/Unicycler)  |
| 5 | Determine the serotype of isolates | [GBS-SG](https://github.com/swainechen/GBS-SBG)  |
| 6 | Determine the ST of isolates | [SRST2]()  |
| 7 | Genome Annotation | [Prokka](https://github.com/tseemann/prokka)  |
| 8 | Pangenome Analysis | [Panaroo](https://github.com/gtonkinhill/panaroo)  |
| 9 | Mapping and variant calling | [Snippy](https://github.com/tseemann/snippy)  |
| 10 | Produce a whole genome SNP alignment | [SNP-sites](https://github.com/sanger-pathogens/snp-sites)  |
| 11 | Call unitigs | [Unitig-caller](https://github.com/bacpop/unitig-caller) |
| 12 | Conduct a GWAS using SNPs | [pyseer](https://github.com/mgalardini/pyseer) |
| 13 | Conduct a GWAS using unitigs (i.e. DBGWAS) | [pyseer](https://github.com/mgalardini/pyseer) |
| 14 | Conduct a GWAS using gene presence/absence (i.e. PanGWAS)| [pyseer](https://github.com/mgalardini/pyseer) |
| 15 | Produce a phylogeney | [FastTree](http://www.microbesonline.org/fasttree/) |





# Pipeline Architecture

NEXTFLOW_PIPELINE\
&nbsp;&nbsp;| scripts\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|--- nextflow.config\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|--- Nextflow_pipeline.nf\
&nbsp;&nbsp;| 0.RAW_READS\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|--- *r1.fq.gz\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|--- *r2.fq.gz\
&nbsp;&nbsp;| 1.TRIMMED_READS\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| *_trimmed_1.fq.gz\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| *_trimmed_2.fq.gz\
&nbsp;&nbsp;| 2.KRAKEN\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| *_kraken.out\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| *_report.txt\
&nbsp;&nbsp;| 3.FILTERED_READS\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| *_filtered_1.fq.gz\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| *_filtered_2.fq.gz\
&nbsp;&nbsp;| 4.ASSEMBLIES\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| *.fasta\
&nbsp;&nbsp;| 5.ANNOTATION\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| *.gff3\
&nbsp;&nbsp;| 6.SEROTYPES\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| *_sero.tab\
&nbsp;&nbsp;| 7.MLST\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| *_mlst.tab

# Running the Pipeline

## 1. Create ARCHITECTURE
```
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
```

## 2. Download Raw reads from NCBI
Note: SraAccList.txt contains the list of accessions you want
```
cd 0.RAW_READS
sbatch -p shared -t 1-00:00 --mem=100000 --wrap="prefetch --option-file SraAccList.txt"
for i in *RR*
do
  sbatch -p shared  -t 0-00:10 --mem=10000 --wrap="fasterq-dump --split-files $i/*sra"
done
```

## 3. Install Java 11
```
module load python
conda create -n java      # Only run once to set up; All following times, skip this
conda activate java
conda install openjdk=11  # Only run once to set up; All following times, skip this
java -version             # Check java version
```


## 4. Install Nextflow
```
# Download the executable package:
wget -qO- https://get.nextflow.io | bash   
# Make the binary executable on your system by running:  
chmod +x nextflow  
# Add executable to $PATH                           
nano  ~/.bashrc      
# add line at the end of file:
export PATH="<path_to_nextflow>:$PATH"
# exist file with ctlX and Y
source ~/.bashrc      
```



# 5. Run Nextflow
```
cd NEXTFLOW_PIPELINE/scripts/
for i in ../0.RAW_READS/*_1.fastq
do
 base=$(echo $i | cut -d '/' -f3-3 | cut -d '_' -f1-1)
 sbatch -p shared -t 0-03:00 --mem=100000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline.nf --base $base"
done
```
