# Load required libraries
require(plm)          # Panel data analysis
require(sandwich)     # Robust covariance matrix estimation
require(lmtest)       # Statistical testing for linear models
require(ggplot2)      # Data visualization
library(tidyverse)    # Data manipulation
library(corrr)        # Correlation matrix visualization
library(psych)        # Descriptive statistics
library(lme4)         # Linear mixed-effects models
library(performance)  # Model performance evaluation
library(jtools)       # Summary of regression models
library(lmerTest)     # Mixed-effects model with statistical tests
require(lubridate)    # Date manipulation
library(eeptools)     # Date calculations
library(ggplot2)      # Data visualization

# Set the working directory and clean the workspace
getwd()
rm(list = ls())  # Remove all objects from the environment

# Load the data
data <- read_csv("./03_data_final/complete_merge1.csv")

#-------------------------------------------------------------------------------

# Create different iterations of the dependent variable (DV) and standardize to a 0-100 scale
#-------------------------------------------------------------------------------
data <- data %>%
  # Remove invalid responses for dependent variables (coded as 8)
  filter(red_inc_diff != 8, gov_int != 8, union_pref != 8) %>%
  
  # Create a standardized DV (0-100 scale) based on `red_inc_diff`
  mutate(DV_one_to_zero = (100 * (red_inc_diff - 1)) / (7 - 1)) %>%
  
  # Combine `gov_int` and `red_inc_diff` into a new DV (average)
  mutate(DV_combined_01 = (gov_int + red_inc_diff) / 2) %>%
  
  # Combine `gov_int`, `red_inc_diff`, and `union_pref` into a new DV (average)
  mutate(DV_combined_02 = (gov_int + red_inc_diff + union_pref) / 3) %>%
  
  # Standardize `DV_combined_01` to a 0-100 scale
  mutate(DV_combined_01_one_to_zero = (100 * (DV_combined_01 - 1)) / (7 - 1)) %>%
  
  # Standardize `DV_combined_02` to a 0-100 scale
  mutate(DV_combined_02_one_to_zero = (100 * (DV_combined_02 - 1)) / (7 - 1))

#-------------------------------------------------------------------------------

# Re-code and standardize Level 1 (individual) variables
#-------------------------------------------------------------------------------

# Recode `sex` into categorical variable
data <- data %>%
  mutate(
    sex = case_when(
      sex %in% 1 ~ "Male",
      sex %in% 2 ~ "Female",
      sex %in% 3 ~ "Other"
    )
  ) %>%
  mutate(sex = factor(sex))

# Recode `age` based on the birth year and standardize
data <- data %>%
  mutate(age = 2017 - birth_year) %>%  # Calculate age (2017 is the reference year)
  mutate_at(vars(age), ~ (scale(.) %>% as.vector))  # Standardize age

# Recode and standardize `education` (years of education)
data <- data %>%
  mutate(education = educyrs) %>%
  mutate_at(vars(education), ~ (scale(.) %>% as.vector))

# Recode `employment_status` into descriptive categories
data <- data %>%
  mutate(
    employment_status = case_when(
      work_status %in% 1 ~ "Employed",
      work_status %in% 2 ~ "Student",
      work_status %in% 3 ~ "Unemployed and Actively Looking for Work",
      work_status %in% 4 ~ "Unemployed, not actively looking",
      work_status %in% 5 ~ "Permanently sick or disabled",
      work_status %in% 6 ~ "Retired",
      work_status %in% 7 ~ "Community or Military Service",
      work_status %in% 8 ~ "Housework, caregiving"
    )
  ) %>%
  mutate(employment_status = factor(employment_status))

# Recode `occupation` into descriptive categories
data <- data %>%
  mutate(
    occupation = case_when(
      work_type %in% 1 ~ "Modern professional occupations",
      work_type %in% 2 ~ "Clerical and intermediate occupations",
      work_type %in% 3 ~ "Senior managers or administrators",
      work_type %in% 4 ~ "Technical and craft occupations",
      work_type %in% 5 ~ "Semi-routine manual and service",
      work_type %in% 6 ~ "Routine manual and service",
      work_type %in% 7 ~ "Middle or junior managers",
      work_type %in% 8 ~ "Traditional professional occupations"
    )
  ) %>%
  mutate(occupation = factor(occupation))

#-------------------------------------------------------------------------------

# Standardize Level 2 (contextual) variables
#-------------------------------------------------------------------------------
data <- data %>%
  mutate_at(
    vars(
      b_perc_low40_hh, b_pop_total, b_pop_over_65, b_pop_nonwest,
      b_avg_inc_recip, b_perc_low_inc_hh, b_pop_dens, b_perc_soc_min_hh,
      w_perc_low40_hh, g_perc_low40_hh
    ),
    ~ (scale(.) %>% as.vector)
  )

#-------------------------------------------------------------------------------


# Explore distributions of variables of interest
#-------------------------------------------------------------------------------

hist(data$b_perc_low40_hh)
hist(data$DV_combined_01_one_to_zero)

hist(data$b_pop_over_65)
hist(data$b_pop_nonwest)
hist(data$b_avg_inc_recip)
hist(data$b_perc_low_inc_hh)
hist(data$b_pop_dens)
hist(data$b_perc_soc_min_hh)
hist(data$b_pop_total)

#---------------------------------------------------------------------------------------------------------
# Correlation between DV and 40_Lowest_Income_Households (all levels)

(correlations <- 
   data %>%
   select(b_perc_low40_hh, w_perc_low40_hh, 
          g_perc_low40_hh, DV_combined_01_one_to_zero) %>%
   correlate())
rplot(correlations)



