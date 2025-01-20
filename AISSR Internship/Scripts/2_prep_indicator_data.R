# scripts/prep_indicator_data.R

# Load required packages
library(tidyverse)

# Load indicator data
indicators <- read_csv("data/raw/indicators_buurt_wijk_gemeente.csv", na = ".")

# Remove unnecessary columns
indicators <- indicators %>%
  select(-Codering_3, -IndelingswijzigingWijkenEnBuurten_4, -Marokko_19, -Turkije_22)

# Rename columns for clarity
colnames(indicators) <- c(
  "id", "code", "municipality", "region_type", "pop_total", "pop_over_65",
  "pop_west", "pop_nonwest", "pop_dens", "avg_home_value", "avg_inc_recip",
  "avg_inc_pers", "perc_low40_pers", "perc_high20_pers", "perc_low40_hh",
  "perc_high20_hh", "perc_low_inc_hh", "perc_soc_min_hh"
)

# Split data into Buurt, Wijk, and Gemeente levels
ind_bu <- indicators %>% filter(region_type == "Buurt") %>%
  mutate(buurt_id = substr(code, 3, 10)) # Remove "BU" prefix from code

ind_wi <- indicators %>% filter(region_type == "Wijk") %>%
  mutate(wijk_id = substr(code, 3, 8)) # Remove "WK" prefix from code

ind_ge <- indicators %>% filter(region_type == "Gemeente") %>%
  mutate(gemeente_id = substr(code, 3, 6)) # Remove "GM" prefix from code

# Save prepped indicator data
write_csv(ind_bu, "data/processed/indicators_buurt.csv")
write_csv(ind_wi, "data/processed/indicators_wijk.csv")
write_csv(ind_ge, "data/processed/indicators_gemeente.csv")
