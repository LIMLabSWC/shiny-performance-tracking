# source("renv/activate.R")
.First <- function() {
  # Source all utility functions
  source(file.path("utility_functions", "ConvertToRDS.R"))
  source(file.path("utility_functions", "ReadData.R"))
  source(file.path("utility_functions", "TRAININGtoCSV.R"))
  source(file.path("utility_functions", "ReadBpodData.R"))
  source(file.path("utility_functions", "ReadBcontrolData.R"))
  source(file.path("utility_functions", "ReadTrialData.R"))
  # to be completed: source(file.path("utility_functions", "ReadBonsaiData"))
}


# Dynamically detect the computer name
computer_name <- Sys.info()[["nodename"]]

# Define paths based on the computer name
if (computer_name == "LAPTOP-DSAR795N") {
  path_to_mat_files <- file.path(
    "Z:", "_raw_data", "rat_training_172", "SoloData", "Data"
  )
  path_to_rds_files <- file.path(
    "Z:", "_raw_data", "rat_training_172", "rds_files"
  )
} else if (computer_name == "akramihpc1.akramilab.swc.ucl.ac.uk") {
  path_to_mat_files <- file.path(
    "/mnt", "ceph", "_raw_data", "rat_training_172", "SoloData", "Data"
  )
  path_to_rds_files <- file.path(
    "/mnt", "ceph", "_raw_data", "rat_training_172", "rds_files"
  )
} else {
  stop(paste("Unsupported computer name:", computer_name))
}


# Load commonly used libraries
# Data Visualization and Manipulation
library(ggplot2) # For creating elegant and complex data visualizations
library(ggpubr) # For enhancing ggplot2 plots with additional functionalities
library(ggrepel) # For avoiding overlapping text labels in ggplot2 plots
library(plotly) # For interactive and web-based data visualizations

# Data Manipulation and Wrangling
library(tidyverse) # Packages for data manipulation and visualization
library(forcats) # For working with categorical data
library(purrr) # For functional programming tools
library(stringr) # For string manipulation
library(readr) # For reading rectangular data 
library(tibble) # For tibbles, a modern reimagining of data frames
library(zoo) # For working with time series data
library(chron) # For working with time series data
library(padr) # For padding time series data

# Data Import and Export
library(R.matlab) # For importing and exporting data between R and MATLAB

# Shiny and Web Applications
library(shiny) # For building interactive web applications with R
library(shinyjs) # For adding JavaScript interactivity to Shiny apps
library(DT) # For creating interactive tables in Shiny apps
library(kableExtra) # For enhancing tables in R Markdown and Shiny apps
library(rmarkdown) # For creating dynamic documents with R Markdown
library(knitr) # For knitting R Markdown documents into various formats

# Utilities and Helpers
library(gridExtra) # For arranging multiple grid graphics on a page
library(magrittr) # For a pipe operator that makes code more readable
library(parallel) # For parallel computing in R
