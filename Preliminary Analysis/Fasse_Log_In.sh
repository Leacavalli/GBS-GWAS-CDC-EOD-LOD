

cd /n/hanage_gbs_gwas_l3/Lab

#Install Nextflow Pipeline

git clone https://github.com/Leacavalli/GBS-GWAS-pipeline.git
cd GBS-GWAS-pipeline/Nextflow_pipeline/


#Install Java


module load python
conda create -n java      # Only run once to set up; All following times, skip this
source activate java
conda install -c conda-forge openjdk=17 #Updated to java 17 for nextflow compatability 
java -version             # Check java version
deactivate java             


#Install Nextflow Executable

cd scripts 

# Download the executable package:
wget -qO- https://get.nextflow.io | bash   
# Make the binary executable on your system by running:  
chmod +x nextflow  
# Add executable to $PATH                           
nano  ~/.bashrc      
# add line at the end of file:
export PATH="/n/hanage_gFs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline/scripts:$PATH"
# exist file with ctlX and Y
source ~/.bashrc     

#Install Trimmomatic

cd Files
wget https://github.com/usadellab/Trimmomatic/files/5854859/Trimmomatic-0.39.zip
unzip Trimmomatic-0.39.zip
java -jar Trimmomatic-0.39/trimmomatic-0.39.jar -h

#Install Unicycler

module load python
conda create -n  unicycler   
source activate unicycler
conda install bioconda::unicycler

#Install FastTree

cd Files
curl -O http://www.microbesonline.org/fasttree/FastTree.c
gcc -O3 -finline-functions -funroll-loops -Wall -o FastTree FastTree.c -lm
chmod +x FastTree
./FastTree -h

#Install RAxML-NG

module load python
conda create -n raxml-ng
source activate raxml-ng
conda install -c bioconda raxml-ng
raxml-ng -h

#Install ROARY

conda create -n roary
source activate roary
conda config --add channels r
conda config --add channels defaults
conda config --add channels conda-forge
conda config --add channels bioconda
conda install roary

#Install CLARC

cd Files
git clone https://github.com/IndraGonz/CLARC.git
chmod -R u+w CLARC
cd CLARC
module load python
conda env create --file envs/clarc_env.yml
source activate clarc_env
python setup.py install
clarc -h
conda deactivate

#Install Pyseer 

cd Files
git clone https://github.com/mgalardini/pyseer


#Download Accessions

#Download netherlands data

while read acc; do sbatch -p fasse -t 0-12:00 --mem=10000 --wrap="prefetch $acc -O . || echo $acc >> ./failed_downloads.txt"; done < /n/hanage_gbs_gwas_l3/Lab/ErrAccList_Netherlands.txt

for i in *RR*
do
  sbatch -p fasse -t 0-00:10 --mem=10000 --wrap="fasterq-dump --split-files $i/*sra"
done

for file in *.fastq; do
    sbatch -p fasse -t 0-12:00 --mem=10000 --wrap="gzip $file"
done
