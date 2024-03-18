#!/usr/bin/env Rscript --vanilla

# name : get_taxonomy_tibble.R
# author: William Argiroff
# inputs : Trimmed phyloseq object
# output : tibble of taxonomic classifications
# notes : expects order of inputs, output
#   expects input paths for asv_processed/ps_trimmed.rds and output 
#   data/processed/<16S or ITS>/asv_processed/taxonomy_tibble.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(phyloseq)

# Get taxonomy
ps <- read_rds(clargs[1])

taxonomy <- tax_table(ps) %>%
  as.data.frame(.) %>%
  as_tibble(rownames = NA) %>%
  rownames_to_column(var = "asv_id")

# Save
write_tsv(
  taxonomy,
  file = clargs[2]
)
