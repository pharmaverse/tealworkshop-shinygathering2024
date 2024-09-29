library(teal)

custom_module_ui <- function(id) {
  ns <- NS(id)
  
  tags$div(
    shiny::selectInput(
      ns("datasets"),
      label = "select dataset",
      choices = c("iris", "mtcars")
    ),
    DT::dataTableOutput(ns("tbl"))
  )
  
}

custom_module_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    
    output$tbl <- DT::renderDataTable({
      data()[[input$datasets]]
    })
    
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
