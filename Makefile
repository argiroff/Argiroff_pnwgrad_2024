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



