library(shiny)
library(vroom)
library(tidyverse)
library(plotly)


ui <- fluidPage(
  titlePanel("CDC FluSight Forecast"),
  sidebarLayout(
    sidebarPanel(
      selectInput("Outcome", "Outcome:", choices = unique(model_data$target), selected = "wk inc flu hosp"),
      selectInput("Unit", "Unit:", choices = unique(model_data$abbreviation), selected = 'CA'),
      selectInput("Interval", "Interval:", choices = c("0%", "50%", "95%")),
      selectInput("Models", "Select Models:", choices = unique(model_data$model_id), selected = "CADPH-FluCAT_Ensemble")
    ),
    mainPanel(
      plotOutput("fluplot"),
      verbatimTextOutput("stats")
    )
  )
)

server <- function(input, output) {

  filtered_model_data <- reactive({
    model_data|>
      filter(abbreviation == input$Unit,
             model_id %in% input$Models,
             target == input$Outcome)
  })
  filtered_target_data <- reactive({
    target_data|>
      filter(abbreviation.x == input$Unit)
  })



  output$fluplot <- renderPlot({
    ggplot() +
      geom_line(data = filtered_model_data(), aes(x = reference_date, y = value, color = "Model Data"), linetype = "dashed") +
      # Plot target data
      geom_line(data = filtered_target_data(), aes(x = date, y = value, color = "Target Data")) +
      scale_color_manual(values = c("Model Data" = "blue", "Target Data" = "red")) +
      theme_bw() +
      xlab("Date") +
      ylab("Cases") +
      ggtitle(paste("CDC FluSight Forecast for", input$Unit, "(", input$Outcome, ")")) +
      theme(legend.title = element_blank())
  })
}

#use thehubvis plotting function-could plot the interval


#when switch to plotly--not working

shinyApp(ui = ui, server = server)






#
# ui <- fluidPage(
#   fluidRow(
#     column(6,
#            selectizeInput("Outcome", "Outcome:", choices = unique(model_data$target), selected = "wk inc flu hosp"),
#            selectizeInput("Unit", "Unit:", choices = unique(model_data$locatio), selected = '06'),
#            selectInput("Interval", "Interval:", choices = c("0%", "50%", "95%")),
#            selectInput("Models", "Select Models:", choices = unique(model_data$model_id), selected = "CADPH-FluCAT_Ensemble")
#     )
#   ),
#   fluidRow(
#     column(12,
#            textOutput("selectedValue")
#     )
#   )
# )

# server <- function(input, output, session) {
#   output$selectedValue <- renderText({
#     paste("You selected:", input$Unit, input$Outcome, input$Interval, input$Models)
#   })
# }


