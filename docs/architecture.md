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

![Mermaid Diagram](https://mermaidviewer.com/api/diagrams/cmabqds5m01y4mt1cg7bcv904/image)


```mermaid
sequenceDiagram
    participant Cron as cron/systemd (optional)
    participant Extract as ExtractSaveData.R
    participant Drive as Centralized Data Drive
    participant Convert as ConvertToRDS.R
    participant ReadData as ReadData.R (wrapper)
    participant Bcontrol as ReadBcontrolData.R
    participant Bpod as ReadBpodData.R
    participant CSV as TRAININGtoCSV.R
    participant Loader as load_data.R
    participant App as Shiny app

    Cron->>Extract: scheduled trigger
    Extract->>Drive: scan for new .mat files
    Extract->>Convert: call ConvertToRDS.R
    Convert-->>Extract: .rds file
    Extract->>ReadData: pass .rds file

    alt Source is BControl
        ReadData->>Bcontrol: .rds file
        Bcontrol-->>ReadData: TRAINING list
    else Source is Bpod
        ReadData->>Bpod: .rds file
        Bpod-->>ReadData: TRAINING list
    end

    ReadData-->>Extract: TRAINING list
    Extract->>CSV: pass TRAINING list
    CSV->>Loader: TRAINING.csv
    Loader->>App: tidy tibble
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
