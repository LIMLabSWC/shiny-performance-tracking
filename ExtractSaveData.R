# ExtractSaveData.R
# Main batch processor for the Shiny Performance Tracking system
# This script orchestrates the data pipeline from raw .mat files to TRAINING.csv
# See docs/architecture.md for detailed system design

# Suppress package startup messages for cleaner logging
suppressPackageStartupMessages({
  library(tidyverse)    # includes dplyr, ggplot2, purrr, etc.
  library(plotly)
  library(R.matlab)
  library(zoo)
  library(chron)
  library(gridExtra)
  library(shinyjs)
  library(DT)
  library(kableExtra)
})

# Print initial status
cat(sprintf("\n[%s] Starting data extraction\n", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))
cat(sprintf("Input path: %s\n", path_to_mat_files))
cat(sprintf("Output path: %s\n", path_to_rds_files))

# ============================================================================
# 1. Configuration and Setup
# ============================================================================
# Define paths and initialize variables for the data processing pipeline

# Input path for raw .mat files from behavioral rigs
in_path <- path_to_mat_files

# ============================================================================
# 2. File Discovery and Filtering
# ============================================================================
# Scan for new .mat files and filter out test/experimenter data

# List all .mat files in the data folder
file_list <- list.files(in_path, pattern = "\\.mat$", recursive = TRUE)

# Filter out experimenter data, session settings, and fake subjects
file_list <- file_list[!grepl(
  "experimenter|Session Settings|FakeSubject",
  file_list
)]

# ============================================================================
# 3. Conversion Status Check
# ============================================================================
# Identify which files need to be converted from .mat to .rds format

# List files already converted to rds
rds_list <- list.files(path_to_rds_files)

# Identify not yet converted mat files by comparing base file names
not_yet_conv <- setdiff(
  basename(file_list),
  basename(rds_list) %>% str_remove(pattern = "\\.rds$")
)

# Add full paths to the not yet converted mat files
to_be_conv <- if (length(not_yet_conv) > 0) {
  file.path(in_path, file_list[str_detect(
    file_list,
    paste(not_yet_conv, collapse = "|")
  )])
} else {
  character()
}

# ============================================================================
# 4. Parallel Conversion Process
# ============================================================================
# Convert new .mat files to .rds format using parallel processing

if (length(to_be_conv) > 0) {
  # Set up parallel backend using available cores minus one
  cl <- makeCluster(detectCores() - 1)

  # Convert files in parallel using ConvertToRDS function
  parLapply(cl, to_be_conv, ConvertToRDS)

  # Clean up parallel cluster
  stopCluster(cl)
} else {
  warning("No new files to convert")
}

# ============================================================================
# 5. Data Aggregation
# ============================================================================
# Process .rds files and append to TRAINING.csv

# Get updated list of rds files
rds_list <- list.files(path_to_rds_files)

# Identify which rds files need to be appended to TRAINING.csv
to_append <- setdiff(
  rds_list,
  suppressMessages(suppressWarnings(
    if (file.exists(file.path("shiny_app", "TRAINING.csv"))) {
      read_csv(file.path("shiny_app", "TRAINING.csv")) %>%
        dplyr::select(file) %>%
        pull()
    } else {
      character()
    }
  ))
)

# Process each new file and append to TRAINING.csv
walk(to_append, ~ ReadData(rds_file = .x) %>% TRAININGtoCSV())

# ============================================================================
# 6. Optional: Trial-by-Trial Data Processing
# ============================================================================
# Uncomment to enable trial-level data extraction
# walk(rds_list, ~ ReadData(rds_file = .x, trialData = TRUE) %>%
#        TRAININGtoCSV(filename = "TrialByTrial.csv"))

# Example of processing a specific file for trial data
# ReadData(
#   rds_file = "LT01_Gap_Detection_20191011_093950.mat.rds",
#   trialData = TRUE) %>%
#   TRAININGtoCSV(filename = "TrialByTrial.csv")

