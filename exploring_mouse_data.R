path_to_qp_mice <- file.path("V:","Quentin","Head_Fixed_Behavior","Data") 

files <- list.files(
  path_to_qp_mice, 
  pattern = "^Trial_Summary.*\\.csv$", 
  full.names = TRUE, 
  include.dirs = TRUE,
  recursive = TRUE
  )

# Read each file into a tibble, extracting the basename and dirname
tibbles <- files[1:100] %>%
  purrr::map(~ {
    data <- read_csv(.x)
    # data$file_path <-.x
    # data$basename <- basename(.x)
    # data$dirname <- dirname(.x)
    # data
  })


col_names <- lapply(tibbles, colnames) %>% unlist() %>% unique() %>% sort()




library(stringdist)

# Calculate the distance matrix using Levenshtein distance
distance_matrix <- stringdistmatrix(col_names, col_names, method = "lv")
threshold <- 3

hc <- hclust(as.dist(distance_matrix), method = "average")
clusters <- cutree(hc, h = threshold)
unique_ids <- paste0("Cluster_", clusters)

cols <- tibble(
  col_names1 = col_names,
  cluster = unique_ids
  
)

plot(hc)


qp_mice <- read_csv(
  file.path(
    "V:","Quentin","Head_Fixed_Behavior","Data" ,
    "Concat_Standard", "SC_Data_Standardized.csv"
    )
  )

only_na_columns <- qp_mice %>%
  is.na() %>%
  apply(MARGIN = 2, FUN = all) %>%
  which() %>%
  names()

# Print columns with only NA values
print(only_na_columns)

qp_mice <- qp_mice %>%
  dplyr::select(!all_of(only_na_columns))
  
daterange <- qp_mice$Date %>% max() - 21

qp_mice %>% 
  #dplyr::filter(Participant_ID == "QP0101") %>% 
  #dplyr::mutate(Date = as.Date(Date, format = "%m/%d/%Y")) %>%
  dplyr::group_by(Participant_ID, Date, Stage, Trial_Outcome) %>%
  dplyr::summarize(SumCorrectTrial = sum(correct)) %>%
  dplyr::filter(
    Trial_Outcome %in% c("Correct", "No_Response"),
    Date > daterange
    ) %>%
  ggplot(aes(x = Date, y = SumCorrectTrial, colour = Trial_Outcome)) +
  geom_point() +
  geom_line() +
  facet_wrap(~Participant_ID) 

plot_theme_settings <- function() {
  theme(
    axis.text.x = element_text(angle = 90, vjust = -0.001, size = 12),
    axis.text.y = element_text(size = 12),
    axis.title = element_text(size = 13, face = "bold"),
    plot.title = element_text(size = 15, face = "bold"),
    legend.title = element_text(size = 12, face = "bold"),
    legend.text = element_text(size = 12),
    legend.position = "bottom"
  )
}



qp_mice %>% 
  dplyr::filter(Date > daterange) %>% 
  dplyr::filter(Date == max(Date)) %>% 
  dplyr::filter(Trial == 1)

# Training stage
qp_mice %>% 
  dplyr::filter(
    Date > daterange,
    Trial == 1
    ) %>%
  ggplot(aes(x = Date, y = Participant_ID)) +
  geom_point(aes(col = Stage), size = 6) +
  scale_x_date(
    date_breaks = "1 day",
    date_labels = "%b %d",
    minor_breaks = "1 day"
  ) +
  xlab("Date [day]") +
  ylab("Animals") +
  ggtitle("Training stage") +
  geom_label_repel(
    data = . %>%
      dplyr::filter(Date == max(Date)),
    mapping = aes(label = Participant_ID),
    direction = "y",
    hjust = -1
  ) +
  labs(col = "Stage") +
  plot_theme_settings()



# correct ratio
qp_mice %>% 
  dplyr::filter(Date > daterange) %>% 
  dplyr::group_by(Participant_ID, Date) %>%
  summarise(
    all_trials = length(correct), 
    correct_trials = sum(correct),
    correct_ratio = correct_trials / all_trials
    ) %>% 
  ggplot(aes(x = Date, y = correct_ratio, colour = Participant_ID)) +
  ylim(0,1) +
  geom_point(size = 3) +
  geom_line(linetype = "dashed") +
  geom_hline(yintercept = 0.50, col = "gray") +
  annotate(
    "text",
    x = daterange, y = 0.51,
    label = "Chance level", col = "gray",
    vjust = 2, hjust = -0.5
  ) +
  scale_x_date(
    date_breaks = "1 day",
    date_labels = "%b %d",
    minor_breaks = "1 day"
  ) +
  # ylim(0, max(all_trials) + 10) +
  ylab("Correct ratio [No. correct / No. completed trials]") +
  xlab("Date [day]") +
  ggtitle("Correct to completed ratio") +
  geom_label_repel(
    data = . %>%
      dplyr::filter(
        Date == max(Date)
      ),
    mapping = aes(label = Participant_ID, col = Participant_ID),
    hjust = -0.5,
    direction = "y"
  ) +
  plot_theme_settings()
  


# completed trials
qp_mice %>% 
  dplyr::filter(Date > daterange) %>% 
  dplyr::group_by(Participant_ID, Date) %>%
  summarise(
    all_trials = length(correct), 
    correct_trials = sum(correct),
    correct_ratio = correct_trials / all_trials
    ) %>% 
  ggplot(aes(x = Date, y = all_trials, colour = Participant_ID)) +
  geom_point(size = 3) +
  geom_line(linetype = "dashed") +
  scale_x_date(
    date_breaks = "1 day",
    date_labels = "%b %d",
    minor_breaks = "1 day"
  ) +
  # ylim(0, max(all_trials) + 10) +
  ylab("No. completed trials") +
  xlab("Date [day]") +
  ggtitle("Completed trials") +
  geom_label_repel(
    data = . %>%
      dplyr::filter(
        Date == max(Date)
      ),
    mapping = aes(label = Participant_ID, col = Participant_ID),
    hjust = -0.5,
    direction = "y"
  ) +
  plot_theme_settings()


# choice direction
qp_mice %>% 
  dplyr::filter(Date > daterange) %>% 
  dplyr::group_by(Participant_ID, Date) %>%
  summarise(
    all_trials = length(choice),
    right_trials = sum(choice),
    left_trials = all_trials - right_trials
    ) %>% 
  tidyr::gather(key = "choice_direction", value = "No_pokes", right_trials, left_trials) %>% 
  ggplot(aes(x = Participant_ID, y = No_pokes, fill = choice_direction)) +
  geom_boxplot(alpha = 0.3) +
  geom_point(aes(group = choice_direction, col = choice_direction),
    position = position_dodge(width = 0.75),
    size = 2
  ) +
  plot_theme_settings()
