#!/usr/bin/env bash

# name: import_seqs_to_qza.sh
# author: William Argiroff
# inputs: QIIME2 manifest and fastq files
# outputs: QIIME2 demux artifact into proper subdirectories in data
# notes: expects path(relative to project root)/manifest.txt as input

# Activate QIIME2 environment
echo "Activating QIIME2 environment."
source activate /opt/miniconda3/envs/qiime2-2022.8

# Files
echo "Obtaining filepaths."

infile=`echo "$PWD"/"$1"`
outfile=`echo "$infile" | sed -E "s/manifest/demux/" | sed -E "s/\.txt/\.qza/"`

# Import
progress=`echo "$infile" | sed -E "s/\/manifest.txt//" | sed -E "s/(.*\/)//"`
echo "Importing .fastq files in ""$progress"" as ""$outfile"

qiime tools import \
    --type 'SampleData[PairedEndSequencesWithQuality]' \
    --input-path "$infile" \
    --input-format PairedEndFastqManifestPhred33V2 \
    --output-path "$outfile"

echo "Finished importing ""$outfile"

# Deactivate QIIME2 environment
echo "Deactivating QIIME2 environment."

conda deactivate
