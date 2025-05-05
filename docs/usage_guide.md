---

title: "shiny-performance-tracking"
output: github\_document
------------------------

# Shiny Performance Tracking

A pipeline for extracting, processing, and visualizing rodent behavioral training data using R and Shiny.

---

## 🧠 Purpose

This project supports labs running experiments via **BControl** or **Bpod**, enabling them to:

* Convert raw `.mat` files into `.rds` for easier handling
* Extract and clean session-level data automatically
* Visualize training progress and performance metrics interactively
* Deploy the analysis as a Shiny web app

---

## 📂 Project Structure

```
shiny-performance-tracking/
├── shiny_app/             # Shiny frontend and preprocessed data
├── utility_functions/     # Backend data extraction utilities
├── docs/                  # Documentation files (architecture, usage, dictionary)
├── ExtractSaveData.R      # Main processing pipeline
├── analysis.R             # Offline exploration
└── README.md              # (You are here)
```

---

## 🚀 Quick Start

1. Add `.mat` files to your data folder
2. Run:

   ```r
   source("ExtractSaveData.R")
   ```
3. Launch the app:

   ```r
   shiny::runApp("shiny_app")
   ```

---

## 📊 Features

* Boxplots of choice direction
* Time series of completed trials
* Accuracy ratio plots
* Stage tracking visuals
* Experimenter/animal filtering

---

## 📖 Documentation

| File                      | Purpose                       |
| ------------------------- | ----------------------------- |
| `docs/architecture.Rmd`   | Full system overview          |
| `docs/data_dictionary.md` | Description of TRAINING.csv   |
| `docs/usage_guide.md`     | End-to-end usage instructions |

---

## 🧰 Dependencies

R packages:

```r
c("tidyverse", "ggplot2", "ggpubr", "stringr", "parallel", "R.matlab", "ggrepel")
```

---

## 📤 Deployment

App can be deployed to [shinyapps.io](https://www.shinyapps.io) using files in `shiny_app/rsconnect/`.

---

## 🧪 Credits

Developed by Viktor Plattner at the Akrami Lab (UCL - SWC).

---

> See `docs/` for extended documentation. Contributions and feedback are welcome!
