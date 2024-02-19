#!/usr/bin/env Rscript --vanilla

# name : download_worldclim.R
# author: William Argiroff
# inputs : Sequence sample metadata files
#   data/metadata/BOARD/BOARD_metadata_SraRunTable.txt
# output : Single uniform metadata file to merge with phyloseq object
# notes : expects order of inputs (args ##-##) output

clargs <- commandArgs(trailingOnly = TRUE)

