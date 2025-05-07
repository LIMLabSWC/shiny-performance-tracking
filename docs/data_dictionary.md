# Data Dictionary: TRAINING.csv

This file defines the meaning and origin of each column in `TRAINING.csv`, the main dataset used by the Shiny app.


## Column Descriptions

| Column             | Description |
|--------------------|-------------|
| `file`             | Filename of the original `.mat` file |
| `settings_file`    | Settings file basename used in the session |
| `protocol`         | Protocol name parsed from the filename |
| `data_source`      | Source type: either `"bcontrol"` or `"bpod"` |
| `experimenter`     | Name of the person who ran the session |
| `animal_id`        | Unique identifier of the subject |
| `rig_id`           | ID of the behavioral rig used |
| `date`             | Session date (parsed from save timestamp) |
| `start_time`       | Start time (converted from load timestamp) |
| `save_time`        | Save time (timestamp of session end) |
| `stage`            | Stage label (e.g., `"1_center_poke_on"`, `"3_NoReward"`) |
| `right_trials`     | Number of right-sided choices |
| `left_trials`      | Number of left-sided choices |
| `right_hit_frac`   | Hit fraction for right trials (if available) |
| `left_hit_frac`    | Hit fraction for left trials (if available) |
| `all_trials`       | Total number of trials attempted |
| `completed_trials` | Trials with valid outcome (correct or error) |
| `correct_trials`   | Number of correct (i.e., rewarded) trials |
| `error_trials`     | Number of incorrect responses |
| `violation_trials` | Number of rule violations during the session |
| `timeout_trials`   | Number of timeout trials |
| `init_CP`          | Initial center poke duration |
| `total_CP`         | Total center poke duration |
| `A1_time`, `A2_time` | Time spent in certain state/action windows |
| `reward_type`      | Type of reward policy used |
| `session_length`   | Derived from `save_time - start_time` |
| `choice_direction` | Either `"left_trials"` or `"right_trials"` (long format) |
| `No_pokes`         | Number of pokes for the given choice direction |



## Notes

- Some fields (like `reward_type`, `stage`, and `A2_time`) are re-coded during the `load_data.R` cleaning step.
- The file is reshaped to *long format* before plotting: one row per choice direction (`left_trials` or `right_trials`).
- Fields marked as `"empty_field_in_mat_file"` were missing in the original `.mat`.
