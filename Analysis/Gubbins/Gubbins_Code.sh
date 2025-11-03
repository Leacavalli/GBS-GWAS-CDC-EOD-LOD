# Remove recombination
module load python
# conda create -n gubbins
source activate gubbins
#conda config --add channels r
#conda config --add channels defaults
#conda config --add channels conda-forge
#conda config --add channels bioconda
#conda install gubbins
gubbins -h


# Full alignment
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/Fulltree_Gubbins
../seqtk/seqtk subseq ../../11.SNIPPY_MULTI/clean.full.aln Full_samples.txt > Full.fasta
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/Fulltree_Gubbins/gubbins_fulltree_out --threads 48 --starting-tree /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/12.Phylogeny/12.1.FastTree_DP/EOD_LOD_VLOD_CDC_FastTree_DP.tre --model GTRGAMMA Full.fasta"
# FAILED - STOP RUNNING WITHOUT ERROR MESSAGE...

# Full alignment - no start tree
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/Fulltree_nostarttree
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix gubbins_fulltree_nostarttree --threads 48 --model GTRGAMMA /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/11.SNIPPY_MULTI/clean.full.aln"
## Run Pyseer with the recombination-free tree
source activate pyseer
sbatch -p fasse -t 0-12:00 --mem=50000 --wrap="python ../../../Files/pyseer/scripts/phylogeny_distance.py --lmm ../gubbins_fulltree_nostarttree.node_labelled.final_tree.tre > full_gubbins_tree_K.tsv"
sbatch -p fasse -t 0-12:00 --mem=100000 --wrap="pyseer --lmm --phenotypes ../../../Files/phenotypes_filtered.txt --phenotype-column binary --vcf ../../../11.SNIPPY_MULTI/merged_max5missing.vcf --similarity full_gubbins_tree_K.tsv > SNPGWAS_gubbins.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --lmm --phenotypes ../../../Files/phenotypes_filtered.txt  --phenotype-column binary --kmers ../../../14.UNITIGS/unitigs.txt --uncompressed --similarity full_gubbins_tree_K.tsv > DBGWAS_gubbins.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="pyseer --min-af 0.05 --max-af 0.95 --lmm --phenotypes ../../../Files/phenotypes_filtered.txt --phenotype-column binary --pres ../../../13.Pangenome_analysis/13.1.Panaroo/gene_presence_absence.Rtab --similarity full_gubbins_tree_K.tsv > PanGWAS_gubbins.txt"
sbatch -p fasse -t 0-01:00 --mem=10000 --wrap="annotate_hits_pyseer DBGWAS_gubbins.txt ../../../Files/DBGWAS_references.txt DBGWAS_gubbins_annotation.txt"

# Need to subset to each major SC ?
## SC1
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC1
../seqtk/seqtk subseq ../../11.SNIPPY_MULTI/clean.full.aln SC1_Samples.txt > SC1.fasta
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix gubbins_SC1_out --threads 48 --model GTRGAMMA SC1.fasta"

## SC2
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC2
../seqtk/seqtk subseq ../../11.SNIPPY_MULTI/clean.full.aln SC2_Samples.txt > SC2.fasta
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix gubbins_SC2_out --threads 48 --model GTRGAMMA SC2.fasta"

## SC3
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC3
../seqtk/seqtk subseq ../../11.SNIPPY_MULTI/clean.full.aln SC3_Samples.txt > SC3.fasta
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix gubbins_SC3_out --threads 48 --model GTRGAMMA SC3.fasta"

## SC4
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC4
../seqtk/seqtk subseq ../../11.SNIPPY_MULTI/clean.full.aln SC4_Samples.txt > SC4.fasta
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix gubbins_SC4_out --threads 48 --model GTRGAMMA SC4.fasta"

## SC5
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC5
../seqtk/seqtk subseq ../../11.SNIPPY_MULTI/clean.full.aln SC5_Samples.txt > SC5.fasta
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix gubbins_SC5_out --threads 48 --model GTRGAMMA SC5.fasta"

## SC6
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC6
../seqtk/seqtk subseq ../../11.SNIPPY_MULTI/clean.full.aln SC6_Samples.txt > SC6.fasta
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix gubbins_SC6_out --threads 48 --model GTRGAMMA SC6.fasta"

## SC7
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC7
../seqtk/seqtk subseq ../../11.SNIPPY_MULTI/clean.full.aln SC7_Samples.txt > SC7.fasta
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix gubbins_SC7_out --threads 48 --model GTRGAMMA SC7.fasta"

