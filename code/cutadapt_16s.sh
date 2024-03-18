#!/usr/bin/env bash

# name: cutadapt_16s.sh
# author: William Argiroff
# inputs: QIIME2 demux.qza files
# outputs: QIIME2 qzv (visual summary) artifact into proper subdirectories in data
# notes: expects path(relative to project root)/demux.qza as input

# Activate QIIME2 environment
echo "Activating QIIME2 environment."
source activate /opt/miniconda3/envs/qiime2-2022.8

# Files
echo "Obtaining filepaths."

infile=`echo "$PWD"/"$1"`
outfile=`echo "$infile" | sed -E "s/demux.qza/trimmed.qza/"`

# Trim with cudadapt
progress=`echo "$infile" | sed -E "s/\/demux.qza//" | sed -E "s/(.*\/)//"`
echo "Trimming raw sequences in ""$progress"" as ""$outfile"

qiime cutadapt trim-paired \
    --i-demultiplexed-sequences "$infile" \
    --p-front-f GTGCCAGCMGCCGCGGTAA \
    --p-front-f GTGCCAGCMGCWGCGGTAA \
    --p-front-f GTGCCAGCMGCCGCGGTCA \
    --p-front-f GTGKCAGCMGCCGCGGTAA \
    --p-front-r GGACTACHVGGGTWTCTAAT \
    --p-error-rate 0.1 \
    --o-trimmed-sequences "$outfile" \
    --p-cores 10 \
    --verbose

echo "Finished trimming ""$infile"

# Deactivate QIIME2 environment
echo "Deactivating QIIME2 environment."

conda deactivate
