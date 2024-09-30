library(teal)

tealmodule_ui <- function(id) {
  ns <- NS(id)
  # tags$p("Hello Shiny Gathering 2024 - custom teal module")
  tags$div(
    shiny::selectInput(
      inputId = ns("datasets"),
      label = "Datasets",
      choices = NULL
    ),
    DT::dataTableOutput(ns("tbl"))
  )
}

tealmodule_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {

    updateSelectInput(
      inputId = "datasets",
      choices = datanames(data())
    )

    output$tbl <- DT::renderDataTable({
      data()[[input$datasets]]
    })

  })
}

custom_teal_module <- function(label = "My Custom Teal Module") {
  module(
    label = label,
    ui = tealmodule_ui,
    server = tealmodule_server,
    datanames = "all"
  )
}

library(teal)

data <- teal_data(
  adsl = teal.data::rADSL,
  adae = teal.data::rADAE,
  code = "
    adsl <- teal.data::rADSL
    adae <- teal.data::rADAE
  "
)

data <- verify(data)

app <- init(
  data = data,
  modules = modules(
    custom_teal_module()
  ),
  header = "my teal app"
)

shinyApp(app$ui, app$server)
