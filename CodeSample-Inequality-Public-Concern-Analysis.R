###########################################################################
# Project: How Local Income Inequality Shapes Public Concern
# Author: Kaleb Mazurek
# Date: February 5th, 2025
# Origin: Innternship at the UvA's Amsterdam Institute for Social Science Research
#
# Description:
# This script demonstrates data preparation, merging of survey data with
# administrative indicators, and multi-level regression modeling. The goal
# is to investigate whether neighborhood-level income inequality is related
# to individuals’ attitudes toward income redistribution.
#
# This sample is part of a larger project that integrates quantitative
# methods with economic and sociological theory to better understand inequality.
###########################################################################

#-------------------------------
# 1. Load Required Packages
#-------------------------------
library(haven)         # For reading Stata files
library(tidyverse)     # For data manipulation and visualization
library(lubridate)     # For date handling
library(lme4)          # For multi-level models
library(jtools)        # For model summaries
library(corrr)         # For correlation analysis

#-------------------------------
# 2. Data Preparation: Survey Data
#-------------------------------

# Load the survey data (SCORE dataset) from a Stata file
score <- read_dta("./02_data_orig/score.dta") %>% as.data.frame()

# Add leading zeros to the neighborhood code ("Buurtcode") to prepare for merging.
score <- score %>%
  mutate(buurt_id = case_when(
    Buurtcode > 9999  & Buurtcode < 100000   ~ paste0("000", Buurtcode),
    Buurtcode > 99999 & Buurtcode < 1000000  ~ paste0("00", Buurtcode),
    Buurtcode > 999999 & Buurtcode < 10000000 ~ paste0("0", Buurtcode),
    Buurtcode > 9999999                      ~ as.character(Buurtcode)
  )) %>%
  mutate(
    wijk_id = substr(buurt_id, 1, 6),
    gemeente_id = substr(buurt_id, 1, 4)
  )

# Subset and rename variables for clarity
score_final <- score %>%
  select(a27_1, a27_2, a27_3, b01, b02, b03, b04, b05, b06, b07, b08, b09, b10,
         b11, b12_1, b13, b14_1, b14_2, b14_3, b14_4, b14_5, b15, b16, b17, b18,
         b20, b21, b22, weegfac, Buurtcode, buurt_id,
         wijk_id, gemeente_id, respnr) %>%
  rename(
    gov_int         = a27_1,   # Government intervention (1=fully disagree, 7=fully agree)
    red_inc_diff    = a27_2,   # Attitude toward income redistribution
    union_pref      = a27_3,   # Union preference
    sex             = b01,
    birth_year      = b02,
    educlvl         = b03,
    educyrs         = b04,
    voted           = b05,
    vote_choice     = b06,
    work_status     = b07,
    has_worked      = b08,
    work_type       = b09,
    org_type        = b10,
    leader_resp     = b11,
    leader_resp_n   = b12_1,
    job_desc        = b13,
    home_owner      = b14_1,
    other_real_estate = b14_2,
    savings         = b14_3,
    stocks          = b14_4,
    no_owner        = b14_5,
    relig_yn        = b15,
    religiosity     = b16,
    relig_attend    = b17,
    born_in_nl      = b18,
    father_dutch    = b20,
    mother_dutch    = b21,
    weight          = b22,
    geocode         = weegfac,
    respondent_id   = respnr
  )

#-------------------------------
# 3. Data Preparation: Administrative Data
#-------------------------------

# Load the administrative dataset containing neighborhood (buurt), district (wijk),
# and municipality (gemeente) indicators.
ind_bwg <- read_csv("./02_data_orig/indicators_buurt_wijk_gemeente.csv",
                    na = ".") %>%
  select(-c(Codering_3,
            IndelingswijzigingWijkenEnBuurten_4,
            Marokko_19,
            Turkije_22)) %>%
  rename(
    id           = 1,
    code         = 2,
    municipality = 3,
    region_type  = 4,
    pop_total    = 5,
    pop_over_65  = 6,
    pop_west     = 7,
    pop_nonwest  = 8,
    pop_dens     = 9,
    avg_home_value = 10,
    avg_inc_recip  = 11,
    avg_inc_pers   = 12,
    perc_low40_pers = 13,
    perc_high20_pers = 14,
    perc_low40_hh   = 15,
    perc_high20_hh  = 16,
    perc_low_inc_hh = 17,
    perc_soc_min_hh = 18
  )

