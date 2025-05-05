# Data Dictionary: TRAINING.csv

This file describes the structure and meaning of each column in `shiny_app/TRAINING.csv`, the primary dataset used in analysis and visualization.

---

## 🧪 Metadata Fields

| Column          | Type   | Description                                        |
| --------------- | ------ | -------------------------------------------------- |
| `file`          | string | Source filename (.mat converted to .rds)           |
| `settings_file` | string | Name of the settings file loaded during experiment |
| `protocol`      | string | Protocol type parsed from filename                 |
| `data_source`   | string | Source system: `bcontrol` or `bpod`                |
| `experimenter`  | string | User who ran the experiment                        |
| `animal_id`     | string | Uppercased animal identifier                       |
| `rig_id`        | string | Rig or setup used                                  |

## 📅 Timing Fields

| Column           | Type    | Description                                               |
| ---------------- | ------- | --------------------------------------------------------- |
| `date`           | Date    | Session date (parsed from save time)                      |
| `start_time`     | time    | Time the experiment began                                 |
| `save_time`      | time    | Time the session file was saved                           |
| `session_length` | numeric | Duration in minutes (calculated from start and save time) |

## 🧠 Stage Information

| Column  | Type   | Description                                                              |
| ------- | ------ | ------------------------------------------------------------------------ |
| `stage` | string | Training stage label (recoded from numeric codes and reward type fields) |

## 🐁 Behavior Counts

| Column             | Type    | Description                                        |
| ------------------ | ------- | -------------------------------------------------- |
| `right_trials`     | integer | Number of right pokes in session                   |
| `left_trials`      | integer | Number of left pokes in session                    |
| `right_hit_frac`   | numeric | Fraction of hits on right side                     |
| `left_hit_frac`    | numeric | Fraction of hits on left side                      |
| `all_trials`       | integer | Total number of trials completed                   |
| `completed_trials` | integer | Trials with valid outcomes (non-timeout/violation) |
| `correct_trials`   | integer | Trials marked as hits (value = 1)                  |
| `error_trials`     | integer | Trials marked as misses (value = 0)                |
| `violation_trials` | integer | Trials marked as violations                        |
| `timeoout_trials`  | integer | Trials that timed out                              |

## ⏱ Timing Variables

| Column        | Type    | Description                                                        |
| ------------- | ------- | ------------------------------------------------------------------ |
| `init_CP`     | numeric | Initial center poke duration                                       |
| `total_CP`    | numeric | Total center poke duration for session                             |
| `A1_time`     | numeric | Delay between center poke and stim onset                           |
| `A2_time`     | numeric | Delay between stimulus and response phase                          |
| `reward_type` | string  | Reward schedule used (e.g., `Always`, `NoReward`, `DelayedReward`) |

## 📊 Reshaped Fields (long format)

| Column             | Type    | Description                                       |
| ------------------ | ------- | ------------------------------------------------- |
| `choice_direction` | string  | Either `left_trials` or `right_trials`            |
| `No_pokes`         | integer | Count of pokes corresponding to choice\_direction |

---

## Notes

* Field values marked as `"empty_field_in_mat_file"` indicate missing or unlogged information.
* Stage names are assigned in `load_data.R` and may combine reward conditions with numerical stage IDs.
* The `choice_direction` reshaping allows per-choice visualization using ggplot.

## Source

Most fields are parsed from `.mat` files using `ReadBcontrolData.R` or `ReadBpodData.R`, aggregated by `ExtractSaveData.R`, and written to CSV by `TRAININGtoCSV.R`.

---

> This document is maintained in `docs/data_dictionary.md` to support interpretation of behavioral training data.
