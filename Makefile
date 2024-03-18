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

#### Assign taxonomy ####

# 16S
TAX_16S=data/qiime2/final_qzas/16S/asv_taxonomy/

$(TAX_16S) : code/assign_tax_16s_asv.sh\
		data/qiime2/final_qzas/16S/merged_representative_sequences.qza\
		data/qiime2/final_qzas/taxonomy/16S/silva-138-99-515-806-nb-classifier.qza
	code/assign_tax_16s_asv.sh data/qiime2/final_qzas/16S/merged_representative_sequences.qza data/qiime2/final_qzas/taxonomy/16S/silva-138-99-515-806-nb-classifier.qza

# ITS
TAX_ITS=data/qiime2/final_qzas/ITS/asv_taxonomy/

$(TAX_ITS) : code/assign_tax_its_asv.sh\
		data/qiime2/final_qzas/ITS/merged_representative_sequences.qza\
		data/qiime2/final_qzas/taxonomy/ITS/unite_train/unite_QZAs/unite_ver9_seqs_dynamic_29112022.qza\
		data/qiime2/final_qzas/taxonomy/ITS/unite_train/unite_QZAs/unite_ver9_taxonomy_dynamic_29112022.qza
	code/assign_tax_its_asv.sh data/qiime2/final_qzas/ITS/merged_representative_sequences.qza data/qiime2/final_qzas/taxonomy/ITS/unite_train/unite_QZAs/unite_ver9_seqs_dynamic_29112022.qza data/qiime2/final_qzas/taxonomy/ITS/unite_train/unite_QZAs/unite_ver9_taxonomy_dynamic_29112022.qza

# qiime2 : $(MANIFEST_16S_OUT) $(MANIFEST_16S_OUT)\
# $(IMPORT_16S_OUT) $(IMPORT_ITS_OUT)\
# $(SUM_16S_OUT) $(SUM_ITS_OUT)\
# $(TRIM_16S_OUT) $(TRIM_ITS_OUT)\
# $(SUM_16S_TRIM) $(SUM_ITS_TRIM)\
# $(DADA2_16S) $(DADA2_ITS)\
# $(SUM_16S_DADA2) $(SUM_ITS_DADA2)\
# $(MERGE_TAB_16S) $(MERGE_SEQS_ITS)

# qiime2 : $(MERGE_TAB_16S) $(MERGE_TAB_ITS)\
# $(MERGE_SEQS_16S) $(MERGE_SEQS_ITS)\
# $(TAX_16S) $(TAX_ITS)

qiime2 : $(TAX_16S)

#### Format sequence metadata ####

# 16S
data/processed/16S/metadata_working/metadata_16s.txt : code/format_metadata.R\
		$$(MANIFEST_16S_OUT)\
		$$(SITE_COORD)
	code/format_metadata.R $(MANIFEST_16S_OUT) $(SITE_COORD) $@

# ITS
data/processed/ITS/metadata_working/metadata_its.txt : code/format_metadata.R\
		$$(MANIFEST_ITS_OUT)\
		$$(SITE_COORD)
	code/format_metadata.R $(MANIFEST_ITS_OUT) $(SITE_COORD) $@

#### Final phyloseq objects ####

# 16S, phyloseq untrimmed
PS_16S_UNTRIMMED=data/processed/16S/asv_processed/ps_untrimmed.rds

