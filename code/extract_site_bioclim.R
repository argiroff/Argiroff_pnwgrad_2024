#!/usr/bin/env Rscript --vanilla

# name : extract_site_bioclim.R
# author: William Argiroff
# inputs : .rds in data/bioclim/ containing list of BioClim data 
# output : tibble with .rds with BioClim variables by site
# notes : expects order of inputs (stacks .rds), output rds

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(dismo)

# Read in BioClim data
bioclim_data <- read_rds(clargs[1])

# Get coordinates
site_coords <- read_tsv(clargs[2])

coords <- site_coords %>%
  dplyr::select(lon, lat) %>%
  as.data.frame(.)

spatial_points <- sp::SpatialPoints(
  coords,
  proj4string = bioclim_data$bio_data@crs
)

#### Function to extract values from raster layers ####

extract_raster_values <- function(x) {
  
  tmp1 <- raster::extract(x, spatial_points) %>%
    as.data.frame(.) %>%
    as_tibble(.)
  
  return(tmp1)
  
}

# Extract values
site_bioclim_data <- bioclim_data %>%
  .[c("bio_data", "elev", "water_bal", "sd_water")] %>%
  map(., .f = extract_raster_values) %>%
  
  # Combine
  bind_cols(
    site_coords["site"],
    site_coords["state"],
    site_coords["transect"],
    coordinates(spatial_points),
    .
  )

colnames(site_bioclim_data) <- c(
  "site", "state", "transect", "longitude", "latitude",
  "bio1", "bio2", "bio3", "bio4", "bio5", "bio6",
  "bio7", "bio8", "bio9", "bio10", "bio11", "bio12",
  "bio13", "bio14", "bio15", "bio16", "bio17", "bio18",
  "bio19","elev", "ann_water", "stdev_water"
)

# Save
write_tsv(
  site_bioclim_data,
  file = clargs[3]
)
