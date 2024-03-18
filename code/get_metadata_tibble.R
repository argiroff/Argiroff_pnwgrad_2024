#!/usr/bin/env Rscript --vanilla

# name : get_metadata_tibble.R
# author: William Argiroff
# inputs : Trimmed phyloseq object
# output : Metadata tibble
# notes : expects order of inputs, output
#   expects input paths for asv_processed/ps_trimmed.rds
#   and output data/processed/<16S or ITS>/asv_processed/metadata_tibble.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(phyloseq)

# OTU table
ps <- read_rds(clargs[1])

# Metadata
metadata <- sample_data(ps) %>%
  as.data.frame(.) %>%
  as_tibble(rownames = NA) %>%
  rownames_to_column(var = "sample_id") %>%
  distinct(.)

# Save
write_tsv(
  metadata,
  file = clargs[2]
)
