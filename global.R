# =============================================================================
# global.R – Data loading and pre-processing for Finland Health Dashboard
# =============================================================================
# Packages are loaded here so they are available to both ui.R and server.R.

library(shiny)
library(shinydashboard)
library(tidyverse)
library(janitor)
library(plotly)
library(DT)

# ── Helper: null-coalescing operator (returns y when x is NULL or NA) ────────
`%||%` <- function(x, y) if (!is.null(x) && !is.na(x)) x else y

# ── 1. Life Tables ─────────────────────────────────────────────────────────
life_raw <- read_csv(
  file.path("data", "life_tables.csv"),
  show_col_types = FALSE
) |>
  clean_names() |>
  filter(country == "Finland") |>
  rename(prob_death = probability_of_death_per_mille) |>
  mutate(
    age  = as.integer(age),
    year = as.integer(year),
    sex  = factor(sex, levels = c("Male", "Female"))
  )

# ── 2. Hospital Beds ────────────────────────────────────────────────────────
beds_raw <- read_csv(
  file.path("data", "beds.csv"),
  show_col_types = FALSE
) |>
  clean_names() |>
  filter(country == "Finland") |>
  rename(beds_per_100k = hospital_beds_per_100_000_population) |>
  mutate(year = as.integer(year))

# ── 3. Cancer ───────────────────────────────────────────────────────────────
cancer_raw <- read_csv(
  file.path("data", "cancer.csv"),
  show_col_types = FALSE
) |>
  clean_names() |>
  filter(country == "Finland") |>
  rename(
    deaths_per_100k = deaths_per_100_000_population,
    prevalence_per_100k = prevalence_per_100_000
  ) |>
  mutate(year = as.integer(year))

# Note: Cancer data ends 2021, Hospital Beds data ends 2023.
max_cancer_year <- max(cancer_raw$year)   # 2021
max_beds_year   <- max(beds_raw$year)     # 2023

# ── 4. Pre-compute Finland 2021 "All cancers" prevalence for Screening tab ──
finland_2021_prevalence <- cancer_raw |>
  filter(cancer_type == "All cancers", year == max_cancer_year) |>
  pull(prevalence_per_100k) |>
  first()

# Prevalence as a proportion (per 100 000 → proportion)
finland_prevalence_prop <- finland_2021_prevalence / 100000

# ── 5. Year ranges (used in sliders / UI) ──────────────────────────────────
lt_years     <- sort(unique(life_raw$year))
lt_ages      <- sort(unique(life_raw$age))
cancer_years <- sort(unique(cancer_raw$year))
