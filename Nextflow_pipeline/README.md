
# Pipeline Description

This Nextflow pipeline was built to intregate the following steps:
<br>   

| Steps  | Description  | Tool |
| ------------- | ------------- | ------------- |
| 1 | Trim sequencing primers  | [Trimmomatic](https://github.com/timflutre/trimmomatic)  |
| 2 | Identify contaminating reads  | [Kraken2](https://github.com/DerrickWood/kraken2) |
| 3 | Remove contaminating reads  | [KrakenTools](https://github.com/jenniferlu717/KrakenTools) |
| 4 | Reads Quality Control | [FastQC](https://github.com/s-andrews/FastQC)  |
| 5 | Determine the serotype and ST of isolates | [SRST2](), with [GBS-SG](https://github.com/swainechen/GBS-SBG)  |
| 6 | Mapping to reference genome and variant calling | [Snippy](https://github.com/tseemann/snippy)  |
| 7 | Assemble reads  | [Unicycler](https://github.com/rrwick/Unicycler)  |
| 8 | Genome Annotation | [Prokka](https://github.com/tseemann/prokka)  |
| X | Combine QC results | [MultiQC](https://github.com/MultiQC/MultiQC)  |
| X | Pangenome Analysis | [Panaroo](https://github.com/gtonkinhill/panaroo)  |
| X | Produce a whole genome SNP alignment | [Snippy-core](https://github.com/tseemann/snippy)  |
| X | Call unitigs | [Unitig-caller](https://github.com/bacpop/unitig-caller) |
| X | Conduct a GWAS using SNPs | [pyseer](https://github.com/mgalardini/pyseer) |
| X | Conduct a GWAS using unitigs (i.e. DBGWAS) | [pyseer](https://github.com/mgalardini/pyseer) |
| X | Conduct a GWAS using gene presence/absence (i.e. PanGWAS)| [pyseer](https://github.com/mgalardini/pyseer) |
| X | Produce a phylogeney | [FastTree](http://www.microbesonline.org/fasttree/) |





# Pipeline Architecture

NEXTFLOW_PIPELINE\
&nbsp;&nbsp;| scripts\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|--- nextflow.config\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|--- Nextflow_pipeline.nf\
&nbsp;&nbsp;| Files\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|--- AP018935.1.fa\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|--- GBS-SBG.fasta\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|--- Streptococcus_agalactiae.fasta\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|--- profiles_csv\
&nbsp;&nbsp;| 0.RAW_READS\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|--- *_1.fastq.gz\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|--- *_2.fastq.gz\
&nbsp;&nbsp;| 1.TRIMMED_READS\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| *_trimmed_1.fq.gz\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| *_trimmed_2.fq.gz\
&nbsp;&nbsp;| 2.KRAKEN\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| *_kraken.out\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| *_report.txt\
&nbsp;&nbsp;| 3.FILTERED_READS\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| *_filtered_1.fq.gz\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| *_filtered_2.fq.gz\
&nbsp;&nbsp;| 4.FASTQC\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| *_filtered_1_fastqc.html\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| *_filtered_1_fastqc.zip\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| *_filtered_2_fastqc.html\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| *_filtered_2_fastqc.zip\
&nbsp;&nbsp;| 5.SRST2\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| *__genes__GBS-SBG__results.txt\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| *__mlst__Streptococcus_agalactiae__results.txt\
&nbsp;&nbsp;| 6.SNIPPY\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| *\
&nbsp;&nbsp;| 7.ASSEMBLIES\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| *.fasta\
&nbsp;&nbsp;| 8.ANNOTATION\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| *.gff3\


# Running the Pipeline

## 0. Dependencies


## 1. Create ARCHITECTURE
```
mkdir NEXTFLOW_PIPELINE
cd NEXTFLOW_PIPELINE
  mkdir 0.RAW_READS
  mkdir 1.TRIMMED_READS
  mkdir 2.KRAKEN
  mkdir 3.FILTERED_READS
  mkdir 4.FASTQC
  mkdir 5.SRST2
  mkdir 6.SNIPPY
  mkdir 7.ASSEMBLIES
  mkdir 8.ANNOTATION
  mkdir scripts
  mkdir Files
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

## 5. Run Nextflow
```
for i in ../0.RAW_READS/*_1.fastq.gz
do
 base=$(echo $i | cut -d '/' -f3-3 | cut -d '_' -f1-1)
 sbatch -p shared -t 0-03:00 --mem=100000 --wrap="nextflow -C nextflow.config run Nextflow_pipeline.nf --path_to_reads /n/holylfs05/LABS/hanage_lab/Lab/hsphfs1/lcavalli/GBS-GWAS-CDC-EOD-LOD/NEXTFLOW_PIPELINE --base $base"
done
```

## 6. Post-pipeline steps
### Genome quality control
Tool: MultiQC
Output: One QC report for all samples in our dataset
```
# Install MultiQC
conda create -n multiqc
source activate multiqc
conda install multiqc

# Run MultiQC
cd NEXTFLOW_PIPELINE/4.FASTQC
sbatch -p shared  -t 0-03:00 --mem=100000 --wrap="multiqc ."
```
### Merge Snippy results
Tool: snippy-core
Output:  Whole genome SNP alignment
```
# Install Snippy
source activate snippy
# Run Snippy
cd NEXTFLOW_PIPELINE/6.SNIPPY
sbatch -p shared -t 0-02:00 --mem=100000 --wrap="snippy-core --ref 'SRR5063682/ref.fa' SRR*"
```
### Pangenome analysis
Tool: panaroo
Output: Gene Presence/Absence matrix for input into Pyseer
```
# Install Panaroo
conda create -n Panaroo python=3.9
source activate Panaroo
conda install -c conda-forge -c bioconda -c defaults 'panaroo>=1.3'

# Run Panaroo
cd NEXTFLOW_PIPELINE/8.ANNOTATION
mkdir panaroo_results
sbatch -p shared -t 0-05:00 --mem=100000 --wrap="panaroo -i *.gff -o panaroo_results --clean-mode strict --alignment pan --aligner mafft"
```
### Unitig calling
Tool: unitig-counter
Output: Unitig list file for input into Pyseer
```
# Install unitig-counter
conda create -n unitig-counter
source activate unitig-counter
conda install unitig-counter

# Create input file
cd NEXTFLOW_PIPELINE/7.ASSEMBLIES
echo -e "ID\tPath" > strain_list.txt
for i in *.fasta
do
  base=$(echo "$i" | cut -d '.' -f1)
  echo -e "$base\t$i"
done >> strain_list.txt

# Run unitig-counter
sbatch -p shared -c 8 -t 0-05:00 --mem=100000 --wrap="unitig-counter -strains strain_list.txt -output output -nb-cores 8"

# Extend short unitigs leftwards and rightwards by following the neightbouring nodes in the de Bruijn graph
sbatch -p shared -c 8 -t 0-05:00 --mem=100000 --wrap="cdbg-ops extend --graph graph --unitigs unitigs.txt > extended.txt"
```
### Phylogeny - FastTree
Tool: FastTree
```
# install FastTree
curl -O http://www.microbesonline.org/fasttree/FastTree.c
gcc -O3 -finline-functions -funroll-loops -Wall -o FastTree FastTree.c -lm

# Run
cd NEXTFLOW_PIPELINE/7.ASSEMBLIES
sbatch -p shared -t 0-02:00 --mem=100000 --wrap="FastTree -gtr -nt core.full.aln > phylo.aln"

```
### GWAS
Tool: pyseer
```
#installation
conda -n create pyseer
source activate pyseer
conda install pyseer

#create phylogeny tsv file
python scripts/phylogeny_distance.py --lmm core_genome_aln.tree > phylogeny_K.tsv
```

#### SNP-based GWAS
```
pyseer --phenotypes phenotypes --vcf core.vcf --lmm --similarity phylogeny_K.tsv > EOD_LOD_SNPs.txt
```
#### Pan-GWAS
```
pyseer --phenotypes phenotypes --pres gene_presence_absence.Rtab --lmm --similarity phylogeny_K.tsv > EOD_LOD_COGs.txt
```
#### Unigit-based GWAS (DBGWAS)
```

```
