## =============================================================================
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
      menuItem("Home",                  tabName = "home",        icon = icon("house")),
      menuItem("Theoretical Framework", tabName = "theory",      icon = icon("flask")),
      menuItem("Demographics",          tabName = "demographics", icon = icon("chart-line")),
      menuItem("Healthcare & Epi",      tabName = "epi",         icon = icon("hospital")),
      menuItem("Screening Calculator",  tabName = "screening",   icon = icon("calculator"))
    )
  ),
  
  # -- Body ------------------------------------------------------------------
  dashboardBody(
    
    # Custom CSS for polished look
    tags$head(
      tags$link(rel = "shortcut icon", href = "finland_flag.webp"),
      tags$style(HTML("
        .content-wrapper, .right-side { background-color: #f4f6f9; }
        .box { border-top: 3px solid #3c8dbc; }
        .info-box-icon { font-size: 2em; }
        .equation-box {
          background: #fff;
          border-left: 4px solid #3c8dbc;
          padding: 18px 24px;
          margin-bottom: 20px;
          border-radius: 4px;
          box-shadow: 0 1px 4px rgba(0,0,0,.1);
        }
        .citation-box {
          background: #eaf4fb;
          border-left: 4px solid #1a6496;
          padding: 12px 18px;
          margin-top: 16px;
          border-radius: 4px;
          font-size: 0.92em;
        }
      "))
    ),
    tags$style(HTML("
  /* Make all value boxes in the Screening tab same height */
  #screening .value-box {
    min-height: 120px !important;
  }
")),
    
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
            p("Use the sidebar to navigate the five analytical sections:"),
            tags$ul(
              tags$li(tags$strong("Home"), " - project overview and data citations."),
              tags$li(tags$strong("Theoretical Framework"), " - mathematical background."),
              tags$li(tags$strong("Demographics"), " - age-specific probability of death over time."),
              tags$li(tags$strong("Healthcare & Epi"), " - hospital capacity vs cancer mortality."),
              tags$li(tags$strong("Screening Calculator"), " - Bayesian PPV tool.")
            )
          )
        ),
        fluidRow(
          infoBox("Life Table Years",   "2000 - 2024", icon = icon("calendar"), color = "blue",  width = 4),
          infoBox("Hospital Bed Years", "2000 - 2023", icon = icon("bed"),      color = "green", width = 4),
          infoBox("Cancer Data Years",  "2000 - 2021", icon = icon("ribbon"),   color = "red",   width = 4)
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
                  )
                )
            )
          )
        )
      ),
      
      # -- TAB 2: Theoretical Framework ------------------------------------
      tabItem(
        tabName = "theory",
        withMathJax(),
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
          box(
            width = 6, status = "info",
            title = "1. Probability of Death (Life Table)",
            div(
              class = "equation-box",
              p(tags$strong("Definition of \\( q_x \\)")),
              p(
                "The age-specific probability of death \\( q_x \\) represents the ",
                "probability that an individual aged exactly \\( x \\) will die before ",
                "reaching age \\( x+1 \\)."
              ),
              p("$$q_x = \\frac{d_x}{l_x}$$"),
              tags$ul(
                tags$li("\\( d_x \\) - number of deaths between ages \\( x \\) and \\( x+1 \\)"),
                tags$li("\\( l_x \\) - number of survivors reaching exact age \\( x \\) (radix = 100 000)")
              ),
              p("In the force-of-mortality formulation:"),
              p("$$q_x = 1 - e^{-\\int_x^{x+1} \\mu(t)\\, dt} \\approx 1 - e^{-\\mu_x}$$"),
              p(
                "where \\( \\mu_x \\) is the hazard rate (force of mortality) at age \\( x \\). ",
                "Values in this dashboard are expressed as deaths per 1 000 (per mille)."
              )
            )
          ),
          box(
            width = 6, status = "success",
            title = "2. Positive Predictive Value (PPV)",
            div(
              class = "equation-box",
              p(tags$strong("Bayes' Theorem applied to screening")),
              p(
                "The Positive Predictive Value (PPV) is the probability that a ",
                "positive screening test truly indicates disease. It depends on test ",
                "performance ", em("and"), " disease prevalence."
              ),
              p("$$\\text{PPV} = \\frac{\\text{Sensitivity} \\times \\text{Prevalence}}{\\text{Sensitivity} \\times \\text{Prevalence} + (1 - \\text{Specificity}) \\times (1 - \\text{Prevalence})}$$"),
              p("Equivalently, using Bayes' theorem:"),
              p("$$P(D^+ | T^+) = \\frac{P(T^+ | D^+)\\, P(D^+)}{P(T^+)}$$"),
              tags$ul(
                tags$li("\\( P(T^+|D^+) \\) - sensitivity (true positive rate)"),
                tags$li("\\( P(D^+) \\) - prevalence (prior probability of disease)"),
                tags$li("\\( P(T^+) \\) - marginal probability of a positive test")
              ),
              p(
                "A high sensitivity alone is insufficient; low prevalence can still yield ",
                "a low PPV-highlighting the importance of targeted screening programmes."
              )
            )
          )
        ),
        fluidRow(
          box(
            width = 12, status = "warning",
            title = "3. Gompertz-Makeham Mortality Model",
            div(
              class = "equation-box",
              p(
                "The Gompertz-Makeham law describes the exponential increase of mortality ",
                "with age and is widely used in actuarial and demographic studies:"
              ),
              p("$$\\mu(x) = A + B \\cdot e^{\\,cx}$$"),
              tags$ul(
                tags$li("\\( A \\) - age-independent background hazard (accidents, infections)"),
                tags$li("\\( B, c \\) - parameters governing the age-related exponential rise")
              ),
              p(
                "For Finland, estimates suggest \\( c \\approx 0.09 \\) for both sexes, ",
                "consistent with other Nordic populations."
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
            title = "Age-Specific Probability of Death - Finland",
            p(
              "Interactive chart of \\( q_x \\) (per mille) by age. ",
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
            # NEW: Age slider for the Risk Box
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
        # NEW ROW: The Odds Ratio/Relative Risk Box
        fluidRow(
          valueBoxOutput("risk_box", width = 6)
        ),
        # NEW ROW: The Population Pyramid
        fluidRow(
          box(
            width = 12, status = "primary", title = "Stationary Population Structure (Survivors)",
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
            title = "Healthcare Capacity & Cancer Burden - Finland",
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
            plotlyOutput("cancer_plot", height = "380px")
          )
        ),
        # NEW ROW: Correlation Analysis
        fluidRow(
          box(
            width = 4, status = "warning",
            title = "Statistical Link",
            valueBoxOutput("corr_box", width = 12)
          ),
          box(
            width = 8, status = "warning",
            title = "Correlation: Beds vs. Cancer Mortality",
            plotlyOutput("corr_scatter", height = "300px")
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
        )
      ),
      
      # -- TAB 5: Screening Calculator --------------------------------------
      tabItem(
        tabName = "screening",
        withMathJax(),
        fluidRow(
          box(
            width = 12, status = "primary", solidHeader = TRUE,
            title = "Bayesian Positive Predictive Value (PPV) Calculator",
            p(
              "Calculate the PPV of a cancer screening test for Finland using Bayes' Theorem. ",
              "The prevalence field is pre-filled with a baseline estimate for Finland. ",
              "Adjust the parameters to evaluate different screening scenarios."
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
              valueBoxOutput("ppv_result",  width = 3),
              valueBoxOutput("npv_result",  width = 3),
              valueBoxOutput("prev_result", width = 3),
              valueBoxOutput("lr_pos_box",  width = 3),
              valueBoxOutput("lr_neg_box",  width = 3)
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