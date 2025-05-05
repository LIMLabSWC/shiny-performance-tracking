# System Architecture

This document outlines the architecture and data flow of the **Shiny Performance Tracking** system. The project processes and visualizes rodent training data collected via **BControl** or **Bpod** experimental setups.


## 🧱 High-Level Components

- **Raw Input**: `.mat` files from behavioral rigs.
- **Conversion**: Transformed to `.rds` files using `R.matlab`.
- **Parsing**: Extracted into structured R lists representing metadata and trial data.
- **Aggregation**: Session-level summaries are appended into `TRAINING.csv`.
- **Visualization**: Interactive Shiny app for viewing trends across animals, stages, and protocols.

## 🔄 Data Flow

1. `.mat` files placed into a data directory.
2. Run `ExtractSaveData.R`:
   - Converts new `.mat` files to `.rds` via `ConvertToRDS.R`
   - Extracts metadata using `ReadBcontrolData.R` or `ReadBpodData.R`
   - Appends new data into `TRAINING.csv` using `TRAININGtoCSV.R`
3. Shiny app (`shiny_app/app.R`) loads `TRAINING.csv` using `load_data.R`
4. Visualization functions in `shiny_app/functions/` generate plots.


```mermaid
graph TD

  %% Step 1: .mat input to .rds
  A[".mat file (from BControl or Bpod)"] --> B[ConvertToRDS.R]
  B -->|".rds file (converted from .mat)"| C[ReadData.R]

  %% Step 2: Dispatch to reader
  subgraph ReadData.R [ReadData.R dispatch]
    style ReadData.R stroke-dasharray: 5 5
    C -->|bControl .rds| D[ReadBcontrolData.R]
    C -->|bpod .rds| E[ReadBpodData.R]
  end

  %% Step 3: Output to CSV
  D -->|TRAINING list| F[TRAININGtoCSV.R]
  E -->|TRAINING list| F
  F -->|"writes TRAINING.csv (session data from raw data files)"| G[load_data.R]

  %% Step 4: Shiny pipeline
  G -->|"cleaned tibble (reshaped for plotting)"| H[Shiny app: plot modules]

```

## 🗂️ Folder Structure Summary

```
shiny-performance-tracking/
├── shiny\_app/
│   ├── app.R                   # Main Shiny app
│   ├── functions/              # Plot modules
│   └── TRAINING.csv            # Aggregated session-level data
├── utility\_functions/
│   ├── ConvertToRDS.R
│   ├── ReadBcontrolData.R
│   ├── ReadBpodData.R
│   ├── ReadData.R
│   └── TRAININGtoCSV.R
├── ExtractSaveData.R          # Main batch processor

```


## 📈 Plot Functions

These are modular ggplot-based scripts that power the Shiny dashboard:

- `ChoiceDirectionPlot.R`: Boxplot of pokes per direction
- `CorrectRatioPlot.R`: Line plot of correct/total trials
- `CompletedTrialsPlot.R`: Daily trial counts
- `StageTrackingPlot.R`: Tracks stage progression per animal

Each one uses a consistent API: filters by protocol, date, stage, experimenter, and animal.


## 🧠 Design Notes

- The pipeline is **idempotent**: new files are processed only once.
- `ExtractSaveData.R` uses parallel processing for speed.
- Trial-level data extraction is supported but optional (commented).
- Shiny app uses preprocessed `.csv` rather than raw `.rds` for performance.
