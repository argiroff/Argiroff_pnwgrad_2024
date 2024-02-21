#!/usr/bin/env Rscript --vanilla

# name : crop_worldclim_stack.R
# author: William Argiroff
# inputs : .rds for each variable in data/bioclim/
# output : cropped .rds for each variable in data/bioclim/
# notes : expects order of input, output

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(raster)

# Create the limits for the grid
grid_xmin <- -125  # 124 degrees W
grid_xmax <- -118 # 118 degrees W
grid_ymin <- 42    # 40 degrees N 
grid_ymax <- 49    # 50 degrees N

# Combine
grid_extent <- extent(grid_xmin, grid_xmax, grid_ymin, grid_ymax)

# Crop
if(str_detect(clargs[1], "global-et0_monthly.tif_stack.rds")) {
  clim_stack <- read_rds(clargs[1])
  
  clim_crop_temp <- crop(clim_stack, grid_extent)
  
  clim_crop <- aggregate(clim_crop_temp, fact = 5)
  
} else {
  clim_stack <- read_rds(clargs[1])
  
  clim_crop <- crop(clim_stack, grid_extent)
  
}

# Save
write_rds(
  clim_crop,
  file = clargs[2]
)
