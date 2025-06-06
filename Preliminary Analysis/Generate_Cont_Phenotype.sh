#!/bin/bash

# Step 1: Build BioSample -> AGEDYS lookup
awk -F, '
NR > 1 {
    gsub(/"/, "", $2);  # BioSample_accession
    gsub(/"/, "", $7);  # AGEDYS
    biosample = $2;
    age = $7;
    if (biosample != "" && age != "")
        biosample_age[biosample] = age;
}
END {
    for (b in biosample_age)
        print b, biosample_age[b];
}' OFS=',' HARVARD_GBS_2015_2023_metadata.csv > biosample_to_age.txt

# Step 2: Match SRR to AGEDYS value without converting to categories
awk -F, '
BEGIN {
    OFS = ",";
    print "samples", "agedys";
}
FNR == NR {
    biosample_age[$1] = $2;
    next;
}
FNR > 1 {
    gsub(/"/, "", $1);  # SRR
    gsub(/"/, "", $6);  # BioSample
    srr = $1;
    biosample = $6;
    age = biosample_age[biosample];
    if (age == "" || age == "NA") next;
    print srr, age;
}' biosample_to_age.txt SraRunTable.csv > output_samples_comtinuous.txt
