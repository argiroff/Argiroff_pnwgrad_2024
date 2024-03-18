#!/usr/bin/env Rscript --vanilla

# name : make_its_ps_trimmed.R
# author: William Argiroff
# inputs : untrimmed phyloseq
# output : trimmed phyloseq object
# notes : expects order of inputs, output
#   -- output data/processed/ITS/asv_processed/ps_trimmed.rds

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(phyloseq)

ps_its <- read_rds(clargs[1])

# Remove sequences that are not bacteria or archaea and drop ASVs with no seqs
ps_its_trimmed <- subset_taxa(ps_its, Kingdom == "Fungi")

ps_its_trimmed <- prune_taxa(taxa_sums(ps_its_trimmed) > 0, ps_its_trimmed)

ps_its_trimmed <- prune_samples(sample_sums(ps_its_trimmed) > 0, ps_its_trimmed)

# Save
write_rds(
  ps_its_trimmed,
  file = clargs[2]
)
