# =============================================================================
# ui.R - Dashboard layout for Finland Health Dashboard
# =============================================================================

ui <- dashboardPage(
  title = "Finland Health Dashboard",
  skin = "blue",
  
  # -- Header --------------------------------------------------------------
  dashboardHeader(
    title = tags$span(
      tags$img(
        src   = "finland_flag.webp",
        alt   = "Finland flag",
        style = "margin-right:6px; vertical-align:middle; width:23px;"
      ),
      "Finland Health Dashboard"
    ),
    titleWidth = 300
  ),
  
  # -- Sidebar --------------------------------------------------------------
  dashboardSidebar(
    width = 230,
    sidebarMenu(
      id = "sidebar",
      menuItem("Home",                     tabName = "home",              icon = icon("house")),
      menuItem("Demography",               tabName = "demography",        icon = icon("chart-line")),
      menuItem("Mortality & Disease",      tabName = "mortality_disease", icon = icon("heartbeat")),
      menuItem("Epidemiology & Models",    tabName = "epi_models",        icon = icon("hospital")),
      menuItem("Screening Calculator",     tabName = "screening",         icon = icon("calculator")),
      menuItem("Theory",                   tabName = "theory",            icon = icon("flask"))
    )
  ),
  
  # -- Body ------------------------------------------------------------------
  dashboardBody(
    
    # 1. Load MathJax globally before any UI elements
    withMathJax(),
    
    # 2. Custom CSS and JavaScript
    tags$head(
      tags$link(rel = "shortcut icon", href = "finland_flag.webp"),
      tags$style(HTML("
        /* ---- Modern base ---- */
        .content-wrapper, .right-side {
          background-color: #f8f9fa;
        }
        .skin-blue .main-header .logo,
        .skin-blue .main-header .navbar {
          background-color: #1a3a5c;
        }
        .skin-blue .main-sidebar {
          background-color: #1e2d3d;
        }
        .skin-blue .sidebar-menu > li.active > a,
        .skin-blue .sidebar-menu > li:hover > a {
          background-color: #2c4a6e;
          border-left-color: #4fa3e0;
        }
        /* ---- Boxes ---- */
        .box {
          border-top: 3px solid #3c8dbc;
          border-radius: 10px;
          box-shadow: 0 2px 8px rgba(0,0,0,.08);
        }
        .box.box-primary  { border-top-color: #3c8dbc; }
        .box.box-success  { border-top-color: #00a65a; }
        .box.box-danger   { border-top-color: #dd4b39; }
        .box.box-warning  { border-top-color: #f39c12; }
        .box.box-info     { border-top-color: #00c0ef; }
        .box-header .box-title { font-size: 1.05em; font-weight: 600; }
        /* ---- Value / info boxes ---- */
        .small-box { border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,.1); }
        .info-box  { border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,.08); }
        .info-box-icon { font-size: 2em; }
        /* Equal-height value boxes */
        #shiny-tab-screening .small-box,
        #shiny-tab-mortality-disease .small-box { min-height: 120px !important; }
        /* Subtitle wrapping */
        .small-box .inner p { white-space: normal !important; word-wrap: break-word; }
        /* ---- Section sub-headers ---- */
        .section-header {
          font-size: 1.1em;
          font-weight: 700;
          color: #1a3a5c;
          margin: 18px 0 10px 0;
          padding-bottom: 5px;
          border-bottom: 2px solid #dee2e6;
        }
        /* ---- Equation / citation boxes ---- */
        .equation-box {
          background: #fff;
          border-left: 4px solid #3c8dbc;
          padding: 18px 24px;
          margin-bottom: 20px;
          border-radius: 8px;
          box-shadow: 0 1px 4px rgba(0,0,0,.07);
        }
        .citation-box {
          background: #eaf4fb;
          border-left: 4px solid #1a6496;
          padding: 12px 18px;
          margin-top: 16px;
          border-radius: 8px;
          font-size: 0.92em;
        }
        /* ---- Interpretation text ---- */
        .interp-text {
          background: #f0f4f8;
          border-left: 3px solid #6c8ebf;
          padding: 8px 14px;
          margin-top: 10px;
          border-radius: 6px;
          font-size: 0.88em;
          color: #3a4a5c;
        }
        /* ---- Regression table ---- */
        .reg-table { width: 100%; border-collapse: collapse; font-size: 0.9em; }
        .reg-table th { background: #1a3a5c; color: #fff; padding: 8px 12px; }
        .reg-table td { padding: 7px 12px; border-bottom: 1px solid #e0e0e0; }
        .reg-table tr:hover td { background: #f0f4f8; }
        /* ---- Responsive spacing ---- */
        .tab-content > .tab-pane { padding-bottom: 30px; }
      ")),
      
      # Bulletproof MathJax listeners with a slight delay to allow UI rendering first
      tags$script(HTML("
        $(document).ready(function() {
          // Re-render when switching tabs
          $(document).on('shown.bs.tab', 'a[data-toggle=\"tab\"]', function (e) {
            if (window.MathJax) {
              setTimeout(function() { MathJax.Hub.Queue(['Typeset', MathJax.Hub]); }, 100);
            }
          });
          // Re-render when Shiny updates the dynamic formula in Tab 5
          $(document).on('shiny:value', function(event) {
            if (window.MathJax && event.name === 'ppv_formula_display') {
              setTimeout(function() { MathJax.Hub.Queue(['Typeset', MathJax.Hub]); }, 100);
            }
          });
        });
      "))
    ),
    
    tabItems(
      
      # =========================================================
      # TAB 1: Home
      # =========================================================
      tabItem(
        tabName = "home",
        fluidRow(
          box(
            width = 12, status = "primary", solidHeader = TRUE,
            title = "Finland Health Trends Dashboard (2000-2024)",
            p(
              "This dashboard provides an interactive analysis of key public-health ",
              "indicators in ", tags$strong("Finland"), " over the period ",
              tags$strong("2000-2024"), ". It combines official data sources to ",
              "visualise demographic mortality patterns, hospital bed capacity, cancer ",
              "burden, and to support evidence-based screening decisions."
            ),
            p("Use the sidebar to navigate the six analytical sections:"),
            tags$ul(
              tags$li(tags$strong("Home"),                  " - project overview and data citations."),
              tags$li(tags$strong("Demography"),            " - age-specific mortality, population pyramid, and birth rate trends."),
              tags$li(tags$strong("Mortality & Disease"),   " - all-cause death rates, cause-specific trends, and cancer burden."),
              tags$li(tags$strong("Epidemiology & Models"), " - hospital capacity, regression models, and lag analysis."),
              tags$li(tags$strong("Screening Calculator"),  " - Bayesian PPV tool for cancer screening."),
              tags$li(tags$strong("Theory"),                " - mathematical and statistical background.")
            )
          )
        ),

    

        # Key insight value boxes (computed dynamically in server.R)
        fluidRow(
          valueBoxOutput("home_mort_change",  width = 4),
          valueBoxOutput("home_cancer_share", width = 4),
          valueBoxOutput("home_beds_trend",   width = 4)
        ),

        # Data coverage info boxes
        fluidRow(
          infoBox("Life Table Years",   "2000 - 2024", icon = icon("calendar"),  color = "blue",   width = 3),
          infoBox("Hospital Bed Years", "2000 - 2023", icon = icon("bed"),       color = "green",  width = 3),
          infoBox("Cancer Data Years",  "2000 - 2021", icon = icon("ribbon"),    color = "red",    width = 3),
          infoBox("Death Rate Years",   "2000 - 2024", icon = icon("chart-bar"), color = "purple", width = 3)
        ),

        # Data citations (unchanged)
        fluidRow(
          box(
            width = 12, title = "Official Data Citations", status = "info",
            div(class = "citation-box",
                tags$ol(
                  tags$li(
                    "Statistics Finland. ",
                    tags$em("Life table by age and sex, 1986-2024."), " ",
                    tags$a("https://pxdata.stat.fi/PxWeb/pxweb/en/StatFin/StatFin__kuol/statfin_kuol_pxt_12ap.px/",
                           href = "https://pxdata.stat.fi/PxWeb/pxweb/en/StatFin/StatFin__kuol/statfin_kuol_pxt_12ap.px/",
                           target = "_blank"),
                    ". Accessed 2026."
                  ),
                  tags$li(
                    "Our World in Data. ",
                    tags$em("Hospital beds (per 1,000 people)."), " ",
                    tags$a("https://ourworldindata.org/grapher/hospital-beds-per-1000-people",
                           href = "https://ourworldindata.org/grapher/hospital-beds-per-1000-people",
                           target = "_blank"),
                    ". Accessed 2026."
                  ),
                  tags$li(
                    "Our World in Data. ",
                    tags$em("Death rate from cancer."), " ",
                    tags$a("https://ourworldindata.org/grapher/death-rate-from-cancer",
                           href = "https://ourworldindata.org/grapher/death-rate-from-cancer",
                           target = "_blank"),
                    ". Accessed 2026."
                  ),
                  tags$li(
                    "Statistics Finland. ",
                    tags$em("Deaths, age-standardised and crude death rates by cause of death and sex, 1971-2024 (table 11ay)."), " ",
                    tags$a("https://stat.fi/til/ksyyt/index_en.html",
                           href = "https://stat.fi/til/ksyyt/index_en.html",
                           target = "_blank"),
                    ". Accessed 2026."
                  ),
                  tags$li(
                    "Statistics Finland. ",
                    tags$em("Statistical Databases."), " ",
                    tags$a("https://stat.fi/en/services/statistical-data-services/statistical-databases",
                           href = "https://stat.fi/en/services/statistical-data-services/statistical-databases",
                           target = "_blank"),
                    ". Accessed 2026."
                  )
                )
            )
          )
        )
      ),

      # =========================================================
      # TAB 2: Demography
      # =========================================================
      tabItem(
        tabName = "demography",
        fluidRow(
          box(
            width = 12, status = "primary", solidHeader = TRUE,
            title = "Age-Specific Probability of Death (Life Table Analysis)",
            p(
              "Interactive chart of \\( q_x \\) (per mille) by age. ",
              "These are age-specific mortality probabilities derived from life tables, ",
              "allowing comparison independent of population structure.",
              "Use the year slider to animate change across ", strong("2000-2024"), ". ",
              "Toggle between males, females, or both using the filter below."
            )
          )
        ),
        fluidRow(
          box(
            width = 3, status = "info", title = "Controls",
            sliderInput(
              "demo_year", "Select Year:",
              min = 2000, max = 2024, value = 2000, step = 1,
              sep = "", animate = animationOptions(interval = 600, loop = FALSE)
            ),
            sliderInput(
              "demo_age", "Select Age for Risk:",
              min = 0, max = 100, value = 60, step = 1
            ),
            radioButtons(
              "demo_sex", "Sex:",
              choices  = c("Both", "Male", "Female"),
              selected = "Both",
              inline   = FALSE
            ),
            checkboxInput("demo_log", "Log-scale Y-axis", value = FALSE),
            hr(),
            helpText(
              "Click the play button (\u25B6) on the year slider to animate mortality ",
              "improvement over time."
            )
          ),
          box(
            width = 9, status = "primary", title = "q\u2093 (Per Mile) by Age",
            plotlyOutput("demo_plot", height = "450px")
          )
        ),
        fluidRow(
          valueBoxOutput("risk_box", width = 6)
        ),
        fluidRow(
          box(
            width = 12, status = "primary",
            title = "Stationary Population Structure (Linked to Year Slider Above)",
            p("This plot updates with the year selected in the mortality chart above."),
            plotlyOutput("pyramid_plot", height = "400px")
          )
        ),

        # Birth Rate section
        fluidRow(
          box(
            width = 6, status = "success",
            title = "Total Live Births per Year",
            plotlyOutput("birth_rate_plot", height = "350px"),
            div(class = "interp-text",
                "Live births in Finland have declined sharply from ~58,000 in 2000 to under 45,000 by the early 2020s, reflecting demographic transition and changing societal patterns."
            )
          ),
          box(
            width = 6, status = "warning",
            title = "Stillbirth Rate per 1 000 Births",
            plotlyOutput("stillbirth_plot", height = "350px"),
            div(class = "interp-text",
                "The stillbirth rate has remained relatively stable around 4-5 per 1 000 births, reflecting sustained quality of perinatal care."
            )
          )
        ),

        # Demographic Transition Interpretation
        fluidRow(
          box(
            width = 12, status = "info",
            title = "Demographic Transition Interpretation",
            p(
              "Finland is experiencing a classic late-stage ", tags$strong("demographic transition"),
              ": declining birth rates signal that societal, economic, and healthcare factors are",
              " now primary drivers of family size decisions rather than survival necessity."
            ),
            p(
              "The resulting ", tags$strong("aging population"), " places growing pressure on",
              " healthcare systems, pension funds, and social services, as the ratio of working-age",
              " individuals to retirees continues to shrink."
            ),
            p(
              "Smaller birth cohorts entering the workforce each year will further constrain",
              " economic productivity and tax revenues, making long-term sustainability planning",
              " a critical policy priority."
            )
          )
        )
      ),

      # =========================================================
      # TAB 3: Mortality & Disease
      # =========================================================
      tabItem(
        tabName = "mortality_disease",
        fluidRow(
          box(
            width = 12, status = "primary", solidHeader = TRUE,
            title = "All-Cause Mortality & Disease Burden: Finland 2000-2024",
            p(
              "Analysis of Finland's age-standardised all-cause death rate ",
              "(per 100 000 population) from Statistics Finland, with cause-specific ",
              "breakdowns and cancer burden analysis. Data covers 2000-2024."
            )
          )
        ),

        # Summary value boxes
        fluidRow(
          valueBoxOutput("mort_latest_box",  width = 4),
          valueBoxOutput("mort_avg_box",     width = 4),
          valueBoxOutput("mort_change_box",  width = 4)
        ),

        # Death rate time series
        fluidRow(
          box(
            width = 12, status = "primary",
            title = tags$span(icon("chart-line"), " Death Rate Over Time (with LOESS Trend)"),
            plotlyOutput("mort_ts_plot", height = "400px"),
            div(class = "interp-text",
                tags$strong("Interpretation: "),
                "Finland's age-standardised death rate has generally declined since 2000, ",
                "reflecting improvements in healthcare, lifestyle, and public health policy. ",
                "The dashed LOESS curve highlights the long-term downward trend.",
                " A sharp uptick is visible around 2022, likely related to excess ",
                "COVID-19 mortality."
            )
          )
        ),

        # Rate of change + cancer mortality
        fluidRow(
          box(
            width = 6, status = "warning",
            title = tags$span(icon("exchange-alt"), " Year-on-Year % Change in Death Rate"),
            plotlyOutput("mort_roc_plot", height = "380px"),
            div(class = "interp-text",
                tags$strong("Interpretation: "),
                "Positive values indicate years where mortality increased relative to the ",
                "previous year; negative values indicate improvement. ",
                "Large positive spikes may correspond to severe influenza seasons, ",
                "cold winters, or pandemic years."
            )
          ),
          box(
            width = 6, status = "danger",
            title = tags$span(icon("ribbon"), " Cancer Mortality Rate per 100 000 Population"),
            div(style = "height: 10px;"),
            plotlyOutput("cancer_plot", height = "380px"),
            div(class = "interp-text",
                tags$strong("Interpretation: "),
                "Cancer mortality has shown an increasing trend over the period 2000-2021, ",
                "consistent with improvements in early and precise detection, and aging population."
            )
          )
        ),

        # Cause-specific stacked area
        fluidRow(
          box(
            width = 12, status = "info",
            title = "Cause-Specific Mortality: Stacked Area Chart",
            plotlyOutput("cause_area_plot", height = "420px"),
            div(class = "interp-text",
                tags$strong("Interpretation: "),
                "Finland's disease burden has shifted markedly over decades from ",
                "infectious and acute conditions toward chronic diseases such as ",
                "cardiovascular disease and cancer. This epidemiological transition ",
                "reflects rising life expectancy and changing risk factor profiles."
            )
          )
        ),

        # Tumour share + comparative
        fluidRow(
          box(
            width = 6, status = "danger",
            title = "Cancer as Share of Total Deaths",
            plotlyOutput("tumour_share_plot", height = "350px"),
            div(class = "interp-text",
                tags$strong("Interpretation: "),
                "Cancer's share of total deaths reflects both improvements in competing ",
                "causes (e.g. cardiovascular disease declining faster) and the slowly ",
                "changing cancer burden. A rising share may indicate relative success in ",
                "reducing other causes rather than an increase in absolute cancer deaths."
            )
          ),
          box(
            width = 6, status = "danger",
            title = tags$span(icon("balance-scale"), " Overall vs Cancer Mortality (2000-2021)"),
            plotlyOutput("mort_compare_plot", height = "350px"),
            div(class = "interp-text",
                tags$strong("Interpretation: "),
                "Both series are normalised to their 2000 baseline (index = 100) to allow ",
                "direct comparison of relative decline. Cancer mortality has changed relative to baseline, allowing comparison of trends over time."
            )
          )
        )
      ),

      # =========================================================
      # TAB 4: Epidemiology & Models
      # =========================================================
      tabItem(
        tabName = "epi_models",
        fluidRow(
          box(
            width = 12, status = "primary", solidHeader = TRUE,
            title = "Epidemiological Trends: Healthcare Capacity & Regression Models",
            p(
              "Side-by-side comparison of ", strong("hospital bed capacity"),
              " (2000-2023) and advanced regression models examining relationships ",
              "between healthcare capacity, cancer burden, and overall mortality."
            )
          )
        ),

        # Ecological limitation warning
        fluidRow(
          box(
            width = 12, status = "danger",
            title = tags$span(icon("exclamation-triangle"), " Ecological Study Limitation"),
            div(class = "interp-text",
                tags$strong("Ecological Study Limitation: "),
                "All analyses in this section use aggregate yearly data, not individual patient data. ",
                "This is an ecological study design. Associations observed here may reflect ",
                "confounding by time trends (secular trends), and ",
                tags$strong("cannot establish causation.")
            )
          )
        ),

        # Hospital beds
        fluidRow(
          box(
            width = 12, status = "success",
            title = "Hospital Beds per 100 000 Population",
            selectInput(
              "beds_smooth", "Trend line:",
              choices  = c("None", "Loess", "Linear"),
              selected = "Loess"
            ),
            plotlyOutput("beds_plot", height = "380px"),
            div(class = "interp-text",
                tags$strong("Interpretation: "),
                "Hospital bed capacity in Finland has declined steadily since 2000, "
              
            )
          )
        ),

        # Advanced section header
        fluidRow(
          box(
            width = 12, status = "primary", solidHeader = TRUE,
            title = "Advanced Epidemiology: Multivariate Regression & Lag Analysis",
            p(
              "Using the merged dataset (2000-2021, inner join of all three sources) to examine ",
              "relationships between hospital capacity, cancer burden, and overall mortality."
            )
          )
        ),

        # Multivariate regression
        fluidRow(
          box(
            width = 6, status = "primary",
            title = tags$span(icon("chart-line"), " Multivariate Linear Regression"),
            tags$h4("Model: death_rate ~ beds_per_100k + deaths_per_100k + year",
                    class = "section-header"),
            tableOutput("lm_coef_table"),
            br(),
            uiOutput("lm_r2_display"),
            div(class = "interp-text",
                tags$strong("Interpretation: "),
                "The model estimates how much the overall (age-standardised) ",
                "death rate changes with each unit change in hospital bed capacity ",
                "and cancer mortality, holding the other predictors constant. ",
                "The year term captures the underlying time trend (secular change) ",
                "independent of beds or cancer mortality."
            )
          ),
          box(
            width = 6, status = "primary",
            title = tags$span(icon("circle"), " Regression Scatter: Beds vs Overall Mortality"),
            plotlyOutput("reg_scatter", height = "380px"),
            div(class = "interp-text",
                tags$strong("Interpretation: "),
                "Each point represents one year (2000-2021). Colour intensity ",
                "indicates cancer mortality level. The regression line ",
                "shows the marginal association between bed capacity and overall death rate."
            )
          )
        ),

        # Correlation matrix
        fluidRow(
          box(
            width = 12, status = "info",
            title = tags$span(icon("th"), " Correlation Matrix: Beds, Cancer Mortality, Overall Death Rate"),
            plotlyOutput("corr_heatmap", height = "380px"),
            div(class = "interp-text",
                tags$strong("Interpretation: "),
                "Pearson correlation coefficients (r) between the three key indicators. ",
                "Values close to \u00b11 indicate a strong linear association. ",
                "This ecological analysis does not establish causation but highlights ",
                "co-movement patterns over time."
            )
          )
        ),

        # Logistic regression
        fluidRow(
          box(
            width = 6, status = "warning",
            title = tags$span(icon("percent"), " Logistic Regression: Predictors of High Mortality"),
            p("Binary outcome: 1 if death rate is in the top 25% (above 75th percentile), 0 otherwise."),
            tableOutput("glm_coef_table"),
            br(),
            div(class = "interp-text",
                tags$strong("Interpretation: "),
                "Odds ratios (OR) greater than 1 indicate that higher values of the ",
                "predictor are associated with increased odds of a high-mortality year. ",
                "An OR < 1 for beds suggests more bed capacity is associated with lower ",
                "odds of the mortality rate being in the highest quartile (above the 75th percentile)."
            )
          ),
          box(
            width = 6, status = "warning",
            title = tags$span(icon("sliders-h"), " Predicted Probability of High Mortality"),
            p("Adjust predictors to see the logistic model's predicted probability."),
            fluidRow(
              column(6,
                sliderInput("glm_beds", "Beds per 100k:",
                            min = 250, max = 800, value = 450, step = 10)
              ),
              column(6,
                sliderInput("glm_cancer", "Cancer Deaths per 100k:",
                            min = 180, max = 280, value = 220, step = 2)
              )
            ),
            valueBoxOutput("glm_prob_box", width = 12),
            div(class = "interp-text",
                tags$strong("How to read: "),
                "The predicted probability (0-100%) reflects the logistic model's ",
                "estimate that a year with these indicator values would have a ",
                "death rate above the 75th percentile (top 25% of historical years)."
            )
          )
        ),

        # Lag analysis
        fluidRow(
          box(
            width = 12, status = "success",
            title = tags$span(icon("clock"), " Lag Analysis: Delayed Effect of Hospital Bed Capacity"),
            p(
              "Hospital bed investment does not translate immediately into mortality reductions. ",
              "The plot below examines whether the previous year's bed capacity ",
              "(", tags$code("beds_lag1"), ") predicts the current year's overall death rate."
            ),
            plotlyOutput("lag_plot", height = "380px"),
            div(class = "interp-text",
                tags$strong("Interpretation: "),
                "Each point represents a year from 2001 to 2021. The x-axis shows hospital ",
                "bed capacity in the preceding year. A downward trend suggests that higher ",
                "bed capacity one year earlier is associated with a lower death rate the ",
                "following year — consistent with a delayed healthcare effect hypothesis."
            )
          )
        )
      ),

      # =========================================================
      # TAB 5: Screening Calculator
      # =========================================================
      tabItem(
        tabName = "screening",
        fluidRow(
          box(
            width = 12, status = "primary", solidHeader = TRUE,
            title = "Bayesian Positive Predictive Value (PPV) Calculator",
            p(
              "Calculate the PPV of a cancer screening test for Finland using Bayes' Theorem. ",
              "The prevalence field is pre-filled with a baseline estimate for Finland. ",
              "Adjust the parameters to evaluate different screening scenarios."
            ),
            p(
              tags$strong("Key Insight: "),
              "Even highly accurate tests can produce many false positives when disease prevalence is low, ",
              "highlighting the importance of targeted screening."
            )
          )
        ),
        fluidRow(
          box(
            width = 4, status = "info",
            title = "Input Parameters",
            sliderInput(
              "ppv_sensitivity", "Sensitivity (%):",
              min = 1, max = 100, value = 85, step = 1
            ),
            sliderInput(
              "ppv_specificity", "Specificity (%):",
              min = 1, max = 100, value = 90, step = 1
            ),
            numericInput(
              "ppv_prevalence",
              "Cancer Prevalence (per 100 000):",
              value  = 3168,
              min    = 1,
              max    = 10000,
              step   = 1
            ),
            actionButton("ppv_calc", "Calculate PPV", class = "btn-primary btn-block"),
            hr(),
            helpText(
              "Pre-filled prevalence is an assumed baseline estimate for demonstration. ",
              "Adjust to explore other scenarios."
            )
          ),
          box(
            width = 8, status = "success",
            title = "Results",
            fluidRow(
              valueBoxOutput("ppv_result",  width = 4),
              valueBoxOutput("npv_result",  width = 4),
              valueBoxOutput("prev_result", width = 4)
            ),
            fluidRow(
              valueBoxOutput("lr_pos_box",  width = 6),
              valueBoxOutput("lr_neg_box",  width = 6)
            ),
            hr(),
            plotlyOutput("ppv_plot", height = "320px"),
            hr(),
            uiOutput("ppv_formula_display"),
            uiOutput("ppv_interpretation")
          )
        )
      ),

      # =========================================================
      # TAB 6: Theory
      # =========================================================
      tabItem(
        tabName = "theory",
        fluidRow(
          box(
            width = 12, status = "primary", solidHeader = TRUE,
            title = "Mathematical Framework",
            p(
              "The statistical foundations used throughout this dashboard are ",
              "presented below. Equations are rendered using LaTeX notation via MathJax."
            )
          )
        ),
        fluidRow(
          # --- 1. Life Table / qx
          box(
            width = 6, status = "info",
            title = "1. Age-specific Probability of Death \\( q_x \\)",
            div(
              class = "equation-box",
              p(tags$strong("Definition:")),
              p(
                "The age-specific probability of death \\( q_x \\) represents the probability that an individual aged exactly \\( x \\) will die before reaching age \\( x+1 \\)."
              ),
              p("Formula:"),
              p("$$q_x = \\frac{d_x}{l_x}$$"),
              tags$ul(
                tags$li("\\( d_x \\) - number of deaths between ages \\( x \\) and \\( x+1 \\)"),
                tags$li("\\( l_x \\) - number of survivors reaching age \\( x \\) (radix = 100,000)")
              ),
              p("Force-of-mortality approximation:"),
              p("$$q_x \\approx 1 - e^{-\\mu_x}$$"),
              p("where \\( \\mu_x \\) is the hazard rate (force of mortality) at age \\( x \\).")
            )
          ),
          # --- 2. Screening / PPV
          box(
            width = 6, status = "success",
            title = "2. Bayesian Screening Metrics",
            div(
              class = "equation-box",
              p(tags$strong("Positive Predictive Value (PPV)")),
              p(
                "PPV quantifies the probability that a positive test result correctly identifies disease. ",
                "It depends on test characteristics and disease prevalence."
              ),
              p("Formula:"),
              p("$$\\text{PPV} = \\frac{\\text{Sensitivity} \\times \\text{Prevalence}}{\\text{Sensitivity} \\times \\text{Prevalence} + (1 - \\text{Specificity}) \\times (1 - \\text{Prevalence})}$$"),
              p("Complementary metric - Negative Predictive Value (NPV):"),
              p("$$\\text{NPV} = \\frac{\\text{Specificity} \\times (1 - \\text{Prevalence})}{\\text{Specificity} \\times (1 - \\text{Prevalence}) + (1 - \\text{Sensitivity}) \\times \\text{Prevalence}}$$"),
              p("Likelihood Ratios:"),
              p("$$LR^+ = \\frac{\\text{Sensitivity}}{1 - \\text{Specificity}}$$"),
              p("$$LR^- = \\frac{1 - \\text{Sensitivity}}{\\text{Specificity}}$$"),
              tags$ul(
                tags$li("\\( P(T^+|D^+) \\) - sensitivity"),
                tags$li("\\( P(T^-|D^-) \\) - specificity"),
                tags$li("\\( P(D^+) \\) - disease prevalence")
              ),
              p(
                "These metrics are essential for evaluating the effectiveness of screening programs, especially when disease prevalence is low."
              )
            )
          )
        ),
        # --- 3. Gompertz-Makeham
        fluidRow(
          box(
            width = 12, status = "warning",
            title = "3. Gompertz-Makeham Mortality Model",
            div(
              class = "equation-box",
              p(
                "The Gompertz-Makeham law models the exponential rise of mortality with age, separating age-independent and age-dependent hazards:"
              ),
              p("$$\\mu(x) = A + B e^{c x}$$"),
              tags$ul(
                tags$li("\\( A \\) - background hazard (age-independent)"),
                tags$li("\\( B, c \\) - parameters governing age-dependent mortality")
              ),
              p("Estimates for Finland suggest \\( c \\approx 0.09 \\) for both sexes.")
            )
          )
        ),
        # --- 4. OR & RR + 5. Correlation
        fluidRow(
          box(
            width = 6, status = "primary",
            title = "4. Odds Ratio (OR) & Relative Risk (RR)",
            div(
              class = "equation-box",
              p("These metrics compare mortality between males and females at a given age."),
              p("Relative Risk (RR):"),
              p("$$RR = \\frac{P_{male}}{P_{female}}$$"),
              p("Odds Ratio (OR):"),
              p("$$OR = \\frac{P_{male} / (1-P_{male})}{P_{female} / (1-P_{female})}$$"),
              p(
                "Where \\( P_{male} \\) and \\( P_{female} \\) are the probabilities of death for males and females respectively. ",
                "These provide insight into sex-specific risk differences."
              )
            )
          ),
          box(
            width = 6, status = "primary",
            title = "5. Correlation Analysis",
            div(
              class = "equation-box",
              p(
                "To examine the association between healthcare capacity and cancer mortality, we compute the Pearson correlation coefficient:"
              ),
              p("$$r = \\frac{\\sum (x_i - \\bar{x})(y_i - \\bar{y})}{\\sqrt{\\sum (x_i - \\bar{x})^2 \\sum (y_i - \\bar{y})^2}}$$"),
              p(
                "A strong correlation does not imply causation; trends may be influenced by confounding factors such as population aging and healthcare improvements."
              )
            )
          )
        ),
        # --- 6. Mortality Measures
        fluidRow(
          box(
            width = 12, status = "primary",
            title = "6. Mortality Measures in Epidemiology",
            div(
              class = "equation-box",
              p(tags$strong("Crude Death Rate (CDR):")),
              p("$$\\text{CDR} = \\frac{\\text{Deaths (all causes)}}{\\text{Mid-year population}} \\times 100{,}000$$"),
              p("Reflects total mortality burden but is affected by age structure."),
              p(tags$strong("Cause-Specific Mortality Rate (CSMR):")),
              p("$$\\text{CSMR} = \\frac{\\text{Deaths from cause } c}{\\text{Mid-year population}} \\times 100{,}000$$"),
              p("Isolates the contribution of a specific cause to overall mortality.")
            )
          )
        ),
        # --- 7. Linear Regression + 8. Logistic Regression
        fluidRow(
          box(
            width = 6, status = "success",
            title = "7. Linear Regression Interpretation",
            div(
              class = "equation-box",
              p(tags$strong("Model structure:")),
              p("$$\\text{death\\_rate} = \\beta_0 + \\beta_1 \\cdot \\text{beds} + \\beta_2 \\cdot \\text{cancer\\_deaths} + \\beta_3 \\cdot \\text{year} + \\varepsilon$$"),
              p("\\( \\beta_1 \\): Change in death rate per additional bed per 100k, holding year and cancer deaths constant."),
              p("\\( \\beta_3 \\): Captures underlying time trend (secular change) independent of beds or cancer.")
            )
          ),
          box(
            width = 6, status = "warning",
            title = "8. Logistic Regression & Odds Ratio",
            div(
              class = "equation-box",
              p(tags$strong("Log-odds model:")),
              p("$$\\log\\left(\\frac{p}{1-p}\\right) = \\alpha + \\beta_1 X_1 + \\beta_2 X_2$$"),
              p("where \\(p\\) = probability that death_rate \\(\\geq\\) 75th percentile (i.e., a top-25% mortality year)."),
              p("Odds Ratio (OR):"),
              p("$$OR = e^{\\hat{\\beta}_j}$$"),
              p("OR > 1: predictor associated with increased odds of high mortality. OR < 1: associated with decreased odds.")
            )
          )
        ),
        # --- 9. Ecological Fallacy
        fluidRow(
          box(
            width = 12, status = "danger",
            title = "9. Ecological Fallacy & Causation Warning",
            div(
              class = "equation-box",
              p(tags$strong("Ecological Fallacy:")),
              p("When associations found in group-level (aggregate) data are incorrectly assumed to hold at the individual level."),
              p("This dashboard uses country-level yearly data. Correlations between hospital beds and mortality do NOT imply that individual patients with more bed access have lower mortality risk."),
              p(tags$strong("Association \u2260 Causation:")),
              p("Observed associations may arise from confounding variables, reverse causation, or shared time trends (secular trends). All findings should be interpreted with caution.")
            )
          )
        ),
        # --- 10. Age-Standardized Death Rate + 11. Stillbirth Rate
        fluidRow(
          box(
            width = 6, status = "info",
            title = "10. Age-Standardized Death Rate (Direct Method)",
            div(
              class = "equation-box",
              p("$$ADR = \\frac{\\sum E_x^{C,S} \\cdot \\hat{m}_x}{\\sum E_x^{C,S}}$$"),
              p(
                "Where \\( E_x^{C,S} \\) is the standard reference population weight for age group \\( x \\), ",
                "and \\( \\hat{m}_x \\) is the age-specific central death rate for age group \\( x \\) in the observed population."
              ),
              p(
                "Note: For this dashboard, the ADR is a pre-calculated metric provided directly by Statistics Finland, ",
                "already adjusted to a standard population to remove the confounding effect of differing age structures over time."
              )
            )
          ),
          # --- 11. Stillbirth Rate
          box(
            width = 6, status = "info",
            title = "11. Stillbirth Rate",
            div(
              class = "equation-box",
              p("$$\\text{Stillbirth Rate} = \\frac{\\text{Stillbirths}}{\\text{Live Births} + \\text{Stillbirths}} \\times 1000$$"),
              p(
                "Where \\( \\text{Stillbirths} \\) is the total number of fetal deaths at or after a specific gestational age, ",
                "and \\( \\text{Live Births} \\) is the total number of infants born alive."
              ),
              p("The denominator represents total births, ensuring that all pregnancies reaching viability are included in the population at risk.")
            )
          )
        ),
        # --- 12. PMR + 13. Relative % Change
        fluidRow(
          box(
            width = 6, status = "warning",
            title = "12. Proportionate Mortality Ratio",
            div(
              class = "equation-box",
              p("$$\\text{Proportion} = \\frac{\\text{Deaths from specific cause}}{\\text{Total deaths from all causes}} \\times 100$$"),
              p(
                "Where \\( \\text{Deaths from specific cause} \\) is the number of deaths attributed to a particular condition, ",
                "and \\( \\text{Total deaths from all causes} \\) is the absolute total of all deaths in the population during the same period."
              ),
              p("Measures the relative contribution of a specific cause of death compared to all other causes, rather than population risk.")
            )
          ),
          box(
            width = 6, status = "warning",
            title = "13. Relative Percentage Change",
            div(
              class = "equation-box",
              p("$$\\text{Change (\\%)} = \\frac{\\text{Current} - \\text{Baseline}}{\\text{Baseline}} \\times 100$$"),
              p(
                "Where \\( \\text{Current} \\) is the value of the metric in the observation period, ",
                "and \\( \\text{Baseline} \\) is the value of the metric in the reference or starting period."
              ),
              p("Used to quantify temporal changes in mortality rates, including year-on-year variation and long-term trends.")
            )
          )
        ),
        # --- 14. Index Normalization
        fluidRow(
          box(
            width = 12, status = "primary",
            title = "14. Index Normalization",
            div(
              class = "equation-box",
              p("$$\\text{Index}_t = \\frac{x_t}{x_{\\text{baseline}}} \\times 100$$"),
              p(
                "Where \\( \\text{Index}_t \\) is the normalized value at time \\( t \\), ",
                "\\( x_t \\) is the raw value of the indicator at time \\( t \\), ",
                "and \\( x_{\\text{baseline}} \\) is the raw value of the indicator during the chosen baseline period."
              ),
              p("Normalizes values to a baseline year to allow comparison of relative trends across different indicators.")
            )
          )
        )
      )

    )  # end tabItems
  )    # end dashboardBody
)      # end dashboardPage
