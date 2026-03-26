# Finland Health Dashboard

> An interactive R Shiny dashboard analysing demographic and public-health trends in **Finland (2000–2024)**, built as a professional Medical Statistics project.

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

This dashboard integrates three official Finland health datasets to deliver:

- **Demographic trends**: age-specific mortality (q_x) animated over 2000–2024.
- **Healthcare capacity**: hospital bed availability per 100 000 population.
- **Cancer burden**: cause-specific cancer mortality rates (2000–2021).
- **Screening decision support**: interactive Bayesian PPV / NPV calculator with likelihood ratios, using Finland's real cancer prevalence.

The project follows a standard modular R Shiny structure (`global.R` / `ui.R` / `server.R`).

---

## Directory Structure

```
finland-health-dashboard/
├── global.R          # Package loading, data import, pre-processing
├── ui.R              # shinydashboard layout (5 tabs)
├── server.R          # Reactive logic, Plotly charts, PPV calculator
├── data/
│   ├── life_tables.csv   # Age-sex-year mortality (Statistics Finland, 2000–2024)
│   ├── beds.csv          # Hospital beds / 100 000 (Our World in Data, 2000–2023)
│   └── cancer.csv        # Cancer deaths & prevalence (Our World in Data, 2000–2021)
└── README.md
```

---

## Data Sources

| Dataset | Source | Period | Key variable |
|---|---|---|---|
| `life_tables.csv` | Statistics Finland | 2000–2024 | Probability of death per mille (q_x) |
| `beds.csv` | Our World in Data | 2000–2023 | Hospital beds per 100 000 population |
| `cancer.csv` | Our World in Data | 2000–2021 | Deaths per 100 000 population; Prevalence per 100 000 |

All datasets are filtered to **Finland** in `global.R`.  
**Note**: cancer data ends in 2021 and hospital-beds data ends in 2023; both datasets are used up to their respective extents.

### Official Citations

1. Statistics Finland. *Life table by age and sex, 1986–2024*. <https://pxdata.stat.fi/PxWeb/pxweb/en/StatFin/StatFin__kuol/statfin_kuol_pxt_12ap.px/>. Accessed 2026.
2. Our World in Data. *Hospital beds (per 1 000 people)*. <https://ourworldindata.org/grapher/hospital-beds-per-1000-people>. Accessed 2026.
3. Our World in Data. *Death rate from cancer*. <https://ourworldindata.org/grapher/death-rate-from-cancer>. Accessed 2026.

---

## Dashboard Tabs

### 1. Home
Project overview, key summary statistics (infoBoxes for data extents), and the official data citations listed above.

### 2. Theoretical Framework
Mathematical background rendered with **MathJax / LaTeX**:
- **Probability of Death** (q_x): `q_x = d_x / l_x` and the force-of-mortality form.
- **Positive Predictive Value** (PPV): Bayes' theorem applied to a screening context.
- **Gompertz–Makeham** mortality model.

### 3. Demographics
Interactive **Plotly** line chart of age vs. q_x (per mille):
- Year slider (2000–2024) with **animation** support.
- Sex filter (Both / Male / Female).
- Optional log-scale y-axis.
- Age slider for male-vs-female mortality risk box (Relative Risk & Odds Ratio).
- Stationary population pyramid based on survivor counts (l_x).

### 4. Healthcare & Epi
Side-by-side comparison of:
- **Hospital beds per 100 000** (2000–2023) — with optional Loess or linear trend overlay.
- **Cancer mortality rate per 100 000** (2000–2021).
- Pearson correlation analysis between hospital beds and cancer mortality with scatter plot.

### 5. Screening Calculator
Interactive Bayesian PPV tool:
- Sliders for sensitivity (%) and specificity (%).
- Numeric input for prevalence (pre-filled with Finland 2021 all-cancer estimate ≈ 3 168 per 100 000).
- Outputs: **PPV**, **NPV**, **prevalence used**, **LR+**, and **LR−** (valueBoxes).
- PPV/NPV sensitivity-sweep Plotly chart with the user's sensitivity highlighted.
- LaTeX formula display showing the exact calculation performed.

---

## Statistical Methods

### Probability of Death (q_x)
$$q_x = \frac{d_x}{l_x}$$

where $d_x$ is the number of deaths in the age interval $[x, x+1)$ and $l_x$ is the life-table radix survivors at exact age $x$ (conventionally 100 000). Values are reported in per mille (deaths per 1 000).

### Cancer Prevalence
Prevalence is expressed as cases per 100 000 population. The baseline value pre-filled in the Screening Calculator is derived from the Finland 2021 all-cancer estimate in `cancer.csv`. Users may adjust this value to explore alternative screening scenarios.

### Positive Predictive Value (PPV — Bayes' Theorem)
$$\text{PPV} = \frac{\text{Sensitivity} \times \text{Prevalence}}{\text{Sensitivity} \times \text{Prevalence} + (1 - \text{Specificity}) \times (1 - \text{Prevalence})}$$

### Likelihood Ratios
$$\text{LR+} = \frac{\text{Sensitivity}}{1 - \text{Specificity}}$$
$$\text{LR-} = \frac{1 - \text{Sensitivity}}{\text{Specificity}}$$

LR+ quantifies how much more likely a positive test result is in someone with disease compared to without. LR− quantifies how much less likely a negative test result is in someone with disease. When specificity = 100%, LR+ is undefined (displayed as ∞).

### Gompertz–Makeham Model
$$\mu(x) = A + B \cdot e^{cx}$$

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
| `tidyverse` | Data manipulation (`dplyr`, `readr`, `ggplot2`, …) |
| `janitor` | Column-name cleaning (`clean_names()`) |
| `plotly` | Interactive charts |
| `DT` | Interactive data tables (optional) |

---

## Contributing

Pull requests are welcome. Please open an issue first to discuss significant changes.

---

## License

This project is released under the [MIT License](https://opensource.org/licenses/MIT).
