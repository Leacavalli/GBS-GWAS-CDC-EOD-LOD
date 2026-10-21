
#snpEff test for Pipeline 1 


#Install conda environment 

conda create -n snpeff
source activate snpeff 
conda install bioconda::snpeff
snpEff -h

#Create snp eff data directory and copy reference sequences

cp /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/Files/AP018935.1.fa  \
   /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/SNPEFF_TEST/snpeff_data/data/AP018935.1/sequences.fa
cp /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/Files/AP018935.1.gff3 \
   /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/SNPEFF_TEST/snpeff_data/data/AP018935.1/genes.gff




#Add data.dir = /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/SNPEFF_TEST/snpeff_data/data and AP018935.1.genome : AP018935.1 to snpEff.config file 

#Build snpEff DB

JAR=$(ls "$CONDA_PREFIX"/share/snpeff-*/snpEff.jar | head -n1)

java -Xmx6g -jar "$JAR" \
  build -v -gff3 \
  -noCheckCds -noCheckProtein \
  -config /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/SNPEFF_TEST/snpeff_data/snpEff.config \
  -configOption data.dir=/n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/SNPEFF_TEST/snpeff_data/data \
  AP018935.1 2>&1 | tee /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/SNPEFF_TEST/build_AP018935.1.log

#One line example

snpEff -Xmx4g -noDownload \
  -c /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/SNPEFF_TEST/snpeff_data/snpEff.config \
  -v AP018935.1 \
  /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/4.SNIPPY/SRR29447093/snps.vcf \
  | gzip -c > /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/SNPEFF_TEST/SRR29447093.ann.vcf.gz


# Check size of annotated file

ls -lh /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/SNPEFF_TEST/SRR29447093.ann.vcf.gz


#Create list of snps.vcf file paths

SNIPPY_DIR=/n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/4.SNIPPY
cd "$SNIPPY_DIR"
ls -d "$SNIPPY_DIR"/SRR*/snps.vcf 2>/dev/null | sort > /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/SNPEFF_TEST/vcf_list.txt
wc -l /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/SNPEFF_TEST/vcf_list.txt

#Submit batch job per vcf file

while read -r VCF; do sample=$(basename "$(dirname "$VCF")"); sbatch --export=ALL,VCF="$VCF",SAMPLE="$sample" <<'EOS'
#!/bin/bash
#SBATCH -p fasse
#SBATCH -c 1
#SBATCH -t 0-02:00
#SBATCH --mem=8000
#SBATCH -J snpeff
#SBATCH -o /dev/null
#SBATCH -e /dev/null

set -euo pipefail

CFG=/n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/SNPEFF_TEST/snpeff_data/snpEff.config
GENOME=AP018935.1
OUTDIR=/n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/SNPEFF_TEST
LOGDIR="$OUTDIR/logs"
OUTVCF="$OUTDIR/${SAMPLE}.ann.vcf.gz"

mkdir -p "$OUTDIR" "$LOGDIR"

# Route all script output to per-sample logs
exec >"$LOGDIR/${SAMPLE}.out" 2>"$LOGDIR/${SAMPLE}.err"

echo "[$(date)] Annotating \$SAMPLE"
echo "VCF=\$VCF"
echo "Config=\$CFG  Genome=\$GENOME  Output=\$OUTVCF"

snpEff -Xmx4g -noDownload -c "$CFG" -v "$GENOME" "$VCF" | gzip -c > "$OUTVCF"

echo "[$(date)] Done \$SAMPLE"
EOS
done < /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/SNPEFF_TEST/vcf_list.txt


#Summarize across results

cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/SNPEFF_TEST
for f in /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/SNPEFF_TEST/*.ann.vcf.gz; do sample=$(basename "$f" .ann.vcf.gz); zgrep -h "ANN=" "$f" | sed 's/.*ANN=//' | sed 's/;.*//' | tr ',' '\n' | awk -F'|' 'NF>1 {print $2}' | sed '/^$/d' | sort | uniq -c | awk -v s="$sample" '{print s "\t" $2 "\t" $1}'; done > /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/SNPEFF_TEST/snpeff_effect_counts_per_sample.tsv
