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

cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/11.SNIPPY_MULTI
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix gubbins_out --threads 48 --starting-tree ../12.Phylogeny/12.1.FastTree_DP/EOD_LOD_VLOD_CDC_FastTree_DP.tre --model GTRGAMMA clean.full.aln"
# slurm-6217863.out

# Full alignment
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/Fulltree_Gubbins
../seqtk/seqtk subseq ../../11.SNIPPY_MULTI/clean.full.aln Full_samples.txt > Full.fasta
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/Fulltree_Gubbins/gubbins_fulltree_out --threads 48 --starting-tree /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/12.Phylogeny/12.1.FastTree_DP/EOD_LOD_VLOD_CDC_FastTree_DP.tre --model GTRGAMMA Full.fasta"


# Full alignment - no start tree
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/Fulltree_nostarttree
sbatch -p fasse_bigmem -c 48 -t 7-00:00:00 --mem=490000 --wrap="run_gubbins.py --prefix gubbins_fulltree_nostarttree --threads 48 --model GTRGAMMA /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/11.SNIPPY_MULTI/clean.full.aln"

# Need to subset to each major SC ?
## SC1
cd /n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_VLOD_CDC/16.Gubbins/SC2
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
