#!/usr/bin/env Rscript --vanilla

# name : get_manifest.R
# author: William Argiroff
# input : directory of raw fastq files
# output : manifest file (tab delimited text file)
# notes : expects order of input output
#   expects input path ending in /reads/ and output path ending in /#PROJID#/

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)

manifest <- tibble(
  fastq_names = list.files(clargs[1],pattern = "\\.fastq.gz$", ignore.case = TRUE)
)

absolute_filepath <- paste(clargs[1], manifest$fastq_names, sep = "") %>%
  map_chr(., .f = normalizePath)

direction <- rep(c("forward","reverse"), dim(manifest)[1] / 2)

sample_id <- sapply(strsplit(manifest$fastq_names, "_"), "[", 1)

manifest_full <- cbind.data.frame(sample_id, absolute_filepath, direction) %>%
  
  pivot_wider(
    id_cols = sample_id,
    names_from = "direction",
    values_from = "absolute_filepath"
  ) %>%
  
  rename(
    `sample-id` = "sample_id",
    `forward-absolute-filepath` = "forward",
    `reverse-absolute-filepath` = "reverse"
  )

write_tsv(
  manifest_full,
  file = clargs[2]
)
