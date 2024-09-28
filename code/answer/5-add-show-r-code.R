library(teal)
library(ggplot2)

custom_module_ui <- function(id) {
  ns <- NS(id)
  
  tags$div(
    shiny::selectInput(
      ns("datasets"),
      label = "select dataset",
      choices = c("iris", "mtcars")
    ),
    shiny::selectInput(
      ns("variables"),
      label = "select variable",
      choices = NULL
    ),
    shiny::plotOutput(ns("my_plot")),
    teal.widgets::verbatim_popup_ui(ns("rcode"), "Show R code")
  )
  
}

custom_module_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    
    observeEvent(input$datasets, {
      
      only_numeric <- sapply(data()[[input$datasets]], is.numeric)
      
      updateSelectInput(
        inputId = "variables",
        choices = names(data()[[input$datasets]])[only_numeric]
      )
      
    })
    
    result <- reactive({
      req(input$datasets)
      req(input$variables)
      new_data <- within(
        data(), {
          my_plot <- ggplot(input_dataset, aes(x = input_vars)) +
            geom_histogram(binwidth = 2, fill = "skyblue", color = "black")
          my_plot
        },
        input_dataset = as.name(input$datasets),
        input_vars = as.name(input$variables)        
      )
    })
    
    output$my_plot <- shiny::renderPlot({
      result()[["my_plot"]]
    })
    
    teal.widgets::verbatim_popup_srv(
      id = "rcode",
      verbatim_content = reactive(
        teal.data::get_code(result())
      ),
      title = "Example Code"
    )
    
  })
}

my_custom_module <- function(label = "My custom module") {
  module(
    label = label,
    ui = custom_module_ui,
    server = custom_module_server,
    datanames = "all"
  )
}

app <- init(
  data = teal_data(
    iris = iris,
    mtcars = mtcars,
    code = "
      iris <- iris
      mtcars <- mtcars
    "
  ),
  modules = modules(
    my_custom_module(label = "my module")
  ),
  header = "my teal app"
)

shinyApp(app$ui, app$server)
