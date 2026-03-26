# Finland Health Dashboard

> An interactive R Shiny dashboard analysing demographic and public-health trends in **Finland (2000–2024)**, built as a Medical Statistics project.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Directory Structure](#directory-structure)
3. [Data Sources](#data-sources)
4. [Dashboard Tabs](#dashboard-tabs)
5. [Statistical Methods](#statistical-methods)
6. [Installation & Running](#installation--running)
7. [Dependencies](#dependencies)
8. [Contributing](#contributing)
9. [License](#license)

---

## Project Overview

This dashboard integrates five official Finland health datasets to deliver:

- **Demographic trends**: age-specific mortality (q_x) animated over 2000–2024, population pyramid, live birth counts, and stillbirth rates.
- **Mortality & disease burden**: all-cause age-standardised death rates, year-on-year rate-of-change, cause-specific stacked area charts, and cancer's share of total deaths.
- **Healthcare capacity & regression models**: hospital bed trends with multivariate linear regression, logistic regression (high-mortality binary outcome), correlation matrix, and lag analysis.
- **Screening decision support**: interactive Bayesian PPV / NPV calculator with likelihood ratios, using Finland's real cancer prevalence.
- **Mathematical theory**: all statistical and actuarial methods rendered with MathJax / LaTeX.

The project follows a standard modular R Shiny structure (`global.R` / `ui.R` / `server.R`).

---

## Directory Structure

```
finland-health-dashboard/
├── global.R                     # Package loading, data import, pre-processing, model fitting
├── ui.R                         # shinydashboard layout (6 tabs)
├── server.R                     # Reactive logic, Plotly charts, regression outputs, PPV calculator
├── data/
│   ├── life_tables.csv          # Age-sex-year life table (Statistics Finland, 2000–2024)
│   ├── beds.csv                 # Hospital beds / 100 000 (Our World in Data, 2000–2023)
│   ├── cancer.csv               # Cancer deaths per 100 000 (Our World in Data, 2000–2021)
│   ├── DeathRate.csv            # Age-standardised death rate by cause (Statistics Finland, 2000–2024)
│   ├── CrudeBirthRate.csv       # Total live births per year (Statistics Finland, 2000–2024)
│   ├── StillBirths.csv          # Stillbirth counts (Statistics Finland, 2000–2024)
│   └── deathsWithCauseFiltered.csv  # Filtered cause-of-death detail (Statistics Finland)
├── www/
│   └── finland_flag.webp        # Finland flag used in the dashboard header and browser tab icon
└── README.md
```

---

## Data Sources

| Dataset | Source | Period | Key variable |
|---|---|---|---|
| `life_tables.csv` | Statistics Finland (table 12ap) | 2000–2024 | Probability of death per mille (q_x); survivors (l_x) |
| `beds.csv` | Our World in Data | 2000–2023 | Hospital beds per 1 000 people (source unit; multiplied by 100 in `global.R` to give per 100 000) |
| `cancer.csv` | Our World in Data | 2000–2021 | Death rate from malignant neoplasms per 100 000 |
| `DeathRate.csv` | Statistics Finland (table 11ay) | 1971–2024 | Age-standardised death rate by cause of death, whole population per 100 000 |
| `CrudeBirthRate.csv` | Statistics Finland | 2000–2024 | Total live births per year |
| `StillBirths.csv` | Statistics Finland | 2000–2024 | Stillbirth counts (used to derive stillbirth rate per 1 000 births) |

All Statistics Finland CSVs are ingested with `readr::read_csv(skip = 2)` to skip the title row and blank line before the column headers. All datasets are filtered to **Finland** where applicable in `global.R`.

**Note**: cancer data ends in 2021 and hospital-beds data ends in 2023; the merged analytical dataset covers 2000–2021 (inner join of all three sources).

### Official Citations

1. Statistics Finland. *Life table by age and sex, 1986–2024.* <https://pxdata.stat.fi/PxWeb/pxweb/en/StatFin/StatFin__kuol/statfin_kuol_pxt_12ap.px/>. Accessed 2026.
2. Our World in Data. *Hospital beds (per 1 000 people).* <https://ourworldindata.org/grapher/hospital-beds-per-1000-people>. Accessed 2026.
3. Our World in Data. *Death rate from cancer.* <https://ourworldindata.org/grapher/death-rate-from-cancer>. Accessed 2026.
4. Statistics Finland. *Deaths, age-standardised and crude death rates by cause of death and sex, 1971–2024 (table 11ay).* <https://stat.fi/til/ksyyt/index_en.html>. Accessed 2026.
5. Statistics Finland. *Statistical Databases.* <https://stat.fi/en/services/statistical-data-services/statistical-databases>. Accessed 2026.

---

## Dashboard Tabs

### 1. Home
Project overview and research questions. Three dynamic value boxes show: percentage change in the death rate since 2000, cancer's share of all deaths in the latest available year, and the direction of hospital bed capacity since 2000. Static info boxes display the data coverage years for each dataset. Official data citations are listed at the bottom of the page.

### 2. Demography
- **q_x chart**: interactive Plotly line chart of age-specific probability of death (per mille). Year slider (2000–2024) supports animation; sex filter (Both / Male / Female); optional log-scale y-axis.
- **Risk comparison box**: male-vs-female Relative Risk (RR) and Odds Ratio (OR) at a user-selected age.
- **Population pyramid**: stationary pyramid derived from life-table survivor counts (l_x), linked to the year slider.
- **Live births**: total live births per year (2000–2024) with trend line.
- **Stillbirth rate**: stillbirths per 1 000 births (2000–2024).
- **Demographic transition interpretation**: narrative context on Finland's aging population and declining birth cohorts.

### 3. Mortality & Disease
- **All-cause death rate time series**: age-standardised death rate per 100 000 (2000–2024) with LOESS trend overlay and three summary value boxes (latest rate, period average, percentage change).
- **Year-on-year rate of change**: bar chart highlighting years of improvement vs. deterioration.
- **Cancer mortality trend**: cancer deaths per 100 000 (2000–2021).
- **Cause-specific stacked area chart**: eight cause groups (Infectious Diseases, Malignant Neoplasms, Endocrine/Metabolic, Dementia/Alzheimer, Circulatory Diseases, Respiratory Diseases, Alcohol-Related, Accidents & Violence) showing absolute deaths over time.
- **Cancer share of total deaths**: percentage of all deaths attributable to malignant neoplasms.
- **Indexed mortality comparison**: overall vs. cancer mortality normalised to a 2000 baseline (index = 100).

### 4. Epidemiology & Models
Uses a merged dataset (inner join of beds, cancer, and death-rate data, 2000–2021) for ecological analysis. Includes an ecological-fallacy disclaimer.

- **Hospital beds per 100 000**: trend chart with selectable None / Loess / Linear smoothing.
- **Multivariate linear regression**: `death_rate ~ beds_per_100k + deaths_per_100k + year` — coefficient table with standard errors and p-values, R² display, and regression scatter plot.
- **Correlation matrix heatmap**: Pearson r between hospital beds, cancer mortality, and overall death rate.
- **Logistic regression**: binary outcome (death rate ≥ 75th percentile) predicted by beds and cancer deaths — coefficient table with odds ratios, plus interactive sliders to obtain the predicted probability for any combination of predictor values.
- **Lag analysis**: scatter plot of the prior year's bed capacity (`beds_lag1`) against the current year's death rate, testing for a delayed healthcare effect.

### 5. Screening Calculator
Interactive Bayesian PPV tool:
- Sliders for sensitivity (%) and specificity (%).
- Numeric input for prevalence (pre-filled with the Finland 2021 all-cancer baseline ≈ 3 168 per 100 000).
- Outputs: **PPV**, **NPV**, **prevalence used**, **LR+**, and **LR−** (value boxes).
- PPV/NPV sensitivity-sweep Plotly chart with the user's sensitivity highlighted.
- Dynamic LaTeX formula showing the exact calculation performed.

### 6. Theory
Mathematical and statistical background rendered with **MathJax / LaTeX**, covering:
1. Age-specific probability of death (q_x) and force-of-mortality approximation.
2. Bayesian screening metrics: PPV and NPV formulas.
3. Gompertz–Makeham mortality model.
4. Odds Ratio (OR) and Relative Risk (RR) for sex-specific mortality comparison.
5. Pearson correlation coefficient.
6. Crude Death Rate (CDR) and Cause-Specific Mortality Rate (CSMR).
7. Multivariate linear regression interpretation.
8. Logistic regression and odds ratio derivation.
9. Ecological fallacy and causation warning.

---

## Statistical Methods

### Probability of Death (q_x)
$$q_x = \frac{d_x}{l_x}$$

where $d_x$ is the number of deaths in the age interval $[x, x+1)$ and $l_x$ is the life-table radix survivors at exact age $x$ (conventionally 100 000). Values are reported in per mille (deaths per 1 000).

### Positive Predictive Value (PPV — Bayes' Theorem)
$$\text{PPV} = \frac{\text{Sensitivity} \times \text{Prevalence}}{\text{Sensitivity} \times \text{Prevalence} + (1 - \text{Specificity}) \times (1 - \text{Prevalence})}$$

### Negative Predictive Value (NPV)
$$\text{NPV} = \frac{\text{Specificity} \times (1 - \text{Prevalence})}{\text{Specificity} \times (1 - \text{Prevalence}) + (1 - \text{Sensitivity}) \times \text{Prevalence}}$$

### Likelihood Ratios
$$\text{LR+} = \frac{\text{Sensitivity}}{1 - \text{Specificity}}$$
$$\text{LR-} = \frac{1 - \text{Sensitivity}}{\text{Specificity}}$$

When specificity = 100 %, LR+ is undefined (displayed as ∞).

### Gompertz–Makeham Model
$$\mu(x) = A + B \cdot e^{cx}$$

### Multivariate Linear Regression
$$\text{death\_rate} = \beta_0 + \beta_1 \cdot \text{beds} + \beta_2 \cdot \text{cancer\_deaths} + \beta_3 \cdot \text{year} + \varepsilon$$

The year term controls for secular trends; $\beta_1$ and $\beta_2$ estimate marginal effects independent of time.

### Logistic Regression
$$\log\!\left(\frac{p}{1-p}\right) = \alpha + \beta_1 X_1 + \beta_2 X_2$$

Binary outcome: 1 if the age-standardised death rate exceeds the 75th percentile of the 2000–2021 distribution, 0 otherwise. Odds ratios are $e^{\hat{\beta}_j}$.

### Stillbirth Rate
$$\text{SBR} = \frac{\text{stillbirths}}{\text{live births} + \text{stillbirths}} \times 1000$$

---

## Installation & Running

### Prerequisites

- R ≥ 4.2
- RStudio (recommended) or any R console

### Install dependencies

```r
install.packages(c(
  "shiny",
  "shinydashboard",
  "tidyverse",
  "janitor",
  "plotly",
  "DT"
))
```

### Run the dashboard

```r
# From the project root directory:
shiny::runApp()
```

Or open any of `global.R`, `ui.R`, or `server.R` in RStudio and click **Run App**.

---

## Dependencies

| Package | Role |
|---|---|
| `shiny` | Web-app framework |
| `shinydashboard` | Dashboard layout (header, sidebar, body, boxes) |
| `tidyverse` | Data manipulation (`dplyr`, `readr`, `ggplot2`, `tidyr`, `stringr`, …) |
| `janitor` | Column-name cleaning (`clean_names()`) |
| `plotly` | Interactive charts |
| `DT` | Interactive data tables |

---

## Contributing

Pull requests are welcome. Please open an issue first to discuss significant changes.

---

## License

This project is released under the [MIT License](https://opensource.org/licenses/MIT).
