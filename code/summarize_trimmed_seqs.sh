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
outfile=`echo "$infile" | sed -E "s/trimmed.qza/trimmed_summary.qzv/"`

# Summarize
progress=`echo "$infile" | sed -E "s/\/trimmed.qza//" | sed -E "s/(.*\/)//"`
echo "Summarizing trimmed sequences in ""$progress"" as ""$outfile"

qiime demux summarize \
    --i-data "$infile" \
    --o-visualization "$outfile"

echo "Finished summarizing ""$infile"

# Deactivate QIIME2 environment
echo "Deactivating QIIME2 environment."

conda deactivate
