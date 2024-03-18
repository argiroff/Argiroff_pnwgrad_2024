#!/usr/bin/env Rscript --vanilla

# name : make_16s_ps_untrimmed.R
# author: William Argiroff
# inputs : Sequence sample metadata files
#   merged ASV qza, merged tax qza, merged repseq qza
# output : phyloseq object
# notes : expects order of inputs, output
#   expects input paths for merged ASV and rep seqs qzas, tax qza, and metadata
#   and output data/processed/16S/asv_processed/ps_untrimmed.rds

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(qiime2R)
library(phyloseq)

# Make phyloseq object
ps <- qza_to_phyloseq(
  features = clargs[2],
  taxonomy = clargs[3]
)

# Add representative sequences
repseqs_qza <- read_qza(
  file = clargs[1]
)

repseqs <- repseqs_qza$data

ps <- merge_phyloseq(ps, repseqs)

# Add metadata
metadata <- read_tsv(file = clargs[4]) %>%
  
  # Match sample names
  filter(sample_id %in% sample_names(ps)) %>%
  distinct(.) %>%
  arrange(match(sample_id, sample_names(ps))) %>%
  column_to_rownames(var = "sample_id") %>%
  as.data.frame(.)

metadata_input <- sample_data(metadata)

ps <- merge_phyloseq(ps, metadata_input)

# Filter
ps_trimmed <- subset_samples(
  ps,
  !is.na(tree_id)
)

# Save
write_rds(
  ps_trimmed,
  file = clargs[5]
)
