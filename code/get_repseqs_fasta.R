#!/usr/bin/env Rscript --vanilla

# name : get_repseqs_fasta.R
# author: William Argiroff
# inputs : Trimmed phyloseq object
# output : rep seq fasta file
# notes : expects order of inputs, output
#   expects input path for asv_processed/ps_trimmed.rds and output 
#   data/processed/<16S or ITS>/asv_processed/representative_sequences.fasta

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(phyloseq)

ps <- read_rds(clargs[1])

repseqs <- refseq(ps)

# Save
Biostrings::writeXStringSet(
  repseqs,
  filepath = clargs[2],
  format = "fasta"
)
