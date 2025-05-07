# .Rprofile
# Configuration file for the Shiny Performance Tracking system
# This file sets up the R environment, loads dependencies, and configures paths
# See docs/architecture.md for detailed system design

# ============================================================================
# 1. Environment Setup
# ============================================================================
# Initialize the R environment and load utility functions

# Uncomment to activate renv for package management
# source("renv/activate.R")

.First <- function() {
  # Load all utility functions from the utility_functions directory
  utility_files <- c(
    "ConvertToRDS.R",
    "ReadData.R",
    "TRAININGtoCSV.R",
    "ReadBpodData.R",
    "ReadBcontrolData.R",
    "ReadTrialData.R"
    # TODO: Add Bonsai data support
    # "ReadBonsaiData.R"
  )
  
  # Source each utility function
  sapply(utility_files, function(file) {
    source(file.path("utility_functions", file))
  })
}

# ============================================================================
# 2. Path Configuration
# ============================================================================
# Set up data paths based on the current system

# Detect the current system
computer_name <- Sys.info()[["nodename"]]

# Configure paths based on system
if (computer_name == "LAPTOP-DSAR795N") {
  # Windows laptop configuration
  path_to_mat_files <- file.path(
    "Z:", "_raw_data", "rat_training_172", "SoloData", "Data"
  )
  path_to_rds_files <- file.path(
    "Z:", "_raw_data", "rat_training_172", "rds_files"
  )
} else if (computer_name == "akramihpc1.akramilab.swc.ucl.ac.uk") {
  # HPC configuration
  path_to_mat_files <- file.path(
    "/mnt", "ceph", "_raw_data", "rat_training_172", "SoloData", "Data"
  )
  path_to_rds_files <- file.path(
    "/mnt", "ceph", "_raw_data", "rat_training_172", "rds_files"
  )
} else {
  stop(paste("Unsupported computer name:", computer_name))
}

# ============================================================================
# 3. Package Dependencies
# ============================================================================
# Load required packages grouped by functionality

# Core Data Science
library(tidyverse)    # Data manipulation and visualization
library(magrittr)     # Pipe operator for cleaner code
library(parallel)     # Parallel computing support

# Data Import/Export
library(R.matlab)     # MATLAB file support
library(readr)        # Fast data import
library(tibble)       # Modern data frames

# Data Manipulation
library(stringr)      # String manipulation
library(forcats)      # Categorical data handling
library(purrr)        # Functional programming
library(zoo)          # Time series analysis
library(chron)        # Time series analysis
library(padr)         # Time series padding

# Visualization
library(ggplot2)      # Base plotting
library(ggpubr)       # Enhanced ggplot2
library(ggrepel)      # Label positioning
library(plotly)       # Interactive plots
library(gridExtra)    # Multi-plot layouts

# Shiny and Web
library(shiny)        # Web application framework
library(shinyjs)      # JavaScript integration
library(DT)           # Interactive tables
library(kableExtra)   # Enhanced tables
library(rmarkdown)    # Dynamic documents
library(knitr)        # R Markdown processing