#Significance test for correlations
cor.test(data$b_perc_low40_hh, data$DV_combined_01_one_to_zero, method=c("pearson", "kendall", "spearman"))
cor.test(data$w_perc_low40_hh, data$DV_combined_01_one_to_zero, method=c("pearson", "kendall", "spearman"))
cor.test(data$g_perc_low40_hh, data$DV_combined_01_one_to_zero, method=c("pearson", "kendall", "spearman"))


#------------------------------------------------------------------------------
#                           SET THE SAMPLE
#-----------------------------------------------------------------------------
data_two_levels <-
  data %>%
  select(DV_one_to_zero, age, sex, education, employment_status, occupation,
         born_in_nl, father_dutch, mother_dutch,
         b_perc_low40_hh, b_pop_total,
         b_pop_over_65, b_pop_nonwest, 
         b_avg_inc_recip, b_perc_low_inc_hh,
         b_pop_dens, b_perc_soc_min_hh,
         buurt_id) %>%
  na.omit() #WHY ARE SO MANY BEING DROPED EVEN WHEN YOU TAKE RELIGION AND OCCUPATION OUT

#------------------------------------------------------------------------------
#                           Multi-Level Model Buurt
#-----------------------------------------------------------------------------
# empty multilevel model (No fixed factors (intercept only))
m0_buurt <- lmer(DV_one_to_zero ~ 1 +
                   (1 |buurt_id), 
                 data = data_two_levels)


summary(m0_buurt)
summ(m0_buurt)


#------------------------------------------------------------------------------
#Include dependent variable
m1_buurt <- lmer(DV_one_to_zero ~ b_perc_low40_hh
                 +(1 |buurt_id),
                 data = data_two_levels)

summary(m1_buurt)
summ(m1_buurt)
anova(m0_buurt ,m1_buurt) 
#------------------------------------------------------------------------------
#Add level one variables 
m2_buurt <- lmer(DV_one_to_zero ~ b_perc_low40_hh
                 +age
                 +sex
                 +education
                 +employment_status
                 +occupation
                 +born_in_nl
                 +(1 | buurt_id),
                 data = data_two_levels)
summary(m2_buurt)
summ(m2_buurt)
anova(m2_buurt ,m1_buurt)

#------------------------------------------------------------------------------
#Add level two variables 
m3_buurt <- lmer(DV_one_to_zero ~ b_perc_low40_hh
                 +age
                 +sex
                 +education
                 +employment_status
                 +occupation
                 +b_pop_dens
                 +b_pop_over_65
                 +b_pop_nonwest
                 +b_perc_low_inc_hh
                 +b_perc_soc_min_hh
                 +(1 |buurt_id), 
                 data = data_two_levels)

summary(m3_buurt)
summ(m3_buurt)
anova(m3_buurt, m2_buurt) 
#------------------------------------------------------------------------------
#                           Four Level Model
#-----------------------------------------------------------------------------
# empty multilevel model (No fixed factors (intercept only))

m0_four_level <- lmer(DV_one_to_zero ~ 1 
                      +(1 |gemeente_id)
                      +(1 |wijk_id)
                      +(1 |buurt_id), 
                      data = data)


summary(m0_four_level)
summ(m0_four_level)
#------------------------------------------------------------------------------
#Insert Explanatory Variable(s)

m1_four_level <- lmer(DV_one_to_zero ~ b_perc_low40_hh
                      +w_perc_low40_hh
                      +g_perc_low40_hh
                      +(1 |gemeente_id)
                      +(1 |wijk_id)
                      +(1 |buurt_id), 
                      data = data)

summary(m1_four_level)
summ(m1_four_level)
#-------------------------------------------------------------------------------
#Add level one variables
m2_four_level <- lmer(DV_one_to_zero ~ b_perc_low40_hh
                      +w_perc_low40_hh
                      +g_perc_low40_hh
                      +age
                      +sex
                      +education
                      +employment_status
                      +occupation
                      +(1 |gemeente_id)
                      +(1 |wijk_id)
                      +(1 |buurt_id), 
                      data = data)

summary(m2_four_level)
summ(m2_four_level)
#-------------------------------------------------------------------------------
#Add level two variables (what level?, buurt level for now)
m3_four_level <- lmer(DV_one_to_zero ~ b_perc_low40_hh
                      +w_perc_low40_hh
                      +g_perc_low40_hh
                      +age
                      +sex
                      +education
                      +employment_status
                      +occupation
                      +b_pop_dens
                      +b_pop_over_65
                      +b_pop_nonwest
                      +b_perc_low_inc_hh
                      +b_perc_soc_min_hh
                      +(1 |gemeente_id)
                      +(1 |wijk_id)
                      +(1 |buurt_id), 
                      data = data)
summary(m3_four_level)
summ(m3_four_level)
#-------------------------------------------------------------------------------
#Adding two levels of indicators -- is this appropriate?

m4_four_level <- lmer(DV_one_to_zero ~ b_perc_low40_hh
                      +w_perc_low40_hh
                      +g_perc_low40_hh
                      +age
                      +sex
                      +education
                      +employment_status
                      +occupation
                      +b_pop_dens
                      +b_pop_over_65
                      +b_pop_nonwest
                      +b_perc_low_inc_hh
                      +b_perc_soc_min_hh
                      +w_pop_dens
                      +w_pop_over_65
                      +w_pop_nonwest
                      +w_perc_low_inc_hh
                      +w_perc_soc_min_hh
                      +(1 |gemeente_id)
                      +(1 |wijk_id)
                      +(1 |buurt_id), 
                      data = data)


summary(m4_four_level)
summ(m4_four_level)
