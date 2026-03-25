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

# -- 4. Combined Beds + Cancer Dataset (ecological study) --------------------
epi_combined <- inner_join(
  beds_raw   |> select(year, beds_per_100k),
  cancer_raw |> select(year, deaths_per_100k),
  by = "year"
)

beds_cancer_r <- cor(
  epi_combined$beds_per_100k,
  epi_combined$deaths_per_100k,
  method = "pearson"
)

# -- 5. Pre-compute Baseline Prevalence --------------------------------------
# A baseline prevalence estimate (per 100k) is required to initialize 
# the Bayesian PPV calculator on startup.
finland_2021_prevalence <- 3168
finland_prevalence_prop <- finland_2021_prevalence / 100000

# -- 6. Year ranges ---------------------------------------------------------
lt_years     <- sort(unique(life_raw$year))
lt_ages      <- sort(unique(life_raw$age))
cancer_years <- sort(unique(cancer_raw$year))