#!/usr/bin/env Rscript --vanilla

# name : get_asv_tibble.R
# author: William Argiroff
# inputs : Trimmed phyloseq object
# output : ASV table as a 3 column tibble
# notes : expects order of inputs, output
#   expects input paths for asv_processed/ps_trimmed.rds
#   and output data/processed/<16S or ITS>/asv_processed/asv_tibble.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(phyloseq)

ps <- read_rds(clargs[1])

# ASV table, long format
asv <- otu_table(ps) %>%
  
  as.data.frame(.) %>%

  as_tibble(rownames = NA) %>%
  
  rownames_to_column(var = "asv_id") %>%
  
  pivot_longer(
    -asv_id,
    names_to = "sample_id",
    values_to = "n_seqs"
  ) %>%
  
  select(sample_id, asv_id, n_seqs)

# Save
write_tsv(
  asv,
  file = clargs[2]
)
