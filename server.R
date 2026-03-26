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
  
  # -- Population Pyramid ----------------------------------------------------
  output$pyramid_plot <- renderPlotly({
    
    # Uses the year selected in the existing demo_year input
    pyramid_data <- life_raw |>
      filter(year == input$demo_year, sex != "Total") |>
      mutate(
        # Males go left (negative), Females go right (positive)
        display_val = ifelse(sex == "Male", -survivors, survivors)
      )
    
    plot_ly(pyramid_data, x = ~display_val, y = ~age, color = ~sex, colors = c("#2171b5", "#e63946")) |>
      add_bars(orientation = "h", hoverinfo = "text",
               text = ~paste("Age:", age, "<br>Survivors:", survivors)) |>
      layout(
        title = list(
          text = paste0("Stationary Population Pyramid (lx) - Year: <b>", input$demo_year, "</b>"),
          font = list(size = 14)
        ),
        barmode = "overlay",
        xaxis = list(
          title = "Number of Survivors", 
          tickvals = seq(-100000, 100000, 25000),
          ticktext = c("100k", "75k", "50k", "25k", "0", "25k", "50k", "75k", "100k"),
          showgrid = TRUE, gridcolor = "#e0e0e0"
        ),
        yaxis = list(title = "Age (years)", showgrid = TRUE, gridcolor = "#e0e0e0"),
        legend = list(orientation = "h", x = 0.3, y = -0.15),
        plot_bgcolor  = "#fafafa",
        paper_bgcolor = "#fafafa"
      )
  })
  
  # -- Odds Ratio & Relative Risk Box -----------------------------------------
  output$risk_box <- renderValueBox({
    
    # We will need to add an 'input$demo_age' slider to ui.R next!
    req(input$demo_age) 
    
    risk_data <- life_raw |>
      filter(year == input$demo_year, age == input$demo_age, sex != "Total")
    
    # Extract probabilities for the selected age
    p_male <- risk_data |> filter(sex == "Male") |> pull(prob_death) / 1000
    p_female <- risk_data |> filter(sex == "Female") |> pull(prob_death) / 1000
    
    # Fallback if data is missing
    if(length(p_male) == 0 || length(p_female) == 0) {
      return(valueBox("N/A", "Data missing for this age", icon = icon("exclamation-triangle"), color = "red"))
    }
    
    # 1. Relative Risk calculation
    rr <- p_male / p_female
    
    # 2. Odds Ratio calculation
    odds_male <- p_male / (1 - p_male)
    odds_female <- p_female / (1 - p_female)
    or_val <- odds_male / odds_female
    
    valueBox(
      value = HTML(paste0("RR: ", round(rr, 2), " | OR: ", round(or_val, 2))),
      subtitle = paste("Relative Risk & Odds Ratio (Male vs Female) at Age", input$demo_age),
      icon = icon("venus-mars"),
      color = "purple"
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
  
  # -- Correlation Box --------------------------------------------------------
  output$corr_box <- renderValueBox({
    # Calculate Pearson correlation (r)
    r_val <- cor(correlation_df$beds_per_100k, correlation_df$deaths_per_100k, use = "complete.obs")
    
    valueBox(
      value = round(r_val, 3),
      subtitle = "Pearson Correlation (r)",
      icon = icon("link"),
      color = if (r_val < -0.7) "red" else "yellow"
    )
  })
  
  # -- Correlation Scatter Plot -----------------------------------------------
  output$corr_scatter <- renderPlotly({
    # Fit a linear regression line
    fit <- lm(deaths_per_100k ~ beds_per_100k, data = correlation_df)
    
    plot_ly(correlation_df, x = ~beds_per_100k) |>
      add_markers(
        y = ~deaths_per_100k,
        name = "Years (2000-2021)",
        marker = list(color = "#8e44ad", size = 8),
        hovertemplate = "<b>Beds / 100k:</b> %{x:.1f}<br><b>Cancer Deaths / 100k:</b> %{y:.1f}<extra></extra>"
      ) |>
      add_lines(
        x = ~beds_per_100k,
        y = fitted(fit),
        name = "Trend",
        line = list(color = "#2c3e50", dash = "dash")
      ) |>
      layout(
        xaxis = list(title = "Hospital Beds per 100k", showgrid = TRUE, gridcolor = "#e0e0e0"),
        yaxis = list(title = "Cancer Deaths per 100k", showgrid = TRUE, gridcolor = "#e0e0e0"),
        plot_bgcolor  = "#fafafa",
        paper_bgcolor = "#fafafa",
        showlegend = FALSE
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
    
    lr_pos <- if (specificity >= 1) Inf else sensitivity / (1 - specificity)
    lr_neg <- if (sensitivity >= 1) 0   else (1 - sensitivity) / specificity
    
    list(
      ppv = ppv,
      npv = npv,
      sensitivity = sensitivity,
      specificity = specificity,
      prevalence = prevalence,
      tp = tp, fp = fp, fn = fn, tn = tn,
      lr_pos = lr_pos,
      lr_neg = lr_neg
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
  output$lr_pos_box <- renderValueBox({
    res <- ppv_results()
    lr_display <- if (is.infinite(res$lr_pos)) "\u221e" else round(res$lr_pos, 2)
    valueBox(
      value    = lr_display,
      subtitle = "Likelihood Ratio +",
      icon     = icon("plus"),
      color    = "green"
    )
  })
  
  output$lr_neg_box <- renderValueBox({
    res <- ppv_results()
    valueBox(
      value    = round(res$lr_neg, 2),
      subtitle = "Likelihood Ratio -",
      icon     = icon("minus"),
      color    = "red"
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

  # ==========================================================================
  # TAB 4 EXTENSION: Multivariate Regression, Correlation Matrix, Logistic,
  #                  Lag Analysis
  # ==========================================================================

  # -- Multivariate Linear Regression coefficient table ----------------------
  output$lm_coef_table <- renderTable({
    s  <- summary(lm_model)
    cf <- as.data.frame(s$coefficients)
    cf$Term <- rownames(cf)
    cf <- cf[, c("Term", "Estimate", "Std. Error", "t value", "Pr(>|t|)")]
    colnames(cf) <- c("Term", "Estimate", "Std. Error", "t-value", "p-value")
    cf$Estimate    <- round(cf$Estimate,    3)
    cf$`Std. Error` <- round(cf$`Std. Error`, 3)
    cf$`t-value`   <- round(cf$`t-value`,   3)
    cf$`p-value`   <- signif(cf$`p-value`,  3)
    cf
  }, striped = TRUE, hover = TRUE, bordered = TRUE, width = "100%")

  output$lm_r2_display <- renderUI({
    s     <- summary(lm_model)
    r2    <- round(s$r.squared,    3)
    r2adj <- round(s$adj.r.squared, 3)
    f_val <- s$fstatistic
    f_stat <- f_val[1]; df1 <- f_val[2]; df2 <- f_val[3]
    p_f   <- signif(pf(f_stat, df1, df2, lower.tail = FALSE), 3)
    div(
      class = "equation-box",
      tags$strong(paste0("R\u00b2 = ", r2,
                         "  |  Adjusted R\u00b2 = ", r2adj,
                         "  |  Overall p-value = ", p_f))
    )
  })

  # -- Regression scatter: beds vs death_rate, colour = cancer deaths --------
  output$reg_scatter <- renderPlotly({
    df  <- health_df
    fit <- lm(death_rate ~ beds_per_100k, data = df)
    x_seq <- seq(min(df$beds_per_100k), max(df$beds_per_100k), length.out = 100)
    y_fit <- predict(fit, newdata = data.frame(beds_per_100k = x_seq))

    plot_ly(df, x = ~beds_per_100k) |>
      add_markers(
        y             = ~death_rate,
        color         = ~deaths_per_100k,
        colors        = c("#fee8c8", "#c0392b"),
        text          = ~paste0("Year: ", year,
                                "<br>Beds/100k: ", round(beds_per_100k, 1),
                                "<br>Death rate: ", round(death_rate, 1),
                                "<br>Cancer deaths/100k: ", round(deaths_per_100k, 1)),
        hoverinfo     = "text",
        marker        = list(size = 10, opacity = 0.85),
        showlegend    = TRUE,
        name          = "Years (colour = cancer mortality)"
      ) |>
      add_lines(
        x    = x_seq,
        y    = y_fit,
        line = list(color = "#2c3e50", dash = "dash", width = 2),
        name = "Regression line",
        hoverinfo = "skip"
      ) |>
      layout(
        xaxis = list(title = "Hospital Beds per 100k",
                     showgrid = TRUE, gridcolor = "#e0e0e0"),
        yaxis = list(title = "Overall Death Rate per 100k",
                     showgrid = TRUE, gridcolor = "#e0e0e0"),
        coloraxis = list(colorbar = list(title = "Cancer<br>Deaths/100k")),
        plot_bgcolor  = "#fafafa",
        paper_bgcolor = "#fafafa",
        legend = list(orientation = "h", y = -0.2)
      )
  })

  # -- Correlation heatmap ---------------------------------------------------
  output$corr_heatmap <- renderPlotly({
    mat_df <- health_df[, c("beds_per_100k", "deaths_per_100k", "death_rate")]
    mat    <- cor(mat_df, use = "complete.obs")
    labels <- c("Beds /100k", "Cancer Deaths /100k", "Overall Death Rate /100k")
    rownames(mat) <- colnames(mat) <- labels

    # Build annotation text
    ann_text <- round(mat, 3)

    plot_ly(
      x = labels, y = labels,
      z = mat,
      type        = "heatmap",
      colorscale  = list(c(0, "#d73027"), c(0.5, "#f7f7f7"), c(1, "#1a6496")),
      zmin = -1, zmax = 1,
      text         = ann_text,
      texttemplate = "%{text}",
      hovertemplate = "r = %{z:.3f}<extra></extra>"
    ) |>
      layout(
        title  = list(text = "Pearson Correlation Matrix", font = list(size = 13)),
        xaxis  = list(title = "", tickangle = -20),
        yaxis  = list(title = ""),
        plot_bgcolor  = "#fafafa",
        paper_bgcolor = "#fafafa"
      )
  })

  # -- Logistic Regression coefficient table ---------------------------------
  output$glm_coef_table <- renderTable({
    s  <- summary(glm_model)
    cf <- as.data.frame(s$coefficients)
    cf$Term <- rownames(cf)
    cf$OR   <- round(exp(coef(glm_model)), 3)
    cf <- cf[, c("Term", "Estimate", "Std. Error", "z value", "Pr(>|z|)", "OR")]
    colnames(cf) <- c("Term", "Log-Odds", "Std. Error", "z-value", "p-value", "Odds Ratio")
    cf$`Log-Odds`  <- round(cf$`Log-Odds`,  3)
    cf$`Std. Error` <- round(cf$`Std. Error`, 3)
    cf$`z-value`   <- round(cf$`z-value`,   3)
    cf$`p-value`   <- signif(cf$`p-value`,  3)
    cf
  }, striped = TRUE, hover = TRUE, bordered = TRUE, width = "100%")

  # -- Logistic predicted probability value box -----------------------------
  output$glm_prob_box <- renderValueBox({
    new_data <- data.frame(
      beds_per_100k   = input$glm_beds,
      deaths_per_100k = input$glm_cancer
    )
    prob <- predict(glm_model, newdata = new_data, type = "response")
    prob_pct <- round(prob * 100, 1)
    valueBox(
      value    = paste0(prob_pct, "%"),
      subtitle = "Predicted Probability of High Mortality Year",
      icon     = icon("percent"),
      color    = if (prob >= 0.5) "red" else "green"
    )
  })

  # -- Lag plot: beds_lag1 vs death_rate ------------------------------------
  output$lag_plot <- renderPlotly({
    df  <- health_df |> filter(!is.na(beds_lag1))
    fit <- lm(death_rate ~ beds_lag1, data = df)
    x_seq <- seq(min(df$beds_lag1), max(df$beds_lag1), length.out = 100)
    y_fit <- predict(fit, newdata = data.frame(beds_lag1 = x_seq))

    plot_ly(df, x = ~beds_lag1) |>
      add_markers(
        y             = ~death_rate,
        marker        = list(color = "#2c3e50", size = 9, opacity = 0.8),
        text          = ~paste0("Year: ", year,
                                "<br>Beds (prev year): ", round(beds_lag1, 1),
                                "<br>Death rate: ", round(death_rate, 1)),
        hoverinfo     = "text",
        name          = "Year observations"
      ) |>
      add_lines(
        x    = x_seq,
        y    = y_fit,
        line = list(color = "#e74c3c", dash = "dash", width = 2),
        name = "Lag-1 regression",
        hoverinfo = "skip"
      ) |>
      layout(
        xaxis = list(title = "Hospital Beds per 100k (previous year)",
                     showgrid = TRUE, gridcolor = "#e0e0e0"),
        yaxis = list(title = "Overall Death Rate per 100k (current year)",
                     showgrid = TRUE, gridcolor = "#e0e0e0"),
        plot_bgcolor  = "#fafafa",
        paper_bgcolor = "#fafafa",
        legend = list(orientation = "h", y = -0.2)
      )
  })

  # ==========================================================================
  # TAB 5: Mortality Analysis
  # ==========================================================================

  # -- Value boxes -----------------------------------------------------------
  output$mort_latest_box <- renderValueBox({
    latest <- death_raw |> filter(year == max(year))
    valueBox(
      value    = paste0(round(latest$death_rate, 1), " / 100k"),
      subtitle = paste("Latest Death Rate (", latest$year, ")"),
      icon     = icon("heartbeat"),
      color    = "red"
    )
  })

  output$mort_avg_box <- renderValueBox({
    avg_rate <- mean(death_raw$death_rate, na.rm = TRUE)
    valueBox(
      value    = paste0(round(avg_rate, 1), " / 100k"),
      subtitle = "Average Death Rate (2000-2024)",
      icon     = icon("calculator"),
      color    = "blue"
    )
  })

  output$mort_change_box <- renderValueBox({
    sorted <- death_raw |> arrange(year)
    n      <- nrow(sorted)
    if (n >= 2) {
      last_rate <- sorted$death_rate[n]
      prev_rate <- sorted$death_rate[n - 1]
      pct_chg   <- round((last_rate - prev_rate) / prev_rate * 100, 2)
      color_val <- if (pct_chg > 0) "yellow" else "green"
      icon_val  <- if (pct_chg > 0) icon("arrow-up") else icon("arrow-down")
      valueBox(
        value    = paste0(ifelse(pct_chg > 0, "+", ""), pct_chg, "%"),
        subtitle = paste0("Change vs Previous Year (",
                          sorted$year[n - 1], "\u2192", sorted$year[n], ")"),
        icon     = icon_val,
        color    = color_val
      )
    } else {
      valueBox("N/A", "Insufficient data", icon = icon("question"), color = "gray")
    }
  })

  # -- Time series with LOESS ------------------------------------------------
  output$mort_ts_plot <- renderPlotly({
    df   <- death_raw |> arrange(year)
    lo   <- loess(death_rate ~ year, data = df, span = 0.5)
    yfit <- predict(lo, newdata = df)

    plot_ly(df, x = ~year) |>
      add_trace(
        y             = ~death_rate,
        type          = "scatter",
        mode          = "lines+markers",
        name          = "Death Rate",
        line          = list(color = "#2c3e50", width = 2),
        marker        = list(color = "#2c3e50", size = 6),
        hovertemplate = "<b>Year:</b> %{x}<br><b>Death Rate / 100k:</b> %{y:.1f}<extra></extra>"
      ) |>
      add_trace(
        y         = yfit,
        type      = "scatter",
        mode      = "lines",
        name      = "LOESS Trend",
        line      = list(color = "#e74c3c", width = 2.5, dash = "dash"),
        hoverinfo = "skip"
      ) |>
      layout(
        xaxis = list(title = "Year", showgrid = TRUE, gridcolor = "#e0e0e0",
                     dtick = 2, tickformat = "d"),
        yaxis = list(title = "Age-standardised death rate per 100k",
                     showgrid = TRUE, gridcolor = "#e0e0e0"),
        legend = list(orientation = "h", x = 0.3, y = -0.15),
        plot_bgcolor  = "#fafafa",
        paper_bgcolor = "#fafafa"
      )
  })

  # -- Comparative plot: normalised overall vs cancer mortality --------------
  output$mort_compare_plot <- renderPlotly({
    # Restrict to overlapping years with cancer data
    df <- health_df |> arrange(year)
    base_death  <- df$death_rate[1]
    base_cancer <- df$deaths_per_100k[1]
    df <- df |>
      mutate(
        idx_death  = death_rate / base_death * 100,
        idx_cancer = deaths_per_100k / base_cancer * 100
      )

    plot_ly(df, x = ~year) |>
      add_trace(
        y             = ~idx_death,
        type          = "scatter",
        mode          = "lines+markers",
        name          = "Overall Death Rate",
        line          = list(color = "#2c3e50", width = 2),
        marker        = list(color = "#2c3e50", size = 6),
        hovertemplate = "<b>Year:</b> %{x}<br><b>Index:</b> %{y:.1f}<extra>Overall</extra>"
      ) |>
      add_trace(
        y             = ~idx_cancer,
        type          = "scatter",
        mode          = "lines+markers",
        name          = "Cancer Mortality",
        line          = list(color = "#c0392b", width = 2),
        marker        = list(color = "#c0392b", size = 6),
        hovertemplate = "<b>Year:</b> %{x}<br><b>Index:</b> %{y:.1f}<extra>Cancer</extra>"
      ) |>
      add_segments(
        x = min(df$year), xend = max(df$year),
        y = 100, yend = 100,
        line = list(color = "#aaaaaa", dash = "dot", width = 1),
        name = "Baseline (2000 = 100)",
        hoverinfo = "skip"
      ) |>
      layout(
        xaxis = list(title = "Year", showgrid = TRUE, gridcolor = "#e0e0e0",
                     dtick = 2, tickformat = "d"),
        yaxis = list(title = "Index (Year 2000 = 100)",
                     showgrid = TRUE, gridcolor = "#e0e0e0"),
        legend = list(orientation = "h", x = 0.1, y = -0.2),
        plot_bgcolor  = "#fafafa",
        paper_bgcolor = "#fafafa"
      )
  })

  # -- Rate of change (YoY % change) -----------------------------------------
  output$mort_roc_plot <- renderPlotly({
    df <- death_raw |>
      arrange(year) |>
      mutate(
        pct_change = (death_rate - lag(death_rate)) / lag(death_rate) * 100
      ) |>
      filter(!is.na(pct_change))

    bar_colors <- ifelse(df$pct_change >= 0, "#e74c3c", "#27ae60")

    plot_ly(df,
            x    = ~year,
            y    = ~pct_change,
            type = "bar",
            marker = list(color = bar_colors),
            text  = ~paste0(round(pct_change, 2), "%"),
            hovertemplate = "<b>Year:</b> %{x}<br><b>Change:</b> %{y:.2f}%<extra></extra>"
    ) |>
      layout(
        xaxis = list(title = "Year", showgrid = FALSE,
                     dtick = 2, tickformat = "d"),
        yaxis = list(title = "Year-on-Year % Change",
                     showgrid = TRUE, gridcolor = "#e0e0e0",
                     zeroline = TRUE, zerolinecolor = "#888"),
        plot_bgcolor  = "#fafafa",
        paper_bgcolor = "#fafafa"
      )
  })

  # ---------- Birth Rate Plot ------------------------------------------------
  output$birth_rate_plot <- renderPlotly({
    plot_ly(birth_rate_df, x = ~year, y = ~crude_birth_rate,
            type = "scatter", mode = "lines+markers",
            line   = list(color = "#2980b9", width = 2),
            marker = list(color = "#2980b9", size = 6),
            hovertemplate = "<b>Year:</b> %{x}<br><b>Live Births:</b> %{y:,}<extra></extra>") |>
      layout(
        xaxis = list(title = "Year", showgrid = TRUE, gridcolor = "#e0e0e0",
                     dtick = 2, tickformat = "d"),
        yaxis = list(title = "Total Live Births", showgrid = TRUE, gridcolor = "#e0e0e0"),
        plot_bgcolor  = "#fafafa",
        paper_bgcolor = "#fafafa"
      )
  })

  # ---------- Stillbirth Rate Plot -------------------------------------------
  output$stillbirth_plot <- renderPlotly({
    plot_ly(stillbirth_df, x = ~year, y = ~stillbirth_rate,
            type = "scatter", mode = "lines+markers",
            line   = list(color = "#8e44ad", width = 2),
            marker = list(color = "#8e44ad", size = 6),
            hovertemplate = "<b>Year:</b> %{x}<br><b>Stillbirth Rate (per 1 000):</b> %{y:.2f}<extra></extra>") |>
      layout(
        xaxis = list(title = "Year", showgrid = TRUE, gridcolor = "#e0e0e0",
                     dtick = 2, tickformat = "d"),
        yaxis = list(title = "Stillbirth Rate per 1 000 births", showgrid = TRUE, gridcolor = "#e0e0e0"),
        plot_bgcolor  = "#fafafa",
        paper_bgcolor = "#fafafa"
      )
  })

  # ---------- Cause-of-Death Stacked Area Chart ------------------------------
  output$cause_area_plot <- renderPlotly({
    cause_colors <- c(
      "Infectious Diseases"  = "#2ecc71",
      "Malignant Neoplasms"  = "#e74c3c",
      "Endocrine/Metabolic"  = "#f39c12",
      "Dementia/Alzheimer"   = "#9b59b6",
      "Circulatory Diseases" = "#3498db",
      "Respiratory Diseases" = "#1abc9c",
      "Alcohol-Related"      = "#e67e22",
      "Accidents & Violence" = "#95a5a6"
    )

    p <- plot_ly()
    for (cname in names(cause_colors)) {
      sub <- cause_summary_df |> filter(cause == cname)
      if (nrow(sub) > 0) {
        p <- p |> add_trace(
          data = sub, x = ~year, y = ~deaths,
          type = "scatter", mode = "none", name = cname,
          fill = "tonexty",
          fillcolor = cause_colors[[cname]],
          line = list(color = cause_colors[[cname]]),
          stackgroup = "one",
          hovertemplate = paste0("<b>", cname, "</b><br>Year: %{x}<br>Deaths: %{y:,}<extra></extra>")
        )
      }
    }
    p |> layout(
      xaxis = list(title = "Year", showgrid = TRUE, gridcolor = "#e0e0e0",
                   dtick = 2, tickformat = "d"),
      yaxis = list(title = "Deaths (count)", showgrid = TRUE, gridcolor = "#e0e0e0"),
      legend = list(orientation = "h", y = -0.25),
      plot_bgcolor  = "#fafafa",
      paper_bgcolor = "#fafafa"
    )
  })

  # ---------- Tumour Share Plot -----------------------------------------------
  output$tumour_share_plot <- renderPlotly({
    plot_ly(tumour_share_df, x = ~year, y = ~tumour_pct,
            type = "scatter", mode = "lines+markers",
            line   = list(color = "#c0392b", width = 2),
            marker = list(color = "#c0392b", size = 6),
            fill   = "tozeroy",
            fillcolor = "rgba(192,57,43,0.15)",
            hovertemplate = "<b>Year:</b> %{x}<br><b>Cancer share:</b> %{y:.1f}%<extra></extra>") |>
      layout(
        xaxis = list(title = "Year", showgrid = TRUE, gridcolor = "#e0e0e0",
                     dtick = 2, tickformat = "d"),
        yaxis = list(title = "Cancer Deaths as % of All Deaths",
                     showgrid = TRUE, gridcolor = "#e0e0e0"),
        plot_bgcolor  = "#fafafa",
        paper_bgcolor = "#fafafa"
      )
  })

  # ---------- PPV Interpretation Text ----------------------------------------
  output$ppv_interpretation <- renderUI({
    res <- ppv_results()
    ppv_pct <- res$ppv * 100
    msg <- if (ppv_pct < 20) {
      tagList(
        tags$strong("\u26a0 High False Positive Rate: "),
        "A PPV below 20% indicates the majority of positive results are false positives. ",
        "This is common when disease prevalence is low. Consider raising prevalence or improving specificity."
      )
    } else if (ppv_pct >= 50) {
      tagList(
        tags$strong("\u2713 Clinically Useful: "),
        "A PPV above 50% indicates the test is clinically meaningful for this population. ",
        "More than half of positive test results correctly identify disease."
      )
    } else {
      tagList(
        tags$strong("Moderate PPV: "),
        "Between 20% and 50% of positive results correctly identify disease. ",
        "Consider the clinical context before acting on positive results."
      )
    }
    div(class = "interp-text", msg,
        br(), br(),
        tags$strong("Note on prevalence: "),
        "Low disease prevalence (as seen in population-level cancer screening) strongly reduces PPV ",
        "even when sensitivity and specificity are high. This explains why mass screening programs ",
        "often have modest PPV values \u2014 the Finnish Cancer Registry estimated ~",
        finland_2021_prevalence, " cases per 100 000 population."
    )
  })
}