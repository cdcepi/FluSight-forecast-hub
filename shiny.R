library(shiny)
library(vroom)
library(tidyverse)
library(plotly)
library(hubUtils)
library(hubVis)
library(dplyr)

load("~/Documents/2024spring/summer_reich_lab/FluSight-forecast-hub/numericaldataprediction.Rdata")


ui <- fluidPage(
  titlePanel("CDC FluSight Forecast"),
  sidebarLayout(
    sidebarPanel(
      selectInput("Outcome", "Outcome:", choices = unique(model_data$target), selected = "wk inc flu hosp"),
      selectInput("Unit", "Unit:", choices = unique(model_data$abbreviation), selected = 'CA'),
      selectInput("Interval", "Interval:", choices = c(0.5, 0.8, 0.9, 0.95)),
      checkboxGroupInput("Models", "Select Models:", choices = unique(model_data$model_id), selected = "CADPH-FluCAT_Ensemble"),
      sliderInput("Date",
                  "Dates:",
                  min = min(model_data$reference_date),
                  max = max(model_data$reference_date),
                  value = max(model_data$reference_date),
                  step = 7)
    ),
    mainPanel(
      plotOutput("fluplot"),
      verbatimTextOutput("stats")
    )
  )
)

server <- function(input, output) {

  filtered_model_data <- reactive({
    model_data %>%
      filter(abbreviation == input$Unit,
             model_id %in% input$Models,
             target == input$Outcome,
             reference_date == input$Date)|>
      mutate(target_date = as.Date(reference_date) + (horizon * 7) - 1)
  })

  filtered_target_data <- reactive({
    target_data %>%
      filter(abbreviation == input$Unit,
             date >= input$Date - months(6))
  })

  # output$fluplot <- renderPlot({
  #   hubVis::plot_step_ahead_model_output(filtered_model_data(), filtered_target_data(), interactive = FALSE, intervals = input$Interval)
  # })
  output$fluplot <- renderPlotly({
   data <- filtered_target_data()
   p <- ggplot(data, aes(x = date, y = observation)) +
     geom_point()
   ggplotly(p)
  })
}

shinyApp(ui = ui, server = server)




