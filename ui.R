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
      menuItem("Home",                    tabName = "home",         icon = icon("house")),
      menuItem("Theoretical Framework",   tabName = "theory",       icon = icon("flask")),
      menuItem("Demographics",            tabName = "demographics", icon = icon("chart-line")),
      menuItem("Healthcare & Epidemiology", tabName = "epi",        icon = icon("hospital")),
      menuItem("Mortality Analysis",      tabName = "mortality",    icon = icon("heartbeat")),
      menuItem("Screening Calculator",    tabName = "screening",    icon = icon("calculator"))
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
        #shiny-tab-mortality  .small-box { min-height: 120px !important; }
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
      
      # -- TAB 1: Home ----------------------------------------------------
      tabItem(
        tabName = "home",
        fluidRow(
          box(
            width = 12, status = "primary", solidHeader = TRUE,
            title = "Finland Health Trends Dashboard (2000-2024)",
            p(
              "This dashboard provides an interactive analysis of key public-health ",
              "indicators in ", tags$strong("Finland"), " over the period ",
              tags$strong("2000-2024"), ". It combines three official data sources to ",
              "visualise demographic mortality patterns, hospital bed capacity, cancer ",
              "burden, and to support evidence-based screening decisions."
            ),
            p("Use the sidebar to navigate the six analytical sections:"),
            tags$ul(
              tags$li(tags$strong("Home"), " - project overview and data citations."),
              tags$li(tags$strong("Theoretical Framework"), " - mathematical background."),
              tags$li(tags$strong("Demographics"), " - age-specific probability of death over time."),
              tags$li(tags$strong("Healthcare & Epi"), " - hospital capacity vs cancer mortality and multivariate regression."),
              tags$li(tags$strong("Mortality Analysis"), " - all-cause death rate trends, rate of change, and lag analysis."),
              tags$li(tags$strong("Screening Calculator"), " - Bayesian PPV tool.")
            )
          )
        ),
        fluidRow(
          infoBox("Life Table Years",   "2000 - 2024", icon = icon("calendar"), color = "blue",  width = 3),
          infoBox("Hospital Bed Years", "2000 - 2023", icon = icon("bed"),      color = "green", width = 3),
          infoBox("Cancer Data Years",  "2000 - 2021", icon = icon("ribbon"),   color = "red",   width = 3),
          infoBox("Death Rate Years",   "2000 - 2024", icon = icon("chart-bar"), color = "purple", width = 3)
        ),
        fluidRow(
          box(
            width = 12, title = "Official Data Citations", status = "info",
            div(class = "citation-box",
                tags$ol(
                  tags$li(
                    "Statistics Finland. ",
                    tags$em("Life table by age and sex, 1986-2024."), " ",
                    tags$a("https://pxdata.stat.fi/PxWeb/pxweb/en/StatFin/StatFin__kuol/statfin_kuol_pxt_12ap.px/", href = "https://pxdata.stat.fi/PxWeb/pxweb/en/StatFin/StatFin__kuol/statfin_kuol_pxt_12ap.px/", target = "_blank"),
                    ". Accessed 2026."
                  ),
                  tags$li(
                    "Our World in Data. ",
                    tags$em("Hospital beds (per 1,000 people)."), " ",
                    tags$a("https://ourworldindata.org/grapher/hospital-beds-per-1000-people", href = "https://ourworldindata.org/grapher/hospital-beds-per-1000-people", target = "_blank"),
                    ". Accessed 2026."
                  ),
                  tags$li(
                    "Our World in Data. ",
                    tags$em("Death rate from cancer."), " ",
                    tags$a("https://ourworldindata.org/grapher/death-rate-from-cancer", href = "https://ourworldindata.org/grapher/death-rate-from-cancer", target = "_blank"),
                    ". Accessed 2026."
                  ),
                  tags$li(
                    "Statistics Finland. ",
                    tags$em("Deaths, age-standardised and crude death rates by cause of death and sex, 1971-2024 (table 11ay)."), " ",
                    tags$a("https://stat.fi/til/ksyyt/index_en.html", href = "https://stat.fi/til/ksyyt/index_en.html", target = "_blank"),
                    ". Accessed 2026."
                  )
                )
            )
          )
        )
      ),
      
      # -- TAB 2: Theoretical Framework ------------------------------------
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
          # --- Life Table / qx
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
          
          # --- Screening / PPV
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
        # --- Gompertz-Makeham Mortality Model
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
        # --- Odds Ratio & Relative Risk
        fluidRow(
          box(
            width = 6, status = "primary",
            title = "4. Odds Ratio (OR) & Relative Risk (RR)",
            div(
              class = "equation-box",
              p(
                "These metrics compare mortality between males and females at a given age."
              ),
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
          # --- Pearson Correlation
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
        )
      ),
      
      # -- TAB 3: Demographics ----------------------------------------------
      tabItem(
        tabName = "demographics",
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
            width = 9, status = "primary", title = "q\u2093 by Age",
            plotlyOutput("demo_plot", height = "450px")
          )
        ),
        fluidRow(
          valueBoxOutput("risk_box", width = 6)
        ),
        fluidRow(
          box(
            width = 12, status = "primary", title = "Stationary Population Structure (Linked to Year Slider Above)", p("This plot updates with the year selected in the mortality chart above."),
            plotlyOutput("pyramid_plot", height = "400px")
          )
        )
      ),
      
      # -- TAB 4: Healthcare & Epi ------------------------------------------
      tabItem(
        tabName = "epi",
        fluidRow(
          box(
            width = 12, status = "primary", solidHeader = TRUE,
            title = "Epidemiological Trends: Healthcare Capacity & Cancer Burden",
            p(
              "Side-by-side comparison of ", strong("hospital bed capacity"),
              " (2000-2023) and ", strong("cancer mortality rates"),
              " (2000-2021). Note the different data extents."
            )
          )
        ),
        fluidRow(
          box(
            width = 6, status = "success",
            title = "Hospital Beds per 100 000 Population",
            selectInput(
              "beds_smooth", "Trend line:",
              choices  = c("None", "Loess", "Linear"),
              selected = "Loess"
            ),
            plotlyOutput("beds_plot", height = "380px")
          ),
          box(
            width = 6, status = "danger",
            title = "Cancer Mortality Rate per 100 000 Population",
            div(style = "height: 74px;"), # Invisible spacer to align perfectly with the trend line dropdown
            plotlyOutput("cancer_plot", height = "380px")
          )
        ),
        fluidRow(
          box(
            width = 4, status = "warning",
            title = "Statistical Link",
            valueBoxOutput("corr_box", width = 12)
          ),
          box(
            width = 8, status = "warning",
            title = "Correlation: Beds vs. Cancer Mortality",
            plotlyOutput("corr_scatter", height = "300px"),
            br(),
            p(
              tags$strong("Interpretation: "),
              "This represents an ecological correlation over time. ",
              tags$strong("It does not imply causation."),
              " as both variables may be influenced ",
              "by underlying factors such as population aging and healthcare improvements."
            )
          )
        ),
        fluidRow(
          box(
            width = 12, status = "info",
            title = "Data Notes",
            tags$ul(
              tags$li("Hospital bed data (Our World in Data) covers 2000-2023 (24 data points)."),
              tags$li("Cancer mortality data (Our World in Data) covers 2000-2021 (22 data points)."),
              tags$li("Mismatched timelines are intentional; each dataset uses its available extent.")
            )
          )
        ),

        # ---- Advanced Epidemiology ----
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

        # -- Multivariate Regression ----------------------------------------
        fluidRow(
          box(
            width = 6, status = "primary",
            title = tags$span(icon("chart-line"), " Multivariate Linear Regression"),
            tags$h4("Model: death_rate ~ beds_per_100k + deaths_per_100k",
                    class = "section-header"),
            tableOutput("lm_coef_table"),
            br(),
            uiOutput("lm_r2_display"),
            div(class = "interp-text",
                tags$strong("Interpretation: "),
                "The model estimates how much the overall (age-standardised) ",
                "death rate changes with each unit change in hospital bed capacity ",
                "and cancer mortality, holding the other variable constant. ",
                "A negative coefficient for beds suggests more capacity is associated ",
                "with lower mortality; a positive coefficient for cancer deaths ",
                "reflects its contribution to overall mortality burden."
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

        # -- Correlation Matrix ----------------------------------------------
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

        # -- Logistic Regression --------------------------------------------
        fluidRow(
          box(
            width = 6, status = "warning",
            title = tags$span(icon("percent"), " Logistic Regression: Predictors of High Mortality"),
            p("Binary outcome: death rate above the historical median (1 = high, 0 = low)."),
            tableOutput("glm_coef_table"),
            br(),
            div(class = "interp-text",
                tags$strong("Interpretation: "),
                "Odds ratios (OR) greater than 1 indicate that higher values of the ",
                "predictor are associated with increased odds of a high-mortality year. ",
                "An OR < 1 for beds suggests more bed capacity is associated with lower ",
                "odds of above-median overall mortality."
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
                "estimate that a year with these indicator values would have an ",
                "above-median overall death rate."
            )
          )
        ),

        # -- Lag Analysis ---------------------------------------------------
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

      # -- TAB 5: Mortality Analysis ----------------------------------------
      tabItem(
        tabName = "mortality",
        fluidRow(
          box(
            width = 12, status = "primary", solidHeader = TRUE,
            title = "All-Cause Mortality Analysis: Finland 2000-2024",
            p(
              "Analysis of Finland's age-standardised all-cause death rate ",
              "(per 100 000 population) from Statistics Finland. ",
              "The data covers all sexes combined for the period 2000-2024."
            )
          )
        ),

        # Value boxes
        fluidRow(
          valueBoxOutput("mort_latest_box",  width = 4),
          valueBoxOutput("mort_avg_box",     width = 4),
          valueBoxOutput("mort_change_box",  width = 4)
        ),

        # Time series
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

        # Comparative plot + rate of change
        fluidRow(
          box(
            width = 6, status = "danger",
            title = tags$span(icon("balance-scale"), " Overall vs Cancer Mortality (2000-2021)"),
            plotlyOutput("mort_compare_plot", height = "380px"),
            div(class = "interp-text",
                tags$strong("Interpretation: "),
                "Both series are normalised to their 2000 baseline (index = 100) to allow ",
                "direct comparison of relative decline. Cancer mortality has declined ",
                "faster than all-cause mortality, indicating broad improvements across ",
                "multiple disease categories."
            )
          ),
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
          )
        )
      ),
      
      # -- TAB 6: Screening Calculator --------------------------------------
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
              value  = 3168,   # updated by server observer using Finland 2021 data
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
            uiOutput("ppv_formula_display")
          )
        )
      )
    )
  )
)