#!/usr/bin/env bash

# name: summarize_trimmed_seqs.sh
# author: William Argiroff
# inputs: QIIME2 trimmed.qza files
# outputs: QIIME2 qzv (visual summary) artifact into proper subdirectories in data
# notes: expects path(relative to project root)/trimmed.qza as input

# Activate QIIME2 environment
echo "Activating QIIME2 environment."
source activate /opt/miniconda3/envs/qiime2-2022.8

# Files
echo "Obtaining filepaths."

infile=`echo "$PWD"/"$1"`
outdir=`echo "$infile" | sed -E "s/trimmed.qza/dada2/"`

# Summarize
progress=`echo "$infile" | sed -E "s/\/trimmed.qza//" | sed -E "s/(.*\/)//"`
echo "Running DADA2 for ""$progress"" to produce ""$outdir""/"

qiime dada2 denoise-paired \
    --i-demultiplexed-seqs "$infile" \
    --p-trunc-len-f 0 \
    --p-trunc-len-r 0 \
    --output-dir "$outdir" \
    --p-n-threads 10

echo "Finished processing ""$infile"

# Deactivate QIIME2 environment
echo "Deactivating QIIME2 environment."

conda deactivate