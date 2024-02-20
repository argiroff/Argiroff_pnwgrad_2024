#!/usr/bin/env Rscript --vanilla

# name : make_worldclim_stack.R
# author: William Argiroff
# inputs : WorldClim zip archive in data/bioclim/
# output : .rds per variable
# notes : expects order of input (zip), output (stack)

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(raster)

# Variables to stack normally
stack_vars <- paste(
  c(
    "wc2.1_2.5m_prec.zip",
    "wc2.1_2.5m_tmin.zip",
    "wc2.1_2.5m_tmax.zip"
  ), 
  collapse = "|"
)

if(str_detect(clargs[1], stack_vars)) {
  unzip(clargs[1], exdir = "data/bioclim")
  
  zip_name <- str_replace(clargs[1], ".zip", "_")
  
  filenames <- paste(
    zip_name,
    c(paste(0, 1:9, sep = ""), 10, 11, 12),
    ".tif",
    sep = ""
  )
  
} else if(str_detect(clargs[1], "wc2.1_2.5m_elev.zip")) {
  unzip(clargs[1], exdir = "data/bioclim")
  
  filenames = str_replace(clargs[1], ".zip", ".tif")
  
} else if(str_detect(clargs[1], "global-et0_monthly.tif.zip")) {
  unzip(clargs[1], exdir = "data/bioclim")
  
  filenames <- paste(
    "data/bioclim/et0_month/et0_",
    c(paste(0, 1:9, sep = ""), 10, 11, 12),
    ".tif",
    sep = ""
  )
  
} else {
  
  filenames <- clargs[1]
  
}

readme <- list.files(
  path = "data/bioclim",
  pattern = "readme.txt",
  full.names = TRUE
)

if(length(readme > 0)) {
  file.remove("data/bioclim/readme.txt")
  
} else {
  print("No readme to remove.")
  
}

outfile <- stack(filenames)

# Save
write_rds(
  outfile,
  clargs[2]
)
