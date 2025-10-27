#!/usr/bin/env bash
set -euo pipefail

# === EDIT: your FASTA path ===
IN="/n/hanage_gbs_gwas_l3/Lab/GBS-GWAS-pipeline/Nextflow_pipeline_EOD_LOD_CDC/11.SNIPPY_MULTI/clean.full.aln"

# Output in current dir
OUT="clean.full.relaxed.phy"

# Filter sequences with >50% (N or -): 1=yes, 0=no
FILTER=1
DROPPED_IDS="dropped_gt50_ambig_ids.txt"
MAXID=100

tmp_tabs="$(mktemp)"
trap 'rm -f "$tmp_tabs"' EXIT

# 0) Flatten FASTA -> <name>\t<seq>, uppercase, map non-ACGTN- to N
awk '
  BEGIN{OFS="\t"}
  /^>/{
    if (name!=""){print name,seq}
    name=substr($0,2); gsub(/[ \t]/,"_",name); seq="";
    next
  }
  {
    gsub(/[ \t\r]/,"");
    line=toupper($0);
    gsub(/[^ACGTN-]/,"N",line);
    seq=seq line
  }
  END{ if (name!=""){print name,seq} }
' "$IN" > "$tmp_tabs"

# 1) First pass: count kept seqs, check length
awk -v FILTER="$FILTER" -v DROPPED_IDS="$DROPPED_IDS" '
  function ambfrac(s,   t,a){ t=s; a=gsub(/[N-]/,"",t); return (length(s)==0)?1:a/length(s) }
  NR==1 { L=length($2) }
  {
    name=$1; seq=$2; len=length(seq);
    if (len!=L) diff=1;
    if (FILTER==1 && ambfrac(seq)>0.5) { if(DROPPED_IDS!="") print name >> DROPPED_IDS; next }
    n++
  }
  END{
    if (diff){ print "ERROR: sequences have different lengths!" > "/dev/stderr"; exit 1 }
    if (n==0){ print "ERROR: no sequences retained" > "/dev/stderr"; exit 1 }
    print n, L
  }
' "$tmp_tabs" > "$OUT"

# 2) Second pass: write PHYLIP-relaxed lines with sanitized IDs
awk -v out="$OUT" -v FILTER="$FILTER" -v MAXID="$MAXID" '
  function ambfrac(s,   t,a){ t=s; a=gsub(/[N-]/,"",t); return (length(s)==0)?1:a/length(s) }
  {
    name=$1; seq=$2;
    if (FILTER==1 && ambfrac(seq)>0.5) next
    gsub(/[^A-Za-z0-9_.-]/,"_",name);
    if (length(name)>MAXID) name=substr(name,1,MAXID);
    print name, seq >> out
  }
' "$tmp_tabs"

echo "Wrote $OUT"
if [ -s "$DROPPED_IDS" ]; then
  echo "Dropped IDs (>50% gaps+N) in $DROPPED_IDS"
fi
