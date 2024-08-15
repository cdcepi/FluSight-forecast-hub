library(shiny)
library(vroom)
library(tidyverse)
library(plotly)
library(dplyr)

classification_levels <- c("large_decrease", "decrease", "stable", "increase", "large_increase")

# Load your data
load("~/Documents/2024spring/summer_reich_lab/FluSight-forecast-hub/Categoricalshinydata.Rdata")

# Reorder model_id factor levels with specific models on top
top <- c("FluSight-baseline_cat", "FluSight-ens_q_cat", "FluSight-ensemble", "FluSight-equal_cat", "FluSight-national_cat")
remaining_models <- setdiff(unique(model_data_pmf$model_id), top)
ordered_models <- c(top, remaining_models)

model_data_pmf$model_id <- factor(model_data_pmf$model_id, levels = ordered_models)

ui <- fluidPage(
  titlePanel("FluSight Categorical Forecast"),
  tabsetPanel(
    tabPanel("Info",
             mainPanel(
               h3("Introduction towards the FluSight Categorical Forecast"),
               p("This FluSight Categorical Forecast Shiny App compares categorical prediction results with observed data. It offers two types of visualizations: model-based and horizon-based. The app displays side-by-side grid plots to visualize the model's prediction accuracy."),
               p(" For model-based data, users can select multiple models and a specific reference date to view the probability predictions for each category. A gray dot on the model indicates the observed category. The predicted dates are based on the dataset's horizon, which is the difference between the target date and the original date. The horizon sets the time range for forecast predictions, calculated as target_date = original_date + horizon*7. The dataset includes horizons of -1, 0, 1, 2, and 3, providing predictions for one week before, the original week, one week ahead, two weeks ahead, and three weeks ahead. By comparing the category with the predicted probability, users can assess each model's prediction accuracy. The plot below shows the prediction timeframe and the date range covered."),
               p("For horizon-based visualization, the app displays all models and their predicted probabilities for categories. Users can compare prediction accuracy across different horizons by multi-selecting them. This plot offers a clearer visualization of each model's categorical prediction accuracy.")
             )
    ),
    tabPanel("Model-based Facet",
             sidebarLayout(
               sidebarPanel(
                 selectInput("Unit", "Location:", choices = unique(model_data_pmf$abbreviation), selected = 'CA'),
                 checkboxGroupInput("Models", "Select Models:", choices = ordered_models, selected = top),
                 sliderInput("Date1",
                             "Dates:",
                             min = min(model_data_pmf$reference_date),
                             max = max(model_data_pmf$reference_date),
                             value = max(model_data_pmf$reference_date),
                             step = 7)
               ),
               mainPanel(
                 uiOutput("dynamicTitle1"),
                 plotOutput("fluplot"),
                 plotOutput("target_data_plot")
               )
             )
    ),
    tabPanel("Horizon-based Facet",
             sidebarLayout(
               sidebarPanel(
                 checkboxGroupInput("Horizon", "Horizon:", choices = unique(model_data_pmf$horizon), selected = c(0,1)),
                 selectInput("Unit2", "Location:", choices = unique(model_data_pmf$abbreviation), selected = 'CA'),
                 sliderInput("Date2",
                             "Dates:",
                             min = min(model_data_pmf$reference_date),
                             max = max(model_data_pmf$reference_date),
                             value = max(model_data_pmf$reference_date),
                             step = 7)
               ),
               mainPanel(
                 uiOutput("dynamicTitle2"),
                 plotOutput("fluplot_2"),
                 plotOutput("target_data_plot1")
               )
             )
    )
  )
)

