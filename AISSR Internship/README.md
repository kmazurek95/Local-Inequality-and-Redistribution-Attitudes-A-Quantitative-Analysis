# **Geographic Code Standardization and Data Preparation**

## **Overview**
This project is designed to process and standardize geographic and survey data for analysis. The workflow includes cleaning and standardizing geographic codes (Buurt, Wijk, Gemeente), merging datasets, and preparing the final data for exploratory or statistical analysis.

The project is modular, with utility functions, scripts for processing different data sources, and a pipeline for merging data into a unified format.

---

## **Project Structure**
```
project/
├── data/                     
│   ├── raw/                  # Raw datasets (e.g., score.dta, indicators.csv)
│   ├── processed/            # Processed datasets (e.g., score_prepped.csv)
├── scripts/                  
│   ├── 1_process_score.R     # Script for processing raw score dataset
│   ├── 2_process_indicators.R# Script for processing geographic indicators
│   ├── 3_merge_data.R        # Script for merging score and indicator datasets
│   ├── utils/                
│       └── code_standardization.R  # Utility functions for geographic code standardization
├── outputs/                  
│   ├── datasets/             # Final merged datasets
│   ├── reports/              # Model results, visualizations, etc.
└── README.md                 # Project overview and instructions
```

---

## **Scripts**

### **1. `1_process_score.R`**
- **Purpose**: Processes the raw `score` dataset.
- **Key Tasks**:
  - Standardizes `Buurtcodes` to 8 digits by adding leading zeros.
  - Extracts `Wijkcodes` (6 digits) and `Gemeentecodes` (4 digits) from `Buurtcodes`.
  - Filters relevant variables.
  - Saves the cleaned data in `.RData` and `.csv` formats.

---

### **2. `2_process_indicators.R`**
- **Purpose**: Processes geographic indicator data for `Buurt`, `Wijk`, and `Gemeente`.
- **Key Tasks**:
  - Translates variable names into English.
  - Standardizes geographic codes using utility functions.
  - Subsets data into `Buurt`, `Wijk`, and `Gemeente` levels.
  - Saves the processed datasets in `.RData` and `.csv` formats.

---

### **3. `3_merge_data.R`**
- **Purpose**: Merges the cleaned `score` dataset with geographic indicators.
- **Key Tasks**:
  - Merges `score` data with `Buurt`, `Wijk`, and `Gemeente` indicators.
  - Combines all levels into a comprehensive dataset.
  - Saves the merged datasets for further analysis.

---

### **4. `utils/code_standardization.R`**
- **Purpose**: Centralized utility functions for geographic code standardization.
- **Key Functions**:
  - `standardize_buurtcode`: Ensures `Buurtcodes` are 8 digits by adding leading zeros.
  - `extract_wijkcode`: Extracts the first 6 digits of a standardized `Buurtcode` as `Wijkcode`.
  - `extract_gemeentecode`: Extracts the first 4 digits of a standardized `Buurtcode` as `Gemeentecode`.
  - `standardize_codes`: Applies these transformations to a data frame.

---

## **Data Workflow**

1. **Raw Data**:
   - Raw datasets (e.g., `score.dta`, `indicators_beert_wijk_gemeente.csv`) are placed in the `data/raw/` folder.

2. **Processing**:
   - `1_process_score.R` processes the `score` data, ensuring geographic codes are standardized and relevant variables are retained.
   - `2_process_indicators.R` processes geographic indicator data, translating variables and standardizing codes.

3. **Merging**:
   - `3_merge_data.R` combines the cleaned `score` data with the processed indicators to create datasets for analysis.

4. **Output**:
   - The final merged datasets are saved in the `outputs/datasets/` folder.

---

## **How to Run the Project**

### **Prerequisites**
- R version 4.0 or later.
- R packages: `dplyr`, `tidyverse`, `haven`, `readr`, `car`, `questionr`.

### **Steps**
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/your-repository.git
   cd your-repository
   ```

2. Install required R packages:
   ```R
   install.packages(c("dplyr", "tidyverse", "haven", "readr", "car", "questionr"))
   ```

3. Execute the scripts in order:
   - Process the `score` data:
     ```R
     source("scripts/1_process_score.R")
     ```
   - Process the geographic indicators:
     ```R
     source("scripts/2_process_indicators.R")
     ```
   - Merge the datasets:
     ```R
     source("scripts/3_merge_data.R")
     ```

4. Review the outputs in the `outputs/` folder.

---

## **Next Steps**
- Perform exploratory data analysis (EDA) on the merged dataset.
- Develop statistical models using the prepared data.
- Generate visualizations or reports for insights.

---

## **License**
This project is licensed under the MIT License. See `LICENSE` for more information.

---

## **Acknowledgments**
- Data sources: Statistics Netherlands (CBS) & SCORE
- Contributors: [Your name or collaborators].

