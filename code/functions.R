#### Drop ASVs with no sequences ####

drop_0seq_asvs <- function(x) {
  
  tmp1 <- x %>%
    group_by(asv_id) %>%
    mutate(asv_n_seqs = sum(n_seqs)) %>%
    ungroup(.) %>%
    filter(asv_n_seqs > 0) %>%
    select(-asv_n_seqs)
  
  return(tmp1)
  
}

#### Drop samples with no sequences ####

drop_0seq_samples <- function(x) {
  
  tmp1 <- x %>%
    group_by(sample_id) %>%
    mutate(sample_n_seqs = sum(n_seqs)) %>%
    ungroup(.) %>%
    filter(sample_n_seqs > 0) %>%
    select(-sample_n_seqs)
  
  return(tmp1)
  
}

#### Read metadata ####

read_metadata <- function(x) {
  
  tmp1 <- read_tsv(x, col_types = cols(root_dist = col_double()))
  
  return(tmp1)
  
}

#### Function to get facet titles ####

get_facet_title <- function(community, plant_habitat) {
  
  if(community == "Bacteria and Archaea" & plant_habitat == "Root endosphere") {
    
    tmp1 = "(a)"
    
  } else if(community == "Bacteria and Archaea" & plant_habitat == "Rhizosphere") {
    
    tmp1 = "(c)"
    
  } else if(community == "Bacteria and Archaea" & plant_habitat == "Soil") {
    
    tmp1 = "(e)"
    
  } else if(community == "Fungi" & plant_habitat == "Root endosphere") {
    
    tmp1 = "(b)"
    
  } else if(community == "Fungi" & plant_habitat == "Rhizosphere") {
    
    tmp1 = "(d)"
    
  } else if(community == "Fungi" & plant_habitat == "Soil") {
    
    tmp1 = "(f)"
    
  }
  
  return(tmp1)
  
}

#### Function to format axis labels

format_axis <- function(x) {
  
  tmp1 <- format(x, big.mark = ",", scientific = FALSE)
  
  return(tmp1)
  
}

#### Trim ASVs based on presence/absence ####

trim_asv_pa <- function(x, asv.pa) {
  
  # ASV ID filter
  tmp1 <- x %>%
    mutate(asv_pa = ifelse(n_seqs > 0, 1, 0)) %>%
    group_by(asv_id) %>%
    summarise(asv_total_pa = sum(asv_pa)) %>%
    ungroup() %>%
    filter(asv_total_pa >= asv.pa) %>%
    pull(asv_id)
  
  # Trim
  tmp2 <- x %>%
    filter(asv_id %in% tmp1)
  
  return(tmp2)
  
}

#### Function to get list names for TITAN outputs ####

get_TITAN_list_names <- function(x) {
  
  tmp1 <- x %>%
    str_remove(., "data/processed/") %>%
    str_remove(., "_titan_output.rds") %>%
    str_replace(., "/titan/", "_") %>%
    str_replace(., "/", "_")
  
  return(tmp1)
}

#### Function to format TITAN outputs

format_TITAN_outputs <- function(x) {
  
  # Format table
  tmp1 <- x %>%
    separate(
      col = ID,
      into = c("community", "cutoff", "plant_habitat"),
      sep = "_"
    ) %>%
    
    mutate(
      
      community = ifelse(community == "16S", "Bacteria and Archaea", community),
      community = ifelse(community == "ITS", "Fungi", community),
      
      cutoff = round(as.numeric(cutoff) / 100, 2),
      
      plant_habitat = ifelse(plant_habitat == "BS", "Soil", plant_habitat),
      plant_habitat = ifelse(plant_habitat == "RH", "Rhizosphere", plant_habitat),
      plant_habitat = ifelse(plant_habitat == "RE", "Root endosphere", plant_habitat)
      
    )
  
  return(tmp1)
  
}

#### Standard error ####

se <- function(x) {
  
  tmp1 <- sd(x) / sqrt(length(x))
  
  return(tmp1)
  
}

#### Drop metabolites with concentration of 0 ####

drop_0conc_metab <- function(x) {
  
  tmp1 <- x %>%
    group_by(metabolite_id) %>%
    mutate(metab_concentration = sum(concentration)) %>%
    ungroup(.) %>%
    filter(metab_concentration > 0) %>%
    select(-metab_concentration)
  
  return(tmp1)
  
}

#### Drop samples with no metabolite concentrations ####

drop_0conc_trees <- function(x) {
  
  tmp1 <- x %>%
    group_by(tree_id) %>%
    mutate(tree_concentration = sum(concentration)) %>%
    ungroup(.) %>%
    filter(tree_concentration > 0) %>%
    select(-tree_concentration)
  
  return(tmp1)
  
}

#### Function to format fsumz ####

format_fsumz <- function(x) {
  
  tmp1 <- x %>%
    
    # Format
    mutate(
      
      cutoff = ifelse(str_detect(variable, "f"), cutoff, 0),
      
      variable = ifelse(
        str_detect(variable, "sumz-"),
        "Decreasing",
        "Increasing"
      ),
      
      plant_habitat = factor(
        plant_habitat,
        levels = c("Root endosphere", "Rhizosphere", "Soil")
      ),
      
      variable = factor(
        variable,
        levels = c("Decreasing", "Increasing")
      ),
      
      community = factor(
        community,
        levels = c("Bacteria and Archaea", "Fungi")
      )
    ) %>%
    
    # Mean 0
    group_by(cutoff, community, plant_habitat, site, variable) %>%
    summarise(cp = mean(cp)) %>%
    ungroup(.) %>%
    filter(!is.na(cp)) %>%
    group_by(cutoff, community, plant_habitat, site) %>%
    mutate(n_val = n()) %>%
    ungroup(.) %>%
    filter(n_val == 2) %>%
    select(-n_val)
  
  return(tmp1)
  
}