# Split the data by region type and rename columns to include level prefixes
ind_bu <- ind_bwg %>% filter(region_type == "Buurt") %>% 
  rename_with(~ paste0("b_", .))
ind_wi <- ind_bwg %>% filter(region_type == "Wijk") %>% 
  rename_with(~ paste0("w_", .))
ind_ge <- ind_bwg %>% filter(region_type == "Gemeente") %>% 
  rename_with(~ paste0("g_", .))

# Remove the two-letter prefixes in the codes to match the survey data
ind_bu <- ind_bu %>% mutate(buurt_id = substr(b_code, 3, 10))
ind_wi <- ind_wi %>% mutate(wijk_id = substr(w_code, 3, 8))
ind_ge <- ind_ge %>% mutate(gemeente_id = substr(g_code, 3, 6))

#-------------------------------
# 4. Merge Survey and Administrative Data
#-------------------------------

# Sequentially merge neighborhood, district, and municipality data
merge_temp1 <- merge(score_final, ind_bu, by = "buurt_id", all.x = TRUE)
merge_temp2 <- merge(merge_temp1, ind_wi, by = "wijk_id", all.x = TRUE)
complete_merge <- merge(merge_temp2, ind_ge, by = "gemeente_id", all.x = TRUE)

# Save the merged data for subsequent analysis
write.csv(complete_merge, "./03_data_final/complete_merge1.csv", row.names = FALSE)

#-------------------------------
# 5. Data Transformation & Variable Recoding
#-------------------------------

# Reload merged data and filter out problematic cases
data <- read_csv("./03_data_final/complete_merge1.csv") %>%
  filter(red_inc_diff != 8, gov_int != 8, union_pref != 8) %>%
  # Create a dependent variable scaled from 0 to 100 based on income redistribution attitudes
  mutate(DV_one_to_zero = 100 * (red_inc_diff - 1) / (7 - 1)) %>%
  # Recode sex as a factor with descriptive labels
  mutate(sex = factor(case_when(
    sex == 1 ~ "Male",
    sex == 2 ~ "Female",
    sex == 3 ~ "Other"
  ))) %>%
  # Create and standardize age (assuming survey conducted in 2017)
  mutate(age = scale(2017 - birth_year)) %>%
  # Standardize education years
  mutate(education = scale(educyrs))

# Standardize selected neighborhood-level administrative variables
data <- data %>%
  mutate_at(vars(b_perc_low40_hh, b_pop_total, b_pop_over_65, 
                 b_pop_nonwest, b_avg_inc_recip, 
                 b_perc_low_inc_hh, b_pop_dens, b_perc_soc_min_hh),
            ~ as.vector(scale(.)))

#-------------------------------
# 6. Multi-Level Regression Analysis
#-------------------------------

# For demonstration, select a subset of variables and remove any missing data.
data_two_levels <- data %>%
  select(DV_one_to_zero, age, sex, education,
         b_perc_low40_hh, b_pop_total, b_pop_over_65, b_pop_nonwest,
         b_avg_inc_recip, b_perc_low_inc_hh, b_pop_dens, b_perc_soc_min_hh,
         buurt_id) %>%
  na.omit()

# -- Model 0: Empty Model (Intercept Only) --
m0_buurt <- lmer(DV_one_to_zero ~ 1 + (1 | buurt_id), data = data_two_levels)
summary(m0_buurt)
summ(m0_buurt)

# -- Model 1: Add Key Neighborhood Variable --
m1_buurt <- lmer(DV_one_to_zero ~ b_perc_low40_hh + (1 | buurt_id),
                 data = data_two_levels)
summary(m1_buurt)
summ(m1_buurt)
anova(m0_buurt, m1_buurt)

# -- Model 2: Add Individual-Level Controls --
m2_buurt <- lmer(DV_one_to_zero ~ b_perc_low40_hh + age + sex + education +
                   (1 | buurt_id),
                 data = data_two_levels)
summary(m2_buurt)
summ(m2_buurt)
anova(m1_buurt, m2_buurt)

# -- Model 3: Add Additional Neighborhood-Level Controls --
m3_buurt <- lmer(DV_one_to_zero ~ b_perc_low40_hh + age + sex + education +
                   b_pop_dens + b_pop_over_65 + b_pop_nonwest +
                   b_perc_low_inc_hh + b_perc_soc_min_hh +
                   (1 | buurt_id), 
                 data = data_two_levels)
summary(m3_buurt)
summ(m3_buurt)
anova(m2_buurt, m3_buurt)

# End of Script
