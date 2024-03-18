#!/usr/bin/env Rscript --vanilla

# name : make_site_mat_fig.R
# author: William Argiroff
# inputs : tibble with .rds with BioClim variables for each site
# output : pdf of figure
# notes : expects order of inputs (tibble), output fig

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(raster)
library(viridis)

# Read in data
bioclim_data <- read_rds(clargs[1])

site_coords <- read_tsv(clargs[2]) %>%
  filter(site != "Reserve") %>%
  # Add plot shapes
  mutate(
    transect_shape = NA,
    transect_shape = ifelse(transect == "CR", 1, transect_shape),
    transect_shape = ifelse(transect == "TR", 2, transect_shape),
    transect_shape = ifelse(transect == "MR", 0, transect_shape),
    transect_shape = ifelse(transect == "WC", 6, transect_shape)
  )

# Call pdf device
pdf(
  file = clargs[3],
  width = 10,
  height = 10
)

par(
  mar = c(5.1, 6.1, 4.1, 7.1),
  mfrow = c(2, 2),
  xpd = TRUE
)

# Elevation
plot(
  bioclim_data$elev,
  col = viridis(1e3),
  main = expression("Elevation (m)"),
  xlab = "Longitude",
  ylab = "Latitude",
  xlim = c(-125, -117.5),
  cex.main = 2,
  cex.lab = 2
  )

points(
  x = site_coords$lon,
  y = site_coords$lat,
  pch = site_coords$transect_shape,
  col = "white",
  cex = 2
)

legend(
  "left",
  inset = c(0, 0),
  legend = c("CR", "TR", "MR", "WC"),
  col="black",
  pch = c(1, 2, 0, 6),
  cex = 1.25,
  bg = "white"
)

# Mean annual temperature
plot(
  bioclim_data$bio_data$bio1,
  col = viridis(1e3),
  main = expression("Mean annual temperature ("*degree*C*")"),
  xlab="Longitude",
  ylab="Latitude",
  xlim = c(-125, -117.5),
  cex.main = 2,
  cex.lab = 2
)

points(
  x = site_coords$lon,
  y = site_coords$lat,
  pch = site_coords$transect_shape,
  col = "white",
  cex = 2
)

legend(
  "left",
  inset = c(0, 0),
  legend = c("CR", "TR", "MR", "WC"),
  col="black",
  pch = c(1, 2, 0, 6),
  cex = 1.25,
  bg = "white"
)

# Max temperature
plot(
  bioclim_data$bio_data$bio5,
  col = viridis(1e3),
  main = expression("Temp. of warmest month ("*degree*C*")"),
  xlab="Longitude",
  ylab="Latitude",
  xlim = c(-125, -117.5),
  cex.main = 2,
  cex.lab = 2
)

points(
  x = site_coords$lon,
  y = site_coords$lat,
  pch = site_coords$transect_shape,
  col = "white",
  cex = 2
)

legend(
  "left",
  inset = c(0, 0),
  legend = c("CR", "TR", "MR", "WC"),
  col="black",
  pch = c(1, 2, 0, 6),
  cex = 1.25,
  bg = "white"
)

# Annual water balance
plot(
  bioclim_data$water_bal,
  col = viridis(1e3),
  main = expression("Annual water balance ("*mm%.%y^-1*")"),
  xlab="Longitude",
  ylab="Latitude",
  xlim = c(-125, -117.5),
  cex.main = 2,
  cex.lab = 2
)

points(
  x = site_coords$lon,
  y = site_coords$lat,
  pch = site_coords$transect_shape,
  col = "white",
  cex = 2
)

legend(
  "left",
  inset = c(0, 0),
  legend = c("CR", "TR", "MR", "WC"),
  col="black",
  pch = c(1, 2, 0, 6),
  cex = 1.25,
  bg = "white"
)

dev.off()
