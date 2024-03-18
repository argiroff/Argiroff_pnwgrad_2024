#!/usr/bin/env bash

# name: assign_tax_16s_asv.sh
# author: William Argiroff
# inputs: QIIME2 repseq files and SILVA classifier
# outputs: QIIME2 taxonomy file in final_qzas/asv_taxonomy/
# notes: expects path(relative to project root)/repseq as arg1 and classifier as arg2

# Activate QIIME2 environment
echo "Activating QIIME2 environment."
source activate /opt/miniconda3/envs/qiime2-2022.8

# Files
echo "Obtaining filepaths."

infile1=`echo "$PWD"/"$1"`
infile2=`echo "$PWD"/"$2"`
outdir=`echo "$PWD"/"data/qiime2/final_qzas/16S/asv_taxonomy"`

if test -d $outdir; then
  echo "$outdir"" already exists. Removing old directory."
  rm -r $outdir
fi

# Assign taxonomy
echo "Classifying ""$1".

qiime feature-classifier classify-sklearn \
    --i-classifier $infile2 \
    --i-reads $infile1 \
    --output-dir $outdir

echo "Finished classifying ""$1".

# Deactivate QIIME2 environment
echo "Deactivating QIIME2 environment."

conda deactivate
