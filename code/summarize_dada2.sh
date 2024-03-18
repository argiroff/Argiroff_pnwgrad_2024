#!/usr/bin/env bash

# name: itsxpress_its.sh
# author: William Argiroff
# inputs: QIIME2 denoising_stats.qza files
# outputs: QIIME2 qzv (visual summary) artifact into proper subdirectories in data
# notes: expects path(relative to project root)/dada2/denoising_stats.qza as input

# Activate QIIME2 environment
echo "Activating QIIME2 environment."
source activate /opt/miniconda3/envs/qiime2-2022.8

# Files
echo "Obtaining filepaths."

infile=`echo "$PWD"/"$1"`
outfile=`echo "$infile" | sed -E "s/dada2\/denoising_stats.qza/denoising_stats_summary.qzv/"`

# Summarize
progress=`echo "$infile" | sed -E "s/\/demux.qza//" | sed -E "s/(.*\/)//"`
echo "Summarizing DADA2 results in ""$progress"" as ""$outfile"

qiime metadata tabulate \
    --m-input-file $infile \
    --o-visualization $outfile

echo "Finished summarizing ""$infile".

# Deactivate QIIME2 environment
echo "Deactivating QIIME2 environment."

conda deactivate
