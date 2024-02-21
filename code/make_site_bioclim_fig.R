#!/usr/bin/env Rscript --vanilla

# name : make_site_mat_fig.R
# author: William Argiroff
# inputs : tibble with .rds with BioClim variables for each site
# output : pdf of figure
# notes : expects order of inputs (tibble), output fig

clargs <- commandArgs(trailingOnly = TRUE)

library(tidyverse)
library(cowplot)
library(viridis)

# clargs <- c(
#   "data/bioclim/site_bioclim.txt",
#   "figures/site_mat.pdf"
# )

# Format input data
in_data <- read_tsv(clargs[1]) %>%
  
  mutate(
    
    transect = factor(
      transect,
      levels = c("CR", "TR", "MR", "WC")
    ),
    
    state = factor(
      state,
      levels = c("WA", "OR")
    )
    
  ) %>%
  
  filter(site != "Reserve")

# Plot MAT
mat_fig <- ggplot() +
  
  scale_y_continuous(
    limits = c(0, NA),
    expand = expansion(mult = c(0, 0.05))
  ) +
  
  geom_bar(
    data = in_data,
    aes(
      x = site,
      y = bio1,
      fill = transect
    ),
    colour = "black",
    stat = "identity",
    position = position_dodge(width = 0.9)
  ) +
  
  scale_fill_viridis(
    discrete = TRUE,
    name = NULL
  ) +
  
  labs(
    title = "Mean annual temperature",
    y = bquote("Air temperature ("*degree*C*")"),
    x = "Site"
  ) +
  
  facet_wrap(
    ~ state,
    scales = "free_x"
  ) +
  
  theme(
    panel.border = element_rect(colour = "black", fill = NA, linewidth = 0.5), 
    panel.background = element_blank(),
    panel.grid = element_blank(),
    strip.background = element_blank(),
    plot.title = element_text(colour = "black", size = 12, hjust = 0.5),
    axis.title = element_text(colour = "black", size = 10),
    axis.ticks = element_line(colour = "black", linewidth = 0.25),
    axis.text.x = element_text(colour = "black", size = 8),
    axis.text.y = element_text(colour = "black", size = 8),
    strip.text = element_text(colour = "black", size = 10),
    legend.key = element_blank(),
    legend.title = element_text(colour = "black", size = 10),
    legend.text = element_text(colour = "black", size = 8)
  )

# Plot average max temperature of warmest month
maxt_fig <- ggplot() +
  
  scale_y_continuous(
    limits = c(0, NA),
    expand = expansion(mult = c(0, 0.05))
  ) +
  
  geom_bar(
    data = in_data,
    aes(
      x = site,
      y = bio5,
      fill = transect
    ),
    colour = "black",
    stat = "identity",
    position = position_dodge(width = 0.9)
  ) +
  
  scale_fill_viridis(
    discrete = TRUE,
    name = NULL
  ) +
  
  labs(
    title = "Max temperature of warmest month",
    y = bquote("Air temperature ("*degree*C*")"),
    x = "Site"
  ) +
  
  facet_wrap(
    ~ state,
    scales = "free_x"
  ) +
  
  theme(
    panel.border = element_rect(colour = "black", fill = NA, linewidth = 0.5), 
    panel.background = element_blank(),
    panel.grid = element_blank(),
    strip.background = element_blank(),
    plot.title = element_text(colour = "black", size = 12, hjust = 0.5),
    axis.title = element_text(colour = "black", size = 10),
    axis.ticks = element_line(colour = "black", linewidth = 0.25),
    axis.text.x = element_text(colour = "black", size = 8),
    axis.text.y = element_text(colour = "black", size = 8),
    strip.text = element_text(colour = "black", size = 10),
    legend.key = element_blank(),
    legend.title = element_text(colour = "black", size = 10),
    legend.text = element_text(colour = "black", size = 8)
  )

# Plot annual water balance
wb_fig <- ggplot() +
  
  geom_bar(
    data = in_data,
    aes(
      x = site,
      y = ann_water,
      fill = transect
    ),
    colour = "black",
    stat = "identity",
    position = position_dodge(width = 0.9)
  ) +
  
  geom_errorbar(
    data = in_data,
    aes(
      x = site,
      ymin = ann_water - stdev_water,
      ymax = ann_water + stdev_water
    ),
    colour = "black",
    position = position_dodge(width = 0.9),
    width = 0
  ) +
  
  scale_fill_viridis(
    discrete = TRUE,
    name = NULL
  ) +
  
  labs(
    title = "Annual water balance",
    y = bquote(mm%.%y^-1),
    x = "Site"
  ) +
  
  facet_wrap(
    ~ state,
    scales = "free_x"
  ) +
  
  theme(
    panel.border = element_rect(colour = "black", fill = NA, linewidth = 0.5), 
    panel.background = element_blank(),
    panel.grid = element_blank(),
    strip.background = element_blank(),
    plot.title = element_text(colour = "black", size = 12, hjust = 0.5),
    axis.title = element_text(colour = "black", size = 10),
    axis.ticks = element_line(colour = "black", linewidth = 0.25),
    axis.text.x = element_text(colour = "black", size = 8),
    axis.text.y = element_text(colour = "black", size = 8),
    strip.text = element_text(colour = "black", size = 10),
    legend.key = element_blank(),
    legend.title = element_text(colour = "black", size = 10),
    legend.text = element_text(colour = "black", size = 8)
  )

# Get shared legend
out_legend <- get_legend(
  
  mat_fig + 
    theme(legend.position = "right")
  
)

# Arrange figures in grid
out_grid <- plot_grid(
  mat_fig + theme(legend.position = "none"), 
  maxt_fig + theme(legend.position = "none"),
  wb_fig + theme(legend.position = "none"),
  align = 'vh', 
  nrow = 3, 
  ncol = 1
)

# Construct figure
out_fig <- plot_grid(
  out_grid,
  out_legend,
  ncol = 2,
  rel_widths = c(1, 0.1)
)

# Save
ggsave2(
  filename = clargs[2],
  plot = out_fig,
  device = "pdf",
  width = 10,
  height = 8.5,
  units = "in"
)

file.remove("Rplots.pdf")
