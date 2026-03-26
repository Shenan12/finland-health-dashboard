# =============================================================================
# global.R - Data loading and pre-processing for Finland Health Dashboard
# =============================================================================
library(shiny)
library(shinydashboard)
library(tidyverse)
library(janitor)
library(plotly)
library(DT)

# Helper: null-coalescing operator
`%||%` <- function(x, y) if (!is.null(x) && !is.na(x)) x else y

# -- 1. Life Tables ---------------------------------------------------------
life_raw <- read_csv(
  file.path("data", "life_tables.csv"),
  skip = 2,  
  show_col_types = FALSE
) |>
  clean_names() |>
  rename(
    prob_death = probability_of_death_per_mille,
    survivors = survivors_of_100_000_born_alive  
  ) |>
  mutate(
    # NEW FIX: Force R to treat these columns as numbers, not text
    prob_death = as.numeric(prob_death),
    survivors  = as.numeric(survivors),
    
    # Changes "Males" / "Females" to match standard demographic labels
    sex = case_when(
      sex == "Males" ~ "Male",
      sex == "Females" ~ "Female",
      TRUE ~ sex
    ),
    age  = as.integer(age),
    year = as.integer(year),
    sex  = factor(sex, levels = c("Male", "Female", "Total"))
  )
# -- 2. Hospital Beds --------------------------------------------------------
beds_raw <- read_csv(
  file.path("data", "beds.csv"),
  show_col_types = FALSE
) |>
  clean_names() |>
  filter(entity == "Finland") |>
  mutate(
    # Converts beds per 1,000 to per 100,000 so the graph scaling matches cancer data
    beds_per_100k = hospital_beds_per_1_000_people * 100,
    year = as.integer(year)
  )

# -- 3. Cancer ---------------------------------------------------------------
cancer_raw <- read_csv(
  file.path("data", "cancer.csv"),
  show_col_types = FALSE
) |>
  clean_names() |>
  filter(entity == "Finland") |>
  rename(deaths_per_100k = death_rate_from_malignant_neoplasms_among_both_sexes) |>
  mutate(
    year = as.integer(year)
  )

max_cancer_year <- max(cancer_raw$year, na.rm = TRUE)
max_beds_year   <- max(beds_raw$year, na.rm = TRUE)

# -- 4. Death Rate (Statistics Finland) -------------------------------------
# Source: Statistics Finland 11ay – all-cause age-standardised death rate,
# total sex, "00-54 Total" (whole population), 1971-2024.
death_raw <- read_csv(
  file.path("data", "DeathRate.csv"),
  skip = 2,
  show_col_types = FALSE
) |>
  clean_names() |>
  filter(
    sex == "Total",
    underlying_cause_of_death_time_series_classification == "00-54 Total"
  ) |>
  select(
    year,
    death_rate = age_standardised_death_rate_whole_population_1_100_000
  ) |>
  mutate(
    year       = as.integer(year),
    death_rate = as.numeric(death_rate)
  ) |>
  filter(year >= 2000) |>
  na.omit()

death_years <- sort(unique(death_raw$year))

# -- 5. Cause-specific Deaths -----------------------------------------------
death_rate_full <- read_csv(
  file.path("data", "DeathRate.csv"),
  skip = 2,
  show_col_types = FALSE
) |>
  clean_names()

cause_group_map <- c(
  "01-03" = "Infectious Diseases",
  "04-21" = "Malignant Neoplasms",
  "23-24" = "Endocrine/Metabolic",
  "25"    = "Dementia/Alzheimer",
  "27-30" = "Circulatory Diseases",
  "31-35" = "Respiratory Diseases",
  "41"    = "Alcohol-Related",
  "42-53" = "Accidents & Violence"
)

cause_summary_df <- death_rate_full |>
  filter(sex == "Total", year >= 2000) |>
  mutate(
    cause_code = str_extract(underlying_cause_of_death_time_series_classification, "^[0-9]+-?[0-9]*"),
    deaths     = as.numeric(deaths_whole_population),
    year       = as.integer(year)
  ) |>
  filter(cause_code %in% names(cause_group_map)) |>
  mutate(cause = cause_group_map[cause_code]) |>
  group_by(year, cause) |>
  summarise(deaths = sum(deaths, na.rm = TRUE), .groups = "drop") |>
  arrange(year, cause)

cause_share_df <- cause_summary_df |>
  group_by(year) |>
  mutate(proportion = deaths / sum(deaths, na.rm = TRUE)) |>
  ungroup()

