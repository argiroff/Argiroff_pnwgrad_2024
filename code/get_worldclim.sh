#!/usr/bin/env bash

# Get input files and download WorldClim data from https://biogeo.ucdavis.edu/data/worldclim/v2.1/base/
infile=$1

# Get URL based on input file
if [[ "$infile" == "data/bioclim/global-et0_monthly.tif.zip" ]]
then
    inurl=https://figshare.com/ndownloader/files/13901324
else
    inurl=`echo "$infile" | sed -E "s/data\/bioclim\//https:\/\/biogeo.ucdavis.edu\/data\/worldclim\/v2.1\/base\//"`
fi

# Download
wget -P data/bioclim -nc $inurl

# Rename ev file
if [[ "$infile" == "data/bioclim/global-et0_monthly.tif.zip" ]]
then
    mv data/bioclim/13901324 data/bioclim/global-et0_monthly.tif.zip
fi

# Update timestamp
touch $infile

echo "Done."
