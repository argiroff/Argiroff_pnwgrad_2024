#!/usr/bin/env Rscript --vanilla

# name : get_hab_asv.R
# author: William Argiroff
# inputs : full ASV table
# output : habitat-specific ASV table
# notes : expects order of inputs, output

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

source("code/functions.R")

# Filters
if(str_detect(clargs[3], "/phyllosphere/")) {
  
  planthab_filter <- "Phyllosphere"
  
} else if(str_detect(clargs[3], "/rhizosphere/")) {
  
  planthab_filter <- "Rhizosphere"
  
} else if(str_detect(clargs[3], "/soil/")) {
  
  planthab_filter <- "Soil"
  
} else {
  
  planthab_filter <- NULL
  
}

# Get site filter
site_filter <- clargs[3] %>%
  str_remove(., "data/processed/16S/asv_processed/|data/processed/ITS/asv_processed/") %>%
  str_remove(., "phyllosphere/|rhizosphere/|soil/") %>%
  str_remove(., "_asv_table.txt")

# Get sample ID filter
sample_id_filter <- read_tsv(clargs[2]) %>%
  filter(plant_habitat %in% planthab_filter) %>%
  filter(site == site_filter) %>%
  pull(sample_id)

# ASV
asv <- read_tsv(clargs[1]) %>%
  filter(sample_id %in% sample_id_filter) %>%
  drop_0seq_asvs(.) %>%
  
  # Wide format
  pivot_wider(
    id_cols = sample_id,
    names_from = "asv_id",
    values_from = "n_seqs",
    values_fill = 0
  )

# Save
write_tsv(
  asv,
  clargs[3]
)
