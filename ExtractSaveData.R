# ExtractSaveData.R
# Main batch processor for the Shiny Performance Tracking system
# This script orchestrates the data pipeline from raw .mat files to TRAINING.csv
# See docs/architecture.md for detailed system design

# Suppress all package startup messages
options(warn = -1)  # Suppress warnings
options(message = FALSE)  # Suppress messages

# Load required packages silently
suppressPackageStartupMessages({
  library(tidyverse, quietly = TRUE)    # includes dplyr, ggplot2, purrr, etc.
  library(plotly, quietly = TRUE)
  library(R.matlab, quietly = TRUE)
  library(zoo, quietly = TRUE)
  library(chron, quietly = TRUE)
  library(gridExtra, quietly = TRUE)
  library(shinyjs, quietly = TRUE)
  library(DT, quietly = TRUE)
  library(kableExtra, quietly = TRUE)
})

# Restore warning level
options(warn = 0)

# Print initial status
cat(sprintf(
  "\n[%s] Starting data extraction\n", 
  format(Sys.time(), "%Y-%m-%d %H:%M:%S")))
cat(sprintf("Input path: %s\n", path_to_mat_files))
cat(sprintf("Output path: %s\n", path_to_rds_files))

# ============================================================================
# 1. Configuration and Setup
# ============================================================================
# Define paths and initialize variables for the data processing pipeline

# Input path for raw .mat files from behavioral rigs
in_path <- path_to_mat_files

# Log directory
log_path <- "/mnt/ceph/_logs"

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

  # --- basic sanity: remove empty/tiny .mat files (often the real culprit) ---
  file_info <- file.info(to_be_conv)
  tiny_idx <- which(is.na(file_info$size) | file_info$size < 1024)  # <1KB
  if (length(tiny_idx) > 0) {
    tiny_files <- to_be_conv[tiny_idx]
    cat(sprintf(
      "[%s] Skipping %d tiny/invalid .mat files (size < 1KB). Logged to tiny_mat_files.tsv\n",
      format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
      length(tiny_files)
    ))
    writeLines(tiny_files, con = file.path(log_path, "tiny_mat_files.tsv"))

    to_be_conv <- to_be_conv[-tiny_idx]
  }

  if (length(to_be_conv) == 0) {
    warning("No valid .mat files left to convert after filtering tiny/invalid files")
  } else {

    # --- cluster ---
    n_workers <- max(1, parallel::detectCores() - 1)
    cl <- parallel::makeCluster(n_workers)

    # Make sure workers have the packages + functions they need
    parallel::clusterEvalQ(cl, {
      suppressPackageStartupMessages({
        library(R.matlab)
        library(tidyverse)
      })
      NULL
    })

    # Export the conversion function (and any globals it relies on)
    parallel::clusterExport(
      cl,
      varlist = c("ConvertToRDS", "path_to_rds_files"),
      envir = environment()
    )

    # --- wrapper that never hides the filename ---
    safe_convert <- function(f) {
      tryCatch({
        ConvertToRDS(f)
        list(ok = TRUE, file = f, error = NA_character_)
      }, error = function(e) {
        list(ok = FALSE, file = f, error = conditionMessage(e))
      })
    }

    cat(sprintf(
      "[%s] Converting %d .mat files using %d workers\n",
      format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
      length(to_be_conv),
      n_workers
    ))

    results <- parallel::parLapply(cl, to_be_conv, safe_convert)

    parallel::stopCluster(cl)

    # --- summarize + log failures (don’t crash the whole run) ---
    ok_vec <- vapply(results, function(x) isTRUE(x$ok), logical(1))
    n_ok <- sum(ok_vec)
    n_bad <- length(ok_vec) - n_ok

    cat(sprintf(
      "[%s] Conversion done: %d OK, %d FAILED\n",
      format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
      n_ok, n_bad
    ))

    if (n_bad > 0) {
      failed <- results[!ok_vec]
      fail_df <- tibble::tibble(
        file = vapply(failed, `[[`, character(1), "file"),
        error = vapply(failed, `[[`, character(1), "error")
      )

      fail_log <- file.path(log_path, "failed_mat_conversions.tsv")
      readr::write_tsv(fail_df, fail_log)

      cat(sprintf(
        "[%s] Wrote failure log: %s\n",
        format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
        fail_log
      ))

      # Optional: print first few failures to console
      print(utils::head(fail_df, 10))
    }
  }

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

