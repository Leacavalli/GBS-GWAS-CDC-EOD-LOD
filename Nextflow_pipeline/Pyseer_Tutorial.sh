# Tool: pyseer
https://pyseer.readthedocs.io/en/master/options.html
conda create -n pyseer
source activate pyseer
conda install pyseer

##Test installation
#Run unit tests:
pytest -v tests
#Test functions and output:
cd tests/ && bash run_test.sh && cd ../

# Other software
conda install fsm-lite
conda install seer
conda install unitig-counter unitig-caller

## For a genome-wide association study, we need at least three input files:
# Genetic variants (--kmers, --vcf or --pres).
# A phenotype (--phenotypes).
# A representation of the population structure (--distances or --similarity).

## ‘best-practice’ GWAS recommendations
# Use the --lmm mode.
# Use a phylogeny to generate the --similarity matrix.
# Use unitigs as the input, provided with the --kmers option. End-to-end analysis is identical to k-mers.

## GWAS tutorial
wget -O pyseer_tutorial.tar.bz2 https://figshare.com/ndownloader/files/14091179
tar xvf pyseer_tutorial.tar.bz2


## pairwise distance matrix
# create the mash sketches
mkdir assemblies
cd assemblies
tar xf ../assemblies.tar.bz2
cd ..
mash sketch -s 10000 -o mash_sketch assemblies/*.fa
# calculate distances between all pairs of samples

## Alternatively, patristic distances from a phylogeny:
python /n/holylfs05/LABS/hanage_lab/Lab/holyscratch01/lcavalli/Software/pyseer/scripts/phylogeny_distance.py core_genome_aln.tree > phylogeny_dists.tsv

# perform an MDS and these distances and look at a scree plot to choose the number of dimensions to retain
scree_plot_pyseer mash.tsv

## SNP and COG association with fixed effects model
# run the analysis on the COGs:
pyseer --phenotypes resistances.pheno --pres gene_presence_absence.Rtab --distances mash.tsv --save-m mash_mds --max-dimensions 8 > penicillin_COGs_mash.txt
pyseer --phenotypes resistances.pheno --pres gene_presence_absence.Rtab --distances phylogeny_dists.tsv --save-m phylogeny_dists_mds --max-dimensions 8 > penicillin_COGs_phylogeny_dists.txt

# run the analysis on the SNPs:
# To speed up the program we will load the MDS decomposition mash_mds.pkl which was created by the COG analysis above
# We haven’t specified the number of MDS dimensions to retain, so the default of 10 will be used
# Turning on the test for lineage effects with --lineage uses the MDS components as the lineage, and writes the lineages most associated with the phenotype to lineage_effects.txt
# The output now includes the lineage each variant is associated with, though not all variants can be assigned a lineage.
# --print-samples forces the inclusion of a comma separated list of samples the variant is present in k-samples and not present in nk-samples
pyseer --phenotypes resistances.pheno --vcf snps.vcf.gz --load-m mash_mds.pkl --lineage --print-samples > penicillin_SNPs.txt
pyseer --phenotypes resistances.pheno --vcf snps.vcf.gz --load-m phylogeny_dists_mds.pkl --lineage --print-samples > penicillin_SNPs.txt
sort -g -k4,4 penicillin_SNPs.txt | head
head lineage_effects.txt

# This contains co-ordinates and p-values, which can be converted to a .plot file using the following awk one-liner:
cat <(echo "#CHR SNP BP minLOG10(P) log10(p) r^2") <(paste <(sed '1d' penicillin_SNPs.txt | cut -d "_" -f 2) <(sed '1d' penicillin_SNPs.txt | cut -f 4) | awk '{p = -log($2)/log(10); print "26",".",$1,p,p,"0"}' ) | tr ' ' '\t' > penicillin_snps.plot

# we should probably have used a MAF cutoff of at least 2% given the total number of samples we have. As a rule of thumb, a MAF cutoff corresponding to a MAC of at least 10 isn’t a bad start.
sbatch -p shared -t 0-03:00 --mem=100000 --wrap="pyseer --phenotypes resistances.pheno --vcf snps.vcf.gz --load-m phylogeny_dists_mds.pkl --min-af 0.02 --max-af 0.98 > penicillin_SNPs_MAFcutoff.txt"
cat <(echo "#CHR SNP BP minLOG10(P) log10(p) r^2") <(paste <(sed '1d' penicillin_SNPs_MAFcutoff.txt | cut -d "_" -f 2) <(sed '1d' penicillin_SNPs_MAFcutoff.txt | cut -f 4) | awk '{p = -log($2)/log(10); print "26",".",$1,p,p,"0"}' ) | tr ' ' '\t' > penicillin_SNPs_MAFcutoff.plot

# SNP association with mixed effects model
python /n/holylfs05/LABS/hanage_lab/Lab/holyscratch01/lcavalli/Software/pyseer/scripts/phylogeny_distance.py --lmm core_genome_aln.tree > phylogeny_lmm.tsv
sbatch -p shared -c 8 -t 0-10:00 --mem=100000 --wrap="pyseer --lmm --phenotypes resistances.pheno --vcf snps.vcf.gz --similarity phylogeny_lmm.tsv --cpu 8 > penicillin_SNPs_lmm.txt"
cat <(echo "#CHR SNP BP minLOG10(P) log10(p) r^2") <(paste <(sed '1d' penicillin_SNPs_lmm.txt | cut -d "_" -f 2) <(sed '1d' penicillin_SNPs_lmm.txt | cut -f 4) | awk '{p = -log($2)/log(10); print "26",".",$1,p,p,"0"}' ) | tr ' ' '\t' > penicillin_SNPs_lmm.plot

## K-mer association
# count the k-mers from the assemblies:
cd assemblies
fsm-lite -l ../fsm_file_list.txt -s 6 -S 610 -v -t fsm_kmers | gzip -c - > ../fsm_kmers.txt.gz
cd ..

# use the distances from the core genome phylogeny, which has been midpointed rooted
python scripts/phylogeny_distance.py --lmm core_genome_aln.tree > phylogeny_K.tsv

# Alternatively, we could extract a kinship matrix from the mapped SNPs by calculating
similarity_pyseer --vcf snps.vcf.gz samples.txt > gg.snps.txt

# K-mer association with fixed effects model
pyseer --phenotypes resistances.pheno --kmers fsm_kmers.txt.gz --similarity phylogeny_K.tsv > penicillin_SNPs.txt

# K-mer association with mixed effects model
pyseer --lmm --phenotypes resistances.pheno --kmers fsm_kmers.txt.gz --similarity phylogeny_K.tsv --output-patterns kmer_patterns.txt --cpu 8 > penicillin_kmers.txt

# determine a significance threshold using the number of unique k-mer patterns
python scripts/count_patterns.py kmer_patterns.txt

# create a Q-Q plot to check that p-values are not inflated
python scripts/qq_plot.py penicillin_kmers.txt

# Interpreting significant k-mers
# filter these from the output
cat <(head -1 penicillin_kmers.txt) <(awk '$4<1.90E-08 {print $0}' penicillin_kmers.txt) > significant_kmers.txt
# Mapping to a single reference
phandango_mapper significant_kmers.txt Spn23F.fa Spn23F_kmers.plot
