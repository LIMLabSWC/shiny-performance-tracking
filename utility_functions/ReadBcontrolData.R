# Function to read and process data from an RDS file
ReadBcontrolData <- function(rds_file, rat_data, data_source) {
  # Extract section name from rds_file name
  section_name <- rds_file %>% substr(
    start = rds_file %>% gregexpr(pattern = "@") %>% unlist() %>% `+`(1),
    stop = rds_file %>% gregexpr(pattern = "_") %>% unlist() %>% `[`(2) - 1
  )

  # Determine positions for filename and settings filename in the path
  filename_pos <- gregexpr(
    rat_data$saved[, , ]$SavingSection.data.file %>%
      as.character(),
    pattern = "\\\\"
  ) %>%
    unlist() %>%
    `[[`(length(.)) + 1

  settings_filename_pos <- gregexpr(
    rat_data$saved[, , ]$SavingSection.settings.file %>%
      as.character(),
    pattern = "\\\\"
  ) %>%
    unlist() %>%
    `[[`(length(.)) + 1

  # Initialize TRAINING list to store processed data
  TRAINING <- list(
    # Files, animals, experimenters
    file = rds_file,
    settings_file = rat_data$saved[, , ]$SavingSection.settings.file %>%
      as.character() %>%
      substr(start = settings_filename_pos, stop = nchar(.)),
    protocol = substr(rds_file,
      start = rds_file %>% gregexpr(pattern = "@") %>% unlist(),
      stop = rds_file %>% gregexpr(pattern = "_") %>% unlist() %>% `[`(2) - 1
    ),
    data_source = data_source,
    experimenter = rat_data$saved[, , ]$SavingSection.experimenter %>%
      as.character(),
    animal_id = rat_data$saved[, , ]$SavingSection.ratname %>%
      as.character(),
    rig_id = rat_data$saved[, , ]$WaterValvesSection.RigID %>%
      as.character(),

    # Date, time, stage
    date = rat_data$saved[, , ]$SavingSection.SaveTime %>%
      as.character() %>%
      substr(1, 11),
    start_time = rat_data$saved[, , ]$SavingSection.settings.file.load.time %>%
      as.numeric() %>% `-`(719529) %>% `*`(86400) %>%
      as.POSIXct(origin = "1970-01-01", tz = "UTC") %>%
      as.character() %>%
      substr(12, 20),
    save_time = rat_data$saved[, , ]$SavingSection.SaveTime %>%
      as.character() %>%
      substr(13, 20),
    stage = rat_data$saved[, , ]$SideSection.training.stage %>% as.numeric(),

    # Trials
    right_trials = rat_data$saved[, , ]$SideSection.previous.sides %>%
      intToUtf8(multiple = T) %>%
      `[`(. == "r") %>%
      length(),
    left_trials = rat_data$saved[, , ]$SideSection.previous.sides %>%
      intToUtf8(multiple = T) %>%
      `[`(. == "l") %>%
      length(),
    right_hit_frac = rat_data$saved[, , ]$
      OverallPerformanceSection.Right.hit.frac,
    left_hit_frac = rat_data$saved[, , ]$
      OverallPerformanceSection.Left.hit.frac,
    all_trials = rat_data$saved[, , ]$ProtocolsSection.n.done.trials %>%
      as.numeric(),
    completed_trials = get(
      paste(section_name, ".hit.history", sep = ""),
      rat_data$saved[, , ]
    ) %>%
      `[`(!is.na(.)) %>% length(),
    correct_trials = get(
      paste(section_name, ".hit.history", sep = ""),
      rat_data$saved[, , ]
    ) %>%
      `[`(get(
        paste(section_name, ".hit.history", sep = ""),
        rat_data$saved[, , ]
      ) == 1) %>% na.omit() %>% sum(),
    error_trials = get(
      paste(section_name, ".hit.history", sep = ""),
      rat_data$saved[, , ]
    ) %>%
      `[`(get(
        paste(section_name, ".hit.history", sep = ""),
        rat_data$saved[, , ]
      ) == 0) %>% na.omit() %>% length(),

    violation_trials = if (exists(
      paste(section_name, ".violation.history", sep = ""),
      where = rat_data$saved[, , ],
      inherits = FALSE
    )) {
      get(
        paste(section_name, ".violation.history", sep = ""),
        rat_data$saved[, , ]
      ) %>%
        as.numeric() %>%
        sum(na.rm = T)
    } else {
      NA_real_
    },

    timeoout_trials = get(
      paste(section_name, ".timeout.history", sep = ""),
      rat_data$saved[, , ]
    ) %>%
      as.numeric() %>%
      sum(na.rm = T),
    init_CP = rat_data$saved[, , ]$SideSection.init.CP.duration %>%
      as.numeric(),
    total_CP = rat_data$saved[, , ]$SideSection.Total.CP.duration %>%
      as.numeric(),
    A1_time = rat_data$saved[, , ]$SideSection.A1.time %>% as.numeric(),
    A2_time = rat_data$saved[, , ]$SideSection.A2.time %>% as.numeric(),
    reward_type = rat_data$saved[, , ]$SideSection.reward.type %>%
      as.character()
  )

  # Convert empty elements to text for compatibility with TRAININGtoCSV
  TRAINING <- lapply(
    TRAINING,
    function(x) ifelse(is_empty(x), yes = "empty_field_in_mat_file", no = x)
  )
  return(TRAINING)
}

# Documentation:
# Variables:
# - rds_file: The name of the RDS file to process.
# - rat_data: The data structure containing the saved data from the RDS file.
# - data_source: The source of the data (e.g., "experiment", "simulation").
# - section_name: The name of the section within the RDS file.
# - filename_pos: The position of the filename in the path.
# - settings_filename_pos: The position of the settings filename in the path.
# - TRAINING: A list containing processed data from the RDS file.
