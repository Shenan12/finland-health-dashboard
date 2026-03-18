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
- **Screening decision support**: interactive Bayesian PPV / NPV calculator using Finland's real cancer prevalence.

The project follows a standard modular R Shiny structure (`global.R` / `ui.R` / `server.R`).

---

## Directory Structure

```
finland-health-dashboard/
├── global.R          # Package loading, data import, pre-processing
├── ui.R              # shinydashboard layout (5 tabs)
├── server.R          # Reactive logic, Plotly charts, PPV calculator
├── data/
│   ├── life_tables.csv   # Age-sex-year mortality (Human Mortality Database)
│   ├── beds.csv          # Hospital beds / 100 000 (OECD, 2000–2023)
│   └── cancer.csv        # Cancer deaths & prevalence (IARC/GCO, 2000–2021)
└── README.md
```

---

## Data Sources

| Dataset | Source | Period | Key variable |
|---|---|---|---|
| `life_tables.csv` | Human Mortality Database (HMD) | 2000–2024 | Probability of death per mille (q_x) |
| `beds.csv` | OECD Health Statistics | 2000–2023 | Hospital beds per 100 000 population |
| `cancer.csv` | IARC / Global Cancer Observatory | 2000–2021 | Deaths per 100 000 population; Prevalence per 100 000 |

All datasets are filtered to **Finland** in `global.R`.  
**Note**: cancer data ends in 2021 and hospital-beds data ends in 2023; both datasets are used up to their respective extents.

### Official Citations

1. Human Mortality Database. *Life tables for Finland*. <https://www.mortality.org>. Accessed 2024.  
2. OECD Health Statistics. *Hospital beds (per 1 000 population)*. <https://stats.oecd.org>. Accessed 2024.  
3. International Agency for Research on Cancer (IARC) / Global Cancer Observatory. *Cancer incidence and mortality – Finland*. <https://gco.iarc.fr>. Accessed 2024.

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

### 4. Healthcare & Epi
Side-by-side comparison of:
- **Hospital beds per 100 000** (2000–2023) — with optional Loess or linear trend overlay.
- **Cancer mortality rate per 100 000** (2000–2021) — selectable cancer type (All, Lung, Breast, Colorectal, Prostate).

### 5. Screening Calculator
Interactive Bayesian PPV tool:
- Sliders for sensitivity (%) and specificity (%).
- Numeric input for prevalence (pre-filled with Finland 2021 all-cancer estimate).
- Outputs: **PPV**, **NPV**, and the prevalence used (valueBoxes).
- PPV/NPV sensitivity-sweep Plotly chart with the user's sensitivity highlighted.
- LaTeX formula display showing the exact calculation performed.

---

## Statistical Methods

### Probability of Death (q_x)
$$q_x = \frac{d_x}{l_x}$$

where $d_x$ is the number of deaths in the age interval $[x, x+1)$ and $l_x$ is the life-table radix survivors at exact age $x$ (conventionally 100 000). Values are reported in per mille (deaths per 1 000).

### Positive Predictive Value (PPV — Bayes' Theorem)
$$\text{PPV} = \frac{\text{Sensitivity} \times \text{Prevalence}}{\text{Sensitivity} \times \text{Prevalence} + (1 - \text{Specificity}) \times (1 - \text{Prevalence})}$$

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
