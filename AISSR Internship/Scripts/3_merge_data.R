# scripts/merge_data.R

# Load required packages
library(tidyverse)

# Load prepped datasets
survey <- read_csv("data/processed/survey_prepped.csv")
ind_bu <- read_csv("data/processed/indicators_buurt.csv")
ind_wi <- read_csv("data/processed/indicators_wijk.csv")
ind_ge <- read_csv("data/processed/indicators_gemeente.csv")

# Merge datasets step by step
merge_temp1 <- merge(survey, ind_bu, by = "buurt_id", all.x = TRUE) # Merge Buurt data
merge_temp2 <- merge(merge_temp1, ind_wi, by = "wijk_id", all.x = TRUE) # Merge Wijk data
complete_merge <- merge(merge_temp2, ind_ge, by = "gemeente_id", all.x = TRUE) # Merge Gemeente data

# Save the final merged dataset
write_csv(complete_merge, "data/final/complete_merged_data.csv")
