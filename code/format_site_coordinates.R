#!/usr/bin/env Rscript --vanilla

# name : format_site_coordinates.R
# author: William Argiroff
# inputs : site coordinate .txt files in data/metadata
# output : tibble with lon and lat for each site
# notes : expects order of inputs (site coordinates, new site coordinates),
#   output filename

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

# Format coordinates for additional sites
new_coords <- read_tsv(clargs[1]) %>%
  
  rename(
    lon = "longitude",
    lat = "latitude",
    elevation = "altitude"
  ) %>%
  
  select(
    state,
    site,
    lat,
    lon,
    elevation
  ) %>%
  
  group_by(
    state,
    site
  ) %>%
  
  summarise(
    lat = mean(lat),
    lon = mean(lon),
    elevation = mean(elevation)
  ) %>%
  
  ungroup(.)

# Combine with permanent sites
coords <- read_tsv(clargs[2]) %>%
  bind_rows(., new_coords) %>%
  
  # Add transect
  mutate(
    transect = str_remove(site, "\\..*"),
    transect = str_remove(transect, "[0-9]")
  ) %>%
  
  relocate(
    site,
    state,
    everything()
  )

# Save
write_tsv(
  coords,
  file = clargs[3]
)