## SC8
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC8
../seqtk/seqtk subseq ../../11.SNIPPY_MULTI/clean.full.aln SC8_Samples.txt > SC8.fasta
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix gubbins_SC8_out --threads 48 --model GTRGAMMA SC8.fasta"

## SC9
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC9
../seqtk/seqtk subseq ../../11.SNIPPY_MULTI/clean.full.aln SC9_Samples.txt > SC9.fasta
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix gubbins_SC9_out --threads 48 --model GTRGAMMA SC9.fasta"

## SC10
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC10
../seqtk/seqtk subseq ../../11.SNIPPY_MULTI/clean.full.aln SC10_Samples.txt > SC10.fasta
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix gubbins_SC10_out --threads 48 --model GTRGAMMA SC10.fasta"



# Need to subset to each major SC ?
## SC1
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC_specific_Ref/SC1
module load python
source activate snippy
while IFS= read -r base; do
  sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy --outdir SNIPPY_OUT/${base} --R1 ../../../1.TRIMMED_READS/${base}_trimmed_1.fq.gz --R2 ../../../1.TRIMMED_READS/${base}_trimmed_2.fq.gz --ref B105.gbk"
done < SC1_Samples.txt

sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy-core --ref B105.fna SNIPPY_OUT/*RR*"
sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy-clean_full_aln core.full.aln > clean.full.aln"

source activate gubbins
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix gubbins_REFd_SC1_out --threads 48 --model GTRGAMMA clean.full.aln"

## SC2
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC_specific_Ref/SC2
cp /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC2/SC2_Samples.txt ./
module load python
source activate snippy
while IFS= read -r base; do
  sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy --outdir SNIPPY_OUT/${base} --R1 ../../../1.TRIMMED_READS/${base}_trimmed_1.fq.gz --R2 ../../../1.TRIMMED_READS/${base}_trimmed_2.fq.gz --ref MA07.gbk"
done < SC2_Samples.txt

sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy-core --ref MA07.fna SNIPPY_OUT/*RR*"
sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy-clean_full_aln core.full.aln > clean.full.aln"

source activate gubbins
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix gubbins_REFd_SC2_out --threads 48 --model GTRGAMMA clean.full.aln"

## SC3
mkdir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC_specific_Ref/SC3
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC_specific_Ref/SC3
cp /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC3/SC3_Samples.txt ./
module load python
source activate snippy
mkdir SNIPPY_OUT
while IFS= read -r base; do
  sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy --outdir SNIPPY_OUT/${base} --R1 ../../../1.TRIMMED_READS/${base}_trimmed_1.fq.gz --R2 ../../../1.TRIMMED_READS/${base}_trimmed_2.fq.gz --ref HU-GS5823.gbk"
done < SC3_Samples.txt

sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy-core --ref HU-GS5823.fna SNIPPY_OUT/*RR*"
sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy-clean_full_aln core.full.aln > clean.full.aln"

source activate gubbins
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix gubbins_REFd_SC3_out --threads 48 --model GTRGAMMA clean.full.aln"

## SC4
mkdir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC_specific_Ref/SC4
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC_specific_Ref/SC4
cp /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC4/SC4_Samples.txt ./
module load python
source activate snippy
mkdir SNIPPY_OUT
while IFS= read -r base; do
  sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy --outdir SNIPPY_OUT/${base} --R1 ../../../1.TRIMMED_READS/${base}_trimmed_1.fq.gz --R2 ../../../1.TRIMMED_READS/${base}_trimmed_2.fq.gz --ref Sag153.gbk"
done < SC4_Samples.txt

sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy-core --ref Sag153.fna SNIPPY_OUT/*RR*"
sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy-clean_full_aln core.full.aln > clean.full.aln"

source activate gubbins
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix gubbins_REFd_SC4_out --threads 48 --model GTRGAMMA clean.full.aln"

## SC5
mkdir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC_specific_Ref/SC5
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC_specific_Ref/SC5
cp /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC5/SC5_Samples.txt ./
module load python
source activate snippy
mkdir SNIPPY_OUT
while IFS= read -r base; do
  sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy --outdir SNIPPY_OUT/${base} --R1 ../../../1.TRIMMED_READS/${base}_trimmed_1.fq.gz --R2 ../../../1.TRIMMED_READS/${base}_trimmed_2.fq.gz --ref NGBS357.gbk"
done < SC5_Samples.txt

sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy-core --ref NGBS357.fna SNIPPY_OUT/*RR*"
sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy-clean_full_aln core.full.aln > clean.full.aln"

source activate gubbins
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix gubbins_REFd_SC5_out --threads 48 --model GTRGAMMA clean.full.aln"

## SC6
mkdir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC_specific_Ref/SC6
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC_specific_Ref/SC6
cp /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC6/SC6_Samples.txt ./
module load python
source activate snippy
mkdir SNIPPY_OUT
while IFS= read -r base; do
  sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy --outdir SNIPPY_OUT/${base} --R1 ../../../1.TRIMMED_READS/${base}_trimmed_1.fq.gz --R2 ../../../1.TRIMMED_READS/${base}_trimmed_2.fq.gz --ref BCJB1835.gbk"
done < SC6_Samples.txt

sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy-core --ref BCJB1835.fna SNIPPY_OUT/*RR*"
sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy-clean_full_aln core.full.aln > clean.full.aln"

source activate gubbins
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix gubbins_REFd_SC6_out --threads 48 --model GTRGAMMA clean.full.aln"

## SC7
mkdir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC_specific_Ref/SC7
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC_specific_Ref/SC7
cp /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC7/SC7_Samples.txt ./
module load python
source activate snippy
mkdir SNIPPY_OUT
while IFS= read -r base; do
  sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy --outdir SNIPPY_OUT/${base} --R1 ../../../1.TRIMMED_READS/${base}_trimmed_1.fq.gz --R2 ../../../1.TRIMMED_READS/${base}_trimmed_2.fq.gz --ref BJ01.gbk"
done < SC7_Samples.txt

sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy-core --ref BJ01.fna SNIPPY_OUT/*RR*"
sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy-clean_full_aln core.full.aln > clean.full.aln"

source activate gubbins
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix gubbins_REFd_SC7_out --threads 48 --model GTRGAMMA clean.full.aln"

## SC8
mkdir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC_specific_Ref/SC8
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC_specific_Ref/SC8
cp /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC8/SC8_Samples.txt ./
module load python
source activate snippy
mkdir SNIPPY_OUT
while IFS= read -r base; do
  sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy --outdir SNIPPY_OUT/${base} --R1 ../../../1.TRIMMED_READS/${base}_trimmed_1.fq.gz --R2 ../../../1.TRIMMED_READS/${base}_trimmed_2.fq.gz --ref GBS1-NY.gbk"
done < SC8_Samples.txt

sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy-core --ref GBS1-NY.fna SNIPPY_OUT/*RR*"
sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy-clean_full_aln core.full.aln > clean.full.aln"

source activate gubbins
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix gubbins_REFd_SC8_out --threads 48 --model GTRGAMMA clean.full.aln"

## SC9
mkdir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC_specific_Ref/SC9
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC_specific_Ref/SC9
cp /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC9/SC9_Samples.txt ./
module load python
source activate snippy
mkdir SNIPPY_OUT
while IFS= read -r base; do
  sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy --outdir SNIPPY_OUT/${base} --R1 ../../../1.TRIMMED_READS/${base}_trimmed_1.fq.gz --R2 ../../../1.TRIMMED_READS/${base}_trimmed_2.fq.gz --ref GBSIR0001.gbk"
done < SC9_Samples.txt

sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy-core --ref GBSIR0001.fna SNIPPY_OUT/*RR*"
sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy-clean_full_aln core.full.aln > clean.full.aln"

source activate gubbins
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix gubbins_REFd_SC9_out --threads 48 --model GTRGAMMA clean.full.aln"

## SC10
mkdir /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC_specific_Ref/SC10
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC_specific_Ref/SC10
cp /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC10/SC10_Samples.txt ./
module load python
source activate snippy
mkdir SNIPPY_OUT
while IFS= read -r base; do
  sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy --outdir SNIPPY_OUT/${base} --R1 ../../../1.TRIMMED_READS/${base}_trimmed_1.fq.gz --R2 ../../../1.TRIMMED_READS/${base}_trimmed_2.fq.gz --ref FDAARGOS_512.gbk"
done < SC10_Samples.txt

sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy-core --ref FDAARGOS_512.fna SNIPPY_OUT/*RR*"
sbatch -p fasse -t 1-00:00:00 --mem=10000 --wrap="snippy-clean_full_aln core.full.aln > clean.full.aln"

source activate gubbins
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix gubbins_REFd_SC10_out --threads 48 --model GTRGAMMA clean.full.aln"
