#!/usr/bin/env Rscript --vanilla

# name : get_hab_taxonomy.R
# author: William Argiroff
# inputs : habitat specific ASV tables and full taxonomy table
# output : habitat-specific taxonomy table

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

# Trim taxonoy
tax <- read_tsv(clargs[2]) %>%
  filter(asv_id %in% asv_id_filter)

# Save
write_tsv(
  tax,
  clargs[3]
)
