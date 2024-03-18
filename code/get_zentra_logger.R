#!/usr/bin/env Rscript --vanilla

# name : get_zentra_logger.R
# author: William Argiroff
# inputs : text file with logger serial numbers
# output : pdf of figure
# notes : expects order of inputs (tibble), output fig

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(zentracloud)

# Get API token
cat("Enter ZentraClound API token: ")
zc_token <- readLines(con = "stdin", n = 1)

# Set token
setZentracloudOptions(
  token = zc_token
)

# Get site
site_number_temp <- str_remove(
  clargs[2],
  "data/logger/logger_reading_"
)

site_number <- str_remove(
  site_number_temp,
  ".rds"
)

# Get logger serial number
logger_sn <- read_tsv(clargs[1]) %>%
  filter(site == site_number) %>%
  pull(logger_sn)

# Get logger readings
logger_readings <- getReadings(
  device_sn = logger_sn,
  start_time = "2023-08-20 00:00:00",
  end_time = "2024-02-19 23:59:00"
)

# Save
write_rds(
  logger_readings,
  file = clargs[2]
)
