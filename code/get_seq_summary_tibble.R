#!/usr/bin/env Rscript --vanilla

# name : get_taxonomy_tibble.R
# author: William Argiroff
# inputs : Trimmed and untrimmed phyloseq objects
# output : tibble of sequence totals
# notes : expects order of inputs, output
#   expects input paths for asv_processed/ps_trimmed.rds 
#   asv_processed/ps_untrimmed.rds and output 
#   data/processed/<16S or ITS>/asv_processed/taxonomy_tibble.txt

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(phyloseq)

ps_untrimmed <- read_rds(clargs[1])

ps_trimmed <- read_rds(clargs[2])

seq_totals <- tibble(
  pre_trim = sum(sample_sums(ps_untrimmed)),
  post_trim = sum(sample_sums(ps_trimmed))
)

write_tsv(
  seq_totals,
  file = clargs[3]
)
