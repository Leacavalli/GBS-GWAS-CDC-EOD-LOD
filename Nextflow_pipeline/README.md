This Nextflow pipeline was built to intregate the following steps:
```{r table1, tidy=FALSE}
library(tidyverse)
data1 <- tribble(
  ~"Column 1",                                ~"Column 2",
  "lorem ipsum dolor",                        "sit amet, consectetur",
  "adipisci elit, sed eiusmod tempor",        "incidunt ut labore et dolore magna aliqua"
)
knitr::kable((data1), booktabs = TRUE,
caption = 'A test table.')
```
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
