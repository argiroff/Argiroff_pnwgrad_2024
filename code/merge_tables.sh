#!/usr/bin/env bash

# name: merge_tables.sh
# author: William Argiroff
# inputs: All QIIME2 dada2/table.qza files
# outputs: Merged QIIME2 table.qza file in /final_qzas/
# notes: expects path(relative to project root)/dada2/table.qza as input

# Activate QIIME2 environment
echo "Activating QIIME2 environment."
source activate /opt/miniconda3/envs/qiime2-2022.8

# Files
echo "Obtaining filepaths."

infiles1=($@) # Tables as an array
infiles2=() # Empty array

# Populate empty array with full path names
for i in ${!infiles1[@]}; do
    qiime_command=`echo "--i-tables ""$PWD"/"${infiles1[$i]}"" "`
    infiles2+=("$qiime_command")
done

infiles3=`echo ${infiles2[*]}`

# Get outfile paths
outfile1=`echo "$PWD""${infiles1[0]}" | sed -E "s/\/dada2\/table.qza//"`
outfile2=`echo "$outfile1" | sed -E "s/(.*\/)//"`
outfile3=`echo "$outfile1" | sed -E "s/\/"$outfile2"//" | sed -E "s/(.*\/)//"`
outfile4=`echo "$PWD"/"data/qiime2/final_qzas"/"$outfile3"/"merged_table.qza"`

# Merge
echo "Merging tables in ""$outfile3"" and placing in ""$PWD"/"final_qzas"/"$outfile3"

qiime feature-table merge \
    $infiles3 \
    --o-merged-table $outfile4

echo "Finished merging ""$outfile3"" tables."

# Deactivate QIIME2 environment
echo "Deactivating QIIME2 environment."

conda deactivate
