# Shiny Performance Tracking

This repository provides a complete pipeline for processing rodent training data, converting raw `.mat` files into structured `.rds` files, extracting behavioral metrics, and visualizing performance trends in an interactive Shiny dashboard.


## Overview

The system enables researchers to:

- Import experimental data from **BControl** or **Bpod** sessions.
- Process and transform data into a clean, analysis-ready format.
- Automatically aggregate session-level metrics into `TRAINING.csv`.
- Explore data interactively with **Shiny** visualizations.


## Repository Structure

```
shiny-performance-tracking/
├── docs/
│   ├── architecture.md
│   ├── data_dictionary.md
│   ├── usage_guide.md
│   └── setup_notes.md
├── shiny_app/
│   ├── app.R
│   ├── TRAINING.csv         # Main dataset for the dashboard
│   ├── full_TRAINING.csv    # Optional, long-term aggregation
│   └── functions/           # Modular ggplot-based visualization scripts
├── utility_functions/       # File parsing and processing logic
│   ├── ConvertToRDS.R
│   ├── ReadBcontrolData.R
│   ├── ReadBpodData.R
│   ├── ReadData.R
│   ├── ReadTrialData.R
│   └── TRAININGtoCSV.R
├── .Rprofile                # R environment configuration and package management
├── ExtractSaveData.R        # Main ETL pipeline: from .mat to .csv
└── README.md                # Overview + links to docs

```


## Shiny App

Launch the app locally:

```r
setwd("shiny_app")
shiny::runApp()
```

The dashboard includes:

- **Stage tracking** by animal
- **Correct ratio** trends
- **Trial completion rates**
- **Choice direction** distributions



## Dependencies

The system uses several R packages organized by functionality:

### Core Data Science
- `tidyverse` - Data manipulation and visualization
- `magrittr` - Pipe operator for cleaner code
- `parallel` - Parallel computing support

### Data Import/Export
- `R.matlab` - MATLAB file support
- `readr` - Fast data import
- `tibble` - Modern data frames

### Data Manipulation
- `stringr` - String manipulation
- `forcats` - Categorical data handling
- `purrr` - Functional programming
- `zoo`, `chron`, `padr` - Time series analysis

### Visualization
- `ggplot2` - Base plotting
- `ggpubr` - Enhanced ggplot2
- `ggrepel` - Label positioning
- `plotly` - Interactive plots
- `gridExtra` - Multi-plot layouts

### Shiny and Web
- `shiny` - Web application framework
- `shinyjs` - JavaScript integration
- `DT` - Interactive tables
- `kableExtra` - Enhanced tables
- `rmarkdown`, `knitr` - Dynamic documents

All dependencies are automatically loaded through `.Rprofile`, which also:
- Manages utility function loading using a vector-based approach
- Configures system-specific data paths
- Sets up the R environment for optimal performance



## Documentation

- [Project Architecture](docs/architecture.md)
- [Data Dictionary](docs/data_dictionary.md)
- [Usage Guide](docs/usage_guide.md)
- [Server Setup Notes](docs/setup_notes.md)


## Notes

- `ExtractSaveData.R` supports batch processing and parallel conversion.
- New `.mat` files added to the source directory are automatically processed and appended.
- The system supports both session-level and trial-by-trial data (optional).
- Utility functions are loaded dynamically through `.Rprofile` for better maintainability.
