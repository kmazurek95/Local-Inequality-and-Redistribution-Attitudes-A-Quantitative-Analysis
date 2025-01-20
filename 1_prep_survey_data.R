# Load required libraries
library(haven)         # For importing Stata files
library(dplyr)         # For data manipulation
library(tidyverse)     # For general-purpose operations

# Source the utility functions for code standardization
source("scripts/utils/code_standardization.R")

# Set working directory (if needed)
# setwd("path/to/project")

# Step 1: Load the raw score data
score <- read_dta("data/raw/score.dta")

# Step 2: Correct Buurtcodes
# Standardize Buurtcode and generate Wijk and Gemeente codes
score_standardized <- standardize_codes(score, code_column = "Buurtcode")

# Step 3: Select relevant variables (if required)
keeps <- c(
  "a27_1", "a27_2", "a27_3", "b01", "b02", "b03", "b04", "b05", "b06", 
  "b07", "b08", "b09", "b10", "b11", "b12_1", "b13", "b14_1", "b14_2", 
  "b14_3", "b14_4", "b14_5", "b15", "b16", "b17", "b18", "b19", "b20", 
  "b21", "b22", "GENDERID", "weegfac", "Buurtcode", "buurt_code_eight_digits", 
  "wijk_code_six_digits", "gemeente_code_four_digits", "respnr"
)

score_filtered <- score_standardized %>% select(all_of(keeps))

# Step 4: Save the prepared dataset
save(score_filtered, file = "data/processed/score_prepped.RData")
write.csv(score_filtered, "data/processed/score_prepped.csv", row.names = FALSE)

# Note: Stata export can be enabled if required
# library(foreign)
# write.dta(score_filtered, "data/processed/score_prepped.dta")
