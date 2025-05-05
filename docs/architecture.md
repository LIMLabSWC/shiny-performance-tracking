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

  %% Raw input
  A[.mat files] -->|raw MATLAB data| B[ConvertToRDS.R]

  %% ExtractSaveData.R wrapper
  subgraph ExtractSaveData.R [ ]
    style ExtractSaveData.R stroke-dasharray: 5 5

    B -->|.rds file| C[ReadData.R]

    C -->|BControl .rds → rat_data| D[ReadBcontrolData.R]
    C -->|Bpod .rds → rat_data| E[ReadBpodData.R]

    D -->|TRAINING list| F[TRAININGtoCSV.R]
    E -->|TRAINING list| F
  end

  %% Output and downstream
  F -->|append rows| G["TRAINING.csv (in shiny_app/)"]
  G -->|read full CSV| H[load_data.R]
  H -->|cleaned & reshaped tibble| I[Shiny app: ggplot modules]

  %% Legend
  subgraph Legend
    direction TB
    L1[Script = rectangle node]
    L2[Input/Output = arrow label]
    L3[Dashed box = grouped script logic]
  end

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
