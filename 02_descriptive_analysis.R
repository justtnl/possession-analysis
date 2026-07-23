# ===
# Project: What makes a possession end in a shot or goal? 
# Script V2.1: Descriptive Analysis
# Data source: StatsBomb Open Data
#   https://github.com/statsbomb/open-data/tree/master
# ===

# --- Packages and Read Data ---
library(tidyverse)

possessions <- readRDS("data/possessions.rds")

# --- Order outcome by "positive" outcomes ---
possessions <- possessions %>%
  filter(!is.na(outcome)) %>%
  mutate(
    outcome = factor(
      outcome, 
      levels = c("Goal", "Shot (no goal)", "Foul Won", 
                 "Turnover", "Interception", "Clearance", "Offside")
    ),
    #possession speed (in yards/second)
    speed_yps = total_distance / duration_sec
  ) %>%
  filter(!is.na(outcome))

# --- 1. How long are successful possessions? ---

possessions %>%
  group_by(outcome) %>%
  summarise(
    n = n(),
    mean_duration = mean(duration_sec, na.rm=TRUE),
    median_duration = median(duration_sec, na.rm=TRUE),
  .groups = "drop"
  ) %>%
  arrange(desc(mean_duration))

ggplot(possessions, aes(x = outcome, y = duration_sec, fill = outcome)) +
  geom_boxplot(outlier.alpha = 0.2) +
  coord_cartesian(ylim = c(0, quantile(possessions$duration_sec, 0.95, na.rm = TRUE))) +
  labs(title = "Possession duration by outcome",
       x = NULL, y = "Duration (seconds)") +
  theme_minimal() +
  theme(legend.position = "none", axis.text.x = element_text(angle = 30, hjust = 1))

possessions %>% filter(duration_sec > 40) %>% count(outcome) %>% mutate(pct = n/sum(n)*100) 
#Does longer possession time help? ^

ggsave("images/duration_by_outcome.png", width = 8, height = 6, dpi = 300)

# --- 2. What aspects are involved in successful possessions? ---

possessions %>%
  group_by(outcome)%>%
  summarise(
    n = n(),
    mean_events    = mean(n_events, na.rm = TRUE),
    mean_passes    = mean(n_passes, na.rm = TRUE),
    mean_players   = mean(n_players, na.rm = TRUE),
    mean_distance  = mean(total_distance, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_passes))

possessions_long <- possessions %>%
  select(outcome, n_events, n_passes, n_players, total_distance) %>%
  pivot_longer(cols= c(n_events, n_passes, n_players, total_distance),
               names_to = "metric", values_to = "value")

Meanggplot(possessions_long, aes(x = outcome, y = value, fill = outcome)) +
  geom_boxplot(outlier.alpha = 0.15) +
  facet_wrap(~ metric, scales = "free_y") +
  labs(title = "Possession activity metrics by outcome", x = NULL, y = NULL) +
  theme_minimal() +
  theme(legend.position = "none", axis.text.x = element_text(angle = 30, hjust = 1))

# --- 3. Where do possessions start? ---

possessions %>%
  count(start_third, outcome) %>%
  group_by(start_third) %>%
  mutate(pct = n / sum(n) *100) %>%
  ungroup() %>%
  arrange(start_third, desc(pct)) %>%
  print(n = 21)

ggplot(possessions, aes(x = start_third, fill = outcome)) +
  geom_bar(position = "fill") +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Possession outcome by starting third",
       x = "Starting third", y = "Share of possessions") +
  theme_minimal()

ggsave("images/outcome_by_starting_third.png", width = 8, height = 6, dpi = 300)

# --- 4. How many passes generally lead to a shot? ---

possessions %>%
  mutate(led_to_shot = outcome %in% c("Goal", "Shot (no goal)")) %>%
  group_by(led_to_shot) %>%
  summarise(
    n = n(),
    mean_passes   = mean(n_passes, na.rm = TRUE),
    median_passes = median(n_passes, na.rm = TRUE),
    .groups = "drop"
  )

# --- 5. Does possession speed matter ---

possessions %>%
  filter(is.finite(speed_yps)) %>%
  group_by(outcome) %>%
  summarise(
    n = n(),
    mean_speed   = mean(speed_yps, na.rm = TRUE),
    median_speed = median(speed_yps, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_speed))

possessions %>%
  filter(is.finite(speed_yps)) %>%
  ggplot(aes(x = outcome, y = speed_yps, fill = outcome)) +
  geom_boxplot(outlier.alpha = 0.15) +
  coord_cartesian(ylim = c(0, quantile(possessions$speed_yps[is.finite(possessions$speed_yps)], 0.95))) +
  labs(title = "Possession speed by outcome",
       x = NULL, y = "Speed (yards / second)") +
  theme_minimal() +
  theme(legend.position = "none", axis.text.x = element_text(angle = 30, hjust = 1))

# --- 6. How does possession end? ---

possessions %>%
  count(outcome, sort = TRUE) %>%
  mutate(pct = n / sum(n) * 100)

ggplot(possessions, aes(x = fct_infreq(outcome), fill = outcome)) +
  geom_bar() +
  labs(title = "How possessions end", x = NULL, y = "Count") +
  theme_minimal() +
  theme(legend.position = "none", axis.text.x = element_text(angle = 30, hjust = 1))

ggsave("images/outcome_distribution.png", width = 8, height = 6, dpi = 300)

