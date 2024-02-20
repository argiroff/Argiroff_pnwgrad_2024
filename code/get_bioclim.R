#!/usr/bin/env Rscript --vanilla

# name : get_bioclim.R
# author: William Argiroff
# inputs : .rds cropped WorldClim stacks in data/bioclim/
# output : .rds with BioClim variables for cropped grid
# notes : expects order of inputs (stacks .rds), output rds

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(dismo)

# Read in
data_precip <- read_rds(clargs[1])
data_tmin <- read_rds(clargs[2])
data_tmax <- read_rds(clargs[3])
data_elev <- read_rds(clargs[4])
data_pet <- read_rds(clargs[5])

# Get BioVars
data_bio <- dismo::biovars(data_precip, data_tmin, data_tmax)

# Create list to hold ET raster layers
et <- vector(mode = "list", length = 12) %>%
  
  set_names(
    nm = c(
      "et1", "et2", "et3", "et4", "et5", "et6",
      "et7", "et8", "et9", "et10", "et11", "et12"
    )
  )

# Create vectors of layer names
precip_names <- c(
  "wc2.1_2.5m_prec_01",
  "wc2.1_2.5m_prec_02",
  "wc2.1_2.5m_prec_03",
  "wc2.1_2.5m_prec_04",
  "wc2.1_2.5m_prec_05",
  "wc2.1_2.5m_prec_06",
  "wc2.1_2.5m_prec_07",
  "wc2.1_2.5m_prec_08",
  "wc2.1_2.5m_prec_09",
  "wc2.1_2.5m_prec_10",
  "wc2.1_2.5m_prec_11",
  "wc2.1_2.5m_prec_12"
)

pet_names <- c(
  "OBJECTID.1",
  "OBJECTID.2",
  "OBJECTID.3",
  "OBJECTID.4",
  "OBJECTID.5",
  "OBJECTID.6",
  "OBJECTID.7",
  "OBJECTID.8",
  "OBJECTID.9",
  "OBJECTID.10",
  "OBJECTID.11",
  "OBJECTID.12"
)

# Calculate ET for each month
for(i in 1 : length(et)) {
  
  et[[i]] <- data_precip[[precip_names[i]]] - data_pet[[pet_names[i]]]
  
}

# Annual water balance
ann_water <- sum(
  et$et1, et$et2, et$et3, et$et4, et$et5, et$et6,
  et$et7, et$et8, et$et9, et$et10, et$et11, et$et12
)

# SD of annual water balance
mu2 <- ann_water / 12

sumsquares2 <- (
  (et$et1 - mu2) ^ 2 + (et$et2 - mu2)^2 + (et$et3 - mu2)^2 +
    (et$et4 - mu2)^2 + (et$et5 - mu2)^2 + (et$et6 - mu2)^2 + 
    (et$et7 - mu2)^2 + (et$et8 - mu2)^2 + (et$et9 - mu2)^2 + 
    (et$et10 - mu2)^2 + (et$et11 - mu2)^2 + (et$et12 - mu2)^2
)

stdev_water <- sqrt(sumsquares2 / 12)

# Combine
bioclim_data <- list(
  data_bio,
  et,
  ann_water,
  stdev_water
) %>%
  
  set_names(
    nm = c("bio_data", "evap_trans", "water_bal", "sd_water")
  )

# Save
write_rds(
  bioclim_data,
  file = clargs[6]
)
