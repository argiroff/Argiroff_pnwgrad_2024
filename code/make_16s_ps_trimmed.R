#!/usr/bin/env Rscript --vanilla

# name : make_16s_ps_trimmed.R
# author: William Argiroff
# inputs : untrimmed phyloseq
# output : trimmed phyloseq object
# notes : expects order of inputs, output
#   -- output data/processed/16S/asv_processed/ps_trimmed.rds

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(phyloseq)

ps_16s <- read_rds(clargs[1])

# Remove sequences that are not bacteria or archaea and drop ASVs with no seqs
ps_16s_trimmed <- subset_taxa(ps_16s, Kingdom == "d__Bacteria" | Kingdom == "d__Archaea")

ps_16s_trimmed <- subset_taxa(ps_16s_trimmed, Order != "Chloroplast")

ps_16s_trimmed <- subset_taxa(ps_16s_trimmed, Family != "Mitochondria")

ps_16s_trimmed <- prune_taxa(taxa_sums(ps_16s_trimmed) > 0, ps_16s_trimmed)

ps_16s_trimmed <- prune_samples(sample_sums(ps_16s_trimmed) > 0, ps_16s_trimmed)

# Save
write_rds(
  ps_16s_trimmed,
  file = clargs[2]
)
