#GBS_GWAS Post Processing

#Create manhattan plots
cat <(echo -e "#CHR\tSNP\tBP\tminLOG10(P)\tlog10(p)\tr^2") \
<(paste <(sed '1d' SNPGWAS_Fasttree.txt | cut -d "_" -f 2) <(sed '1d' SNPGWAS_Fasttree.txt | cut -f 4) | awk -v chr="AP018935.1" '{p = -log($2)/log(10); print chr, ".", $1, p, p, "0"}') | tr ' ' '\t' > /n/holylfs05/LABS/hanage_lab/Lab/holyscratch01/Ruchita/GBS/GBS_Figure_Shells/SNPGWAS_Fasttree.plot


cat <(echo -e "#CHR\tSNP\tBP\tminLOG10(P)\tlog10(p)\tr^2") \
<(paste <(sed '1d' SNPGWAS_mash.txt | cut -d "_" -f 2) <(sed '1d' SNPGWAS_mash.txt | cut -f 4) | awk -v chr="AP018935.1" '{p = -log($2)/log(10); print chr, ".", $1, p, p, "0"}') | tr ' ' '\t' > /n/holylfs05/LABS/hanage_lab/Lab/holyscratch01/Ruchita/GBS/GBS_Figure_Shells/SNPGWAS_mash.plot


cat <(echo -e "#CHR\tSNP\tBP\tminLOG10(P)\tlog10(p)\tr^2") \
<(paste <(sed '1d' SNPGWAS_SC.txt | cut -d "_" -f 2) <(sed '1d' SNPGWAS_SC.txt | cut -f 4) | awk -v chr="AP018935.1" '{p = -log($2)/log(10); print chr, ".", $1, p, p, "0"}') | tr ' ' '\t' > /n/holylfs05/LABS/hanage_lab/Lab/holyscratch01/Ruchita/GBS/GBS_Figure_Shells/SNPGWAS_SC.plot
