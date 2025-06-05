
#!/bin/bash

# Step 1: Build BioSample -> AGEDYS lookup
awk -F, '
NR > 1 {
    gsub(/"/, "", $2);  # Biosample_accession
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

# Step 2: Match SRR to disease label using corrected column (column 6)
awk -F, '
BEGIN {
    OFS = ",";
    print "samples", "disease";
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
    if (age < 7) disease = 0;
    else if (age <= 89) disease = 1;
    else disease = 2;
    print srr, disease;
}' biosample_to_age.txt SraRunTable.csv > output_samples_disease.txt

