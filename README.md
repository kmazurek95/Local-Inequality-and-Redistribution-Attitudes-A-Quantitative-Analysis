Here's the integrated and updated README file:

---

# Local Inequality and Redistribution Attitudes: A Quantitative Analysis

This repository hosts the research project examining how local income inequality influences individual attitudes toward redistribution. The study is based on survey data and regional indicators from the Netherlands, aiming to uncover the nuances of inequality perception and redistribution preferences.

---

## Research Overview

### Objective
To explore whether people are more concerned about income inequality when it is framed locally, particularly in neighborhoods with high levels of economic diversity.

### Key Research Questions
1. Are people's attitudes toward income inequality shaped more by local income inequality than broader regional or national disparities?
2. How do socio-economic contexts, such as neighborhood diversity, influence redistribution preferences?
3. Does socio-economic class moderate the relationship between local inequality and redistribution attitudes?

### Hypotheses
- **H1:** Neighborhood-level inequality explains differences in redistribution support more significantly than city or regional inequality.
- **H2:** Higher neighborhood inequality leads to stronger redistribution preferences.
- **H3:** Upper-class individuals are less likely to support redistribution in response to local inequality.

---

## Data Sources
- **Survey Data:** Derived from the *"Sub-national Context and Radical Right Support in Europe"* project, focusing on the Netherlands.
- **Regional Indicators:** Provided by Statistics Netherlands (CBS), including data at neighborhood, district, and municipal levels.

---

## Methodology

### Analytical Approach
This project employs multi-level modeling to examine relationships across three nested geographic levels: neighborhoods, districts, and municipalities. It integrates contextual socio-economic indicators with individual survey responses.

### Key Variables
- **Dependent Variable:** Attitudes toward redistribution (measured on a 7-point Likert scale).
- **Independent Variable:** Neighborhood-level income inequality.
- **Control Variables:** Population density, demographic distribution, poverty levels, and individual factors such as age, education, and class.

### Tools and Libraries
- **Data Preparation:** `dplyr`, `tidyverse`
- **Modeling:** `lme4`, `plm`
- **Visualization:** `ggplot2`

---

## Repository Structure

```
├── data/
│   ├── raw/                  # Raw survey and regional indicator data
│   ├── processed/            # Cleaned and prepped datasets
│   ├── final/                # Merged datasets ready for analysis
├── scripts/
│   ├── 1_prep_survey_data.R  # Prepares and cleans the survey data, standardizes neighborhood codes, and filters relevant variables.
│   ├── 2_prep_indicator_data.R # Processes regional socio-economic indicators, splits data by level, and renames variables.
│   ├── 3_merge_data.R        # Merges cleaned survey and indicator data into a final dataset.
│   ├── 4_analysis.R          # Performs multi-level modeling, explores variable distributions, and generates visualizations.
├── outputs/
│   ├── figures/              # Visualizations such as histograms and regression result plots.
│   ├── tables/               # Summary tables and statistical outputs.
├── README.md                 # Project overview and documentation.
```

---

## Results
This project analyzes the interplay between local inequality and redistribution attitudes, presenting key findings through regression models and visualizations. See the `outputs/` directory for detailed results and insights.

---

For questions, please contact **Kaleb Mazurek** at kalebmazurek@gmail.com
