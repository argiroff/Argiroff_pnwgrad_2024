.SECONDARY:
.SECONDEXPANSION:
print-% :
	@echo '$*=$($*)'

# Rule
# target : prerequisite1 prerequisite2 prerequisite3
# (tab)recipe (and other arguments that are passed to the BASH[or other] script)

#### BioClim ####

# Download WorldClim data (precip, tmin, tmax, elev, et)
GET_WORLDCLIM=data/bioclim/wc2.1_2.5m_prec.zip\
data/bioclim/wc2.1_2.5m_tmin.zip\
data/bioclim/wc2.1_2.5m_tmax.zip\
data/bioclim/wc2.1_2.5m_elev.zip\
data/bioclim/global-et0_monthly.tif.zip

$(GET_WORLDCLIM) : code/get_worldclim.sh
	code/get_worldclim.sh $@

# Make raster stack for each WorldClim variable
STACK_WORLDCLIM=$(subst .zip,_stack.rds,$(GET_WORLDCLIM))

$(STACK_WORLDCLIM) : code/make_worldclim_stack.R\
		$$(subst _stack.rds,.zip,$$@)
	code/make_worldclim_stack.R $(subst _stack.rds,.zip,$@) $@

# Format site coordinates
SITE_COORD=data/metadata/all_sep2023_site_coordinates.txt

$(SITE_COORD) : code/format_site_coordinates.R\
		data/metadata/sep2023_new_site_coordinates.txt\
		data/metadata/site_coordinates.txt
	code/format_site_coordinates.R data/metadata/sep2023_new_site_coordinates.txt data/metadata/site_coordinates.txt $@

# Crop WorldClim stacks
CROP_WORLDCLIM=$(subst stack.rds,cropped_stack.rds,$(STACK_WORLDCLIM))

$(CROP_WORLDCLIM) : code/crop_worldclim_stack.R\
		$$(subst cropped_stack.rds,stack.rds,$$@)
	code/crop_worldclim_stack.R $(subst cropped_stack.rds,stack.rds,$@) $@

# Get BioClim
BIOCLIM=data/bioclim/bioclim.rds

$(BIOCLIM) : code/get_bioclim.R\
		$$(CROP_WORLDCLIM)
	code/get_bioclim.R $(CROP_WORLDCLIM) $@

# Extract site-specific BioClim data
SITE_BIOCLIM=data/bioclim/site_bioclim.txt

$(SITE_BIOCLIM) : code/extract_site_bioclim.R\
		$$(BIOCLIM)\
		$$(SITE_COORD)
	code/extract_site_bioclim.R $(BIOCLIM) $(SITE_COORD) $@

# Plot mean annual temperature, max temp, and water balance
BIOCLIM_FIG=figures/site_bioclim.pdf

$(BIOCLIM_FIG) : code/make_site_bioclim_fig.R\
		$$(SITE_BIOCLIM)
	code/make_site_bioclim_fig.R $(SITE_BIOCLIM) $@

# Map elevation mean annual temperature, max temp, and water balance
BIOCLIM_MAP=figures/bioclim_maps.pdf

$(BIOCLIM_MAP) : code/make_bioclim_maps.R\
		$$(BIOCLIM)\
		$$(SITE_COORD)
	code/make_bioclim_maps.R $(BIOCLIM) $(SITE_COORD) $@

bioclim : $(GET_WORLDCLIM) $(STACK_WORLDCLIM) $(SITE_COORD)\
$(CROP_WORLDCLIM) $(BIOCLIM) $(SITE_BIOCLIM) $(BIOCLIM_FIG)\
$(BIOCLIM_MAP)

#### Data loggers ####

# Download data from ZentraCloud
LOGGER_SITE=CR1 CR2 CR3 CR4 TR1 TR2 TR3 TR4\
MR1 MR2 MR3 MR4 WC1 WC2 WC3 WC4
GET_LOGGER=$(foreach site,$(LOGGER_SITE),data/logger/logger_reading_$(site).rds)

$(GET_LOGGER) : code/get_zentra_logger.R\
		data/metadata/logger_sn.txt
	code/get_zentra_logger.R data/metadata/logger_sn.txt $@

logger : $(GET_LOGGER)

#### Use R to make QIIME2 manifest files ####

