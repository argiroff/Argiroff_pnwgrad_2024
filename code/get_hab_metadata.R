#!/usr/bin/env Rscript --vanilla

# name : get_hab_metadata.R
# author: William Argiroff
# inputs : habitat specific ASV tables and full metadata table
# output : habitat-specific metadata

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

# Get sample ID filter
sample_id_filter <- read_tsv(clargs[1]) %>%
  pull(sample_id)

# Metadata
metadata <- read_tsv(clargs[2]) %>%
  filter(sample_id %in% sample_id_filter)

# Save
write_tsv(
  metadata,
  clargs[3]
)
