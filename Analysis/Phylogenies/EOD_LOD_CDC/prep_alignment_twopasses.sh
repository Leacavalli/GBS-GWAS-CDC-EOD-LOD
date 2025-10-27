#!/usr/bin/env bash
set -euo pipefail

# === EDIT THIS to your FASTA path ===
IN="/n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/11.SNIPPY_MULTI/clean.full.aln"

# Output PHYLIP-relaxed in current dir
OUT="clean.full.relaxed.phy"

# Set FILTER=1 to drop sequences with >50% gaps (recommended for stability)
# Set FILTER=0 to keep everything
FILTER=1

# Optional: write IDs we dropped due to >50% gaps
DROPPED_IDS="dropped_gt50_gap_ids.txt"

# Max ID length for tidy PHYLIP-relaxed
MAXID=100

tmp_tabs="$(mktemp)"
trap 'rm -f "$tmp_tabs"' EXIT

# 0) Flatten FASTA -> <name>\t<seq> (sanitize spaces)
awk '
  BEGIN{OFS="\t"}
  /^>/{
    if (name!=""){print name,seq}
    name=substr($0,2)
    gsub(/[ \t]/,"_",name)
    seq=""
    next
  }
  {
    gsub(/[ \t\r]/,"")
    seq=seq $0
  }
  END{
    if (name!=""){print name,seq}
  }
' "$IN" > "$tmp_tabs"

# 1) First pass: count kept seqs and get length, sanity-check
awk -v FILTER="$FILTER" -v DROPPED_IDS="$DROPPED_IDS" '
  function gaps_frac(s,   t, g){
    t=s; g=gsub(/-/, "", t);
    if (length(s)==0) return 1;
    return g/length(s)
  }
  NR==1 { L = length($2) }
  {
    name=$1; seq=$2; len=length(seq)
    if (len != L) { diff=1 }
    if (FILTER==1 && gaps_frac(seq) > 0.5) {
      if (DROPPED_IDS!="") print name >> DROPPED_IDS
      next
    }
    n++
  }
  END{
    if (diff) { print "ERROR: sequences have different lengths!" > "/dev/stderr"; exit 1 }
    if (n==0) { print "ERROR: no sequences retained" > "/dev/stderr"; exit 1 }
    print n, L
  }
' "$tmp_tabs" > "$OUT"

# 2) Second pass: write name + sequence lines (sanitized IDs)
awk -v out="$OUT" -v FILTER="$FILTER" -v MAXID="$MAXID" '
  function gaps_frac(s,   t, g){
    t=s; g=gsub(/-/, "", t);
    if (length(s)==0) return 1;
    return g/length(s)
  }
  {
    name=$1; seq=$2;
    if (FILTER==1 && gaps_frac(seq) > 0.5) next
    gsub(/[^A-Za-z0-9_.-]/, "_", name)
    if (length(name)>MAXID) name=substr(name,1,MAXID)
    print name, seq >> out
  }
' "$tmp_tabs"

echo "Wrote $OUT"
if [ -s "$DROPPED_IDS" ]; then
  echo "Dropped IDs (>50% gaps) recorded in $DROPPED_IDS"
fi
