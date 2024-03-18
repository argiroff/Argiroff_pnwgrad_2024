#!/usr/bin/env bash

# name: assign_tax_its_asv.sh
# author: William Argiroff
# inputs: QIIME2 repseq files and UNITE database
# outputs: QIIME2 taxonomy file in final_qzas/ITS/otu_97_taxonomy/
# notes: expects path(relative to project root)/repseq as arg1, classifier seqs as arg2,
#   and taxonomy as arg3

# Activate QIIME2 environment
echo "Activating QIIME2 environment."
source activate /opt/miniconda3/envs/qiime2-2022.8

# Files
echo "Obtaining filepaths."

infile1=`echo "$PWD"/"$1"`
infile2=`echo "$PWD"/"$2"`
infile3=`echo "$PWD"/"$3"`
outdir=`echo "$PWD"/"data/qiime2/final_qzas/ITS/asv_taxonomy"`

if test -d $outdir; then
  echo "$outdir"" already exists. Removing old directory."
  rm -r $outdir
fi

# Assign taxonomy
echo "Classifying ""$1".

qiime feature-classifier classify-consensus-blast \
    --i-reference-reads $infile2 \
    --i-reference-taxonomy $infile3 \
    --i-query $infile1 \
    --output-dir $outdir

echo "Finished classifying ""$1".

# Deactivate QIIME2 environment
echo "Deactivating QIIME2 environment."

conda deactivate