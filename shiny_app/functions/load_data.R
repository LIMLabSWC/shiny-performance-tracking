# Read the TRAINING dataset from a CSV file
TRAINING <- read_csv(file.path("TRAINING.csv"))

# Transform and clean the TRAINING dataset
TRAINING <- TRAINING %>%
  # Convert date to Date type
  mutate(date = date %>% as.Date(format = c("%d-%b-%Y"))) %>%
  # Convert animal_id to uppercase
  mutate(animal_id = animal_id %>% toupper()) %>%
  # Calculate session_length in minutes
  mutate(session_length = difftime(save_time, start_time, units = "mins")) %>%
  # Clean up settings_file
  mutate(settings_file = ifelse(settings_file == "empty_field_in_mat_file",
    yes = "empty_field_in_mat_file",
    no = settings_file %>% substr(start = nchar(.) - 10, stop = nchar(.) - 4)
  )) %>%
  # Conditionally replace stage values
  mutate(stage = replace(stage, stage == 0, "0_side_poke_on")) %>%
  mutate(
    stage = replace(stage, stage == 1, "1_center_poke_on")
  ) %>%
  mutate(stage = replace(
    stage,
    A2_time > 0 & A2_time < 0.5 & reward_type == "Always",
    "2_intord_stim"
  )) %>%
  mutate(
    stage = replace(
      stage, reward_type == "DelayedReward", "3_DelayedReward"
    )
  ) %>%
  mutate(stage = replace(stage, reward_type == "NoReward", "3_NoReward")) %>%
  # replace NAs in stage with "non-defined stage"
  mutate(
    stage = replace(stage, is.na(stage), "non-defined stage")
  ) %>% 
  # Reshape the data to long format for trials
  rowwise() %>%
  ungroup() %>%
  gather(
    right_trials, left_trials,
    key = "choice_direction", value = "No_pokes"
  )


# all_protocols <- TRAINING$protocol %>% unique() %>% as.character()
