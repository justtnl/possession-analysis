# ===
# Project: What makes a possession end in a shot or goal? 
# Script V.1: Setup, data collection, possession-level feature engineering
# Data source: StatsBomb Open Data
#   https://github.com/statsbomb/open-data/tree/master
# ===

# --- Packages --- 
if (!requireNamespace("devtools", quietly = TRUE)) install.packages("devtools")
if (!requireNamespace("StatsBombR", quietly = TRUE)) {
  devtools::install_github("statsbomb/StatsBombR")
}

library(StatsBombR)
library(tidyverse)
library(lubridate)

# --- Metadata --- 
comps <- FreeCompetitions()
View(comps)

mycomp <- comps %>%
  filter(competition_name == "Copa America", season_name == "2024")

matches <- FreeMatches(mycomp)

# --- Pull events for matches --- 
events_path <- "data/events_raw.rds"

if (!file.exists(events_path)) {
  events <- free_allevents(MatchesDF = matches, Parallel = TRUE)
  events <- allclean(events)  # StatsBombR's standard cleaning pipeline
  dir.create("data", showWarnings = FALSE)
  saveRDS(events, events_path)
} else {
  events <- readRDS(events_path)
}

# --- Possession table ---
possessions <- events %>%
  filter(period != 5) %>%
  group_by(match_id, possession, possession_team.name) %>%
  arrange(match_id, possession, index) %>%
  summarise(
    n_events = n(),
    n_passes = sum(type.name == "Pass", na.rm=TRUE),
    n_carries = sum(type.name == "Carry", na.rm=TRUE),
    n_players = n_distinct(player.name, na.rm=TRUE),
    
    start_x = first(location.x),
    start_y = first(location.y),
    end_x = last(location.x),
    end_y = last(location.y),
    
    start_time = first(ElapsedTime),
    end_time = last(ElapsedTime),
    
    last_event_type = last(type.name),
    ends_in_shot = any(type.name == "Shot",na.rm=TRUE),
    ends_in_goal = any(type.name == "Shot" & shot.outcome.name == "Goal", na.rm=TRUE),
    .groups = "drop"
  ) %>%
  
  mutate(
    duration_sec = end_time - start_time,
    start_third = case_when(
      is.na(start_x) ~ NA_character_,
      start_x < 40 ~ "Defensive",
      start_x < 80 ~ "Middle",
      TRUE ~ "Attacking"
    ),
    outcome = case_when(
      ends_in_goal ~ "Goal",
      ends_in_shot ~ "Shot (no goal)",
      last_event_type == "Interception" ~ "Interception",
      last_event_type == "Offside" ~ "Offside",
      last_event_type == "Clearance" ~ "Clearance",
      last_event_type == "Foul Won" ~ "Foul Won",
      last_event_type %in% c(
        "Ball Receipt*", "Pass", "Block", "Duel", "Miscontrol",
        "Pressure", "Dribble", "Ball Recovery", "Foul Committed",
        "50/50", "Shield", "Carry", "Error", "Goal Keeper",
        "Dispossessed"
      ) ~ "Turnover",
      last_event_type %in% c(
        "Substitution", "Referee Ball-Drop", "Injury Stoppage",
        "Tactical Shift", "Player Off", "Player On",
        "Half End", "Half Start", "Bad Behaviour"
      ) ~ NA_character_,
      TRUE ~ "Other"
    )
  )

# --- Distance travelled per possession ---

possessions_distance <- events %>%
  filter(type.name %in% c("Pass", "Carry", "Dribble", "Shot")) %>%
  arrange(match_id, possession, index) %>%
  group_by(match_id, possession) %>%
  mutate(
    dx = location.x - lag(location.x),
    dy = location.y - lag(location.y),
    step_dist = sqrt(dx^2 + dy^2)
  ) %>%
  summarise(total_distance = sum(step_dist,na.rm=TRUE),.groups = "drop")

possessions <- possessions %>%
  left_join(possessions_distance, by = c("match_id","possession"))

# --- Error check ---
possessions <- possessions %>% filter(!is.na(start_x))
glimpse(possessions)
possessions %>% count(outcome, sort = TRUE)

saveRDS(possessions, "data/possessions.rds")
# file.remove("data/possessions.rds")
# file.exists("data/possessions.rds")