tumour_share_df <- death_rate_full |>
  filter(sex == "Total", year >= 2000) |>
  mutate(
    cause_code = str_extract(underlying_cause_of_death_time_series_classification, "^[0-9]+-?[0-9]*"),
    deaths     = as.numeric(deaths_whole_population),
    year       = as.integer(year)
  ) |>
  filter(cause_code %in% c("04-21", "00-54")) |>
  select(year, cause_code, deaths) |>
  pivot_wider(names_from = cause_code, values_from = deaths) |>
  rename(cancer_deaths = `04-21`, total_deaths = `00-54`) |>
  mutate(tumour_pct = cancer_deaths / total_deaths * 100) |>
  na.omit()

# -- 6. Crude Birth Rate -----------------------------------------------------
birth_rate_df <- read_csv(
  file.path("data", "CrudeBirthRate.csv"),
  skip = 2,
  show_col_types = FALSE
) |>
  clean_names() |>
  select(year, crude_birth_rate = total_live_births) |>
  mutate(
    year             = as.integer(year),
    crude_birth_rate = as.numeric(crude_birth_rate)
  ) |>
  filter(year >= 2000) |>
  na.omit()

# -- 7. Stillbirths ----------------------------------------------------------
stillbirth_raw <- read_csv(
  file.path("data", "StillBirths.csv"),
  skip = 1,
  show_col_types = FALSE
) |>
  clean_names()

stillbirth_df <- stillbirth_raw |>
  select(matches("_stillbirths$")) |>
  slice(1) |>
  pivot_longer(everything(), names_to = "year_col", values_to = "stillbirths") |>
  mutate(
    year        = as.integer(str_extract(year_col, "[0-9]{4}")),
    stillbirths = as.numeric(stillbirths)
  ) |>
  select(year, stillbirths) |>
  left_join(birth_rate_df, by = "year") |>
  mutate(
    stillbirth_rate = stillbirths / (crude_birth_rate + stillbirths) * 1000
  ) |>
  filter(!is.na(stillbirth_rate), year >= 2000)

# -- 8. Merged analytical dataset -------------------------------------------
# Inner join limits to years covered by ALL three sources (2000-2021).
health_df <- beds_raw |>
  select(year, beds_per_100k) |>
  inner_join(cancer_raw |> select(year, deaths_per_100k), by = "year") |>
  inner_join(death_raw  |> select(year, death_rate),      by = "year") |>
  na.omit() |>
  arrange(year) |>
  mutate(
    # Binary outcome: 1 if death rate above 75th percentile (top 25%), 0 otherwise
    high_mortality = as.integer(death_rate > quantile(death_rate, 0.75, na.rm = TRUE)),
    # One-year lag of hospital beds to capture delayed healthcare effects
    beds_lag1      = lag(beds_per_100k, 1)
  )

# -- 9. Pre-compute Baseline Prevalence --------------------------------------
# A baseline prevalence estimate (per 100k) for Finland, based on cancer
# incidence data circa 2021. Required to initialise the Bayesian PPV calculator.
# Source: Finnish Cancer Registry / Our World in Data cancer prevalence estimates.
finland_2021_prevalence <- 3168
finland_prevalence_prop <- finland_2021_prevalence / 100000

# -- 10. Year ranges ---------------------------------------------------------
lt_years     <- sort(unique(life_raw$year))
lt_ages      <- sort(unique(life_raw$age))
cancer_years <- sort(unique(cancer_raw$year))

# -- 11. Correlation Data (beds vs cancer, for existing Epi tab) ------------
# Joins beds and cancer data by year for the ecological study (2000 to 2021)
correlation_df <- inner_join(
  beds_raw |> select(year, beds_per_100k),
  cancer_raw |> select(year, deaths_per_100k),
  by = "year"
)

# -- 12. Pre-fit Statistical Models (global, for performance) ---------------

# Multivariate linear regression: overall death rate ~ beds + cancer deaths + year
lm_model <- lm(death_rate ~ beds_per_100k + deaths_per_100k + year, data = health_df)

# Logistic regression: high mortality (binary) ~ beds + cancer deaths
# Use complete cases only (excluding first row which has NA beds_lag1)
health_df_complete <- health_df |> filter(!is.na(beds_lag1))
glm_model <- glm(
  high_mortality ~ beds_per_100k + deaths_per_100k,
  data   = health_df_complete,
  family = binomial
)