server <- function(input, output) {

  # Calculate the dynamic date
  dynamic_date1 <- reactive({
    as.Date(input$Date1) - 3
  })

  dynamic_date2 <- reactive({
    as.Date(input$Date2) - 3
  })

  output$dynamicTitle1 <- renderUI({
    h3(paste("The prediction is made on", format(dynamic_date1(), "%Y-%m-%d")))
  })

  output$dynamicTitle2 <- renderUI({
    h3(paste("The prediction is made on", format(dynamic_date2(), "%Y-%m-%d")))
  })

  # Filter data based on inputs
  filtered_model_data <- reactive({
    model_data_pmf |>
      filter(abbreviation == input$Unit,
             model_id %in% input$Models,
             reference_date == input$Date1)
  })

  filtered_target_data <- reactive({
    target_data_classified |>
      filter(abbreviation == input$Unit,
             date %in% filtered_model_data()$target_end_date)
  })

  combined_data <- reactive({
    filtered_model_data() |>
      left_join(filtered_target_data(), by = c("target_end_date" = "date"))
  })

  output$fluplot <- renderPlot({
    plot_data <- combined_data()
    ggplot() +
      geom_raster(
        mapping = aes(x = target_end_date, y = output_type_id, fill = value),
        data = filtered_model_data()
      ) +
      scale_fill_viridis_c(
        breaks = seq(from = 0, to = 1, by = 0.2),
        limits = c(0, 1)
      ) +
      geom_point(
        mapping = aes(x = date, y = Classification),
        color = "#888888",
        size = 3, stroke = 2,
        data = filtered_target_data()
      ) +
      scale_fill_gradient(
        low = "yellow",
        high = "red",
        breaks = seq(from = 0, to = 1, by = 0.2),
        limits = c(0, 1)
      )+
      scale_y_discrete(limits = classification_levels) +
      facet_wrap(vars(model_id)) +
      labs(title = "Categorical Forecasts of week ahead incident hospitalizations",
           y = "Week ahead incident hospitalizations", x = "Date", fill = "Probability") +
      theme_bw()
  })

  filtered_horizon_data <- reactive({
    model_data_pmf |>
      filter(horizon %in% input$Horizon,
             abbreviation == input$Unit2,
             reference_date == input$Date2)
  })

  horizon_target_data <- reactive({
    target_data_classified |>
      filter(date %in% filtered_horizon_data()$target_end_date,
             abbreviation == input$Unit2)
  })

  combined_data2 <- reactive({
    filtered_horizon_data() |>
      left_join(horizon_target_data(), by = c("target_end_date" = "date"))
  })

  output$fluplot_2 <- renderPlot({
    # Reorder model_id levels to ensure specified models are at the top
    combined_data2_reordered <- combined_data2()
    combined_data2_reordered$model_id <- factor(
      combined_data2_reordered$model_id,
      levels = rev(ordered_models) # Ensure the specified models are at the top
    )

    ggplot() +
      geom_raster(
        mapping = aes(x = output_type_id, y = model_id, fill = value),
        data = combined_data2_reordered
      ) +
      scale_fill_gradient(
        low = "yellow",
        high = "red",
        breaks = seq(from = 0, to = 1, by = 0.2),
        limits = c(0, 1)
      ) +
      geom_point(
        mapping = aes(x = Classification, y = model_id),
        color = "#888888",
        size = 3, stroke = 2,
        data = combined_data2_reordered
      ) +
      scale_x_discrete(limits = classification_levels) +
      facet_wrap(vars(horizon)) +
      labs(title = "Categorical Forecasts of week ahead incident hospitalizations",
           y = "Models", x = "Categories", fill = "Probability") +
      theme_bw()
  })


  selected_target_data <- reactive({
    target_data_classified |>
      filter(abbreviation == input$Unit, date > as.Date("2023-10-07"))
  })

  output$target_data_plot <- renderPlot({
    data <- selected_target_data()
    filtered_data <- filtered_target_data()
    ggplot(data, aes(x = date, y = Classification)) +
      geom_point() +
      geom_rect(aes(xmin = min(filtered_data$date), xmax = max(filtered_data$date), ymin = -Inf, ymax = Inf), fill = "pink", alpha = 0.01, color = NA) +
      annotate("text", x = input$Date1, y = 2.5, label = "This is when prediction is made!", angle = 90, vjust = -0.5, color = "red") +
      geom_vline(xintercept = as.numeric(input$Date1), color = "red", linetype = "dashed") +
      labs(title = "Target Data Classification Over Time",
           x = "Date", y = "Classification") +
      scale_y_discrete(limits = classification_levels) +
      theme_bw()
  })

  output$target_data_plot1 <- renderPlot({
    data <- selected_target_data()
    filtered_data <- filtered_target_data()
    ggplot(data, aes(x = date, y = Classification)) +
      geom_point() +
      annotate("text", x = input$Date2, y = 2.5, label = "This is when prediction is made!", angle = 90, vjust = -0.5, color = "red") +
      geom_vline(xintercept = as.numeric(input$Date2), color = "red", linetype = "dashed") +
      labs(title = "Target Data Classification Over Time",
           x = "Date", y = "Classification") +
      scale_y_discrete(limits = classification_levels) +
      theme_bw()
  })

}

shinyApp(ui = ui, server = server)