$(PS_16S_UNTRIMMED) : code/make_ps_untrimmed.R\
		$$(wildcard data/qiime2/final_qzas/16S/*.qza)\
		$$(wildcard $$(TAX_16S)*.qza)\
		data/processed/16S/metadata_working/metadata_16s.txt
	code/make_ps_untrimmed.R $(wildcard data/qiime2/final_qzas/16S/*.qza) $(wildcard $(TAX_16S)*.qza) data/processed/16S/metadata_working/metadata_16s.txt $@

# 16S, phyloseq trimmed
PS_16S_TRIMMED=data/processed/16S/asv_processed/ps_trimmed.rds

$(PS_16S_TRIMMED) : code/make_16s_ps_trimmed.R\
		$$(PS_16S_UNTRIMMED)
	code/make_16s_ps_trimmed.R $(PS_16S_UNTRIMMED) $@

# ITS, phyloseq untrimmed
PS_ITS_UNTRIMMED=data/processed/ITS/asv_processed/ps_untrimmed.rds

$(PS_ITS_UNTRIMMED) : code/make_ps_untrimmed.R\
		$$(wildcard data/qiime2/final_qzas/ITS/*.qza)\
		data/qiime2/final_qzas/ITS/asv_taxonomy/classification.qza\
		data/processed/ITS/metadata_working/metadata_its.txt
	code/make_ps_untrimmed.R data/qiime2/final_qzas/ITS/*.qza data/qiime2/final_qzas/ITS/asv_taxonomy/classification.qza data/processed/ITS/metadata_working/metadata_its.txt $@

# ITS, phyloseq trimmed
PS_ITS_TRIMMED=data/processed/ITS/asv_processed/ps_trimmed.rds

$(PS_ITS_TRIMMED) : code/make_its_ps_trimmed.R\
		$$(PS_ITS_UNTRIMMED)
	code/make_its_ps_trimmed.R $(PS_ITS_UNTRIMMED) $@

#### Final ASV tibbles ####

# 16S, ASV
FINAL_16S_ASV=data/processed/16S/asv_processed/asv_table.txt

$(FINAL_16S_ASV) : code/get_asv_tibble.R\
		$$(PS_16S_TRIMMED)
	code/get_asv_tibble.R $(PS_16S_TRIMMED) $@

# ITS, ASV
FINAL_ITS_ASV=data/processed/ITS/asv_processed/asv_table.txt

$(FINAL_ITS_ASV) : code/get_asv_tibble.R\
		$$(PS_ITS_TRIMMED)
	code/get_asv_tibble.R $(PS_ITS_TRIMMED) $@

#### Final metadata tibbles ####

# 16S, metadata
FINAL_16S_META=data/processed/16S/asv_processed/metadata_table.txt

$(FINAL_16S_META) : code/get_metadata_tibble.R\
		$$(PS_16S_TRIMMED)
	code/get_metadata_tibble.R $(PS_16S_TRIMMED) $@

# ITS, metadata
FINAL_ITS_META=data/processed/ITS/asv_processed/metadata_table.txt

$(FINAL_ITS_META) : code/get_metadata_tibble.R\
		$$(PS_ITS_TRIMMED)
	code/get_metadata_tibble.R $(PS_ITS_TRIMMED) $@

#### Final representative sequence fasta ####

# 16S, representative sequences
FINAL_16S_REPSEQS=data/processed/16S/asv_processed/representative_sequences.fasta

$(FINAL_16S_REPSEQS) : code/get_repseqs_fasta.R\
		$$(PS_16S_TRIMMED)
	code/get_repseqs_fasta.R $(PS_16S_TRIMMED) $@

# ITS, representative sequences
FINAL_ITS_REPSEQS=data/processed/ITS/asv_processed/representative_sequences.fasta

$(FINAL_ITS_REPSEQS) : code/get_repseqs_fasta.R\
		$$(PS_ITS_TRIMMED)
	code/get_repseqs_fasta.R $(PS_ITS_TRIMMED) $@

#### Final taxonomy tibbles ####

# 16S, taxonomy
FINAL_16S_TAX=data/processed/16S/asv_processed/taxonomy_table.txt

$(FINAL_16S_TAX) : code/get_taxonomy_tibble.R\
		$$(PS_16S_TRIMMED)
	code/get_taxonomy_tibble.R $(PS_16S_TRIMMED) $@

# ITS, taxonomy
FINAL_ITS_TAX=data/processed/ITS/asv_processed/taxonomy_table.txt

$(FINAL_ITS_TAX) : code/get_taxonomy_tibble.R\
		$$(PS_ITS_TRIMMED)
	code/get_taxonomy_tibble.R $(PS_ITS_TRIMMED) $@

#### Final sequence summary tibbles ####

# 16S sequence summary
FINAL_16S_SUM=data/processed/16S/asv_processed/sequence_summary.txt

$(FINAL_16S_SUM) : code/get_seq_summary_tibble.R\
		$$(PS_16S_UNTRIMMED)\
		$$(PS_16S_TRIMMED)
	code/get_seq_summary_tibble.R $(PS_16S_UNTRIMMED) $(PS_16S_TRIMMED) $@

# ITS sequence summary
FINAL_ITS_SUM=data/processed/ITS/asv_processed/sequence_summary.txt

$(FINAL_ITS_SUM) : code/get_seq_summary_tibble.R\
		$$(PS_ITS_UNTRIMMED)\
		$$(PS_ITS_TRIMMED)
	code/get_seq_summary_tibble.R $(PS_ITS_UNTRIMMED) $(PS_ITS_TRIMMED) $@

#### Split tables by habitat ####

# 16S, ASV
ASV_RH_16S=data/processed/16S/asv_processed/rhizosphere/asv_table.txt
ASV_BS_16S=data/processed/16S/asv_processed/soil/asv_table.txt
ASV_HAB_16S=$(ASV_RH_16S) $(ASV_BS_16S)

$(ASV_HAB_16S) : code/get_hab_asv.R\
		$$(FINAL_16S_ASV)\
		$$(FINAL_16S_META)
	code/get_hab_asv.R $(FINAL_16S_ASV) $(FINAL_16S_META) $@

# ITS, ASV
ASV_PH_ITS=data/processed/ITS/asv_processed/phyllosphere/asv_table.txt
ASV_RH_ITS=data/processed/ITS/asv_processed/rhizosphere/asv_table.txt
ASV_BS_ITS=data/processed/ITS/asv_processed/soil/asv_table.txt
ASV_HAB_ITS=$(ASV_PH_ITS) $(ASV_RH_ITS) $(ASV_BS_ITS)

$(ASV_HAB_ITS) : code/get_hab_asv.R\
		$$(FINAL_ITS_ASV)\
		$$(FINAL_ITS_META)
	code/get_hab_asv.R $(FINAL_ITS_ASV) $(FINAL_ITS_META) $@

# 16S, metadata
META_HAB_16S=$(subst asv_table.txt,metadata_table.txt,$(ASV_HAB_16S))

$(META_HAB_16S) : code/get_hab_metadata.R\
		$$(subst metadata_table.txt,asv_table.txt,$$@)\
		$$(FINAL_16S_META)
	code/get_hab_metadata.R $(subst metadata_table.txt,asv_table.txt,$@) $(FINAL_16S_META) $@

# ITS, metadata
META_HAB_ITS=$(subst asv_table.txt,metadata_table.txt,$(ASV_HAB_ITS))

$(META_HAB_ITS) : code/get_hab_metadata.R\
		$$(subst metadata_table.txt,asv_table.txt,$$@)\
		$$(FINAL_ITS_META)
	code/get_hab_metadata.R $(subst metadata_table.txt,asv_table.txt,$@) $(FINAL_ITS_META) $@

# 16S, repseqs
SEQS_HAB_16S=$(subst asv_table.txt,representative_sequences.fasta,$(ASV_HAB_16S))

$(SEQS_HAB_16S) : code/get_hab_repseqs.R\
		$$(subst representative_sequences.fasta,asv_table.txt,$$@)\
		$$(FINAL_16S_REPSEQS)
	code/get_hab_repseqs.R $(subst representative_sequences.fasta,asv_table.txt,$@) $(FINAL_16S_REPSEQS) $@

# ITS, repseqs
SEQS_HAB_ITS=$(subst asv_table.txt,representative_sequences.fasta,$(ASV_HAB_ITS))

$(SEQS_HAB_ITS) : code/get_hab_repseqs.R\
		$$(subst representative_sequences.fasta,asv_table.txt,$$@)\
		$$(FINAL_ITS_REPSEQS)
	code/get_hab_repseqs.R $(subst representative_sequences.fasta,asv_table.txt,$@) $(FINAL_ITS_REPSEQS) $@

# 16S, taxonomy
TAX_HAB_16S=$(subst asv_table.txt,taxonomy_table.txt,$(ASV_HAB_16S))

$(TAX_HAB_16S) : code/get_hab_taxonomy.R\
		$$(subst taxonomy_table.txt,asv_table.txt,$$@)\
		$$(FINAL_16S_TAX)
	code/get_hab_taxonomy.R $(subst taxonomy_table.txt,asv_table.txt,$@) $(FINAL_16S_TAX) $@

# ITS, taxonomy
TAX_HAB_ITS=$(subst asv_table.txt,taxonomy_table.txt,$(ASV_HAB_ITS))

$(TAX_HAB_ITS) : code/get_hab_taxonomy.R\
		$$(subst taxonomy_table.txt,asv_table.txt,$$@)\
		$$(FINAL_ITS_TAX)
	code/get_hab_taxonomy.R $(subst taxonomy_table.txt,asv_table.txt,$@) $(FINAL_ITS_TAX) $@

#### Split tables by habitat and site ####

SITE=CR1 CR1.5 CR2 CR3 CR4 TR1 TR2 TR2.5 TR3 TR3.5 TR4

# 16S, ASV
ASV_HABSITE_16S=$(foreach site,$(SITE),data/processed/16S/asv_processed/rhizosphere/$(site)_asv_table.txt)\
$(foreach site,$(SITE),data/processed/16S/asv_processed/soil/$(site)_asv_table.txt)

$(ASV_HABSITE_16S) : code/get_habsite_asv.R\
		$$(FINAL_16S_ASV)\
		$$(FINAL_16S_META)
	code/get_habsite_asv.R $(FINAL_16S_ASV) $(FINAL_16S_META) $@

# ITS, ASV
ASV_HABSITE_ITS=$(foreach site,$(SITE),data/processed/ITS/asv_processed/phyllosphere/$(site)_asv_table.txt)\
$(foreach site,$(SITE),data/processed/ITS/asv_processed/rhizosphere/$(site)_asv_table.txt)\
$(foreach site,$(SITE),data/processed/ITS/asv_processed/soil/$(site)_asv_table.txt)

$(ASV_HABSITE_ITS) : code/get_habsite_asv.R\
		$$(FINAL_ITS_ASV)\
		$$(FINAL_ITS_META)
	code/get_habsite_asv.R $(FINAL_ITS_ASV) $(FINAL_ITS_META) $@

# 16S, metadata
META_HABSITE_16S=$(subst _asv_table.txt,_metadata_table.txt,$(ASV_HABSITE_16S))

$(META_HABSITE_16S) : code/get_hab_metadata.R\
		$$(subst _metadata_table.txt,_asv_table.txt,$$@)\
		$$(FINAL_16S_META)
	code/get_hab_metadata.R $(subst _metadata_table.txt,_asv_table.txt,$@) $(FINAL_16S_META) $@

# ITS, metadata
META_HABSITE_ITS=$(subst _asv_table.txt,_metadata_table.txt,$(ASV_HABSITE_ITS))

$(META_HABSITE_ITS) : code/get_hab_metadata.R\
		$$(subst _metadata_table.txt,_asv_table.txt,$$@)\
		$$(FINAL_ITS_META)
	code/get_hab_metadata.R $(subst _metadata_table.txt,_asv_table.txt,$@) $(FINAL_ITS_META) $@

# 16S, repseqs
SEQS_HABSITE_16S=$(subst _asv_table.txt,_representative_sequences.fasta,$(ASV_HABSITE_16S))

$(SEQS_HABSITE_16S) : code/get_hab_repseqs.R\
		$$(subst _representative_sequences.fasta,_asv_table.txt,$$@)\
		$$(FINAL_16S_REPSEQS)
	code/get_hab_repseqs.R $(subst _representative_sequences.fasta,_asv_table.txt,$@) $(FINAL_16S_REPSEQS) $@

# ITS, repseqs
SEQS_HABSITE_ITS=$(subst _asv_table.txt,_representative_sequences.fasta,$(ASV_HABSITE_ITS))

$(SEQS_HABSITE_ITS) : code/get_hab_repseqs.R\
		$$(subst _representative_sequences.fasta,_asv_table.txt,$$@)\
		$$(FINAL_ITS_REPSEQS)
	code/get_hab_repseqs.R $(subst _representative_sequences.fasta,_asv_table.txt,$@) $(FINAL_ITS_REPSEQS) $@

# 16S, taxonomy
TAX_HABSITE_16S=$(subst _asv_table.txt,_taxonomy_table.txt,$(ASV_HABSITE_16S))

$(TAX_HABSITE_16S) : code/get_hab_taxonomy.R\
		$$(subst _taxonomy_table.txt,_asv_table.txt,$$@)\
		$$(FINAL_16S_TAX)
	code/get_hab_taxonomy.R $(subst _taxonomy_table.txt,_asv_table.txt,$@) $(FINAL_16S_TAX) $@

# ITS, taxonomy
TAX_HABSITE_ITS=$(subst _asv_table.txt,_taxonomy_table.txt,$(ASV_HABSITE_ITS))

$(TAX_HABSITE_ITS) : code/get_hab_taxonomy.R\
		$$(subst _taxonomy_table.txt,_asv_table.txt,$$@)\
		$$(FINAL_ITS_TAX)
	code/get_hab_taxonomy.R $(subst _taxonomy_table.txt,_asv_table.txt,$@) $(FINAL_ITS_TAX) $@

ps : data/processed/16S/metadata_working/metadata_16s.txt\
data/processed/ITS/metadata_working/metadata_its.txt\
$(PS_16S_UNTRIMMED) $(PS_16S_TRIMMED)\
$(PS_ITS_UNTRIMMED) $(PS_ITS_TRIMMED)\
$(FINAL_16S_ASV) $(FINAL_ITS_ASV)\
$(FINAL_16S_META) $(FINAL_ITS_META)\
$(FINAL_16S_REPSEQS) $(FINAL_ITS_REPSEQS)\
$(FINAL_16S_TAX) $(FINAL_ITS_TAX)\
$(FINAL_16S_SUM) $(FINAL_ITS_SUM)\
$(ASV_HAB_16S) $(ASV_HAB_ITS)\
$(META_HAB_16S) $(META_HAB_ITS)\
$(SEQS_HAB_16S) $(SEQS_HAB_ITS)\
$(TAX_HAB_16S) $(TAX_HAB_ITS)\
$(ASV_HABSITE_16S) $(ASV_HABSITE_ITS)\
$(META_HABSITE_16S) $(META_HABSITE_ITS)\
$(SEQS_HABSITE_16S) $(SEQS_HABSITE_ITS)\
$(TAX_HABSITE_16S) $(TAX_HABSITE_ITS)
