library(shiny)
library(vroom)
library(tidyverse)
library(plotly)
library(dplyr)

load("Categoricalshinydata.Rdata")
ui <- fluidPage(
  titlePanel("CDC FluSight Forecast"),
  sidebarLayout(
    sidebarPanel(
      selectInput("Outcome", "Outcome:", choices = unique(model_data_pmf$output_type), selected = "pmf"),
      selectInput("Unit", "Unit:", choices = unique(model_data_pmf$abbreviation), selected = 'CA'),
      checkboxGroupInput("Models", "Select Models:", choices = unique(model_data_pmf$model_id), selected = "CEPH-Rtrend_fluH"),
      sliderInput("Date",
                  "Dates:",
                  min = min(model_data_pmf$reference_date),
                  max = max(model_data_pmf$reference_date),
                  value = max(model_data_pmf$reference_date),
                  step = 7)
    ),
    mainPanel(
      p("Each grid on the plot corresponds to a predicted probability of a certain date"),
      plotOutput("fluplot"),
      verbatimTextOutput("stats")
    )
  )
)

server <- function(input, output) {

  # Filter data based on inputs
  filtered_model_data <- reactive({
    model_data_pmf|>
      filter(output_type == input$Outcome,
             abbreviation == input$Unit,
             model_id %in% input$Models,
             reference_date == input$Date)
  })

  filtered_target_data <- reactive({
    target_data_classified|>
      filter(abbreviation == input$Unit,
             date %in% filtered_model_data()$target_end_date)
  })

  combined_data <- reactive({
    filtered_model_data()|>
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
      scale_y_discrete(limits = classification_levels)+
      facet_wrap(vars(model_id))
  })

}


shinyApp(ui = ui, server = server)






