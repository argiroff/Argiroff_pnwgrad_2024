#!/usr/bin/env Rscript --vanilla

# name : format_16s_board_metadata.R
# author: William Argiroff
# inputs : Sequence sample metadata files
# output : Single uniform metadata file to merge with phyloseq object

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

# Site coordinates
site_coords <- read_tsv(clargs[3])

# Metadata
metadata <- clargs[1:2] %>%
  map(., .f = read_tsv) %>%
  bind_rows(.) %>%
  rename(sample_id = "sample-id") %>%
  select(sample_id) %>%
  
  # Get metadata
  mutate(
    
    site = sample_id,
    site = str_remove(site, "-16S|-ITS"),
    site = str_remove(site, "-leaf|-rhizo|-soil"),
    
    site = ifelse(
      str_detect(site, "NTC-"),
      NA,
      site
    ),
    
    site = ifelse(
      str_detect(site, "Extr-|Extraction"),
      NA,
      site
    ),
    
    site = str_replace(site, "1-5", "1.5"),
    site = str_replace(site, "2-5", "2.5"),
    site = str_replace(site, "3-5", "3.5"),
    
    community = str_extract(sample_id, "-16S|-ITS"),
    community = str_remove(community, "-"),
    
    community = ifelse(
      community == "16S",
      "Bacteria and Archaea",
      community
    ),
    
    community = ifelse(
      community == "ITS",
      "Fungi",
      community
    ),
    
    plant_habitat = str_extract(sample_id, "-leaf|-rhizo|-soil"),
    plant_habitat = str_remove(plant_habitat, "-"),
    
    plant_habitat = ifelse(
      plant_habitat == "leaf",
      "Phyllosphere",
      plant_habitat
    ),
    
    plant_habitat = ifelse(
      plant_habitat == "rhizo",
      "Rhizosphere",
      plant_habitat
    ),
    
    plant_habitat = ifelse(
      plant_habitat == "soil",
      "Soil",
      plant_habitat
    )
    
  ) %>%
  
  separate(site, into = c("site", "tree_id"), sep = "-") %>%
  left_join(., site_coords, by = "site")

# Save
write_tsv(
  metadata,
  clargs[4]
)
