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
├── .Rprofile                # R profile for package loading and configuration
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

You’ll need the following packages:

- `tidyverse`
- `ggplot2`
- `ggrepel`
- `ggpubr`
- `R.matlab`
- `parallel`
- `readr`

All are automatically loaded if your `.Rprofile` is properly configured.

Utilize `.Rprofile` for:
- Loading utility functions
- Building paths to data files based on the computer.
- Loading package dependencies.



## Documentation

- [System Architecture](docs/architecture.md)
- [Data Dictionary](docs/data_dictionary.md)
- [Usage Guide](docs/usage_guide.md)
- [Server Setup Notes](docs/setup_notes.md)


## Notes

- `ExtractSaveData.R` supports batch processing and parallel conversion.
- New `.mat` files added to the source directory are automatically processed and appended.
- The system supports both session-level and trial-by-trial data (optional).
