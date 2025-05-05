# Usage Guide

This guide walks you through how to process new data files and run the Shiny dashboard.

---

## 🧪 Step 1: Convert `.mat` Files to `.rds` and Append to `TRAINING.csv`

1. Place new `.mat` files in the data directory configured via `path_to_mat_files`.
2. Run the main script:

```r
source("ExtractSaveData.R")
````

This will:

* Identify new (unprocessed) `.mat` files
* Convert them to `.rds` using `ConvertToRDS.R`
* Extract metadata with `ReadBcontrolData.R` or `ReadBpodData.R`
* Append results to `shiny_app/TRAINING.csv`

> ✅ Already-processed files are skipped automatically.

---

## 📊 Step 2: Launch the Shiny Dashboard

From within R or RStudio:

```r
setwd("shiny_app")
shiny::runApp()
```

The app loads `TRAINING.csv`, applies cleaning and reshaping (via `load_data.R`), and generates interactive plots.

---

## 🧪 Optional: Trial-by-Trial Data Export

Uncomment this block in `ExtractSaveData.R` to enable trial-level exports:

```r
# walk(rds_list, ~ ReadData(rds_file = .x, trialData = TRUE) %>%
#        TRAININGtoCSV(filename = "TrialByTrial.csv"))
```

---

## 🧼 Notes

* The pipeline uses **parallel processing** to speed up file conversion.
* `shiny_app/full_TRAINING.csv` can be used to accumulate data across sessions or datasets.
* Only sessions not already listed in the CSV will be added.
* You can rerun `ExtractSaveData.R` safely without duplicating entries.

---

## 🔧 Troubleshooting

* If the Shiny app fails to launch, check for formatting issues in `TRAINING.csv` (e.g., broken rows).
* Ensure that all required packages are installed: `tidyverse`, `R.matlab`, `shiny`, `ggpubr`, `ggrepel`, `parallel`.
