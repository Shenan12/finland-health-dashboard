# =============================================================================
# server.R - Reactive logic for Finland Health Dashboard
# =============================================================================

server <- function(input, output, session) {
  
  # -- Update prevalence numeric input once global.R has loaded --------------
  observe({
    updateNumericInput(
      session, "ppv_prevalence",
      value = round(finland_2021_prevalence, 1)
    )
  })
  
  # ==========================================================================
  # TAB 3: Demographics
  # ==========================================================================
  
  output$demo_plot <- renderPlotly({
    
    sel_year <- input$demo_year
    sel_sex  <- input$demo_sex
    use_log  <- input$demo_log
    
    df <- life_raw |>
      filter(year == sel_year)
    
    if (sel_sex != "Both") {
      df <- df |> filter(sex == sel_sex)
    }
    
    color_map <- c("Male" = "#2171b5", "Female" = "#e63946")
    
    p <- plot_ly()
    
    sexes <- if (sel_sex == "Both") c("Male", "Female") else sel_sex
    
    for (s in sexes) {
      d <- df |> filter(sex == s)
      p <- p |>
        add_trace(
          data       = d,
          x          = ~age,
          y          = ~prob_death,
          type       = "scatter",
          mode       = "lines+markers",
          name       = s,
          line       = list(color = color_map[s], width = 2.5),
          marker     = list(color = color_map[s], size = 5),
          hovertemplate = paste0(
            "<b>Age:</b> %{x}<br>",
            "<b>q\u2093 (per mille):</b> %{y:.3f}<extra>", s, "</extra>"
          )
        )
    }
    
    y_axis_type <- if (use_log) "log" else "linear"
    
    p |>
      layout(
        title  = list(
          text = paste0("Finland - Age-specific Mortality (q\u2093), Year: <b>", sel_year, "</b>"),
          font = list(size = 14)
        ),
        xaxis  = list(
          title      = "Age (years)",
          showgrid   = TRUE,
          gridcolor  = "#e0e0e0",
          zeroline   = FALSE
        ),
        yaxis  = list(
          title     = "Probability of death (per mille)",
          type      = y_axis_type,
          showgrid  = TRUE,
          gridcolor = "#e0e0e0"
        ),
        legend = list(orientation = "h", x = 0.3, y = -0.15),
        hovermode = "x unified",
        plot_bgcolor  = "#fafafa",
        paper_bgcolor = "#fafafa"
      )
  })
  
  # ==========================================================================
  # TAB 4: Healthcare & Epi
  # ==========================================================================
  
  # -- Hospital Beds ----------------------------------------------------------
  output$beds_plot <- renderPlotly({
    
    df   <- beds_raw
    smth <- input$beds_smooth
    
    p <- plot_ly(
      data = df, x = ~year, y = ~beds_per_100k,
      type = "scatter", mode = "lines+markers",
      name = "Hospital beds",
      line   = list(color = "#27ae60", width = 2),
      marker = list(color = "#27ae60", size = 6),
      hovertemplate = "<b>Year:</b> %{x}<br><b>Beds / 100k:</b> %{y:.1f}<extra></extra>"
    )
    
    if (smth == "Loess") {
      lo  <- loess(beds_per_100k ~ year, data = df, span = 0.5)
      yfit <- predict(lo, newdata = df)
      p <- p |>
        add_trace(
          x = ~year, y = yfit, type = "scatter", mode = "lines",
          name = "Loess trend",
          line = list(color = "#1a7a44", width = 2, dash = "dash"),
          hoverinfo = "skip",
          data = df
        )
    } else if (smth == "Linear") {
      lm_fit <- lm(beds_per_100k ~ year, data = df)
      yfit   <- predict(lm_fit, newdata = df)
      p <- p |>
        add_trace(
          x = ~year, y = yfit, type = "scatter", mode = "lines",
          name = "Linear trend",
          line = list(color = "#1a7a44", width = 2, dash = "dash"),
          hoverinfo = "skip",
          data = df
        )
    }
    
    p |>
      layout(
        xaxis = list(title = "Year", showgrid = TRUE, gridcolor = "#e0e0e0",
                     dtick = 2, tickformat = "d", range = c(2000, 2024)),
        yaxis = list(title = "Beds per 100 000 population",
                     showgrid = TRUE, gridcolor = "#e0e0e0"),
        legend = list(orientation = "h", x = 0, y = -0.2),
        plot_bgcolor  = "#fafafa",
        paper_bgcolor = "#fafafa"
      )
  })
  
  # -- Cancer Mortality -------------------------------------------------------
  output$cancer_plot <- renderPlotly({
    
    # Directly plot the raw data since there is only one overall cancer type now
    df <- cancer_raw
    
    plot_ly(
      data = df, x = ~year, y = ~deaths_per_100k,
      type = "scatter", mode = "lines+markers",
      name = "Cancer Mortality",
      line   = list(color = "#c0392b", width = 2),
      marker = list(color = "#c0392b", size = 6),
      hovertemplate = "<b>Year:</b> %{x}<br><b>Deaths / 100k:</b> %{y:.2f}<extra></extra>"
    ) |>
      layout(
        xaxis = list(title = "Year", showgrid = TRUE, gridcolor = "#e0e0e0",
                     dtick = 2, tickformat = "d", range = c(2000, 2024)),
        yaxis = list(title = "Deaths per 100 000 population",
                     showgrid = TRUE, gridcolor = "#e0e0e0"),
        plot_bgcolor  = "#fafafa",
        paper_bgcolor = "#fafafa"
      )
  })
  
  # ==========================================================================
  # TAB 5: Screening Calculator
  # ==========================================================================
  
  ppv_results <- eventReactive(input$ppv_calc, {
    sensitivity <- input$ppv_sensitivity / 100
    specificity <- input$ppv_specificity / 100
    prevalence  <- (input$ppv_prevalence %||% finland_2021_prevalence) / 100000
    
    # Bayes' theorem
    tp  <- sensitivity * prevalence
    fp  <- (1 - specificity) * (1 - prevalence)
    fn  <- (1 - sensitivity) * prevalence
    tn  <- specificity * (1 - prevalence)
    
    ppv <- tp / (tp + fp)
    npv <- tn / (tn + fn)
    
    list(
      ppv         = ppv,
      npv         = npv,
      sensitivity = sensitivity,
      specificity = specificity,
      prevalence  = prevalence,
      tp = tp, fp = fp, fn = fn, tn = tn
    )
  }, ignoreNULL = FALSE)
  
  output$ppv_result <- renderValueBox({
    res <- ppv_results()
    valueBox(
      value    = paste0(round(res$ppv * 100, 2), "%"),
      subtitle = "Positive Predictive Value (PPV)",
      icon     = icon("check-circle"),
      color    = if (res$ppv >= 0.5) "green" else "yellow"
    )
  })
  
  output$npv_result <- renderValueBox({
    res <- ppv_results()
    valueBox(
      value    = paste0(round(res$npv * 100, 2), "%"),
      subtitle = "Negative Predictive Value (NPV)",
      icon     = icon("times-circle"),
      color    = if (res$npv >= 0.9) "green" else "yellow"
    )
  })
  
  output$prev_result <- renderValueBox({
    prev_val <- (input$ppv_prevalence %||% finland_2021_prevalence)
    valueBox(
      value    = paste0(round(prev_val, 0), " / 100k"),
      subtitle = "Cancer Prevalence Used",
      icon     = icon("info-circle"),
      color    = "blue"
    )
  })
  
  output$ppv_plot <- renderPlotly({
    res <- ppv_results()
    
    # Sensitivity sweep for PPV curve
    prev <- res$prevalence
    spec <- res$specificity
    sens_seq <- seq(0.01, 0.99, by = 0.01)
    ppv_seq  <- (sens_seq * prev) / (sens_seq * prev + (1 - spec) * (1 - prev))
    npv_seq  <- (spec * (1 - prev)) /
      (spec * (1 - prev) + (1 - sens_seq) * prev)
    
    df_curve <- data.frame(
      sensitivity = sens_seq * 100,
      ppv         = ppv_seq  * 100,
      npv         = npv_seq  * 100
    )
    
    plot_ly(df_curve, x = ~sensitivity) |>
      add_trace(
        y = ~ppv, type = "scatter", mode = "lines",
        name = "PPV", line = list(color = "#27ae60", width = 2.5)
      ) |>
      add_trace(
        y = ~npv, type = "scatter", mode = "lines",
        name = "NPV", line = list(color = "#2980b9", width = 2.5)
      ) |>
      add_segments(
        x = res$sensitivity * 100, xend = res$sensitivity * 100,
        y = 0, yend = 100,
        line = list(color = "red", dash = "dot", width = 1.5),
        name = "Current sensitivity"
      ) |>
      layout(
        title  = list(text = "PPV / NPV vs. Sensitivity (at fixed Specificity & Prevalence)",
                      font = list(size = 13)),
        xaxis  = list(title = "Sensitivity (%)", range = c(0, 100),
                      showgrid = TRUE, gridcolor = "#e0e0e0"),
        yaxis  = list(title = "Value (%)", range = c(0, 100),
                      showgrid = TRUE, gridcolor = "#e0e0e0"),
        legend = list(orientation = "h", x = 0.2, y = -0.2),
        plot_bgcolor  = "#fafafa",
        paper_bgcolor = "#fafafa"
      )
  })
  
  output$ppv_formula_display <- renderUI({
    res <- ppv_results()
    withMathJax(
      div(
        class = "equation-box",
        tags$strong("Formula applied:"),
        p(sprintf(
          "$$\\text{PPV} = \\frac{%.2f \\times %.5f}{%.2f \\times %.5f + (1 - %.2f) \\times (1 - %.5f)} = %.4f$$",
          res$sensitivity, res$prevalence,
          res$sensitivity, res$prevalence,
          res$specificity, res$prevalence,
          res$ppv
        ))
      )
    )
  })
}