#!/usr/bin/env bash

# name: itsxpress_its.sh
# author: William Argiroff
# inputs: QIIME2 demux.qza files
# outputs: QIIME2 qza artifact into proper subdirectories in data
# notes: expects path(relative to project root)/demux.qza as input

# Activate QIIME2 environment
echo "Activating QIIME2 environment."
source activate /opt/miniconda3/envs/qiime2-2022.8

# Files
echo "Obtaining filepaths."

infile=`echo "$PWD"/"$1"`
outfile=`echo "$infile" | sed -E "s/demux.qza/trimmed.qza/"`

# Trim with ITSxpress
progress=`echo "$infile" | sed -E "s/\/demux.qza//" | sed -E "s/(.*\/)//"`
echo "Trimming raw sequences in ""$progress"" as ""$outfile"

qiime itsxpress trim-pair-output-unmerged \
    --i-per-sample-sequences "$infile" \
    --p-region ITS2 \
    --p-taxa F \
    --o-trimmed "$outfile" \
    --p-threads 10

echo "Finished trimming ""$infile"

# Deactivate QIIME2 environment
echo "Deactivating QIIME2 environment."

conda deactivate
