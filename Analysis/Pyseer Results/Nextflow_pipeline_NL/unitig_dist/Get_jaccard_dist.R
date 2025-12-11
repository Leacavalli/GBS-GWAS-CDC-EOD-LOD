# Load data
unitig_counter_presabs_df <- read.table("unitig_counter_mini.rtab", header= T) 
# unitig_caller_presabs_df <- read.table("unitig_caller.rtab", header= T) 
# unitig_NL_presabs_df <- read.table("unitigs_NL.tsv", header= T)

# Accessory genome distances (jaccard dissimilarity)
library(vegan) 
jacc_dist_counter<- vegdist(as.matrix((unitig_counter_presabs_df[,-1])), method = "jaccard", binary = TRUE)
# jacc_dist_caller <- jaccard(as.matrix((unitig_caller_presabs_df |> select(-KmerID))))
# jacc_dist_NL <- jaccard(as.matrix((unitig_NL_presabs_df  |> select(-Unitig_sequence))))

# write: 
write.table(jacc_dist_counter, "jacc_dist_counter.tsv")