# 16S
PATH_16S=$(wildcard data/qiime2/16S/*)
MANIFEST_16S_OUT=$(foreach path,$(PATH_16S),$(path)/manifest.txt)

$(MANIFEST_16S_OUT) : code/get_manifest.R\
		$$(dir $$@)reads/
	code/get_manifest.R $(dir $@)reads/ $@

# ITS
PATH_ITS=$(wildcard data/qiime2/ITS/*)
MANIFEST_ITS_OUT=$(foreach path,$(PATH_ITS),$(path)/manifest.txt)

$(MANIFEST_ITS_OUT) : code/get_manifest.R\
		$$(dir $$@)reads/
	code/get_manifest.R $(dir $@)reads/ $@

qiime2 : $(MANIFEST_16S_OUT) $(MANIFEST_16S_OUT)\
$(IMPORT_16S_OUT) $(IMPORT_ITS_OUT)

#### IMPORT fastq to qza using QIIME2 ####

# 16S
IMPORT_16S_OUT=$(foreach path,$(PATH_16S),$(path)/demux.qza)

$(IMPORT_16S_OUT) : code/import_seqs_to_qza.sh\
		$$(dir $$@)manifest.txt
	code/import_seqs_to_qza.sh $(dir $@)manifest.txt

# ITS
IMPORT_ITS_OUT=$(foreach path,$(PATH_ITS),$(path)/demux.qza)

$(IMPORT_ITS_OUT) : code/import_seqs_to_qza.sh\
		$$(dir $$@)manifest.txt
	code/import_seqs_to_qza.sh $(dir $@)manifest.txt

IMPORT_ITS=$(MANIFEST_ITS_OUT) $(IMPORT_ITS_OUT)

#### Summarize imported raw seqs as qzv ####

# 16S
SUM_16S_OUT=$(foreach path,$(PATH_16S),$(path)/demux_summary.qzv)

$(SUM_16S_OUT) : code/summarize_seqs.sh\
		$$(dir $$@)demux.qza
	code/summarize_seqs.sh $(dir $@)demux.qza

# ITS
SUM_ITS_OUT=$(foreach path,$(PATH_ITS),$(path)/demux_summary.qzv)

$(SUM_ITS_OUT) : code/summarize_seqs.sh\
		$$(dir $$@)demux.qza
	code/summarize_seqs.sh $(dir $@)demux.qza

#### Trim sequences ####

# 16S, cutadapt
TRIM_16S_OUT=$(foreach path,$(PATH_16S),$(path)/trimmed.qza)

$(TRIM_16S_OUT) : code/cutadapt_16s.sh\
		$$(dir $$@)demux.qza
	code/cutadapt_16s.sh $(dir $@)demux.qza

# ITS, ITSxpress
TRIM_ITS_OUT=$(foreach path,$(PATH_ITS),$(path)/trimmed.qza)

$(TRIM_ITS_OUT) : code/itsxpress_its.sh\
		$$(dir $$@)demux.qza
	code/itsxpress_its.sh $(dir $@)demux.qza

#### Summarize trimmed seqs as qzv ####

# 16S
SUM_16S_TRIM=$(foreach path,$(PATH_16S),$(path)/trimmed_summary.qzv)

$(SUM_16S_TRIM) : code/summarize_trimmed_seqs.sh\
		$$(dir $$@)trimmed.qza
	code/summarize_trimmed_seqs.sh $(dir $@)trimmed.qza

# ITS
SUM_ITS_TRIM=$(foreach path,$(PATH_ITS),$(path)/trimmed_summary.qzv)

$(SUM_ITS_TRIM) : code/summarize_trimmed_seqs.sh\
		$$(dir $$@)trimmed.qza
	code/summarize_trimmed_seqs.sh $(dir $@)trimmed.qza

#### DADA2

# 16S
DADA2_16S=$(foreach path,$(PATH_16S),$(path)/dada2/)

$(DADA2_16S) : code/dada2.sh\
		$$(subst dada2,trimmed.qza,$$@)
	code/dada2.sh $(subst dada2,trimmed.qza,$@)

# ITS
DADA2_ITS=$(foreach path,$(PATH_ITS),$(path)/dada2/)

$(DADA2_ITS) : code/dada2.sh\
		$$(subst dada2,trimmed.qza,$$@)
	code/dada2.sh $(subst dada2,trimmed.qza,$@)

#### Summarize DADA2 output as qzv ####

# 16S
SUM_16S_DADA2=$(foreach path,$(PATH_16S),$(path)/denoising_stats_summary.qzv)

$(SUM_16S_DADA2) : code/summarize_dada2.sh\
		$$(dir $$@)dada2/denoising_stats.qza
	code/summarize_dada2.sh $(dir $@)dada2/denoising_stats.qza

# ITS
SUM_ITS_DADA2=$(foreach path,$(PATH_ITS),$(path)/denoising_stats_summary.qzv)

$(SUM_ITS_DADA2) : code/summarize_dada2.sh\
		$$(dir $$@)dada2/denoising_stats.qza
	code/summarize_dada2.sh $(dir $@)dada2/denoising_stats.qza

#### Merge ASV tables ####

# 16S
TAB_16S=$(wildcard data/qiime2/16S/*/dada2/table.qza)
MERGE_TAB_16S=data/qiime2/final_qzas/16S/merged_table.qza

$(MERGE_TAB_16S) : code/merge_tables.sh\
		$$(TAB_16S)
	code/merge_tables.sh $(TAB_16S)

#ITS
TAB_ITS=$(wildcard data/qiime2/ITS/*/dada2/table.qza)
MERGE_TAB_ITS=data/qiime2/final_qzas/ITS/merged_table.qza

$(MERGE_TAB_ITS) : code/merge_tables.sh\
		$$(TAB_ITS)
	code/merge_tables.sh $(TAB_ITS)

#### Merge ASV representative sequences ####

# 16S
SEQS_16S=$(wildcard data/qiime2/16S/*/dada2/representative_sequences.qza)
MERGE_SEQS_16S=data/qiime2/final_qzas/16S/merged_representative_sequences.qza

$(MERGE_SEQS_16S) : code/merge_repseqs.sh\
		$$(SEQS_16S)
	code/merge_repseqs.sh $(SEQS_16S)

#ITS
SEQS_ITS=$(wildcard data/qiime2/ITS/*/dada2/representative_sequences.qza)
MERGE_SEQS_ITS=data/qiime2/final_qzas/ITS/merged_representative_sequences.qza

$(MERGE_SEQS_ITS) : code/merge_repseqs.sh\
		$$(SEQS_ITS)
	code/merge_repseqs.sh $(SEQS_ITS)
