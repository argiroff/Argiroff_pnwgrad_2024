#!/usr/bin/env Rscript --vanilla

# name : get_hab_repseqs.R
# author: William Argiroff
# inputs : habitat specific ASV tables and full rep seqs fasta
# output : habitat-specific rep seqs fasta

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

# Get ASV ID filter
asv_id_filter <- read_tsv(clargs[1]) %>%
  pivot_longer(
    -sample_id,
    names_to = "asv_id",
    values_to = "n_seqs"
  ) %>%
  select(asv_id) %>%
  distinct(.) %>%
  pull(asv_id)

# Trim representative sequences
repseqs <- Biostrings::readDNAStringSet(
  filepath = clargs[2],
  format = "fasta"
)

repseqs_out <- repseqs[asv_id_filter]

# Save
Biostrings::writeXStringSet(
  repseqs_out,
  filepath = clargs[3],
  format = "fasta"
)
